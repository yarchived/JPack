--[[
	JPack_Ex: A button on you bag frame!
	orig by zyleon@sohu.com
	yaroot#gmail _dot_ com
]]

local loc, L = GetLocale(), {
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
}

if loc == 'zhCN' then
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
elseif loc == 'zhTW' then
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
elseif loc == 'koKR' then
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
elseif loc == 'deDE' then
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
end


local function OnClick(self, button)
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


local function OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip:AddDoubleLine(L['Click'], L['Pack'], 0, 1, 0, 0, 1, 0)
	if JPack.DEV_MOD then GameTooltip:AddDoubleLine(L['Alt + Left-Click'], L['Packup guildbank'], 0, 1, 0, 0, 1, 0) end
	GameTooltip:AddDoubleLine(L['Shift + Left-Click'], L['Save to the bank'], 0, 1, 0, 0, 1, 0)
	GameTooltip:AddDoubleLine(L['Ctrl + Left-Click'], L['Load from the bank'], 0, 1, 0, 0, 1, 0)
	GameTooltip:AddDoubleLine(L['Shift + Right-Click'], L['Set sequence to ascend'], 0, 1, 0, 0, 1, 0)
	GameTooltip:AddDoubleLine(L['Ctrl + Right-Click'], L['Set sequence to descend'], 0, 1, 0, 0, 1, 0)
	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

function BuildButton(parent, width, height, point1, point2, point3)
	local f = CreateFrame('Button', nil, parent, 'UIPanelButtonTemplate')		
	
	f:SetWidth(width)
	f:SetHeight(height)
	f:SetPoint(point1, point2, point3)
	f:SetText(L['Pack'])
	f:SetScript('OnMouseUP', OnClick)
	
	f:SetScript('OnEnter', OnEnter)
	f:SetScript('OnLeave', OnLeave)
	
	return f
end

local function ADDON_LOADED(self,event,addon)
	if addon ~= 'Blizzard_GuildBankUI' then return end
	BuildButton(GuildBankFrame, 45, 20, 'TOPRIGHT', -25, -15)
	self:UnregisterEvent('ADDON_LOADED', ADDON_LOADED)
end

local function onLoad()
	JPack:UnregisterEvent('PLAYER_LOGIN', onLoad)
	if IsAddOnLoaded('ArkInventory') then
		local i = 1
		while i do
			local arkframe = _G['ARKINV_Frame'..i]
			if not arkframe then break end
			BuildButton(arkframe, 50, 25, 'TOPRIGHT', -135, -15)
			i = i + 1
		end
		return
		
	elseif IsAddOnLoaded('Baggins') then
		BuildButton(BagginsBag1, 45, 20, 'TOPRIGHT', -30, -6)
		BuildButton(BagginsBag12, 45, 20, 'TOPRIGHT', -30, -6)
		
	elseif IsAddOnLoaded('Bagnon') then
		if BagnonFrame then
			local id = 0
			hooksecurefunc(BagnonFrame, 'Create', function()
				local framename = format('BagnonFrame%d', id)
				id = id + 1
				local f = getglobal(framename)
				if not f then return end
				BuildButton(f, 45, 20, 'TOPRIGHT', -30, -7):SetFrameStrata('FULLSCREEN')
			end)
		else
			local id = 1
			hooksecurefunc(Bagnon.Frame, 'New', function(self, name)
				local f = getglobal('BagnonFrame'..id)
				if not f then return end
				BuildButton(f, 45, 20, 'TOPRIGHT', -50, -8):SetFrameStrata('FULLSCREEN')
				id = id + 1
			end)
		end
	elseif IsAddOnLoaded('BaudBag') then
		BuildButton(BBCont1_1, 45, 20, 'TOPRIGHT', -40, 20)
		BuildButton(BBCont2_1, 45, 20, 'TOPRIGHT', -40, 20)
		
	elseif IsAddOnLoaded('Combuctor') then
		CombuctorFrame1Search:SetPoint('TOPRIGHT',-166,-44)
		CombuctorFrame2Search:SetPoint('TOPRIGHT',-166,-44)
		BuildButton(CombuctorFrame1, 45, 25, 'TOPRIGHT', -50, -40)
		BuildButton(CombuctorFrame2, 45, 20, 'TOPRIGHT', -50, -40)
		
	elseif IsAddOnLoaded('MyInventory') then
		BuildButton(MyInventoryFrame, 45, 20, 'TOPRIGHT', -15, -35)
		BuildButton(MyBankFrame, 45, 20, 'TOPRIGHT', -15, -35)
		
	elseif IsAddOnLoaded('OneBag') or IsAddOnLoaded('OneBag3') then
		BuildButton(OneBagFrame, 60, 20, 'TOPRIGHT', -105, -6)
		if IsAddOnLoaded('OneBank') or IsAddOnLoaded('OneBank3') then
			BuildButton(OneBankFrame, 60, 20, 'TOPRIGHT', -105, -6)
		end
		
	else -- blizzy bag
		BuildButton(ContainerFrame1, 45, 20, 'TOPRIGHT', -10, -28)
		BuildButton(BankFrame, 45, 20, 'TOPRIGHT', -50, -15)
	end
	
	if JPack.DEV_MOD then JPack:RegisterEvent('ADDON_LOADED', ADDON_LOADED) end
end

JPack:RegisterEvent('PLAYER_LOGIN', onLoad)
