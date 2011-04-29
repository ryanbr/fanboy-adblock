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
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list"
ZIP="/usr/local/bin/7za"
IEDIR="/tmp/ieramdisk"
SUBS="/tmp/ieramdisk/subscriptions"

# Clear out any old files lurking
#
rm -rf $IEDIR/* $SUBS/*

# Copy TPL (Microsoft IE9) Script
#
# cp -f /root/maketpl.pl $IEDIR

####### Placeholder ########
# Cleanup fanboy-espanol-addon.txt (remove the top 8 lines) 
#
# sed '1,8d' $GOOGLEDIR/ie/fanboy-espanol-addon.txt > $IEDIR/fanboy-espanol-addon.txt

# Take out the element blocks from the list
#
sed -n '/Adblock Plus/,/Generic Spanish/{/Generic Spanish/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt > $IEDIR/fanboy-espanol.txt

####### Placeholder ########
# Merge with Google-code (IE adblock addon)
#
# cat $IEDIR/fanboy-espanol.txt $IEDIR/fanboy-espanol-addon.txt > $IEDIR/fanboy-espanol-merged.txt
# mv -f $IEDIR/fanboy-espanol-merged.txt $IEDIR/fanboy-espanol.txt

####### Placeholder ########
# Remove Old files
#
# rm -rf $IEDIR/fanboy-espanol-addon.txt

# Generate .tpl IE list
#
# perl $IEDIR/maketpl.pl &> /dev/null
cp -f $GOOGLEDIR/scripts/ie/combineSubscriptions.py $IEDIR
python $IEDIR/combineSubscriptions.py

# Now remove filters that cause issues in IE (and false positives)
#
sed -i '/# elnuevodiario.com/d' $SUBS/fanboy-espanol.tpl
sed -i '/# ondacero.es/d' $SUBS/fanboy-espanol.tpl
sed -i '/# uol.com.br/d' $SUBS/fanboy-espanol.tpl
sed -i '/# ||/d' $SUBS/fanboy-espanol.tpl
sed -i '/# @@/d' $SUBS/fanboy-espanol.tpl
sed -i '/# .imageshack.us/d' $SUBS/fanboy-espanol.tpl

# Remove last line of file
#
sed '$d' $SUBS/fanboy-espanol.tpl > $SUBS/fanboy-espanol-trim.tpl
mv -f $SUBS/fanboy-espanol-trim.tpl $SUBS/fanboy-espanol.tpl

# Remove old gz file
#
rm -f $SUBS/fanboy-espanol.tpl*.gz

# Re-compress newly modified file
#
$ZIP a -mx=9 -y -tgzip $SUBS/fanboy-espanol.tpl.gz $SUBS/fanboy-espanol.tpl > /dev/null

# Now copy finished tpl list to the website.
#
cp -f $SUBS/fanboy-espanol*.tpl* $MAINDIR/ie/
