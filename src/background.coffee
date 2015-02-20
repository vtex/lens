#
# BACKGROUND
#
# Listens to relevant changes in the background.
# Provides the necessary data to Services.
#

versions = {}
clientCss = true
isVtex = {}

chrome.webRequest.onBeforeRequest.addListener ((request) ->
	if !clientCss and request.url.indexOf('checkout-custom.css') != -1
		return {cancel: true}

), {urls: ["*://*/*"]}, ["blocking"]

chrome.webRequest.onCompleted.addListener ((request) ->
	if request.tabId is -1 then return

	chrome.tabs.get request.tabId, (tab) =>
		uri = URI(tab.url)

		versions[uri.hostname()] or= {}
		isVtex[uri.hostname()]   or= false

		headers = {}
		headers[h.name] = h.value for h in request.responseHeaders

		appName = headers['X-VTEX-Router-Backend-App']
		version = headers['X-VTEX-Router-Backend-Version']
		environment = headers['X-VTEX-Router-Backend-Environment']

		if headers['X-Powered-by-VTEX-Janus-Edge']
			isVtex[uri.hostname()] = true

		if appName
			if not version
				# The -Version header sometimes is bundled with the -App header
				# "portal - v1.0.22"
				[appName, version] = appName.split(' - ')
			versions[uri.hostname()][appName] = "#{version} #{environment}"
			chrome.runtime.sendMessage {message: 'refresh'}

		match = request.url.match(/https?:\/\/io\.vtex\.com\.br\/([^\/]*)\/([^\/]*)\/(.*)/)
		# match[1] == front-portal-plugins
		# match[2] == v02-01-00-stable-25
		# match[3] == js/portal-template-as-modal.min.js
		if match and match[1] != 'front-libs'
			versions[uri.hostname()][match[1]] = match[2]

), {urls: ["*://*/*"]}, ["responseHeaders"]

chrome.runtime.onMessage.addListener (request, sender, sendResponse) =>
	if request.service == 'versions'
		sendResponse(versions[request.hostname] or {})
	else if request.service == 'isVtex'
		sendResponse(isVtex[request.hostname] or (versions[request.hostname] && Object.keys(versions[request.hostname]).length > 0))
	else if request.service == 'clientCss'
		sendResponse(clientCss)
	else if request.service == 'setClientCss'
		clientCss = request.value
