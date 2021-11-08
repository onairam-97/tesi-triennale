require 'csv'

ELEMENT_CMD = ["RUN", "ADD", "ARG", "CMD", "COPY", "ENTRYPOINT", "ENV", "EXPOSE", "FROM", "HEALTHCHECK", "LABEL", "MAINTAINER", "ONBUILD", "STOPSIGNAL", "USER", "VOLUME", "WORKDIR", "SHELL"]

lines = []
index_array = []
index = 0
clear_comments = []

CSV.open("data_clean.csv", "w+") do |out_csv|
    # write header
    out_csv << ["dockerfile_sha1","instruction","comment","instruction_number","comment_number","instruction_line","comment_line","instruction_type","comment_clean"]
    CSV.foreach("data.csv") do |row|

        # skip header row
        if index == 0
            index = index + 1
            next
        end

        if row.any?{ |e| e.nil? }
            next
        end

        comment = row[2]
        start_with_instruction = false
        duplicate = []
        clear_comments = []

        # substitute all escape characters with \n
        row_comment = comment.gsub(/\R+/, '\n')

        ELEMENT_CMD.each do |element|
            if comment.strip.start_with? (element)
                start_with_instruction = true
                break
            end
        end

        if start_with_instruction
            if row_comment.include? "\\n"
                lines = row_comment.split("\\n")
                line_index = nil

                lines.each do |line|
                    ELEMENT_CMD.each do |element|
                        duplicate = lines.each_index.select { |i| lines[i] == line } # check for duplicate element
                        if line.strip.start_with? (element)
                            if duplicate.size > 1
                                line_index = duplicate.last
                            else
                                line_index = lines.index(line)
                            end
                        elsif line.strip.empty?
                            line.replace("")
                        end
                        duplicate.clear
                    end
                end

                # clear any line with an index less than or equal to the index of the line which start with docker instruction
                if line_index != nil
                    lines.each do |line|
                        if lines.index(line) <= line_index
                            line.replace("")
                        end
                    end
                end

                comments = lines.join(" ").strip
                if !comments.strip.empty?
                    clear_comments << comments
                else
                    next
                end

            else
                next
            end
        else
            if row_comment.include? "\\n"

                lines = row_comment.split("\\n")
                line_index = nil

                lines.each do |line|
                    ELEMENT_CMD.each do |element|
                        if line.strip.start_with? (element)
                            if duplicate.size > 1
                                line_index = duplicate.last
                            else
                                line_index = lines.index(line)
                            end
                        elsif line.strip.empty?
                            line.replace("")
                        end
                        duplicate.clear
                    end
                end

                if line_index != nil
                    lines.each do |line|
                        if lines.index(line) <= line_index
                            line.replace("")
                        end
                    end
                end

                comments = lines.join(" ").strip
                if !comments.strip.empty?
                    clear_comments << comments
                else
                    next
                end
            else
                clear_comments << row_comment
            end
        end
        index_array.clear
        lines.clear

        index = index + 1

        # write to output
        string_clear_comments = clear_comments.join(",")
        row << string_clear_comments
        out_csv << row
    end
end

puts "*** DONE ***"