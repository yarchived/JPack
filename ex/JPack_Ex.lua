--[[
	JPack_Ex for Inventory&JPack
	zyleon@sohu.com
]]

local loc, L = GetLocale(), {
	["Click"] = "Click",
	["Pack"] = "Pack",
	
	["Shift + Left-Click"] = "Shift + Right-Click",
	["Save to the bank"] = "Save to the bank",
	["Ctrl + Left-Click"] = "Ctrl + Right-Click",
	["Load from the bank"] = "Load from the bank",
	["Shift + Right-Click"] = "Shift + Left-Click",
	["Set sequence to asc"] = "Set sequence to asc",
	["Ctrl + Right-Click"] = "Ctrl + Left-Click",
	["Set sequence to desc"] = "Set sequence to desc",
}

if loc == "zhCN" then
	L["Click"] = "点击"
	L["Pack"] = "整理"
	
	L["Shift + Left-Click"] = "Shift + 左键"
	L["Save to the bank"] = "保存到银行"
	L["Ctrl + Left-Click"] = "Ctrl + 左键"
	L["Load from the bank"] = "从银行取出"
	L["Shift + Right-Click"] = "Shift + 右键"
	L["Set sequence to asc"] = "正序整理"
	L["Ctrl + Right-Click"] = "Ctrl + 右键"
	L["Set sequence to desc"] = "逆序整理"
elseif loc == "zhTW" then
	L["Click"] = "點擊"
	L["Pack"] = "整理"
	
	L["Shift + Left-Click"] = "Shift + 左鍵"
	L["Save to the bank"] = "保存到銀行"
	L["Ctrl + Left-Click"] = "Ctrl + 左鍵"
	L["Load from the bank"] = "從銀行取出"
	L["Shift + Right-Click"] = "Shift + 右鍵"
	L["Set sequence to asc"] = "正序整理"
	L["Ctrl + Right-Click"] = "Ctrl + 右鍵"
	L["Set sequence to desc"] = "逆序整理"
elseif loc == "koKR" then
	L['Click'] = '클릭'
	L['Pack'] = '정리'

	L['Shift + Right-Click'] = 'SHIFT + 오른쪽-클릭'
	L['Save to the bank'] = '은행에 넣기'
	L['Ctrl + Right-Click'] = 'CTRL + 오른쪽-클릭'
	L['Load from the bank'] = '은행에서 꺼내기'
	L['Shift + Left-Click'] = 'SHIFT + 왼쪽-클릭'
	L['Set sequence to asc'] = '오름차순으로 설정'
	L['Ctrl + Left-Click'] = 'CTRL + 왼쪽-클릭'
	L['Set sequence to desc'] = '내림차순으로 설정'
	
	L['HELP'] = '도움말을 보려면 "/jpack help"를 입력하세요.'
elseif loc == "deDE" then
	L["Click"] = "Linksklick"
	L["Pack"] = "Packen"

	L["Shift + Right-Click"] = "SHIFT + Rechtsklick"
	L["Save to the bank"] = "Sichere zur Bank"
	L["Ctrl + Right-Click"] = "CTRL + Rechtsklick"
	L["Load from the bank"] = "Lade von der Bank"
	L["Shift + Left-Click"] = "SHIFT + Linksklick"
	L["Set sequence to asc"] = "Setze aufsteigende Reihenfolge"
	L["Ctrl + Left-Click"] = "CTRL + Linksklick"
	L["Set sequence to desc"] = "Setze absteigende Reihenfolge"
end

JPack_Ex = CreateFrame("Frame")

function JPack_Ex:PLAYER_LOGIN()
	JPack_Ex:BuildButtons()
	JPack_Ex:UnregisterEvent("PLAYER_LOGIN")
	JPack_Ex.PLAYER_LOGIN = nil
end

JPack_Ex:SetScript("OnEvent", function(self, event, ...) self[event](...) end)
if IsLoggedIn() then JPack_Ex:PLAYER_LOGIN() else JPack_Ex:RegisterEvent("PLAYER_LOGIN") end


function JPack_Ex:Work(button)
	local access, order
	if ( button == "LeftButton" ) then
		if IsShiftKeyDown() then
			access = 1
		elseif IsControlKeyDown() then
			access = 2
		end
	elseif ( button == "RightButton" ) then
		if IsShiftKeyDown() then
			order = 1
		elseif IsControlKeyDown() then
			order = 2
		end
	end
	JPack:Pack(access, order)
