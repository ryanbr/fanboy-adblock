#!/bin/bash
#
# Fanboy Adblock list grabber script v1.8 (15/08/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Version history
#
# 2.00 Re-write the script to support split files
# 1.82 Better checking of scripts being loaded
# 1.81 Misc Cleanups
# 1.8  Allow list to be stored in ramdisk
# 1.752 Declare global variables
# 1.751 Remove Shred, and cleanup variable names
# 1.75 Store log in ramdisk to avoid unnessary writes (Currently disabled)
# 1.74 Store repo in ramdisk to avoid unnessary writes (Currently disabled)
#
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
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export IEDIR="/tmp/ieramdisk"
export SUBS="/tmp/ieramdisk/subscriptions"
export IRONDIR="/tmp/Ramdisk/www/adblock/iron"

# Test for Ram disks
#
if [ ! -d "/tmp/work/" ]; then
  rm -rf /tmp/work/
  mkdir /tmp/work; chmod 777 /tmp/work
  mount -t tmpfs -o size=50M tmpfs /tmp/work/
fi

if [ ! -d "/tmp/work/opera" ]; then
  mkdir /tmp/work/opera; chmod 777 /tmp/work/opera
  mkdir /tmp/work/opera/test; chmod 777 /tmp/work/opera/test
fi

if [ ! -d "/tmp/work/opera/test" ]; then
  mkdir /tmp/work/opera/test; chmod 777 /tmp/work/opera/test
fi

if [ ! -d "/tmp/ieramdisk/subscriptions" ]; then
  rm -rf /tmp/ieramdisk/subscriptions
  mkdir /tmp/ieramdisk; chmod 777 /tmp/ieramdisk
  mount -t tmpfs -o size=30M tmpfs /tmp/ieramdisk
  mkdir /tmp/ieramdisk/subscriptions; chmod 777 /tmp/ieramdisk/subscriptions
fi

if [ ! -d "/tmp/Ramdisk/www/adblock/split" ]; then
  mkdir /tmp/Ramdisk/www/adblock/split; chmod 777 /tmp/Ramdisk/www/adblock/split
fi


# Fanboy-Adblock (fanboy-generic.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-generic.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-generic.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-generic.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        echo "" >> $HGSERV/fanboy-adblock/fanboy-header.txt

       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-elements-specific.txt > $TESTDIR/fanboy-merged.txt

        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-generic.txt $MAINDIR/split/fanboy-generic.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/split/fanboy-adblock.txt
        rm -rf $MAINDIR/split/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/split/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-generic.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-generic failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-thirdparty.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-thirdparty.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-thirdparty.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-thirdparty.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt
        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $MAINDIR/split/fanboy-thirdparty.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-thirdparty.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-thirdparty failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-thirdparty.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-firstparty.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-firstparty.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-firstparty.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-firstparty.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt
        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-firstparty.txt $MAINDIR/split/fanboy-firstparty.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-firstparty.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-firstparty.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-firstparty.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-popups.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-popups.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-popups.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-popups.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt
        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-popups.txt $MAINDIR/split/fanboy-popups.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-popups.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-popups.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-popups.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-whitelist.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-whitelist.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-whitelist.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-whitelist.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt
        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-whitelist.txt $MAINDIR/split/fanboy-whitelist.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-whitelist.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-whitelist.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-whitelist.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-dimensions.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-dimensions.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-dimensions.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-dimensions.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt
        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-dimensions.txt $MAINDIR/split/fanboy-dimensions.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-dimensions.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-dimensions.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-dimensions.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-dimensions-whitelist.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-dimensions-whitelist.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt

        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $MAINDIR/split/fanboy-dimensions-whitelist.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-dimensions-whitelist.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-dimensions-whitelist.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-dimensions-whitelist.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-adult-generic.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-adult-generic.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-adult-generic.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-adult-generic.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt

        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $MAINDIR/split/fanboy-adult-generic.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-adult-generic.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-adult-generic.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-adult-generic.txt failed to update: $DATE"
fi


