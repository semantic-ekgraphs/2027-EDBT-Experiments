**Artist Trigger Evaluation on GPT-5.6 following Table 3\.**

# **Step 1**

---

**TR identification:** identified all relevant rules  
\* psi\_artist\_1 \- pivot-relevant CTR  
\* psi\_artist\_2 \- pivot-relevant Local-DTR, xsd:string. \*/  
\* psi\_artist\_3 \- pivot-relevant Local-DTR, xsd:string. \*/  
\* psi\_artist\_4 \- pivot-relevant Local-DTR, xsd:string. \*/  
\* psi\_artist\_5 \- pivot-relevant CTR with selection artist.type \= 1\. \*/  
\* psi\_artist\_6 \- pivot-relevant CTR with selection artist.type \= 2\. \*/  
\* psi\_artist\_7 \- pivot-relevant Path-DTR.   
\* psi\_artist\_8 \- pivot-relevant OTR.  
\* psi\_artist\_9 \- pivot-relevant OTR.  
\* psi\_artist\_10 \- pivot-relevant OTR.  
\* psi\_artist\_11 \- pivot-relevant OTR.  
\* psi\_artist\_13 \- pivot-relevant OTR.  
\* psi\_artist\_14 \- pivot-relevant Path-DTR.  
\* psi\_artist\_tag\_2 \- relation-relevant OTR.

---

**Computation of A-\[Ψ\](u), A+\[Ψ\](u), S2\[Ψ\](u), Δrel+\[Ψ\](u), Δ+\[Ψ\](u):** correctly produced all relational joins  
\* psi\_artist\_1 \- pivot-relevant CTR:  
'rdf\_contributions', jsonb\_build\_object(  
                'DeltaPlusPivot', q.contribution,  
                'DeltaPlus', q.contribution  
            )  
        )  
    FROM (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT jsonb\_build\_object(  
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '\#\_'  
            )),  
            '\[\]'::jsonb  
        ) AS contribution  
        FROM inserted\_artist AS i  
    ) AS q;  
\* psi\_artist\_2 \- pivot-relevant Local-DTR, xsd:string. \*/  
'rdf\_contributions', jsonb\_build\_object(  
                'DeltaPlusPivot', q.contribution,  
                'S2', '\[\]'::jsonb,  
                'DeltaPlusRel', '\[\]'::jsonb,  
                'DeltaPlus', q.contribution  
            )  
        )  
    FROM (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT jsonb\_build\_object(  
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '\#\_',  
                'object', i.gid::text  
            )),  
            '\[\]'::jsonb  
        ) AS contribution  
        FROM inserted\_artist AS i  
        WHERE i.gid IS NOT NULL  
    ) AS q;

\* psi\_artist\_3 \- pivot-relevant Local-DTR, xsd:string. \*/  
'rdf\_contributions', jsonb\_build\_object(  
                'DeltaPlusPivot', q.contribution,  
                'S2', '\[\]'::jsonb,  
                'DeltaPlusRel', '\[\]'::jsonb,  
                'DeltaPlus', q.contribution  
            )  
        )  
    FROM (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT jsonb\_build\_object(  
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '\#\_',  
                'object', i.name  
            )),  
            '\[\]'::jsonb  
        ) AS contribution  
        FROM inserted\_artist AS i  
        WHERE i.name IS NOT NULL  
    ) AS q;

\* psi\_artist\_4 \- pivot-relevant Local-DTR, xsd:string. \*/  
'rdf\_contributions', jsonb\_build\_object(  
                'DeltaPlusPivot', q.contribution,  
                'S2', '\[\]'::jsonb,  
                'DeltaPlusRel', '\[\]'::jsonb,  
                'DeltaPlus', q.contribution  
            )  
        )  
    FROM (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT jsonb\_build\_object(  
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '\#\_',  
                'object', i.sort\_name  
            )),  
            '\[\]'::jsonb  
        ) AS contribution  
        FROM inserted\_artist AS i  
        WHERE i.sort\_name IS NOT NULL  
    ) AS q;

