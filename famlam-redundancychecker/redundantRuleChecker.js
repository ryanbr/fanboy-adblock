"use strict";
var toolsFile;
var createText = function(text, appendTo) {
  var el = document.createTextNode(text.replace(/\ {2,}|\ $|^\ /g, function(m) {
    return new Array(m.length + 1).join("\u00A0");
  }));
  if (appendTo) {
    appendTo.appendChild(el);
  }
  return el;
};

var createTag = function(tagname, attributes, properties, appendTo) {
  var i, el = document.createElement(tagname);
  if (attributes) {
    for (i in attributes) {
      el.setAttribute(i, attributes[i]);
    }
  }
  if (properties) {
    for (i in properties) {
      if (i === "textContent") {
        createText(properties[i], el);
      } else {
        el[i] = properties[i];
      }
    }
  }
  if (appendTo) {
    appendTo.appendChild(el);
  }
  return el;
};

var switchTab = function(e) {
  var i, currentActive = document.querySelectorAll(".activeTab");
  for (i=0; i<currentActive.length; i++) {
    currentActive[i].classList.remove("activeTab");
  }

  var target;
  if (typeof e === "string") {
    target = document.getElementById("tabtitle_" + e);
  } else {
    target = e.target;
    if (target.parentNode.id !== "tab_titles") {
      target = target.parentNode;
    }
  }
  target.classList.add("activeTab");
  var tabcontent = document.getElementById(target.id.replace("tabtitle", "tab"));
  tabcontent.classList.add("activeTab");
};

var addTab = function(id, title, content, index) {
  title.id = "tabtitle_" + id;
  title.addEventListener("click", switchTab, false);
  var tabtitlebar = document.getElementById("tab_titles");
  if (index !== undefined && tabtitlebar.children.length > index) {
    tabtitlebar.insertBefore(title, tabtitlebar.children[index]);
  } else {
    tabtitlebar.appendChild(title);
  }
  content.id = "tab_" + id;
  document.getElementById("tab_contents").appendChild(content);
};

var removeTabs = function(id) {
  var i, tabIds = id ? [document.getElementById("tabtitle_" + id)] : document.querySelectorAll("[id^='tabtitle_']");
  for (i=0; i<tabIds.length; i++) {
    document.getElementById("tab_titles").removeChild(tabIds[i]);
    var contentarea = document.getElementById(tabIds[i].id.replace("tabtitle", "tab"));
    while (contentarea.firstChild) {
      // Way faster to first remove all tags inside it
      contentarea.removeChild(contentarea.firstChild);
    }
    contentarea.parentNode.removeChild(contentarea);
  }
  if (!id) {
    document.getElementById("tabs").classList.add("hidden");
  }
};

var startWorker = function(script, command, done) {
  var btn = document.getElementById("btnstart");
  btn.value = "Checking... please wait";
  btn.disabled = true;
  var prcnt = document.getElementById("percent");
  prcnt.classList.remove("hidden");
  prcnt.value = 0;
  var ind = document.getElementById("progressindicator");
  ind.classList.remove("hidden");
  ind.textContent = "0%";
  var txtbox = document.getElementById("filters");
  txtbox.disabled = true;
  var tabarea = document.getElementById("tabs");
  tabarea.classList.add("hidden");

  var worker = new window.Worker(script);
  worker.addEventListener("error", function(ex) {
    window.alert("The check had to abort due to an error.\nThe error (on line " + ex.lineno + ") was\n" + ex.message);
  }, false);
  worker.addEventListener("message", function(e) {
    if (e.data.progress !== undefined) {
      prcnt.value = Math.max(prcnt.value, e.data.progress);
      ind.textContent = Math.round(prcnt.value) + "%";
    } else {
      done(e.data);
      btn.value = "Check for redundant rules";
      btn.disabled = false;
      prcnt.classList.add("hidden");
      ind.classList.add("hidden");
      txtbox.disabled = false;
      tabarea.classList.remove("hidden");
    }
  }, false);
  worker.postMessage(command);
};

