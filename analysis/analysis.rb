#!/usr/bin/ruby

require 'set'
require './WordSequenceDatabase.rb'

def SimilarityMeasure(originSeq,compareSeq)
    originA = originSeq.split
    compareA = compareSeq.split
    originS = Set.new(originA)
    compareS = Set.new(compareA)
    #print "origin length: #{originS.size}"
    #puts
    #print "origin: #{originS}"
    #puts
    #print "compare length: #{compareS.size}"
    #puts
    #print "compare: #{compareS}" 
    intersect = originS & compareS
    #puts
    #print "intersect length: #{intersect.size}"
    #puts
    #print "intersect: #{intersect}"
    #puts
    length = 0
    if(originS.size > compareS.size)
        length = originS.size
    else
        length = compareS.size
    end
    
    return intersect.size.to_f/length.to_f
end

def lcs(a, b)
    lengths = Array.new(a.size+1) { Array.new(b.size+1) { 0 } }
    # row 0 and column 0 are initialized to 0 already
    a.split('').each_with_index { |x, i|
        b.split('').each_with_index { |y, j|
            if x == y
                lengths[i+1][j+1] = lengths[i][j] + 1
            else
                lengths[i+1][j+1] = \
                    [lengths[i+1][j], lengths[i][j+1]].max
            end
        }
    }
    # read the substring out from the matrix
    result = ""
    x, y = a.size, b.size
    while x != 0 and y != 0
        if lengths[x][y] == lengths[x-1][y]
            x -= 1
        elsif lengths[x][y] == lengths[x][y-1]
            y -= 1
        else
            # assert a[x-1] == b[y-1]
            result << a[x-1]
            x -= 1
            y -= 1
        end
    end
    result.reverse
end

shortest=4
longest=10
gap = 3
threshold=0.7

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
    break if (counter == 3000)
end

counter = 0
counterRPair=0

projectseqs.each do |id, type, sequence|
    if(sequence.size >= shortest && sequence.size <= longest)
	    to_compare = Set.new()

	    sequence.split.each do |word|
		word = word.strip

		next if (stopwords.include?(word))

		to_compare.merge(wordhash[word])
	    end
	    to_compare.each do |sid|
		diff = sequence.size - projectseqs[sid][2].size
                 if(gap <= diff.abs)
			simMeasure = SimilarityMeasure(sequence,projectseqs[sid][2])
			if(simMeasure > threshold && simMeasure != 1.0)
			    print "Sequence: #{sequence}"
			    puts
			    print "Compare with: #{projectseqs[sid][2]}"
			    puts
		   	    print "Similarity: #{simMeasure}"
			    puts
			    lcs = lcs(sequence,projectseqs[sid][2])
			    print "LCS: #{lcs}"
			    puts
			    diff1 = sequence;
			    diff2  =projectseqs[sid][2]
			    diff1.gsub(lcs,"")
			    diff2.gsub(lcs,"")
			    print "RPairs = #{diff1} and #{diff2}"
			    puts
			end
		end
	    end
	    #puts

	    #print "#{counter} => "
	    to_compare.each do |sid|
		if (sid != counter)
	    #        print "#{sid} "
		end
	    end
	    #puts
    end

    counter += 1
end

counter = 0
projectseqs.each do |id, type, sequence|
    #puts "#{counter} => #{sequence}"
    counter += 1
end


