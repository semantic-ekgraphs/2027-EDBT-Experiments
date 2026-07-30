# Execução do Prompt da Fase 2 - `R = artist`

## Resultado

A compilação foi concluída com:

- uma função PostgreSQL `compute_changeset_artist()`;
- um trigger statement-level `AFTER UPDATE`;
- uma publicação em `rdf_maintenance_queue` por statement;
- 14 publicações em `rdf_rule_contribution` por evento, uma para cada regra
  relevante.

O código não acessa GraphDB e não executa SPARQL. A obtenção de `S1`, a
computação da contribuição final de remoção e a atualização do dataset RDF
permanecem atribuídas ao worker assíncrono.

### Aviso não bloqueante sobre a planilha

A aba `Consolidated Rules` contém 83 regras explícitas e únicas, enquanto o
título e a aba `Summary` ainda registram 89 regras. Para obedecer à regra de
autoridade do prompt, a compilação considerou exclusivamente as linhas de
regras efetivamente presentes em `Consolidated Rules`. Essa divergência não
altera `Relev(artist)`, mas convém atualizar o resumo da planilha.

## A) Tabela analítica obrigatória

| Ψ | pivot(Ψ) | path(Ψ) | Type | Affected tuples | Justification |
|---|---|---|---|---|---|
| `psi_artist_1` | `artist` | `[]` | `pivot` | `inserted_artist` | `pivot(Ψ)=artist`. Não há ocorrência não-pivot de `artist`; o caminho não é necessário para estabelecer a relevância pivot. |
| `psi_artist_2` | `artist` | `[]` | `pivot` | `inserted_artist` com `gid IS NOT NULL` | `pivot(Ψ)=artist`. Local-DTR; produz `mo:musicbrainz_guid` com datatype `xsd:string`. |
| `psi_artist_3` | `artist` | `[]` | `pivot` | `inserted_artist` com `name IS NOT NULL` | `pivot(Ψ)=artist`. Local-DTR; produz `foaf:name` com datatype `xsd:string`. |
| `psi_artist_4` | `artist` | `[]` | `pivot` | `inserted_artist` com `sort_name IS NOT NULL` | `pivot(Ψ)=artist`. Local-DTR; produz `ov:sortLabel` com datatype `xsd:string`. |
| `psi_artist_5` | `artist` | `[]` | `pivot` | `inserted_artist` com `type=1` | `pivot(Ψ)=artist`. A condição de seleção é aplicada ao pivot inserido. |
| `psi_artist_6` | `artist` | `[]` | `pivot` | `inserted_artist` com `type=2` | `pivot(Ψ)=artist`. A condição de seleção é aplicada ao pivot inserido. |
| `psi_artist_7` | `artist` | `[artist_fk_gender]` | `pivot` | `inserted_artist`, seguido de `artist.gender = gender.id` | `pivot(Ψ)=artist`. `gender` é uma relação não-pivot; `artist` é apenas a relação inicial do caminho. |
| `psi_artist_8` | `artist` | `[artist_fk_area]` | `pivot` | `inserted_artist`, seguido de `artist.area = area.id` | `pivot(Ψ)=artist`. `area` é a relação não-pivot; `artist` é apenas a relação inicial do caminho. |
| `psi_artist_9` | `artist` | `[artist_credit_name_fk_artist^-1, artist_credit_name_fk_artist_credit, release_group_fk_artist_credit^-1]` | `pivot` | `inserted_artist` e `release_group` alcançados pelo caminho | `pivot(Ψ)=artist`. O caminho começa no pivot e termina em `release_group`; não contém outra ocorrência de `artist`. |
| `psi_artist_10` | `artist` | `[artist_credit_name_fk_artist^-1, artist_credit_name_fk_artist_credit, release_fk_artist_credit^-1]` | `pivot` | `inserted_artist` e `release` alcançados pelo caminho | `pivot(Ψ)=artist`. O caminho começa no pivot e termina em `release`; não contém outra ocorrência de `artist`. |
| `psi_artist_11` | `artist` | `[artist_credit_name_fk_artist^-1, artist_credit_name_fk_artist_credit, track_fk_artist_credit^-1]` | `pivot` | `inserted_artist` e `track` alcançados pelo caminho | `pivot(Ψ)=artist`. O caminho começa no pivot e termina em `track`; não contém outra ocorrência de `artist`. |
| `psi_artist_13` | `artist` | `[artist_credit_name_fk_artist^-1, artist_credit_name_fk_artist_credit, recording_fk_artist_credit^-1]` | `pivot` | `inserted_artist` e `recording` alcançados pelo caminho | `pivot(Ψ)=artist`. O caminho começa no pivot e termina em `recording`; não contém outra ocorrência de `artist`. |
| `psi_artist_14` | `artist` | `[artist_annotation_fk_artist^-1, artist_annotation_fk_annotation]` | `pivot` | `inserted_artist` e suas `annotation` | `pivot(Ψ)=artist`. `annotation` é não-pivot; o literal é `xsd:string`. |
| `psi_artist_tag_2` | `artist_tag` | `[artist_tag_fk_artist]` | `relation` | `artist_tag` que referencia IDs em `deleted_artist` ou `inserted_artist` | `artist(a)` ocorre no corpo como relação não-pivot e como destino do caminho iniciado em `artist_tag(at)`. Por isso são calculados separadamente `A−`, `A+`, `S2` e `Δ+rel`. |

Resumo:

- 13 regras `pivot`;
- 1 regra `relation`;
- nenhuma regra `both`.

## B) Correspondência com o algoritmo

### Publicação do evento

O trigger agrega `deleted_artist` e `inserted_artist` em JSON e insere exatamente
uma linha em `rdf_maintenance_queue`, recuperando seu `event_id`.

### Regras pivot-relevant

Para cada uma das 13 regras cujo pivot é `artist`,
`DeltaPlusPivot[Ψ](u)` é calculada aplicando a regra aos registros de
`inserted_artist` e consultando as relações relacionadas no estado
pós-atualização. Como essas regras não são relation-relevant para `artist`:

- `A_minus = []`;
- `A_plus = []`;
- `S2 = []`;
- `DeltaPlusRel = []`;
- `DeltaPlus = DeltaPlusPivot`.

Para CTR, o JSON contém somente `DeltaPlusPivot` e `DeltaPlus`, conforme o
`class_quad_template`.

### Regra relation-relevant

Para `psi_artist_tag_2`:

- `A_minus` contém os pivots `artist_tag` que referenciam artistas presentes em
  `deleted_artist`;
- `A_plus` contém os pivots `artist_tag` que referenciam artistas presentes em
  `inserted_artist`;
- `S2` aplica a regra aos pivots de `A_minus` sobre o estado PostgreSQL
  pós-atualização;
- `DeltaPlusRel` aplica a regra aos pivots de `A_plus` sobre o estado
  pós-atualização;
- `DeltaPlusPivot = []`;
- `DeltaPlus = DeltaPlusRel`.

O worker poderá combinar `S2` com `S1`, obtido de `W0`, para calcular a
contribuição relation-relevant de remoção.

## C) Templates e proveniência

Cada registro usa:

- `class_quad_template` para CTR;
- `datatype_quad_template`, incluindo o datatype certificado, para DTR;
- `object_quad_template` para OTR.

A Rule URI da planilha é copiada literalmente para:

1. `rdf_rule_contribution.rule_graph_uri`;
2. o campo `graph` do template;
3. a identificação do named graph da contribuição.

## Artefato SQL

O arquivo `compute_changeset_artist.sql` contém a função e o trigger completos.
