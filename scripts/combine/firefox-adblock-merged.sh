#!/bin/bash
#
# Fanboy-Merge-complete Adblock list grabber script v1.1 (18/03/2012)
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
sed '1,2d' $MAINDIR/enhancedstats.txt > $TESTDIR/fanboy-enhanced.txt
sed '1,2d' $GOOGLEDIR/fanboy-adblocklist-addon.txt > $TESTDIR/fanboy-addon.txt
sed '1,2d' $MAINDIR/fanboy-tracking-complete.txt > $TESTDIR/fanboy-complete.txt

# Merge to the files together
#
cat $MAINDIR/fanboy-adblock.txt $TESTDIR/fanboy-complete.txt $TESTDIR/fanboy-enhanced.txt $TESTDIR/fanboy-addon.txt > $TESTDIR/fanboy-merged2.txt

# Remove Empty Lines
#
sed '/^$/d' $TESTDIR/fanboy-merged2.txt > $TESTDIR/fanboy-merged.txt

# Create a backup incase addchecksum "zeros" the file
#
cp -f $TESTDIR/fanboy-merged.txt $TESTDIR/fanboy-merged-bak.txt

# Add checksum to file
#
perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-merged.txt

# Now lets check if fanboy-merged.txt isnt zero
#
if [ -s $TESTDIR/fanboy-merged.txt ];
then
  # Copy Merged file to main dir
  #
  cp -f $TESTDIR/fanboy-merged.txt $MAINDIR/r/fanboy+tracking+addon.txt

  # Compress file
  #
  ### echo "Updated fanboy+tracking+addon.txt"
  rm -f $MAINDIR/r/fanboy+tracking+addon.txt.gz
  # Compress file
  $NICE $ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+tracking+addon.txt.gz $MAINDIR/r/fanboy+tracking+addon.txt > /dev/null
  # Log
  echo "Updated fanboy+tracking+addon.txt (script: firefox-adblock-merged.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  # Clear old Variables
  #
  rm -rf $TESTDIR/fanboy-merged*
else
  # Use the backup file (fanboy-merged.txt was zero'd by addchecksum)
  #
  sleep 2
  perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-merged-bak.txt
  
  # Copy Merged file to main dir
  #
  cp -f $TESTDIR/fanboy-merged-bak.txt $MAINDIR/r/fanboy+tracking+addon.txt
  
  # Compress file
  #
  ### echo "Updated fanboy+tracking+addon.txt (file was zero)"
  rm -f $MAINDIR/r/fanboy+tracking+addon.txt.gz
  # Compress file
  $NICE $ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+tracking+addon.txt.gz $MAINDIR/r/fanboy+tracking+addon.txt > /dev/null
  # Log
  echo "*** ERROR ***: Addchecksum Zero'd the file: fanboy-merged.txt (script: firefox-adblock-merged.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
  # Clear old Variables
  #
  rm -rf $TESTDIR/fanboy-merged*
fi