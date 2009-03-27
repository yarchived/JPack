Bagnon_Ex = {}
Bagnon_Ex.Player = UnitName("player")

Bagnon_Ex.ClearBag = "整理背包"		--文字
Bagnon_Ex.Width = 80			--宽度
Bagnon_Ex.Asc = true			--true:左键正序,右键逆序 false:右键逆序,右键正序


function Bagnon_Ex:CreateJPackButton(frame)
	local button = CreateFrame("Button", nil, frame)
	button:SetNormalFontObject('GameFontNormalLeft')
	button:SetHighlightFontObject('GameFontHighlightLeft')
	button:RegisterForClicks("anyUp")
	button:SetWidth(self.Width); button:SetHeight(26)
	button:SetText(self.ClearBag)
	button:SetScript("OnClick", JPack_Ex.Work)

	return button
end
