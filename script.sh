#!/bin/bash
hg pull -u
# Firefox
perl scripts/addChecksum.pl fanboy-adblocklist-current-expanded.txt
perl scripts/addChecksum.pl fanboy-adblocklist-stats.txt  
perl scripts/addChecksum.pl fanboy-adblocklist-addon.txt
perl scripts/addChecksum.pl enhancedstats-addon.txt
perl scripts/addChecksum.pl adblock-gannett.txt
perl scripts/addChecksum.pl other/chrome-addon.txt
perl scripts/addChecksum.pl other/tracking-intl.txt
# Firefox Regional lists
perl scripts/addChecksum.pl firefox-regional/fanboy-adblocklist-chn.txt
perl scripts/addChecksum.pl firefox-regional/fanboy-adblocklist-cz.txt
perl scripts/addChecksum.pl firefox-regional/fanboy-adblocklist-esp.txt
perl scripts/addChecksum.pl firefox-regional/fanboy-adblocklist-jpn.txt
perl scripts/addChecksum.pl firefox-regional/fanboy-adblocklist-krn.txt
perl scripts/addChecksum.pl firefox-regional/fanboy-adblocklist-rus-v2.txt
perl scripts/addChecksum.pl firefox-regional/fanboy-adblocklist-swe.txt
perl scripts/addChecksum.pl firefox-regional/fanboy-adblocklist-tky.txt
perl scripts/addChecksum.pl firefox-regional/fanboy-adblocklist-ita.txt
perl scripts/addChecksum.pl firefox-regional/fanboy-adblocklist-vtn.txt
perl scripts/addChecksum.pl firefox-regional/fanboy-adblocklist-ind.txt
perl scripts/addChecksum.pl firefox-regional/fanboy-adblocklist-pol.txt
# Opera
perl scripts/addChecksum-opera.pl opera/urlfilter.ini
perl scripts/addChecksum.pl opera/fanboy-adblocklist-elements-v3.css
# Now sync
hg commit -m "$1"
hg push
