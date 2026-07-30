# 2027-EDBT-Experiments
Supplemental Material


# IVM

## Introduction

This repository contains the full paper with all proofs, the code, data, and resources that complement the paper submitted for publication:  

**Incremental Maintenance of RDB2RDF Views: A Post-Update, LLM-Compilable Formulation of Changeset Computation**

*Abstract*

A strategy for exposing relational data as part of a knowledge graph is to define RDB2RDF views that map relational tuples to RDF triples using transformation rules. These views are often materialized in RDF stores to improve query performance and data availability, requiring incremental mechanisms to maintain them under updates. A central problem in incremental maintenance is computing deletion changesets, which traditionally requires reconstructing the pre-update database state. This paper challenges this assumption by introducing a formal model of transformation rules that leads to provably correct changesets that operate directly over the post-update state. The paper proceeds by describing how to create an asynchronous maintenance tool for an RDB2RDF view, defined by R2RML statements, leveraging the formal model. As a pre-processing stage, the paper starts by showing how to compile R2RML statements into transformation rules with the help of an LLM, prompted with the formal model. Then, it introduces an asynchronous maintenance architecture that features AFTER triggers automatically synthesized from the transformation rules, again with the help of an LLM, prompted with the formal model. Finally, the paper describes an experiment that evaluates the complete implementation cycle for an RDB2RDF view defined on top of a version of the MusicBrainz database. The paper therefore demonstrates that LLMs, when guided by the proposed formal model, can automatically generate correct database triggers and the maintenance logic for the proposed architecture.
 
## Repository Structure

### Full paper
The full paper is available at 
`Full-Paper.pdf`

### Database
The MusicBrains relational schema is available at 
`MusicBrainz-Complete-Schema.sql`

### Prompts
This folder contains the main prompts and attached documents used in the experiments. It is organized into the following subfolders:

- Phase 1 – Transformation Rules Compilation
	This folder contains the prompt used to compile the R2RML statements into equivalent URI constructors and transformation rules:
	`PROMPT - R2RML-to-TR Compilation.md`
	 
- Phase 2 - Triggers Compilation
	This folder contains the prompt used to compile the transformation rules into after triggers:
	`PROMPT - Generate the After Trigger for Table R.md`
	 and the files passed as attachments:
	`IVM-Short-Paper.pdf`
	`MusicBrainz-Complete-Schema.sql`
	`Infrastructure-Maintenance-Queue.pdf`
	`musicbrainz-transformation-rules.xlsx`

### Results
This folder contains the results of the experiments. It is organized into the following subfolders:

- Phase 1 – Transformation Rules Compilation
	This folder contains a single spreadsheet with the results of Phase 1 of the implementation - the URI constructors and transformation rules compiled from the R2RML statements:
	`musicbrainz-transformation-rules.xlsx`

- Phase 2 - Triggers Compilation
	This folder contains the results of Phase 2 of the implementation – the triggers compiled. The first file describes the validation process in detail:
	 `validation-trigger-compilation (Phase 2).md`
	 
	The subfolders are organized by LLM.

	- GPT-5.6
		This folder contains the triggers generated using GPT-5.6 and their evaluation. It is organized into subfolders by database relation.
		- Artist
			This folder contains the results for the Artist relation.
			`GPT-5.6-compute-changeset-artist.sql` -- the trigger-side work of Algorithm 2.
			`GPT-5.6-results-artist.md` -- the final results of Phase 2.
		- `GPT-5.6-trigger-evaluation-artist.md` -- the evaluation of the final results of Phase 2.
		- Medium
			This folder contains the results for the Medium relation.
			`GPT-5.6-compute-changeset-medium.sql` -- the trigger-side work of Algorithm 2.
			`GPT-5.6-results-medium.md` -- the final results of Phase 2.
			`GPT-5.6-trigger-evaluation-medium.md` -- the evaluation of the final results of Phase 2.
		- Track
			This folder contains the results for the Track relation.
			`GPT-5.6-compute-changeset-track.sql` -- the trigger-side work of Algorithm 2.
			`GPT-5.6-results-track.md` -- the final results of Phase 2.
			`GPT-5.6-trigger-evaluation-track.md` -- the evaluation of the final results of Phase 2.

	  - Qwen3.8
		This folder contains the triggers generated using Qwen3.8 and their evaluation. It is organized into subfolders by database relation.
		- Track
			This folder contains the results for the Track relation.
			`Qwen3.8-compute-changeset-track.sql` -- the trigger-side work of Algorithm 2.
			`Qwen3.8-results-track.md` -- the final results of Phase 2.
			`Qwen3.8-trigger-evaluation-track.md` -- the evaluation of the final results of Phase 2.
