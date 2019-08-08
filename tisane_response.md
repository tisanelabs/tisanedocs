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
* `external_contact` - attempts to establish contact or payment via external means of communication, e.g. phone, email, instant messaging (may violate the rules in certain communities, e.g. gig economy portals, e-commerce portals)
* `spam` - (RESERVED) spam content
* `generic` - undefined

### Sentiment Analysis

The `sentiment_expressions` section is an array of detected fragments indicating the attitude towards aspects or entities. 

The section exists if sentiment is detected and the `sentiment` [setting](#output-customization) is either omitted or set to `true`.

Every instance contains the following attributes:

* `offset` (unsigned integer) - zero-based offset where the instance starts
* `length` (unsigned integer) - length of the content
* `sentence_index` (unsigned integer) - zero-based index of the sentence containing the instance
* `text` (string) - fragment of text containing the instance (only included if the `snippets` setting is set to `true`)
* `polarity` (string) - whether the attitude is `positive`, `negative`, or `mixed`. Additionally, there is a `default` sentiment used for cases when the entire snippet has been pre-classified. For instance, if a review is split into two portions, _What did you like?_ and _What did you not like?_, and the reviewer replies briefly, e.g. _The quiet. The service_, the utterance itself has no sentiment value. When the calling application is aware of the intended sentiment, the _default_ sentiment simply provides the targets / aspects, which will be then added the sentiment externally. 
* `targets` (array of strings) - when available, provides set of aspects and/or entities which are the targets of the sentiment. For instance, when the utterance is, _The breakfast was yummy but the staff is unfriendly_, the targets for the two sentiment expressions are `meal` and `staff`. Named entities may also be targets of the sentiment.
* `reasons` (array of strings) - when available, provides reasons for the sentiment. In the example utterance above (_The breakfast was yummy but the staff is unfriendly_), the `reasons` array for the `staff` is `["unfriendly"]`, while the `reasons` array for `meal` is `["tasty"]`.

Example:

```json
"sentiment_expressions": [
        {
            "sentence_index": 0,
             "offset": 0,
             "length": 32,
             "polarity": "positive",
             "reasons": ["close"],
             "targets": ["location"]
         },
         {
            "sentence_index": 0,
             "offset": 38,
             "length": 29,
             "polarity": "negative",
             "reasons": ["disrespectful"],
             "targets": ["staff"]
         }
     ]
```

### Entities

The `entities_summary` section is an array of named entity objects detected in the text. 

The section exists if named entities are detected and the `entities` [setting](#output-customization) is either omitted or set to `true`.

Every entity contains the following attributes:

* `name` (string) - the most complete name of the entity in the text of all the mentions
* `ref_lemma` (string) - when available, the dictionary form of the entity in the reference language (English) regardless of the input language
* `type` (string) - a string or an array of strings specifying the type of the entity, such as `person`, `organization`, `numeric`, `amount_of_money`, `place`. Certain entities, like countries, may have several types (because a country is both a `place` and an `organization`).
* `mentions` (array of objects) - a set of instances where the entity was mentioned in the text

Every mention contains the following attributes:

* `offset` (unsigned integer) - zero-based offset where the instance starts
* `length` (unsigned integer) - length of the content
* `sentence_index` (unsigned integer) - zero-based index of the sentence containing the instance
* `text` (string) - fragment of text containing the instance (only included if the `snippets` setting is set to `true`)


Example:
```json
 "entities_summary": [
        {
            "type": "person",
             "name": "John Smith",
             "ref_lemma": "John Smith",
             "mentions": [
                {
                    "sentence_index": 0,
                     "offset": 0,
                     "length": 10 }
             ]
         }
    ,
         {
            "type": [ "organization", "place" ]
        ,
             "name": "UK",
             "ref_lemma": "U.K.",
             "mentions": [
                {
                    "sentence_index": 0,
                     "offset": 40,
                     "length": 2 }
             ]
         }
     ]
```



### Topics






### Advanced Low-Level Data: Sentences, Phrases, and Words




#### Context-Aware Spelling Correction

Tisane supports automatic, context-aware spelling correction. Whether it's a misspelling or a purported obfuscation, Tisane attempts to deduce the intended meaning, if the language model does not recognize the word. 

When or if it's found, Tisane adds the `corrected_text` attribute to the word (if the words / lexical chunks are returned) and the sentence (if the sentence text is displayed). 

Note that **the invokation of spell-checking does not depend on whether the sentences and the words are displayed***. The spellchecking can be disabled by [setting](#content-cues-and-instructions) `disable_spellcheck` to `true`.


The response sections and attributes are: 

+ topics (array[string], optional) - a list of dominant topics in descending order (the most pertinent first)
+ sentence_list (array[object]) - a list of sentences
  + index (number) - the index of the sentence
  + text (string) - the original text of the sentence
  + corrected_text (string, optional) - the modified text, if it was modified
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

