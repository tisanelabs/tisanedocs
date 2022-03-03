# Tisane Embedded Library Documentation

**Table of Contents**

- [Getting Started](#getting-started)
- [What's in the Package](#whats-in-the-package)
  * [Language Models](#language-models)
  * [Binaries](#binaries)
- [Integration](#integration)
  * [Preloading vs. Lazy Loading](#preloading-vs-lazy-loading)
  * [.NET](#net)
    + [Language Model Access](#language-model-access)
    + [Cleanup](#cleanup)
  * [Native C/C++ Applications](#native-cc-applications)
  * [Advanced](#advanced)
    + [LaMP](#lamp)
    + [Deploying by Language Packs](#deploying-by-language-packs)
    + [Tisane.TestConsole.exe.Config Reference](#tisanetestconsoleexeconfig-reference)

## Getting Started

Tisane Embedded Library allows seamless integration of the Tisane functionality in desktop and server applications, eliminating the need to connect to a remote server. 
The two principal components of the package are the runtime library and the set of language models. The library runs on POSIX C/C++ and uses RocksDB to store its language models, making it natively cross-platform on OSes that support POSIX. 

<p align="center">
  <img src="https://github.com/tisanelabs/tisanedocs/blob/master/images/tisaneRuntimeArchitecture.png" alt="Tisane architecture"/>
</p>

Deployment is accomplished by copying the components. The libraries are not COM-based, so no registration is necessary. To start your tests, simply extract the files from the archive into a folder of your choice. (However, bear in mind that the sample PowerShell scripts point at _C:\Tisane_.)

## What's in the Package

### Language Models

The language models or the runtime database use RocksDB, which stores multiple files per data store. The data store names in Tisane are in the following format:

_(language code)_-_(data store name)_

For example, the data store containing the English phrasal patterns is: _en-phrase_. The language codes come from [ISO-639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes); if the language model is specific to a dialect or a script (e.g. Simplified Chinese vs. Traditional Chinese), the code may be followed by an [ISO-3166 two-letter code of a region or a country](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes), e.g. _ps-AF_ for Pashto (Afghanistan).

The datastore _xx-spell_, storing the spellchecking dictionaries, is optional. If it does not exist, no spelling corrections will be performed. 

In addition to the language-specific data stores, the following three data stores are shared across all language models:

* family
* role
* pragma

All the datastores must reside in the same folder. If you require to provide selected languages only, simply use the name prefixes (e.g. en, de, zh_CN) to figure out the language codes, and include the three shared datastores (_family_, _role_, _pragma_).

### Binaries

The Windows distribution contains

* Runtime engine files: 
  * libTisane.dll - the Tisane runtime, with the embedded RocksDB library
  * libgcc_s_seh-1.dll - standard POSIX C/C++ library
  * libstdc++-6.dll - standard POSIX C/C++ library
  * libwinpthread-1.dll - standard POSIX C/C++ library
* .NET wrapper files:
  * Tisane.Runtime.dll - the Tisane wrapper assembly
  * native/amd64/rocksdb.dll - a Windows port of RocksDB engine
  * RocksDbSharp.dll, RocksDbNative.dll - the .NET wrapper for RocksDB
  * netstandard.dll - a standard .NET assembly
  * Microsoft.Win32.Primitives.dll - a standard .NET assembly
  * Newtonsoft.Json.dll - a JSON parsing assembly
  * System.\*.dll - other standard .NET assemblies
* Tisane.TestConsole.exe - diagnostic / test desktop UI tool relying on the .NET libraries
* Tisane.TestConsole.exe.Config - a configuration file for the Tisane Test Console tool. (See reference in the _Tisane.TestConsole.exe.Config Reference_ chapter.)

## Integration

### Preloading vs. Lazy Loading

As parsing language is a complex matter, the language models are complex structures. To optimize the user experience in different scenarios, Tisane provides two ways to work with the language models:

1. **Lazy loading**. Minor portions of the language model are loaded at the initialization, while the lexicon is queried on the go. The initialization takes a couple of seconds, but the initial queries may be a bit slower. Overall, the lazy loading requires roughly 20 to 40 Mb RAM per language, with additional fixed amount of 40 to 60 Mb. 
2. **Preloading**. The entire language model, except for the spellchecking dictionary, is preloaded into the RAM at the initialization time. On a modern midrange machine, equipped with an SSD, it takes between 20 to 40 seconds. The lexicon takes about 400 to 800 Mb per language, with additional fixed amount of 40 to 60 Mb. Callback interface is provided to display the progress when loading.

The preloading mode is recommended for server-based applications and cases when there is a lot of data to analyze. For incidental usage, as well as low-spec hardware, we recommend lazy loading.

It is also possible to preload some language models and let other language models function in the lazy loading mode. Note that once the lazy loading mode is on, it cannot be turned off for the lifetime of the Tisane library. 

### .NET

Requirements: .NET 4.7

<p align="center">
  <img src="https://github.com/tisanelabs/tisanedocs/blob/master/images/tisaneRuntimeNET.png" alt="Tisane architecture"/>
</p>

For .NET applications, we supply a .NET assembly wrapping the core library and a configuration with settings passed to the calls. The settings must be ported to the configuration file associated with the caller application (e.g. _MyApplication.exe.config_). See _Tisane.TestConsole.exe.Config Reference_ for more info. 

* Assembly name:  **Tisane.Runtime.dll**
* Class name:     **Tisane.Server**. Note that while the class is thread-safe, there are no attributes and the class is stateless, but the underlying C/C++ object changes its state. 
* Method:         **Parse** (System.String _language_, System.String _content_, System.String _settings_)
  * _language_ - the code of the language model. Values `*` and `?` or a set of codes delimited by vertical bar (e.g. `de|fr|ja`) invoke language autodetection.
  * _content_  - the text to parse
  * _settings_ - the settings JSON object according to the [settings specs](tisane_settings.md)
  * returns a JSON structure according to the [response specs](tisane_response.md)

* Method:         **Transform** (System.String _sourceLanguage_, System.String _targetLanguage_, System.String _content_, System.String _settings_)
  * _sourceLanguage_ - the code of the language model for the input content. Values `*` and `?` or a set of codes delimited by vertical bar (e.g. `de|fr|ja`) invoke language autodetection.
  * _targetLanguage_ - the code of the target language model
  * _content_  - the text to transform
  * _settings_ - the settings JSON object according to the [settings specs](tisane_settings.md)
  * returns a translated or paraphrased text

* Method:         **DetectLanguage** (System.String _content_, System.String _likelyLanguages_, System.String _delimiter_)
  * _content_  - the content to analyze
  * _likelyLanguages_ - the codes of the likely language model for the input content, delimited by a vertical bar (e.g. `de|fr|ja`). Values `*` and `?` or an empty string means the languages are unknown.
  * _delimiter_ - an optional custom delimiter regex (Google RE2 flavor) that allows custom chunking of the text. E.g. it is possible to probe at the level of a sentence, a paragraph, a sub-sentence, etc. 
  * returns the language breakdown in the specified content as a JSON string.

#### Language Model Access

The language model access methods allow inspecting elements in the language models.

* Method:   **GetFamilyData** (int id)
 * _id_ - the ID of the family to get
 * returns a JSON document (System.IO.Stream) containing family description, definition, and other attributes

* Method:  **ListSenses**  (System.String language, System.String word)
 * _language_ - the language code. **Automatic detection is not supported.**
 * _word_ - a word (including multi-word expressions) to look up. Does not have to be a lemma. 
 * returns a JSON document (System.IO.Stream) containing the families linked to the specified word (IDs, descriptions, and features)

* Method:  **ListHypernyms** (int family, int maxLevel)
 * _family_ - the ID of the family to list the hypernyms for
 * _maxLevel_ - the maximum number of levels to go up
 * returns a JSON document (System.IO.Stream) containing the hypernyms linked to the specified word (IDs, descriptions, and features)

* public  **GetInflectedForms** (System.String language, int lexeme, int family)
 * _language_ - the language code. **Automatic detection is not supported.**
 * _lexeme_ - the ID of the family to list the inflected forms for
 * _family_ - the ID of the lexeme to list the inflected forms for
 * returns a JSON document (System.IO.Stream) containing the families linked to the specified word (IDs, descriptions, and features)

#### Cleanup

* Method:        **Normalize** (System.String _dirtyText_)
  * _dirtyText_ - the text to normalize or clean up
  * returns a cleaned-up text without OCR artifacts, email headers, quoted email text, boilerplate signatures, and fixed-length text breaks (like in Gutenberg Project e-books)

* Method:        **ExtractText** (System.String _webpageText_)
  * _webpageText_ - a web page content to extract text from
  * returns an extracted text from a web page content


The [TisaneTest PowerShell script](TisaneTest.ps1) allows launching the .NET assembly and testing the settings without the need to recompile or modify your application. 

### Native C/C++ Applications

Requirements: Windows XP+ 64 bit

<p align="center">
  <img src="https://github.com/tisanelabs/tisanedocs/blob/master/images/tisaneRuntimeWindowsArchitecture.png" alt="Tisane architecture"/>
</p>

Integration with the native C/C++ applications is available via low-level access to the Tisane library. The prototypes are in C, for the sake of compatibility. 

Use `SetDbPath` to set the data path and `LoadAnalysisLanguageModel` to load your language model, then call `Parse` to process the text. Also see the [response specs](tisane_response.md) and the [settings specs](tisane_settings.md).

Example code:

```c
  SetDbPath("C:\\Tisane");
  ActivateLazyLoading(); // it's a test, we don't want to spend a minute waiting for a tiny piece of text to be processed
  LoadAnalysisLanguageModel("en");
  cout << "\n" << Parse("en", "This is a test.", "{\"parses\":true, \"words\":true}");
```


See the header extract with the function declarations below. 

```c
/**
 * Define the data path to the language models. MUST BE CALLED FIRST
 * @param dataRootPath the path to the language models root folder
 */
__stdcall void SetDbPath(const char *dataRootPath);

/***
 * Loads a language model associated with the specified language code. ONLY AFTER SetDbPath
 * @param languageCode the code of the language to load
 */
__stdcall void LoadAnalysisLanguageModel(const char *languageCode);

/***
 * Loads a language model associated with the specified language code for transformation (translation and paraphrase) applications. ONLY AFTER SetDbPath
 * @param languageCode the code of the target language to load
 */
__stdcall void LoadGenerationLanguageModel(const char *languageCode);

/***
 * Loads a customized language model associated with the specified language code. ONLY AFTER SetDbPath
 * @param languageCode the code of the language to load
 * @param customizationSuffix the suffix for the customization add-on model
 */
__stdcall void LoadCustomizedAnalysisLanguageModel(const char *languageCode, const char *customizationSuffix);

/***
 * Unloads a language model associated with the specified language code.
 * @param languageCode the code of the language to unload
 */
__stdcall void UnloadAnalysisLanguageModel(const char *languageCode);

/**
 * Links a callback function used when a language model is loaded.
 * @param ptrProgressCallback a void function with a double parameter; the parameter will be a number in range 0 thru 1 indicating the progress
 */
 void SetProgressCallback(void __stdcall ptrProgressCallback(double));

/**
 * Activates the lazy loading mode.
 */
void ActivateLazyLoading();

/**
 * Gets whether the lazy loading mode is active.
 * @return true if the lazy loading mode is active, false the lazy loading mode is not active.
 */
bool IsLazyLoadingActive();

/**
 * Parse the specified content in the specified language using the specified settings
 * @param language the language code
 * @param content the text to parse (UTF-8 encoding)
 * @param settings the settings according to the settings specs
 * @return a JSON structure according to the response specs
 */
 const char* Parse(const char * language, const char * content, const char * settings);

/**
 * Detects a language from the specified content.
 * @param content the text to parse (UTF-8 encoding)
 * @param likelyLanguages (optional) languages likely to be in the text
 * @param segmentDelimiter (optional) segment delimiter
 * @return
 */
__stdcall const char* DetectLanguage(const char * content, const char * likelyLanguages, const char* segmentDelimiter);


/**
 * **NOT ACTIVE YET**. Parse the specified content with session-scope modifications to the language model. 
 * @param language the language code
 * @param content the text to parse (UTF-8 encoding)
 * @param settings the settings according to the settings specs
 * @param privateLexicon an array of JSON lexeme entries
 * @param privateFamilies an array of JSON family entries
 * @param privatePragmatics an array of JSON pragmatic / commonsense cue entries
 * @return a JSON structure according to the response specs
 */
__stdcall const char* ParseCustomSession(const char * language, const char * content,
                                            const char * settings, const char * privateLexicon,
                                            const char * privateFamilies,
                                            const char * privatePragmatics);
                                            
/**
 * Translate or paraphrase a string from one language to another
 * @param sourceLanguage the source language code
 * @param targetLanguage the target language code
 * @param content the text to transform (UTF-8 encoding)
 * @param settings the settings according to the [settings specs](tisane_settings.md)
 * @return a translated or paraphrased string
 */
__stdcall const char* Transform(const char * sourceLanguage, const char * targetLanguage,
        const char * content, const char * settings);

```

### Advanced

#### LaMP

Tisane language models are created and edited using a web-based tool called LaMP (Language Model Portal). LaMP is a Windows Communication Foundation web service using Microsoft SQL Server as a backend database. An Angular-based front-end is provided, however, it is possible to substitute it with a custom front-end calling the LaMP API. 

<p align="center">
  <img src="https://github.com/tisanelabs/tisanedocs/blob/master/images/tisaneDBArchitecture.png" alt="Tisane architecture"/>
</p>

A Tisane compiler tool is used to generate the runtime database for the Tisane runtime libraries to use. 

In a typical installation, a nightly compile job uploads most recent builds to a dedicated FTP folder. 
LaMP can be configured to generate complementary (custom) language models by specifying the _CustomSubdir_ parameter. 

How to:

* [add terms in LaMP](https://tisane.ai/knowledgebase/adding-new-terms/)
* [add patterns and commonsense cues in LaMP](https://tisane.ai/knowledgebase/adding-commonsense/)

#### Deploying by Language Packs

Language models are stored in folders. If you do not want to distribute all the language models, include in distribution only folders starting with the codes of the languages you intend to supply, and the three folders _family_, _role_, and _pragma_. E.g. if you need only English, deploy all the _en-_ folders plus  _family_, _role_, and _pragma_.

#### Tisane.TestConsole.exe.Config Reference

The Test Console configuration file is a standard .NET configuration file. The Tisane-specific settings are under the _\<appSettings\>_ tag. 

* _DbPath_ the path of the root folder containing the language models.
* _CustomSubdir_ the subdirectory for the customized datastores, when customized language model overrides are used. 
* _language_ the ISO code of the default language.
* _content_ the content to load at the Test Console startup.
* _PreloadLanguages_ a list of codes of the language models to preload
* _lazy_loading_ determines whether the lazy loading mode is on. The language models are to be loaded fully when first accessed and the setting is _False_; if _True_, the lazy loading mode is on. The user cannot switch it off from the UI.
* _trace_from_section_ contains the name of a section in the process where the tracer will start logging messages to the log file.
* _log_name_ contains the name of the log file for the Tisane core library only. If empty, the logging is turned off. Please note that this is to debug the parsing process only. 
* _Log_ is a pathname of a trace file used to dump higher-level debugging info, e.g. the libraries, the folders, the physical integrity of the files, etc.
* the rest of settings directly reference the attributes in the [Tisane settings](tisane_settings.md).
