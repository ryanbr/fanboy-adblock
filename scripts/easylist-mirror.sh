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
   $WGET https://88.198.15.197/easylist.txt.gz &> /dev/null
   $WGET https://88.198.15.197/fanboy-annoyance.txt.gz &> /dev/null
   $WGET https://88.198.15.197/easyprivacy+easylist.txt.gz &> /dev/null
   $WGET https://88.198.15.197/fanboy-social.txt.gz &> /dev/null
   $WGET https://88.198.15.197/easyprivacy.txt.gz &> /dev/null
   $WGET https://88.198.15.197/malwaredomains_full.txt.gz &> /dev/null
else
   mkdir $TEMPDIR
   $WGET https://88.198.15.197/easylist.txt.gz &> /dev/null
   $WGET https://88.198.15.197/fanboy-annoyance.txt.gz &> /dev/null
   $WGET https://88.198.15.197/easyprivacy+easylist.txt.gz &> /dev/null
   $WGET https://88.198.15.197/fanboy-social.txt.gz &> /dev/null
   $WGET https://88.198.15.197/easyprivacy.txt.gz &> /dev/null
   $WGET https://88.198.15.197/malwaredomains_full.txt.gz &> /dev/null
fi

###################   WGET CHECKER   ###################
#
# Check WGET was successful at grabbing the file, if not, re-grab from easylist-downloads.adblockplus.org

if [[ -e "$TEMPDIR/easylist.txt.gz" && -s "$TEMPDIR/easylist.txt.gz" ]];
  then
      echo "Easylist file grabbed" > /dev/null
  else
      $WGET https://easylist-downloads.adblockplus.org/easylist.txt.gz
fi
## Easyprivacy
if [[ -e "$TEMPDIR/easyprivacy.txt.gz" && -s "$TEMPDIR/easyprivacy.txt.gz" ]];
  then
      echo "Easyprivacy file grabbed" > /dev/null
  else
      $WGET https://easylist-downloads.adblockplus.org/easyprivacy.txt.gz
fi
## Fanboy-Annoyance
if [[ -e "$TEMPDIR/fanboy-annoyance.txt.gz" && -s "$TEMPDIR/fanboy-annoyance.txt.gz" ]];
  then
      echo "fanboy-annoyance.txt.gz file grabbed" > /dev/null
  else
      $WGET https://easylist-downloads.adblockplus.org/fanboy-annoyance.txt.gz
fi
## easyprivacy+easylist.txt.gz
if [[ -e "$TEMPDIR/easyprivacy+easylist.txt.gz" && -s "$TEMPDIR/easyprivacy+easylist.txt.gz" ]];
  then
      echo "easyprivacy+easylist.txt.gz file grabbed" > /dev/null
  else
      $WGET https://easylist-downloads.adblockplus.org/easyprivacy+easylist.txt.gz
fi
## fanboy-social.txt.gz
if [[ -e "$TEMPDIR/fanboy-social.txt.gz" && -s "$TEMPDIR/fanboy-social.txt.gz" ]];
  then
      echo "fanboy-social.txt.gz file grabbed" > /dev/null
  else
      $WGET https://easylist-downloads.adblockplus.org/fanboy-social.txt.gz
fi
## malwaredomains_full.txt.gz
if [[ -e "$TEMPDIR/malwaredomains_full.txt.gz" && -s "$TEMPDIR/malwaredomains_full.txt.gz" ]];
  then
      echo "malwaredomains_full.txt.gz file grabbed" > /dev/null
  else
      $WGET https://easylist-downloads.adblockplus.org/malwaredomains_full.txt.gz
fi


