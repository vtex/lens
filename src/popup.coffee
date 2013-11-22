$(document).ready ->

	changeEnv = (env) ->
		TabService (tab) ->		
			a = document.createElement("a")
			a.href = tab.url
			url = a.protocol + "//" + siteName + "." + env + ".com.br" + a.pathname + a.search + a.hash
			chrome.tabs.update tab.id, url: url
			window.close()

	changeCookie = (name, value) ->
		TabService (tab) ->
			week = parseInt((new Date/1000) + 7*24*60*60)
			chrome.cookies.set {url: tab.url, name: name, value: value, expirationDate: week} 
			CookiesService showCookies

	showVersions = (versions) ->
		list = $('#app-list').empty()
		for name, props of versions
			title = $("<dt>#{name}</dt>")
			desc = $('<dd></dd>')
			for propName, propValue of props
				desc.append $ "<p>#{propName}: #{propValue}</p>"
			list.append(title, desc)

	showSiteInfo = (isVtex) ->
		if isVtex
			SiteNameService (siteName) ->
				$('#sitename').removeClass('warning')
				$('#sitename').text(siteName) if $('#sitename').text() isnt siteName
				$('.hide-not-vtex').show()
				$('.show-not-vtex').hide()
		else
			$('#sitename').text('desconhecido').addClass('warning')
			$('.hide-not-vtex').hide()
			$('.show-not-vtex').show()

	showCookies = (cookies) ->
		section = $('#cookies')

		section.find('li').each (i, el) ->
			$el = $(el)
			name = $el.data('cookieName')
			id = $el.attr('id')
			status = section.find('#' + id).find('.status')
			status.removeClass('enabled disabled')
			if cookies[name] in [1, "1", "Value=1"]
				status.text('disabled').addClass('disabled')
			else # in [0, "0", "Value=0"]
				status.text('enabled').addClass('enabled')

	refresh = ->
		VersionsService showVersions
		CookiesService showCookies
		IsVtexService showSiteInfo

	# bind actions
	$(".env-change").on "click", ->
		unless $(this).hasClass('pure-button-disabled')
			env = $(this).data("env")
			changeEnv(env)

	$('#cookies .action').on 'click', ->
		value = if $(this).hasClass('enable') then 'Value=0' else 'Value=1'
		name = $(this).closest('.cookie').data('cookieName')
		changeCookie(name, value)

	refresh()
	setInterval refresh, 200
	alert('oi')