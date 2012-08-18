#!/bin/bash
#
# Fanboy Adblock list grabber Opera script v1.8 (15/08/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Version history
#
# 1.8  Allow list to be stored in ramdisk

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

# Make Ramdisk.
#
$GOOGLEDIR/scripts/ramdisk.sh
# Fallback if ramdisk.sh isn't excuted.
#
if [ ! -d "/tmp/work/opera" ]; then
  rm -rf /tmp/work/
  mkdir /tmp/work; chmod 777 /tmp/work
  mount -t tmpfs -o size=30M tmpfs /tmp/work/
  mkdir /tmp/work/opera/
  cp -f $GOOGLEDIR/scripts/addChecksum-opera.pl $TESTDIR
  cp -f $GOOGLEDIR/scripts/addChecksum-opera.pl $TESTDIR $TESTDIR/opera
fi

# Make sure Addchecksum is loaded
#
if [ ! -d "$TESTDIR/opera/addChecksum-opera.pl" ]; then
   cp -rf $GOOGLEDIR/scripts/addChecksum-opera.pl $TESTDIR
   cp -rf $GOOGLEDIR/scripts/addChecksum-opera.pl $TESTDIR/opera
   cp -rf $GOOGLEDIR/scripts/addChecksum.pl $TESTDIR
fi




# Opera logging
#
echo "************************* Start of Opera script *************************" >> $LOGFILE2

# Copy Popular Files into Ram Disk
#
rm -rf  $TESTDIR/opera/urlfilter.ini $TESTDIR/opera/urlfilter-stats.ini
cp -f $GOOGLEDIR/scripts/addChecksum.pl $GOOGLEDIR/scripts/addChecksum-opera.pl $TESTDIR
cp -f $GOOGLEDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-stats.ini $TESTDIR/opera/

