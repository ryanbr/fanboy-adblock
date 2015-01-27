#!/bin/bash
#
# Easylist Mirroring Script
# Prerequisites: Webserver (nginx), 7zip, sha256sum, cron, wget
#
# Note, Please respect adblockplus.org and don't run script often to avoid 
# escessive server load for easylist-downloads.adblockplus.org. 
# (Once every 2hrs should be enough)
#
# 0 */2 * * *  /home/username/easylist-mirror.sh 
#
# Compress file
export ZIP="nice -n 19 /usr/local/bin/7za a -mx=9 -y -tgzip"
#
# Where its downloaded first.
export TEMPDIR="/root/temp"
#
# Main WWW Site
export MAINDIR="/var/www"
#
# For file comparison
export SHA256SUM="/usr/bin/sha256sum"
#
# Wget string
export WGET="nice -n 19 /usr/bin/wget -c -w 20 --no-check-certificate --tries=10 --waitretry=20 --retry-connrefused --timeout=45 --random-wait -U firefox -P $TEMPDIR"
#
# Check Tempdir exists before downloading to temp folder
if [[ -d "$TEMPDIR" && ! -L "$TEMPDIR" ]] ; then
   # Clear out old files before grabbing new ones.
   rm -rf $TEMPDIR/easylist.txt* $TEMPDIR/easyprivacy.txt* $TEMPDIR/fanboy-social.txt* $TEMPDIR/fanboy-annoyance.txt* $TEMPDIR/malwaredomains_full.txt* $TEMPDIR/easyprivacy+easylist.txt*
   # Using specific ip since mirrors will lag between commits
   # Current IPs: 88.198.15.197, 188.40.105.83, 88.198.59.19
   $WGET https://88.198.15.197/easylist.txt &> /dev/null 
   $WGET https://88.198.15.197/fanboy-annoyance.txt &> /dev/null
   $WGET https://88.198.15.197/easyprivacy+easylist.txt &> /dev/null
   $WGET https://88.198.15.197/fanboy-social.txt &> /dev/null
   $WGET https://88.198.15.197/easyprivacy.txt &> /dev/null
   $WGET https://88.198.15.197/malwaredomains_full.txt &> /dev/null
else
   mkdir $TEMPDIR
   $WGET https://88.198.15.197/easylist.txt &> /dev/null
   $WGET https://88.198.15.197/fanboy-annoyance.txt &> /dev/null
   $WGET https://88.198.15.197/easyprivacy+easylist.txt &> /dev/null
   $WGET https://88.198.15.197/fanboy-social.txt &> /dev/null
   $WGET https://88.198.15.197/easyprivacy.txt &> /dev/null
   $WGET https://88.198.15.197/malwaredomains_full.txt &> /dev/null
fi

###################   WGET CHECKER   ###################
#
# Check WGET was successful at grabbing the file, if not, re-grab from easylist-downloads.adblockplus.org

if [[ -e "$TEMPDIR/easylist.txt" && -s "$TEMPDIR/easylist.txt" ]];
  then
      echo "Easylist file grabbed" > /dev/null
  else
      $WGET https://easylist-downloads.adblockplus.org/easylist.txt
fi
## Easyprivacy
if [[ -e "$TEMPDIR/easyprivacy.txt" && -s "$TEMPDIR/easyprivacy.txt" ]];
  then
      echo "Easyprivacy file grabbed" > /dev/null
  else
      $WGET https://easylist-downloads.adblockplus.org/easyprivacy.txt
fi
## Fanboy-Annoyance
if [[ -e "$TEMPDIR/fanboy-annoyance.txt" && -s "$TEMPDIR/fanboy-annoyance.txt" ]];
  then
      echo "fanboy-annoyance.txt file grabbed" > /dev/null
  else
      $WGET https://easylist-downloads.adblockplus.org/fanboy-annoyance.txt
fi
## easyprivacy+easylist.txt
if [[ -e "$TEMPDIR/easyprivacy+easylist.txt" && -s "$TEMPDIR/easyprivacy+easylist.txt" ]];
  then
      echo "easyprivacy+easylist.txt file grabbed" > /dev/null
  else
      $WGET https://easylist-downloads.adblockplus.org/easyprivacy+easylist.txt
fi
## fanboy-social.txt
if [[ -e "$TEMPDIR/fanboy-social.txt" && -s "$TEMPDIR/fanboy-social.txt" ]];
  then
      echo "fanboy-social.txt file grabbed" > /dev/null
  else
      $WGET https://easylist-downloads.adblockplus.org/fanboy-social.txt
fi
## malwaredomains_full.txt
if [[ -e "$TEMPDIR/malwaredomains_full.txt" && -s "$TEMPDIR/malwaredomains_full.txt" ]];
  then
      echo "malwaredomains_full.txt file grabbed" > /dev/null
  else
      $WGET https://easylist-downloads.adblockplus.org/malwaredomains_full.txt
