@echo off
:: Firefox
perl sorter.pl ..\..\fanboy-adblocklist-current-expanded.txt
perl sorter.pl ..\..\fanboy-adblocklist-stats.txt
perl sorter.pl ..\..\fanboy-adblocklist-addon.txt
perl sorter.pl ..\..\adblock-gannett.txt
perl sorter.pl ..\..\other\enhancedstats-addon.txt
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
perl sorter.pl ..\..\ie\fanboy-russian-addon.txt
:: Lower case elements
perl -pi.bak -we "s/DIV\[/div\[/g" ..\..\fanboy-adblocklist-current-expanded.txt
perl -pi.bak -we "s/LI\[/li\[/g" ..\..\fanboy-adblocklist-current-expanded.txt
perl -pi.bak -we "s/TD\[/td\[/g" ..\..\fanboy-adblocklist-current-expanded.txt
perl -pi.bak -we "s/TR\[/tr\[/g" ..\..\fanboy-adblocklist-current-expanded.txt
perl -pi.bak -we "s/TABLE\[/table\[/g" ..\..\fanboy-adblocklist-current-expanded.txt
perl -pi.bak -we "s/P\[/p\[/g" ..\..\fanboy-adblocklist-current-expanded.txt
perl -pi.bak -we "s/A\[/a\[/g" ..\..\fanboy-adblocklist-current-expanded.txt
perl -pi.bak -we "s/FONT\[/font\[/g" ..\..\fanboy-adblocklist-current-expanded.txt
perl -pi.bak -we "s/FIELDSET\[/fieldset\[/g" ..\..\fanboy-adblocklist-current-expanded.txt
perl -pi.bak -we "s/IMG\[/img\[/g" ..\..\fanboy-adblocklist-current-expanded.txt
perl -pi.bak -we "s/SPAN\[/span\[/g" ..\..\fanboy-adblocklist-current-expanded.txt
perl -pi.bak -we "s/IFRAME\[/iframe\[/g" ..\..\fanboy-adblocklist-current-expanded.txt
perl -pi.bak -we "s/EM\[/em\[/g" ..\..\fanboy-adblocklist-current-expanded.txt
del /Q /F ..\..\fanboy-adblocklist-current-expanded.txt.bak
:: Call winscript
cd ..\..
echo Executing winscript...
call winscript.bat sort