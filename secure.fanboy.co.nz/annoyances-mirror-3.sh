#!/bin/bash
#
# Easylist Cookie Mirroring Script
# Prerequisites: Webserver (nginx), 7zip, sha256sum, cron, wget, addChecksum.pl
#
# 0 */2 * * *  /home/username/easylist-mirror.sh
#
set -e

# Main WWW Site
export MAINDIR="/var/www"

# Cookie DIR
export ANNOYDIR="/root/temp/annoyances"

# For file comparison
export SHA256SUM="/usr/bin/sha256sum"

# Wget string
export WGET="nice -n 19 /usr/bin/wget -w 20 --no-cache --no-cookies --tries=10 --waitretry=20 --retry-connrefused --timeout=45 --random-wait -U firefox -P $ANNOYDIR"

export ADDCHECKSUM="nice -n 19 perl /root/fanboy-adblock/scripts/addChecksum.pl"
# export ZIP="/usr/bin/7za a -mx=9 -y -tgzip"
# gzip -c -9 file.txt > file.txt.gz
export ZIP="gzip -c -9"

# date
export CURRENTDATE=$(date +"%Y%m%d_%H%M%S")

# Diff logs
export DIFFLOGS="/var/www/difflogs/annoyances"

# ANNOYDIR
rm -Rf $ANNOYDIR
if [ $? -ne 0 ]; then
    echo "Failed to remove src. Aborting script."
    exit 1
fi

