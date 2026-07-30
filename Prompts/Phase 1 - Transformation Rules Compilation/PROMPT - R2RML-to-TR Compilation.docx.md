# **Prompt: R2RML-to-TR Compilation**

You are given the following inputs:

* **the relational database schema**:  
  Esquema MusicBrainz Completo  
* **the R2RML mappings defining the LinkedBrainz RDF view**:  
  map R2RML \_ MusicBrainz completo  
* **Transformation Rules formalism:**   
  2027 EDBT   
* **Additional integrity constraints:** Assume that the attribute `name` is a unique identifier of the `tag` relation. 

**Task:** Your task is to  transforms an Entity-Preserving R2RML mapping into a certified semantic specification expressed as Transformation Rules. The **R2RML-to-TR Compilation Process** consists of the following six steps (subtasks):

1. **Verify the Entity-Preserving Property.**  
2. **Identify the Candidate Pivot Relation.**  
3. **Derive the URI Constructor.**  
4. **Define the `hasURI` Predicate.**  
5. **Validate the Pivot Relation and URI Constructor.**  
6. **Generate and validate the Transformation Rules.**

Each Triples Map must be processed independently through these six steps. Transformation Rules must be generated only if the mapping is classified as entity-preserving and both the pivot relation and the URI constructor are successfully validated. Otherwise, the Triples Map must be classified as **Manual Analysis Required**, and no Transformation Rules should be generated.

### Process Output

The output of the R2RML-to-TR Compilation Process is a structured **JSON file** containing the information extracted and generated during the six compilation steps for each R2RML Triples Map. The JSON file records the entity-preservation analysis, the identified pivot relation, the derived URI constructor and `hasURI` predicate, the validation results, and the generated Transformation Rules. For mappings that fail the validation process, the output records the corresponding validation errors and marks them as **Manual Analysis Required**, without generating Transformation Rules.

This JSON file provides a structured and machine-readable representation of the compilation results and serves as the input for the subsequent trigger-generation phase.

---

### Step 1 — Verify the Entity-Preserving Property

For each mapping, determine whether it satisfies the entity-preserving property.

Only mappings satisfying this property are considered eligible for automatic compilation into Transformation Rules.

Mappings that are not entity-preserving must be reported for manual analysis.

Determine whether the mapping satisfies all of the following conditions.

1. A pivot relation exists.  
2. Every tuple of the pivot relation generates exactly one RDF resource.  
3. Every RDF resource corresponds to exactly one pivot tuple.  
4. The logical table does not contain analytical constructs that destroy the one-to-one correspondence, such as  
* GROUP BY  
* DISTINCT  
* UNION  
* aggregation  
* other derived analytical transformations.  
5. The subject URI is functionally determined by the pivot tuple.

If any condition is violated, classify the mapping as Manual Analysis Required and explain why.

---

### Step 2 — Identify the Pivot Relation

If the mapping is entity-preserving, identify the pivot relation and explain why this relation represents the identity of the RDF resource. 

**The relation whose tuples determine the identity of the RDF subject is** the candidate pivot relation.

**Additional Rule — Pivot Relation Selection**

The pivot relation shall be identified from the semantics of the mapping, not from the syntactic structure of the SQL query. Determine the pivot relation using the relational schema, including primary keys, candidate keys, functional dependencies, foreign-key relationships, and join cardinalities. The pivot relation is the relation whose tuples uniquely determine the identity of the generated RDF resource. Do not assume that the first table appearing in the `FROM` clause is the pivot relation.

The pivot relation is not the relation that generates the triples; it is the relation that identifies the RDF subject.

---

### Step 3 — Derive the URI Constructor

URI\_R(r,s) ≡ hasURI(template, \<e1,...,en\>, s)

where

\-  ***template*** denotes the URI template extracted from the R2RML Subject Map, 

\- **\<e1,...,en\>** is the ordered sequence of pivot-rooted attribute expressions corresponding to the placeholders of the R2RML URI template;, and 

