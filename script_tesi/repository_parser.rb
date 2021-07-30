require 'csv'
require 'open-uri'
require 'fileutils'

option = ARGV[0]
directory = ARGV[1]
n = ARGV[2]
mode = ARGV[3]
host = ARGV[4]
port = ARGV[5]
user = ARGV[7]
pwd = ARGV[8]

if n != nil && n != "0"
    n = n.to_i - 1
end

if option == "-dir" && directory != nil && directory != "-" && n == "0"
    if mode == "--dbmongo" && host != nil && port != nil && user != nil && pwd != nil
        if Dir.exists?(directory)
            `java -jar dfa_tool-1.0-SNAPSHOT-jar-with-dependencies.jar #{directory} #{mode} #{host} #{port} --login #{user} #{pwd}`
        else 
            p "Directory does not exist"
        end
    elsif mode == "-dockerfileToJson" && host == nil && port == nil && user == nil && pwd == nil
        if Dir.exists?(directory)
            Dir.mkdir("json") unless File.exists?('json')
            `java -jar dfa_tool-1.0-SNAPSHOT-jar-with-dependencies.jar #{directory} #{mode}`
        else 
            p "Directory does not exist"
        end
    end
elsif option == "-repo" && directory == "-" && n != nil && mode == nil && host == nil && port == nil && user == nil && pwd == nil
    Dir.mkdir("json") unless File.exists?('json')
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
                `java -jar dfa_tool-1.0-SNAPSHOT-jar-with-dependencies.jar #{complete_url} -repositoryToJson`
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