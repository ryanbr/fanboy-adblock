#!/bin/bash
#
# cleanup old log files Script
# Prerequisites: Webserver (nginx), 7zip, sha256sum, cron, wget, addChecksum.pl
#
#
set -e

# 180 days, clear old log files.

# Agegate
if [[ -d "/var/www/difflogs/agegate" ]]; then
    find /var/www/difflogs/agegate -type f -mtime +180 -exec rm {} \;
else
    echo "The folder does not exist."
fi

# Annoyances
if [[ -d "/var/www/difflogs/annoyances" ]]; then
    find /var/www/difflogs/annoyances -type f -mtime +180 -exec rm {} \;
else
    echo "The folder does not exist."
fi

# diffs
if [[ -d "/var/www/difflogs/diffs" ]]; then
    find /var/www/difflogs/diffs -type f -mtime +180 -exec rm {} \;
else
    echo "The folder does not exist."
fi

# Easylist
if [[ -d "/var/www/difflogs/easylist" ]]; then
    find /var/www/difflogs/easylist -type f -mtime +180 -exec rm {} \;
else
    echo "The folder does not exist."
fi

# Easylist Cookie
if [[ -d "/var/www/difflogs/easylistcookie" ]]; then
    find /var/www/difflogs/easylistcookie -type f -mtime +180 -exec rm {} \;
else
    echo "The folder does not exist."
fi

# Newsletter
if [[ -d "/var/www/difflogs/newsletter" ]]; then
    find /var/www/difflogs/newsletter -type f -mtime +180 -exec rm {} \;
else
    echo "The folder does not exist."
fi

# Notifications
if [[ -d "/var/www/difflogs/notifications" ]]; then
    find /var/www/difflogs/notifications -type f -mtime +180 -exec rm {} \;
else
    echo "The folder does not exist."
fi

# Social
if [[ -d "/var/www/difflogs/social" ]]; then
    find /var/www/difflogs/social -type f -mtime +180 -exec rm {} \;
else
    echo "The folder does not exist."
fi









