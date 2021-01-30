# LaMP API

### Entities in LaMP

#### Family

A family represents a real-world concept, whether it is an action, an attribute, or a physical object. Families may have links to other families:

* **hypernyms** - more generic families
* **hyponyms** - less generic families
* **domains** - topics of the current family
* **domain members** - families for which the current family is a topic

Families are crosslingual: a _truck_ is always a _vehicle_, no matter what the language is. 

#### Lexeme

A lexeme is a word with all its inflected forms. The inflected forms may be actual entities in the database or generated dynamically based on the grammar rules. A lexeme may be linked to one or more families. 

#### Commonsense Cue

A commonsense cue attempts to match a co-occurrence of specified features (usually family IDs or hypernym IDs), and, optionally, assigns labels or topics. Commonsense cues are matched after a phrasal pattern has been matched. 

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

### Lexicon

The lexicon module consists of a number of screens. It is, in a way, similar to the knowledge graph, but "inside out", with the lexemes being its central entity. The module allows editing the links between the lexemes and the families (like the knowledge graph), as well as editing the lexeme attributes and inflections linked to the lexemes. 

#### Main List View

The main list view shows the basic information about the lexemes, allowing the linguists to edit the links to the families quickly and efficiently, very similar to the knowledge graph main screen. Every node is shown in a collapsible panel, standard in the system. 

In the closed state shown on the figure below, the panel shows the lemma, the dictionary tag associated with it, and a comma-delimited list of inflected forms. It also alerts about a potential duplication, if the node contains a certain attribute. 


In the open state, the list of linked families with their definitions is shown in a bullet list, with a number of buttons manipulating or editing the lexeme. See the figure below. 


#### Lexeme Family Connection Edit

The lexeme family connection edit screen is shown on the figure below. The selection of the family is performed by calling the Family Selection dialogue from the Knowledge Graph. 



#### Lexeme Merge Dialogue

The merge lexemes function calls a modal Lexeme Merge page shown below. If the user confirms, */mergeLexemes* method is called after which the entire page is refreshed. 

![Lexicon merge](wiki-attachment:lexemeMerge.png)

#### Advanced Criteria

The advanced criteria used by the lexeme family connection shown on the figure below will be reused in other modules. 

![Advanced criteria lookup](wiki-attachment:tisaneAdvancedCriteriaList.png)

The user will be able to create / update / delete advanced criteria sets from the lookup page, using the edit page shown below. The hypernyms and the required phrases can be selected by the family selection UI built for the knowledge graph.

![Advanced criteria edit 1](wiki-attachment:tisaneAdvancedCriteriaEdit1.png)
![Advanced criteria edit 2](wiki-attachment:tisaneAdvancedCriteriaEdit2.png)

#### Lexeme Edit

The lexeme edit screen is a rich but standard screen that allows modifying the attributes of a lexeme, as shown on the figure below. 

![Lexeme edit 1](wiki-attachment:tisaneLexemeEdit1.png)
![Lexeme edit 2](wiki-attachment:tisaneLexiconEdit2.png)

The lexeme merge screen shown below exists for one purpose, to merge two duplicate lexemes. 

##### Tagging Trace

The trace link opens the screen as shown below. 

![tisaneTagTrace.png](wiki-attachment:tisaneTagTrace.png)

#### Inflection Table

The *Inflection* button opens the inflection table page shown below:

![Inflections](wiki-attachment:tisaneInflectionsSpanish.png)

The purpose of the table is to show the inflections associated with the specified lexeme. Some of the inflections come from the database (they have an *inflectionId* attribute), others are dynamically generated. The linguists will be able to override the dynamic ones by editing them in the Inflection Edit screen. 

The web service tries to sort the inflections into paper-dictionary-like view. However, the current result may be imperfect. The format of the web service response simply instructs to create a table (or a <ul> element) with lines of text and specified indents. In the web service response the entries which are forms, are marked with the attribute `"inflection":true`.

##### Matched Inflection

The page is called by the button with the eye icon in the Inflection Table and uses the content of the `generatedBy` attribute. 

![Matched inflection](wiki-attachment:tisaneMatchedInflection.png)

##### Unmatched Inflections

The page is called by the Unmatched Inflections button in the Inflection Table and displays the content of the `failures` attribute. 

