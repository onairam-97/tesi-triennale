require 'csv'
require 'open-uri'
require 'fileutils'

Dir.mkdir("json") unless File.exists?('json')

option = ARGV[0]
directory = ARGV[1]
n = ARGV[2]

if n != nil
    n = n.to_i - 1
end

if option == "-dir" && directory != nil && directory != "-"
    if Dir.exists?(directory)
        `java -jar dfa_tool-1.0-SNAPSHOT-jar-with-dependencies.jar #{directory}`
    else 
        p "Directory does not exist"
    end
elsif option == "-repo" && directory == "-" && n != nil
    array_repo_name = []
    github_url = "https://github.com/"
    
    content = File.read("bq-results-20210507-200521-4b4s93asjwc9.csv")
    CSV.parse(content, headers: true, col_sep: ',') do |row|
        repo_name = row['repo_name']
        array_repo_name << repo_name
    end
    
    array_repo_name[0..n].each do |repo_name|
        complete_url = github_url + repo_name
        begin
            URI.open(complete_url) do
                `java -jar dfa_tool-1.0-SNAPSHOT-jar-with-dependencies.jar #{complete_url} -json`
            end
        rescue
            p 'Repository non trovato ' + complete_url
        end   
    end
else 
    p "Parametri errati"
end

Dir.glob('*.json').each do |file|
    FileUtils.mv(file, 'json')
end
 

 

