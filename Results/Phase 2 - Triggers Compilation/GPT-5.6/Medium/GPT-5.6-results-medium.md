# Resultado final da Fase 2 para `R = medium`

## Decisão incorporada

Por decisão definitiva da autora, `psi_medium_5` permanece `Path-DTR`, mas passa a produzir o literal `medium_format.id` com datatype `xsd:int`. A compilação utiliza `RDFLiteral` e `datatype_quad_template`.

## Regras relevantes

| Regra | pivot | path | Relevância |
|---|---|---|---|
| `psi_medium_1` | `medium` | `[]` | `pivot` |
| `psi_medium_2` | `medium` | `[]` | `pivot` |
| `psi_medium_3` | `medium` | `[]` | `pivot` |
| `psi_medium_4` | `medium` | `[track_fk_medium^-1]` | `pivot` |
| `psi_medium_5` | `medium` | `[medium_fk_format]` | `pivot` |
| `psi_release_4` | `release` | `[medium_fk_release^-1]` | `relation` |

`medium` ocorre como relação não pivô de `psi_release_4`: a partir do pivô `release`, o caminho inverso `medium_fk_release^-1` alcança as tuplas de `medium`. Assim, `A−` contém releases referenciados por `deleted_medium.release`, e `A+` contém releases referenciados por `inserted_medium.release`.

## Resultado da compilação

O SQL:

- cria `compute_changeset_medium() RETURNS trigger`;
- captura exatamente um evento por comando `UPDATE`;
- usa `deleted_medium` e `inserted_medium`;
- publica exatamente seis contribuições por evento;
- calcula `A−`, `A+`, `S2` e `DeltaPlusRel` para `psi_release_4`;
- calcula `DeltaPlusPivot` para as cinco regras com pivô `medium`;
- usa as seis URIs certificadas como `rule_graph_uri` e grafo RDF;
- não consulta GraphDB;
- termina com `RETURN NULL`;
- cria `trg_compute_changeset_medium` como `AFTER UPDATE FOR EACH STATEMENT`.

## Verificação

A verificação estática confirmou:

- 1 inserção em `rdf_maintenance_queue`;
- 6 inserções em `rdf_rule_contribution`;
- 6 URIs certificadas;
- contrato de trigger de nível de comando;
- presença das duas tabelas de transição.

O SQL não foi executado contra uma instância PostgreSQL real, pois nenhuma conexão de teste foi fornecida.
