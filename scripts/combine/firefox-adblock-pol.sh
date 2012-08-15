#!/bin/bash
#
# Fanboy-Merge (Polish) Adblock list grabber script v1.0 (12/06/2011)
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



# Remove Standalone Filters
#
sed -n '/Adblock Plus/,/Standalone/{/Standalone/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt > $TESTDIR/fanboy-pol-temp1.txt

# Trim off header file (first 2 lines)
#
sed '1,2d' $TESTDIR/fanboy-pol-temp1.txt > $TESTDIR/fanboy-pol-temp2.txt

# Remove Dubes
#
sed -i '/||adocean.pl^$third-party/d' $TESTDIR/fanboy-pol-temp2.txt
sed -i '/||ads.adone.pl^$third-party/d' $TESTDIR/fanboy-pol-temp2.txt
sed -i '/||metaffiliation.com^$third-party/d' $TESTDIR/fanboy-pol-temp2.txt
sed -i '/||netsales.pl/d' $TESTDIR/fanboy-pol-temp2.txt
sed -i '/\.swf?click/d' $TESTDIR/fanboy-pol-temp2.txt

# Remove Empty Lines
#
sed '/^$/d' $TESTDIR/fanboy-pol-temp2.txt > $TESTDIR/fanboy-pol-temp.txt

# Remove Bottom Line
#
sed '$d' < $TESTDIR/fanboy-pol-temp.txt > $TESTDIR/fanboy-pol-temp2.txt

# Merge to the files together
#
cat $MAINDIR/fanboy-adblock.txt $TESTDIR/fanboy-pol-temp2.txt > $TESTDIR/fanboy-pol-merged.txt
# Create a backup incase addchecksum "zeros" the file
#
cp -f $TESTDIR/fanboy-pol-merged.txt $TESTDIR/fanboy-pol-merged-bak.txt
# Add checksum
#
perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-pol-merged.txt

if [ -s $TESTDIR/fanboy-pol-merged.txt ];
then
  # Copy Merged file to main dir
  #
  cp $TESTDIR/fanboy-pol-merged.txt $MAINDIR/r/fanboy+polish.txt

  # Compress file
  #
  rm -f $MAINDIR/r/fanboy+polish.txt.gz
  $NICE $ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+polish.txt.gz $TESTDIR/fanboy-pol-merged.txt > /dev/null
  
  # log
  ### echo "Updated fanboy+polish.txt"
  echo "Updated /r/fanboy+polish.txt (merged fanboy+polish) (script: firefox-adblock-pol.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  # Clear old Variables
  #
  rm -rf $TESTDIR/fanboy-pol-*
else
  # Add checksum
  #
  sleep 2
  perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-pol-merged-bak.txt
  
  # Copy Merged file to main dir
  #
  cp $TESTDIR/fanboy-pol-merged-bak.txt $MAINDIR/r/fanboy+polish.txt
   
  # Compress file
  #
  rm -f $MAINDIR/r/fanboy+polish.txt.gz
  
  ### echo "Updated fanboy+polish.txt (checksum zerod file)"
  $NICE $ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+polish.txt.gz $TESTDIR/fanboy-pol-merged-bak.txt > /dev/null
  echo "*** ERROR ***: Addchecksum Zero'd the file: fanboy+polish.txt (script: firefox-adblock-pol.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  # Clear old Variables
  #
  rm -rf $TESTDIR/fanboy-pol-*
fi