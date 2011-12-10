#!/bin/bash
#
# Fanboy Russian Opera Merging script v1.0 (10/12/2011)
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

# Make copies into Ramdisk
#
cp -f $GOOGLEDIR/opera/css/fanboy-russian.css $TESTDIR/opera-russian-test.css
cp -f $MAINDIR/opera/fanboy-adblocklist-elements-v4.css $TESTDIR/opera-test.css

# remove bottom line (unneeded)
#
sed -e '$d' $TESTDIR/opera-test.css  > $TESTDIR/opera-test2.css

# Remove selected lines (be very specific, include comma)
# sed -i '/#testfilter,/d' $TESTDIR/fanboy-css.txt
sed -i '/promo-power-centre/d' $TESTDIR/opera-test2.css

# remove the top 10 lines (the comments of the Russian file)
#
sed '1,10d' $TESTDIR/opera-russian-test.css > $TESTDIR/opera-russian-test2.css

# Copy modified files
#
cat $TESTDIR/opera-test2.css $TESTDIR/opera-russian-test2.css > $TESTDIR/opera-russian.css

# Checksum the file
#
perl $TESTDIR/addChecksum.pl $TESTDIR/opera-russian.css

# Compare the Differences, if any changes, upload a copy.
#
if diff $TESTDIR/opera-russian.css $MAINDIR/opera/rus/fanboy-russian.css >/dev/null ; then
   echo "No Changes detected: fanboy-russian.css"
 else
   # Things change, upload generated file
   cp -f $TESTDIR/opera-russian.css $MAINDIR/opera/rus/fanboy-russian.css
   rm -f $MAINDIR/opera/rus/fanboy-russian.css.gz
   $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/rus/fanboy-russian.css.gz $TESTDIR/opera-russian.css > /dev/null
fi
