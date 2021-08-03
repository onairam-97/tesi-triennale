# Repository Parser

Ruby script that parses repositories and folder which contain Dockerfiles to analyze them.

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

1. Analyze a specified folder that contains dockerfiles and save results into a json file
   * Arguments: -dir {folder path} 0 -repositoryToJson
   * Hint: you find the json files in a new folder named "json"
   * Example: `ruby repository_parser.rb -dir path/to/folder 0 -repositoryToJson`
2. Analyze GitHub repositories from .csv file that contains repo_path and save results into a json file
    * Arguments: -repo "-" {number of repositories to parse}
    * Hint: you find the json files in a new folder named "json"
    * Example: `ruby repository_parser.rb -repo - 5`
3. Analyze a specified folder that contains dockerfiles and save results into a mongodb database
    * Arguments: -dir {folder path} 0 --dbmongo {host} {port} --login {user} {password}
    * Example: `ruby repository_parser.rb -repo -dir path/to/folder 0 --dbmongo <host> <port> --login <user> <pwd>`

## Authors

* **Mariano Buttino** - *University of Molise*
