# Tisane Response Reference

The response contains several sections which are displayed or hidden according to the [settings](#output-customization). 

The common attributes are:

* `text` (string) - the original input
* `reduced_output` (boolean) - if the input is too big, and verbose information like the lexical chunk was requested, the verbose information will not be generated, and this flag will be set to `true` and returned as part of the response
* `sentiment` (floating-point number) - a number in range -1 to 1 indicating the document-level sentiment. Only shown when `document_sentiment` [setting](#output-customization) is set to `true`.
* `signal2noise` (floating-point number) - a signal to noise ranking of the text, in relation to the array of concepts specified in the `relevant` [setting](#signal-to-noise-ranking). Only shown when the `relevant` setting exists.

### Abusive Content

The `abuse` section is an array of detected instances of content that may violate some terms of use. **NOTE**: the terms of use in online communities may vary, and so it is up to the administrators to determine whether the content is indeed abusive. For instance, it makes no sense to restrict sexual advances in a dating community, or censor profanities when it's accepted in the bulk of the community. 

The section exists if instances of abuse are detected and the `abuse` [setting](#output-customization) is either omitted or set to `true`.

Every instance contains the following attributes:

* `offset` (unsigned integer) - zero-based offset where the instance starts
* `length` (unsigned integer) - length of the content
* `sentence_index` (unsigned integer) - zero-based index of the sentence containing the instance
* `text` (string) - fragment of text containing the instance (only included if the `snippets` [setting](#output-customization) is set to `true`)
* `tags` (array of strings) - when exists, provides additional detail about the abuse. For instance, if the fragment is classified as an attempt to sell hard drugs, one of the tags will be _hard_drug_.
* `type` (string) - the type of the abuse
* `severity` (string) - how severe the abuse is. The levels of severity are `low`, `medium`, `high`, and `extreme`

The currently supported types are:

* `personal_attack` - an insult / attack on the addressee, e.g. an instance of cyberbullying. Please note that an attack on a post or a point, or just negative sentiment is not the same as an insult. The line may be blurred at times. See [our Knowledge Base for more information](http://tisane.ai/knowledgebase/how-do-i-detect-personal-attacks/).
* `bigotry` - hate speech aimed at one of the [protected classes](https://en.wikipedia.org/wiki/Protected_group). The hate speech detected is not just racial slurs, but, generally, hostile statements aimed at the group as a whole
* `profanity` - profane language, regardless of the intent
* `sexual_advances` - welcome or unwelcome attempts to gain some sort of sexual favor or gratification
* `criminal_activity` - attempts to sell or procure restricted items, criminal services, issuing death threats, and so on
* `external_contact` - attempts to establish contact or payment outside of the online community (may violate the rules in certain communities, e.g. gig economy portals, e-commerce portals)
* `spam` - (RESERVED) spam content
* `generic` - undefined

### Sentiment Analysis

The `sentiment_expressions` section is an array of detected fragments relevant to sentiment. 

Every instance contains the following attributes:

* `offset` (unsigned integer) - zero-based offset where the instance starts
* `length` (unsigned integer) - length of the content
* `sentence_index` (unsigned integer) - zero-based index of the sentence containing the instance
* `text` (string) - fragment of text containing the instance (only included if the `snippets` setting is set to `true`)
* `tags` (array of strings) - when exists, provides additional detail about the abuse. For instance, if the abuse is about s


### Entities

Every mention contains the following attributes:

* `offset` (unsigned integer) - zero-based offset where the instance starts
* `length` (unsigned integer) - length of the content
* `sentence_index` (unsigned integer) - zero-based index of the sentence containing the instance
* `text` (string) - fragment of text containing the instance (only included if the `snippets` setting is set to `true`)


### Topics / Subjects / Domains




### Context-Aware Spelling Correction


### Advanced Low-Level Data: Sentences, Phrases, and Words



The response sections and attributes are: 

+ sentiment_expressions (array[object], optional) - a list of sentiment expressions
  + polarity (enum) - negative or positive
      + Values
          + negative - negative sentiment
          + positive - positive sentiment
          + mixed - mixed sentiment
  + reasons (array[string]) - the reasons that the sentiment phrase targets
  + targets (array[string]) - the aspects/entities that the sentiment phrase and its sub-phrases refer to
  + offset (number) - the offset of the phrase that contains the sentiment from the beginning of the sentence
  + length (number) - the length of the phrase that contains the sentiment
  + sentence_index (number) - the index of the sentence that contains the sentiment
+ topics (array[string], optional) - a list of dominant topics in descending order (the most pertinent first)
+ entities_summary (array[object], optional) - a list of entities
  + type (enum) - the type of the entity
      + Values
          + generic - unclassified type of entity
          + person - a person
          + place - a location
          + organization - an organization or a business
          + number - a number
  + name (string) - the full name of the entity (the longest mention)
  + index (number) - the index of the entity
  + mentions (array[EntityMention]) - all the detected mentions of the entity
    + offset (number) - an offset from the beginning of the sentence where the entity is mentioned
    + length (number) - a length of the entity mention
    + sentence_index (number) - the index of the sentence that contains the sentiment
    + text (string) - the mention text, shown only if the setting `snippets` is set to true
+ sentence_list (array[object]) - a list of sentences
  + index (number) - the index of the sentence
  + text (string) - the original text of the sentence
  + modified_text (string, optional) - the modified text, if it was modified
  + elements (array[object]) - the words and the punctuation marks that make up the sentence
    + text (string) - the word itself
    + offset (number) - where the word is located from the beginning of the sentence
    + type (enum) - a type of the constituent
        + Values
            + word - a word or a Constituent
            + punctuation - a punctuation mark
            + numeral - a numeral 
    + role (string, optional) - a semantic role of the word (agent / patient)
    + grammar (array[string], optional) - grammar features
    + style (array[string], optional) - style features
    + nbest_senses (array[WordSense]) - other word senses of the Constituent that were shortlisted
  + parses (array[object])
    + index (number) - the parse index
    + phrases (array[object]) - the phrases, arranged hierarchically
      + index (string) - the index of the phrase
      + text (string) - the phrase and its members, separated by a vertical bar. Sub-phrases are enclosed in brackets
      + type (string) - a type of the phrase (e.g. NP; for those without standard codes, sense_id will be used)
      + parent (number) - the index of the parent
      + children (array[object], optional) - sub-phrases

