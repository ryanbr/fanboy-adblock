#!/bin/bash
#
# Fanboy-Merge (Ultimate) Adblock list grabber script v1.1 (18/03/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Make Ramdisk.
#
$GOOGLEDIR/scripts/ramdisk.sh
# Fallback if ramdisk.sh isn't excuted.
#
if [ ! -d "/tmp/ramdisk/" ]; then
  rm -rf /tmp/ramdisk/
  mkdir /tmp/ramdisk; chmod 777 /tmp/ramdisk
  mount -t tmpfs -o size=30M tmpfs /tmp/ramdisk/
  mkdir /tmp/ramdisk/opera/
fi



# Clear old files
#
rm -rf $TESTDIR/fanboy-addon-temp*.txt $TESTDIR/enhancedstats-addon-temp*.txt $TESTDIR/fanboy-stats-temp*.txt $TESTDIR/fanboy-complete.txt $TESTDIR/fanboy-ultimate.txt

# Tracking filter: Trim off header file, remove empty lines, and bottom line
sed '1,9d' $GOOGLEDIR/fanboy-adblocklist-stats.txt > $TESTDIR/fanboy-stats-temp2.txt
sed '/^$/d' $TESTDIR/fanboy-stats-temp2.txt > $TESTDIR/fanboy-stats-temp3.txt
sed '$d' < $TESTDIR/fanboy-stats-temp3.txt > $TESTDIR/fanboy-stats-temp.txt

# Annoyances filter: Trim off header file, remove empty lines, and bottom line
sed '1,10d' $GOOGLEDIR/fanboy-adblocklist-addon.txt > $TESTDIR/fanboy-addon-temp2.txt
sed '/^$/d' $TESTDIR/fanboy-addon-temp2.txt > $TESTDIR/fanboy-addon-temp3.txt

# Enhanced-tracking filter: Trim off header file, remove empty lines, and bottom line
sed '1,9d' $MAINDIR/enhancedstats.txt > $TESTDIR/enhancedstats-addon-temp2.txt
sed '/^$/d' $TESTDIR/enhancedstats-addon-temp2.txt > $TESTDIR/enhancedstats-addon-temp3.txt
sed '$d' < $TESTDIR/enhancedstats-addon-temp3.txt > $TESTDIR/enhancedstats-addon-temp.txt

# Remove dubes
sed -i '/analytics.js/d' $TESTDIR/fanboy-stats-temp.txt
sed -i '/com\/ga.js/d' $TESTDIR/fanboy-stats-temp.txt
sed -i '/\/js\/tracking.js/d' $TESTDIR/fanboy-stats-temp.txt

# Insert a new line to avoid chars running into each other
#
cat $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt | sed '$a!' > $TESTDIR/fanboy-adblocklist-current.txt

# Merge to the files together
#
cat $TESTDIR/fanboy-adblocklist-current.txt $TESTDIR/fanboy-stats-temp.txt $TESTDIR/enhancedstats-addon-temp.txt $TESTDIR/fanboy-addon-temp3.txt > $TESTDIR/fanboy-ultimate.txt
# Ultimate List for IE (minus the main list)
#
cat $TESTDIR/fanboy-stats-temp.txt $TESTDIR/enhancedstats-addon-temp.txt $TESTDIR/fanboy-addon-temp3.txt > $MAINDIR/fanboy-ultimate-ie.txt
cat $TESTDIR/fanboy-stats-temp.txt $TESTDIR/enhancedstats-addon-temp.txt > $TESTDIR/fanboy-complete.txt > $MAINDIR/fanboy-complete-ie.txt
# Complete List
#
cat $TESTDIR/fanboy-adblocklist-current.txt $TESTDIR/fanboy-stats-temp.txt $TESTDIR/enhancedstats-addon-temp.txt > $TESTDIR/fanboy-complete.txt

# Add titles
#
sed -i 's/Adblock\ List/Complete\ List/g' $TESTDIR/fanboy-complete.txt
sed -i 's/Adblock\ List/Ultimate\ List/g' $TESTDIR/fanboy-ultimate.txt

# Create backups for zero'd addchecksum
#
cp -f $TESTDIR/fanboy-complete.txt $TESTDIR/fanboy-complete-bak.txt
cp -f $TESTDIR/fanboy-ultimate.txt $TESTDIR/fanboy-ultimate-bak.txt

# Addchecksum
#
perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-complete.txt
perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-ultimate.txt


