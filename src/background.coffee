systems = systems || {}

chrome.webRequest.onCompleted.addListener ((request) ->
	chrome.tabs.get request.tabId, (tab) =>
		a = document.createElement("a")
		a.href = tab.url

		systems[a.hostname] or= {}

		headers = {}
		headers[h.name] = h.value for h in request.responseHeaders

		appName = headers['X-VTEX-Router-Backend-App']

		if appName
			systems[a.hostname][appName] =
				version: headers['X-VTEX-Router-Backend-Version']
				environment: headers['X-VTEX-Router-Backend-Environment']

), {urls: ["*://*/*"]}, ["responseHeaders"]

chrome.runtime.onMessage.addListener (request, sender, sendResponse) =>
	if request.service == 'systems'
		sendResponse(systems[request.hostname] or {})
