DROP TRIGGER IF EXISTS trg_after_update_track_rdf_maintenance ON track;

CREATE TRIGGER trg_after_update_track_rdf_maintenance
AFTER UPDATE ON track
REFERENCING
    OLD TABLE AS deleted_R
    NEW TABLE AS inserted_R
FOR EACH STATEMENT
EXECUTE FUNCTION compute_changeset_track();