![Unmatched inflections](wiki-attachment:tisaneInflectionsDidNotMatch.png)

#### Inflection Edit

Clicking on the *Edit* button in the Inflections Table calls the inflection edit screen shown below:

![Inflection Edit](wiki-attachment:tisaneInflectionEdit1.png)
![Inflection Edit](wiki-attachment:tisaneInflectionEdit2.png)
![Inflection Edit](wiki-attachment:tisaneInflectionEdit3.png)

**NOTE** that if there is an inflection override, then *GET /inflection?id=my_id* must be called to obtain the attributes being edited. If a new inflection override is being defined, the *features* and the *text* must be passed on to initialize the features and the text in the Inflection Edit. 

#### Root Lookup

The root lookup screen is used by multiple modules and allows looking up roots. 

![Root lookup](wiki-attachment:tisaneRootLookup.png)


#### API

##### Lexicon, lexeme edit, lexeme family edit, advanced criteria

|     Method         |   Verb   |   Query parameter(s)     | Request body      |      Notes                                 |
| ------------------ |:--------:|:-------------------------|:-----------|:-----------------------------------------------------------|
|  /lexicon      | GET      | **arg** search argument |   None     | Fetches the list of lexemes for the current language in the specified range |
|                    |          | **type** search argument type (id, text, range) |     |                      |
|  /mergeLexemes      | GET      | **target** the lexeme to merge into (currently selected lexeme) |   None     | Merges lexemes into one (presumably duplicate ones at this stage) |
|                    |          | **ids** a comma-delimited list of the IDs of the lexemes to merge |     |                      |
|  /lexemeFamily  | GET      | **lexeme** the lexeme ID |  None  | Fetches the details of a lexeme family connection to edit. Must be called before attempting to update (PUT). |
|                    |          | **family** the family ID |     |                      |
|  /lexemeFamily  | PUT    | none   |  New values of the fields in the record being edited; no need to specify unchanged ones  |  Updates an existing record with the fields as specified in the request body. |
|  /lexemeFamily  | POST    | none  | Values for the fields to set in the new record  | Inserts a new lexeme family connection into the database with the fields as specified in the request body. |
|  /lexemeFamily         | DELETE  | **lexeme** the lexeme ID  |  None     | Deletes a lexeme family connection. |
|                    |          | **family** the family ID |     |                      |
|  /lexeme          | GET      | **id** the ID of the lexeme to edit |  None  | Fetches the details of a lexeme to edit. Must be called before attempting to update (PUT). |
|  /lexeme          | PUT    | none   |  New values of the fields in the record being edited; no need to specify unchanged ones  |  Updates an existing record with the fields as specified in the request body. |
|  /lexeme        | POST    | none  | Values for the fields to set in the new record  | Inserts a new lexeme into the database with the fields as specified in the request body. |
|  /lexeme         | DELETE  | **id** the ID of the lexeme to delete  |  None     | Deletes a lexeme. |
|  /rootList      | GET      | **arg** search argument |   None     | Fetches the list of roots for the current language in the specified range |
|                    |          | **type** search argument type (id, text, range) |     |                      |
|  /advancedCriteriaList      | GET      | **forWords** whether the lookup mode is "for words" (boolean) |   None     | Fetches the list of advanced criteria sets in the specified range |
|                    |          | **arg** search argument |     |                      |
|                    |          | **type** search argument type (id, text, range) |     |                      |
|  /advancedCriteria          | PUT    | none   |  New values of the fields in the record being edited; no need to specify unchanged ones  |  Updates an existing record with the fields as specified in the request body. |
|  /advancedCriteria        | POST    | none  | Values for the fields to set in the new record  | Inserts a new advanced criteria set into the database with the fields as specified in the request body. |
|  /advancedCriteria         | DELETE  | **id** the ID of the advanced criteria set to delete  |  None     | Deletes an advanced criteria set. |



Attributes (the lexicon page):

|     Name         |  Label / Description       |         Notes                                 |
|:-----------------|:---------------------------|:---------------------------------------------------|
|   id             |  Lexeme ID                 | The unique identifier of the lexeme. |
|   lemma          |  Lemma                     | The lexeme lemma. |
|   inflections    |  List of inflections       | A comma-delimited list of inflections . |
|   duplicateWarning | Duplicates exist?        | A boolean value indicating that a duplicate exits. | 
|   duplicateIds | Duplicates lexeme ID list        | A list of IDs for the duplicate lexemes. | 
|   families       |  Families linked to the lexeme | An array of families linked to lexeme. |
|   families/id       |  Family ID | An ID of a family linked to the lexeme. |
|   families/definition |  Definition | A definition of a family linked to the lexeme. |

