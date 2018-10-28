/*!
 This script searches for active whitelisting rules written in the Adblock Plus syntax,
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
var findWhitelistRules = function(lines) {
  importScripts("redundant.js");

  var ELEMHIDE = /^([^\/\*\|\@\"\!]*?)\#\s*(\@)?\s*\#([^\{\}]+)$/, /**/
   BLOCKING = /^(@@)?(.*?)(\$~?[\w\-]+(?:=[^,\s]+)?(?:,~?[\w\-]+(?:=[^,\s]+)?)*)?$/, /**/

   i, j,
   startWorkerResults = startWorker({filters: lines, modifiers: {matchWhitelist: true, loosely: true}}, false, true),
   resultByWhitelist = {},
   resultByFilter = {};

  // Show all whitelist rules, including the non-matching ones
  lines = lines.split("\n");
  for (i=0; i<lines.length; i++) {
    if (ELEMHIDE.test(lines[i])) {
      if (lines[i].match(ELEMHIDE)[2]) {
        resultByWhitelist[lines[i]] = [];
      }
    } else if (lines[i].match(BLOCKING)[1]) {
      resultByWhitelist[lines[i]] = [];
    }
  }

  for (i in startWorkerResults.results) {
    var splitted = startWorkerResults.results[i].split("\n");
    if (ELEMHIDE.test(i)) {
      if (!i.match(ELEMHIDE)[2]) {
        continue;
      }
    } else if (!i.match(BLOCKING)[1]) {
      continue;
    } else {
      for (j=splitted.length-1; j>=0; j--) {
        if (splitted[j].match(BLOCKING)[1]) {
          splitted.splice(i, 1);
        }
      }
    }
    resultByWhitelist[i] = resultByWhitelist[i].concat(splitted);
    for (j=0; j<splitted.length; j++) {
      resultByFilter[splitted[j]] = resultByFilter[splitted[j]] || [];
      resultByFilter[splitted[j]].push(i);
    }
  }

  self.postMessage({resultByFilter: resultByFilter, resultByWhitelist: resultByWhitelist});
  self.close();
};
this.addEventListener("message", function(e) {
  findWhitelistRules(e.data.filters);
}, false);