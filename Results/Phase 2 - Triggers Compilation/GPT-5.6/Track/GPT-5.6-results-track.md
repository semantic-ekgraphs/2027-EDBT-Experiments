# Phase 2 Result for `R = track`

## A) Analytical Table

| Ψ | pivot(Ψ) | path(Ψ) | Type | Affected tuples | Justification |
|---|---|---|---|---|---|
| `psi_artist_11` | `artist` | `[artist_credit_name_fk_artist^-1, artist_credit_name_fk_artist_credit, track_fk_artist_credit^-1]` | `relation` | `A−`: artists associated with the `artist_credit` of `deleted_track`; `A+`: artists associated with the `artist_credit` of `inserted_track` | `track(t)` appears in the body as a non-pivot relation. In the path starting from `artist`, `track` is the target relation reached through the inverse step `track_fk_artist_credit^-1`. |
| `psi_medium_4` | `medium` | `[track_fk_medium^-1]` | `relation` | `A−`: media referenced by `deleted_track.medium`; `A+`: media referenced by `inserted_track.medium` | `track(tr)` appears in the body as a non-pivot relation. In the path starting from `medium`, `track` is the target relation of the inverse step `track_fk_medium^-1`. |
| `psi_track_1` | `track` | `[]` | `pivot` | Tuples in `inserted_track` | `pivot(Ψ) = track`. The rule does not contain a second non-pivot occurrence of `track`; therefore, it does not require `track` in `path(Ψ)`. |
| `psi_track_2` | `track` | `[]` | `pivot` | Tuples in `inserted_track` with `position IS NOT NULL` | `pivot(Ψ) = track`. The rule does not contain a second non-pivot occurrence of `track`; therefore, it does not require `track` in `path(Ψ)`. |
| `psi_track_3` | `track` | `[]` | `pivot` | Tuples in `inserted_track` with `name IS NOT NULL` | `pivot(Ψ) = track`. The rule does not contain a second non-pivot occurrence of `track`; therefore, it does not require `track` in `path(Ψ)`. |
| `psi_track_4` | `track` | `[]` | `pivot` | Tuples in `inserted_track` with `length IS NOT NULL` | `pivot(Ψ) = track`. The rule does not contain a second non-pivot occurrence of `track`; therefore, it does not require `track` in `path(Ψ)`. |
| `psi_track_5` | `track` | `[track_fk_recording]` | `pivot` | Tuples in `inserted_track` that reach `recording` through `track.recording = recording.id` | `pivot(Ψ) = track`. `recording` is the non-pivot relation in the path; `track` appears only as the pivot, not as a non-pivot occurrence. |

Thus,

`Relev(track) = {psi_artist_11, psi_medium_4, psi_track_1, psi_track_2, psi_track_3, psi_track_4, psi_track_5}`.

No rule is simultaneously pivot-relevant and relation-relevant for `track`.

## B) PostgreSQL Function

The executable function is provided in `compute_changeset_track.sql`. It:

1. inserts exactly one update event into `rdf_maintenance_queue`;
2. uses `deleted_track` and `inserted_track` as transition tables;
3. inserts exactly seven contributions, one for each rule in `Relev(track)`;
4. computes `A−`, `A+`, `S2`, and `DeltaPlusRel` for the two relation-relevant rules;
5. computes `DeltaPlusPivot` for the five pivot-relevant rules;
6. publishes `DeltaPlus` as the union of the applicable contributions;
7. uses each certified `Rule URI` both as `rule_graph_uri` and as the template graph;
8. does not execute SPARQL or access GraphDB;
9. terminates with `RETURN NULL`.

The fixed components of the RDF quads are stored in the templates, while the variable components are stored in the contributions, exactly as specified by the infrastructure:

- CTR: `class_quad_template`;
- Local-DTR: `datatype_quad_template`;
- OTR: `object_quad_template`.

For the three Local-DTRs, the literal datatypes were derived from the column types declared in the schema:

- `track.position INTEGER` → `xsd:integer`;
- `track.name VARCHAR` → `xsd:string`;
- `track.length INTEGER` → `xsd:integer`.

## C) PostgreSQL Trigger

The same SQL file creates:

```sql
CREATE TRIGGER trg_compute_changeset_track
AFTER UPDATE ON track
REFERENCING
    OLD TABLE AS deleted_track
    NEW TABLE AS inserted_track
FOR EACH STATEMENT
EXECUTE FUNCTION compute_changeset_track();
```

## Observation Produced by the Test

On page 7 of Prompt v8, the statement “Rule contribution for a CTR: S2 and DeltaPlus” does not match the CTR template in the infrastructure file, which defines `DeltaPlusPivot` and `DeltaPlus`, but does not define `S2`.

The SQL follows the infrastructure template because the prompt itself instructs that its structure must be preserved without modification. The recommended minimal textual correction to the prompt is:

> Rule contribution for a CTR: DeltaPlusPivot and DeltaPlus.
