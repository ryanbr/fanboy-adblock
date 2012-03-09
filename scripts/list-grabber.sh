#!/bin/bash
#
# Fanboy Adblock list grabber script v1.5 (14/02/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#

# Creating a 20Mb ramdisk Temp storage...
#
if [ ! -d "/tmp/ramdisk/" ]; then
    rm -rf /tmp/ramdisk/
    mkdir /tmp/ramdisk; chmod 777 /tmp/ramdisk
    mount -t tmpfs -o size=20M tmpfs /tmp/ramdisk/
    mkdir /tmp/ramdisk/opera/
fi
if [ ! -d "/tmp/ramdisk/opera/" ]; then
    mkdir /tmp/ramdisk/opera/
fi

# Variables for directorys
#
MAINDIR="/var/www/adblock"
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list"
TESTDIR="/tmp/ramdisk"
ZIP="nice -n 19 /usr/local/bin/7za"
NICE="nice -n 19"
SHRED="nice -n 19 /usr/bin/shred"
LOGFILE="/etc/crons/log-listgrabber.txt"
DATE="`date`"
ECHORESPONSE="List Changed: $LS2"
BADUPDATE="Bad Update: $LS2"
LS2="`ls -al $FILE`"
# Grab Mercurial Updates
#
cd /home/fanboy/google/fanboy-adblock-list/
$NICE /usr/local/bin/hg pull
$NICE /usr/local/bin/hg update

# Copy Popular Files into Ram Disk
#
$SHRED -n 5 -z -u  $TESTDIR/opera/urlfilter.ini $TESTDIR/opera/urlfilter-stats.ini
cp -f $GOOGLEDIR/scripts/addChecksum.pl $GOOGLEDIR/scripts/addChecksum-opera.pl $TESTDIR
cp -f $GOOGLEDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-stats.ini $TESTDIR/opera/

