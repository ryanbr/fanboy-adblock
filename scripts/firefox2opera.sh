#!/bin/bash
#
# Fanboy Adblock list Firefox-Opera bash script v2.0 (11/10/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Version history
#
# 3.0 Re-write script, cleaner and better, removed lots of cruft.

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
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export TWIDGE="/usr/bin/twidge update"
export IEDIR="/tmp/work/ie"
export IESUBS="/tmp/work/ie/subscriptions"
export IRONDIR="/tmp/Ramdisk/www/adblock/iron"
export PERL="/usr/bin/perl"

# Check mirror dir exists and its not a symlink
#
if [ -d "/var/hgstuff/fanboy-adblock-list" ] && [ -h "/tmp/hgstuff" ]; then
    export HGSERV="/var/hgstuff/fanboy-adblock-list"
    echo "HGSERV=/var/hgstuff/fanboy-adblock-list"
    cd /tmp/hgstuff/fanboy-adblock-list
    $NICE $HG pull
    $NICE $HG update
  else
    # If not, its stored here
    export HGSERV="/tmp/hgstuff/fanboy-adblock-list"
    echo "HGSERV=/tmp/hgstuff/fanboy-adblock-list"
    cd /tmp/hgstuff/fanboy-adblock-list
    $NICE $HG pull
    $NICE $HG update
fi

# Check that the www server is up before proceding
#
if [ -d "/tmp/Ramdisk/www/adblock" ]; then

  # Fanboy-Adblock
  #
  $NICE $PERL $HGSERV/scripts/createOperaFilters_new.pl --nocss $MAINDIR/fanboy-adblock.txt --urlfilter $MAINDIR/opera/urlfilter-adblock.bak --nocomments --everythingisfirstparty

  # Fanboy-Tracking
  #
  $NICE $PERL $HGSERV/scripts/createOperaFilters_new.pl --nocss $MAINDIR/fanboy-tracking.txt --urlfilter $MAINDIR/opera/urlfilter-tracking.bak --nocomments --everythingisfirstparty

  # Because Tracking list is merged with Adblock, remove the top 5 lines
  #
  sed -i -e '1,5d' $MAINDIR/opera/urlfilter-tracking.bak

  # Include Opera urlfilter header file
  #
  $CAT $HGSERV/opera/urlfilter-header.txt $MAINDIR/opera/urlfilter-adblock.bak > $MAINDIR/opera/urlfilter-adblock.bak2
  # Adblock+Tracking
  $CAT $HGSERV/opera/urlfilter-header.txt $MAINDIR/opera/urlfilter-adblock.bak $MAINDIR/opera/urlfilter-tracking.bak > $MAINDIR/opera/urlfilter-tracking.bak2

  # Remove empty lines
  #
  sed -i -e '/^$/d' $MAINDIR/opera/urlfilter-adblock.bak2
  sed -i -e '/^$/d' $MAINDIR/opera/urlfilter-tracking.bak2

  # Checksums
  #
  $PERL $HGSERV/scripts/addChecksum-opera.pl $MAINDIR/opera/urlfilter-adblock.bak2
  $PERL $HGSERV/scripts/addChecksum-opera.pl $MAINDIR/opera/urlfilter-tracking.bak2

  # GZIP
  #
  cp -f $MAINDIR/opera/urlfilter-adblock.bak2 $MAINDIR/opera/urlfilter.ini
  cp -f $MAINDIR/opera/urlfilter-tracking.bak2 $MAINDIR/opera/complete/urlfilter.ini

  # Clear old files first
  #
  rm -rf $MAINDIR/opera/urlfilter.ini.gz $MAINDIR/opera/complete/urlfilter.ini.gz

  $ZIP $MAINDIR/opera/urlfilter.ini.gz $MAINDIR/opera/urlfilter-adblock.bak2 > /dev/null
  $ZIP $MAINDIR/opera/complete/urlfilter.ini.gz $MAINDIR/opera/urlfilter-tracking.bak2 > /dev/null

  # Remove Backup files
  #
  rm -rf $MAINDIR/opera/urlfilter-tracking.bak* $MAINDIR/opera/urlfilter-adblock.bak*

fi


