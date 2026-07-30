# Resultado da Fase 2 para `R = track`

## A) Tabela analítica

| Ψ | pivot(Ψ) | path(Ψ) | Tipo | Tuplas afetadas | Justificativa |
|---|---|---|---|---|---|
| `psi_artist_11` | `artist` | `[artist_credit_name_fk_artist^-1, artist_credit_name_fk_artist_credit, track_fk_artist_credit^-1]` | `relation` | `A−`: artistas associados ao `artist_credit` de `deleted_track`; `A+`: artistas associados ao `artist_credit` de `inserted_track` | `track(t)` ocorre no corpo como relação não pivô. No caminho iniciado em `artist`, `track` é a relação-alvo alcançada pelo passo inverso `track_fk_artist_credit^-1`. |
| `psi_medium_4` | `medium` | `[track_fk_medium^-1]` | `relation` | `A−`: mediums referenciados por `deleted_track.medium`; `A+`: mediums referenciados por `inserted_track.medium` | `track(tr)` ocorre no corpo como relação não pivô. No caminho iniciado em `medium`, `track` é a relação-alvo do passo inverso `track_fk_medium^-1`. |
| `psi_track_1` | `track` | `[]` | `pivot` | Tuplas de `inserted_track` | `pivot(Ψ) = track`. A regra não contém uma segunda ocorrência não pivô de `track`; por isso não precisa de `track` em `path(Ψ)`. |
| `psi_track_2` | `track` | `[]` | `pivot` | Tuplas de `inserted_track` com `position IS NOT NULL` | `pivot(Ψ) = track`. A regra não contém uma segunda ocorrência não pivô de `track`; por isso não precisa de `track` em `path(Ψ)`. |
| `psi_track_3` | `track` | `[]` | `pivot` | Tuplas de `inserted_track` com `name IS NOT NULL` | `pivot(Ψ) = track`. A regra não contém uma segunda ocorrência não pivô de `track`; por isso não precisa de `track` em `path(Ψ)`. |
| `psi_track_4` | `track` | `[]` | `pivot` | Tuplas de `inserted_track` com `length IS NOT NULL` | `pivot(Ψ) = track`. A regra não contém uma segunda ocorrência não pivô de `track`; por isso não precisa de `track` em `path(Ψ)`. |
| `psi_track_5` | `track` | `[track_fk_recording]` | `pivot` | Tuplas de `inserted_track` que alcançam `recording` por `track.recording = recording.id` | `pivot(Ψ) = track`. `recording` é a relação não pivô do caminho; `track` aparece apenas como pivô, não como ocorrência não pivô. |

Assim:

`Relev(track) = {psi_artist_11, psi_medium_4, psi_track_1, psi_track_2, psi_track_3, psi_track_4, psi_track_5}`.

Nenhuma regra é simultaneamente pivot-relevant e relation-relevant para `track`.

## B) Função PostgreSQL

A função executável está em `compute_changeset_track.sql`. Ela:

1. insere exatamente um evento de atualização em `rdf_maintenance_queue`;
2. usa `deleted_track` e `inserted_track` como tabelas de transição;
3. insere exatamente sete contribuições, uma para cada regra de `Relev(track)`;
4. computa `A−`, `A+`, `S2` e `DeltaPlusRel` para as duas regras relation-relevant;
5. computa `DeltaPlusPivot` para as cinco regras pivot-relevant;
6. publica `DeltaPlus` como a união das parcelas aplicáveis;
7. usa cada `Rule URI` certificada como `rule_graph_uri` e como grafo do template;
8. não executa SPARQL nem acessa GraphDB;
9. termina com `RETURN NULL`.

Os componentes fixos dos quads ficam nos templates e os componentes variáveis nas contribuições, exatamente como especificado pela infraestrutura:

- CTR: `class_quad_template`;
- Local-DTR: `datatype_quad_template`;
- OTR: `object_quad_template`.

Para as três Local-DTRs, a tipagem literal foi obtida das colunas declaradas no esquema:

- `track.position INTEGER` → `xsd:integer`;
- `track.name VARCHAR` → `xsd:string`;
- `track.length INTEGER` → `xsd:integer`.

## C) Trigger PostgreSQL

O mesmo arquivo SQL cria:

```sql
CREATE TRIGGER trg_compute_changeset_track
AFTER UPDATE ON track
REFERENCING
    OLD TABLE AS deleted_track
    NEW TABLE AS inserted_track
FOR EACH STATEMENT
EXECUTE FUNCTION compute_changeset_track();
```

## Observação produzida pelo teste

Na página 7 do prompt v8, a frase “Rule contribution for a CTR: S2 and DeltaPlus” não coincide com o template CTR do arquivo de infraestrutura, que define `DeltaPlusPivot` e `DeltaPlus` e não define `S2`.

O SQL segue o template da infraestrutura porque o próprio prompt manda preservar sua estrutura sem alterações. A correção textual mínima recomendada para o prompt é:

> Rule contribution for a CTR: DeltaPlusPivot and DeltaPlus.
