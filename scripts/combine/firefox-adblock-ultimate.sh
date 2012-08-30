#!/bin/bash
#
# Fanboy-Merge (Ultimate) Adblock list grabber script v1.2 (30/08/2012)
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
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export IEDIR="/tmp/ieramdisk"
export SUBS="/tmp/ieramdisk/subscriptions"
export IRONDIR="/tmp/Ramdisk/www/adblock/iron"

# Clear old files
#
rm -rf $TESTDIR/fanboy-addon-temp*.txt $TESTDIR/enhancedstats-addon-temp*.txt $TESTDIR/fanboy-stats-temp*.txt $TESTDIR/fanboy-complete.txt $TESTDIR/fanboy-ultimate.txt

# Tracking filter: Trim off header file, remove empty lines, and bottom line
sed '1,9d' $MAINDIR/fanboy-adblocklist-stats.txt > $TESTDIR/fanboy-stats-temp2.txt
sed '/^$/d' $TESTDIR/fanboy-stats-temp2.txt > $TESTDIR/fanboy-stats-temp3.txt
sed '$d' < $TESTDIR/fanboy-stats-temp3.txt > $TESTDIR/fanboy-stats-temp.txt

# Annoyances filter: Trim off header file, remove empty lines, and bottom line
sed '1,10d' $HGSERV/fanboy-adblocklist-addon.txt > $TESTDIR/fanboy-addon-temp2.txt
sed '/^$/d' $TESTDIR/fanboy-addon-temp2.txt > $TESTDIR/fanboy-addon-temp3.txt

# Enhanced-tracking filter: Trim off header file, remove empty lines, and bottom line
sed '1,9d' $MAINDIR/enhancedstats.txt > $TESTDIR/enhancedstats-addon-temp2.txt
sed '/^$/d' $TESTDIR/enhancedstats-addon-temp2.txt > $TESTDIR/enhancedstats-addon-temp3.txt
sed '$d' < $TESTDIR/enhancedstats-addon-temp3.txt > $TESTDIR/enhancedstats-addon-temp.txt

# Remove dubes
sed -i '/analytics.js/d' $TESTDIR/fanboy-stats-temp.txt
sed -i '/com\/ga.js/d' $TESTDIR/fanboy-stats-temp.txt
sed -i '/\/js\/tracking.js/d' $TESTDIR/fanboy-stats-temp.txt

# Insert a new line to avoid chars running into each other
#
cat $MAINDIR/fanboy-adblock.txt | sed '$a!' > $TESTDIR/fanboy-adblocklist-current.txt

# Ultimate List
#
cat $TESTDIR/fanboy-adblocklist-current.txt $TESTDIR/fanboy-stats-temp.txt $TESTDIR/enhancedstats-addon-temp.txt $TESTDIR/fanboy-addon-temp3.txt > $TESTDIR/fanboy-ultimate.txt

# Complete List
#
cat $TESTDIR/fanboy-adblocklist-current.txt $TESTDIR/fanboy-stats-temp.txt $TESTDIR/enhancedstats-addon-temp.txt > $TESTDIR/fanboy-complete.txt

# Ultimate List for IE (minus the main list)
#
cat $TESTDIR/fanboy-stats-temp.txt $TESTDIR/enhancedstats-addon-temp.txt $TESTDIR/fanboy-addon-temp3.txt > $MAINDIR/fanboy-ultimate-ie.txt
cat $TESTDIR/fanboy-stats-temp.txt $TESTDIR/enhancedstats-addon-temp.txt > $TESTDIR/fanboy-complete.txt > $MAINDIR/fanboy-complete-ie.txt

# Add titles
#
sed -i 's/Adblock\ List/Complete\ List/g' $TESTDIR/fanboy-complete.txt
sed -i 's/Adblock\ List/Ultimate\ List/g' $TESTDIR/fanboy-ultimate.txt

# Create backups for zero'd addchecksum
#
cp -f $TESTDIR/fanboy-complete.txt $TESTDIR/fanboy-complete-bak.txt
cp -f $TESTDIR/fanboy-ultimate.txt $TESTDIR/fanboy-ultimate-bak.txt

# Addchecksum
#
$ADDCHECKSUM $TESTDIR/fanboy-complete.txt
$ADDCHECKSUM $TESTDIR/fanboy-ultimate.txt

# Copy to the website
#
cp -f $TESTDIR/fanboy-complete.txt $MAINDIR/r/fanboy-complete.txt
cp -f $TESTDIR/fanboy-ultimate.txt $MAINDIR/r/fanboy-ultimate.txt

# Gzip up the ultimate/complete lists
#
rm -f $MAINDIR/r/fanboy-ultimate.txt.gz $MAINDIR/r/fanboy-complete.txt.gz
$ZIP $MAINDIR/r/fanboy-complete.txt.gz $TESTDIR/fanboy-complete.txt &> /dev/null
$ZIP $MAINDIR/r/fanboy-ultimate.txt.gz $TESTDIR/fanboy-ultimate.txt &> /dev/null