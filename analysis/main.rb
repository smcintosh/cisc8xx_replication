#!/usr/bin/ruby

require 'rubygems'
require 'stemmer'
require 'set'
require './WordSequenceDatabase.rb'
require './SeqComparator.rb'
require './Cutoffs.rb'
require './hacks.rb'

# Configuration
max_procs = 4

#
# MAIN LOOP
#

num_procs = 0
File.read("projlist").each_line do |project|
    if (num_procs < max_procs)
        project = project.strip
        puts "Doing #{project}"
        STDOUT.flush
        Process.fork do
            db = WordSequenceDatabase.new("/scratch3/shane/word_seqs.db")
            $stdout.reopen("#{project}.log", "w")
            db.for_project(project) do |pdata|
                pdata.process
                exit
            end
            db.close
        end
        num_procs += 1
    else
        Process.wait
        num_procs -= 1
    end
end

Process.waitall
