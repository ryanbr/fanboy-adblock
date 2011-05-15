#!/bin/bash
#
# Fanboy Adblock Iron Convert script (russian) v1.0 (15/05/2011)
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
sed -n '/Russian-addon/,/Wildcards/{/Wildcards/!p}'  $MAINDIR/rus/urlfilter.ini > $TESTDIR/urlfilter4.ini

# remove the top line
#
sed '1d' $TESTDIR/urlfilter4.ini > $TESTDIR/urlfilter-rus.ini

# remove # from the file
#
sed '/^\#/d' $TESTDIR/urlfilter-rus.ini > $TESTDIR/urlfilter-rus2.ini

# Merge with main
#
cat $IRONDIR/adblock.ini $TESTDIR/urlfilter-rus2.ini > $TESTDIR/adblock-rus.ini

# Merge with tracking
#
cat $IRONDIR/complete/adblock.ini $TESTDIR/adblock-rus.ini > $TESTDIR/adblock-rus-stats.ini

# remove any blank lines
#
sed '/^$/d' $TESTDIR/adblock-rus.ini > $TESTDIR/adblock-rus2.ini
sed '/^$/d' $TESTDIR/adblock-rus-stats.ini > $TESTDIR/adblock-rus-stats2.ini

# remove any wildcards
#
tr -d '*' <$TESTDIR/adblock-rus2.ini >$IRONDIR/rus/adblock.ini
tr -d '*' <$TESTDIR/adblock-rus-stats2.ini >$IRONDIR/rus/complete/adblock.ini

# Checksum the file (Done)
#
perl $IRONDIR/addChecksum-opera.pl $IRONDIR/rus/adblock.ini
perl $IRONDIR/addChecksum-opera.pl $IRONDIR/rus/complete/adblock.ini
rm $IRONDIR/rus/adblock.ini.gz 
rm $IRONDIR/rus/complete/adblock.ini.gz

# Zip up files..
#
$ZIP a -mx=9 -y -tgzip $IRONDIR/rus/adblock.ini.gz $IRONDIR/rus/adblock.ini > /dev/null
$ZIP a -mx=9 -y -tgzip $IRONDIR/rus/complete/adblock.ini.gz $IRONDIR/rus/complete/adblock.ini > /dev/null