var startToolSimilar = function() {
  if (document.getElementById("tab_Similarities")) {
    switchTab("Similarities");
    return;
  }
  startWorker("similar.js", {filters: toolsFile}, function(e) {
    var i, results = e.results;
    var tabTitle = createTag("span", {"class": "toolsTab"}, {textContent: "similarities"});
    var tabContent = createTag("div");
    createTag("p", {}, {textContent: "The following rules look about the same"}, tabContent);
    createTag("em", {}, {textContent: "Please note: these results are only based upon the plain text, not on the meaning of it! You should therefore not use them, unless you're very sure what you're doing!"}, tabContent);
    createTag("br", {}, {}, tabContent);
    var div = createTag("div", {"class": "toolsResults"}, {}, tabContent);
    var sortable, b, j, pre, sortfunction = function(a, b) {
      if (a[1] === b[1]) {
        return b[0] < a[0] ? 1 : -1;
      }
      return b[1] - a[1] < 0 ? -1 : 1;
    };
    var clickhandler = function() {
      this.nextElementSibling.classList.toggle("hidden");
    };
    for (i in results) {
      sortable = [];
      b = createTag("strong", {}, {}, div);
      b.addEventListener("click", clickhandler, false);
      createText(i + " ", b);
      createTag("em", {}, {textContent: " (" + Object.keys(results[i]).length + ")"}, b);

      pre = createTag("pre", {"class": "hidden"}, {}, div);
      for (j in results[i]) {
        sortable.push([j, results[i][j]]);
      }
      sortable.sort(sortfunction);
      for (j=0; j<sortable.length; j++) {
        createTag("span", {"class": "priority" + Math.floor(sortable[j][1]*10)}, {textContent: sortable[j][0]}, pre);
        createTag("br", {}, {}, pre);
      }
    }
    if (Object.keys(results).length === 0) {
      createTag("p", {}, {textContent: "No results found!"}, tabContent);
    }
    addTab("Similarities", tabTitle, tabContent);
    switchTab("Similarities");
  });
};

var startToolHideToBlock = function() {
  if (document.getElementById("tab_Hidetoblock")) {
    switchTab("Hidetoblock");
    return;
  }
  startWorker("hidingToBlocking.js", {filters: toolsFile}, function(e) {
    var i, results = e.results;
    var tabTitle = createTag("span", {"class": "toolsTab"}, {textContent: "Hiding to blocking"});
    var tabContent = createTag("div");
    createTag("p", {}, {textContent: "The following rules can become blocking rules"}, tabContent);
    createTag("em", {}, {textContent: "Please note: these rules can be converted to blocking rules, but it is not always useful to do so. Some sites for example break when you block the resource, but not if you hide it. Other rules are just too unspecific for blocking rules"}, tabContent);
    createTag("br", {}, {}, tabContent);
    createTag("br", {}, {}, tabContent);
    var sortedKeys = Object.keys(results).sort(function(a, b) {
      if (results[a].priority !== results[b].priority) {
        return results[a].priority > results[b].priority ? -1 : 1;
      }
      return a > b ? -1 : 1;
    });
    for (i=0; i<sortedKeys.length; i++) {
      createTag("strong", {"class": "priority" + results[sortedKeys[i]].priority}, {textContent: sortedKeys[i]}, tabContent);
      createTag("span", {"class": "priority" + results[sortedKeys[i]].priority}, {textContent: " can be converted to "}, tabContent);
      createTag("strong", {"class": "priority" + results[sortedKeys[i]].priority}, {textContent: results[sortedKeys[i]].newRule}, tabContent);
      createTag("br", {}, {}, tabContent);
    }
    if (Object.keys(results).length === 0) {
      createTag("p", {}, {textContent: "No results found!"}, tabContent);
    }
    addTab("Hidetoblock", tabTitle, tabContent);
    switchTab("Hidetoblock");
  });
};


var startToolLessOptions = function(e) {
  var tabid, tabtitle, contenttitle, modifier;
  if (e.target.id === "buttonNoOptionsNoDomains") {
    modifier = {ignoreOptions: true, ignoreDomains: true};
    tabid = "NoOptionsNoDomains";
    tabtitle = "ignoring options and domains";
    contenttitle = "The following rules are redundant if domains and filter options are ignored:";
  } else if (e.target.id === "buttonNoDomains") {
    modifier = {ignoreDomains: true};
    tabid = "NoDomains";
    tabtitle = "ignoring domains";
    contenttitle = "The following rules are redundant if domains are ignored:";
  } else if (e.target.id === "buttonNoOptions") {
    modifier = {ignoreOptions: true};
    tabid = "NoOptions";
    tabtitle = "ignoring options";
    contenttitle = "The following rules are redundant if filter options are ignored:";
  } else if (e.target.id === "buttonLoosely") {
    modifier = {loosely: true};
    tabid = "Loosely";
    tabtitle = "loosely";
    contenttitle = "The following rules are redundant if the more loose method is used:";
  }
  if (document.getElementById("tab_" + tabid)) {
    switchTab(tabid);
    return;
  }
  startWorker("redundant.js", {filters: toolsFile, modifiers: modifier}, function(e) {
    var i, results = e.results;
    var tabTitle = createTag("span", {"class": "toolsTab"}, {textContent: tabtitle});
    var tabContent = createTag("div");
    createTag("p", {}, {textContent: contenttitle}, tabContent);
    createTag("em", {}, {textContent: "Please note: these results are based upon modified rules and are not truely redundant! You should therefore not use them, unless you're very sure what you're doing!"}, tabContent);
    createTag("br", {}, {}, tabContent);
    createTag("br", {}, {}, tabContent);

    for (i in results) {
      createTag("strong", {}, {textContent: i}, tabContent);
      createText(" would have been made redundant by ", tabContent);
      createTag("strong", {}, {textContent: results[i]}, tabContent);
      createTag("br", {}, {}, tabContent);
    }
    if (Object.keys(results).length === 0) {
      createTag("p", {}, {textContent: "No results found!"}, tabContent);
    }
    addTab(tabid, tabTitle, tabContent);
    switchTab(tabid);
  });
};


