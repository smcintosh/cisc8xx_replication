use strict;
use DB_File;
use Compress::LZF;
use DBI;
use Regexp::Common qw /comment/;

# TODO: Make configurable
my $build_proj_ids = 0;

# Connect to the output database
# TODO: Make DB path configurable
my $odbh = DBI->connect("dbi:SQLite:dbname=/scratch1/shane/cisc8xx/replication/word_seqs.db", "", "") || die "Cannot connect: $DBI::errstr";

# Improve performance, sacrifice robustness
$odbh->do("PRAGMA synchronous = OFF");

# Create the tables if necessary
$odbh->do("CREATE TABLE IF NOT EXISTS proj_ids (id VARCHAR[20], project VARCHAR[80])");
$odbh->do("CREATE TABLE IF NOT EXISTS word_seqs(type CHAR, id VARCHAR[20], seq VARCHAR[2000])");

# Read the idx file into memory...
# Create the id to project mapping
my $idxpath = "/scratch1/AudrisData/ALL.idx";
my %idxhash;
open (IDXFILE, "<$idxpath") or die "Failed to open $idxpath\n";
print "Reading IDX file into memory\n";
while (<IDXFILE>) {
    my $line = $_;
    chomp($line);

    my @line_pieces = split(/;/, $line);
    my $idx = @line_pieces[0];

    my $start_idx = 1;
    if (@line_pieces[1] =~ /^[0-9]+$/) {
        $start_idx = 2;
    }

    my @vals;
    for my $i ($start_idx .. $#line_pieces) {
        push(@vals, @line_pieces[$i]);
    }

    $idxhash{$idx} = [ @vals ];

    if ($build_proj_ids) {
        foreach my $val (@vals) {
            my $proj = $val;
            $proj =~ s/\/.*$//g;

            $odbh->do("INSERT OR IGNORE INTO proj_ids VALUES (\"$idx\", \"$proj\")");
        }
    }
}
close(IDXFILE);

# Keywords to skip
my @keywords = ("abstract", "continue", "for", "new", "switch", "assert",
    "default", "goto", "package", "synchronized", "boolean", "do", "if",
    "private", "this", "break", "double", "implements", "protected", "throw",
    "byte", "else", "import", "public", "throws", "case", "enum", "instanceof",
    "return", "transient", "catch", "extends", "int", "short", "try", "char",
    "final", "interface", "static", "void", "class", "finally", "long",
    "strictfp", "volatile", "const", "float", "native", "super", "while");

# Boilerplate for access to the .db files.
my $b = new DB_File::HASHINFO;
$b ->{cachesize}=1000000000;
$b ->{nelem} = 100000;
$b ->{bsize} = 4096;

my $fname="$ARGV[0]";
my (%clones);
tie %clones, "DB_File", $fname, O_RDONLY, 0666, $b
    or die "cant open file  $fname\n";

# Loop through each entry in the db
while (my ($codec, $vs) = each %clones){
    my @firstfilesplit = split(/\//,@{ $idxhash{$vs} }[0]);
    my $firstfile = @firstfilesplit[$#firstfilesplit-1];
    my @dotextsplit = split(/\./, $firstfile);
    my $dotext = @dotextsplit[$#dotextsplit];

   # look up id, get first file entry, check dot extention
    if ($dotext eq "c" || $dotext eq "h" || $dotext eq "java") {
        my $code = decompress $codec;

    	print "$vs: methods\n";

    	# Looks for method headers and break them up into words
    	while ($code =~ /([A-Za-z0-9_]+)[ \t\n\r]*\(.*\)[ \t\n\r]*(throws[ \t\n\r]+[A-Za-z0-9_]+[ \t\n\r]*)?\{.*\}*/g) {
			if (!grep( /$1/, @keywords)) {
				# DeCamel them or seperate underscore words
            	my @lineParsed = split(/(?<!^)(?=[A-Z])|_/,$1);
                my $lower = lc("@lineParsed");
                $lower =~ s/^\s+//; # remove leading spaces
                $lower =~ s/\s+$//; # remove trailing spaces
                unless ($lower =~ /^\s*$/) {
                    $odbh->do("INSERT INTO word_seqs VALUES ('D', \"$vs\", \"$lower\")");

                }
        	}
    	}

    	print "$vs: comments\n";



        # Looks for comments in code and break them up into words
        my @commentArray =  getComments($code);

        foreach my $comment (@commentArray){

            #Remove special characters from comment blocks
            my $commentBlocks = $comment;
            $commentBlocks =~ s/\*|\/|}|-|=|\$|:|&|'|"|`|<|>|@|\[|\]|,|\\|{|}|\(|\)|\|//g;

            #Break comment blocks into sentences
            my @sentences = split(/\. |;|!|\?/,$commentBlocks);

            #Split each of the sentences into words
            for my $i ( 0 .. $#sentences){
                my @words = split(/[\t\n\r ]+/,$sentences[$i]);
                my $lower = lc("@words");
                $lower =~ s/^\s+//; # remove leading spaces
                $lower =~ s/\s+$//; # remove trailing spaces
                unless ($lower =~ /^\s*$/) {
                    $odbh->do("INSERT INTO word_seqs VALUES ('M', \"$vs\", \"$lower\")");
                }
            }
        }

    } else {
		print "$vs: skipping\n";
    }
}
untie %clones;

$odbh->disconnect;


sub getComments{
    my $wordsIn = shift;
    my @arr = $wordsIn =~  m/$RE{comment}{Java}/g;
    return @arr;
}
