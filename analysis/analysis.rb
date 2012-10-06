#!/usr/bin/ruby

require './WordSequenceDatabase.rb'

db = WordSequenceDatabase.new("/scratch2/cisc835/replication/word_seqs.db")

counter = 0
projecthash = {}
db.each_sequence("2d3d.googlcode.com") do |id, type, sequence|
    projecthash[counter] = [id, type, sequence]
end
