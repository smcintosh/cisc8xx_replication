#!/usr/bin/ruby

require 'rubygems'
require 'stemmer'
require 'set'
require './WordSequenceDatabase.rb'
require './SeqComparator.rb'
require './Cutoffs.rb'
require './hacks.rb'

#
# MAIN LOOP
#

db = WordSequenceDatabase.new("/scratch3/shane/word_seqs.db")
db.for_project("a2ps") do |pdata|
    pdata.process
end

db.close
