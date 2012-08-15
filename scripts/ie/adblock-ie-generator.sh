#!/bin/bash
#
# Fanboy Adblock IE Convert script v1.3 (16/04/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#

# Creating a 10Mb ramdisk Temp storage...
#
if [ ! -d "/tmp/ieramdisk/" ]; then
    rm -rf /tmp/ieramdisk/
    mkdir /tmp/ieramdisk; chmod 777 /tmp/ieramdisk
    mount -t tmpfs -o size=10M tmpfs /tmp/ieramdisk/
    cp -f /home/fanboy/google/fanboy-adblock-list/scripts/ie/combineSubscriptions.py /tmp/ieramdisk/
    mkdir /tmp/ieramdisk/subscriptions
    mkdir /tmp/ieramdisk/subscriptions/temp
fi

# Variables
#
export MAINDIR="/tmp/Ramdisk/www"
export GOOGLEDIR="/tmp/hgstuff/fanboy-adblock-list"
export TESTDIR="/tmp/work"
export IEDIR="/tmp/ieramdisk"
export SUBS="/tmp/ieramdisk/subscriptions"
export ZIP="nice -n 19 /usr/local/bin/7za"
export NICE="nice -n 19"

# Clear out any old files lurking
#
rm -rf $IEDIR/*.txt $SUBS/*
cd $IEDIR

# Copy TPL (Microsoft IE9) Script
#
# cp -f /root/maketpl.pl $IEDIR

# Cleanup fanboy-adblock-addon.txt (remove the top 8 lines)
#
sed '1,8d' $GOOGLEDIR/ie/fanboy-adblock-addon.txt > $IEDIR/fanboy-adblock-addon.txt

# Merge with Google-code (IE adblock addon)
#
cat $MAINDIR/fanboy-adblock-noele.txt $IEDIR/fanboy-adblock-addon.txt > $IEDIR/fanboy-noele.txt

# IE Ultimate and Complete
#
cat $IEDIR/fanboy-noele.txt $MAINDIR/fanboy-ultimate-ie.txt > $IEDIR/fanboy-ultimate-ie.txt
cat $IEDIR/fanboy-noele.txt $MAINDIR/fanboy-complete-ie.txt > $IEDIR/fanboy-complete-ie.txt

# Remove Old files
#
rm -rf $IEDIR/fanboy-adblock-noele.txt $IEDIR/fanboy-adblock-addon.txt

# Remove ~third-party
#
sed -i '/~third-party/d' $IEDIR/fanboy-noele.txt $IEDIR/fanboy-ultimate-ie.txt $IEDIR/fanboy-complete-ie.txt

# Generate .tpl IE list
#
# perl $IEDIR/maketpl.pl &> /dev/null
python $GOOGLEDIR/scripts/ie/combineSubscriptions.py $IEDIR $SUBS

# Cleanup Script
#
$GOOGLEDIR/scripts/ie/ie-cleanup-filters.sh

# Remove old gz file
#
rm -f $SUBS/fanboy-noele.tpl*.gz
rm -f $SUBS/fanboy-ultimate-*.gz
rm -f $SUBS/fanboy-complete-*.gz

# Re-compress newly modified file
#
$ZIP a -mx=9 -y -tgzip $SUBS/fanboy-noele.tpl.gz $SUBS/fanboy-noele.tpl > /dev/null
$ZIP a -mx=9 -y -tgzip $SUBS/fanboy-ultimate-ie.tpl.gz $SUBS/fanboy-ultimate-ie.tpl > /dev/null
$ZIP a -mx=9 -y -tgzip $SUBS/fanboy-complete-ie.tpl.gz $SUBS/fanboy-complete-ie.tpl > /dev/null

# Now copy finished tpl list to the website.
#
cp -f $SUBS/fanboy-noele.tpl* $MAINDIR/ie/
cp -f $SUBS/fanboy-ultimate-ie.tpl* $MAINDIR/ie/
cp -f $SUBS/fanboy-complete-ie.tpl* $MAINDIR/ie/

