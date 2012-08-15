#!/bin/bash
#
# Fanboy Adblock list grabber script v1.8 (15/08/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Version history
#
# 1.81 Misc Cleanups
# 1.8  Allow list to be stored in ramdisk
# 1.752 Declare global variables
# 1.751 Remove Shred, and cleanup variable names
# 1.75 Store log in ramdisk to avoid unnessary writes (Currently disabled)
# 1.74 Store repo in ramdisk to avoid unnessary writes (Currently disabled)
#
# Variables for directorys
#
export MAINDIR="/tmp/Ramdisk/www"
export GOOGLEDIR="/tmp/hgstuff/fanboy-adblock-list"
export TESTDIR="/tmp/work"
export ZIP="nice -n 19 /usr/local/bin/7za"
export NICE="nice -n 19"
export LOGFILE="/etc/crons/log-listgrabber.txt"
export DATE="`date`"
export ECHORESPONSE="List Changed: $LS2"
export BADUPDATE="Bad Update: $LS2"
export LS2="`ls -al $FILE`"
export SHA256SUM="/usr/bin/sha256sum"
export HG="/usr/local/bin/hg"
export TAIL="/usr/bin/tail"
export LOGFILE2="/var/log/adblock-log.txt"
export TEMPLOGFILE="/tmp/Ramdisk/www/adblock.log"
export IEDIR="/tmp/ieramdisk"
export SUBS="/tmp/ieramdisk/subscriptions"
export IRONDIR="$MAINDIR/www/adblock/iron"

# Make Ramdisk.
#
$GOOGLEDIR/scripts/ramdisk.sh
# Fallback if ramdisk.sh isn't excuted.
#
if [ ! -d "/tmp/work/" ]; then
  rm -rf /tmp/work/
  mkdir /tmp/work; chmod 777 /tmp/work
  mount -t tmpfs -o size=30M tmpfs /tmp/work/
  cp -rf $MAINDIR/addChecksum.pl $TESTDIR
  mkdir /tmp/work/opera; chmod 777 /tmp/work/opera
  mkdir /tmp/work/opera/test; chmod 777 /tmp/work/opera/test
fi

# Make sure Addchecksum is loaded
#
if [ ! -d "$TESTDIR/addChecksum.pl" ]; then
   cp -rf $GOOGLEDIR/scripts/addChecksum.pl $TESTDIR
   cp -rf $GOOGLEDIR/scripts/addChecksum-opera.pl $TESTDIR
   cp -rf $GOOGLEDIR/scripts/addChecksum-opera.pl $TESTDIR/opera
fi

# Fallback if ramdisk.sh isn't excuted. (mercurial repo in ramdisk)

#if [ ! -d "/tmp/hg-ramdisk/" ]; then
#  rm -rf /tmp/hg-ramdisk/
#  mkdir /tmp/hg-ramdisk; chmod 777 /tmp/hg-ramdisk
#  mount -t tmpfs -o size=110M tmpfs /tmp/hg-ramdisk/
#  cd /home/fanboy/google/fanboy-adblock-list/
#  $NICE $HG pull >> /dev/null
#  $NICE $HG update >> /dev/null
#  cp -rf /home/fanboy/google/fanboy-adblock-list/ /tmp/hg-ramdisk/
# fi

# Fallback if ramdisk.sh isn't excuted. (mercurial repo in ramdisk)
#
#if [ ! -d "/tmp/hg-log/" ]; then
#  rm -rf /tmp/hg-log/
#  mkdir /tmp/hg-log; chmod 777 /tmp/hg-log
#  mount -t tmpfs -o size=10M tmpfs /tmp/hg-log/
#  rm -rf $LOGFILE2 ; cd /var/www ; ln -s /tmp/hg-log/adblock.log .
#fi

