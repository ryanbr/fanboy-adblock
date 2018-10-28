/*!
 This script searches for redundant rules written in the Adblock Plus syntax,
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
var startWorker = function(data, secondTime, returnWhenDone) {
  data.modifiers = data.modifiers || {};
  var timeStart = Date.now(),
      redundant = {},
      warnings = [],
      id = 0,

      warningMessages = [
        {id:   1, pri: "H", msg: "The selector isn't a valid CSS3 selector"},
        {id:   2, pri: "H", msg: "This rule could not be parsed"},
        {id:   3, pri: "H", msg: "This rule uses an old, unsupported syntax. It is broken and therefore can't be converted to the new syntax"},
        {id:   4, pri: "M", msg: "Domain '{1}' is included and excluded"},
        {id:   5, pri: "M", msg: "Domain '{1}' isn't a valid domain"},
        {id:   6, pri: "M", msg: "Invalid lonely separator ('{1}') in the domain specifier"},
        {id:   7, pri: "M", msg: "Invalid preceeding separator ('{1}') in the domain specifier"},
        {id:   8, pri: "M", msg: "Invalid repeating separator ('{1}') in the domain specifier"},
        {id:   9, pri: "M", msg: "Invalid trailing separator ('{1}') in the domain specifier"},
        {id:  10, pri: "M", msg: "Option '{1}' can only be used with a value part"},
        {id:  11, pri: "M", msg: "Option '{1}' cannot be used with a value part"},
        {id:  12, pri: "M", msg: "Option '{1}' doesn't have any effect when inversed. Specify the inverse in the option value instead"},
        {id:  13, pri: "M", msg: "Selector '{1}' will never match anything"},
        {id:  14, pri: "M", msg: "This filter has been made redundant by '{1}' and '{2}'"},
        {id:  15, pri: "M", msg: "This rule doesn't match any resource type"},
        {id:  16, pri: "M", msg: "This rule doesn't match anything! '|' as first character must be followed by a valid protocol"},
        {id:  17, pri: "M", msg: "This rule doesn't match anything! '||' must be followed by a valid domain"},
        {id:  19, pri: "M", msg: "Unknown option '{1}'"},
        {id:  20, pri: "M", msg: "Option '{1}' exists multiple times. Specify the option once and use a pipe ('|') to separate the values instead"},
        {id:  21, pri: "M", msg: "Probably '{1}' was used instead of ',' to separate options"},
        {id:  18, pri: "M", msg: "Probably option '{1}' is desired instead of '{2}'"},
        {id:  22, pri: "M", msg: "This is likely a broken hiding rule. Hiding rules may not contain { or }"},
        {id:  23, pri: "M", msg: "This is likely a hiding rule with a broken domain or an exclusion rule for a hiding rule. Their syntax is 'domain#@#rule'"},
        {id:  24, pri: "M", msg: "This is likely an exclusion rule for a hiding rule. Their syntax is 'domain#@#rule'"},
        {id:  25, pri: "M", msg: "This is very likely a hiding rule with a broken domain"},
        {id:  26, pri: "M", msg: "This is very likely a rule with broken options"},
        {id:  27, pri: "M", msg: "Both '{1}' and '~{1}' are used in the same rule"},
        {id:  28, pri: "M", msg: "Option '{1}' does no longer exist"},
        {id:  29, pri: "M", msg: "They are at least partially redundant"},
        {id:  30, pri: "M", msg: "This rule uses an old, unsupported syntax. Replace it by {1}"},
        {id:  31, pri: "M", msg: "The following domain of '{1}' can be removed: {2}"},
        {id:  32, pri: "M", msg: "The following domains of '{1}' can be removed: {2}"},
        {id:  33, pri: "M", msg: "They are redundant at almost every domain. Consider applying '{1}' to these domains only: {2}"},
        {id:  34, pri: "M", msg: "They are redundant at almost every domain. Consider applying '{1}' to this domain only: {2}"},
        {id:  35, pri: "M", msg: "They are redundant for at least domain '{1}'"},
        {id:  64, pri: "M", msg: "They are redundant for at least domain '{1}' if you neglect the domain variant '{2}'"},
        {id:  65, pri: "M", msg: "They are redundant for domain '{1}' if you neglect the domain variant '{2}'"},
        {id:  36, pri: "M", msg: "This filter has possibly been made redundant by the regex '{1}'"},
        {id:  37, pri: "M", msg: "This filter has possibly been made redundant by the regex '{1}' on domain '{2}'"},
        {id:  38, pri: "M", msg: "Option '{1}' only works on whitelist rules"},
        {id:  39, pri: "M", msg: "Excluded domain '{1}' doesn't have any effect"},
        {id:  66, pri: "M", msg: "Option '{1}' cancels the effect of option '{2}'"},
        {id:  40, pri: "M", msg: "Option '{1}' doesn't have any effect"},
        {id:  41, pri: "M", msg: "Option '{1}' doesn't have any effect when inversed"},
        {id:  42, pri: "M", msg: "Option '{1}' doesn't have any effect, except for the first time it is used"},
        {id:  43, pri: "M", msg: "Option '{1}' has no effect on whitelisting rules"},
        {id:  44, pri: "M", msg: "Option '{1}' is deprecated. Use '{2}' instead"},
        {id:  45, pri: "M", msg: "Selector '{1}' matches everything and should thus be removed"},
        {id:  46, pri: "M", msg: "Selector '{1}' matches everything and should thus be replaced by the universal selector (*)"},
        {id:  47, pri: "M", msg: "Domain '{1}' exists multiple times"},
        {id:  48, pri: "M", msg: "Excluded domain '{1}' exists multiple times"},
        {id:  49, pri: "M", msg: "Option '{1}' exists multiple times"},
        {id:  50, pri: "M", msg: "Rule '{1}' has been made redundant by '{2}'"},
        {id:  51, pri: "M", msg: "Selector '{1}' has been made redundant by '{2}'"},
        {id:  52, pri: "M", msg: "Some excluded subdomains of '{1}' are redundant"},
        {id:  53, pri: "M", msg: "Some subdomains of '{1}' are redundant"},
        {id:  54, pri: "L", msg: "Consider replacing '{1}' by '{2}' because it's faster"},
        {id:  55, pri: "L", msg: "Unnecessary '{1}' found at the end of the filter"},
        {id:  56, pri: "L", msg: "Unnecessary '{1}' found at the start of the filter"},
        {id:  57, pri: "L", msg: "Unnecessary regular expression. Use '{1}' instead, or use '{2}' if it isn't a regex"},
        {id:  58, pri: "L", msg: "Unnecessary universal selector (*) found before '{1}'"},
        {id:  59, pri: "L", msg: "Unnecessary preceding wildcard found"},
        {id:  60, pri: "L", msg: "Unnecessary successive wildcards found"},
        {id:  61, pri: "L", msg: "Unnecessary trailing dot found for domain '{1}'"},
        {id:  62, pri: "L", msg: "Unnecessary trailing wildcard found"},
        {id:  63, pri: "L", msg: "Unnecessary whitespace character(s) found"}
      ],// largest existing id = 66, higher in the list means higher priority

      // Regexes
      // Hiding rule identifier:
      //   \-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*
      ELEMHIDE = /^([^\/\*\|\@\"\!]*?)\#\s*(\@)?\s*\#([^\{\}]+)$/, /**/
      PROBABLYELEMHIDE = /^.*?\#\s*\@*\s*\#.+/,
      BLOCKING = /^(@@)?(.*?)(\$~?[\w\-]+(?:=[^,\s]+)?(?:,~?[\w\-]+(?:=[^,\s]+)?)*)?$/, /**/
      PROBABLYOPTIONS = /\$,*~?[\w\-_]+(?:=[^,\s]*)?(?:,+~?[\w\-_]+(?:=[^,\s]*)?)*,*$/,
      B_REGEX = /^\/.+\/$/, /**/
      PROBABLYNOTREGEX = /^\/[^\\\.\*\{\}\+\?\^\$\[\]\(\)\|<\>\#]+\/$/,
      B_DOMAINIS = /(?:\,|\$|^)domain\=([^\,]+)/i, /**/
      WHITESPACE_G = /\s+/g, /**/
      WHITESPACE = /\s+/,
      H_IDENTIFIER = /\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*/gi,
      H_IDENTIFIERSTART = /^\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*/i,
      H_IDENTIFIERENDSPACE = /^\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*\s$/i,
      ESCAPEDSTAR_G = /\\\*/g,
      ESCAPEDROOFTOP_G = /\\\^/g,
      ESCAPEDROOFTOPSTART = /^(?:\\\|)?\\\^/,
      ESCAPEDROOFTOPEND = /(?:\\\^)+\\\|$/,
      B_TRIPLEROOFTOP_G = /\|\^\^\^\)/g,
      B_USELESSWILDCARD_G = /^\.\*|\.\*$/g,
      B_USELESSSTAR_G = /^\*|\*$/g, /**/
      ESCAPECHAR_G = /\W/g,
      SUBDOMAIN = /^.+?(?:\.|$)/, /**/
      ONEESCAPEDPIPE = /^\\\|/,
      TWOESCAPEDPIPES = /^\\\|\\\|/,
      MANYSTARS_G = /\*{2,}/g, /**/
      TILDESTART = /^\~/,
      ESCAPEDPIPEFINAL = /\\\|$/,
      DASH_G = /\-/g,
      CURLYBRACKETS = /\{|\}/,
      DOTEND = /\.$/, /**/
      COMMAEND = /\,$/,
      H_PROBABLYELEMHIDEEXCLUDE = /^(?:\@\@[^\#\@]*\#\@{0,2}|[^\#\@]*\#\@\@|[^\#\@]*\@\@?\#\@?)\#.+/,
      B_BADFILTERSTART = /^\|\|[^a-z0-9_\-\.\~\%\!\$\&\'\(\)\+\,\;\=\:\@\[\*\u00DF-\u00F6\u00F8-\uFFFFFF]/i,
      B_BADPROTOCOLSTART = /^\|([^a-z]|[a-z0-9\+\-\.]*[^a-z0-9\+\-\.\:\^\*])/i,
      B_USELESSFILTERSTART = /^\|\*/, /**/
      B_USELESSFILTEREND = /(?:\*+|^)(?:\^+\|?|\|)$/, /**/
      H_BROWSERPSEUDOSELECTOR = /^\:?\-[a-z]+\-.+/,
      OLDSTYLEHIDING = /^[^\/\*\|\@\"\!]*?\#(?:[\w\-]+|\*)(?:\([\w\-]+(?:[\$\^\*]?=[^\(\)\"]*)?\))*$/,
      COMMENTLINE = /^\s*(?:\!|.*\[Adblock.*\]|\s+$)/i, /**/
      B_STARTWILDCARDPIPE_G = /^(?:\*|\.?\*\\)\|/g, /**/
      B_ENDWILDCARDPIPE_G = /\|\.?\*$/g, /**/
      H_ATTRSELECTORNOVALUE = /^\[\s*(\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*\||\*\||\|)?(\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*)\s*\]$/i,
      H_ATTRDOUBLEQUOTESSELECTOR = /^\[\s*(\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*\||\*\||\|)?(\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*)\s*((\~|\^|\$|\*|\|)?\=\s*\"((?:\\.|[^\"\\])*?)\")\s*\]$/i,
      H_ATTRSINGLEQUOTESSELECTOR = /^\[\s*(\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*\||\*\||\|)?(\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*)\s*((\~|\^|\$|\*|\|)?\=\s*\'((?:\\.|[^\'\\])*?)\')\s*\]$/i,
      H_ATTRNOQUOTESSELECTOR = /^\[\s*(\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*\||\*\||\|)?(\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*)\s*((\~|\^|\$|\*|\|)?\=\s*(\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*))\s*\]$/i,
      H_ATTRIDSELECTOR = /^\[id\=\'\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*\'\]$/i,
      H_ATTRCLASSSELECTOR = /^\[class\~?\=\'\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*(?:\s+\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*)*\'\]$/i,
      H_PSEUDOCLASSSELECTOR = /^\:(\:?\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*)(?:\((.+)\))?$/i,
      H_LOOSEATTRIBUTEVALUESELECTOR = /^\[(\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*\||\*\||\|)?(\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*)((\~|\^|\$|\*|\|)?\=\'((?:\\.|[^\\])*?)\')\]$/i,
      H_IDSELECTOR = /^\#\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*$/i,
      H_CLASSSELECTOR = /^\.\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*$/i,
      H_NODENAMESELECTOR = /^((?:\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*|\*)?\|)?((?:\*|\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*))$/i, /**/
      H_TREESELECTORCOMMASTART = /^\s*[\>\~\+\s\,]\s*/,
      H_TREESELECTORCOMMA = /^\s*[\>\~\+\s\,]\s*$/,
      H_NTHPSEUDOCONTENT = /^\s*((\-|\+)?\d*n(\s*(\-|\+)?\s*\d+)?|(\-|\+)?\d+|odd|even)\s*$/i,
      H_LANGPSEUDOCONTENT = /^\s*\-?(?:[_a-z]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])(?:[\-_a-z0-9]|[^\u0000-\u009F]|\\[0-9a-f]{1,6}\s?|\\[^0-9a-f])*\s*$/i,
      H_LANGPSEUDOCONTENTSPLITTER_G = /(?:^|\-)(?:\\.|[^\\\-])+/g,
      VALIDDOMAIN = /^\~?((?:[a-z0-9\-_\u00DF-\u00F6\u00F8-\uFFFFFF]+|xn\-\-[a-z0-9\-_\u00DF-\u00F6\u00F8-\u00FF]+)\.)*(?:[a-z0-9\u00DF-\u00F6\u00F8-\uFFFFFF]+|xn\-\-[a-z0-9\-_\u00DF-\u00F6\u00F8-\u00FF]+)\.?$/i,
      H_OLDSTYLEIDCLASS = /\(([^\=]+?)\)/,
      H_OLDSTYLEATTRIBUTE_G = /\(([^\)\=]+?\=)([^\)]+?)\)/g,
      B_OPTIONVALUE = /\=.+$/,
      BACKSLASHEND = /\\+$/,
      B_MATCHEVERYTHING = /^(?:\|\||\:|\||\|\*\:|\^|\|\*\^)?(?:\*\/|\*\^|\*\|)?$/,
      B_HATSTAR_G = /\^|\*/g,
      STAR_G = /\*/g,
      AT_G = /\@/g,
      WARNINGINSERTS = /\{(\d)\}/g,
      B_ROOFTOPCHARACTERS = /[^\-\.\%a-zA-Z0-9_\|\*\u0080-\uFFFFFF\^]/, // excluding ^ itself
      B_KEYCHARACTERS = /[\%a-z0-9\u0080-\uFFFFFF]/,

      // The blocking options
      knownOptions = [
        "third_party",
        "match_case",
        "collapse",
        "domain",
        "sitekey"
      ],
      deprecated = {
        background: "image",
        dtd: "other",
        ping: "other",
        xbl: "other",
        donottrack: ""
      },
      Types = {ALL: 0};
  [
    "document",
    "elemhide",
    "font",
    "genericblock",
    "generichide",
    "image",
    "background",
    "media",
    "object",
    "object_subrequest",
    "other",
    "dtd",
    "ping",
    "xbl",
    "popup",
    "script",
    "stylesheet",
    "subdocument",
    "xmlhttprequest"
  ].forEach(function(val) {
    if (deprecated.hasOwnProperty(val)) {
      Types[val] = Types[deprecated[val]]; // requires deprecated items after replacement items
    } else {
      Types[val] = Types.ALL + 1;
      Types.MAX = Types.ALL + 1;
      Types.ALL = Types.MAX * 2 - 1;
    }
  });

  var status = {
        OK: 1,
        INVALID: 2,
        IGNORE: 4,
        DISCARD: 8
      },

      syntax = {
        hiding: 1,
        blocking: 2
      },

      // Objects containing the individual filters
      h_global = [],
      h_siteSpecific = [],
      h_siteCollection = {},
      b_siteCollection = {},
      b_withoutkey = [],
      b_withkey = [],
      b_keyCollection = {},

      // Reporting the progress
      currentChecks = 0,
      maxChecks = 0,
      nextReport = 0,
      reportProgress = function(n) {
        if (secondTime) {
          return;
        }
        currentChecks += n;
        nextReport -= n;
        if (nextReport < 1) {
          nextReport = maxChecks / 200;
          self.postMessage({progress: Math.round(currentChecks / nextReport) / 2});
        }
      };

  String.prototype.trimLeft = String.prototype.trimLeft || function() { // non-standard function
    return this.replace(/^\s+/, "");
  };
  String.prototype.trimRight = String.prototype.trimRight || function() { // non-standard function
    return this.replace(/\s+$/, "");
  };
  String.prototype.trim = function() {
    // I don't want to trim 'foo\ ' to 'foo\'
    var diff,
        match = this.trimRight().match(BACKSLASHEND);
    if (!match || match[0].length%2 === 0) {
      return this.trimRight().trimLeft();
    }
    diff = this.length - this.trimRight().length;
    if (diff > 1) {
      return this.substring(0, this.length - diff + 1).trimLeft();
    }
    return this.trimLeft();
  };
  Array.prototype.contains = function(obj) {
    return this.indexOf(obj) !== -1;
  };
  String.prototype.contains = String.prototype.contains || Array.prototype.contains; // part of ES6
  String.prototype.startsWith = String.prototype.startsWith || function(obj) { // part of ES6
    return this.indexOf(obj) === 0;
  };
  String.prototype.endsWith = String.prototype.endsWith || function(obj) { // part of ES6
    var position = this.length - obj.length;
    return position > -1 && this.substring(position) === obj;
  };
  Array.prototype.clone = function() {
    return this.slice(0);
  };
  Array.prototype.unique = function() {
    var i,
        l = this.length,
        arr = [];
    for (i=0; i<l; i++) {
      if (this.indexOf(this[i], i+1) === -1) {
        arr.push(this[i]);
      }
    }
    return arr;
  };
  Array.prototype.removeAt = function(index) {
    if (index < 0) {
      return [];
    }
    return this.splice(index, 1);
  };


  var isObjectProperty = function(str) {
    return ({})[str] !== undefined;
  };

  startWorker.isEmptyObject = function(obj) {
    var i;
    for (i in obj) {
      return false;
    }
    return true;
  };

  var isInaccurateNumber = function(nr) {
    return Math.abs(nr) > Math.pow(2, 53); // IEEE 754
  };

  // Remove exact duplicates and comments
  var getLinesWithoutDuplicates = function() {
    // Inputs:
    //   nothing
    // Returns:
    //   array of strings
    var i, line,
        linesObj = {},
        lines = data.filters.split("\n");
    for (i=lines.length-1; i>=0; i--) {
      line = lines[i];
      if (!line || COMMENTLINE.test(line) || isObjectProperty(line)) {
        lines.removeAt(i);
      } else if (linesObj.hasOwnProperty(line)) {
        redundant[line] = line;
        lines.removeAt(i);
      } else {
        linesObj[line] = true; // Object.hasOwnProperty is faster than Array.contains()
      }
    }
    return lines;
  };

  var getWarningIndex = function(warningID) {
    // Inputs:
    //   warningID: number
    // Returns:
    //   number
    var i;
    for (i=0; i<warningMessages.length; i++) {
      if (warningID === warningMessages[i].id) {
        return i;
      }
    }
  };
  var warn = function(warningID, rules, arg) {
    // Inputs:
    //   warningID: number
    //   rules: string or array of strings
    //   arg: string or array of strings
    // Returns:
    //   nothing
    if (typeof rules === "string") {
      rules = [rules];
    }
    if (typeof arg !== "object") {
      arg = [arg];
    }
    var index = getWarningIndex(warningID);
    warnings.push({
      rules: rules.sort(),
      index: index,
      priority: warningMessages[index].pri,
      msg: warningMessages[index].msg.replace(WARNINGINSERTS, function(m0, m1) {
        return arg[Number(m1)-1];
      })
    });
  };
  var getWarningPriority = function(rules) {
    // Inputs:
    //   rules: string
    // Returns:
    //   number
    var i,
        res = Infinity;
    for (i=0; i<warnings.length; i++) {
      if (rules === warnings[i].rules.join("\n")) {
        res = Math.min(res, warnings[i].index);
      }
    }
    return res;
  };
  var bestReplacement = function(redundantRule, rule) {
    // Inputs:
    //   redundantRule: parsed rule object
    //   rule: parsed rule object
    // Returns:
    //   nothing
    var both = {},
        current = redundant[redundantRule.filter];
    if (!current || current === rule.filter) {
      if (redundantRule.shim) {
        warn(29, [redundantRule.filter, rule.filter]);
      } else {
        redundant[redundantRule.filter] = rule.filter;
      }
    } else if (data.modifiers.matchWhitelist) {
      redundant[redundantRule.filter] += "\n" + rule.filter;
    } else {
      if (!secondTime) {
        both = startWorker({filters: rule.filter + "\n" + current, modifiers: data.modifiers}, true);
      }
      if (both[current] === rule.filter) {
        redundant[redundantRule.filter] = rule.filter;
      } else if (both[rule.filter] !== current) {
        if (rule.filter.length < current.length || (rule.filter.length === current.length && rule.filter < current)) {
          redundant[redundantRule.filter] = rule.filter;
        }
      }
    }
  };




  // ======================================================================== //
  // Removes included and excluded domains that are specified, but redundant in the own rule
  // Detects invalid domains
  // ======================================================================== //
  var checkForBrokenDomains = function(domains, line, options) {
    // Inputs:
    //   domains: array of strings
    //   line: string
    //   options: object with keys
    //     ignoreBroken: boolean
    //     syntax: syntax
    //     isExclude: boolean
    //     excludeOverride: array of strings
    // Returns:
    //   object with keys:
    //     include: array of strings
    //     exclude: array of strings
    //     status: status

    var i, j, siteParts, isSubdomain, hasCorrectInclude, excludedCheck,
        excluded=options.excludeOverride || [],
        included=[],
        domainInfo = [];

    for (i=0; i<domains.length; i++) {
      domainInfo.push({
        original: domains[i],
        parsed: domains[i].replace(WHITESPACE_G, "").toLowerCase()
      });
      // Unicode 00DF-00F6 and 00F8-00FF are characters with diacritic signs, etcetera...
      // Unicode 0430-044F are Cyrillic characters, 0621-063F and 0641-064A are Arabic, 0E01-0E3A and 0E40-0E5B are Thai,
      // 4E00-9FFF are chinese/CJK, etcetera... too much
      if (!options.ignoreBroken && !VALIDDOMAIN.test(domainInfo[i].parsed)) {
        if (domainInfo[i].parsed === "") {
          if (i === 0 && domains.join("").replace(WHITESPACE_G, "") === "") {
            warn(6, line, options.syntax === syntax.hiding ? "," : "|");
          } else if (i === 0) {
            warn(7, line, options.syntax === syntax.hiding ? "," : "|");
          } else if (i === domains.length - 1) {
            warn(9, line, options.syntax === syntax.hiding ? "," : "|");
          } else {
            warn(8, line, options.syntax === syntax.hiding ? "," : "|");
          }
        } else {
          warn(5, line, domainInfo[i].original);
        }
        return {status: status.INVALID};
      }

      if (options.syntax === syntax.blocking && DOTEND.test(domainInfo[i].parsed)) {
        domainInfo[i].parsed = domainInfo[i].parsed.replace(DOTEND, "");
        if (!options.ignoreBroken) {
          warn(61, line, domainInfo[i].original);
        }
      }

      if (domainInfo[i].parsed[0] === "~") {
        excluded.push(domainInfo[i].parsed.substring(1));
      } else {
        included.push(domainInfo[i].parsed);
      }
    }

    for (i=included.length-1; i>=0; i--) {
      siteParts = included[i];
      isSubdomain=false;
      while (SUBDOMAIN.test(siteParts)) {
        if (excluded.contains(siteParts)) {
          break;
        }
        if (!options.ignoreBroken && isObjectProperty(siteParts)) {
          return {status: status.IGNORE};
        }
        if (isSubdomain && included.contains(siteParts)) {
          if (!options.ignoreBroken) {
            if (options.isExclude) {
              warn(52, line, siteParts);
            } else {
              warn(53, line, siteParts);
            }
          }
          included.removeAt(i);
        } else if (!isSubdomain && included.indexOf(siteParts) !== included.lastIndexOf(siteParts)) {
          if (!options.ignoreBroken) {
            if (options.isExclude) {
              warn(48, line, siteParts);
            } else {
              warn(47, line, siteParts);
            }
          }
          included.removeAt(i);
        }
        siteParts = siteParts.replace(SUBDOMAIN, "");
        isSubdomain = true;
      }
    }
    if (excluded.length && !options.isExclude) {
      excludedCheck = checkForBrokenDomains(excluded, line, {ignoreBroken: options.ignoreBroken, syntax: options.syntax,
                                                             isExclude: true, excludeOverride: included});
      if (excludedCheck.status !== status.OK) {
        return {status: excludedCheck.status};
      }
      excluded = excludedCheck.include;
      if (included.length) {
        for (j=excluded.length-1; j>=0; j--) {
          hasCorrectInclude = false;
          siteParts = excluded[j];
          while (SUBDOMAIN.test(siteParts)) {
            if (included.contains(siteParts)) {
              if (siteParts === excluded[j]) {
                warn(4, line, siteParts);
                return {status: status.IGNORE};
              }
              hasCorrectInclude = true;
              break;
            }
            siteParts = siteParts.replace(SUBDOMAIN, "");
          }
          if (!hasCorrectInclude) {
            if (!options.ignoreBroken) {
              warn(39, line, excluded[j]);
            }
            excluded.removeAt(j);
          }
        }
      }
      return {include: included, exclude: excluded, status: status.OK};
    }
    return {include: included, exclude: [], status: status.OK};
  };


  startWorker.parseCSSSelector = function(selector) {
  // Inputs:
  //   selector: string
  // Returns:
  //   array of array of array of strings
    var current, match,
        stringChar = "",
        selectorIndex = 0,
        bracketCount = 0,
        bracketChar = "",
        selectorParts = [],
        depths = [],
        selectors = [],
        endOfSelectorPart = function() {
          if (selectorIndex) {
            selectorParts.push(selector.substring(0, selectorIndex));
            selector = selector.substring(selectorIndex);
            selectorIndex = 0;
          }
        },
        endOfDepth = function() {
          endOfSelectorPart();
          depths.unshift(selectorParts);
          selectorParts = [];
        },
        endOfSelector = function() {
          endOfDepth();
          selector = selector.trim();
          selectors.push(depths);
          depths = [];
        };

    selector = selector.trim();
    while (selector) {
      if (selector.length <= selectorIndex) {
        break;
      }
      current = selector[selectorIndex].replace(WHITESPACE, " ");

      // Strings between "" and ''
      if (stringChar) {
        switch (current) {
          case stringChar: {
            stringChar = "";
            break;
          }
          case "\\": {
            selectorIndex++;
            break;
          }
        }
        selectorIndex++;
        continue;
      }

      // Content inside () and []; beginnings of strings
      switch (current) {
        case "'": case "\"": {
          stringChar = current;
          selectorIndex++;
          continue;
        }
        case "(": case "[": {
          if (bracketChar && bracketChar === current) {
            bracketCount++;
          } else if (!bracketChar) {
            if (current === "[") {
              endOfSelectorPart();
            }
            bracketCount = 1;
            bracketChar = current;
          }
          selectorIndex++;
          continue;
        }
        case ")": case "]": {
          if ((bracketChar === "(" && current === ")") || (bracketChar === "[" && current === "]")) {
            bracketCount--;
            if (bracketCount === 0) {
              bracketChar = "";
            }
          }
          selectorIndex++;
          continue;
        }
        default: {
          if (bracketChar) {
            selectorIndex++;
            continue;
          }
        }
      }

      // CSS identifiers
      match = selector.substring(selectorIndex).match(H_IDENTIFIERSTART);
      if (!match && current === "*") {
        match = ["*"];
      }
      if (match) {
        selectorIndex += match[0].length;
        if (WHITESPACE.test(match[0][match[0].length-1]) && H_IDENTIFIERENDSPACE.test(match[0])) {
          selector = selector.substring(0, selectorIndex-1) + selector.substring(selectorIndex);
          selectorIndex -= 1;
        }
        if (selector[selectorIndex] !== "(" && selector[selectorIndex] !== "|") {
          endOfSelectorPart();
        }
        continue;
      }

      // ids, classes, pseudoclasses, pseudoselectors, treeselectors, combinators
      switch (current) {
        case "#": case ".": case ":": {
          endOfSelectorPart();
          if (current === ":" && selector[selectorIndex+1] === ":") {
            selectorIndex++;
          }
          selectorIndex++;
          continue;
        }
        case " ": case ">": case "+": case "~": case ",": {
          endOfSelectorPart();
          match = selector.match(H_TREESELECTORCOMMASTART);
          selectorIndex += match[0].length;
          if (match[0].trim() === ",") {
            endOfSelector();
          } else {
            endOfDepth();
          }
          continue;
        }
      }

      selectorIndex++;
    }
    endOfSelector();
    return selectors;
  };

  // ======================================================================== //
  // Searches for errors in the hiding rule.
  // Parses the hiding rule into individual selectors
  // ======================================================================== //
  var generalizeCSSSelector = function(rule, is_notpseudoselector_content, line, noChangeSuggestions) {
    // Inputs:
    //   rule: array of array of objects|strings
    //   is_notpseudoselector_content: boolean
    //   line: string
    //   noChangeSuggestions: boolean
    // Returns:
    //   object {value: [[Array] or String], status: [status]}
    var i, j, depth, current, match, next, hasNodeName, currentDepth, constValue, nValue, workerResults,
        isGoodNotSelector, nSplit, otherSelector, bracketIndexI, lastPlusIndexI, redundantSelector, ruleSelector,
        redundantParsed, ruleParsed, mutuallyRedundant, converted,
        result = [],
        indepthRedundancyFilter = function(item) {
          return item !== "*" && item !== ">" && item !== "+" && item !== " " && item !== "~";
        };

    if (is_notpseudoselector_content && rule.length !== 1) {
      return {status: status.INVALID};
    }
    for (depth=0; depth<rule.length; depth++) {
      currentDepth = rule[depth].clone();
      if (currentDepth.length === 0) {
        return {status: status.INVALID};
      }
      if (is_notpseudoselector_content && currentDepth.length > 1) {
        return {status: status.INVALID};
      }
      result[depth] = [];

      // Check the individual items
      for (i=0; i<currentDepth.length; i++) {
        current = currentDepth[i];
        if (H_TREESELECTORCOMMA.test(current)) {
          current = current.trim() || " ";
        }
        next = currentDepth[i+1];
        switch (current[0]) {
          case "#": {
            match = current.match(H_IDSELECTOR);
            if (match) {
              result[depth].push("[id='" + current.substring(1) + "']");
              break;
            }
            return {status: status.INVALID};
          }
          case ".": {
            match = current.match(H_CLASSSELECTOR);
            if (match) {
              result[depth].push("[class~='" + current.substring(1) + "']");
              break;
            }
            return {status: status.INVALID};
          }
          case "[": {
            match = current.match(H_ATTRSELECTORNOVALUE);
            if (match) {
              match[1] = (!match[1] || match[1] === "|") ? "" : match[1].toLowerCase(); // namespace
              match[2] = match[2].toLowerCase(); // attr
              result[depth].push("[" + match[1] + match[2] + "]");
              break;
            }

            match = current.match(H_ATTRDOUBLEQUOTESSELECTOR) || current.match(H_ATTRSINGLEQUOTESSELECTOR) || current.match(H_ATTRNOQUOTESSELECTOR);
            if (match) {
              match[1] = (!match[1] || match[1] === "|") ? "" : match[1].toLowerCase(); // namespace
              match[2] = match[2].toLowerCase(); // attr
              match[3] = (match[4] || "") + "='" + match[5] + "'"; // operator+value
              result[depth].push("[" + match[1] + match[2] + match[3] + "]");

              if (match[4] === "~" && WHITESPACE.test(match[5].replace(H_IDENTIFIER, ""))) {
                return {status: status.DISCARD, value: current};
              }

              if (match[2] === "id" && H_ATTRIDSELECTOR.test("[" + match[2] + match[3] + "]")) {
                if (line && !noChangeSuggestions) {
                  warn(54, line, [current, "#" + match[5]]);
                }
              } else if (H_ATTRCLASSSELECTOR.test("[" + match[2] + match[3] + "]")) {
                if (line && !noChangeSuggestions && match[4] === "~") {
                  warn(54, line, [current, "." + match[5]]);
                }
              }
              break;
            }
            return {status: status.INVALID};
          }
          case ":": {
            match = current.match(H_PSEUDOCLASSSELECTOR);
            if (match) {
              match[1] = match[1].toLowerCase();
              switch (match[1]) {
                case "not": {
                  if (is_notpseudoselector_content || !match[2] || !match[2].trim()) {
                    return {status: status.INVALID};
                  }
                  isGoodNotSelector = prepareHidingRule(match[2], true, line, noChangeSuggestions);
                  if (isGoodNotSelector.status === status.OK) {
                    result[depth].push(":not(" + JSON.stringify(isGoodNotSelector.rules[0][0]) + ")");
                    break;
                  }
                  if (isGoodNotSelector.status === status.DISCARD) {
                    if (line && !noChangeSuggestions) {
                      if (i > 0 || (next && !H_TREESELECTORCOMMA.test(next))) {
                        warn(45, line, current);
                      } else {
                        warn(46, line, current);
                      }
                    }
                    break;
                  }
                  if (isGoodNotSelector.status === status.IGNORE) {
                    return {status: status.IGNORE};
                  }
                  return {status: status.INVALID};
                }

                case "nth-of-type": case "nth-last-of-type": case "nth-child": case "nth-last-child": {
                  if (!match[2] || !H_NTHPSEUDOCONTENT.test(match[2])) {
                    return {status: status.INVALID};
                  }
                  match[2] = match[2].replace(WHITESPACE_G, "").toLowerCase();
                  if (match[2] === "odd") {
                    match[2] = "2n+1";
                  } else if (match[2] === "even") {
                    match[2] = "2n";
                  }

                  nSplit = match[2].split("n");
                  nValue = 0;
                  constValue = 0;
                  if (nSplit.length === 1) {
                    constValue = Number(match[2]);
                  } else {
                    if (nSplit[1]) {
                      constValue = Number(nSplit[1]);
                    }
                    if (!nSplit[0] || nSplit[0] === "+" || nSplit[0] === "-") {
                      nValue = Number(nSplit[0] + "1");
                    } else {
                      nValue = Number(nSplit[0]);
                    }
                  }

                  if (isInaccurateNumber(nValue) || isInaccurateNumber(constValue)) {
                    return {status: status.IGNORE};
                  }
                  nValue = Number(nValue);
                  constValue = Number(constValue);

                  if (nValue > 0 && constValue <= 0) {
                    while (constValue <= 0) {
                      constValue += nValue;
                    }
                  } else if (nValue < 0 && constValue > 0 && constValue + nValue <= 0) {
                    nValue = 0;
                  } else if (nValue <= 0 && constValue <= 0) {
                    return {status: status.DISCARD, value: current};
                  }

                  result[depth].push(":" + match[1] + "(" + nValue + "n+" + constValue + ")");
                  break;
                }
                case "lang": {
                  if (!match[2] || !H_LANGPSEUDOCONTENT.test(match[2])) {
                    return {status: status.INVALID};
                  }
                  match = match[2].trim().toLowerCase().match(H_LANGPSEUDOCONTENTSPLITTER_G);
                  for (j=0; j<match.length; j++) {
                    result[depth].push(":lang(" + match[0] + ")");
                    match[0] += match[j+1];
                  }
                  break;
                }
                case ":first-line": case ":first-letter": case ":before": case ":after": // CSS3 pseudo-elements
                case ":value": case ":choices": case ":repeat-item": case ":repeat-index": // CSS3UI "at risk": may be dropped
                case "after": case "before": case "first-letter": case "first-line": case ":selection": {// Unofficial
                  if (is_notpseudoselector_content || match[2] || (next && !H_TREESELECTORCOMMA.test(next))) {
                    return {status: status.INVALID};
                  }
                  return {status: status.DISCARD, value: current};
                }
                case "first-child": case "last-child": case "first-of-type": case "last-of-type": {
                  if (match[2]) {
                    return {status: status.INVALID};
                  }
                  result[depth].push(":nth-" + match[1].replace("first-", "") + "(0n+1)");
                  break;
                }
                case "only-child": case "only-of-type": {
                  if (match[2]) {
                    return {status: status.INVALID};
                  }
                  result[depth].push(":" + match[1].replace("only", "nth") + "(0n+1)",
                                     ":" + match[1].replace("only", "nth-last") + "(0n+1)");
                  break;
                }
                case "empty": case "root": case "active": case "hover": case "focus": // CSS3
                case "target": case "enabled": case "disabled": case "checked": case "visited": case "link": // CSS3 http://www.w3.org/TR/selectors/
                case "indeterminate": case "default": case "valid": case "invalid": case "in-range": // CSS3UI
                case "out-of-range": case "required": case "optional": case "read-only": case "read-write": {// CSS3UI http://www.w3.org/TR/css3-ui/
                  if (match[2]) {
                    return {status: status.INVALID};
                  }
                  result[depth].push(":" + match[1]);
                  break;
                }
                default: {
                  if (!H_BROWSERPSEUDOSELECTOR.test(match[1])) {
                    return {status: status.INVALID};
                  }
                  result[depth].push(":" + match[1] + (match[2] ? "(" + match[2] + ")" : ""));
                }
              }
              break;
            }
            return {status: status.INVALID};
          }
          case " ": case ">": case "~": case "+": {
            if (i !== 0) {
              result[depth].push(current);
              break;
            }
            return {status: status.INVALID};
          }
          case ",": {
            if (i !== 0) {
              break;
            }
            return {status: status.INVALID};
          }
          default: {
            match = current.match(H_NODENAMESELECTOR);
            if (match && i === 0) {
              hasNodeName = true;
              if (current === "*|*") {
                break;
              }
              if (current === "*" && !noChangeSuggestions && line && next && !H_TREESELECTORCOMMA.test(next)) {
                warn(58, line, next);
              }
              if (!match[1]) {
                result[depth].push(match[2].toLowerCase());
                result[depth].push("*|" + match[2].toLowerCase());
                if (match[2] !== "*") {
                  result[depth].push("*");
                }
              } else {
                result[depth].push(current.toLowerCase());
                if (match[2] !== "*") {
                  result[depth].push(match[1].toLowerCase() + "*");
                }
                if (match[1] !== "*|") {
                  result[depth].push("*|" + match[2].toLowerCase());
                }
              }
              break;
            }
            return {status: status.INVALID};
          }
        }
      }
      if (!hasNodeName) {
        result[depth].push("*");
      } else {
        hasNodeName = false;
      }

      currentDepth.removeAt(currentDepth.indexOf("*|*"));
      result[depth].removeAt(result[depth].indexOf("*|*"));

      // Check if :not(...) selectors make matching impossible
      if (!secondTime) {
        for (i=0; i<currentDepth.length; i++) {
          if (currentDepth[i].toLowerCase().startsWith(":not(")) {
            for (j=0; j<currentDepth.length; j++) {
              if (i === j) {
                otherSelector = "##*|* *|*";
              } else if (currentDepth[j].toLowerCase().startsWith(":not(")) {
                continue;
              } else {
                otherSelector = "##*|* " + currentDepth[j];
              }
              workerResults = startWorker({filters: "##" + currentDepth[i].substring(5, currentDepth[i].length-1) + "\n" + otherSelector}, true);
              if (workerResults.hasOwnProperty(otherSelector)) {
                return {status: status.DISCARD, value: depth};
              }
            }
          }
        }
      }

      // Check if :nth-...(...) selectors make matching impossible
      for (i=0; i<result[depth].length; i++) {
        if (result[depth][i].startsWith(":nth-") && result[depth][i].contains("(0n+")) {
          bracketIndexI = result[depth][i].indexOf("(");
          lastPlusIndexI = result[depth][i].lastIndexOf("+");
          for (j=0; j<result[depth].length; j++) {
            if (i !== j && result[depth][j].substring(0, bracketIndexI) === result[depth][i].substring(0, bracketIndexI)) {
              constValue = Number(result[depth][i].substring(lastPlusIndexI, result[depth][i].length - 1))
                               - Number(result[depth][j].substring(result[depth][j].lastIndexOf("+"), result[depth][j].length - 1));
              nValue = Number(result[depth][j].substring(bracketIndexI + 1, lastPlusIndexI - 1));
              if (constValue < 0 || (nValue > 0 && constValue % nValue !== 0)) {
                return {status: status.DISCARD, value: depth};
              }
            }
          }
        }
      }

      // Filter out the internal redundancies. Who needs them anyway?
      if (!secondTime) {
        workerResults = startWorker({filters: ("##" + currentDepth.filter(indepthRedundancyFilter).join("\n##"))}, true);
        if (line && !noChangeSuggestions) {
          for (i in workerResults) {
            redundantSelector = workerResults[i].substring(2);
            ruleSelector = i.substring(2);
            redundantParsed = generalizeCSSSelector([[redundantSelector]], is_notpseudoselector_content, undefined, true).value[0];
            ruleParsed = generalizeCSSSelector([[ruleSelector]], is_notpseudoselector_content, undefined, true).value[0];
            mutuallyRedundant = redundantParsed.length === ruleParsed.length;
            if (mutuallyRedundant) {
              for (j=0; j<redundantParsed.length; j++) {
                if (redundantParsed[j] !== ruleParsed[j]) {
                  mutuallyRedundant = false;
                  break;
                }
              }
            }
            if (mutuallyRedundant) {
              // startWorker was called with secondTime=true, and in this context the redundant rule is the one that should stay
              warn(51, line, [ruleSelector, redundantSelector]);
            } else {
              warn(51, line, [redundantSelector, ruleSelector]);
            }
          }
        }
        while (!startWorker.isEmptyObject(workerResults)) {
          redundantSelector = workerResults[Object.keys(workerResults)[0]].substring(2);
          currentDepth.removeAt(currentDepth.indexOf(redundantSelector));
          redundantParsed = generalizeCSSSelector([[redundantSelector]], is_notpseudoselector_content, undefined, true).value[0];
          for (j=0; j<redundantParsed.length; j++) {
            if (redundantParsed[j] !== "*") {
              result[depth].removeAt(result[depth].indexOf(redundantParsed[j]));
            }
          }
          workerResults = startWorker({filters: ("##" + currentDepth.filter(indepthRedundancyFilter).join("\n##"))}, true);
        }
      }

      // Filter out impossible combinations of attribute selectors (including #id and .class)
      if (!secondTime) {
        converted = getSelectorsForMatching([result[depth]]);
        if (isCSSimpossibleCombination(converted.attr[0], converted.attr[0], true)) {
          return {status: status.DISCARD, value: depth};
        }
      }
    }
    return {status: status.OK, value: result};
  };



  var isCSSimpossibleCombination = function(redRuleAttr, ruleAttr, skipIisJ) {
    // Inputs:
    //   redRuleAttr: array of objects
    //   ruleAttr: array of objects
    //   skipIisJ: boolean
    // Returns:
    //   boolean
    var i, j;
    for (j=0; j<ruleAttr.length; j++) {
      for (i=0; i<redRuleAttr.length; i++) {
        if (i===j && skipIisJ) {
          continue;
        }
        if (redRuleAttr[i].attr !== ruleAttr[j].attr) {
          continue;
        }
        if (redRuleAttr[i].operator === "="
            || ((redRuleAttr[i].operator === "^" || redRuleAttr[i].operator === "$" || redRuleAttr[i].operator === "|")
                && redRuleAttr[i].operator === ruleAttr[j].operator)
            || (redRuleAttr[i].operator === "|" && ruleAttr[j].operator === "^")) {
          if (redRuleAttr[i].namespace === ruleAttr[j].namespace || redRuleAttr[i].namespace === "*|" || ruleAttr[j].namespace === "*|") {
            return true;
          }
        }
      }
    }
    return false;
  };



  var prepareHidingRule = function(rule, is_notpseudoselector_content, line, noChangeSuggestions) {
    // Inputs:
    //   rule: string
    //   is_notpseudoselector_content: boolean
    //   line: string
    //   noChangeSuggestions: boolean
    // Returns:
    //   object {rules: [Array], status: [status]}

    var i, j, badSelector, generalized, workerResults,
        result = [],
        joinedDepth = "",
        joinedRules = [],
        parsed = startWorker.parseCSSSelector(rule);

    if (parsed.length > 1 && !is_notpseudoselector_content && !secondTime) {
      for (i=0; i<parsed.length; i++) {
        for (j=parsed[i].length-1; j>=0; j--) {
          joinedDepth += parsed[i][j].join("");
        }
        if (i !== parsed.length-1) {
          joinedDepth = joinedDepth.substring(0, joinedDepth.length - parsed[i][0][parsed[i][0].length-1].length);
        }
        joinedRules.push("##" + joinedDepth);
        joinedDepth = "";
      }
      do {
        workerResults = startWorker({filters: joinedRules.join("\n")}, true);
        for (i in workerResults) {
          parsed.removeAt(joinedRules.indexOf(i));
          joinedRules.removeAt(joinedRules.indexOf(i));
          if (line && !noChangeSuggestions) {
            warn(50, line, [i.substring(2), workerResults[i].substring(2)]);
          }
        }
      } while (!startWorker.isEmptyObject(workerResults) && parsed.length > 1);
    }

    for (i=0; i<parsed.length; i++) {
      generalized = generalizeCSSSelector(parsed[i], is_notpseudoselector_content, line, noChangeSuggestions);
      switch (generalized.status) {
        case status.OK: {
          result.push(generalized.value);
          break;
        }
        case status.INVALID: {
          return {status: status.INVALID};
        }
        case status.IGNORE: {
          return {status: status.IGNORE};
        }
        case status.DISCARD: {
          badSelector = generalized.value;

          if (typeof badSelector === "number") {
            badSelector = parsed[i][badSelector];
            if (H_TREESELECTORCOMMA.test(badSelector[badSelector.length-1])) {
              badSelector.removeAt(badSelector.length-1);
            }
            badSelector = badSelector.join("");
          }

          if (line && !is_notpseudoselector_content && !noChangeSuggestions) {
            warn(13, line, badSelector);
          }
          break;
        }
      }
    }
    if (result.length === 0) {
      if (line && !is_notpseudoselector_content && badSelector && noChangeSuggestions) {
        warn(13, line, badSelector);
      }
      return {status: status.DISCARD};
    }
    return {status: status.OK, rules: result};
  };

  var getSelectorsForMatching = function(parsedRule) {
    // Inputs:
    //   parsedRule: array of array of strings
    // Returns:
    //   object of array of array of strings|objects
    var attrmatch, j, k, l,
        selectors = {
          literal: [],
          tree: [],
          attr: [],
          nth: [],
          not: []
        },
        sortfn = function(a, b) {
          var scoreA, scoreB,
              scoretable = ["*", "[", undefined, "|", ".", ":", "#"];
          if (a[0] !== b[0]) {
            scoreA = scoretable.indexOf(a[0]);
            scoreB = scoretable.indexOf(b[0]);
            scoreA = scoreA < 0 ? 2 : scoreA;
            scoreB = scoreB < 0 ? 2 : scoreB;
          }
          if (scoreA === scoreB) {
            if (a.length === b.length) {
              return a > b ? 1 : -1;
            }
            return a.length > b.length ? 1 : -1;
          }
          return scoreA > scoreB ? -1 : 1;
        };
    for (j=0; j<parsedRule.length; j++) {
      selectors.attr.push([]);
      selectors.literal.push([]);
      selectors.nth.push([]);
      selectors.not.push([]);
      for (k=0; k<parsedRule[j].length; k++) {
        l = parsedRule[j][k];
        if (l[0] === "[" && H_LOOSEATTRIBUTEVALUESELECTOR.test(l)) {
          attrmatch = l.match(H_LOOSEATTRIBUTEVALUESELECTOR);
          selectors.attr[j].push({
            attr: attrmatch[2],
            namespace: attrmatch[1] || "",
            operator: attrmatch[4] || "=",
            value: attrmatch[5],
            withoutValue: false
          });
        } else if (l[0] === "[") {
          attrmatch = l.match(H_ATTRSELECTORNOVALUE);
          selectors.attr[j].push({
            attr: attrmatch[2],
            namespace: attrmatch[1] || "",
            withoutValue: true
          });
        } else if (l.length === 1 && H_TREESELECTORCOMMA.test(l)) {
          selectors.tree.push(l);
        } else if (l.startsWith(":nth-")) {
          selectors.nth[j].push({
            name: l.substring(1, l.indexOf("(")),
            nValue: Number(l.substring(l.indexOf("(") + 1, l.lastIndexOf("n"))),
            constValue: Number(l.substring(l.lastIndexOf("n") + 1, l.length - 1))
          });
        } else if (l.startsWith(":not(")) {
          selectors.not[j].push(JSON.parse(l.substring(5, l.length - 1)));
        } else {
          selectors.literal[j].push(l);
        }
      }
    }
    for (j=0; j<selectors.literal.length; j++) {
      selectors.literal[j].sort(sortfn);
    }
    return selectors;
  };




  // ======================================================================== //
  // Place the hiding rules in the right categories
  // ======================================================================== //
  var sortHidingIntoCategories = function(line, shimMatch, shimParsedRule) {
    // Inputs:
    //   line: string
    //   shimMatch: array of strings
    //   shimParsedRule: parsed rule object
    // Returns:
    //   nothing
    var object, j, r, sites,
        match = shimMatch || line.match(ELEMHIDE),
        parsedRule = shimParsedRule || prepareHidingRule(match[3]).rules;

    if (parsedRule.length > 1 && !match[2]) {
      for (r=0; r<parsedRule.length; r++) {
        sortHidingIntoCategories(line, match, parsedRule.slice(r, r+1));
      }
      return;
    }

    object = {
      selectors: match[2] ? {} : getSelectorsForMatching(parsedRule[0]),
      excludedDomains: [],
      includedDomains: [],
      isWhitelist: (match[2] || data.modifiers.matchWhitelist ? true : false),
      syntax: syntax.hiding,
      filter: line,
      ruleString: match[3].trim(),
      shim: shimMatch ? true : false
    };
    if (!match[1] || data.modifiers.ignoreDomains) {
      h_global.push(object);
      return;
    }
    sites = checkForBrokenDomains(match[1].split(","), line, {ignoreBroken: true, syntax: syntax.hiding});
    if (!sites.include.length) {
      object.excludedDomains = sites.exclude;
      h_global.push(object);
      return;
    }
    object.includedDomains = sites.include;
    object.excludedDomains = sites.exclude;
    object.id = id++;
    h_siteSpecific.push(object);
    for (j=0; j<sites.include.length; j++) {
      if (h_siteCollection.hasOwnProperty(sites.include[j])) {
        h_siteCollection[sites.include[j]].push(object);
      } else {
        h_siteCollection[sites.include[j]] = [object];
      }
    }
  };




  // ======================================================================== //
  // Search for errors in the blocking rule options
  // Parse the blocking options
  // ======================================================================== //
  var prepareBlockingOptions = function(options, line, isWhitelistRule, noWarnings) {
    // Inputs:
    //   options:
    //   line: string
    //   isWhitelistRule: boolean
    //   noWarnings: boolean
    // Returns:
    //   {ruleOptions, allowed, status}
    var i, currentOption, isInverse, hasValue, allowedTypes, index,
        normalizedOptions = [],
        typeOptions = [],
        ruleOptions = {};

    if (options && !data.modifiers.ignoreOptions) {
      options = options.substring(1).split(",");
      for (i=0; i<options.length; i++) {
        hasValue = options[i].contains("=");

        // Is the option value build up from multiple options? The ABP regex allows $ in values, so...
        if (hasValue && !noWarnings) {
          index = options[i].lastIndexOf("$");
          if (index > -1 && prepareBlockingOptions(options[i].substring(index), line, isWhitelistRule, true).status !== status.INVALID) {
            if (prepareBlockingOptions("$" + options[i].substring(0, index - 1), line, isWhitelistRule, true).status === status.INVALID) {
              warn(18, line, [options[i].substring(index + 1), options[i]]);
            } else {
              warn(21, line, "$");
            }
          }
        }

        currentOption = options[i].toLowerCase().replace(DASH_G, "_").replace(B_OPTIONVALUE, "");
        isInverse = currentOption[0] === "~";
        if (isInverse) {
          currentOption = currentOption.substring(1);
        }

        // Filter out invalid/unknown options
        if (!Types.hasOwnProperty(currentOption) && !knownOptions.contains(currentOption) && !deprecated.hasOwnProperty(currentOption)) {
          if (!noWarnings) {
            warn(19, line, options[i]);
          }
          return {status: status.INVALID};
        }

        // Check if the option=value syntax is allowed or required
        if (hasValue && !["domain", "sitekey"].contains(currentOption)) {
          warn(11, line, currentOption);
          return {status: status.INVALID};
        }
        if (!hasValue && ["domain", "sitekey"].contains(currentOption)) {
          if (!noWarnings) {
            warn(10, line, currentOption);
          }
          return {status: status.INVALID};
        }

        // Check if the ~inverse is allowed
        if (isInverse) {
          if (["domain"].contains(currentOption)) {
            if (!noWarnings) {
              warn(12, line, currentOption);
            }
            return {status: status.DISCARD};
          }
          if (["match_case"].contains(currentOption)) {
            if (!noWarnings) {
              warn(41, line, currentOption);
            }
          } else if (["sitekey"].contains(currentOption)) {
            if (!noWarnings) {
              warn(41, line, currentOption);
            }
            return {status: status.DISCARD};
          }
        }

        // Check if the option is allowed or disallowed in whitelist rules
        if (isWhitelistRule && ["collapse"].contains(currentOption)) {
          if (!noWarnings) {
            warn(43, line, currentOption);
          }
          continue;
        }
        if (!noWarnings && !isWhitelistRule && !isInverse && ["document", "elemhide"].contains(currentOption)) {
          warn(38, line, currentOption);
        }

        // Check for deprecated options
        if (deprecated.hasOwnProperty(currentOption)) {
          if (!deprecated[currentOption]) {
            if (!noWarnings) {
              warn(28, line, currentOption);
            }
            return {status: status.INVALID};
          } else if (!noWarnings) {
            warn(44, line, [currentOption, deprecated[currentOption]]);
          }
        }

        normalizedOptions.push((isInverse ? "~" : "") + currentOption);
      }
    }

    for (i=0; i<normalizedOptions.length; i++) {
      currentOption = normalizedOptions[i];
      isInverse = currentOption[0] === "~";
      // Warn about duplicates
      if (normalizedOptions.lastIndexOf(currentOption) > i) {
        if (["domain", "sitekey"].contains(currentOption)) {
          if (!noWarnings) {
            warn(20, line, currentOption);
          }
          return {status: status.DISCARD};
        }
        if (!noWarnings) {
          warn(49, line, currentOption);
        }
      }

      // Warn about contradicting options
      if (!noWarnings && knownOptions.contains(currentOption) && normalizedOptions.contains("~" + currentOption)) {
        warn(27, line, currentOption);
      }

      // Process the resource type options
      if (Types.hasOwnProperty(currentOption.replace(TILDESTART, ""))) {
        if (isInverse) {
          if (allowedTypes === undefined) {
            allowedTypes = Types.ALL & ~(Types.elemhide | Types.document | Types.popup);
          } else if (normalizedOptions.indexOf(currentOption) === normalizedOptions.lastIndexOf(currentOption)
                     && !(allowedTypes & Types[currentOption.replace(TILDESTART, "")]) && !noWarnings) {
            warn(40, line, currentOption);
          }
          allowedTypes &= ~Types[currentOption.replace(TILDESTART, "")];
        } else {
          allowedTypes = allowedTypes || 0;
          if (normalizedOptions.indexOf(currentOption) === normalizedOptions.lastIndexOf(currentOption)
              && (allowedTypes & Types[currentOption]) && !noWarnings) {
            warn(40, line, currentOption);
          }
          allowedTypes |= Types[currentOption];
        }
        typeOptions.push(currentOption);
      }

      ruleOptions[currentOption.replace(TILDESTART, "")] = (isInverse ? -1 : 1);
    }

    // $document implies $elemhide
    if (!isWhitelistRule && (allowedTypes & (Types.elemhide | Types.document))) {
      allowedTypes = allowedTypes & ~(Types.elemhide | Types.document);
      if (allowedTypes === 0) {
        return {status: status.DISCARD};
      }
    } else if (allowedTypes & Types.document) {
      if (allowedTypes & Types.elemhide) {
        if (!noWarnings) {
          warn(40, line, "elemhide");
        }
      } else {
        if (!noWarnings && (typeOptions.indexOf("~elemhide") > 0 || (typeOptions.length === 1 && typeOptions[0] === "~elemhide"))) {
          warn(40, line, "~elemhide");
        }
        allowedTypes |= Types.elemhide;
      }
    }

    // If no types have been specified or all types have cancelled each other
    if (allowedTypes === undefined) {
      allowedTypes = Types.ALL & ~(Types.elemhide | Types.document | Types.popup);
    } else if (allowedTypes === 0) {
      if (!noWarnings) {
        warn(15, line);
      }
      return {status: status.DISCARD};
    }

    // Find type options that cancel each other
    if (!noWarnings) {
      for (i=0; i<typeOptions.length; i++) {
        if (i !== 0 && typeOptions[i][0] === "~" && (allowedTypes & Types[typeOptions[i].substring(1)])) {
          if (typeOptions[0] === typeOptions[i]) {
            warn(42, line, typeOptions[i]);
          } else {
            warn(40, line, typeOptions[i]);
          }
        } else if (typeOptions[i][0] !== "~" && !(allowedTypes & Types[typeOptions[i]])) {
          if (i === 0 && typeOptions[1][0] === "~") {
            warn(66, line, ["~" + typeOptions[i], typeOptions[i]]);
          } else {
            warn(40, line, typeOptions[i]);
          }
        }
      }
    }

    // Ignore the sitekey option
    if (ruleOptions.sitekey) {
      return {status: status.IGNORE};
    }

    // Ignore these new options until they're released
    if (ruleOptions.genericblock || ruleOptions.generichide) {
      return {status: status.IGNORE};
    }

    return {ruleOptions: ruleOptions, allowed: allowedTypes, status: status.OK};
  };




  // ======================================================================== //
  // Put the blocking (and whitelisting) rules in the right categories
  // ======================================================================== //
  var sortBlockingIntoCategories = function(line) {
    // Inputs:
    //   line: string
    // Returns:
    //   nothing
    var j, object, keys, sites, blockingoptions, firstlast,
        match = line.replace(WHITESPACE_G, "").match(BLOCKING),
        escapeCharacter = function(m) {
          if (data.modifiers.loosely) {
            if (B_ROOFTOPCHARACTERS.test(m)) {
              return "(?:\\"+ m + "|^^^)";
            }
          }
          return "\\" + m;
        },
        getKeys = function(str) {
          var i,
              key = "",
              keys = [],
              recording = false;
          str = str.toLowerCase();
          for (i=0; i<str.length; i++) {
            if (B_KEYCHARACTERS.test(str[i])) {
              if (recording) {
                key += str[i];
              }
            } else if (str[i] === "*") {
              key = "";
              recording = false;
            } else {
              if (key.length >= 4 && !isObjectProperty(key)) {
                keys.push(key);
              }
              key = "";
              recording = true;
            }
          }
          return keys;
        };

    blockingoptions = prepareBlockingOptions(match[3], line, match[1] === "@@");
    if (blockingoptions.status !== status.OK) {
      return;
    }
    delete blockingoptions.status;
    object = {
      options: blockingoptions,
      excludedDomains: [],
      includedDomains: [],
      isWhitelist: (match[1] || data.modifiers.matchWhitelist ? true : false),
      isRegex: false,
      string: "",
      syntax: syntax.blocking,
      filter: line,
      domainstart: false
    };

    if (B_REGEX.test(match[2])) {
      try {
        object.rule = new RegExp(match[2].substring(1, match[2].length - 1), blockingoptions.ruleOptions.match_case === 1 ? "" : "i");
      } catch(ex) {
        warn(2, line);
        return;
      }
      if (PROBABLYNOTREGEX.test(match[2])) {
        object.string = match[2].substring(1, match[2].length - 1);
      } else {
        object.isRegex = true;
      }
    } else {
      firstlast = match[2][0] + match[2][match[2].length-1];
      match[2] = match[2]
                   .replace(MANYSTARS_G, "*")
                   .replace(B_USELESSFILTEREND, "*")
                   .replace(B_USELESSFILTERSTART, "*");
      object.rule = new RegExp(match[2]
                         .replace(ESCAPECHAR_G, escapeCharacter)
                         .replace(ESCAPEDSTAR_G, ".*")
                         .replace(ESCAPEDROOFTOPEND, function(match) {
                           return "[^\\-\\.\\%a-zA-Z0-9_\\*\\u0080-\\uFFFFFF]{0," + (match.length/2-1) + "}\\|";
                         })
                         .replace(ESCAPEDROOFTOPSTART, "[^\\-\\.\\%a-zA-Z0-9_\\|\\*\\u0080-\\uFFFFFF]")
                         .replace(ESCAPEDROOFTOP_G, "[^\\-\\.\\%a-zA-Z0-9_\\*\\u0080-\\uFFFFFF]")
                         .replace(B_TRIPLEROOFTOP_G, "|\\^)")
                         .replace(TWOESCAPEDPIPES, "\\|(?:[a-zA-Z0-9_\\-]+\\:\\/+|\\|)(?:[^\\.\\/\\^\\*]+\\.)*?")
                         .replace(ONEESCAPEDPIPE, data.modifiers.loosely ? "^\\|?" : "^\\|")
                         .replace(ESCAPEDPIPEFINAL, data.modifiers.loosely ? "(?:\\||\\^)?$" : "\\|$")
                         .replace(B_STARTWILDCARDPIPE_G, ".+\\|")
                         .replace(B_ENDWILDCARDPIPE_G, "|.+")
                         .replace(B_USELESSWILDCARD_G, "")
                         || ".*", blockingoptions.ruleOptions.match_case === 1 ? "" : "i");
      object.string = match[2]
                .replace(B_STARTWILDCARDPIPE_G, "**|")
                .replace(B_ENDWILDCARDPIPE_G, "|**")
                .replace(B_USELESSSTAR_G, "");
      if (object.string.startsWith("||")) {
        object.domainstart = {
          dot: object.string.replace("||", "."),
          slash: object.string.replace("||", "/")
        };
      }
      if (object.string && firstlast[0] === "*" && object.string[0] !== "*" && (firstlast === "**" || !B_REGEX.test(object.string))
          && !COMMENTLINE.test(object.string) && !(!object.isWhitelist && object.string[0] === "@" && object.string[1] === "@")) {
        warn(59, line);
      } else if (object.string && (firstlast[1] === "*" && object.string[object.string.length-1] !== "*" && !B_REGEX.test(object.string))) {
        warn(62, line);
      }
    }
    keys = (object.isRegex || data.modifiers.loosely) ? [] : getKeys(object.string);
    if (keys.length) {
      for (j=0; j<keys.length; j++) {
        if (b_keyCollection.hasOwnProperty(keys[j])) {
          b_keyCollection[keys[j]].push(object);
        } else {
          b_keyCollection[keys[j]] = [object];
        }
      }
      b_withkey.push(object);
    } else {
      b_withoutkey.push(object);
    }

    if (match[3] && B_DOMAINIS.test(match[3]) && !data.modifiers.ignoreDomains) {
      sites = checkForBrokenDomains(match[3].match(B_DOMAINIS)[1].split("|"), line, {ignoreBroken: true, syntax: syntax.blocking});
      object.includedDomains = sites.include;
      object.excludedDomains = sites.exclude;
      for (j=0; j<sites.include.length; j++) {
        if (b_siteCollection.hasOwnProperty(sites.include[j])) {
          b_siteCollection[sites.include[j]].push(object);
        } else {
          b_siteCollection[sites.include[j]] = [object];
        }
      }
    }
  };


  var getMatchingDomains = function(ruleIncluded, ruleExcluded, redRuleIncluded, redRuleExcluded, addDomains) {
    // Inputs:
    //   ruleIncluded: array of strings
    //   ruleExcluded: array of strings
    //   redRuleExcluded: array of strings
    //   redRuleExcluded: array of strings
    //   addDomains: array of strings
    // Returns:
    //   object {domainlist, matchingDomains, isRedundant}
    var topDomain, i,
        matchingDomains = [],
        isRedundant = true,
        domainlist = {
          ALL: {
            matchedByRedundantRule: redRuleIncluded.length === 0,
            matchedByRule: ruleIncluded.length === 0,
            name: "ALL",
            children: [],
            parent: null
          }
        },
        allDomains = [].concat(ruleIncluded, ruleExcluded, redRuleIncluded, redRuleExcluded, addDomains || []).unique(),
        setMatched = function(child) {
          var i;
          if (child.name !== "ALL") {
            if (redRuleIncluded.contains(child.name)) {
              child.matchedByRedundantRule = true;
            } else if (redRuleExcluded.contains(child.name)) {
              child.matchedByRedundantRule = false;
            } else {
              child.matchedByRedundantRule = child.parent.matchedByRedundantRule;
            }
            if (ruleIncluded.contains(child.name)) {
              child.matchedByRule = true;
            } else if (ruleExcluded.contains(child.name)) {
              child.matchedByRule = false;
            } else {
              child.matchedByRule = child.parent.matchedByRule;
            }
          }
          for (i=0; i<child.children.length; i++) {
            setMatched(child.children[i]);
          }
        };

    if (allDomains.length) {
      for (i=0; i<allDomains.length; i++) {
        domainlist[allDomains[i]] = {children: []};
      }

      for (i=0; i<allDomains.length; i++) {
        topDomain = allDomains[i].replace(SUBDOMAIN, "") || "ALL";
        while (!domainlist.hasOwnProperty(topDomain)) {
          topDomain = topDomain.replace(SUBDOMAIN, "") || "ALL";
        }
        domainlist[topDomain].children.push(domainlist[allDomains[i]]);
        domainlist[allDomains[i]].parent = domainlist[topDomain];
        domainlist[allDomains[i]].name = allDomains[i];
      }

      setMatched(domainlist.ALL);
    }

    for (i in domainlist) {
      if (domainlist[i].matchedByRedundantRule || domainlist[i].matchedByRule) {
        matchingDomains.push(i);
      }
      if (isRedundant && domainlist[i].matchedByRedundantRule && !domainlist[i].matchedByRule) {
        isRedundant = false;
      }
    }

    return {domainlist: domainlist, matchingDomains: matchingDomains, isRedundant: isRedundant};
  };


  var matchDomains = function(redRule, rule, returnOnly) {
    // Inputs:
    //   redRule: parsed rule object
    //   rule: parsed rule object
    //   returnOnly: boolean
    // Returns:
    //   boolean
    var result, i, domainlist, originalMatchingDomains, thisDomain,
        newExcludedDomainsWithTilde = [],
        excludedDomainsWithTilde = [],
        newIncludedDomains = [],
        modifiedDomains = [],
        domainsWarnCanBeRemoved = [],
        ruleIncluded = rule.includedDomains,
        ruleExcluded = rule.excludedDomains,
        redRuleIncluded = redRule.includedDomains,
        redRuleExcluded = redRule.excludedDomains;
    redRuleExcluded.sort();
    result = getMatchingDomains(ruleIncluded, ruleExcluded, redRuleIncluded, redRuleExcluded);
    domainlist = result.domainlist;
    originalMatchingDomains = result.matchingDomains;


    if (data.modifiers.loosely) {
      // loosely matches if at least one domain (or 'ALL') matches
      for (i in domainlist) {
        if (domainlist[i].matchedByRedundantRule && domainlist[i].matchedByRule
            && (rule.string !== redRule.string || rule.ruleString !== redRule.ruleString
                || (rule.options && (rule.options.allowed !== redRule.options.allowed
                                  || rule.options.ruleOptions.match_case !== redRule.options.ruleOptions.match_case
                                  || rule.options.ruleOptions.third_party !== redRule.options.ruleOptions.third_party)))) {
          result.isRedundant = true;
          break;
        }
      }
    }

    // True redundancies
    if (result.isRedundant) {
      if (!returnOnly) {
        bestReplacement(redRule, rule);
      }
      return true;
    }
    if (returnOnly) {
      return false;
    }

    for (i=0; i<redRuleExcluded.length; i++) {
      excludedDomainsWithTilde.push("~" + redRuleExcluded[i]);
    }
    for (i=0; i<redRuleIncluded.length; i++) {
      thisDomain = redRuleIncluded[i];
      if (!domainlist[thisDomain].matchedByRule) {
        newIncludedDomains.push(thisDomain);
        continue;
      }
      modifiedDomains = redRuleIncluded.clone();
      modifiedDomains.removeAt(i);
      result = checkForBrokenDomains(excludedDomainsWithTilde.concat(modifiedDomains), redRule.filter, {ignoreBroken: true, syntax: redRule.syntax});
      result = getMatchingDomains(ruleIncluded, ruleExcluded, result.include, result.exclude, [thisDomain].concat(redRuleExcluded)).matchingDomains;
      if (result.length !== originalMatchingDomains.length) {
        newIncludedDomains.push(thisDomain);
      } else {
        domainsWarnCanBeRemoved.push(thisDomain);
      }
    }
    for (i=0; i<redRuleExcluded.length; i++) {
      thisDomain = redRuleExcluded[i];
      modifiedDomains = excludedDomainsWithTilde.clone();
      modifiedDomains.removeAt(i);
      result = checkForBrokenDomains(newIncludedDomains.concat(modifiedDomains), redRule.filter, {ignoreBroken: true, syntax: redRule.syntax});
      result = getMatchingDomains(ruleIncluded, ruleExcluded, result.include, result.exclude, redRuleExcluded.concat(redRuleIncluded)).matchingDomains;
      if (result.length !== originalMatchingDomains.length) {
        newExcludedDomainsWithTilde.push("~" + thisDomain);
      } else {
        domainsWarnCanBeRemoved.push("~" + thisDomain);
      }
    }

    // due to removing excluded domains, cases like a,c.b.a###ads may appear
    result = checkForBrokenDomains(newIncludedDomains.concat(newExcludedDomainsWithTilde), redRule.filter, {ignoreBroken: true, syntax: redRule.syntax});
    if (result.include.length !== newIncludedDomains.length) {
      for (i=0; i<newIncludedDomains.length; i++) {
        if (!result.include.contains(newIncludedDomains[i])) {
          domainsWarnCanBeRemoved.push(newIncludedDomains[i]);
        }
      }
    }

    result = getMatchingDomains(ruleIncluded, ruleExcluded, result.include, result.exclude);

    if (result.domainlist.ALL.matchedByRedundantRule && result.domainlist.ALL.matchedByRule
        && (redRule.syntax === syntax.hiding || redRuleExcluded.length || redRuleIncluded.length)) {
      // In case of ~x###ads and ~y##div#ads, ~y is useless. However, don't suggest removing it.
      // Suggest making the rule specific instead: x##div#ads
      newIncludedDomains = [];
      for (i=0; i<ruleExcluded.length; i++) {
        if (domainlist[ruleExcluded[i]].matchedByRedundantRule) {
          newIncludedDomains.push(ruleExcluded[i]);
        }
      }
      result = checkForBrokenDomains(newIncludedDomains.concat(excludedDomainsWithTilde), redRule.filter, {ignoreBroken: true, syntax: redRule.syntax});
      for (i=0; i<result.exclude.length; i++) {
        result.exclude[i] = "~" + result.exclude[i];
      }
      result = result.include.concat(result.exclude);
      if (result.length === 1) {
        warn(34, [rule.filter, redRule.filter], [redRule.filter, result[0]]);
      } else {
        result.sort();
        result = result.join(redRule.syntax === syntax.hiding ? "," : "|");
        warn(33, [rule.filter, redRule.filter], [redRule.filter, result]);
      }
    } else if (domainsWarnCanBeRemoved.length > 0) {
      domainsWarnCanBeRemoved.sort();
      if (domainsWarnCanBeRemoved.length === 1) {
        warn(31, [rule.filter, redRule.filter], [redRule.filter, domainsWarnCanBeRemoved[0]]);
      } else {
        warn(32, [rule.filter, redRule.filter], [redRule.filter, domainsWarnCanBeRemoved.join(", ")]);
      }
    }
    return false;
  };

  // ======================================================================== //
  // Check for whitelisted hiding, blocking of whitelisting rules
  // ======================================================================== //
  var matchExclusionRules = function() {
    if (data.modifiers.ignoreOptions || data.modifiers.ignoreDomains) {
      return;
    }

    var i, j, k, alldomains, allFilters, domainset, currentDocumentElemhide, currentDomain, useDotVariant, dotIndependent,
        documentelemhideRules = [],
        hidingdomains = Object.keys(h_siteCollection);
    alldomains = Object.keys(b_siteCollection).concat(hidingdomains).unique();
    allFilters = b_withkey.concat(b_withoutkey);

    for (i=0; i<allFilters.length; i++) {
      currentDocumentElemhide = allFilters[i];
      if (!currentDocumentElemhide.isWhitelist) {
        continue;
      }
      if (!(currentDocumentElemhide.options.allowed & Types.elemhide)) {
        continue;
      }
      if (currentDocumentElemhide.options.ruleOptions.third_party) {
        continue;
      }
      // a frame from x.com on y.com has $domain=y.com, while it's resources have $domain=x.com:
      if (currentDocumentElemhide.includedDomains.length !== 0) {
        continue;
      }
      // a frame from x.com on y.com has $domain=y.com, while it's resources have $domain=x.com:
      if (currentDocumentElemhide.excludedDomains.length !== 0) {
        continue;
      }
      maxChecks += (currentDocumentElemhide.options.allowed & Types.document) ? alldomains.length : hidingdomains.length;
      documentelemhideRules.push(currentDocumentElemhide);
    }

    for (i=0; i<documentelemhideRules.length; i++) {
      currentDocumentElemhide = documentelemhideRules[i];
      domainset = (currentDocumentElemhide.options.allowed & Types.document) ? alldomains : hidingdomains;
      reportProgress(domainset.length);
      for (j=0; j<domainset.length; j++) {
        currentDomain = domainset[j];
        useDotVariant = false;
        dotIndependent = false;
        if (!currentDocumentElemhide.rule.test("||" + currentDomain + "^")) {
          useDotVariant = true;
        }
        if (currentDocumentElemhide.rule.test("||" + currentDomain + ".^")) {
          if (!useDotVariant) {
            dotIndependent = true;
          }
        } else if (useDotVariant) {
          continue;
        }

        if (currentDocumentElemhide.isRegex && !useDotVariant && (
            !currentDocumentElemhide.rule.test("|http:/" + currentDomain + "^")
            || !currentDocumentElemhide.rule.test("|x-yz:///" + currentDomain + "/")
            || !currentDocumentElemhide.rule.test("." + currentDomain + "^")
            || !currentDocumentElemhide.rule.test("|q://r.s." + currentDomain + "/"))) {
          continue;
        }
        if (currentDocumentElemhide.isRegex && (dotIndependent || useDotVariant) && (
            !currentDocumentElemhide.rule.test("|http:/" + currentDomain + ".^")
            || !currentDocumentElemhide.rule.test("|x-yz:///" + currentDomain + "./")
            || !currentDocumentElemhide.rule.test("." + currentDomain + ".^")
            || !currentDocumentElemhide.rule.test("|q://r.s." + currentDomain + "./"))) {
          continue;
        }
        if (!useDotVariant && h_siteCollection.hasOwnProperty(currentDomain)) {
          for (k=0; k<h_siteCollection[currentDomain].length; k++) {
            if (h_siteCollection[currentDomain][k].includedDomains.length > 1) {
              if (!currentDocumentElemhide.isRegex) {
                warn(35, [h_siteCollection[currentDomain][k].filter, currentDocumentElemhide.filter], currentDomain);
              } else {
                warn(37, h_siteCollection[currentDomain][k].filter, [currentDocumentElemhide.filter, currentDomain]);
              }
            } else {
              if (!currentDocumentElemhide.isRegex) {
                matchDomains(h_siteCollection[currentDomain][k], currentDocumentElemhide);
              } else {
                warn(36, h_siteCollection[currentDomain][k].filter, currentDocumentElemhide.filter);
              }
            }
          }
        }
        if ((currentDocumentElemhide.options.allowed & Types.document) && b_siteCollection.hasOwnProperty(currentDomain)) {
          for (k=0; k<b_siteCollection[currentDomain].length; k++) {
            if (b_siteCollection[currentDomain][k].includedDomains.length > 1) {
              if (!currentDocumentElemhide.isRegex) {
                if (dotIndependent) {
                  warn(35, [b_siteCollection[currentDomain][k].filter, currentDocumentElemhide.filter], currentDomain);
                } else {
                  warn(64, [b_siteCollection[currentDomain][k].filter, currentDocumentElemhide.filter],
                                                                  useDotVariant ? [currentDomain + ".", currentDomain] : [currentDomain, currentDomain + "."]);
                }
              } else {
                warn(37, b_siteCollection[currentDomain][k].filter, [currentDocumentElemhide.filter, currentDomain]);
              }
            } else {
              if (!currentDocumentElemhide.isRegex) {
                if (dotIndependent) {
                  matchDomains(b_siteCollection[currentDomain][k], currentDocumentElemhide);
                } else {
                  warn(65, [b_siteCollection[currentDomain][k].filter, currentDocumentElemhide.filter],
                                                                  useDotVariant ? [currentDomain + ".", currentDomain] : [currentDomain, currentDomain + "."]);
                }
              } else {
                warn(36, b_siteCollection[currentDomain][k].filter, currentDocumentElemhide.filter);
              }
            }
          }
        }
      }

      if (!currentDocumentElemhide.isRegex && currentDocumentElemhide.string.length < 6 && B_MATCHEVERYTHING.test(currentDocumentElemhide.string)) {
        for (k=0; k<h_siteSpecific.length; k++) {
          matchDomains(h_siteSpecific[k], currentDocumentElemhide);
        }
        for (k=0; k<h_global.length; k++) {
          matchDomains(h_global[k], currentDocumentElemhide);
        }
        if (currentDocumentElemhide.options.allowed & Types.document) {
          for (k=0; k<allFilters.length; k++) {
            if (allFilters[k].filter !== currentDocumentElemhide.filter) {
              matchDomains(allFilters[k], currentDocumentElemhide);
            }
          }
        }
      }
    }
  };




  // ======================================================================== //
  // Check for redundant hiding rules
  // ======================================================================== //
  var isMatchInHidingDepth = function(redRuleSelectors, ruleSelectors, redRuleDepth, ruleDepth) {
    // Inputs:
    //   redRuleSelectors: object with keys of arrays of arrays of strings
    //   ruleSelectors: object with keys of arrays of arrays of strings
    //   redRuleDepth: integer
    //   ruleDepth: integer
    // Returns:
    //   boolean

    var attributeMatched, i, j, ruleCurrentNotSelectors,
        redRule_literal = redRuleSelectors.literal[redRuleDepth],
        rule_literal = ruleSelectors.literal[ruleDepth],
        redRule_attr = redRuleSelectors.attr[redRuleDepth],
        rule_attr = ruleSelectors.attr[ruleDepth],
        redRule_nth = redRuleSelectors.nth[redRuleDepth],
        rule_nth = ruleSelectors.nth[ruleDepth],
        redRule_not = redRuleSelectors.not[redRuleDepth],
        rule_not = ruleSelectors.not[ruleDepth];

    // match any selector that must exist literally against the others
    if (rule_literal.length > redRule_literal.length) {
      return false;
    }
    for (i=0; i<rule_literal.length; i++) {
      if (redRule_literal.indexOf(rule_literal[i], i) === -1) {
        return false;
      }
    }

    // Match attribute selectors against attribute selectors
    for (i=0; i<rule_attr.length; i++) {
      attributeMatched = false;
top:  for (j=0; j<redRule_attr.length; j++) {
        if (rule_attr[i].attr !== redRule_attr[j].attr) {
          continue;
        }
        if (rule_attr[i].namespace !== redRule_attr[j].namespace && rule_attr[i].namespace !== "*|") {
          continue;
        }
        if ((rule_attr[i].operator === redRule_attr[j].operator && rule_attr[i].value === redRule_attr[j].value) || rule_attr[i].withoutValue) {
          attributeMatched = true;
          break;
        }

        if (!redRule_attr[j].value || !rule_attr[i].value || rule_attr[i].value.length > redRule_attr[j].value.length) {
          continue;
        }
        switch (rule_attr[i].operator) {
          case "=": case "undefined": {
            break;
          }
          case "^": {
            if ((redRule_attr[j].operator === "=" || redRule_attr[j].operator === "^" || redRule_attr[j].operator === "|")
                && redRule_attr[j].value.startsWith(rule_attr[i].value)) {
              attributeMatched = true;
              break top;
            }
            break;
          }
          case "$": {
            if ((redRule_attr[j].operator === "=" || redRule_attr[j].operator === "$") && redRule_attr[j].value.endsWith(rule_attr[i].value)) {
              attributeMatched = true;
              break top;
            }
            break;
          }
          case "*": {
            if (redRule_attr[j].value.contains(rule_attr[i].value)) {
              attributeMatched = true;
              break top;
            }
            break;
          }
          case "|": {
            if (((redRule_attr[j].operator === "=" || redRule_attr[j].operator === "|") && redRule_attr[j].value === rule_attr[i].value)
                || ((redRule_attr[j].operator === "=" || redRule_attr[j].operator === "^" || redRule_attr[j].operator === "|")
                    && redRule_attr[j].value.startsWith(rule_attr[i].value + "-"))) {
              attributeMatched = true;
              break top;
            }
            break;
          }
          case "~": {
            if (redRule_attr[j].operator === "="
                && (" " + redRule_attr[j].value.replace(WHITESPACE_G, " ") + " ").contains(" " + rule_attr[i].value + " ")) {
              attributeMatched = true;
              break top;
            }
            if ((redRule_attr[j].operator === "^" || redRule_attr[j].operator === "|")
                && (" " + redRule_attr[j].value.replace(WHITESPACE_G, " ")).contains(" " + rule_attr[i].value + " ")) {
              attributeMatched = true;
              break top;
            }
            if (redRule_attr[j].operator === "$"
                && (redRule_attr[j].value.replace(WHITESPACE_G, " ") + " ").contains(" " + rule_attr[i].value + " ")) {
              attributeMatched = true;
              break top;
            }
            if (redRule_attr[j].operator === "*"
                && redRule_attr[j].value.replace(WHITESPACE_G, " ").contains(" " + rule_attr[i].value + " ")) {
              attributeMatched = true;
              break top;
            }
            break;
          }
        }
      }
      if (!attributeMatched) {
        return false;
      }
    }

    // Match :nth-* selectors
    for (i=0; i<rule_nth.length; i++) {
      attributeMatched = false;
      for (j=0; j<redRule_nth.length; j++) {
        if (rule_nth[i].name !== redRule_nth[j].name) {
          continue;
        }
        if (rule_nth[i].nValue === redRule_nth[j].nValue && rule_nth[i].constValue === redRule_nth[j].constValue) {
          attributeMatched = true;
          break;
        }
        if (redRule_nth[j].nValue % rule_nth[i].nValue !== 0) {
          continue;
        }
        if ((redRule_nth[j].constValue - rule_nth[i].constValue) % rule_nth[i].nValue !== 0) {
          continue;
        }
        if (rule_nth[i].nValue < 0) {
          if (redRule_nth[j].nValue > 0) {
            continue;
          }
          if (redRule_nth[j].constValue > rule_nth[i].constValue) {
            continue;
          }
        } else {
          if (redRule_nth[j].nValue >= 0 && redRule_nth[j].constValue < rule_nth[i].constValue) {
            continue;
          }
          if (redRule_nth[j].nValue < 0 && (redRule_nth[j].constValue % redRule_nth[j].nValue || -1 * redRule_nth[j].nValue) < rule_nth[j].constValue) {
            continue;
          }
        }
        attributeMatched = true;
        break;
      }
      if (!attributeMatched) {
        return false;
      }
    }

    // match :not() selectors against other :not() selectors
    for (i=0; i<rule_not.length; i++) {
      attributeMatched = false;
      ruleCurrentNotSelectors = getSelectorsForMatching([rule_not[i]]);
      for (j=0; j<redRule_not.length; j++) {
        if (isMatchInHidingDepth(ruleCurrentNotSelectors, getSelectorsForMatching([redRule_not[j]]), 0, 0)) {
          attributeMatched = true;
          break;
        }
      }
      if (!attributeMatched) {
        if (isCSSimpossibleCombination(ruleCurrentNotSelectors.attr[0], redRule_attr)
            && !isMatchInHidingDepth(ruleCurrentNotSelectors, {literal: [[]], nth: [[]], not: [[]], attr: [redRule_attr]}, 0, 0)) {
          attributeMatched = true;
        }
      }
      if (!attributeMatched) {
        return false;
      }
    }

    return true;
  };
  var matchHidingrules = function() {
    var siteParts, site, sI, sJ, i, j, checkReverse,
        insertNull = function(arrays, nullcount) {
          var i, arr, position, clone,
              newArrays = [];
          if (nullcount === 0) {
            return arrays;
          }
          for (i=0; i<arrays.length; i++) {
            arr = arrays[i];
            for (position=0; position<arr.length+1; position++) {
              if (arr[position-1] === null) {
                break;
              }
              clone = arr.clone();
              clone.splice(position, 0, null);
              newArrays.push(clone);
            }
          }
          return insertNull(newArrays, nullcount-1);
        },
        matchRules = function(sI, sJ) {
          var i, k, sJ_tree, sI_tree, j, sItreeI, possible_pathways, nullcount, matchHistory, currentPath, vert,
              possibleRedundantPart, firstNullIndex, domainlist, domainlist2,
              mustSplice = false,
              equalWhitelistRules = [];
          if (sI.isWhitelist && !sJ.isWhitelist) {
            return;
          }
          if (!sJ.isWhitelist && !sI.isWhitelist) {
            if (sJ.selectors.tree.length > sI.selectors.tree.length) {
              return;
            }

            if (sI.selectors.tree.length === 0) {
              if (!isMatchInHidingDepth(sI.selectors, sJ.selectors, 0, 0)) {
                return;
              }
            } else {
              sI_tree = sI.selectors.tree.clone();
              sJ_tree = sJ.selectors.tree.clone();
              sI_tree.unshift("end");
              sJ_tree.unshift("end");
              possible_pathways = insertNull([sJ_tree], sI_tree.length - sJ_tree.length);
              for (i=0; i<sI_tree.length; i++) {
                sItreeI = sI_tree[i];
                for (j=possible_pathways.length-1; j>=0; j--) {
                  switch (possible_pathways[j][i]) {
                    case "end": {
                      if (sItreeI !== "end" && sItreeI !== ">" && sItreeI !== " ") {
                        mustSplice = true;
                      }
                      break;
                    }
                    case ">": {
                      if (sItreeI !== ">") {
                        mustSplice = true;
                      }
                      break;
                    }
                    case "+": {
                      if (sItreeI !== "+") {
                        mustSplice = true;
                      }
                      break;
                    }
                    case " ": {
                      if (sItreeI !== ">" && sItreeI !== " ") {
                        mustSplice = true;
                      }
                      break;
                    }
                    case "~": {
                      if (sItreeI !== "+" && sItreeI !== "~") {
                        mustSplice = true;
                      }
                      break;
                    }
                  }
                  if (mustSplice) {
                    possible_pathways.removeAt(j);
                    mustSplice = false;
                  }
                }
              }
              if (possible_pathways.length === 0) {
                return;
              }

              for (j=possible_pathways.length-1; j>=0; j--) {
                currentPath=possible_pathways[j];
                for (i=currentPath.indexOf("end")+1; i<currentPath.length; i++) {
                  if (currentPath[i-1] === null && currentPath[i] !== null) {
                    if (currentPath[i] === "+") {
                      mustSplice = true;
                    } else if (currentPath[i] === ">" || currentPath[i] === "~") {
                      possibleRedundantPart = sI_tree.slice(firstNullIndex, i + 1); // note: slice(1,4) returns indexes 1,2,3
                      vert = 0;
                      for (k=0; k<possibleRedundantPart.length; k++) {
                        if (possibleRedundantPart[k] === ">") {
                          vert += 1;
                          if (vert > 1) {
                            break;
                          }
                        } else if (possibleRedundantPart[k] === " ") {
                          vert = Infinity;
                          break;
                        }
                      }
                      if (vert > 1 || (vert === 1 && currentPath[i] === "~")) {
                        mustSplice = true;
                      }
                    }
                    if (mustSplice) {
                      possible_pathways.removeAt(j);
                      mustSplice = false;
                      break;
                    }
                  } else if (currentPath[i] === null && currentPath[i-1] !== null) {
                    firstNullIndex = i;
                  }
                }
              }
              if (possible_pathways.length === 0) {
                return;
              }

              // The selector must match directly before the tree selector
              for (i=0; i<sI_tree.length; i++) {
                matchHistory = {};
                for (j=possible_pathways.length-1; j>=0; j--) {
                  if (!possible_pathways[j][i]) {
                    continue;
                  }
                  nullcount = 0;
                  for (k=0; k<i; k++) {
                    if (possible_pathways[j][k] === null) {
                      nullcount += 1;
                    }
                  }
                  if (!matchHistory.hasOwnProperty(nullcount)) {
                    matchHistory[nullcount] = isMatchInHidingDepth(sI.selectors, sJ.selectors, i, i-nullcount);
                  }
                  if (!matchHistory[nullcount]) {
                    possible_pathways.removeAt(j);
                  }
                }
              }
              if (possible_pathways.length === 0) {
                return;
              }
            }

            // Do not make hiding rules redundant if the redundant rule is whitelisted for this domain
            for (i=0; i<h_global.length; i++) {
              if (h_global[i].isWhitelist && h_global[i].ruleString === sJ.ruleString && sI.ruleString !== sJ.ruleString) {
                equalWhitelistRules.push(h_global[i]);
              }
            }
            for (i=0; i<h_siteSpecific.length; i++) {
              if (h_siteSpecific[i].isWhitelist && h_siteSpecific[i].ruleString === sJ.ruleString && sI.ruleString !== sJ.ruleString) {
                equalWhitelistRules.push(h_siteSpecific[i]);
              }
            }
            for (i=0; i<equalWhitelistRules.length; i++) {
              domainlist = getMatchingDomains(equalWhitelistRules[i].includedDomains, equalWhitelistRules[i].excludedDomains,
                                              sJ.includedDomains, sJ.excludedDomains, sI.includedDomains.concat(sI.excludedDomains)).domainlist;
              domainlist2 = getMatchingDomains([], [], sI.includedDomains, sI.excludedDomains, sJ.excludedDomains.concat(
                                               equalWhitelistRules[i].includedDomains, equalWhitelistRules[i].excludedDomains, sJ.includedDomains)).domainlist;
              for (j in domainlist) {
                if (domainlist[j].matchedByRedundantRule && domainlist[j].matchedByRule && domainlist2[j].matchedByRedundantRule) {
                  return;
                }
              }
            }
          } else if (sJ.ruleString !== sI.ruleString) {
            // at least one of them is a #@# rule
            return;
          }

          matchDomains(sI, sJ);
        };

    for (i=0; i<h_global.length; i++) {
      sI = h_global[i];
      reportProgress(h_global.length);
      for (j=i+1; j<h_global.length; j++) {
        matchRules(sI, h_global[j]);
        matchRules(h_global[j], sI);
      }
    }

    for (i=0; i<h_global.length; i++) {
      sI = h_global[i];
      reportProgress(h_siteSpecific.length);
      checkReverse = sI.excludedDomains.length !== 0;
      for (j=0; j<h_siteSpecific.length; j++) {
        if (checkReverse) {
          matchRules(sI, h_siteSpecific[j]);
        }
        matchRules(h_siteSpecific[j], sI);
      }
    }

    for (site in h_siteCollection) {
      siteParts = site;
      reportProgress(1);
      while (SUBDOMAIN.test(siteParts)) {
        if (h_siteCollection.hasOwnProperty(siteParts) && (site !== siteParts || h_siteCollection[siteParts].length !== 1)) {
          for (i=0; i<h_siteCollection[site].length; i++) {
            sI = h_siteCollection[site][i];
            for (j=0; j<h_siteCollection[siteParts].length; j++) {
              sJ = h_siteCollection[siteParts][j];
              if (sI.id !== sJ.id) {
                matchRules(sI, sJ);
                matchRules(sJ, sI);
              }
            }
          }
        }
        siteParts = siteParts.replace(SUBDOMAIN, "");
      }
    }
  };




  // ======================================================================== //
  // Check for redundant blocking (or whitelisting) rules
  // ======================================================================== //
  var matchBlockingrules = function() {
    var i, j, key, coll, sI,
        testProperties = function(rule, redRule) {
          // Test the content of everything behind the $ except for domain=*
          var k,
              ruleOptions = rule.options.ruleOptions,
              redRuleOptions = redRule.options.ruleOptions,
              ruleAllowed = rule.options.allowed,
              redRuleAllowed = redRule.options.allowed;
          if (redRuleOptions.third_party * ruleOptions.third_party === -1) {
            return false;
          }
          if (redRuleOptions.collapse !== ruleOptions.collapse && !rule.isWhitelist) {
            return false;
          }
          if (!data.modifiers.loosely) {
            if (!redRuleOptions.third_party && ruleOptions.third_party) {
              return false;
            }
            if (!redRuleOptions.match_case && ruleOptions.match_case === 1) {
              return false;
            }
            for (k=1; k<=Types.MAX; k*=2) {
              if (!(k & ruleAllowed) && (k & redRuleAllowed)) {
                return false;
              }
            }
          } else {
            if ((ruleAllowed & redRuleAllowed) === 0) {
              return false;
            }
          }
          return true;
        },
        matchRules = function(sI, sJ) {
          var i, alsotest,
              maycontinue = false,
              mustBecomeRegexWarning = false;
          if (sI.filter === sJ.filter) {
            return;
          }
          if (sI.isWhitelist && !sJ.isWhitelist) {
            return;
          }
          if (sJ.string.length > 2 * sI.string.length) {
            return;
          }
          if (sI.isRegex) {
            return;
          }
          if (!sJ.rule.test(sI.string)) {
            if (sI.domainstart) {
              switch (sJ.string[0]) {
                case ".": {
                  if (sI.domainstart.hasOwnProperty("dot") && sJ.rule.test(sI.domainstart.dot)) {
                    alsotest = "dot";
                  }
                  break;
                }
                case "/": case "^": case ":": {
                  if (sI.domainstart.hasOwnProperty("slash") && ((sJ.rule.test(":" + sI.domainstart.slash) && sJ.rule.test(":///" + sI.domainstart.slash))
                      || (data.modifiers.loosely && sJ.rule.test(":/" + sI.domainstart.slash)))) {
                    alsotest = "slash";
                  }
                }
              }
              if (alsotest) {
                if (!testProperties(sJ, sI)) {
                  return;
                }
                if (!matchDomains(sI, sJ, true)) {
                  return;
                }
                delete sI.domainstart[alsotest];
                if (data.modifiers.loosely) {
                  matchDomains(sI, sJ);
                } else if (sI.domainstart.hasOwnProperty("other")) {
                  warn(14, sI.filter, [sJ.filter, sI.domainstart.other].sort());
                  sI.domainstart = false;
                } else {
                  sI.domainstart.other = sJ.filter;
                }
              }
            }
            return;
          }
          if (!testProperties(sJ, sI)) {
            return;
          }
          if (sJ.isRegex) {
            // Regex can check for literal ||, |, ^ or *
            if (sI.string.substring(0, 2) === "||") {
              alsotest = ["|http:/", "|x-yz:///", ".", "|q://r.s."];
              for (i=0; i<alsotest.length; i++) {
                if (!sJ.rule.test(sI.string.replace("||", alsotest[i]))) {
                  return;
                }
              }
              mustBecomeRegexWarning = true;
            } else if (sI.string[0] === "|") {
              if (!sJ.rule.test(sI.string.substring(1))) {
                return;
              }
            }
            if (sI.string[sI.string.length-1] === "|") {
              if (!sJ.rule.test(sI.string.substring(0, sI.string.length-1))) {
                return;
              }
            }
            if (sI.string.contains("*") || sI.string.contains("^")) {
              if (!sJ.rule.test(sI.string.replace(B_HATSTAR_G, "/"))) {
                return;
              }
              if (sI.string.contains("*")) {
                if (!sJ.rule.test(sI.string.replace(STAR_G, "Z"))) {
                  return;
                }
                alsotest = sI.string.split("*");
                for (i=0; i<alsotest.length; i++) {
                  if (sJ.rule.test(alsotest[i])) {
                    maycontinue = true;
                    break;
                  }
                }
                if (!maycontinue) {
                  return;
                }
              }
              mustBecomeRegexWarning = true;
            }
            if (mustBecomeRegexWarning && matchDomains(sI, sJ, true)) {
              warn(36, sI.filter, sJ.filter);
              return;
            }
          }
          matchDomains(sI, sJ);
        };

    for (key in b_keyCollection) {
      coll = b_keyCollection[key];
      for (i=0; i<coll.length; i++) {
        reportProgress(coll.length);
        for (j=i+1; j<coll.length; j++) {
          matchRules(coll[i], coll[j]);
          matchRules(coll[j], coll[i]);
        }
      }
    }

    for (i=0; i<b_withoutkey.length; i++) {
      sI = b_withoutkey[i];
      reportProgress(b_withkey.length);
      for (j=0; j<b_withkey.length; j++) {
        matchRules(b_withkey[j], sI);
      }
      reportProgress(b_withoutkey.length);
      for (j=i+1; j<b_withoutkey.length; j++) {
        matchRules(sI, b_withoutkey[j]);
        matchRules(b_withoutkey[j], sI);
      }
    }
  };



  var checkForBrokenHidingRules = function(line, noWarnings) {
    // Inputs:
    //   line: string
    //   noWarnings: boolean
    // Returns:
    //   status
    var isGoodRule,
        match = line.match(ELEMHIDE);
    if (WHITESPACE.test(line.substring(0, line.length - match[3].length)) || match[3].trim() !== match[3]) {
      warn(63, line);
      match[1] = match[1].trim();
    }
    isGoodRule = prepareHidingRule(match[3], false, line, noWarnings || match[2] === "@");
    if (isGoodRule.status !== status.OK) {
      if (!noWarnings && isGoodRule.status === status.INVALID) {
        warn(1, line);
      }
      return isGoodRule.status;
    }
    if (match[1] && !data.modifiers.ignoreDomains) {
      return checkForBrokenDomains(match[1].split(","), line, {ignoreBroken: noWarnings, syntax: syntax.hiding}).status;
    }
    return status.OK;
  };

  var checkForBrokenBlockingRules = function(line) {
    // Inputs:
    //   line: string
    // Returns:
    //   status
    var options, badEnd, afterReplace,
        match = line.replace(WHITESPACE_G, "").match(BLOCKING);

    if (PROBABLYELEMHIDE.test(line)) {
      if (CURLYBRACKETS.test(line)) {
        warn(22, line);
      } else if (H_PROBABLYELEMHIDEEXCLUDE.test(line.replace(WHITESPACE_G, "")) && ELEMHIDE.test(line.replace(AT_G, ""))) {
        if (line.indexOf("@") < line.indexOf("#")) {
          warn(23, line);
        } else {
          warn(24, line);
        }
      } else {
        warn(25, line);
      }
    }

    options = (match[3] || "");
    if (WHITESPACE.test(line)) {
      if (OLDSTYLEHIDING.test(line.replace(WHITESPACE_G, ""))) {
        oldStyleToNewSuggestion(line, line.replace(WHITESPACE_G, ""));
        return status.IGNORE;
      }
      warn(63, line);
    } else if (match[2].contains("**")) {
      warn(60, line);
    }

    if (!options && PROBABLYOPTIONS.test(match[2])) {
      warn(26, line);
    } else if (options && match[2].replace(COMMAEND, "").match(BLOCKING)[3]
        && prepareBlockingOptions(match[2].replace(COMMAEND, "").match(BLOCKING)[3], line, match[1]==="@@", true).status !== status.INVALID) {
      warn(21, line, COMMAEND.test(match[2]) ? ",$" : "$");
    } else if (PROBABLYNOTREGEX.test(match[2])) {
      warn(57, line, [(match[1] || "") + match[2].substring(1, match[2].length - 1) + (match[3] || ""),
                      (match[1] || "") + match[2] + "*" + (match[3] || "")]);
    }

    if (B_USELESSFILTEREND.test(match[2])) {
      badEnd = match[2].match(B_USELESSFILTEREND)[0];
      afterReplace = match[2].replace(B_USELESSFILTEREND, "");
      if (B_REGEX.test(afterReplace) || match[2] === badEnd || afterReplace[afterReplace.length-1] === "|") {
        badEnd = badEnd.substring(1);
      }
      if (badEnd) {
        warn(55, line, badEnd);
      }
    }

    if (match[2].startsWith("||")) {
      if (B_BADFILTERSTART.test(match[2])) {
        warn(17, line);
        return status.DISCARD;
      }
    } else if (match[2][0] === "|") {
      if (match[2][1] === "*") {
        warn(56, line, B_REGEX.test(match[2].substring(2)) || match[2].length === 2
                       || COMMENTLINE.test(match[2].substring(2)) || match[2][2] === "|"  ? "|" : "|*");
      } else if (B_BADPROTOCOLSTART.test(match[2])) {
        warn(16, line);
        return status.DISCARD;
      }
    }

    if (options && B_DOMAINIS.test(options) && !data.modifiers.ignoreDomains) {
      return checkForBrokenDomains(options.match(B_DOMAINIS)[1].split("|"), line, {ignoreBroken: false, syntax: syntax.blocking}).status;
    }
    return status.OK;
  };

  var oldStyleToNewSuggestion = function(line, useRule) {
    // Inputs:
    //   line: string
    //   useRule: string
    // Returns:
    //   nothing
    useRule = useRule || line;
    var parsedDomains, idOrClass, i,
        newRules = [],
        domains = useRule.substring(0, useRule.indexOf("#")).replace(WHITESPACE_G, "").toLowerCase(),
        rule = "##" + useRule.substring(useRule.indexOf("#") + 1).trim().replace(H_OLDSTYLEATTRIBUTE_G, "[$1\"$2\"]");
    if (domains) {
      parsedDomains = checkForBrokenDomains(domains.split(","), useRule, {ignoreBroken: false, syntax: syntax.hiding});
      if (parsedDomains.status === status.OK) {
        if (parsedDomains.exclude.length) {
          domains = parsedDomains.include.join(",") + (parsedDomains.include.length ? ",~" : "~") + parsedDomains.exclude.join(",~");
        } else {
          domains = parsedDomains.include.join(",");
        }
      }
    }

    idOrClass = rule.match(H_OLDSTYLEIDCLASS);
    if (idOrClass) {
      newRules.push(domains + rule.replace(idOrClass[0], "#" + idOrClass[1]));
      newRules.push(domains + rule.replace(idOrClass[0], "." + idOrClass[1]));
    } else {
      newRules.push(domains + rule);
    }

    for (i=0; i<newRules.length; i++) {
      if (!ELEMHIDE.test(newRules[i]) || checkForBrokenHidingRules(newRules[i], true) !== status.OK) {
        warn(3, line);
        break;
      }
    }
    warn(30, line, newRules.join(" and "));
  };

  var begin = function() {
    var i, warningContainsRedundantRules, betterRule,
        lines = getLinesWithoutDuplicates();
    for (i=0; i<lines.length; i++) {
      if (ELEMHIDE.test(lines[i])) {
        if (checkForBrokenHidingRules(lines[i]) === status.OK) {
          sortHidingIntoCategories(lines[i]);
        }
      } else if (OLDSTYLEHIDING.test(lines[i])) {
        oldStyleToNewSuggestion(lines[i]);
      } else if (checkForBrokenBlockingRules(lines[i]) === status.OK) {
        sortBlockingIntoCategories(lines[i]);
      }
    }
    lines = undefined;

    for (i in b_keyCollection) {
      if (b_keyCollection[i].length === 1) {
        delete b_keyCollection[i];
      } else {
        maxChecks += Math.pow(b_keyCollection[i].length, 2);
      }
    }

    maxChecks += Math.pow(h_global.length, 2) + h_global.length * h_siteSpecific.length + Object.keys(h_siteCollection).length
                 + Math.pow(b_withoutkey.length, 2) + b_withoutkey.length * b_withkey.length + 1;

    matchExclusionRules();
    matchHidingrules();
    matchBlockingrules();

    for (i in redundant) {
      // Remove x has been made redundant by X, X has been made redundant by x results
      betterRule = redundant[i];
      if (redundant[betterRule] === i && i !== betterRule) {
        if (getWarningPriority(i) < getWarningPriority(betterRule)
            || (getWarningPriority(i) === getWarningPriority(betterRule) && (betterRule.length < i.length
                || (betterRule.length === i.length && betterRule < i)))) {
          delete redundant[betterRule];
        } else {
          delete redundant[i];
        }
      }
    }

    warningContainsRedundantRules = function(el) {
      var j;
      for (j=0; j<el.rules.length; j++) {
        if (el.priority !== "H" && redundant.hasOwnProperty(el.rules[j]) && redundant[el.rules[j]] !== el.rules[j]) {
          return true;
        }
      }
      return false;
    };
    warnings = warnings.filter(function(el, i) {
      var j, k, allPresent;
      if (warningContainsRedundantRules(el)) {
        return false;
      }
      for (j=0; j<warnings.length; j++) {
        if (i === j) {
          continue;
        }
        if (warnings[j].index > el.index) {
          continue; // higher index (lower priority) can never make higher priority redundant
        }
        if (warningContainsRedundantRules(warnings[j])) {
          continue; // other rule will be discarded
        }
        if (warnings[j].rules.length >= el.rules.length) {
          allPresent = true;
          for (k=0; k<el.rules.length; k++) {
            if (!warnings[j].rules.contains(el.rules[k])) {
              allPresent = false;
              break;
            }
          }
          if (!allPresent) {
            continue; // Not all rules in the warning are covered in the other warning
          }
        }
        if (warnings[j].index < el.index) {
          return false;
        }
        // priority (and therefore rules) are equal; sort the message alphabetically
        if (warnings[j].msg < el.msg) {
          return false;
        }
        if (warnings[j].msg === el.msg && i < j) {
          return false; // exactly identical warnings; leave only one behind
        }
      }
      return true;
    });
  };

  begin();

  if (secondTime) {
    return redundant;
  }
  var returnThis = {
    results: redundant,
    seconds: Math.ceil((Date.now() - timeStart) / 1000),
    warnings: warnings
  };
  if (returnWhenDone) {
    return returnThis;
  }
  self.postMessage(returnThis);
  self.close();
};
this.addEventListener("message", function(e) {
  startWorker(e.data);
}, false);
