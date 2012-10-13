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

        seq1_phrases = []
        seq2_phrases = []

        phrase = ""
        @seq1.each do |word|
            if (!lcs.include?(word))
                phrase += "#{word} "
            else
                seq1_phrases.push(phrase.strip) if (!phrase.strip.empty?)
                phrase = ""
            end
        end

        seq1_phrases.push(phrase.strip) if (!phrase.strip.empty?)
        phrase = ""
        @seq2.each do |word|
            if (!lcs.include?(word))
                phrase += "#{word} "
            else
                seq2_phrases.push(phrase.strip) if (!phrase.strip.empty?)
                phrase = ""
            end
        end

        seq2_phrases.push(phrase.strip) if (!phrase.strip.empty?)

        shorter = seq1_phrases.size
        if (seq1_phrases.size > seq2_phrases.size)
            shorter = seq2_phrases.size
        end

        rpairs = []
        shorter.times do |i|
            rpairs[i] = [seq1_phrases[i], seq2_phrases[i]]
        end

        return rpairs
    end
end