# Fanboy-Adblock (fanboy-adult-firstparty.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-adult-firstparty.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt

        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt $MAINDIR/split/fanboy-adult-firstparty.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-adult-firstparty.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-adult-firstparty.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-adult-firstparty.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-adult-firstparty.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-adult-firstparty.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt

        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt $MAINDIR/split/fanboy-adult-firstparty.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-adult-firstparty.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-adult-firstparty.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-adult-firstparty.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-adult-thirdparty.tx)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-adult-thirdparty.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt

        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $MAINDIR/split/fanboy-adult-thirdparty.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-adult-firstparty.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-adult-firstparty.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-adult-firstparty.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-adult-thirdparty.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-adult-thirdparty.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt

        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $MAINDIR/split/fanboy-adult-thirdparty.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-adult-thirdparty.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-adult-thirdparty.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-adult-thirdparty.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-adult-elements.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-adult-elements.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-adult-elements.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-adult-elements.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt

        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $MAINDIR/split/fanboy-adult-elements.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        # $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-adult-elements.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-adult-elements.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-adult-elements.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-adult-whitelists.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-adult-whitelists.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt

        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt $MAINDIR/split/fanboy-adult-whitelists.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-adult-whitelists.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-adult-whitelists.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-adult-whitelists.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-p2p-firstparty.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-p2p-firstparty.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt

        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $MAINDIR/split/fanboy-p2p-firstparty.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-p2p-firstparty.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-p2p-firstparty.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-p2p-firstparty.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-p2p-thirdparty.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-p2p-thirdparty.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt

        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $MAINDIR/split/fanboy-p2p-thirdparty.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-p2p-thirdparty.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-p2p-thirdparty.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-p2p-thirdparty.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-p2p-elements.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-p2p-elements.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-p2p-elements.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt

        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt $MAINDIR/split/fanboy-p2p-elements.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-p2p-elements.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-p2p-elements.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-p2p-elements.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-p2p-elements.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-p2p-elements.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-p2p-elements.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt

        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt $MAINDIR/split/fanboy-p2p-elements.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-p2p-elements.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-p2p-elements.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-p2p-elements.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-elements-generic.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-elements-generic.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-elements-generic.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-elements-generic.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-specific-elements.txt > $TESTDIR/fanboy-merged.txt

        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $MAINDIR/split/fanboy-elements-generic.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-elements-generic.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-elements-generic.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-elements-generic.txt failed to update: $DATE"
fi

# Fanboy-Adblock (fanboy-specific-elements.txt)
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-specific-elements.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-specific-elements.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-specific-elements.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
       $CAT $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-popups.txt $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-elements.txt \
        $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $HGSERV/fanboy-adblock/fanboy-elements-specific.txt > $TESTDIR/fanboy-merged.txt

        # Copy over
        #
        cp -f $HGSERV/fanboy-adblock/fanboy-elements-specific.txt $MAINDIR/split/fanboy-elements-specific.txt

        # Checksum
        #
        $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

        # Compress
        #
        cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-adblock.txt
        rm -rf $MAINDIR/fanboy-adblock.txt.gz
        # $ZIP $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

        # Fanboy Ultimate + Complete
        #
        # $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

     else
        echo "Files are the same: fanboy-elements-specific.txt" > /dev/null
   fi
 else
  # Notify!
  #
  echo "fanboy-elements-specific.txt failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-elements-specific.txt failed to update: $DATE"
fi

