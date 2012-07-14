#!/bin/bash
#
# Fanboy Adblock list Firefox-Opera bash script v1.01 (21/05/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Variables for directorys
#
MAINDIR="/var/www/adblock"
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list"
OPERATEST="/var/www/adblock/opera/test"
TESTDIR="/tmp/ramdisk"
ZIP="nice -n 19 /usr/local/bin/7za"
NICE="nice -n 19"
DATE="`date`"
PERL="nice -n 19 /usr/bin/perl"


# Make Ramdisk.
#
$GOOGLEDIR/scripts/ramdisk.sh
# Fallback if ramdisk.sh isn't excuted.
#
if [ ! -d "/tmp/ramdisk/" ]; then
  rm -rf /tmp/ramdisk/
  mkdir /tmp/ramdisk; chmod 777 /tmp/ramdisk
  mount -t tmpfs -o size=30M tmpfs /tmp/ramdisk/
  mkdir /tmp/ramdisk/opera; chmod 777 /tmp/ramdisk/opera
  mkdir /tmp/ramdisk/opera/test; chmod 777 /tmp/ramdisk/opera/test
fi

# Our Opera test Dirstuff (Temp DIR)
#
if [ ! -d "/tmp/ramdisk/opera/test/" ]; then
  mkdir /tmp/ramdisk/opera/test; chmod 777 /tmp/ramdisk/opera/test
  rm -rf $TESTDIR/opera/test/*
fi

# Docs
# Take a copy of the files, move to Ramdisk, convert from Firefox to Opera, copy file over and compress
#

# Fanboy-Adblock.text
# 
cp -f $MAINDIR/fanboy-adblock.txt $TESTDIR/opera/test
$PERL $GOOGLEDIR/scripts/createOperaFilters_new.pl $TESTDIR/opera/test/fanboy-adblock.txt --nocss >/dev/null

cp -f $TESTDIR/opera/test/urlfilter.ini $TESTDIR/opera/test/urlfilter.ini2
$ZIP a -mx=9 -y -tgzip $TESTDIR/opera/test/urlfilter.ini.gz $TESTDIR/opera/test/urlfilter.ini2 > /dev/null
cp -f $TESTDIR/opera/test/urlfilter.ini.gz $TESTDIR/opera/test/urlfilter.ini $OPERATEST
# Remove any dead file
rm -rf $TESTDIR/opera/test/*

# Fanboy-Adblock+Tracking
#
cp -f $MAINDIR/r/fanboy+tracking.txt $TESTDIR/opera/test
$PERL $GOOGLEDIR/scripts/createOperaFilters_new.pl $TESTDIR/opera/test/fanboy+tracking.txt --nocss >/dev/null

cp -f $TESTDIR/opera/test/urlfilter.ini $TESTDIR/opera/test/urlfilter.ini2
$ZIP a -mx=9 -y -tgzip $TESTDIR/opera/test/urlfilter.ini.gz $TESTDIR/opera/test/urlfilter.ini2 > /dev/null
cp -f $TESTDIR/opera/test/urlfilter.ini.gz $TESTDIR/opera/test/urlfilter.ini $OPERATEST/tracking
# Remove any dead files
rm -rf $TESTDIR/opera/test/*

# Fanboy-Adblock+Tracking+Annoyances (Complete)
#
cp -f $MAINDIR/r/fanboy-complete.txt $TESTDIR/opera/test
$PERL $GOOGLEDIR/scripts/createOperaFilters_new.pl $TESTDIR/opera/test/fanboy-complete.txt --nocss >/dev/null

cp -f $TESTDIR/opera/test/urlfilter.ini $TESTDIR/opera/test/urlfilter.ini2
$ZIP a -mx=9 -y -tgzip $TESTDIR/opera/test/urlfilter.ini.gz $TESTDIR/opera/test/urlfilter.ini2 > /dev/null
cp -f $TESTDIR/opera/test/urlfilter.ini.gz $TESTDIR/opera/test/urlfilter.ini $OPERATEST/complete
# Remove any dead files
rm -rf $TESTDIR/opera/test/*

# Fanboy-Adblock+Tracking+Annoyances+Enhanced (Ultimate)
#
cp -f $MAINDIR/r/fanboy-ultimate.txt $TESTDIR/opera/test
$PERL $GOOGLEDIR/scripts/createOperaFilters_new.pl $TESTDIR/opera/test/fanboy-ultimate.txt --nocss >/dev/null

cp -f $TESTDIR/opera/test/urlfilter.ini $TESTDIR/opera/test/urlfilter.ini2
$ZIP a -mx=9 -y -tgzip $TESTDIR/opera/test/urlfilter.ini.gz $TESTDIR/opera/test/urlfilter.ini2 > /dev/null
cp -f $TESTDIR/opera/test/urlfilter.ini.gz $TESTDIR/opera/test/urlfilter.ini $OPERATEST/ultimate
# Remove any dead files
rm -rf $TESTDIR/opera/test/*
