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
# Others to mirror:
$WGET https://raw.githubusercontent.com/ryanbr/fanboy-adblock/master/fanboy-antifacebook.txt &> /dev/null
$WGET https://raw.githubusercontent.com/ryanbr/fanboy-adblock/master/fanboy-antifonts.txt &> /dev/null

# List of specific file names to check (used to check if the they 0sized or if they exist)
files_to_check=("easylist.txt" "easyprivacy.txt" "fanboy-antifacebook.txt" "fanboy-antifonts.txt")

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


########################################################################################################
########################################       Easylist   ##############################################
########################################################################################################


# Compare /var/www with the downloaded Easylist
if diff $MAINDIR/easylist.txt $TEMPDIR/easylist.txt &> /dev/null; then
    # Easylist hasn't changed
    echo "Files are identical. No update needed"
else
    # re-zip Easylist
    echo "Generate Easylist List"
    $ZIP $TEMPDIR/easylist.txt > $TEMPDIR/easylist.txt.gz
    # rm old copies
    rm -rf $MAINDIR/easylist.txt $MAINDIR/easylist.txt.gz
    # copy txt and txt.gz to /var/www
    cp -f $TEMPDIR/easylist.txt $MAINDIR/easylist.txt
    cp -f $TEMPDIR/easylist.txt.gz $MAINDIR/easylist.txt.gz
    #
    # combo list easyprivacy+easylist.txt
    # remove top 18 lines
    echo "Generate Easylist+Easyprivacy List"
    sed '1,18d' $TEMPDIR/easyprivacy.txt > $TEMPDIR/easyprivacy-min.txt
    cat $MAINDIR/easylist.txt $TEMPDIR/easyprivacy-min.txt > $TEMPDIR/easylist-combined.txt
    # Remove blank lines
    sed -i '/\S/,$!d' $TEMPDIR/easylist-combined.txt
    # Addchecksum
    $ADDCHECKSUM $TEMPDIR/easylist-combined.txt
    # GZIP
    $ZIP $TEMPDIR/easylist-combined.txt > $TEMPDIR/easyprivacy+easylist.txt.gz
    
    # rm old copies
    rm -rf $MAINDIR/easyprivacy+easylist.txt $MAINDIR/easyprivacy+easylist.txt.gz
    
    # copy combom txt and txt.gz to /var/www
    cp -f $TEMPDIR/easylist-combined.txt $MAINDIR/easyprivacy+easylist.txt
    cp -f $TEMPDIR/easyprivacy+easylist.txt.gz $MAINDIR/easyprivacy+easylist.txt.gz
    
fi

########################################################################################################
#####################################       Easyprivacy   ##############################################
########################################################################################################


#
# Compare /var/www with the downloaded Easyprivacy
if diff $MAINDIR/easyprivacy.txt $TEMPDIR/easyprivacy.txt &> /dev/null; then
    # Easylist hasn't changed
    echo "Files are identical. No update needed"
else
    # re-zip Easylist
    echo "Generate Easyprivacy List"
    $ZIP $TEMPDIR/easyprivacy.txt >  $TEMPDIR/easyprivacy.txt.gz
    # rm old copies
    rm -rf $MAINDIR/easyprivacy.txt $MAINDIR/easyprivacy.txt.gz
    # copy txt and txt.gz to /var/www
    cp -f $TEMPDIR/easyprivacy.txt $MAINDIR/easyprivacy.txt
    cp -f $TEMPDIR/easyprivacy.txt.gz $MAINDIR/easyprivacy.txt.gz
    #
    # combo list easyprivacy+easylist.txt
    # remove top 18 lines
    echo "Generate Easylist+Easyprivacy List"
    sed '1,18d' $TEMPDIR/easyprivacy.txt > $TEMPDIR/easyprivacy-min.txt
    cat $MAINDIR/easylist.txt $TEMPDIR/easyprivacy-min.txt > $TEMPDIR/easylist-combined.txt
    # Remove blank lines
    sed -i '/\S/,$!d' $TEMPDIR/easylist-combined.txt
    # Addchecksum
    $ADDCHECKSUM $TEMPDIR/easylist-combined.txt
    # GZIP
    $ZIP $TEMPDIR/easylist-combined.txt > $TEMPDIR/easyprivacy+easylist.txt.gz
    
    # rm old copies
    rm -rf $MAINDIR/easyprivacy+easylist.txt $MAINDIR/easyprivacy+easylist.txt.gz
    
    # copy combom txt and txt.gz to /var/www
    cp -f $TEMPDIR/easylist-combined.txt $MAINDIR/easyprivacy+easylist.txt
    cp -f $TEMPDIR/easyprivacy+easylist.txt.gz $MAINDIR/easyprivacy+easylist.txt.gz
    
fi

########################################################################################################
################################       fanboy-antifacebook.txt    ######################################
########################################################################################################

# CHECKSUM before comparing
$ADDCHECKSUM $TEMPDIR/fanboy-antifacebook.txt


# Compare /var/www with the downloaded Easyprivacy
if diff $MAINDIR/fanboy-antifacebook.txt $TEMPDIR/fanboy-antifacebook.txt &> /dev/null; then
    # Easylist hasn't changed
    echo "Files are identical. No update needed"
