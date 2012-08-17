@echo off
hg pull -u
:: pre-sort
perl docs\sorting\sorter2.pl fanboy-adblocklist-current-expanded.txt fanboy-adblocklist-stats.txt fanboy-adblocklist-addon.txt enhancedstats-addon.txt
:: Firefox Regional lists
perl docs\sorting\sorter2.pl firefox-regional\fanboy-adblocklist-cz.txt firefox-regional\fanboy-adblocklist-esp.txt firefox-regional\fanboy-adblocklist-ind.txt firefox-regional\fanboy-adblocklist-ita.txt firefox-regional\fanboy-adblocklist-jpn.txt firefox-regional\fanboy-adblocklist-krn.txt firefox-regional\fanboy-adblocklist-pol.txt firefox-regional\fanboy-adblocklist-rus-v2.txt firefox-regional\fanboy-adblocklist-swe.txt firefox-regional\fanboy-adblocklist-tky.txt firefox-regional\fanboy-adblocklist-vtn.txt
:: Opera
perl docs\sorting\sorter2.pl opera\urlfilter.ini opera\urlfilter-cz.ini opera\urlfilter-esp.ini opera\urlfilter-ind.ini opera\urlfilter-jpn.ini opera\urlfilter-krn.ini opera\urlfilter-pol.ini opera\urlfilter-rus.ini opera\urlfilter-stats.ini opera\urlfilter-tky.ini opera\urlfilter-vtn.ini opera\urlfilter-swe.ini
:: IE Addon List
perl docs\sorting\sorter2.pl ie\fanboy-adblock-addon.txt ie\fanboy-tracking-addon.txt ie\fanboy-russian-addon.txt
:: Firefox
perl scripts\addChecksum.pl fanboy-adblocklist-current-expanded.txt fanboy-adblocklist-stats.txt fanboy-adblocklist-addon.txt other\adblock-gannett.txt other\chrome-addon.txt enhancedstats-addon.txt other\tracking-intl.txt
:: Firefox Regional lists
perl scripts\addChecksum.pl firefox-regional\fanboy-adblocklist-cz.txt firefox-regional\fanboy-adblocklist-esp.txt firefox-regional\fanboy-adblocklist-ita.txt firefox-regional\fanboy-adblocklist-jpn.txt firefox-regional\fanboy-adblocklist-krn.txt firefox-regional\fanboy-adblocklist-rus-v2.txt firefox-regional\fanboy-adblocklist-swe.txt firefox-regional\fanboy-adblocklist-tky.txt firefox-regional\fanboy-adblocklist-vtn.txt firefox-regional\fanboy-adblocklist-ind.txt firefox-regional\fanboy-adblocklist-pol.txt
:: Opera
perl scripts\addChecksum-opera.pl opera\urlfilter.ini
:: Internet Explorer
perl scripts\addChecksum.pl ie\fanboy-adblock-addon.txt ie\fanboy-tracking-addon.txt ie\fanboy-russian-addon.txt
:: Commit
hg commit -m "%*"
hg push