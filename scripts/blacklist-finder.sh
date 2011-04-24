# Fanboy Adblock Blacklist script v1.0 (24/04/2011)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Finding Blacklisted filters in the list that were mistakently added..
#
#

BLACKLISTDIR="/home/fanboy/blacklists"
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list/scripts/blacklists"

#
# Find any bad filters in the adblock (fanboy-adblock.txt) file
#
cp /var/www/fanboy-adblock.txt $BLACKLISTDIR/list.txt
tr '[:upper:]' '[:lower:]' < $BLACKLISTDIR/list.txt > $BLACKLISTDIR/output.txt
cp $GOOGLEDIR/blacklist-adblock.txt $BLACKLISTDIR/list1.temp
tr '[:upper:]' '[:lower:]' < $BLACKLISTDIR/list1.temp > $BLACKLISTDIR/blacklist-adblock.txt
awk 'FNR==NR{b[$1];next}{for(i in b){if($0 == i){ print}}}' $BLACKLISTDIR/blacklist-adblock.txt $BLACKLISTDIR/output.txt > $BLACKLISTDIR/fanboy-adblock-bad.txt

if [[ -s $BLACKLISTDIR/fanboy-adblock-bad.txt ]] ; then
   mail -s "Blacklist Scan (Adblock List)" mp3geek@gmail.com < $BLACKLISTDIR/fanboy-adblock-bad.txt
else
   echo "Blacklist scan completed, nothing detected.." > /dev/null
fi ;

#
# Find any bad filters in the Tracking (fanboy-tracking.txt) file
#
cp /var/www/fanboy-tracking.txt $BLACKLISTDIR/list.txt
tr '[:upper:]' '[:lower:]' < $BLACKLISTDIR/list.txt > $BLACKLISTDIR/output.txt
cp $GOOGLEDIR/blacklist-tracking.txt $BLACKLISTDIR/list2.temp
tr '[:upper:]' '[:lower:]' < $BLACKLISTDIR/list2.temp > $BLACKLISTDIR/blacklist-tracking.txt
awk 'FNR==NR{b[$1];next}{for(i in b){if($0 == i){ print}}}' $BLACKLISTDIR/blacklist-tracking.txt $BLACKLISTDIR/output.txt > $BLACKLISTDIR/fanboy-tracking-bad.txt

if [[ -s $BLACKLISTDIR/fanboy-tracking-bad.txt ]] ; then
   mail -s "Blacklist (Tracking List)" mp3geek@gmail.com < $BLACKLISTDIR/fanboy-tracking-bad.txt
else
   echo "Blacklist scan completed, nothing detected.." > /dev/null
fi ;