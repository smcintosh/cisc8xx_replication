class SeqComparator
    @seq1
    @seq2
    @solutions

    def initialize(seq1, seq2)
        @seq1 = seq1
        @seq2 = seq2
        @solutions = {}
    end

    def lcs(start1=0,start2=0)
        result = []
        remainder1 = ""
        remainder2 = ""
        index = start1.to_s + "," + start2.to_s

        if (@solutions[index])
            return @solutions[index]
        end

        if (start1 == @seq1.size || start2 == @seq2.size)
            result = []
        elsif (@seq1[start1] == @seq2[start2])
            result = []
            result[0] = @seq1[start1]
            result += lcs(start1 + 1,start2 + 1)
        else
            remainder1 = lcs(start1 + 1,start2)
            remainder2 = lcs(start1, start2 + 1)
            if (remainder1.size > remainder2.size)
                result = remainder1
            else
                result = remainder2
            end
        end

        @solutions[index] = result
        return result
    end

    def similarity()
        return 1 if (@seq1.join == @seq2.join)

        length = @seq1.size
        if (@seq1.size > @seq2.size)
            length = @seq2.size
        end
    
        return self.lcs.size.to_f/length.to_f
    end

    def rpairs()
        lcs = self.lcs

        length = 0
        if(@seq1.size < @seq2.size)
            length = @seq1.size
        else
            length = @seq2.size
        end
        rpairs = []
        rpairsCount = 0
        lcsCount = 0
        origCount = 0
        compCount = 0
        shorterCount = 0
        until (shorterCount >= length ) do
            if(lcsCount >= lcs.size) 
                if(@seq1[origCount] != @seq2[compCount])
                    rpairs[rpairsCount] = [@seq1[origCount],@seq2[compCount]]
                    rpairsCount += 1
                end
                origCount += 1
                compCount += 1
            else
                if(lcs[lcsCount] == @seq1[origCount] && lcs[lcsCount] == @seq2[compCount]) 
                    origCount += 1
                    compCount += 1
                    lcsCount += 1
                elsif(lcs[lcsCount] != @seq1[origCount] && lcs[lcsCount] != @seq2[compCount])
                    rpairs[rpairsCount] = [@seq1[origCount],@seq2[compCount]]
                    rpairsCount += 1
                    origCount += 1
                    compCount += 1
                elsif(lcs[lcsCount] != @seq1[origCount] && lcs[lcsCount] == @seq2[compCount])
                    origCount += 1
                elsif(lcs[lcsCount] == @seq1[origCount] && lcs[lcsCount] != @seq2[compCount])
                    compCount += 1
                end
            end
            if(@seq1.size < @seq2.size)
                shorterCount = origCount
            else
                shorterCount = compCount
            end
        end

        return rpairs
    end
end