\* psi\_artist\_5 \- pivot-relevant CTR with selection artist.type \= 1\. \*/  
'rdf\_contributions', jsonb\_build\_object(  
                'DeltaPlusPivot', q.contribution,  
                'DeltaPlus', q.contribution  
            )  
        )  
    FROM (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT jsonb\_build\_object(  
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '\#\_'  
            )),  
            '\[\]'::jsonb  
        ) AS contribution  
        FROM inserted\_artist AS i  
        WHERE i.type \= 1  
    ) AS q;

\* psi\_artist\_6 \- pivot-relevant CTR with selection artist.type \= 2\. \*/  
'rdf\_contributions', jsonb\_build\_object(  
                'DeltaPlusPivot', q.contribution,  
                'DeltaPlus', q.contribution  
            )  
        )  
    FROM (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT jsonb\_build\_object(  
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '\#\_'  
            )),  
            '\[\]'::jsonb  
        ) AS contribution  
        FROM inserted\_artist AS i  
        WHERE i.type \= 2  
    ) AS q;

\* psi\_artist\_7 \- pivot-relevant Path-DTR.   
'rdf\_contributions', jsonb\_build\_object(  
                'DeltaPlusPivot', q.contribution,  
                'S2', '\[\]'::jsonb,  
                'DeltaPlusRel', '\[\]'::jsonb,  
                'DeltaPlus', q.contribution  
            )  
        )  
    FROM (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT jsonb\_build\_object(  
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '\#\_',  
                'object', lower(g.name)  
            )),  
            '\[\]'::jsonb  
        ) AS contribution  
        FROM inserted\_artist AS i  
        JOIN gender AS g  
          ON g.id \= i.gender  
        WHERE g.name IS NOT NULL  
    ) AS q;

\* psi\_artist\_8 \- pivot-relevant OTR.  
'rdf\_contributions', jsonb\_build\_object(  
                'DeltaPlusPivot', q.contribution,  
                'S2', '\[\]'::jsonb,  
                'DeltaPlusRel', '\[\]'::jsonb,  
                'DeltaPlus', q.contribution  
            )  
        )  
    FROM (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT jsonb\_build\_object(  
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '\#\_',  
                'object', 'http://musicbrainz.org/area/' || ar.gid::text || '\#\_'  
            )),  
            '\[\]'::jsonb  
        ) AS contribution  
        FROM inserted\_artist AS i  
        JOIN area AS ar  
          ON ar.id \= i.area  
    ) AS q;

\* psi\_artist\_9 \- pivot-relevant OTR.  
'rdf\_contributions', jsonb\_build\_object(  
                'DeltaPlusPivot', q.contribution,  
                'S2', '\[\]'::jsonb,  
                'DeltaPlusRel', '\[\]'::jsonb,  
                'DeltaPlus', q.contribution  
            )  
        )  
    FROM (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT jsonb\_build\_object(  
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '\#\_',  
                'object', 'http://musicbrainz.org/signal-group/' || rg.gid::text || '\#\_'  
            )),  
            '\[\]'::jsonb  
        ) AS contribution  
        FROM inserted\_artist AS i  
        JOIN artist\_credit\_name AS acn  
          ON acn.artist \= i.id  
        JOIN release\_group AS rg  
          ON rg.artist\_credit \= acn.artist\_credit  
    ) AS q;

\* psi\_artist\_10 \- pivot-relevant OTR.  
'rdf\_contributions', jsonb\_build\_object(  
                'DeltaPlusPivot', q.contribution,  
                'S2', '\[\]'::jsonb,  
                'DeltaPlusRel', '\[\]'::jsonb,  
                'DeltaPlus', q.contribution  
            )  
        )  
    FROM (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT jsonb\_build\_object(  
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '\#\_',  
                'object', 'http://musicbrainz.org/release/' || rel.gid::text || '\#\_'  
            )),  
            '\[\]'::jsonb  
        ) AS contribution  
        FROM inserted\_artist AS i  
        JOIN artist\_credit\_name AS acn  
          ON acn.artist \= i.id  
        JOIN release AS rel  
          ON rel.artist\_credit \= acn.artist\_credit  
    ) AS q;

