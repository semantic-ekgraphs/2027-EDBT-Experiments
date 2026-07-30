/*
 * Phase 2 - Trigger Compilation Agent
 * Relation R = track
 *
 * Preconditions:
 *   - rdf_maintenance_queue and rdf_rule_contribution already exist;
 *   - the MusicBrainz tables are visible in the function's search_path;
 *   - the trigger is attached to the same track table used by the rules.
 *
 * The function implements the trigger-side portion of Algorithm 2.
 * It does not query GraphDB and does not compute S1, DeltaMinusPivot,
 * DeltaMinusRel, or the final DeltaMinus.
 */

CREATE OR REPLACE FUNCTION compute_changeset_track()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
    v_event_id BIGINT;
    v_deleted_tuples JSONB;
    v_inserted_tuples JSONB;
BEGIN
    /*
     * Algorithm 2, lines 1-2: capture one statement-level event and obtain
     * its identifier. ORDER BY id makes the serialized transition sets
     * deterministic without changing their set semantics.
     */
    SELECT COALESCE(jsonb_agg(to_jsonb(d) ORDER BY d.id), '[]'::jsonb)
      INTO v_deleted_tuples
      FROM deleted_track AS d;

    SELECT COALESCE(jsonb_agg(to_jsonb(i) ORDER BY i.id), '[]'::jsonb)
      INTO v_inserted_tuples
      FROM inserted_track AS i;

    INSERT INTO rdf_maintenance_queue
        (relation_name, operation_type, deleted_tuples, inserted_tuples)
    VALUES
        ('track', 'UPDATE', v_deleted_tuples, v_inserted_tuples)
    RETURNING event_id INTO v_event_id;

    /*
     * psi_artist_11 - relation-relevant.
     *
     * A_minus: artist pivot tuples connected to deleted_track through
     * artist_credit_name and artist_credit.
     * A_plus:  artist pivot tuples connected to inserted_track.
     * S2:      post-update evaluation of psi_artist_11 over A_minus.
     * DeltaPlusRel: post-update evaluation over A_plus.
     * DeltaPlusPivot is empty because pivot(psi_artist_11) = artist.
     */
    INSERT INTO rdf_rule_contribution
        (event_id, rule_id, rule_graph_uri, relevance_type,
         pivot_relation, path, rule_contribution)
    WITH
    a_minus AS (
        SELECT a.*
          FROM artist AS a
         WHERE EXISTS (
                   SELECT 1
                     FROM artist_credit_name AS acn
                     JOIN deleted_track AS d
                       ON d.artist_credit = acn.artist_credit
                    WHERE acn.artist = a.id
               )
    ),
    a_plus AS (
        SELECT a.*
          FROM artist AS a
         WHERE EXISTS (
                   SELECT 1
                     FROM artist_credit_name AS acn
                     JOIN inserted_track AS i
                       ON i.artist_credit = acn.artist_credit
                    WHERE acn.artist = a.id
               )
    ),
    s2_pairs AS (
        SELECT DISTINCT
               'http://musicbrainz.org/artist/' || a.gid::text || '#_' AS subject,
               'http://musicbrainz.org/track/' || t.id::text || '#_' AS object
          FROM a_minus AS a
          JOIN artist_credit_name AS acn
            ON acn.artist = a.id
          JOIN track AS t
            ON t.artist_credit = acn.artist_credit
    ),
    delta_plus_rel_pairs AS (
        SELECT DISTINCT
               'http://musicbrainz.org/artist/' || a.gid::text || '#_' AS subject,
               'http://musicbrainz.org/track/' || t.id::text || '#_' AS object
          FROM a_plus AS a
          JOIN artist_credit_name AS acn
            ON acn.artist = a.id
          JOIN track AS t
            ON t.artist_credit = acn.artist_credit
    )
    SELECT
        v_event_id,
        'psi_artist_11',
        'http://musicbrainz.org/graph/mapping/psi_artist_11',
        'relation',
        'artist',
        jsonb_build_array(
            'artist_credit_name_fk_artist^-1',
            'artist_credit_name_fk_artist_credit',
            'track_fk_artist_credit^-1'
        ),
        jsonb_build_object(
            'rule_id', 'psi_artist_11',
            'rule_type', 'OTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', (
                    SELECT COALESCE(jsonb_agg(to_jsonb(x) ORDER BY x.id), '[]'::jsonb)
                      FROM a_minus AS x
                ),
                'A_plus', (
                    SELECT COALESCE(jsonb_agg(to_jsonb(x) ORDER BY x.id), '[]'::jsonb)
                      FROM a_plus AS x
                )
            ),
            'object_quad_template', jsonb_build_object(
                'predicate', 'http://xmlns.com/foaf/0.1/made',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_artist_11'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', '[]'::jsonb,
                'S2', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object(
                                       'subject', subject,
                                       'object', object
                                   )
                                   ORDER BY subject, object
                               ),
                               '[]'::jsonb
                           )
                      FROM s2_pairs
                ),
                'DeltaPlusRel', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object(
                                       'subject', subject,
                                       'object', object
                                   )
                                   ORDER BY subject, object
                               ),
                               '[]'::jsonb
                           )
                      FROM delta_plus_rel_pairs
                ),
                'DeltaPlus', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object(
                                       'subject', subject,
                                       'object', object
                                   )
                                   ORDER BY subject, object
                               ),
                               '[]'::jsonb
                           )
                      FROM delta_plus_rel_pairs
                )
            )
        );

    /*
     * psi_medium_4 - relation-relevant.
     *
     * A_minus/A_plus are medium pivot tuples referenced by the old/new
     * track tuples. S2 and DeltaPlusRel evaluate the rule over the
     * post-update track table.
     */
    INSERT INTO rdf_rule_contribution
        (event_id, rule_id, rule_graph_uri, relevance_type,
         pivot_relation, path, rule_contribution)
    WITH
    a_minus AS (
        SELECT m.*
          FROM medium AS m
         WHERE EXISTS (
                   SELECT 1
                     FROM deleted_track AS d
                    WHERE d.medium = m.id
               )
    ),
    a_plus AS (
        SELECT m.*
          FROM medium AS m
         WHERE EXISTS (
                   SELECT 1
                     FROM inserted_track AS i
                    WHERE i.medium = m.id
               )
    ),
    s2_pairs AS (
        SELECT DISTINCT
               'http://musicbrainz.org/record/' || m.id::text || '#_' AS subject,
               'http://musicbrainz.org/track/' || t.id::text || '#_' AS object
          FROM a_minus AS m
          JOIN track AS t
            ON t.medium = m.id
    ),
    delta_plus_rel_pairs AS (
        SELECT DISTINCT
               'http://musicbrainz.org/record/' || m.id::text || '#_' AS subject,
               'http://musicbrainz.org/track/' || t.id::text || '#_' AS object
          FROM a_plus AS m
          JOIN track AS t
            ON t.medium = m.id
    )
    SELECT
        v_event_id,
        'psi_medium_4',
        'http://musicbrainz.org/graph/mapping/psi_medium_4',
        'relation',
        'medium',
        jsonb_build_array('track_fk_medium^-1'),
        jsonb_build_object(
            'rule_id', 'psi_medium_4',
            'rule_type', 'OTR',
            'affected_tuples', jsonb_build_object(
                'A_minus', (
                    SELECT COALESCE(jsonb_agg(to_jsonb(x) ORDER BY x.id), '[]'::jsonb)
                      FROM a_minus AS x
                ),
                'A_plus', (
                    SELECT COALESCE(jsonb_agg(to_jsonb(x) ORDER BY x.id), '[]'::jsonb)
                      FROM a_plus AS x
                )
            ),
            'object_quad_template', jsonb_build_object(
                'predicate', 'http://purl.org/ontology/mo/track',
                'graph', 'http://musicbrainz.org/graph/mapping/psi_medium_4'
            ),
            'rdf_contributions', jsonb_build_object(
                'DeltaPlusPivot', '[]'::jsonb,
                'S2', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object(
                                       'subject', subject,
                                       'object', object
                                   )
                                   ORDER BY subject, object
                               ),
                               '[]'::jsonb
                           )
                      FROM s2_pairs
                ),
                'DeltaPlusRel', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object(
                                       'subject', subject,
                                       'object', object
                                   )
                                   ORDER BY subject, object
                               ),
                               '[]'::jsonb
                           )
                      FROM delta_plus_rel_pairs
                ),
                'DeltaPlus', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object(
                                       'subject', subject,
                                       'object', object
                                   )
                                   ORDER BY subject, object
                               ),
                               '[]'::jsonb
                           )
                      FROM delta_plus_rel_pairs
                )
            )
        );

    /*
     * psi_track_1 - pivot-relevant CTR.
     * DeltaPlus = DeltaPlusPivot because the rule is not relation-relevant.
     */
    INSERT INTO rdf_rule_contribution
        (event_id, rule_id, rule_graph_uri, relevance_type,
         pivot_relation, path, rule_contribution)
    WITH delta_plus_pivot AS (
        SELECT DISTINCT
               'http://musicbrainz.org/track/' || i.id::text || '#_' AS subject
          FROM inserted_track AS i
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
                'DeltaPlusPivot', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object('subject', subject)
                                   ORDER BY subject
                               ),
                               '[]'::jsonb
                           )
                      FROM delta_plus_pivot
                ),
                'DeltaPlus', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object('subject', subject)
                                   ORDER BY subject
                               ),
                               '[]'::jsonb
                           )
                      FROM delta_plus_pivot
                )
            )
        );

    /*
     * psi_track_2 - pivot-relevant Local-DTR.
     * The INTEGER column track.position is represented as xsd:integer.
     */
    INSERT INTO rdf_rule_contribution
        (event_id, rule_id, rule_graph_uri, relevance_type,
         pivot_relation, path, rule_contribution)
    WITH delta_plus_pivot AS (
        SELECT DISTINCT
               'http://musicbrainz.org/track/' || i.id::text || '#_' AS subject,
               i.position AS object
          FROM inserted_track AS i
         WHERE i.position IS NOT NULL
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
                'DeltaPlusPivot', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object(
                                       'subject', subject,
                                       'object', object
                                   )
                                   ORDER BY subject, object
                               ),
                               '[]'::jsonb
                           )
                      FROM delta_plus_pivot
                ),
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object(
                                       'subject', subject,
                                       'object', object
                                   )
                                   ORDER BY subject, object
                               ),
                               '[]'::jsonb
                           )
                      FROM delta_plus_pivot
                )
            )
        );

    /*
     * psi_track_3 - pivot-relevant Local-DTR.
     * The VARCHAR column track.name is represented as xsd:string.
     */
    INSERT INTO rdf_rule_contribution
        (event_id, rule_id, rule_graph_uri, relevance_type,
         pivot_relation, path, rule_contribution)
    WITH delta_plus_pivot AS (
        SELECT DISTINCT
               'http://musicbrainz.org/track/' || i.id::text || '#_' AS subject,
               i.name AS object
          FROM inserted_track AS i
         WHERE i.name IS NOT NULL
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
                'DeltaPlusPivot', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object(
                                       'subject', subject,
                                       'object', object
                                   )
                                   ORDER BY subject, object
                               ),
                               '[]'::jsonb
                           )
                      FROM delta_plus_pivot
                ),
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object(
                                       'subject', subject,
                                       'object', object
                                   )
                                   ORDER BY subject, object
                               ),
                               '[]'::jsonb
                           )
                      FROM delta_plus_pivot
                )
            )
        );

    /*
     * psi_track_4 - pivot-relevant Local-DTR with length IS NOT NULL.
     * The INTEGER column track.length is represented as xsd:integer.
     */
    INSERT INTO rdf_rule_contribution
        (event_id, rule_id, rule_graph_uri, relevance_type,
         pivot_relation, path, rule_contribution)
    WITH delta_plus_pivot AS (
        SELECT DISTINCT
               'http://musicbrainz.org/track/' || i.id::text || '#_' AS subject,
               i.length AS object
          FROM inserted_track AS i
         WHERE i.length IS NOT NULL
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
                'DeltaPlusPivot', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object(
                                       'subject', subject,
                                       'object', object
                                   )
                                   ORDER BY subject, object
                               ),
                               '[]'::jsonb
                           )
                      FROM delta_plus_pivot
                ),
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object(
                                       'subject', subject,
                                       'object', object
                                   )
                                   ORDER BY subject, object
                               ),
                               '[]'::jsonb
                           )
                      FROM delta_plus_pivot
                )
            )
        );

    /*
     * psi_track_5 - pivot-relevant OTR.
     * The post-update recording row is reached through track_fk_recording.
     */
    INSERT INTO rdf_rule_contribution
        (event_id, rule_id, rule_graph_uri, relevance_type,
         pivot_relation, path, rule_contribution)
    WITH delta_plus_pivot AS (
        SELECT DISTINCT
               'http://musicbrainz.org/track/' || i.id::text || '#_' AS subject,
               'http://musicbrainz.org/recording/' || rec.gid::text || '#_' AS object
          FROM inserted_track AS i
          JOIN recording AS rec
            ON rec.id = i.recording
    )
    SELECT
        v_event_id,
        'psi_track_5',
        'http://musicbrainz.org/graph/mapping/psi_track_5',
        'pivot',
        'track',
        jsonb_build_array('track_fk_recording'),
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
                'DeltaPlusPivot', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object(
                                       'subject', subject,
                                       'object', object
                                   )
                                   ORDER BY subject, object
                               ),
                               '[]'::jsonb
                           )
                      FROM delta_plus_pivot
                ),
                'S2', '[]'::jsonb,
                'DeltaPlusRel', '[]'::jsonb,
                'DeltaPlus', (
                    SELECT COALESCE(
                               jsonb_agg(
                                   jsonb_build_object(
                                       'subject', subject,
                                       'object', object
                                   )
                                   ORDER BY subject, object
                               ),
                               '[]'::jsonb
                           )
                      FROM delta_plus_pivot
                )
            )
        );

    /*
     * AFTER FOR EACH STATEMENT ignores the returned row. The durable output
     * is the event row plus the seven per-rule contribution rows above.
     */
    RETURN NULL;
END;
$function$;

DROP TRIGGER IF EXISTS trg_compute_changeset_track ON track;

CREATE TRIGGER trg_compute_changeset_track
AFTER UPDATE ON track
REFERENCING
    OLD TABLE AS deleted_track
    NEW TABLE AS inserted_track
FOR EACH STATEMENT
EXECUTE FUNCTION compute_changeset_track();
