#!/bin/bash
#
# Easylist Cookie Mirroring Script
# Prerequisites: Webserver (nginx), gzip, sha256sum, cron, wget, addChecksum.pl
#
# 0 */2 * * *  /home/username/easylist-mirror.sh
#
set -e

# Main WWW Site
export MAINDIR="/var/www"

# Cookie DIR
export COOKDIR="/root/temp/cookies"
# Ensure Cookie Dir exists.
if [ ! -d "$COOKDIR" ]; then
    mkdir -p "$COOKDIR"
    echo "Folder created: $folder_path"
else
    # echo "Folder already exists: $folder_path"
    :
fi

# For file comparison
export SHA256SUM="/usr/bin/sha256sum"

# Wget string
export WGET="nice -n 19 /usr/bin/wget -w 20 --no-cache --no-cookies --tries=10 --waitretry=20 --retry-connrefused --timeout=45 --random-wait -U firefox -P $COOKDIR"

export ADDCHECKSUM="nice -n 19 perl /root/fanboy-adblock/scripts/addChecksum.pl"

# export ZIP="/usr/bin/7za a -mx=9 -y -tgzip"
export ZIP="gzip -c -9"

# date
export CURRENTDATE=$(date +"%Y%m%d_%H%M%S")

# Diff logs
export DIFFLOGS="/var/www/difflogs/easylistcookie"
# Ensure Logs exist.
if [ ! -d "$DIFFLOGS" ]; then
    mkdir -p "$DIFFLOGS"
    echo "Folder created: $folder_path"
else
    # echo "Folder already exists: $folder_path"
    :
fi


# COOKDIR
rm -Rf $COOKDIR
if [ $? -ne 0 ]; then
    echo "Failed to remove src. Aborting script."
    exit 1
fi

