
# Tisane Web Service Documentation

**Table of Contents**

- [Getting Started](#getting-started)
  * [Deployment](#deployment)
- [What's in the Package](#whats-in-the-package)
  * [Language Models](#language-models)
  * [Binaries](#binaries)
- [API Reference](#api-reference)
- [Tisane.Runtime.Service.exe.config Reference](#tisaneruntimeserviceexeconfig-reference)
- [Tisane.TestConsole.exe.Config Reference](#tisanetestconsoleexeconfig-reference)
- [LaMP](#lamp)

## Getting Started

Tisane Web Service allows remote client applications use Tisane. 
The two principal components of the package are the executables and the set of language models. The core Tisane library runs on POSIX C/C++ and uses RocksDB to store its language models. On Windows, the library is encapsulated in a .NET assembly, relying on Windows Communication Framework to power the web methods. 

<p align="center">
  <img src="https://github.com/tisanelabs/tisanedocs/blob/master/images/tisaneRuntimeNET.png" alt="Tisane architecture"/>
</p>

### Requirements

Tisane requires:

* Windows Server 2012 or newer
* .NET 4.7+
* 4 Gb RAM or better

Faster drives (e.g. SSD) are recommended. 
Tisane Web Service is self-hosted. There is no need to install IIS. For production-level loads, allocate about 1.2 Gb per instance. For example, a machine with 8 Gb RAM can comfortably run 5 instances of Tisane on different ports. 

### Deployment

Deployment is accomplished by copying the components, and registering the service, which can be then accessed and controlled from Windows Services Manager:

1. Create a folder (e.g. _C:\Tisane\_)
2. Extract the archive to the folder of your choice. (However, bear in mind that the sample PowerShell scripts point at _C:\Tisane_.)
3. Set the _DbPath_ parameter in _Tisane.Runtime.Service.exe.config_ to your root Tisane path (mind the backslash). 
4. **As an Administrator**, execute the following in Powershell or Command Prompt (substitute _C:\Tisane_ to your Tisane root path): 

```
cd C:\Tisane
.\Tisane.Runtime.Service.exe -i
```
If everything worked, you will see your Tisane service in the Windows Services Manager. The service description contains the name of the folder where it's been deployed. 

<p align="center">
  <img src="https://github.com/tisanelabs/tisanedocs/blob/master/images/tisaneWindowsService.png" alt="Tisane services"/>
</p>

#### Running Several Instances

Several instances of Tisane may run in parallel. They can access the same linguistic database, but they need to be in different folders and run on different ports. To deploy an additional instance:

1. Create a new folder.
2. Copy all the files from the root Tisane folder + `native` subfolder to the new folder.
3. Set the _DbPath_ parameter in _Tisane.Runtime.Service.exe.config_ in your new folder. Set the _baseAddress_ parameter to point to a new port.    
4. **As an Administrator**, execute the following in Powershell or Command Prompt (substitute _C:\MyNewTisaneFolder_ to your new folder's name): 
```
cd C:\MyNewTisaneFolder
.\Tisane.Runtime.Service.exe -i
```
If everything worked, you will see your Tisane service in the Windows Services Manager. 

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
* Tisane.TestConsole.exe - diagnostic / test desktop UI tool
* Tisane.TestConsole.exe.Config - a configuration file for the Tisane Test Console tool. (See reference in the _Tisane.TestConsole.exe.Config Reference_ chapter.)
* Tisane.Runtime.Service.exe.config - a sample configuration file for Tisane Web Service. (See reference in the _Tisane.Runtime.Service.exe.config Reference_ chapter.)

## API Reference

See [/parse method reference on Tisane Labs' developers portal](https://dev.tisane.ai/docs/services/5a3b6668a3511b11cc292655/operations/5a3b7177a3511b11cc29265c). No need to use the API keys. 

## Tisane.Runtime.Service.exe.config Reference

* _DbPath_ the path of the root folder containing the language models.
* _PreloadLanguages_ a list of codes of the language models to preload
* _FeedbackUrl_ a URL to send all the input to (optional)

As Tisane Web Service runs on [Windows Communication Foundation](https://en.wikipedia.org/wiki/Windows_Communication_Foundation), anything supported by WCF can be used by Tisane Web Service (packet signing, SOAP, advanced authentication, etc.). [Read more on configuring WCF services](https://docs.microsoft.com/en-us/dotnet/framework/wcf/configuring-services-using-configuration-files).

## Tisane.TestConsole.exe.Config Reference

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

## LaMP

Tisane language models are created and edited using a web-based tool called LaMP (Language Model Portal). LaMP is a 


ommunication Foundation web service using Microsoft SQL Server as a backend database. An Angular-based front-end is provided, however, it is possible to substitute it with a custom front-end calling the LaMP API. 

<p align="center">
  <img src="https://github.com/tisanelabs/tisanedocs/blob/master/images/tisaneDBArchitecture.png" alt="Tisane architecture"/>
</p>

A Tisane compiler tool is used to generate the runtime database for the Tisane runtime libraries to use. 

In a typical installation, a nightly compile job uploads most recent builds to a dedicated FTP folder. 
LaMP can be configured to generate complementary (custom) language models by specifying the _CustomSubdir_ parameter. 

How to:

* [add terms in LaMP](https://tisane.ai/knowledgebase/adding-new-terms/)
* [add patterns and commonsense cues in LaMP](https://tisane.ai/knowledgebase/adding-commonsense/)


