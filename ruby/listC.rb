require 'rubygems'
require 'bdb'

#
# Class representing a DB from the world of code.
#
class AudrisDb
	#
	# Filename is the name of the .db file to open.
	#
	def initialize(filename)
		@db = Bdb::Db.new()
		@db.h_nelem = 100000
		@db.open(nil, ARGV[0], nil, Bdb::Db::UNKNOWN, Bdb::DB_RDONLY, 0)
	end

	#
	# Iterate over each key-value pair in the .db file.
	#
	def each
		dbc = @db.cursor(nil,0)
		key,val = dbc.get(nil,nil,Bdb::DB_FIRST)

		begin
			yield key,val
			key,val = dbc.get(nil,nil,Bdb::DB_NEXT)
		end while key

		dbc.close
	end

	def close
		@db.close
	end
end

# Example code to iterate and print each value.
db = SQLite3::Database.new("ids")
adb = AudrisDb.new(ARGV[0])
adb.each do |key,val|
	print val
	type = db.get_first_row("select type from ids where id=\"#{val}\"")

	case type
	when 'C'
		puts " .c"
	when 'H'
		puts " .h"
	when 'J'
		puts " .java"
	else
		puts " SKIP"
	end
end

adb.close
