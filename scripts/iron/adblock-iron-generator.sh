#!/bin/bash
#
# Fanboy Adblock Iron Convert script v1.0 (15/05/2011)
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
sed -n '/exclude]/,/Wildcards/{/Wildcards/!p}' $MAINDIR/urlfilter.ini > $TESTDIR/urlfilter2.ini
sed -n '/Stats list (Opera)/,/Wildcards/{/Wildcards/!p}' $MAINDIR/complete/urlfilter.ini > $TESTDIR/urlfilter3.ini
sed -n '/Russian-addon/,/Wildcards/{/Wildcards/!p}'  $MAINDIR/rus/urlfilter.ini > $TESTDIR/urlfilter4.ini

# remove the top line
#
sed '1d' $TESTDIR/urlfilter2.ini > $TESTDIR/urlfilter.ini
sed '1d' $TESTDIR/urlfilter3.ini > $TESTDIR/urlfilter-stats.ini
sed '1d' $TESTDIR/urlfilter4.ini > $TESTDIR/urlfilter-rus.ini

# remove # from the file
#
sed '/^\#/d' $TESTDIR/urlfilter.ini > $TESTDIR/urlfilter2.ini
sed '/^\#/d' $TESTDIR/urlfilter-stats.ini > $TESTDIR/urlfilter-stats2.ini
cat $IRONDIR/header.txt $TESTDIR/urlfilter2.ini > $TESTDIR/adblock.ini
# Merge with tracking
cat $TESTDIR/adblock.ini $TESTDIR/urlfilter-stats2.ini > $TESTDIR/adblock-stats.ini


# remove any blank lines
#
sed '/^$/d' $TESTDIR/adblock.ini > $TESTDIR/adblock2.ini
sed '/^$/d' $TESTDIR/adblock-stats.ini > $TESTDIR/adblock2-stats.ini

#
# remove any wildcards
#
tr -d '*' <$TESTDIR/adblock2.ini >$IRONDIR/adblock.ini
tr -d '*' <$TESTDIR/adblock2-stats.ini >$IRONDIR/complete/adblock.ini

# Checksum the file (Done)
#
perl $IRONDIR/addChecksum-opera.pl $IRONDIR/adblock.ini
perl $IRONDIR/addChecksum-opera.pl $IRONDIR/complete/adblock.ini
rm $IRONDIR/adblock.ini.gz
rm $IRONDIR/complete/adblock.ini.gz

# echo "adblock.ini copied" > /dev/null
#
$ZIP a -mx=9 -y -tgzip $IRONDIR/adblock.ini.gz $IRONDIR/adblock.ini > /dev/null
$ZIP a -mx=9 -y -tgzip $IRONDIR/complete/adblock.ini.gz $IRONDIR/complete/adblock.ini > /dev/null
