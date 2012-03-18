#!/bin/bash
#
# Fanboy-Merge (Ultimate) Adblock list grabber script v1.1 (18/03/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Variables for directorys
#
MAINDIR="/var/www/adblock"
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list"
TESTDIR="/tmp/ramdisk"
ZIP="/usr/local/bin/7za"
NICE="nice -n 19"
DATE="`date`"

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
cat $TESTDIR/fanboy-adblocklist-current.txt $TESTDIR/fanboy-stats-temp.txt $TESTDIR/enhancedstats-addon-temp.txt > $TESTDIR/fanboy-complete.txt
perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-complete.txt
perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-ultimate.txt

# Copy Merged file to main dir
#
cp $TESTDIR/fanboy-complete.txt $MAINDIR/r/fanboy-complete.txt
cp $TESTDIR/fanboy-ultimate.txt $MAINDIR/r/fanboy-ultimate.txt

# Delete files before compressing
#
rm -f $TESTDIR/fanboy-ultimate.txt.gz $TESTDIR/fanboy-complete.txt.gz

# Compress Files
#
$NICE $ZIP a -mx=9 -y -tgzip $TESTDIR/fanboy-complete.txt.gz $TESTDIR/fanboy-complete.txt > /dev/null
$NICE $ZIP a -mx=9 -y -tgzip $TESTDIR/fanboy-ultimate.txt.gz $TESTDIR/fanboy-ultimate.txt > /dev/null

# Check Compressed file exists first for -complete
#
if [ -f $TESTDIR/fanboy-complete.txt.gz ];
then
   rm -f $MAINDIR/r/fanboy-complete.txt.gz
   cp $TESTDIR/fanboy-complete.txt.gz $MAINDIR/r/fanboy-complete.txt.gz
   ## DEBUG
   ### echo "Updated fanboy-complete"
   echo "Updated fanboy-complete.txt.gz on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
else
   ### echo "Unable to update fanboy-complete"
   echo "*** ERROR ***: Unable to update fanboy-complete.txt.gz on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
fi

# Check Compressed file exists first for -ultimate
#
if [ -f $TESTDIR/fanboy-ultimate.txt.gz ];
then
   rm -rf $MAINDIR/r/fanboy-ultimate.txt.gz
   cp $TESTDIR/fanboy-ultimate.txt.gz $MAINDIR/r/fanboy-ultimate.txt.gz
   ## DEBUG
   ### echo "Updated fanboy-ultimate"
   echo "Updated fanboy-ultimate.txt.gz on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
else
   ### echo "Unable to update fanboy-ultimate"
   echo "*** ERROR ***: Unable to update fanboy-ultimate.txt.gz on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
fi


