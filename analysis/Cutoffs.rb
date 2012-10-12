class Cutoffs
    @shortest
    @longest
    @gap
    @threshold

    def initialize(shortest, longest, gap, threshold)
        @shortest = shortest
        @longest = longest
        @gap = gap
        @threshold = threshold
    end

    attr_reader :shortest
    attr_reader :longest
    attr_reader :gap
    attr_reader :threshold
end
