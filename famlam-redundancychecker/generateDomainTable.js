/*!
 This script searches for similar rules written in the Adblock Plus syntax,
 documentated here: http://adblockplus.org/en/filters, and reports them.
 Author: Famlam (fam.lam [at] live.nl)

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.
*/
"use strict";
var extractDomainsFromFilters = function(lines) {
  importScripts("redundant.js");
  startWorker({filters: ""}, false, true); // import it's "globals"

  lines = lines.split("\n");
  var i, j, domains, match, line, isThirdParty, firstParty,
   knownThirdPartyDomains = [],
   domainInfo = {},
   ELEMHIDE = /^([^\/\*\|\@\"\!]*?)\#\s*(\@)?\s*\#([^\{\}]+)$/, /**/
   B_DOMAINIS = /(?:\,|\$|^)domain\=([^\,]+)/i, /**/
   B_THIRDPARTY = /(?:\,|\$)third[_\-]party(?:\,|$)/i,
   WHITESPACE_G = /\s+/g, /**/
   DOTEND = /\.$/, /**/
   SUBDOMAIN = /^.+?(?:\.|$)/, /**/
   B_DOMAINMATCH = /^(?:\|\||\|?[\w\-]+\:\/+)([^\^\/\*]+?\.[^\^\/\*]+?)[\^\/]/,
   BLOCKING = /^(@@)?(.*?)(\$~?[\w\-]+(?:=[^,\s]+)?(?:,~?[\w\-]+(?:=[^,\s]+)?)*)?$/; /**/

  for (i=0; i<lines.length; i++) {
    line = lines[i].toLowerCase().replace(WHITESPACE_G, "");
    match = line.match(ELEMHIDE);
    firstParty = false;
    if (match && match[1]) {
      domains = match[1].split(",");
      firstParty = true;
    } else {
      match = line.match(BLOCKING);
      domains = [];
      isThirdParty = false;
      if (match[3]) {
        if (B_DOMAINIS.test(match[3])) {
          domains = match[3].match(B_DOMAINIS)[1].split("|");
          firstParty = true;
        }
        isThirdParty = B_THIRDPARTY.test(match[3]);
      }

      match = match[2].match(B_DOMAINMATCH);
      if (match) {
        if (/^(?:\d{1,3}\.){3}\d{1,3}$/.test(match[1])) {
          isThirdParty = true;
        } else if (!isThirdParty) {
          for (j=0; j<domains.length; j++) {
            if (match[1].endsWith(domains[j])) {
              isThirdParty = false;
              break;
            }
            isThirdParty = true;
          }
        }
        if (!isThirdParty) {
          domains.push(match[1]);
          firstParty = firstParty || false;
        } else {
          knownThirdPartyDomains.push(match[1]);
        }
      }
    }

    for (j=0; j<domains.length; j++) {
      domains[j] = domains[j].replace("~", "").replace(DOTEND, "");
    }
    domains = domains.unique();
    for (j=0; j<domains.length; j++) {
      if (domains[j].contains(".")) {
        domainInfo[domains[j]] = domainInfo[domains[j]] || {filters: [], parentDomain: null, subdomains: [], unknownParty: !firstParty};
        domainInfo[domains[j]].filters.push(lines[i].trim());
      }
    }
  }

  for (j=0; j<knownThirdPartyDomains.length; j++) {
    knownThirdPartyDomains[j] = knownThirdPartyDomains[j].replace("~", "").replace(DOTEND, "");
  }
  for (i in domainInfo) {
    if (domainInfo[i].unknownParty && knownThirdPartyDomains.contains(i)) {
      delete domainInfo[i];
    } else {
      delete domainInfo[i].unknownParty;
    }
  }

  domains = Object.keys(domainInfo).sort(function(a, b) {
    return a.length < b.length ? -1 : 1;
  });

  for (i=0; i<domains.length; i++) {
    match = domains[i].replace(SUBDOMAIN, "");
    while (SUBDOMAIN.test(match)) {
      if (domainInfo.hasOwnProperty(match)) {
        domainInfo[match].subdomains.push(domains[i]);
        domainInfo[domains[i]].parentDomain = match;
        break;
      }
      match = match.replace(SUBDOMAIN, "");
    }
  }

  for (i in domainInfo) {
    domainInfo[i].subdomains.sort();
    domainInfo[i].filters.sort();
  }

  self.postMessage({results: domainInfo});
  self.close();
};
this.addEventListener("message", function(e) {
  extractDomainsFromFilters(e.data.filters);
}, false);