/*!
 This script searches for identical rules with different domains written in the Adblock Plus syntax,
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
var onlyDomainDiffers = function(lines) {
  importScripts("redundant.js");

  var ELEMHIDE = /^([^\/\*\|\@\"\!]*?)\#\s*(\@)?\s*\#([^\{\}]+)$/, /**/
      BLOCKING = /^(@@)?(.*?)(\$~?[\w\-]+(?:=[^,\s]+)?(?:,~?[\w\-]+(?:=[^,\s]+)?)*)?$/, /**/
      B_DOMAINIS = /(?:\,|\$|^)domain\=([^\,]+)/, /**/
      STARTCOMMA = /^\,/,

      i, j, startWorkerResults, match, key, startWorkerResults2, betterRule, options, modifiedI,
      result = {},
      linesWithDomains = lines.split("\n");

  startWorker({filters: ""}, false, true); // import it's "globals"

  // Remove rules without domains/options
  for (i=linesWithDomains.length-1; i>=0; i--) {
    match = linesWithDomains[i].match(ELEMHIDE);
    if (match && !match[1]) {
      linesWithDomains.splice(i, 1);
    } else if (!match) {
      match = linesWithDomains[i].match(BLOCKING);
      if (!match[3] || !B_DOMAINIS.test(match[3].toLowerCase())) {
        linesWithDomains.splice(i, 1);
      }
    }
  }

  startWorkerResults = startWorker({filters: linesWithDomains.join("\n"), modifiers: {ignoreDomains: true}}, false, true);

top:
  for (i in startWorkerResults.results) {
    betterRule = startWorkerResults.results[i];
    for (j=0; j<startWorkerResults.warnings.length; j++) {
      if (startWorkerResults.warnings[j].rules.contains(i) || startWorkerResults.warnings[j].rules.contains(betterRule)) {
        continue top;
      }
    }

    if (ELEMHIDE.test(i)) {
      match = i.match(ELEMHIDE);
      startWorkerResults2 = startWorker({filters: betterRule + "\n" + i.replace(match[1], "")}, false, true);
      if (startWorker.isEmptyObject(startWorkerResults2.results)) {
        continue;
      }

      key = "#" + (match[2] || "") + "#" + match[3];
      result[key] = result[key] || [];
      result[key].push(i);
      if (!result[key].contains(betterRule)) {
        result[key].push(betterRule);
      }
    } else {
      match = i.match(BLOCKING);
      options = match[3].substring(1).toLowerCase().split(",");

      match[3] = "";
      for (j=0; j<options.length; j++) {
        if (!B_DOMAINIS.test(options[j])) {
          match[3] += "," + options[j];
        }
      }
      match[3] = match[3].replace(STARTCOMMA, "$");

      modifiedI = (match[1] || "") + (match[2] || "") + match[3];
      startWorkerResults2 = startWorker({filters: betterRule + "\n" + modifiedI}, false, true);
      if (startWorker.isEmptyObject(startWorkerResults2.results)) {
        continue;
      }

      key = (match[1] || "") + match[2] + match[3];
      result[key] = result[key] || [];
      result[key].push(i);
      if (!result[key].contains(betterRule)) {
        result[key].push(betterRule);
      }
    }
  }

  self.postMessage({results: result});
  self.close();
};
this.addEventListener("message", function(e) {
  onlyDomainDiffers(e.data.filters);
}, false);