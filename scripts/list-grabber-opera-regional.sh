#!/bin/bash
#
# Fanboy Adblock list grabber Opera (regional) script v1.0 (30/08/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Version history
#
# 1.9  Re-implement the iron list generator
# 1.8  Allow list to be stored in ramdisk

# Variables for directorys
#

export ZIP="nice -n 19 /usr/local/bin/7za a -mx=9 -y -tgzip"
export NICE="nice -n 19"
export TAC="/usr/bin/tac"
export CAT="/bin/cat"
export MAINDIR="/tmp/Ramdisk/www/adblock"
export SPLITDIR="/tmp/Ramdisk/www/adblock/split/test"
export HGSERV="/tmp/hgstuff/fanboy-adblock-list"
export TESTDIR="/tmp/work"
export DATE="`date`"
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum-opera.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export IEDIR="/tmp/ieramdisk"
export TWIDGE="/usr/bin/twidge update"
export SUBS="/tmp/ieramdisk/subscriptions"
export IRONDIR="/tmp/Ramdisk/www/adblock/iron"

# Check mirror dir exists and its not a symlink
#
if [ -d "/var/hgstuff/fanboy-adblock-list" ] && [ -h "/tmp/hgstuff" ]; then
    export HGSERV="/var/hgstuff/fanboy-adblock-list"
  else
    # If not, its stored here
    export HGSERV="/tmp/hgstuff/fanboy-adblock-list"
fi


if diff $HGSERV/opera/urlfilter-cz.ini $MAINDIR/opera/urlfilter-cz.ini > /dev/null ; then
     echo "No Changes detected: czech/urlfilter.ini" > /dev/null
  else
    cp -f $HGSERV/opera/urlfilter-cz.ini $MAINDIR/opera/urlfilter-cz.ini
    cat $MAINDIR/opera/complete/urlfilter.ini $MAINDIR/opera/urlfilter-cz.ini > $TESTDIR/opera/urlfilter-cz-stats2.ini
    cat $MAINDIR/opera/urlfilter.ini $MAINDIR/opera/urlfilter-cz.ini > $TESTDIR/opera/urlfilter-cz2.ini
    # remove spaces
    sed '/^$/d'  $TESTDIR/opera/urlfilter-cz2.ini >  $TESTDIR/opera/urlfilter-cz.ini
    sed '/^$/d'  $TESTDIR/opera/urlfilter-cz-stats2.ini >  $TESTDIR/opera/urlfilter-cz-stats.ini
    # Addchecksum
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-cz.ini
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-cz-stats.ini
    # Gzip
    rm -rf $MAINDIR/opera/cz/complete/urlfilter.ini.gz $MAINDIR/opera/cz/urlfilter.ini.gz
    $ZIP $MAINDIR/opera/cz/complete/urlfilter.ini.gz $TESTDIR/opera/urlfilter-cz-stats.ini > /dev/null
    $ZIP $MAINDIR/opera/cz/urlfilter.ini.gz $TESTDIR/opera/urlfilter-cz.ini > /dev/null
    # Generate Iron script
    $HGSERV/scripts/iron/czech-iron-generator.sh
fi


if diff $HGSERV/opera/urlfilter-pol.ini $MAINDIR/opera/urlfilter-pol.ini > /dev/null ; then
     echo "No Changes detected: Polish/urlfilter.ini" > /dev/null
  else
    cp -f $HGSERV/opera/urlfilter-pol.ini $MAINDIR/opera/urlfilter-pol.ini
    cat $MAINDIR/opera/complete/urlfilter.ini $MAINDIR/opera/urlfilter-pol.ini > $TESTDIR/opera/urlfilter-pol-stats2.ini
    cat $MAINDIR/opera/urlfilter.ini $MAINDIR/opera/urlfilter-pol.ini > $TESTDIR/opera/urlfilter-pol2.ini
    # remove spaces
    sed '/^$/d'  $TESTDIR/opera/urlfilter-pol2.ini >  $TESTDIR/opera/urlfilter-pol.ini
    sed '/^$/d'  $TESTDIR/opera/urlfilter-pol-stats2.ini >  $TESTDIR/opera/urlfilter-pol-stats.ini
    # Addchecksum
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-pol.ini
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-pol-stats.ini
    # Gzip
    rm -rf $MAINDIR/opera/pol/complete/urlfilter.ini.gz $MAINDIR/opera/pol/urlfilter.ini.gz
    $ZIP $MAINDIR/opera/pol/complete/urlfilter.ini.gz $TESTDIR/opera/urlfilter-pol-stats.ini > /dev/null
    $ZIP $MAINDIR/opera/pol/urlfilter.ini.gz $TESTDIR/opera/urlfilter-pol.ini > /dev/null
fi


