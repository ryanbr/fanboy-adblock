#!/bin/bash
#
# Fanboy Turkish IE Convert script v1.2 (17/04/2011)
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
    cp -f $GOOGLEDIR/scripts/ie/combineSubscriptions.py /tmp/ieramdisk/
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
rm -rf $IEDIR/*.txt $SUBS/*
cd $IEDIR

# Copy TPL (Microsoft IE9) Script
#
# cp -f /root/maketpl.pl $IEDIR

####### Placeholder ########
# Cleanup fanboy-tky-addon.txt (remove the top 8 lines) 
#
# sed '1,8d' $GOOGLEDIR/ie/fanboy-tky-addon.txt > $IEDIR/fanboy-tky-addon.txt

# Take out the element blocks from the list
#
sed -n '/Adblock Plus/,/Firefox 3.x/{/Firefox 3.x/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt > $IEDIR/fanboy-turkish.txt

####### Placeholder ########
# Merge with Google-code (IE adblock addon)
#
# cat $IEDIR/fanboy-turkish.txt $IEDIR/fanboy-tky-addon.txt > $IEDIR/fanboy-tky-merged.txt
# mv -f $IEDIR/fanboy-tky-merged.txt $IEDIR/fanboy-turkish.txt

####### Placeholder ########
# Remove Old files
#
# rm -rf $IEDIR/fanboy-tky-addon.txt

# Generate .tpl IE list
#
# perl $IEDIR/maketpl.pl &> /dev/null
python $IEDIR/combineSubscriptions.py

# Now remove filters that cause issues in IE (and false positives)
#
sed -i '/# \./d' $SUBS/fanboy-turkish.tpl
sed -i '/# \//d' $SUBS/fanboy-turkish.tpl
sed -i '/# ||/d' $SUBS/fanboy-turkish.tpl
sed -i '/# @@/d' $SUBS/fanboy-turkish.tpl

# Remove last line of file
#
sed '$d' $SUBS/fanboy-turkish.tpl > $SUBS/fanboy-turkish-trim.tpl
mv -f $SUBS/fanboy-turkish-trim.tpl $SUBS/fanboy-turkish.tpl


# Remove old gz file
#
rm -f $SUBS/fanboy-turkish.tpl*.gz

# Re-compress newly modified file
#
$ZIP a -mx=9 -y -tgzip $SUBS/fanboy-turkish.tpl.gz $SUBS/fanboy-turkish.tpl > /dev/null

# Now copy finished tpl list to the website.
#
cp -f $SUBS/fanboy-turkish*.tpl* $MAINDIR/ie/
