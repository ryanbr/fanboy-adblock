#!/bin/bash
#
# Fanboy Adblock list grabber script v2.50 (27/01/2013)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Version history
#
# 2.50 Ultimate/Complete list based on merged list
# 2.40 Include test Easylist sub generator
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
export MAINDIR="/var/www/adblock"
export SPLITDIR="/var/www/adblock/split/test"
export HGSERV="/root/fanboy-adblock-list"
export TESTDIR="/root/tmp/work"
export DATE="`date`"
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export TWIDGE="/usr/bin/twidge update"
export IEDIR="/var/test/tmp/work/ie"
export IESUBS="/var/test/ie/subscriptions"
export EASYLIST="/root/easylist/easylist/easylistfanboy/fanboy-adblock"

# Test for Ram disks
#
#if [ ! -d "/tmp/work/" ]; then
#  rm -rf /tmp/work/
#  mkdir /tmp/work; chmod 777 /tmp/work
#  mount -t tmpfs -o size=50M tmpfs /tmp/work/
#fi

#if [ ! -d "/tmp/work/opera" ]; then
#  mkdir /tmp/work/opera; chmod 777 /tmp/work/opera
#  mkdir /tmp/work/opera/test; chmod 777 /tmp/work/opera/test
#fi

#if [ ! -d "/tmp/work/opera/test" ]; then
#  mkdir /tmp/work/opera/test; chmod 777 /tmp/work/opera/test
#fi

#if [ ! -d "/tmp/work/split" ]; then
#  mkdir /tmp/work/split; chmod 777 /tmp/work/split
#  mkdir /tmp/work/split/fanboy-adblock; chmod 777 /tmp/work/split/fanboy-adblock
#  mkdir /tmp/work/split/fanboy-addon; chmod 777 /tmp/work/split/fanboy-addon
#  mkdir /tmp/work/split/fanboy-tracking; chmod 777 /tmp/work/split/fanboy-tracking
#fi

#if [ ! -d "/tmp/Ramdisk/" ]; then
#  rm -rf /tmp/Ramdisk/
#  mkdir /tmp/Ramdisk; chmod 777 /tmp/Ramdisk
#  mount -t tmpfs -o size=110M tmpfs /tmp/Ramdisk/
#fi

#if [ ! -d "/tmp/ieramdisk/subscriptions" ]; then
#  rm -rf /tmp/ieramdisk/subscriptions
#  mkdir /tmp/ieramdisk; chmod 777 /tmp/ieramdisk
#  mount -t tmpfs -o size=30M tmpfs /tmp/ieramdisk
#  mkdir /tmp/ieramdisk/subscriptions; chmod 777 /tmp/ieramdisk/subscriptions
#fi

#if [ ! -d "/tmp/Ramdisk/www/adblock/split" ]; then
#  mkdir /tmp/Ramdisk/www/adblock/split; chmod 777 /tmp/Ramdisk/www/adblock/split
#fi

# Check mirror dir exists and its not a symlink
#
#if [ -d "/var/hgstuff/fanboy-adblock-list" ] && [ -h "/tmp/hgstuff" ]; then
#    export HGSERV="/var/hgstuff/fanboy-adblock-list"
#    echo "HGSERV=/var/hgstuff/fanboy-adblock-list"
#    cd /tmp/hgstuff/fanboy-adblock-list
#    $NICE $HG pull
#    $NICE $HG update
#  else
#    # If not, its stored here
#    export HGSERV="/tmp/hgstuff/fanboy-adblock-list"
#    echo "HGSERV=/tmp/hgstuff/fanboy-adblock-list"
#    cd /tmp/hgstuff/fanboy-adblock-list
#    $NICE $HG pull
#    $NICE $HG update
#fi

#if [ -d "/root/easylist/easylist" ]; then
#    cd /root/easylist/easylist
#    $NICE $HG pull
#    $NICE $HG update
#fi

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

############### Fanboy Anti-facebook #################
SSLHG=$($SHA256SUM $HGSERV/fanboy-antifacebook.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-antifacebook.txt | cut -d' ' -f1)

if [ "$SSLHG" != "$SSLMAIN" ]
then
    # Copy list
    cp -f $HGSERV/fanboy-antifacebook.txt $TESTDIR/fanboy-antifacebook.txt
    # Re-generate checksum
    $ADDCHECKSUM $TESTDIR/fanboy-antifacebook.txt
    cp -f $TESTDIR/fanboy-antifacebook.txt $MAINDIR/fanboy-antifacebook.txt
    rm -rf $MAINDIR/fanboy-antifacebook.txt.gz
    # GZip
    $ZIP $MAINDIR/fanboy-antifacebook.txt.gz $TESTDIR/fanboy-antifacebook.txt > /dev/null
else
   echo "Files are the same: fanboy-antifacebook.txt" > /dev/null
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
   cp -f $TESTDIR/fanboy-japanese.txt $MAINDIR/fanboy-japanese.txt
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