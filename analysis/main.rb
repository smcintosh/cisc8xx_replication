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
            end
        end
    end
end

File.read("projlist").each_line do |project|
    if (children_pids.size >= max_procs)
        begin
            begin
                cpid = Process.wait(0)
            end while (!children_pids.include?(cpid))
            children_pids.delete(cpid)
        rescue
            # Silently continue
        end
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
        exit(0)
    end
    puts "Processing project: #{project} #{cpid}"
    children_pids.push(cpid)
end

Process.waitall
