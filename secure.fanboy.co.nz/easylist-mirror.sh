#!/bin/bash
#
# Easylist/Easyprivacy Mirroring Script
# Prerequisites: Webserver (nginx), 7zip, sha256sum, cron, wget
#
# Note, Please respect adblockplus.org and don't run script often to avoid 
# escessive server load for easylist-downloads.adblockplus.org. 
# (Once every 2hrs should be enough)
#
# 0 */2 * * *  /home/username/easylist-mirror.sh 
#
set -e

# Where its downloaded first.
export TEMPDIR="/root/temp"
# Ensure Cookie Dir exists.
if [ ! -d "$TEMPDIR" ]; then
    mkdir -p "$TEMPDIR"
    echo "Folder created: $folder_path"
else
    # echo "Folder already exists: $folder_path"
    :
fi

# Diff logs
export DIFFLOGS="/var/www/difflogs/easylist"
# Ensure Logs exist.
if [ ! -d "$DIFFLOGS" ]; then
    mkdir -p "$DIFFLOGS"
    echo "Folder created: $folder_path"
else
    # echo "Folder already exists: $folder_path"
    :
fi

# Cron job (where script is stored)
export CRONDIR="/etc/crons/secure.fanboy.co.nz/"

# Wget string
export WGET="nice -n 19 /usr/bin/wget -w 20 --no-check-certificate --tries=10 --waitretry=20 --retry-connrefused --timeout=45 --random-wait -U firefox -P $TEMPDIR"

export ADDCHECKSUM="nice -n 19 perl /root/fanboy-adblock/scripts/addChecksum.pl"
# export ZIP="/usr/bin/7za a -mx=9 -y -tgzip"
export ZIP="gzip -c -9"

#
# Main WWW Site
export MAINDIR="/var/www"
#

# Change to the download directory
cd "$TEMPDIR" || exit 1

# clear folder
rm -rf $TEMPDIR/*

# Store downloaded files in $TEMPDIR
$WGET https://easylist.to/easylist/easylist.txt  &> /dev/null
$WGET https://easylist.to/easylist/easyprivacy.txt  &> /dev/null


# List of specific file names to check (used to check if the they 0sized or if they exist)
files_to_check=("easylist.txt" "easyprivacy.txt")

# Check through each file, to ensure they exist and not empty
#
for file in "${files_to_check[@]}"; do
    # Check if the file exists and has a size greater than 0 bytes
    if [ -s "$file" ] && [ -e "$file" ]; then
       # echo "File '$file' exists and is not 0 bytes."
       # placeholder
       :
    else
        echo "Error: File '$file' either does not exist or is 0 bytes. Exiting script."
        exit 1
    fi
done


# Compare /var/www with the downloaded Easylist
if diff $MAINDIR/easylist.txt $TEMPDIR/easylist.txt &> /dev/null; then
    # Easylist hasn't changed
    echo "Files are identical. No update needed"
else
    # re-zip Easylist
    echo "Syncing Easylist / Easylist+Easyprivacy"
    $ZIP $TEMPDIR/easylist.txt > $TEMPDIR/easylist.txt.gz
    # copy txt and txt.gz to /var/www
    cp -f $TEMPDIR/easylist.txt $MAINDIR/easylist.txt
    cp -f $TEMPDIR/easylist.txt.gz $MAINDIR/easylist.txt.gz
    # combo
    # remove top 18 lines
    sed '1,18d' $TEMPDIR/easyprivacy.txt > $TEMPDIR/easyprivacy-min.txt
    cat $MAINDIR/easylist.txt $TEMPDIR/easyprivacy-min.txt > $TEMPDIR/easylist-combined.txt
    # Remove blank lines
    sed -i '/\S/,$!d' $TEMPDIR/easylist-combined.txt
    # Addchecksum
    $ADDCHECKSUM $TEMPDIR/easylist-combined.txt
    # GZIP
    $ZIP $TEMPDIR/easylist-combined.txt > $TEMPDIR/easyprivacy+easylist.txt.gz
    # copy combom txt and txt.gz to /var/www
    cp -f $TEMPDIR/easylist-combined.txt $MAINDIR/easyprivacy+easylist.txt
    cp -f $TEMPDIR/easyprivacy+easylist.txt.gz $MAINDIR/easyprivacy+easylist.txt.gz
    
fi

#
# Compare /var/www with the downloaded Easyprivacy
if diff $MAINDIR/easyprivacy.txt $TEMPDIR/easyprivacy.txt &> /dev/null; then
    # Easylist hasn't changed
    echo "Files are identical. No update needed"
else
    # re-zip Easylist
    echo "Syncing Easyprivacy / Easylist+Easyprivacy"
    $ZIP $TEMPDIR/easyprivacy.txt >  $TEMPDIR/easyprivacy.txt.gz
    # copy txt and txt.gz to /var/www
    cp -f $TEMPDIR/easyprivacy.txt $MAINDIR/easyprivacy.txt
    cp -f $TEMPDIR/easyprivacy.txt.gz $MAINDIR/easyprivacy.txt.gz
    # combo
    # remove top 18 lines
    sed '1,18d' $TEMPDIR/easyprivacy.txt > $TEMPDIR/easyprivacy-min.txt
    cat $MAINDIR/easylist.txt $TEMPDIR/easyprivacy-min.txt > $TEMPDIR/easylist-combined.txt
    # Remove blank lines
    sed -i '/\S/,$!d' $TEMPDIR/easylist-combined.txt
    # Addchecksum
    $ADDCHECKSUM $TEMPDIR/easylist-combined.txt
    # GZIP
    $ZIP $TEMPDIR/easylist-combined.txt > $TEMPDIR/easyprivacy+easylist.txt.gz
    # copy combom txt and txt.gz to /var/www
    cp -f $TEMPDIR/easylist-combined.txt $MAINDIR/easyprivacy+easylist.txt
    cp -f $TEMPDIR/easyprivacy+easylist.txt.gz $MAINDIR/easyprivacy+easylist.txt.gz
    
fi


