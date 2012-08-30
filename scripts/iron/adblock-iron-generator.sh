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
export ADDCHECKSUMOPERA="nice -n 19 perl $HGSERV/scripts/addChecksum-opera.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export IEDIR="/tmp/ieramdisk"
export TWIDGE="/usr/bin/twidge update"
export SUBS="/tmp/ieramdisk/subscriptions"

# Split the Opera-specific stuff off... into its own list
#
sed -n '/exclude]/,/Wildcards/{/Wildcards/!p}' $MAINDIR/opera/urlfilter.ini > $TESTDIR/urlfilter2.ini

# remove ; from the file
#
sed '/^\;/d' $TESTDIR/urlfilter2.ini > $TESTDIR/urlfilter3.ini

# remove the top line
#
sed '1d' $TESTDIR/urlfilter3.ini > $TESTDIR/urlfilter.ini

# Merge with main
#
cat $MAINDIR/iron/header.txt $TESTDIR/urlfilter.ini > $TESTDIR/adblock.ini

# remove any blank lines
#
sed '/^$/d' $TESTDIR/adblock.ini > $TESTDIR/adblock2.ini

# remove any wildcards
#
tr -d '*' <$TESTDIR/adblock2.ini >$TESTDIR/adblock.ini

# Checksum the file (Done)
#
$ADDCHECKSUMOPERA $TESTDIR/adblock.ini
cp -f $TESTDIR/adblock.ini $MAINDIR/iron/adblock.ini
rm $MAINDIR/iron/adblock.ini.gz

# echo "adblock.ini copied" > /dev/null
#
$ZIP $MAINDIR/iron/adblock.ini.gz $TESTDIR/adblock.ini &> /dev/null
