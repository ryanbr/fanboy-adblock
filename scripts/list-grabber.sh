#!/bin/bash
#
# Fanboy Adblock list grabber script v1.4 (18/04/2011)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#

# Creating a 20Mb ramdisk Temp storage...
#
if [ ! -d "/tmp/ramdisk/" ]; then
    rm -rf /tmp/ramdisk/
    mkdir /tmp/ramdisk; chmod 777 /tmp/ramdisk
    mount -t tmpfs -o size=20M tmpfs /tmp/ramdisk/
    mkdir /tmp/ramdisk/opera/
fi
if [ ! -d "/tmp/ramdisk/opera/" ]; then
    mkdir /tmp/ramdisk/opera/
fi

# Grab Mercurial Updates
#
cd /home/fanboy/google/fanboy-adblock-list/
/usr/local/bin/hg pull
/usr/local/bin/hg update

# Variables for directorys
#
MAINDIR="/var/www/adblock"
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list"
TESTDIR="/tmp/ramdisk"
ZIP="/usr/local/bin/7za"

# Copy Popular Files into Ram Disk
#
rm -f $TESTDIR/opera/urlfilter.ini $TESTDIR/opera/urlfilter-stats.ini
cp -f $MAINDIR/addChecksum.pl $MAINDIR/opera/addChecksum-opera.pl $TESTDIR
cp -f $GOOGLEDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-stats.ini $TESTDIR/opera/