# Grab the files we need
rm -rf $COOKDIR/*
mkdir /root/temp/cookies
cd $COOKDIR
export COOKDIR="/root/temp/cookies"

########################################################################################################
########################################       GRAB FILES         ######################################
########################################################################################################

# Store downloaded files in $COOKDIR
$WGET https://raw.githubusercontent.com/easylist/easylist/master/easylist_cookie/easylist_cookie_general_block.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/easylist_cookie/easylist_cookie_general_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/easylist_cookie/easylist_cookie_thirdparty.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/easylist_cookie/easylist_cookie_specific_block.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/easylist_cookie/easylist_cookie_specific_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/easylist_cookie/easylist_cookie_specific_uBO.txt &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/easylist_cookie/easylist_cookie_specific_ABP.txt &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/easylist_cookie/easylist_cookie_international_specific_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/easylist_cookie/easylist_cookie_international_specific_block.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/easylist_cookie/easylist_cookie_allowlist_general_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/easylist_cookie/easylist_cookie_allowlist.txt  &> /dev/null



# List of specific file names to check (used to check if the they 0sized or if they exist)
files_to_check=("easylist_cookie_general_block.txt" "easylist_cookie_general_hide.txt" "easylist_cookie_thirdparty.txt" "easylist_cookie_specific_block.txt" "easylist_cookie_specific_hide.txt" "easylist_cookie_specific_uBO.txt" \
                "easylist_cookie_specific_ABP.txt" "easylist_cookie_international_specific_hide.txt" "easylist_cookie_international_specific_block.txt" "easylist_cookie_allowlist_general_hide.txt" "easylist_cookie_allowlist.txt")

# Change to the download directory
cd "$COOKDIR" || exit 1

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

echo "All specified files exist and have a size greater than 0 bytes."
# The files exist, so we can continue on.

########################################################################################################
########################################       CONCAT FILES       ######################################
########################################################################################################

## uBO
cat $MAINDIR/easylist-cookie-template.txt $COOKDIR/easylist_cookie_general_block.txt $COOKDIR/easylist_cookie_general_hide.txt $COOKDIR/easylist_cookie_thirdparty.txt $COOKDIR/easylist_cookie_specific_block.txt $COOKDIR/easylist_cookie_specific_hide.txt \
    $COOKDIR/easylist_cookie_international_specific_block.txt $COOKDIR/easylist_cookie_specific_uBO.txt $COOKDIR/easylist_cookie_international_specific_hide.txt \
    $COOKDIR/easylist_cookie_international_specific_block.txt $COOKDIR/easylist_cookie_allowlist_general_hide.txt $COOKDIR/easylist_cookie_allowlist.txt > $COOKDIR/easylist-cookie.txt
    
## ABP    
cat $MAINDIR/easylist-cookie-template.txt $COOKDIR/easylist_cookie_general_block.txt $COOKDIR/easylist_cookie_general_hide.txt $COOKDIR/easylist_cookie_thirdparty.txt $COOKDIR/easylist_cookie_specific_block.txt $COOKDIR/easylist_cookie_specific_hide.txt \
    $COOKDIR/easylist_cookie_specific_ABP.txt $COOKDIR/easylist_cookie_international_specific_hide.txt $COOKDIR/easylist_cookie_international_specific_block.txt \
    $COOKDIR/easylist_cookie_international_specific_block.txt $COOKDIR/easylist_cookie_allowlist_general_hide.txt $COOKDIR/easylist_cookie_allowlist.txt > $COOKDIR/easylist-cookie-abp.txt

# Check $COOKDIR/easylist-cookie.txt exists and not zero
if [ ! -e "$COOKDIR/easylist-cookie.txt" ] || [ ! -s "$COOKDIR/easylist-cookie.txt" ]; then
    echo "File is either empty or does not exist. Exiting..."
    exit 1
fi
# echo "File is non-empty. Continue with the rest of the script.

# BACKUP LOGS (easylist-cookie-premod-1-)
cp -f $COOKDIR/easylist-cookie.txt $DIFFLOGS/easylist-cookie-premod-1-$CURRENTDATE.txt

# Remove blank lines
sed -i '/\S/,$!d' $COOKDIR/easylist-cookie.txt
sed -i '/\S/,$!d' $COOKDIR/easylist-cookie-abp.txt

# Checksum
$ADDCHECKSUM $COOKDIR/easylist-cookie.txt
$ADDCHECKSUM $COOKDIR/easylist-cookie-abp.txt

# BACKUP LOGS (easylist-cookie-premod-2-)
cp -f $COOKDIR/easylist-cookie.txt $DIFFLOGS/easylist-cookie-premod-2-$CURRENTDATE.txt

########################################################################################################
########################################       PUBLISH            ######################################
########################################################################################################

if diff $COOKDIR/easylist-cookie.txt $MAINDIR/easylist-cookie_ubo.txt > $DIFFLOGS/easylist-cookie-$CURRENTDATE-differences.log ; then
    echo "No need to change"
  else
     echo "Successfully created easylist-cookie.txt"
     # Remove blank lines
     # Compare if the file has changed on secure.fanboy.co.nz before updating
     # Ensure filesize is large enough before updating (60k)
     minimumsize=60000
     actualsize=$(wc -c <"/root/temp/cookies/easylist-cookie.txt")
     if [ $actualsize -ge $minimumsize ]; then
       # File is large enough (Over size)
       #
       echo "File size seems correct"
       echo "easylist-cookie.txt has been updated"
       # BACKUP LOGS (easylist-cookie-init-loop-2-)
       cp -f $COOKDIR/easylist-cookie.txt $DIFFLOGS/easylist-cookie-init-loop-2-$CURRENTDATE.txt
       
       # Copy to server and create gzip copy
       cp -f $COOKDIR/easylist-cookie.txt $MAINDIR/fanboy-cookie.txt
       cp -f $COOKDIR/easylist-cookie.txt $MAINDIR/fanboy-cookie_ubo.txt
                
       # copy to /var/www
       cp -f $COOKDIR/easylist-cookie.txt $MAINDIR/easylist-cookie.txt
       cp -f $COOKDIR/easylist-cookie.txt $MAINDIR/easylist-cookie_ubo.txt
       # ABP relaed
       cp -f $COOKDIR/easylist-cookie-abp.txt $MAINDIR/easylist-cookie_abp.txt
       cp -f $COOKDIR/easylist-cookie-abp.txt $MAINDIR/fanboy-cookie_abp.txt
       cp -f $COOKDIR/easylist-cookie-abp.txt $MAINDIR/adblock/fanboy-cookie.txt

       # remove old .gz
       rm -rf $MAINDIR/fanboy-cookie.txt.gz $MAINDIR/fanboy-cookie.txt.gz $MAINDIR/fanboy-cookie.txt.gz $MAINDIR/adblock/fanboy-cookie.txt.gz
       # Create gzip'd
       $ZIP $COOKDIR/easylist-cookie.txt >  $MAINDIR/fanboy-cookie.txt.gz
       cp -f $MAINDIR/fanboy-cookie.txt.gz  $MAINDIR/fanboy-cookie_ubo.txt.gz
       cp -f $MAINDIR/fanboy-cookie.txt.gz  $MAINDIR/easylist-cookie_ubo.txt.gz
       # ABP
       $ZIP $COOKDIR/easylist-cookie-abp.txt > $MAINDIR/easylist-cookie_abp.txt.gz
       cp -f $MAINDIR/easylist-cookie_abp.txt.gz $MAINDIR/fanboy-cookie_abp.txt.gz
       cp -f $MAINDIR/easylist-cookie_abp.txt.gz $MAINDIR/adblock/fanboy-cookie.txt.gz       

       ### BACKUP LOGS (easylist-cookie-gzipd-3-)
       cp -f $MAINDIR/fanboy-cookie.txt.gz $DIFFLOGS/easylist-cookie-gzipd-3-$CURRENTDATE.txt.gz
       
       # Copy to /var/www
       cp -f $COOKDIR/easylist_cookie_specific_uBO.txt $MAINDIR/easylist_cookie/easylist_cookie_specific_uBO.txt

       # ultimate list combo
       cp -f $COOKDIR/easylist_cookie_specific_uBO.txt $MAINDIR/r/easylist_cookie/easylist_cookie_specific_uBO.txt
       cp -f $COOKDIR/easylist_cookie_specific_uBO.txt $MAINDIR/r/easylist_cookie_specific_uBO.txt

       $ZIP $COOKDIR/easylist_cookie_specific_uBO.txt > $COOKDIR/easylist_cookie_specific_uBO.txt.gz
                  
       # Copy to /var/www
       mv -f $COOKDIR/easylist_cookie_specific_uBO.txt.gz $MAINDIR/easylist_cookie/easylist_cookie_specific_uBO.txt.gz
       
     else
        echo "File size too small, nothing updated"
     fi
        echo "File Hasnt changed (Easylist Cookie)"
  echo "Failed in list creation (Easylist Cookie)"
fi


 
