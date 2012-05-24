#!/usr/bin/env perl

#  Script to convert ABP filters to Opera urlfilter and a CSS with a hiding rule
#  Copyright (C) 2012  anonymous74100
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use File::Spec;
use File::Slurp;
use Getopt::Long qw(:config no_auto_abbrev);
use feature 'unicode_strings';

die "Usage: $^X $0 subscription.txt\n" unless @ARGV;


# Set defaults
my $filename = my $urlfilterfile = my $cssfile = my $customcssfile = my $nourlfilter = my $nocss = my $newsyntax = '';

# Get command line options
GetOptions ('<>'             => \&{$filename = shift},
            'urlfilter:s'    => \$urlfilterfile,
            'css:s'          => \$cssfile,
            'addcustomcss:s' => \$customcssfile,
            'nourlfilter'    => \$nourlfilter,
            'nocss'          => \$nocss,
            'new'            => \$newsyntax);

die "Specified file: $filename doesn't exist!\n" unless (-e $filename);
my ($volume,$directories,$file) = File::Spec->splitpath($filename);
my $path = $volume.$directories;    # Get ABP list path

$urlfilterfile = $path."urlfilter.ini" unless $urlfilterfile;    # Set urlfilter file name
$cssfile = $path."element-filter.css" unless $cssfile;    # Set css file name


die "No lists generated!\n" if ($nocss and $nourlfilter);


my $list = read_file($filename, binmode => ':utf8' );    # Read ABP list

$list =~ s/\r\n/\n/gm;    # Remove CR from CR+LF line endings
$list =~ s/\r/\n/gm;    # Convert CR line endings to LF


my $urlfilter = createUrlfilter($list) unless $nourlfilter;
my $elemfilter = createElemfilter($list) unless $nocss;


# Warn if a file won't be generated
print "Urlfilter won't be generated!\n" unless $urlfilter;
print "CSS won't be generated!\n" unless $elemfilter;


# Write generated files
write_file($urlfilterfile, {binmode => ':utf8'}, $urlfilter) unless ($nourlfilter or !$urlfilter);
write_file($cssfile, {binmode => ':utf8'}, $elemfilter) unless ($nocss or !$elemfilter);




sub createUrlfilter
{
  my $list = shift;

  # Get old checksum and modification time
  my $oldchecksum = my $oldmodified = '';
  if (-e $urlfilterfile)
  {
    my $oldlist = read_file($urlfilterfile, binmode => ':utf8' );
    $oldchecksum = $1 if $oldlist =~ m/(Checksum:.*)$/mi;
    $oldmodified = $1 if $oldlist =~ m/((Last modified|Updated):.*)$/mi;
  }

  my $whitelists = join("\n", ($list =~ m/^@@.*$/gm));    # Collect whitelists

  $list =~ s/^\[.+\]\n//m;    # Remove ABP header
  $list =~ s/^@@.*\n?//gm;    # Remove whitelists
  $list =~ s/^.*##.*\n?//gm;    # Remove element filters
  $list =~ s/^.*\$.*\n?//gm;    # Remove filters with types

  $list =~ s/^!/;/gm;    # Convert comments

  return '' if ((scalar(split(m/^([^;])/m,$list)) - 1) < 1);

  $list =~ s/^(;\s*)Title:\s/$1/mi;    # Normalize title
  $list =~ s/^(;\s*Redirect.*\n)//gmi;    # Remove redirect comment

  $list =~ s/^(;\s*)(Checksum:.*)$/$1$oldchecksum/mi if $oldchecksum;    # Insert old checksum
  $list =~ s/^(;\s*)((Last modified|Updated):.*)$/$1$oldmodified/mi if $oldmodified;    # Insert old modification date/time

  $list =~ s/^([^;|*].*$)/\*$1/gm;    # Add beginning asterisk
  $list =~ s/^([^;]\S*[^|*])$/$1\*/gm;    # Add ending asterisk
  $list =~ s/^\|([^|].*)$/$1/gm;    # Remove beginning pipe
  $list =~ s/^([^;].*)\|$/$1/gm;    # Remove ending pipe



  # Parse whitelists
  my $urlfilter = my $matcheswhitelist = '';

  $whitelists =~ s/^@@//gm;    # Remove whitelist symbols
  $whitelists =~ s/^\|\|//gm;    # Remove vertical bars
  $whitelists =~ s/\^$//gm;    # Remove ending caret
  $whitelists =~ s/\^/\//gm;    # Convert caret to slash
  $whitelists =~ s/\$.*//gm;    # Remove everything after a dollar sign
  $whitelists =~ s/^\*//gm;    # Remove beginning asterisk
  $whitelists =~ s/\*$//gm;    # Remove ending asterisk

  foreach my $line (split(/\n/, $list))
  {
    # Remove filters that require whitelists
    my $tmpline = $line;
    unless ($line =~ m/^;/)
    {
      $tmpline =~ s/^\|\|//;    # Remove pipes
      $tmpline =~ s/\^$//;    # Remove ending caret
      $tmpline =~ s/\^/\//;    # Convert caret to slash
      $tmpline =~ s/\$.*//;    # Remove everything after a dollar sign
      $tmpline =~ s/^\*//;    # Remove beginning asterisk
      $tmpline =~ s/\*$//;    # Remove ending asterisk

      $matcheswhitelist = 1 if (($tmpline =~ m/\Q$whitelists\E/gmi) or ($whitelists =~ m/\Q$tmpline\E/gmi));
    }

    $urlfilter = $urlfilter."$line\n" unless $matcheswhitelist;
    $matcheswhitelist = '';
  }
  $list = $urlfilter;

  return '' if ((scalar(split(m/^([^;])/m,$list)) - 1) < 1);


  unless ($newsyntax)
  {
    $list =~ s/^\|\|(.*)/\*:\/\/$1\n\*\.$1/gm;    # Remove pipes and add protocol and add a filter with subdomain
    $list =~ s/^([^;].*)\^/$1\//gm;    # Convert caret to slash
  }


  $list =~ s/^(;\s*)\n/\[prefs\]\nprioritize excludelist=1\n\[include\]\n\*\n\[exclude\]\n$1\n/m;    # Add urlfilter header

  return $list;
}


