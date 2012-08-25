#!/bin/bash
#
# Fanboy Adblock IE Convert script v1.4 (25/08/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Variables
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
export IEDIR="/tmp/work/ie"
export IESUBS="/tmp/work/ie/subscriptions"
export IRONDIR="/tmp/Ramdisk/www/adblock/iron"


# Check for temp ie stuff
#
if [ ! -d "$IEDIR" ]; then
    rm -rf $IEDIR
    mkdir $IEDIR; chmod 777 $IEDIR
fi

if [ ! -d "$IEDIR/combineSubscriptions.py" ]; then
    cp -f $HGSERV/scripts/ie/combineSubscriptions.py $IEDIR
fi

# Clear out any old files lurking
#

if [ -d "$IESUBS" ]; then
    rm -rf $IESUBS/*
fi

if [ -d "$IEDIR" ]; then
    rm -rf $IEDIR/*.txt
fi

# Cleanup fanboy-adblock-addon.txt (remove the top 8 lines)
#
sed '1,8d' $HGSERV/ie/fanboy-adblock-addon.txt > $IEDIR/fanboy-adblock-addon.txt

# Merge with Google-code (IE adblock addon)
#

cat $HGSERV/fanboy-adblock/fanboy-header.txt $HGSERV/fanboy-adblock/fanboy-generic.txt $HGSERV/fanboy-adblock/fanboy-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-whitelist.txt $HGSERV/fanboy-adblock/fanboy-dimensions.txt \
        $HGSERV/fanboy-adblock/fanboy-dimensions-whitelist.txt $HGSERV/fanboy-adblock/fanboy-adult-generic.txt $HGSERV/fanboy-adblock/fanboy-adult-firstparty.txt \
        $HGSERV/fanboy-adblock/fanboy-adult-thirdparty.txt $HGSERV/fanboy-adblock/fanboy-adult-whitelists.txt \
        $HGSERV/fanboy-adblock/fanboy-p2p-firstparty.txt $HGSERV/fanboy-adblock/fanboy-p2p-thirdparty.txt > $IEDIR/fanboy-adblock-noele.txt

cat $MAINDIR/fanboy-adblock-noele.txt $IEDIR/fanboy-adblock-addon.txt > $IEDIR/fanboy-noele.txt

# IE Ultimate and Complete
#
cat $IEDIR/fanboy-noele.txt $MAINDIR/fanboy-ultimate-ie.txt > $IEDIR/fanboy-ultimate-ie.txt
cat $IEDIR/fanboy-noele.txt $MAINDIR/fanboy-complete-ie.txt > $IEDIR/fanboy-complete-ie.txt

# Remove Old files
#
rm -rf $IEDIR/fanboy-adblock-noele.txt $IEDIR/fanboy-adblock-addon.txt

# Remove ~third-party
#
sed -i '/~third-party/d' $IEDIR/fanboy-noele.txt $IEDIR/fanboy-ultimate-ie.txt $IEDIR/fanboy-complete-ie.txt

# Generate .tpl IE list
#
python $IEDIR/combineSubscriptions.py $IEDIR $SUBS

# Cleanup Script
#
$HGSERV/scripts/ie/ie-cleanup-filters.sh

# Remove old gz file
#
rm -f $SUBS/fanboy-noele.tpl*.gz
rm -f $SUBS/fanboy-ultimate-*.gz
rm -f $SUBS/fanboy-complete-*.gz

# Re-compress newly modified file
#
$ZIP $SUBS/fanboy-noele.tpl.gz $SUBS/fanboy-noele.tpl > /dev/null
$ZIP $SUBS/fanboy-ultimate-ie.tpl.gz $SUBS/fanboy-ultimate-ie.tpl > /dev/null
$ZIP $SUBS/fanboy-complete-ie.tpl.gz $SUBS/fanboy-complete-ie.tpl > /dev/null

# Now copy finished tpl list to the website.
#
cp -f $SUBS/fanboy-noele.tpl* $MAINDIR/ie/
cp -f $SUBS/fanboy-ultimate-ie.tpl* $MAINDIR/ie/
cp -f $SUBS/fanboy-complete-ie.tpl* $MAINDIR/ie/

