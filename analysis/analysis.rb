#!/usr/bin/ruby

require 'set'
require './WordSequenceDatabase.rb'

db = WordSequenceDatabase.new("/scratch2/cisc835/replication/word_seqs.db")

counter = 0
projectseqs = []
wordhash = {}
stopwords = Set.new()

File.read("stopwords").each_line do |line|
    line = line.strip
    stopwords.add(line)
end

db.each_sequence("FLOSSmole") do |id, type, sequence|
#db.each_sequence("2d3d.googlcode.com") do |id, type, sequence|
    projectseqs[counter] = [id, type, sequence]

    sequence.split.each do |word|
        word = word.strip

        next if (stopwords.include?(word))

        if (wordhash[word] == nil)
            wordhash[word] = Set.new()
        end
        wordhash[word].add(counter)
    end

    counter += 1
    break if (counter == 10)
end

counter = 0
projectseqs.each do |id, type, sequence|
    to_compare = Set.new()

    sequence.split.each do |word|
        word = word.strip

        next if (stopwords.include?(word))

        to_compare.merge(wordhash[word])
    end

    print "#{counter} => "
    to_compare.each do |sid|
        if (sid != counter)
            print "#{sid} "
        end
    end
    puts
    counter += 1
end

counter = 0
projectseqs.each do |id, type, sequence|
    puts "#{counter} => #{sequence}"
    counter += 1
end