var startToolOnlyDomainDiffers = function() {
  if (document.getElementById("tab_SameRuleDifferentDomain")) {
    switchTab("SameRuleDifferentDomain");
    return;
  }
  startWorker("onlyDomainDiffers.js", {filters: toolsFile}, function(e) {
    var i, results = e.results;
    var tabTitle = createTag("span", {"class": "toolsTab"}, {textContent: "same rule, different domains"});
    var tabContent = createTag("div");
    createTag("p", {}, {textContent: "The following rules only differ in their domains"}, tabContent);
    createTag("em", {}, {textContent: "Please note: you can combine the rules below. It however certainly is not necessary to do so!"}, tabContent);
    createTag("br", {}, {}, tabContent);
    var div = createTag("div", {"class": "toolsResults"}, {}, tabContent);
    var b, j, pre;
    var clickhandler = function() {
      this.nextElementSibling.classList.toggle("hidden");
    };
    var keys = Object.keys(results);
    keys.sort(function(a, b) {
      if (results[a].length === results[b].length) {
        return a > b ? 1 : -1;
      }
      return results[a].length > results[b].length ? -1 : 1;
    });
    for (i=0; i<keys.length; i++) {
      b = createTag("strong", {}, {}, div);
      b.addEventListener("click", clickhandler, false);
      createText(keys[i] + " ", b);
      createTag("em", {}, {textContent: " (" + Object.keys(results[keys[i]]).length + ")"}, b);

      pre = createTag("pre", {"class": "hidden"}, {}, div);
      results[keys[i]].sort();
      for (j=0; j<results[keys[i]].length; j++) {
        createTag("span", {"class": "priority10"}, {textContent: results[keys[i]][j]}, pre);
        createTag("br", {}, {}, pre);
      }
    }
    if (Object.keys(results).length === 0) {
      createTag("p", {}, {textContent: "No results found!"}, tabContent);
    }
    addTab("SameRuleDifferentDomain", tabTitle, tabContent);
    switchTab("SameRuleDifferentDomain");
  });
};

