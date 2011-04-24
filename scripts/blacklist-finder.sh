# Fanboy Adblock Blacklist script v1.0 (24/04/2011)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Finding Blacklisted filters in the list that were mistakently added..
#

# Variables
#
BLACKLISTDIR="/home/fanboy/blacklists"
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list/scripts"

# Find any bad filters in the adblock (fanboy-adblock.txt) file
#
cp /var/www/fanboy-adblock.txt $BLACKLISTDIR/list.txt

# Remove false positives from the file first.
#
sed -i '/||jta.org/d' $BLACKLISTDIR/list.txt
sed -i '/||static.linkedin.com/d' $BLACKLISTDIR/list.txt
sed -i '/||a.giantrealm.com^$script/d' $BLACKLISTDIR/list.txt
sed -i '/||kraken.giantrealm.com^/d' $BLACKLISTDIR/list.txt
sed -i '/||ltassrv.com\/serve\//d' $BLACKLISTDIR/list.txt
sed -i '/||pagead2\.\*\/pagead\/\*\.js/d' $BLACKLISTDIR/list.txt
sed -i '/||xmlconfig.ltassrv.com/d' $BLACKLISTDIR/list.txt
sed -i '/@@/d' $BLACKLISTDIR/list.txt

tr '[:upper:]' '[:lower:]' < $BLACKLISTDIR/list.txt > $BLACKLISTDIR/output.txt
cp $GOOGLEDIR/blacklists/blacklist-adblock.txt $BLACKLISTDIR/list1.temp
tr '[:upper:]' '[:lower:]' < $BLACKLISTDIR/list1.temp > $BLACKLISTDIR/blacklist-adblock.txt

# Run perl check
#
perl $GOOGLEDIR/blacklist-check.pl $BLACKLISTDIR/output.txt $BLACKLISTDIR/blacklist-adblock.txt > $BLACKLISTDIR/fanboy-adblock-bad.txt

if [[ -s $BLACKLISTDIR/fanboy-adblock-bad.txt ]] ; then
   mail -s "Blacklist Scan (Adblock List)" mp3geek@gmail.com < $BLACKLISTDIR/fanboy-adblock-bad.txt
else
   echo "Blacklist scan completed, nothing detected.." > /dev/null
fi ;

# Find any bad filters in the Tracking (fanboy-tracking.txt) file
#
cp /var/www/fanboy-tracking.txt $BLACKLISTDIR/list.txt
tr '[:upper:]' '[:lower:]' < $BLACKLISTDIR/list.txt > $BLACKLISTDIR/output.txt
cp $GOOGLEDIR/blacklists/blacklist-tracking.txt $BLACKLISTDIR/list2.temp
tr '[:upper:]' '[:lower:]' < $BLACKLISTDIR/list2.temp > $BLACKLISTDIR/blacklist-tracking.txt

# Run perl check
#
perl $GOOGLEDIR/blacklist-check.pl $BLACKLISTDIR/output.txt $BLACKLISTDIR/blacklist-tracking.txt > $BLACKLISTDIR/fanboy-tracking-bad.txt

if [[ -s $BLACKLISTDIR/fanboy-tracking-bad.txt ]] ; then
   mail -s "Blacklist Scan (Tracking List)" mp3geek@gmail.com < $BLACKLISTDIR/fanboy-tracking-bad.txt
else
   echo "Blacklist scan completed, nothing detected.." > /dev/null
fi ;