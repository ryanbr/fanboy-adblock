#!/bin/bash
#
# Fanboy P2P Adblock list grabber script v1.0 (26/05/2011)
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
rm -f $TESTDIR/fanboy-p2p*.txt
rm -f $TESTDIR/fanboy-adblocklist-current-expanded.txt

cp -f $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $TESTDIR/fanboy-adblocklist-current-expanded.txt

sed  -n '/P2P Rules/,/Adult Hiding FF 3.x Rules/{/Adult Hiding FF 3.x Rules/!p}' $TESTDIR/fanboy-adblocklist-current-expanded.txt > $TESTDIR/fanboy-p2p.txt
sed '1,2d' $TESTDIR/fanboy-p2p.txt > $TESTDIR/fanboy-p3p.txt
sed -e '$d' $TESTDIR/fanboy-p3p.txt > $TESTDIR/fanboy-p2p.txt
cat $MAINDIR/header-p2p.txt $TESTDIR/fanboy-p2p.txt > $TESTDIR/fanboy-p2p.txt2
perl $MAINDIR/addChecksum.pl $TESTDIR/fanboy-p2p.txt2

# Compare the P2P List on the website vs mercurial copy
#
if diff $TESTDIR/fanboy-p2p.txt2 $MAINDIR/fanboy-p2p.txt >/dev/null ; then
     echo "No Changes detected: fanboy-p2p.txt"
  else
     echo "Updated: fanboy-p2p.txt"
     rm -f $MAINDIR/fanboy-p2p.txt.gz
     $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-p2p.txt.gz $TESTDIR/fanboy-p2p.txt2 > /dev/null
fi
 