class LCS
    @seq1
    @seq2
    @solutions

    def initialize(seq1, seq2)
        @seq1 = seq1
        @seq2 = seq2
        @solutions = {}
    end

    def calculate(start1=0,start2=0)
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
            result += calculate(start1 + 1,start2 + 1)
        else
            remainder1 = calculate(start1 + 1,start2)
            remainder2 = calculate(start1, start2 + 1)
            if (remainder1.size > remainder2.size)
                result = remainder1
            else
                result = remainder2
            end
        end

        @solutions[index] = result
        return result
    end
end