fi


###################   Easylist   ###################
#
# Check MAINDIR exists before comparing files
if [[ -d "${MAINDIR}" && ! -L "${MAINDIR}" ]] ; then
    #
    # Store checksum for file comparison
    SSLTEMP=$($SHA256SUM $TEMPDIR/easylist.txt | cut -d' ' -f1)
    SSLMAIN=$($SHA256SUM $MAINDIR/easylist.txt | cut -d' ' -f1)

    # Make sure the Downloaded file exists before going ahead
    if [[ -e "$TEMPDIR/easylist.txt" && -s "$TEMPDIR/easylist.txt" ]]; then
         # Now check between www and temp copies
         if [ "$SSLTEMP" != "$SSLMAIN" ]
        then
            # If file grabbed has changed, update site.
            echo "Lets Update the list, easylist.txt" > /dev/null
            cp -f $TEMPDIR/easylist.txt $MAINDIR/easylist.txt          
            $ZIP $TEMPDIR/easylist.txt.gz $MAINDIR/easylist.txt > /dev/null
            mv $TEMPDIR/easylist.txt.gz $MAINDIR/easylist.txt.gz
            # Now clear downloaded list
            rm -rf $TEMPDIR/easylist.txt         
         else
            rm -rf $TEMPDIR/easylist.txt    
            echo "Do Nothing (easylist.txt)" > /dev/null
         fi
    else
       echo "File does not exist"
    fi
else
  # Webserver dir not there?
  echo "Failed to find MAINDIR"
fi

###################   Easyprivacy   ###################
#
# Check MAINDIR exists before comparing files
if [[ -d "${MAINDIR}" && ! -L "${MAINDIR}" ]] ; then
    #
    # Store checksum for file comparison
    SSLTEMP=$($SHA256SUM $TEMPDIR/easyprivacy.txt | cut -d' ' -f1)
    SSLMAIN=$($SHA256SUM $MAINDIR/easyprivacy.txt | cut -d' ' -f1)

    # Make sure the Downloaded file exists before going ahead
    if [[ -e "$TEMPDIR/easyprivacy.txt" && -s "$TEMPDIR/easyprivacy.txt" ]]; then
         # Now check between www and temp copies
         if [ "$SSLTEMP" != "$SSLMAIN" ]
         then
            # If file grabbed has changed, update site.
            echo "Lets Update the list, easyprivacy.txt" > /dev/null
            cp -f $TEMPDIR/easyprivacy.txt $MAINDIR/easyprivacy.txt          
            $ZIP $TEMPDIR/easyprivacy.txt.gz $MAINDIR/easyprivacy.txt > /dev/null
            mv $TEMPDIR/easyprivacy.txt.gz $MAINDIR/easyprivacy.txt.gz
            # Now clear downloaded list
            rm -rf $TEMPDIR/easyprivacy.txt          
         else
            rm -rf $TEMPDIR/easyprivacy.txt
            echo "Do Nothing (easyprivacy.txt)" > /dev/null
         fi
    else
       echo "File does not exist"
    fi
else
  # Webserver dir not there?
  echo "Failed to find MAINDIR"
fi

###################   Easyprivacy+Easylist   ###################
#
# Check MAINDIR exists before comparing files
if [[ -d "${MAINDIR}" && ! -L "${MAINDIR}" ]] ; then
    #
    # Store checksum for file comparison
    SSLTEMP=$($SHA256SUM $TEMPDIR/easyprivacy+easylist.txt | cut -d' ' -f1)
    SSLMAIN=$($SHA256SUM $MAINDIR/easyprivacy+easylist.txt | cut -d' ' -f1)

    # Make sure the Downloaded file exists before going ahead
    if [[ -e "$TEMPDIR/easyprivacy+easylist.txt" && -s "$TEMPDIR/easyprivacy+easylist.txt" ]]; then
         # Now check between www and temp copies
         if [ "$SSLTEMP" != "$SSLMAIN" ]
         then
            # If file grabbed has changed, update site.
            echo "Lets Update the list, easyprivacy+easylist.txt" > /dev/null
            cp -f $TEMPDIR/easyprivacy+easylist.txt $MAINDIR/easyprivacy+easylist.txt          
            $ZIP $TEMPDIR/easyprivacy+easylist.txt.gz $MAINDIR/easyprivacy+easylist.txt > /dev/null
            mv $TEMPDIR/easyprivacy+easylist.txt.gz $MAINDIR/easyprivacy+easylist.txt.gz
            # Now clear downloaded list
            rm -rf $TEMPDIR/easyprivacy+easylist.txt
         else            
            rm -rf $TEMPDIR/easyprivacy+easylist.txt
            echo "Do Nothing (easyprivacy+easylist.txt)"  > /dev/null
         fi
    else
       echo "File does not exist"
    fi
else
  # Webserver dir not there?
  echo "Failed to find MAINDIR"
