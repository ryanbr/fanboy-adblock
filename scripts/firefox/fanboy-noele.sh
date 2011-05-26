#!/bin/bash
#
# Fanboy Dimensions Adblock list grabber script v1.0 (26/05/2011)
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

# Remove Temp files
#
rm -f $TESTDIR/fanboy-noele*.txt
rm -f $TESTDIR/fanboy-adblocklist-current-expanded.txt

cp -f $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $TESTDIR/fanboy-adblocklist-current-expanded.txt

sed  -n '/Adblock Plus/,/p2p Element Firefox/{/p2p Element Firefox/!p}' $TESTDIR/fanboy-adblocklist-current-expanded.txt > $TESTDIR/fanboy-noele.txt
sed -e '$d' $TESTDIR/fanboy-noele.txt > $TESTDIR/fanboy-noele2.txt
perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-noele2.txt
if diff $TESTDIR/fanboy-noele2.txt $MAINDIR/fanboy-adblock-noele.txt > /dev/null ; then
    echo "No Changes detected: fanboy-adblock-noele.txt"
  else
    echo "Updated: fanboy-adblock-noele.txt"
    rm -f $MAINDIR/fanboy-adblock-noele.txt.gz
    cp -f $TESTDIR/fanboy-noele2.txt $MAINDIR/fanboy-adblock-noele.txt
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-adblock-noele.txt.gz $TESTDIR/fanboy-noele2.txt > /dev/null
    # Generate IE script
    $GOOGLEDIR/scripts/ie/adblock-ie-generator.sh
fi 