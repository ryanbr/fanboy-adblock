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
var similarity = function(lines) {
  importScripts("redundant.js");
  startWorker({filters: ""}, false, true); // import it's "globals"

  lines = lines.split("\n");
  var i, j, sI, score,
      result = {},
      ELEMHIDE = /^([^\/\*\|\@\"\!]*?)\#\s*(\@)?\s*\#([^\{\}]+)$/, /**/
      BLOCKING = /^(@@)?(.*?)(\$~?[\w\-]+(?:=[^,\s]+)?(?:,~?[\w\-]+(?:=[^,\s]+)?)*)?$/, /**/
      MANYSTARS_G = /\*{2,}/g, /**/
      B_USELESSFILTERSTART = /^\|\*/, /**/
      B_USELESSFILTEREND = /(?:\*+|^)(?:\^+\|?|\|)$/, /**/
      B_USELESSSTAR_G = /^\*|\*$/g, /**/
      B_STARTWILDCARDPIPE_G = /^(?:\*|\.?\*\\)\|/g, /**/
      B_ENDWILDCARDPIPE_G = /\|\.?\*$/g, /**/
      H_HIDINGKEYGROUPS = /[\*\|\~\$\^]?\=\s*\"(?:\\.|[^\\\"])*?\"|[\*\|\~\$\^]?\=\s*\'(?:\\.|[^\\\'])*?\'|\-?(?:[_a-z]|[^\u0000-\u0177]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u0177]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*|\((?:\\.|[^\\\)])*?\)|\s*[\>\+\~\,]\s*|./gi,
      WHITESPACE_G = /\s+/g, /**/
      B_REGEX = /^\/.+\/$/, /**/
      B_BLOCKINGKEYS = /^\|\||\%[0-9a-f]{2}|[a-z]+|[0-9]+|[^\*\^]|\^\*/g,

      cat_elemhide = {},
      cat_block = {},

      currentChecks = 0,
      maxChecks = 0,
      nextReport = 0,
      reportProgress = function(n) {
        currentChecks += n;
        nextReport -= n;
        if (nextReport < 1) {
          nextReport = maxChecks;
          self.postMessage({progress: Math.round(currentChecks / maxChecks) / 2});
        }
      };

  var isEmptyObject = function(obj) {
    var i;
    for (i in obj) {
      return false;
    }
    return true;
  };

  var get_keys_block = function(line) {
    var newLine, i, j,
        match = line.replace(WHITESPACE_G, "").match(BLOCKING),
        keys = [],
        singlekeys = [];
    if (B_REGEX.test(match[2])) {
      match[2] = match[2].substring(1, match[2].length - 1);
    } else {
      match[2] = match[2]
                   .replace(MANYSTARS_G, "*")
                   .replace(B_USELESSFILTEREND, "*")
                   .replace(B_USELESSFILTERSTART, "*");
      match[2] = match[2]
                .replace(B_STARTWILDCARDPIPE_G, "**|")
                .replace(B_ENDWILDCARDPIPE_G, "|**")
                .replace(B_USELESSSTAR_G, "");
    }
    newLine = (match[1] || "") + (match[2] || "") + (match[3] ? "$" : "");
    if (match[1]) {
      keys.push("@@");
    }
    if (match[2]) {
      singlekeys = match[2].toLowerCase().match(B_BLOCKINGKEYS);
      for (i=0; i<singlekeys.length; i++) {
        for (j=Math.min(i+10, singlekeys.length); j>i; j--) {
          keys.push(singlekeys.slice(i, j).join(""));
        }
      }
    }
    if (match[3]) {
      keys.push("$");
      singlekeys = match[3].substring(1).split(",");
      for (i=0; i<singlekeys.length; i++) {
        if (singlekeys[i][0] !== "~" && !singlekeys.contains("~" + singlekeys[i])) {
          keys.push(singlekeys[i]);
        }
      }
    }
    return keys.sort(function(a, b) {
      if (a.length === b.length) {
        return a > b ? 1 : -1;
      }
      return b.length-a.length < 0 ? -1 : 1;
    });
  };
  var get_keys_hide = function(line) {
    var singlekeys, i, j,
        match = line.match(ELEMHIDE),
        keys = [];
    match[1] = match[1].replace(WHITESPACE_G, "").toLowerCase();
    match[2] = match[2] ? "#@#" : "##";
    if (match[1]) {
      keys.push(match[1]);
    }
    keys.push(match[2]);
    singlekeys = match[3].trim().match(H_HIDINGKEYGROUPS);

    for (i=0; i<singlekeys.length; i++) {
      for (j=Math.min(i+10, singlekeys.length); j>i; j--) {
        keys.push(singlekeys.slice(i, j).join(""));
      }
    }
    return keys.sort(function(a, b) {
      if (a.length === b.length) {
        return a > b ? 1 : -1;
      }
      return b.length-a.length < 0 ? -1 : 1;
    });
  };

  var tresholdcache = [9, 9, 9, 9, 9, 4, 5, 5, 6, 6];
  var get_treshold = function(length) {
    if (tresholdcache.length > length) {
      return tresholdcache[length];
    }
    var i, sqrt;
    for (i=tresholdcache.length; i<length+1; i++) {
      if (i<55) {
        // 1 2 3 4 5 6 = 21 = de som     minus de x-waarde van de som = 6     minus Math.floor(x/10) maal de (x-1)-waarde van de som = 0
        sqrt = Math.sqrt(8*i + 1);
        tresholdcache.push(Math.ceil(i - (Math.floor(sqrt/20 - 0.05)*(sqrt + 1) + sqrt)/2));
      } else {
        // de ingekortte 'som'    minus 11     minus 10*floor(x/10)
        tresholdcache.push(Math.ceil(i - 11 - 10*Math.floor((i/10 + 4.5)/10)));
      }
    }
    return tresholdcache[length];
  };

  var get_score = function(rule, similarRule) {
    var i, prevScore,
        equal = rule.length,
        treshold = get_treshold(rule.length);
    if (similarRule.length < treshold) {
      return 0;
    }
    for (i=0; i<rule.length; i++) {
      if (i > 0 && rule[i] === rule[i-1]) {
        equal += prevScore; // prevScore <= 0
        continue;
      }
      prevScore = 0;
      if (!similarRule.contains(rule[i])) {
        equal -= 1;
        prevScore = -1;
        if (equal < treshold) {
          return 0;
        }
      }
    }
    equal = equal/rule.length;
    return equal >= 0.6 ? equal : 0;
  };

  for (i=0; i<lines.length; i++) {
    if (ELEMHIDE.test(lines[i])) {
      cat_elemhide[lines[i]] = get_keys_hide(lines[i]);
    } else {
      cat_block[lines[i]] = get_keys_block(lines[i]);
    }
  }
  maxChecks += (Math.pow(Object.keys(cat_elemhide).length, 2) + Math.pow(Object.keys(cat_block).length, 2) + 1) / 200;

  for (i in cat_elemhide) {
    sI = cat_elemhide[i];
    result[i] = {};
    for (j in cat_elemhide) {
      reportProgress(1);
      if (i === j) {
        continue;
      }
      score = get_score(sI, cat_elemhide[j]);
      if (score) {
        result[i][j] = score;
      }
    }
  }
  for (i in cat_block) {
    sI = cat_block[i];
    result[i] = {};
    for (j in cat_block) {
      reportProgress(1);
      if (i === j) {
        continue;
      }
      score = get_score(sI, cat_block[j]);
      if (score) {
        result[i][j] = score;
      }
    }
  }
  for (i in result) {
    if (isEmptyObject(result[i])) {
      delete result[i];
    }
  }
  self.postMessage({results: result});
  self.close();
};
this.addEventListener("message", function(e) {
  similarity(e.data.filters);
}, false);