fi

###################   FanboyAnnoyance   ###################
#
# Check MAINDIR exists before comparing files
if [[ -d "${MAINDIR}" && ! -L "${MAINDIR}" ]] ; then
    #
    # Store checksum for file comparison
    SSLTEMP=$($SHA256SUM $TEMPDIR/fanboy-annoyance.txt | cut -d' ' -f1)
    SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-annoyance.txt | cut -d' ' -f1)

    # Make sure the Downloaded file exists before going ahead
    if [[ -e "$TEMPDIR/fanboy-annoyance.txt" && -s "$TEMPDIR/fanboy-annoyance.txt" ]]; then
         # Now check between www and temp copies
         if [ "$SSLTEMP" != "$SSLMAIN" ]
         then
            # If file grabbed has changed, update site.
            echo "Lets Update the list, fanboy-annoyance.txt" > /dev/null
            cp -f $TEMPDIR/fanboy-annoyance.txt $MAINDIR/fanboy-annoyance.txt          
            $ZIP $TEMPDIR/fanboy-annoyance.txt.gz $MAINDIR/fanboy-annoyance.txt > /dev/null
            mv $TEMPDIR/fanboy-annoyance.txt.gz $MAINDIR/fanboy-annoyance.txt.gz
            # Now clear downloaded list
            rm -rf $TEMPDIR/fanboy-annoyance.txt
         else
            rm -rf $TEMPDIR/fanboy-annoyance.txt
            echo "Do Nothing (fanboy-annoyance.txt)"  > /dev/null
         fi
    else
       echo "File does not exist"
    fi
else
  # Webserver dir not there?
  echo "Failed to find MAINDIR"
fi

###################   FanboySocial   ###################
#
# Check MAINDIR exists before comparing files
if [[ -d "${MAINDIR}" && ! -L "${MAINDIR}" ]] ; then
    #
    # Store checksum for file comparison
    SSLTEMP=$($SHA256SUM $TEMPDIR/fanboy-social.txt | cut -d' ' -f1)
    SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-social.txt | cut -d' ' -f1)

    # Make sure the Downloaded file exists before going ahead
    if [[ -e "$TEMPDIR/fanboy-social.txt" && -s "$TEMPDIR/fanboy-social.txt" ]]; then
         # Now check between www and temp copies
         if [ "$SSLTEMP" != "$SSLMAIN" ]
         then
            # If file grabbed has changed, update site.
            echo "Lets Update the list, fanboy-social.txt" > /dev/null
            cp -f $TEMPDIR/fanboy-social.txt $MAINDIR/fanboy-social.txt          
            $ZIP $TEMPDIR/fanboy-social.txt.gz $MAINDIR/fanboy-social.txt > /dev/null
            mv $TEMPDIR/fanboy-social.txt.gz $MAINDIR/fanboy-social.txt.gz
            # Now clear downloaded list
            rm -rf $TEMPDIR/fanboy-social.txt
         else
            rm -rf $TEMPDIR/fanboy-social.txt            
            echo "Do Nothing (fanboy-social.txt)"  > /dev/null
         fi
    else
       echo "File does not exist"
    fi
else
  # Webserver dir not there?
  echo "Failed to find MAINDIR"
fi

###################   Malwaredomains   ###################
#
# Check MAINDIR exists before comparing files
if [[ -d "${MAINDIR}" && ! -L "${MAINDIR}" ]] ; then
    #
    # Store checksum for file comparison
    SSLTEMP=$($SHA256SUM $TEMPDIR/malwaredomains_full.txt | cut -d' ' -f1)
    SSLMAIN=$($SHA256SUM $MAINDIR/malwaredomains_full.txt | cut -d' ' -f1)

    # Make sure the Downloaded file exists before going ahead
    if [[ -e "$TEMPDIR/malwaredomains_full.txt" && -s "$TEMPDIR/malwaredomains_full.txt" ]]; then
         # Now check between www and temp copies
         if [ "$SSLTEMP" != "$SSLMAIN" ]
         then
            # If file grabbed has changed, update site.
            echo "Lets Update the list, malwaredomains_full.txt" > /dev/null
            cp -f $TEMPDIR/malwaredomains_full.txt $MAINDIR/malwaredomains_full.txt          
            $ZIP $TEMPDIR/malwaredomains_full.txt.gz $MAINDIR/malwaredomains_full.txt > /dev/null
            mv $TEMPDIR/malwaredomains_full.txt.gz $MAINDIR/malwaredomains_full.txt.gz
            # Now clear downloaded list
            rm -rf $TEMPDIR/malwaredomains_full.txt
         else
            rm -rf $TEMPDIR/malwaredomains_full.txt
            echo "Do Nothing (malwaredomains_full.txt)"  > /dev/null
         fi
    else
       echo "File does not exist"
    fi
else
  # Webserver dir not there?
  echo "Failed to find MAINDIR"
fi