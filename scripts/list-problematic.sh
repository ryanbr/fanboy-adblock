#!/bin/bash
#
# Fanboy-Problematic Adblock list grabber script v1.0 (11/03/2017)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#

export ZIP="nice -n 19 /usr/local/bin/7za a -mx=9 -y -tgzip"
export NICE="nice -n 19"
export TAC="/usr/bin/tac"
export CAT="/bin/cat"
export MAINDIR="/var/www/adblock"
export SPLITDIR="/var/www/adblock/split/test"
export HGSERV="/root/fanboy-adblock-list"
export TESTDIR="/root/tmp/work"
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export REPO="/home/fanboy/git/fanboy-adblock"

# Remove old files
rm -rf $TESTDIR/problematic* $TESTDIR/fanboy-problem*

# Copy the selected text  (from the enhanced list)
sed  -n '/Anti Adblock Tracking/,/Whitelisting rules/{/Whitelisting rules/!p}' $MAINDIR/enhancedstats.txt > $TESTDIR/problematic-bak.txt

# Include Adblock Header
cat $REPO/headers/header-problematic-sites.txt $TESTDIR/problematic-bak.txt  > $TESTDIR/problematic-bak.txt

# Remove Empty Lines
#
sed '/^$/d' $TESTDIR/problematic-bak.txt > $TESTDIR/fanboy-problematic.txt

# Create a backup incase addchecksum "zeros" the file
#
cp -f $TESTDIR/fanboy-problematic.txt $TESTDIR/fanboy-problematic-bak.txt

# Add checksum to file
#
$ADDCHECKSUM $TESTDIR/fanboy-problematic.txt

# Now lets check if fanboy-merged.txt isnt zero
#
if [ -s $TESTDIR/fanboy-problematic.txt ];
then
  # Copy Merged file to main dir
  #
  cp -f $TESTDIR/fanboy-problematic.txt $MAINDIR/fanboy-problematic-sites.txt

  # Compress file
  #
  ### echo "Updated fanboy-problematic-sites.txt"
  rm -f $MAINDIR/fanboy-problematic-sites.txt.gz
  # Compress file
  $ZIP $MAINDIR/fanboy-problematic-sites.txt.gz $MAINDIR/fanboy-problematic-sites.txt > /dev/null
  # Clear old Variables
  #
  rm -rf $TESTDIR/fanboy-problematic*
else
  # Use the backup file (fanboy-merged.txt was zero'd by addchecksum)
  #
  sleep 2
  $ADDCHECKSUM $TESTDIR/fanboy-problematic-bak.txt
  
  # Copy Merged file to main dir
  #
  cp -f $TESTDIR/fanboy-problematic-bak.txt $MAINDIR/fanboy-problematic-sites.txt
  
  # Compress file
  #
  ### echo "Updated fanboy+tracking+addon.txt (file was zero)"
  rm -f $MAINDIR/fanboy-problematic-sites.txt.gz
  # Compress file
  $ZIP $MAINDIR/fanboy-problematic-sites.txt.gz $MAINDIR/fanboy-problematic-sites.txt > /dev/null
  # Log
  # Clear old Variables
  #
  rm -rf $TESTDIR/fanboy-problematic*
fi
