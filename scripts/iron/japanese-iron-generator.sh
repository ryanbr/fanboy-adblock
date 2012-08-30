#!/bin/bash
#
# Fanboy Adblock Iron Convert script (jpn) v2.0 (30/08/2012)
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
export ADDCHECKSUMIRON="nice -n 19 perl $HGSERV/scripts/addChecksum-iron.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export IEDIR="/tmp/ieramdisk"
export TWIDGE="/usr/bin/twidge update"
export SUBS="/tmp/ieramdisk/subscriptions"

# Split the Opera-specific stuff off... into its own list
#
sed -n '/Japanese-addon/,/Wildcards/{/Wildcards/!p}'  $MAINDIR/opera/urlfilter.ini > $TESTDIR/urlfilter4.ini

# remove ; from the file
#
sed '/^\;/d' $TESTDIR/urlfilter4.ini > $TESTDIR/urlfilter-jpn.ini

# remove the top line
#
sed '1d' $TESTDIR/urlfilter-jpn.ini > $TESTDIR/urlfilter4.ini

# Merge with main
#
cat $MAINDIR/iron/adblock.ini $TESTDIR/urlfilter4.ini > $TESTDIR/adblock-jpn.ini

# Merge with tracking
#
cat $MAINDIR/iron/complete/adblock.ini $TESTDIR/adblock-jpn.ini > $TESTDIR/adblock-jpn-stats.ini

# remove any blank lines
#
sed '/^$/d' $TESTDIR/adblock-jpn.ini > $TESTDIR/adblock-jpn2.ini
sed '/^$/d' $TESTDIR/adblock-jpn-stats.ini > $TESTDIR/adblock-jpn-stats2.ini

# remove any wildcards
#
tr -d '*' <$TESTDIR/adblock-jpn2.ini >$TESTDIR/adblock-jpn.ini
tr -d '*' <$TESTDIR/adblock-jpn-stats2.ini >$TESTDIR/adblock-jpn-stats.ini

# Checksum the file (Done)
#
$ADDCHECKSUMIRON $TESTDIR/adblock-jpn.ini
$ADDCHECKSUMIRON $TESTDIR/adblock-jpn-stats.ini

# Copy over files
#
cp -f $TESTDIR/adblock-jpn.ini $MAINDIR/iron/jpn/adblock.ini
cp -f $TESTDIR/adblock-jpn-stats.ini $MAINDIR/iron/jpn/complete/adblock.ini

# Remove old gzip'd
#
rm -f $MAINDIR/iron/jpn/adblock.ini.gz
rm -f $MAINDIR/iron/jpn/complete/adblock.ini.gz

# Zip up files..
#
$ZIP $MAINDIR/iron/jpn/adblock.ini.gz $TESTDIR/adblock-jpn.ini &> /dev/null
$ZIP $MAINDIR/iron/jpn/complete/adblock.ini.gz $TESTDIR/adblock-jpn-stats.ini &> /dev/null