var isOpera = function() {
  return navigator.userAgent.indexOf("OPR/") > -1;
};
var chromeListener = function(msg) {
  var el, i, tr = document.querySelector("tr.pendingDomainCheck[data-domain='" + msg.domain + "']"), top;
  if (msg.installed) {
    el = document.querySelector(".extensionMissing");
    if (msg.incognito) {
      el.parentElement.removeChild(el);
    } else {
      el.textContent = "You need to provide the extension access to incognito pages for it to function correctly. The extension uses incognito pages to determine whether an URL is live, so that no unwanted websites will end up in your search history or leave cookies behind. Furthermore, this way it can fully disable plugins on the websites it opens to prevent security issues, without comprimising your normal browsing on regular tabs. Please visit about://extensions and check the box to allow the extension access to " + (isOpera() ? "private" : "incognito") + " mode. ";
      var a = createTag("a", {href: "#", title: "Retry!"}, {textContent: "Retry!"}, el);
      a.addEventListener("click", function(e) {
        e.preventDefault();
        chromeConnect(chromeConnect.maxIndent, true);
      }, false);
    }
  } else if (msg.cancelled) {
    tr = document.querySelectorAll("tr.pendingDomainCheck");
    for (i=0; i<tr.length; i++) {
      tr[i].classList.remove("pendingDomainCheck");
      tr[i].classList.add("cancelledDomainCheck");
      tr[i].childNodes[1].textContent = "cancelled...";
    }
  } else if (msg.started) {
    tr.childNodes[1].textContent = "checking...";
  } else if (msg.passed) {
    top = tr.dataset.top;
    do {
      document.getElementById("domainCheckProgress").value += 1;
      tr.classList.remove("pendingDomainCheck");
      tr.classList.add("passedDomainCheck");
      tr.childNodes[1].textContent = "OK";
      tr = document.querySelector("tr.pendingDomainCheck[data-domain='" + tr.dataset.parent + "']");
    } while (tr);
    if (!document.querySelector("[data-top='" + top + "']:not(.passedDomainCheck)")) {
      top = document.querySelectorAll("[data-top='" + top + "']");
      window.setTimeout(function() {
        var i;
        for (i=0; i<top.length; i++) {
          top[i].parentElement.removeChild(top[i]);
        }
      }, 1000);
    }
    document.getElementById("domainCheckProgress").title = document.getElementById("domainCheckProgress").value
                                                           + "/" + document.getElementById("domainCheckProgress").max;
  } else {
    document.getElementById("domainCheckProgress").value += 1;
    document.getElementById("domainCheckProgress").title = document.getElementById("domainCheckProgress").value
                                                           + "/" + document.getElementById("domainCheckProgress").max;
    tr.classList.remove("pendingDomainCheck");
    tr.classList.add("failedDomainCheck");
    tr.childNodes[1].textContent = msg.msg;
  }
  if (msg.remaining === 0) {
    chromeConnect(chromeConnect.maxIndent - 1, false);
  }
};
var chromeConnect = function(maxIndent, firstTime) {
  var j, port, els,
      domains = [],
      extensionID = isOpera() ? "jmcmbnjnjmkfmkgpfppghcagmhofghjh" : "jmcmbnjnjmkfmkgpfppghcagmhofghjh"; // for debugging, use local ID!
 //extensionID = "aelckglegkcbdbilkhepjhkhkgeidilg"; //TODO: REMOVE
  chromeConnect.maxIndent = maxIndent;
  try {
    port = chrome.runtime.connect(extensionID);
    port.onMessage.addListener(chromeListener);
    if (firstTime) {
      port.postMessage({prepare: true});
    } else if (maxIndent === -1) {
      port.postMessage({done: true});
    }
  } catch(ex) {
    return;
  }
  if (maxIndent > 0) {
    els = document.querySelectorAll("tr.pendingDomainCheck > td[data-indent='" + maxIndent + "']");
  } else if (maxIndent === 0) {
    els = document.querySelectorAll("tr.pendingDomainCheck > td:first-child");
  } else {
    document.getElementById("domainCheckProgress").classList.add("hidden");
    return;
  }
  for (j=0; j<els.length; j++) {
    domains.push(els[j].parentNode.dataset.domain);
  }
  if (domains.length === 0) {
    chromeConnect(maxIndent - 1, false);
    return;
  }
  try {
    port.postMessage({domains: domains});
  } catch(ex) {}
};

