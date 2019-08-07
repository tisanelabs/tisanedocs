### Tisane Settings Reference

The purpose of the settings structure is to:

  * [Content Cues and Instructions](#content-cues-and-instructions) - provide cues about the content being sent to improve the results
  * [Output Customization](#output-customization) - customize the output and select sections to be shown
  * [Standards and Formats](#standards-and-formats) - define standards and formats in use
  * [Signal to Noise Ranking](#signal-to-noise-ranking) - define and calculate the signal to noise ranking

All settings are optional. To leave all settings to default, simply provide an empty object (`{}`).

#### Content Cues and Instructions

`format` (string) - the format of the content. Some policies will be applied depending on the format. Certain logic in the underlying language models may require the content to be of a certain format (e.g. logic applied on the reviews may seek for sentiment more aggressively). The default format is empty / undefined. The format values are:

* `review` - a review of a product or a service or any other review. Normally, the underlying language models will seek for sentiment expressions more aggressively in reviews.
* `dialogue` - a comment or a post which is a part of a dialogue. An example of a logic more specific to a dialogue is name calling. A single word like "idiot" would not be a personal attack in any other format, but it is certainly a personal attack when part of a dialogue.
* `shortpost` - a microblogging post, e.g. a tweet.
* `longform` - a long post or an article.
* `proofread` - a post which was proofread. In the proofread posts, the spellchecking is switched off. 

`disable_spellcheck` (boolean) - determines whether the automatic spellchecking is to be disabled. Default: `false`.

`domain_factors` (set of pairs made of strings and numbers) - provides a session-scope cues for the domains of discourse. This is a powerful tool that allows tailoring the result based on the use case. The format is, family ID of the domain as a key and the multiplication factor as a value (e.g. _"12345": 5.0_). For example, when processing text looking for criminal activity, we may want to set domains relevant to drugs, firearms, crime, higher: `"domain_factors": {"31058": 5.0, "45220": 5.0, "14112": 5.0, "14509": 3.0, "28309": 5.0, "43220": 5.0, "34581": 5.0}`. The same device can be used to eliminate noise coming from domains we know are irrelevant by setting the factor to a value lower than 1. 

`when` (date string, format YYYY-MM-DD) - indicates when the utterance was uttered. (TO BE IMPLEMENTED) The purpose is to prune word senses that were not available at a particular point in time. For example, the words `troll`, `mail`, and `post` had nothing to do with the Internet 300 years ago because there was no Internet, and so if we are confident that the text originated hundreds of years ago, we should ignore the word senses that emerged only recently.

#### Output Customization

`abuse` (boolean) - output instances of abusive content (default: `true`)

`sentiment` (boolean) - output sentiment-bearing snippets (default: `true`)

`entities` (boolean) - output entities (default: `true`)

`topics` (boolean) - output topics (default: `true`), with two more relevant settings:

 * `topic_stats` (boolean) - include coverage statistics in the topic output (default: `false`). When set, the topic is an object containing the attributes `topic` (string) and `coverage` (floating-point number). The coverage indicates a share of sentences touching the topic among all the sentences. 
 * `optimize_topics` (boolean) - if `true`, the less specific topics are removed if they are parts of the more specific topics. For example, when the topic is `cryptocurrency`, the optimization removes `finance`.  
 
`words` (boolean) - output the lexical chunks / words for every sentence (default: `false`). In languages without white spaces (Chinese, Japanese, Thai), the tokens are tokenized words. In languages with compounds (e.g. German, Dutch, Norwegian), the compounds are split. 

  `fetch_definitions` (boolean) - include definitions of the words in the output (default: `false`). Only relevant when the `words` setting is `true`

`parses` (boolean) - output parse forests of phrases

`deterministic` (boolean) - whether the n-best senses and n-best parses are to be output in addition to the detected sense. If `true`, only the detected sense will be output. Default: `true`

`snippets` (boolean) - include the text snippets in the abuse, sentiment, and entities sections (default: `false`)


#### Standards and Formats

`feature_standard` (string) - determines the standard used to output the features (grammar, style, semantics) in the response object. The standards we support are: 

* `ud`: [Universal Dependencies tags](https://universaldependencies.org/u/pos/) (default)
* `penn`: [Penn treebank tags](https://www.ling.upenn.edu/courses/Fall_2003/ling001/penn_treebank_pos.html)
* `native`: Tisane native feature codes
* `description`: Tisane native feature descriptions

Only the native Tisane standards (codes and descriptions) support style and semantic features.

`topic_standard` (string) - determines the standard used to output the topics in the response object. The standards we support are:

* `iptc_code` - IPTC topic taxonomy code
* `iptc_description` - IPTC topic taxonomy description
* `iab_code` - IAB topic taxonomy code
* `iab_description` - IAB topic taxonomy description
* `native` - Tisane domain description, coming from the family description (default)

`sentiment_analysis_type` (string) - (RESERVED) the type of the sentiment analysis strategy. The values are:

* `products_and_services` - most common sentiment analysis of products and services
* `entity` - sentiment analysis with entities as targets
* `creative_content_review` - reviews of creative content
* `political_essay` - political essays

#### Signal to Noise Ranking

When we're studying a bunch of posts commenting on an issue or an article, we may want to prioritise the ones more relevant to the topic, and containing more reason and logic than emotion. This is what the signal to noise ranking is meant to achieve.

The signal to noise ranking is made of two parts:

1. Determine the most relevant concepts. This part may be omitted, depending on the use case scenario (e.g. we want to track posts most relevant to a particular set of issues). 
2. Rank the actual post in relevance to these concepts. 

To determine the most relevant concepts, we need to analyze the headline or the article itself. The headline is usually enough. We need two additional settings:

* `keyword_features` (an object of strings with string values) - determines the features to look for in a word. When such a feature is found, the family ID is added to the set of potentially relevant family IDs. 
* `stop_hypernyms` (an array of integers) - if a potentially relevant family ID has a hypernym listed in this setting, it will not be considered. For example, we extracted a set of nouns from the headline, but we may not be interested in abstractions or feelings. E.g. from a headline like _Fear and Loathing in Las Vegas_ we want _Las Vegas_ only. Optional.

If `keyword_features` is provided in the settings, the response will have a special attribute, `relevant`, containing a set of family IDs. 

At the second stage, when ranking the actual posts or comments for relevance, this array is to be supplied among the settings. The ranking is boosted when the domain, the hypernyms, or the families related to those in the `relevant` array are mentioned, when negative and positive sentiment is linked to aspects, and penalized when the negativity is not linked to aspects, or abuse of any kind is found. The latter consideration may be disabled, e.g. when we are looking for specific criminal content. When the `abuse_not_noise` parameter is specified and set to `true`, the abuse is not penalized by the ranking calculations. 

To sum it up, in order to calculate the signal to noise ranking: 

1. Analyze the headline with `keyword_features` and, optionally, `stop_hypernyms` in the settings. Obtain the `relevant` attribute.
2. When analyzing the posts or the comments, specify the `relevant` attribute obtained in step 1. 