\- **s** is the URI associated with the pivot tuple r.

Pivot-rooted attribute expressions have one of the following forms:

ei ::= r.A

ei ::= \[FK(r,t)/t.A\]

where r.A denotes an attribute of the pivot tuple, and \[FK(r,t)/t.A\] denotes the value of attribute A obtained after following the foreign key FK from the pivot tuple r to tuple t.

For every URI component,

identify whether it is

* a pivot attribute \[r.A\]

or

* an FK-path attribute expression \[ \[FK(r,t)/t.A\].\]

The resulting URI constructor must preserve exactly the same placeholder order defined by the original R2RML template. 

In particular, verify that the placeholder values uniquely identify each participating pivot tuple. If uniqueness cannot be established from the schema or the mapping, classify the Triples Map as **Manual Analysis Required**.

---

### Step 4 — Define the hasURI Predicate

Derive the corresponding predicate

hasURI(template, \<e1,...,en\>, s) iff

	s \= instantiate(template, encode(eval(e1)), ..., encode(eval(en))).

by specifying

* the URI template;  
* every FK navigation required to obtain placeholder values;  
* the concatenation order used to construct the final URI.

 The instantiate function replaces each placeholder of the template with the encoded value obtained by evaluating the corresponding expression while preserving all constant fragments of the template.

Evaluation rules:

  eval(r.A) \= r\[A\]

  eval(\[FK(r,t)/t.A\]) \= t\[A\], provided that FK(r,t) holds.

\============

**Step 5 — Validate the Pivot Relation and URI Constructor**

Validate that the selected pivot relation correctly represents the identity of the RDF subject and that the derived URI constructor is semantically equivalent to the original R2RML subject map. Verify that every template placeholder is functionally determined by the pivot tuple, either directly or through a functional foreign-key path; that the original template fragments and placeholder order are preserved; and that evaluating the URI constructor produces exactly the same subject URI as the R2RML mapping for every logical-table row. Also verify that each generated URI corresponds to exactly one pivot tuple and that each participating pivot tuple generates at most one subject URI. If any condition cannot be established, classify the mapping as **Manual Analysis Required**.

**\====================**

### **Step 6 — Generate and Validate  the Transformation Rules**

After the Triples Map has been classified as entity-preserving and both the pivot relation and the URI constructor have been successfully validated, generate the corresponding Transformation Rules. 

The Transformation Rules must be generated strictly according to the TR formalism provided in Section 3 of the paper \[2027 EDBT\]. Do not invent rule types, predicates, operators, or syntactic constructs that are not defined in the provided formalism.

The generated rules must:

* use the validated pivot relation as the pivot of the transformation;  
* use the validated URI​ predicate to identify the RDF subject;  
* preserve the semantics of the original R2RML Triples Map;  
* translate each predicate-object map into the corresponding transformation rule;  
* preserve all relevant join conditions, attribute expressions, constants, datatypes, language tags, and IRI-construction expressions;  
* generate only rules that are supported by the relational schema and explicitly defined in the R2RML mapping.  
* RelationalPath must be represented as an ordered list of foreign key constraints, RelationalPath=\[fk1,…,fkn\]\\ where each fki​  
  * :is a **concrete foreign key constraint** defined in the relational schema;  
* appears **exactly with its original name** as declared in the schema;  
* occupies the position corresponding to its traversal order along the relational path;  
* connects the pivot relation to the target relation;  
* **must not** be replaced by generic symbols such as `FK`, `path`, `RelationalPath`, `relational_path_from_SQL`, or by any other auxiliary predicate or invented notation.  
* The compilation process must preserve the exact sequence of foreign key constraints extracted from the relational schema. No abstraction, renaming, or simplification of the relational path is permitted.

Transformation Rules must be generated only when:

Entity-Preserving: YES

Pivot Relation Validation: VALIDATED

URI Constructor Validation: VALIDATED

