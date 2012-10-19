require 'rubygems'
require 'sqlite3'
require './ProjData.rb'

#
# Class for connecting to the SQLite DB
#
class WordSequenceDatabase
    @dbconn

    def initialize(db)
        @dbconn = SQLite3::Database.new(db)
    end

    def each_project()
        # Read the stopwords list
        stopwords = Set.new()
        File.read("stopwords").each_line do |line|
            line = line.strip
            stopwords.add(line)
        end

        pdata = nil
        current_proj = ""
        first = true
        @dbconn.execute("SELECT pids.project, ws.id, ws.type, ws.seq FROM word_seqs ws, proj_ids pids WHERE pids.id = ws.id ORDER BY pids.project") do |row|
            if (first)
                current_proj = row[0]
                pdata = ProjData.new(current_proj, stopwords)
                first = false
            elsif (row[0] != current_proj)
                yield pdata
                return # TODO REMOVE ME
                current_proj = row[0]
                pdata = ProjData.new(current_proj, stopwords)
            else
                pdata.add(row[1], row[2], row[3])
            end
        end

        yield pdata
    end

    # Hack for quick results
    def for_project(projname)
        # Read the stopwords list
        stopwords = Set.new()
        File.read("stopwords").each_line do |line|
            line = line.strip
            stopwords.add(line)
        end

        pdata = ProjData.new(projname, stopwords)
        @dbconn.execute("SELECT ws.id, ws.type, ws.seq FROM word_seqs ws, proj_ids pids WHERE pids.id = ws.id AND pids.project = \"#{projname}\"") do |row|
            pdata.add(row[0], row[1], row[2])
        end

        yield pdata
    end

    def close()
        @dbconn.close
    end
end
