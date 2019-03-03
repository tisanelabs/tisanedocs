# TISANE API

*Use natural language processing to detect abusive content, get sentiment analysis 2.0, topic modelling, and more, in 27 languages*

## About Tisane API

Tisane API provides:

* Granular sentiment analysis (aspect-based sentiment analysis). Rather than a single figure, the result is a vector of values for specific targets
* Detection of abuse: hate speech / personal attacks / sexual advances / profanities
* Topic modeling. IAB and IPTC standards are supported, as well as native topic Tisane IDs. 
* Part of speech tagging with additional tags. Supported standards: [glossing abbreviations](https://en.wikipedia.org/wiki/List_of_glossing_abbreviations), Penn Treebank tags, Universal Dependencies, or native Tisane features
* Entity extraction
* Sense disambiguation

A separate Language Model API provides access to the language model lookup. 

27 languages supported. 

## Setting up

Before deploying, you must:

* [Sign up for a Tisane Labs account](https://tisane.ai/signup/). Free plan is available.
* [Log on to your account and obtain the API key](https://dev.tisane.ai/developer), primary or secondary
* Add a header for Ocp-Apim-Subscription-Key with your API key to the call

That's it - setting it up takes less than 3 minutes. 

[Access full documentation, including source code for different platforms, on Tisane here](https://dev.tisane.ai/docs/services/5a3b6668a3511b11cc292655/operations/5a3b7177a3511b11cc29265c)


## Usage

The request is a POST request with a JSON structure as a sole parameter. The structure has 3 elements:

* `language`: the [ISO 639-1 code](https://www.loc.gov/standards/iso639-2/php/code_list.php) of the language to process
* `content`: the content to process
* `settings`: what to output and other settings. Abuse instances, sentiment snippets, entities, and topics are shown by default. Individual lexical units and parse trees are hidden. 

### POST request (JavaScript)

    $(function() {
        $.ajax({
            url: "https://api.tisane.ai/parse",
            beforeSend: function(xhrObj){
                // Request headers
                xhrObj.setRequestHeader("Content-Type","application/json");
                xhrObj.setRequestHeader("Ocp-Apim-Subscription-Key","{your subscription key}");
            },
            type: "POST",
            // Request body
            data: "{request body}",
        })
        .done(function(data) {
            alert("success");
        })
        .fail(function() {
            alert("error");
        });
    });

### Scenarios

Tisane has a variety of use cases, from a moderation aid to intelligent indexing. 

#### Moderation

For the moderation scenarios, we recommend adopting an approach that works best for your community. In real-time chat environments human moderators cannot be in the middle between the posting and the publishing; here, the moderators can only react after abusive content was published. Depending on how frequent and severe the incidents are, and how the community reacts to them, you may want to mix and match the following options:

* alert the poster, suggesting to rethink what they are about to publish ("was that really necessary?")
* keep track of the frequency of abuses, with an automatic multiple strikes system, after which the account is temporarily suspended until a review of a human moderator
* quietly alert the moderators
* provide an option for the other participants not to see content with particular types of abuse or even blacklist the abusive poster, unless explicitly whitelisted ("you're dead to me"). This is likely to be the most annoying option for the trolls, as they can no longer complain about the authorities misusing their power; in this scenario, it's the other users that voluntarily took action against them
* in case of a personal attack, allow the user that the attack seems to be aimed to, eliminate the message
* censor the message completely or put it in a custody until reviewed by a human moderator. As a general rule, we do not recommend this option, however, it may be required in certain environments (e.g. for legal reasons)
* append a taunting message (e.g. "Sorry, I'm having a bad day today. Please ignore what I'm going to say next"). We also do not recommend this, as it interferes with the natural communication

#### Automatic Notebook

Certain particulars about date, time, location, prices, contact details may be mentioned in the chat; smart chat apps may save these and interact with other applications, like calendars, scheduling software, or a notebook when shopping around and comparing offers. You can use Tisane to extract entities and cleanly store them alongside the original document. 

#### Statistics and Content Aggregation

Tisane's topic extraction can be used for contextual ad display; topics, entities, concepts, and sentiment analysis 2.0 snippets can be aggregated into statistics that can provide the community management with powerful data points to see what their community is excited about and what holds it back. 

### Request Body Examples

#### Sentiment Analysis 2.0

Request:

    {
      "language": "en",
      "content": "The chicken was really pink. I couldn't believe my eyes!",
      "settings": {}
    }


Response:

    {
      "text": "The chicken was really pink. I couldn't believe my eyes!",
      "sentiment_expressions": [
        {
          "sentence_index": 0,
          "offset": 0,
          "length": 27,
          "polarity": "negative",
          "targets": [
            "food",
            "meat"
          ]
        }
      ]
    }


### Abuse Detection: Hate Speech / Bigotry

Request:

    {
      "language": "en",
      "content": "Babylonians are reckless drivers",
      "settings": {}
    }

Response:

    {
      "text": "Babylonians are reckless drivers",
      "abuse": [
        {
          "sentence_index": 0,
          "offset": 0,
          "length": 32,
          "type": "bigotry",
          "severity": "medium"
        }
      ],
      "sentiment_expressions": [
        {
          "sentence_index": 0,
          "offset": 0,
          "length": 32,
          "polarity": "negative",
          "targets": [
            "people"
          ]
        }
      ]
    }

### Abuse Detection: Personal Attack / Cyberbullying

Request:


    {
      "language": "en",
      "content": "Your mother was a hamster",
      "settings": {}
    }

Response:

    {
      "text": "Your mother was a hamster",
      "abuse": [
        {
          "sentence_index": 0,
          "offset": 0,
          "length": 25,
          "type": "personal_attack",
          "severity": "high"
        }
      ],
      "sentiment_expressions": [
        {
          "sentence_index": 0,
          "offset": 0,
          "length": 25,
          "polarity": "negative",
          "targets": [
            "addressee"
          ]
        }
      ]
    }
    
### Topic Modelling

Request:

    {
      "language": "id",
      "content": "HP tarik baterai laptop karena rawan terbakar",
      "settings": {"topic_standard":"iptc_description"}
    }

Response:

    {
      "text": "HP tarik baterai laptop karena rawan terbakar",
      "topics": [
        "IT/computer sciences"
      ],
      "entities_summary": [
        {
          "type": "organization",
          "name": "HP",
          "mentions": [
            {
              "sentence_index": 0,
              "offset": 0,
              "length": 2
            }
          ]
        }
      ]
    }