Otherwise, no Transformation Rules must be generated, and the Triples Map must be reported as:  Manual Analysis Required. 

**Rule Naming Convention**

Assign a unique identifier to each generated Transformation Rule using the following format :`psi_<pivot_relation>_<sequential_number> ,` where `<sequential_number>` is an integer assigned sequentially within the same pivot relation.

**Example:** psi\_artist\_1 psi\_artist\_2

**Step 1: Generate and Validate the Class Transformation rules**

    For each validated Entity-Preserving `TriplesMap`:

1. Instantiate the CTR template defined by the proposed formalism.  
2. Reuse the validated compilation specification produced in the previous phase.  
3. Populate the CTR template with:  
   * the RDF class generated by the `TriplesMap`;  
   * the validated pivot relation;  
   * the validated URI constructor;  
   * the corresponding `hasURI` predicate;  
   * the selection condition, when specified by the R2RML mapping.  
4. If no selection condition is defined, generate the CTR without a selection predicate.  
5. Preserve the URI generation and selection condition exactly as specified by the R2RML mapping.  
6. Do not introduce new predicates, notation, selection conditions, or auxiliary expressions beyond those defined by the formalism.  
7. Produce one Class Transformation Rule (CTR) for each validated Entity-Preserving `TriplesMap`.  
8. Validate the generated CTR Validate the generated CTR by comparing it with the corresponding R2RML `TriplesMap`, the validated compilation specification, and the formal CTR template.

Do not generate a new CTR unless a correction is explicitly requested. Do not introduce new predicates, notation, relations, attributes, or conditions.

**VALIDATION CHECKS**

1. **Template conformance**

    Verify that the generated rule is a valid instance of the formal CTR template.

2. **RDF class**

    Verify that the class in the head of the CTR is exactly the class generated by the corresponding R2RML `TriplesMap`.

3. **Pivot relation**

    Verify that the relation used in the body of the CTR is exactly the validated pivot relation.

4. **URI constructor**

    Verify that the CTR uses the validated URI constructor associated with the pivot relation.

5. **URI equivalence**

    Verify that the URI generated by the CTR is equivalent to the URI generated by the R2RML Subject Map, including:

   * URI template or constant;  
   * referenced attributes;  
   * placeholder order;  
   * foreign-key paths, when applicable;  
   * term type.  
6. **`hasURI` predicate**

    Verify that the `hasURI` expression is instantiated exactly as defined in the validated compilation specification.

7. **Selection condition**

    Verify that the selection condition is included when specified by the logical table or SQL query of the R2RML mapping.

    If no selection condition exists in the mapping, verify that the CTR does not introduce one.

    Verify that the selection condition preserves the original relational semantics and does not omit, weaken, strengthen, or modify any predicate.

8. **Schema consistency**

    Verify that every referenced relation, attribute, foreign key, and path exists in the relational schema and is used with the correct name and direction.

9. **No unsupported content**

    Verify that the CTR does not contain:

   * invented predicates;  
   * undefined notation;  
   * additional joins;  
   * additional filters;  
   * omitted URI components;  
   * attributes not functionally determined by the pivot relation.  
10. **Entity-preserving consistency**

     Verify that the CTR remains consistent with the previously validated Entity-Preserving specification, including the one-to-one correspondence between pivot tuples and generated RDF subjects.

Return the validation result using the following structure:

9. Rule identifier:  
10. Rule type: CTR  
11. Validation status: PASS | FAIL  
12. Checks:  
13. \- Template conformance: PASS | FAIL  
14. \- RDF class: PASS | FAIL  
15. \- Pivot relation: PASS | FAIL  
16. \- URI constructor: PASS | FAIL  
17. \- URI equivalence: PASS | FAIL  
18. \- hasURI predicate: PASS | FAIL  
19. \- Selection condition: PASS | FAIL | NOT APPLICABLE  
20. \- Schema consistency: PASS | FAIL  
21. \- Entity-preserving consistency: PASS | FAIL  
22. \- No unsupported content: PASS | FAIL  
23.   
24. Detected inconsistencies:  
25. \- ...  
26.   
27. Required corrections:  
28. \- ...  
29.   
30. Validation evidence:

    \- For each failed check, identify the conflicting elements in the generated CTR, the R2RML mapping, or the validated specification.

