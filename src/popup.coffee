$(document).ready ->

	clientCss = true

	changeUrl = (url) ->
		TabService (tab) ->
			chrome.tabs.update tab.id, url: url
			window.close()

	changeEnv = (env) ->
		TabService (tab) ->		
			SiteNameService (siteName) ->
				uri = URI(tab.url)
				url = uri.protocol() + "://" + siteName + "." + env + ".com.br" + uri.pathname() + uri.search() + uri.hash()
				chrome.tabs.update tab.id, url: url
				window.close()

	changeCookie = (name, value) ->
		TabService (tab) ->
			week = parseInt((new Date/1000) + 7*24*60*60)
			chrome.cookies.set {url: tab.url, name: name, value: value, expirationDate: week} 
			CookiesService showCookies

	changeQueryString = (key, value) ->
		TabService (tab) ->
			uri = URI(tab.url)
			uri.removeSearch(key).addSearch(key, value)
			chrome.tabs.update tab.id, url: uri.toString()
			window.close()

	showVersions = (versions) ->
		list = $('#app-list').empty()
		for name, version of versions
			list.append($("<li><strong>#{name}</strong>: #{version}</li>"))

	showSiteInfo = (isVtex) ->
		if isVtex
			SiteNameService (siteName) ->
				$('#sitename').removeClass('warning')
				$('#sitename').text(siteName) if $('#sitename').text() isnt siteName
				$('.hide-not-vtex').show()
				$('.show-not-vtex').hide()

			TabService (tab) ->
				uri = URI(tab.url)
				$('#djs').removeClass('enabled disabled')
				if uri.search(true)["debugjs2"] == "true"
					$('#djs').addClass('enabled')
				else
					$('#djs').addClass('disabled')

			ClientCssService (clientCss) ->
				$('#ccss').removeClass('enabled disabled')
				if clientCss
					$('#ccss').addClass('enabled')
				else
					$('#ccss').addClass('disabled')

		else
			$('#sitename').text('desconhecido').addClass('warning')
			$('.hide-not-vtex').hide()
			$('.show-not-vtex').show()

	showCookies = (cookies) ->
		$('.cookie').each (i, el) ->
			$el = $(el).removeClass('enabled disabled')
			name = $el.data('cookieName')
			if cookies[name] in [1, "1", "Value=1"]
				$el.addClass('disabled')
			else # in [0, "0", "Value=0"]
				$el.addClass('enabled')

	refresh = ->
		VersionsService showVersions
		CookiesService showCookies
		IsVtexService showSiteInfo

	# bind actions
	$('#version').on 'click', ->
		changeUrl 'https://github.com/vtex/lens#changelog'
	
	$(".env-change").on "click", ->
		unless $(this).hasClass('pure-button-disabled')
			env = $(this).data("env")
			changeEnv(env)

	$('.cookie .action').on 'click', ->
		key = $(this).closest('.cookie').data('cookieName')
		value = if $(this).hasClass('enable') then 'Value=0' else 'Value=1'
		changeCookie(key, value)

	$('#djs .action').on 'click', ->
		key = 'debugjs2'
		value = if $(this).hasClass('enable') then 'true' else 'false'
		changeQueryString(key, value)

	$('#ccss .action').on 'click', ->
		value = if $(this).hasClass('enable') then true else false
		SetClientCssService value

	refresh()
	setInterval refresh, 200
