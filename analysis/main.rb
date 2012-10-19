#!/usr/bin/ruby

require 'rubygems'
require 'stemmer'
require 'set'
require './WordSequenceDatabase.rb'
require './SeqComparator.rb'
require './Cutoffs.rb'
require './hacks.rb'

# Configuration
max_procs = 15

#
# MAIN LOOP
#

num_procs = 0
children_pids = []

# Monitoring thread
Thread.new do
    while (true) do
        children_pids.each do |pid|
            uptime = `ps -p #{pid} -o etime=`.strip.split(":")
            if (uptime[uptime.size-2].to_i > 14)
                puts "Reaping PID #{pid}"
                Process.kill("USR1", pid)
                children_pids.delete(pid)
                num_procs -= 1
            end
        end
    end
end

File.read("projlist").each_line do |project|
    if (num_procs >= max_procs)
        cpid = Process.wait
        children_pids.delete(cpid)

        num_procs -= 1
    end

    project = project.strip
    STDOUT.flush
    cpid = Process.fork do
        db = WordSequenceDatabase.new("/scratch3/shane/word_seqs.db")
        $stdout.reopen("/dev/null", "w")
        db.for_project(project) do |pdata|

            Signal.trap("USR1") do
                pdata.raise_sig
            end

            pdata.process
        end

        db.close
        exit
    end
    puts "Processing project: #{project} #{cpid}"
    children_pids.push(cpid)

    num_procs += 1
end

Process.waitall
