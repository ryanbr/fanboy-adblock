#!/bin/bash
#
# Checksum Agegate List checker
# Prerequisites: Webserver (nginx)
#


# Main WWW Site
export MAINDIR="/var/www"

# Cron job
export CRONDIR="/etc/crons/secure.fanboy.co.nz/"

# Cookie DIR
export COOKDIR="/root/temp/cookies-checksum-agegate"

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

# fanboy-agegate.txt.gz
zcat $MAINDIR/fanboy-agegate.txt.gz > $COOKDIR/fanboy-agegate.txt.gz.zcat
$VALIDCHECKSUM $COOKDIR/fanboy-agegate.txt.gz.zcat > $COOKDIR/fanboy-agegate.txt.gz.zcat.chk

#### Non gzip'd (AGE GATE List)
$VALIDCHECKSUM $MAINDIR/fanboy-agegate.txt > $COOKDIR/fanboy-agegate.txt.chk

## Combine together, so we aren't creating too many loops below
cat $COOKDIR/fanboy-agegate.txt.chk $COOKDIR/fanboy-agegate.txt.gz.zcat.chk > $COOKDIR/fanboy-ageage-checksum.txt

# AGE GATE List (GZIP)
files=("fanboy-ageage-checksum.txt")

for file in "${files[@]}"; do
    if grep -q "\[Wrong checksum\]" "$file"; then
        echo "GZIP'd File '$file' contains '[Wrong checksum]'"
        # Log checksums
        cp -f fanboy-agegate.txt.chk $DIFFLOGS/fanboy-agegate.txt.$CURRENTDATE.chk
        # Backup bad files
        cp -f $MAINDIR/fanboy-agegate.txt.gz $MAINDIR/fanboy-agegate.$CURRENTDATE.txt.gz
        cp -f $MAINDIR/fanboy-agegate.txt $MAINDIR/fanboy-agegate.$CURRENTDATE.txt
        # re-run age-gate script
        . $CRONDIR/age-gate.sh
        echo "Updated Agegate, Bad checksum was detected."
    else
        # echo "GZIP'd File '$file' does not contain '[Wrong checksum]'"
        echo "Fanboy Agegate list has a valid checksum, no updates needed"
    fi
done

# remove old files
rm -rf $COOKDIR/*.txt.gz $COOKDIR/*.chk $COOKDIR/*.zcat $COOKDIR/*.txt

