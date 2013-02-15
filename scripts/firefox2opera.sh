#!/bin/bash
#
# Fanboy Adblock list Firefox-Opera bash script v2.0 (09/11/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Version history
#
# 3.1 Minor bug
# 3.0 Re-write script, cleaner and better, removed lots of cruft.

# Variables for directorys
#
export ZIP="nice -n 19 /usr/local/bin/7za a -mx=9 -y -tgzip"
export NICE="nice -n 19"
export TAC="/usr/bin/tac"
export CAT="/bin/cat"
export MAINDIR="/var/www/adblock"
export SPLITDIR="/var/www/adblock/split/test"
export HGSERV="/root/fanboy-adblock-list"
export TESTDIR="/tmp/work"
export DATE="`date`"
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export TWIDGE="/usr/bin/twidge update"
export IEDIR="/var/test/tmp/work/ie"
export IESUBS="/var/test/ie/subscriptions"
export IRONDIR="/var/www/adblock/iron"
export EASYLIST="/root/easylist/easylist/easylistfanboy/fanboy-adblock"

# Check mirror dir exists and its not a symlink
#
if [ -d "/var/hgstuff/fanboy-adblock-list" ] && [ -h "/tmp/hgstuff" ]; then
    export HGSERV="/var/hgstuff/fanboy-adblock-list"
    echo "HGSERV=/var/hgstuff/fanboy-adblock-list"
    cd /tmp/hgstuff/fanboy-adblock-list
    $NICE $HG pull
    $NICE $HG update
  else
    # If not, its stored here
    export HGSERV="/tmp/hgstuff/fanboy-adblock-list"
    echo "HGSERV=/tmp/hgstuff/fanboy-adblock-list"
    cd /tmp/hgstuff/fanboy-adblock-list
    $NICE $HG pull
    $NICE $HG update
fi