var startToolDomainCheck = function() {
  if (document.getElementById("tab_Domaincheck")) {
    switchTab("Domaincheck");
    return;
  }
  startWorker("generateDomainTable.js", {filters: toolsFile}, function(e) {
    var i,
        results = e.results,
        isSupported = true;
    var tabTitle = createTag("span", {"class": "toolsTab"}, {textContent: "Dead domains"});
    var tabContent = createTag("div");
    createTag("p", {}, {textContent: "The following table shows whether domains are live, dead, redirected or parked."}, tabContent);
    createTag("em", {}, {textContent: "Please note: even if the tool is unable to detect any live web pages on a domain, there might be live pages on the domain or its subdomains!"}, tabContent);
    createTag("br", {}, {}, tabContent);
    createTag("em", {}, {textContent: "Manually visit the original URL for which the filter was added and use a search engine to be sure a domain is really gone. Third-party domains are ignored."}, tabContent);
    if (typeof chrome === "undefined" || !chrome.runtime || !chrome.runtime.connect) {
      createTag("div", {"class": "workerUnsupported"}, {textContent: "Unfortunately this tool has to perform actions that web pages are not allowed to do by themselves. Browser extensions have more permissions and can therefore aid in this process. For Chrome/Opera I wrote such an extension. Unfortunately no such extension is available for your browser. Sorry :("}, tabContent);
      isSupported = false;
    }
    createTag("br", {}, {}, tabContent);
    createTag("br", {}, {}, tabContent);

    var table = createTag("table", {"class": "toolsResults"}, {}, tabContent);
    var ttype = createTag("thead", {}, {}, table);
    var tline = createTag("tr", {}, {}, ttype);
    var th = createTag("th", {}, {textContent: "Domain"}, tline);
    createTag("th", {}, {textContent: "Status"}, tline);
    createTag("th", {}, {textContent: "Filters"}, tline);
    createTag("progress", {value: 0, id: "domainCheckProgress", max: Object.keys(results).length, title: "0/" + Object.keys(results).length}, {}, th);
    ttype = createTag("tbody", {}, {}, table);
    var domains = Object.keys(results).sort();
    var subdomains = [];
    for (i=0; i<domains.length; i++) {
      if (!results[domains[i]].parentDomain) {
        tline = createTag("tr", {"data-domain": domains[i], "class": "pendingDomainCheck"}, {}, ttype);
        subdomains = subdomains.concat(results[domains[i]].subdomains.reverse());
        createTag("td", {}, {textContent: domains[i]}, tline);
        createTag("td", {}, {textContent: "pending..."}, tline);
        createTag("td", {"class": "filterCell"}, {textContent: results[domains[i]].filters.join("\n")}, tline);
      }
    }
    var maxIndent = 0;
    while (subdomains.length > 0) {
      tline = createTag("tr", {"data-domain": subdomains[0], "data-parent": results[subdomains[0]].parentDomain, "class": "pendingDomainCheck"}, {});
      var parentRow = ttype.querySelector("tr[data-domain='" + results[subdomains[0]].parentDomain + "']");
      parentRow.parentNode.insertBefore(tline, parentRow.nextSibling);
      subdomains = subdomains.concat(results[subdomains[0]].subdomains.reverse());
      createTag("td", {"data-indent": Number(parentRow.firstChild.dataset.indent || 0) + 1}, {textContent: subdomains[0]}, tline);
      maxIndent = Math.max(Number(parentRow.firstChild.dataset.indent || 0) + 1, maxIndent);
      createTag("td", {}, {textContent: "pending..."}, tline);
      createTag("td", {"class": "filterCell"}, {textContent: results[subdomains[0]].filters.join("\n")}, tline);
      subdomains.shift();
    }

    var trs = ttype.querySelectorAll("tr"), topDomain;
    for (i=0; i<trs.length; i++) {
      if (!trs[i].dataset.parent) {
        topDomain = trs[i].dataset.domain;
      }
      trs[i].dataset.top = topDomain;
    }

    tline = createTag("tr", {"class": "emptynotifier"}, {}, ttype);
    createTag("td", {colspan: "3"}, {textContent: "All domains in the list seem to be online"}, tline);

    addTab("Domaincheck", tabTitle, tabContent);
    switchTab("Domaincheck");

    var extensionURL = isOpera() ? "data:text/html,the extension for Opera will be added as soon as possible, sorry to keep you waiting :(" : "https://chrome.google.com/webstore/detail/domain-check/jmcmbnjnjmkfmkgpfppghcagmhofghjh";
    if (isSupported) {
      chromeConnect(maxIndent, true);
      var div = createTag("div", {"class": "workerUnsupported extensionMissing hidden"}, {textContent: "Unfortunately this tool has to perform actions that web pages are not allowed to do by themselves. Browser extensions have more permissions and can therefore aid in this process. Therefore, in order to use this tool, you have to install the extension which you can obtain from "}, tabContent);
      createTag("a", {href: extensionURL, title: "Install", target: "_blank"}, {textContent: "here"}, div);
      createText(". After installing, you also have to give the extension access to the " + (isOpera() ? "private" : "incognito") + " mode via a check box on about://extensions . ", div);
      var aRetry = createTag("a", {href: "#", title: "Retry!"}, {textContent: "Retry!"}, div);
      aRetry.addEventListener("click", function(e) {
        e.preventDefault();
        chromeConnect(maxIndent, true);
      }, false);
      window.setTimeout(function() {
        div.classList.remove("hidden");
      }, 1234);
    }
    
    var aExport = createTag("a", {title: "Export domain check results", href: "#"}, {textContent: "Export results"}, tabContent);
    aExport.addEventListener("click", function(e) {
      e.preventDefault();
      var output = "",
          els = document.querySelectorAll(".failedDomainCheck,.cancelledDomainCheck,.pendingDomainCheck");
      if (els.length) {
        var i,
            domains = [],
            filters=[],
            errors = [],
            maxLength = 0;
        for (i=0; i<els.length; i++) {
          domains.push(els[i].children[0].textContent);
          errors.push(els[i].children[1].textContent);
          filters = filters.concat(els[i].children[2].textContent.split("\n"));
          maxLength = Math.max(maxLength, domains[i].length);
        }
        for (i=0; i<els.length; i++) {
          output += "\n!" + new Array(maxLength - domains[i].length + 1).join(" ") + domains[i] + " => " + errors[i];
        }
        output += "\n\n\n! Involved filters:\n\n" + filters.sort().filter(function(elem, i, arr) {return elem !== arr[i+1]}).join("\n");
      } else {
        output = document.querySelector("#tab_Domaincheck .toolsResults .emptynotifier").textContent;
      }
      window.open("data:text/plain;charset=utf-8," + encodeURIComponent("! Redundancy check domain check results:\n" + output).replace(/\'/g, "%27"));
    }, false);
  });
};


var startToolWhitelists = function() {
  if (document.getElementById("tab_WhitelistsPerRule")) {
    switchTab("WhitelistsPerRule");
    return;
  }
  startWorker("findWhitelistRules.js", {filters: toolsFile}, function(e) {
    var i, results = e.resultByFilter;
    var tabTitle = createTag("span", {"class": "toolsTab"}, {textContent: "whitelists per rule"});
    var tabContent = createTag("div");
    createTag("p", {}, {textContent: "The following rules have one or more matching whitelists"}, tabContent);
    createTag("em", {}, {textContent: "Please note: this is only an indication! If the rule isn't litterally included in the whitelist, it won't be found!"}, tabContent);
    createTag("br", {}, {}, tabContent);
    var div = createTag("div", {"class": "toolsResults"}, {}, tabContent);
    var b, j, pre;
    var clickhandler = function() {
      this.nextElementSibling.classList.toggle("hidden");
    };
    var keys = Object.keys(results);
    keys.sort(function(a, b) {
      if (results[a].length === results[b].length) {
        return a > b ? 1 : -1;
      }
      return results[a].length > results[b].length ? -1 : 1;
    });
    for (i=0; i<keys.length; i++) {
      b = createTag("strong", {}, {}, div);
      b.addEventListener("click", clickhandler, false);
      createText(keys[i] + " ", b);
      createTag("em", {}, {textContent: " (" + Object.keys(results[keys[i]]).length + ")"}, b);

      pre = createTag("pre", {"class": "hidden"}, {}, div);
      results[keys[i]].sort();
      for (j=0; j<results[keys[i]].length; j++) {
        createTag("span", {"class": "priority10"}, {textContent: results[keys[i]][j]}, pre);
        createTag("br", {}, {}, pre);
      }
    }
    if (Object.keys(results).length === 0) {
      createTag("p", {}, {textContent: "No results found!"}, tabContent);
    }
    addTab("WhitelistsPerRule", tabTitle, tabContent);
    switchTab("WhitelistsPerRule");



    results = e.resultByWhitelist;
    tabTitle = createTag("span", {"class": "toolsTab"}, {textContent: "rules per whitelist"});
    tabContent = createTag("div");
    createTag("p", {}, {textContent: "The following shows the amount of rules that are involved in the whitelist"}, tabContent);
    createTag("em", {}, {textContent: "Please note: this is only an indication! If the rule isn't litterally included in the whitelist, it won't be found!"}, tabContent);
    createTag("br", {}, {}, tabContent);
    div = createTag("div", {"class": "toolsResults"}, {}, tabContent);
    keys = Object.keys(results);
    keys.sort(function(a, b) {
      if (results[a].length === results[b].length) {
        return a > b ? 1 : -1;
      }
      return results[a].length > results[b].length ? -1 : 1;
    });
    for (i=0; i<keys.length; i++) {
      b = createTag("strong", {}, {}, div);
      b.addEventListener("click", clickhandler, false);
      createText(keys[i] + " ", b);
      createTag("em", {}, {textContent: " (" + Object.keys(results[keys[i]]).length + ")"}, b);

      pre = createTag("pre", {"class": "hidden"}, {}, div);
      results[keys[i]].sort();
      for (j=0; j<results[keys[i]].length; j++) {
        createTag("span", {"class": "priority10"}, {textContent: results[keys[i]][j]}, pre);
        createTag("br", {}, {}, pre);
      }
    }
    if (Object.keys(results).length === 0) {
      createTag("p", {}, {textContent: "No results found!"}, tabContent);
    }
    addTab("RulesPerWhitelist", tabTitle, tabContent);
  });
};

var startRedundancyCheck = function() {
  removeTabs();
  toolsFile = "\n";
  startWorker("redundant.js", {filters: document.getElementById("filters").value}, function(e) {
    var i, redundant = e.results, time = e.seconds, warnings = e.warnings;

    // REDUNDANCIES TAB
    var tabTitle = createTag("span", {}, {textContent: "redundancies (" + Object.keys(redundant).length + ")"});
    var tabContent = createTag("div");
    createTag("p", {}, {
        textContent: "Finished (after " + (time === 1 ? "1 second" : time + " seconds") + ")!  " +(Object.keys(redundant).length || "No") + " redundant rule" + (Object.keys(redundant).length === 1 ? "" : "s") + " found!"
      }, tabContent);
    for (i in redundant) {
      if (location.search !== "?nodups" || i.toLowerCase() !== redundant[i].toLowerCase()) {// TEMP, on Fanboys request
        createTag("strong", {}, {textContent: i}, tabContent);
        createText(" has been made redundant by ", tabContent);
        createTag("strong", {}, {textContent: redundant[i]}, tabContent);
        createTag("br", {}, {}, tabContent);
      }
    }
    addTab("Redundancies", tabTitle, tabContent);

    // CORRECTED FILE TAB
    tabTitle = createTag("span", {}, {textContent: "corrected"});
    tabContent = createTag("div");
    var oldFile = document.getElementById("filters").value.split("\n"), duplicates = {}, newFile = "";
    for (i=0; i<oldFile.length; i++) {
      if (redundant[oldFile[i]]) {
        if (redundant[oldFile[i]] === oldFile[i] && !duplicates[oldFile[i]]) {
          duplicates[oldFile[i]] = true;
        } else {
          continue;
        }
      }
      newFile += oldFile[i] + "\n";
      if (oldFile[i] && !/^\s*(?:\!|.*\[Adblock.*\]|\s+$)/i.test(oldFile[i])) {
        toolsFile += oldFile[i] + "\n";
      }
    }
    createText("The file without redundancies: ", tabContent);
    createTag("a", {href: "#"}, {textContent: "open in a new tab"}, tabContent).
        addEventListener("click", function() {
          window.open("data:text/plain;charset=utf-8," + encodeURIComponent(newFile).replace(/\'/g, "%27"));
          event.preventDefault();
        }, false);
    createTag("pre", {}, {textContent: newFile}, tabContent);
    addTab("Corrected", tabTitle, tabContent);

    // WARNINGS TAB
    var p, minor, major, minorwarningcount = 0;
    tabContent = createTag("div");
    if (warnings.length > 1) {
      p = createTag("p", {}, {}, tabContent);
      createText("The following " + warnings.length + " ", p);
      createTag("span", {"class": "majorwarning"}, {"textContent": "errors"}, p);
      createText(", warnings or ", p);
      createTag("span", {"class": "minorwarning"}, {"textContent": "optimalizations"}, p);
      createText(" were encountered while checking the rules:", p);
    } else if (warnings.length === 1) {
      p = createTag("p", {}, {}, tabContent);
      createText("The following ", p);
      createTag("span", {"class": "majorwarning"}, {"textContent": "error"}, p);
      createText(", warning or ", p);
      createTag("span", {"class": "minorwarning"}, {"textContent": "optimalization"}, p);
      createText(" was encountered while checking the rules:", p);
    } else {
      createTag("p", {}, {textContent: "No errors or warnings were encountered while checking the rules"}, tabContent);
    }
    major = createTag("span", {"class": "majorwarning"}, {}, tabContent);
    minor = createTag("span", {"class": "minorwarning"}, {});
    for (i=0; i<warnings.length; i++) {
      var j, cat = tabContent;
      if (warnings[i].priority === "H") {
        cat = major;
        toolsFile = toolsFile.replace(new RegExp("\n" + warnings[i].rules[0].replace(/\W/g, "\\$&") + "\n", "g"), "\n");
      } else if (warnings[i].priority === "L") {
        cat = minor;
        minorwarningcount++;
      }

      for (j=0; j<warnings[i].rules.length; j++) {
        createTag("strong", {}, {textContent: warnings[i].rules[j]}, cat);
        if (j < warnings[i].rules.length-1) {
          if (j < warnings[i].rules.length-2) {
            createText(", ", cat);
          } else {
            createText(" and ", cat);
          }
        }
      }
      createText(" : " + warnings[i].msg, cat);
      createTag("br", {}, {}, cat);
    }
    tabContent.appendChild(minor);

    tabTitle = createTag("span");
    createText("warnings (" + (warnings.length - minorwarningcount), tabTitle);
    if (minorwarningcount) {
      createTag("span", {"class": "minorwarning"}, {textContent: "+" + minorwarningcount}, tabTitle);
    }
    createText(")", tabTitle);
    addTab("Warnings", tabTitle, tabContent, 1);


    // TOOLS TAB
    tabTitle = createTag("span", {"class": "toolsTab"}, {textContent: "tools"});
    tabContent = createTag("div");
    createTag("em", {}, {textContent: "The tools below should only be used to gather information. There is no guarantee that any of the results do actually mean something, neither that the results are complete. Therefore, these tools should NOT be used, unless you're very sure what you're doing. Results that are already mentioned in preceding tabs will be ignored here. If you modify the contents of the big text box above, first click 'Check for redundant rules' before using any of the tools."}, tabContent);
    createTag("br", {}, {}, tabContent);
    createTag("br", {}, {}, tabContent);

    var tools = {
      "buttonSimilar": {
        shortDesc: "Search for rules that look the same",
        longDesc: "This option will start a search for rules that look about the same. It does not check the syntax, so you might end up with very weird matches. It however allows you to find rules that are similar, although not exactly the same. The output is a list of all rules that are similar to another rule.",
        fn: startToolSimilar
      },
      "buttonNoOptionsNoDomains": {
        shortDesc: "Ignore the domain and rule options when searching for redundancies",
        longDesc: "This option will act like the normal redundancy check, except for that it ignores the domains of all types of rules, as well as the options (like $image) for blocking/whitelisting rules.",
        fn: startToolLessOptions
      },
      "buttonNoOptions": {
        shortDesc: "Ignore the rule options when searching for redundancies",
        longDesc: "This option will act like the normal redundancy check, except for that it ignores the options (like $image) for blocking/whitelisting rules. The option $domain=a|b|c is not ignored.",
        fn: startToolLessOptions
      },
      "buttonNoDomains": {
        shortDesc: "Ignore the domains when searching for redundancies",
        longDesc: "This option will act like the normal redundancy check, except for that it ignores the domains of all types of rules.",
        fn: startToolLessOptions
      },
      "buttonLoosely": {
        shortDesc: "Search for redundancies using a less strict method",
        longDesc: "This option will instruct the normal redundancy check to mark a rule as redundant when there is a chance that they are redundant, although not all requirements have been met to be truely redundant.",
        fn: startToolLessOptions
      },
      "buttonOnlyDomainDiffers": {
        shortDesc: "Search for equal rules for which only the domain differs",
        longDesc: "This option will allow you to find rules for which everything is exactly the same, except for the domain. It'll for example tell you that the rules 'domain1.com###banner' and 'domain2.net###banner' both use the rule '###banner'. The output is a list of rules that share the same rule.",
        fn: startToolOnlyDomainDiffers
      },
      "buttonCheckWhitelists": {
        shortDesc: "Find rules that were matched by whitelist rules",
        longDesc: "This option allows you to find out how many whitelists you have for a specific rule. It outputs a list of rules and which whitelist rules match them, as well as a list of whitelist rules and which rules have been matched by them.",
        fn: startToolWhitelists
      },
      "buttonHidingToBlocking": {
        shortDesc: "Find hiding rules that can be converted to blocking rules",
        longDesc: "This option allows you to find hiding rules that can potentially become blocking rules.",
        fn: startToolHideToBlock
      },
      "buttonDomainCheck": {
        shortDesc: "Find dead, redirected or parked domains",
        longDesc: "This option allows you to find rules for which some domains can be removed because they are either dead, redirected and/or parked. This requires an additional browser extension for Chrome or Opera",
        fn: startToolDomainCheck
      }
    };
    var mouseoverfn = function(e) {
      document.getElementById("toolsdescription").textContent = tools[e.target.id].longDesc;
    };
    for (i in tools) {
      var btn = createTag("input", {type: "button", id: i, value: tools[i].shortDesc}, {}, tabContent);
      btn.addEventListener("click", tools[i].fn, false);
      btn.addEventListener("mouseover", mouseoverfn, false);


      createTag("br", {}, {}, tabContent);
    }

    p = createTag("fieldset", {}, {}, tabContent);
    createTag("legend", {}, {textContent: "Description"}, p);
    createTag("p", {id: "toolsdescription"}, {textContent: "Move your mouse over a button to show the description."}, p);

    addTab("Tools", tabTitle, tabContent);
    switchTab("Redundancies");
  });
};

window.setTimeout(function() {
  try {
    new Worker("redundant.js").terminate();
    var fn = function() {
      if (this /*strict mode unsupported*/ || Object.hasOwnProperty("__proto__") /*__proto__ is treated as custom property*/) {
        createTag("div", {"class": "workerUnsupported"}, {"textContent": "Your current browser has some limitations. Proceed with caution or use a different browser."}, document.body);
      }
    };
    fn();
    var btnstart = document.getElementById("btnstart");
    btnstart.addEventListener("click", startRedundancyCheck, false);
    btnstart.removeAttribute("disabled");
  } catch(ex) {
    createTag("div", {"class": "workerUnsupported"}, {"textContent": "Your browser does not support web workers."}, document.body);
  }

  document.addEventListener("click", function(e) {
    var p = e.target;
    while (p) {
      if (p.id === "information" || p.id === "helplink") {
        return;
      }
      if (p.id === "closeinformation") {
        break;
      }
      p = p.parentNode;
    }
    document.getElementById("information").classList.add("hidden");
  }, false);
  document.getElementById("helplink").addEventListener("click", function() {
    document.getElementById("information").classList.remove("hidden");
    event.preventDefault();
  }, false);
}, 0);