if not IsAddOnLoaded("Bagnon") then 
	return 
end

-- show bags
local showBags = function(self, show, updateParent)
	self:GetParent().sets.showBags = show
end
hooksecurefunc(BagnonBagFrame, "ShowBags", showBags)

-- sort

function BagnonFrame:LayoutItems(cols, space, offX, offY)
	if not next(self.items) then 
		return 0, 0 
	end

	local itemSize = BagnonItem.SIZE + space
	local slots = self.slots
	local player = self:GetPlayer()

	local i = 0
	local start, finish, step 
	for _,bag in ipairs(self:GetVisibleBags()) do
		if self.sets.reverseSort then
			start, finish, step = (self.bagSizes[bag] or 0), 1, -1
		else
			start, finish, step = 1, (self.bagSizes[bag] or 0), 1
		end
		for slot = start, finish, step do
			local item = self.items[(bag<0 and bag*100 - slot) or (bag*100 + slot)]
			if item then
				i = i + 1
				local row = mod(i - 1, cols)
				local col = ceil(i / cols) - 1
				item:SetPoint('TOPLEFT', self, 'TOPLEFT', itemSize * row + offX, -(itemSize * col + offY))
				item:Show()
			end
		end
	end

	return itemSize * min(cols, i) - space, itemSize * ceil(i / cols) - space
end

local width = - ( Bagnon_Ex.Width + 24 )

local SetPlayer = function(frame, player)
	if player ~= Bagnon_Ex.Player then
		frame.JPack:Hide()
		frame.title:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -24, -16 - frame.borderSize/2)
	else
		frame.JPack:Show()
		frame.title:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", width, -16 - frame.borderSize/2)
	end
end

BagnonFrame._Create = BagnonFrame.Create
function BagnonFrame:Create(name, sets, bags, isBank)
	local frame = self:_Create(name, sets, bags, isBank)
	if not isBank then
		local button = Bagnon_Ex:CreateJPackButton(frame)
		button:SetPoint("Right", name .. "Close", "LEFT", 5, 0)

		frame.JPack = button
		frame.title:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", width, -16 - frame.borderSize/2)

		hooksecurefunc(frame, "SetPlayer", SetPlayer)
	end
	return frame
end

