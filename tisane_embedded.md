## Getting Started

Tisane Embedded Library allows seamless integration in desktop applications, eliminating the need to connect to a remote server. 
The two principal components of the package are the runtime library and the set of language models. The library runs on POSIX C/C++ and uses RocksDB to store its language models, making it natively cross-platform on OSes that support POSIX. 

<p align="center">
  <img src="https://github.com/tisanelabs/tisanedocs/blob/master/images/tisaneRuntimeArchitecture.png" alt="Tisane architecture"/>
</p>

Deployment is accomplished by copying the components. No registration necessary. To start your tests, simply extract the files from the archive into a folder of your choice. (However, bear in mind that the sample PowerShell scripts point at _C:\Tisane_.)

## What's in the Package

### Database

The language models or the runtime database use RocksDB, which stores multiple files per data store. The data store names in Tisane are in the following format:

_(language code)_-_(data store name)_

For example, the data store containing the English phrasal patterns is: _en-phrase_.

The datastore _xx-spell_, storing the spellchecking dictionaries, is optional. If it does not exist, no spelling corrections will be performed. 

In addition to the language-specific data stores, the following three data stores are shared across all language models:

* family
* role
* pragma

All the datastores must reside in the same folder. 

## Integration

### .NET


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

#### Modular Deployment

Language models are stored in folders. 
