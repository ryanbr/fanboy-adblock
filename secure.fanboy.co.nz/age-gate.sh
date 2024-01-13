#!/bin/bash
#
# Fanboy Agegat  Script
# Prerequisites: Webserver (nginx), 7zip, sha256sum, cron, wget, addChecksum.pl
#
# 0 */2 * * *  /etc/crons/agegate.sh
#
set -e

# Main WWW Site
export MAINDIR="/var/www"

# Cookie DIR
export AGEGATEDIR="/root/temp/notifi"
# Ensure Dir exists.
if [ ! -d "$AGEGATEDIR" ]; then
    mkdir -p "$AGEGATEDIR"
    echo "Folder created: $folder_path"
else
    # echo "Folder already exists: $folder_path"
    :
fi

# For file comparison
export SHA256SUM="/usr/bin/sha256sum"

# Wget string
export WGET="nice -n 19 /usr/bin/wget -w 20 --no-cache --no-cookies --tries=10 --waitretry=20 --retry-connrefused --timeout=45 --random-wait -U firefox -P $AGEGATEDIR"

export ADDCHECKSUM="nice -n 19 perl /root/fanboy-adblock/scripts/addChecksum.pl"

# export ZIP="/usr/bin/7za a -mx=9 -y -tgzip"
export ZIP="gzip -c -9"

# date
export CURRENTDATE=$(date +"%Y%m%d_%H%M%S")

# Diff logs
export DIFFLOGS="/var/www/difflogs/agegate"
# Ensure Logs exist.
if [ ! -d "$DIFFLOGS" ]; then
    mkdir -p "$DIFFLOGS"
    echo "Folder created: $folder_path"
else
    # echo "Folder already exists: $folder_path"
    :
fi


# AGEGATEDIR
rm -Rf $AGEGATEDIR
if [ $? -ne 0 ]; then
    echo "Failed to remove src. Aborting script."
    exit 1
fi

# Grab the files we need
rm -rf $AGEGATEDIR/*
mkdir /root/temp/notifi
cd $AGEGATEDIR
export AGEGATEDIR="/root/temp/notifi"

# Notifications
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_agegate_allowlist.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_agegate_general_block.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_agegate_general_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_agegate_specific_block.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_agegate_specific_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_agegate_specific_uBO.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_agegate_thirdparty.txt &> /dev/null


files_to_check=("fanboy_agegate_allowlist.txt"
                "fanboy_agegate_general_block.txt"
                "fanboy_agegate_general_hide.txt"
                "fanboy_agegate_specific_block.txt"
                "fanboy_agegate_specific_hide.txt"
                "fanboy_agegate_specific_uBO.txt"
                "fanboy_agegate_thirdparty.txt"
)


# Change to the download directory
cd "$AGEGATEDIR" || exit 1

# Loop through the specified files to check
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


########################################################################################################
########################################       CONCAT FILES       ######################################
########################################################################################################

## uBO
cat $MAINDIR/fanboy-agegate-template.txt $AGEGATEDIR/fanboy_agegate_general_block.txt $AGEGATEDIR/fanboy_agegate_specific_block.txt $AGEGATEDIR/fanboy_agegate_general_hide.txt \
    $AGEGATEDIR/fanboy_agegate_specific_hide.txt $AGEGATEDIR/fanboy_agegate_thirdparty.txt $AGEGATEDIR/fanboy_agegate_specific_uBO.txt $AGEGATEDIR/fanboy_agegate_allowlist.txt > $AGEGATEDIR/news.yxx42

## ABP
cat $MAINDIR/fanboy-agegate-template.txt $AGEGATEDIR/fanboy_agegate_general_block.txt $AGEGATEDIR/fanboy_agegate_specific_block.txt $AGEGATEDIR/fanboy_agegate_general_hide.txt \
    $AGEGATEDIR/fanboy_agegate_specific_hide.txt $AGEGATEDIR/fanboy_agegate_thirdparty.txt $AGEGATEDIR/fanboy_agegate_allowlist.txt  > $AGEGATEDIR/news.yxx43
    

# Check Combined file exists and not zero
if [ ! -e "$AGEGATEDIR/news.yxx42" ] || [ ! -s "$AGEGATEDIR/news.yxx42" ]; then
    echo "File is either empty or does not exist. Exiting..."
    exit 1
fi
# echo "File is non-empty. Continue with the rest of the script.

# LOG-1
cp -f $AGEGATEDIR/news.yxx42 $DIFFLOGS/fanboy-agegate-premod-$CURRENTDATE.txt

# Remove blank lines
sed -i '/\S/,$!d' $AGEGATEDIR/news.yxx42
sed -i '/\S/,$!d' $AGEGATEDIR/news.yxx43

# rename
cp -f $AGEGATEDIR/news.yxx43 $AGEGATEDIR/fanboy-agegate_abp.txt
cp -f $AGEGATEDIR/news.yxx42 $AGEGATEDIR/fanboy-agegate.txt

# Checksum before comparing between /var/www and agegatedir
$ADDCHECKSUM $AGEGATEDIR/fanboy-agegate_abp.txt
$ADDCHECKSUM $AGEGATEDIR/fanboy-agegate.txt

# LOG-2
cp -f $AGEGATEDIR/fanboy-agegate.txt $DIFFLOGS/fanboy-agegate-post-checksum-$CURRENTDATE.txt

########################################################################################################
########################################       PUBLISH            ######################################
########################################################################################################

if diff -q $AGEGATEDIR/fanboy-agegate.txt $MAINDIR/fanboy-agegate.txt > $DIFFLOGS/fanboy-agegate-diff-$CURRENTDATE-differences.log ; then
    echo "No need to change"
  else
     echo "Successfully created fanboy-agegate.txt"
     # Remove blank lines
     # Compare if the file has changed on secure.fanboy.co.nz before updating
     # Ensure filesize is large enough before updating (6k)
     minimumsize=6000
     actualsize=$(wc -c <"/root/temp/notifi/fanboy-agegate.txt")
     if [ $actualsize -ge $minimumsize ]; then
       # File is large enough (Over size)

       echo "File size seems correct"
       echo "fanboy-agegate.txt has been updated"
       # LOG-3
       cp -f $AGEGATEDIR/fanboy-agegate.txt $DIFFLOGS/fanboy-agegate-$CURRENTDATE.txt
             
       # Copy to server and create gzip copy
       cp -f $AGEGATEDIR/fanboy-agegate.txt $MAINDIR/fanboy-agegate.txt
       cp -f $AGEGATEDIR/fanboy-agegate_abp.txt $MAINDIR/fanboy-agegate_abp.txt
	         
       # remove old .gz
       rm -rf $MAINDIR/fanboy-agegate_abp.txt.gz $MAINDIR/fanboy-agegate.txt.gz
             
	   # Create gz
       $ZIP $MAINDIR/fanboy-agegate.txt > $MAINDIR/fanboy-agegate.txt.gz
       $ZIP $MAINDIR/fanboy-agegate_abp.txt > $MAINDIR/fanboy-agegate_abp.txt.gz
       # LOG-4
       cp -f $MAINDIR/fanboy-agegate.txt.gz $DIFFLOGS/fanboy-agegate-$CURRENTDATE.txt.gz
       
     else
        echo "File size too small, nothing updated"
     fi
        echo "File Hasnt changed (AgeGate)"
  echo "Failed in list creation (Fanboy Agegate)"
fi

