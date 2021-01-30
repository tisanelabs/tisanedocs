# LaMP API

### Entities in LaMP

#### Family

A family represents a real-world concept, whether it is an action, an attribute, or a physical object. Families are crosslingual; they have 

#### Lexeme

#### Commonsense Cue


### Knowledge Graph

The knowledge graph shows and allows editing of families. The main purpose it to allow a fast and efficient revision of large numbers of families, displaying only the information the linguist needs, and minimizing the need to visit other screens and modules. 

There are several edit points in the knowledge graph module: 

* the family details (only accessible to the admin users)
* the links (only accessible to the admin users)
* the family localization details
* the lexemes linked to the family

#### API

|     Method         |   Verb   |   Query parameter(s)     | Request body      |      Notes                                 |
| ------------------ |:--------:|:-------------------------|:-----------:|:-----------------------------------------------------------|
|  /knowledgeGraph   | GET      | **arg** search argument |   None     | Fetches the list of knowledge graph nodes for the current range |
|                    |          | **type** search argument type (id, text, range) |     |                      |
|                    |          | **basic** whether the graph is shown in basic mode |     |                      |
| /hyponymList       | GET      | **family** a family ID for the hyponyms to be displayed | None | Fetches the list of the hyponym families for the specified family, with an ID and a description for each |
|                    |          | **range** a range ID to apply as a filter. If empty, all hyponyms are displayed |   |                                       |
| /domainMemberList  | GET      | **family** a family ID for the domain members to be displayed | None | Fetches the list of the domain member families for the specified family, with an ID and a description for each |
|                    |          | **range** a range ID to apply as a filter. If empty, all domain members are displayed |   |                                       |
|  /familyLexemes        | POST    | **family** a family ID for the lexemes to be inserted for | None  | Inserts new lexeme links for the specified family. |
|                        |         | **lexemes** a comma-delimited list of lexeme IDs, e.g. "3455,4566,3499" | None  |  |
|  /familyLexemes        | DELETE  | **family** a family ID for the lexemes to be deleted for | None  | Deletes existing links for the specified family. |
|                        |         | **lexemes** a comma-delimited list of lexeme IDs, e.g. "3455,4566,3499" | None  |       |
|  /familyLinks        | POST    | **family** a family ID for the links to be inserted for | None  | Inserts new family links for the specified family selected by user from the Family Selection page. |
|                        |         | **type** a type of the links to insert: hypernyms / domains / hyponyms / domainMembers / relatedConcepts / antonyms | None  |  |
|                        |         | **links** a comma-delimited list of link IDs, e.g. "3455,4566,3499" | None  |  |
|  /familyLinks        | DELETE  | **family** a family ID for the links to be deleted for | None  | Deletes existing links for the specified family. |
|                        |         | **type** a type of the links to delete: hypernyms / domains / hyponyms / domainMembers / relatedConcepts / antonyms | None  |  |
|                        |         | **links** a comma-delimited list of link IDs, e.g. "3455,4566,3499" | None  |       |
|  /findFamilies    | GET      | **arg** search argument |   None     | Fetches the list of families with basic information (ID + main lemma) for the current range |
|                    |          | **type** search argument type (id, text, range) |     |                      |
|  /findLexemes    | GET      | **arg** search argument |   None     | Fetches the list of lexemes with basic information for the current range |
|                    |          | **type** search argument type (id, text, range) |     |                      |
|  /family          | GET      | **id** family to edit |   None     | Starts editing the specified family. For **admin users only**. |
|  /family          | POST      | None |   Values for the family being edited | Saves a new family. For **admin users only**. |
|  /family          | PUT      | None |   Changed values in the family being edited | Saves changes to the specified family. For **admin users only**. |
|  /family          | DELETE      | **id** family to edit |   None     | Deletes the specified family. For **admin users only**. |
|  /familyLocalization          | GET      | **id** family to edit |   None     | Starts editing the specified family localization record for the current language. |
|  /familyLocalization          | PUT      | None |   Changed values in the family localization record being edited | Saves changes to the specified family localization record.  |
|  /moveLexemeLinks          | PUT      | **family** the family to take the lexemes from |   None | Saves changes to the specified family localization record.  |
|                            |         | **targetFamilies** a comma-separated list of the families to move the lexemes to |   |    |
|                            |         | **lexemeIds** a comma-separated list of the lexemes to move |   |    |
|  /suggestLexemeLinks          | GET      | **family** the family to suggest the lexemes for |   None | Produces a list of lexemes to add to the existing family.  |

