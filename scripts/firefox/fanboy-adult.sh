#!/bin/bash
#
# Fanboy Adult Adblock list grabber script v2.0 (29/08/2011)
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
export MAINDIR="/tmp/Ramdisk/www/adblock"
export SPLITDIR="/tmp/Ramdisk/www/adblock/split/test"
export HGSERV="/tmp/hgstuff/fanboy-adblock-list"
export TESTDIR="/tmp/work"
export DATE="`date`"
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export IEDIR="/tmp/ieramdisk"
export TWIDGE="/usr/bin/twidge update"
export SUBS="/tmp/ieramdisk/subscriptions"
export IRONDIR="/tmp/Ramdisk/www/adblock/iron"


# Cat the Adult list together
#
rm -rf $TESTDIR/fanboy-adult-test.txt
cat  $HGSERV/fanboy-adblock/fanboy-header.txt \
     $HGSERV/fanboy-adblock/fanboy-adult-generic.txt \
     $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
     $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt \
     $HGSERV/fanboy-adblock/fanboy-adult-elements.txt \
     $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt > $TESTDIR/fanboy-adult-test.txt

# Make sure the file exists
#
if [ -s "$TESTDIR/fanboy-adult-test.txt" ]; then
     # Remove empty lines
     #
     sed '/^$/d' $TESTDIR/fanboy-adult-test.txt > $TESTDIR/fanboy-adult-test2.txt
     mv -f $TESTDIR/fanboy-adult-test2.txt $TESTDIR/fanboy-adult-test.txt

     # Checksum the file
     #
     $ADDCHECKSUM $TESTDIR/fanboy-adult-test.txt

     # Remove empty lines
     #
     SSLHG=$($SHA256SUM $TESTDIR/fanboy-adult-test.txt | cut -d' ' -f1)
     SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-adult.txt | cut -d' ' -f1)

     if [ "$SSLHG" != "$SSLMAIN" ]
       then
          # Create our measure of changes
          cp -f $TESTDIR/fanboy-adult-test.txt $MAINDIR/split/fanboy-adult.txt
          # Title: Fanboy Adult List
          sed -i 's/Adblock\ List/Adult\ List/g' $TESTDIR/fanboy-adult-test.txt
          # Re-do Checksum
          $ADDCHECKSUM $TESTDIR/fanboy-adult-test.txt
          # Copy over files to webserver now
          cp -f $TESTDIR/fanboy-adult-test.txt $MAINDIR/fanboy-adult.txt
          rm -rf $MAINDIR/fanboy-adult.txt.gz
          # Gzip the file
          $ZIP $MAINDIR/fanboy-adult.txt.gz $TESTDIR/fanboy-adult-test.txt
       else
          # File check differences before replacing
          echo "Files are the same: fanboy-adult.txt" > /dev/null
     fi

else
    # If the Cat fails.
    echo "Error creating file fanboy-adult-test.txt: fanboy-adult - $DATE" >> $LOGFILE
fi







