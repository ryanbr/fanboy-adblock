#!/bin/bash
#
# Fanboy Adblock list Firefox-Opera bash script v2.0 (19/08/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Version history
#
# 2.0 Re-write script, cleaner and better, removed lots of cruft.

# Variables for directorys
#
MAINDIR="/tmp/Ramdisk/www"
MAINDIROPERA="/tmp/Ramdisk/www/opera/test/"

GOOGLEDIR="/tmp/hgstuff/fanboy-adblock-list"
OPERATEST="/tmp/ramdisk/opera/test/"
TESTDIR="/tmp/work"

ZIP="nice -n 19 /usr/local/bin/7za"
NICE="nice -n 19"
DATE="`date`"
PERL="nice -n 19 /usr/bin/perl"


# Make Ramdisk.
#
$GOOGLEDIR/scripts/ramdisk.sh

if [ ! -d "/tmp/work/" ]; then
  rm -rf /tmp/work/
  mkdir /tmp/work; chmod 777 /tmp/work
  mount -t tmpfs -o size=30M tmpfs /tmp/work/
  cp -f $MAINDIR/addChecksum.pl $TESTDIR
  cp -f $GOOGLEDIR/scripts/createOperaFilters_new.pl $TESTDIR
  cp -f $GOOGLEDIR/scripts/addChecksum-opera.pl $TESTDIR
  mkdir /tmp/work/opera; chmod 777 /tmp/work/opera
  mkdir /tmp/work/opera/test; chmod 777 /tmp/work/opera/test
fi

# Our Opera test Dirstuff (Temp DIR)
#
if [ ! -d "/tmp/work/opera/test" ]; then
  mkdir /tmp/work/opera/test; chmod 777 /tmp/work/opera/test
fi

if [ ! -d "$TESTDIR/createOperaFilters_new.pl" ]; then
   cp -f $GOOGLEDIR/scripts/createOperaFilters_new.pl $TESTDIR
fi

if [ ! -d "$TESTDIR/addChecksum-opera.pl" ]; then
   cp -f $GOOGLEDIR/scripts/addChecksum-opera.pl $TESTDIR
fi

# Check that the www server is up before proceding
#
if [ ! -d "/tmp/Ramdisk/www/opera/test/" ]; then

  # Fanboy-Adblock
  #
  $PERL $TESTDIR/createOperaFilters_new.pl --nocss $MAINDIR/fanboy-adblock.txt --urlfilter $OPERATEST/fanboy-adblock.ini
  $PERL $TESTDIR/addChecksum-opera.pl $OPERATEST/fanboy-adblock.ini
  cp -f $OPERATEST/fanboy-adblock.ini $OPERATEST/fanboy-adblock.ini2
  $ZIP a -mx=9 -y -tgzip $OPERATEST/fanboy-adblock.ini.gz $OPERATEST/fanboy-adblock.ini2 > /dev/null

  # Fanboy-Tracking (merged)
  #
  $PERL $TESTDIR/createOperaFilters_new.pl --nocss $MAINDIR/adblock/r/fanboy+tracking.txt --urlfilter $OPERATEST/fanboy-tracking.ini
  $PERL $TESTDIR/addChecksum-opera.pl $OPERATEST/fanboy-tracking.ini
  cp -f $OPERATEST/fanboy-tracking.ini $OPERATEST/fanboy-tracking.ini2
  $ZIP a -mx=9 -y -tgzip $OPERATEST/fanboy-tracking.ini.gz $OPERATEST/fanboy-tracking.ini2 > /dev/null

  # Fanboy-Complete
  #
  $PERL $TESTDIR/createOperaFilters_new.pl --nocss $MAINDIR/adblock/r/fanboy-complete.txt --urlfilter $OPERATEST/fanboy-complete.ini
  $PERL $TESTDIR/addChecksum-opera.pl $OPERATEST/fanboy-complete.ini
  cp -f $OPERATEST/fanboy-complete.ini $OPERATEST/fanboy-complete.ini2
  $ZIP a -mx=9 -y -tgzip $OPERATEST/fanboy-complete.ini.gz $OPERATEST/fanboy-complete.ini2 > /dev/null

  # Fanboy-Ultimate
  #
  $PERL $TESTDIR/createOperaFilters_new.pl --nocss $MAINDIR/adblock/r/fanboy-ultimate.txt --urlfilter $OPERATEST/fanboy-ultimate.ini
  $PERL $TESTDIR/addChecksum-opera.pl $OPERATEST/fanboy-ultimate.ini
  cp -f $OPERATEST/fanboy-ultimate.ini $OPERATEST/fanboy-ultimate.ini2
  $ZIP a -mx=9 -y -tgzip $OPERATEST/fanboy-ultimate.ini.gz $OPERATEST/fanboy-ultimate.ini2 > /dev/null

  # Copy over files to webserver
  #
  cp -rf $OPERATEST/* $MAINDIROPERA

  # Remove any dead files afterwards
  #
  if [ ! -d "$OPERATEST" ]; then
     rm -rf $OPERATEST/*
  fi

fi


