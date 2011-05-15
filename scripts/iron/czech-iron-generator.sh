#!/bin/bash
#
# Fanboy Adblock Iron Convert script (czech) v1.0 (15/05/2011)
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
sed -n '/cz-addon/,/Wildcards/{/Wildcards/!p}'  $MAINDIR/cz/urlfilter.ini > $TESTDIR/urlfilter4.ini

# remove the top line
#
sed '1d' $TESTDIR/urlfilter4.ini > $TESTDIR/urlfilter-cz.ini

# remove # from the file
#
sed '/^\#/d' $TESTDIR/urlfilter-cz.ini > $TESTDIR/urlfilter-cz2.ini

# Merge with main
#
cat $IRONDIR/adblock.ini $TESTDIR/urlfilter-cz2.ini > $TESTDIR/adblock-cz.ini

# Merge with tracking
#
cat $IRONDIR/complete/adblock.ini $TESTDIR/adblock-cz.ini > $TESTDIR/adblock-cz-stats.ini

# remove any blank lines
#
sed '/^$/d' $TESTDIR/adblock-cz.ini > $TESTDIR/adblock-cz2.ini
sed '/^$/d' $TESTDIR/adblock-cz-stats.ini > $TESTDIR/adblock-cz-stats2.ini

# remove any wildcards
#
tr -d '*' <$TESTDIR/adblock-cz2.ini >$IRONDIR/cz/adblock.ini
tr -d '*' <$TESTDIR/adblock-cz-stats2.ini >$IRONDIR/cz/complete/adblock.ini

# Checksum the file (Done)
#
perl $IRONDIR/addChecksum-opera.pl $IRONDIR/cz/adblock.ini
perl $IRONDIR/addChecksum-opera.pl $IRONDIR/cz/complete/adblock.ini
rm $IRONDIR/cz/adblock.ini.gz 
rm $IRONDIR/cz/complete/adblock.ini.gz

# Zip up files..
#
$ZIP a -mx=9 -y -tgzip $IRONDIR/cz/adblock.ini.gz $IRONDIR/cz/adblock.ini > /dev/null 
$ZIP a -mx=9 -y -tgzip $IRONDIR/cz/complete/adblock.ini.gz $IRONDIR/cz/complete/adblock.ini > /dev/null
