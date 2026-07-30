/*
 * Phase 2 — R = medium.
 * Implements only the trigger-side work of Algorithm 2.
 */
CREATE OR REPLACE FUNCTION compute_changeset_medium()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
    v_event_id BIGINT;
BEGIN
    INSERT INTO rdf_maintenance_queue
        (relation_name, operation_type, deleted_tuples, inserted_tuples)
    SELECT
        'medium',
        'UPDATE',
        (SELECT COALESCE(jsonb_agg(to_jsonb(d) ORDER BY d.id), '[]'::jsonb)
           FROM deleted_medium d),
        (SELECT COALESCE(jsonb_agg(to_jsonb(i) ORDER BY i.id), '[]'::jsonb)
           FROM inserted_medium i)
    RETURNING event_id INTO v_event_id;

    /* psi_release_4: relation-relevant; medium is the non-pivot target. */
    INSERT INTO rdf_rule_contribution
        (event_id, rule_id, rule_graph_uri, relevance_type,
         pivot_relation, path, rule_contribution)
    WITH
    am AS (
        SELECT r.* FROM release r
        WHERE EXISTS (SELECT 1 FROM deleted_medium d WHERE d.release = r.id)
    ),
    ap AS (
        SELECT r.* FROM release r
        WHERE EXISTS (SELECT 1 FROM inserted_medium i WHERE i.release = r.id)
    ),
    s2q AS (
        SELECT DISTINCT
          'http://musicbrainz.org/release/' || r.gid::text || '#_' s,
          'http://musicbrainz.org/record/' || m.id::text || '#_' o
        FROM am r JOIN medium m ON m.release = r.id
    ),
    dpq AS (
        SELECT DISTINCT
          'http://musicbrainz.org/release/' || r.gid::text || '#_' s,
          'http://musicbrainz.org/record/' || m.id::text || '#_' o
        FROM ap r JOIN medium m ON m.release = r.id
    )
    SELECT v_event_id, 'psi_release_4',
      'http://musicbrainz.org/graph/mapping/psi_release_4',
      'relation', 'release', jsonb_build_array('medium_fk_release^-1'),
      jsonb_build_object(
        'rule_id','psi_release_4','rule_type','OTR',
        'affected_tuples',jsonb_build_object(
          'A_minus',(SELECT COALESCE(jsonb_agg(to_jsonb(x) ORDER BY x.id),'[]') FROM am x),
          'A_plus',(SELECT COALESCE(jsonb_agg(to_jsonb(x) ORDER BY x.id),'[]') FROM ap x)),
        'object_quad_template',jsonb_build_object(
          'predicate','http://purl.org/ontology/mo/record',
          'graph','http://musicbrainz.org/graph/mapping/psi_release_4'),
        'rdf_contributions',jsonb_build_object(
          'DeltaPlusPivot','[]'::jsonb,
          'S2',(SELECT COALESCE(jsonb_agg(jsonb_build_object('subject',s,'object',o) ORDER BY s,o),'[]') FROM s2q),
          'DeltaPlusRel',(SELECT COALESCE(jsonb_agg(jsonb_build_object('subject',s,'object',o) ORDER BY s,o),'[]') FROM dpq),
          'DeltaPlus',(SELECT COALESCE(jsonb_agg(jsonb_build_object('subject',s,'object',o) ORDER BY s,o),'[]') FROM dpq)));

    /* psi_medium_1: pivot-relevant CTR. */
    INSERT INTO rdf_rule_contribution
    SELECT v_event_id, 'psi_medium_1',
      'http://musicbrainz.org/graph/mapping/psi_medium_1',
      'pivot','medium','[]'::jsonb,
      jsonb_build_object(
        'rule_id','psi_medium_1','rule_type','CTR','pivot_relation','medium',
        'class_quad_template',jsonb_build_object(
          'predicate','http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
          'class','http://purl.org/ontology/mo/Record',
          'graph','http://musicbrainz.org/graph/mapping/psi_medium_1'),
        'rdf_contributions',jsonb_build_object(
          'DeltaPlusPivot',q.a,'DeltaPlus',q.a))
    FROM (
      SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'subject','http://musicbrainz.org/record/'||i.id::text||'#_')
        ORDER BY i.id),'[]') a
      FROM inserted_medium i
    ) q;

    /* psi_medium_2: pivot-relevant Local-DTR, name -> xsd:string. */
    INSERT INTO rdf_rule_contribution
    SELECT v_event_id,'psi_medium_2',
      'http://musicbrainz.org/graph/mapping/psi_medium_2',
      'pivot','medium','[]'::jsonb,
      jsonb_build_object(
        'rule_id','psi_medium_2','rule_type','DTR',
        'affected_tuples',jsonb_build_object('A_minus','[]'::jsonb,'A_plus','[]'::jsonb),
        'datatype_quad_template',jsonb_build_object(
          'predicate','http://purl.org/dc/elements/1.1/title',
          'datatype','http://www.w3.org/2001/XMLSchema#string',
          'graph','http://musicbrainz.org/graph/mapping/psi_medium_2'),
        'rdf_contributions',jsonb_build_object(
          'DeltaPlusPivot',q.a,'S2','[]'::jsonb,
          'DeltaPlusRel','[]'::jsonb,'DeltaPlus',q.a))
    FROM (
      SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'subject','http://musicbrainz.org/record/'||i.id::text||'#_',
        'object',i.name) ORDER BY i.id),'[]') a
      FROM inserted_medium i WHERE i.name IS NOT NULL
    ) q;

    /* psi_medium_3: pivot-relevant Local-DTR, track_count -> xsd:int. */
    INSERT INTO rdf_rule_contribution
    SELECT v_event_id,'psi_medium_3',
      'http://musicbrainz.org/graph/mapping/psi_medium_3',
      'pivot','medium','[]'::jsonb,
      jsonb_build_object(
        'rule_id','psi_medium_3','rule_type','DTR',
        'affected_tuples',jsonb_build_object('A_minus','[]'::jsonb,'A_plus','[]'::jsonb),
        'datatype_quad_template',jsonb_build_object(
          'predicate','http://purl.org/ontology/mo/track_count',
          'datatype','http://www.w3.org/2001/XMLSchema#int',
          'graph','http://musicbrainz.org/graph/mapping/psi_medium_3'),
        'rdf_contributions',jsonb_build_object(
          'DeltaPlusPivot',q.a,'S2','[]'::jsonb,
          'DeltaPlusRel','[]'::jsonb,'DeltaPlus',q.a))
    FROM (
      SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'subject','http://musicbrainz.org/record/'||i.id::text||'#_',
        'object',i.track_count) ORDER BY i.id),'[]') a
      FROM inserted_medium i WHERE i.track_count IS NOT NULL
    ) q;

    /* psi_medium_4: pivot-relevant OTR, evaluated in the post-update state. */
    INSERT INTO rdf_rule_contribution
    SELECT v_event_id,'psi_medium_4',
      'http://musicbrainz.org/graph/mapping/psi_medium_4',
      'pivot','medium',jsonb_build_array('track_fk_medium^-1'),
      jsonb_build_object(
        'rule_id','psi_medium_4','rule_type','OTR',
        'affected_tuples',jsonb_build_object('A_minus','[]'::jsonb,'A_plus','[]'::jsonb),
        'object_quad_template',jsonb_build_object(
          'predicate','http://purl.org/ontology/mo/track',
          'graph','http://musicbrainz.org/graph/mapping/psi_medium_4'),
        'rdf_contributions',jsonb_build_object(
          'DeltaPlusPivot',q.a,'S2','[]'::jsonb,
          'DeltaPlusRel','[]'::jsonb,'DeltaPlus',q.a))
    FROM (
      SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'subject','http://musicbrainz.org/record/'||i.id::text||'#_',
        'object','http://musicbrainz.org/track/'||t.id::text||'#_')
        ORDER BY i.id,t.id),'[]') a
      FROM inserted_medium i JOIN track t ON t.medium=i.id
    ) q;

    /*
     * psi_medium_5: pivot-relevant Path-DTR.
     * Definitive author decision: medium_format.id is an xsd:int literal.
     */
    INSERT INTO rdf_rule_contribution
    SELECT v_event_id,'psi_medium_5',
      'http://musicbrainz.org/graph/mapping/psi_medium_5',
      'pivot','medium',jsonb_build_array('medium_fk_format'),
      jsonb_build_object(
        'rule_id','psi_medium_5','rule_type','DTR',
        'affected_tuples',jsonb_build_object('A_minus','[]'::jsonb,'A_plus','[]'::jsonb),
        'datatype_quad_template',jsonb_build_object(
          'predicate','http://purl.org/ontology/mo/media_type',
          'datatype','http://www.w3.org/2001/XMLSchema#int',
          'graph','http://musicbrainz.org/graph/mapping/psi_medium_5'),
        'rdf_contributions',jsonb_build_object(
          'DeltaPlusPivot',q.a,'S2','[]'::jsonb,
          'DeltaPlusRel','[]'::jsonb,'DeltaPlus',q.a))
    FROM (
      SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'subject','http://musicbrainz.org/record/'||i.id::text||'#_',
        'object',mf.id) ORDER BY i.id,mf.id),'[]') a
      FROM inserted_medium i
      JOIN medium_format mf ON mf.id=i.format
      WHERE mf.id IS NOT NULL
    ) q;

    RETURN NULL;
END;
$function$;

DROP TRIGGER IF EXISTS trg_compute_changeset_medium ON medium;

CREATE TRIGGER trg_compute_changeset_medium
AFTER UPDATE ON medium
REFERENCING OLD TABLE AS deleted_medium NEW TABLE AS inserted_medium
FOR EACH STATEMENT
EXECUTE FUNCTION compute_changeset_medium();
