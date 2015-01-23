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
		list = $('#app-list tbody').empty()
		for name, version of versions
			$(list).append($("<tr><strong><td>#{name}</td><td>#{version}</td></tr>"))

	showSiteInfo = (isVtex) ->
		if isVtex
			SiteNameService (siteName) ->
				$('#sitename').removeClass('warning')
				$('#sitename').text(siteName) if $('#sitename').text() isnt siteName
				$('.hide-not-vtex').show()
				$('.show-not-vtex').hide()

			TabService (tab) ->
				uri = URI(tab.url)
				$('#djs .btn').removeClass('enabled disabled')
				if uri.search(true)["debugjs2"] == "true"
					$('#djs').addClass('enabled')
				else
					$('#djs').addClass('disabled')

			ClientCssService (clientCss) ->
				$('#ccss .btn').removeClass('enabled disabled')
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

		$('#workspace').val(cookies['vtex_workspace']);

	refresh = ->
		VersionsService showVersions
		CookiesService showCookies
		IsVtexService showSiteInfo

	# bind actions
	$('.tab-control .nav a').on 'click mouseenter', (e) ->
		e.preventDefault()
		$(this).tab('show')

	$('#version').on 'click', ->
		changeUrl 'https://github.com/vtex/lens#changelog'
	
	$(".env-change").on "click", ->
		unless $(this).hasClass('pure-button-disabled')
			env = $(this).data("env")
			changeEnv(env)

	$('.cookie .btn').on 'click', ->
		cookieElem = $(this).closest('.cookie')
		key = $(cookieElem).data('cookieName')
		value = if $(cookieElem).hasClass('disabled') then 'Value=0' else 'Value=1'
		changeCookie(key, value)

	$('#djs .btn').on 'click', ->
		cookieElem = $(this).closest('.cookie')
		key = 'debugjs2'
		value = if $(cookieElem).hasClass('disabled') then 'true' else 'false'
		changeQueryString(key, value)

	$('#ccss .btn').on 'click', ->
		cookieElem = $(this).closest('.cookie')
		value = if $(cookieElem).hasClass('disabled') then true else false
		SetClientCssService value

	setWorkspace = (ev) ->
		ev.preventDefault()
		changeCookie('vtex_workspace', $('#workspace').val())

	$('#gallery .btn').on 'click', setWorkspace
	$('.form-workspace').on 'submit', setWorkspace

	refresh()
	
	chrome.runtime.onMessage.addListener (request, sender, sendResponse) =>
		if request.message == 'refresh'
			refresh()