# Make sure the shell scripts are exexcutable, all the time..
#
chmod a+x $GOOGLEDIR/scripts/ie/*.sh $GOOGLEDIR/scripts/iron/*.sh $GOOGLEDIR/scripts/*.sh $GOOGLEDIR/scripts/firefox/*.sh $GOOGLEDIR/scripts/combine/*.sh

# Grab Mercurial Updates
#
cd $GOOGLEDIR
echo "------------------------- Start of script -------------------------" >> $LOGFILE2
echo "Updated hg (hg pull ; hg update (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
$NICE $HG pull >> $LOGFILE2
$NICE $HG update >> $LOGFILE2
echo "------ End of hg pull and Update ------" >> $LOGFILE2

# Log Changes
# 
$NICE $TAIL -n 6000 $LOGFILE2 > $TEMPLOGFILE



#$NICE tac $LOGFILE2 | head -n 6000 > /var/www/adblock.log

# Main List
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-adblock.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-adblock.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $SSLGOOGLE"

#
if [ "$SSLGOOGLE" != "$SSLMAIN" ]
 then
    # Log
    echo "Googles copy: `ls -al $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt`" >> $LOGFILE2
    echo "Local copy: `ls -al $MAINDIR/fanboy-adblock.txt`" >> $LOGFILE2
    echo "Googles copy: `cat $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt | grep Checksum: ;echo HASH: $SSLGOOGLE`" >> $LOGFILE2
    echo "Local copy: `cat $MAINDIR/fanboy-adblock.txt | grep Checksum: ;echo HASH: $SSLMAIN`" >> $LOGFILE2
    echo "Updated fanboy-adblock.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    # Write patch to log file
    #
    echo " " >> $LOGFILE2
    echo "Changes to File: fanboy-adblock.txt" >> $LOGFILE2
    $NICE diff -Naur $MAINDIR/fanboy-adblock.txt $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt > $TESTDIR/fanboy-adblock.patch
    cat $TESTDIR/fanboy-adblock.patch >> $LOGFILE2
    echo " " >> $LOGFILE2
    ## DEBUG
    ### echo "Updated: fanboy-adblock.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-adblock.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $SSLGOOGLE"
    # Make sure the old copy is cleared before we start
    rm -f $TESTDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-adblock.txt
    # Copy to ram disk first. (quicker)
    cp -f $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $TESTDIR/fanboy-adblock.txt
    # Re-generate checksum
    perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-adblock.txt
    cp -f $TESTDIR/fanboy-adblock.txt $MAINDIR/fanboy-adblock.txt
    # Compress file in Ram disk
    $ZIP a -mx=9 -y -tgzip $TESTDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-adblock.txt > /dev/null
    # Clear Webhost-copy before copying
    rm -f $MAINDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-adblock.patch
    
    # Now Copy over GZip'd list
    cp -f $TESTDIR/fanboy-adblock.txt.gz $MAINDIR/fanboy-adblock.txt.gz
    # perl $TESTDIR/addChecksum.pl $TESTDIR/firefox-expanded.txt-org2
    # cp -f $TESTDIR/firefox-expanded.txt-org2 $MAINDIR/fanboy-adblock.txt
    # cp -f $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $MAINDIR/fanboy-adblock.txt
    # cp -f $TESTDIR/fanboy-adblocklist-current-expanded.txt $MAINDIR/fanboy-adblock.txt

    # The Dimensions List
    ### echo "Updated: fanboy-dimensions.txt"
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-dimensions.sh

    # The Adult List
    ### echo "Updated: fanboy-adult.txt"
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-adult.sh

    # The P2P List
    ### echo "Updated: fanboy-p2p.txt"
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-p2p.sh

    # Seperate off CSS elements for Opera CSS
    ### echo "Updated: fanboy-element-opera-generator.sh"
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-element-opera-generator.sh

    # Seperate off Elements
    ### echo "Updated: fanboy-noele.sh"
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-noele.sh

    # Combine (Czech)
    ### echo "Combine: firefox-adblock-czech.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-czech.sh
    # Combine (Espanol)
    ### echo "Combine: firefox-adblock-esp.sh"
		$NICE $GOOGLEDIR/scripts/combine/firefox-adblock-esp.sh
    # Combine (Russian)
    ### echo "Combine: firefox-adblock-rus.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-rus.sh
    # Combine (Japanese)
    ### echo "Combine: firefox-adblock-jpn.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-jpn.sh
    # Combine (Swedish)
    ### echo "Combine: firefox-adblock-swe.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-swe.sh
    # Combine (Chinese)
    ### echo "Combine: firefox-adblock-chn.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-chn.sh
    # Combine (Vietnam)
    ### echo "Combine: firefox-adblock-vtn.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-vtn.sh
    # Combine (Vietnam)
    ### echo "Combine: firefox-adblock-krn.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-krn.sh
    # Combine (Turkish)
    ### echo "Combine: firefox-adblock-turk.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-turk.sh
    # Combine (Italian)
    ### echo "Combine: firefox-adblock-ita.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-ita.sh
    # Combine (Polish)
    ### echo "Combine: firefox-adblock-pol.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-pol.sh
    # Combine (Indian)
    ### echo "Combine: firefox-adblock-ind.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-ind.sh
    # Combine Regional trackers
    ### echo "Combine: firefox-adblock-intl-tracking.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    ### echo "Combine: firefox-adblock-tracking.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-tracking.sh
    ### echo "Combine: firefox-adblock-merged.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    ### echo "Combine: firefox-adblock-ultimate.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-ultimate.sh
    # Firefox2Opera
    # $NICE $GOOGLEDIR/scripts/firefox2opera.sh
else
    echo "Files are the same: fanboy-adblock.txt" > /dev/null
    ## DEBUG
    ### echo Not Processed
    ### echo "SSLMAIN: $MAINDIR/fanboy-adblock.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-adblock.txt $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt
fi

# Tracking List
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/fanboy-adblocklist-stats.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-tracking.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-tracking.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-stats.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-tracking.txt $GOOGLEDIR/fanboy-adblocklist-stats.txt

# Tracking
# Check for 0-sized file first
#
if [ "$SSLGOOGLE" != "$SSLMAIN" ]
 then
    # Log
    echo "Updated fanboy-tracking.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    echo "Googles copy: `ls -al $GOOGLEDIR/fanboy-adblocklist-stats.txt`" >> $LOGFILE2
    echo "Local copy: `ls -al $MAINDIR/fanboy-tracking.txt`" >> $LOGFILE2
    # Write patch to log file
    #
    echo " " >> $LOGFILE2
    echo "Changes to File: fanboy-tracking.txt" >> $LOGFILE2
    $NICE diff -Naur $MAINDIR/fanboy-tracking.txt $GOOGLEDIR/fanboy-adblocklist-stats.txt > $TESTDIR/fanboy-tracking.patch
    $NICE cat $TESTDIR/fanboy-tracking.patch >> $LOGFILE2
    echo " " >> $LOGFILE2
    ## DEBUG
    ### echo "Updated: fanboy-tracking.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-tracking.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-stats.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-tracking.txt $GOOGLEDIR/fanboy-adblocklist-stats.txt
    # Clear old list
    rm -f $TESTDIR/fanboy-tracking.txt.gz $TESTDIR/fanboy-tracking.txt
    # Copy list from repo to RAMDISK
    cp -f $GOOGLEDIR/fanboy-adblocklist-stats.txt $TESTDIR/fanboy-tracking.txt
    # Re-generate checksum
    perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-tracking.txt
    # GZip
    $ZIP a -mx=9 -y -tgzip $TESTDIR/fanboy-tracking.txt.gz $TESTDIR/fanboy-tracking.txt > /dev/null
    # Create a log
    FILE="$TESTDIR/fanboy-tracking.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Clear Webhost-copy before copying and Copy over GZip'd list
    cp -f $TESTDIR/fanboy-tracking.txt $MAINDIR/fanboy-tracking.txt
    rm -f $MAINDIR/fanboy-tracking.txt.gz $TESTDIR/fanboy-tracking.patch
    cp -f $TESTDIR/fanboy-tracking.txt.gz $MAINDIR/fanboy-tracking.txt.gz
    # Now combine with international list
    sh /etc/crons/hg-grab-intl.sh
    # Generate IE script
    $GOOGLEDIR/scripts/ie/tracking-ie-generator.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-tracking.sh
    $GOOGLEDIR/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $GOOGLEDIR/scripts/combine/firefox-adblock-ultimate.sh
    # Firefox2Opera
    # $NICE $GOOGLEDIR/scripts/firefox2opera.sh
else
   echo "Files are the same: fanboy-tracking.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-tracking.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-stats.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-tracking.txt $GOOGLEDIR/fanboy-adblocklist-stats.txt
fi

# Enhanced Trackers
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/enhancedstats-addon.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/enhancedstats.txt-org | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/enhancedstats.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/enhancedstats-addon.txt $SSLGOOGLE"
### ls -al $MAINDIR/enhancedstats.txt $GOOGLEDIR/enhancedstats-addon.txt

if [ "$SSLGOOGLE" != "$SSLMAIN" ]
then
    # Log
    echo "Updated enhancedstats.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    echo "Googles copy: `ls -al $GOOGLEDIR/enhancedstats-addon.txt`" >> $LOGFILE2
    echo "Local copy: `ls -al $MAINDIR/enhancedstats.txt-org`" >> $LOGFILE2
    # Write patch to log file
    #
    echo " " >> $LOGFILE2
    echo "Changes to File: fanboy-enhancedstats.txt" >> $LOGFILE2
    $NICE diff -Naur $MAINDIR/enhancedstats.txt-org $GOOGLEDIR/enhancedstats-addon.txt > $TESTDIR/fanboy-enhancedtracking.patch
    $NICE cat $TESTDIR/fanboy-enhancedtracking.patch >> $LOGFILE2
    echo " " >> $LOGFILE2
    ## DEBUG
    ### echo "Updated: enhancedstats-addon.txt"
    ### echo "SSLMAIN: $MAINDIR/enhancedstats.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/enhancedstats-addon.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/enhancedstats.txt $GOOGLEDIR/enhancedstats-addon.txt
    # Clear old list
    rm -f $TESTDIR/enhancedstats.txt $TESTDIR/enhancedstats.txt.gz
    # Copy list from repo to RAMDISK
    cp -f $GOOGLEDIR/enhancedstats-addon.txt $TESTDIR/enhancedstats.txt
    # Copy Orginal file over
    cp -f $GOOGLEDIR/enhancedstats-addon.txt $MAINDIR/enhancedstats.txt-org
    # GZip
    $ZIP a -mx=9 -y -tgzip $TESTDIR/enhancedstats.txt.gz $TESTDIR/enhancedstats.txt > /dev/null
    # Create a log
    FILE="$TESTDIR/enhancedstats.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Clear Webhost-copy before copying and now Copy over GZip'd list
    cp -f $TESTDIR/enhancedstats.txt $MAINDIR/enhancedstats.txt
    rm -f $MAINDIR/enhancedstats.txt.gz $TESTDIR/fanboy-enhancedtracking.patch
    cp -f $TESTDIR/enhancedstats.txt.gz $MAINDIR/enhancedstats.txt.gz
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $GOOGLEDIR/scripts/combine/firefox-adblock-ultimate.sh
    # Firefox2Opera
    # $NICE $GOOGLEDIR/scripts/firefox2opera.sh
else
   echo "Files are the same: enhancedstats.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/enhancedstats.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/enhancedstats-addon.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/enhancedstats.txt $GOOGLEDIR/enhancedstats-addon.txt

fi

# Addon/Annoyances
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/fanboy-adblocklist-addon.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-addon.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-addon.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-addon.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-addon.txt $GOOGLEDIR/fanboy-adblocklist-addon.txt

if [ "$SSLGOOGLE" != "$SSLMAIN" ]
then
    # Log
    echo "Updated fanboy-addon.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    echo "Googles copy: `ls -al $GOOGLEDIR/fanboy-adblocklist-addon.txt`" >> $LOGFILE2
    echo "Local copy: `ls -al $MAINDIR/fanboy-addon.txt`" >> $LOGFILE2
    # Write patch to log file
    #
    echo " " >> $LOGFILE2
    echo "Changes to File: fanboy-annoyances.txt" >> $LOGFILE2
    $NICE diff -Naur $MAINDIR/fanboy-addon.txt $GOOGLEDIR/fanboy-adblocklist-addon.txt > $TESTDIR/fanboy-annoy.patch
    $NICE cat $TESTDIR/fanboy-annoy.patch >> $LOGFILE2
    echo " " >> $LOGFILE2
    ## DEBUG
    ### echo "Updated: fanboy-addon.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-addon.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-addon.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-addon.txt $GOOGLEDIR/fanboy-adblocklist-addon.txt
    # Clear old list
    rm -f $TESTDIR/fanboy-addon.txt $TESTDIR/fanboy-addon.txt.gz 
    # Copy list from repo to RAMDISK
    cp -f $GOOGLEDIR/fanboy-adblocklist-addon.txt $TESTDIR/fanboy-addon.txt
    # GZip
    $ZIP a -mx=9 -y -tgzip $TESTDIR/fanboy-addon.txt.gz $TESTDIR/fanboy-addon.txt > /dev/null
    # Create a log
    FILE="$TESTDIR/fanboy-addon.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Clear Webhost-copy before copying and now Copy over GZip'd list
    cp -f $TESTDIR/fanboy-addon.txt $MAINDIR/fanboy-addon.txt
    rm -f $MAINDIR/fanboy-addon.txt.gz $TESTDIR/fanboy-annoy.patch
    cp -f $TESTDIR/fanboy-addon.txt.gz $MAINDIR/fanboy-addon.txt.gz
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $GOOGLEDIR/scripts/combine/firefox-adblock-ultimate.sh
    # Firefox2Opera
    # $NICE $GOOGLEDIR/scripts/firefox2opera.sh
else
   echo "Files are the same: fanboy-addon.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-addon.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-addon.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-addon.txt $GOOGLEDIR/fanboy-adblocklist-addon.txt
fi

# CZECH
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-czech.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-czech.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt $SSLGOOGLE"

if [ "$SSLGOOGLE" != "$SSLMAIN" ]
then
   # Log
   echo "Updated fanboy-czech.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
   echo "Googles copy: `ls -al $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt`" >> $LOGFILE2
   echo "Local copy: `ls -al $MAINDIR/fanboy-czech.txt`" >> $LOGFILE2
    # Write patch to log file
    #
   echo " " >> $LOGFILE2
   echo "Changes to File: fanboy-czech.txt" >> $LOGFILE2
   $NICE diff -Naur $MAINDIR/fanboy-czech.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt > $TESTDIR/fanboy-czech.patch
   $NICE cat $TESTDIR/fanboy-czech.patch >> $LOGFILE2
   echo " " >> $LOGFILE2
   ## DEBUG
   ### echo "Updated: fanboy-czech.txt"
   ### echo "SSLMAIN: $MAINDIR/fanboy-czech.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-czech.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt $MAINDIR/fanboy-czech.txt
   # Wipe old files
   rm -rf $MAINDIR/fanboy-czech.txt.gz $TESTDIR/fanboy-czech.patch
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-czech.txt.gz $MAINDIR/fanboy-czech.txt > /dev/null
   # Create a log
   FILE="$MAINDIR/fanboy-czech.txt"
   echo $ECHORESPONSE >> $LOGFILE
   # Combine Regional trackers
   $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $GOOGLEDIR/scripts/ie/czech-ie-generator.sh
   # Combine
   $GOOGLEDIR/scripts/combine/firefox-adblock-czech.sh
   # Remove uneeded file
   rm -rf $TESTDIR/fanboy-czech.patch
else
   echo "Files are the same: fanboy-czech.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-czech.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-czech.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt
fi

# RUSSIAN
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-russian.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-russian.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-russian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt

if [ "$SSLGOOGLE" != "$SSLMAIN" ]
then
   # Log
   echo "Updated fanboy-russian.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
   echo "Googles copy: `ls -al $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt`" >> $LOGFILE2
   echo "Local copy: `ls -al $MAINDIR/fanboy-russian.txt`" >> $LOGFILE2
    # Write patch to log file
    #
   echo " " >> $LOGFILE2
   echo "Changes to File: fanboy-russian.txt" >> $LOGFILE2
   $NICE diff -Naur $MAINDIR/fanboy-russian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt > $TESTDIR/fanboy-russian.patch
   $NICE cat $TESTDIR/fanboy-russian.patch >> $LOGFILE2
   echo " " >> $LOGFILE2
   ## DEBUG
   ### echo "Updated: fanboy-russian.txt"
   ### echo "SSLMAIN: $MAINDIR/fanboy-russian.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-russian.txtt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt $MAINDIR/fanboy-russian.txt
   # Wipe old files
   rm -rf  $MAINDIR/fanboy-russian.txt.gz $TESTDIR/fanboy-russian.patch
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-russian.txt.gz $MAINDIR/fanboy-russian.txt > /dev/null
   # Create a log
   FILE="$MAINDIR/fanboy-russian.txt"
   echo $ECHORESPONSE >> $LOGFILE
   # Combine Regional trackers
   $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $GOOGLEDIR/scripts/ie/russian-ie-generator.sh
   # Combine
   $GOOGLEDIR/scripts/combine/firefox-adblock-rus.sh
   # Generate Opera RUS script also
   $GOOGLEDIR/scripts/firefox/opera-russian.sh
else
   echo "Files are the same: fanboy-russian.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-russian.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-russian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt
fi

# TURK
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-turkish.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-turkish.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-turkish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt

if [ "$SSLGOOGLE" != "$SSLMAIN" ]
then
   # Log
   echo "Updated fanboy-turkish.txt (sctipt: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
   echo "Googles copy: `ls -al $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt`" >> $LOGFILE2
   echo "Local copy: `ls -al $MAINDIR/fanboy-turkish.txt`" >> $LOGFILE2
    # Write patch to log file
    #
   echo " " >> $LOGFILE2
   echo "Changes to File: fanboy-turkish.txt" >> $LOGFILE2
   $NICE diff -Naur $MAINDIR/fanboy-turkish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt > $TESTDIR/fanboy-turk.patch
   $NICE cat $TESTDIR/fanboy-turk.patch >> $LOGFILE2
   echo " " >> $LOGFILE2
   ## DEBUG
   ### echo "Updated: fanboy-turkish.txt"
   ### echo "SSLMAIN: $MAINDIR/fanboy-turkish.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-turkish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt $MAINDIR/fanboy-turkish.txt
   # Wipe old files
   rm -rf $MAINDIR/fanboy-turkish.txt.gz $TESTDIR/fanboy-turk.patch
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-turkish.txt.gz $MAINDIR/fanboy-turkish.txt > /dev/null
   # Create a log
   FILE="$MAINDIR/fanboy-turkish.txt"
   echo $ECHORESPONSE >> $LOGFILE
   # Combine Regional trackers
   $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $GOOGLEDIR/scripts/ie/turkish-ie-generator.sh
   # Combine
   $GOOGLEDIR/scripts/combine/firefox-adblock-turk.sh
else
   echo "Files are the same: fanboy-turkish.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-turkish.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-turkish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt
fi

# JAPANESE
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-japanese.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-japanese.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-japanese.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt

if [ "$SSLGOOGLE" != "$SSLMAIN" ]
then
   # Log
   echo "Updated fanboy-japanese.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
   echo "Googles copy: `ls -al $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt`" >> $LOGFILE2
   echo "Local copy: `ls -al $MAINDIR/fanboy-japanese.txt`" >> $LOGFILE2
    # Write patch to log file
    #
   echo " " >> $LOGFILE2
   echo "Changes to File: fanboy-japanese.txt" >> $LOGFILE2
   $NICE diff -Naur $MAINDIR/fanboy-japanese.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt > $TESTDIR/fanboy-jpn.patch
   $NICE cat $TESTDIR/fanboy-jpn.patch >> $LOGFILE2
   echo " " >> $LOGFILE2
   ## DEBUG
   ### echo "Updated: fanboy-japanese.txt"
   ### echo "SSLMAIN: $MAINDIR/fanboy-japanese.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-japanese.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt $MAINDIR/fanboy-japanese.txt
   # Wipe old files
   rm -rf $MAINDIR/fanboy-japanese.txt.gz $TESTDIR/fanboy-jpn.patch
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-japanese.txt.gz $MAINDIR/fanboy-japanese.txt > /dev/null
   # Create a log
   FILE="$MAINDIR/fanboy-japanese.txt"
   echo $ECHORESPONSE >> $LOGFILE
   # Combine Regional trackers
   $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $GOOGLEDIR/scripts/ie/japanese-ie-generator.sh
   # Combine
   $GOOGLEDIR/scripts/combine/firefox-adblock-jpn.sh
else
   echo "Files are the same: fanboy-japanese.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-japanese.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-japanese.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt

fi

# KOREAN
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-korean.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-korean.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-korean.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt

if [ "$SSLGOOGLE" != "$SSLMAIN" ]
then
    # Log
    echo "Updated fanboy-korean.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    echo "Googles copy: `ls -al $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt`" >> $LOGFILE2
    echo "Local copy: `ls -al $MAINDIR/fanboy-korean.txt`" >> $LOGFILE2
    # Write patch to log file
    #
    echo " " >> $LOGFILE2
    echo "Changes to File: fanboy-korean.txt" >> $LOGFILE2
    $NICE diff -Naur $MAINDIR/fanboy-japanese.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt > $TESTDIR/fanboy-krn.patch
    $NICE cat $TESTDIR/fanboy-krn.patch >> $LOGFILE2
    echo " " >> $LOGFILE2
    ## DEBUG
    ### echo "Updated: fanboy-korean.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-korean.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-korean.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt $MAINDIR/fanboy-korean.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-korean.txt.gz $TESTDIR/fanboy-krn.patch
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-korean.txt.gz $MAINDIR/fanboy-korean.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-korean.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-krn.sh
else
   echo "Files are the same: fanboy-korean.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-korean.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-korean.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt
fi


# ITALIAN
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-italian.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-italian.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-italian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt

if [ "$SSLGOOGLE" != "$SSLMAIN" ]
then
    # Log
    echo "Updated fanboy-italian.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    echo "Googles copy: `ls -al $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt`" >> $LOGFILE2
    echo "Local copy: `ls -al $MAINDIR/fanboy-italian.txt`" >> $LOGFILE2
    # Write patch to log file
    #
    echo " " >> $LOGFILE2
    echo "Changes to File: fanboy-italian.txt" >> $LOGFILE2
    $NICE diff -Naur $MAINDIR/fanboy-italian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt > $TESTDIR/fanboy-ita.patch
    $NICE cat $TESTDIR/fanboy-ita.patch >> $LOGFILE2
    echo " " >> $LOGFILE2
    ## DEBUG
    ### echo "Updated: fanboy-italian.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-italian.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-italian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt $MAINDIR/fanboy-italian.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-italian.txt.gz $TESTDIR/fanboy-ita.patch
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-italian.txt.gz $MAINDIR/fanboy-italian.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-italian.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Generate IE script
    $GOOGLEDIR/scripts/ie/italian-ie-generator.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-ita.sh
else
   echo "Files are the same: fanboy-italian.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-italian.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-italian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt
fi

# POLISH
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-polish.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-polish.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-polish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt

if [ "$SSLGOOGLE" != "$SSLMAIN" ]
then
    # Log
    echo "Updated fanboy-polish.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    echo "Googles copy: `ls -al $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt`" >> $LOGFILE2
    echo "Local copy: `ls -al $MAINDIR/fanboy-polish.txt`" >> $LOGFILE2
    # Write patch to log file
    #
    echo " " >> $LOGFILE2
    echo "Changes to File: fanboy-polish.txt" >> $LOGFILE2
    $NICE diff -Naur $MAINDIR/fanboy-polish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt > $TESTDIR/fanboy-pol.patch
    $NICE cat $TESTDIR/fanboy-pol.patch >> $LOGFILE2
    echo " " >> $LOGFILE2
    ## DEBUG
    ### echo "Updated: fanboy-polish.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-polish.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-polish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt $MAINDIR/fanboy-polish.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-polish.txt.gz $TESTDIR/fanboy-pol.patch
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-polish.txt.gz $MAINDIR/fanboy-polish.txt /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-polish.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-pol.sh
    # Remove uneeded file
    rm -rf $TESTDIR/fanboy-pol.patch
else
   echo "Files are the same: fanboy-polish.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-polish.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-polish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt
fi

# INDIAN
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-indian.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-indian.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-indian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt

if [ "$SSLGOOGLE" != "$SSLMAIN" ]
then
    # Log
    echo "Updated fanboy-indian.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    echo "Googles copy: `ls -al $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt`" >> $LOGFILE2
    echo "Local copy: `ls -al $MAINDIR/fanboy-indian.txt`" >> $LOGFILE2
    # Write patch to log file
    #
    echo " " >> $LOGFILE2
    echo "Changes to File: fanboy-indian.txt" >> $LOGFILE2
    $NICE diff -Naur $MAINDIR/fanboy-indian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt > $TESTDIR/fanboy-ind.patch
    $NICE cat $TESTDIR/fanboy-ind.patch >> $LOGFILE2
    echo " " >> $LOGFILE2
    ## DEBUG
    ### echo "Updated: fanboy-indian.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-indian.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-indian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt $MAINDIR/fanboy-indian.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-indian.txt.gz $TESTDIR/fanboy-ind.patch
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-indian.txt.gz $MAINDIR/fanboy-indian.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-indian.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-ind.sh
else
   echo "Files are the same: fanboy-indian.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-indian.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-indian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt
fi

# VIETNAM
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-vietnam.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-vietnam.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-vietnam.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt

if [ "$SSLGOOGLE" != "$SSLMAIN" ]
then
    # Log
    echo "Updated fanboy-vietnam.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    echo "Googles copy: `ls -al $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt`" >> $LOGFILE2
    echo "Local copy: `ls -al $MAINDIR/fanboy-vietnam.txt`" >> $LOGFILE2
    # Write patch to log file
    #
    echo " " >> $LOGFILE2
    echo "Changes to File: fanboy-vietnam.txt" >> $LOGFILE2
    $NICE diff -Naur $MAINDIR/fanboy-vietnam.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt > $TESTDIR/fanboy-vtn.patch
    $NICE cat $TESTDIR/fanboy-vtn.patch >> $LOGFILE2
    echo " " >> $LOGFILE2
    ## DEBUG
    ### echo "Updated: fanboy-vietnam.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-vietnam.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-vietnam.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt $MAINDIR/fanboy-vietnam.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-vietnam.txt.gz $TESTDIR/fanboy-vtn.patch
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-vietnam.txt.gz $MAINDIR/fanboy-vietnam.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-vietnam.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-vtn.sh
else
   echo "Files are the same: fanboy-vietnam.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-vietnam.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-vietnam.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt
fi

# CHINESE
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-chinese.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-chinese.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-chinese.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt

if [ "$SSLGOOGLE" != "$SSLMAIN" ]
then
    # Log
    echo "Updated fanboy-chinese.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    echo "Googles copy: `ls -al $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt`" >> $LOGFILE2
    echo "Local copy: `ls -al $MAINDIR/fanboy-chinese.txt`" >> $LOGFILE2
    # Write patch to log file
    #
    echo " " >> $LOGFILE2
    echo "Changes to File: fanboy-chinese.txt" >> $LOGFILE2
    $NICE diff -Naur $MAINDIR/fanboy-chinese.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt > $TESTDIR/fanboy-chn.patch
    $NICE cat $TESTDIR/fanboy-chn.patch >> $LOGFILE2
    echo " " >> $LOGFILE2
    ## DEBUG
    ### echo "Updated: fanboy-chinese.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-chinese.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-chinese.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt $MAINDIR/fanboy-chinese.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-chinese.txt.gz $TESTDIR/fanboy-chn.patch
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-chinese.txt.gz $MAINDIR/fanboy-chinese.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-chinese.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-chn.sh

else
   echo "Files are the same: fanboy-chinese.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-chinese.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-chinese.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt
fi

# ESPANOL
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-espanol.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-espanol.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-espanol.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt

if [ "$SSLGOOGLE" != "$SSLMAIN" ]
then
    # Log
    echo "Updated fanboy-espanol.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    echo "Googles copy: `ls -al $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt`" >> $LOGFILE2
    echo "Local copy: `ls -al $MAINDIR/fanboy-espanol.txt`" >> $LOGFILE2
    # Write patch to log file
    #
    echo " " >> $LOGFILE2
    echo "Changes to File: fanboy-espanol.txt" >> $LOGFILE2
    $NICE diff -Naur $MAINDIR/fanboy-espanol.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt > $TESTDIR/fanboy-esp.patch
    $NICE cat $TESTDIR/fanboy-esp.patch >> $LOGFILE2
    echo " " >> $LOGFILE2
    ## DEBUG
    ### echo "Updated: fanboy-espanol.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-espanol.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-espanol.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt $MAINDIR/fanboy-espanol.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-espanol.txt.gz $TESTDIR/fanboy-esp.patch
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-espanol.txt.gz $MAINDIR/fanboy-espanol.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-espanol.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
		# Generate IE script
		$GOOGLEDIR/scripts/ie/espanol-ie-generator.sh
		# Combine
		$GOOGLEDIR/scripts/combine/firefox-adblock-esp.sh
else
   echo "Files are the same: fanboy-espanol.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "Not updated: fanboy-espanol.txt"
   ### echo "SSLMAIN: $MAINDIR/fanboy-espanol.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-espanol.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt
fi

# SWEDISH
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-swedish.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-swedish.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-swedish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt

if [ "$SSLGOOGLE" != "$SSLMAIN" ]
then
    ## DEBUG
    ### echo "Updated: fanboy-swedish.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-swedish.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-swedish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt
    # Log
    echo "Updated fanboy-swedish.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    echo "Googles copy: `ls -al $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt`" >> $LOGFILE2
    echo "Local copy: `ls -al $MAINDIR/fanboy-swedish.txt`" >> $LOGFILE2
    # Write patch to log file
    #
    echo " " >> $LOGFILE2
    echo "Changes to File: fanboy-swedish.txt" >> $LOGFILE2
    $NICE diff -Naur $MAINDIR/fanboy-swedish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt > $TESTDIR/fanboy-swe.patch
    $NICE cat $TESTDIR/fanboy-swe.patch >> $LOGFILE2
    echo " " >> $LOGFILE2
    #
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt $MAINDIR/fanboy-swedish.txt
    # Wipe old files
    rm -rf $MAINDIR/fanboy-swedish.txt.gz $TESTDIR/fanboy-swe.patch
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-swedish.txt.gz $MAINDIR/fanboy-swedish.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-swedish.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-swe.sh
else
   echo "Files are the same: fanboy-swedish.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "Not updated: fanboy-swedish.txt"
   ### echo "SSLMAIN: $MAINDIR/fanboy-swedish.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt $SSLGOOGLE"
   ### ls -al $GOOGLEDIR/other/adblock-gannett.txt $MAINDIR/adblock-gannett.txt
fi

# Gannett
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($SHA256SUM $GOOGLEDIR/other/adblock-gannett.txt | cut -d' ' -f1)
SSLMAIN=$($SHA256SUM $MAINDIR/adblock-gannett.txt | cut -d' ' -f1)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/adblock-gannett.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/other/adblock-gannett.txt $SSLGOOGLE"
### ls -al $GOOGLEDIR/other/adblock-gannett.txt $MAINDIR/adblock-gannett.txt

if [ "$SSLGOOGLE" != "$SSLMAIN" ]
then
    ## DEBUG
    ### echo "Updated: fanboy-gannett.txt"
    ### echo "SSLMAIN: $MAINDIR/adblock-gannett.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/other/adblock-gannett.txt $SSLGOOGLE"
    ### ls -al $GOOGLEDIR/other/adblock-gannett.txt $MAINDIR/adblock-gannett.txt
    # Log
    echo "Updated fanboy-gannett.txt (script: list-grabber.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    cp -f $GOOGLEDIR/other/adblock-gannett.txt $MAINDIR/adblock-gannett.txt
    # Properly wipe old file.
    rm -rf $MAINDIR/adblock-gannett.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/adblock-gannett.txt.gz $MAINDIR/adblock-gannett.txt > /dev/null
else
   echo "Files are the same: adblock-gannett.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "Not updated: fanboy-gannett.txt"
   ### echo "SSLMAIN: $MAINDIR/adblock-gannett.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/other/adblock-gannett.txt $SSLGOOGLE"
   ### ls -al $GOOGLEDIR/other/adblock-gannett.txt $MAINDIR/adblock-gannett.txt
fi

# echo when script is finished
#
echo "Script finished executing on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
echo "------------------------- End of script -------------------------" >> $LOGFILE2
echo " " >> $LOGFILE2
$NICE $TAIL -n 6000 $LOGFILE2 > $MAINDIR/adblock.log