sub createElemfilter
{
  my $list = shift;

  # Get old checksum and modification time
  my $oldchecksum = my $oldmodified = '';
  if (-e $cssfile)
  {
    my $oldlist = read_file($cssfile, binmode => ':utf8' );
    $oldchecksum = $1 if $oldlist =~ m/(Checksum:.*)$/mi;
    $oldmodified = $1 if $oldlist =~ m/((Last modified|Updated):.*)$/mi;
  }

  $list =~ s/^(?!##|!).*\n?//gm;    # Leave only generic element filters and comments


  $list =~ s/^(!\s*)Title:\s/$1/mi;    # Normalize title
  $list =~ s/^(!\s*Redirect.*\n)//gmi;    # Remove redirect comment

  $list =~ s/^(!\s*)(Checksum:.*)$/$1$oldchecksum/mi if $oldchecksum;    # Insert old checksum
  $list =~ s/^(!\s*)((Last modified|Updated):.*)$/$1$oldmodified/mi if $oldmodified;    # Insert old modification date/time

  $list =~ s/^##//gm;    # Remove beginning number signs
  $list =~ s/(^[^!].*[\[.#])/\L$1/gmi;    # Convert tags to lowercase

  $list =~ s/^((?!\/\*|\*\/|\!).*[^,])\s*$/$1,/gm;    # Add commas
  $list =~ s/^(!\s*?)\n/\@namespace "http:\/\/www.w3.org\/1999\/xhtml";\n$1\n/m;    # Add xml namespace declaration
  $list =~ s/(^[^!].*),\s*$/$1/ms;    # Remove last comma
  $list = $list." { display: none !important; }\n";    # Add CSS rule


  if ($customcssfile and (-e $customcssfile))
  {
    my $customcss = read_file($customcssfile, binmode => ':utf8' );    # Read custom CSS file
    $customcss =~ s/\r\n/\n/gm;    # Remove CR from CR+LF line endings
    $customcss =~ s/\r/\n/gm;    # Convert CR line endings to LF

    $customcss =~ s/^@.*\n//gm;    # Remove at-rules
    $list = $list."\n".$customcss;    # Add custom CSS to list
  }

  return '' if ((scalar(split(m/^([^!])/m,$list)) - 1) < 1);


  # Convert comments
  my $tmplist = my $previousline = '';

  foreach my $line (split(/\n/, $list))
  {
    $tmplist = $tmplist."/*\n" if (($previousline !~ m/^!/) and ($line =~ m/^!/));
    $tmplist = $tmplist."*/\n" if (($previousline =~ m/^!/) and ($line !~ m/^!/));
    $tmplist = $tmplist.$line."\n";
    $previousline = $line;
  }
  ($list) = $tmplist;

  return $list;
}