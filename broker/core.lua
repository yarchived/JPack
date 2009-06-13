local loc, L = GetLocale(), {
	['Sequence'] = 'Sequence',
	['asc'] = 'asc',
	['desc'] = 'desc',
	
	['Click'] = 'Click',
	['Pack'] = 'Pack',
	
	['Alt + Left-Click'] = 'Alt + Left-Click',
	['Packup guildbank'] = 'Packup guildbank',
	['Shift + Left-Click'] = 'Shift + Right-Click',
	['Save to the bank'] = 'Save to the bank',
	['Ctrl + Left-Click'] = 'Ctrl + Right-Click',
	['Load from the bank'] = 'Load from the bank',
	['Shift + Right-Click'] = 'Shift + Left-Click',
	['Set sequence to ascend'] = 'Set sequence to ascend',
	['Ctrl + Right-Click'] = 'Ctrl + Left-Click',
	['Set sequence to descend'] = 'Set sequence to descend',
	
	['HELP'] = 'Type "/jpack help" for help.',
}

if loc == 'zhCN' then
	L['Sequence'] = '整理顺序'
	L['asc'] = '正序'
	L['desc'] = '逆序'
	
	L['Click'] = '点击'
	L['Pack'] = '整理'
	
	L['Alt + Left-Click'] = 'Alt + 左键'
	L['Packup guildbank'] = '整理公会银行'
	L['Shift + Left-Click'] = 'Shift + 左键'
	L['Save to the bank'] = '保存到银行'
	L['Ctrl + Left-Click'] = 'Ctrl + 左键'
	L['Load from the bank'] = '从银行取出'
	L['Shift + Right-Click'] = 'Shift + 右键'
	L['Set sequence to ascend'] = '正序整理'
	L['Ctrl + Right-Click'] = 'Ctrl + 右键'
	L['Set sequence to descend'] = '逆序整理'
	
	L['HELP'] = '输入"/jpack help"获取帮助.'
elseif loc == 'zhTW' then
	L['Sequence'] = '整理順序'
	L['asc'] = '正序'
	L['desc'] = '逆序'
	
	L['Click'] = '點擊'
	L['Pack'] = '整理'
	
	L['Alt + Left-Click'] = 'Alt + 左鍵'
	L['Packup guildbank'] = '整理公會銀行'
	L['Shift + Left-Click'] = 'Shift + 左鍵'
	L['Save to the bank'] = '保存到銀行'
	L['Ctrl + Left-Click'] = 'Ctrl + 左鍵'
	L['Load from the bank'] = '從銀行取出'
	L['Shift + Right-Click'] = 'Shift + 右鍵'
	L['Set sequence to ascend'] = '正序整理'
	L['Ctrl + Right-Click'] = 'Ctrl + 右鍵'
	L['Set sequence to descend'] = '逆序整理'
	
	L['HELP'] = '輸入"/jpack help"獲取幫助.'
elseif loc == 'koKR' then
	L['Sequence'] = '순서'
	L['asc'] = '오름차순'
	L['desc'] = '내림차순'
	
	L['Click'] = '클릭'
	L['Pack'] = '정리'

	L['Shift + Right-Click'] = 'SHIFT + 오른쪽-클릭'
	L['Save to the bank'] = '은행에 넣기'
	L['Ctrl + Right-Click'] = 'CTRL + 오른쪽-클릭'
	L['Load from the bank'] = '은행에서 꺼내기'
	L['Shift + Left-Click'] = 'SHIFT + 왼쪽-클릭'
	L['Set sequence to ascend'] = '오름차순으로 설정'
	L['Ctrl + Left-Click'] = 'CTRL + 왼쪽-클릭'
	L['Set sequence to descend'] = '내림차순으로 설정'
	
	L['HELP'] = '도움말을 보려면 "/jpack help"를 입력하세요.'
elseif loc == 'deDE' then
	L['Sequence'] = 'Reihenfolge'
	L['asc'] = 'Aufsteigend'
	L['desc'] = 'Absteigend'
	
	L['Click'] = 'Linksklick'
	L['Pack'] = 'Packen'

	L['Shift + Right-Click'] = 'SHIFT + Rechtsklick'
	L['Save to the bank'] = 'Sichere zur Bank'
	L['Ctrl + Right-Click'] = 'CTRL + Rechtsklick'
	L['Load from the bank'] = 'Lade von der Bank'
	L['Shift + Left-Click'] = 'SHIFT + Linksklick'
	L['Set sequence to ascend'] = 'Setze aufsteigende Reihenfolge'
	L['Ctrl + Left-Click'] = 'CTRL + Linksklick'
	L['Set sequence to descend'] = 'Setze absteigende Reihenfolge'
	
	L['HELP'] = 'Tippe "/jpack help" für Hilfe'
end

local dataobj = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject('JPack', {
	type = 'launcher',
	label = 'JPack',
	icon = 'Interface\\Icons\\INV_Misc_Bag_10_Green',
})

dataobj.OnTooltipShow = function(tooltip)
	if not tooltip or not tooltip.AddLine then return end
	
	tooltip:AddLine('|cff32cd32JPack|r')
	tooltip:AddDoubleLine(L['Sequence'], JPackDB.asc and L['asc'] or L['desc'], 1, 1, 0, 1, 1, 1)
	
	tooltip:AddLine(' ')
	tooltip:AddDoubleLine(L['Click'], L['Pack'], 0, 1, 0, 0, 1, 0)
	if JPack.DEV_MOD then tooltip:AddDoubleLine(L['Alt + Left-Click'], L['Packup guildbank'], 0, 1, 0, 0, 1, 0) end
	tooltip:AddDoubleLine(L['Shift + Left-Click'], L['Save to the bank'], 0, 1, 0, 0, 1, 0)
	tooltip:AddDoubleLine(L['Ctrl + Left-Click'], L['Load from the bank'], 0, 1, 0, 0, 1, 0)
	tooltip:AddDoubleLine(L['Shift + Right-Click'], L['Set sequence to ascend'], 0, 1, 0, 0, 1, 0)
	tooltip:AddDoubleLine(L['Ctrl + Right-Click'], L['Set sequence to descend'], 0, 1, 0, 0, 1, 0)

	tooltip:AddLine(' ')
	tooltip:AddLine(L['HELP'], 0, 1, 0)
end

dataobj.OnClick = function(_, button)
	local access, order
	if ( button == 'LeftButton' ) then
		if IsShiftKeyDown() then
			access = 1
		elseif IsControlKeyDown() then
			access = 2
		elseif IsAltKeyDown() then
			access = 3
		end
	elseif ( button == 'RightButton' ) then
		if IsShiftKeyDown() then
			order = 1
		elseif IsControlKeyDown() then
			order = 2
		end
	end
	JPack:Pack(access, order)
end
