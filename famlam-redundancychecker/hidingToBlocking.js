/*!
 This script searches for rules that can be changed into blocking rules,
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
var hidingToBlocking = function(lines) {
  importScripts("redundant.js");
  startWorker({filters: ""}, false, true); // import it's "globals"

  var ELEMHIDE = /^([^\/\*\|\@\"\!]*?)\#\s*(\@)?\s*\#([^\{\}]+)$/, /**/
      H_NODENAMESELECTOR = /^((?:\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*|\*)?\|)?((?:\*|\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*))$/i, /**/
      H_ATTRIBUTENAME = /^\[\s*(data|src)\s*\W?\=/i,
      WHITESPACE_G = /\s+/g, /**/
      COMMA_G = /\,/g, /**/
      B_REGEX = /^\/.+\/$/, /**/
      H_RELATIVEPATH = /^(?:\.\.?\/)+/,

      i,
      result = {},
      toBlocking = function(line) {
        var match = line.match(ELEMHIDE),
        parsed = startWorker.parseCSSSelector(match[3]),
          priority = 10,
          i, s, foundRule, previousFoundRule,
          options = [];
        if (parsed.length !== 1 || match[2]) {
          return;
        }
        if (match[1]) {
          options.push("domain=" + match[1].replace(COMMA_G, "|").toLowerCase());
        }
        if (parsed[0].length !== 1) {
          priority = 6;
        }
        parsed = parsed[0][0];
        for (i=0; i<parsed.length; i++) {
          s = parsed[i];
          if (H_NODENAMESELECTOR.test(s.toLowerCase())) {
            switch (s.toLowerCase().substring(s.indexOf("|") + 1)) {
              case "img": {
                options.push("image");
                break;
              }
              case "object": case "embed": case "applet": {
                options.push("object");
                break;
              }
              case "video": case "audio": case "source": {
                options.push("media");
                break;
              }
              case "frame": case "iframe": {
                options.push("subdocument");
                break;
              }
              default: {
                priority = 6;
              }
            }
          } else if (s[0] === "[") {
            if (!H_ATTRIBUTENAME.test(s)) {
              priority = 6;
              continue;
            }
            if (foundRule) {
              priority = 9;
              previousFoundRule = foundRule;
            }
            if (s.substring(s.indexOf("=") - 1, s.indexOf("=")) === "\\") {
              priority = 6;
              continue;
            }
            foundRule = s.substring(0, s.length - 1).substring(s.indexOf("=") + 1).trim();
            if (foundRule[0] === "\"" || foundRule[0] === "'") {
              foundRule = foundRule.substring(1, foundRule.length - 1);
            }
            if (encodeURI(foundRule) !== foundRule || foundRule.contains("*") || foundRule.contains("$")
                || (foundRule.contains(":") && foundRule.substring(0, 5) !== "http:" && foundRule.substring(0, 6) !== "https:")) {
              priority = 6;
              foundRule = previousFoundRule || "";
              continue;
            }
            if (previousFoundRule && previousFoundRule.length > foundRule.length) {
              foundRule = previousFoundRule;
            }
            if (B_REGEX.test(foundRule)) {
              foundRule = foundRule + "*";
            } else if (foundRule[0] === "!" || (foundRule[0] === "@" && foundRule[1] === "@")) {
              foundRule = "*" + foundRule;
            }
            if (H_RELATIVEPATH.test(foundRule)) {
              foundRule = foundRule.replace(H_RELATIVEPATH, "/");
              if (foundRule === "/") {
                foundRule = previousFoundRule || "";
              }
            }
          } else {
            priority = 6;
          }
        }
        if (foundRule) {
          result[line] = {
            priority: priority,
            newRule: (foundRule + (options.length ? "$" + options.sort().join(",") : "")).replace(WHITESPACE_G, "")
          };
        }
      };

  lines = lines.split("\n");
  for (i=0; i<lines.length; i++) {
    if (ELEMHIDE.test(lines[i])) {
      toBlocking(lines[i]);
    }
  }

  self.postMessage({results: result});
  self.close();
};
this.addEventListener("message", function(e) {
  hidingToBlocking(e.data.filters);
}, false);