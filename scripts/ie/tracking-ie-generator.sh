#!/bin/bash
#
# Fanboy Tracking IE Convert script v1.3 (12/02/2012)
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

# Clear out any old files lurking
#
rm -rf $IEDIR/*.txt $SUBS/*
cd $IEDIR

# Copy TPL (Microsoft IE9) Script
#
# cp -f /root/maketpl.pl $IEDIR

# Cleanup fanboy-tracking-addon.txt (remove the top 8 lines) 
#
sed '1,8d' $GOOGLEDIR/ie/fanboy-tracking-addon.txt > $IEDIR/fanboy-tracking-addon.txt

# Merge with Google-code (IE adblock addon)
#
cat $MAINDIR/fanboy-adblocklist-stats.txt $TESTDIR/fanboy-track-test-ie.txt $IEDIR/fanboy-tracking-addon.txt > $IEDIR/fanboy-tracking-merged.txt
mv -f $IEDIR/fanboy-tracking-merged.txt $IEDIR/fanboy-tracking.txt

# Remove ~third-party
#
sed -i '/~third-party/d' $IEDIR/fanboy-tracking.txt

# Remove Old files
#
rm -rf $IEDIR/fanboy-tracking-addon.txt

# Generate .tpl IE list
#
# perl $IEDIR/maketpl.pl &> /dev/null
python $IEDIR/combineSubscriptions.py $IEDIR $SUBS

# Cleanup Script
#
$GOOGLEDIR/scripts/ie/ie-cleanup-filters.sh

# Remove old gz file
#
rm -f $SUBS/fanboy-tracking.tpl*.gz

# Re-compress newly modified file
#
$ZIP a -mx=9 -y -tgzip $SUBS/fanboy-tracking.tpl.gz $SUBS/fanboy-tracking.tpl > /dev/null

# Now copy finished tpl list to the website.
#
cp -f $SUBS/fanboy-tracking.tpl $SUBS/fanboy-tracking.tpl.gz $MAINDIR/ie/


