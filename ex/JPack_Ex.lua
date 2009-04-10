--[[
	JPack_Ex for Inventory&JPack
	zyleon@sohu.com
]]

JPack_Ex = CreateFrame("Frame")
local L = JPack_Ex_Locale

function JPack_Ex:PLAYER_LOGIN()
	JPack_Ex:BuildButtons()
	JPack_Ex:UnregisterEvent("PLAYER_LOGIN")
	JPack_Ex.PLAYER_LOGIN = nil
end

--[[function JPack_Ex:OnLoad()
	JPack_Ex:RegisterEvent("BANKFRAME_OPENED")
	JPack_Ex:RegisterEvent("BANKFRAME_CLOSED")
	if not IsAddOnLoaded("JPack") then 
		return 
	else
		SetJPack_ExButton()
	end	
end]]

JPack_Ex:SetScript("OnEvent", function(self, event, ...)
	if self[event]
		then self[event](self, event, ...)
	else
		self:UnregisterEvent(event)
	end
end)
JPack_Ex:RegisterEvent("PLAYER_LOGIN")

local function JPack_Ex_CmdToParam(cmd)
	if(cmd == "desc")then
		return 2
	elseif(cmd == "asc")then
		return 1
	elseif(cmd == "save" or cmd == "deposit")then
		return 4
	elseif(cmd == "load" or cmd == "draw")then
		return 8
	else
		return 0
	end
end

JPACK_LEFT_CLICK  = JPack_Ex_CmdToParam(JPACK_LEFT_CLICK)
JPACK_RIGHT_CLICK = JPack_Ex_CmdToParam(JPACK_RIGHT_CLICK)
JPACK_ALT_DOWN    = JPack_Ex_CmdToParam(JPACK_ALT_DOWN)
JPACK_SHIFT_DOWN  = JPack_Ex_CmdToParam(JPACK_SHIFT_DOWN)
JPACK_CTRL_DOWN   = JPack_Ex_CmdToParam(JPACK_CTRL_DOWN)

function JPack_Ex:Work(button)
	local param = 0
	if button == "LeftButton" then
		param = bit.bor(param , JPACK_LEFT_CLICK)
	elseif button == "RightButton" then
		param = bit.bor(param , JPACK_RIGHT_CLICK)
	end
	if IsAltKeyDown() then
		param = bit.bor(param , JPACK_ALT_DOWN)
	elseif IsControlKeyDown() then
		param = bit.bor(param , JPACK_CTRL_DOWN)
	elseif IsShiftKeyDown() then
		param = bit.bor(param , JPACK_SHIFT_DOWN)	
	end
	
	JPack:Pack(bit.rshift(param,2), bit.band(param, 3))
end

--------------------------------
-- 
--------------------------------
function JPack_Ex:Build(parent, width, height, point1, point2, point3)
	local f = CreateFrame("Button", "JPack_ExButton", parent, "UIPanelButtonTemplate");		
	
	f:SetWidth(width)
	f:SetHeight(height)
	f:SetPoint(point1, point2, point3)
	f:SetText(L.BUTTON_TEXT)
	f:RegisterForClicks('anyUp')
	f:SetScript("OnEnter", function(f)
			GameTooltip:SetOwner(f, "ANCHOR_RIGHT");
			GameTooltip:SetText(L.BUTTON_TOOLTIP)
			GameTooltip:Show();
		end
	);
	f:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);
	f:SetScript("OnClick", JPack_Ex.Work)

	return f
end

--------------------------------
-- Build Buttons
--------------------------------

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
			local framename = format('BagnonFrame%d', id)
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


