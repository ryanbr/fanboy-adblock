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
export VALIDCHECKSUM="nice -n 19 perl /root/fanboy-adblock-list/scripts/validateChecksum.pl"

cd $COOKDIR

# easylist-cookie_ubo.txt.gz
zcat $MAINDIR/easylist-cookie_ubo.txt.gz > $COOKDIR/easylist-cookie_ubo.txt.gz.zcat
$VALIDCHECKSUM $COOKDIR/easylist-cookie_ubo.txt.gz.zcat > $COOKDIR/easylist-cookie_ubo.txt.gz.zcat.chk

# easylist-cookie.txt.gz
zcat $MAINDIR/easylist-cookie.txt.gz > $COOKDIR/easylist-cookie.txt.gz.zcat
$VALIDCHECKSUM $COOKDIR/easylist-cookie.txt.gz.zcat > $COOKDIR/easylist-cookie.txt.gz.zcat.chk

# fanboy-annoyance_ubo.txt.gz
zcat $MAINDIR/fanboy-annoyance_ubo.txt.gz > $COOKDIR/fanboy-annoyance_ubo.txt.gz.zcat
$VALIDCHECKSUM $COOKDIR/fanboy-annoyance_ubo.txt.gz.zcat > $COOKDIR/fanboy-annoyance_ubo.txt.gz.zcat.chk

# fanboy-cookiemonster.txt.gz
zcat $MAINDIR/fanboy-cookiemonster.txt.gz > $COOKDIR/fanboy-cookiemonster.txt.gz.zcat
$VALIDCHECKSUM $COOKDIR/fanboy-cookiemonster.txt.gz.zcat > $COOKDIR/fanboy-cookiemonster.txt.gz.zcat.chk

# fanboy-agegate.txt.gz
zcat $MAINDIR/fanboy-agegate.txt.gz > $COOKDIR/fanboy-agegate.txt.gz.zcat
$VALIDCHECKSUM $COOKDIR/fanboy-agegate.txt.gz.zcat > $COOKDIR/fanboy-agegate.txt.gz.zcat.chk

# fanboy-mobile-notifications.txt.gz
zcat $MAINDIR/fanboy-mobile-notifications.txt.gz > $COOKDIR/fanboy-mobile-notifications.txt.gz.zcat
$VALIDCHECKSUM $COOKDIR/fanboy-mobile-notifications.txt.gz.zcat > $COOKDIR/fanboy-mobile-notifications.txt.gz.zcat.chk

# fanboy-notifications.txt.gz
zcat $MAINDIR/fanboy-notifications.txt.gz > $COOKDIR/fanboy-notifications.txt.gz.zcat
$VALIDCHECKSUM $COOKDIR/fanboy-notifications.txt.gz.zcat > $COOKDIR/fanboy-notifications.txt.gz.zcat.chk

# fanboy-mobile-notifications.txt (non-gzip)
$VALIDCHECKSUM $MAINDIR/fanboy-mobile-notifications.txt > $COOKDIR/fanboy-mobile-notifications.txt.chk
$VALIDCHECKSUM $MAINDIR/fanboy-notifications.txt > $COOKDIR/fanboy-notifications.txt.chk


#### Non gzip'd (Easylist Cookie)

$VALIDCHECKSUM $MAINDIR/easylist-cookie.txt > $COOKDIR/easylist-cookie.txt.chk
$VALIDCHECKSUM $MAINDIR/easylist-cookie_ubo.txt > $COOKDIR/easylist-cookie_ubo.txt.chk
$VALIDCHECKSUM $MAINDIR/fanboy-annoyance.txt > $COOKDIR/fanboy-annoyance.txt.chk
$VALIDCHECKSUM $COOKDIR/fanboy-agegate.txt > $COOKDIR/fanboy-agegate.txt.chk


# Easylist Cookie + Fanboy Annoyances (GZIP)
files=("easylist-cookie_ubo.txt.gz.zcat.chk" 
       "easylist-cookie.txt.gz.zcat.chk" 
       "fanboy-annoyance_ubo.txt.gz.zcat.chk" 
       "fanboy-cookiemonster.txt.gz.zcat.chk" 
       "easylist-cookie.txt.chk" 
       "easylist-cookie_ubo.txt.chk" 
       "fanboy-annoyance.txt.chk"
)

