# GPT-5.6 Trigger Evaluation Medium

## **Step 1**

> ### **TR identification:** 
> `identified all relevant rules`

- psi\_release\_4: relation-relevant; medium is the non-pivot target.  
- psi\_medium\_1: pivot-relevant CTR.   
- psi\_medium\_2: pivot-relevant Local-DTR, name \-\> xsd:string.   
- psi\_medium\_3: pivot-relevant Local-DTR, track\_count \-\> xsd:int.   
- psi\_medium\_4: pivot-relevant OTR, evaluated in the post-update state.   
- psi\_medium\_5: pivot-relevant Path-DTR. Definitive author decision: medium\_format.id is an xsd:int literal.  


> ### Computation of A-\[Ψ\](u), A+\[Ψ\](u), S2\[Ψ\](u), Δrel+\[Ψ\](u), Δ+\[Ψ\](u): 
> `correctly produced all relational joins`  
 
- psi\_release\_4: relation-relevant; medium is the non-pivot target.  
```
am AS (  
        SELECT r.\* FROM release r  
        WHERE EXISTS (SELECT 1 FROM deleted\_medium d WHERE d.release \= r.id)  
    ),  
ap AS (  
        SELECT r.\* FROM release r  
        WHERE EXISTS (SELECT 1 FROM inserted\_medium i WHERE i.release \= r.id)  
    ),  
s2q AS (  
        SELECT DISTINCT  
          'http://musicbrainz.org/release/' || r.gid::text || '\#\_' s,  
          'http://musicbrainz.org/record/' || m.id::text || '\#\_' o  
        FROM am r JOIN medium m ON m.release \= r.id  
    ),  
dpq AS (  
        SELECT DISTINCT  
          'http://musicbrainz.org/release/' || r.gid::text || '\#\_' s,  
          'http://musicbrainz.org/record/' || m.id::text || '\#\_' o  
        FROM ap r JOIN medium m ON m.release \= r.id  
    )  
'rdf\_contributions',jsonb\_build\_object(  
          'DeltaPlusPivot','\[\]'::jsonb,  
          'S2',(SELECT COALESCE(jsonb\_agg(jsonb\_build\_object('subject',s,'object',o) ORDER BY s,o),'\[\]') FROM s2q),  
          'DeltaPlusRel',(SELECT COALESCE(jsonb\_agg(jsonb\_build\_object('subject',s,'object',o) ORDER BY s,o),'\[\]') FROM dpq),  
          'DeltaPlus',(SELECT COALESCE(jsonb\_agg(jsonb\_build\_object('subject',s,'object',o) ORDER BY s,o),'\[\]') FROM dpq)));`
```

- psi\_medium\_1: pivot-relevant CTR.   
```'DeltaPlusPivot',q.a,'DeltaPlus',q.a))  
    FROM (  
      SELECT COALESCE(jsonb\_agg(jsonb\_build\_object(  
        'subject','http://musicbrainz.org/record/'||i.id::text||'\#\_')  
        ORDER BY i.id),'\[\]') a  
      FROM inserted\_medium i  
    ) q;
```

- psi\_medium\_2: pivot-relevant Local-DTR, name \-\> xsd:string.   
```
'DeltaPlusPivot',q.a,'S2','\[\]'::jsonb,  
          'DeltaPlusRel','\[\]'::jsonb,'DeltaPlus',q.a))  
    FROM (  
      SELECT COALESCE(jsonb\_agg(jsonb\_build\_object(  
        'subject','http://musicbrainz.org/record/'||i.id::text||'\#\_',  
        'object',i.name) ORDER BY i.id),'\[\]') a  
      FROM inserted\_medium i WHERE i.name IS NOT NULL  
    ) q;
