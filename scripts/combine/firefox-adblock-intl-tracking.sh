#!/bin/bash
#
# Fanboy Regional Tracking Combination script v1.4 (18/03/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#

export ZIP="nice -n 19 /usr/local/bin/7za a -mx=9 -y -tgzip"
export NICE="nice -n 19"
export TAC="/usr/bin/tac"
export CAT="/bin/cat"
export MAINDIR="/tmp/Ramdisk/www/adblock"
export SPLITDIR="/tmp/Ramdisk/www/adblock/split/test"
export HGSERV="/tmp/hgstuff/fanboy-adblock-list"
export TESTDIR="/tmp/work"
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export IEDIR="/tmp/ieramdisk"
export SUBS="/tmp/ieramdisk/subscriptions"
export IRONDIR="/tmp/Ramdisk/www/adblock/iron"

# Copy the Tracking addon from google dir
#
cp -f $HGSYNC/other/tracking-intl.txt $TESTDIR

sed '1,10d' $HGSYNC/ie/fanboy-tracking-addon.txt > $TESTDIR/fanboy-tracking-addon2.txt
mv -f $TESTDIR/fanboy-tracking-addon2.txt $TESTDIR/fanboy-tracking-addon.txt

# Copy Filters from the subscriptions..
#
sed -n '/Czech Trackers/,/Slovak Filters/{/Slovak Filters/!p}' $HGSYNC/firefox-regional/fanboy-adblocklist-cz.txt > $TESTDIR/fanboy-cz-track.txt
sed -n '/Russian Trackers/,/Russian Whitelist/{/Russian Whitelist/!p}' $HGSYNC/firefox-regional/fanboy-adblocklist-rus-v2.txt > $TESTDIR/fanboy-rus-track.txt
sed -n '/Turkish Trackers/,/Firefox 3.x/{/Firefox 3.x/!p}' $HGSYNC/firefox-regional/fanboy-adblocklist-tky.txt > $TESTDIR/fanboy-tky-track.txt
sed -n '/Japanese Trackers/,/Japanese Whitelist/{/Japanese Whitelist/!p}' $HGSYNC/firefox-regional/fanboy-adblocklist-jpn.txt > $TESTDIR/fanboy-jpn-track.txt
sed -n '/Korean Trackers/,/Korean Specific Whitelists/{/Korean Specific Whitelists/!p}' $HGSYNC/firefox-regional/fanboy-adblocklist-krn.txt > $TESTDIR/fanboy-krn-track.txt
sed -n '/Italian Trackers/,/Whitelists/{/Whitelists/!p}' $HGSYNC/firefox-regional/fanboy-adblocklist-ita.txt> $TESTDIR/fanboy-ita-track.txt
sed -n '/Polish Trackers/,/Polish Whitelist/{/Polish Whitelist/!p}' $HGSYNC/firefox-regional/fanboy-adblocklist-pol.txt > $TESTDIR/fanboy-pol-track.txt
sed -n '/Indian Trackers/,/Indian Whitelists/{/Indian Whitelists/!p}' $HGSYNC/firefox-regional/fanboy-adblocklist-ind.txt > $TESTDIR/fanboy-ind-track.txt
sed -n '/Vietnamese Trackers/,/Whitelists/{/Whitelists/!p}' $HGSYNC/firefox-regional/fanboy-adblocklist-vtn.txt > $TESTDIR/fanboy-vtn-track.txt
sed -n '/Chinese Trackers/,/Chinese Whitelist/{/Chinese Whitelist/!p}' $HGSYNC/firefox-regional/fanboy-adblocklist-chn.txt > $TESTDIR/fanboy-chn-track.txt
sed -n '/Portuguese Trackers/,/Portuguese Generic/{/Portuguese Generic/!p}' $HGSYNC/firefox-regional/fanboy-adblocklist-esp.txt > $TESTDIR/fanboy-esp-track.txt
sed -n '/Swedish Trackers/,/Swedish Whitelist/{/Swedish Whitelist/!p}' $HGSYNC/firefox-regional/fanboy-adblocklist-swe.txt > $TESTDIR/fanboy-swe-track.txt

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
#
#
sed -i '/||cnzz.com/stat/d' $TESTDIR/fanboy-chn-track.txt
sed -i '/\/webtrekk./d' $TESTDIR/fanboy-ita-track.txt
sed -i '/.cn\/urchin.js/d' $TESTDIR/fanboy-chn-track.txt
sed -i '/||zoosnet.net/d' $TESTDIR/fanboy-chn-track.txt
sed -i '/||stat.tudou.com/d' $TESTDIR/fanboy-chn-track.txt
sed -i '/||bugun.com.tr\^\*\/stat.aspx/d' $TESTDIR/fanboy-tky-track.txt
sed -i '/||dot.wp.pl/d' $TESTDIR/fanboy-pol-track.txt
sed -i '/.com\/logger\//d' $TESTDIR/fanboy-krn-track.txt
sed -i '/||mc.yandex.ru/d' $TESTDIR/fanboy-rus-track.txt
sed -i '/||hotlog.ru/d' $TESTDIR/fanboy-rus-track.txt
sed -i '/||rek.www.wp.pl/d' $TESTDIR/fanboy-pol-track.txt
sed -i '/||spylog.ru\/counter/d' $TESTDIR/fanboy-rus-track.txt
sed -i '/||videoplaza.com\/proxy\/tracker/d' $TESTDIR/fanboy-swe-track.txt
sed -i '/||easyresearch.se/d' $TESTDIR/fanboy-swe-track.txt
sed -i '/||webiqonline.com/d' $TESTDIR/fanboy-krn-track.txt
sed -i '/||tns-counter.ru/d' $TESTDIR/fanboy-rus-track.txt
sed -i '/||newstogram/d' $TESTDIR/fanboy-esp-track.txt
sed -i '/||net-filter.com/d' $TESTDIR/fanboy-ind-track.txt
sed -i '/||openstat.net/d' $TESTDIR/fanboy-rus-track.txt
sed -i '/||post.rmbn.ru/d' $TESTDIR/fanboy-rus-track.txt
sed -i '/||waplog.net/d' $TESTDIR/fanboy-rus-track.txt


