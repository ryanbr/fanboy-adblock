#!/bin/bash
#
# Fanboy-Merge-complete Adblock list grabber script v1.0 (18/06/2011)
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
perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-merged.txt

# Copy Merged file to main dir
#
cp $TESTDIR/fanboy-merged.txt $MAINDIR/r/fanboy+tracking+addon.txt

# Compress file
#
rm -f $MAINDIR/r/fanboy+tracking+addon.txt.gz
$ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+tracking+addon.txt.gz $MAINDIR/r/fanboy+tracking+addon.txt > /dev/null