###################   Easylist   ###################
#
# Check MAINDIR exists before comparing files
if [[ -d "${MAINDIR}" && ! -L "${MAINDIR}" ]] ; then
    #
    # Store checksum for file comparison
    SSLTEMP=$($SHA256SUM $TEMPDIR/easylist.txt.gz | cut -d' ' -f1)
    SSLMAIN=$($SHA256SUM $MAINDIR/easylist.txt.gz | cut -d' ' -f1)

    # Make sure the Downloaded file exists before going ahead
    if [[ -e "$TEMPDIR/easylist.txt.gz" && -s "$TEMPDIR/easylist.txt.gz" ]]; then
         # Now check between www and temp copies
         if [ "$SSLTEMP" != "$SSLMAIN" ]
        then
            # If file grabbed has changed, update site.
            echo "Lets Update the list, easylist.txt.gz" > /dev/null
            cp -f $TEMPDIR/easylist.txt.gz $MAINDIR/easylist.txt.gz
            rm -rf $MAINDIR/easylist.txt         
            gunzip -c $TEMPDIR/easylist.txt.gz > $MAINDIR/easylist.txt 
            # Now clear downloaded list
            rm -rf $TEMPDIR/easylist.txt.gz         
         else
            rm -rf $TEMPDIR/easylist.txt.gz    
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
    SSLTEMP=$($SHA256SUM $TEMPDIR/easyprivacy.txt.gz | cut -d' ' -f1)
    SSLMAIN=$($SHA256SUM $MAINDIR/easyprivacy.txt.gz | cut -d' ' -f1)

    # Make sure the Downloaded file exists before going ahead
    if [[ -e "$TEMPDIR/easyprivacy.txt.gz" && -s "$TEMPDIR/easyprivacy.txt.gz" ]]; then
         # Now check between www and temp copies
         if [ "$SSLTEMP" != "$SSLMAIN" ]
         then
            # If file grabbed has changed, update site.
            echo "Lets Update the list, easyprivacy.txt.gz" > /dev/null
            cp -f $TEMPDIR/easyprivacy.txt.gz $MAINDIR/easyprivacy.txt.gz          
            rm -rf $MAINDIR/easyprivacy.txt
            gunzip -c $TEMPDIR/easyprivacy.txt.gz > $MAINDIR/easyprivacy.txt 
            # Now clear downloaded list
            rm -rf $TEMPDIR/easyprivacy.txt.gz          
         else
            rm -rf $TEMPDIR/easyprivacy.txt.gz
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
    SSLTEMP=$($SHA256SUM $TEMPDIR/easyprivacy+easylist.txt.gz | cut -d' ' -f1)
    SSLMAIN=$($SHA256SUM $MAINDIR/easyprivacy+easylist.txt.gz | cut -d' ' -f1)

    # Make sure the Downloaded file exists before going ahead
    if [[ -e "$TEMPDIR/easyprivacy+easylist.txt.gz" && -s "$TEMPDIR/easyprivacy+easylist.txt.gz" ]]; then
         # Now check between www and temp copies
         if [ "$SSLTEMP" != "$SSLMAIN" ]
         then
            # If file grabbed has changed, update site.
            echo "Lets Update the list, easyprivacy+easylist.txt.gz" > /dev/null
            cp -f $TEMPDIR/easyprivacy+easylist.txt.gz $MAINDIR/easyprivacy+easylist.txt.gz          
            rm -rf $MAINDIR/easyprivacy+easylist.txt
            gunzip -c $TEMPDIR/easyprivacy+easylist.txt.gz > $MAINDIR/easyprivacy+easylist.txt
            # Now clear downloaded list
            rm -rf $TEMPDIR/easyprivacy+easylist.txt.gz
         else            
            rm -rf $TEMPDIR/easyprivacy+easylist.txt.gz
            echo "Do Nothing (easyprivacy+easylist.txt.gz)"  > /dev/null
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
    SSLTEMP=$($SHA256SUM $TEMPDIR/fanboy-annoyance.txt.gz | cut -d' ' -f1)
    SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-annoyance.txt.gz | cut -d' ' -f1)

    # Make sure the Downloaded file exists before going ahead
    if [[ -e "$TEMPDIR/fanboy-annoyance.txt.gz" && -s "$TEMPDIR/fanboy-annoyance.txt.gz" ]]; then
         # Now check between www and temp copies
         if [ "$SSLTEMP" != "$SSLMAIN" ]
         then
            # If file grabbed has changed, update site.
            echo "Lets Update the list, fanboy-annoyance.txt.gz" > /dev/null
            cp -f $TEMPDIR/fanboy-annoyance.txt.gz $MAINDIR/fanboy-annoyance.txt.gz          
            rm -rf $MAINDIR/fanboy-annoyance.txt
            gunzip -c $TEMPDIR/fanboy-annoyance.txt.gz > $MAINDIR/fanboy-annoyance.txt
            # Now clear downloaded list
            rm -rf $TEMPDIR/fanboy-annoyance.txt.gz
         else
            rm -rf $TEMPDIR/fanboy-annoyance.txt.gz
            echo "Do Nothing (fanboy-annoyance.txt.gz)"  > /dev/null
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
    SSLTEMP=$($SHA256SUM $TEMPDIR/fanboy-social.txt.gz | cut -d' ' -f1)
    SSLMAIN=$($SHA256SUM $MAINDIR/fanboy-social.txt.gz | cut -d' ' -f1)

    # Make sure the Downloaded file exists before going ahead
    if [[ -e "$TEMPDIR/fanboy-social.txt.gz" && -s "$TEMPDIR/fanboy-social.txt.gz" ]]; then
         # Now check between www and temp copies
         if [ "$SSLTEMP" != "$SSLMAIN" ]
         then
            # If file grabbed has changed, update site.
            echo "Lets Update the list, fanboy-social.txt.gz" > /dev/null
            cp -f $TEMPDIR/fanboy-social.txt.gz $MAINDIR/fanboy-social.txt.gz          
            rm -rf $MAINDIR/fanboy-social.txt
            gunzip -c $TEMPDIR/fanboy-social.txt.gz > $MAINDIR/fanboy-social.txt
            # Now clear downloaded list
            rm -rf $TEMPDIR/fanboy-social.txt.gz
         else
            rm -rf $TEMPDIR/fanboy-social.txt.gz            
            echo "Do Nothing (fanboy-social.txt.gz)"  > /dev/null
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
    SSLTEMP=$($SHA256SUM $TEMPDIR/malwaredomains_full.txt.gz | cut -d' ' -f1)
    SSLMAIN=$($SHA256SUM $MAINDIR/malwaredomains_full.txt.gz | cut -d' ' -f1)

    # Make sure the Downloaded file exists before going ahead
    if [[ -e "$TEMPDIR/malwaredomains_full.txt.gz" && -s "$TEMPDIR/malwaredomains_full.txt.gz" ]]; then
         # Now check between www and temp copies
         if [ "$SSLTEMP" != "$SSLMAIN" ]
         then
            # If file grabbed has changed, update site.
            echo "Lets Update the list, malwaredomains_full.txt.gz" > /dev/null
            cp -f $TEMPDIR/malwaredomains_full.txt.gz $MAINDIR/malwaredomains_full.txt.gz          
            rm -rf $MAINDIR/malwaredomains_full.txt
            gunzip -c $TEMPDIR/malwaredomains_full.txt.gz > $MAINDIR/malwaredomains_full.txt
            # Now clear downloaded list
            rm -rf $TEMPDIR/malwaredomains_full.txt.gz
         else
            rm -rf $TEMPDIR/malwaredomains_full.txt.gz
            echo "Do Nothing (malwaredomains_full.txt.gz)"  > /dev/null
         fi
    else
       echo "File does not exist"
    fi
else
  # Webserver dir not there?
  echo "Failed to find MAINDIR"
fi