else
    # re-zip Easylist
    echo "Generate fanboy Antifacebook List"
    # another checksum
    $ADDCHECKSUM $TEMPDIR/fanboy-antifacebook.txt
    
    # ZIP and store in TEMPDIR
    $ZIP $TEMPDIR/fanboy-antifacebook.txt >  $TEMPDIR/fanboy-antifacebook.txt.gz\
    
    # rm old copies
    rm -rf $MAINDIR/fanboy-antifacebook.txt $MAINDIR/fanboy-antifacebook.txt.gz
    
    # copy txt and txt.gz to /var/www
    cp -f $TEMPDIR/fanboy-antifacebook.txt $MAINDIR/fanboy-antifacebook.txt
    cp -f $TEMPDIR/fanboy-antifacebook.txt.gz $MAINDIR/fanboy-antifacebook.txt.gz
fi


########################################################################################################
###################################       fanboy-antifonts.txt    ######################################
########################################################################################################

# CHECKSUM before comparing
$ADDCHECKSUM $TEMPDIR/fanboy-antifonts.txt


# Compare /var/www with the downloaded Easyprivacy
if diff $MAINDIR/fanboy-antifonts.txt $TEMPDIR/fanboy-antifonts.txt &> /dev/null; then
    # Easylist hasn't changed
    echo "Files are identical. No update needed"
else
    # re-zip Easylist
    echo "Generate fanboy Antifonts List"
    # another checksum
    $ADDCHECKSUM $TEMPDIR/fanboy-antifonts.txt
    
    # ZIP and store in TEMPDIR
    $ZIP $TEMPDIR/fanboy-antifonts.txt >  $TEMPDIR/fanboy-antifonts.txt.gz
    
    # rm old copies 
    rm -rf $MAINDIR/fanboy-antifonts.txt $MAINDIR/fanboy-antifonts.txt.gz
    
    # copy txt and txt.gz to /var/www
    cp -f $TEMPDIR/fanboy-antifonts.txt $MAINDIR/fanboy-antifonts.txt
    cp -f $TEMPDIR/fanboy-antifonts.txt.gz $MAINDIR/fanboy-antifonts.txt.gz
fi


########################################################################################################
###################################       fanboy-ultimate.txt    #######################################
########################################################################################################


if [ -s "$MAINDIR/r/fanboy-ultimate.txt" ] && [ -s "$MAINDIR/r/fanboy-ultimate.txt" ]; then
    # Remove the template file, top 13 lines.
    echo "Generate fanboy Ultimate List"
    # trim EP
    sed '1,18d' $MAINDIR/easyprivacy.txt > $TEMPDIR/easyprivacy-min.txt
    # trim FB Annoyances
    sed '1,12d' $MAINDIR/fanboy-annoyance_ubo.txt > $TEMPDIR/fanboy-annoyances-min.txt
    # trim FB Agegate
    sed '1,12d' $MAINDIR/fanboy-agegate.txt > $TEMPDIR/fanboy-agegate-min.txt
    # Combine
    cat $MAINDIR/easylist.txt $TEMPDIR/easyprivacy-min.txt $TEMPDIR/fanboy-annoyances-min.txt $TEMPDIR/fanboy-agegate-min.txt >  $TEMPDIR/fanboy-ult.txt
    # Remove blank lines
    sed -i '/\S/,$!d' $TEMPDIR/fanboy-ult.txt
    # Addchecksum
    $ADDCHECKSUM $TEMPDIR/fanboy-ult.txt

    # ZIP and store in TEMPDIR
    $ZIP $TEMPDIR/fanboy-ult.txt > $TEMPDIR/fanboy-ultimate.txt.gz
    
    # rm old copies
    rm -rf $MAINDIR/r/fanboy-ultimate.txt $MAINDIR/r/fanboy-ultimate.txt.gz
    
    # copy txt and txt.gz to /var/www/r
    cp -f $TEMPDIR/fanboy-ult.txt $MAINDIR/r/fanboy-ultimate.txt
    cp -f $TEMPDIR/fanboy-ultimate.txt.gz $MAINDIR/r/fanboy-ultimate.txt.gz

else
    echo "Either one or both files do not exist or are empty."
fi

########################################################################################################
###################################       fanboy-complete.txt    #######################################
########################################################################################################


if [ -s "$MAINDIR/r/fanboy-complete.txt" ] && [ -s "$MAINDIR/r/fanboy-complete.txt" ]; then
    # Remove the template file, top 13 lines.
    echo "Generate fanboy Complete List"
    # trim FB Social
    sed '1,12d' $MAINDIR/fanboy-social.txt > $TEMPDIR/fanboy-social-min.txt
    # Combine
    cat $MAINDIR/easylist.txt $TEMPDIR/easyprivacy-min.txt $TEMPDIR/fanboy-social-min.txt $TEMPDIR/fanboy-agegate-min.txt >  $TEMPDIR/fanboy-comp.txt
    # Remove blank lines
    sed -i '/\S/,$!d' $TEMPDIR/fanboy-comp.txt
    # Addchecksum
    $ADDCHECKSUM $TEMPDIR/fanboy-comp.txt

    # ZIP and store in TEMPDIR  
    $ZIP $TEMPDIR/fanboy-comp.txt > $TEMPDIR/fanboy-complete.txt.gz
    
    # rm old copies
    rm -rf $MAINDIR/r/fanboy-complete.txt $MAINDIR/r/fanboy-complete.txt.gz
    
    # copy txt and txt.gz to /var/www/r 
    cp -f $TEMPDIR/fanboy-comp.txt $MAINDIR/r/fanboy-complete.txt
    cp -f $TEMPDIR/fanboy-complete.txt.gz $MAINDIR/r/fanboy-complete.txt.gz

else
    echo "Either one or both files do not exist or are empty."
fi



