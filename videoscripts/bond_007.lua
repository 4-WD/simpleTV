-- видеоскрипт "Бонд 007" [псевдо тв] https://wink.rt.ru (6/9/20)
-- Copyright © 2017-2020 Nexterr
-- необходим скрапер TVS: psevdotv_pls
-- необходимы скрипты: wink-vod
-- открывает ссылку:
-- bond_007
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^[$]*bond_007') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
		if m_simpleTV.Control.ChannelID == 268435455 then
			m_simpleTV.Control.ChangeChannelLogo('https://raw.githubusercontent.com/Nexterr/simpleTV.img/master/bond_007.png', m_simpleTV.Control.ChannelID)
		end
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'bond 007 ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then
			showError('0')
		 return
		end
	local pls = decode64('aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL05leHRlcnIvc2ltcGxlVFYucGxheWxpc3RzL21hc3Rlci8wMDcudHh0')
	local rc, answer = m_simpleTV.Http.Request(session, {url = pls})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('1')
		 return
		end
	answer = answer .. '\n'
	local tab, i = {}, 1
	local title, adr
		for w in answer:gmatch('#EXTINF:(.-\n.-)%c') do
			title = w:match(',(.-)\n')
			adr = w:match('\n(.+)')
			if adr and title then
				tab[i] = {}
				tab[i].Id = i
				tab[i].Address = string.format('%s?&isPlst=true&fromScr=true', adr)
				tab[i].Name = title
				i = i + 1
			end
		end
		if i == 1 then
			showError('2')
		 return
		end
	tab.ExtParams = {}
	tab.ExtParams.Random = 1
	tab.ExtParams.PlayMode = 1
	tab.ExtParams.StopOnError = 0
	local plstIndex = math.random(#tab)
	m_simpleTV.OSD.ShowSelect_UTF8('Бонд 007 🔫🎞️', plstIndex - 1, tab, 0, 64 + 256)
	m_simpleTV.Control.ChangeAddress = 'No'
	m_simpleTV.Control.CurrentAddress = tab[plstIndex].Address
	dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
-- debug_in_file(tab[plstIndex].Address .. '\n')