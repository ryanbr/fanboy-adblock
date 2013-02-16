#!/bin/bash
#
# Fanboy-Merge (Tracking) Adblock list grabber script v1.0 (12/06/2011)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
export ZIP="nice -n 19 /usr/local/bin/7za a -mx=9 -y -tgzip"
export NICE="nice -n 19"
export TAC="/usr/bin/tac"
export CAT="/bin/cat"
export MAINDIR="/var/www/adblock"
export SPLITDIR="/var/www/adblock/split/test"
export HGSERV="/root/fanboy-adblock-list"
export TESTDIR="/tmp/work"
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export IEDIR="/tmp/ieramdisk"
export SUBS="/tmp/ieramdisk/subscriptions"


# Trim off header file (first 2 lines)
#
sed '1,2d' $HGSERV/fanboy-adblocklist-stats.txt > $TESTDIR/fanboy-stats-temp2.txt

# Remove Empty Lines
#
sed '/^$/d' $TESTDIR/fanboy-stats-temp2.txt > $TESTDIR/fanboy-stats-temp.txt

# Remove Bottom Line
#
sed '$d' < $TESTDIR/fanboy-stats-temp.txt > $TESTDIR/fanboy-stats-temp2.txt

# Merge to the files together
#
cat $MAINDIR/fanboy-adblock.txt $TESTDIR/fanboy-stats-temp2.txt > $TESTDIR/fanboy-stats-merged.txt
$ADDCHECKSUM $TESTDIR/fanboy-stats-merged.txt

# Copy Merged file to main dir
#
cp $TESTDIR/fanboy-stats-merged.txt $MAINDIR/r/fanboy+tracking.txt

# Compress file
#
rm -f $MAINDIR/r/fanboy+tracking.txt.gz
$ZIP $MAINDIR/r/fanboy+tracking.txt.gz $MAINDIR/r/fanboy+tracking.txt > /dev/null