Attributes (the lexeme family connection page):

|     Name         |  Label / Description       |         Notes                                 |
|:-----------------|:---------------------------|:---------------------------------------------------|
|   id             |  Lexeme family connection ID   | The unique identifier of the lexeme family connection (not used by the web methods). |
|   lexemeId       |  Lexeme ID                 | The unique identifier of the lexeme. |
|   lemma          |  Lexeme lemma                 | The lemma of the lexeme. |
|   familyId       |  Family ID                 | The unique identifier of the family. |
|   familyDescription |  Family description                 | The description of the family. |
|   legacyMapId       |  Legacy map ID                 | The legacy map ID (read-only). |
|   discouraged       |  Discouraged                 | Whether the connection is discouraged. |
|   unverified      |  Unverified                 | Whether the record is unverified after bulk processing. |
|   frequency       |  Frequency                 | The frequency grade (a numeric value in range 1 thru 10). |
|   advancedCriteriaId       |  Advanced criteria ID                 | The ID of the advanced criteria set. |
|   advancedCriteriaDescription       |  Advanced criteria description                 | The description of the advanced criteria set (supplied by GET; the description must be refreshed if a new advanced criteria set is selected by the user, but there is no need to return it to the web service). |

Attributes (the advanced criteria pages):

|     Name         |  Label / Description       |         Notes                                 |
|:-----------------|:---------------------------|:---------------------------------------------------|
|   id             |  Advanced critieria ID (list + edit)   | The unique identifier of the advanced criteria ID. Read-only. |
|   forWords          |  For words (list + edit)                     | A boolean value whether the advanced criteria is for words (true) or for affixes / clitics / interfixes (false). |
|   description          |  Description (list + edit)                     | The advanced criteria's description. |
|   phonemesMustMatch    |  Must match (phonemes)                    | The radio buttons field determining whether the phonemes must match or must not match. |
|   hypernymsMustMatch    |  Must match (hypernyms)                    | The radio buttons field determining whether the hypernyms must match or must not match. |
|   clearRequiredPhrases    |  Clear required phrases                    | Determines whether the required phrases must be cleared in the target word. |
|   legacyReferenceID    |  Legacy reference ID                    | A read only attribute holding the the legacy reference ID. |
|  phoneticCompatibility |  Compatible or incompatible phonemes                    | A list of regular expressions or strings. |
|  phoneticCompatibility/type |  Type of the phoneme comparison      | Values: simple / regex. |
|  phoneticCompatibility/expression |  The phoneme itself    | A regular expression or a string to match. |
|  phoneticCompatibility/direction |  Direction of the phoneme comparison  | Values: forward / backward |
|  hypernyms |  Compatible or incompatible hypernyms                   | A list of hypernyms. |
|  hypernyms/id |  Family ID                   | A hypernym family ID. |
|  hypernyms/description |  Description                   | A description of the hypernym family. |
|  hypernyms/definition |  Definition         | A definition from the hypernym family. |
|  hypernyms/children |  Add children? | Whether children must be added along with the hypernym. |
|  requiredPhrases |  Required phrases                    | A list of required phrases. |
|  requiredPhrases/id |  Family ID                   | A required phrase family ID. |
|  requiredPhrases/description |  Description                   | A description of the required phrase family. |
|  requiredPhrases/definition |  Definition         | A definition from the required phrase family. |
|  lexemeIds    |  Linked lexemes                    | A comma-delimited list of lexemes where the advanced criteria is used. |
|  extrahypothesisIds    |  Linked extra-hypotheses                    | A comma-delimited list of extra-hypotheses where the advanced criteria is used. |
|  interfixIds    |  Linked interfixes                    | A comma-delimited list of interfixes where the advanced criteria is used. |
|  cliticIds    |  Linked clitics                    | A comma-delimited list of clitics where the advanced criteria is used. |
|  taggingAffixIds    |  Linked tagging affixes                   | A comma-delimited list of affixes used for tagging where the advanced criteria is used. |
|  inflectionAffixIds    |  Linked inflection affixes                   | A comma-delimited list of affixes used to generate inflections where the advanced criteria is used. |