```

- psi\_medium\_3: pivot-relevant Local-DTR, track\_count \-\> xsd:int.   
```
'DeltaPlusPivot',q.a,'S2','\[\]'::jsonb,  
          'DeltaPlusRel','\[\]'::jsonb,'DeltaPlus',q.a))  
    FROM (  
      SELECT COALESCE(jsonb\_agg(jsonb\_build\_object(  
        'subject','http://musicbrainz.org/record/'||i.id::text||'\#\_',  
        'object',i.track\_count) ORDER BY i.id),'\[\]') a  
      FROM inserted\_medium i WHERE i.track\_count IS NOT NULL  
    ) q;
```

- psi\_medium\_4: pivot-relevant OTR, evaluated in the post-update state.   
```
'rdf\_contributions',jsonb\_build\_object(  
          'DeltaPlusPivot',q.a,'S2','\[\]'::jsonb,  
          'DeltaPlusRel','\[\]'::jsonb,'DeltaPlus',q.a))  
    FROM (  
      SELECT COALESCE(jsonb\_agg(jsonb\_build\_object(  
        'subject','http://musicbrainz.org/record/'||i.id::text||'\#\_',  
        'object','http://musicbrainz.org/track/'||t.id::text||'\#\_')  
        ORDER BY i.id,t.id),'\[\]') a  
      FROM inserted\_medium i JOIN track t ON t.medium=i.id  
    ) q;
```

- psi\_medium\_5: pivot-relevant Path-DTR. Definitive author decision: medium\_format.id is an xsd:int literal.  
```
'rdf\_contributions',jsonb\_build\_object(  
          'DeltaPlusPivot',q.a,'S2','\[\]'::jsonb,  
          'DeltaPlusRel','\[\]'::jsonb,'DeltaPlus',q.a))  
    FROM (  
      SELECT COALESCE(jsonb\_agg(jsonb\_build\_object(  
        'subject','http://musicbrainz.org/record/'||i.id::text||'\#\_',  
        'object',mf.id) ORDER BY i.id,mf.id),'\[\]') a  
      FROM inserted\_medium i  
      JOIN medium\_format mf ON mf.id=i.format  
      WHERE mf.id IS NOT NULL  
    ) q;
```

> ### **Code Minimality:** 
> `produced minimal code`

- code
```
INSERT INTO rdf\_rule\_contribution  
    SELECT v\_event\_id,'psi\_medium\_2',  
      'http://musicbrainz.org/graph/mapping/psi\_medium\_2',  
      'pivot','medium','\[\]'::jsonb,  
      jsonb\_build\_object(  
        'rule\_id','psi\_medium\_2','rule\_type','DTR',  
        'affected\_tuples',jsonb\_build\_object('A\_minus','\[\]'::jsonb,'A\_plus','\[\]'::jsonb),  
        'datatype\_quad\_template',jsonb\_build\_object(  
          'predicate','http://purl.org/dc/elements/1.1/title',  
          'datatype','http://www.w3.org/2001/XMLSchema\#string',  
          'graph','http://musicbrainz.org/graph/mapping/psi\_medium\_2'),  
        'rdf\_contributions',jsonb\_build\_object(  
          'DeltaPlusPivot',q.a,'S2','\[\]'::jsonb,  
          'DeltaPlusRel','\[\]'::jsonb,'DeltaPlus',q.a))  
    FROM (  
      SELECT COALESCE(jsonb\_agg(jsonb\_build\_object(  
        'subject','http://musicbrainz.org/record/'||i.id::text||'\#\_',  
        'object',i.name) ORDER BY i.id),'\[\]') a  
      FROM inserted\_medium i WHERE i.name IS NOT NULL  
    ) q;
