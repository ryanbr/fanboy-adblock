#!/bin/bash
#
# Fanboy IE Cleanup (29/08/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Variables
#

export IEDIR="/tmp/work/ie"
export IESUBS="/tmp/work/ie/subscriptions"

# Now remove filters that cause issues in IE (and false positives)
#
sed -i '10,20000{/\#/d}' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '10,20000{/#/d}' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d atdmt.com/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d doubleclick.net/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/247realmedia.com/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/googlesyndication.com/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/scorecardresearch.com/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/oascentral.thechronicleherald.ca/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/au.adserver.yahoo.com/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d adserver.yahoo.com/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d skimlinks.com/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d ad-emea.doubleclick.net/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d ad.au.doubleclick.net/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d spotxchange.com/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/adf.ly/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d ad-emea.doubleclick.net/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d g.doubleclick.net/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d pagead2.googlesyndication.com/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d partner.googleadservices.com/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d ads.yimg.com/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d ad.ca.doubleclick.net/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d ad.doubleclick.net/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d zedo.com/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
# http://hg.fanboy.co.nz/rev/5760d7c3afb3
sed -i '/&adsType=/d' $IESUBS/fanboy-noele.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl

# Now remove filters that cause issues in IE (and false positives)
#
sed -i '9,20000{/\#/d}' $IESUBS/fanboy-tracking.tpl
sed -i '9,20000{/#/d}' $IESUBS/fanboy-tracking.tpl

sed -i '/Do-Not-Track/d' $IESUBS/fanboy-tracking.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/donottrack/d' $IESUBS/fanboy-tracking.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/-d nbcudigitaladops.com/d' $IESUBS/fanboy-tracking.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/-d dw.com.com/d' $IESUBS/fanboy-tracking.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d dhl./d' $IESUBS/fanboy-tracking.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d server-au.imrworldwide.com/d' $IESUBS/fanboy-tracking.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d secure-us.imrworldwide.com/d' $IESUBS/fanboy-tracking.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d revsci.net/d' $IESUBS/fanboy-tracking.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d js.revsci.net/d' $IESUBS/fanboy-tracking.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/+d easy.box/d' $IESUBS/fanboy-tracking.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/- \/quant.js/d' $IESUBS/fanboy-tracking.tpl $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
sed -i '/post-flair/d' $IESUBS/fanboy-ultimate-ie.tpl $IESUBS/fanboy-complete-ie.tpl
