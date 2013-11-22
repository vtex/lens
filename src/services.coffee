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
		a = document.createElement("a")
		a.href = tab.url
		chrome.runtime.sendMessage {service: 'versions', hostname: a.hostname}, (response) ->	
			callback(response)

root.CookiesService = (callback) ->
	TabService (tab) ->
		chrome.cookies.getAll {url: tab.url}, (cookies) ->
			cookiesObj = {}
			cookiesObj[c.name] = c.value for c in cookies
			callback(cookiesObj)

root.IsVtexService = (callback) ->
	TabService (tab) ->
		a = document.createElement("a")
		a.href = tab.url
		chrome.runtime.sendMessage {service: 'isVtex', hostname: a.hostname}, (response) ->	
			callback(response)

root.SiteNameService = (callback) ->
	TabService (tab) ->
		a = document.createElement("a")
		a.href = tab.url

		if /vtexcommerce/.test(a.hostname)
			parts = a.hostname.split('.')
			siteName = (if parts[0] is "www" or parts[0] is "loja" then parts[1] else parts[0])
		else if jsnomeSite?
			siteName = jsnomeSite
		else
			parts = a.hostname.split('.')
			siteName = (if parts[0] is "www" or parts[0] is "loja" then parts[1] else parts[0])

		callback(siteName)