\* psi\_artist\_11 \- pivot-relevant OTR.  
'rdf\_contributions', jsonb\_build\_object(  
                'DeltaPlusPivot', q.contribution,  
                'S2', '\[\]'::jsonb,  
                'DeltaPlusRel', '\[\]'::jsonb,  
                'DeltaPlus', q.contribution  
            )  
        )  
    FROM (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT jsonb\_build\_object(  
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '\#\_',  
                'object', 'http://musicbrainz.org/track/' || t.id::text || '\#\_'  
            )),  
            '\[\]'::jsonb  
        ) AS contribution  
        FROM inserted\_artist AS i  
        JOIN artist\_credit\_name AS acn  
          ON acn.artist \= i.id  
        JOIN track AS t  
          ON t.artist\_credit \= acn.artist\_credit  
    ) AS q;

\* psi\_artist\_13 \- pivot-relevant OTR.  
'rdf\_contributions', jsonb\_build\_object(  
                'DeltaPlusPivot', q.contribution,  
                'S2', '\[\]'::jsonb,  
                'DeltaPlusRel', '\[\]'::jsonb,  
                'DeltaPlus', q.contribution  
            )  
        )  
    FROM (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT jsonb\_build\_object(  
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '\#\_',  
                'object', 'http://musicbrainz.org/recording/' || rec.gid::text || '\#\_'  
            )),  
            '\[\]'::jsonb  
        ) AS contribution  
        FROM inserted\_artist AS i  
        JOIN artist\_credit\_name AS acn  
          ON acn.artist \= i.id  
        JOIN recording AS rec  
          ON rec.artist\_credit \= acn.artist\_credit  
    ) AS q;

\* psi\_artist\_14 \- pivot-relevant Path-DTR.  
'rdf\_contributions', jsonb\_build\_object(  
                'DeltaPlusPivot', q.contribution,  
                'S2', '\[\]'::jsonb,  
                'DeltaPlusRel', '\[\]'::jsonb,  
                'DeltaPlus', q.contribution  
            )  
        )  
    FROM (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT jsonb\_build\_object(  
                'subject', 'http://musicbrainz.org/artist/' || i.gid::text || '\#\_',  
                'object', an.text  
            )),  
            '\[\]'::jsonb  
        ) AS contribution  
        FROM inserted\_artist AS i  
        JOIN artist\_annotation AS aa  
          ON aa.artist \= i.id  
        JOIN annotation AS an  
          ON an.id \= aa.annotation  
        WHERE an.text IS NOT NULL  
    ) AS q;

\* psi\_artist\_tag\_2 \- relation-relevant OTR.  
a\_minus AS (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT to\_jsonb(at)),  
            '\[\]'::jsonb  
        ) AS tuples  
        FROM artist\_tag AS at  
        JOIN deleted\_artist AS d  
          ON d.id \= at.artist  
    ),  
    a\_plus AS (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT to\_jsonb(at)),  
            '\[\]'::jsonb  
        ) AS tuples  
        FROM artist\_tag AS at  
        JOIN inserted\_artist AS i  
          ON i.id \= at.artist  
    ),  
    s2 AS (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT jsonb\_build\_object(  
                'subject',  
                    'http://musicbrainz.org/artist/' || a.gid::text ||  
                    '\#tag/' || t.name,  
                'object',  
                    'http://musicbrainz.org/artist/' || a.gid::text || '\#\_'  
            )),  
            '\[\]'::jsonb  
        ) AS contribution  
        FROM artist\_tag AS at  
        JOIN deleted\_artist AS d  
          ON d.id \= at.artist  
        JOIN artist AS a  
          ON a.id \= at.artist  
        JOIN tag AS t  
          ON t.id \= at.tag  
    ),  
    delta\_plus\_rel AS (  
        SELECT COALESCE(  
            jsonb\_agg(DISTINCT jsonb\_build\_object(  
                'subject',  
                    'http://musicbrainz.org/artist/' || a.gid::text ||  
                    '\#tag/' || t.name,  
                'object',  
                    'http://musicbrainz.org/artist/' || a.gid::text || '\#\_'  
            )),  
            '\[\]'::jsonb  
        ) AS contribution  
        FROM artist\_tag AS at  
        JOIN inserted\_artist AS i  
          ON i.id \= at.artist  
        JOIN artist AS a  
          ON a.id \= at.artist  
        JOIN tag AS t  
          ON t.id \= at.tag  
    )

