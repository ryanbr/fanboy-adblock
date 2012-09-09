#!/bin/bash
#
# Fanboy Dimensions Adblock list grabber script v2.0 (08/09/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#

export ZIP="nice -n 19 /usr/local/bin/7za a -mx=9 -y -tgzip"
export NICE="nice -n 19"
export TAC="/usr/bin/tac"
export CAT="/bin/cat"
export MAINDIR="/tmp/Ramdisk/www/adblock"
export SPLITDIR="/tmp/Ramdisk/www/adblock/split/test"
export HGSERV="/tmp/hgstuff/fanboy-adblock-list"
export TESTDIR="/tmp/work"
export DATE="`date`"
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export TWIDGE="/usr/bin/twidge update"
export IEDIR="/tmp/work/ie"
export IESUBS="/tmp/work/ie/subscriptions"
export IRONDIR="/tmp/Ramdisk/www/adblock/iron"


# Add New line
#
sed -e '$a\' $HGSERV/opera/opera-header.txt > $TESTDIR/opera-header.txt
sed -e '$a\' $HGSERV/fanboy-adblock/fanboy-elements-generic.txt > $TESTDIR/fanboy-elements-generic2.txt

# Remove top lines
#
sed '1,3d' $TESTDIR/fanboy-elements-generic2.txt > $TESTDIR/fanboy-elements-generic.txt

# the magic, remove ## and #. and add , to each line
#
cat $TESTDIR/fanboy-elements-generic.txt | sed 's/^..\(.*\)$/\1,/' > $TESTDIR/fanboy-css.txt

# Combine
#
cat $TESTDIR/opera-header.txt $TESTDIR/fanboy-css.txt $HGSERV/other/opera-addon.css > $TESTDIR/opera-addon.css

# Remove selected lines (be very specific, include comma)
# sed -i '/#testfilter,/d' $TESTDIR/opera-addon.css
sed -i '/.ad-vertical-container/d' $TESTDIR/opera-addon.css

# Remove any trailing blank lines, or blank lines in front
#
sed -i -e 's/^[ \t]*//;s/[ \t]*$//' $TESTDIR/opera-addon.css

# Remove empty lines
#
sed -i -e '/^$/d' $TESTDIR/opera-addon.css

# Checksum
#
$ADDCHECKSUM $TESTDIR/opera-addon.css

# Compress
#
cp -f $TESTDIR/opera-addon.css $MAINDIR/opera/fanboy-adblocklist-elements-v4.css
rm -rf $MAINDIR/opera/fanboy-adblocklist-elements-v4.css.gz
$ZIP $MAINDIR/opera/fanboy-adblocklist-elements-v4.css.gz $TESTDIR/opera-addon.css > /dev/null

# Remove temp files
#
rm -rf $TESTDIR/opera-header.txt $TESTDIR/fanboy-elements-generic.txt $TESTDIR/fanboy-css.txt $TESTDIR/opera-addon.css $TESTDIR/fanboy-elements-generic2.txt
