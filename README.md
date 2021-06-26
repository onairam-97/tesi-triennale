# Repository Parser

Ruby script that parses repositories which contain Dockerfiles from .cvs file and uses java tool to produces .json file in output.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

Run:

```
git clone https://github.com/onairam-97/repository_parser.git
```
### Prerequisites

What things you need to install the software and how to install them:

* java sdk ditribution: corretto-1.8
* ruby version: 2.7.2p137
* maven version: Apache Maven 3.6.3

## Running instructions

There are different possibilities on how the script can be executed:

1. Analyze a specified folder
   * Arguments: -dir {folder path}
   * Example: `ruby repository_parser.rb -dir path/to/folder`
2. Analyze GitHub repositories from .csv file that contains repo_path 
    * Arguments: -repo "-" {number of repositories to parse}
    * Example: `ruby repository_parser.rb -repo - 5`

## Authors

* **Mariano Buttino** - *University of Molise*
