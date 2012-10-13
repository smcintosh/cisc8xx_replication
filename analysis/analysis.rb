#!/usr/bin/ruby

require 'set'
require './WordSequenceDatabase.rb'
require './LCS.rb'
require './Cutoffs.rb'

def SimilarityMeasure(originSeq,compareSeq)
    return 1 if (originSeq == compareSeq)

    origin = originSeq.split
    compare = compareSeq.split
    intersect = origin & compare
    length = 0
    union = origin | compare
    if(union == intersect)
        return 1.0
    end

    if(origin.size > compare.size)
        length = compare.size
    else
        length = origin.size
    end
    
    return intersect.size.to_f/length.to_f
end

def rpairs(originS,compareS,lcsS)
    origin = originS.split
    compare = compareS.split
    lcs = lcsS
    length = 0
    if(origin.size < compare.size)
        length = origin.size
    else
        length = compare.size
    end
    rpairs = []
    rpairsCount = 0
    lcsCount = 0
    origCount = 0
    compCount = 0
    shorterCount = 0
    until (shorterCount >= length ) do
         if(lcsCount >= lcs.size) 
            if(origin[origCount] != compare[compCount])
                rpairs[rpairsCount] = [origin[origCount],compare[compCount]]
                rpairsCount += 1
            end
            origCount += 1
            compCount += 1
        else
        if(lcs[lcsCount] == origin[origCount] && lcs[lcsCount] == compare[compCount]) 
            origCount += 1
            compCount += 1
            lcsCount += 1
        elsif(lcs[lcsCount] != origin[origCount] && lcs[lcsCount] != compare[compCount])
            rpairs[rpairsCount] = [origin[origCount],compare[compCount]]
            rpairsCount += 1
            origCount += 1
            compCount += 1
        elsif(lcs[lcsCount] != origin[origCount] && lcs[lcsCount] == compare[compCount])
            origCount += 1
        elsif(lcs[lcsCount] == origin[origCount] && lcs[lcsCount] != compare[compCount])
            compCount += 1
        end
        end
    if(origin.size < compare.size)
      shorterCount = origCount
    else
      shorterCount = compCount
    end
    end
    return rpairs
end

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
    break if (counter == 500)
end

cutoffs = {
    "MM" => Cutoffs.new(4, 10, 3, 0.7),
    "DD" => Cutoffs.new(2, 4, 0, 0.5),
    "MD" => Cutoffs.new(2, 6, 1, 0.6),
    "DM" => Cutoffs.new(2, 6, 1, 0.6)
}

counter = 0

projectseqs.each do |id, type, sequence|
	to_compare = Set.new()

    sequence.split.each do |word|
        word = word.strip

		next if (stopwords.include?(word))

		to_compare.merge(wordhash[word])
	end

	to_compare.each do |sid|
        # Don't compare against yourself
        next if (sid == counter)

        mycutoffs = cutoffs[projectseqs[sid][1] + type]
        my_sequence = sequence.split
        other_sequence = projectseqs[sid][2].split
		diff = (my_sequence.size - other_sequence.size).abs

        next if (my_sequence.length < mycutoffs.shortest ||
            other_sequence.length < mycutoffs.shortest ||
            my_sequence.length > mycutoffs.longest ||
            other_sequence.length > mycutoffs.longest ||
            diff > mycutoffs.gap)

	    simMeasure = SimilarityMeasure(sequence,projectseqs[sid][2])
		if (simMeasure > mycutoffs.threshold &&
            simMeasure != 1.0)

		    print "Sequence: #{my_sequence.inspect}\n"
		    print "Compare with: #{other_sequence.inspect}\n"
		    print "Similarity: #{simMeasure}\n"
            lcs = LCS.new(my_sequence,other_sequence).calculate
            print "LCS: #{lcs.inspect}\n"
			rpairs = rpairs(sequence,projectseqs[sid][2],lcs)
            print "Actual RPairs: #{rpairs.inspect}\n\n"
	    end
    end

    counter += 1
end