# Merge Everything together
#
# Merge for IE trackers
cat $TESTDIR/fanboy-esp-track.txt $TESTDIR/fanboy-cz-track.txt $TESTDIR/fanboy-rus-track.txt $TESTDIR/fanboy-vtn-track.txt $TESTDIR/fanboy-tky-track.txt $TESTDIR/fanboy-jpn-track.txt $TESTDIR/fanboy-krn-track.txt $TESTDIR/fanboy-ita-track.txt $TESTDIR/fanboy-pol-track.txt $TESTDIR/fanboy-chn-track.txt $TESTDIR/fanboy-swe-track.txt $TESTDIR/fanboy-ind-track.txt > $TESTDIR/fanboy-track-test-ie.txt
# Merge enhanced for Firefox
cat $HGSYNC/enhancedstats-addon.txt $TESTDIR/fanboy-track-test-ie.txt > $TESTDIR/fanboy-track-test.txt
# Create a backup incase addchecksum "zeros" the file
#
cp -f $TESTDIR/fanboy-track-test.txt $TESTDIR/fanboy-track-bak.txt
$ADDCHECKSUM $TESTDIR/fanboy-track-test.txt

# Now lets check if fanboy-track-test.txt isnt zero
#
if [ -s $TESTDIR/fanboy-track-test.txt ];
then
  cp -f $TESTDIR/fanboy-track-test.txt $MAINDIR/enhancedstats.txt
  # mv -f $TESTDIR/fanboy-track-test.txt $MAINDIR/fanboy-tracking-complete.txt

  ### echo "Updated enhancedstats.txt"
  rm -f $MAINDIR/enhancedstats.txt.gz
  # Compress file
  #
  $ZIP $MAINDIR/enhancedstats.txt.gz $TESTDIR/fanboy-track-test.txt > /dev/null
  # Log
  echo "Updated enhancedstats.txt (script: firefox-adblock-intl-tracking.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
else
  # Use the backup file (fanboy-track-test.txt was zero'd by addchecksum)
  #
  sleep 2
  perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-track-bak.txt
  cp -f $TESTDIR/fanboy-track-bak.txt $MAINDIR/enhancedstats.txt
  # mv -f $TESTDIR/fanboy-track-test.txt $MAINDIR/fanboy-tracking-complete.txt

  ### echo "Updated enhancedstats.txt (file was zero)"
  rm -f $MAINDIR/enhancedstats.txt.gz
  # Compress file
  #
  $ZIP $MAINDIR/enhancedstats.txt.gz $TESTDIR/fanboy-track-test.txt > /dev/null
  # Log
  echo "*** ERROR ***: Addchecksum Zero'd the file: enhancedstats.txt (script: firefox-adblock-intl-tracking.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
fi
  