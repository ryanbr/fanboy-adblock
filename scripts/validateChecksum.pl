#!/usr/bin/perl

#############################################################################
# This is a reference script to validate the checksum in downloadable       #
# subscription. This performs the same validation as Adblock Plus when it   #
# downloads the subscription.                                               #
#                                                                           #
# To validate a subscription file, run the script like this:                #
#                                                                           #
#   perl validateChecksum.pl subscription.txt                               #
#                                                                           #
# Note: your subscription file should be saved in UTF-8 encoding, otherwise #
# the validation result might be incorrect.                                 #
#                                                                           #
#############################################################################

use strict;
use warnings;
use Digest::MD5 qw(md5_base64);

die "Usage: $^X $0 subscription.txt\n" unless @ARGV;

my $file = $ARGV[0];
my $data = readFile($file);

# Normalize data
$data =~ s/\r//g;
$data =~ s/\n+/\n/g;

# Extract checksum

# Remove checksum
$data =~ s/^\s*!\s*checksum[\s\-:]+([\w\+\/=]+).*\n//mi;
my $checksum = $1;
die "Couldn't find a checksum in the file\n" unless $checksum;

# Calculate new checksum
my $checksumExpected = md5_base64($data);

# Compare checksums
if ($checksum eq $checksumExpected)
{
  print "[OK] Checksum is valid.\n";
  exit(0);
}
else
{
  print "[Wrong checksum] found $checksum, expected [$checksumExpected].\n";
  exit(1);
}

sub readFile
{
  my $file = shift;

  open(local *FILE, "<", $file) || die "Could not read file '$file'";
  binmode(FILE);
  local $/;
  my $result = <FILE>;
  close(FILE);

  return $result;
}
