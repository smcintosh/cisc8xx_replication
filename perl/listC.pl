use strict;
use DB_File;
use Compress::LZF;
use DBI;

my @keywords = ("abstract", "continue", "for", "new", "switch", "assert",
	"default", "goto", "package", "synchronized", "boolean", "do", "if",
	"private", "this", "break", "double", "implements", "protected", "throw",
	"byte", "else", "import", "public", "throws", "case", "enum",
	"instanceof", "return", "transient", "catch", "extends", "int", "short",
	"try", "char", "final", "interface", "static", "void", "class",
	"finally", "long", "strictfp", "volatile", "const", "float", "native",
	"super", "while");

my $b = new DB_File::HASHINFO;
$b ->{cachesize}=1000000000;
$b ->{nelem} = 100000;
$b ->{bsize} = 4096;

my $fname="$ARGV[0]";
my (%clones);
tie %clones, "DB_File", $fname, O_RDONLY, 0666, $b
	or die "cant open file  $fname\n";

# TODO: Make DB path configurable
my $dbh = DBI->connect("dbi:SQLite:dbname=/scratch1/shane/cisc8xx/replication/ids", "", "") || die "Cannot connect: $DBI::errstr";

while (my ($codec, $vs) = each %clones){
    my $res = $dbh->selectall_arrayref("SELECT type FROM ids WHERE id = \"$vs\"");
    if (@$res->[0][0] == 'C' || @$res->[0][0] == 'H' || @$res->[0][0] == 'J') {
        my $code = decompress $codec;

    	print "PRINTING METHOD HEADERS\n\n";

    	# Looks for method headers and break them up into words
    	while ($code =~ /([A-Za-z0-9_]+)[ \t\n\r]*\(.*\)[ \t\n\r]*(throws[ \t\n\r]+[A-Za-z0-9_]+[ \t\n\r]*)?\{.*\}*/g) {
			if (!grep( /$1/, @keywords)) {
				# DeCamel them or seperate underscore words
            	my @lineParsed = split(/(?<!^)(?=[A-Z])|_/,$1);
				for my $i ( 0 .. $#lineParsed){
               		print "$lineParsed[$i],";
            	}
            	print "\n";
        	}
    	}

    	print "PRINTING COMMENTS\n\n";

		# Looks for comments in code and break them up into words
		while ($code =~ /((?:\/\*(?:[^*]|(?:\*+[^*\/]))*\*+\/)|(?:\/\/.*))/g) {

			#Remove special characters from comment blocks
			my $commentBlocks = $1;
			$commentBlocks =~ s/\*|\/|}|-|=|\$|:|&|'|"|`|<|>|@|\[|\]|,|\\|{|}|\(|\)//g;

			#Break comment blocks into sentences
			my @sentences = split(/\.|;|!|\?/,$commentBlocks);

			#Split each of the sentences into words
			for my $i ( 0 .. $#sentences){
				my @words = split(/[\t\n\r ]+/,$sentences[$i]);

				#Print each word seperated by commas
				for my $j (0 .. $#words){
					print "$words[$j],";
				}
				print "\n";
			}
		}
    } else {
		print "SKIPPING\n";
    }
}
untie %clones;

$dbh->disconnect;
