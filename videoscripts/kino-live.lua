-- видеоскрипт для сайта http://kino-live2.pw (11/10/20)
-- открывает подобные ссылки:
-- http://k34n.live2.pw/715734347-vzryv.html
-- http://k34n.live2.pw/715734379-kurator.html
-- ## прокси ##
local proxy = ''
-- '' - нет
--  'https://proxy-nossl.antizapret.prostovpn.org:29976' (пример)
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://kino%-live[%d+]*%.')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://kinolive%.')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://[%w.]*live2%.pw/')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	require 'json'
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000 * 5, id = 'channelName'})
	m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'kino-live ошибка: ' .. str, showTime = 8000, color = 0xffff6600, id = 'channelName'})
	end
	local host = inAdr:match('(https?://.-)/')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.3809.87 Safari/537.36', proxy, false)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local function nameclean(name)
		local name = name:gsub('%sHD', ''):gsub('1080p?', ''):gsub('720p?', ''):gsub('FullHD', ''):gsub('%(HD%)', ''):gsub('%(SATRip%)', ''):gsub('%(WEBRip%)', ''):gsub('%[%]', ''):gsub('%s%)', ')'):gsub('%(%)', ''):gsub('онлайн на.+', ''):gsub(' смотреть онлайн.-$', '')
	 return name
	end
	local function GetAddressFromPlaylist(answer)
		local tab = json.decode(answer)
			if not tab or not tab.playlist then
				showError('1')
			 return
			end
		local a, n, k, l, sezon = {}, 1
		local Adr, sezon = '', ''
		for i = 1, #tab.playlist, 1 do
			local t = tab.playlist
			local isfile
			if t[i].file ~= nil then
				k = 1
				isfile = true
			else
				if t[i].playlist == nil then break end
				t = t[i].playlist
				k = #t
				isfile = false
			end
			if k > 1 then
				sezon = tab.playlist[i].comment
				sezon = ' (' .. sezon .. ')'
			end
			for j = 1, k, 1 do
				a[n] = {}
				a[n].Id = n
				if isfile == true then
					l = i
				elseif isfile == false then l = j end
					a[n].Name = nameclean(t[l].comment .. sezon)
					a[n].Address = t[l].file:gsub('^https://', 'http://')
					n = n + 1
			end
		end
		if #a > 1 then
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, a, 5000)
			id = id or 1
			Adr = a[id].Address
			title = title .. ' - ' .. a[id].Name
		else
			Adr = a[1].Address
		end
	 return Adr
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('2')
		 return
		end
	local flashvars = answer:match('<iframe src=".-</iframe>')
		if not flashvars then
			showError('3')
		 return
		end
	title = answer:match('<title>(.-)</title>') or 'kino-live'
	title = m_simpleTV.Common.multiByteToUTF8(title)
	title = nameclean(title)
	m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	local file = flashvars:match('file=(.-)"')
	local pl = file:match('/player/.-$')
	if pl then
		local pl = host .. pl
		local rc, answer = m_simpleTV.Http.Request(session, {url = pl})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				showError('4')
			 return
			end
		answer = answer:match('{.+}')
			if not answer then m_simpleTV.Http.Close(session) return end
		answer = answer:gsub('(%[%])', '""')
		local Adr = GetAddressFromPlaylist(answer, title)
		m_simpleTV.Control.CurrentAddress = Adr
	 return
	end
	local retAdr
	if file then
		retAdr = file
	end
		if not file and not pl then
			m_simpleTV.Http.Close(session)
			showError('5')
		 return
		end
	m_simpleTV.Http.Close(session)
	retAdr = retAdr:gsub('^https://', 'http://')
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
