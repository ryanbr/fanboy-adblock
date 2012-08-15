#!/bin/bash
#
# Fanboy-Merge (Korean) Adblock list grabber script v1.0 (12/06/2011)
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
sed '1,2d' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt > $TESTDIR/fanboy-krn-temp2.txt

# Remove Empty Lines
#
sed '/^$/d' $TESTDIR/fanboy-krn-temp2.txt > $TESTDIR/fanboy-krn-temp.txt

# Remove Bottom Line
#
sed '$d' < $TESTDIR/fanboy-krn-temp.txt > $TESTDIR/fanboy-krn-temp2.txt

# Merge to the files together
#
cat $MAINDIR/fanboy-adblock.txt $TESTDIR/fanboy-krn-temp2.txt > $TESTDIR/fanboy-krn-merged.txt

# Create a backup incase addchecksum "zeros" the file
#
cp -f $TESTDIR/fanboy-krn-merged.txt $TESTDIR/fanboy-krn-merged-bak.txt

# Add checksum
#
perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-krn-merged.txt

if [ -s $TESTDIR/fanboy-krn-merged.txt ];
then
  # Copy Merged file to main dir
  #
  cp $TESTDIR/fanboy-krn-merged.txt $MAINDIR/r/fanboy+korean.txt

  # Compress file
  #
  rm -f $MAINDIR/r/fanboy+korean.txt.gz
  $NICE $ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+korean.txt.gz $TESTDIR/fanboy-krn-merged.txt > /dev/null
  
  # log
  ### echo "Updated fanboy+korean.txt"
  echo "Updated /r/fanboy+korean.txt (merged fanboy+korean) (script: firefox-adblock-krn.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  # Clear old Variables
  #
  rm -rf $TESTDIR/fanboy-krn-*
else
  # Add checksum
  #
  sleep 2
  perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-krn-merged-bak.txt
  
  # Copy Merged file to main dir
  #
  cp $TESTDIR/fanboy-krn-merged-bak.txt $MAINDIR/r/fanboy+korean.txt

  # Compress file
  #
  rm -f $MAINDIR/r/fanboy+korean.txt.gz
  $NICE $ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+korean.txt.gz $TESTDIR/fanboy-krn-merged-bak.txt > /dev/null
  
  # log
  ### echo "Updated fanboy+korean.txt (checksum zerod file)"
  echo "*** ERROR ***: Addchecksum Zero'd the file: fanboy+korean.txt (script: firefox-adblock-krn.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  # Clear old Variables
  #
  rm -rf $TESTDIR/fanboy-krn-*
fi