# Check that the www server is up before proceding
#
if [ -d "/tmp/Ramdisk/www/adblock" ]; then

  # Fanboy-Adblock
  #
  $NICE $PERL $HGSERV/scripts/createOperaFilters_new.pl $MAINDIR/fanboy-adblock.txt --urlfilter $MAINDIR/opera/urlfilter-adblock.bak --nocomments --everythingisfirstparty --nocss --ignorewhitelist
  $NICE $PERL $HGSERV/scripts/createOperaFilters_new.pl $HGSERV/fanboy-adblock/fanboy-opera-specific.txt --urlfilter $MAINDIR/opera/urlfilter-specific.bak --nocomments --everythingisfirstparty --nocss --ignorewhitelist
  # Fanboy-Tracking
  #
  $NICE $PERL $HGSERV/scripts/createOperaFilters_new.pl $MAINDIR/fanboy-tracking.txt --urlfilter $MAINDIR/opera/urlfilter-tracking.bak --nocomments --everythingisfirstparty --nocss --ignorewhitelist

  # Because Tracking list is merged with Adblock, remove the top 5 lines
  #
  sed -i -e '1,5d' $MAINDIR/opera/urlfilter-tracking.bak
  sed -i -e '1,5d' $MAINDIR/opera/urlfilter-specific.bak

  # Remove Bad opera filters
  #
  sed -i -e '/\/adsWrapper\./d' $MAINDIR/opera/urlfilter-adblock.bak
  # http://forums.fanboy.co.nz/forums/viewtopic.php?f=5&t=15558
  sed -i -e '/eloqua.com/d' $MAINDIR/opera/urlfilter-tracking.bak
  # http://forums.fanboy.co.nz/forums/viewtopic.php?f=8&p=40974
  sed -i -e '/analytics_prod./d' $MAINDIR/opera/urlfilter-tracking.bak
  sed -i -e '/wikia-beacon.com/d' $MAINDIR/opera/urlfilter-tracking.bak
  # http://forums.fanboy.co.nz/forums/viewtopic.php?f=6&t=7043
  sed -i -e '/webtrends.com/d' $MAINDIR/opera/urlfilter-tracking.bak
  # http://forums.fanboy.co.nz/forums/viewtopic.php?f=8&t=15669
  sed -i -e '/.php?zoneid=/d' $MAINDIR/opera/urlfilter-adblock.bak
  # http://forums.fanboy.co.nz/forums/viewtopic.php?f=8&t=15567
  sed -i -e '/viglink.com/d' $MAINDIR/opera/urlfilter-adblock.bak
  # http://forums.fanboy.co.nz/forums/viewtopic.php?f=8&t=6840
  sed -i -e '/comscore.com/d' $MAINDIR/opera/urlfilter-tracking.bak
  # http://forums.fanboy.co.nz/forums/viewtopic.php?f=8&t=15711
  sed -i -e '/\/logging.js/d' $MAINDIR/opera/urlfilter-tracking.bak
  # http://forums.fanboy.co.nz/forums/viewtopic.php?f=8&t=15697
  sed -i -e '/yumenetworks.com/d' $MAINDIR/opera/urlfilter-adblock.bak
  # http://forums.fanboy.co.nz/forums/viewtopic.php?f=8&t=9849
  sed -i -e '/linksynergy.com/d' $MAINDIR/opera/urlfilter-adblock.bak
  # Problematic filter
  sed -i -e '/scorecardresearch.com/d' $MAINDIR/opera/urlfilter-adblock.bak
  # http://forums.fanboy.co.nz/forums/viewtopic.php?f=8&t=16666
  sed -i -e '/.com\/ads-/d' $MAINDIR/opera/urlfilter-adblock.bak
  # http://forums.fanboy.co.nz/forums/viewtopic.php?f=8&t=9849&start=10
  sed -i -e '/tkqlhce.com/d' $MAINDIR/opera/urlfilter-adblock.bak
  sed -i -e '/anrdoezrs.net/d' $MAINDIR/opera/urlfilter-adblock.bak
  sed -i -e '/jdoqocy.com/d' $MAINDIR/opera/urlfilter-adblock.bak
  sed -i -e '/apmebf.com/d' $MAINDIR/opera/urlfilter-adblock.bak
  sed -i -e '/kqzyfj.com/d' $MAINDIR/opera/urlfilter-adblock.bak
  sed -i -e '/dpbolvw.net/d' $MAINDIR/opera/urlfilter-adblock.bak
  sed -i -e '/apmebf.com/d' $MAINDIR/opera/urlfilter-adblock.bak
  sed -i -e '/rover.ebay.com/d' $MAINDIR/opera/urlfilter-tracking.bak
  sed -i -e '/amazon.com\/gp\/\*&linkCode/d' $MAINDIR/opera/urlfilter-tracking.bak
  sed -i -e '/emjcd.com/d' $MAINDIR/opera/urlfilter-tracking.bak
  # http://forums.fanboy.co.nz/forums/viewtopic.php?f=6&t=15969&p=41651
  sed -i -e '/googletagservices.com/d' $MAINDIR/opera/urlfilter-adblock.bak
  # http://forums.fanboy.co.nz/forums/viewtopic.php?f=8&t=15843
  sed -i -e '/\*\/advertising\/\*/d' $MAINDIR/opera/urlfilter-adblock.bak
  # http://forums.fanboy.co.nz/forums/viewtopic.php?f=8&t=6885
  sed -i -e '/chitika.com/d' $MAINDIR/opera/urlfilter-adblock.bak
  # https://hg.fanboy.co.nz/rev/1480009e909c
  sed -i -e '/\*:\/\/ads.\*/d' $MAINDIR/opera/urlfilter-adblock.bak
  # http://forums.fanboy.co.nz/forums/viewtopic.php?f=8&t=16117
  sed -i -e '/\/analytics_prod./d' $MAINDIR/opera/urlfilter-tracking.bak

  # Include Opera urlfilter header file
  #
  $CAT $HGSERV/opera/urlfilter-header.txt $MAINDIR/opera/urlfilter-adblock.bak $MAINDIR/opera/urlfilter-specific.bak > $MAINDIR/opera/urlfilter-adblock.bak2
  # Adblock+Tracking
  $CAT $HGSERV/opera/urlfilter-header.txt $MAINDIR/opera/urlfilter-adblock.bak $MAINDIR/opera/urlfilter-tracking.bak  $MAINDIR/opera/urlfilter-specific.bak > $MAINDIR/opera/urlfilter-tracking.bak2

  # Remove empty lines
  #
  sed -i -e '/^$/d' $MAINDIR/opera/urlfilter-adblock.bak2
  sed -i -e '/^$/d' $MAINDIR/opera/urlfilter-tracking.bak2

  # Checksums
  #
  $PERL $HGSERV/scripts/addChecksum-opera.pl $MAINDIR/opera/urlfilter-adblock.bak2
  $PERL $HGSERV/scripts/addChecksum-opera.pl $MAINDIR/opera/urlfilter-tracking.bak2

  # GZIP
  #
  cp -f $MAINDIR/opera/urlfilter-adblock.bak2 $MAINDIR/opera/urlfilter.ini
  cp -f $MAINDIR/opera/urlfilter-tracking.bak2 $MAINDIR/opera/complete/urlfilter.ini

  # Clear old files first
  #
  rm -rf $MAINDIR/opera/urlfilter.ini.gz $MAINDIR/opera/complete/urlfilter.ini.gz

  $ZIP $MAINDIR/opera/urlfilter.ini.gz $MAINDIR/opera/urlfilter-adblock.bak2 > /dev/null
  $ZIP $MAINDIR/opera/complete/urlfilter.ini.gz $MAINDIR/opera/urlfilter-tracking.bak2 > /dev/null

  # Remove Backup files
  #
  rm -rf $MAINDIR/opera/urlfilter-tracking.bak* $MAINDIR/opera/urlfilter-adblock.bak* $MAINDIR/opera/urlfilter-specific.bak*

fi


