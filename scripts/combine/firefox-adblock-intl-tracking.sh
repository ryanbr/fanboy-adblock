#!/bin/bash
#
# Fanboy-Merge-complete Adblock list grabber script v1.2 (11/02/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#

# Creating a 20Mb ramdisk Temp storage...
#
if [ ! -d "/tmp/ramdisk/" ]; then
    rm -rf /tmp/ramdisk/
    mkdir /tmp/ramdisk; chmod 777 /tmp/ramdisk
    mount -t tmpfs -o size=20M tmpfs /tmp/ramdisk/
    mkdir /tmp/ramdisk/opera/
fi

# Variables for directorys
#
MAINDIR="/var/www/adblock"
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list"
TESTDIR="/tmp/ramdisk"
ZIP="/usr/local/bin/7za"

# Copy the Tracking addon from google dir
#
cp -f $GOOGLEDIR/other/tracking-intl.txt $TESTDIR

sed '1,10d' $GOOGLEDIR/ie/fanboy-tracking-addon.txt > $TESTDIR/fanboy-tracking-addon2.txt
mv -f $TESTDIR/fanboy-tracking-addon2.txt $TESTDIR/fanboy-tracking-addon.txt

# Copy Filters from the subscriptions..
#
sed -n '/Czech Trackers/,/Slovak Filters/{/Slovak Filters/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt > $TESTDIR/fanboy-cz-track.txt
sed -n '/Russian Trackers/,/Russian Whitelist/{/Russian Whitelist/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt > $TESTDIR/fanboy-rus-track.txt
sed -n '/Turkish Trackers/,/Firefox 3.x/{/Firefox 3.x/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt > $TESTDIR/fanboy-tky-track.txt
sed -n '/Japanese Trackers/,/Japanese Whitelist/{/Japanese Whitelist/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt > $TESTDIR/fanboy-jpn-track.txt
sed -n '/Korean Trackers/,/Korean Specific Whitelists/{/Korean Specific Whitelists/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt > $TESTDIR/fanboy-krn-track.txt
sed -n '/Italian Trackers/,/Whitelists/{/Whitelists/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt> $TESTDIR/fanboy-ita-track.txt
sed -n '/Polish Trackers/,/Polish Whitelist/{/Polish Whitelist/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt > $TESTDIR/fanboy-pol-track.txt
sed -n '/Indian Trackers/,/Indian Whitelists/{/Indian Whitelists/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt > $TESTDIR/fanboy-ind-track.txt
sed -n '/Vietnamese Trackers/,/Whitelists/{/Whitelists/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt > $TESTDIR/fanboy-vtn-track.txt
sed -n '/Chinese Trackers/,/Chinese Whitelist/{/Chinese Whitelist/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt > $TESTDIR/fanboy-chn-track.txt
sed -n '/Portuguese Trackers/,/Portuguese Generic/{/Portuguese Generic/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt > $TESTDIR/fanboy-esp-track.txt
sed -n '/Swedish Trackers/,/Swedish Whitelist/{/Swedish Whitelist/!p}' $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt > $TESTDIR/fanboy-swe-track.txt

# Remove Dubes and bad filters
#
sed -i '/\/stats.php/d' $TESTDIR/fanboy-ind-track.txt
sed -i '/c.waplog.net/d' $TESTDIR/fanboy-ind-track.txt
sed -i '/stat24.com/d' $TESTDIR/fanboy-pol-track.txt
sed -i '/stat.4u.pl/d' $TESTDIR/fanboy-cz-track.txt
sed -i '/publicidees.com/d' $TESTDIR/fanboy-ita-track.txt
sed -i '/hbxmodify/d' $TESTDIR/fanboy-krn-track.txt
sed -i '/urchin.js/d' $TESTDIR/fanboy-jpn-track.txt
sed -i '/topshoptv.com.ua/d' $TESTDIR/fanboy-rus-track.txt
sed -i '/stats.e-go.gr/d' $TESTDIR/fanboy-rus-track.txt
sed -i '/nigma.ru/d' $TESTDIR/fanboy-rus-track.txt
sed -i '/gemius_/d' $TESTDIR/fanboy-rus-track.txt

# Merge Everything together
#
# Merge for IE trackers
cat $TESTDIR/fanboy-esp-track.txt $TESTDIR/fanboy-cz-track.txt $TESTDIR/fanboy-rus-track.txt $TESTDIR/fanboy-tky-track.txt $TESTDIR/fanboy-jpn-track.txt $TESTDIR/fanboy-krn-track.txt $TESTDIR/fanboy-ita-track.txt $TESTDIR/fanboy-pol-track.txt $TESTDIR/fanboy-swe-track.txt $TESTDIR/fanboy-ind-track.txt > $TESTDIR/fanboy-track-test-ie.txt
# Merge enhanced for Firefox
cat $GOOGLEDIR/enhancedstats-addon.txt $TESTDIR/fanboy-track-test-ie.txt > $TESTDIR/fanboy-track-test.txt
perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-track-test.txt
cp -f $TESTDIR/fanboy-track-test.txt $MAINDIR/enhancedstats.txt
# mv -f $TESTDIR/fanboy-track-test.txt $MAINDIR/fanboy-tracking-complete.txt

# Compress file
#
rm -f $MAINDIR/enhancedstats.txt.gz
$ZIP a -mx=9 -y -tgzip $MAINDIR/enhancedstats.txt.gz $TESTDIR/fanboy-track-test.txt > /dev/null