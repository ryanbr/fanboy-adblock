#!/bin/bash
#
# Fanboy Adblock Iron Convert script (czech) v1.1 (03/09/2011)
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
sed -n '/cz-addon/,/Wildcards/{/Wildcards/!p}'  $MAINDIR/opera/urlfilter.ini > $TESTDIR/urlfilter4.ini

# remove ; from the file
#
sed '/^\;/d' $TESTDIR/urlfilter4.ini > $TESTDIR/urlfilter-cz.ini

# remove the top line
#
sed '1d' $TESTDIR/urlfilter-cz.ini > $TESTDIR/urlfilter4.ini

# Merge with main
#
cat $MAINDIR/iron/adblock.ini $TESTDIR/urlfilter4.ini > $TESTDIR/adblock-cz.ini

# Merge with tracking
#
cat $MAINDIR/iron/complete/adblock.ini $TESTDIR/adblock-cz.ini > $TESTDIR/adblock-cz-stats.ini

# remove any blank lines
#
sed '/^$/d' $TESTDIR/adblock-cz.ini > $TESTDIR/adblock-cz2.ini
sed '/^$/d' $TESTDIR/adblock-cz-stats.ini > $TESTDIR/adblock-cz-stats2.ini

# remove any wildcards
#
tr -d '*' <$TESTDIR/adblock-cz2.ini >$TESTDIR/adblock-cz.ini
tr -d '*' <$TESTDIR/adblock-cz-stats2.ini >$TESTDIR/adblock-cz-stats.ini

# Checksum the file (Done)
#
$ADDCHECKSUMOPERA $TESTDIR/adblock-cz.ini
$ADDCHECKSUMOPERA $TESTDIR/adblock-cz-stats.ini

# Copy over files
#
cp -f $TESTDIR/adblock-cz.ini $MAINDIR/iron/cz/adblock.ini
cp -f $TESTDIR/adblock-cz-stats.ini $MAINDIR/iron/cz/complete/adblock.ini

# Remove old gzip'd
#
rm -f $MAINDIR/iron/cz/adblock.ini.gz
rm -f $MAINDIR/iron/cz/complete/adblock.ini.gz

# Zip up files..
#
$ZIP $MAINDIR/iron/cz/adblock.ini.gz $TESTDIR/adblock-cz.ini &> /dev/null
$ZIP $MAINDIR/iron/cz/complete/adblock.ini.gz $TESTDIR/adblock-cz-stats.ini &> /dev/null
