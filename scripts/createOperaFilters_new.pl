#!/usr/bin/env perl

#  Script to convert ABP filters to Opera urlfilter and CSS element filters
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
use File::Basename;
use List::MoreUtils qw{lastidx firstval};

die "Usage: $^X $0 subscription.txt\n" unless @ARGV;

my $file = $ARGV[0];
my $path = dirname($file);
my $list = readFile($file);

my $nocss = 1 if ( grep { $_ eq "--nocss"} @ARGV );
my $nourlfilter = 1 if ( grep { $_ eq "--nourlfilter"} @ARGV );
die "No lists generated!\n" if ((defined $nourlfilter) and (defined $nocss));


my $urlfilter = createUrlfilter($list) unless (defined $nourlfilter);
my $elemfilter = createElemfilter($list) unless (defined $nocss);

# Warn if a file won't be generated
print "Urlfilter won't be generated!\n" unless (defined $urlfilter);
print "CSS won't be generated!\n" unless (defined $elemfilter);

# Write generated files
writeFile("$path/urlfilter.ini",$urlfilter) unless ((defined $nourlfilter) or (!defined $urlfilter));
writeFile("$path/element-filter.css",$elemfilter) unless ((defined $nocss) or (!defined $elemfilter));



sub createUrlfilter
{
  my $list = shift;
  my @urlfilter;
  my @whitelists;

  my $oldchecksum;
  my $oldmodified;

  # Get old checksum and modification time
  if (-e "$path/urlfilter.ini")
  {
    my @oldlist = (split(/\n/, (readFile("$path/urlfilter.ini"))));
    $oldchecksum = firstval { $_ =~ m/Checksum:/i } @oldlist;
    $oldmodified = firstval { $_ =~ m/(Last modified|Updated):/i } @oldlist;
    undef @oldlist;
  }


  foreach my $line (split(/\n/, $list))
  {
    unless ($line =~m/\[.*?\]/i)
    {
      # Convert comments
      if ($line =~ m/^!/)
      {
        # Insert old checksumm
        if ($line =~ m/Checksum:/i)
        {
          (defined $oldchecksum) ? ($line) = $oldchecksum : $line =~ s/^!/;/;
        }

        # Insert old last modified
        elsif ($line =~ m/(Last modified|Updated):/i)
        {
          (defined $oldmodified) ? ($line) = $oldmodified : $line =~ s/^!/;/;
        }

        # Normalize title
        elsif ($line =~ m/Title:/i)
        {
          $line =~ s/Title: //i;
        }

        # Add the rest of comments
        unless ($line =~ m/Redirect:/i)
        {
          $line =~ s/^\!/;/;
          push @urlfilter, $line;
        }
      }

      # Collect whitelists
      elsif (($line =~ m/^@@/) and ($line !~ m/\^\$elemhide$/))
      {
        $line =~ s/\$.*// if $line =~ m/\$/;    # Remove everything after a dollar sign

        if ($line =~ m/^@@\|\|/)
        {
          # Collect domain whitelists
          if ($line =~ m/\^$/)
          {
            $line =~ s/^@@\|\|//;    # Remove whitelist symbols and vertical bars
            $line =~ s/\^$//;    # Remove ending caret

            push @whitelists, $line;
          }
          else
          # Collect whitelists with a domain in them
          {
            $line =~ s/\^/\// if $line =~ m/\^/;    # Convert caret to slash
            $line =~ s/\*$// if $line =~ m/\*$/;    # Remove ending asterisk
          }
        }
        else
        # Collect generic whitelists
        {
          $line =~ s/^\*// if $line =~ m/^\*/;    # Remove beginning asterisk
          $line =~ s/\*$// if $line =~ m/\*$/;    # Remove ending asterisk
        }
        push @whitelists, $line;
      }

      elsif (($line !~ m/\$/) and ($line !~ m/##/))
      {
        $line =~ s/^\|// if (($line !~ m/^\|\|/) and ($line =~ m/^\|/));    # Remove beginning pipe
        $line = "*".$line unless (($line =~ m/^[\|\* ]/) or ($line =~ m/.:\/\//));    # Add beginning asterisk
        $line = $line."*" unless ($line =~ m/[\|\* ]$/);    # Add ending asterisk
        $line =~ s/\|$// if ($line =~ m/\|$/);    # Convert filter endings

        push @urlfilter, $line;
      }
    }
  }


  return undef if (scalar(grep {$_ !~ m/^;/} @urlfilter) <= 0);    # Return undef if list is empty


  $list = join("\n", @urlfilter);
  undef @urlfilter;
  my $whitelists = join("\n", @whitelists);
  my $tmpline = "";
  my $matcheswhitelist;

  foreach my $line (split(/\n/, $list))
  {
    # Remove filters that require whitelists
    ($tmpline) = $line;

    $tmpline =~ s/^\*:\/\///;    # Remove protocol
    $tmpline =~ s/^\|\|//;    # Remove pipes
    $tmpline =~ s/\^$//;    # Remove ending caret
    $tmpline =~ s/\^/\//;    # Convert caret to slash
    $tmpline =~ s/\$.*//;    # Remove everything after a dollar sign
    $tmpline =~ s/^\*//;    # Remove beginning asterisk
    $tmpline =~ s/\*$//;    # Remove ending asterisk

    foreach my $inline (split(/\n/, $whitelists))
    {
      $matcheswhitelist = 1 if (($tmpline =~ m/\Q$inline\E/i) or ($inline =~ m/\Q$tmpline\E/i));
    }

    push @urlfilter, $line unless (defined $matcheswhitelist);
    undef $matcheswhitelist;
  }


  return undef if (scalar(grep {$_ !~ m/^;/} @urlfilter) <= 0);    # Return undef if list is empty


  # Add urlfilter header
  my $linenr = 0;
  foreach my $line (split(/\n/, $list))
  {
    last if ($line =~ m/^;[ ]*$/);
    $linenr++;
  }
  splice (@urlfilter, $linenr, 0, "[prefs]\nprioritize excludelist=1\n[include]\n*\n[exclude]");

  return join("\n", @urlfilter);
}


sub createElemfilter
{
  my $list = shift;
  my @elemfilter;

  my $oldchecksum;
  my $oldmodified;

  # Get old checksum and modification time
  if (-e "$path/element-filter.css")
  {
    my @oldlist = (split(/\n/, (readFile("$path/element-filter.css"))));
    $oldchecksum = firstval { $_ =~ m/Checksum:/i } @oldlist;
    $oldmodified = firstval { $_ =~ m/(Last modified|Updated):/i } @oldlist;
    undef @oldlist;
  }


  foreach my $line (split(/\n/, $list))
  {
    # Remove ABP header
    if ($line =~m/\[.*?\]/i)
    {
    }
    unless ($line =~ m/Redirect:/i)
    {
      if ($line =~ m/^!/)
      {
        # Insert old checksumm
        if ($line =~ m/Checksum:/i)
        {
          ($line) = $oldchecksum if defined $oldchecksum;
        }
        # Insert old last modified
        elsif ($line =~ m/(Last modified|Updated):/i)
        {
          ($line) = $oldmodified if defined $oldmodified;
        }
        push @elemfilter, $line;
      }
    }

    # Add generic element filters
    if ($line =~ m/^##/)
    {
      $line =~ s/##//;
      $line =~ s/(^.*[\[\.\#])/\L$1/ if ($line =~ m/^.*[\[\.\#]/);    # Convert tags to lowercase
      push @elemfilter, $line.",";
    }

  }


  return undef if (scalar(grep {$_ !~ m/^!/} @elemfilter) <= 0);    # Return undef if list is empty


  # Add xml namespace declaration
  my $linenr = 0;
  $list = join("\n", @elemfilter);
  foreach my $line (split(/\n/, $list))
  {
    last if ($line =~ m/^![ ]*$/);
    $linenr++;
  }
  splice (@elemfilter, $linenr, 0, "\@namespace \"http://www.w3.org/1999/xhtml\";");

  $elemfilter[lastidx{ ($_ =~ m/,$/) and ($_ !~ m/^!/) } @elemfilter] =~ s/,$//;    # Remove last comma

  push @elemfilter,"{ display: none !important; }";    # Add CSS rule


  # Convert comments
  my $previousline = "";

  $list = join("\n", @elemfilter);
  undef @elemfilter;

  foreach my $line (split(/\n/, $list))
  {
    push @elemfilter, "/*" if (($previousline !~ m/^!/) and ($line =~ m/^!/));
    push @elemfilter, "*/" if (($previousline =~ m/^!/) and ($line !~ m/^!/));
    push @elemfilter, $line;
    $previousline = $line;
  }
  undef $previousline;


  return join("\n", @elemfilter);
}


sub readFile
{
  my $file = shift;

  open(local *FILE, "<", $file) || die "Could not read file '$file'\n";
  binmode(FILE);
  local $/;
  my $result = <FILE>;
  close(FILE);

  return $result;
}

sub writeFile
{
  my ($file, $contents) = @_;

  open(local *FILE, ">", $file) || die "Could not write file '$file'\n";
  binmode(FILE);
  print FILE $contents;
  close(FILE);
}