\- Return `PASS` only if all applicable checks pass. Otherwise, return `FAIL`.

**Step 2: Generate and Validate the Object Transformation rules**

For each PredicateObjectMap that generates RDF resources: 

1\. Instantiate the OTR template defined in the formal specification. 

2\. Reuse the previously generated CTRs. 

3\. Derive: 

• the target pivot relation; 

• the relational path.

 4\. The relational path must exactly reproduce the join structure of the R2RML mapping. 

5\. Do not introduce new notation or auxiliary predicates. 

6\. Produce one OTR for each PredicateObjectMap.

**Step 3: Generate and Validate the Data Transformation rules**

For each `PredicateObjectMap` that generates RDF literal:

1. Instantiate the DTR template defined by the proposed formalism.  
2. Reuse the previously generated Class Transformation Rule (CTR) corresponding to the subject class.  
3. Derive:  
   * the target relation containing the attribute referenced by the ObjectMap;  
   * the relational path from the pivot relation to the target relation, when the attribute is not stored in the pivot relation;  
   * the transformation function specified by the ObjectMap, when applicable.  
4. If the attribute belongs to the pivot relation, no relational path should be generated.  
5. Represent relational paths exactly using the formal notation defined in Section 3\. Do not introduce auxiliary predicates or alternative notation.  
6. Preserve all transformation functions, datatypes, language tags, constants, templates, and literal values exactly as specified in the R2RML mapping.  
7. Produce one Data Transformation Rule (DTR) for each PredicateObjectMap.

Validate the generated DTR by comparing it with the corresponding R2RML `PredicateObjectMap`, the validated subject CTR, the relational schema, and the formal DTR template.

Do not generate a new DTR unless a correction is explicitly requested. Do not introduce new predicates, notation, relations, attributes, paths, transformation functions, or conditions.

### **VALIDATION CHECKS**

1. **Template conformance**

    Verify that the generated rule is a valid instance of the formal DTR template.

2. **Datatype property**

    Verify that the predicate in the head of the DTR is exactly the datatype property specified by the corresponding R2RML `PredicateObjectMap`.

3. **Subject construction**

    Verify that the subject-side atoms of the DTR reproduce the right-hand side of the validated CTR for the domain class, including:

   * the pivot relation RDR\_DRD​;  
   * the URI constructor BD\[d,s\]B\_D\[d,s\]BD​\[d,s\];  
   * the selection condition, when applicable.  
4. **Target relation**

    Verify that the relation containing the source value is correctly identified.

    If the referenced attribute belongs to the pivot relation, verify that the target relation is the pivot relation itself.

    If the referenced attribute belongs to another relation, verify that the correct target relation is used.

5. **Relational path**

    When the target relation differs from the pivot relation, verify that the relational path:

   * connects the pivot relation to the target relation;  
   * exactly reproduces the join structure induced by the R2RML mapping;  
   * uses only foreign keys defined in the relational schema;  
   * preserves the correct order of traversals;  
   * preserves the correct forward or inverse direction of each traversal;  
   * does not omit, add, or replace any traversal.  
6. If the target relation is the pivot relation, verify that no relational path is introduced.

7. **Source attributes**

    Verify that all attributes referenced by the DTR are exactly those specified by the R2RML ObjectMap or by the corresponding logical table expression.

8. **Transformation expression**

    Verify that the literal-producing expression exactly preserves the transformation specified by the ObjectMap, including, when applicable:

   * direct column access;  
   * constants;  
   * templates;  
   * concatenation;  
   * casts;  
   * normalization functions;  
   * user-defined transformation functions;  
   * function names;  
   * input arguments;  
   * argument ordering.  