---

**Code Minimality:** relatively clean and concise  
Using aliases as variables to reduce code:  
'rdf\_contributions', jsonb\_build\_object(  
                'DeltaPlusPivot', ***q.contribution**,*  
                'S2', '\[\]'::jsonb,  
                'DeltaPlusRel', '\[\]'::jsonb,  
                'DeltaPlus', ***q.contribution***  
            )

---

**Hallucination:** did not hallucinate

# **Step 2**

## 2.1 Rule Contribution Correctness

**Update scenario:**  
UPDATE artist  
SET "comment" \= 'Update test in artist.comment',  
        ended \= true   
WHERE id \= 90253

### **GPT-Artist: Validation of Data Generated by the Trigger**

| Rule | Expected Data | Data Generated by the Trigger | Is the Same |
| :---- | :---- | :---- | :---- |
| psi\_artist\_1 | \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://www.w3.org/1999/02/22-rdf-syntax-ns\#type\> \<http://purl.org/ontology/mo/MusicArtist\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_1\> . | { "rdf\_contributions": {     "DeltaPlus": \[       {         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \],     "DeltaPlusPivot": \[       {         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \]   },   "class\_quad\_template": {     "class": "http://purl.org/ontology/mo/MusicArtist",     "graph": "http://musicbrainz.org/graph/mapping/psi\_artist\_1",     "predicate": "http://www.w3.org/1999/02/22-rdf-syntax-ns\#type"   } } |  |
| psi\_artist\_2 | \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://purl.org/ontology/mo/musicbrainz\_guid\> "05dbab6f-af89-47c3-8899-201711538b13" \<http://musicbrainz.org/graph/mapping/psi\_artist\_2\> . | { "rdf\_contributions": {     "S2": \[\],     "DeltaPlus": \[       {         "object": "05dbab6f-af89-47c3-8899-201711538b13",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \],     "DeltaPlusRel": \[\],     "DeltaPlusPivot": \[       {         "object": "05dbab6f-af89-47c3-8899-201711538b13",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \]   },   "datatype\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_artist\_2",     "datatype": "http://www.w3.org/2001/XMLSchema\#string",     "predicate": "http://purl.org/ontology/mo/musicbrainz\_guid"   } } |  |
| psi\_artist\_3 | \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://xmlns.com/foaf/0.1/name\> "Mighty Sam McClain" \<http://musicbrainz.org/graph/mapping/psi\_artist\_3\> . | { "rdf\_contributions": {     "S2": \[\],     "DeltaPlus": \[       {         "object": "Mighty Sam McClain",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \],     "DeltaPlusRel": \[\],     "DeltaPlusPivot": \[       {         "object": "Mighty Sam McClain",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \]   },   "datatype\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_artist\_3",     "datatype": "http://www.w3.org/2001/XMLSchema\#string",     "predicate": "http://xmlns.com/foaf/0.1/name"   } } |  |
| psi\_artist\_4 | \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://open.vocab.org/terms/sortLabel\> "McClain, Mighty Sam" \<http://musicbrainz.org/graph/mapping/psi\_artist\_4\> . | { "rdf\_contributions": {     "S2": \[\],     "DeltaPlus": \[       {         "object": "McClain, Mighty Sam",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \],     "DeltaPlusRel": \[\],     "DeltaPlusPivot": \[       {         "object": "McClain, Mighty Sam",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \]   },   "datatype\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_artist\_4",     "datatype": "http://www.w3.org/2001/XMLSchema\#string",     "predicate": "http://open.vocab.org/terms/sortLabel"   } } |  |
| psi\_artist\_5 | \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://www.w3.org/1999/02/22-rdf-syntax-ns\#type\> \<http://purl.org/ontology/mo/SoloMusicArtist\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_5\> . | { "rdf\_contributions": {     "DeltaPlus": \[       {         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \],     "DeltaPlusPivot": \[       {         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \]   },   "class\_quad\_template": {     "class": "http://purl.org/ontology/mo/SoloMusicArtist",     "graph": "http://musicbrainz.org/graph/mapping/psi\_artist\_5",     "predicate": "http://www.w3.org/1999/02/22-rdf-syntax-ns\#type"   } } |  |
| psi\_artist\_6 |  | { "rdf\_contributions": {     "DeltaPlus": \[\],     "DeltaPlusPivot": \[\]   },   "class\_quad\_template": {     "class": "http://purl.org/ontology/mo/MusicGroup",     "graph": "http://musicbrainz.org/graph/mapping/psi\_artist\_6",     "predicate": "http://www.w3.org/1999/02/22-rdf-syntax-ns\#type"   } } |  |
| psi\_artist\_7 | \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://xmlns.com/foaf/0.1/gender\> "male" \<http://musicbrainz.org/graph/mapping/psi\_artist\_7\> . | { "rdf\_contributions": {     "S2": \[\],     "DeltaPlus": \[       {         "object": "male",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \],     "DeltaPlusRel": \[\],     "DeltaPlusPivot": \[       {         "object": "male",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \]   },   "datatype\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_artist\_7",     "datatype": "http://www.w3.org/2001/XMLSchema\#string",     "predicate": "http://xmlns.com/foaf/0.1/gender"   } } |  |
| psi\_artist\_8 | \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://xmlns.com/foaf/0.1/based\_near\> \<http://musicbrainz.org/area/489ce91b-6658-3307-9877-795b68554c98\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_8\> . | { "rdf\_contributions": {     "S2": \[\],     "DeltaPlus": \[       {         "object": "http://musicbrainz.org/area/489ce91b-6658-3307-9877-795b68554c98\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \],     "DeltaPlusRel": \[\],     "DeltaPlusPivot": \[       {         "object": "http://musicbrainz.org/area/489ce91b-6658-3307-9877-795b68554c98\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \]   },   "object\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_artist\_8",     "predicate": "http://xmlns.com/foaf/0.1/based\_near"   } } |  |
| psi\_artist\_9 | \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://xmlns.com/foaf/0.1/made\> \<http://musicbrainz.org/signal-group/316f58f3-8e65-3114-bb1b-49ec9331cfff\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_9\> . | { "rdf\_contributions": {     "S2": \[\],     "DeltaPlus": \[       {         "object": "http://musicbrainz.org/signal-group/316f58f3-8e65-3114-bb1b-49ec9331cfff\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \],     "DeltaPlusRel": \[\],     "DeltaPlusPivot": \[       {         "object": "http://musicbrainz.org/signal-group/316f58f3-8e65-3114-bb1b-49ec9331cfff\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \]   },   "object\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_artist\_9",     "predicate": "http://xmlns.com/foaf/0.1/made"   } } |  |
| psi\_artist\_10 | \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://xmlns.com/foaf/0.1/made\> \<http://musicbrainz.org/release/5a3c32e6-d025-4a25-a3fa-509447a7bd84\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_10\> . | { "rdf\_contributions": {     "S2": \[\],     "DeltaPlus": \[       {         "object": "http://musicbrainz.org/release/5a3c32e6-d025-4a25-a3fa-509447a7bd84\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \],     "DeltaPlusRel": \[\],     "DeltaPlusPivot": \[       {         "object": "http://musicbrainz.org/release/5a3c32e6-d025-4a25-a3fa-509447a7bd84\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \]   },   "object\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_artist\_10",     "predicate": "http://xmlns.com/foaf/0.1/made"   } } |  |
| psi\_artist\_11 | \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://xmlns.com/foaf/0.1/made\> \<http://musicbrainz.org/track/1000000\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_11\> . \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://xmlns.com/foaf/0.1/made\> \<http://musicbrainz.org/track/1000001\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_11\> . \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://xmlns.com/foaf/0.1/made\> \<http://musicbrainz.org/track/1000002\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_11\> . \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://xmlns.com/foaf/0.1/made\> \<http://musicbrainz.org/track/1000003\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_11\> . \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://xmlns.com/foaf/0.1/made\> \<http://musicbrainz.org/track/1000004\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_11\> . | { "rdf\_contributions": {     "S2": \[\],     "DeltaPlus": \[       {         "object": "http://musicbrainz.org/track/1000000\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/track/1000001\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/track/1000002\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/track/1000003\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/track/1000004\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \],     "DeltaPlusRel": \[\],     "DeltaPlusPivot": \[       {         "object": "http://musicbrainz.org/track/1000000\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/track/1000001\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/track/1000002\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/track/1000003\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/track/1000004\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \]   },   "object\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_artist\_11",     "predicate": "http://xmlns.com/foaf/0.1/made"   } } |  |
| psi\_artist\_13 | \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://xmlns.com/foaf/0.1/made\> \<http://musicbrainz.org/recording/09e79154-c4d9-4a80-9d2c-a53ca10ca23a\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_13\> . \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://xmlns.com/foaf/0.1/made\> \<http://musicbrainz.org/recording/1a3dba70-5836-49fa-bdf8-3b7aa7627fb5\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_13\> . \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://xmlns.com/foaf/0.1/made\> \<http://musicbrainz.org/recording/611406c3-e473-4cb0-b565-983675272f5a\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_13\> . \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://xmlns.com/foaf/0.1/made\> \<http://musicbrainz.org/recording/6e083767-1850-4edb-9b93-9d5e0f2371b6\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_13\> . \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://xmlns.com/foaf/0.1/made\> \<http://musicbrainz.org/recording/e5e7e780-c2d2-4ac3-8a16-9ab456cdc658\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_13\> . | { "rdf\_contributions": {     "S2": \[\],     "DeltaPlus": \[       {         "object": "http://musicbrainz.org/recording/09e79154-c4d9-4a80-9d2c-a53ca10ca23a\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/recording/1a3dba70-5836-49fa-bdf8-3b7aa7627fb5\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/recording/611406c3-e473-4cb0-b565-983675272f5a\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/recording/6e083767-1850-4edb-9b93-9d5e0f2371b6\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/recording/e5e7e780-c2d2-4ac3-8a16-9ab456cdc658\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \],     "DeltaPlusRel": \[\],     "DeltaPlusPivot": \[       {         "object": "http://musicbrainz.org/recording/09e79154-c4d9-4a80-9d2c-a53ca10ca23a\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/recording/1a3dba70-5836-49fa-bdf8-3b7aa7627fb5\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/recording/611406c3-e473-4cb0-b565-983675272f5a\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/recording/6e083767-1850-4edb-9b93-9d5e0f2371b6\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       },       {         "object": "http://musicbrainz.org/recording/e5e7e780-c2d2-4ac3-8a16-9ab456cdc658\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_"       }     \]   },   "object\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_artist\_13",     "predicate": "http://xmlns.com/foaf/0.1/made"   } } |  |
| psi\_artist\_14 |  | { "rdf\_contributions": {     "S2": \[\],     "DeltaPlus": \[\],     "DeltaPlusRel": \[\],     "DeltaPlusPivot": \[\]   },   "datatype\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_artist\_14",     "datatype": "http://www.w3.org/2001/XMLSchema\#string",     "predicate": "http://www.w3.org/2000/01/rdf-schema\#comment"   } } |  |
| psi\_artist\_tag\_2 | \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#tag/blues\> \<http://purl.org/muto/core\#taggedResource\> \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_tag\_2\> . \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#tag/soul%20blues\> \<http://purl.org/muto/core\#taggedResource\> \<http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_\> \<http://musicbrainz.org/graph/mapping/psi\_artist\_tag\_2\> . | { "rdf\_contributions": {     "S2": \[       {         "object": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#tag/blues"       },       {         "object": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#tag/soul blues"       }     \],     "DeltaPlus": \[       {         "object": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#tag/blues"       },       {         "object": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#tag/soul blues"       }     \],     "DeltaPlusRel": \[       {         "object": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#tag/blues"       },       {         "object": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\_",         "subject": "http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#tag/soul blues"       }     \],     "DeltaPlusPivot": \[\]   },   "object\_quad\_template": {     "graph": "http://musicbrainz.org/graph/mapping/psi\_artist\_tag\_2",     "predicate": "http://purl.org/muto/core\#taggedResource"   } } |  |

