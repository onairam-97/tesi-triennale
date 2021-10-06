require 'mongo'
require 'csv'

user = ARGV[0]
pwd = ARGV[1]
host = ARGV[2]
port = ARGV[3]
db = ARGV[4]

client = Mongo::Client.new("mongodb://#{user}:#{pwd}@#{host}:#{port}/#{db}")
collection = client[:dockerfile]

result = collection.find({"dockerfileBody.mycomments" => { "$exists" => true}})

ELEMENTS = %w(myruns myadds myargs mycmds mycopies myentrypoints myenvs myexposes myfroms myhealthchecks mylabels mymaintainers myonbuilds mystopsignals myusers myvolumes myworkdirs myshells)

ELEMENT_CMD = {
    "myruns"=> "RUN",
    "myadds"=> "ADD",
    "myargs"=> "ARG",
    "mycmds"=> "CMD",
    "mycopies"=> "COPY",
    "myentrypoints"=> "ENTRYPOINT",
    "myenvs"=> "ENV",
    "myexposes"=> "EXPOSE",
    "myfroms"=> "FROM",
    "myhealthchecks"=> "HEALTHCHECK",
    "mylabels"=> "LABEL",
    "mymaintainers"=> "MAINTAINER",
    "myonbuilds"=> "ONBUILD",
    "mystopsignals"=> "STOPSIGNAL",
    "myusers"=> "USER",
    "myvolumes"=> "VOLUME",
    "myworkdirs"=> "WORKDIR",
    "myshells"=> "SHELL"
}

comments_array = []

CSV.open('data.csv', 'w')  do |csv|
    csv << ['dockerfile_sha1', 'instruction', 'comment', 'instruction_number', 'comment_number', 'instruction_line', 'comment_line', 'instruction_type']
    result.each do |object|
        
        object['dockerfileBody']['mycomments'].each do |mycomment|
            ELEMENTS.each do |element|
                if object.dig('dockerfileBody', element) != nil
                    object['dockerfileBody'][element].each do |instruction|
                        if mycomment['instruction'] == (instruction['instruction'] - 1)
                            search_for_key = mycomment['instruction']
                            while object['dockerfileBody']['mycomments'].any?{|hash| hash['instruction'] == search_for_key}
                                object['dockerfileBody']['mycomments'].each do |comment|
                                    if comment['instruction'] == search_for_key
                                        comment['lines'].each do |line|
                                            # filter on comments
                                            comments_array << line.gsub(/(^#+)/, '').strip
                                        end
                                    end
                                end
                                search_for_key = search_for_key - 1
                            end
                            
                             # filter on instructions
                            str_instruction = ""
                            instruction['lines'].each do |line|
                                str_instruction += line.gsub(/(\\+$)/, '')
                            end
                            str_instruction.gsub!(/\s+/, " ")

                            # converting element to docker instruction
                            type = ELEMENT_CMD[element]

                            str_comment = comments_array.reverse.join("\n")
                            if !str_comment.to_s.strip.empty? && !type.nil?
                                csv << [object['_id'], str_instruction, str_comment, instruction['instruction'], mycomment['instruction'], instruction['lineNumber'], mycomment['lineNumber'], type]
                                puts "."
                            end

                            comments_array.clear
                        end
                    end
                end
            end
        end
    end
end

puts "***DONE***"