# Phase 2 Prompt Execution - `R = artist`

## Result

The compilation produced:

- one PostgreSQL function `compute_changeset_artist()`;
- one statement-level `AFTER UPDATE` trigger;
- one publication to `rdf_maintenance_queue` per statement;
- 14 publications to `rdf_rule_contribution` per event, one for each
  relevant rule.

The code does not access GraphDB and does not execute SPARQL. The retrieval of `S1`, the computation of the final removal contribution, and the update of the RDF dataset remain the responsibility of the asynchronous worker.

### Non-blocking warning about the spreadsheet

The `Consolidated Rules` worksheet contains 83 explicit and unique rules, whereas the title and the `Summary` worksheet still report 89 rules. To comply with the prompt's authority rule, the compilation considered exclusively the rule entries actually present in `Consolidated Rules`. This discrepancy does not affect `Relev(artist)`, but it is advisable to update the spreadsheet summary.

## A) Required analytical table

| Ψ | pivot(Ψ) | path(Ψ) | Type | Affected tuples | Justification |
|---|---|---|---|---|---|
| `psi_artist_1` | `artist` | `[]` | `pivot` | `inserted_artist` | `pivot(Ψ)=artist`. There is no non-pivot occurrence of `artist`; the path is not required to establish pivot relevance. |
| `psi_artist_2` | `artist` | `[]` | `pivot` | `inserted_artist` with `gid IS NOT NULL` | `pivot(Ψ)=artist`. Local-DTR; produces `mo:musicbrainz_guid` with datatype `xsd:string`. |
| `psi_artist_3` | `artist` | `[]` | `pivot` | `inserted_artist` with `name IS NOT NULL` | `pivot(Ψ)=artist`. Local-DTR; produces `foaf:name` with datatype `xsd:string`. |
| `psi_artist_4` | `artist` | `[]` | `pivot` | `inserted_artist` with `sort_name IS NOT NULL` | `pivot(Ψ)=artist`. Local-DTR; produces `ov:sortLabel` with datatype `xsd:string`. |
| `psi_artist_5` | `artist` | `[]` | `pivot` | `inserted_artist` with `type=1` | `pivot(Ψ)=artist`. The selection condition is applied to the inserted pivot. |
| `psi_artist_6` | `artist` | `[]` | `pivot` | `inserted_artist` with `type=2` | `pivot(Ψ)=artist`. The selection condition is applied to the inserted pivot. |
| `psi_artist_7` | `artist` | `[artist_fk_gender]` | `pivot` | `inserted_artist`, followed by `artist.gender = gender.id` | `pivot(Ψ)=artist`. `gender` is a non-pivot relation; `artist` is only the starting relation of the path. |
| `psi_artist_8` | `artist` | `[artist_fk_area]` | `pivot` | `inserted_artist`, followed by `artist.area = area.id` | `pivot(Ψ)=artist`. `area` is a non-pivot relation; `artist` is only the starting relation of the path. |
| `psi_artist_9` | `artist` | `[artist_credit_name_fk_artist^-1, artist_credit_name_fk_artist_credit, release_group_fk_artist_credit^-1]` | `pivot` | `inserted_artist` and the `release_group` records reached through the path | `pivot(Ψ)=artist`. The path starts at the pivot and ends at `release_group`; it contains no other occurrence of `artist`. |
| `psi_artist_10` | `artist` | `[artist_credit_name_fk_artist^-1, artist_credit_name_fk_artist_credit, release_fk_artist_credit^-1]` | `pivot` | `inserted_artist` and the `release` records reached through the path | `pivot(Ψ)=artist`. The path starts at the pivot and ends at `release`; it contains no other occurrence of `artist`. |
| `psi_artist_11` | `artist` | `[artist_credit_name_fk_artist^-1, artist_credit_name_fk_artist_credit, track_fk_artist_credit^-1]` | `pivot` | `inserted_artist` and the `track` records reached through the path | `pivot(Ψ)=artist`. The path starts at the pivot and ends at `track`; it contains no other occurrence of `artist`. |
| `psi_artist_13` | `artist` | `[artist_credit_name_fk_artist^-1, artist_credit_name_fk_artist_credit, recording_fk_artist_credit^-1]` | `pivot` | `inserted_artist` and the `recording` records reached through the path | `pivot(Ψ)=artist`. The path starts at the pivot and ends at `recording`; it contains no other occurrence of `artist`. |
| `psi_artist_14` | `artist` | `[artist_annotation_fk_artist^-1, artist_annotation_fk_annotation]` | `pivot` | `inserted_artist` and its `annotation` records | `pivot(Ψ)=artist`. `annotation` is non-pivot; the literal has datatype `xsd:string`. |
| `psi_artist_tag_2` | `artist_tag` | `[artist_tag_fk_artist]` | `relation` | `artist_tag` records referencing IDs in `deleted_artist` or `inserted_artist` | `artist(a)` appears in the body as a non-pivot relation and as the destination of the path starting at `artist_tag(at)`. Therefore, `A−`, `A+`, `S2`, and `Δ+rel` are computed separately. |

Summary:

- 13 `pivot` rules;
- 1 `relation` rule;
- no `both` rules.

## B) Correspondence with the algorithm

### Event publication

The trigger aggregates `deleted_artist` and `inserted_artist` into JSON and inserts exactly one row into `rdf_maintenance_queue`, retrieving its `event_id`.

### Pivot-relevant rules

For each of the 13 rules whose pivot is `artist`,
`DeltaPlusPivot[Ψ](u)` is computed by applying the rule to the records in
`inserted_artist` and querying the related relations in the
post-update state. Since these rules are not relation-relevant for `artist`:

- `A_minus = []`;
- `A_plus = []`;
- `S2 = []`;
- `DeltaPlusRel = []`;
- `DeltaPlus = DeltaPlusPivot`.

For CTR, the JSON contains only `DeltaPlusPivot` and `DeltaPlus`, according to the `class_quad_template`.

### Relation-relevant rule

For `psi_artist_tag_2`:

- `A_minus` contains the `artist_tag` pivots that reference artists present in `deleted_artist`;
- `A_plus` contains the `artist_tag` pivots that reference artists present in `inserted_artist`;
- `S2` applies the rule to the pivots in `A_minus` over the PostgreSQL post-update state;
- `DeltaPlusRel` applies the rule to the pivots in `A_plus` over the PostgreSQL post-update state;
- `DeltaPlusPivot = []`;
- `DeltaPlus = DeltaPlusRel`.

The worker can combine `S2` with `S1`, obtained from `W0`, to compute the relation-relevant removal contribution.

## C) Templates and provenance

Each record uses:

- `class_quad_template` for CTR;
- `datatype_quad_template`, including the certified datatype, for DTR;
- `object_quad_template` for OTR.

The Rule URI from the spreadsheet is copied verbatim to:

1. `rdf_rule_contribution.rule_graph_uri`;
2. the `graph` field of the template;
3. the identifier of the contribution's named graph.

## SQL Artifact

The file `compute_changeset_artist.sql` contains the complete function and trigger.