# Now lets check if fanboy-merged.txt isnt zero
#
if [ -s $TESTDIR/fanboy-complete.txt ] && [ -s $TESTDIR/fanboy-ultimate.txt ];
then
  # Copy Merged file to main dir
  #
  cp -f $TESTDIR/fanboy-complete.txt $MAINDIR/r/fanboy-complete.txt
  cp -f $TESTDIR/fanboy-ultimate.txt $MAINDIR/r/fanboy-ultimate.txt

  # Delete files before compressing
  #
  rm -f $TESTDIR/fanboy-ultimate.txt.gz $TESTDIR/fanboy-complete.txt.gz

  # Compress Files
  #
  $NICE $ZIP a -mx=9 -y -tgzip $TESTDIR/fanboy-complete.txt.gz $TESTDIR/fanboy-complete.txt > /dev/null
  $NICE $ZIP a -mx=9 -y -tgzip $TESTDIR/fanboy-ultimate.txt.gz $TESTDIR/fanboy-ultimate.txt > /dev/null
  
  # Copy to server
  #
  cp -f $TESTDIR/fanboy-complete.txt.gz $MAINDIR/r/fanboy-complete.txt.gz
  cp -f $TESTDIR/fanboy-ultimate.txt.gz $MAINDIR/r/fanboy-ultimate.txt.gz

  # Check Compressed file exists first for -complete
  #
  if [ -f $TESTDIR/fanboy-complete.txt.gz ];
  then
     rm -f $MAINDIR/r/fanboy-complete.txt.gz
     cp $TESTDIR/fanboy-complete.txt.gz $MAINDIR/r/fanboy-complete.txt.gz
     ## DEBUG
     ### echo "Updated fanboy-complete"
     echo "Updated fanboy-complete.txt.gz (script: firefox-adblock-ultimate.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  else
     ### echo "Unable to update fanboy-complete"
     echo "*** ERROR ***: Unable to update fanboy-complete.txt.gz (script: firefox-adblock-ultimate.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  fi

  # Check Compressed file exists first for -ultimate
  #
  if [ -f $TESTDIR/fanboy-ultimate.txt.gz ];
  then
     rm -rf $MAINDIR/r/fanboy-ultimate.txt.gz
     cp $TESTDIR/fanboy-ultimate.txt.gz $MAINDIR/r/fanboy-ultimate.txt.gz
     ## DEBUG
     ### echo "Updated fanboy-ultimate"
     echo "Updated fanboy-ultimate.txt.gz (script: firefox-adblock-ultimate.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  else
     ### echo "Unable to update fanboy-ultimate"
     echo "*** ERROR ***: Unable to update fanboy-ultimate.txt.gz (script: firefox-adblock-ultimate.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  fi
else
  # Use the backup file (fanboy-merged.txt was zero'd by addchecksum)
  ### echo "Updated fanboy-enhanced.txt (file was zero)"
  #
  sleep 2
  # Addchecksum
  #
  perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-complete-bak.txt
  sleep 2
  perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-ultimate-bak.txt
  
  # Copy Merged file to main dir
  #
  cp -f $TESTDIR/fanboy-complete-bak.txt $MAINDIR/r/fanboy-complete.txt
  cp -f $TESTDIR/fanboy-ultimate-bak.txt $MAINDIR/r/fanboy-ultimate.txt
  
  # Delete files before compressing
  #
  rm -f $TESTDIR/fanboy-ultimate.txt.gz $TESTDIR/fanboy-complete.txt.gz
  
  # Compress Files
  #
  $NICE $ZIP a -mx=9 -y -tgzip $TESTDIR/fanboy-complete.txt.gz $TESTDIR/fanboy-complete-bak.txt > /dev/null
  sleep 2
  $NICE $ZIP a -mx=9 -y -tgzip $TESTDIR/fanboy-ultimate.txt.gz $TESTDIR/fanboy-ultimate-bak.txt > /dev/null
  
  # Copy to server
  #
  cp -f $TESTDIR/fanboy-complete.txt.gz $MAINDIR/r/fanboy-complete.txt.gz
  cp -f $TESTDIR/fanboy-ultimate.txt.gz $MAINDIR/r/fanboy-ultimate.txt.gz
  
  # Log
  echo "*** ERROR ***: Addchecksum Zero'd the file: fanboy-adblock-ultimate.txt (script: firefox-adblock-ultimate.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
fi