9. Verify that no transformation is introduced when the ObjectMap defines only a direct column reference.

10. **Literal construction**

     Verify that the generated literal preserves all applicable R2RML term-map characteristics, including:

    * lexical value;  
    * `rr:termType`;  
    * `rr:datatype`;  
    * `rr:language`;  
    * constant literal value;  
    * template structure and placeholder order.  
11. **Null semantics**

     Verify that the DTR preserves the null-handling semantics of the R2RML mapping and does not generate an RDF literal when the corresponding ObjectMap would produce no RDF term.

12. **Selection conditions**

     Verify that all relevant selection conditions inherited from the subject CTR or required by the logical table are preserved.

     Verify that the DTR does not omit, weaken, strengthen, or introduce selection conditions.

13. **Schema consistency**

     Verify that every referenced relation, attribute, foreign key, and transformation input exists in the relational schema and is used with the correct name and type.

14. **No unsupported content**

     Verify that the DTR does not contain:

    * invented predicates;  
    * undefined notation;  
    * additional joins;  
    * additional filters;  
    * alternative relational paths;  
    * invented attributes;  
    * invented transformation functions;  
    * omitted literal components;  
    * datatype or language annotations not present in the mapping.

Return the validation result using the following structure:

Rule identifier:

Rule type: DTR

Validation status: PASS | FAIL

Checks:

\- Template conformance: PASS | FAIL

\- Datatype property: PASS | FAIL

\- Subject construction: PASS | FAIL

\- Target relation: PASS | FAIL

\- Relational path: PASS | FAIL | NOT APPLICABLE

\- Source attributes: PASS | FAIL

\- Transformation expression: PASS | FAIL | NOT APPLICABLE

\- Literal construction: PASS | FAIL

\- Null semantics: PASS | FAIL

\- Selection conditions: PASS | FAIL | NOT APPLICABLE

\- Schema consistency: PASS | FAIL

\- No unsupported content: PASS | FAIL

Detected inconsistencies:

\- ...

Required corrections:

\- ...

Validation evidence:

\- For each failed check, identify the conflicting elements in the generated DTR, the R2RML PredicateObjectMap, the validated CTR, or the relational schema.

Return `PASS` only if all applicable checks pass. Otherwise, return `FAIL`.

Do not classify an omitted optional component as an error when it is not required by the corresponding R2RML mapping

---

### **Output Specification**

1\.  The output of the compilation process must be a structured JSON file containing one entry for each R2RML Triples Map analyzed. Each entry must record the information extracted, derived, validated, and generated during the six compilation steps. 

 For each Triples Map, the JSON output must include:

* **Triples Map Identifier:** the identifier of the analyzed R2RML Triples Map.  
* **Entity-Preserving:** `YES` or `NO`.  
* **Justification:** an explanation of the entity-preservation classification.  
* **Pivot Relation:** the identified pivot relation.  
* **Pivot Relation Validation:** `VALIDATED` or `FAILED`, together with the corresponding validation evidence or errors.  
* **R2RML Subject Template:** the original URI template extracted from the R2RML Subject Map.  
* **URI Constructor:** the derived URIR(r,s)URI\_R(r,s)URIR​(r,s) predicate.  
* **URI Components:** the ordered list of pivot-rooted attribute expressions corresponding to the placeholders of the R2RML subject template.  
* **hasURI Definition:** the instantiated `hasURI` predicate, including the template and the ordered URI components.  
* **URI Constructor Validation:** `VALIDATED` or `FAILED`, together with the corresponding validation evidence or errors.  
* **Transformation Rules:** the TRs generated from the Triples Map, when the mapping and its derived components have been successfully validated.  
* **Status:** `COMPILED` or `MANUAL_ANALYSIS_REQUIRED`. 

