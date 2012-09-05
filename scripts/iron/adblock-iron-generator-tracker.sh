#!/bin/bash
#
# Fanboy Adblock Iron Convert script v2.0 (30/08/2012)
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
sed -n '/Stats list (Opera)/,/Wildcards/{/Wildcards/!p}' $MAINDIR/opera/complete/urlfilter.ini > $TESTDIR/urlfilter3.ini

# remove ; from the file
#
sed '/^\;/d' $TESTDIR/urlfilter3.ini > $TESTDIR/urlfilter4.ini

# remove the top line
#
sed '1d' $TESTDIR/urlfilter4.ini > $TESTDIR/urlfilter-stats.ini

# Merge with tracking
#
cat $MAINDIR/iron/adblock.ini $TESTDIR/urlfilter-stats.ini > $TESTDIR/adblock-stats.ini

# remove any blank lines
#
sed '/^$/d' $TESTDIR/adblock-stats.ini > $TESTDIR/adblock2-stats.ini

# remove any wildcards
#
tr -d '*' <$TESTDIR/adblock2-stats.ini >$MAINDIR/iron/complete/adblock.ini

# Checksum the file (Done)
#
$ADDCHECKSUMIRON $MAINDIR/iron/complete/adblock.ini
rm $MAINDIR/iron/complete/adblock.ini.gz

# echo "adblock.ini copied" > /dev/null
#
$ZIP $MAINDIR/iron/complete/adblock.ini.gz $MAINDIR/iron/complete/adblock.ini > /dev/null
 