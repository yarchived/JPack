if not IsAddOnLoaded("Bagnon_Forever") then return end

local SaveEquipment = function(self)
	self.pdb.e = "19,0"
end
hooksecurefunc(BagnonDB, "SaveEquipment", SaveEquipment)