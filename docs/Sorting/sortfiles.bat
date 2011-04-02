@echo off
:: Firefox
perl sorter.pl ..\..\fanboy-adblocklist-current-expanded.txt
perl sorter.pl ..\..\fanboy-adblocklist-stats.txt
perl sorter.pl ..\..\fanboy-adblocklist-addon.txt
perl sorter.pl ..\..\adblock-gannett.txt
:: Firefox Regional lists
perl sorter.pl ..\..\firefox-regional\fanboy-adblocklist-chn.txt
perl sorter.pl ..\..\firefox-regional\fanboy-adblocklist-cz.txt
perl sorter.pl ..\..\firefox-regional\fanboy-adblocklist-esp.txt
perl sorter.pl ..\..\firefox-regional\fanboy-adblocklist-ind.txt
perl sorter.pl ..\..\firefox-regional\fanboy-adblocklist-ita.txt
perl sorter.pl ..\..\firefox-regional\fanboy-adblocklist-jpn.txt
perl sorter.pl ..\..\firefox-regional\fanboy-adblocklist-krn.txt
perl sorter.pl ..\..\firefox-regional\fanboy-adblocklist-pol.txt
perl sorter.pl ..\..\firefox-regional\fanboy-adblocklist-rus-v2.txt
perl sorter.pl ..\..\firefox-regional\fanboy-adblocklist-swe.txt
perl sorter.pl ..\..\firefox-regional\fanboy-adblocklist-tky.txt
perl sorter.pl ..\..\firefox-regional\fanboy-adblocklist-vtn.txt
:: Opera
perl sorter.pl ..\..\opera\urlfilter.ini
perl sorter.pl ..\..\opera\urlfilter-chn.ini
perl sorter.pl ..\..\opera\urlfilter-cz.ini
perl sorter.pl ..\..\opera\urlfilter-esp.ini
perl sorter.pl ..\..\opera\urlfilter-ind.ini
perl sorter.pl ..\..\opera\urlfilter-jpn.ini
perl sorter.pl ..\..\opera\urlfilter-krn.ini
perl sorter.pl ..\..\opera\urlfilter-pol.ini
perl sorter.pl ..\..\opera\urlfilter-rus.ini
perl sorter.pl ..\..\opera\urlfilter-stats.ini
perl sorter.pl ..\..\opera\urlfilter-tky.ini
perl sorter.pl ..\..\opera\urlfilter-vtn.ini
perl sorter.pl ..\..\opera\urlfilter-swe.ini
:: IE Addon List
perl sorter.pl ..\..\ie\fanboy-adblock-addon.txt
perl sorter.pl ..\..\ie\fanboy-tracking-addon.txt
:: Call winscript
cd ..\..
call winscript.bat sort