#!/bin/bash
#
# Fanboy-Merge (Polish) Adblock list grabber script v1.0 (12/06/2011)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#

# Creating a 20Mb ramdisk Temp storage...
#
if [ ! -d "/tmp/ramdisk/" ]; then
    rm -rf /tmp/ramdisk/
    mkdir /tmp/ramdisk; chmod 777 /tmp/ramdisk
    mount -t tmpfs -o size=20M tmpfs /tmp/ramdisk/
    mkdir /tmp/ramdisk/opera/
fi

# Variables for directorys
#
MAINDIR="/var/www/adblock"
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list"
TESTDIR="/tmp/ramdisk"
ZIP="/usr/local/bin/7za"

# Remove Standalone Filters
#
sed -n '/Adblock Plus/,/Standalone/{/Standalone/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt > $TESTDIR/fanboy-pol-temp1.txt

# Trim off header file (first 2 lines)
#
sed '1,2d' $TESTDIR/fanboy-pol-temp1.txt > $TESTDIR/fanboy-pol-temp2.txt

# Remove Empty Lines
#
sed '/^$/d' $TESTDIR/fanboy-pol-temp2.txt > $TESTDIR/fanboy-pol-temp.txt

# Remove Bottom Line
#
sed '$d' < $TESTDIR/fanboy-pol-temp.txt > $TESTDIR/fanboy-pol-temp2.txt

# Merge to the files together
#
cat $MAINDIR/fanboy-adblock.txt $TESTDIR/fanboy-pol-temp2.txt > $TESTDIR/fanboy-pol-merged.txt
perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-pol-merged.txt

# Copy Merged file to main dir
#
cp $TESTDIR/fanboy-pol-merged.txt $MAINDIR/r/fanboy+polish.txt

# Compress file
#
rm -f $MAINDIR/r/fanboy+polish.txt.gz
$ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+polish.txt.gz $MAINDIR/r/fanboy+polish.txt > /dev/null