```

> ### **Hallucination:** 
`did not hallucinate`


## **Step 2**

### 2.1 Rule Contribution Correctness

#### **Update scenario:**  
```
UPDATE medium  
SET track\_count \= 21  
WHERE id \= 55522;
```

#### **GPT-Medium: Validation of Data Generated by the Trigger**

| Rule | Expected Data | Data Generated by the Trigger | Is the Same |
| :---- | :---- | :---- | :---- |
| psi\_medium\_1 | \<http://musicbrainz.org/record/55522\#\_\> \<http://www.w3.org/1999/02/22-rdf-syntax-ns\#type\> \<http://purl.org/ontology/mo/Record\> \<http://musicbrainz.org/graph/mapping/psi\_medium\_1\> .  | { "rdf\_contributions": {     "DeltaPlus": \[       {         "subject": "http://musicbrainz.org/record/55522\#\_"       }     \],     "DeltaPlusPivot": \[       {         "subject": "http://musicbrainz.org/record/55522\#\_"       }     \]   },   "class\_quad\_template": {     "class": "http://purl.org/ontology/mo/Record",     "graph": "http://musicbrainz.org/graph/mapping/psi\_medium\_1",     "predicate": "http://www.w3.org/1999/02/22-rdf-syntax-ns\#type"   } } | YES |
| psi\_medium\_2 | \<http://musicbrainz.org/record/55522\#\_\> \<http://purl.org/dc/elements/1.1/title\> "" \<http://musicbrainz.org/graph/mapping/psi\_medium\_2\> .  | { "rdf\_contributions": {     "S2": \[\],     "DeltaPlus": \[       {         "object": "",         "subject": "http://musicbrainz.org/record/55522\#\_"       }     \],     "DeltaPlusRel": \[\],     "DeltaPlusPivot": \[       {         "object": "",         "subject": "http://musicbrainz.org/record/55522\#\_"       }     \]   },   "datatype\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_medium\_2",     "datatype": "http://www.w3.org/2001/XMLSchema\#string",     "predicate": "http://purl.org/dc/elements/1.1/title"   } }  | YES |
| psi\_medium\_3 | \<http://musicbrainz.org/record/55522\#\_\> \<http://purl.org/ontology/mo/track\_count\> "21"^^\<http://www.w3.org/2001/XMLSchema\#int\> \<http://musicbrainz.org/graph/mapping/psi\_medium\_3\> .  | { "rdf\_contributions": {     "S2": \[\],     "DeltaPlus": \[       {         "object": 21,         "subject": "http://musicbrainz.org/record/55522\#\_"       }     \],     "DeltaPlusRel": \[\],     "DeltaPlusPivot": \[       {         "object": 21,         "subject": "http://musicbrainz.org/record/55522\#\_"       }     \]   },   "datatype\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_medium\_3",     "datatype": "http://www.w3.org/2001/XMLSchema\#int",     "predicate": "http://purl.org/ontology/mo/track\_count"   } } | YES |
| psi\_medium\_4 | \<http://musicbrainz.org/record/55522\#\_\> \<http://purl.org/ontology/mo/track\> \<http://musicbrainz.org/track/1000034\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_medium\_4\> . \<http://musicbrainz.org/record/55522\#\_\> \<http://purl.org/ontology/mo/track\> \<http://musicbrainz.org/track/1000025\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_medium\_4\> . \<http://musicbrainz.org/record/55522\#\_\> \<http://purl.org/ontology/mo/track\> \<http://musicbrainz.org/track/1000029\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_medium\_4\> . \<http://musicbrainz.org/record/55522\#\_\> \<http://purl.org/ontology/mo/track\> \<http://musicbrainz.org/track/1000033\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_medium\_4\> . \<http://musicbrainz.org/record/55522\#\_\> \<http://purl.org/ontology/mo/track\> \<http://musicbrainz.org/track/1000027\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_medium\_4\> . \<http://musicbrainz.org/record/55522\#\_\> \<http://purl.org/ontology/mo/track\> \<http://musicbrainz.org/track/1000028\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_medium\_4\> . \<http://musicbrainz.org/record/55522\#\_\> \<http://purl.org/ontology/mo/track\> \<http://musicbrainz.org/track/1000031\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_medium\_4\> . \<http://musicbrainz.org/record/55522\#\_\> \<http://purl.org/ontology/mo/track\> \<http://musicbrainz.org/track/1000030\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_medium\_4\> . \<http://musicbrainz.org/record/55522\#\_\> \<http://purl.org/ontology/mo/track\> \<http://musicbrainz.org/track/1000032\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_medium\_4\> . \<http://musicbrainz.org/record/55522\#\_\> \<http://purl.org/ontology/mo/track\> \<http://musicbrainz.org/track/1000026\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_medium\_4\> . | {  "rdf\_contributions": {     "S2": \[\],     "DeltaPlus": \[       {         "object": "http://musicbrainz.org/track/1000025\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000026\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000027\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000028\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000029\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000030\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000031\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000032\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000033\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000034\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       }     \],     "DeltaPlusRel": \[\],     "DeltaPlusPivot": \[       {         "object": "http://musicbrainz.org/track/1000025\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000026\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000027\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000028\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000029\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000030\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000031\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000032\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000033\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       },       {         "object": "http://musicbrainz.org/track/1000034\#\_",         "subject": "http://musicbrainz.org/record/55522\#\_"       }     \]   },   "object\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_medium\_4",     "predicate": "http://purl.org/ontology/mo/track"   } } | YES |
| psi\_medium\_5 | \<http://musicbrainz.org/record/55522\#\_\> \<http://purl.org/ontology/mo/media\_type\> "31"^^\<http://www.w3.org/2001/XMLSchema\#int\> \<http://musicbrainz.org/graph/mapping/psi\_medium\_5\> . | { "rdf\_contributions": {     "S2": \[\],     "DeltaPlus": \[       {         "object": 31,         "subject": "http://musicbrainz.org/record/55522\#\_"       }     \],     "DeltaPlusRel": \[\],     "DeltaPlusPivot": \[       {         "object": 31,         "subject": "http://musicbrainz.org/record/55522\#\_"       }     \]   },   "datatype\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_medium\_5",     "datatype": "http://www.w3.org/2001/XMLSchema\#int",     "predicate": "http://purl.org/ontology/mo/media\_type"   } } | YES |
| psi\_release\_4 | \<http://musicbrainz.org/record/55522\#\_\> \<http://purl.org/ontology/mo/record\> \<http://musicbrainz.org/release/9d52af97-3527-4aeb-85da-57fd0f84a81a\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_medium\_4\> .  | { "rdf\_contributions": {     "S2": \[       {         "object": "http://musicbrainz.org/record/55522\#\_",         "subject": "http://musicbrainz.org/release/9d52af97-3527-4aeb-85da-57fd0f84a81a\#\_"       }     \],     "DeltaPlus": \[       {         "object": "http://musicbrainz.org/record/55522\#\_",         "subject": "http://musicbrainz.org/release/9d52af97-3527-4aeb-85da-57fd0f84a81a\#\_"       }     \],     "DeltaPlusRel": \[       {         "object": "http://musicbrainz.org/record/55522\#\_",         "subject": "http://musicbrainz.org/release/9d52af97-3527-4aeb-85da-57fd0f84a81a\#\_"       }     \],     "DeltaPlusPivot": \[\]   },   "object\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_release\_4",     "predicate": "http://purl.org/ontology/mo/record"   } } | YES |



####  **Validation Summary Table**

| Rule | Expected Data | Data Generated by the Trigger | Is the Same |
| :---- | :---- | :---- | :---- |
| **psi\_medium\_1 / psi\_medium\_2** | \[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#) \[http://www.w3.org/1999/02/22-rdf-syntax-ns\#type\](http://www.w3.org/1999/02/22-rdf-syntax-ns\#type) \[http://purl.org/ontology/mo/Record\](http://purl.org/ontology/mo/Record) \[http://musicbrainz.org/graph/mapping/psi\_medium\_1\](http://musicbrainz.org/graph/mapping/psi\_medium\_1) .  \[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#) \[http://purl.org/dc/elements/1.1/title\](http://purl.org/dc/elements/1.1/title) \[http://musicbrainz.org/graph/mapping/psi\_medium\_2\](http://musicbrainz.org/graph/mapping/psi\_medium\_2) . | {"rdf\_contributions": {"DeltaPlus": \[{"subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_"}\], "DeltaPlusPivot": \[{"subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_"}\], "class\_quad\_template": {"class": "\[http://purl.org/ontology/mo/Record\](http://purl.org/ontology/mo/Record)", "graph": "\[http://musicbrainz.org/graph/mapping/psi\_medium\_1\](http://musicbrainz.org/graph/mapping/psi\_medium\_1)", "predicate": "\[http://www.w3.org/1999/02/22-rdf-syntax-ns\#type\](http://www.w3.org/1999/02/22-rdf-syntax-ns\#type)"}}, {"rdf\_contributions": {"S2": \[\], "DeltaPlus": \[{"object": "", "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)"}\], "DeltaPlusRel": \[\], "DeltaPlusPivot": \[{"object": "", "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_"}\], "datatype\_quad\_template": {"graph": "\[http://musicbrainz.org/graph/mapping/psi\_medium\_2\](http://musicbrainz.org/graph/mapping/psi\_medium\_2)", "datatype": "\[http://www.w3.org/2001/XMLSchema\#string\](http://www.w3.org/2001/XMLSchema\#string)", "predicate": "\[http://purl.org/dc/elements/1.1/title\](http://purl.org/dc/elements/1.1/title)"}}}} | **YES** |
| **psi\_medium\_3** | \[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#) \[http://purl.org/ontology/mo/track\_count\](http://purl.org/ontology/mo/track\_count) "21"^^\[http://www.w3.org/2001/XMLSchema\#int\](http://www.w3.org/2001/XMLSchema\#int) \[http://musicbrainz.org/graph/mapping/psi\_medium\_3\](http://musicbrainz.org/graph/mapping/psi\_medium\_3) . | {"rdf\_contributions": {"S2": \[\], "DeltaPlus": \[{"object": 21, "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_"}\], "DeltaPlusRel": \[\], "DeltaPlusPivot": \[{"object": 21, "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)"}\], "datatype\_quad\_template": {"graph": "\[http://musicbrainz.org/graph/mapping/psi\_medium\_3\](http://musicbrainz.org/graph/mapping/psi\_medium\_3)", "datatype": "\[http://www.w3.org/2001/XMLSchema\#int\](http://www.w3.org/2001/XMLSchema\#int)", "predicate": "\[http://purl.org/ontology/mo/track\_count\](http://purl.org/ontology/mo/track\_count)"}}} | **YES** |
| **psi\_medium\_4** | \<\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_\> \[http://purl.org/ontology/mo/track\](http://purl.org/ontology/mo/track) \<\[http://musicbrainz.org/track/1000034\#\](http://musicbrainz.org/track/1000034\#)\_\> \[http://musicbrainz.org/graph/mapping/psi\_medium\_4\](http://musicbrainz.org/graph/mapping/psi\_medium\_4) .  \[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#) \[http://purl.org/ontology/mo/track\](http://purl.org/ontology/mo/track) \<\[http://musicbrainz.org/track/1000025\#\](http://musicbrainz.org/track/1000025\#)\_\> \[http://musicbrainz.org/graph/mapping/psi\_medium\_4\](http://musicbrainz.org/graph/mapping/psi\_medium\_4) .  \[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#) \[http://purl.org/ontology/mo/track\](http://purl.org/ontology/mo/track) \<\[http://musicbrainz.org/track/1000029\#\](http://musicbrainz.org/track/1000029\#)\_\> \[http://musicbrainz.org/graph/mapping/psi\_medium\_4\](http://musicbrainz.org/graph/mapping/psi\_medium\_4) .  \<\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_\> \[http://purl.org/ontology/mo/track\](http://purl.org/ontology/mo/track) \[http://musicbrainz.org/track/1000033\#\](http://musicbrainz.org/track/1000033\#) \[http://musicbrainz.org/graph/mapping/psi\_medium\_4\](http://musicbrainz.org/graph/mapping/psi\_medium\_4) .  \<\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_\> \[http://purl.org/ontology/mo/track\](http://purl.org/ontology/mo/track) \<\[http://musicbrainz.org/track/1000027\#\](http://musicbrainz.org/track/1000027\#)\_\> \[http://musicbrainz.org/graph/mapping/psi\_medium\_4\](http://musicbrainz.org/graph/mapping/psi\_medium\_4) .  \[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#) \[http://purl.org/ontology/mo/track\](http://purl.org/ontology/mo/track) \<\[http://musicbrainz.org/track/1000028\#\](http://musicbrainz.org/track/1000028\#)\_\> \[http://musicbrainz.org/graph/mapping/psi\_medium\_4\](http://musicbrainz.org/graph/mapping/psi\_medium\_4) .  \<\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_\> \[http://purl.org/ontology/mo/track\](http://purl.org/ontology/mo/track) \<\[http://musicbrainz.org/track/1000031\#\](http://musicbrainz.org/track/1000031\#)\_\> \[http://musicbrainz.org/graph/mapping/psi\_medium\_4\](http://musicbrainz.org/graph/mapping/psi\_medium\_4) .  \[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#) \[http://purl.org/ontology/mo/track\](http://purl.org/ontology/mo/track) \<\[http://musicbrainz.org/track/1000030\#\](http://musicbrainz.org/track/1000030\#)\_\> \[http://musicbrainz.org/graph/mapping/psi\_medium\_4\](http://musicbrainz.org/graph/mapping/psi\_medium\_4) .  \[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#) \[http://purl.org/ontology/mo/track\](http://purl.org/ontology/mo/track) \<\[http://musicbrainz.org/track/1000032\#\](http://musicbrainz.org/track/1000032\#)\_\> \[http://musicbrainz.org/graph/mapping/psi\_medium\_4\](http://musicbrainz.org/graph/mapping/psi\_medium\_4) .  \<\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_\> \[http://purl.org/ontology/mo/track\](http://purl.org/ontology/mo/track) \<\[http://musicbrainz.org/track/1000026\#\](http://musicbrainz.org/track/1000026\#)\_\> \[http://musicbrainz.org/graph/mapping/psi\_medium\_4\](http://musicbrainz.org/graph/mapping/psi\_medium\_4) . | {"rdf\_contributions": {"S2": \[\], "DeltaPlus": \[{"object": "\[http://musicbrainz.org/track/1000025\#\](http://musicbrainz.org/track/1000025\#)\_", "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)"}, {"object": "\[http://musicbrainz.org/track/1000026\#\](http://musicbrainz.org/track/1000026\#)\_", "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_"}, {"object": "\[http://musicbrainz.org/track/1000027\#\](http://musicbrainz.org/track/1000027\#)\_", "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_"}, {"object": "\[http://musicbrainz.org/track/1000028\#\](http://musicbrainz.org/track/1000028\#)\_", "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_"}, {"object": "\[http://musicbrainz.org/track/1000029\#\](http://musicbrainz.org/track/1000029\#)\_", "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_"}, {"object": "\[http://musicbrainz.org/track/1000030\#\](http://musicbrainz.org/track/1000030\#)\_", "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_"}, {"object": "\[http://musicbrainz.org/track/1000031\#\](http://musicbrainz.org/track/1000031\#)\_", "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)"}, {"object": "\[http://musicbrainz.org/track/1000032\#\](http://musicbrainz.org/track/1000032\#)\_", "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_"}, {"object": "\[http://musicbrainz.org/track/1000033\#\](http://musicbrainz.org/track/1000033\#)\_", "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_"}, {"object": "\[http://musicbrainz.org/track/1000034\#\](http://musicbrainz.org/track/1000034\#)\_", "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_"}\], "DeltaPlusRel": \[\], "DeltaPlusPivot": \[...\], "object\_quad\_template": {"graph": "\[http://musicbrainz.org/graph/mapping/psi\_medium\_4\](http://musicbrainz.org/graph/mapping/psi\_medium\_4)", "predicate": "\[http://purl.org/ontology/mo/track\](http://purl.org/ontology/mo/track)"}}} | **YES** |
| **psi\_medium\_5** | \<\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_\> \[http://purl.org/ontology/mo/media\_type\](http://purl.org/ontology/mo/media\_type) "31"^^\[http://www.w3.org/2001/XMLSchema\#int\](http://www.w3.org/2001/XMLSchema\#int) \[http://musicbrainz.org/graph/mapping/psi\_medium\_5\](http://musicbrainz.org/graph/mapping/psi\_medium\_5) . | {"rdf\_contributions": {"S2": \[\], "DeltaPlus": \[{"object": 31, "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_"}\], "DeltaPlusRel": \[\], "DeltaPlusPivot": \[{"object": 31, "subject": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_"}\], "datatype\_quad\_template": {"graph": "\[http://musicbrainz.org/graph/mapping/psi\_medium\_5\](http://musicbrainz.org/graph/mapping/psi\_medium\_5)", "datatype": "\[http://www.w3.org/2001/XMLSchema\#int\](http://www.w3.org/2001/XMLSchema\#int)", "predicate": "\[http://purl.org/ontology/mo/media\_type\](http://purl.org/ontology/mo/media\_type)"}}} | **YES** |
| **psi\_release\_4** | \[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#) \[http://purl.org/ontology/mo/record\](http://purl.org/ontology/mo/record) \<\[http://musicbrainz.org/release/9d52af97-3527-4aeb-85da-57fd0f84a81a\#\](http://musicbrainz.org/release/9d52af97-3527-4aeb-85da-57fd0f84a81a\#)\_\> \[http://musicbrainz.org/graph/mapping/psi\_medium\_4\](http://musicbrainz.org/graph/mapping/psi\_medium\_4) . | {"rdf\_contributions": {"S2": \[{"object": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_", "subject": "\[http://musicbrainz.org/release/9d52af97-3527-4aeb-85da-57fd0f84a81a\#\](http://musicbrainz.org/release/9d52af97-3527-4aeb-85da-57fd0f84a81a\#)\_"}\], "DeltaPlus": \[{"object": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_", "subject": "\[http://musicbrainz.org/release/9d52af97-3527-4aeb-85da-57fd0f84a81a\#\](http://musicbrainz.org/release/9d52af97-3527-4aeb-85da-57fd0f84a81a\#)\_"}\], "DeltaPlusRel": \[{"object": "\[http://musicbrainz.org/record/55522\#\](http://musicbrainz.org/record/55522\#)\_", "subject": "\[http://musicbrainz.org/release/9d52af97-3527-4aeb-85da-57fd0f84a81a\#\](http://musicbrainz.org/release/9d52af97-3527-4aeb-85da-57fd0f84a81a\#)"}\], "DeltaPlusPivot": \[\], "object\_quad\_template": {"graph": "\[http://musicbrainz.org/graph/mapping/psi\_release\_4\](http://musicbrainz.org/graph/mapping/psi\_release\_4)", "predicate": "\[http://purl.org/ontology/mo/record\](http://purl.org/ontology/mo/record)"}}} | **YES** |


### **Result of Rule Contribution Correctness**

> The trigger for the medium relation generated contributions for all 6 rules evaluated. The produced quadruples are correct for all of the rules.

## 2.2 Changeset Correctness
