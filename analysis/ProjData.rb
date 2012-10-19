class ProjData
    @projname
    @rows
    @wordhash
    @stopwords
    @rpair_list
    @rpair_examples
    @rpair_sims

    def initialize(projname, stopwords)
        @projname = projname
        @stopwords = stopwords
        @rows = []
        @wordhash = {}

        @rpair_list = {}
        @rpair_examples = {}
        @rpair_sims = {}
    end

    def add(id, type, seq)
        idx = @rows.size
        @rows.push([id, type, seq])

        seq.split.each do |word|
            word = word.strip

            next if (@stopwords.include?(word))

            @wordhash[word] = Set.new() if (!@wordhash[word])
            @wordhash[word].add(idx)
        end
    end

    def process()
        # CUTOFFS
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

        @rows.each_index do |idx|
            type = @rows[idx][1]
            my_sequence = @rows[idx][2].split

            # Skip if sequence is smaller than the shorest short, or longer than
            # the longest long
            next if (my_sequence.length < min_shortest ||
                my_sequence.length > max_longest)

	        to_compare = Set.new()

            my_sequence.each do |word|
                word = word.strip

		        next if (@stopwords.include?(word))

		        to_compare.merge(@wordhash[word])
	        end

	        to_compare.each do |sid|
                # Don't compare against yourself
                next if (sid.to_i <= idx.to_i)

                other_sequence = @rows[sid][2].split

                # Skip if _way_ too long or _way_ too short
                next if (other_sequence.length < min_shortest ||
                    other_sequence.length > max_longest)

                compare_type = @rows[sid][1] + type
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
                        next if (@stopwords.include?(pair[0]) ||
                            @stopwords.include?(pair[1]) ||
                            pair[0].stem == pair[1].stem)

                        sorted = pair.sort
                        @rpair_list[compare_type] = {} if (!@rpair_list[compare_type])
                        @rpair_examples[compare_type] = {} if (!@rpair_examples[compare_type])
                        @rpair_sims[compare_type] = {} if (!@rpair_sims[compare_type])

                        my_rpair_list = @rpair_list[compare_type]
                        my_rpair_example = @rpair_examples[compare_type]
                        my_rpair_sims = @rpair_sims[compare_type]

                        rpair_idx = sorted[0]+","+sorted[1] 
                
                        my_rpair_list[rpair_idx] = 0 if (!my_rpair_list[rpair_idx])
                        my_rpair_list[rpair_idx] += 1

                        my_rpair_example[rpair_idx] = [my_sequence.join(" "), other_sequence.join(" ")]
                        my_rpair_sims[rpair_idx] = [] if (!my_rpair_sims[rpair_idx])
                        my_rpair_sims[rpair_idx].push(simMeasure)
                    end
	            end
            end
        end

        print_results()
    end

    def print_results()
        if (@rpair_list.size > 0)
            $stdout.reopen("#{@projname}.log", "w")
            puts "type,phrase1,phrase2,support,seq1,seq2,max_sim"
        end
        @rpair_list.each do |type, rpairs|
            rpairs.each do |key, val|
                example = @rpair_examples[type][key]
                max_sim = @rpair_sims[type][key].max
                puts "#{type},#{key},#{val},#{example[0]},#{example[1]},#{max_sim}"
            end
        end
    end
end
