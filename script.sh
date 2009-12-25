#!/bin/bash
perl addChecksum.pl fanboy-adblocklist-adult.txt
perl addChecksum.pl fanboy-adblocklist-current-expanded.txt
perl addChecksum.pl fanboy-adblocklist-cz.txt
perl addChecksum.pl fanboy-adblocklist-stats.txt  
perl addChecksum.pl firefox-regional/fanboy-adblocklist-cz.txt
perl addChecksum.pl firefox-regional/fanboy-adblocklist-jpn.txt
perl addChecksum.pl firefox-regional/fanboy-adblocklist-esp.txt
perl addChecksum.pl firefox-regional/fanboy-adblocklist-tky.txt
hl add .
hg commit -m "$1"
hg push
