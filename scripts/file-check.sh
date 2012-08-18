#!/bin/bash
#
# Fanboy Adblock list - Filename checks v1.0 (7/05/2011)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Checks for 0-sized files and smaller than expected files.
#

# Creating Temp storage dir...
#
if [ ! -d "/var/tmp/temp" ]; then
    rm -rf /var/tmp/temp/*
    mkdir /var/tmp/temp; chmod 777 /var/tmp/temp
fi

# Variables for directorys
#
MAINDIR="/var/www/adblock"
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list"
ZIP="/usr/local/bin/7za"
TESTDIR="/var/tmp/temp"

# Clear Testdir
#
rm -rf /var/tmp/temp/*

# Main List (353530 - 2011-05-07)
#
FILENAME=/var/www/adblock/fanboy-adblock.txt
SIZE=$(du -sb $FILENAME | awk '{ print $1 }')

if ((SIZE<310000)); then 
    echo "Filesize is incorrect..." > /dev/null
    # Use wget instead of hg (assuming corruption of hg database)
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/fanboy-adblocklist-current-expanded.txt -P $TESTDIR --output-document=$TESTDIR/firefox-expanded.txt
    # Copy master file over
    cp -f $TESTDIR/firefox-expanded.txt $MAINDIR/fanboy-adblock.txt
    rm -rf $MAINDIR/fanboy-adblock.txt.gz
    # Compress
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-adblock.txt.gz $MAINDIR/fanboy-adblock.txt > /dev/null
    mail -s "fanboy-adblock.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# Tracking List (56584 - 2011-05-07)
#
FILENAME=/var/www/adblock/fanboy-tracking.txt

if ((SIZE<50000)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/fanboy-adblocklist-stats.txt -P $TESTDIR --output-document=$TESTDIR/firefox-tracking.txt
    cp -f $TESTDIR/firefox-tracking.txt $MAINDIR/fanboy-tracking.txt
    rm -rf $MAINDIR/fanboy-tracking.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-tracking.txt.gz $MAINDIR/fanboy-tracking.txt > /dev/null
    mail -s "fanboy-tracking.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# Addon List (56924 2011-05-07)
#
FILENAME=/var/www/adblock/fanboy-tracking.txt

if ((SIZE<40000)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/fanboy-adblocklist-addon.txt -P $TESTDIR --output-document=$TESTDIR/firefox-addon.txt
    cp -f $TESTDIR/firefox-addon.txt $MAINDIR/fanboy-addon.txt
    rm -rf $MAINDIR/fanboy-addon.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-addon.txt.gz $MAINDIR/fanboy-addon.txt > /dev/null
    mail -s "fanboy-addon.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# CZECH List (13863 2011-05-05)
#
FILENAME=/var/www/adblock/fanboy-czech.txt

if ((SIZE<11000)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/firefox-regional/fanboy-adblocklist-cz.txt -P $TESTDIR --output-document=$TESTDIR/firefox-cz.txt
    cp -f $TESTDIR/firefox-cz.txt $MAINDIR/fanboy-czech.txt
    rm -rf $MAINDIR/fanboy-czech.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-czech.txt.gz $MAINDIR/fanboy-czech.txt > /dev/null
    mail -s "fanboy-czech.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# RUSSIAN  (46502 2011-05-06)
#
FILENAME=/var/www/adblock/fanboy-russian.txt

if ((SIZE<40000)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/firefox-regional/fanboy-adblocklist-rus-v2.txt -P $TESTDIR --output-document=$TESTDIR/firefox-rus.txt
    cp -f $TESTDIR/firefox-rus.txt $MAINDIR/fanboy-russian.txt
    rm -rf $MAINDIR/fanboy-russian.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-russian.txt.gz $MAINDIR/fanboy-russian.txt > /dev/null
    mail -s "fanboy-russian.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# Turk  (46502 2011-05-06)
#
FILENAME=/var/www/adblock/fanboy-turkish.txt

if ((SIZE<40000)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/firefox-regional/fanboy-adblocklist-tky.txt -P $TESTDIR --output-document=$TESTDIR/fanboy-turkish.txt
    cp -f $TESTDIR/fanboy-turkish.txt $MAINDIR/fanboy-turkish.txt
    rm -rf $MAINDIR/fanboy-turkish.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-turkish.txt.gz $MAINDIR/fanboy-turkish.txt > /dev/null
    mail -s "fanboy-turkish.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# JAPANESE (12275 2011-04-23)
#
FILENAME=/var/www/adblock/fanboy-japanese.txt

if ((SIZE<10000)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/firefox-regional/fanboy-adblocklist-jpn.txt -P $TESTDIR --output-document=$TESTDIR/fanboy-japanese.txt
    cp -f $TESTDIR/fanboy-japanese.txt $MAINDIR/fanboy-japanese.txt
    rm -rf $MAINDIR/fanboy-japanese.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-japanese.txt.gz $MAINDIR/fanboy-japanese.txt > /dev/null
    mail -s "fanboy-japanese.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# KOREAN (55463 2011-04-22)
#
FILENAME=/var/www/adblock/fanboy-korean.txt

if ((SIZE<50000)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/firefox-regional/fanboy-adblocklist-krn.txt -P $TESTDIR --output-document=$TESTDIR/fanboy-korean.txt
    cp -f $TESTDIR/fanboy-korean.txt $MAINDIR/fanboy-korean.txt
    rm -rf $MAINDIR/fanboy-korean.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-korean.txt.gz $MAINDIR/fanboy-korean.txt > /dev/null
    mail -s "fanboy-korean.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# ITALIAN (27832 2011-04-22)
#
FILENAME=/var/www/adblock/fanboy-italian.txt

if ((SIZE<50000)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/firefox-regional/fanboy-adblocklist-ita.txt -P $TESTDIR --output-document=$TESTDIR/fanboy-italian.txt
    cp -f $TESTDIR/fanboy-italian.txt $MAINDIR/fanboy-italian.txt
    rm -rf $MAINDIR/fanboy-italian.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-italian.txt.gz $MAINDIR/fanboy-italian.txt > /dev/null
    mail -s "fanboy-italian.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# POLISH (7746 2011-04-22)
#
FILENAME=/var/www/adblock/fanboy-polish.txt

if ((SIZE<6800)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/firefox-regional/fanboy-adblocklist-pol.txt -P $TESTDIR --output-document=$TESTDIR/fanboy-polish.txt
    cp -f $TESTDIR/fanboy-polish.txt $MAINDIR/fanboy-polish.txt
    rm -rf $MAINDIR/fanboy-polish.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-polish.txt.gz $MAINDIR/fanboy-polish.txt > /dev/null
    mail -s "fanboy-polish.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# INDIAN (12017 2011-05-07)
#
FILENAME=/var/www/adblock/fanboy-indian.txt

if ((SIZE<10000)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/firefox-regional/fanboy-adblocklist-ind.txt -P $TESTDIR --output-document=$TESTDIR/fanboy-indian.txt
    cp -f $TESTDIR/fanboy-indian.txt $MAINDIR/fanboy-indian.txt
    rm -rf $MAINDIR/fanboy-indian.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-indian.txt.gz $MAINDIR/fanboy-indian.txt > /dev/null
    mail -s "fanboy-indian.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# VIETNAM (7475 2011-04-28)
#
FILENAME=/var/www/adblock/fanboy-vietnam.txt

if ((SIZE<6800)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/firefox-regional/fanboy-adblocklist-vtn.txt -P $TESTDIR --output-document=$TESTDIR/fanboy-vietnam.txt
    cp -f $TESTDIR/fanboy-vietnam.txt $MAINDIR/fanboy-vietnam.txt
    rm -rf $MAINDIR/fanboy-vietnam.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-vietnam.txt.gz $MAINDIR/fanboy-vietnam.txt > /dev/null
    mail -s "fanboy-vietnam.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# CHINESE (11281 2011-04-23)
#
FILENAME=/var/www/adblock/fanboy-chinese.txt

if ((SIZE<9800)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/firefox-regional/fanboy-adblocklist-chn.txt -P $TESTDIR --output-document=$TESTDIR/fanboy-chinese.txt
    cp -f $TESTDIR/fanboy-chinese.txt $MAINDIR/fanboy-chinese.txt
    rm -rf $MAINDIR/fanboy-chinese.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-chinese.txt.gz $MAINDIR/fanboy-chinese.txt > /dev/null
    mail -s "fanboy-chinese.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# ESPANOL (31227 2011-05-05)
#
FILENAME=/var/www/adblock/fanboy-espanol.txt

if ((SIZE<27000)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/firefox-regional/fanboy-adblocklist-esp.txt -P $TESTDIR --output-document=$TESTDIR/fanboy-espanol.txt
    cp -f $TESTDIR/fanboy-espanol.txt $MAINDIR/fanboy-espanol.txt
    rm -rf $MAINDIR/fanboy-espanol.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-espanol.txt.gz $MAINDIR/fanboy-espanol.txt > /dev/null
    mail -s "fanboy-espanol.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# SWEDISH (4579 2011-04-06)
#
FILENAME=/var/www/adblock/fanboy-espanol.txt

if ((SIZE<27000)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/firefox-regional/fanboy-adblocklist-swe.txt -P $TESTDIR --output-document=$TESTDIR/fanboy-swedish.txt
    cp -f $TESTDIR/fanboy-swedish.txt $MAINDIR/fanboy-swedish.txt
    rm -rf $MAINDIR/fanboy-swedish.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-swedish.txt.gz $MAINDIR/fanboy-swedish.txt > /dev/null
    mail -s "fanboy-swedish.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# Gannett (36548 2011-04-06)
#
FILENAME=/var/www/adblock/adblock-gannett.txt

if ((SIZE<27000)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd https://fanboy-adblock-list.googlecode.com/hg/adblock-gannett.txt -P $TESTDIR --output-document=$TESTDIR/adblock-gannett.txt
    cp -f $TESTDIR/adblock-gannett.txt $MAINDIR/adblock-gannett.txt
    rm -rf $MAINDIR/adblock-gannett.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/adblock-gannett.txt.gz $MAINDIR/adblock-gannett.txt > /dev/null
    mail -s "adblock-gannett.txt was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi

# Opera - urlfilter.ini (88761 2011-05-07)
#
if ((SIZE<80000)); then 
    echo "Filesize is incorrect..." > /dev/null
    wget -e robots=off -c --no-check-certificate -q --no-cache --no-cookies --referer="http://www.google.com" -c -m -nd http://fanboy-adblock-list.googlecode.com/hg/opera/urlfilter.ini -P $TESTDIR --output-document=$TESTDIR/urlfilter.ini
    cp -f $TESTDIR/urlfilter.ini $MAINDIR/opera/urlfilter.ini
    rm -rf $MAINDIR/opera/urlfilter.ini.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/urlfilter.ini.gz $MAINDIR/opera/urlfilter.ini > /dev/null
    mail -s "urlfilter.ini was smaller than expected, please fix." mp3geek@gmail.com < /dev/null
else 
    echo "Filesize is correct..." &> /dev/null
fi