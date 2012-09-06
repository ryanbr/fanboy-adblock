#!/bin/bash
#
# Fanboy Adblock list grabber Opera script v2.2 (06/09/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Version history
#
# 2.2  Fix bug where Opera uncompressed wasnt being copied over.
# 2.1  Re-implement the iron list generator
# 2.0  Re-write Opera code, and split off regional list
# 1.8  Allow list to be stored in ramdisk

# Variables for directorys
#
export ZIP="nice -n 19 /usr/local/bin/7za a -mx=9 -y -tgzip"
export NICE="nice -n 19"
export TAC="/usr/bin/tac"
export CAT="/bin/cat"
export MAINDIR="/tmp/Ramdisk/www/adblock"
export SPLITDIR="/tmp/Ramdisk/www/adblock/split/test"
export HGSERV="/tmp/hgstuff/fanboy-adblock-list"
export TESTDIR="/tmp/work"
export DATE="`date`"
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum-opera.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export IEDIR="/tmp/ieramdisk"
export TWIDGE="/usr/bin/twidge update"
export SUBS="/tmp/ieramdisk/subscriptions"
export IRONDIR="/tmp/Ramdisk/www/adblock/iron"

# Check mirror dir exists and its not a symlink
#
if [ -d "/var/hgstuff/fanboy-adblock-list" ] && [ -h "/tmp/hgstuff" ]; then
    export HGSERV="/var/hgstuff/fanboy-adblock-list"
  else
    # If not, its stored here
    export HGSERV="/tmp/hgstuff/fanboy-adblock-list"
fi

# Opera Standard Filter
if [ -n $HGSERV/opera/urlfilter.ini ]
then
  if diff $HGSERV/opera/urlfilter.ini $MAINDIR/opera/urlfilter.ini > /dev/null ; then
    # echo "No Changes detected: urlfilter.ini" > /dev/null
    echo "No Changes detected: urlfilter.ini (script: list-grabber-opera.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE
   else
    # echo "Updated: urlfilter.ini"
    cp -f $HGSERV/opera/urlfilter.ini $TESTDIR/opera/urlfilter.ini
    $ADDCHECKSUM $TESTDIR/opera/urlfilter.ini
    cp -f $TESTDIR/opera/urlfilter.ini $MAINDIR/opera/urlfilter.ini
    # Properly wipe old file.
    rm -rf $MAINDIR/opera/urlfilter.ini.gz
    $ZIP $MAINDIR/opera/urlfilter.ini.gz $TESTDIR/opera/urlfilter.ini > /dev/null
    # Generate Iron script
    # Turn off for the time being.
    $HGSERV/scripts/iron/adblock-iron-generator.sh

    cp -f $TESTDIR/opera/urfilter-stats2.ini $MAINDIR/opera/complete/urlfilter.ini
    # Properly wipe old file.
    rm -rf $MAINDIR/opera/complete/urlfilter.ini.gz
    $ZIP $MAINDIR/opera/complete/urlfilter.ini.gz $TESTDIR/opera/urfilter-stats.ini > /dev/null
    # Generate Iron script
    $HGSERV/scripts/iron/adblock-iron-generator-tracker.sh
    # Regional Opera
    $HGSERV/scripts/list-grabber-opera-regional.sh
  fi
else
# echo "Something went bad, file size is 0"
  echo "urlfilter.ini/urlfilter-stats size is zero, please fix." >> $LOGFILE
fi

# Opera Tracking Filter
if [ -n $HGSERV/opera/urlfilter-stats.ini ]
then
  if diff $HGSERV/opera/urlfilter-stats.ini $MAINDIR/opera/urlfilter-stats.ini > /dev/null ; then
    # echo "No Changes detected: urlfilter-stats.ini" > /dev/null
    echo "No Changes detected: urlfilter-stats.ini (script: list-grabber-opera.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE
   else
    echo "Updated: complete/urlfilter.ini"
    # echo "Updated: urlfilter.ini"
    cp -f $HGSERV/opera/urlfilter-stats.ini $TESTDIR/opera/urlfilter-stats.ini
    # Keep a copy of stats also (used for comparison)
    cp -f $HGSERV/opera/urlfilter-stats.ini $MAINDIR/opera/urlfilter-stats.ini
    # Combine tracking filter
    sed '/^$/d' $HGSERV/opera/urlfilter-stats.ini > $TESTDIR/opera/urlfilter-stats.ini
    cat $MAINDIR/opera/urlfilter.ini $TESTDIR/opera/urlfilter-stats.ini > $TESTDIR/opera/urfilter-stats2.ini
    $ADDCHECKSUM $TESTDIR/opera/urfilter-stats2.ini
    #
    cp -f $TESTDIR/opera/urfilter-stats2.ini $MAINDIR/opera/complete/urlfilter.ini
    # Properly wipe old file.
    rm -rf $MAINDIR/opera/complete/urlfilter.ini.gz
    $ZIP $MAINDIR/opera/complete/urlfilter.ini.gz $TESTDIR/opera/urfilter-stats2.ini > /dev/null
    # Generate Iron script
    $HGSERV/scripts/iron/adblock-iron-generator-tracker.sh
    # Regional Opera
    $HGSERV/scripts/list-grabber-opera-regional.sh
  fi
else
# echo "Something went bad, file size is 0"
  echo "urlfilter.ini/urlfilter-stats size is zero, please fix." >> $LOGFILE
fi



