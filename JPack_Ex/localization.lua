if ( GetLocale() == "zhCN") then
	BUTTON_TEXT = "整理"
	BUTTON_TOOLTIP = "|cFF00FF00左键点击|r正序整理\n\n|cFF00FF00右键点击|r逆序整理";
elseif ( GetLocale() == "zhTW") then
	BUTTON_TEXT = "整理"
	BUTTON_TOOLTIP = "|cFF00FF00左鍵點擊|r正序整理\n\n|cFF00FF00右鍵點擊|r逆序整理";
else
	BUTTON_TEXT = "Pack"
	BUTTON_TOOLTIP = "|cFF00FF00Left-Click|rPack to asc\n\n|cFF00FF00Right-Click|rPack to desc";
end