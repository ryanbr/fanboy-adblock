#!/bin/bash
#
# Fanboy Adblock list grabber script v1.4 (18/04/2011)
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
rm -f $TESTDIR/fanboy-adult*.txt
rm -f $TESTDIR/fanboy-adblocklist-current-expanded.txt

cp -f $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $TESTDIR/fanboy-adblocklist-current-expanded.txt
sed  -n '/Adult Blocking Rules/,/P2P Rules/{/P2P Rules/!p}' $TESTDIR/fanboy-adblocklist-current-expanded.txt > $TESTDIR/fanboy-adult.txt
sed  -n '/Adult Hiding FF 3.x Rules/,/Generic Hiding Rules/{/Generic Hiding Rules/!p}' $TESTDIR/fanboy-adblocklist-current-expanded.txt > $TESTDIR/fanboy-adult-ele.txt
cat $TESTDIR/fanboy-adult.txt $TESTDIR/fanboy-adult-ele.txt > $TESTDIR/fanboy-adult2.txt
sed -e '$d' $TESTDIR/fanboy-adult2.txt > $TESTDIR/fanboy-adult1.txt
cat $MAINDIR/header-adult.txt $TESTDIR/fanboy-adult1.txt > $TESTDIR/fanboy-adult.txt
perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-adult.txt

# Compare the Adult List on the website vs mercurial copy
#
if diff $TESTDIR/fanboy-adult.txt $MAINDIR/fanboy-adult.txt >/dev/null ; then
    echo "No Changes detected: fanboy-adult.txt"
 else
    echo "Updated: fanboy-adult.txt"
    cp -f $TESTDIR/fanboy-adult.txt $MAINDIR/fanboy-adult.txt
    rm -f $MAINDIR/fanboy-adult.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-adult.txt.gz $TESTDIR/fanboy-adult.txt > /dev/null
fi 