#!/bin/bash
#
# Fanboy Non-element Adblock list grabber script v2.1 (29/08/2011)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#

# Version history
#
# 2.00 Re-write script to be cleaner and more readable, better error checking.

export ZIP="nice -n 19 /usr/local/bin/7za a -mx=9 -y -tgzip"
export NICE="nice -n 19"
export TAC="/usr/bin/tac"
export CAT="/bin/cat"
export MAINDIR="/var/www/adblock"
export SPLITDIR="/var/www/adblock/split/test"
export HGSERV="/root/fanboy-adblock-list"
export TESTDIR="/root/tmp/work"
export DATE="`date`"
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export IEDIR="/root/tmp/ieramdisk"
export TWIDGE="/usr/bin/twidge update"
export SUBS="/root/tmp/ieramdisk/subscriptions"
export IRONDIR="/root/tmp/Ramdisk/www/adblock/iron"

# Cat the No-element list together
#
rm -rf $TESTDIR/fanboy-non-element.txt
$CAT $HGSERV/fanboy-adblock/fanboy-header.txt \
     $HGSERV/fanboy-adblock/fanboy-generic.txt \
     $HGSERV/fanboy-adblock/fanboy-thirdparty.txt \
     $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
     $HGSERV/fanboy-adblock/fanboy-popups.txt \
     $HGSERV/fanboy-adblock/fanboy-whitelist.txt \
     $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
     $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt \
     $HGSERV/fanboy-adblock/fanboy-adult-generic.txt \
     $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
     $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt \
     $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
     $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt \
     $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt > $TESTDIR/fanboy-non-element.txt

# Make sure the file exists
#
if [ -s "$TESTDIR/fanboy-non-element.txt" ]; then

          # Remove empty lines
          #
          sed '/^$/d' $TESTDIR/fanboy-non-element.txt > $TESTDIR/fanboy-non-element2.txt
          mv -f $TESTDIR/fanboy-non-element2.txt $TESTDIR/fanboy-non-element.txt

          # Title: Fanboy Adblock-Nonelements List
          #
          sed -i 's/Adblock\ List/Adblock-Nonelements\ List/g' $TESTDIR/fanboy-non-element.txt

          # Re-do Checksum
          #
          $ADDCHECKSUM $TESTDIR/fanboy-non-element.txt

          # Copy over files to webserver now
          #
          cp -f $TESTDIR/fanboy-non-element.txt $MAINDIR/fanboy-adblock-noele.txt
          rm -rf $MAINDIR/fanboy-adblock-noele.txt.gz

          # Gzip the file
          #
          $ZIP $MAINDIR/fanboy-adblock-noele.txt.gz $TESTDIR/fanboy-non-element.txt &> /dev/null

          # Generate IE list (Generates Adblock, Complete and Ultimate)
          #
          $NICE $HGSERV/scripts/ie/adblock-ie-generator.sh
    else
          # If the Cat fails.
          #
          echo "Error creating file fanboy-non-element.txt: fanboy-nonele - $DATE" >> $LOGFILE
fi