Attributes (the lexeme edit page):

|     Name         |  Label / Description       |         Notes                                 |
|:-----------------|:---------------------------|:---------------------------------------------------|
|   id             |  Lexeme ID   | The lexeme ID. **Read-only**. |
|   lemma            |  Lemma   | The lexeme lemma. |
|   stem            |  Stem   | The lexeme stem. **Read-only, must be refreshed once the Tag button is pressed**. |
|   note            |  Note  | The linguist's notes. |
|   frequency      |  Frequency | The frequency grade in range 0 thru 10. |
|   advancedCriteriaId       |  Advanced criteria ID                 | The ID of the advanced criteria set. |
|   advancedCriteriaDescription       |  Advanced criteria description                 | The description of the advanced criteria set (supplied by GET; the description must be refreshed if a new advanced criteria set is selected by the user, but there is no need to return it to the web service). |
|   invariable       |  Invariable  | Whether the lexeme is invariable. |
|   unverified       |  Unverified | Whether the lexeme is unverified. |
|   legacyInflectionMapId    |  Legacy inflection Map ID | The legacy inflection map ID. |
|   earliestMention       |  Earliest mention | The date when the lexeme was first mentioned. **Time is not necessary**. Calendar lookup would be good. |
|   lastYearActive    |  Last year active | The last year when the lexeme was known to be active. |
|   root       |  Root | Root 1 ID. |
|   root2       |  Root 2 | Root 2 ID. |
|   root3       |  Root 3 | Root 3 ID. |
|   root4       |  Root 4 | Root 4 ID. |
|   rootDescription       |  Root description | Root description (no need to send back when updating). |
|   root2Description       |  Root 2 description | Root 2 description (no need to send back when updating). |
|   root3Description       |  Root 3 description | Root 3 description (no need to send back when updating). |
|   root4Description       |  Root 4 description | Root 4 description (no need to send back when updating). |
|   unverified      |  Unverified                 | Whether the record is unverified after bulk processing. |
|   mweBehavior       |  MWE behavior | MWE behavior. Values: wholeOnly / flexible / default. |
|   grammar       |  Grammar features | Grammar features associated with the lexeme. (Standard feature edit UI - array.) |
|   style       |  Style features | Style features associated with the lexeme. (Standard feature edit UI - array.) |

Attributes (the root lookup):

|     Name         |  Label / Description       |         Notes                                 |
|:-----------------|:---------------------------|:---------------------------------------------------|
|   id             |  Root ID   | The root ID. |
|   root             |  Root | The root string. |
|   familyId             |  Family ID   | The associated family ID. |
|   familyDescription |  Family description   | The family description. |

##### Inflection table, inflection edit, tagging

|     Method         |   Verb   |   Query parameter(s)     | Request body      |      Notes                                 |
| ------------------ |:--------:|:-------------------------|:-----------|:-----------------------------------------------------------|
|  /inflectionList  | GET      | **lexeme** the lexeme ID to show the inflections for |   None     | Builds and shows the table of inflected forms, distributed according to their features. |
|  /inflection  | POST      | None | A structure containing *features*, *text*, *inflectionId* of the currently selected inflection, as well as *lexemeId* and the currently selected *familyId*. The bulk may be copied from the structure returned by */inflectionList*.   | Obtains details of an inflection override or values to initialize the form with, if the inflection override is not defined. |
|  /inflection  | PUT      | None |   Edited attributes.    | Saves changes or creates a new inflection override. |
|  /inflection  | DELETE      | **id** the ID of the inflection to delete |   None    | Deletes an inflection override. |
| /runtimeInflectionFeatures | POST      | None | A structure containing *familyId*, *lexemeId*, and *features* associated with the currently selected inflected form.    | Generates runtime inflection features. |
| /tagLemma | POST      | None | A snapshot of the lexeme being edited.    | Generates *stem*, *grammar*, *style*, and *invariable*. **If these attributes exist in the web service response, they must overwrite the existing controls. The rest of the attributes must remain unchanged**. |

Attributes (inflection table):

