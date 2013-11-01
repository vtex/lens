getTab = (callback) ->
	chrome.tabs.query {active: true, currentWindow: true}, (tabs) ->
		callback tabs[0]

changeVtexEnv = (env) ->
	getTab (tab) ->
		a = document.createElement("a")
		a.href = tab.url
		if /vtexcommerce/.test(a.hostname)
			parts = a.hostname.split(".")
			siteName = (if parts[0] is "www" then parts[1] else parts[0])
		else if jsnomeSite
			siteName = jsnomeSite
		else
			siteName = "UNKNOWN"
		url = a.protocol + "//" + siteName + "." + env + ".com.br" + a.pathname + a.search + a.hash
		chrome.tabs.update tab.id, url: url


$(".env-change").on "click", ->
	changeVtexEnv $(this).data("env")

refresh = ->
	getTab (tab) ->
		chrome.cookies.getAll {url: tab.url}, (cookies) ->
			section = $('#cookies')

			cookiesObj = {}
			cookies.forEach (c) ->
				cookiesObj[c.name] = c

			section.find('li').each (i, el) ->
				name = $(el).data('cookieName')
				id = $(el).attr('id')
				status = section.find('#' + id).find('.status').removeClass('enabled disabled unknown')
				switch cookiesObj[name]?.value
					when 0, "0", "Value=0"
						status.text('enabled').addClass('enabled')
					when 1, "1", "Value=1"
						status.text('disabled').addClass('disabled')
					else
						status.text('unknown').addClass('unknown')

$('#cookies .action').on 'click', ->
	value = if $(this).hasClass('enable') then 'Value=0' else 'Value=1'
	name = $(this).closest('.cookie').data('cookieName')
	getTab (tab) ->
		chrome.cookies.set {url: tab.url, name: name, value: value, expirationDate: moment().add('days', 7).unix()}
		refresh()


$(document).ready refresh