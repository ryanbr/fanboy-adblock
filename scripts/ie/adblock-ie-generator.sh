#!/bin/bash
#
# Fanboy Adblock IE Convert script v1.2 (17/04/2011)
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

# Cleanup fanboy-adblock-addon.txt (remove the top 8 lines)
#
sed '1,8d' $GOOGLEDIR/ie/fanboy-adblock-addon.txt > $IEDIR/fanboy-adblock-addon.txt

# Merge with Google-code (IE adblock addon)
#
cat $MAINDIR/fanboy-adblock-noele.txt $IEDIR/fanboy-adblock-addon.txt > $IEDIR/fanboy-noele.txt

# Remove Old files
#
rm -rf $IEDIR/fanboy-adblock-noele.txt $IEDIR/fanboy-adblock-addon.txt

# Generate .tpl IE list
#
perl $IEDIR/maketpl.pl &> /dev/null

# Now remove filters that cause issues in IE (and false positives)
#
sed -i '/+d atdmt.com/d' $SUBS/fanboy-noele.tpl
sed -i '/+d doubleclick.net/d' $SUBS/fanboy-noele.tpl
sed -i '/+d 247realmedia.com/d' $SUBS/fanboy-noele.tpl
sed -i '/+d googlesyndication.com/d' $SUBS/fanboy-noele.tpl
sed -i '/+d scorecardresearch.com/d' $SUBS/fanboy-noele.tpl
sed -i '/# \//d' $SUBS/fanboy-noele.tpl
sed -i '/+d oascentral.thechronicleherald.ca/d' $SUBS/fanboy-noele.tpl
sed -i '/+d au.adserver.yahoo.com/d' $SUBS/fanboy-noele.tpl
sed -i '/+d adserver.yahoo.com/d' $SUBS/fanboy-noele.tpl
sed -i '/+d skimlinks.com/d' $SUBS/fanboy-noele.tpl
sed -i '/# @@/d' $SUBS/fanboy-noele.tpl
sed -i '/+d ad-emea.doubleclick.net/d' $SUBS/fanboy-noele.tpl
sed -i '/+d ad.au.doubleclick.net/d' $SUBS/fanboy-noele.tpl
sed -i '/+d spotxchange.com/d' $SUBS/fanboy-noele.tpl
sed -i '/+d ad-emea.doubleclick.net/d' $SUBS/fanboy-noele.tpl
sed -i '/# ||/d' $SUBS/fanboy-noele.tpl
sed -i '/+d g.doubleclick.net/d' $SUBS/fanboy-noele.tpl
sed -i '/+d pagead2.googlesyndication.com/d' $SUBS/fanboy-noele.tpl
sed -i '/+d partner.googleadservices.com/d' $SUBS/fanboy-noele.tpl
sed -i '/+d ads.yimg.com/d' $SUBS/fanboy-noele.tpl
sed -i '/+d ad.ca.doubleclick.net/d' $SUBS/fanboy-noele.tpl
sed -i '/+d ad.doubleclick.net/d' $SUBS/fanboy-noele.tpl
sed -i '/+d zedo.com/d' $SUBS/fanboy-noele.tpl

# Regerate Checksum
#
perl $MAINDIR/addChecksum.pl $SUBS/fanboy-noele.tpl &> /dev/null

# Remove old gz file
#
rm -f $SUBS/fanboy-noele.tpl*.gz

# Re-compress newly modified file
#
$ZIP a -mx=9 -y -tgzip $SUBS/fanboy-noele.tpl.gz $SUBS/fanboy-noele.tpl > /dev/null

# Now copy finished tpl list to the website.
#
cp -f $SUBS/fanboy-noele*.tpl* $MAINDIR/ie/
