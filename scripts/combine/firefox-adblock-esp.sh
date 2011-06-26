#!/bin/bash
#
# Fanboy-Merge (Espanol) Adblock list grabber script v1.0 (12/06/2011)
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
sed '1,2d' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt > $TESTDIR/fanboy-esp-temp.txt

# The Generic filters are already in the main list, dont need to doubleup on filters... remove "Espanol Generic (Standalone)"
#
sed -n '/Spanish\/Portuguese Adblock/,/Spanish\/Portuguese Generic/{/Spanish\/Portuguese Generic/!p}' $TESTDIR/fanboy-esp-temp.txt > $TESTDIR/fanboy-esp-temp1.txt
sed -n '/Generic Spanish\/Portuguese/,$p' < $TESTDIR/fanboy-esp-temp.txt > $TESTDIR/fanboy-esp-temp3.txt

# Merge without Standalone Elements.
#
cat $TESTDIR/fanboy-esp-temp1.txt $TESTDIR/fanboy-esp-temp3.txt > $TESTDIR/fanboy-esp-temp.txt

# Seperage off Easylist filters
#
sed -n '/Portuguese Adblock/,/Easylist-specific/{/Easylist-specific/!p}' $TESTDIR/fanboy-esp-temp.txt > $TESTDIR/fanboy-esp-temp2.txt

# Remove Empty Lines
#
sed '/^$/d' $TESTDIR/fanboy-esp-temp2.txt > $TESTDIR/fanboy-esp-temp.txt

# Remove Bottom Line
#
sed '$d' < $TESTDIR/fanboy-esp-temp.txt > $TESTDIR/fanboy-esp-temp2.txt

# Merge to the files together
#
cat $MAINDIR/fanboy-adblock.txt $TESTDIR/fanboy-esp-temp2.txt > $TESTDIR/fanboy-esp-merged.txt
perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-esp-merged.txt

# Copy Merged file to main dir
#
cp $TESTDIR/fanboy-esp-merged.txt $MAINDIR/r/fanboy+espanol.txt

# Compress file
#
rm -f $MAINDIR/r/fanboy+espanol.txt.gz
$ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+espanol.txt.gz $MAINDIR/r/fanboy+espanol.txt > /dev/null
