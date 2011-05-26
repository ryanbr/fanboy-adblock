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
rm -f $TESTDIR/dim*.txt
rm -f $TESTDIR/fanboy-adblocklist-current-expanded.txt

cp -f $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $TESTDIR/fanboy-adblocklist-current-expanded.txt

sed  -n '/Dimensions/,/Adult Blocking Rules/{/Adult Blocking Rules/!p}' $TESTDIR/fanboy-adblocklist-current-expanded.txt > $TESTDIR/dim-temp.txt
sed '1,2d' $TESTDIR/dim-temp.txt > $TESTDIR/dim-temp1.txt
sed -e '$d' $TESTDIR/dim-temp1.txt > $TESTDIR/dim-temp2.txt
cat $MAINDIR/header-dim.txt $TESTDIR/dim-temp2.txt > $TESTDIR/dim-temp.txt
perl $MAINDIR/addChecksum.pl $TESTDIR/dim-temp.txt > /dev/null

# Compare the Dimensions on the website vs mercurial copy
#
if diff $TESTDIR/dim-temp.txt $MAINDIR/fanboy-dimensions.txt >/dev/null ; then
    echo "No Changes detected: fanboy-dimensions.txt"
  else
    echo "Updated: fanboy-dimensions.txt"
    cp -f $TESTDIR/dim-temp.txt $MAINDIR/fanboy-dimensions.txt
    rm -f $MAINDIR/fanboy-dimensions.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-dimensions.txt.gz $TESTDIR/dim-temp.txt > /dev/null
fi
 