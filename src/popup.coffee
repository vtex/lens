$(document).ready ->
	chrome.tabs.query {active: true, currentWindow: true}, (tabs) ->
		tab = tabs[0]

		systems = {}

		a = document.createElement("a")
		a.href = tab.url

		siteName = null
		if /vtexcommerce/.test(a.hostname)
			parts = a.hostname.split('.')
			siteName = (if parts[0] is "www" or parts[0] is "loja" then parts[1] else parts[0])
		else if jsnomeSite?
			siteName = jsnomeSite
		else
			parts = a.hostname.split('.')
			siteName = (if parts[0] is "www" or parts[0] is "loja" then parts[1] else parts[0])

		isVtex = ->
			!(siteName in ['', null, undefined])

		changeVtexEnv = (env, callback) ->
			url = a.protocol + "//" + siteName + "." + env + ".com.br" + a.pathname + a.search + a.hash
			chrome.tabs.update tab.id, url: url
			callback()

		refreshSiteName = ->
			if isVtex()
				$('#sitename').text(siteName).removeClass('warning')
			else
				$('#sitename').text('desconhecido').addClass('warning')

		refreshEnv = ->
			if isVtex()
				$('#env a').removeClass('pure-button-disabled')
			else
				$('#env a').addClass('pure-button-disabled')

		refreshCookies = ->
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
						when 1, "1", "Value=1"
							status.text('disabled').addClass('disabled')
						else #when 0, "0", "Value=0"
							status.text('enabled').addClass('enabled')

		refreshSystems = ->
			list = $('#app-list').empty()
			for name, props of systems
				title = $("<dt>#{name}</dt>")
				desc = $('<dd></dd>')
				for propName, propValue of props
					desc.append $ "<p>#{propName}: #{propValue}</p>"
				list.append(title, desc)

		refresh = ->
			refreshSiteName()
			refreshEnv()
			refreshCookies()
			refreshSystems()

		bindActions = ->
			$(".env-change").on "click", ->
				unless $(this).hasClass('pure-button-disabled')
					changeVtexEnv $(this).data("env"), ->
						window.close()

			$('#cookies .action').on 'click', ->
				value = if $(this).hasClass('enable') then 'Value=0' else 'Value=1'
				name = $(this).closest('.cookie').data('cookieName')
				chrome.cookies.set {url: tab.url, name: name, value: value, expirationDate: moment().add('days', 7).unix()}
				refresh()

		chrome.webRequest.onCompleted.addListener ((req) ->
			headers = {}
			headers[h.name] = h.value for h in req.responseHeaders

			if appName = headers['X-VTEX-Router-Backend-App']
				systems[appName] =
					version: headers['X-VTEX-Router-Backend-Version']
					environment: headers['X-VTEX-Router-Backend-Environment']

				refreshSystems()

		), {urls: ["*://*/*"], tabId: tab.id}, ["responseHeaders"]

		refresh()
		bindActions()

		return