if diff $HGSERV/opera/urlfilter-esp.ini $MAINDIR/opera/urlfilter-esp.ini > /dev/null ; then
     echo "No Changes detected: Espanol/urlfilter.ini" > /dev/null
  else
    cp -f $HGSERV/opera/urlfilter-esp.ini $MAINDIR/opera/urlfilter-esp.ini
    cat $MAINDIR/opera/complete/urlfilter.ini $MAINDIR/opera/urlfilter-esp.ini > $TESTDIR/opera/urlfilter-esp-stats2.ini
    cat $MAINDIR/opera/urlfilter.ini $MAINDIR/opera/urlfilter-esp.ini > $TESTDIR/opera/urlfilter-esp2.ini
    # remove spaces
    sed '/^$/d'  $TESTDIR/opera/urlfilter-esp2.ini >  $TESTDIR/opera/urlfilter-esp.ini
    sed '/^$/d'  $TESTDIR/opera/urlfilter-esp-stats2.ini >  $TESTDIR/opera/urlfilter-esp-stats.ini
    # Addchecksum
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-esp.ini
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-esp-stats.ini
    # Gzip
    rm -rf $MAINDIR/opera/esp/complete/urlfilter.ini.gz $MAINDIR/opera/esp/urlfilter.ini.gz
    $ZIP $MAINDIR/opera/esp/complete/urlfilter.ini.gz $TESTDIR/opera/urlfilter-esp-stats.ini > /dev/null
    $ZIP $MAINDIR/opera/esp/urlfilter.ini.gz $TESTDIR/opera/urlfilter-esp.ini > /dev/null
    # Generate Iron script
    $HGSERV/scripts/iron/espanol-iron-generator.sh
fi

if diff $HGSERV/opera/urlfilter-rus.ini $MAINDIR/opera/urlfilter-rus.ini > /dev/null ; then
     echo "No Changes detected: Russian/urlfilter.ini" > /dev/null
  else
    cp -f $HGSERV/opera/urlfilter-rus.ini $MAINDIR/opera/urlfilter-rus.ini
    cat $MAINDIR/opera/complete/urlfilter.ini $MAINDIR/opera/urlfilter-rus.ini > $TESTDIR/opera/urlfilter-rus-stats2.ini
    cat $MAINDIR/opera/urlfilter.ini $MAINDIR/opera/urlfilter-rus.ini > $TESTDIR/opera/urlfilter-rus2.ini
    # remove spaces
    sed '/^$/d'  $TESTDIR/opera/urlfilter-rus2.ini >  $TESTDIR/opera/urlfilter-rus.ini
    sed '/^$/d'  $TESTDIR/opera/urlfilter-rus-stats2.ini >  $TESTDIR/opera/urlfilter-rus-stats.ini
    # Addchecksum
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-rus.ini
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-rus-stats.ini
    # Gzip
    rm -rf $MAINDIR/opera/rus/complete/urlfilter.ini.gz $MAINDIR/opera/rus/urlfilter.ini.gz
    $ZIP $MAINDIR/opera/rus/complete/urlfilter.ini.gz $TESTDIR/opera/urlfilter-rus-stats.ini > /dev/null
    $ZIP $MAINDIR/opera/rus/urlfilter.ini.gz $TESTDIR/opera/urlfilter-rus.ini > /dev/null
    # Generate Iron script
    $HGSERV/scripts/iron/russian-iron-generator.sh
fi

if diff $HGSERV/opera/urlfilter-swe.ini $MAINDIR/opera/urlfilter-swe.ini > /dev/null ; then
     echo "No Changes detected: Swedish/urlfilter.ini" > /dev/null
  else
    cp -f $HGSERV/opera/urlfilter-swe.ini $MAINDIR/opera/urlfilter-swe.ini
    cat $MAINDIR/opera/complete/urlfilter.ini $MAINDIR/opera/urlfilter-swe.ini > $TESTDIR/opera/urlfilter-swe-stats2.ini
    cat $MAINDIR/opera/urlfilter.ini $MAINDIR/opera/urlfilter-swe.ini > $TESTDIR/opera/urlfilter-swe2.ini
    # remove spaces
    sed '/^$/d'  $TESTDIR/opera/urlfilter-swe2.ini >  $TESTDIR/opera/urlfilter-swe.ini
    sed '/^$/d'  $TESTDIR/opera/urlfilter-swe-stats2.ini >  $TESTDIR/opera/urlfilter-swe-stats.ini
    # Addchecksum
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-swe.ini
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-swe-stats.ini
    # Gzip
    rm -rf $MAINDIR/opera/swe/complete/urlfilter.ini.gz $MAINDIR/opera/swe/urlfilter.ini.gz
    $ZIP $MAINDIR/opera/swe/complete/urlfilter.ini.gz $TESTDIR/opera/urlfilter-swe-stats.ini > /dev/null
    $ZIP $MAINDIR/opera/swe/urlfilter.ini.gz $TESTDIR/opera/urlfilter-swe.ini > /dev/null
fi

