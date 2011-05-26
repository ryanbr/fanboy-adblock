  #!/bin/bash
#
# Fanboy Dimensions Adblock list grabber script v1.0 (26/05/2011)
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

# Variables for directorys
#
MAINDIR="/var/www/adblock"
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list"
TESTDIR="/tmp/ramdisk"
ZIP="/usr/local/bin/7za"

# Remove Temp files
#
rm -f $TESTDIR/dim*.txt
rm -f $TESTDIR/fanboy-adblocklist-current-expanded.txt

cp -f $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $TESTDIR/fanboy-adblocklist-current-expanded.txt
      
# Seperage off CSS elements for Opera CSS
sed -n '/Generic Hiding Rules/,/Common Element Rules/{/Common Element Rules/!p}' $TESTDIR/fanboy-adblocklist-current-expanded.txt > $TESTDIR/fanboy-css.txt

# remove the top 3 lines
sed '1,2d' $TESTDIR/fanboy-css.txt > $TESTDIR/fanboy-css0.txt

# remove bottom line
sed -e '$d' $TESTDIR/fanboy-css0.txt  > $TESTDIR/fanboy-css.txt

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
# sed -i '/.ad-vertical-container/d' $TESTDIR/fanboy-css.txt

perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-css.txt
# Compare the Dimensions on the website vs mercurial copy
#
if diff $TESTDIR/fanboy-css.txt $MAINDIR/opera/fanboy-adblocklist-elements-v4.css >/dev/null ; then
   echo "No Changes detected: fanboy-adblocklist-elements-v4.css"
 else
   cp -f $TESTDIR/fanboy-css.txt $MAINDIR/opera/fanboy-adblocklist-elements-v4.css
   rm -f $MAINDIR/opera/fanboy-adblocklist-elements-v4.css.gz
   $ZIP a -mx=9 -y -tgzip $MAINDIR/opera/fanboy-adblocklist-elements-v4.css.gz $MAINDIR/opera/fanboy-adblocklist-elements-v4.css > /dev/null
fi