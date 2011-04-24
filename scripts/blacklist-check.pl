use strict;
use warnings;

# Usage: foo.pl DATA_FILE BLACKLIST_FILE
my ($data_file, $blacklist_file) = @ARGV;

# Store the blacklist: lowercase, without newlines.
@ARGV = ($blacklist_file);
my @blacklist = map { chomp; lc } <>;

# Process the data.
@ARGV = ($data_file);
while (my $line = <>){
    for my $bk (@blacklist){
        # Print the line if a blacklist item is found in it.
        if ( index(lc($line), $bk) > -1 ){
            print 'line ', $., ': ', $line;
            last;
        }
    }
}