# Grab the files we need
rm -rf $ANNOYDIR/*
mkdir /root/temp/annoyances
cd $ANNOYDIR
export ANNOYDIR="/root/temp/annoyances"

# Store downloaded files in $ANNOYDIR
# Annoyances, Notifications/ Social
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_annoyance_general_block.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_annoyance_general_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_annoyance_specific_block.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_annoyance_thirdparty.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_annoyance_allowlist_general_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_annoyance_specific_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_annoyance_specific_ABP.txt &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_annoyance_specific_uBO.txt &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_annoyance_allowlist.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_annoyance_international.txt  &> /dev/null
# social
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_social_general_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_social_general_block.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_social_thirdparty.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_social_specific_ABP.txt &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_social_specific_uBO.txt &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_social_specific_block.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_social_specific_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_social_international.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_social_allowlist_general_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_social_allowlist.txt  &> /dev/null
# Newsletter
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_specific_block.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_specific_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_specific_uBO.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_specific_ABP.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_general_block.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_general_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_allowlist.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_allowlist_general_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_international_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_international_block.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_thirdparty.txt  &> /dev/null
# Newsletter shopping
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_shopping_allowlist_general_hide.txt &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_shopping_specific_block.txt &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_shopping_specific_hide.txt &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_shopping_specific_uBO.txt &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_shopping_allowlist.txt &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_newsletter_shopping_specific_ABP.txt &> /dev/null

# List of specific file names to check (used to check if the they 0sized or if they exist)
# Easylist Cookie, Notifications are grabbed in seperate script.

files_to_check=("fanboy_annoyance_general_block.txt"
                "fanboy_annoyance_general_hide.txt"
                "fanboy_annoyance_specific_block.txt"
                "fanboy_annoyance_thirdparty.txt"
                "fanboy_annoyance_allowlist_general_hide.txt"
                "fanboy_annoyance_specific_hide.txt"
                "fanboy_annoyance_specific_ABP.txt"
                "fanboy_annoyance_specific_uBO.txt"
                "fanboy_annoyance_allowlist.txt"
                "fanboy_annoyance_international.txt"
                "fanboy_social_general_hide.txt"
                "fanboy_social_general_block.txt"
                "fanboy_social_thirdparty.txt"
                "fanboy_social_specific_ABP.txt"
                "fanboy_social_specific_uBO.txt"
                "fanboy_social_specific_block.txt"
                "fanboy_social_specific_hide.txt"
                "fanboy_social_international.txt"
                "fanboy_social_allowlist_general_hide.txt"
                "fanboy_social_allowlist.txt"
                "fanboy_newsletter_specific_block.txt"
                "fanboy_newsletter_specific_hide.txt"
                "fanboy_newsletter_specific_uBO.txt"
                "fanboy_newsletter_specific_ABP.txt"
                "fanboy_newsletter_general_block.txt"
                "fanboy_newsletter_general_hide.txt"
                "fanboy_newsletter_allowlist.txt"
                "fanboy_newsletter_allowlist_general_hide.txt"
                "fanboy_newsletter_international_hide.txt"
                "fanboy_newsletter_international_block.txt"
                "fanboy_newsletter_thirdparty.txt"
                "fanboy_newsletter_shopping_allowlist_general_hide.txt"
                "fanboy_newsletter_shopping_specific_block.txt"
                "fanboy_newsletter_shopping_specific_hide.txt"
                "fanboy_newsletter_shopping_specific_ABP.txt"
                "fanboy_newsletter_shopping_specific_uBO.txt"
)

# Change to the download directory
cd "$ANNOYDIR" || exit 1

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

echo "All specified files exist and have a size greater than 0 bytes."

####################  NEWSLETTER

### uBO Newsletter combine
cat $MAINDIR/fanboy-newsletter-template.txt $ANNOYDIR/fanboy_newsletter_general_block.txt $ANNOYDIR/fanboy_newsletter_international_block.txt $ANNOYDIR/fanboy_newsletter_specific_block.txt $ANNOYDIR/fanboy_newsletter_general_hide.txt \
    $ANNOYDIR/fanboy_newsletter_specific_hide.txt $ANNOYDIR/fanboy_newsletter_international_hide.txt $ANNOYDIR/fanboy_newsletter_thirdparty.txt $ANNOYDIR/fanboy_newsletter_specific_uBO.txt $ANNOYDIR/fanboy_newsletter_shopping_specific_block.txt \
    $ANNOYDIR/fanboy_newsletter_shopping_specific_hide.txt $ANNOYDIR/fanboy_newsletter_shopping_allowlist_general_hide.txt $ANNOYDIR/fanboy_newsletter_shopping_specific_uBO.txt $ANNOYDIR/fanboy_newsletter_allowlist.txt $ANNOYDIR/fanboy_newsletter_shopping_allowlist.txt \
    $ANNOYDIR/fanboy_newsletter_shopping_allowlist_general_hide.txt $ANNOYDIR/fanboy_newsletter_allowlist_general_hide.txt > $ANNOYDIR/news-ubo.xx1

### ABP Newsletter combine
cat $MAINDIR/fanboy-newsletter-template.txt $ANNOYDIR/fanboy_newsletter_general_block.txt $ANNOYDIR/fanboy_newsletter_international_block.txt $ANNOYDIR/fanboy_newsletter_specific_block.txt $ANNOYDIR/fanboy_newsletter_general_hide.txt \
    $ANNOYDIR/fanboy_newsletter_specific_hide.txt $ANNOYDIR/fanboy_newsletter_international_hide.txt $ANNOYDIR/fanboy_newsletter_thirdparty.txt $ANNOYDIR/fanboy_newsletter_specific_ABP.txt $ANNOYDIR/fanboy_newsletter_shopping_specific_block.txt \
    $ANNOYDIR/fanboy_newsletter_shopping_specific_hide.txt $ANNOYDIR/fanboy_newsletter_shopping_allowlist_general_hide.txt $ANNOYDIR/fanboy_newsletter_shopping_specific_ABP.txt $ANNOYDIR/fanboy_newsletter_allowlist.txt $ANNOYDIR/fanboy_newsletter_shopping_allowlist.txt \
    $ANNOYDIR/fanboy_newsletter_shopping_allowlist_general_hide.txt $ANNOYDIR/fanboy_newsletter_allowlist_general_hide.txt > $ANNOYDIR/news-abp.xx1

# Check $ANNOYDIR/news-ubo.xx1 exists and not zero
if [ ! -e "$ANNOYDIR/news-ubo.xx1" ] || [ ! -s "$ANNOYDIR/news-ubo.xx1" ]; then
    echo "File is either empty or does not exist. Exiting..."
    exit 1
fi
# echo "File is non-empty. Continue with the rest of the script.

# Remove blank lines
sed -i '/\S/,$!d' $ANNOYDIR/news-ubo.xx1
sed -i '/\S/,$!d' $ANNOYDIR/news-abp.xx1
# Rename
cp -f $ANNOYDIR/news-abp.xx1 $ANNOYDIR/fanboy-newsletter_abp.txt
cp -f $ANNOYDIR/news-ubo.xx1 $ANNOYDIR/fanboy-newsletter.txt

#################### SOCIAL

### uBO Social combine
cat $MAINDIR/fanboy-social-template.txt $ANNOYDIR/fanboy_social_general_block.txt $ANNOYDIR/fanboy_social_general_hide.txt $ANNOYDIR/fanboy_social_thirdparty.txt $ANNOYDIR/fanboy_social_specific_block.txt \
    $ANNOYDIR/fanboy_social_specific_hide.txt $ANNOYDIR/fanboy_social_specific_uBO.txt $ANNOYDIR/fanboy_social_international.txt $ANNOYDIR/fanboy_social_allowlist_general_hide.txt $ANNOYDIR/fanboy_social_allowlist.txt > $ANNOYDIR/easylist-social_ubo.txt

### ABP Social combine
cat $MAINDIR/fanboy-social-template.txt $ANNOYDIR/fanboy_social_general_block.txt $ANNOYDIR/fanboy_social_general_hide.txt $ANNOYDIR/fanboy_social_thirdparty.txt $ANNOYDIR/fanboy_social_specific_block.txt \
    $ANNOYDIR/fanboy_social_specific_hide.txt fanboy_social_specific_ABP.txt $ANNOYDIR/fanboy_social_international.txt $ANNOYDIR/fanboy_social_allowlist_general_hide.txt $ANNOYDIR/fanboy_social_allowlist.txt > $ANNOYDIR/easylist-social.txt

# Check $ANNOYDIR/easylist-social_ubo.txt exists and not zero
if [ ! -e "$ANNOYDIR/easylist-social_ubo.txt" ] || [ ! -s "$ANNOYDIR/easylist-social_ubo.txt" ]; then
    echo "File is either empty or does not exist. Exiting..."
    exit 1
fi
# echo "File is non-empty. Continue with the rest of the script.

# Remove blank lines
sed -i '/\S/,$!d' $ANNOYDIR/easylist-social_ubo.txt
sed -i '/\S/,$!d' $ANNOYDIR/easylist-social.txt
  
# Remove the template file, top 10 lines (for merging other files)
sed '1,13d' $ANNOYDIR/easylist-social_ubo.txt > $ANNOYDIR/social-clean_ubo.txt
sed '1,13d' $ANNOYDIR/easylist-social.txt > $ANNOYDIR/social_clean_abp.txt


####################  EASYLIST COOKIE (we can generate it from exisiting)

if [ -s "$MAINDIR/easylist-cookie_ubo.txt" ] && [ -s "$MAINDIR/easylist-cookie_abp.txt" ]; then
    # Remove the template file, top 10 lines.
    sed '1,10d' $MAINDIR/easylist-cookie_ubo.txt > $ANNOYDIR/elc-clean_ubo.txt
    sed '1,10d' $MAINDIR/easylist-cookie_abp.txt > $ANNOYDIR/elc-clean_abp.txt
else
    echo "Either one or both files do not exist or are empty."
fi

####################  Fanboy Notifications (we can generate it from exisiting)

if [ -s "$MAINDIR/fanboy-notifications.txt" ] && [ -s "$MAINDIR/fanboy-mobile-notifications.txt" ]; then
    # Remove the template file, top 14 lines.
    sed '1,14d' $MAINDIR/fanboy-notifications.txt > $ANNOYDIR/fanboy-noti-clean.txt
else
    echo "Either one or both files do not exist or are empty."
fi

####################  Fanboy Agegate (we can generate it from exisiting)

if [ -s "$MAINDIR/fanboy-agegate.txt" ] && [ -s "$MAINDIR/fanboy-agegate_abp.txt" ]; then
    # Remove the template file, top 13 lines.
    sed '1,13d' $MAINDIR/fanboy-agegate.txt > $ANNOYDIR/fanboy-age_clean_ubo.txt
    sed '1,13d' $MAINDIR/fanboy-agegate_abp.txt > $ANNOYDIR/fanboy-age_clean_abp.txt
else
    echo "Either one or both files do not exist or are empty."
fi

####################  Annoyances Specific

### uBO Annoyances combine
cat $MAINDIR/fanboy-annoyance-template.txt $ANNOYDIR/fanboy_annoyance_general_block.txt $ANNOYDIR/fanboy_annoyance_general_hide.txt $ANNOYDIR/fanboy_annoyance_specific_block.txt $ANNOYDIR/fanboy_annoyance_thirdparty.txt \
    $ANNOYDIR/fanboy_annoyance_specific_hide.txt $ANNOYDIR/fanboy_annoyance_international.txt $ANNOYDIR/fanboy_annoyance_allowlist.txt $ANNOYDIR/fanboy_annoyance_allowlist_general_hide.txt $ANNOYDIR/fanboy_annoyance_allowlist.txt \
    $ANNOYDIR/fanboy_annoyance_specific_uBO.txt $ANNOYDIR/social-clean_ubo.txt $ANNOYDIR/elc-clean_ubo.txt $ANNOYDIR/fanboy-noti-clean.txt $ANNOYDIR/fanboy-age_clean_ubo.txt > $ANNOYDIR/test.yxy41

### ABP Annoyances combine
cat $MAINDIR/fanboy-annoyance-template.txt $ANNOYDIR/fanboy_annoyance_general_block.txt $ANNOYDIR/fanboy_annoyance_general_hide.txt $ANNOYDIR/fanboy_annoyance_specific_block.txt $ANNOYDIR/fanboy_annoyance_thirdparty.txt \
    $ANNOYDIR/fanboy_annoyance_specific_hide.txt $ANNOYDIR/fanboy_annoyance_international.txt $ANNOYDIR/fanboy_annoyance_allowlist.txt $ANNOYDIR/fanboy_annoyance_allowlist_general_hide.txt $ANNOYDIR/fanboy_annoyance_allowlist.txt \
    $ANNOYDIR/fanboy_annoyance_specific_ABP.txt $ANNOYDIR/social_clean_abp.txt $ANNOYDIR/elc-clean_abp.txt $ANNOYDIR/fanboy-noti-clean.txt $ANNOYDIR/fanboy-age_clean_abp.txt > $ANNOYDIR/test.yxy42
    
# Check $ANNOYDIR/test.yxy41 exists and not zero
if [ ! -e "$ANNOYDIR/test.yxy41" ] || [ ! -s "$ANNOYDIR/test.yxy41" ]; then
    echo "File is either empty or does not exist. Exiting..."
    exit 1
fi
# echo "File is non-empty. Continue with the rest of the script.

# Remove blank lines
sed -i '/\S/,$!d' $ANNOYDIR/test.yxy41
sed -i '/\S/,$!d' $ANNOYDIR/test.yxy42

mv -f $ANNOYDIR/test.yxy41 $ANNOYDIR/fanboy-annoyances.txt
mv -f $ANNOYDIR/test.yxy42 $ANNOYDIR/fanboy-annoyances_abp.txt

# Checksum
$ADDCHECKSUM $ANNOYDIR/fanboy-annoyances.txt
$ADDCHECKSUM $ANNOYDIR/fanboy-annoyances_abp.txt

####################  PUBLISH

if diff $ANNOYDIR/fanboy-annoyances.txt $MAINDIR/fanboy-annoyance.txt > $DIFFLOGS/annoyances-$CURRENTDATE-differences.log ; then
    echo "No need to change"
else
    echo "Creating Fanboy Annoyances"
    # BACKUP
    cp -f $ANNOYDIR/fanboy-annoyances.txt $DIFFLOGS/fanboy-annoyances-$CURRENTDATE.txt

    # Copy to server and create gzip copy
    cp -f $ANNOYDIR/fanboy-annoyances.txt $MAINDIR/fanboy-annoyance.txt
    cp -f $ANNOYDIR/fanboy-annoyances.txt $MAINDIR/fanboy-annoyance_ubo.txt
    cp -f $ANNOYDIR/fanboy-annoyances_abp.txt $MAINDIR/fanboy-annoyances_abp.txt
   
    # cp -f $ANNOYDIR/easylist_cookie_specific_uBO.txt $MAINDIR/easylist_cookie/easylist_cookie_specific_uBO.txt
    # cp -f $ANNOYDIR/fanboy_notifications_specific_uBO.txt $MAINDIR/fanboy_notifications_specific_uBO.txt
    # cp -f $ANNOYDIR/fanboy_newsletter_specific_uBO.txt $MAINDIR/fanboy_newsletter_specific_uBO.txt

    # cp -f $COOKDIR/easylist_cookie_specific_uBO.txt $MAINDIR/r/easylist_cookie_specific_uBO.txt
    # cp -f $COOKDIR/easylist_cookie_specific_uBO.txt $MAINDIR/r/easylist_cookie/easylist_cookie_specific_uBO.txt
    # cp -f $COOKDIR/fanboy_notifications_specific_uBO.txt $MAINDIR/r/fanboy_notifications_specific_uBO.txt
    # cp -f $COOKDIR/fanboy_notifications_specific_uBO.txt $MAINDIR/r/easylist_cookie/fanboy_notifications_specific_uBO.txt

    cp -f $ANNOYDIR/fanboy_annoyance_specific_uBO.txt $MAINDIR/easylist_cookie/fanboy_annoyance_specific_uBO.txt
    cp -f $ANNOYDIR/fanboy_annoyance_specific_uBO.txt $MAINDIR/r/fanboy_annoyance_specific_uBO.txt

    # newsletter
    # cp -f $COOKDIR/fanboy_newsletter_cookie_specific_uBO.txt $MAINDIR/r/easylist_cookie/fanboy_newsletter_specific_uBO.txt
    # cp -f $COOKDIR/fanboy_newsletter_cookie_specific_uBO.txt $MAINDIR/r/fanboy_newsletter_specific_uBO.txt

    # cp -f $COOKDIR/fanboy_social_specific_uBO.txt $MAINDIR/easylist_cookie/fanboy_social_specific_uBO.txt
    # cp -f $COOKDIR/fanboy_social_specific_uBO.txt $MAINDIR/r/fanboy_social_specific_uBO.txt

    rm -rf $MAINDIR/easylist_cookie/easylist_cookie_specific_uBO.txt.gz $MAINDIR/easylist_cookie/fanboy_annoyance_specific_uBO.txt.gz $MAINDIR/easylist_cookie/fanboy_social_specific_uBO.txt.gz
  
    # Clear old .gz first
    rm -rf $MAINDIR/fanboy-annoyance.txt.gz $MAINDIR/fanboy-annoyance_ubo.txt.gz $MAINDIR/fanboy-annoyances_abp.txt.gz
 
    # Compress
    $ZIP $MAINDIR/fanboy-annoyance.txt > $MAINDIR/fanboy-annoyance.txt.gz
    cp -f $MAINDIR/fanboy-annoyance.txt.gz $DIFFLOGS/fanboy-annoyances-$CURRENTDATE.txt.gz
    
    $ZIP $MAINDIR/fanboy-annoyances_abp.txt > $MAINDIR/fanboy-annoyances_abp.txt.gz
    $ZIP $MAINDIR/fanboy-annoyance_ubo.txt > $MAINDIR/fanboy-annoyance_ubo.txt.gz
  
    $ZIP $ANNOYDIR/fanboy_annoyance_specific_uBO.txt > $MAINDIR/easylist_cookie/fanboy_annoyance_specific_uBO.txt.gz

fi




