## Getting Started

Tisane Embedded Library allows seamless integration of the Tisane functionality in desktop applications, eliminating the need to connect to a remote server. 
The two principal components of the package are the runtime library and the set of language models. The library runs on POSIX C/C++ and uses RocksDB to store its language models, making it natively cross-platform on OSes that support POSIX. 

<p align="center">
  <img src="https://github.com/tisanelabs/tisanedocs/blob/master/images/tisaneRuntimeArchitecture.png" alt="Tisane architecture"/>
</p>

Deployment is accomplished by copying the components. The libraries are not COM-based, so no registration is necessary. To start your tests, simply extract the files from the archive into a folder of your choice. (However, bear in mind that the sample PowerShell scripts point at _C:\Tisane_.)

## What's in the Package

### Language Models

The language models or the runtime database use RocksDB, which stores multiple files per data store. The data store names in Tisane are in the following format:

_(language code)_-_(data store name)_

For example, the data store containing the English phrasal patterns is: _en-phrase_. The language codes come from [ISO-639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes); if the language model is specific to a dialect or a script (e.g. Simplified Chinese vs. Traditional Chinese), the code may be followed by an [ISO-3166 two-letter code of a region or a country](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes), e.g. _ps_AF_ for Pashto (Afghanistan).

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
  * System.\*.dll - standard .NET assemblies
* Tisane.TestConsole.exe - diagnostic / test desktop UI tool relying on the .NET libraries
* Tisane.TestConsole.exe.Config - a configuration file for the Tisane Test Console tool

## Integration

### .NET

Requirements: .NET 4.7

<p align="center">
  <img src="https://github.com/tisanelabs/tisanedocs/blob/master/images/tisaneRuntimeNET.png" alt="Tisane architecture"/>
</p>

For the needs of integration in .NET applications, Tisane Labs supplies a .NET assembly wrapping the core library and a configuration with settings passed to the calls. 
The assembly name is *Tisane.Server*.

### Native C/C++ Applications

<p align="center">
  <img src="https://github.com/tisanelabs/tisanedocs/blob/master/images/tisaneRuntimeWindowsArchitecture.png" alt="Tisane architecture"/>
</p>


### Advanced

#### LaMP

Tisane language models are created and edited using a web-based tool called LaMP (Language Model Portal). LaMP is a Windows Communication Foundation web service using Microsoft SQL Server as a backend database. An Angular-based front-end is provided, however, it is possible to substitute it with a custom front-end calling the LaMP API. 

<p align="center">
  <img src="https://github.com/tisanelabs/tisanedocs/blob/master/images/tisaneDBArchitecture.png" alt="Tisane architecture"/>
</p>

A Tisane compiler tool is used to generate the runtime database for the Tisane runtime libraries to use. 

#### Deploying by Language Packs

Language models are stored in folders. If you do not want to distribute all the language models, include in distribution only folders starting with the codes of the languages you intend to supply, and the three folders _family_, _role_, and _pragma_.

#### Tisane.TestConsole.exe.Config Reference

The Test Console configuration file is a standard .NET configuration file. The Tisane-specific settings are under the _\<appSettings\>_ tag. 

* _DbPath_ holds the path of the root folder containing the language models
* _language_ contains the ISO code of the default language
* _content_ holds the content to load at the Test Console startup
* the rest of settings directly reference the attributes in the [Tisane settings](tisane_settings.md)
