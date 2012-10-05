#!/usr/bin/ruby

require './WordSequenceDatabase.rb'

db = WordSequenceDatabase.new("/scratch2/cisc835/replication/word_seqs.db")

db.each_sequence("FLOSSmole") do |type, sequence|
    puts "TYPE: #{type}"
    puts "SEQUENCE: #{sequence}"
end
