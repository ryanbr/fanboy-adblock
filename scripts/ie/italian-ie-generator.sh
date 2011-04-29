#!/bin/bash
#
# Fanboy Italian IE Convert script v1.2 (17/04/2011)
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
# Cleanup fanboy-ita-addon.txt (remove the top 8 lines) 
#
# sed '1,8d' $GOOGLEDIR/ie/fanboy-ita-addon.txt > $IEDIR/fanboy-ita-addon.txt

# Take out the element blocks from the list
#
sed -n '/Adblock Plus/,/Firefox 3.x/{/Firefox 3.x/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt > $IEDIR/fanboy-italian.txt

####### Placeholder ########
# Merge with Google-code (IE adblock addon)
#
# cat $IEDIR/fanboy-italian.txt $IEDIR/fanboy-ita-addon.txt > $IEDIR/fanboy-ita-merged.txt
# mv -f $IEDIR/fanboy-ita-merged.txt $IEDIR/fanboy-italian.txt

####### Placeholder ########
# Remove Old files
#
# rm -rf $IEDIR/fanboy-ita-addon.txt

# Generate .tpl IE list
#
# perl $IEDIR/maketpl.pl &> /dev/null

python $IEDIR/combineSubscriptions.py

# Now remove filters that cause issues in IE (and false positives)
#
sed -i '/# \./d' $SUBS/fanboy-italian.tpl
sed -i '/# \//d' $SUBS/fanboy-italian.tpl
sed -i '/# ||/d' $SUBS/fanboy-italian.tpl
sed -i '/# @@/d' $SUBS/fanboy-italian.tpl
sed -i '/# #/d' $SUBS/fanboy-italian.tpl
sed -i '/###/d' $SUBS/fanboy-italian.tpl
sed -i '/##\./d' $SUBS/fanboy-italian.tpl

# Remove last line of file
#
sed '$d' $SUBS/fanboy-italian.tpl > $SUBS/fanboy-italian-trim.tpl
mv -f $SUBS/fanboy-italian-trim.tpl $SUBS/fanboy-italian.tpl

# Remove old gz file
#
rm -f $SUBS/fanboy-italian.tpl*.gz

# Re-compress newly modified file
#
$ZIP a -mx=9 -y -tgzip $SUBS/fanboy-italian.tpl.gz $SUBS/fanboy-italian.tpl > /dev/null

# Now copy finished tpl list to the website.
#
cp -f $SUBS/fanboy-italian*.tpl* $MAINDIR/ie/
