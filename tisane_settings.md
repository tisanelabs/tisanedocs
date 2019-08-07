### Tisane Settings Reference

The purpose of the settings structure is to:

* provide cues about the content to improve the results
* select the sections of the output are to be shown
* define standards and formats in use

The following sections will elaborate on each purpose. All settings are optional. To leave all settings to default, simply provide an empty object (`{}`).

#### Content Cues

`format` (string) - the format of the content. Some policies will be applied depending on the format. Certain logic in the underlying language models may require the content to be of a certain format (e.g. logic applied on the reviews may seek for sentiment more aggressively). The format values are:

* `review` - a review of a product or a service or any other review. Normally, the underlying language models will seek for sentiment expressions more aggressively in reviews.
* `dialogue` - a comment or a post which is a part of a dialogue. An example of a logic more specific to a dialogue is name calling. A single word like "idiot" would not be a personal attack in any other format, but it is certainly a personal attack when part of a dialogue.
* `shortpost` - a microblogging post, e.g. a tweet.
* `longform` - a long post or an article.
* `proofread` - a post which was proofread. In the proofread posts, the spellchecking is switched off. 


abuse (boolean, optional) - instructs to output the abuse section (default: true)
sentiment (boolean, optional) - instructs to output the sentiment_expressions section (default: true)
entities (boolean, optional) - instructs to output the entities_summary section (default: true)
parses (boolean, optional) - instructs to output the parses section (phrases) (default: false)
words (boolean, optional) - instructs to output the elements section (words) (default: false)
snippets (boolean, optional) - instructs to output the text snippets in the abuse, sentiment, and entities sections (default: false)
deterministic (boolean, optional) - instructs whether to omit the n-best senses (default: false)
expected_domains (array[string], optional) - a list of expected domains
expected_hypernyms (array[string], optional) - a list of expected hypernyms
when (string, optional) - when the utterance was uttered (date + time)
format (enum, optional) - the format of the content. One of the following: unspecified / review / proofread / shortpost / longpost / dialogue.
Default: unspecified
Members
unspecified - no special behaviour to enforce
review - any kind of review. More aggressive scanning for sentiment phrases.
proofread - a piece that was proofread. E.g. an article in a magazine, a book, a speech, etc.
shortpost - a short post, e.g. tweet in social media
longform - a long post
dialogue - a part of a dialogue
sentiment_analysis_type (enum, optional) - (RESERVED) the type of the sentiment analysis strategy.
Default: products_and_services
Members
products_and_services - most common sentiment analysis of products and services
entity - sentiment analysis with entities as targets
creative_content_review - reviews of creative content
political_essay - political essays
fetch_definitions (boolean, optional) - if true, instructs to include definitions in the output (warning: slows down the application and increases the size of the response).
debug (boolean, optional) - if true, the process tracing is set to on.
paragraphs (boolean, optional) - if true, outputs paragraph information

#### Standards and Formats

`feature_standard` (string) - determines the standard used to output the features (grammar, style, semantics) in the response object. The standards we support are: 

* `ud`: [Universal Dependencies tags](https://universaldependencies.org/u/pos/)
* `penn`: [Penn treebank tags](https://www.ling.upenn.edu/courses/Fall_2003/ling001/penn_treebank_pos.html)
* `native`: Tisane native feature codes
* `description`: Tisane native feature descriptions

Only the native Tisane standards (codes and descriptions) support style and semantic features.

`topic_standard` (string) - determines the standard used to output the topics in the response object. The standards we support are:

* `iptc_code` - IPTC topic taxonomy code
* `iptc_description` - IPTC topic taxonomy description
* `iab_code` - IAB topic taxonomy code
* `iab_description` - IAB topic taxonomy description
* `native` - Tisane domain description, coming from the family description

