#!/bin/bash
#
# Checksum v2
# Prerequisites: Webserver (nginx)
#


# Main WWW Site
export MAINDIR="/var/www"

# Cron job
export CRONDIR="/etc/crons/secure.fanboy.co.nz/"

# Cookie DIR
export COOKDIR="/root/temp/cookies-checksum"

# Ensure Dir exists.
if [ ! -d "$COOKDIR" ]; then
    mkdir -p "$COOKDIR"
    echo "Folder created: $folder_path"
else
    # echo "Folder already exists: $folder_path"
    :
fi

# VALIDCHECKSUM CHECKS
export VALIDCHECKSUM="nice -n 19 perl /root/fanboy-adblock-list/scripts/validateChecksum.pl"

cd $COOKDIR

# extact gz to plain text.
zcat $MAINDIR/easylist-cookie_ubo.txt.gz > $COOKDIR/easylist-cookie_ubo.txt.gz.zcat
zcat $MAINDIR/easylist-cookie.txt.gz > $COOKDIR/easylist-cookie.txt.gz.zcat
zcat $MAINDIR/fanboy-annoyance_ubo.txt.gz > $COOKDIR/fanboy-annoyance_ubo.txt.gz.zcat
zcat $MAINDIR/fanboy-cookiemonster.txt.gz > $COOKDIR/fanboy-cookiemonster.txt.gz.zcat
# agegate
zcat $MAINDIR/fanboy-agegate.txt.gz > $COOKDIR/fanboy-agegate.txt.gz.zcat
# notifications
zcat $MAINDIR/fanboy-mobile-notifications.txt.gz > $COOKDIR/fanboy-mobile-notifications.txt.gz.zcat
zcat $MAINDIR/fanboy-notifications.txt.gz > $COOKDIR/fanboy-notifications.txt.gz.zcat


$VALIDCHECKSUM $COOKDIR/easylist-cookie_ubo.txt.gz.zcat > $COOKDIR/easylist-cookie_ubo.txt.gz.zcat.chk
$VALIDCHECKSUM $COOKDIR/easylist-cookie.txt.gz.zcat > $COOKDIR/easylist-cookie.txt.gz.zcat.chk
$VALIDCHECKSUM $COOKDIR/fanboy-annoyance_ubo.txt.gz.zcat > $COOKDIR/fanboy-annoyance_ubo.txt.gz.zcat.chk
$VALIDCHECKSUM $COOKDIR/fanboy-cookiemonster.txt.gz.zcat > $COOKDIR/fanboy-cookiemonster.txt.gz.zcat.chk
# agegate
$VALIDCHECKSUM $COOKDIR/fanboy-agegate.txt.gz.zcat > $COOKDIR/fanboy-agegate.txt.gz.zcat.chk
# notifications
$VALIDCHECKSUM $COOKDIR/fanboy-mobile-notifications.txt.gz.zcat > $COOKDIR/fanboy-mobile-notifications.txt.gz.zcat.chk
$VALIDCHECKSUM $COOKDIR/fanboy-notifications.txt.gz.zcat > $COOKDIR/fanboy-notifications.txt.gz.zcat.chk


#### Non gzip'd (Easylist Cookie)

$VALIDCHECKSUM $MAINDIR/easylist-cookie.txt > $COOKDIR/easylist-cookie.txt.chk
$VALIDCHECKSUM $MAINDIR/easylist-cookie_ubo.txt > $COOKDIR/easylist-cookie_ubo.txt.chk
$VALIDCHECKSUM $MAINDIR/fanboy-annoyance.txt > $COOKDIR/fanboy-annoyance.txt.chk
# Easylist Cookie (GZIP)
files=("easylist-cookie_ubo.txt.gz.zcat.chk" "easylist-cookie.txt.gz.zcat.chk" "fanboy-annoyance_ubo.txt.gz.zcat.chk" "fanboy-cookiemonster.txt.gz.zcat.chk" "easylist-cookie.txt.chk" "easylist-cookie_ubo.txt.chk" "fanboy-annoyance.txt.chk")

for file in "${files[@]}"; do
    if grep -q "\[Wrong checksum\]" "$file"; then
        echo "GZIP'd File '$file' contains '[Wrong checksum]'"
        . $CRONDIR/easylist-cookie-mirror.sh
        
    else
        echo "GZIP'd File '$file' does not contain '[Wrong checksum]'"
    fi
done

#### Non gzip'd (AGE GATE List)
$VALIDCHECKSUM $MAINDIR/fanboy-agegate.txt > $COOKDIR/fanboy-agegate.txt.chk
# AGE GATE List (GZIP)
files=("fanboy-agegate.txt.gz.zcat.chk" "fanboy-agegate.txt.chk")

for file in "${files[@]}"; do
    if grep -q "\[Wrong checksum\]" "$file"; then
        echo "GZIP'd File '$file' contains '[Wrong checksum]'"
        . $CRONDIR/age-gate.sh
        
    else
        echo "GZIP'd File '$file' does not contain '[Wrong checksum]'"
    fi
done

$VALIDCHECKSUM $MAINDIR/fanboy-mobile-notifications.txt > $COOKDIR/fanboy-mobile-notifications.txt.chk
$VALIDCHECKSUM $MAINDIR/fanboy-notifications.txt > $COOKDIR/fanboy-notifications.txt.chk

# Notifications List (GZIP)
files=("fanboy-mobile-notifications.txt.gz.zcat.chk" "fanboy-notifications.txt.gz.zcat.chk" "fanboy-mobile-notifications.txt.chk" "fanboy-notifications.txt.chk")

for file in "${files[@]}"; do
    if grep -q "\[Wrong checksum\]" "$file"; then
        echo "GZIP'd File '$file' contains '[Wrong checksum]'"
        . $CRONDIR/make-notifications.sh
        
    else
        echo "GZIP'd File '$file' does not contain '[Wrong checksum]'"
    fi
done


# remove old files
rm -rf $COOKDIR/*.txt.gz $COOKDIR/*.chk $COOKDIR/*.zcat
