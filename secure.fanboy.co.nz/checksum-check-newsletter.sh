#!/bin/bash
#
# Checksum Newsletter List checker
# Prerequisites: Webserver (nginx)
#


# Main WWW Site
export MAINDIR="/var/www"

# Cron job
export CRONDIR="/etc/crons/secure.fanboy.co.nz/"

# Cookie DIR
export COOKDIR="/root/temp/cookies-checksum-news"

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

# fanboy-newsletter.txt.gz
zcat $MAINDIR/fanboy-newsletter.txt.gz > $COOKDIR/fanboy-newsletter.txt.zcat
$VALIDCHECKSUM $COOKDIR/fanboy-newsletter.txt.zcat > $COOKDIR/fanboy-newsletter.txt.gz.zcat.chk

#### Non gzip'd (AGE GATE List)
$VALIDCHECKSUM $MAINDIR/fanboy-newsletter.txt > $COOKDIR/fanboy-newsletter.txt.chk

## Combine together, so we aren't creating too many loops below
cat $COOKDIR/fanboy-newsletter.txt.chk $COOKDIR/fanboy-newsletter.txt.gz.zcat.chk > $COOKDIR/fanboy-news-checksum.txt

# AGE GATE List (GZIP)
files=("fanboy-news-checksum.txt")

for file in "${files[@]}"; do
    if grep -q "\[Wrong checksum\]" "$file"; then
        echo "GZIP'd File '$file' contains '[Wrong checksum]'"
        # Log checksums
        cp -f fanboy-newsletter.txt.chk $DIFFLOGS/fanboy-newsletter.txt.$CURRENTDATE.chk
        # Backup bad files
        cp -f $MAINDIR/fanboy-newsletter.txt.gz $MAINDIR/fanboy-newsletter.$CURRENTDATE.txt.gz
        cp -f $MAINDIR/fanboy-newsletter.txt $MAINDIR/fanboy-newsletter.$CURRENTDATE.txt
        # re-run age-gate script
        . $CRONDIR/annoyances-mirror-3.sh
        echo "Updated newsletter, Bad checksum was detected."
    else
        # echo "GZIP'd File '$file' does not contain '[Wrong checksum]'"
        echo "Fanboy Newsletter list has a valid checksum, no updates needed"
    fi
done

# remove old files
rm -rf $COOKDIR/*.txt.gz $COOKDIR/*.chk $COOKDIR/*.zcat $COOKDIR/*.txt
