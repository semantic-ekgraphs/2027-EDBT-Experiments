/*
 * Phase 2 - Trigger Compilation Agent
 * Relation R = artist
 *
 * Relevant rules:
 *   Pivot:    psi_artist_1..psi_artist_11, psi_artist_13, psi_artist_14
 *             (psi_artist_12 is not present in the authoritative workbook)
 *   Relation: psi_artist_tag_2
 *
 * The function accesses PostgreSQL only. GraphDB/SPARQL work remains assigned
 * to the asynchronous worker.
 */

CREATE OR REPLACE FUNCTION compute_changeset_artist()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
    v_event_id bigint;
BEGIN
    /* Algorithm 2, publication step: exactly one queue event per statement. */
    INSERT INTO rdf_maintenance_queue (
        relation_name,
        operation_type,
        deleted_tuples,
        inserted_tuples
    )
    VALUES (
        'artist',
        'UPDATE',
        COALESCE(
            (SELECT jsonb_agg(to_jsonb(d)) FROM deleted_artist AS d),
            '[]'::jsonb
        ),
        COALESCE(
            (SELECT jsonb_agg(to_jsonb(i)) FROM inserted_artist AS i),
            '[]'::jsonb
        )
    )
    RETURNING event_id INTO v_event_id;

    /*
     * psi_artist_1 - pivot-relevant CTR
     * DeltaPlusPivot = psi_artist_1(inserted_artist), evaluated in sigma_1.
     */
    INSERT INTO rdf_rule_contribution (
        event_id, rule_id, rule_graph_uri, relevance_type,
        pivot_relation, path, rule_contribution
    )
    SELECT
        v_event_id,
        'psi_artist_1',
        'http://musicbrainz.org/graph/mapping/psi_artist_1',
        'pivot',
        'artist',
        '[]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_artist_1',
            'rule_type', 'CTR',
            'pivot_relation', 'artist',
            'class_quad_template', jsonb_build_object(
                'predicate', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
                'class', 'http://purl.org/ontology/mo/MusicArtist',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_1'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', q.contribution,
                'DeltaPlus', q.contribution
            )
        )
    FROM (
        SELECT COALESCE(
            jsonb_agg(DISTINCT jsonb_build_object(
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '#_'
            )),
            '[]'::jsonb
        ) AS contribution
        FROM inserted_artist AS i
    ) AS q;

    /* psi_artist_2 - pivot-relevant Local-DTR, xsd:string. */
    INSERT INTO rdf_rule_contribution (
        event_id, rule_id, rule_graph_uri, relevance_type,
        pivot_relation, path, rule_contribution
    )
    SELECT
        v_event_id,
        'psi_artist_2',
        'http://musicbrainz.org/graph/mapping/psi_artist_2',
        'pivot',
        'artist',
        '[]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_artist_2',
            'rule_type', 'DTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', '[]'::jsonb,
                'A_plus', '[]'::jsonb
            ),
            'datatype_quad_template', jsonb_build_object(
                'predicate', 'http://purl.org/ontology/mo/musicbrainz_guid',
                'datatype', 'http://www.w3.org/2001/XMLSchema#string',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_2'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', q.contribution,
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', q.contribution
            )
        )
    FROM (
        SELECT COALESCE(
            jsonb_agg(DISTINCT jsonb_build_object(
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '#_',
                'object', i.gid::text
            )),
            '[]'::jsonb
        ) AS contribution
        FROM inserted_artist AS i
        WHERE i.gid IS NOT NULL
    ) AS q;

    /* psi_artist_3 - pivot-relevant Local-DTR, xsd:string. */
    INSERT INTO rdf_rule_contribution (
        event_id, rule_id, rule_graph_uri, relevance_type,
        pivot_relation, path, rule_contribution
    )
    SELECT
        v_event_id,
        'psi_artist_3',
        'http://musicbrainz.org/graph/mapping/psi_artist_3',
        'pivot',
        'artist',
        '[]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_artist_3',
            'rule_type', 'DTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', '[]'::jsonb,
                'A_plus', '[]'::jsonb
            ),
            'datatype_quad_template', jsonb_build_object(
                'predicate', 'http://xmlns.com/foaf/0.1/name',
                'datatype', 'http://www.w3.org/2001/XMLSchema#string',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_3'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', q.contribution,
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', q.contribution
            )
        )
    FROM (
        SELECT COALESCE(
            jsonb_agg(DISTINCT jsonb_build_object(
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '#_',
                'object', i.name
            )),
            '[]'::jsonb
        ) AS contribution
        FROM inserted_artist AS i
        WHERE i.name IS NOT NULL
    ) AS q;

    /* psi_artist_4 - pivot-relevant Local-DTR, xsd:string. */
    INSERT INTO rdf_rule_contribution (
        event_id, rule_id, rule_graph_uri, relevance_type,
        pivot_relation, path, rule_contribution
    )
    SELECT
        v_event_id,
        'psi_artist_4',
        'http://musicbrainz.org/graph/mapping/psi_artist_4',
        'pivot',
        'artist',
        '[]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_artist_4',
            'rule_type', 'DTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', '[]'::jsonb,
                'A_plus', '[]'::jsonb
            ),
            'datatype_quad_template', jsonb_build_object(
                'predicate', 'http://open.vocab.org/terms/sortLabel',
                'datatype', 'http://www.w3.org/2001/XMLSchema#string',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_4'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', q.contribution,
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', q.contribution
            )
        )
    FROM (
        SELECT COALESCE(
            jsonb_agg(DISTINCT jsonb_build_object(
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '#_',
                'object', i.sort_name
            )),
            '[]'::jsonb
        ) AS contribution
        FROM inserted_artist AS i
        WHERE i.sort_name IS NOT NULL
    ) AS q;

    /* psi_artist_5 - pivot-relevant CTR with selection artist.type = 1. */
    INSERT INTO rdf_rule_contribution (
        event_id, rule_id, rule_graph_uri, relevance_type,
        pivot_relation, path, rule_contribution
    )
    SELECT
        v_event_id,
        'psi_artist_5',
        'http://musicbrainz.org/graph/mapping/psi_artist_5',
        'pivot',
        'artist',
        '[]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_artist_5',
            'rule_type', 'CTR',
            'pivot_relation', 'artist',
            'class_quad_template', jsonb_build_object(
                'predicate', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
                'class', 'http://purl.org/ontology/mo/SoloMusicArtist',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_5'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', q.contribution,
                'DeltaPlus', q.contribution
            )
        )
    FROM (
        SELECT COALESCE(
            jsonb_agg(DISTINCT jsonb_build_object(
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '#_'
            )),
            '[]'::jsonb
        ) AS contribution
        FROM inserted_artist AS i
        WHERE i.type = 1
    ) AS q;

    /* psi_artist_6 - pivot-relevant CTR with selection artist.type = 2. */
    INSERT INTO rdf_rule_contribution (
        event_id, rule_id, rule_graph_uri, relevance_type,
        pivot_relation, path, rule_contribution
    )
    SELECT
        v_event_id,
        'psi_artist_6',
        'http://musicbrainz.org/graph/mapping/psi_artist_6',
        'pivot',
        'artist',
        '[]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_artist_6',
            'rule_type', 'CTR',
            'pivot_relation', 'artist',
            'class_quad_template', jsonb_build_object(
                'predicate', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
                'class', 'http://purl.org/ontology/mo/MusicGroup',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_6'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', q.contribution,
                'DeltaPlus', q.contribution
            )
        )
    FROM (
        SELECT COALESCE(
            jsonb_agg(DISTINCT jsonb_build_object(
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '#_'
            )),
            '[]'::jsonb
        ) AS contribution
        FROM inserted_artist AS i
        WHERE i.type = 2
    ) AS q;

    /*
     * psi_artist_7 - pivot-relevant Path-DTR.
     * [artist_fk_gender] means artist.gender = gender.id.
     */
    INSERT INTO rdf_rule_contribution (
        event_id, rule_id, rule_graph_uri, relevance_type,
        pivot_relation, path, rule_contribution
    )
    SELECT
        v_event_id,
        'psi_artist_7',
        'http://musicbrainz.org/graph/mapping/psi_artist_7',
        'pivot',
        'artist',
        '["artist_fk_gender"]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_artist_7',
            'rule_type', 'DTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', '[]'::jsonb,
                'A_plus', '[]'::jsonb
            ),
            'datatype_quad_template', jsonb_build_object(
                'predicate', 'http://xmlns.com/foaf/0.1/gender',
                'datatype', 'http://www.w3.org/2001/XMLSchema#string',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_7'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', q.contribution,
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', q.contribution
            )
        )
    FROM (
        SELECT COALESCE(
            jsonb_agg(DISTINCT jsonb_build_object(
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '#_',
                'object', lower(g.name)
            )),
            '[]'::jsonb
        ) AS contribution
        FROM inserted_artist AS i
        JOIN gender AS g
          ON g.id = i.gender
        WHERE g.name IS NOT NULL
    ) AS q;

    /*
     * psi_artist_8 - pivot-relevant OTR.
     * [artist_fk_area] means artist.area = area.id.
     */
    INSERT INTO rdf_rule_contribution (
        event_id, rule_id, rule_graph_uri, relevance_type,
        pivot_relation, path, rule_contribution
    )
    SELECT
        v_event_id,
        'psi_artist_8',
        'http://musicbrainz.org/graph/mapping/psi_artist_8',
        'pivot',
        'artist',
        '["artist_fk_area"]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_artist_8',
            'rule_type', 'OTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', '[]'::jsonb,
                'A_plus', '[]'::jsonb
            ),
            'object_quad_template', jsonb_build_object(
                'predicate', 'http://xmlns.com/foaf/0.1/based_near',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_8'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', q.contribution,
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', q.contribution
            )
        )
    FROM (
        SELECT COALESCE(
            jsonb_agg(DISTINCT jsonb_build_object(
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '#_',
                'object', 'http://musicbrainz.org/area/' || ar.gid::text || '#_'
            )),
            '[]'::jsonb
        ) AS contribution
        FROM inserted_artist AS i
        JOIN area AS ar
          ON ar.id = i.area
    ) AS q;

    /*
     * psi_artist_9 - pivot-relevant OTR.
     * artist -> artist_credit_name -> artist_credit -> release_group.
     */
    INSERT INTO rdf_rule_contribution (
        event_id, rule_id, rule_graph_uri, relevance_type,
        pivot_relation, path, rule_contribution
    )
    SELECT
        v_event_id,
        'psi_artist_9',
        'http://musicbrainz.org/graph/mapping/psi_artist_9',
        'pivot',
        'artist',
        '["artist_credit_name_fk_artist^-1","artist_credit_name_fk_artist_credit","release_group_fk_artist_credit^-1"]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_artist_9',
            'rule_type', 'OTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', '[]'::jsonb,
                'A_plus', '[]'::jsonb
            ),
            'object_quad_template', jsonb_build_object(
                'predicate', 'http://xmlns.com/foaf/0.1/made',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_9'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', q.contribution,
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', q.contribution
            )
        )
    FROM (
        SELECT COALESCE(
            jsonb_agg(DISTINCT jsonb_build_object(
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '#_',
                'object', 'http://musicbrainz.org/signal-group/' || rg.gid::text || '#_'
            )),
            '[]'::jsonb
        ) AS contribution
        FROM inserted_artist AS i
        JOIN artist_credit_name AS acn
          ON acn.artist = i.id
        JOIN release_group AS rg
          ON rg.artist_credit = acn.artist_credit
    ) AS q;

    /*
     * psi_artist_10 - pivot-relevant OTR.
     * artist -> artist_credit_name -> artist_credit -> release.
     */
    INSERT INTO rdf_rule_contribution (
        event_id, rule_id, rule_graph_uri, relevance_type,
        pivot_relation, path, rule_contribution
    )
    SELECT
        v_event_id,
        'psi_artist_10',
        'http://musicbrainz.org/graph/mapping/psi_artist_10',
        'pivot',
        'artist',
        '["artist_credit_name_fk_artist^-1","artist_credit_name_fk_artist_credit","release_fk_artist_credit^-1"]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_artist_10',
            'rule_type', 'OTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', '[]'::jsonb,
                'A_plus', '[]'::jsonb
            ),
            'object_quad_template', jsonb_build_object(
                'predicate', 'http://xmlns.com/foaf/0.1/made',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_10'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', q.contribution,
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', q.contribution
            )
        )
    FROM (
        SELECT COALESCE(
            jsonb_agg(DISTINCT jsonb_build_object(
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '#_',
                'object', 'http://musicbrainz.org/release/' || rel.gid::text || '#_'
            )),
            '[]'::jsonb
        ) AS contribution
        FROM inserted_artist AS i
        JOIN artist_credit_name AS acn
          ON acn.artist = i.id
        JOIN release AS rel
          ON rel.artist_credit = acn.artist_credit
    ) AS q;

    /*
     * psi_artist_11 - pivot-relevant OTR.
     * artist -> artist_credit_name -> artist_credit -> track.
     */
    INSERT INTO rdf_rule_contribution (
        event_id, rule_id, rule_graph_uri, relevance_type,
        pivot_relation, path, rule_contribution
    )
    SELECT
        v_event_id,
        'psi_artist_11',
        'http://musicbrainz.org/graph/mapping/psi_artist_11',
        'pivot',
        'artist',
        '["artist_credit_name_fk_artist^-1","artist_credit_name_fk_artist_credit","track_fk_artist_credit^-1"]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_artist_11',
            'rule_type', 'OTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', '[]'::jsonb,
                'A_plus', '[]'::jsonb
            ),
            'object_quad_template', jsonb_build_object(
                'predicate', 'http://xmlns.com/foaf/0.1/made',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_11'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', q.contribution,
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', q.contribution
            )
        )
    FROM (
        SELECT COALESCE(
            jsonb_agg(DISTINCT jsonb_build_object(
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '#_',
                'object', 'http://musicbrainz.org/track/' || t.id::text || '#_'
            )),
            '[]'::jsonb
        ) AS contribution
        FROM inserted_artist AS i
        JOIN artist_credit_name AS acn
          ON acn.artist = i.id
        JOIN track AS t
          ON t.artist_credit = acn.artist_credit
    ) AS q;

    /*
     * psi_artist_13 - pivot-relevant OTR.
     * artist -> artist_credit_name -> artist_credit -> recording.
     */
    INSERT INTO rdf_rule_contribution (
        event_id, rule_id, rule_graph_uri, relevance_type,
        pivot_relation, path, rule_contribution
    )
    SELECT
        v_event_id,
        'psi_artist_13',
        'http://musicbrainz.org/graph/mapping/psi_artist_13',
        'pivot',
        'artist',
        '["artist_credit_name_fk_artist^-1","artist_credit_name_fk_artist_credit","recording_fk_artist_credit^-1"]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_artist_13',
            'rule_type', 'OTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', '[]'::jsonb,
                'A_plus', '[]'::jsonb
            ),
            'object_quad_template', jsonb_build_object(
                'predicate', 'http://xmlns.com/foaf/0.1/made',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_13'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', q.contribution,
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', q.contribution
            )
        )
    FROM (
        SELECT COALESCE(
            jsonb_agg(DISTINCT jsonb_build_object(
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '#_',
                'object', 'http://musicbrainz.org/recording/' || rec.gid::text || '#_'
            )),
            '[]'::jsonb
        ) AS contribution
        FROM inserted_artist AS i
        JOIN artist_credit_name AS acn
          ON acn.artist = i.id
        JOIN recording AS rec
          ON rec.artist_credit = acn.artist_credit
    ) AS q;

    /*
     * psi_artist_14 - pivot-relevant Path-DTR.
     * artist -> artist_annotation -> annotation.
     */
    INSERT INTO rdf_rule_contribution (
        event_id, rule_id, rule_graph_uri, relevance_type,
        pivot_relation, path, rule_contribution
    )
    SELECT
        v_event_id,
        'psi_artist_14',
        'http://musicbrainz.org/graph/mapping/psi_artist_14',
        'pivot',
        'artist',
        '["artist_annotation_fk_artist^-1","artist_annotation_fk_annotation"]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_artist_14',
            'rule_type', 'DTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', '[]'::jsonb,
                'A_plus', '[]'::jsonb
            ),
            'datatype_quad_template', jsonb_build_object(
                'predicate', 'http://www.w3.org/2000/01/rdf-schema#comment',
                'datatype', 'http://www.w3.org/2001/XMLSchema#string',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_14'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', q.contribution,
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', q.contribution
            )
        )
    FROM (
        SELECT COALESCE(
            jsonb_agg(DISTINCT jsonb_build_object(
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '#_',
                'object', an.text
            )),
            '[]'::jsonb
        ) AS contribution
        FROM inserted_artist AS i
        JOIN artist_annotation AS aa
          ON aa.artist = i.id
        JOIN annotation AS an
          ON an.id = aa.annotation
        WHERE an.text IS NOT NULL
    ) AS q;

    /*
     * psi_artist_tag_2 - relation-relevant OTR.
     *
     * A_minus: artist_tag pivots whose artist is in deleted_artist.
     * A_plus:  artist_tag pivots whose artist is in inserted_artist.
     * S2:      post-update contribution of A_minus, evaluated in sigma_1.
     * DeltaPlusRel: contribution of A_plus, evaluated in sigma_1.
     * DeltaPlusPivot is empty because pivot(psi_artist_tag_2) = artist_tag.
     */
    INSERT INTO rdf_rule_contribution (
        event_id, rule_id, rule_graph_uri, relevance_type,
        pivot_relation, path, rule_contribution
    )
    WITH
    a_minus AS (
        SELECT COALESCE(
            jsonb_agg(DISTINCT to_jsonb(at)),
            '[]'::jsonb
        ) AS tuples
        FROM artist_tag AS at
        JOIN deleted_artist AS d
          ON d.id = at.artist
    ),
    a_plus AS (
        SELECT COALESCE(
            jsonb_agg(DISTINCT to_jsonb(at)),
            '[]'::jsonb
        ) AS tuples
        FROM artist_tag AS at
        JOIN inserted_artist AS i
          ON i.id = at.artist
    ),
    s2 AS (
        SELECT COALESCE(
            jsonb_agg(DISTINCT jsonb_build_object(
                'subject',
                    'http://musicbrainz.org/artist/' || a.gid::text ||
                    '#tag/' || t.name,
                'object',
                    'http://musicbrainz.org/artist/' || a.gid::text || '#_'
            )),
            '[]'::jsonb
        ) AS contribution
        FROM artist_tag AS at
        JOIN deleted_artist AS d
          ON d.id = at.artist
        JOIN artist AS a
          ON a.id = at.artist
        JOIN tag AS t
          ON t.id = at.tag
    ),
    delta_plus_rel AS (
        SELECT COALESCE(
            jsonb_agg(DISTINCT jsonb_build_object(
                'subject',
                    'http://musicbrainz.org/artist/' || a.gid::text ||
                    '#tag/' || t.name,
                'object',
                    'http://musicbrainz.org/artist/' || a.gid::text || '#_'
            )),
            '[]'::jsonb
        ) AS contribution
        FROM artist_tag AS at
        JOIN inserted_artist AS i
          ON i.id = at.artist
        JOIN artist AS a
          ON a.id = at.artist
        JOIN tag AS t
          ON t.id = at.tag
    )
    SELECT
        v_event_id,
        'psi_artist_tag_2',
        'http://musicbrainz.org/graph/mapping/psi_artist_tag_2',
        'relation',
        'artist_tag',
        '["artist_tag_fk_artist"]'::jsonb,
        jsonb_build_object(
            'rule_id', 'psi_artist_tag_2',
            'rule_type', 'OTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', a_minus.tuples,
                'A_plus', a_plus.tuples
            ),
            'object_quad_template', jsonb_build_object(
                'predicate', 'http://purl.org/muto/core#taggedResource',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_tag_2'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', '[]'::jsonb,
                'S2', s2.contribution,
                'DeltaPlusRel', delta_plus_rel.contribution,
                'DeltaPlus', delta_plus_rel.contribution
            )
        )
    FROM a_minus
    CROSS JOIN a_plus
    CROSS JOIN s2
    CROSS JOIN delta_plus_rel;

    /*
     * AFTER FOR EACH STATEMENT trigger functions ignore their return value.
     * The observable result is the queue publication above.
     */
    RETURN NULL;
END;
$function$;

DROP TRIGGER IF EXISTS trg_compute_changeset_artist_after_update ON artist;

CREATE TRIGGER trg_compute_changeset_artist_after_update
AFTER UPDATE ON artist
REFERENCING
    OLD TABLE AS deleted_artist
    NEW TABLE AS inserted_artist
FOR EACH STATEMENT
EXECUTE FUNCTION compute_changeset_artist();
