#!/bin/bash
#
# Fanboy Tracking IE Convert script v1.4 (29/08/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Version history
#
# 1.50 Re-write script to be cleaner and more readable, better error checking.
#
# Variables

export ZIP="nice -n 19 /usr/local/bin/7za a -mx=9 -y -tgzip"
export NICE="nice -n 19"
export TAC="/usr/bin/tac"
export CAT="/bin/cat"
export MAINDIR="/tmp/Ramdisk/www/adblock"
export SPLITDIR="/tmp/Ramdisk/www/adblock/split/test"
export HGSERV="/tmp/hgstuff/fanboy-adblock-list"
export TESTDIR="/tmp/work"
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export IEDIR="/tmp/work/ie"
export IESUBS="/tmp/work/ie/subscriptions"
export IRONDIR="/tmp/Ramdisk/www/adblock/iron"

# Check for temp ie stuff
#
if [ ! -d "$IEDIR" ]; then
    rm -rf $IEDIR
    mkdir $IEDIR; chmod 777 $IEDIR
    mkdir $IESUBS; chmod 777 $IESUBS
fi

# To be used for mirrors
#
if [ -d "/var/hgstuff/fanboy-adblock-list" ]; then
  export HGSERV="/var/hgstuff/fanboy-adblock-list"
fi

if [ ! -s "$IEDIR/combineSubscriptions.py" ]; then
    cp -f $HGSERV/scripts/ie/combineSubscriptions.py $IEDIR
fi

# Clear out any old files lurking
#

if [ -d "$IESUBS" ]; then
    rm -rf $IESUBS/*
fi

if [ -d "$IEDIR" ]; then
    rm -rf $IEDIR/*.txt
fi

# Check we have a generated non-element file before processing.
#
if [ -s "$TESTDIR/fanboy-tracking-merged.txt" ]; then
      # Cleanup fanboy-tracking-addon.txt (remove the top 8 lines)
      #
      sed '1,8d' $HGSERV/ie/fanboy-tracking-addon.txt > $MAINDIR/split/fanboy-tracking-addon.txt

      # Standard Adblock Filter
      cat $TESTDIR/fanboy-tracking-merged.txt \
          $MAINDIR/split/fanboy-tracking-addon.txt > $IEDIR/fanboy-tracking.txt
      # IE Ultimate
      cat $TESTDIR/fanboy-non-element.txt \
          $TESTDIR/fanboy-adblock-ie-addon.txt \
          $MAINDIR/fanboy-tracking.txt \
          $MAINDIR/split/fanboy-tracking-addon.txt \
          $MAINDIR/fanboy-addon.txt \
          $MAINDIR/enhancedstats.txt > $IEDIR/fanboy-ultimate-ie.txt
      # IE Complete
      cat $TESTDIR/fanboy-non-element.txt \
          $TESTDIR/fanboy-adblock-ie-addon.txt \
          $MAINDIR/fanboy-tracking.txt \
          $MAINDIR/split/fanboy-tracking-addon.txt \
          $MAINDIR/enhancedstats.txt > $IEDIR/fanboy-complete-ie.txt

      # Remove ~third-party
      #
      sed -i '/~third-party/d' $IEDIR/fanboy-tracking.txt $IEDIR/fanboy-ultimate-ie.txt $IEDIR/fanboy-complete-ie.txt

      # Generate .tpl IE list
      #
      python $IEDIR/combineSubscriptions.py $IEDIR $IESUBS

      # Remove Generated gzip filters, we dont need these yet
      #
      rm -f $IESUBS/fanboy-tracking.txt*.gz
      rm -f $IESUBS/fanboy-ultimate-*.gz
      rm -f $IESUBS/fanboy-complete-*.gz

      # Cleanup Script (removed filters not compatible with IE)
      #
      $HGSERV/scripts/ie/ie-cleanup-filters.sh

      # Re-compress newly modified file
      #
      $ZIP $IESUBS/fanboy-ultimate-ie.tpl.gz $IESUBS/fanboy-ultimate-ie.tpl &> /dev/null
      $ZIP $IESUBS/fanboy-complete-ie.tpl.gz $IESUBS/fanboy-complete-ie.tpl &> /dev/null
      $ZIP $IESUBS/fanboy-tracking.tpl.gz $IESUBS/fanboy-tracking.tpl &> /dev/null

      # Now copy finished tpl list to the website.
      #
      cp -f $IESUBS/fanboy-tracking.tpl* $IESUBS/fanboy-ultimate-ie.tpl* $IESUBS/fanboy-complete-ie.tpl* $MAINDIR/ie/

      # If we cannot locate fanboy-non-element.txt, spit out an error:
      #
      else
         echo "Unable to locate fanboy-tracking-merged.txt: TESTDIR/fanboy-tracking-merged.txt - $DATE" >> $LOGFILE
fi