if diff $HGSERV/opera/urlfilter-jpn.ini $MAINDIR/opera/urlfilter-jpn.ini > /dev/null ; then
     echo "No Changes detected: Japanese/urlfilter.ini" > /dev/null
  else
    cp -f $HGSERV/opera/urlfilter-jpn.ini $MAINDIR/opera/urlfilter-jpn.ini
    cat $MAINDIR/opera/complete/urlfilter.ini $MAINDIR/opera/urlfilter-jpn.ini > $TESTDIR/opera/urlfilter-jpn-stats2.ini
    cat $MAINDIR/opera/urlfilter.ini $MAINDIR/opera/urlfilter-jpn.ini > $TESTDIR/opera/urlfilter-jpn2.ini
    # remove spaces
    sed '/^$/d'  $TESTDIR/opera/urlfilter-jpn2.ini >  $TESTDIR/opera/urlfilter-jpn.ini
    sed '/^$/d'  $TESTDIR/opera/urlfilter-jpn-stats2.ini >  $TESTDIR/opera/urlfilter-jpn-stats.ini
    # Addchecksum
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-jpn.ini
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-jpn-stats.ini
    # Gzip
    rm -rf $MAINDIR/opera/jpn/complete/urlfilter.ini.gz $MAINDIR/opera/jpn/urlfilter.ini.gz
    $ZIP $MAINDIR/opera/jpn/complete/urlfilter.ini.gz $TESTDIR/opera/urlfilter-jpn-stats.ini > /dev/null
    $ZIP $MAINDIR/opera/jpn/urlfilter.ini.gz $TESTDIR/opera/urlfilter-jpn.ini > /dev/null
    # Generate Iron script
    $HGSERV/scripts/iron/japanese-iron-generator.sh
fi

if diff $HGSERV/opera/urlfilter-vtn.ini $MAINDIR/opera/urlfilter-vtn.ini > /dev/null ; then
     echo "No Changes detected: Vietnamese/urlfilter.ini" > /dev/null
  else
    cp -f $HGSERV/opera/urlfilter-vtn.ini $MAINDIR/opera/urlfilter-vtn.ini
    cat $MAINDIR/opera/complete/urlfilter.ini $MAINDIR/opera/urlfilter-vtn.ini > $TESTDIR/opera/urlfilter-vtn-stats2.ini
    cat $MAINDIR/opera/urlfilter.ini $MAINDIR/opera/urlfilter-vtn.ini > $TESTDIR/opera/urlfilter-vtn2.ini
    # remove spaces
    sed '/^$/d'  $TESTDIR/opera/urlfilter-vtn2.ini >  $TESTDIR/opera/urlfilter-vtn.ini
    sed '/^$/d'  $TESTDIR/opera/urlfilter-vtn-stats2.ini >  $TESTDIR/opera/urlfilter-vtn-stats.ini
    # Addchecksum
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-vtn.ini
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-vtn-stats.ini
    # Gzip
    rm -rf $MAINDIR/opera/vtn/complete/urlfilter.ini.gz $MAINDIR/opera/vtn/urlfilter.ini.gz
    $ZIP $MAINDIR/opera/vtn/complete/urlfilter.ini.gz $TESTDIR/opera/urlfilter-vtn-stats.ini > /dev/null
    $ZIP $MAINDIR/opera/vtn/urlfilter.ini.gz $TESTDIR/opera/urlfilter-vtn.ini > /dev/null
fi

if diff $HGSERV/opera/urlfilter-tky.ini $MAINDIR/opera/urlfilter-tky.ini > /dev/null ; then
     echo "No Changes detected: Turkey/urlfilter.ini" > /dev/null
  else
    cp -f $HGSERV/opera/urlfilter-tky.ini $MAINDIR/opera/urlfilter-tky.ini
    cat $MAINDIR/opera/complete/urlfilter.ini $MAINDIR/opera/urlfilter-tky.ini > $TESTDIR/opera/urlfilter-tky-stats2.ini
    cat $MAINDIR/opera/urlfilter.ini $MAINDIR/opera/urlfilter-tky.ini > $TESTDIR/opera/urlfilter-tky2.ini
    # remove spaces
    sed '/^$/d'  $TESTDIR/opera/urlfilter-tky2.ini >  $TESTDIR/opera/urlfilter-tky.ini
    sed '/^$/d'  $TESTDIR/opera/urlfilter-tky-stats2.ini >  $TESTDIR/opera/urlfilter-tky-stats.ini
    # Addchecksum
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-tky.ini
    $ADDCHECKSUM $TESTDIR/opera/urlfilter-tky-stats.ini
    # Gzip
    rm -rf $MAINDIR/opera/trky/complete/urlfilter.ini.gz $MAINDIR/opera/trky/urlfilter.ini.gz
    $ZIP $MAINDIR/opera/trky/complete/urlfilter.ini.gz $TESTDIR/opera/urlfilter-tky-stats.ini > /dev/null
    $ZIP $MAINDIR/opera/trky/urlfilter.ini.gz $TESTDIR/opera/urlfilter-tky.ini > /dev/null
fi