# Create a combined script, to be used else where
if [ -n $TESTDIR/opera/urlfilter.ini ] || [ -n $TESTDIR/opera/urlfilter-stats.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $TESTDIR/opera/urlfilter-stats.ini > $TESTDIR/urlfilter-stats.ini
else
# echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter.ini/urlfilter-stats size is zero, please fix." mp3geek@gmail.com < /dev/null
fi
# Temp Sleep
sleep 5
  

# Opera and Tracking filter.
if [ -n $TESTDIR/opera/urlfilter.ini ] || [ -n $TESTDIR/opera/urlfilter-stats.ini ]
then
  if diff $TESTDIR/opera/urlfilter.ini $MAINDIR/opera/urlfilter.ini > /dev/null ; then
    # echo "No Changes detected: urlfilter.ini" > /dev/null
    echo "No Changes detected: urlfilter.ini (script: list-grabber-opera.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
   else
    # echo "Updated: urlfilter.ini"
    echo "Changes detected: urlfilter.ini (script: list-grabber-opera.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    cp -f $TESTDIR/opera/urlfilter.ini $MAINDIR/opera/urlfilter.ini
    # Properly wipe old file.
    rm -rf $MAINDIR/opera/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/urlfilter.ini.gz $TESTDIR/opera/urlfilter.ini > /dev/null
    # Generate Iron script
    # Turn off for the time being.
    $GOOGLEDIR/scripts/iron/adblock-iron-generator.sh
    # Combine tracking filter
    sed '/^$/d' $TESTDIR/urlfilter-stats.ini > $TESTDIR/urfilter-stats2.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urfilter-stats2.ini
    if diff $TESTDIR/urfilter-stats2.ini $MAINDIR/opera/complete/urlfilter.ini > /dev/null ; then
      echo "No Changes detected: complete/urlfilter.ini"
    else
      echo "Updated: complete/urlfilter.ini"
      cp -f $TESTDIR/urfilter-stats2.ini $MAINDIR/opera/complete/urlfilter.ini
      # Properly wipe old file.
      rm -rf $MAINDIR/opera/complete/urlfilter.ini.gz
      $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/complete/urlfilter.ini.gz $TESTDIR/urfilter-stats2.ini > /dev/null
      # Temp Sleep
      sleep 5
      # Generate Iron script
      # Turn off for the time being.
      $GOOGLEDIR/scripts/iron/adblock-iron-generator-tracker.sh  
    fi
  fi
else
# echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter.ini/urlfilter-stats size is zero, please fix." mp3geek@gmail.com < /dev/null
fi


# Opera Czech
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/opera/urlfilter-cz.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-cz.ini > $TESTDIR/urlfilter-cz.ini
  sed '/^$/d' $TESTDIR/urlfilter-cz.ini > $TESTDIR/urlfilter-cz2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-cz2.ini
  if diff $TESTDIR/urlfilter-cz2.ini $MAINDIR/opera/cz/urlfilter.ini > /dev/null ; then
     echo "No Changes detected: czech/urlfilter.ini" > /dev/null
  else
     # echo "Updated: czech/urlfilter.ini & czech/complete/urlfilter.ini"
     echo "Changes detected: czech/urlfilter.ini (script: list-grabber-opera.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
     cat $TESTDIR/urlfilter-stats.ini $GOOGLEDIR/opera/urlfilter-cz.ini > $TESTDIR/urlfilter-cz-stats.ini
     perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-cz-stats.ini
     cp -f $TESTDIR/urlfilter-cz2.ini $MAINDIR/opera/cz/urlfilter.ini
     cp -f $TESTDIR/urlfilter-cz-stats.ini $MAINDIR/opera/cz/complete/urlfilter.ini
     # Properly wipe old file.
     rm -rf $MAINDIR/opera/cz/complete/urlfilter.ini.gz $MAINDIR/opera/cz/urlfilter.ini.gz
     $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/cz/complete/urlfilter.ini.gz $TESTDIR/urlfilter-cz-stats.ini > /dev/null
     $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/cz/urlfilter.ini.gz $TESTDIR/urlfilter-cz2.ini > /dev/null
     # Temp Sleep
     sleep 5
     # Generate Iron script
     $GOOGLEDIR/scripts/iron/czech-iron-generator.sh  
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-cz.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi


# Opera Polish
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/opera/urlfilter-pol.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-pol.ini > $TESTDIR/urlfilter-pol.ini
  sed '/^$/d' $TESTDIR/urlfilter-pol.ini > $TESTDIR/urlfilter-pol2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-pol2.ini
  if diff $TESTDIR/urlfilter-pol2.ini $MAINDIR/opera/pol/urlfilter.ini > /dev/null ; then
      echo "No Changes detected: polish/urlfilter.ini" > /dev/null
  else
    # echo "Updated: polish/urlfilter.ini & pol/complete/urlfilter.ini"
    echo "Changes detected: polish/urlfilter.ini (script: list-grabber-opera.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    cat $TESTDIR/urlfilter-stats.ini  $GOOGLEDIR/opera/urlfilter-pol.ini > $TESTDIR/urlfilter-pol-stats.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-pol-stats.ini
    cp -f $TESTDIR/urlfilter-pol2.ini $MAINDIR/opera/pol/urlfilter.ini
    cp -f $TESTDIR/urlfilter-pol-stats.ini $MAINDIR/opera/pol/complete/urlfilter.ini
    # Properly wipe old file.
    rm -rf $MAINDIR/opera/pol/urlfilter.ini.gz $MAINDIR/opera/pol/complete/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/pol/complete/urfilter.ini.gz $TESTDIR/urlfilter-pol-stats.ini > /dev/null
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/pol/urlfilter.ini.gz $TESTDIR/urlfilter-pol2.ini > /dev/null
    # Temp Sleep
    sleep 5
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-pol.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi


# Opera Espanol
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/opera/urlfilter-esp.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-esp.ini > $TESTDIR/urlfilter-esp.ini
  sed '/^$/d' $TESTDIR/urlfilter-esp.ini  > $TESTDIR/urlfilter-esp2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-esp2.ini
  if diff $TESTDIR/urlfilter-esp2.ini $MAINDIR/opera/esp/urlfilter.ini > /dev/null ; then
    echo "No Changes detected: esp/urlfilter.ini" > /dev/null
else
    # echo "Updated: esp/urlfilter.ini & esp/complete/urlfilter.ini"
    echo "Changes detected: esp/urlfilter.ini (script: list-grabber-opera.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    cat $TESTDIR/urlfilter-stats.ini $GOOGLEDIR/opera/urlfilter-esp.ini > $TESTDIR/urlfilter-esp-stats.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-esp-stats.ini
    cp -f $TESTDIR/urlfilter-esp-stats.ini $MAINDIR/opera/esp/complete/urlfilter.ini
    cp -f $TESTDIR/urlfilter-esp2.ini $MAINDIR/opera/esp/urlfilter.ini
    # Properly wipe old file.
    rm -rf $MAINDIR/opera/esp/urlfilter.ini.gz $MAINDIR/opera/esp/complete/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/esp/urlfilter.ini.gz $TESTDIR/urlfilter-esp2.ini > /dev/null
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/esp/complete/urlfilter.ini.gz $TESTDIR/urlfilter-esp-stats.ini >/dev/null
    # Generate Iron script
    $GOOGLEDIR/scripts/iron/espanol-iron-generator.sh  
    # Temp Sleep
    sleep 5
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-esp.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi


# Opera Russian
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/opera/urlfilter-rus.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-rus.ini > $TESTDIR/urlfilter-rus.ini
  sed '/^$/d' $TESTDIR/urlfilter-rus.ini > $TESTDIR/urlfilter-rus2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-rus2.ini
  if diff $TESTDIR/urlfilter-rus2.ini $MAINDIR/opera/rus/urlfilter.ini > /dev/null ; then
    echo "No Changes detected: rus/urlfilter.ini" > /dev/null
  else
    # echo "Updated: rus/urlfilter.ini & rus/complete/urlfilter.ini"
    echo "Changes detected: rus/urlfilter.ini (script: list-grabber-opera.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    cat $TESTDIR/urlfilter-stats.ini $GOOGLEDIR/opera/urlfilter-rus.ini > $TESTDIR/urlfilter-rus-stats.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-rus-stats.ini
    cp -f $TESTDIR/urlfilter-rus-stats.ini $MAINDIR/opera/rus/complete/urlfilter.ini
    cp -f $TESTDIR/urlfilter-rus2.ini $MAINDIR/opera/rus/urlfilter.ini
    # Properly wipe old file.
    rm -rf $MAINDIR/opera/rus/complete/urlfilter.ini.gz $MAINDIR/opera/rus/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/rus/complete/urlfilter.ini.gz $TESTDIR/urlfilter-rus-stats.ini >/dev/null
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/rus/urlfilter.ini.gz $TESTDIR/urlfilter-rus2.ini >/dev/null
    # Generate Iron script
    $GOOGLEDIR/scripts/iron/russian-iron-generator.sh  
    # Temp Sleep
    sleep 5
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-rus.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi


# Opera Swedish
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/opera/urlfilter-swe.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-swe.ini > $TESTDIR/urlfilter-swe.ini
  sed '/^$/d' $TESTDIR/urlfilter-swe.ini > $TESTDIR/urlfilter-swe2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-swe2.ini
  if diff $TESTDIR/urlfilter-swe2.ini $MAINDIR/opera/swe/urlfilter.ini > /dev/null ; then
    echo "No Changes detected: swe/urlfilter.ini" > /dev/null
  else
    # echo "Updated: swe/urlfilter.ini & swe/complete/urlfilter.ini"
    echo "Changes detected: swe/urlfilter.ini (script: list-grabber-opera.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    cat $TESTDIR/urlfilter-stats.ini $GOOGLEDIR/opera/urlfilter-swe.ini > $TESTDIR/urlfilter-swe-stats.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-swe-stats.ini
    cp -f $TESTDIR/urlfilter-swe-stats.ini $MAINDIR/opera/swe/complete/urlfilter.ini
    cp -f $TESTDIR/urlfilter-swe2.ini $MAINDIR/opera/swe/urlfilter.ini
    # Properly wipe old file.
    rm -rf  $MAINDIR/opera/swe/urlfilter.ini.gz $MAINDIR/opera/swe/complete/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/swe/complete/urlfilter.ini.gz $TESTDIR/urlfilter-swe-stats.ini > /dev/null
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/swe/urlfilter.ini.gz $TESTDIR/urlfilter-swe2.ini > /dev/null
    # Temp Sleep
    sleep 5
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-swe.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi


# Opera JPN
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/opera/urlfilter-jpn.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-jpn.ini > $TESTDIR/urlfilter-jpn.ini
  sed '/^$/d' $TESTDIR/urlfilter-jpn.ini > $TESTDIR/urlfilter-jpn2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-jpn2.ini
  if diff $TESTDIR/urlfilter-jpn2.ini $MAINDIR/opera/jpn/urlfilter.ini > /dev/null ; then
    echo "No Changes detected: jpn/urlfilter.ini" > /dev/null
  else
    # echo "Updated: jpn/urlfilter.ini & jpn/complete/urlfilter.ini"
    echo "Changes detected: jpn/urlfilter.ini (script: list-grabber-opera.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    cat $TESTDIR/urlfilter-stats.ini $GOOGLEDIR/opera/urlfilter-jpn.ini > $TESTDIR/urlfilter-jpn-stats.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-jpn-stats.ini
    cp -f $TESTDIR/urlfilter-jpn-stats.ini $MAINDIR/opera/jpn/complete/urlfilter.ini
    cp -f $TESTDIR/urlfilter-jpn2.ini $MAINDIR/opera/jpn/urlfilter.ini
    # Properly wipe old file.
    rm -rf $MAINDIR/opera/jpn/urlfilter.ini.gz $MAINDIR/opera/jpn/complete/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/jpn/complete/urlfilter.ini.gz $TESTDIR/urlfilter-jpn-stats.ini > /dev/null
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/jpn/urlfilter.ini.gz $TESTDIR/urlfilter-jpn2.ini > /dev/null
    # Temp Sleep
    sleep 5
    # Generate Iron script
    $GOOGLEDIR/scripts/iron/japanese-iron-generator.sh  
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-jpn.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi
    
# Opera VTN
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/opera/urlfilter-vtn.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-vtn.ini > $TESTDIR/urlfilter-vtn.ini
  sed '/^$/d' $TESTDIR/urlfilter-vtn.ini > $TESTDIR/urlfilter-vtn2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-vtn2.ini
  if diff $TESTDIR/urlfilter-vtn2.ini $MAINDIR/opera/vtn/urlfilter.ini > /dev/null ; then
    echo "No Changes detected: vtn/urlfilter.ini" > /dev/null
  else
    # echo "Updated: vtn/urlfilter.ini & vtn/complete/urlfilter.ini"
    echo "Changes detected: vtn/urlfilter.ini (script: list-grabber-opera.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    cat $TESTDIR/urlfilter-stats.ini $GOOGLEDIR/opera/urlfilter-vtn.ini > $TESTDIR/urlfilter-vtn-stats.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-vtn-stats.ini
    cp -f $TESTDIR/urlfilter-vtn-stats.ini $MAINDIR/opera/vtn/complete/urlfilter.ini
    cp -f $TESTDIR/urlfilter-vtn2.ini $MAINDIR/opera/vtn/urlfilter.ini
    # Properly wipe old file.
    rm -rf $MAINDIR/opera/vtn/urlfilter.ini.gz $MAINDIR/opera/vtn/complete/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/vtn/complete/urlfilter.ini.gz $TESTDIR/urlfilter-vtn-stats.ini > /dev/null
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/vtn/urlfilter.ini.gz $TESTDIR/urlfilter-vtn2.ini > /dev/null
    # Temp Sleep
    sleep 5
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-vtn.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi


# Opera Turk
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/opera/urlfilter-tky.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-tky.ini > $TESTDIR/urlfilter-tky.ini
  sed '/^$/d' $TESTDIR/urlfilter-tky.ini >  $TESTDIR/urlfilter-tky2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-tky2.ini
  if diff $TESTDIR/urlfilter-tky2.ini $MAINDIR/opera/trky/urlfilter.ini > /dev/null ; then
    echo "No Changes detected: trky/urlfilter.ini" > /dev/null
  else
    # echo "Updated: trky/urlfilter.ini & trky/complete/urlfilter.ini"
    echo "Changes detected: trky/urlfilter.ini (script: list-grabber-opera.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
    cat $TESTDIR/urlfilter-stats.ini $GOOGLEDIR/opera/urlfilter-tky.ini > $TESTDIR/urlfilter-tky-stats.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-tky-stats.ini
    cp -f $TESTDIR/urlfilter-tky-stats.ini $MAINDIR/opera/trky/complete/urlfilter.ini
    cp -f $TESTDIR/urlfilter-tky2.ini $MAINDIR/opera/trky/urlfilter.ini
    # Properly wipe old file.
    rm -rf $MAINDIR/opera/trky/complete/urlfilter.ini.gz $MAINDIR/opera/trky/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/trky/complete/urlfilter.ini.gz $TESTDIR/urlfilter-tky-stats.ini > /dev/null
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/trky/urlfilter.ini.gz $TESTDIR/urlfilter-tky2.ini > /dev/null
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-tky.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# End of logging
#
echo "Script finished executing on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE2
echo "************************* End of Opera script *************************" >> $LOGFILE2
echo " " >> $LOGFILE2