#
# BACKGROUND
#
# Listens to relevant changes in the background.
# Provides the necessary data to Services.
#

versions = versions || {}
isVtex = false

chrome.webRequest.onCompleted.addListener ((request) ->
	chrome.tabs.get request.tabId, (tab) =>
		a = document.createElement("a")
		a.href = tab.url

		versions[a.hostname] or= {}

		headers = {}
		headers[h.name] = h.value for h in request.responseHeaders

		appName = headers['X-VTEX-Router-Backend-App']

		if appName
			versions[a.hostname][appName] =
				version: headers['X-VTEX-Router-Backend-Version']
				environment: headers['X-VTEX-Router-Backend-Environment']

), {urls: ["*://*/*"]}, ["responseHeaders"]

chrome.runtime.onMessage.addListener (request, sender, sendResponse) =>
	if request.service == 'versions'
		sendResponse(versions[request.hostname] or {})
	else if request.service == 'isVtex'
		sendResponse(Object.keys(versions[request.hostname]).length > 0)