If a Triples Map is not entity-preserving, or if the pivot relation or URI constructor cannot be successfully validated, the corresponding JSON entry must report the reason for failure, set the status to `MANUAL_ANALYSIS_REQUIRED`, and no Transformation Rules must be generated.

The JSON output must preserve the traceability between the original R2RML Triples Map, the results of the entity-preservation analysis, the derived pivot and URI specifications, the validation results, and the generated Transformation Rules.

2\.  Generate a table containing one entry for each identified pivot relation. For each entry, include:

* the name of the pivot relation;  
* the URI constructor derived from the corresponding R2RML Subject Map;  
* the formal definition of the associated `hasURI` function. 

3\. Generate a table containing one entry for each generated Transformation Rule, **ordered by pivot relation**. For each rule, report the main compilation artifacts, including:

* Rule ID;  
* Rule type (CTR, OTR, or DTR);  
* Pivot relation;  
* Generated RDF class or property;  
* Rule Body  
* URI constructor(s);  
* `hasURI` predicate(s);  
* Source R2RML mapping (`TriplesMap` or `PredicateObjectMap`);  
* Relational path (when applicable);  
* Transformation expression (when applicable);  
* Selection condition (when applicable).

## 

## **\===========================================**

## **Example:**  Uri constructor for pivot table ***artist\_tag*** 

**R2RML:** 

lb:artist\_tag a rr:TriplesMap ;

  rr:logicalTable \[rr:sqlQuery

    """SELECT artist.gid, tag.name

       FROM artist\_tag

         INNER JOIN artist ON artist\_tag.artist \= artist.id          INNER JOIN tag ON artist\_tag.tag \= tag.id"""\] ;  

 rr:subjectMap \[rr:template "http://musicbrainz.org/artist/{gid} \#tag/{name}";

                 rr:class muto:Tagging\] ;

  rr:predicateObjectMap

    \[rr:predicate muto:taggedResource ;

     rr:objectMap lb:sm\_artist\] ,

    \[rr:predicate muto:hasTag ;

     rr:objectMap lb:sm\_tag\] .

**Pivot relation:** artist\_tag

**URI predicate**:

URI\_artist\_tag(r,s) ≡

hasURI(

  "http://musicbrainz.org/artist/{gid}\#tag/{name}",

  \<

    \[artist\_tag\_fk\_artist(r,a)/a.gid\],

    \[artist\_tag\_fk\_tag(r,t)/t.name\]

  \>,

  s

)

Semantics:

s \= instantiate(

      "http://musicbrainz.org/artist/{gid}\#tag/{name}",

      encode(eval(\[artist\_tag\_fk\_artist(r,a)/a.gid\])),

      encode(eval(\[artist\_tag\_fk\_tag(r,t)/t.name\]))

	)

Assuming:

  a.gid \= '8f3d4d52'

  t.name \= 'Jazz'

the resulting URI is:

  http://musicbrainz.org/artist/8f3d4d52\#tag/Jazz

This example illustrates that hasURI reproduces exactly the URI specified by the original R2RML template, while the values inserted into the placeholders are obtained through the pivot-rooted attribute expressions.

## \==========================

## Important Requirements

* Analyze each Triples Map independently.  
* Never infer URI templates that are not explicitly defined in the R2RML mapping.  
* Preserve the original placeholder order of the R2RML template.  
* Every URI component must be rooted at the pivot tuple.  
* Use FK-path attribute expressions whenever the value is obtained through a foreign-key navigation.  
* Be conservative. If the existence of a unique pivot relation cannot be established, classify the mapping as Manual Analysis Required.

> **Nenhum símbolo concreto do esquema pode ser substituído por uma abreviação genérica durante a compilação.**

Isso inclui:

* nomes de relações;  
* nomes de atributos;  
* nomes de foreign keys;  
* aliases das variáveis;  
* templates de URI;  
* ordem dos placeholders;  
* caminhos relacionais;  
* nomes dos Triples Maps.

  