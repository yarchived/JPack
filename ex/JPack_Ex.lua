-- <= == == == == == == == == == == == == =>
-- =>   JPack_Ex.lua
-- =>	  v 0.5
-- =>   JPack_Ex for Inventory&JPack
-- =>   阳一( zyleon ) 
-- =>	  zyleon@sohu.com
-- <= == == == == == == == == == == == == =>

JPack_Ex = CreateFrame("Frame", "JPack_Ex")
local L = JPack_Ex_Locale

function JPack_Ex:OnEvent()
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self:OnLoad()
	end
end

function JPack_Ex:OnLoad()
	JPack_Ex:RegisterEvent("BANKFRAME_OPENED")
	JPack_Ex:RegisterEvent("BANKFRAME_CLOSED")
	if not IsAddOnLoaded("JPack") then 
		return 
	else
		SetJPack_ExButton()
	end	
end

JPack_Ex:SetScript("OnEvent", JPack_Ex.OnEvent)
JPack_Ex:RegisterEvent("PLAYER_ENTERING_WORLD")

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
		
	if ( IsAddOnLoaded("EngBags") ) then
		EngInventory_UpdateWindow();
		EngInventory_frame:Hide();
		EngBank_UpdateWindow();
		EngBank_frame:Hide();
	elseif ( IsAddOnLoaded("ArkInventory") ) then
		ARKINV_Frame1:Hide();
		ARKINV_Frame3:Hide();
	else
	  return
	end
end


--------------------------------
-- Hook Button to Frame
--------------------------------

