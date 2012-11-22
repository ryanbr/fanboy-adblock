#!/bin/bash
#
# Fanboy Adblock list grabber script v2.21 (08/09/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Version history
#
# 2.30 Remove p2p list
# 2.21 Opera CSS generator
# 2.20 Allow spaces to prepended to each list before processing
# 2.15 Optimise sed (no need for temp files)
# 2.14 More error Checking of Ramdisks, removal of seperate IE ramdisk
# 2.13 Allow mirrors to use non-ram disk for HG
# 2.12 Annoyance List split list (beta)
# 2.11 Added Non-element and Fanboy-Adult
# 2.10 Tracking List split list
# 2.06 Better error checking
# 2.05 Remove Dube loops and create error checking.
# 2.04 Remove any empty lines
# 2.03 Allow Hg pulls
# 2.02 Typo in fanboy-elements-specific.txt
# 2.01 Various cleanups, add Israeli List
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
export DATE="`date`"
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export TWIDGE="/usr/bin/twidge update"
export IEDIR="/tmp/work/ie"
export IESUBS="/tmp/work/ie/subscriptions"
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

if [ ! -d "/tmp/work/split" ]; then
  mkdir /tmp/work/split; chmod 777 /tmp/work/split
  mkdir /tmp/work/split/fanboy-adblock; chmod 777 /tmp/work/split/fanboy-adblock
  mkdir /tmp/work/split/fanboy-addon; chmod 777 /tmp/work/split/fanboy-addon
  mkdir /tmp/work/split/fanboy-tracking; chmod 777 /tmp/work/split/fanboy-tracking
fi

if [ ! -d "/tmp/Ramdisk/" ]; then
  rm -rf /tmp/Ramdisk/
  mkdir /tmp/Ramdisk; chmod 777 /tmp/Ramdisk
  mount -t tmpfs -o size=110M tmpfs /tmp/Ramdisk/
fi

#if [ ! -d "/tmp/ieramdisk/subscriptions" ]; then
#  rm -rf /tmp/ieramdisk/subscriptions
#  mkdir /tmp/ieramdisk; chmod 777 /tmp/ieramdisk
#  mount -t tmpfs -o size=30M tmpfs /tmp/ieramdisk
#  mkdir /tmp/ieramdisk/subscriptions; chmod 777 /tmp/ieramdisk/subscriptions
#fi

if [ ! -d "/tmp/Ramdisk/www/adblock/split" ]; then
  mkdir /tmp/Ramdisk/www/adblock/split; chmod 777 /tmp/Ramdisk/www/adblock/split
fi

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

#######################################  fanboy-generic.txt  #######################################
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
        rm -rf $TESTDIR/fanboy-merged.txt > /dev/null

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

   $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-popups.txt $TESTDIR/split/fanboy-adblock/fanboy-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-adult-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-elements.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-whitelists.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-elements-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-specific.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-exceptions.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-generic.txt $MAINDIR/split/fanboy-generic.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

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

              # Fanboy-non-element
              #
              $NICE $HGSERV/scripts/firefox/fanboy-noele.sh

              # Firefox2operascript
              #
              $NICE $HGSERV/scripts/firefox2opera.sh

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-merged.txt: fanboy-generic.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-generic.txt" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-generic.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi

#######################################  fanboy-thirdparty.txt  #######################################
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
        rm -rf $TESTDIR/fanboy-merged.txt

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

   $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-popups.txt $TESTDIR/split/fanboy-adblock/fanboy-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-adult-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-elements.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-whitelists.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-elements-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-specific.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-exceptions.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $MAINDIR/split/fanboy-thirdparty.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

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

              # Fanboy-non-element
              #
              $NICE $HGSERV/scripts/firefox/fanboy-noele.sh

              # Firefox2operascript
              #
              $NICE $HGSERV/scripts/firefox2opera.sh

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-merged.txt: fanboy-thirdparty.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-thirdparty.txt" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-thirdparty.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi

#######################################  fanboy-firstparty.txt  #######################################
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
        rm -rf $TESTDIR/fanboy-merged.txt

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

   $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-popups.txt $TESTDIR/split/fanboy-adblock/fanboy-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-adult-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-elements.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-whitelists.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-elements-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-specific.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-exceptions.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then

              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-firstparty.txt $MAINDIR/split/fanboy-firstparty.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

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

              # Fanboy-non-element
              #
              $NICE $HGSERV/scripts/firefox/fanboy-noele.sh

              # Firefox2operascript
              #
              $NICE $HGSERV/scripts/firefox2opera.sh

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-merged.txt: fanboy-firstparty.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-firstparty.txt" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-firstparty.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi

#######################################  fanboy-popups.txt  #######################################
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
        rm -rf $TESTDIR/fanboy-merged.txt

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

   $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-popups.txt $TESTDIR/split/fanboy-adblock/fanboy-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-adult-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-elements.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-whitelists.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-elements-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-specific.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-exceptions.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-popups.txt $MAINDIR/split/fanboy-popups.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

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

              # Fanboy-non-element
              #
              $NICE $HGSERV/scripts/firefox/fanboy-noele.sh

              # Firefox2operascript
              #
              $NICE $HGSERV/scripts/firefox2opera.sh

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-merged.txt: fanboy-popups.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-popups.txt" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-popups.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi

#######################################  fanboy-whitelist.txt  #######################################
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
        rm -rf $TESTDIR/fanboy-merged.txt

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

   $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-popups.txt $TESTDIR/split/fanboy-adblock/fanboy-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-adult-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-elements.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-whitelists.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-elements-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-specific.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-exceptions.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-whitelist.txt $MAINDIR/split/fanboy-whitelist.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

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

              # Fanboy-non-element
              #
              $NICE $HGSERV/scripts/firefox/fanboy-noele.sh

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-merged.txt: fanboy-whitelist.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-whitelist.txt" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-whitelist.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi

#######################################  fanboy-dimensions.txt  #######################################
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
        rm -rf $TESTDIR/fanboy-merged.txt

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

   $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-popups.txt $TESTDIR/split/fanboy-adblock/fanboy-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-adult-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-elements.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-whitelists.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-elements-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-specific.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-exceptions.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-dimensions.txt $MAINDIR/split/fanboy-dimensions.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

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

              # Fanboy-non-element
              #
              $NICE $HGSERV/scripts/firefox/fanboy-noele.sh

              # Firefox2operascript
              #
              $NICE $HGSERV/scripts/firefox2opera.sh

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-merged.txt: fanboy-dimensions.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-dimensions.txt" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-dimensions.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi

#######################################  fanboy-dimensions-whitelist.txt  #######################################
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
        rm -rf $TESTDIR/fanboy-merged.txt

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

   $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-popups.txt $TESTDIR/split/fanboy-adblock/fanboy-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-adult-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-elements.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-whitelists.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-elements-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-specific.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-exceptions.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $MAINDIR/split/fanboy-dimensions-whitelist.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

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

              # Fanboy-non-element
              #
              $NICE $HGSERV/scripts/firefox/fanboy-noele.sh

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-merged.txt: fanboy-dimensions-whitelist.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-dimensions-whitelist.txt" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-dimensions-whitelist.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi

#######################################  fanboy-adult-generic.txt  #######################################
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
        rm -rf $TESTDIR/fanboy-merged.txt
        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

   $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-popups.txt $TESTDIR/split/fanboy-adblock/fanboy-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-adult-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-elements.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-whitelists.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-elements-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-specific.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-exceptions.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $MAINDIR/split/fanboy-adult-generic.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

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

              # Fanboy-Adult
              #
              $NICE $HGSERV/scripts/firefox/fanboy-adult.sh

              # Fanboy-non-element
              #
              $NICE $HGSERV/scripts/firefox/fanboy-noele.sh

              # Firefox2operascript
              #
              $NICE $HGSERV/scripts/firefox2opera.sh

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-merged.txt: fanboy-adult-generic.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-adult-generic.txt" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-adult-generic.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi


#######################################  fanboy-adult-firstparty.txt  #######################################
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
        rm -rf $TESTDIR/fanboy-merged.txt

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

   $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-popups.txt $TESTDIR/split/fanboy-adblock/fanboy-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-adult-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-elements.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-whitelists.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-elements-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-specific.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-exceptions.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt $MAINDIR/split/fanboy-adult-firstparty.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

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

              # Fanboy-Adult
              #
              $NICE $HGSERV/scripts/firefox/fanboy-adult.sh

              # Fanboy-non-element
              #
              $NICE $HGSERV/scripts/firefox/fanboy-noele.sh

              # Firefox2operascript
              #
              $NICE $HGSERV/scripts/firefox2opera.sh

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-merged.txt: fanboy-adult-firstparty.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-adult-firstparty.txt" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-adult-firstparty.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi

#######################################  fanboy-adult-thirdparty.txt  #######################################
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
        rm -rf $TESTDIR/fanboy-merged.txt

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

   $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-popups.txt $TESTDIR/split/fanboy-adblock/fanboy-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-adult-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-elements.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-whitelists.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-elements-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-specific.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-exceptions.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $MAINDIR/split/fanboy-adult-thirdparty.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

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

              # Fanboy-Adult
              #
              $NICE $HGSERV/scripts/firefox/fanboy-adult.sh

              # Fanboy-non-element
              #
              $NICE $HGSERV/scripts/firefox/fanboy-noele.sh

              # Firefox2operascript
              #
              $NICE $HGSERV/scripts/firefox2opera.sh

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-merged.txt: fanboy-adult-thirdparty.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-adult-thirdparty.txt" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-adult-thirdparty.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi

#######################################  fanboy-adult-elements.txt  #######################################
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
        rm -rf $TESTDIR/fanboy-merged.txt

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

   $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-popups.txt $TESTDIR/split/fanboy-adblock/fanboy-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-adult-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-elements.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-whitelists.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-elements-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-specific.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-exceptions.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-adult-elements.txt $MAINDIR/split/fanboy-adult-elements.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

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

              # Fanboy-Adult
              #
              $NICE $HGSERV/scripts/firefox/fanboy-adult.sh

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-merged.txt: fanboy-adult-elements.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-adult-elements.txt" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-adult-elements.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi

#######################################  fanboy-adult-whitelists.txt  #######################################
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
        rm -rf $TESTDIR/fanboy-merged.txt

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

   $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-popups.txt $TESTDIR/split/fanboy-adblock/fanboy-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-adult-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-elements.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-whitelists.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-elements-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-specific.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-exceptions.txt > $TESTDIR/fanboy-merged.txt


        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
             # Copy over
             #
             cp -f $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt $MAINDIR/split/fanboy-adult-whitelists.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

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

              # Fanboy-Adult
              #
              $NICE $HGSERV/scripts/firefox/fanboy-adult.sh

              # Fanboy-non-element
              #
              $NICE $HGSERV/scripts/firefox/fanboy-noele.sh

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-merged.txt: fanboy-adult-whitelists.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-adult-whitelists.txt" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-adult-whitelists.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi


#######################################  fanboy-dimensions.txt  #######################################
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
       rm -rf $TESTDIR/fanboy-merged.txt

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

       $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
            $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-dimensions.txt $MAINDIR/split/fanboy-dimensions.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

              # Dimension Header
              #
              sed -i 's/Adblock\ List/Fanboy\ Dimension\ List/g' $TESTDIR/fanboy-merged.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

              # Compress
              #
              cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-dimensions.txt
              rm -rf $MAINDIR/fanboy-dimensions.txt.gz
              $ZIP $MAINDIR/fanboy-dimensions.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # Firefox2operascript
              #
              $NICE $HGSERV/scripts/firefox2opera.sh

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-dimensions.txt: fanboy-dimensions.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-dimensions.txt" > /dev/null
    fi
else
  echo "fanboy-dimensions (fanboy-dimensions.txt) failed to update: $DATE" >> $LOGFILE
fi


#######################################  fanboy-dimensions-whitelist.txt  #######################################
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
       rm -rf $TESTDIR/fanboy-merged.txt


       # Allow Temp dir so we can insert spaces..
       #
       cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

       # Add a space at the end of each file (before we cat it)
       #
       sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

       $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
            $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $MAINDIR/split/fanboy-dimensions-whitelist.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

              # Dimension Header
              #
              sed -i 's/Adblock\ List/Fanboy\ Dimension\ List/g' $TESTDIR/fanboy-merged.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-merged.txt

              # Compress
              #
              cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/fanboy-dimensions.txt
              rm -rf $MAINDIR/fanboy-dimensions.txt.gz
              $ZIP $MAINDIR/fanboy-dimensions.txt.gz $TESTDIR/fanboy-merged.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-dimensions-whitelist.txt: fanboy-dimensions-whitelist.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-dimensions-whitelist.txt" > /dev/null
    fi
else
  echo "fanboy-dimensions-whitelist (fanboy-dimensions-whitelist.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-p2p-firstparty.txt failed to update: $DATE"
fi

#######################################  fanboy-elements-generic.txt  #######################################
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
        rm -rf $TESTDIR/fanboy-merged.txt

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

   $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-popups.txt $TESTDIR/split/fanboy-adblock/fanboy-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-adult-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-elements.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-whitelists.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-elements-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-specific.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-exceptions.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-elements-generic.txt $MAINDIR/split/fanboy-elements-generic.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

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

              # Opera CSS
              #
              $NICE $HGSERV/scripts/firefox/fanboy-element-opera-generator.sh

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-merged.txt: fanboy-elements-generic.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-elements-generic.txt" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-elements-generic.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi

#######################################  fanboy-elements-specific.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-elements-specific.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-elements-specific.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-elements-specific.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        rm -rf $TESTDIR/fanboy-merged.txt

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

   $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-popups.txt $TESTDIR/split/fanboy-adblock/fanboy-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-adult-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-elements.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-whitelists.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-elements-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-specific.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-exceptions.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-elements-specific.txt $MAINDIR/split/fanboy-elements-specific.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

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

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-merged.txt: fanboy-elements-specific.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-elements-specific.txt" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-elements-specific.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi

#######################################  fanboy-elements-exceptions.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-adblock/fanboy-elements-exceptions.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-adblock/fanboy-elements-exceptions.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-elements-exceptions.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        rm -rf $TESTDIR/fanboy-merged.txt

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-adblock/*.txt $TESTDIR/split/fanboy-adblock

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-adblock/*.txt

   $CAT $TESTDIR/split/fanboy-adblock/fanboy-header.txt $TESTDIR/split/fanboy-adblock/fanboy-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-popups.txt $TESTDIR/split/fanboy-adblock/fanboy-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-dimensions.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-dimensions-whitelist.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-firstparty.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-adult-thirdparty.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-elements.txt $TESTDIR/split/fanboy-adblock/fanboy-adult-whitelists.txt \
        $TESTDIR/split/fanboy-adblock/fanboy-elements-generic.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-specific.txt $TESTDIR/split/fanboy-adblock/fanboy-elements-exceptions.txt > $TESTDIR/fanboy-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-adblock/fanboy-elements-exceptions.txt $MAINDIR/split/fanboy-elements-exceptions.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-merged.txt

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

              # Remove temp files
              #
              rm -rf $TESTDIR/split/fanboy-adblock/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-merged.txt: fanboy-elements-exceptions.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-elements-exceptions.txt" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-elements-exceptions.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi

#######################################  fanboy-tracking-generic.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-tracking/fanboy-tracking-generic.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-tracking/fanboy-tracking-generic.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-tracking-generic.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        rm -rf $TESTDIR/fanboy-tracking-merged.txt > /dev/null

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-tracking/*.txt $TESTDIR/split/fanboy-tracking

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-tracking/*.txt

       $CAT $TESTDIR/split/fanboy-tracking/fanboy-header.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-generic.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-thirdparty.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-firstparty.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-adult.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-general.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-nonenglish.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-whitelist.txt > $TESTDIR/fanboy-tracking-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-tracking-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-tracking/fanboy-tracking-generic.txt $MAINDIR/split/fanboy-tracking-generic.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-tracking-merged.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-tracking-merged.txt
              # Compress
              #
              cp -f $TESTDIR/fanboy-tracking-merged.txt $MAINDIR/fanboy-tracking.txt
              rm -rf $MAINDIR/fanboy-tracking.txt.gz
              $ZIP $MAINDIR/fanboy-tracking.txt.gz $TESTDIR/fanboy-tracking-merged.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # IE: Fanboy-Tracking
              #
              $NICE $HGSERV/scripts/ie/tracking-ie-generator.sh

              # Firefox2operascript
              #
              $NICE $HGSERV/scripts/firefox2opera.sh

              # Remove temp files
              #
              rm -f $TESTDIR/split/fanboy-tracking/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-tracking-merged.txt: fanboy-tracking-generic.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-tracking-generic.txt" > /dev/null
    fi
else
  echo "fanboy-tracking-merged.txt (fanboy-tracking-generic.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-tracking-generic.txt failed to update: $DATE"
fi

#######################################  fanboy-tracking-firstparty.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-tracking/fanboy-tracking-firstparty.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-tracking/fanboy-tracking-firstparty.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-tracking-firstparty.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        rm -rf $TESTDIR/fanboy-tracking-merged.txt > /dev/null

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-tracking/*.txt $TESTDIR/split/fanboy-tracking

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-tracking/*.txt

       $CAT $TESTDIR/split/fanboy-tracking/fanboy-header.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-generic.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-thirdparty.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-firstparty.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-adult.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-general.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-nonenglish.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-whitelist.txt > $TESTDIR/fanboy-tracking-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-tracking-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-tracking/fanboy-tracking-firstparty.txt $MAINDIR/split/fanboy-tracking-firstparty.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-tracking-merged.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-tracking-merged.txt

              # Compress
              #
              cp -f $TESTDIR/fanboy-tracking-merged.txt $MAINDIR/fanboy-tracking.txt
              rm -rf $MAINDIR/fanboy-tracking.txt.gz
              $ZIP $MAINDIR/fanboy-tracking.txt.gz $TESTDIR/fanboy-tracking-merged.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # IE: Fanboy-Tracking
              #
              $NICE $HGSERV/scripts/ie/tracking-ie-generator.sh

              # Remove temp files
              #
              rm -f $TESTDIR/split/fanboy-tracking/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-tracking-merged.txt: fanboy-tracking-firstparty.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-tracking-firstparty.txt" > /dev/null
    fi
else
  echo "fanboy-tracking-merged.txt (fanboy-tracking-firstparty.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-tracking-firstparty.txt failed to update: $DATE"
fi

#######################################  fanboy-tracking-thirdparty.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-tracking/fanboy-tracking-thirdparty.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-tracking/fanboy-tracking-thirdparty.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-tracking-thirdparty.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        rm -rf $TESTDIR/fanboy-tracking-merged.txt > /dev/null

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-tracking/*.txt $TESTDIR/split/fanboy-tracking

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-tracking/*.txt

       $CAT $TESTDIR/split/fanboy-tracking/fanboy-header.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-generic.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-thirdparty.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-firstparty.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-adult.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-general.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-nonenglish.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-whitelist.txt > $TESTDIR/fanboy-tracking-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-tracking-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-tracking/fanboy-tracking-thirdparty.txt $MAINDIR/split/fanboy-tracking-thirdparty.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-tracking-merged.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-tracking-merged.txt

              # Compress
              #
              cp -f $TESTDIR/fanboy-tracking-merged.txt $MAINDIR/fanboy-tracking.txt
              rm -rf $MAINDIR/fanboy-tracking.txt.gz
              $ZIP $MAINDIR/fanboy-tracking.txt.gz $TESTDIR/fanboy-tracking-merged.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # IE: Fanboy-Tracking
              #
              $NICE $HGSERV/scripts/ie/tracking-ie-generator.sh

              # Firefox2operascript
              #
              $NICE $HGSERV/scripts/firefox2opera.sh

              # Remove temp files
              #
              rm -f $TESTDIR/split/fanboy-tracking/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-tracking-merged.txt: fanboy-tracking-thirdparty.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-tracking-thirdparty.txt" > /dev/null
    fi
else
  echo "fanboy-tracking-merged.txt (fanboy-tracking-thirdparty.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-tracking-thirdparty.txt failed to update: $DATE"
fi

#######################################  fanboy-tracking-general.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-tracking/fanboy-tracking-general.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-tracking/fanboy-tracking-general.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-tracking-general.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        rm -rf $TESTDIR/fanboy-tracking-merged.txt > /dev/null

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-tracking/*.txt $TESTDIR/split/fanboy-tracking

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-tracking/*.txt

       $CAT $TESTDIR/split/fanboy-tracking/fanboy-header.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-generic.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-thirdparty.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-firstparty.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-adult.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-general.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-nonenglish.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-whitelist.txt > $TESTDIR/fanboy-tracking-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-tracking-merged.txt" ]; then

              # Copy over
              #
              cp -f $HGSERV/fanboy-tracking/fanboy-tracking-general.txt $MAINDIR/split/fanboy-tracking-general.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-tracking-merged.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-tracking-merged.txt

              # Compress
              #
              cp -f $TESTDIR/fanboy-tracking-merged.txt $MAINDIR/fanboy-tracking.txt
              rm -rf $MAINDIR/fanboy-tracking.txt.gz
              $ZIP $MAINDIR/fanboy-tracking.txt.gz $TESTDIR/fanboy-tracking-merged.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # IE: Fanboy-Tracking
              #
              $NICE $HGSERV/scripts/ie/tracking-ie-generator.sh

              # Firefox2operascript
              #
              $NICE $HGSERV/scripts/firefox2opera.sh

              # Remove temp files
              #
              rm -f $TESTDIR/split/fanboy-tracking/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-tracking-merged.txt: fanboy-tracking-general.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-tracking-general.txt" > /dev/null
    fi
else
  echo "fanboy-tracking-merged.txt (fanboy-tracking-general.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-tracking-general.txt failed to update: $DATE"
fi

#######################################  fanboy-tracking-nonenglish.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-tracking/fanboy-tracking-nonenglish.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-tracking/fanboy-tracking-nonenglish.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-tracking-nonenglish.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        rm -rf $TESTDIR/fanboy-tracking-merged.txt > /dev/null

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-tracking/*.txt $TESTDIR/split/fanboy-tracking

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-tracking/*.txt

       $CAT $TESTDIR/split/fanboy-tracking/fanboy-header.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-generic.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-thirdparty.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-firstparty.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-adult.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-general.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-nonenglish.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-whitelist.txt > $TESTDIR/fanboy-tracking-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-tracking-merged.txt" ]; then

              # Copy over
              #
              cp -f $HGSERV/fanboy-tracking/fanboy-tracking-nonenglish.txt $MAINDIR/split/fanboy-tracking-nonenglish.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-tracking-merged.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-tracking-merged.txt

              # Compress
              #
              cp -f $TESTDIR/fanboy-tracking-merged.txt $MAINDIR/fanboy-tracking.txt
              rm -rf $MAINDIR/fanboy-tracking.txt.gz
              $ZIP $MAINDIR/fanboy-tracking.txt.gz $TESTDIR/fanboy-tracking-merged.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # IE: Fanboy-Tracking
              #
              $NICE $HGSERV/scripts/ie/tracking-ie-generator.sh

              # Firefox2operascript
              #
              $NICE $HGSERV/scripts/firefox2opera.sh

              # Remove temp files
              #
              rm -f $TESTDIR/split/fanboy-tracking/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-tracking-merged.txt: fanboy-tracking-nonenglish.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-tracking-nonenglish.txt" > /dev/null
    fi
else
  echo "fanboy-tracking-merged.txt (fanboy-tracking-nonenglish.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-tracking-nonenglish.txt failed to update: $DATE"
fi

#######################################  fanboy-tracking-adult.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-tracking/fanboy-tracking-adult.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-tracking/fanboy-tracking-adult.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-tracking-adult.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        rm -rf $TESTDIR/fanboy-tracking-merged.txt > /dev/null

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-tracking/*.txt $TESTDIR/split/fanboy-tracking

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-tracking/*.txt

       $CAT $TESTDIR/split/fanboy-tracking/fanboy-header.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-generic.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-thirdparty.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-firstparty.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-adult.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-general.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-nonenglish.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-whitelist.txt > $TESTDIR/fanboy-tracking-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-tracking-merged.txt" ]; then

              # Copy over
              #
              cp -f $HGSERV/fanboy-tracking/fanboy-tracking-adult.txt $MAINDIR/split/fanboy-tracking-adult.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-tracking-merged.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-tracking-merged.txt

              # Compress
              #
              cp -f $TESTDIR/fanboy-tracking-merged.txt $MAINDIR/fanboy-tracking.txt
              rm -rf $MAINDIR/fanboy-tracking.txt.gz
              $ZIP $MAINDIR/fanboy-tracking.txt.gz $TESTDIR/fanboy-tracking-merged.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # IE: Fanboy-Tracking
              #
              $NICE $HGSERV/scripts/ie/tracking-ie-generator.sh

              # Firefox2operascript
              #
              $NICE $HGSERV/scripts/firefox2opera.sh

              # Remove temp files
              #
              rm -f $TESTDIR/split/fanboy-tracking/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-tracking-merged.txt: fanboy-tracking-adult.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-tracking-adult.txt" > /dev/null
    fi
else
  echo "fanboy-tracking-merged.txt (fanboy-tracking-adult.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-tracking-adult.txt failed to update: $DATE"
fi


#######################################  fanboy-tracking-whitelist.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-tracking/fanboy-tracking-whitelist.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-tracking/fanboy-tracking-whitelist.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-tracking-whitelist.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        rm -rf $TESTDIR/fanboy-tracking-merged.txt > /dev/null

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-tracking/*.txt $TESTDIR/split/fanboy-tracking

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-tracking/*.txt

       $CAT $TESTDIR/split/fanboy-tracking/fanboy-header.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-generic.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-thirdparty.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-firstparty.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-adult.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-general.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-nonenglish.txt \
            $TESTDIR/split/fanboy-tracking/fanboy-tracking-whitelist.txt > $TESTDIR/fanboy-tracking-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-tracking-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-tracking/fanboy-tracking-whitelist.txt $MAINDIR/split/fanboy-tracking-whitelist.txt

              # Remove empty lines
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-tracking-merged.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-tracking-merged.txt

              # Compress
              #
              cp -f $TESTDIR/fanboy-tracking-merged.txt $MAINDIR/fanboy-tracking.txt
              rm -rf $MAINDIR/fanboy-tracking.txt.gz
              $ZIP $MAINDIR/fanboy-tracking.txt.gz $TESTDIR/fanboy-tracking-merged.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # IE: Fanboy-Tracking
              #
              $NICE $HGSERV/scripts/ie/tracking-ie-generator.sh

              # Remove temp files
              #
              rm -f $TESTDIR/split/fanboy-tracking/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-tracking-merged.txt: fanboy-tracking-whitelist.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-tracking-whitelist.txt" > /dev/null
    fi
else
  echo "fanboy-tracking-merged.txt (fanboy-tracking-whitelist.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-tracking-whitelist.txt failed to update: $DATE"
fi

#######################################  fanboy-addon-generic.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-addon/fanboy-addon-generic.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-addon/fanboy-addon-generic.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-addon-generic.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        rm -rf $TESTDIR/fanboy-addon-merged.txt > /dev/null

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-addon/*.txt $TESTDIR/split/fanboy-addon

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-addon/*.txt

       $CAT $TESTDIR/split/fanboy-addon/fanboy-header.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-generic.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-thirdparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-firstparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-whitelists.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-intl.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-specific.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-exceptions.txt > $TESTDIR/fanboy-addon-merged.txt
       # English
       rm -rf $TESTDIR/fanboy-addon-merged-english.txt > /dev/null
       $CAT $TESTDIR/split/fanboy-addon/fanboy-header.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-generic.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-thirdparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-firstparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-whitelists.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-specific.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-exceptions.txt > $TESTDIR/fanboy-addon-merged-english.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-addon-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-addon/fanboy-addon-generic.txt $MAINDIR/split/fanboy-addon-generic.txt

              # Remove empty lines (International + English)
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-addon-merged.txt $TESTDIR/fanboy-addon-merged-english.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-addon-merged-english.txt $TESTDIR/fanboy-addon-merged.txt

              # Compress (International)
              #
              cp -f $TESTDIR/fanboy-addon-merged.txt $MAINDIR/fanboy-addon.txt
              rm -rf $MAINDIR/fanboy-addon.txt.gz
              $ZIP $MAINDIR/fanboy-addon.txt.gz $TESTDIR/fanboy-addon-merged.txt > /dev/null

              # Compress (English)
              #
              cp -f $TESTDIR/fanboy-addon-merged-english.txt $MAINDIR/fanboy-addon-english.txt
              rm -rf $MAINDIR/fanboy-addon-english.txt.gz
              $ZIP $MAINDIR/fanboy-addon-english.txt.gz $TESTDIR/fanboy-addon-merged-english.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # Remove temp files
              #
              rm -f $TESTDIR/split/fanboy-addon/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-addon-generic.txt: fanboy-addon-merged.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-addon-generic.txt" > /dev/null
    fi
else
  echo "fanboy-addon-generic.txt (fanboy-addon-merged.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-tracking-thirdparty.txt failed to update: $DATE"
fi

#######################################  fanboy-addon-thirdparty.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-addon/fanboy-addon-thirdparty.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-addon/fanboy-addon-thirdparty.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-addon-thirdparty.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        rm -rf $TESTDIR/fanboy-addon-merged.txt > /dev/null

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-addon/*.txt $TESTDIR/split/fanboy-addon

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-addon/*.txt

       $CAT $TESTDIR/split/fanboy-addon/fanboy-header.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-generic.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-thirdparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-firstparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-whitelists.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-intl.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-specific.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-exceptions.txt > $TESTDIR/fanboy-addon-merged.txt
       # English
       rm -rf $TESTDIR/fanboy-addon-merged-english.txt > /dev/null
       $CAT $TESTDIR/split/fanboy-addon/fanboy-header.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-generic.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-thirdparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-firstparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-whitelists.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-specific.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-exceptions.txt > $TESTDIR/fanboy-addon-merged-english.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-addon-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-addon/fanboy-addon-thirdparty.txt $MAINDIR/split/fanboy-addon-thirdparty.txt

              # Remove empty lines (International + English)
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-addon-merged.txt $TESTDIR/fanboy-addon-merged-english.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-addon-merged.txt $TESTDIR/fanboy-addon-merged-english.txt

              # Compress (International)
              #
              cp -f $TESTDIR/fanboy-addon-merged.txt $MAINDIR/fanboy-addon.txt
              rm -rf $MAINDIR/fanboy-addon.txt.gz
              $ZIP $MAINDIR/fanboy-addon.txt.gz $TESTDIR/fanboy-addon-merged.txt > /dev/null

              # Compress (English)
              #
              cp -f $TESTDIR/fanboy-addon-merged-english.txt $MAINDIR/fanboy-addon-english.txt
              rm -rf $MAINDIR/fanboy-addon-english.txt.gz
              $ZIP $MAINDIR/fanboy-addon-english.txt.gz $TESTDIR/fanboy-addon-merged-english.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # Remove temp files
              #
              rm -f $TESTDIR/split/fanboy-addon/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-addon-generic.txt: fanboy-addon-merged.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-addon-generic.txt" > /dev/null
    fi
else
  echo "fanboy-addon-generic.txt (fanboy-addon-merged.tx) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-tracking-thirdparty.txt failed to update: $DATE"
fi

#######################################  fanboy-addon-firstparty.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-addon/fanboy-addon-firstparty.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-addon/fanboy-addon-firstparty.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-addon-firstparty.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        rm -rf $TESTDIR/fanboy-addon-merged.txt > /dev/null

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-addon/*.txt $TESTDIR/split/fanboy-addon

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-addon/*.txt

       $CAT $TESTDIR/split/fanboy-addon/fanboy-header.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-generic.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-thirdparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-firstparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-whitelists.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-intl.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-specific.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-exceptions.txt > $TESTDIR/fanboy-addon-merged.txt
       # English
       rm -rf $TESTDIR/fanboy-addon-merged-english.txt > /dev/null
       $CAT $TESTDIR/split/fanboy-addon/fanboy-header.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-generic.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-thirdparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-firstparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-whitelists.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-specific.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-exceptions.txt > $TESTDIR/fanboy-addon-merged-english.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-addon-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-addon/fanboy-addon-firstparty.txt $MAINDIR/split/fanboy-addon-firstparty.txt

              # Remove empty lines (International + English)
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-addon-merged.txt $TESTDIR/fanboy-addon-merged-english.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-addon-merged.txt $TESTDIR/fanboy-addon-merged-english.txt

              # Compress (International)
              #
              cp -f $TESTDIR/fanboy-addon-merged.txt $MAINDIR/fanboy-addon.txt
              rm -rf $MAINDIR/fanboy-addon.txt.gz
              $ZIP $MAINDIR/fanboy-addon.txt.gz $TESTDIR/fanboy-addon-merged.txt > /dev/null

              # Compress (English)
              #
              cp -f $TESTDIR/fanboy-addon-merged-english.txt $MAINDIR/fanboy-addon-english.txt
              rm -rf $MAINDIR/fanboy-addon-english.txt.gz
              $ZIP $MAINDIR/fanboy-addon-english.txt.gz $TESTDIR/fanboy-addon-merged-english.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # Remove temp files
              #
              rm -f $TESTDIR/split/fanboy-addon/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-addon-firstparty.txt: fanboy-addon-firstparty.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-addon-firstparty.txt" > /dev/null
    fi
else
  echo "fanboy-addon-generic.txt (fanboy-addon-firstparty.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-tracking-thirdparty.txt failed to update: $DATE"
fi

#######################################  fanboy-addon-whitelists.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-addon/fanboy-addon-whitelists.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-addon/fanboy-addon-whitelists.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-addon-whitelists.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        rm -rf $TESTDIR/fanboy-addon-merged.txt > /dev/null

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-addon/*.txt $TESTDIR/split/fanboy-addon

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-addon/*.txt

       $CAT $TESTDIR/split/fanboy-addon/fanboy-header.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-generic.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-thirdparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-firstparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-whitelists.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-intl.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-specific.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-exceptions.txt > $TESTDIR/fanboy-addon-merged.txt
       # English
       rm -rf $TESTDIR/fanboy-addon-merged-english.txt > /dev/null
       $CAT $TESTDIR/split/fanboy-addon/fanboy-header.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-generic.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-thirdparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-firstparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-whitelists.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-specific.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-exceptions.txt > $TESTDIR/fanboy-addon-merged-english.txt
        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-addon-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-addon/fanboy-addon-whitelists.txt $MAINDIR/split/fanboy-addon-whitelists.txt

              # Remove empty lines (International + English)
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-addon-merged.txt $TESTDIR/fanboy-addon-merged-english.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-addon-merged.txt $TESTDIR/fanboy-addon-merged-english.txt

              # Compress (International)
              #
              cp -f $TESTDIR/fanboy-addon-merged.txt $MAINDIR/fanboy-addon.txt
              rm -rf $MAINDIR/fanboy-addon.txt.gz
              $ZIP $MAINDIR/fanboy-addon.txt.gz $TESTDIR/fanboy-addon-merged.txt > /dev/null

              # Compress (English)
              #
              cp -f $TESTDIR/fanboy-addon-merged-english.txt $MAINDIR/fanboy-addon-english.txt
              rm -rf $MAINDIR/fanboy-addon-english.txt.gz
              $ZIP $MAINDIR/fanboy-addon-english.txt.gz $TESTDIR/fanboy-addon-merged-english.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # Remove temp files
              #
              rm -f $TESTDIR/split/fanboy-addon/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-addon-firstparty.txt: fanboy-addon-whitelists.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-addon-whitelists.txt" > /dev/null
    fi
else
  echo "fanboy-addon-whitelists.txt (fanboy-addon-whitelists.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-tracking-thirdparty.txt failed to update: $DATE"
fi

#######################################  fanboy-addon-intl.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-addon/fanboy-addon-intl.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-addon/fanboy-addon-intl.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-addon-intl.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        rm -rf $TESTDIR/fanboy-addon-merged.txt > /dev/null
        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-addon/*.txt $TESTDIR/split/fanboy-addon

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-addon/*.txt

       $CAT $TESTDIR/split/fanboy-addon/fanboy-header.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-generic.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-thirdparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-firstparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-whitelists.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-intl.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-specific.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-exceptions.txt > $TESTDIR/fanboy-addon-merged.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-addon-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-addon/fanboy-addon-intl.txt $MAINDIR/split/fanboy-addon-intl.txt

              # Remove empty lines (International + English)
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-addon-merged.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-addon-merged.txt

              # Compress (International)
              #
              cp -f $TESTDIR/fanboy-addon-merged.txt $MAINDIR/fanboy-addon.txt
              rm -rf $MAINDIR/fanboy-addon.txt.gz
              $ZIP $MAINDIR/fanboy-addon.txt.gz $TESTDIR/fanboy-addon-merged.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # Remove temp files
              #
              rm -f $TESTDIR/split/fanboy-addon/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-addon-intl.txt: fanboy-addon-intl.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-addon-intl.txt" > /dev/null
    fi
else
  echo "fanboy-addon-intl.txt (fanboy-addon-intl.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-tracking-thirdparty.txt failed to update: $DATE"
fi

#######################################  fanboy-addon-elements.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-addon/fanboy-addon-elements.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-addon/fanboy-addon-elements.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-addon-elements.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        rm -rf $TESTDIR/fanboy-addon-merged.txt > /dev/null

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-addon/*.txt $TESTDIR/split/fanboy-addon

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-addon/*.txt

       $CAT $TESTDIR/split/fanboy-addon/fanboy-header.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-generic.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-thirdparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-firstparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-whitelists.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-intl.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-specific.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-exceptions.txt > $TESTDIR/fanboy-addon-merged.txt
       # English
       rm -rf $TESTDIR/fanboy-addon-merged-english.txt > /dev/null
       $CAT $TESTDIR/split/fanboy-addon/fanboy-header.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-generic.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-thirdparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-firstparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-whitelists.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-specific.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-exceptions.txt > $TESTDIR/fanboy-addon-merged-english.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-addon-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-addon/fanboy-addon-elements.txt $MAINDIR/split/fanboy-addon-elements.txt

              # Remove empty lines (International + English)
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-addon-merged.txt $TESTDIR/fanboy-addon-merged-english.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-addon-merged.txt $TESTDIR/fanboy-addon-merged-english.txt

              # Compress (International)
              #
              cp -f $TESTDIR/fanboy-addon-merged.txt $MAINDIR/fanboy-addon.txt
              rm -rf $MAINDIR/fanboy-addon.txt.gz
              $ZIP $MAINDIR/fanboy-addon.txt.gz $TESTDIR/fanboy-addon-merged.txt > /dev/null

              # Compress (English)
              #
              cp -f $TESTDIR/fanboy-addon-merged-english.txt $MAINDIR/fanboy-addon-english.txt
              rm -rf $MAINDIR/fanboy-addon-english.txt.gz
              $ZIP $MAINDIR/fanboy-addon-english.txt.gz $TESTDIR/fanboy-addon-merged-english.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # Remove temp files
              #
              rm -f $TESTDIR/split/fanboy-addon/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-addon-elements.txt: fanboy-addon-elements.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-addon-elements.txt" > /dev/null
    fi
else
  echo "fanboy-addon-whitelists.txt (fanboy-addon-elements.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-tracking-thirdparty.txt failed to update: $DATE"
fi

#######################################  fanboy-addon-elements-specific.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-addon/fanboy-addon-elements-specific.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-addon/fanboy-addon-elements-specific.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-addon-elements-specific.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        rm -rf $TESTDIR/fanboy-addon-merged.txt > /dev/null

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-addon/*.txt $TESTDIR/split/fanboy-addon

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-addon/*.txt

       $CAT $TESTDIR/split/fanboy-addon/fanboy-header.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-generic.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-thirdparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-firstparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-whitelists.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-intl.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-specific.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-exceptions.txt > $TESTDIR/fanboy-addon-merged.txt
       # English
       rm -rf $TESTDIR/fanboy-addon-merged-english.txt > /dev/null
       $CAT $TESTDIR/split/fanboy-addon/fanboy-header.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-generic.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-thirdparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-firstparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-whitelists.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-specific.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-exceptions.txt > $TESTDIR/fanboy-addon-merged-english.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-addon-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-addon/fanboy-addon-elements-specific.txt $MAINDIR/split/fanboy-addon-elements-specific.txt

              # Remove empty lines (International + English)
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-addon-merged.txt $TESTDIR/fanboy-addon-merged-english.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-addon-merged.txt $TESTDIR/fanboy-addon-merged-english.txt

              # Compress (International)
              #
              cp -f $TESTDIR/fanboy-addon-merged.txt $MAINDIR/fanboy-addon.txt
              rm -rf $MAINDIR/fanboy-addon.txt.gz
              $ZIP $MAINDIR/fanboy-addon.txt.gz $TESTDIR/fanboy-addon-merged.txt > /dev/null

              # Compress (English)
              #
              cp -f $TESTDIR/fanboy-addon-merged-english.txt $MAINDIR/fanboy-addon-english.txt
              rm -rf $MAINDIR/fanboy-addon-english.txt.gz
              $ZIP $MAINDIR/fanboy-addon-english.txt.gz $TESTDIR/fanboy-addon-merged-english.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # Remove temp files
              #
              rm -f $TESTDIR/split/fanboy-addon/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-addon-elements-specific.txt: fanboy-addon-elements-specific.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-addon-elements-specific.txt" > /dev/null
    fi
else
  echo "fanboy-addon-elements-specific.txt (fanboy-addon-elements-specific.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-tracking-elements-exceptions.txt failed to update: $DATE"
fi

#######################################  fanboy-addon-elements-exceptions.txt  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/fanboy-addon/fanboy-addon-elements-exceptions.txt" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/fanboy-addon/fanboy-addon-elements-exceptions.txt | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/fanboy-addon-elements-exceptions.txt | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        # Clean up
        #
        rm -rf $TESTDIR/fanboy-addon-merged.txt > /dev/null

        # Allow Temp dir so we can insert spaces..
        #
        cp -f $HGSERV/fanboy-addon/*.txt $TESTDIR/split/fanboy-addon

        # Add a space at the end of each file (before we cat it)
        #
        sed -i -e '$G' $TESTDIR/split/fanboy-addon/*.txt

       $CAT $TESTDIR/split/fanboy-addon/fanboy-header.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-generic.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-thirdparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-firstparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-whitelists.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-intl.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-specific.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-exceptions.txt > $TESTDIR/fanboy-addon-merged.txt
       # English
       rm -rf $TESTDIR/fanboy-addon-merged-english.txt > /dev/null
       $CAT $TESTDIR/split/fanboy-addon/fanboy-header.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-generic.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-thirdparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-firstparty.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-whitelists.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-specific.txt \
            $TESTDIR/split/fanboy-addon/fanboy-addon-elements-exceptions.txt > $TESTDIR/fanboy-addon-merged-english.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-addon-merged.txt" ]; then
              # Copy over
              #
              cp -f $HGSERV/fanboy-addon/fanboy-addon-elements-exceptions.txt $MAINDIR/split/fanboy-addon-elements-exceptions.txt

              # Remove empty lines (International + English)
              #
              sed -i -e '/^$/d' $TESTDIR/fanboy-addon-merged.txt $TESTDIR/fanboy-addon-merged-english.txt

              # Checksum
              #
              $ADDCHECKSUM $TESTDIR/fanboy-addon-merged.txt $TESTDIR/fanboy-addon-merged-english.txt

              # Compress (International)
              #
              cp -f $TESTDIR/fanboy-addon-merged.txt $MAINDIR/fanboy-addon.txt
              rm -rf $MAINDIR/fanboy-addon.txt.gz
              $ZIP $MAINDIR/fanboy-addon.txt.gz $TESTDIR/fanboy-addon-merged.txt > /dev/null

              # Compress (English)
              #
              cp -f $TESTDIR/fanboy-addon-merged-english.txt $MAINDIR/fanboy-addon-english.txt
              rm -rf $MAINDIR/fanboy-addon-english.txt.gz
              $ZIP $MAINDIR/fanboy-addon-english.txt.gz $TESTDIR/fanboy-addon-merged-english.txt > /dev/null

              # Fanboy Ultimate + Complete
              #
              $NICE $HGSERV/scripts/combine/firefox-adblock-ultimate.sh

              # Remove temp files
              #
              rm -f $TESTDIR/split/fanboy-addon/*.txt
        else
              # If the Cat fails.
              echo "Error creating file fanboy-addon-elements-exceptions.txt: fanboy-addon-elements-exceptions.txt - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-addon-elements-exceptions.txt" > /dev/null
    fi
else
  echo "fanboy-addon-elements-exceptions.txt (fanboy-addon-elements-exceptions.txt) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-tracking-elements-exceptions.txt failed to update: $DATE"
fi

#######################################  fanboy-adblocklist-elements-v4.css  #######################################
# Make sure the file exists, and the work directorys are also there before processing.
#
if [ -s "$HGSERV/other/opera-addon.css" ] && [ -d "$TESTDIR" ] && [ -d "$MAINDIR" ] && [ -d "$HGSERV" ];
  then
   # Compare differences, only process if file has changed..
   #
   SSLHG=$($SHA256SUM $HGSERV/other/opera-addon.css | cut -d' ' -f1)
   SSLMAIN=$($SHA256SUM $MAINDIR/split/opera-addon.css | cut -d' ' -f1)
   #
   if [ "$SSLHG" != "$SSLMAIN" ]
     then
        rm -rf $TESTDIR/fanboy-opera-css.txt
        # Copy over
        #
        cp -f $HGSERV/other/opera-addon.css $MAINDIR/split/opera-addon.css

        # Add New line
        #
        sed -e '$a\' $HGSERV/opera/opera-header.txt > $TESTDIR/opera-header2.txt
        sed -e '$a\' $HGSERV/fanboy-adblock/fanboy-elements-generic.txt > $TESTDIR/fanboy-elements-generic3.txt

        # Remove top lines
        #
        sed '1,3d' $TESTDIR/fanboy-elements-generic3.txt > $TESTDIR/fanboy-elements-generic.txt

        # the magic, remove ## and #. and add , to each line
        #
        cat $TESTDIR/fanboy-elements-generic.txt | sed 's/^..\(.*\)$/\1,/' > $TESTDIR/fanboy-css.txt

        # Combine
        #
        cat $TESTDIR/opera-header2.txt $TESTDIR/fanboy-css.txt $HGSERV/other/opera-addon.css > $TESTDIR/fanboy-opera-css.txt

        # Make sure the file exists
        #
        if [ -s "$TESTDIR/fanboy-opera-css.txt" ]; then

          # Remove selected lines (be very specific, include comma)
          # sed -i '/#testfilter,/d' $TESTDIR/opera-addon.css
          sed -i '/.ad-vertical-container/d' $TESTDIR/fanboy-opera-css.txt

          # Remove any trailing blank lines, or blank lines in front
          #
          sed -i -e 's/^[ \t]*//;s/[ \t]*$//' $TESTDIR/fanboy-opera-css.txt

          # Remove empty lines
          #
          sed -i -e '/^$/d' $TESTDIR/fanboy-opera-css.txt

          # Checksum
          #
          $ADDCHECKSUM $TESTDIR/fanboy-opera-css.txt

          # Compress
          #
          cp -f $TESTDIR/fanboy-opera-css.txt $MAINDIR/opera/fanboy-adblocklist-elements-v4.css
          rm -rf $MAINDIR/opera/fanboy-adblocklist-elements-v4.css.gz
          $ZIP $MAINDIR/opera/fanboy-adblocklist-elements-v4.css.gz $TESTDIR/fanboy-opera-css.txt > /dev/null

          # Remove temp files
          #
          rm -rf $TESTDIR/opera-header2.txt $TESTDIR/fanboy-elements-generic3.txt $TESTDIR/fanboy-opera-css.txt $TESTDIR/fanboy-elements-generic.txt
        else
          # If the Cat fails.
          echo "Error creating file fanboy-adblocklist-elements-v4.css: fanboy-adblocklist-elements-v4.css - $DATE" >> $LOGFILE
        fi
    else
        # File check hg vs secure.fanboy.co.nz
        echo "Files are the same: fanboy-adblocklist-elements-v4.css" > /dev/null
    fi