end

function JPack_Ex:Build(parent, width, height, point1, point2, point3)
	local f = CreateFrame("Button", "JPack_ExButton", parent, "UIPanelButtonTemplate");		
	
	f:SetWidth(width)
	f:SetHeight(height)
	f:SetPoint(point1, point2, point3)
	f:SetText(L["Pack"])
	f:RegisterForClicks("anyUp")
	f:SetScript("OnClick", JPack_Ex.Work)
	
	if JPACK_EX_NOTOOLTIP then return f end
	
	f:SetScript("OnEnter", function(f)
		GameTooltip:SetOwner(f, "ANCHOR_RIGHT");
		GameTooltip:AddDoubleLine(L["Click"], L["Pack"], 0, 1, 0, 0, 1, 0)
		GameTooltip:AddDoubleLine(L["Shift + Left-Click"], L["Save to the bank"], 0, 1, 0, 0, 1, 0)
		GameTooltip:AddDoubleLine(L["Ctrl + Left-Click"], L["Load from the bank"], 0, 1, 0, 0, 1, 0)
		GameTooltip:AddDoubleLine(L["Shift + Right-Click"], L["Set sequence to asc"], 0, 1, 0, 0, 1, 0)
		GameTooltip:AddDoubleLine(L["Ctrl + Right-Click"], L["Set sequence to desc"], 0, 1, 0, 0, 1, 0)
		GameTooltip:Show();
		end
	);
	
	f:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);
	
	return f
end

function JPack_Ex:BuildButtons()
	if IsAddOnLoaded("Combuctor") then
		CombuctorFrame1Search:SetPoint("TOPRIGHT",-166,-44)
		CombuctorFrame2Search:SetPoint("TOPRIGHT",-166,-44)
		
		JPack_Ex:Build(CombuctorFrame1, 45, 25, "TOPRIGHT", -50, -40)
		JPack_Ex:Build(CombuctorFrame2, 45, 20, "TOPRIGHT", -50, -40)
		
	elseif IsAddOnLoaded("MyInventory") then
		JPack_Ex:Build(MyInventoryFrame, 45, 20, "TOPRIGHT", -15, -35)
		JPack_Ex:Build(MyBankFrame, 45, 20, "TOPRIGHT", -15, -35)
		
	elseif IsAddOnLoaded("BaudBag") then
		JPack_Ex:Build(BBCont1_1, 45, 20, "TOPRIGHT", -40, 20)
		JPack_Ex:Build(BBCont2_1, 45, 20, "TOPRIGHT", -40, 20)
		
	elseif IsAddOnLoaded("OneBag") or IsAddOnLoaded("OneBag3") then
		JPack_Ex:Build(OneBagFrame, 60, 20, "TOPRIGHT", -105, -6)
		
		if IsAddOnLoaded("OneBank") or IsAddOnLoaded("OneBank3") then
			JPack_Ex:Build(OneBankFrame, 60, 20, "TOPRIGHT", -105, -6)
		end
	elseif IsAddOnLoaded("cargBags") then
		JPack_Ex:Build(cb_main, 45, 20, "TOPRIGHT", -5, 20)
		JPack_Ex:Build(cb_bank, 45, 20, "TOPRIGHT", -5, 20)
		
	elseif IsAddOnLoaded("Baggins") then
		JPack_Ex:Build(BagginsBag1, 45, 20, "TOPRIGHT", -30, -6)
		JPack_Ex:Build(BagginsBag12, 45, 20, "TOPRIGHT", -30, -6)
		
	elseif IsAddOnLoaded("Bagnon") then
		local id = 0
		hooksecurefunc(BagnonFrame, "Create", function()
			local framename = format("BagnonFrame%d", id)
			id = id + 1
			local f = getglobal(framename)
			if f then
				local b = JPack_Ex:Build(f, 45, 20, "TOPRIGHT", -30, -7)
				b:SetFrameStrata("FULLSCREEN")
			end
		end)
	else -- blizzy bag
		JPack_Ex:Build(ContainerFrame1, 45, 20, "TOPRIGHT", -10, -28)
		JPack_Ex:Build(BankFrame, 45, 20, "TOPRIGHT", -35, -40)
	end
end


