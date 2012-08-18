#!/bin/bash
#
# Fanboy-Merge (Italian) Adblock list grabber script v1.0 (12/06/2011)
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
sed '1,2d' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt > $TESTDIR/fanboy-ita-temp.txt

# Seperage off Easylist filters
#
sed -n '/Italian-addon/,/Easylist-specific/{/Easylist-specific/!p}' $TESTDIR/fanboy-ita-temp.txt > $TESTDIR/fanboy-ita-temp2.txt

# Remove Empty Lines
#
sed '/^$/d' $TESTDIR/fanboy-ita-temp2.txt > $TESTDIR/fanboy-ita-temp.txt

# Remove Bottom Line
#
sed '$d' < $TESTDIR/fanboy-ita-temp.txt > $TESTDIR/fanboy-ita-temp2.txt

# Merge to the files together
#
cat $MAINDIR/fanboy-adblock.txt $TESTDIR/fanboy-ita-temp2.txt > $TESTDIR/fanboy-ita-merged.txt

# Create a backup incase addchecksum "zeros" the file
#
cp -f $TESTDIR/fanboy-ita-merged.txt $TESTDIR/fanboy-ita-merged-bak.txt

# Add checksum
#
perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-ita-merged.txt

if [ -s $TESTDIR/fanboy-ita-merged.txt ];
then
  # Copy Merged file to main dir
  #
  cp $TESTDIR/fanboy-ita-merged.txt $MAINDIR/r/fanboy+italian.txt
  
  # Compress file
  #
  rm -f $MAINDIR/r/fanboy+italian.txt.gz
  $NICE $ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+italian.txt.gz $MAINDIR/r/fanboy+italian.txt > /dev/null
  # log
  ### echo "Updated fanboy+italian.txt"
  echo "Updated /r/fanboy+polish.txt (merged fanboy+polish) (script: firefox-adblock-pol.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  # Clear old Variables
  #
  rm -rf $TESTDIR/fanboy-ita-*
else
  # Add checksum
  #
  sleep 2
  perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-ita-merged-bak.txt
  
  # Copy Merged file to main dir
  #
  cp $TESTDIR/fanboy-ita-merged-bak.txt $MAINDIR/r/fanboy+italian.txt
  
  # Compress file
  #
  rm -f $MAINDIR/r/fanboy+italian.txt.gz
  $NICE $ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+italian.txt.gz $MAINDIR/r/fanboy+italian.txt > /dev/null
  # log
  ### echo "Updated fanboy+italain.txt (checksum zerod file)"
  echo "*** ERROR ***: Addchecksum Zero'd the file: fanboy+italian.txt (script: firefox-adblock-ita.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  # Clear old Variables
  #
  rm -rf $TESTDIR/fanboy-ita-*
fi
