# Final Phase 2 Result for `R = medium`

## Incorporated Decision

By the author's final decision, `psi_medium_5` remains a `Path-DTR`, but now produces the literal `medium_format.id` with datatype `xsd:int`. The compilation uses `RDFLiteral` and `datatype_quad_template`.

## Relevant Rules

| Rule | pivot | path | Relevance |
|---|---|---|---|
| `psi_medium_1` | `medium` | `[]` | `pivot` |
| `psi_medium_2` | `medium` | `[]` | `pivot` |
| `psi_medium_3` | `medium` | `[]` | `pivot` |
| `psi_medium_4` | `medium` | `[track_fk_medium^-1]` | `pivot` |
| `psi_medium_5` | `medium` | `[medium_fk_format]` | `pivot` |
| `psi_release_4` | `release` | `[medium_fk_release^-1]` | `relation` |

`medium` appears as a non-pivot relation in `psi_release_4`: starting from the `release` pivot, the inverse path `medium_fk_release^-1` reaches the `medium` tuples. Therefore, `A−` contains the releases referenced by `deleted_medium.release`, and `A+` contains the releases referenced by `inserted_medium.release`.

## Compilation Result

The SQL:

- creates `compute_changeset_medium() RETURNS trigger`;
- captures exactly one event per `UPDATE` statement;
- uses `deleted_medium` and `inserted_medium`;
- publishes exactly six contributions per event;
- computes `A−`, `A+`, `S2`, and `DeltaPlusRel` for `psi_release_4`;
- computes `DeltaPlusPivot` for the five rules whose pivot is `medium`;
- uses the six certified URIs as `rule_graph_uri` and RDF graph;
- does not query GraphDB;
- terminates with `RETURN NULL`;
- creates `trg_compute_changeset_medium` as an `AFTER UPDATE FOR EACH STATEMENT` trigger.

## Verification

The static verification confirmed:

- 1 insertion into `rdf_maintenance_queue`;
- 6 insertions into `rdf_rule_contribution`;
- 6 certified URIs;
- compliance with the statement-level trigger contract;
- the presence of both transition tables.

The SQL was not executed against a real PostgreSQL instance, as no test connection was provided.