# Make sure the shell scripts are exexcutable, all the time..
#
chmod a+x $GOOGLEDIR/scripts/ie/*.sh $GOOGLEDIR/scripts/iron/*.sh $GOOGLEDIR/scripts/*.sh $GOOGLEDIR/scripts/firefox/*.sh

# Main List
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt ]
then
  if diff $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $MAINDIR/fanboy-adblock.txt-org >/dev/null ; then
    echo "No changes detected: fanboy-adblock.txt" > /dev/null
  else
    # temp re-direct
    # sed '5a\! Redirect: http://fanboy-adblock-list.googlecode.com/hg/fanboy-adblocklist-current-expanded.txt' $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt > $TESTDIR/firefox-expanded.txt-org2
    cp -f $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $MAINDIR/fanboy-adblock.txt-org
    sed '5a\! Redirect: https://bitbucket.org/fanboy/fanboyadblock/raw/tip/fanboy-adblocklist-current-expanded.txt' $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt > $TESTDIR/firefox-expanded.txt-org2
    perl $TESTDIR/addChecksum.pl $TESTDIR/firefox-expanded.txt-org2
    cp -f $TESTDIR/firefox-expanded.txt-org2 $MAINDIR/fanboy-adblock.txt
    # cp -f $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $MAINDIR/fanboy-adblock.txt
    # cp -f $TESTDIR/fanboy-adblocklist-current-expanded.txt $MAINDIR/fanboy-adblock.txt
    rm -f $MAINDIR/fanboy-adblock.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-adblock.txt.gz $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt > /dev/null
    # The Dimensions List
    #
    sed  -n '/Dimensions/,/Adult Blocking Rules/{/Adult Blocking Rules/!p}' $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt > $TESTDIR/dim-temp.txt
    sed '1,2d' $TESTDIR/dim-temp.txt > $TESTDIR/dim-temp1.txt
    sed -e '$d' $TESTDIR/dim-temp1.txt > $TESTDIR/dim-temp2.txt
    cat $MAINDIR/header-dim.txt $TESTDIR/dim-temp2.txt > $TESTDIR/dim-temp.txt
    perl $TESTDIR/addChecksum.pl $TESTDIR/dim-temp.txt > /dev/null
    # Compare the Dimensions on the website vs mercurial copy
    #
    if diff $TESTDIR/dim-temp.txt $MAINDIR/fanboy-dimensions.txt >/dev/null ; then
       echo "No Changes detected: fanboy-dimensions.txt"
      else
       echo "Updated: fanboy-dimensions.txt"
       cp -f $TESTDIR/dim-temp.txt $MAINDIR/fanboy-dimensions.txt
       rm -f $MAINDIR/fanboy-dimensions.txt.gz
       $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-dimensions.txt.gz $TESTDIR/dim-temp.txt > /dev/null
    fi
    
    # The Adult List
    #
    $GOOGLEDIR/scripts/firefox/fanboy-adult.sh

    # The P2P List
    #
    $GOOGLEDIR/scripts/firefox/fanboy-p2p.sh

    # Seperage off CSS elements for Opera CSS
    sed -n '/Generic Hiding Rules/,/Common Element Rules/{/Common Element Rules/!p}' $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt > $TESTDIR/fanboy-css.txt
    # remove the top 3 lines
    sed '1,2d' $TESTDIR/fanboy-css.txt > $TESTDIR/fanboy-css0.txt
    # remove bottom line
    sed -e '$d' $TESTDIR/fanboy-css0.txt  > $TESTDIR/fanboy-css.txt
    #
    # Remove selected lines (be very specific, include comma)
    # sed -i '/#testfilter,/d' fanboy-css.txt
    #
    # the magic, remove ## and #. and add , to each line
    cat $TESTDIR/fanboy-css.txt | sed 's/^..\(.*\)$/\1,/' > $TESTDIR/fanboy-cs2.txt
    cat $MAINDIR/header-opera.txt $TESTDIR/fanboy-cs2.txt $GOOGLEDIR/other/opera-addon.css > $TESTDIR/fanboy-css.txt
    # remove any blank lines in Opera css
    sed '/^$/d' $TESTDIR/fanboy-css.txt > $TESTDIR/fanboy-css0.txt
    # remove ^M from the lists..
    tr -d '\r' <$TESTDIR/fanboy-css0.txt >$TESTDIR/fanboy-css.txt
    mv -f $TESTDIR/fanboy-css0.txt $TESTDIR/fanboy-css.txt
    # Fix speedtest.net 27/03/2011 (reported)
    sed -i '/.ad-vertical-container/d' $TESTDIR/fanboy-css.txt
    perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-css.txt
    cp -f $TESTDIR/fanboy-css.txt $MAINDIR/opera/fanboy-adblocklist-elements-v4.css
    rm -f $MAINDIR/opera/fanboy-adblocklist-elements-v4.css.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/fanboy-adblocklist-elements-v4.css.gz $MAINDIR/opera/fanboy-adblocklist-elements-v4.css > /dev/null
    # Seperate off Elements
    #
    sed  -n '/Adblock Plus/,/p2p Element Firefox/{/p2p Element Firefox/!p}' $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt > $TESTDIR/fanboy-noele.txt
    sed -e '$d' $TESTDIR/fanboy-noele.txt > $TESTDIR/fanboy-noele2.txt
    perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-noele2.txt
    if diff $TESTDIR/fanboy-noele2.txt $MAINDIR/fanboy-adblock-noele.txt > /dev/null ; then
        echo "No Changes detected: fanboy-adblock-noele.txt"
    else
        echo "Updated: fanboy-adblock-noele.txt"
        rm -f $MAINDIR/fanboy-adblock-noele.txt.gz
        cp -f $TESTDIR/fanboy-noele2.txt $MAINDIR/fanboy-adblock-noele.txt
        $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-adblock-noele.txt.gz $TESTDIR/fanboy-noele2.txt > /dev/null
        # Generate IE script
        $GOOGLEDIR/scripts/ie/adblock-ie-generator.sh
    fi
    echo "Updated: fanboy-adblock.txt" > /dev/null
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror fanboy-adblocklist-current-expanded.txt size is zero, please fix. " mp3geek@gmail.com < /dev/null
fi

# Tracking
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/fanboy-adblocklist-stats.txt ]
then
  if diff $GOOGLEDIR/fanboy-adblocklist-stats.txt $MAINDIR/fanboy-tracking.txt >/dev/null ; then
     echo "No Changes detected: fanboy-tracking.txt"
   else
    echo "Updated: fanboy-tracking.txt"
    cp -f $GOOGLEDIR/fanboy-adblocklist-stats.txt $MAINDIR/fanboy-tracking.txt
    rm -f $MAINDIR/fanboy-tracking.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-tracking.txt.gz $GOOGLEDIR/fanboy-adblocklist-stats.txt > /dev/null
    # Now combine with international list
    sh /etc/crons/hg-grab-intl.sh
    # Generate IE script
    $GOOGLEDIR/scripts/ie/tracking-ie-generator.sh
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror fanboy-adblocklist-stats.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# Addon/Annoyances
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/fanboy-adblocklist-addon.txt ]
then
  if diff $GOOGLEDIR/fanboy-adblocklist-addon.txt $MAINDIR/fanboy-addon.txt >/dev/null ; then
    echo "No Changes detected: fanboy-addon.txt"
  else
    echo "Updated: fanboy-addon.txt"
    cp -f $GOOGLEDIR/fanboy-adblocklist-addon.txt $MAINDIR/fanboy-addon.txt
    rm -f $MAINDIR/fanboy-addon.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-addon.txt.gz $MAINDIR/fanboy-addon.txt > /dev/null
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror fanboy-adblocklist-addon.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# CZECH
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt $MAINDIR/fanboy-czech.txt >/dev/null ; then
    echo "No Changes detected: fanboy-czech.txt"
  else
   echo "Updated: fanboy-czech.txt"
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt $MAINDIR/fanboy-czech.txt
   rm -f $MAINDIR/fanboy-czech.txt.gz
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-czech.txt.gz $MAINDIR/fanboy-czech.txt > /dev/null
   # Generate IE script
   $GOOGLEDIR/scripts/ie/czech-ie-generator.sh
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror fanboy-adblocklist-cz.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# RUSSIAN
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt $MAINDIR/fanboy-russian.txt >/dev/null ; then
    echo "No Changes detected: fanboy-russian.txt"
  else
   echo "Updated: fanboy-russian.txt"
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt $MAINDIR/fanboy-russian.txt
   rm -f $MAINDIR/fanboy-russian.txt.gz
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-russian.txt.gz $MAINDIR/fanboy-russian.txt > /dev/null
   # Generate IE script
   $GOOGLEDIR/scripts/ie/russian-ie-generator.sh
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror fanboy-adblocklist-rus-v2.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# TURK
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt $MAINDIR/fanboy-turkish.txt >/dev/null ; then
    echo "No Changes detected: fanboy-turkish.txt"
  else
   echo "Updated: fanboy-turkish.txt"
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt $MAINDIR/fanboy-turkish.txt
   rm -f $MAINDIR/fanboy-turkish.txt.gz
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-turkish.txt.gz $MAINDIR/fanboy-turkish.txt > /dev/null
   # Generate IE script
   $GOOGLEDIR/scripts/ie/turkish-ie-generator.sh 
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror fanboy-adblocklist-tky.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# JAPANESE
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt $MAINDIR/fanboy-japanese.txt >/dev/null ; then
    echo "No Changes detected: fanboy-japanese.txt"
  else
   echo "Updated: fanboy-japanese.txt"
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt $MAINDIR/fanboy-japanese.txt
   rm -f $MAINDIR/fanboy-japanese.txt.gz
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-japanese.txt.gz $MAINDIR/fanboy-japanese.txt > /dev/null
   # Generate IE script
   $GOOGLEDIR/scripts/ie/italian-ie-generator.sh
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror fanboy-adblocklist-jpn.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# KOREAN
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt $MAINDIR/fanboy-korean.txt > /dev/null ; then
    echo "No Changes detected: fanboy-korean.txt"
   else
    echo "Updated: fanboy-korean.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt $MAINDIR/fanboy-korean.txt
    rm -f $MAINDIR/fanboy-korean.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-korean.txt.gz $MAINDIR/fanboy-korean.txt > /dev/null
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror fanboy-adblocklist-krn.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi


# ITALIAN
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt $MAINDIR/fanboy-italian.txt > /dev/null ; then
    echo "No Changes detected: fanboy-italian.txt"
   else
    echo "Updated: fanboy-italian.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt $MAINDIR/fanboy-italian.txt
    rm -f $MAINDIR/fanboy-italian.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-italian.txt.gz $MAINDIR/fanboy-italian.txt > /dev/null
    # Generate IE script
     $GOOGLEDIR/scripts/ie/italian-ie-generator.sh
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror fanboy-adblocklist-ita.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# POLISH
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt $MAINDIR/fanboy-polish.txt > /dev/null ; then
    echo "No Changes detected: fanboy-polish.txt"
   else
    echo "Updated: fanboy-polish.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt $MAINDIR/fanboy-polish.txt
    rm -f $MAINDIR/fanboy-polish.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-polish.txt.gz $MAINDIR/fanboy-polish.txt /dev/null
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror fanboy-adblocklist-pol.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# INDIAN
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt $MAINDIR/fanboy-indian.txt > /dev/null ; then
    echo "No Changes detected: fanboy-indian.txt"
   else
    echo "Updated: fanboy-indian.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt $MAINDIR/fanboy-indian.txt
    rm -f $MAINDIR/fanboy-indian.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-indian.txt.gz $MAINDIR/fanboy-indian.txt > /dev/null
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror fanboy-adblocklist-ind.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# VIETNAM
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt $MAINDIR/fanboy-vietnam.txt > /dev/null ; then
    echo "No Changes detected: fanboy-vietnam.txt"
   else
    echo "Updated: fanboy-vietnam.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt $MAINDIR/fanboy-vietnam.txt
    rm -f $MAINDIR/fanboy-vietnam.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-vietnam.txt.gz $MAINDIR/fanboy-vietnam.txt > /dev/null
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror fanboy-adblocklist-vtn.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# CHINESE
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt $MAINDIR/fanboy-chinese.txt > /dev/null ; then
    echo "No Changes detected: fanboy-chinese.txt"
   else
    echo "Updated: fanboy-chinese.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt $MAINDIR/fanboy-chinese.txt
    rm -f $MAINDIR/fanboy-chinese.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-chinese.txt.gz $MAINDIR/fanboy-chinese.txt > /dev/null
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror fanboy-adblocklist-chn.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# ESPANOL
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt $MAINDIR/fanboy-espanol.txt > /dev/null ; then
    echo "No Changes detected: fanboy-espanol.txt"
   else
    echo "Updated: fanboy-espanol.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt $MAINDIR/fanboy-espanol.txt
    rm -f $MAINDIR/fanboy-espanol.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-espanol.txt.gz $MAINDIR/fanboy-espanol.txt > /dev/null
		# Generate IE script
		$GOOGLEDIR/scripts/ie/espanol-ie-generator.sh
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror fanboy-adblocklist-esp.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# SWEDISH
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt ]
then
 if diff $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt $MAINDIR/fanboy-swedish.txt > /dev/null ; then
    echo "No Changes detected: fanboy-swedish.txt"
   else
    echo "Updated: fanboy-swedish.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt $MAINDIR/fanboy-swedish.txt
    rm -f $MAINDIR/fanboy-swedish.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-swedish.txt.gz $MAINDIR/fanboy-swedish.txt > /dev/null
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror fanboy-adblocklist-swe.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# Gannett
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/adblock-gannett.txt ]
then
 if diff $GOOGLEDIR/adblock-gannett.txt $MAINDIR/adblock-gannett.txt > /dev/null ; then
    echo "No Changes detected: fanboy-gannett.txt"
   else
    echo "Updated: fanboy-gannett.txt"
    cp -f $GOOGLEDIR/adblock-gannett.txt $MAINDIR/adblock-gannett.txt
    rm -f $MAINDIR/adblock-gannett.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/adblock-gannett.txt.gz $MAINDIR/adblock-gannett.txt > /dev/null
 fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror adblock-gannett.txt size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# Create a combined script, to be used else where
if [ -n $TESTDIR/opera/urlfilter.ini ] || [ -n $TESTDIR/opera/urlfilter-stats.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $TESTDIR/opera/urlfilter-stats.ini > $TESTDIR/urlfilter-stats.ini
else
# echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter.ini/urlfilter-stats size is zero, please fix." mp3geek@gmail.com < /dev/null
fi
  

# Opera and Tracking filter.
if [ -n $TESTDIR/opera/urlfilter.ini ] || [ -n $TESTDIR/opera/urlfilter-stats.ini ]
then
  if diff $TESTDIR/opera/urlfilter.ini $MAINDIR/opera/urlfilter.ini > /dev/null ; then
    echo "No Changes detected: urlfilter.ini"
   else
    echo "Updated: urlfilter.ini"
    cp -f $TESTDIR/opera/urlfilter.ini $MAINDIR/opera/urlfilter.ini
    rm -f $MAINDIR/opera/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/urlfilter.ini.gz $TESTDIR/opera/urlfilter.ini > /dev/null
    # Generate Iron script
    $GOOGLEDIR/scripts/iron/adblock-iron-generator.sh
    # Combine tracking filter
    sed '/^$/d' $TESTDIR/urlfilter-stats.ini > $TESTDIR/urfilter-stats2.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urfilter-stats2.ini
    if diff $TESTDIR/urfilter-stats2.ini $MAINDIR/opera/complete/urlfilter.ini > /dev/null ; then
      echo "No Changes detected: complete/urlfilter.ini"
    else
      echo "Updated: complete/urlfilter.ini"
      cp -f $TESTDIR/urfilter-stats2.ini $MAINDIR/opera/complete/urlfilter.ini
      rm -f $MAINDIR/opera/complete/urlfilter.ini.gz
      $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/complete/urlfilter.ini.gz $TESTDIR/urfilter-stats2.ini > /dev/null
      # Generate Iron script
      $GOOGLEDIR/scripts/iron/adblock-iron-generator.sh  
    fi
  fi
else
# echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter.ini/urlfilter-stats size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# Opera Czech
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/opera/urlfilter-cz.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-cz.ini > $TESTDIR/urlfilter-cz.ini
  sed '/^$/d' $TESTDIR/urlfilter-cz.ini > $TESTDIR/urlfilter-cz2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-cz2.ini
  if diff $TESTDIR/urlfilter-cz2.ini $MAINDIR/opera/cz/urlfilter.ini > /dev/null ; then
     echo "No Changes detected: czech/urlfilter.ini"
  else
     echo "Updated: czech/urlfilter.ini & czech/complete/urlfilter.ini"
     cat $TESTDIR/urlfilter-stats.ini $GOOGLEDIR/opera/urlfilter-cz.ini > $TESTDIR/urlfilter-cz-stats.ini
     perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-cz-stats.ini
     cp -f $TESTDIR/urlfilter-cz2.ini $MAINDIR/opera/cz/urlfilter.ini
     cp -f $TESTDIR/urlfilter-cz-stats.ini $MAINDIR/opera/cz/complete/urlfilter.ini
     rm -f $MAINDIR/opera/cz/complete/urlfilter.ini.gz $MAINDIR/opera/cz/urlfilter.ini.gz
     $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/cz/complete/urlfilter.ini.gz $TESTDIR/urlfilter-cz-stats.ini > /dev/null
     $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/cz/urlfilter.ini.gz $TESTDIR/urlfilter-cz2.ini > /dev/null
     # Generate Iron script
     $GOOGLEDIR/scripts/iron/czech-iron-generator.sh  
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-cz.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# Opera Polish
# Check for 0-sized file first
# 
if [ -n $GOOGLEDIR/opera/urlfilter-pol.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-pol.ini > $TESTDIR/urlfilter-pol.ini
  sed '/^$/d' $TESTDIR/urlfilter-pol.ini > $TESTDIR/urlfilter-pol2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-pol2.ini
  if diff $TESTDIR/urlfilter-pol2.ini $MAINDIR/opera/pol/urlfilter.ini > /dev/null ; then
      echo "No Changes detected: polish/urlfilter.ini"
  else
    echo "Updated: polish/urlfilter.ini & pol/complete/urlfilter.ini"
    cat $TESTDIR/urlfilter-stats.ini  $GOOGLEDIR/opera/urlfilter-pol.ini > $TESTDIR/urlfilter-pol-stats.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-pol-stats.ini
    cp -f $TESTDIR/urlfilter-pol2.ini $MAINDIR/opera/pol/urlfilter.ini
    cp -f $TESTDIR/urlfilter-pol-stats.ini $MAINDIR/opera/pol/complete/urlfilter.ini
    rm -f $MAINDIR/opera/pol/urlfilter.ini.gz $MAINDIR/opera/pol/complete/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/pol/complete/urfilter.ini.gz $TESTDIR/urlfilter-pol-stats.ini > /dev/null
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/pol/urlfilter.ini.gz $TESTDIR/urlfilter-pol2.ini > /dev/null
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-pol.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# Opera Espanol
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/opera/urlfilter-esp.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-esp.ini > $TESTDIR/urlfilter-esp.ini
  sed '/^$/d' $TESTDIR/urlfilter-esp.ini  > $TESTDIR/urlfilter-esp2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-esp2.ini
  if diff $TESTDIR/urlfilter-esp2.ini $MAINDIR/opera/esp/urlfilter.ini > /dev/null ; then
    echo "No Changes detected: esp/urlfilter.ini"
else
    echo "Updated: esp/urlfilter.ini & esp/complete/urlfilter.ini"
    cat $TESTDIR/urlfilter-stats.ini $GOOGLEDIR/opera/urlfilter-esp.ini > $TESTDIR/urlfilter-esp-stats.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-esp-stats.ini
    cp -f $TESTDIR/urlfilter-esp-stats.ini $MAINDIR/opera/esp/complete/urlfilter.ini
    cp -f $TESTDIR/urlfilter-esp2.ini $MAINDIR/opera/esp/urlfilter.ini
    rm -f $MAINDIR/opera/esp/urlfilter.ini.gz $MAINDIR/opera/esp/complete/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/esp/urlfilter.ini.gz $TESTDIR/urlfilter-esp2.ini > /dev/null
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/esp/complete/urlfilter.ini.gz $TESTDIR/urlfilter-esp-stats.ini >/dev/null
    # Generate Iron script
    $GOOGLEDIR/scripts/iron/espanol-iron-generator.sh  
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-esp.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# Opera Russian
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/opera/urlfilter-rus.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-rus.ini > $TESTDIR/urlfilter-rus.ini
  sed '/^$/d' $TESTDIR/urlfilter-rus.ini > $TESTDIR/urlfilter-rus2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-rus2.ini
  if diff $TESTDIR/urlfilter-rus2.ini $MAINDIR/opera/rus/urlfilter.ini > /dev/null ; then
    echo "No Changes detected: rus/urlfilter.ini"
  else
    echo "Updated: rus/urlfilter.ini & rus/complete/urlfilter.ini"
    cat $TESTDIR/urlfilter-stats.ini $GOOGLEDIR/opera/urlfilter-rus.ini > $TESTDIR/urlfilter-rus-stats.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-rus-stats.ini
    cp -f $TESTDIR/urlfilter-rus-stats.ini $MAINDIR/opera/rus/complete/urlfilter.ini
    cp -f $TESTDIR/urlfilter-rus2.ini $MAINDIR/opera/rus/urlfilter.ini
    rm -f $MAINDIR/opera/rus/complete/urlfilter.ini.gz $MAINDIR/opera/rus/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/rus/complete/urlfilter.ini.gz $TESTDIR/urlfilter-rus-stats.ini >/dev/null
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/rus/urlfilter.ini.gz $TESTDIR/urlfilter-rus2.ini >/dev/null
    # Generate Iron script
    $GOOGLEDIR/scripts/iron/russian-iron-generator.sh  
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-rus.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# Opera Swedish
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/opera/urlfilter-swe.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-swe.ini > $TESTDIR/urlfilter-swe.ini
  sed '/^$/d' $TESTDIR/urlfilter-swe.ini > $TESTDIR/urlfilter-swe2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-swe2.ini
  if diff $TESTDIR/urlfilter-swe2.ini $MAINDIR/opera/swe/urlfilter.ini > /dev/null ; then
    echo "No Changes detected: swe/urlfilter.ini"
  else
    echo "Updated: swe/urlfilter.ini & swe/complete/urlfilter.ini"
    cat $TESTDIR/urlfilter-stats.ini $GOOGLEDIR/opera/urlfilter-swe.ini > $TESTDIR/urlfilter-swe-stats.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-swe-stats.ini
    cp -f $TESTDIR/urlfilter-swe-stats.ini $MAINDIR/opera/swe/complete/urlfilter.ini
    cp -f $TESTDIR/urlfilter-swe2.ini $MAINDIR/opera/swe/urlfilter.ini
    rm -f $MAINDIR/opera/swe/urlfilter.ini.gz $MAINDIR/opera/swe/complete/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/swe/complete/urlfilter.ini.gz $TESTDIR/urlfilter-swe-stats.ini > /dev/null
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/swe/urlfilter.ini.gz $TESTDIR/urlfilter-swe2.ini > /dev/null
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-swe.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi
    
# Opera JPN
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/opera/urlfilter-jpn.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-jpn.ini > $TESTDIR/urlfilter-jpn.ini
  sed '/^$/d' $TESTDIR/urlfilter-jpn.ini > $TESTDIR/urlfilter-jpn2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-jpn2.ini
  if diff $TESTDIR/urlfilter-jpn2.ini $MAINDIR/opera/jpn/urlfilter.ini > /dev/null ; then
    echo "No Changes detected: jpn/urlfilter.ini"
  else
    echo "Updated: jpn/urlfilter.ini & jpn/complete/urlfilter.ini"
    cat $TESTDIR/urlfilter-stats.ini $GOOGLEDIR/opera/urlfilter-jpn.ini > $TESTDIR/urlfilter-jpn-stats.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-jpn-stats.ini
    cp -f $TESTDIR/urlfilter-jpn-stats.ini $MAINDIR/opera/jpn/complete/urlfilter.ini
    cp -f $TESTDIR/urlfilter-jpn2.ini $MAINDIR/opera/jpn/urlfilter.ini
    rm -f $MAINDIR/opera/jpn/urlfilter.ini.gz $MAINDIR/opera/jpn/complete/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/jpn/complete/urlfilter.ini.gz $TESTDIR/urlfilter-jpn-stats.ini > /dev/null
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/jpn/urlfilter.ini.gz $TESTDIR/urlfilter-jpn2.ini > /dev/null
    # Generate Iron script
    $GOOGLEDIR/scripts/iron/japanese-iron-generator.sh  
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-jpn.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi
    
# Opera VTN
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/opera/urlfilter-vtn.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-vtn.ini > $TESTDIR/urlfilter-vtn.ini
  sed '/^$/d' $TESTDIR/urlfilter-vtn.ini > $TESTDIR/urlfilter-vtn2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-vtn2.ini
  if diff $TESTDIR/urlfilter-vtn2.ini $MAINDIR/opera/vtn/urlfilter.ini > /dev/null ; then
    echo "No Changes detected: vtn/urlfilter.ini"
  else
    echo "Updated: vtn/urlfilter.ini & vtn/complete/urlfilter.ini"
    cat $TESTDIR/urlfilter-stats.ini $GOOGLEDIR/opera/urlfilter-vtn.ini > $TESTDIR/urlfilter-vtn-stats.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-vtn-stats.ini
    cp -f $TESTDIR/urlfilter-vtn-stats.ini $MAINDIR/opera/vtn/complete/urlfilter.ini
    cp -f $TESTDIR/urlfilter-vtn2.ini $MAINDIR/opera/vtn/urlfilter.ini
    rm -f $MAINDIR/opera/vtn/urlfilter.ini.gz $MAINDIR/opera/vtn/complete/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/vtn/complete/urlfilter.ini.gz $TESTDIR/urlfilter-vtn-stats.ini > /dev/null
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/vtn/urlfilter.ini.gz $TESTDIR/urlfilter-vtn2.ini > /dev/null
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-vtn.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi

# Opera Turk
# Check for 0-sized file first
#
if [ -n $GOOGLEDIR/opera/urlfilter-tky.ini ]
then
  cat $TESTDIR/opera/urlfilter.ini $GOOGLEDIR/opera/urlfilter-tky.ini > $TESTDIR/urlfilter-tky.ini
  sed '/^$/d' $TESTDIR/urlfilter-tky.ini >  $TESTDIR/urlfilter-tky2.ini
  perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-tky2.ini
  if diff $TESTDIR/urlfilter-tky2.ini $MAINDIR/opera/trky/urlfilter.ini > /dev/null ; then
    echo "No Changes detected: trky/urlfilter.ini"
  else
    echo "Updated: trky/urlfilter.ini & trky/complete/urlfilter.ini"
    cat $TESTDIR/urlfilter-stats.ini $GOOGLEDIR/opera/urlfilter-tky.ini > $TESTDIR/urlfilter-tky-stats.ini
    perl $TESTDIR/addChecksum-opera.pl $TESTDIR/urlfilter-tky-stats.ini
    cp -f $TESTDIR/urlfilter-tky-stats.ini $MAINDIR/opera/trky/complete/urlfilter.ini
    cp -f $TESTDIR/urlfilter-tky2.ini $MAINDIR/opera/trky/urlfilter.ini
    rm -f $MAINDIR/opera/trky/complete/urlfilter.ini.gz $MAINDIR/opera/trky/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/trky/complete/urlfilter.ini.gz $TESTDIR/urlfilter-tky-stats.ini > /dev/null
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/trky/urlfilter.ini.gz $TESTDIR/urlfilter-tky2.ini > /dev/null
  fi
else
  # echo "Something went bad, file size is 0"
  mail -s "Google mirror urlfilter-tky.ini size is zero, please fix." mp3geek@gmail.com < /dev/null
fi
