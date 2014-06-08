#!/bin/bash
hg pull -u
# Firefox Regional lists
perl docs/Sorting/sorter2.pl fanboy-antifacebook.txt firefox-regional/fanboy-adblocklist-cz.txt firefox-regional/fanboy-adblocklist-esp.txt firefox-regional/fanboy-adblocklist-ind.txt firefox-regional/fanboy-adblocklist-ita.txt firefox-regional/fanboy-adblocklist-jpn.txt firefox-regional/fanboy-adblocklist-krn.txt firefox-regional/fanboy-adblocklist-pol.txt firefox-regional/fanboy-adblocklist-rus-v2.txt firefox-regional/fanboy-adblocklist-swe.txt firefox-regional/fanboy-adblocklist-tky.txt firefox-regional/fanboy-adblocklist-vtn.txt
# Opera
perl scripts/addChecksum-opera.pl opera/urlfilter.ini
# Checksums for regionals and others
perl scripts/addChecksum.pl fanboy-antifacebook.txt enhancedstats-addon.txt other/tracking-intl.txt firefox-regional/fanboy-adblocklist-cz.txt firefox-regional/fanboy-adblocklist-esp.txt firefox-regional/fanboy-adblocklist-ita.txt firefox-regional/fanboy-adblocklist-jpn.txt firefox-regional/fanboy-adblocklist-krn.txt firefox-regional/fanboy-adblocklist-swe.txt firefox-regional/fanboy-adblocklist-tky.txt firefox-regional/fanboy-adblocklist-vtn.txt firefox-regional/fanboy-adblocklist-ind.txt firefox-regional/fanboy-adblocklist-pol.txt
# Commit
hg commit -m "$1"
hg push
