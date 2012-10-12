#!/usr/bin/ruby

require 'set'
require './WordSequenceDatabase.rb'

def SimilarityMeasure(originSeq,compareSeq)
    origin = originSeq.split
    compare = compareSeq.split
    intersect = origin & compare
    length = 0
    if(origin.size > compare.size)
        length = compare.size
    else
        length = origin.size
    end
    
    return intersect.size.to_f/length.to_f
end

def LongestCommonSubsequenceWord(arr1,arr2)
  solutions = []
  return lcsWord(0,0)
  def lcsWord(start1,start2)
    result = ""
    remainder1 = ""
    remainder2 = ""
    index = start1 + "," + start2
    if(solutions[index] != null)
      return solutions[index]
    end
  if(start1 == arr1.size || start2 == arr2.size)
    result = []
  elsif ( arr1[start1] == arr2[start2])
    result = []
    result[0] = arr1[start1]
    result = result.concat(lcsWord(start1 + 1,start2 + 1))
  else
    remainder1 = lcsWord(start1 + 1,start2)
    remainder2 = lcsWord(start1, start2 + 1)
    if(remainder1.size > remainder2.size)
      result = remainder1
    else
      result = remainder2
    end
  end
  solutions[index] = result
  return result
  end
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

def rpairs(originS,compareS,lcsS)
    origin = originS.split
    compare = compareS.split
    #lcs = lcsS.split
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
    until (origCount >= length || compCount >= length) do
        #print "#{lcsCount},#{lcs.size}\n"
        if(lcsCount >= lcs.size)
            if(origin[origCount] != compare[compCount])
                rpairs[rpairsCount] = [origin[origCount],compare[compCount]]
                rpairsCount += 1
            end
            origCount += 1
            compCount += 1
        else
        if(lcs[lcsCount] == origin[origCount] && lcs[lcsCount] == compare[compCount]) 
            #print "lcs[#{lcsCount}]=#{lcs[lcsCount]},origin[#{origCount}]=#{origin[origCount]},comp[#{compCount}]=#{compare[compCount]}\n"
            origCount += 1
            compCount += 1
            lcsCount += 1
        elsif(lcs[lcsCount] != origin[origCount] && lcs[lcsCount] != compare[compCount])
            #print "lcs[#{lcsCount}]=#{lcs[lcsCount]},origin[#{origCount}]=#{origin[origCount]},comp[#{compCount}]=#{compare[compCount]}\n"
            rpairs[rpairsCount] = [origin[origCount],compare[compCount]]
            rpairsCount += 1
            origCount += 1
            compCount += 1
        elsif(lcs[lcsCount] != origin[origCount] && lcs[lcsCount] == compare[compCount])
            #print "lcs[#{lcsCount}]=#{lcs[lcsCount]},origin[#{origCount}]=#{origin[origCount]},comp[#{compCount}]=#{compare[compCount]}\n"
            origCount += 1
        elsif(lcs[lcsCount] == origin[origCount] && lcs[lcsCount] != compare[compCount])
            #print "lcs[#{lcsCount}]=#{lcs[lcsCount]},origin[#{origCount}]=#{origin[origCount]},comp[#{compCount}]=#{compare[compCount]}\n"
            compCount += 1
        end
        end
    end
    return rpairs
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
    break if (counter == 500)
end

counter = 0
counterRPair=0

projectseqs.each do |id, type, sequence|
    if(sequence.split.size >= shortest && sequence.split.size <= longest)
	    to_compare = Set.new()

	    sequence.split.each do |word|
		word = word.strip

		next if (stopwords.include?(word))

		to_compare.merge(wordhash[word])
	    end
	    to_compare.each do |sid|
		diff = sequence.split.size - projectseqs[sid][2].split.size
                 if(gap <= diff.abs)
			simMeasure = SimilarityMeasure(sequence,projectseqs[sid][2])
			if(simMeasure > threshold && simMeasure != 1.0)
			    print "Sequence: #{sequence.split.inspect}\n"
			    print "Compare with: #{projectseqs[sid][2].split.inspect}\n"
		   	    print "Similarity: #{simMeasure}\n"
			    #lcs = lcs(sequence,projectseqs[sid][2])
			    #lcs = sequence.split & projectseqs[sid][2].split
                            lcs = LongestCommonSubsequenceWord(sequence.split,projectseqs[sid][2].split)
                            print "LCS: #{lcs.inspect}\n"
			    rpairs = rpairs(sequence,projectseqs[sid][2],lcs)
                            print "Actual RPairs: #{rpairs.inspect}\n\n"
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


