#!/bin/bash
#
# Checksum v2
# Prerequisites: Webserver (nginx)
#
# 30 * * * * /etc/crons/checksum-check.sh
#
# Where its downloaded first.
export TEMPDIR="/root/temp"

# Main WWW Site
export MAINDIR="/var/www"

# Cookie DIR
export COOKDIR="/root/temp/cookies-checksum"

# VALIDCHECKSUM CHECKS
export VALIDCHECKSUM="nice -n 19 perl /root/fanboy-adblock-list/scripts/validateChecksum.pl"

cd $COOKDIR
# zcat
cp $MAINDIR/easylist-cookie_ubo.txt.gz $MAINDIR/easylist-cookie.txt.gz $MAINDIR/fanboy-annoyance_ubo.txt.gz $MAINDIR/fanboy-cookiemonster.txt.gz $COOKDIR

zcat $COOKDIR/easylist-cookie_ubo.txt.gz > $COOKDIR/easylist-cookie_ubo.txt.gz.zcat
zcat $COOKDIR/easylist-cookie.txt.gz > $COOKDIR/easylist-cookie.txt.gz.zcat
zcat $COOKDIR/fanboy-annoyance_ubo.txt.gz > $COOKDIR/fanboy-annoyance_ubo.txt.gz.zcat
zcat $COOKDIR/fanboy-cookiemonster.txt.gz > $COOKDIR/fanboy-cookiemonster.txt.gz.zcat

$VALIDCHECKSUM $COOKDIR/easylist-cookie_ubo.txt.gz.zcat > $COOKDIR/easylist-cookie_ubo.txt.gz.zcat.chk
$VALIDCHECKSUM $COOKDIR/easylist-cookie.txt.gz.zcat > $COOKDIR/easylist-cookie.txt.gz.zcat.chk
$VALIDCHECKSUM $COOKDIR/fanboy-annoyance_ubo.txt.gz.zcat > $COOKDIR/fanboy-annoyance_ubo.txt.gz.zcat.chk
$VALIDCHECKSUM $COOKDIR/fanboy-cookiemonster.txt.gz.zcat > $COOKDIR/fanboy-cookiemonster.txt.gz.zcat.chk

files=("easylist-cookie_ubo.txt.gz.zcat.chk" "easylist-cookie.txt.gz.zcat.chk" "fanboy-annoyance_ubo.txt.gz.zcat.chk" "fanboy-cookiemonster.txt.gz.zcat.chk")

for file in "${files[@]}"; do
    if grep -q "\[Wrong checksum\]" "$file"; then
        echo "GZIP'd File '$file' contains '[Wrong checksum]'"
        . /etc/crons/easylist-cookie-mirror.sh
        
    else
        echo "GZIP'd File '$file' does not contain '[Wrong checksum]'"
    fi
done

#### Non gzip'd

$VALIDCHECKSUM $MAINDIR/easylist-cookie.txt > $COOKDIR/easylist-cookie.txt.chk
$VALIDCHECKSUM $MAINDIR/easylist-cookie_ubo.txt > $COOKDIR/easylist-cookie_ubo.txt.chk
$VALIDCHECKSUM $MAINDIR/fanboy-annoyance.txt > $COOKDIR/fanboy-annoyance.txt.chk

files=("easylist-cookie.txt.chk" "easylist-cookie_ubo.txt.chk" "fanboy-annoyance.txt.chk")

for file in "${files[@]}"; do
    if grep -q "\[Wrong checksum\]" "$file"; then
        echo "Non-GZIP'd File '$file' contains '[Wrong checksum]'"
        echo "Re-grabbinng "
        . /etc/crons/easylist-cookie-mirror.sh
        
    else
        echo "Non-GZIP'd File '$file' does not contain '[Wrong checksum]'"
    fi
done

# remove old files
rm -rf $COOKDIR/*.txt.gz $COOKDIR/*.chk $COOKDIR/*.zcat