function SetJPack_ExButton()
	--JPackMMIconDB.hide = true
		
	if ( IsAddOnLoaded("Combuctor") ) then
	  CombuctorFrame1Search:SetPoint("TOPRIGHT",-166,-44);
	  CombuctorFrame2Search:SetPoint("TOPRIGHT",-166,-44);
	  
		local f = CreateFrame("Button", "JPack_ExButton", CombuctorFrame1, "UIPanelButtonTemplate");		
		
		f:SetWidth(45)
		f:SetHeight(25)
		f:SetPoint("TOPRIGHT", -50, -40)
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
			end
		);
		f:SetScript("OnClick", JPack_Ex.Work)
		
		local bf = CreateFrame("Button", "JPack_ExButton", CombuctorFrame2, "UIPanelButtonTemplate");
		bf:SetWidth(45)
		bf:SetHeight(25)
		bf:SetPoint("TOPRIGHT", -50, -40)
		bf:SetText(L.BUTTON_TEXT)
		bf:RegisterForClicks('anyUp')
		bf:SetScript("OnEnter", function(bf)
				GameTooltip:SetOwner(bf, "ANCHOR_RIGHT");
				GameTooltip:SetText(L.BUTTON_TOOLTIP)
				GameTooltip:Show();
			end
		);
		bf:SetScript("OnLeave", function()
				GameTooltip:Hide();
			end
		);
		bf:SetScript("OnClick", JPack_Ex.Work)
		
	elseif ( IsAddOnLoaded("MyInventory") ) then
	
		local f = CreateFrame("Button", "JPack_ExButton", MyInventoryFrame, "UIPanelButtonTemplate");
		f:SetWidth(45)
		f:SetHeight(25)
		f:SetPoint("TOPRIGHT", -15, -35)
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
			end
		);
		f:SetScript("OnClick", JPack_Ex.Work)
		
		local bf = CreateFrame("Button", "JPack_ExButton", MyBankFrame, "UIPanelButtonTemplate");
		bf:SetWidth(45)
		bf:SetHeight(25)
		bf:SetPoint("TOPRIGHT", -15, -35)
		bf:SetText(L.BUTTON_TEXT)
		bf:RegisterForClicks('anyUp')
		bf:SetScript("OnEnter", function(bf)
				GameTooltip:SetOwner(bf, "ANCHOR_RIGHT");
				GameTooltip:SetText(L.BUTTON_TOOLTIP)
				GameTooltip:Show();
			end
		);
		bf:SetScript("OnLeave", function()
				GameTooltip:Hide();
			end
		);
		bf:SetScript("OnClick", JPack_Ex.Work)
		
	elseif ( IsAddOnLoaded("BaudBag") ) then
	
		local f = CreateFrame("Button", "JPack_ExButton", BBCont1_1, "UIPanelButtonTemplate");
		f:SetWidth(45)
		f:SetHeight(20)
		f:SetPoint("TOPRIGHT", -40, 20)
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
			end
		);
		f:SetScript("OnClick", JPack_Ex.Work)
		
		local bf = CreateFrame("Button", "JPack_ExButton", BBCont2_1, "UIPanelButtonTemplate");
		bf:SetWidth(45)
		bf:SetHeight(20)
		bf:SetPoint("TOPRIGHT", -40, 20)
		bf:SetText(L.BUTTON_TEXT)
		bf:RegisterForClicks('anyUp')
		bf:SetScript("OnEnter", function(bf)
				GameTooltip:SetOwner(bf, "ANCHOR_RIGHT");
				GameTooltip:SetText(L.BUTTON_TOOLTIP)
				GameTooltip:Show();
			end
		);
		bf:SetScript("OnLeave", function()
				GameTooltip:Hide();
			end
		);
		bf:SetScript("OnClick", JPack_Ex.Work)
		
	elseif ( IsAddOnLoaded("OneBag") or IsAddOnLoaded("OneBag3")) then
	
		local f = CreateFrame("Button", "JPack_ExButton", OneBagFrame, "UIPanelButtonTemplate");
		f:SetWidth(60)
		f:SetHeight(20)
		f:SetPoint("TOPRIGHT", -105, -6)
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
			end
		);
		f:SetScript("OnClick", JPack_Ex.Work)
		
	  if ( IsAddOnLoaded("OneBank") or IsAddOnLoaded("OneBank3")) then
		
			local bf = CreateFrame("Button", "JPack_ExButton", OneBankFrame, "UIPanelButtonTemplate");
			bf:SetWidth(60)
			bf:SetHeight(20)
			bf:SetPoint("TOPRIGHT", -105, -6)
			bf:SetText(L.BUTTON_TEXT)
			bf:RegisterForClicks('anyUp')
			bf:SetScript("OnEnter", function(bf)
					GameTooltip:SetOwner(bf, "ANCHOR_RIGHT");
					GameTooltip:SetText(L.BUTTON_TOOLTIP)
					GameTooltip:Show();
				end
			);
			bf:SetScript("OnLeave", function()
					GameTooltip:Hide();
				end
			);
			bf:SetScript("OnClick", JPack_Ex.Work)
		end
	
	elseif ( IsAddOnLoaded("cargBags") ) then
	
		local f = CreateFrame("Button", "JPack_ExButton", cb_main, "UIPanelButtonTemplate");
		f:SetWidth(45)
		f:SetHeight(20)
		f:SetPoint("TOPRIGHT", -5, 20)
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
			end
		);
		f:SetScript("OnClick", JPack_Ex.Work)
		
		local bf = CreateFrame("Button", "JPack_ExButton", cb_bank, "UIPanelButtonTemplate");
		bf:SetWidth(45)
		bf:SetHeight(20)
		bf:SetPoint("TOPRIGHT", -5, 20)
		bf:SetText(L.BUTTON_TEXT)
		bf:RegisterForClicks('anyUp')
		bf:SetScript("OnEnter", function(bf)
				GameTooltip:SetOwner(bf, "ANCHOR_RIGHT");
				GameTooltip:SetText(L.BUTTON_TOOLTIP)
				GameTooltip:Show();
			end
		);
		bf:SetScript("OnLeave", function()
				GameTooltip:Hide();
			end
		);
		bf:SetScript("OnClick", JPack_Ex.Work)
		
	elseif ( IsAddOnLoaded("Baggins") ) then
	
		local f = CreateFrame("Button", "JPack_ExButton", BagginsBag1, "UIPanelButtonTemplate");
		f:SetWidth(45)
		f:SetHeight(20)
		f:SetPoint("TOPRIGHT", -30, -6)
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
			end
		);
		f:SetScript("OnClick", JPack_Ex.Work)
		
		local bf = CreateFrame("Button", "JPack_ExButton", BagginsBag12, "UIPanelButtonTemplate");
		bf:SetWidth(45)
		bf:SetHeight(20)
		bf:SetPoint("TOPRIGHT", -30, -6)
		bf:SetText(L.BUTTON_TEXT)
		bf:RegisterForClicks('anyUp')
		bf:SetScript("OnEnter", function(bf)
				GameTooltip:SetOwner(bf, "ANCHOR_RIGHT");
				GameTooltip:SetText(L.BUTTON_TOOLTIP)
				GameTooltip:Show();
			end
		);
		bf:SetScript("OnLeave", function()
				GameTooltip:Hide();
			end
		);
		bf:SetScript("OnClick", JPack_Ex.Work)
	
	elseif ( IsAddOnLoaded("ArkInventory") ) then
	
		local f = CreateFrame("Button", "JPack_ExButton", ARKINV_Frame1, "UIPanelButtonTemplate");
		f:SetWidth(45)
		f:SetHeight(20)
		f:SetPoint("TOPRIGHT", -5, 20)
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
			end
		);
		f:SetScript("OnClick", JPack_Ex.Work)
		
		local bf = CreateFrame("Button", "JPack_ExButton", ARKINV_Frame3, "UIPanelButtonTemplate");
		bf:SetWidth(45)
		bf:SetHeight(20)
		bf:SetPoint("TOPRIGHT", -35, -40)
		bf:SetText(L.BUTTON_TEXT)
		bf:RegisterForClicks('anyUp')
		bf:SetScript("OnEnter", function(bf)
				GameTooltip:SetOwner(bf, "ANCHOR_RIGHT");
				GameTooltip:SetText(L.BUTTON_TOOLTIP)
				GameTooltip:Show();
			end
		);
		bf:SetScript("OnLeave", function()
				GameTooltip:Hide();
			end
		);
		bf:SetScript("OnClick", JPack_Ex.Work)
		
	elseif ( IsAddOnLoaded("EngBags") ) then
	
		local f = CreateFrame("Button", "JPack_ExButton", EngInventory_frame, "UIPanelButtonTemplate");
		f:SetWidth(45)
		f:SetHeight(20)
		f:SetPoint("TOPRIGHT", -10, 20)
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
			end
		);
		f:SetScript("OnClick", JPack_Ex.Work)
		
		local bf = CreateFrame("Button", "JPack_ExButton", EngBank_frame, "UIPanelButtonTemplate");
		bf:SetWidth(45)
		bf:SetHeight(20)
		bf:SetPoint("TOPRIGHT", -10, 20)
		bf:SetText(L.BUTTON_TEXT)
		bf:RegisterForClicks('anyUp')
		bf:SetScript("OnEnter", function(bf)
				GameTooltip:SetOwner(bf, "ANCHOR_RIGHT");
				GameTooltip:SetText(L.BUTTON_TOOLTIP)
				GameTooltip:Show();
			end
		);
		bf:SetScript("OnLeave", function()
				GameTooltip:Hide();
			end
		);
		bf:SetScript("OnClick", JPack_Ex.Work)

	else
	
		local f = CreateFrame("Button", "JPack_ExButton", ContainerFrame1, "UIPanelButtonTemplate");
		f:SetWidth(45)
		f:SetHeight(20)
		f:SetPoint("TOPRIGHT", -10, -28)
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
			end
		);
		f:SetScript("OnClick", JPack_Ex.Work)
		
		local bf = CreateFrame("Button", "JPack_ExButton", BankFrame, "UIPanelButtonTemplate");
		bf:SetWidth(45)
		bf:SetHeight(20)
		bf:SetPoint("TOPRIGHT", -35, -40)
		bf:SetText(L.BUTTON_TEXT)
		bf:RegisterForClicks('anyUp')
		bf:SetScript("OnEnter", function(bf)
				GameTooltip:SetOwner(bf, "ANCHOR_RIGHT");
				GameTooltip:SetText(L.BUTTON_TOOLTIP)
				GameTooltip:Show();
			end
		);
		bf:SetScript("OnLeave", function()
				GameTooltip:Hide();
			end
		);
		bf:SetScript("OnClick", JPack_Ex.Work)
				
	end
	
end