### Validation Summary Table

Análise detalhada das regras e da correspondência entre os quádruplos de **Expected Data** e os dados gerados em **Data Generated by the Trigger**:

1. **psi\_artist\_1**:  
   * **Expected**: \<\[http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\](http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#)\_\> \[http://www.w3.org/1999/02/22-rdf-syntax-ns\#type\](http://www.w3.org/1999/02/22-rdf-syntax-ns\#type) \[http://purl.org/ontology/mo/MusicArtist\](http://purl.org/ontology/mo/MusicArtist) \[http://musicbrainz.org/graph/mapping/psi\_artist\_1\](http://musicbrainz.org/graph/mapping/psi\_artist\_1) .

   * **Trigger (class\_quad\_template)**: Usa class no objeto. Ao reconstruir a quádrupla: \<\[http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\](http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#)\_\> \[http://www.w3.org/1999/02/22-rdf-syntax-ns\#type\](http://www.w3.org/1999/02/22-rdf-syntax-ns\#type) \[http://purl.org/ontology/mo/MusicArtist\](http://purl.org/ontology/mo/MusicArtist) \[http://musicbrainz.org/graph/mapping/psi\_artist\_1\](http://musicbrainz.org/graph/mapping/psi\_artist\_1) .  
   * **Resultado**: **YES**  
2. **psi\_artist\_2**:  
   * **Expected**: \<\[http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\](http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#)\_\> \[http://purl.org/ontology/mo/musicbrainz\_guid\](http://purl.org/ontology/mo/musicbrainz\_guid) "05dbab6f-af89-47c3-8899-201711538b13" \[http://musicbrainz.org/graph/mapping/psi\_artist\_2\](http://musicbrainz.org/graph/mapping/psi\_artist\_2) .

   * **Trigger (datatype\_quad\_template)**: Objeto literal "05dbab6f-af89-47c3-8899-201711538b13", sujeito, predicado e grafo idênticos ao esperado.  
   * **Resultado**: **YES**  
3. **psi\_artist\_3**:  
   * **Expected**: \<\[http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\](http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#)\_\> \[http://xmlns.com/foaf/0.1/name\](http://xmlns.com/foaf/0.1/name) "Mighty Sam McClain" \[http://musicbrainz.org/graph/mapping/psi\_artist\_3\](http://musicbrainz.org/graph/mapping/psi\_artist\_3) .

   * **Trigger**: Quádrupla gerada é idêntica ao esperado.  
   * **Resultado**: **YES**  
4. **psi\_artist\_4**:  
   * **Expected**: \<\[http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\](http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#)\_\> \[http://open.vocab.org/terms/sortLabel\](http://open.vocab.org/terms/sortLabel) "McClain, Mighty Sam" \[http://musicbrainz.org/graph/mapping/psi\_artist\_4\](http://musicbrainz.org/graph/mapping/psi\_artist\_4) .

   * **Trigger**: Quádrupla gerada é idêntica ao esperado.  
   * **Resultado**: **YES**  
5. **psi\_artist\_5**:  
   * **Expected**: \<\[http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\](http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#)\_\> \[http://www.w3.org/1999/02/22-rdf-syntax-ns\#type\](http://www.w3.org/1999/02/22-rdf-syntax-ns\#type) \[http://purl.org/ontology/mo/SoloMusicArtist\](http://purl.org/ontology/mo/SoloMusicArtist) \[http://musicbrainz.org/graph/mapping/psi\_artist\_5\](http://musicbrainz.org/graph/mapping/psi\_artist\_5) .

   * **Trigger**: Usa class\_quad\_template combinando o sujeito do DeltaPlus com o predicado, classe e grafo especificados, resultando numa quádrupla idêntica ao esperado.  
   * **Resultado**: **YES**  
6. **psi\_artist\_6**:  
   * **Expected**: Vazio.  
   * **Trigger**: DeltaPlus é uma lista vazia (\[\]), logo não gera nenhuma quádrupla.  
   * **Resultado**: **YES**  
7. **psi\_artist\_7**:  
   * **Expected**: \<\[http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\](http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#)\_\> \[http://xmlns.com/foaf/0.1/gender\](http://xmlns.com/foaf/0.1/gender) "male" \[http://musicbrainz.org/graph/mapping/psi\_artist\_7\](http://musicbrainz.org/graph/mapping/psi\_artist\_7) .

   * **Trigger**: Quádrupla gerada é idêntica ao esperado.  
   * **Resultado**: **YES**  
8. **psi\_artist\_8**:  
   * **Expected**: \<\[http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\](http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#)\_\> \[http://xmlns.com/foaf/0.1/based\_near\](http://xmlns.com/foaf/0.1/based\_near) \<\[http://musicbrainz.org/area/489ce91b-6658-3307-9877-795b68554c98\#\](http://musicbrainz.org/area/489ce91b-6658-3307-9877-795b68554c98\#)\_\> \[http://musicbrainz.org/graph/mapping/psi\_artist\_8\](http://musicbrainz.org/graph/mapping/psi\_artist\_8) .

   * **Trigger**: Quádrupla gerada é idêntica ao esperado.  
   * **Resultado**: **YES**  
9. **psi\_artist\_9**:  
   * **Expected**: \<\[http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\](http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#)\_\> \[http://xmlns.com/foaf/0.1/made\](http://xmlns.com/foaf/0.1/made) \<\[http://musicbrainz.org/signal-group/316f58f3-8e65-3114-bb1b-49ec9331cfff\#\](http://musicbrainz.org/signal-group/316f58f3-8e65-3114-bb1b-49ec9331cfff\#)\_\> \[http://musicbrainz.org/graph/mapping/psi\_artist\_9\](http://musicbrainz.org/graph/mapping/psi\_artist\_9) .

   * **Trigger**: Quádrupla gerada é idêntica ao esperado.  
   * **Resultado**: **YES**  
10. **psi\_artist\_10**:  
    * **Expected**: \<\[http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#\](http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#)\_\> \[http://xmlns.com/foaf/0.1/made\](http://xmlns.com/foaf/0.1/made) \<\[http://musicbrainz.org/release/5a3c32e6-d025-4a25-a3fa-509447a7bd84\#\](http://musicbrainz.org/release/5a3c32e6-d025-4a25-a3fa-509447a7bd84\#)\_\> \[http://musicbrainz.org/graph/mapping/psi\_artist\_10\](http://musicbrainz.org/graph/mapping/psi\_artist\_10) .

    * **Trigger**: Quádrupla gerada é idêntica ao esperado.  
    * **Resultado**: **YES**  
11. **psi\_artist\_11**:  
    * **Expected**: Contém 5 quádruplas para as faixas 1000000 a 1000004\.  
    * **Trigger**: Contém 5 objetos em DeltaPlus referentes às faixas 1000000 a 1000004\.  
    * **Resultado**: **YES**  
12. **psi\_artist\_13**:  
    * **Expected**: Contém 5 quádruplas para recordings com as URIs especificadas.  
    * **Trigger**: As 5 quádruplas montadas através de DeltaPlus correspondem exatamente às esperadas.  
    * **Resultado**: **YES**  
13. **psi\_artist\_14**:  
    * **Expected**: Vazio.  
    * **Trigger**: DeltaPlus está vazio, portanto nenhuma quádrupla é gerada.  
    * **Resultado**: **YES**  
14. **psi\_artist\_tag\_2**:  
    * **Expected**:  
      1. \[http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#tag/blues\](http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#tag/blues) ...

      2. \[http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#tag/soul%20blues\](http://musicbrainz.org/artist/05dbab6f-af89-47c3-8899-201711538b13\#tag/soul%20blues) ...

    * **Trigger**:  
      1. Sujeito do 1º elemento: ...\#tag/blues

      2. Sujeito do 2º elemento: ...\#tag/soul blues (Note a ausência da codificação de URL %20 no espaço em relação ao esperado soul%20blues).  
    * **Resultado**: **PARTIAL** (ou NO, dependendo do critério estrito de codificação de URIs; dado que um dos elementos é perfeitamente idêntico e o outro difere apenas na codificação percentual do espaço, classifica-se como **PARTIAL**).

## 

### Result of Rule Contribution Correctness

The trigger on _artist_ relation generated contributions for all 14 rules evaluated. 

The quadruples for the 13 rules were generated correctly; the 14th rule generated quadruples with a URI encoding error due to a whitespace character.


## 2.2 Changeset Correctness