|     Name         |  Label / Description       |         Notes                                 |
|:-----------------|:---------------------------|:---------------------------------------------------|
|   failures       |  Inflection rules that did not match   | Displayed in the "unmatched inflections" dialogue. See reference for the individual attributes in the section dedicated to the unmatched inflections. |
|   generatedBy           | Inflection rule that matched and created this form.            | Displayed in the matched inflection dialogue (marked by the eye icon).    |
|   text           | Text to display            | Feature description or the inflected form to display.    |
|   indent         | Indentation before the text | How many spaces (or tabs, it will look better) to insert before the text. |
|  features        | The features of the form    | Used in the Inflection Edit screen.    |
|  highlight       | Whether to highlight the form | Indicates whether the form is stored in the database (if *true*) or dynamically generated. |
|  inflectionId    | Inflection ID                | ID of the inflection, if stored in the database. Used in the Inflection Edit calls.        |

Attributes for `generatedBy` and `failures` array members in the Inflection Table:

|     Name         |  Label / Description       |         Notes                                 |
|:-----------------|:---------------------------|:---------------------------------------------------|
|   id       |  Inflection rule ID.   | The ID of the inflection rule. |
|   pattern       |  Affix concatenation pattern.   | Demonstrates how the affixes are applied on a word. |
|   required   |  Required features.   | Comma-delimited list of feature descriptions. |
|   assigned   |  Assigned features.   | Comma-delimited list of feature descriptions. |
|   incompatible   |  Incompatible features.   | Whether incompatible features are defined (boolean). |
|   hypernyms   |  Hypernym conditions.   | Whether hypernym conditions are defined (boolean). |
|   trigger    |  Triggering feature.   | A feature associated with the trigger that the rule is linked to. |
|   reason     |  Where the rule failed.   | If the rule failed, where. Values: pattern / required / assigned / incompatible / hypernyms / phonetic / regex / redundant  |

Attributes (inflection edit):

|     Name         |  Label / Description       |         Notes                                 |
|:-----------------|:---------------------------|:---------------------------------------------------|
|   inflectionId   |  Inflection ID  | The ID of the inflected form **if it is in the database**. Does not exist for the dynamic forms. |
|   lexemeId             |  Lexeme ID   | The lexeme ID. **Read-only**. |
|   familyId             |  Family ID   | The currently selected family ID, if available. **Read-only**. |
|   text            |  Form text  | The text of the inflected form. |
|   advancedCriteriaId       |  Advanced criteria ID                 | The ID of the advanced criteria set. |
|   advancedCriteriaDescription       |  Advanced criteria description                 | The description of the advanced 
|   isLemma            |  Is lemma?  | Whether the current form is a lemma. **Lemmas cannot be deleted**. |
|   misspelling            |  Is misspelling?  | Whether the current form is a misspelling. |
|   additionalForms    |  Base for additional forms?  | Whether the current form is used to create additional forms. **Read-only**. Values: no / baseOnly / complete. |
|   note            |  Note  | The linguist's notes. |
|   legacyInflectionMapId            |  Legacy Map ID  | The readonly field for the legacy map ID. |
|   lexemeFeatures            |  Lexeme features  | The unified features from the lexeme. Used only as input for the /runtimeInflectionFeatures.  |
|   familyFeatures            |  Family features  | The unified features from the family. Used only as input for the /runtimeInflectionFeatures.  |
|   lexemeFamilyFeatures            |  Lexeme family features  | The unified features from the lexeme/family connection. Used only as input for the /runtimeInflectionFeatures.  |
|   lexemeGrammar            |  Lexeme grammar features  | The grammar features from the lexeme. **Read-only**. |
|   lexemeStyle            |  Lexeme style features  | The style features from the lexeme. **Read-only**. |
|   familyGrammar            |  Family grammar features  | The grammar features from the currently selected family. **Read-only**. |
|   familySemantics         |  Family semantic features  | The semantic features from the lexeme. **Read-only**. |
|   lexemeFamilyStyle       |  Lexxeme/Family Connection style features  | The style features from the lexeme/family connection. **Read-only**. |
|   inflectionFeatures         |  Inflection features  | The features defined in the inflected form being edited. |
|   inflectionGrammar         |  Inflection grammar | Taken from *inflectionFeatures*.  |
|   inflectionStyle         |  Inflection style | Taken from *inflectionFeatures*. |


