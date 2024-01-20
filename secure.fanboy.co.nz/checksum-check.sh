#!/bin/bash
#
# Checksum Cookie List checker
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
export VALIDCHECKSUM="nice -n 19 perl /root/fanboy-adblock/scripts/validateChecksum.pl"

cd $COOKDIR

# fanboy-annoyance_ubo.txt.gz
zcat $MAINDIR/fanboy-annoyance_ubo.txt.gz > $COOKDIR/fanboy-annoyance_ubo.txt.gz.zcat
$VALIDCHECKSUM $COOKDIR/fanboy-annoyance_ubo.txt.gz.zcat > $COOKDIR/fanboy-annoyance_ubo.txt.gz.zcat.chk

# fanboy-cookiemonster.txt.gz
zcat $MAINDIR/fanboy-cookiemonster.txt.gz > $COOKDIR/fanboy-cookiemonster.txt.gz.zcat
$VALIDCHECKSUM $COOKDIR/fanboy-cookiemonster.txt.gz.zcat > $COOKDIR/fanboy-cookiemonster.txt.gz.zcat.chk

# fanboy-cookiemonster_ubo.txt.gz
zcat $MAINDIR/fanboy-cookiemonster_ubo.txt.gz > $COOKDIR/fanboy-cookiemonster_ubo.txt.gz.zcat
$VALIDCHECKSUM $COOKDIR/fanboy-cookiemonster_ubo.txt.gz.zcat > $COOKDIR/fanboy-cookiemonster_ubo.txt.gz.zcat.chk


#### Non gzip'd (Easylist Cookie)

# $VALIDCHECKSUM $MAINDIR/easylist-cookie.txt > $COOKDIR/easylist-cookie.txt.chk
# $VALIDCHECKSUM $MAINDIR/easylist-cookie_ubo.txt > $COOKDIR/easylist-cookie_ubo.txt.chk

$VALIDCHECKSUM $MAINDIR/fanboy-cookiemonster.txt > $COOKDIR/fanboy-cookiemonster.txt.chk
$VALIDCHECKSUM $MAINDIR/fanboy-cookiemonster_ubo.txt > $COOKDIR/fanboy-cookiemonster_ubo.txt.chk
$VALIDCHECKSUM $MAINDIR/fanboy-annoyance.txt > $COOKDIR/fanboy-annoyance.txt.chk

## Combine together, so we aren't creating too many loops below
cat $COOKDIR/fanboy-annoyance.txt.chk $COOKDIR/fanboy-cookiemonster_ubo.txt.chk $COOKDIR/fanboy-cookiemonster.txt.chk \
    $COOKDIR/fanboy-annoyance_ubo.txt.gz.zcat.chk $COOKDIR/fanboy-cookiemonster.txt.gz.zcat.chk $COOKDIR/fanboy-cookiemonster_ubo.txt.gz.zcat.chk > $COOKDIR/fanboy-cookie-checksum.txt


# Easylist Cookie + Fanboy Annoyances (GZIP)
files=("fanboy-cookie-checksum.txt")

for file in "${files[@]}"; do
    if grep -q "\[Wrong checksum\]" "$file"; then
        echo "GZIP'd File '$file' contains '[Wrong checksum]'"
        echo "Logging Easylist Cookie changes"
        # Log checksums
        cp -f fanboy-annoyance_ubo.txt.gz.zcat.chk $DIFFLOGS/fanboy-annoyance_ubo.txt.gz.zcat.$CURRENTDATE.chk
        cp -f fanboy-cookiemonster.txt.gz.zcat.chk $DIFFLOGS/fanboy-cookiemonster.txt.gz.zcat.$CURRENTDATE.chk
        cp -f fanboy-annoyance.txt.chk $DIFFLOGS/fanboy-annoyance.txt.$CURRENTDATE.chk
        # Backup the gzip files
        cp -f $MAINDIR/fanboy-annoyance_ubo.txt.gz $DIFFLOGS/fanboy-annoyance_ubo.$CURRENTDATE.txt.gz
        cp -f $MAINDIR/fanboy-cookiemonster.txt.gz $DIFFLOGS/fanboy-cookiemonster.$CURRENTDATE.txt.gz
        # Backup the plain txt files
        cp -f $MAINDIR/fanboy-annoyance_ubo.txt $DIFFLOGS/fanboy-annoyance_ubo.$CURRENTDATE.txt
        cp -f $MAINDIR/fanboy-cookiemonster.txt $DIFFLOGS/fanboy-cookiemonster.$CURRENTDATE.txt
        . $CRONDIR/easylist-cookie-mirror-3.sh
        echo "Updated Easylist Cookie, Bad checksum was detected."
    else
        # echo "GZIP'd File '$file' does not contain '[Wrong checksum]'"
        echo "Easylist Cookie has a valid checksum, no updates needed"
    fi
done

# remove old files
rm -rf $COOKDIR/*.txt.gz $COOKDIR/*.chk $COOKDIR/*.zcat $COOKDIR/*.txt
