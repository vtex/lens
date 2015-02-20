# 
# SERVICES
# 
# Provides Services for accessign data collected by Background.
#

root = window || exports

root.TabService = (callback) ->
	chrome.tabs.query {active: true, currentWindow: true}, (tabs) ->
		callback(tabs[0])

root.VersionsService = (callback) ->
	TabService (tab) ->
		chrome.runtime.sendMessage {service: 'versions', hostname: URI(tab.url).hostname()}, (response) ->	
			callback(response)

root.CookiesService = (callback) ->
	TabService (tab) ->
		chrome.cookies.getAll {url: tab.url}, (cookies) ->
			cookiesObj = {}
			cookiesObj[c.name] = c.value for c in cookies
			callback(cookiesObj)

root.IsVtexService = (callback) ->
	TabService (tab) ->
		chrome.runtime.sendMessage {service: 'isVtex', hostname: URI(tab.url).hostname()}, (response) ->
			callback(response)

root.SiteNameService = (callback) ->
	TabService (tab) ->
		uri = URI(tab.url)

		if /vtexcommerce/.test(uri.hostname())
			parts = uri.hostname().split('.')
			siteName = (if parts[0] is "www" or parts[0] is "loja" then parts[1] else parts[0])
		else
			# TODO melhorar
			parts = uri.hostname().split('.')
			siteName = (if parts[0] is "www" or parts[0] is "loja" then parts[1] else parts[0])

		callback(siteName)

root.ClientCssService = (callback) ->
	chrome.runtime.sendMessage {service: 'clientCss'}, (response) ->	
		callback(response)

root.SetClientCssService = (value) ->
	chrome.runtime.sendMessage {service: 'setClientCss', value: value}