Attributes: advanced edit for admins

|     Name         |  Label / Description       |         Notes                                 |
|:-----------------|:----------------------|:----------------------------------------------|
|   id             |  ID                    | Language-independent ID of the family |
|   properNoun     |  Is proper noun? (checkbox)   | A toggle determining whether the family is a proper noun |
|   description     |  Description   | A short note (single line) describing the family (empty pretty much everywhere, it's a new column) |
|   definition     |  Definition      | A longer note describing the family. A multiline text field.  |
|   fallback       |  Fallback policy | Describes how the family handles absence of data in a particular language. **Only for phrases**. Possible values: onlyIfEmpty / complement / never / insertEmptyWord / literalEquivalent |
|   grammar       |  A set of grammar features (type=Grammar)  | A standard feature editing array. **Only send the array back if something changed**.  |
|   grammarCopyToHyponyms |  Whether the grammar features are to be inherited by the hyponym families.  | A checkbox embedded in or close to the grammar editing control.  |
|   semanticFeatures  |  A set of semantic features (type=Semantics) | A standard feature editing array. **Only send the array back if something changed**.  |
|   semanticsCopyToHyponyms |  Whether the semantic features are to be inherited by the hyponym families.  | A checkbox embedded in or close to the semantic features editing control.  |
|   properNounHyponymEntities |  Whether hyponym proper noun families are treated like entities.  | A checkbox.  |
|   value             |  Numeric value.  | A valid numeral in the US English format, or an empty string.  |
|   numericDomain     |  Numeric domain.  | A single feature editing UI selecting a semantic feature.  |
|   frequency         |  Frequency grade.  | A number in range 0 through 10, or an empty string.  |
|   earliestMention   |  Date of the earliest mention.  | A date when the concept first emerged, or an empty string.  |
|   lastYearActive    |  Last year when the concept was in active use.  | A valid year, only this era (CE).  |
|   phraseTag         |  Phrase linguistic tag.  | A short text field with code representing the type of the phrase.  |
|   phraseType        |  Type of the phrase family.  | A set of choices for phrase families: (empty string)=not a phrase, regular=regular phrase, list=list phrase, mainClause=main clause, connector=connector phrase  |
|   wordnetId         |  WordNet 3.0 ID.  | A short text field with code representing the WordNet 3.0 ID.  |
|   wikidataId        |  Wikidata ID.  | A short text field with code representing the Wikidata ID.  |
|   customId        |  Custom ID.  | A short text field with code representing a custom external ID.  |
|   iptc            |  IPTC code.  | A single feature editing UI (type: Semantic, index: 24).  |
|   iab            |  IAB code.  | A single feature editing UI (type: Semantic, index: 25).  |

Attributes: advanced localized edit

|     Name         |  Label / Description       |         Notes                                 |
|:-----------------|:----------------------|:----------------------------------------------|
|   familyId             |  Family ID                    | Language-independent ID of the family |
|   description     |  Description   | A short note (single line) describing the family (empty pretty much everywhere, it's a new column) |
|   definition     |  Definition      | A longer note describing the family. A multiline text field.  |
|   grammar       |  A set of grammar features (type=Grammar)  | A standard feature editing array. **Only send the array back if it changed**.  |
|   semanticFeatures  |  A set of semantic features (type=Semantics) | A standard feature editing array. **Only send the array back if it changed**.  |



