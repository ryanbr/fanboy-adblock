#!/bin/bash
#
# Fanboy Adblock Iron Convert script (russian) v1.1 (15/05/2011)
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

# Split the Opera-specific stuff off... into its own list
#
sed -n '/Russian-addon/,/Wildcards/{/Wildcards/!p}'  $GOOGLEDIR/opera/urlfilter-rus.ini > $TESTDIR/urlfilter4.ini

# remove ; from the file
#
sed '/^\;/d' $TESTDIR/urlfilter4.ini > $TESTDIR/urlfilter-rus.ini

# remove the top line
#
sed '1d' $TESTDIR/urlfilter-rus.ini > $TESTDIR/urlfilter4.ini

# Merge with main
#
cat $IRONDIR/adblock.ini $TESTDIR/urlfilter4.ini > $TESTDIR/adblock-rus.ini

# Merge with tracking
#
cat $IRONDIR/complete/adblock.ini $TESTDIR/urlfilter4.ini > $TESTDIR/adblock-rus-stats.ini

# remove any blank lines
#
sed '/^$/d' $TESTDIR/adblock-rus.ini > $TESTDIR/adblock-rus2.ini
sed '/^$/d' $TESTDIR/adblock-rus-stats.ini > $TESTDIR/adblock-rus-stats2.ini

# remove any wildcards
#
tr -d '*' <$TESTDIR/adblock-rus2.ini >$TESTDIR/adblock-rus.ini
tr -d '*' <$TESTDIR/adblock-rus-stats2.ini >$TESTDIR/adblock-stats.ini

# Checksum the file (Done)
#
perl $IRONDIR/addChecksum-opera.pl $TESTDIR/adblock-rus.ini
perl $IRONDIR/addChecksum-opera.pl $TESTDIR/adblock-stats.ini

# Copy over files
#
cp -f $TESTDIR/adblock-rus.ini $IRONDIR/rus/adblock.ini
cp -f $TESTDIR/adblock-stats.ini $IRONDIR/rus/complete/adblock.ini


# Zip up files..
#
rm $IRONDIR/rus/adblock.ini.gz
rm $IRONDIR/rus/complete/adblock.ini.gz
$ZIP a -mx=9 -y -tgzip $IRONDIR/rus/adblock.ini.gz $TESTDIR/adblock-rus.ini > /dev/null
$ZIP a -mx=9 -y -tgzip $IRONDIR/rus/complete/adblock.ini.gz $TESTDIR/adblock-stats.ini > /dev/null
