// ==UserScript==
// @name         Remove Google junks
// @namespace    https://www.google.com/search
// @version      1.0
// @description  Remove useless results from google search
// @author       astralbody
// @match        https://www.google.com/search*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=tampermonkey.net
// @grant        none
// @require      https://cdn.jsdelivr.net/npm/umbrellajs
// ==/UserScript==

/* global u */
(function () {
	"use strict";
	const RESULTS_ID = "#rso";
	const BLOCK_LIST = ["w3schools.com", "geeksforgeeks.org"];

	const shouldBlockNode = (node) =>
		BLOCK_LIST.some((domain) => u(node).find("a").attr("href").includes(domain));

	u(RESULTS_ID).children().filter(shouldBlockNode).remove();
})();
