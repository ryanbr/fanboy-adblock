#!/bin/bash
#
# Fanboy Tracking IE Convert script v1.2 (17/04/2011)
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
    mkdir /tmp/ieramdisk/subscriptions
fi

# Variables
#
MAINDIR="/var/www/adblock"
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list"
ZIP="/usr/local/bin/7za"
IEDIR="/tmp/ieramdisk"
SUBS="/tmp/ieramdisk/subscriptions"

# Clear out any old files lurking
#
rm -rf $IEDIR/* $SUBS/*

# Copy TPL (Microsoft IE9) Script
#
cp -f /root/maketpl.pl $IEDIR

# Cleanup fanboy-tracking-addon.txt (remove the top 8 lines) 
#
sed '1,8d' $GOOGLEDIR/ie/fanboy-tracking-addon.txt > $IEDIR/fanboy-tracking-addon.txt

# Merge with Google-code (IE adblock addon)
#
cat $MAINDIR/fanboy-tracking-complete.txt $IEDIR/fanboy-tracking-addon.txt > $IEDIR/fanboy-tracking-merged.txt
mv -f $IEDIR/fanboy-tracking-merged.txt $IEDIR/fanboy-tracking.txt

# Remove Old files
#
rm -rf $IEDIR/fanboy-tracking-addon.txt

# Generate .tpl IE list
#
perl $IEDIR/maketpl.pl &> /dev/null

# Now remove filters that cause issues in IE (and false positives)
#
sed -i '/Do-Not-Track/d' $SUBS/fanboy-tracking.tpl
sed -i '/#  /d' $SUBS/fanboy-tracking.tpl
sed -i '/donottrack/d' $SUBS/fanboy-tracking.tpl
sed -i '/# http/d' $SUBS/fanboy-tracking.tpl
sed -i '/-d nbcudigitaladops.com/d' $SUBS/fanboy-tracking.tpl
sed -i '/+d dhl./d' $SUBS/fanboy-tracking.tpl
sed -i '/+d server-au.imrworldwide.com/d' $SUBS/fanboy-tracking.tpl
sed -i '/+d secure-us.imrworldwide.com/d' $SUBS/fanboy-tracking.tpl
sed -i '/+d revsci.net/d' $SUBS/fanboy-tracking.tpl
sed -i '/+d js.revsci.net/d' $SUBS/fanboy-tracking.tpl
sed -i '/# :/d' $SUBS/fanboy-tracking.tpl
sed -i '/# \./d' $SUBS/fanboy-tracking.tpl
sed -i '/# \//d' $SUBS/fanboy-tracking.tpl
sed -i '/# \@/d' $SUBS/fanboy-tracking.tpl
sed -i '/# ||/d' $SUBS/fanboy-tracking.tpl
sed -i '/+d easy.box/d' $SUBS/fanboy-tracking.tpl
sed -i '/- /quant.js/d' $SUBS/fanboy-tracking.tpl

# Remove old gz file
#
rm -f $SUBS/fanboy-tracking.tpl*.gz

# Re-compress newly modified file
#
$ZIP a -mx=9 -y -tgzip $SUBS/fanboy-tracking.tpl.gz $SUBS/fanboy-tracking.tpl > /dev/null

# Now copy finished tpl list to the website.
#
cp -f $SUBS/fanboy-tracking*.tpl* $MAINDIR/ie/
