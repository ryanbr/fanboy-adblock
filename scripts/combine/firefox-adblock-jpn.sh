#!/bin/bash
#
# Fanboy-Merge (Japanese) Adblock list grabber script v1.0 (12/06/2011)
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
sed '1,2d' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt > $TESTDIR/fanboy-jpn-temp2.txt

# The Generic filters are already in the main list, dont need to doubleup on filters... remove "Japanese Generic (Standalone)"
#
sed -n '/Japanese-addon/,/Japanese Generic/{/Japanese Generic/!p}' $TESTDIR/fanboy-jpn-temp2.txt > $TESTDIR/fanboy-jpn-temp1.txt
sed -n '/Japanese Site Specific/,$p' < $TESTDIR/fanboy-jpn-temp2.txt > $TESTDIR/fanboy-jpn-temp3.txt

# Merge without Standalone Elements.
#
cat $TESTDIR/fanboy-jpn-temp1.txt $TESTDIR/fanboy-jpn-temp3.txt > $TESTDIR/fanboy-jpn-temp2.txt

# Remove Empty Lines
#
sed '/^$/d' $TESTDIR/fanboy-jpn-temp2.txt > $TESTDIR/fanboy-jpn-temp.txt

# Remove Bottom Line
#
sed '$d' < $TESTDIR/fanboy-jpn-temp.txt > $TESTDIR/fanboy-jpn-temp2.txt

# Remove Dubes
#
#cp -f $MAINDIR/fanboy-adblock.txt $TESTDIR/fanboy-adblock.txt
sed -i '/\.jp\/html.ng\//d' $TESTDIR/fanboy-jpn-temp2.txt
sed -i '/||rcm-jp.amazon.co.jp/e/cm/d' $TESTDIR/fanboy-jpn-temp2.txt
sed -i '/||impact-ad.jp^' $TESTDIR/fanboy-jpn-temp2.txt
sed -i '/||advg.jp' $TESTDIR/fanboy-jpn-temp2.txt


# Merge to the files together
#
cat $MAINDIR/fanboy-adblock.txt $TESTDIR/fanboy-jpn-temp2.txt > $TESTDIR/fanboy-jpn-merged.txt
perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-jpn-merged.txt

# Copy Merged file to main dir
#
cp $TESTDIR/fanboy-jpn-merged.txt $MAINDIR/r/fanboy+japanese.txt

# Compress file
#
rm -f $MAINDIR/r/fanboy+japanese.txt.gz
$ZIP a -mx=9 -y -tgzip $MAINDIR/r/fanboy+japanese.txt.gz $MAINDIR/r/fanboy+japanese.txt > /dev/null
