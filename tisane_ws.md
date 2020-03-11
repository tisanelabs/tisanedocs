
# Tisane Web Service Documentation

**Table of Contents**

- [Getting Started](#getting-started)
  * [Deployment](#deployment)
- [What's in the Package](#whats-in-the-package)
  * [Language Models](#language-models)
  * [Binaries](#binaries)
- [Integration](#integration)
  * [.NET](#net)
  * [Native C/C++ Applications](#native-cc-applications)
  * [Advanced](#advanced)
    + [LaMP](#lamp)
    + [Tisane.Runtime.Service.exe.config Reference](#tisaneruntimeserviceexeconfig-reference)
    + [Tisane.TestConsole.exe.Config Reference](#tisanetestconsoleexeconfig-reference)

## Getting Started

Tisane Web Service allows remote client applications use Tisane. 
The two principal components of the package are the executables and the set of language models. The core Tisane library runs on POSIX C/C++ and uses RocksDB to store its language models. On Windows, the library is encapsulated in a .NET assembly, relying on Windows Communication Framework to power the web methods. 

<p align="center">
  <img src="https://github.com/tisanelabs/tisanedocs/blob/master/images/tisaneRuntimeNET.png" alt="Tisane architecture"/>
</p>

### Deployment

Deployment is accomplished by copying the components, and registering the service, which can be then accessed and controlled from Windows Services Manager:

1. Create a folder (e.g. _C:\Tisane\_)
2. Extract the archive to the folder
3. Set the _DbPath_ parameter in _Tisane.Runtime.Service.exe.config_ to your root Tisane path (mind the backslash). 
4. **As an Administrator**, execute the following in Powershell or Command Prompt (substitute _C:\Tisane_ to your Tisane root path): 

```
cd C:\Tisane
.\Tisane.Runtime.Service.exe -i
```

To start your tests, simply extract the files from the archive into a folder of your choice. (However, bear in mind that the sample PowerShell scripts point at _C:\Tisane_.)

<p align="center">
  <img src="https://github.com/tisanelabs/tisanedocs/blob/master/images/tisaneWindowsService.png" alt="Tisane services"/>
</p>

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
  * Tisane.Runtime.Service.exe - the Windows service
* Tisane.TestConsole.exe - diagnostic / test desktop UI tool relying on the .NET libraries
* Tisane.TestConsole.exe.Config - a configuration file for the Tisane Test Console tool. (See reference in the _Tisane.TestConsole.exe.Config Reference_ chapter.)
* Tisane.Runtime.Service.exe.config - a sample configuration file for Tisane Web Service. (See reference in the _Tisane.Runtime.Service.exe.config Reference_ chapter.)

## Integration
### .NET

Requirements: .NET 4.7

<p align="center">
  <img src="https://github.com/tisanelabs/tisanedocs/blob/master/images/tisaneRuntimeNET.png" alt="Tisane architecture"/>
</p>

For .NET applications, we supply a .NET assembly wrapping the core library and a configuration with settings passed to the calls. The settings must be ported to the configuration file associated with the caller application (e.g. _MyApplication.exe.config_). See _Tisane.TestConsole.exe.Config Reference_ for more info. 

* Assembly name:  **Tisane.Runtime.dll**
* Class name:     **Tisane.Server**. Note that while the class is thread-safe, there are no attributes and the class is stateless, but the underlying C/C++ object changes its state. 
* Method:         **Parse** (System.String _language_, System.String _content_, System.String _settings_)
  * _language_ - the code of the language model
  * _content_  - the text to parse
  * _settings_ - the settings JSON object according to the [settings specs](tisane_settings.md)
  * returns a JSON structure according to the [response specs](tisane_response.md)

* Method:         **Transform** (System.String _sourceLanguage_, System.String _targetLanguage_, System.String _content_, System.String _settings_)
  * _sourceLanguage_ - the code of the language model for the input content
  * _targetLanguage_ - the code of the target language model
  * _content_  - the text to transform
  * _settings_ - the settings JSON object according to the [settings specs](tisane_settings.md)
  * returns a translated or paraphrased text


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
__stdcall const char* Parse(const char * language, const char * content, const char * settings);

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
__stdcall EXPORT_FUNCTION const char* Transform(const char * sourceLanguage, const char * targetLanguage,
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

#### Tisane.Runtime.Service.exe.config Reference


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