for file in "${files[@]}"; do
    if grep -q "\[Wrong checksum\]" "$file"; then
        echo "GZIP'd File '$file' contains '[Wrong checksum]'"
        . $CRONDIR/easylist-cookie-mirror.sh
        # Log checksums
        cp -f easylist-cookie_ubo.txt.gz.zcat.chk $DIFFLOGS/easylist-cookie_ubo.txt.gz.zcat.$CURRENTDATE.chk
        cp -f easylist-cookie.txt.gz.zcat.chk $DIFFLOGS/easylist-cookie.txt.gz.zcat.$CURRENTDATE.chk
        cp -f fanboy-annoyance_ubo.txt.gz.zcat.chk $DIFFLOGS/fanboy-annoyance_ubo.txt.gz.zcat.$CURRENTDATE.chk
        cp -f fanboy-cookiemonster.txt.gz.zcat.chk $DIFFLOGS/fanboy-cookiemonster.txt.gz.zcat.$CURRENTDATE.chk
        cp -f easylist-cookie.txt.chk $DIFFLOGS/easylist-cookie.txt.$CURRENTDATE.chk
        cp -f easylist-cookie_ubo.txt.chk $DIFFLOGS/easylist-cookie_ubo.txt.$CURRENTDATE.chk
        cp -f fanboy-annoyance.txt.chk $DIFFLOGS/fanboy-annoyance.txt.$CURRENTDATE.chk
        # Backup the gzip files
        cp -f $MAINDIR/easylist-cookie_ubo.txt.gz $DIFFLOGS/easylist-cookie_ubo.$CURRENTDATE.txt.gz
        cp -f $MAINDIR/easylist-cookie.txt.gz $DIFFLOGS/easylist-cookie.$CURRENTDATE.txt.gz
        cp -f $MAINDIR/fanboy-annoyance_ubo.txt.gz $DIFFLOGS/fanboy-annoyance_ubo.$CURRENTDATE.txt.gz
        cp -f $MAINDIR/fanboy-cookiemonster.txt.gz $DIFFLOGS/fanboy-cookiemonster.$CURRENTDATE.txt.gz
        # Backup the plain txt files
        cp -f $MAINDIR/easylist-cookie_ubo.txt $DIFFLOGS/easylist-cookie_ubo.$CURRENTDATE.txt
        cp -f $MAINDIR/easylist-cookie.txt $DIFFLOGS/easylist-cookie.$CURRENTDATE.txt
        cp -f $MAINDIR/fanboy-annoyance_ubo.txt $DIFFLOGS/fanboy-annoyance_ubo.$CURRENTDATE.txt
        cp -f $MAINDIR/fanboy-cookiemonster.txt $DIFFLOGS/fanboy-cookiemonster.$CURRENTDATE.txt
       
    else
        # echo "GZIP'd File '$file' does not contain '[Wrong checksum]'"
        :
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
        # Log checksums
        cp -f fanboy-agegate.txt.chk $DIFFLOGS/fanboy-agegate.txt.$CURRENTDATE.chk
        # Backup bad files
        cp -f $MAINDIR/fanboy-agegate.txt.gz $MAINDIR/fanboy-agegate.$CURRENTDATE.txt.gz
        cp -f $MAINDIR/fanboy-agegate.txt $MAINDIR/fanboy-agegate.$CURRENTDATE.txt
    else
        # echo "GZIP'd File '$file' does not contain '[Wrong checksum]'"
        :
    fi
done


# Notifications List (GZIP)
files=("fanboy-mobile-notifications.txt.gz.zcat.chk" "fanboy-notifications.txt.gz.zcat.chk" "fanboy-mobile-notifications.txt.chk" "fanboy-notifications.txt.chk")

for file in "${files[@]}"; do
    if grep -q "\[Wrong checksum\]" "$file"; then
        echo "GZIP'd File '$file' contains '[Wrong checksum]'"
        . $CRONDIR/make-notifications.sh
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
    else
        # echo "GZIP'd File '$file' does not contain '[Wrong checksum]'"
        :
    fi
done


# remove old files
rm -rf $COOKDIR/*.txt.gz $COOKDIR/*.chk $COOKDIR/*.zcat
