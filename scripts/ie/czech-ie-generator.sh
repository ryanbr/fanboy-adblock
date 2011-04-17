#!/bin/bash
#
# Fanboy Espanol/Portuguese IE Convert script v1.2 (17/04/2011)
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
GOOGLEDIR="/root/google/fanboy-adblock-list"
ZIP="/usr/local/bin/7za"
IEDIR="/tmp/ieramdisk"
SUBS="/tmp/ieramdisk/subscriptions"

# Clear out any old files lurking
#
rm -rf $IEDIR/* $SUBS/*

# Copy TPL (Microsoft IE9) Script
#
cp -f /root/maketpl.pl $IEDIR

####### Placeholder ########
# Cleanup fanboy-cz-addon.txt (remove the top 8 lines) 
#
# sed '1,8d' $GOOGLEDIR/ie/fanboy-cz-addon.txt > $IEDIR/fanboy-cz-addon.txt

# Take out the element blocks from the list
#
sed -n '/Adblock Plus/,/Firefox 3.x/{/Firefox 3.x/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt > $IEDIR/fanboy-czech.txt

####### Placeholder ########
# Merge with Google-code (IE adblock addon)
#
# cat $IEDIR/fanboy-czech.txt $IEDIR/fanboy-czech-addon.txt > $IEDIR/fanboy-czech-merged.txt
# mv -f $IEDIR/fanboy-czech-merged.txt $IEDIR/fanboy-czech.txt

####### Placeholder ########
# Remove Old files
#
# rm -rf $IEDIR/fanboy-czech-addon.txt

# Generate .tpl IE list
#
perl $IEDIR/maketpl.pl &> /dev/null

# Now remove filters that cause issues in IE (and false positives)
#
sed -i '/# \./d' $SUBS/fanboy-czech.tpl
sed -i '/# \//d' $SUBS/fanboy-czech.tpl
sed -i '/# ||/d' $SUBS/fanboy-czech.tpl
sed -i '/# @@/d' $SUBS/fanboy-czech.tpl
sed -i '/# pokec.azet.sk/d' $SUBS/fanboy-czech.tpl
sed -i '/# lepsiebyvanie.centrum.sk/d' $SUBS/fanboy-czech.tpl

# Remove last line of file
#
sed '$d' $SUBS/fanboy-czech.tpl > $SUBS/fanboy-czech-trim.tpl
mv -f $SUBS/fanboy-czech-trim.tpl $SUBS/fanboy-czech.tpl

# Regerate Checksum
#
perl $MAINDIR/addChecksum.pl $SUBS/fanboy-czech.tpl &> /dev/null

# Remove old gz file
#
rm -f $SUBS/fanboy-czech.tpl*.gz

# Re-compress newly modified file
#
$ZIP a -mx=9 -y -tgzip $SUBS/fanboy-czech.tpl.gz $SUBS/fanboy-czech.tpl > /dev/null

# Now copy finished tpl list to the website.
#
cp -f $SUBS/fanboy-czech*.tpl* $MAINDIR/ie/
