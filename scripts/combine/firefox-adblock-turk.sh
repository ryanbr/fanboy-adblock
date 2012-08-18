#!/bin/bash
#
# Fanboy-Merge (Turkish) Adblock list grabber script v1.0 (12/06/2011)
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




# Trim off header file (first 2 lines)
#
sed '1,2d' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt > $TESTDIR/fanboy-tky-temp.txt

# Seperage off Easylist filters
#
sed -n '/Turkish-addon/,/Easylist-specific/{/Easylist-specific/!p}' $TESTDIR/fanboy-tky-temp.txt > $TESTDIR/fanboy-tky-temp2.txt

# Remove Empty Lines
#
sed '/^$/d' $TESTDIR/fanboy-tky-temp2.txt > $TESTDIR/fanboy-tky-temp.txt

# Remove Bottom Line
#
sed '$d' < $TESTDIR/fanboy-tky-temp.txt > $TESTDIR/fanboy-tky-temp2.txt

# Merge to the files together
#
cat $MAINDIR/fanboy-adblock.txt $TESTDIR/fanboy-tky-temp2.txt > $TESTDIR/fanboy-tky-merged.txt

# Create a backup incase addchecksum "zeros" the file
#
cp -f $TESTDIR/fanboy-tky-merged.txt $TESTDIR/fanboy-tky-merged-bak.txt

# Add checksum
#
perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-tky-merged.txt

if [ -s $TESTDIR/fanboy-tky-merged.txt ];
then
  # Copy Merged file to main dir
  #
  cp $TESTDIR/fanboy-tky-merged.txt $MAINDIR/r/fanboy+turkish.txt

  # Compress file
  #
  rm -f $MAINDIR/r/fanboy+turkish.txt.gz
  $NICE $ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+turkish.txt.gz $MAINDIR/r/fanboy+turkish.txt > /dev/null
  # log
  ### echo "Updated fanboy+turkish.txt"
  echo "Updated /r/fanboy+turkish.txt (merged fanboy+turkish) (script: firefox-adblock-turk.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  # Clear old Variables
  #
  rm -rf $TESTDIR/fanboy-tky-*
else
  # Add checksum
  #
  sleep 2
  perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-tky-merged-bak.txt
  
  # Copy Merged file to main dir
  #
  cp $TESTDIR/fanboy-tky-merged-bak.txt $MAINDIR/r/fanboy+turkish.txt

  # Compress file
  #
  rm -f $MAINDIR/r/fanboy+turkish.txt.gz
  $NICE $ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+turkish.txt.gz $MAINDIR/r/fanboy+turkish.txt > /dev/null
  # log
  ### echo "Updated fanboy+turkish.txt (checksum zerod file)"
  echo "*** ERROR ***: Addchecksum Zero'd the file: fanboy+turkish.txt (script: firefox-adblock-turk.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  # Clear old Variables
  #
  rm -rf $TESTDIR/fanboy-tky-*
fi
