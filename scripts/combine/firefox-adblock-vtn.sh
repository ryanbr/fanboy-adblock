#!/bin/bash
#
# Fanboy-Merge (Vietnam) Adblock list grabber script v1.0 (12/06/2011)
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
sed '1,2d' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt > $TESTDIR/fanboy-vtn-temp2.txt

# Remove Empty Lines
#
sed '/^$/d' $TESTDIR/fanboy-vtn-temp2.txt > $TESTDIR/fanboy-vtn-temp.txt

# Remove Bottom Line
#
sed '$d' < $TESTDIR/fanboy-vtn-temp.txt > $TESTDIR/fanboy-vtn-temp2.txt

# Merge to the files together
#
cat $MAINDIR/fanboy-adblock.txt $TESTDIR/fanboy-vtn-temp2.txt > $TESTDIR/fanboy-vtn-merged.txt

# Create a backup incase addchecksum "zeros" the file
#
cp -f $TESTDIR/fanboy-vtn-merged.txt $TESTDIR/fanboy-vtn-merged-bak.txt

# Add checksum
#
perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-vtn-merged.txt

if [ -s $TESTDIR/fanboy-vtn-merged.txt ];
then
  # Copy Merged file to main dir
  #
  cp $TESTDIR/fanboy-vtn-merged.txt $MAINDIR/r/fanboy+vietnam.txt

  # Compress file
  #
  rm -f $MAINDIR/r/fanboy+vietnam.txt.gz
  $NICE $ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+vietnam.txt.gz $TESTDIR/fanboy-vtn-merged.txt > /dev/null > /dev/null
  
  # log
  ### echo "Updated fanboy+vietnam.txt"
  echo "Updated /r/fanboy+vietnam.txt (merged fanboy+vietnam) (script: firefox-adblock-vtn.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  # Clear old Variables
  #
  rm -rf $TESTDIR/fanboy-vtn-*
else
  # Add checksum
  #
  sleep 2
  perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-vtn-merged-bak.txt
  
  # Copy Merged file to main dir
  #
  cp $TESTDIR/fanboy-vtn-merged-bak.txt $MAINDIR/r/fanboy+vietnam.txt
   
  # Compress file
  #
  rm -f $MAINDIR/r/fanboy+vietnam.txt.gz
  
  ### echo "Updated fanboy+vietnam.txt (checksum zerod file)"
  $NICE $ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+vietnam.txt.gz $TESTDIR/fanboy-vtn-merged-bak.txt > /dev/null > /dev/null
  echo "*** ERROR ***: Addchecksum Zero'd the file: fanboy+vietnam.txt (script: firefox-adblock-vtn.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  # Clear old Variables
  #
  rm -rf $TESTDIR/fanboy-vtn-*
fi