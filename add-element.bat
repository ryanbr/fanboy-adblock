@echo off
echo %time%
hg pull -u
echo %time%
:: pre-sort
perl docs\sorting\sorter2.pl fanboy-adblock\fanboy-adult-generic.txt fanboy-adblock\fanboy-adult-elements.txt fanboy-adblock\fanboy-adult-firstparty.txt fanboy-adblock\fanboy-adult-thirdparty.txt fanboy-adblock\fanboy-adult-whitelists.txt fanboy-adblock\fanboy-p2p-elements.txt fanboy-adblock\fanboy-p2p-firstparty.txt fanboy-adblock\fanboy-p2p-thirdparty.txt
echo %time%
::
perl docs\sorting\sorter2.pl fanboy-adblock\fanboy-dimensions.txt fanboy-adblock\fanboy-dimensions-whitelist.txt fanboy-adblock\fanboy-generic.txt fanboy-adblock\fanboy-popups.txt fanboy-adblock\fanboy-firstparty.txt fanboy-adblock\fanboy-thirdparty.txt fanboy-adblock\fanboy-whitelist.txt fanboy-adblock\fanboy-elements-exceptions.txt fanboy-adblock\fanboy-elements-generic.txt fanboy-adblock\fanboy-elements-specific.txt
echo %time%
::
perl docs\sorting\sorter2.pl fanboy-adblocklist-stats.txt fanboy-adblocklist-addon.txt enhancedstats-addon.txt other\adblock-gannett.txt
echo %time%
:: Firefox Regional lists
perl docs\sorting\sorter2.pl firefox-regional\IsraelList.txt firefox-regional\fanboy-adblocklist-cz.txt firefox-regional\fanboy-adblocklist-esp.txt firefox-regional\fanboy-adblocklist-ind.txt firefox-regional\fanboy-adblocklist-ita.txt firefox-regional\fanboy-adblocklist-jpn.txt firefox-regional\fanboy-adblocklist-krn.txt firefox-regional\fanboy-adblocklist-pol.txt firefox-regional\fanboy-adblocklist-rus-v2.txt firefox-regional\fanboy-adblocklist-swe.txt firefox-regional\fanboy-adblocklist-tky.txt firefox-regional\fanboy-adblocklist-vtn.txt
echo %time%
:: Opera
echo %time%
perl docs\sorting\sorter2.pl opera\urlfilter.ini opera\urlfilter-cz.ini opera\urlfilter-esp.ini opera\urlfilter-ind.ini opera\urlfilter-jpn.ini opera\urlfilter-krn.ini opera\urlfilter-pol.ini opera\urlfilter-rus.ini opera\urlfilter-stats.ini opera\urlfilter-tky.ini opera\urlfilter-vtn.ini opera\urlfilter-swe.ini
echo %time%
:: IE Addon List
echo %time%
perl docs\sorting\sorter2.pl ie\fanboy-adblock-addon.txt ie\fanboy-tracking-addon.txt ie\fanboy-russian-addon.txt
:: Opera
echo %time%
perl scripts\addChecksum-opera.pl opera\urlfilter.ini
:: Internet Explorer
:: perl scripts\addChecksum.pl ie\fanboy-adblock-addon.txt ie\fanboy-tracking-addon.txt ie\fanboy-russian-addon.txt
:: Commit
echo %time%
hg commit -m "%*"
echo %time%
hg push
echo %time%