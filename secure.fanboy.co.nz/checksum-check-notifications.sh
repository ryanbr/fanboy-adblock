#!/bin/bash
#
# Checksum Notification List checker
# Prerequisites: Webserver (nginx)
#


# Main WWW Site
export MAINDIR="/var/www"

# Cron job
export CRONDIR="/etc/crons/secure.fanboy.co.nz/"

# Cookie DIR
export COOKDIR="/root/temp/cookies-checksum-notifications"

# Ensure Dir exists.
if [ ! -d "$COOKDIR" ]; then
    mkdir -p "$COOKDIR"
    echo "Folder created: $folder_path"
else
    # echo "Folder already exists: $folder_path"
    :
fi

# date
export CURRENTDATE=$(date +"%Y%m%d_%H%M%S")

# Diff logs
export DIFFLOGS="/var/www/difflogs/diffs"
# Ensure Logs exist.
if [ ! -d "$DIFFLOGS" ]; then
    mkdir -p "$DIFFLOGS"
    echo "Folder created: $folder_path"
else
    # echo "Folder already exists: $folder_path"
    :
fi

# VALIDCHECKSUM CHECKS
export VALIDCHECKSUM="nice -n 19 perl /root/fanboy-adblock/scripts/validateChecksum.pl"

cd $COOKDIR

# fanboy-mobile-notifications.txt.gz
zcat $MAINDIR/fanboy-mobile-notifications.txt.gz > $COOKDIR/fanboy-mobile-notifications.txt.gz.zcat
$VALIDCHECKSUM $COOKDIR/fanboy-mobile-notifications.txt.gz.zcat > $COOKDIR/fanboy-mobile-notifications.txt.gz.zcat.chk

# fanboy-notifications.txt.gz
zcat $MAINDIR/fanboy-notifications.txt.gz > $COOKDIR/fanboy-notifications.txt.gz.zcat
$VALIDCHECKSUM $COOKDIR/fanboy-notifications.txt.gz.zcat > $COOKDIR/fanboy-notifications.txt.gz.zcat.chk

# fanboy-mobile-notifications.txt (non-gzip)
$VALIDCHECKSUM $MAINDIR/fanboy-mobile-notifications.txt > $COOKDIR/fanboy-mobile-notifications.txt.chk
$VALIDCHECKSUM $MAINDIR/fanboy-notifications.txt > $COOKDIR/fanboy-notifications.txt.chk


## Combine together, so we aren't creating too many loops below
cat $COOKDIR/fanboy-mobile-notifications.txt.gz.zcat.chk $COOKDIR/fanboy-notifications.txt.gz.zcat.chk \
    $COOKDIR/fanboy-mobile-notifications.txt.chk $COOKDIR/fanboy-notifications.txt.chk > $COOKDIR/fanboy-notification-checksum.txt

# Notifications List (GZIP)
files=("fanboy-notification-checksum.txt")

for file in "${files[@]}"; do
    if grep -q "\[Wrong checksum\]" "$file"; then
        echo "GZIP'd File '$file' contains '[Wrong checksum]'"

        # Log checksums
        cp -f fanboy-mobile-notifications.txt.gz.zcat.chk $DIFFLOGS/fanboy-mobile-notifications.txt.gz.zcat.$CURRENTDATE.chk
        cp -f fanboy-notifications.txt.gz.zcat.chk $DIFFLOGS/fanboy-notifications.txt.gz.zcat.$CURRENTDATE.chk
        cp -f fanboy-mobile-notifications.txt.chk $DIFFLOGS/fanboy-mobile-notifications.txt.$CURRENTDATE.chk
        cp -f fanboy-notifications.txt.chk $DIFFLOGS/fanboy-notifications.txt.$CURRENTDATE.chk
        # Backup bad files
        cp -f $MAINDIR/fanboy-mobile-notifications.txt.gz $DIFFLOGS/fanboy-mobile-notifications.$CURRENTDATE.txt.gz
        cp -f $MAINDIR/fanboy-notifications.txt.gz $DIFFLOGS/fanboy-notifications.$CURRENTDATE.txt.gz
        cp -f $MAINDIR/fanboy-mobile-notifications.txt $DIFFLOGS/fanboy-mobile-notifications.$CURRENTDATE.txt
        cp -f $MAINDIR/fanboy-notifications.txt $DIFFLOGS/fanboy-notifications.$CURRENTDATE.txt
        . $CRONDIR/make-notifications.sh
        echo "Updated Notifications List, Bad checksum was detected."
    else
        # echo "GZIP'd File '$file' does not contain '[Wrong checksum]'"
        echo "Fanboy Notifcations list has a valid checksum, no updates needed"
    fi
done


# remove old files
rm -rf $COOKDIR/*.txt.gz $COOKDIR/*.chk $COOKDIR/*.zcat $COOKDIR/*.txt
