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

    # Get data for specified project
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
