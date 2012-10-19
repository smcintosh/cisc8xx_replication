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

        rpairs = []
        seq1_idx = 0
        seq2_idx = 0
        lcs.each do |common_word|
           seq1_phrase = ""
           seq2_phrase = ""

           while (@seq1[seq1_idx] != common_word && seq1_idx < @seq1.size)
               seq1_phrase += "#{@seq1[seq1_idx]} "
               seq1_idx += 1
           end

           while (@seq2[seq2_idx] != common_word && seq2_idx < @seq2.size)
               seq2_phrase += "#{@seq2[seq2_idx]} "
               seq2_idx += 1
           end

           if (!seq1_phrase.empty? and !seq2_phrase.empty? and !seq1_phrase.is_i? and !seq2_phrase.is_i?)
               rpairs.push([seq1_phrase.strip, seq2_phrase.strip])
           end

           seq1_idx += 1
           seq2_idx += 1
        end

        return rpairs
    end
end
