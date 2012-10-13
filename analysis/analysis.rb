#!/usr/bin/ruby

require 'rubygems'
require 'stemmer'
require 'set'
require './WordSequenceDatabase.rb'
require './SeqComparator.rb'
require './Cutoffs.rb'
require './hacks.rb'

debug = false

db = WordSequenceDatabase.new("/scratch2/cisc835/replication/word_seqs.db")

counter = 0
projectseqs = []
wordhash = {}
stopwords = Set.new()
rPairs = []
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
    break if (counter == 10000)
end

cutoffs = {
    "MM" => Cutoffs.new(4, 10, 3, 0.7),
    "DD" => Cutoffs.new(2, 4, 0, 0.5),
    "MD" => Cutoffs.new(2, 6, 1, 0.6),
    "DM" => Cutoffs.new(2, 6, 1, 0.6)
}

# Calculate the shortest and longest values
min_shortest = Integer::MAX
max_longest = Integer::MIN
cutoffs.each do |key, val|
    min_shortest = val.shortest if (min_shortest > val.shortest)
    max_longest = val.longest if (max_longest < val.longest)
end

counter = 0
rpair_list = {}

projectseqs.each do |id, type, sequence|
    my_sequence = sequence.split

    # Skip if sequence is smaller than the shorest short, or longer than the longest long
    next if (my_sequence.length < min_shortest ||
        my_sequence.length > max_longest)

	to_compare = Set.new()

    my_sequence.each do |word|
        word = word.strip

		next if (stopwords.include?(word))

		to_compare.merge(wordhash[word])
	end

	to_compare.each do |sid|
        # Don't compare against yourself
        next if (sid.to_i <= counter.to_i)

        other_sequence = projectseqs[sid][2].split

        # Skip if _way_ too long or _way_ too short
        next if (other_sequence.length < min_shortest ||
            other_sequence.length > max_longest)

        compare_type = projectseqs[sid][1] + type
        my_cutoffs = cutoffs[compare_type]
		diff = (my_sequence.size - other_sequence.size).abs

        # Skip if too long or too short
        next if (my_sequence.length < my_cutoffs.shortest ||
            other_sequence.length < my_cutoffs.shortest ||
            my_sequence.length > my_cutoffs.longest ||
            other_sequence.length > my_cutoffs.longest ||
            diff > my_cutoffs.gap)

        seqcompare = SeqComparator.new(my_sequence, other_sequence)
	    simMeasure = seqcompare.similarity
		if (simMeasure > my_cutoffs.threshold &&
            simMeasure != 1.0)

			seqcompare.rpairs.each do |pair|
                puts "#{pair.inspect}"
                next if (stopwords.include?(pair[0]) ||
                    stopwords.include?(pair[1]) ||
                    pair[0].stem == pair[1].stem)

                sorted = pair.sort
                if (!rpair_list[compare_type])
                    rpair_list[compare_type] = {}
                end
                my_rpair_list = rpair_list[compare_type]

                rpair_idx = sorted[0]+","+sorted[1] 
                if (!my_rpair_list[rpair_idx])
                    my_rpair_list[rpair_idx] = 0
                end
                my_rpair_list[rpair_idx] += 1
            end

            if (debug)
		        print "Sequence: #{my_sequence.inspect}\n"
		        print "Compare with: #{other_sequence.inspect}\n"
		        print "Similarity: #{simMeasure}\n"
                lcs = seqcompare.lcs
                print "LCS: #{lcs.inspect}\n"
                print "Actual RPairs: #{rpairs.inspect}\n\n"
            end
	    end
    end

    counter += 1
end

rpair_list.each do |type, rpairs|
    rpairs.each do |key, val|
        puts "#{type} - #{key} - #{val}"
    end
end
