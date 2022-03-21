# Build dataset

In this repository we describe the whole process of obtaining a dataset of code-comment pairs used for the training phase of a Natural Language Source Code Generation system.

## Getting Started
To obtaining the dataset you need to run the scripts in the same order as described in section below.

### Script

#### 1. Repository_parser

This script extract data from Dockerfile.

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

#### 2. Export_data

This script establishes a connection wtih MongoDB and create a code-comment pairs from the information extracted in the previous step and save result in a .csv file.

#### 3. Clear_data

This script remove lines with any empty field and lines that starts with Docker instruction from .csv file. Also remove the lines that starts with Docker instruction in a multilines comment.

#### 4. Data_filter

This script applies various heuristics to obtain the final dataset.

The heuristics applied in the script are:

1. Removes the code-comment pairs whose comment is not in english.
2. Removes the code-comment pairs whose comment is not composed of at least two words.
3. Removes the code-comment pairs whose comment contains a percentage of special characters greater than 7%.
4. Removes the code-comment pairs whose comment do not starts with an alphabetic character.
5. Removes the code-comment pairs whose comment contains link.
6. Removes the code-comment pairs whose comment contains the words "todo", "license" and "copyright".

#### 5. Insert_elastic

This script uploads the data obtained in the previous step to Elasticsearch.

## Authors

* **Mariano Buttino** - *University of Molise*
