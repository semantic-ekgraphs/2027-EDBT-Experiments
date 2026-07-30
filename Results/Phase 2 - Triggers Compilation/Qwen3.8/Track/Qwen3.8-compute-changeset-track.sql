CREATE OR REPLACE FUNCTION compute_changeset_track()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_event_id        BIGINT;
    v_deleted_tuples  JSONB;
    v_inserted_tuples JSONB;
BEGIN
    /*
      Compute_Changeset_track

      Implements Algorithm 2 for R = track.

      Transition tables:
        deleted_R  = D = pre-update tuples of track
        inserted_R = I = post-update tuples of track

      This trigger function computes and publishes:
        - A−[Ψ](u) for relation-relevant rules;
        - A+[Ψ](u) for relation-relevant rules;
        - S2[Ψ](u) for relation-relevant rules;
        - Δ+[Ψ](u) for every relevant rule.

      It does NOT:
        - access GraphDB;
        - execute SPARQL;
        - retrieve S1[Ψ](u);
        - compute Δ−pivot[Ψ](u);
        - apply changesets to the RDF store.

      Those operations are executed by the asynchronous worker.
    */

    -------------------------------------------------------------------------
    -- STEP 2 (event-level queue initialization)
    -- Insert one maintenance event for this statement-level UPDATE on track.
    -------------------------------------------------------------------------
    SELECT COALESCE(jsonb_agg(to_jsonb(d)), '[]'::jsonb)
      INTO v_deleted_tuples
      FROM deleted_R d;

    SELECT COALESCE(jsonb_agg(to_jsonb(i)), '[]'::jsonb)
      INTO v_inserted_tuples
      FROM inserted_R i;

    INSERT INTO rdf_maintenance_queue (
        relation_name,
        operation_type,
        deleted_tuples,
        inserted_tuples
    )
    VALUES (
        'track',
        'UPDATE',
        v_deleted_tuples,
        v_inserted_tuples
    )
    RETURNING event_id INTO v_event_id;

    -------------------------------------------------------------------------
    -- RULE psi_track_1
    -- Type: CTR
    -- Relevance: pivot
    -- Rule:
    --   psi_track_1: mo:Track(s) ← track(tr), URI_track(tr,s)
    --
    -- URI_track(tr,s) = http://musicbrainz.org/track/{id}#_
    --
    -- Pivot-relevant contribution:
    --   Δ+pivot[Ψ](u) = quads generated from inserted pivot tuples I.
    -------------------------------------------------------------------------
    INSERT INTO rdf_rule_contribution (
        event_id,
        rule_id,
        rule_graph_uri,
        relevance_type,
        pivot_relation,
        path,
        rule_contribution
    )
    WITH dp AS (
        SELECT DISTINCT
            'http://musicbrainz.org/track/' || i.id::text || '#_' AS subject
        FROM inserted_R i
    ),
    dp_arr AS (
        SELECT COALESCE(
                   jsonb_agg(jsonb_build_object('subject', dp.subject)),
                   '[]'::jsonb
               ) AS arr
        FROM dp
    )
    SELECT
        v_event_id,
        'psi_track_1',
        'http://musicbrainz.org/graph/mapping/psi_track_1',
        'pivot',
        'track',
        '[]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_track_1',
            'rule_type', 'CTR',
            'pivot_relation', 'track',
            'class_quad_template', jsonb_build_object(
                'predicate', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
                'class', 'http://purl.org/ontology/mo/Track',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_track_1'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', COALESCE((SELECT arr FROM dp_arr), '[]'::jsonb),
                'DeltaPlus', COALESCE((SELECT arr FROM dp_arr), '[]'::jsonb)
            )
        );

    -------------------------------------------------------------------------
    -- RULE psi_track_2
    -- Type: DTR (Local-DTR)
    -- Relevance: pivot
    -- Rule:
    --   psi_track_2: mo:track_number(s,v) ←
    --       track(tr), URI_track(tr,s),
    --       nonNull(tr.position),
    --       RDFLiteral(tr.position,"position","track",v)
    --
    -- Datatype: xsd:integer
    -------------------------------------------------------------------------
    INSERT INTO rdf_rule_contribution (
        event_id,
        rule_id,
        rule_graph_uri,
        relevance_type,
        pivot_relation,
        path,
        rule_contribution
    )
    WITH dp AS (
        SELECT DISTINCT
            'http://musicbrainz.org/track/' || i.id::text || '#_' AS subject,
            i.position::text AS object
        FROM inserted_R i
        WHERE i.position IS NOT NULL
    ),
    dp_arr AS (
        SELECT COALESCE(
                   jsonb_agg(
                       jsonb_build_object(
                           'subject', dp.subject,
                           'object', dp.object
                       )
                   ),
                   '[]'::jsonb
               ) AS arr
        FROM dp
    )
    SELECT
        v_event_id,
        'psi_track_2',
        'http://musicbrainz.org/graph/mapping/psi_track_2',
        'pivot',
        'track',
        '[]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_track_2',
            'rule_type', 'DTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', '[]'::jsonb,
                'A_plus', '[]'::jsonb
            ),
            'datatype_quad_template', jsonb_build_object(
                'predicate', 'http://purl.org/ontology/mo/track_number',
                'datatype', 'http://www.w3.org/2001/XMLSchema#integer',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_track_2'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', COALESCE((SELECT arr FROM dp_arr), '[]'::jsonb),
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', COALESCE((SELECT arr FROM dp_arr), '[]'::jsonb)
            )
        );

    -------------------------------------------------------------------------
    -- RULE psi_track_3
    -- Type: DTR (Local-DTR)
    -- Relevance: pivot
    -- Rule:
    --   psi_track_3: dc:title(s,v) ←
    --       track(tr), URI_track(tr,s),
    --       nonNull(tr.name),
    --       RDFLiteral(tr.name,"name","track",v)
    --
    -- Datatype: xsd:string
    -------------------------------------------------------------------------
    INSERT INTO rdf_rule_contribution (
        event_id,
        rule_id,
        rule_graph_uri,
        relevance_type,
        pivot_relation,
        path,
        rule_contribution
    )
    WITH dp AS (
        SELECT DISTINCT
            'http://musicbrainz.org/track/' || i.id::text || '#_' AS subject,
            i.name::text AS object
        FROM inserted_R i
        WHERE i.name IS NOT NULL
    ),
    dp_arr AS (
        SELECT COALESCE(
                   jsonb_agg(
                       jsonb_build_object(
                           'subject', dp.subject,
                           'object', dp.object
                       )
                   ),
                   '[]'::jsonb
               ) AS arr
        FROM dp
    )
    SELECT
        v_event_id,
        'psi_track_3',
        'http://musicbrainz.org/graph/mapping/psi_track_3',
        'pivot',
        'track',
        '[]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_track_3',
            'rule_type', 'DTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', '[]'::jsonb,
                'A_plus', '[]'::jsonb
            ),
            'datatype_quad_template', jsonb_build_object(
                'predicate', 'http://purl.org/dc/elements/1.1/title',
                'datatype', 'http://www.w3.org/2001/XMLSchema#string',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_track_3'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', COALESCE((SELECT arr FROM dp_arr), '[]'::jsonb),
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', COALESCE((SELECT arr FROM dp_arr), '[]'::jsonb)
            )
        );

    -------------------------------------------------------------------------
    -- RULE psi_track_4
    -- Type: DTR (Local-DTR)
    -- Relevance: pivot
    -- Rule:
    --   psi_track_4: mo:duration(s,v) ←
    --       track(tr), URI_track(tr,s),
    --       nonNull(tr.length),
    --       RDFLiteral(tr.length,"length","track",v),
    --       tr.length IS NOT NULL
    --
    -- Datatype: xsd:integer
    -------------------------------------------------------------------------
    INSERT INTO rdf_rule_contribution (
        event_id,
        rule_id,
        rule_graph_uri,
        relevance_type,
        pivot_relation,
        path,
        rule_contribution
    )
    WITH dp AS (
        SELECT DISTINCT
            'http://musicbrainz.org/track/' || i.id::text || '#_' AS subject,
            i.length::text AS object
        FROM inserted_R i
        WHERE i.length IS NOT NULL
    ),
    dp_arr AS (
        SELECT COALESCE(
                   jsonb_agg(
                       jsonb_build_object(
                           'subject', dp.subject,
                           'object', dp.object
                       )
                   ),
                   '[]'::jsonb
               ) AS arr
        FROM dp
    )
    SELECT
        v_event_id,
        'psi_track_4',
        'http://musicbrainz.org/graph/mapping/psi_track_4',
        'pivot',
        'track',
        '[]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_track_4',
            'rule_type', 'DTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', '[]'::jsonb,
                'A_plus', '[]'::jsonb
            ),
            'datatype_quad_template', jsonb_build_object(
                'predicate', 'http://purl.org/ontology/mo/duration',
                'datatype', 'http://www.w3.org/2001/XMLSchema#integer',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_track_4'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', COALESCE((SELECT arr FROM dp_arr), '[]'::jsonb),
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', COALESCE((SELECT arr FROM dp_arr), '[]'::jsonb)
            )
        );

    -------------------------------------------------------------------------
    -- RULE psi_track_5
    -- Type: OTR
    -- Relevance: pivot
    -- Rule:
    --   psi_track_5: mo:publication_of(s,o) ←
    --       track(tr), URI_track(tr,s),
    --       recording(rec), URI_recording(rec,o),
    --       [track_fk_recording](tr,rec)
    --
    -- Subject URI: http://musicbrainz.org/track/{track.id}#_
    -- Object URI:  http://musicbrainz.org/recording/{recording.gid}#_
    --
    -- Pivot-relevant contribution:
    --   Δ+pivot[Ψ](u) = quads generated from inserted track tuples
    --                   joined to recording in σ1.
    -------------------------------------------------------------------------
    INSERT INTO rdf_rule_contribution (
        event_id,
        rule_id,
        rule_graph_uri,
        relevance_type,
        pivot_relation,
        path,
        rule_contribution
    )
    WITH dp AS (
        SELECT DISTINCT
            'http://musicbrainz.org/track/' || i.id::text || '#_' AS subject,
            'http://musicbrainz.org/recording/' || r.gid::text || '#_' AS object
        FROM inserted_R i
        JOIN recording r
          ON r.id = i.recording
    ),
    dp_arr AS (
        SELECT COALESCE(
                   jsonb_agg(
                       jsonb_build_object(
                           'subject', dp.subject,
                           'object', dp.object
                       )
                   ),
                   '[]'::jsonb
               ) AS arr
        FROM dp
    )
    SELECT
        v_event_id,
        'psi_track_5',
        'http://musicbrainz.org/graph/mapping/psi_track_5',
        'pivot',
        'track',
        '["track_fk_recording"]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_track_5',
            'rule_type', 'OTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', '[]'::jsonb,
                'A_plus', '[]'::jsonb
            ),
            'object_quad_template', jsonb_build_object(
                'predicate', 'http://purl.org/ontology/mo/publication_of',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_track_5'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', COALESCE((SELECT arr FROM dp_arr), '[]'::jsonb),
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', COALESCE((SELECT arr FROM dp_arr), '[]'::jsonb)
            )
        );

    -------------------------------------------------------------------------
    -- RULE psi_artist_11
    -- Type: OTR
    -- Relevance: relation
    -- Rule:
    --   psi_artist_11: foaf:made(s,o) ←
    --       artist(a), URI_artist(a,s),
    --       track(t), URI_track(t,o),
    --       [artist_credit_name_fk_artist^-1,
    --        artist_credit_name_fk_artist_credit,
    --        track_fk_artist_credit^-1](a,t)
    --
    -- Subject URI: http://musicbrainz.org/artist/{artist.gid}#_
    -- Object URI:  http://musicbrainz.org/track/{track.id}#_
    --
    -- Relation-relevant contributions:
    --   A−: artist pivot tuples affected by deleted track tuples.
    --   A+: artist pivot tuples affected by inserted track tuples.
    --   S2: post-update RDF contribution for every pivot tuple in A−.
    --   Δ+rel: post-update RDF contribution for every pivot tuple in A+.
    -------------------------------------------------------------------------
    INSERT INTO rdf_rule_contribution (
        event_id,
        rule_id,
        rule_graph_uri,
        relevance_type,
        pivot_relation,
        path,
        rule_contribution
    )
    WITH affected_minus AS (
        SELECT DISTINCT
            a.id  AS pivot_id,
            a.gid AS pivot_gid
        FROM deleted_R d
        JOIN artist_credit ac
          ON ac.id = d.artist_credit
        JOIN artist_credit_name acn
          ON acn.artist_credit = ac.id
        JOIN artist a
          ON a.id = acn.artist
    ),
    affected_plus AS (
        SELECT DISTINCT
            a.id  AS pivot_id,
            a.gid AS pivot_gid
        FROM inserted_R i
        JOIN artist_credit ac
          ON ac.id = i.artist_credit
        JOIN artist_credit_name acn
          ON acn.artist_credit = ac.id
        JOIN artist a
          ON a.id = acn.artist
    ),
    s2 AS (
        SELECT DISTINCT
            'http://musicbrainz.org/artist/' || a.gid::text || '#_' AS subject,
            'http://musicbrainz.org/track/' || t.id::text || '#_' AS object
        FROM affected_minus am
        JOIN artist a
          ON a.id = am.pivot_id
        JOIN artist_credit_name acn
          ON acn.artist = a.id
        JOIN artist_credit ac
          ON ac.id = acn.artist_credit
        JOIN track t
          ON t.artist_credit = ac.id
    ),
    delta_plus_rel AS (
        SELECT DISTINCT
            'http://musicbrainz.org/artist/' || a.gid::text || '#_' AS subject,
            'http://musicbrainz.org/track/' || t.id::text || '#_' AS object
        FROM affected_plus ap
        JOIN artist a
          ON a.id = ap.pivot_id
        JOIN artist_credit_name acn
          ON acn.artist = a.id
        JOIN artist_credit ac
          ON ac.id = acn.artist_credit
        JOIN track t
          ON t.artist_credit = ac.id
    ),
    am_arr AS (
        SELECT COALESCE(
                   jsonb_agg(
                       jsonb_build_object(
                           'id', affected_minus.pivot_id,
                           'gid', affected_minus.pivot_gid
                       )
                   ),
                   '[]'::jsonb
               ) AS arr
        FROM affected_minus
    ),
    ap_arr AS (
        SELECT COALESCE(
                   jsonb_agg(
                       jsonb_build_object(
                           'id', affected_plus.pivot_id,
                           'gid', affected_plus.pivot_gid
                       )
                   ),
                   '[]'::jsonb
               ) AS arr
        FROM affected_plus
    ),
    s2_arr AS (
        SELECT COALESCE(
                   jsonb_agg(
                       jsonb_build_object(
                           'subject', s2.subject,
                           'object', s2.object
                       )
                   ),
                   '[]'::jsonb
               ) AS arr
        FROM s2
    ),
    dpr_arr AS (
        SELECT COALESCE(
                   jsonb_agg(
                       jsonb_build_object(
                           'subject', delta_plus_rel.subject,
                           'object', delta_plus_rel.object
                       )
                   ),
                   '[]'::jsonb
               ) AS arr
        FROM delta_plus_rel
    )
    SELECT
        v_event_id,
        'psi_artist_11',
        'http://musicbrainz.org/graph/mapping/psi_artist_11',
        'relation',
        'artist',
        '["artist_credit_name_fk_artist^-1","artist_credit_name_fk_artist_credit","track_fk_artist_credit^-1"]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_artist_11',
            'rule_type', 'OTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', COALESCE((SELECT arr FROM am_arr), '[]'::jsonb),
                'A_plus', COALESCE((SELECT arr FROM ap_arr), '[]'::jsonb)
            ),
            'object_quad_template', jsonb_build_object(
                'predicate', 'http://xmlns.com/foaf/0.1/made',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_11'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', '[]'::jsonb,
                'S2', COALESCE((SELECT arr FROM s2_arr), '[]'::jsonb),
                'DeltaPlusRel', COALESCE((SELECT arr FROM dpr_arr), '[]'::jsonb),
                'DeltaPlus', COALESCE((SELECT arr FROM dpr_arr), '[]'::jsonb)
            )
        );

    -------------------------------------------------------------------------
    -- RULE psi_medium_4
    -- Type: OTR
    -- Relevance: relation
    -- Rule:
    --   psi_medium_4: mo:track(s,o) ←
    --       medium(m), URI_medium(m,s),
    --       track(tr), URI_track(tr,o),
    --       [track_fk_medium^-1](m,tr)
    --
    -- Subject URI: http://musicbrainz.org/record/{medium.id}#_
    -- Object URI:  http://musicbrainz.org/track/{track.id}#_
    --
    -- Relation-relevant contributions:
    --   A−: medium pivot tuples affected by deleted track tuples.
    --   A+: medium pivot tuples affected by inserted track tuples.
    --   S2: post-update RDF contribution for every pivot tuple in A−.
    --   Δ+rel: post-update RDF contribution for every pivot tuple in A+.
    -------------------------------------------------------------------------
    INSERT INTO rdf_rule_contribution (
        event_id,
        rule_id,
        rule_graph_uri,
        relevance_type,
        pivot_relation,
        path,
        rule_contribution
    )
    WITH affected_minus AS (
        SELECT DISTINCT
            m.id AS pivot_id
        FROM deleted_R d
        JOIN medium m
          ON m.id = d.medium
    ),
    affected_plus AS (
        SELECT DISTINCT
            m.id AS pivot_id
        FROM inserted_R i
        JOIN medium m
          ON m.id = i.medium
    ),
    s2 AS (
        SELECT DISTINCT
            'http://musicbrainz.org/record/' || m.id::text || '#_' AS subject,
            'http://musicbrainz.org/track/' || t.id::text || '#_' AS object
        FROM affected_minus am
        JOIN medium m
          ON m.id = am.pivot_id
        JOIN track t
          ON t.medium = m.id
    ),
    delta_plus_rel AS (
        SELECT DISTINCT
            'http://musicbrainz.org/record/' || m.id::text || '#_' AS subject,
            'http://musicbrainz.org/track/' || t.id::text || '#_' AS object
        FROM affected_plus ap
        JOIN medium m
          ON m.id = ap.pivot_id
        JOIN track t
          ON t.medium = m.id
    ),
    am_arr AS (
        SELECT COALESCE(
                   jsonb_agg(
                       jsonb_build_object(
                           'id', affected_minus.pivot_id
                       )
                   ),
                   '[]'::jsonb
               ) AS arr
        FROM affected_minus
    ),
    ap_arr AS (
        SELECT COALESCE(
                   jsonb_agg(
                       jsonb_build_object(
                           'id', affected_plus.pivot_id
                       )
                   ),
                   '[]'::jsonb
               ) AS arr
        FROM affected_plus
    ),
    s2_arr AS (
        SELECT COALESCE(
                   jsonb_agg(
                       jsonb_build_object(
                           'subject', s2.subject,
                           'object', s2.object
                       )
                   ),
                   '[]'::jsonb
               ) AS arr
        FROM s2
    ),
    dpr_arr AS (
        SELECT COALESCE(
                   jsonb_agg(
                       jsonb_build_object(
                           'subject', delta_plus_rel.subject,
                           'object', delta_plus_rel.object
                       )
                   ),
                   '[]'::jsonb
               ) AS arr
        FROM delta_plus_rel
    )
    SELECT
        v_event_id,
        'psi_medium_4',
        'http://musicbrainz.org/graph/mapping/psi_medium_4',
        'relation',
        'medium',
        '["track_fk_medium^-1"]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_medium_4',
            'rule_type', 'OTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', COALESCE((SELECT arr FROM am_arr), '[]'::jsonb),
                'A_plus', COALESCE((SELECT arr FROM ap_arr), '[]'::jsonb)
            ),
            'object_quad_template', jsonb_build_object(
                'predicate', 'http://purl.org/ontology/mo/track',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_medium_4'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', '[]'::jsonb,
                'S2', COALESCE((SELECT arr FROM s2_arr), '[]'::jsonb),
                'DeltaPlusRel', COALESCE((SELECT arr FROM dpr_arr), '[]'::jsonb),
                'DeltaPlus', COALESCE((SELECT arr FROM dpr_arr), '[]'::jsonb)
            )
        );

    -------------------------------------------------------------------------
    -- AFTER FOR EACH STATEMENT trigger functions must return NULL.
    -- The effective output is the rows inserted into:
    --   rdf_maintenance_queue
    --   rdf_rule_contribution
    -------------------------------------------------------------------------
    RETURN NULL;
END;
$$;