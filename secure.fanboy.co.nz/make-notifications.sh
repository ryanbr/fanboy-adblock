#!/bin/bash
#
# Fanboy Notification Script
# Prerequisites: Webserver (nginx), 7zip, sha256sum, cron, wget, addChecksum.pl
#
# 0 */2 * * *  /home/username/easylist-mirror.sh
#
set -e

# Main WWW Site
export MAINDIR="/var/www"

# Cookie DIR
export NOTIDIR="/root/temp/notifi"

# For file comparison
export SHA256SUM="/usr/bin/sha256sum"

# Wget string
export WGET="nice -n 19 /usr/bin/wget -w 20 --no-cache --no-cookies --tries=10 --waitretry=20 --retry-connrefused --timeout=45 --random-wait -U firefox -P $NOTIDIR"

export ADDCHECKSUM="nice -n 19 perl /root/fanboy-adblock/scripts/addChecksum.pl"
export ZIP="/usr/bin/7za a -mx=9 -y -tgzip"

# NOTIDIR
rm -Rf $NOTIDIR
if [ $? -ne 0 ]; then
    echo "Failed to remove src. Aborting script."
    exit 1
fi

# Grab the files we need
rm -rf $NOTIDIR/*
mkdir /root/temp/notifi
cd $NOTIDIR
export NOTIDIR="/root/temp/notifi"

# Notifications
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_notifications_allowlist.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_notifications_general_block.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_notifications_general_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_notifications_allowlist_general_hide.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_notifications_thirdparty.txt  &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_notifications_specific_block.txt  &> /dev/null
# Use official EL mirror
# $WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_notifications_specific_ABP.txt &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_notifications_specific_uBO.txt &> /dev/null
$WGET https://raw.githubusercontent.com/easylist/easylist/master/fanboy-addon/fanboy_notifications_specific_hide.txt  &> /dev/null

files_to_check=("fanboy_notifications_allowlist.txt"
                "fanboy_notifications_general_block.txt"
                "fanboy_notifications_general_hide.txt"
                "fanboy_notifications_allowlist_general_hide.txt"
                "fanboy_notifications_thirdparty.txt"
                "fanboy_notifications_specific_block.txt"
                "fanboy_notifications_specific_uBO.txt"
                "fanboy_notifications_specific_hide.txt"
)


# Change to the download directory
cd "$NOTIDIR" || exit 1

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
########################################  FB NOTIFICATION HEADER  ######################################
########################################################################################################

cat $MAINDIR/fanboy-notification-template.txt $NOTIDIR/fanboy_notifications_general_block.txt $NOTIDIR/fanboy_notifications_specific_block.txt $NOTIDIR/fanboy_notifications_general_hide.txt \
    $NOTIDIR/fanboy_notifications_specific_hide.txt $NOTIDIR/fanboy_notifications_thirdparty.txt $NOTIDIR/fanboy_notifications_specific_uBO.txt $NOTIDIR/fanboy_notifications_allowlist.txt \
    $NOTIDIR/fanboy_notifications_allowlist_general_hide.txt > $NOTIDIR/news.yxy
    
# Remove blank lines
sed -i '/\S/,$!d' $NOTIDIR/news.yxy
# Test
cp -f $NOTIDIR/news.yxy $NOTIDIR/fanboy-notifications.txt

# Now make FB Mobile
sed '/Mobile/,$!d' $NOTIDIR/fanboy_notifications_general_hide.txt > $NOTIDIR/fanboy_notifications_mobile_general_hide.txt
sed '/Mobile/,$!d' $NOTIDIR/fanboy_notifications_general_block.txt > $NOTIDIR/fanboy_notifications_mobile_general_block.txt
sed '/Mobile/,$!d' $NOTIDIR/fanboy_notifications_specific_block.txt  > $NOTIDIR/fanboy_notifications_mobile_specific_block.txt
sed '/Mobile/,$!d' $NOTIDIR/fanboy_notifications_specific_hide.txt  >  $NOTIDIR/fanboy_notifications_mobile_specific_hide.txt
sed '/Mobile/,$!d' $NOTIDIR/fanboy_notifications_thirdparty.txt  >  $NOTIDIR/fanboy_notifications_mobile_thirdparty.txt
# Just use uBO proper list
# sed '/Mobile/,$!d' $NOTIDIR/fanboy_notifications_specific_uBO.txt  >  $NOTIDIR/fanboy_notifications_mobile_specific_uBO.txt
sed '/Mobile/,$!d' $NOTIDIR/fanboy_notifications_allowlist.txt  >  $NOTIDIR/fanboy_notifications_mobile_allowlist.txt
sed '/Mobile/,$!d' $NOTIDIR/fanboy_notifications_allowlist_general_hide.txt >  $NOTIDIR/fanboy_notifications_mobile_allowlist_general_hide.txt


########################################################################################################
########################################  FB MOBILE NOTIFICATION HEADER  ###############################
########################################################################################################
echo "0.1"
# Clear old files, now merge mobile files
rm -rf $NOTIDIR/news.*

cat $MAINDIR/fanboy-m-notification-template.txt $NOTIDIR/fanboy_notifications_mobile_general_block.txt $NOTIDIR/fanboy_notifications_mobile_specific_block.txt $NOTIDIR/fanboy_notifications_mobile_general_hide.txt \
    $NOTIDIR/fanboy_notifications_mobile_specific_hide.txt $NOTIDIR/fanboy_notifications_mobile_thirdparty.txt $NOTIDIR/fanboy_notifications_specific_uBO.txt $NOTIDIR/fanboy_notifications_mobile_allowlist.txt \
    $NOTIDIR/fanboy_notifications_mobile_allowlist_general_hide.txt > $NOTIDIR/news.yxy
    
# Remove blank lines
sed -i '/\S/,$!d' $NOTIDIR/news.yxy
# Test
cp -f $NOTIDIR/news.yxy $NOTIDIR/fanboy-mobile-notifications.txt

cat $MAINDIR/fanboy-notification-template.txt $NOTIDIR/fanboy_notifications_general_block.txt $NOTIDIR/fanboy_notifications_general_hide.txt $NOTIDIR/fanboy_notifications_specific_block.txt \
    $NOTIDIR/fanboy_notifications_specific_hide.txt $NOTIDIR/fanboy_notifications_specific_block.txt $NOTIDIR/news2.xxy $NOTIDIR/fanboy_notifications_thirdparty.txt $NOTIDIR/fanboy_notifications_allowlist.txt \
    $NOTIDIR/fanboy_notifications_allowlist_general_hide.txt > $NOTIDIR/news2.yxy

# Remove blank lines
sed -i '/\S/,$!d' $NOTIDIR/news2.yxy
cp -f $NOTIDIR/news2.yxy $NOTIDIR/fanboy-notifications.txt

# FANBOY NOTIFICATIONS
# Ensure file isn't empty before continuing
if [[ -e "$NOTIDIR/fanboy-notifications.txt" && -s "$NOTIDIR/fanboy-notifications.txt" ]];
  then
     echo "Successfully created fanboy-notifications.txt"
     echo "0"
     # Remove blank lines
     sed -i '/\S/,$!d' $NOTIDIR/fanboy-notifications.txt
     # Checksum
     $ADDCHECKSUM $NOTIDIR/fanboy-notifications.txt
     echo "1"
     # Compare if the file has changed on secure.fanboy.co.nz before updating
     # Generate a hash to compare.
     SSLHG=$($SHA256SUM $NOTIDIR/fanboy-notifications.txt | cut -d' ' -f1)
     SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-notifications.txt | cut -d' ' -f1)
     echo "2"
     if [ "$SSLHG" != "$SSLMAIN" ]
       then
         # Ensure filesize is large enough before updating (6k)
         minimumsize=6000
         actualsize=$(wc -c <"/root/temp/notifi/fanboy-notifications.txt")
         if [ $actualsize -ge $minimumsize ]; then
             # File is large enough (Over size)
             echo "3"
             echo "File size seems correct"
             echo "fanboy-notifications.txt has been updated"
             # Copy to server and create gzip copy
             cp -f $NOTIDIR/fanboy-notifications.txt $MAINDIR/fanboy-notifications.txt
	     # remove old .gz
             rm -rf $MAINDIR/fanboy-notifications.txt.gz 
	     # Create gz
             $ZIP $NOTIDIR/fanboy-notifications.txt.gz $NOTIDIR/fanboy-notifications.txt > /dev/null
	     cp -f $NOTIDIR/fanboy-notifications.txt.gz $MAINDIR/fanboy-notifications.txt.gz
	     # Clear temp files
             #rm -rf $NOTIDIR/fanboy-notifications.txt $NOTIDIR/fanboy_notifications_*.txt news.*

         else
           echo "File size too small, nothing updated"
        fi
        echo "File Hasnt changed (Notifications)"
    fi
else
      # empty or missing file if fails here
     #rm -rf $NOTIDIR/fanboy-notifications.txt $NOTIDIR/fanboy_notifications_*.txt news.*
     echo "Failed in list creation (Fanboy Notifications)"
fi

# FANBOY MOBILE NOTIFICATIONS
# Ensure file isn't empty before continuing
if [[ -e "$NOTIDIR/fanboy-mobile-notifications.txt" && -s "$NOTIDIR/fanboy-mobile-notifications.txt" ]];
  then
     echo "Successfully created fanboy-mobile-notifications.txt"
     #echo "0"
     # Remove blank lines
     sed -i '/\S/,$!d' $NOTIDIR/fanboy-mobile-notifications.txt
     # Checksum
     $ADDCHECKSUM $NOTIDIR/fanboy-mobile-notifications.txt
     echo "1"
     # Compare if the file has changed on secure.fanboy.co.nz before updating
     # Generate a hash to compare.
     SSLHG=$($SHA256SUM $NOTIDIR/fanboy-mobile-notifications.txt | cut -d' ' -f1)
     SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-mobile-notifications.txt | cut -d' ' -f1)
     #echo "2"
     if [ "$SSLHG" != "$SSLMAIN" ]
       then
         # Ensure filesize is large enough before updating (6k)
         minimumsize=6000
         actualsize=$(wc -c <"/root/temp/notifi/fanboy-mobile-notifications.txt")
         if [ $actualsize -ge $minimumsize ]; then
             # File is large enough (Over size)
             # echo "3"
             echo "File size seems correct"
             echo "fanboy-mobile-notifications has been updated"
             # Copy to server and create gzip copy
             cp -f $NOTIDIR/fanboy-mobile-notifications.txt $MAINDIR/fanboy-mobile-notifications.txt
	     # remove old .gz
             rm -rf $MAINDIR/fanboy-notifications.txt.gz 
	     # Create gz
             $ZIP $NOTIDIR/fanboy-mobile-notifications.txt.gz $NOTIDIR/fanboy-mobile-notifications.txt > /dev/null
	     cp -f $NOTIDIR/fanboy-mobile-notifications.txt.gz $MAINDIR/fanboy-mobile-notifications.txt.gz
	     # Clear temp files
             #rm -rf $NOTIDIR/fanboy-notifications.txt $NOTIDIR/fanboy_notifications_*.txt news.*

         else
           echo "File size too small, nothing updated"
        fi
        echo "File Hasnt changed (Notifications)"
    fi
else
      # empty or missing file if fails here
     echo "Failed in list creation (Fanboy Notifications)"
fi

