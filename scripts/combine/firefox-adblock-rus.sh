#!/bin/bash
#
# Fanboy-Merge (Russian) Adblock list grabber script v1.0 (12/06/2011)
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


# Trim off header file (first 2 lines)
#
sed '1,2d' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt > $TESTDIR/fanboy-rus-temp.txt

# The Generic filters are already in the main list, dont need to doubleup on filters... remove "Russian Generic (Standalone)"
#
sed -n '/Russian-V2-addon/,/Russian Generic (Standalone)/{/Russian Generic (Standalone)/!p}' $TESTDIR/fanboy-rus-temp.txt > $TESTDIR/fanboy-rus-temp1.txt
sed -n '/Russian Specific Element/,$p' < $TESTDIR/fanboy-rus-temp.txt > $TESTDIR/fanboy-rus-temp3.txt

# Merge without Standalone Elements.
#
cat $TESTDIR/fanboy-rus-temp1.txt $TESTDIR/fanboy-rus-temp3.txt > $TESTDIR/fanboy-rus-temp.txt

# Seperage off Easylist filters
#
sed -n '/Russian-V2-addon/,/Easylist-specific/{/Easylist-specific/!p}' $TESTDIR/fanboy-rus-temp.txt > $TESTDIR/fanboy-rus-temp2.txt

# Remove Empty Lines
#
sed '/^$/d' $TESTDIR/fanboy-rus-temp2.txt > $TESTDIR/fanboy-rus-temp.txt

# Remove Bottom Line
#
sed '$d' < $TESTDIR/fanboy-rus-temp.txt > $TESTDIR/fanboy-rus-temp2.txt

# Merge to the files together
#
cat $MAINDIR/fanboy-adblock.txt $TESTDIR/fanboy-rus-temp2.txt > $TESTDIR/fanboy-rus-merged.txt
perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-rus-merged.txt

# Copy Merged file to main dir
#
cp $TESTDIR/fanboy-rus-merged.txt $MAINDIR/r/fanboy+russian.txt

# Compress file
#
rm -f $MAINDIR/r/fanboy+russian.txt.gz
$ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+russian.txt.gz $MAINDIR/r/fanboy+russian.txt > /dev/null