############### Fanboy Tracking #################
SSLHG=$($SHA256SUM $HGSERV/fanboy-adblocklist-stats.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-tracking.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
 then
    # Copy list
    cp -f $HGSERV/fanboy-adblocklist-stats.txt $MAINDIR/fanboy-tracking.txt
    # Re-generate checksum
    $ADDCHECKSUM $MAINDIR/fanboy-tracking.txt
    rm -rf $MAINDIR/fanboy-tracking.txt.gz
    # ZIP
    $ZIP $MAINDIR/fanboy-tracking.txt.gz $HGSERV/fanboy-adblocklist-stats.txt > /dev/null
    # Now combine with international list
    # sh /etc/crons/hg-grab-intl.sh
    # Generate IE script
    $HGSERV/scripts/ie/tracking-ie-generator.sh
    # Combine
    $HGSERV/scripts/combine/firefox-adblock-tracking.sh
    $HGSERV/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $HGSERV/scripts/combine/firefox-adblock-ultimate.sh
    # Firefox2Opera
    # $NICE $HGSERV/scripts/firefox2opera.sh
else
   echo "Files are the same: fanboy-tracking.txt" > /dev/null
fi

############### Fanboy Enhanced Trackers #################
SSLHG=$($SHA256SUM $HGSERV/enhancedstats-addon.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/enhancedstats.txt-org | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    # Copy list
    cp -f $HGSERV/enhancedstats-addon.txt $MAINDIR/enhancedstats.txt
    # Re-generate checksum
    $ADDCHECKSUM $MAINDIR/enhancedstats.txt
    rm -rf $MAINDIR/enhancedstats.txt.gz
    # GZip
    $ZIP $MAINDIR/enhancedstats.txt.gz $HGSERV/enhancedstats-addon.txt > /dev/null
    # Combine Regional trackers
    $HGSERV/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $HGSERV/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $HGSERV/scripts/combine/firefox-adblock-ultimate.sh
    # Firefox2Opera
    # $NICE $HGSERV/scripts/firefox2opera.sh
else
   echo "Files are the same: enhancedstats.txt" > /dev/null
fi

############### Fanboy Addon/Annoyances #################
SSLHG=$($SHA256SUM $HGSERV/fanboy-adblocklist-addon.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-addon.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    # Copy list from repo to RAMDISK
    cp -f $HGSERV/fanboy-adblocklist-addon.txt $TESTDIR/fanboy-addon.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/fanboy-addon.txt
    cp -f $TESTDIR/fanboy-addon.txt $MAINDIR/fanboy-addon.txt
    # Remove old copy, then gzip it
    rm -rf $MAINDIR/fanboy-addon.txt.gz
    $ZIP $MAINDIR/fanboy-addon.txt.gz $TESTDIR/fanboy-addon.txtt > /dev/null
    # Combine
    $HGSERV/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $HGSERV/scripts/combine/firefox-adblock-ultimate.sh
    # Firefox2Opera
    # $NICE $HGSYNC/scripts/firefox2opera.sh
else
   echo "Files are the same: fanboy-addon.txt" > /dev/null
fi

############### Fanboy CZECH #################
SSLHG=$($SHA256SUM $HGSERV/firefox-regional/fanboy-adblocklist-cz.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-czech.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
   cp -f $HGSERV/firefox-regional/fanboy-adblocklist-cz.txt $TESTDIR/fanboy-czech.txt
   # Re-generate checksum
   $ADDCHECKSUM $TESTDIR/fanboy-czech.txt
   cp -f $TESTDIR/fanboy-czech.txt $MAINDIR/fanboy-czech.txt
   # Remove old copy, then gzip it
   rm -rf $MAINDIR/fanboy-czech.txt.gz
   $ZIP $MAINDIR/fanboy-czech.txt.gz $TESTDIR/fanboy-czech.txt > /dev/null
   # Combine Regional trackers
   $HGSERV/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $HGSERV/scripts/ie/czech-ie-generator.sh
   # Combine
   $HGSERV/scripts/combine/firefox-adblock-czech.sh
else
   echo "Files are the same: fanboy-czech.txt" > /dev/null
fi

############### Fanboy Russian #################
SSLHG=$($SHA256SUM $HGSERV/firefox-regional/fanboy-adblocklist-rus-v2.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-russian.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
   cp -f $HGSERV/firefox-regional/fanboy-adblocklist-rus-v2.txt $TESTDIR/fanboy-russian.txt
   # Re-generate checksum
   $ADDCHECKSUM $TESTDIR/fanboy-russian.txt
   cp -f $TESTDIR/fanboy-russian.txt $MAINDIR/fanboy-russian.txt
   # Wipe old files
   rm -rf  $MAINDIR/fanboy-russian.txt.gz
   $ZIP $MAINDIR/fanboy-russian.txt.gz $TESTDIR/fanboy-russian.txt > /dev/null
   # Combine Regional trackers
   $HGSYNC/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $HGSYNC/scripts/ie/russian-ie-generator.sh
   # Combine
   $HGSYNC/scripts/combine/firefox-adblock-rus.sh
   # Generate Opera RUS script also
   $HGSYNC/scripts/firefox/opera-russian.sh
else
   echo "Files are the same: fanboy-russian.txt" > /dev/null
fi

############### Fanboy Turkish #################
SSLHG=$($SHA256SUM $HGSERV/firefox-regional/fanboy-adblocklist-tky.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-turkish.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
   cp -f $HGSYNC/firefox-regional/fanboy-adblocklist-tky.txt $TESTDIR/fanboy-turkish.txt
   # Re-generate checksum
   $ADDCHECKSUM $TESTDIR/fanboy-turkish.txt
   cp -f $TESTDIR/fanboy-turkish.txt $MAINDIR/fanboy-turkish.txt
   # Wipe old files
   rm -rf $MAINDIR/fanboy-turkish.txt.gz
   $ZIP $MAINDIR/fanboy-turkish.txt.gz $TESTDIR/fanboy-turkish.txt > /dev/null
   # Combine Regional trackers
   $HGSYNC/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $HGSYNC/scripts/ie/turkish-ie-generator.sh
   # Combine
   $HGSYNC/scripts/combine/firefox-adblock-turk.sh
else
   echo "Files are the same: fanboy-turkish.txt" > /dev/null
fi

############### Fanboy JAPANESE #################
SSLHG=$($SHA256SUM $HGSERV/firefox-regional/fanboy-adblocklist-jpn.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-japanese.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
   cp -f $HGSERV/firefox-regional/fanboy-adblocklist-jpn.txt $TESTDIR/fanboy-japanese.txt
   # Re-generate checksum
   $ADDCHECKSUM $TESTDIR/fanboy-japanese.txt
   # Wipe old files
   rm -rf $MAINDIR/fanboy-japanese.txt.gz
   $ZIP $MAINDIR/fanboy-japanese.txt.gz $TESTDIR/fanboy-japanese.txt > /dev/null
   # Combine Regional trackers
   $HGSYNC/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $HGSYNC/scripts/ie/japanese-ie-generator.sh
   # Combine
   $HGSYNC/scripts/combine/firefox-adblock-jpn.sh
else
   echo "Files are the same: fanboy-japanese.txt" > /dev/null
fi

############### Fanboy KOREAN #################
SSLHG=$($SHA256SUM $HGSERV/firefox-regional/fanboy-adblocklist-krn.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-korean.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    cp -f $HGSERV/firefox-regional/fanboy-adblocklist-krn.txt $TESTDIR/fanboy-korean.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/fanboy-korean.txt
    cp -f $TESTDIR/fanboy-korean.txt $MAINDIR/fanboy-korean.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-korean.txt.gz
    $ZIP $MAINDIR/fanboy-korean.txt.gz $TESTDIR/fanboy-korean.txt > /dev/null
    # Combine Regional trackers
    $HGSYNC/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $HGSYNC/scripts/combine/firefox-adblock-krn.sh
else
   echo "Files are the same: fanboy-korean.txt" > /dev/null
fi

############### Fanboy ITALIAN #################
SSLHG=$($SHA256SUM $HGSYNC/firefox-regional/fanboy-adblocklist-ita.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-italian.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    cp -f $HGSERV/firefox-regional/fanboy-adblocklist-ita.txt $TESTDIR/fanboy-italian.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/fanboy-italian.txt
    cp -f $TESTDIR/fanboy-italian.txt $MAINDIR/fanboy-italian.txt
    $ZIP $MAINDIR/fanboy-italian.txt.gz $TESTDIR/fanboy-italian.txt > /dev/null
    # Combine Regional trackers
    $HGSYNC/scripts/combine/firefox-adblock-intl-tracking.sh
    # Generate IE script
    $HGSYNC/scripts/ie/italian-ie-generator.sh
    # Combine
    $HGSYNC/scripts/combine/firefox-adblock-ita.sh
else
   echo "Files are the same: fanboy-italian.txt" > /dev/null
fi

############### Fanboy POLISH #################
SSLHG=$($SHA256SUM $HGSERV/firefox-regional/fanboy-adblocklist-pol.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-polish.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    cp -f $HGSERV/firefox-regional/fanboy-adblocklist-pol.txt $TESTDIR/fanboy-polish.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/fanboy-polish.txt
    cp -f $TESTDIR/fanboy-polish.txt $MAINDIR/fanboy-polish.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-polish.txt.gz 
    $ZIP $MAINDIR/fanboy-polish.txt.gz $TESTDIR/fanboy-polish.txt > /dev/null
    # Combine Regional trackers
    $HGSYNC/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $HGSYNC/scripts/combine/firefox-adblock-pol.sh
else
   echo "Files are the same: fanboy-polish.txt" > /dev/null
fi

############### Fanboy INDIAN #################
SSLHG=$($SHA256SUM $HGSYNC/firefox-regional/fanboy-adblocklist-ind.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-indian.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    cp -f $HGSYNC/firefox-regional/fanboy-adblocklist-ind.txt $TESTDIR/fanboy-indian.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/fanboy-indian.txt 
    cp -f $TESTDIR/fanboy-indian.txt $MAINDIR/fanboy-indian.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-indian.txt.gz
    $ZIP $MAINDIR/fanboy-indian.txt.gz $MAINDIR/fanboy-indian.txt > /dev/null
    # Combine Regional trackers
    $HGSYNC/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $HGSYNC/scripts/combine/firefox-adblock-ind.sh
else
   echo "Files are the same: fanboy-indian.txt" > /dev/null
fi

############### Fanboy VIETNAM #################
SSLHG=$($SHA256SUM $HGSYNC/firefox-regional/fanboy-adblocklist-vtn.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-vietnam.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    cp -f $HGSYNC/firefox-regional/fanboy-adblocklist-vtn.txt $TESTDIR/fanboy-vietnam.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/fanboy-vietnam.txt
    cp -f $TESTDIR/fanboy-vietnam.txt $MAINDIR/fanboy-vietnam.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-vietnam.txt.gz
    $ZIP $MAINDIR/fanboy-vietnam.txt.gz $MAINDIR/fanboy-vietnam.txt > /dev/null
    # Combine Regional trackers
    $HGSYNC/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $HGSYNC/scripts/combine/firefox-adblock-vtn.sh
else
   echo "Files are the same: fanboy-vietnam.txt" > /dev/null
fi

############### Fanboy ESPANOL #################
SSLHG=$($SHA256SUM $HGSYNC/firefox-regional/fanboy-adblocklist-esp.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-espanol.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    cp -f $HGSYNC/firefox-regional/fanboy-adblocklist-esp.txt $TESTDIR/fanboy-espanol.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/fanboy-espanol.txt
    cp -f $TESTDIR/fanboy-espanol.txt $MAINDIR/fanboy-espanol.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-espanol.txt.gz
    $ZIP $MAINDIR/fanboy-espanol.txt.gz $MAINDIR/fanboy-espanol.txt > /dev/null
    # Combine Regional trackers
    $HGSYNC/scripts/combine/firefox-adblock-intl-tracking.sh
		# Generate IE script
		$HGSYNC/scripts/ie/espanol-ie-generator.sh
		# Combine
		$HGSYNC/scripts/combine/firefox-adblock-esp.sh
else
   echo "Files are the same: fanboy-espanol.txt" > /dev/null
fi

############### Fanboy SWEDISH #################
SSLHG=$($SHA256SUM $HGSYNC/firefox-regional/fanboy-adblocklist-swe.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-swedish.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    cp -f $HGSYNC/firefox-regional/fanboy-adblocklist-swe.txt $TESTDIR/fanboy-swedish.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/fanboy-swedish.txt
    cp -f $TESTDIR/fanboy-swedish.txt $MAINDIR/fanboy-swedish.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-swedish.txt.gz
    $ZIP $MAINDIR/fanboy-swedish.txt.gz $MAINDIR/fanboy-swedish.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-swedish.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $HGSYNC/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $HGSYNC/scripts/combine/firefox-adblock-swe.sh
else
   echo "Files are the same: fanboy-swedish.txt" > /dev/null
fi