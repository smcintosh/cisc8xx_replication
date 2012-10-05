require 'rubygems'
require 'sqlite3'

#
# Class for connecting to the SQLite DB
#
class WordSequenceDatabase
    @dbconn

    def initialize(db)
        @dbconn = SQLite3::Database.new(db)
    end

    def each_project
        @dbconn.execute("SELECT DISTINCT pids.project FROM word_seqs ws, proj_ids pids WHERE pids.id = ws.id") do |row|
            yield row
        end
    end

    def each_sequence(project)
        @dbconn.execute("SELECT ws.type, ws.seq FROM word_seqs ws, proj_ids pids WHERE pids.id = ws.id AND pids.project = \"#{project}\"") do |row|
            yield row[0], row[1]
        end
    end
end
