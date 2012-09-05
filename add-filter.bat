@echo off
:: Sync
:: This script needs b - Distributed Bug Tracking.
:: Note: add /b to the .hg/hgrc under "[extensions]"
:: "b = c:\Users\Username\Directory\..\b.py" (where ever the hg repo is)
:: see: http://www.digitalgemstones.com/projects/b/
hg pull -u
:: b
hg b add -e "%*"
:: pre-sort
perl docs\sorting\sorter2.pl fanboy-adblock\fanboy-adult-generic.txt fanboy-adblock\fanboy-adult-elements.txt fanboy-adblock\fanboy-adult-firstparty.txt fanboy-adblock\fanboy-adult-thirdparty.txt fanboy-adblock\fanboy-adult-whitelists.txt fanboy-adblock\fanboy-p2p-elements.txt fanboy-adblock\fanboy-p2p-firstparty.txt fanboy-adblock\fanboy-p2p-thirdparty.txt
::
perl docs\sorting\sorter2.pl fanboy-adblock\fanboy-dimensions.txt fanboy-adblock\fanboy-dimensions-whitelist.txt fanboy-adblock\fanboy-generic.txt fanboy-adblock\fanboy-popups.txt fanboy-adblock\fanboy-firstparty.txt fanboy-adblock\fanboy-thirdparty.txt fanboy-adblock\fanboy-whitelist.txt fanboy-adblock\fanboy-elements-exceptions.txt fanboy-adblock\fanboy-elements-generic.txt fanboy-adblock\fanboy-elements-specific.txt
:: Fanboy Tracking
perl docs\sorting\sorter2.pl fanboy-tracking\fanboy-tracking-generic.txt fanboy-tracking\fanboy-tracking-firstparty.txt fanboy-tracking\fanboy-tracking-thirdparty.txt fanboy-tracking\fanboy-tracking-whitelist.txt fanboy-tracking\fanboy-tracking-adult.txt fanboy-tracking\fanboy-tracking-general.txt fanboy-tracking\fanboy-tracking-nonenglish.txt
:: Fanboy Annoyances
perl docs\sorting\sorter2.pl enhancedstats-addon.txt fanboy-addon\fanboy-addon-generic.txt fanboy-addon\fanboy-addon-thirdparty.txt fanboy-addon\fanboy-addon-firstparty.txt fanboy-addon\fanboy-addon-whitelists.txt fanboy-addon\fanboy-addon-intl.txt fanboy-addon\fanboy-addon-elements.txt fanboy-addon\fanboy-addon-elements-exceptions.txt
:: Firefox Regional lists
perl docs\sorting\sorter2.pl firefox-regional\IsraelList.txt firefox-regional\fanboy-adblocklist-cz.txt firefox-regional\fanboy-adblocklist-esp.txt firefox-regional\fanboy-adblocklist-ind.txt firefox-regional\fanboy-adblocklist-ita.txt firefox-regional\fanboy-adblocklist-jpn.txt firefox-regional\fanboy-adblocklist-krn.txt firefox-regional\fanboy-adblocklist-pol.txt firefox-regional\fanboy-adblocklist-rus-v2.txt firefox-regional\fanboy-adblocklist-swe.txt firefox-regional\fanboy-adblocklist-tky.txt firefox-regional\fanboy-adblocklist-vtn.txt
:: Opera
perl docs\sorting\sorter2.pl opera\urlfilter.ini opera\urlfilter-cz.ini opera\urlfilter-esp.ini opera\urlfilter-ind.ini opera\urlfilter-jpn.ini opera\urlfilter-krn.ini opera\urlfilter-pol.ini opera\urlfilter-rus.ini opera\urlfilter-stats.ini opera\urlfilter-tky.ini opera\urlfilter-vtn.ini opera\urlfilter-swe.ini
:: IE Addon List
perl docs\sorting\sorter2.pl ie\fanboy-adblock-addon.txt ie\fanboy-tracking-addon.txt ie\fanboy-russian-addon.txt
:: Opera
perl scripts\addChecksum-opera.pl opera\urlfilter.ini
:: Checksums for regionals and others
perl scripts\addChecksum.pl other\chrome-addon.txt enhancedstats-addon.txt other\tracking-intl.txt firefox-regional\fanboy-adblocklist-cz.txt firefox-regional\fanboy-adblocklist-esp.txt firefox-regional\fanboy-adblocklist-ita.txt firefox-regional\fanboy-adblocklist-jpn.txt firefox-regional\fanboy-adblocklist-krn.txt firefox-regional\fanboy-adblocklist-rus-v2.txt firefox-regional\fanboy-adblocklist-swe.txt firefox-regional\fanboy-adblocklist-tky.txt firefox-regional\fanboy-adblocklist-vtn.txt firefox-regional\fanboy-adblocklist-ind.txt firefox-regional\fanboy-adblocklist-pol.txt firefox-regional\IsraelList.txt
:: Internet Explorer
:: perl scripts\addChecksum.pl ie\fanboy-adblock-addon.txt ie\fanboy-tracking-addon.txt ie\fanboy-russian-addon.txt
:: Commit
hg commit -m "%*"
hg push