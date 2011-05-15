#!/bin/bash
#
# Fanboy Adblock Iron Convert script (espanol) v1.0 (15/05/2011)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#

# Creating a 10Mb ramdisk Temp storage...
#
if [ ! -d "/tmp/iron/" ]; then
    rm -rf /tmp/iron/
    mkdir /tmp/iron; chmod 777 /tmp/iron
    mount -t tmpfs -o size=10M tmpfs /tmp/iron/
fi

# Variables
#
MAINDIR="/var/www/adblock/opera"
IRONDIR="/var/www/adblock/iron"
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list"
ZIP="/usr/local/bin/7za"
TESTDIR="/tmp/iron"

# Split the Opera-specific stuff off... into its own list
#
sed -n '/Portuguese-addon/,/Wildcards/{/Wildcards/!p}'  $MAINDIR/esp/urlfilter.ini > $TESTDIR/urlfilter4.ini

# remove the top line
#
sed '1d' $TESTDIR/urlfilter4.ini > $TESTDIR/urlfilter-esp.ini

# remove # from the file
#
sed '/^\#/d' $TESTDIR/urlfilter-esp.ini > $TESTDIR/urlfilter-esp2.ini

# Merge with main
#
cat $IRONDIR/adblock.ini $TESTDIR/urlfilter-esp2.ini > $TESTDIR/adblock-esp.ini

# Merge with tracking
#
cat $IRONDIR/complete/adblock.ini $TESTDIR/adblock-esp.ini > $TESTDIR/adblock-esp-stats.ini

# remove any blank lines
#
sed '/^$/d' $TESTDIR/adblock-esp.ini > $TESTDIR/adblock-esp2.ini
sed '/^$/d' $TESTDIR/adblock-esp-stats.ini > $TESTDIR/adblock-esp-stats2.ini

# remove any wildcards
#
tr -d '*' <$TESTDIR/adblock-esp2.ini >$IRONDIR/esp/adblock.ini
tr -d '*' <$TESTDIR/adblock-esp-stats2.ini >$IRONDIR/esp/complete/adblock.ini

# Checksum the file (Done)
#
perl $IRONDIR/addChecksum-opera.pl $IRONDIR/esp/adblock.ini
perl $IRONDIR/addChecksum-opera.pl $IRONDIR/esp/complete/adblock.ini
rm $IRONDIR/esp/adblock.ini.gz 
rm $IRONDIR/esp/complete/adblock.ini.gz

# Zip up files..
#
$ZIP a -mx=9 -y -tgzip $IRONDIR/esp/adblock.ini.gz $IRONDIR/esp/adblock.ini > /dev/null
$ZIP a -mx=9 -y -tgzip $IRONDIR/esp/complete/adblock.ini.gz $IRONDIR/esp/complete/adblock.ini > /dev/null
