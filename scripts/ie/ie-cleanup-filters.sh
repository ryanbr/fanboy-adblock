#!/bin/bash
#
# Fanboy IE Cleanup (31/07/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#

# Creating a 10Mb ramdisk Temp storage...
#
if [ ! -d "/tmp/ieramdisk/subscriptions" ]; then
    rm -rf /tmp/ieramdisk/
    mkdir /tmp/ieramdisk; chmod 777 /tmp/ieramdisk
    mount -t tmpfs -o size=10M tmpfs /tmp/ieramdisk/
    cp -f $MAINDIR/scripts/ie/combineSubscriptions.py /tmp/ieramdisk/
    mkdir /tmp/ieramdisk/subscriptions
    mkdir /tmp/ieramdisk/subscriptions/temp
fi

# Now remove filters that cause issues in IE (and false positives)
#
sed -i '10,20000{/\#/d}' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '10,20000{/#/d}' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d atdmt.com/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d doubleclick.net/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d 247realmedia.com/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d googlesyndication.com/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d scorecardresearch.com/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d oascentral.thechronicleherald.ca/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d au.adserver.yahoo.com/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d adserver.yahoo.com/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d skimlinks.com/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d ad-emea.doubleclick.net/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d ad.au.doubleclick.net/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d spotxchange.com/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/adf.ly/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d ad-emea.doubleclick.net/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d g.doubleclick.net/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d pagead2.googlesyndication.com/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d partner.googleadservices.com/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d ads.yimg.com/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d ad.ca.doubleclick.net/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d ad.doubleclick.net/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d zedo.com/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
# http://hg.fanboy.co.nz/rev/5760d7c3afb3
sed -i '/&adsType=/d' $SUBS/fanboy-noele.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl

# Now remove filters that cause issues in IE (and false positives)
#
sed -i '9,20000{/\#/d}' $SUBS/fanboy-tracking.tpl
sed -i '9,20000{/#/d}' $SUBS/fanboy-tracking.tpl

sed -i '/Do-Not-Track/d' $SUBS/fanboy-tracking.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/donottrack/d' $SUBS/fanboy-tracking.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/-d nbcudigitaladops.com/d' $SUBS/fanboy-tracking.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/-d dw.com.com/d' $SUBS/fanboy-tracking.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d dhl./d' $SUBS/fanboy-tracking.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d server-au.imrworldwide.com/d' $SUBS/fanboy-tracking.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d secure-us.imrworldwide.com/d' $SUBS/fanboy-tracking.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d revsci.net/d' $SUBS/fanboy-tracking.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d js.revsci.net/d' $SUBS/fanboy-tracking.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/+d easy.box/d' $SUBS/fanboy-tracking.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/- \/quant.js/d' $SUBS/fanboy-tracking.tpl $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
sed -i '/post-flair/d' $SUBS/fanboy-ultimate-ie.tpl $SUBS/fanboy-complete-ie.tpl
