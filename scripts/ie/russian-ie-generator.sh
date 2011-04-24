#!/bin/bash
#
# Fanboy Russian IE Convert script v1.2 (17/04/2011)
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

# Cleanup fanboy-russian-addon.txt (remove the top 8 lines)
#
sed '1,8d' $GOOGLEDIR/ie/fanboy-russian-addon.txt > $IEDIR/fanboy-russian-addon.txt

# Take out the element blocks from the list
#
sed -n '/Adblock Plus/,/Site specific/{/Site specific/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt > $IEDIR/fanboy-russian.txt

# Merge with Google-code (IE adblock addon)
#
cat $IEDIR/fanboy-russian.txt $IEDIR/fanboy-russian-addon.txt > $IEDIR/fanboy-russian-merged.txt
mv -f $IEDIR/fanboy-russian-merged.txt $IEDIR/fanboy-russian.txt

# Remove Old files
#
rm -rf $IEDIR/fanboy-russian-addon.txt

# Generate .tpl IE list
#
perl $IEDIR/addChecksum-opera.pl &> /dev/null

# Now remove filters that cause issues in IE (and false positives)
#
sed -i '/+d b.dclick.ru/d' $SUBS/fanboy-russian.tpl
sed -i '/+d redtram.com/d' $SUBS/fanboy-russian.tpl
sed -i '/+d advert.kp.ru/d' $SUBS/fanboy-russian.tpl
sed -i '/+d echo.msk.ru/d' $SUBS/fanboy-russian.tpl
sed -i '/+d ad.adriver.ru/d' $SUBS/fanboy-russian.tpl
sed -i '/# ||/d' $SUBS/fanboy-russian.tpl
sed -i '/# @@/d' $SUBS/fanboy-russian.tpl
sed -i '/Firefox 3.x/d' $SUBS/fanboy-russian.tpl
sed -i '/# :\/\//d' $SUBS/fanboy-russian.tpl

# Regerate Checksum
#
perl $MAINDIR/addChecksum.pl $SUBS/fanboy-russian.tpl &> /dev/null

# Remove old gz file
#
rm -f $SUBS/fanboy-russian.tpl*.gz

# Re-compress newly modified file
#
$ZIP a -mx=9 -y -tgzip $SUBS/fanboy-russian.tpl.gz $SUBS/fanboy-russian.tpl > /dev/null

# Now copy finished tpl list to the website.
#
cp -f $SUBS/fanboy-russian*.tpl* $MAINDIR/ie/
