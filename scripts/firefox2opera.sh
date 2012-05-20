#!/bin/bash
#
# Fanboy Adblock list Firefox-Opera bash script v1.00 (20/05/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Variables for directorys
#
MAINDIR="/var/www/adblock"
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list"
OPERATEST="/var/www/adblock/opera-test"
TESTDIR="/tmp/ramdisk"
ZIP="nice -n 19 /usr/local/bin/7za"
NICE="nice -n 19"
DATE="`date`"


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

# Our Opera test Dirstuff
#
mkdir /tmp/ramdisk/opera/test; chmod 777 /tmp/ramdisk/opera/test
rm -rf $TESTDIR/opera/test/*

# Fanboy-Adblock.text
# 
cp -f $MAINDIR/fanboy-adblock.txt $TESTDIR/opera/test
$NICE perl $GOOGLEDIR/scripts/createOperaFilters_new.pl $TESTDIR/opera/test/fanboy-adblock.txt --nocss

cp -f $TESTDIR/opera/test/urlfilter.ini $OPERATEST/urlfilter.ini2
mv $OPERATEST/urlfilter.ini2 $OPERATEST/urlfilter.ini
$ZIP a -mx=9 -y -tgzip $OPERATEST/urlfilter.ini.gz $OPERATEST/urlfilter.ini2 > /dev/null
rm -rf $TESTDIR/opera/test/*

# Fanboy-Adblock+Tracking
#
cp -f $MAINDIR/r/fanboy+tracking.txt $TESTDIR/opera/test
$NICE perl $GOOGLEDIR/scripts/createOperaFilters_new.pl $TESTDIR/opera/test/fanboy+tracking.txt --nocss

cp -f $TESTDIR/opera/test/urlfilter.ini $OPERATEST/tracking/urlfilter.ini2
mv $OPERATEST/tracking/urlfilter.ini2 $OPERATEST/tracking/urlfilter.ini
$ZIP a -mx=9 -y -tgzip $OPERATEST/tracking/urlfilter.ini.gz $OPERATEST/tracking/urlfilter.ini2 > /dev/null
rm -rf $TESTDIR/opera/test/*

# Fanboy-Adblock+Tracking+Annoyances (Complete)
#
cp -f $MAINDIR/r/fanboy-complete.txt $TESTDIR/opera/test
$NICE perl $GOOGLEDIR/scripts/createOperaFilters_new.pl $TESTDIR/opera/test/fanboy-complete.txt --nocss

cp -f $TESTDIR/opera/test/urlfilter.ini $OPERATEST/complete/urlfilter.ini2
mv $OPERATEST/complete/urlfilter.ini2 $OPERATEST/complete/urlfilter.ini
$ZIP a -mx=9 -y -tgzip $OPERATEST/complete/urlfilter.ini.gz $OPERATEST/complete/urlfilter.ini2 > /dev/null
rm -rf $TESTDIR/opera/test/*

# Fanboy-Adblock+Tracking+Annoyances+Enhanced (Ultimate)
#
cp -f $MAINDIR/r/fanboy-ultimate.txt $TESTDIR/opera/test
$NICE perl $GOOGLEDIR/scripts/createOperaFilters_new.pl $TESTDIR/opera/test/fanboy-ultimate.txt --nocss

cp -f $TESTDIR/opera/test/urlfilter.ini $OPERATEST/ultimate/urlfilter.ini2
mv $OPERATEST/ultimate/urlfilter.ini2 $OPERATEST/ultimate/urlfilter.ini
$ZIP a -mx=9 -y -tgzip $OPERATEST/ultimate/urlfilter.ini.gz $OPERATEST/ultimate/urlfilter.ini2 > /dev/null
rm -rf $TESTDIR/opera/test/*