# Make sure the shell scripts are exexcutable, all the time..
#
chmod a+x $GOOGLEDIR/scripts/ie/*.sh $GOOGLEDIR/scripts/iron/*.sh $GOOGLEDIR/scripts/*.sh $GOOGLEDIR/scripts/firefox/*.sh $GOOGLEDIR/scripts/combine/*.sh

# Main List
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt ]
then
  if diff $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $MAINDIR/fanboy-adblock.txt >/dev/null ; then
    echo "No changes detected: fanboy-adblock.txt" > /dev/null
  else
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
    rm -f $MAINDIR/fanboy-adblock.txt.gz
    # Now Copy over GZip'd list
    cp -f $TESTDIR/fanboy-adblock.txt.gz $MAINDIR/fanboy-adblock.txt.gz
    # perl $TESTDIR/addChecksum.pl $TESTDIR/firefox-expanded.txt-org2
    # cp -f $TESTDIR/firefox-expanded.txt-org2 $MAINDIR/fanboy-adblock.txt
    # cp -f $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $MAINDIR/fanboy-adblock.txt
    # cp -f $TESTDIR/fanboy-adblocklist-current-expanded.txt $MAINDIR/fanboy-adblock.txt
    
    # Create a log
    FILE="$TESTDIR/fanboy-adblock.txt"
    echo $ECHORESPONSE >> $LOGFILE

    # The Dimensions List
    #
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-dimensions.sh
    
    # The Adult List
    #
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-adult.sh

    # The P2P List
    #
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-p2p.sh

    # Seperate off CSS elements for Opera CSS
    #
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-element-opera-generator.sh
    
    # Seperate off Elements
    #
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-noele.sh
    
    # Combine (Czech)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-czech.sh
    # Combine (Espanol)
		$NICE $GOOGLEDIR/scripts/combine/firefox-adblock-esp.sh
    # Combine (Russian)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-rus.sh
    # Combine (Japanese)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-jpn.sh
    # Combine (Swedish)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-swe.sh
    # Combine (Chinese)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-chn.sh
    # Combine (Vietnam)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-vtn.sh
    # Combine (Vietnam)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-krn.sh
    # Combine (Turkish)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-turk.sh
    # Combine (Italian)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-ita.sh
    # Combine (Polish)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-pol.sh
    # Combine Regional trackers
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-tracking.sh
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-ultimate.sh
    # echo "Updated: fanboy-adblock.txt" > /dev/null
  fi
else
    # echo "Something went bad, file size is 0"
    # Create a log
    FILE="$TESTDIR/fanboy-adblock.txt"
    echo $BADUPDATE >> $LOGFILE
fi

# Tracking
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/fanboy-adblocklist-stats.txt ]
then
  if diff $GOOGLEDIR/fanboy-adblocklist-stats.txt $MAINDIR/fanboy-tracking.txt >/dev/null ; then
     echo "No Changes detected: fanboy-tracking.txt" > /dev/null
   else
    # echo "Updated: fanboy-tracking.txt"
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
    rm -f $MAINDIR/fanboy-tracking.txt.gz
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
 fi
else
    # echo "Something went bad, file size is 0"
    # Create a log
    FILE="$TESTDIR/fanboy-tracking.txt"
    echo $BADUPDATE >> $LOGFILE
fi

# Enhanced Trackers
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/enhancedstats-addon.txt ]
then
  if diff $GOOGLEDIR/enhancedstats-addon.txt $MAINDIR/enhancedstats.txt >/dev/null ; then
    echo "No Changes detected: enhancedstats-addon.txt" > /dev/null
  else
    # echo "Updated: enhancedstats-addon.txt"
    # Clear old list
    rm -f $TESTDIR/enhancedstats.txt $TESTDIR/enhancedstats.txt.gz
    # Copy list from repo to RAMDISK
    cp -f $GOOGLEDIR/enhancedstats-addon.txt $TESTDIR/enhancedstats.txt
    # GZip
    $ZIP a -mx=9 -y -tgzip $TESTDIR/enhancedstats.txt.gz $TESTDIR/enhancedstats.txt > /dev/null
    # Create a log
    FILE="$TESTDIR/enhancedstats.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Clear Webhost-copy before copying and now Copy over GZip'd list
    cp -f $TESTDIR/enhancedstats.txt $MAINDIR/enhancedstats.txt
    rm -f $MAINDIR/enhancedstats.txt.gz
    cp -f $TESTDIR/enhancedstats.txt.gz $MAINDIR/enhancedstats.txt.gz
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $GOOGLEDIR/scripts/combine/firefox-adblock-ultimate.sh
 fi
else
    # echo "Something went bad, file size is 0"
    # Create a log
    FILE="$MAINDIR/enhancedstats.txt"
    echo $BADUPDATE >> $LOGFILE
fi

# Addon/Annoyances
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/fanboy-adblocklist-addon.txt ]
then
  if diff $GOOGLEDIR/fanboy-adblocklist-addon.txt $MAINDIR/fanboy-addon.txt >/dev/null ; then
    echo "No Changes detected: fanboy-addon.txt" > /dev/null
  else
    # echo "Updated: fanboy-addon.txt"
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
    rm -f $MAINDIR/fanboy-addon.txt.gz
    cp -f $TESTDIR/fanboy-addon.txt.gz $MAINDIR/fanboy-addon.txt.gz
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $GOOGLEDIR/scripts/combine/firefox-adblock-ultimate.sh
 fi
else
  # echo "Something went bad, file size is 0"
  # Create a log
  FILE="$TESTDIR/fanboy-addon.txt"
  echo $BADUPDATE >> $LOGFILE
fi

# CZECH
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt $MAINDIR/fanboy-czech.txt >/dev/null ; then
    echo "No Changes detected: fanboy-czech.txt" > /dev/null
  else
   echo "Updated: fanboy-czech.txt"
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt $MAINDIR/fanboy-czech.txt
   # Properly wipe old file.
   $SHRED -n 3 -z -u $MAINDIR/fanboy-czech.txt.gz
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
 fi
else
  # echo "Something went bad, file size is 0"
  # Create a log
  FILE="$MAINDIR/fanboy-czech.txt"
  echo $BADUPDATE >> $LOGFILE
fi

# RUSSIAN
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt $MAINDIR/fanboy-russian.txt >/dev/null ; then
    echo "No Changes detected: fanboy-russian.txt" > /dev/null
  else
   echo "Updated: fanboy-russian.txt"
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt $MAINDIR/fanboy-russian.txt
   # Properly wipe old file.
   $SHRED -n 3 -z -u $MAINDIR/fanboy-russian.txt.gz
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
 fi
else
  # echo "Something went bad, file size is 0"
  # Create a log
  FILE="$MAINDIR/fanboy-russian.txt"
  echo $BADUPDATE >> $LOGFILE
fi

# TURK
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt $MAINDIR/fanboy-turkish.txt >/dev/null ; then
    echo "No Changes detected: fanboy-turkish.txt" > /dev/null
  else
   echo "Updated: fanboy-turkish.txt"
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt $MAINDIR/fanboy-turkish.txt
   # Properly wipe old file.
   $SHRED -n 3 -z -u  $MAINDIR/fanboy-turkish.txt.gz
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
 fi
else
  # echo "Something went bad, file size is 0"
  # Create a log
  FILE="$MAINDIR/fanboy-turkish.txt"
  echo $BADUPDATE >> $LOGFILE
fi

# JAPANESE
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt $MAINDIR/fanboy-japanese.txt >/dev/null ; then
    echo "No Changes detected: fanboy-japanese.txt" > /dev/null
  else
   echo "Updated: fanboy-japanese.txt"
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt $MAINDIR/fanboy-japanese.txt
   # Properly wipe old file.
   $SHRED -n 3 -z -u  $MAINDIR/fanboy-japanese.txt.gz
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-japanese.txt.gz $MAINDIR/fanboy-japanese.txt > /dev/null
   # Create a log
   FILE="$MAINDIR/fanboy-japanese.txt"
   echo $ECHORESPONSE >> $LOGFILE
   # Combine Regional trackers
   $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $GOOGLEDIR/scripts/ie/italian-ie-generator.sh
   # Combine
   $GOOGLEDIR/scripts/combine/firefox-adblock-jpn.sh
 fi
else
  # echo "Something went bad, file size is 0"
  # Create a log
  FILE="$MAINDIR/fanboy-japanese.txt"
  echo $BADUPDATE >> $LOGFILE
fi

# KOREAN
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt $MAINDIR/fanboy-korean.txt > /dev/null ; then
    echo "No Changes detected: fanboy-korean.txt" > /dev/null
   else
    echo "Updated: fanboy-korean.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt $MAINDIR/fanboy-korean.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-korean.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-korean.txt.gz $MAINDIR/fanboy-korean.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-korean.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-krn.sh
 fi
else
  # echo "Something went bad, file size is 0"
  # Create a log
  FILE="$MAINDIR/fanboy-korean.txt"
  echo $BADUPDATE >> $LOGFILE
fi


# ITALIAN
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt $MAINDIR/fanboy-italian.txt > /dev/null ; then
    echo "No Changes detected: fanboy-italian.txt" > /dev/null
   else
    echo "Updated: fanboy-italian.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt $MAINDIR/fanboy-italian.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-italian.txt.gz
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
 fi
else
  # echo "Something went bad, file size is 0"
  # Create a log
  FILE="$MAINDIR/fanboy-italian.txt"
  echo $BADUPDATE >> $LOGFILE
fi

# POLISH
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt $MAINDIR/fanboy-polish.txt > /dev/null ; then
    echo "No Changes detected: fanboy-polish.txt" > /dev/null
   else
    echo "Updated: fanboy-polish.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt $MAINDIR/fanboy-polish.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-polish.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-polish.txt.gz $MAINDIR/fanboy-polish.txt /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-polish.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-pol.sh
 fi
else
  # echo "Something went bad, file size is 0"
  # Create a log
  FILE="$MAINDIR/fanboy-polish.txt"
  echo $BADUPDATE >> $LOGFILE
fi

# INDIAN
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt $MAINDIR/fanboy-indian.txt > /dev/null ; then
    echo "No Changes detected: fanboy-indian.txt" > /dev/null
   else
    echo "Updated: fanboy-indian.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt $MAINDIR/fanboy-indian.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-indian.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-indian.txt.gz $MAINDIR/fanboy-indian.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-indian.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-ind.sh
 fi
else
  # echo "Something went bad, file size is 0"
  # Create a log
  FILE=" $MAINDIR/fanboy-indian.txt"
  echo $BADUPDATE >> $LOGFILE
fi

# VIETNAM
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt $MAINDIR/fanboy-vietnam.txt > /dev/null ; then
    echo "No Changes detected: fanboy-vietnam.txt" > /dev/null
   else
    echo "Updated: fanboy-vietnam.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt $MAINDIR/fanboy-vietnam.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-vietnam.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-vietnam.txt.gz $MAINDIR/fanboy-vietnam.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-vietnam.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-vtn.sh
 fi
else
  # echo "Something went bad, file size is 0"
  # Create a log
  FILE="$MAINDIR/fanboy-vietnam.txt"
  echo $BADUPDATE >> $LOGFILE
fi

# CHINESE
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt $MAINDIR/fanboy-chinese.txt > /dev/null ; then
    echo "No Changes detected: fanboy-chinese.txt" > /dev/null
   else
    echo "Updated: fanboy-chinese.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt $MAINDIR/fanboy-chinese.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-chinese.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-chinese.txt.gz $MAINDIR/fanboy-chinese.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-chinese.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-chn.sh
 fi
else
  # echo "Something went bad, file size is 0"
  # Create a log
  FILE="$MAINDIR/fanboy-chinese.txt"
  echo $BADUPDATE >> $LOGFILE
fi

# ESPANOL
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt $MAINDIR/fanboy-espanol.txt > /dev/null ; then
    echo "No Changes detected: fanboy-espanol.txt" > /dev/null
   else
    echo "Updated: fanboy-espanol.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt $MAINDIR/fanboy-espanol.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-espanol.txt.gz
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
 fi
else
  # echo "Something went bad, file size is 0"
  # Create a log
  FILE="$MAINDIR/fanboy-espanol.txt"
  echo $BADUPDATE >> $LOGFILE
fi

# SWEDISH
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt $MAINDIR/fanboy-swedish.txt > /dev/null ; then
    echo "No Changes detected: fanboy-swedish.txt" > /dev/null
   else
    echo "Updated: fanboy-swedish.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt $MAINDIR/fanboy-swedish.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-swedish.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-swedish.txt.gz $MAINDIR/fanboy-swedish.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-swedish.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-swe.sh
 fi
else
  # echo "Something went bad, file size is 0"
  # Create a log
  FILE="$MAINDIR/fanboy-swedish.txt"
  echo $BADUPDATE >> $LOGFILE
fi

# Gannett
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/other/adblock-gannett.txt ]
then
 if diff $GOOGLEDIR/other/adblock-gannett.txt $MAINDIR/adblock-gannett.txt > /dev/null ; then
    echo "No Changes detected: fanboy-gannett.txt" > /dev/null
   else
    echo "Updated: fanboy-gannett.txt"
    cp -f $GOOGLEDIR/adblock-gannett.txt $MAINDIR/adblock-gannett.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/adblock-gannett.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/adblock-gannett.txt.gz $MAINDIR/adblock-gannett.txt > /dev/null
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror adblock-gannett.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