else
  echo "fanboy-generic (fanboy-adblocklist-elements-v4.css) failed to update: $DATE" >> $LOGFILE
  # twidge update "fanboy-generic.txt failed to update: $DATE"
fi


############### Fanboy Enhanced Trackers #################
SSLHG=$($SHA256SUM $HGSERV/enhancedstats-addon.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/enhancedstats.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    # Copy list
    cp -f $HGSERV/enhancedstats-addon.txt $TESTDIR/enhancedstats.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/enhancedstats.txt
    cp -f $TESTDIR/enhancedstats.txt $MAINDIR/enhancedstats.txt
    rm -rf $MAINDIR/enhancedstats.txt.gz
    # GZip
    $ZIP $MAINDIR/enhancedstats.txt.gz $TESTDIR/enhancedstats-addon.txt > /dev/null
    # Combine Regional trackers
    # $HGSERV/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    # $HGSERV/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $HGSERV/scripts/combine/firefox-adblock-ultimate.sh
    # Firefox2Opera
    # # $NICE $HGSERV/scripts/firefox2opera.sh
else
   echo "Files are the same: enhancedstats.txt" > /dev/null
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
   # $HGSERV/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   # $HGSERV/scripts/ie/czech-ie-generator.sh
   # Combine
   # $HGSERV/scripts/combine/firefox-adblock-czech.sh
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
   # $HGSERV/scripts/ie/russian-ie-generator.sh
   # Combine
   # $HGSERV/scripts/combine/firefox-adblock-rus.sh
   # Generate Opera RUS script also
   # $HGSERV/scripts/firefox/opera-russian.sh
else
   echo "Files are the same: fanboy-russian.txt" > /dev/null
fi

############### Fanboy Turkish #################
SSLHG=$($SHA256SUM $HGSERV/firefox-regional/fanboy-adblocklist-tky.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-turkish.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
   cp -f $HGSERV/firefox-regional/fanboy-adblocklist-tky.txt $TESTDIR/fanboy-turkish.txt
   # Re-generate checksum
   $ADDCHECKSUM $TESTDIR/fanboy-turkish.txt
   cp -f $TESTDIR/fanboy-turkish.txt $MAINDIR/fanboy-turkish.txt
   # Wipe old files
   rm -rf $MAINDIR/fanboy-turkish.txt.gz
   $ZIP $MAINDIR/fanboy-turkish.txt.gz $TESTDIR/fanboy-turkish.txt > /dev/null
   # Combine Regional trackers
   # $HGSERV/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   # $HGSERV/scripts/ie/turkish-ie-generator.sh
   # Combine
   # $HGSERV/scripts/combine/firefox-adblock-turk.sh
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
   # $HGSERV/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   # $HGSERV/scripts/ie/japanese-ie-generator.sh
   # Combine
   # $HGSERV/scripts/combine/firefox-adblock-jpn.sh
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
    # $HGSERV/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    # $HGSERV/scripts/combine/firefox-adblock-krn.sh
else
   echo "Files are the same: fanboy-korean.txt" > /dev/null
fi

############### Fanboy ITALIAN #################
SSLHG=$($SHA256SUM $HGSERV/firefox-regional/fanboy-adblocklist-ita.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-italian.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    cp -f $HGSERV/firefox-regional/fanboy-adblocklist-ita.txt $TESTDIR/fanboy-italian.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/fanboy-italian.txt
    cp -f $TESTDIR/fanboy-italian.txt $MAINDIR/fanboy-italian.txt
    $ZIP $MAINDIR/fanboy-italian.txt.gz $TESTDIR/fanboy-italian.txt > /dev/null
    # Combine Regional trackers
    # $HGSERV/scripts/combine/firefox-adblock-intl-tracking.sh
    # Generate IE script
    # $HGSERV/scripts/ie/italian-ie-generator.sh
    # Combine
    # $HGSERV/scripts/combine/firefox-adblock-ita.sh
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
    # $HGSERV/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    # $HGSERV/scripts/combine/firefox-adblock-pol.sh
else
   echo "Files are the same: fanboy-polish.txt" > /dev/null
fi

############### Fanboy INDIAN #################
SSLHG=$($SHA256SUM $HGSERV/firefox-regional/fanboy-adblocklist-ind.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-indian.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    cp -f $HGSERV/firefox-regional/fanboy-adblocklist-ind.txt $TESTDIR/fanboy-indian.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/fanboy-indian.txt 
    cp -f $TESTDIR/fanboy-indian.txt $MAINDIR/fanboy-indian.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-indian.txt.gz
    $ZIP $MAINDIR/fanboy-indian.txt.gz $TESTDIR/fanboy-indian.txt > /dev/null
    # Combine Regional trackers
    # $HGSERV/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    # $HGSERV/scripts/combine/firefox-adblock-ind.sh
else
   echo "Files are the same: fanboy-indian.txt" > /dev/null
fi

############### Fanboy VIETNAM #################
SSLHG=$($SHA256SUM $HGSERV/firefox-regional/fanboy-adblocklist-vtn.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-vietnam.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    cp -f $HGSERV/firefox-regional/fanboy-adblocklist-vtn.txt $TESTDIR/fanboy-vietnam.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/fanboy-vietnam.txt
    cp -f $TESTDIR/fanboy-vietnam.txt $MAINDIR/fanboy-vietnam.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-vietnam.txt.gz
    $ZIP $MAINDIR/fanboy-vietnam.txt.gz $TESTDIR/fanboy-vietnam.txt > /dev/null
    # Combine Regional trackers
    # $HGSERV/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    # $HGSERV/scripts/combine/firefox-adblock-vtn.sh
else
   echo "Files are the same: fanboy-vietnam.txt" > /dev/null
fi

############### Fanboy ESPANOL #################
SSLHG=$($SHA256SUM $HGSERV/firefox-regional/fanboy-adblocklist-esp.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-espanol.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    cp -f $HGSERV/firefox-regional/fanboy-adblocklist-esp.txt $TESTDIR/fanboy-espanol.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/fanboy-espanol.txt
    cp -f $TESTDIR/fanboy-espanol.txt $MAINDIR/fanboy-espanol.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-espanol.txt.gz
    $ZIP $MAINDIR/fanboy-espanol.txt.gz $TESTDIR/fanboy-espanol.txt > /dev/null
    # Combine Regional trackers
    # $HGSERV/scripts/combine/firefox-adblock-intl-tracking.sh
		# Generate IE script
		# $HGSERV/scripts/ie/espanol-ie-generator.sh
		# Combine
		# $HGSERV/scripts/combine/firefox-adblock-esp.sh
else
   echo "Files are the same: fanboy-espanol.txt" > /dev/null
fi

############### Fanboy SWEDISH #################
SSLHG=$($SHA256SUM $HGSERV/firefox-regional/fanboy-adblocklist-swe.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-swedish.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    cp -f $HGSERV/firefox-regional/fanboy-adblocklist-swe.txt $TESTDIR/fanboy-swedish.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/fanboy-swedish.txt
    cp -f $TESTDIR/fanboy-swedish.txt $MAINDIR/fanboy-swedish.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-swedish.txt.gz
    $ZIP $MAINDIR/fanboy-swedish.txt.gz $TESTDIR/fanboy-swedish.txt > /dev/null
    # Combine Regional trackers
    # $HGSERV/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    # $HGSERV/scripts/combine/firefox-adblock-swe.sh
else
   echo "Files are the same: fanboy-swedish.txt" > /dev/null
fi

############### Fanboy ISRAELI #################
SSLHG=$($SHA256SUM $HGSERV/firefox-regional/IsraelList.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/IsraelList.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    cp -f $HGSERV/firefox-regional/IsraelList.txt $TESTDIR/IsraelList.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/IsraelList.txt
    cp -f $TESTDIR/IsraelList.txt $MAINDIR/IsraelList.txt
    # Wipe old files
    rm -rf $MAINDIR/IsraelList.txt.gz
    $ZIP $MAINDIR/IsraelList.txt.gz $TESTDIR/IsraelList.txt > /dev/null
    # Combine Regional trackers
    # $HGSERV/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    # $HGSERV/scripts/combine/
else
   echo "Files are the same: IsraelList.txt" > /dev/null
fi