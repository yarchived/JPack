-- dev modify

local NOGUILDBANK = true
local debug = function() end

--@debug@
local debugf = tekDebug and tekDebug:GetFrame("JPack")--tekDebug
if debugf then
	debug = function(...) debugf:AddMessage(string.join(", ", ...)) end
end
NOGUILDBANK = false
--@end-debug@


--[[===================================
			Local
=====================================]]
JPack = CreateFrame"Frame"

JPack.bankOpened=false
JPack.guildbankOpened=false
JPack.deposit=false
JPack.draw=false
JPack.bagGroups={}
JPack.packingGroupIndex=1
JPack.packingBags={}

local version = GetAddOnMetadata("JPack", "Version")
local L = JPackLocale

--local interval=0.1
local bagSize=0
local packingBags={}
local JPACK_MAXMOVE_ONCE=3
local current,to,lockedSlots,currentGBTab

-- 整理状态
local JPACK_STEP=0
local JPACK_STARTED=1
local JPACK_DEPOSITING=2
local JPACK_DRAWING=3	--
local JPACK_STACKING=4	--
local JPACK_STACK_OVER=5
local JPACK_SORTING=6	--
local JPACK_PACKING=7
local JPACK_START_PACK=8
local JPACK_GUILDBANK_STACKING=9
local JPACK_GUILDBANK_SORTING=10
local JPACK_GUILDBANK_COMPLETE=11
local JPACK_SPEC_BAG_OVER=12
local JPACK_SPEC_BANK_OVER=13
local JPACK_STOPPED=0


--[[===================================
			lib
=====================================]]

--[[if table.getn == nil then
	local fun, err = loadstring("return function(tb) return #tb end")
	table.getn = fun()
end]]

--[[if not table.getn then
	table.getn = function(tb) return #tb end
end]]

local function print(msg,r,g,b)
	DEFAULT_CHAT_FRAME:AddMessage('JPack: '..msg, r or .41, g or .8, b or .94)
end

local function IndexOfTable(t,v)
	for i=1,table.getn(t) do
		if(v==t[i])then
			return i
		end
	end
	return 0
end

--[[
获得一个 JPack 格式的物品对象
isGB - 是否为工会银行
]]
local function getJPackItem(bag,slot,isGB)
	local link = isGB and GetGuildBankItemLink(bag,slot) or GetContainerItemLink(bag,slot) 
	if not link then return nil end
	local item={}
	item.slotId=c
	item.name, item.link, item.rarity, 
	item.level, item.minLevel, item.type, item.subType, item.stackCount,
	item.equipLoc, item.texture = GetItemInfo(link)
	item.itemid = tonumber(link:match("item:(%d+):"))
	return item
end

--是否能放入某背包
local function CanGoInBag(frombag,fromslot, tobag)
   local item = GetContainerItemLink(frombag,fromslot)
   -- Get the item's family
   local itemFamily = GetItemFamily(item)
   
   -- If the item is a container, then the itemFamily should be 0
   --[[
   local equipSlot = select(9, GetItemInfo(item))
   if equipSlot == "INVTYPE_BAG" then
      itemFamily = 0
   end
]]--
   -- Get the bag's family
   local bagFamily = select(2, GetContainerNumFreeSlots(bag))

   return bagFamily == 0 or bit.band(itemFamily, bagFamily) > 0
end

--背包是否准备好了（无锁定物品）
local function isBagReady(bag)
	for i=1,GetContainerNumSlots(bag) do
		local _, _, locked = GetContainerItemInfo(bag,i)
		if(locked)then return false end
	end
	return true
end

-- 公会银行是否准备好 (无锁定物品)
local function isGBReady(tab)
	for i = 1, 98 do -- 每页98个格子
		local _,_,locked = GetGuildBankItemInfo(tab or currentGBTab, i)
		if locked then return false end
	end
	return true
end

--是否所有背包准备好了
local function isAllBagReady()
	for i=1,table.getn(JPack.bagGroups) do
		for j=1,table.getn(JPack.bagGroups[i]) do
			if(not isBagReady(JPack.bagGroups[i][j])) then return false end
		end
	end
	return true
end

--[[
return 1xxx 非垃圾 ，0xxx for 垃圾，xxx为（999-JPACK_ORDER中所定的位置）
]]
local function getPerffix(item)
	if(item==nil)then return nil end
	
	--按名称获取顺序
	local i=IndexOfTable(JPACK_ORDER,item.name)
	if(i<=0)then
		--按子类别获取顺序
		i=IndexOfTable(JPACK_ORDER,"#"..item.type.."##"..item.subType)
	else
		--名称匹配直接返回
		return '1'..string.format("%3d",999-i)
	end
	if(i<=0)then
		--按子类别获取顺序
		i=IndexOfTable(JPACK_ORDER,"##"..item.subType)
	end
	if(i<=0)then
		--按类别获取顺序
		i=IndexOfTable(JPACK_ORDER,"#"..item.type)
	end
	if(i<=0)then
		--默认类别顺序
		i=IndexOfTable(JPACK_ORDER,"#")
	end
	if(i<=0)then
		--默认顺序
		i=999
	end
	local s=string.format("%3d",999-i)
	--灰色物品、可装备的非优秀物品
	if(item.rarity==0)then
		return "00"..s
	elseif(IsEquippableItem(item.name) and item.type~=L.TYPE_BAG and item.subType~=L.TYPE_FISHWEAPON) and item.subType~=L.TYPE_MISC then 
		if(item.rarity <= 1 ) then
			return '01'..s
		end
	end
	return "1"..s
	
end

--[[
bagIds = {1,3,5}
packIndex ---JPack的index
bagID --- wow 的bagId
slotId ---- wow 的slotId
]]

--[[
bag  背包
slot  位置
return 是否需要保存到银行
]]
local function shouldSaveToBank(bag,slot)
	local item=getJPackItem(bag,slot)
	return item~=nil and ((IndexOfTable(JPACK_DEPOSIT,"#"..item.type.."##"..item.subType)>0) or (IndexOfTable(JPACK_DEPOSIT,"#"..item.type)>0) or (IndexOfTable(JPACK_DEPOSIT,"##"..item.subType)>0) or (IndexOfTable(JPACK_DEPOSIT,item.name)>0))
end

--[[
bag  背包
slot  位置
return 是否需要从银行取出
]]
local function shouldLoadFromBank(bag,slot)
	local item=getJPackItem(bag,slot)
	return item~=nil and ((IndexOfTable(JPACK_DRAW,"#"..item.type.."##"..item.subType)>0) or (IndexOfTable(JPACK_DRAW,"#"..item.type)>0) or (IndexOfTable(JPACK_DRAW,"##"..item.subType)>0) or (IndexOfTable(JPACK_DRAW,item.name)>0))
end

--[[
bags  一组背包
bag    当前背包在bags中位置
slot   当前背包slot
return  前一个背包位置的  bag,slot
]]--
local function getPrevSlot(bags,bag,slot)
	if(slot>1)then
		slot=slot-1
	elseif(bag>1)then
		bag=bag-1
		slot=GetContainerNumSlots(bags[bag])
	else
		bag=-1
	end
	return bag,slot
end

--[[
比较用的字符串,与排序直接相关的函数
]]
local function getCompareStr(item)
	if(not item)then
		return nil
	elseif(not item.compareStr)then
		local _,_,textureType,textureIndex=string.find(item.texture,"\\.*\\([^_]+_?[^_]*_?[^_]*)_?(%d*)")
		if(not item.rarity)then item.rarity='1' end
		item.compareStr= getPerffix(item).." "..item.rarity..item.type.." "..item.subType.." "..textureType.." "
			..string.format("%2d",item.minLevel).." "..string.format("%2d",item.level).." "..(textureIndex or "00")..item.name
	end
	return item.compareStr
end

--[[
比较两个物品
return 1 a 在前
return -1 b 在前
]]
local function compare(a, b)
	local ret=0
	if(a==b)then
		ret= 0
	elseif(a==nil)then
		ret= -1
	elseif(b==nil)then
		ret= 1
	elseif(a.name==b.name)then
		ret= 0
	else
		local sa = getCompareStr(a)
		local sb = getCompareStr(b)
		if(sa>sb)then
			ret= 1
		elseif(sa<sb) then
			ret= -1
		end
	end
	return ret
end

local function swap(items,i,j)
	local y=items[i]
	items[i]=items[j]
	items[j]=y
end

local function qsort(items,from,to)

	local i,j=from,to
	local ix=items[i]
	local x=i
	while(i<j) do
		while(j>x) do
			if(compare(items[j], ix)==1)then
				swap(items,j,x)
				x=j
      		else
   				j=j-1
			end
  		end
		while(i<x)do
			if(compare(items[i], ix)==-1)then
				swap(items,i,x)
				x=i
			else
   				i=i+1
			end
  		end
 	end
	if(x-1 > from) then
		qsort(items,from,x-1)
	end
	if(x+1 < to) then
		qsort(items,x+1,to)
	end
end

--[[
排序 items ,并返回一个新的排序过的 items,原 items 不变
]]
local function jsort(items)
	local clone = {}--Item:new[items.length]
	for i=1,bagSize do
		clone[i] = items[i]
	end
	qsort(clone,1,bagSize)
	return clone
end

--local moving=false
local function sortTo(_current, _to)
	current=_current
	to=_to
	lockedSlots={}
	JPACK_STEP=JPACK_PACKING
end

--[[===================================
		  Main Processing
=====================================]]
--移动到特殊背包，如箭袋，灵魂袋，草药袋，矿石袋
--flag =0 , 背包， flag = 1 bank
local function moveToSpecialBag(flag)
	local bagTypes = nil
	if flag == 0 then
		bagTypes = JPack.bagSlotTypes
	elseif flag == 1 then
		bagTypes = JPack.bankSlotTypes
		if(not JPack.bankOpened)then return end
	--elseif guidbank
	end
	
	local fromBags = bagTypes[L.TYPE_BAG]
	
	for k,v in pairs(bagTypes) do
		--针对每种不同的背包,k is type,v is slots
		if k ~= L.TYPE_BAG then 
		local toBags = v
		local frombagIndex,tobagIndex=table.getn(fromBags),table.getn(toBags)
		local frombag,tobag = fromBags[frombagIndex],toBags[tobagIndex]
		local fromslot,toslot=GetContainerNumSlots(frombag),GetContainerNumSlots(tobag)
		--移动
		while(true) do
			while(tobagIndex>0 and GetContainerItemLink(tobag,toslot))do
				--直到找到一个空格
				tobagIndex,toslot=getPrevSlot(toBags,tobagIndex,toslot)
			end
			tobag = toBags[tobagIndex]
			
			while(frombagIndex>0 and (not CanGoInBag(fromBags[frombagIndex],fromslot,tobag)))do
				tobagIndex,toslot=getPrevSlot(toBags,tobagIndex,toslot)
			end
			
			if(frombagIndex<=0 or tobagIndex <=0 or fromslot<=0 or toslot<=0)then 
				debug("break to move sepical bag")
				break
			end
			if (CursorHasItem() or CursorHasMoney() or CursorHasSpell()) then
				print(L["WARN"],1,0,0)
			end
			PickupContainerItem(frombag,fromslot)
			PickupContainerItem(tobag,toslot)
			--next
			frombagIndex,fromslot=getPrevSlot(fromBags,frombagIndex,fromslot)
			tobagIndex,toslot=getPrevSlot(toBags,tobag,toslot)
		end
		
		end
	end

end

--保存到银行
local function saveToBank()
	if(not JPack.bankOpened)then return end
	
	--保存
	for k,v in pairs(JPack.bankSlotTypes) do
		--针对每种不同的背包,k is type,v is slots
		local bkTypes,bagTypes=JPack.bankSlotTypes[k],JPack.bagSlotTypes[k]
		local bkBag,bag=table.getn(bkTypes),table.getn(bagTypes)
		local bkSlot,slot=GetContainerNumSlots(bkTypes[bkBag]),GetContainerNumSlots(bagTypes[bag])
		--保存
		while(true) do
			while(bkBag>0 and GetContainerItemLink(bkTypes[bkBag],bkSlot))do
				--直到找到一个空格
				bkBag,bkSlot=getPrevSlot(bkTypes,bkBag,bkSlot)
			end
			
			while(bag>0 and (not shouldSaveToBank(bagTypes[bag],slot)))do
				bag,slot=getPrevSlot(bagTypes,bag,slot)
			end
			
			if(bkBag<=0 or bag <=0 or bkSlot<=0 or slot<=0)then 
				debug("break to save")
				break
			end
			if (CursorHasItem() or CursorHasMoney() or CursorHasSpell()) then
				print(L["WARN"],1,0,0)
			end
			PickupContainerItem(bagTypes[bag],slot)
			PickupContainerItem(bkTypes[bkBag],bkSlot)
			--next
			bkBag,bkSlot=getPrevSlot(bkTypes,bkBag,bkSlot)
			bag,slot=getPrevSlot(bagTypes,bag,slot)
		end
	end
end

--从银行取出
local function loadFromBank()
	if(not JPack.bankOpened)then return end
	
	--保存
	for k,v in pairs(JPack.bankSlotTypes) do
		--针对每种不同的背包,k is type,v is slots
		local bkTypes,bagTypes=JPack.bankSlotTypes[k],JPack.bagSlotTypes[k]
		local bkBag,bag=table.getn(bkTypes),table.getn(bagTypes)
		local bkSlot,slot=GetContainerNumSlots(bkTypes[bkBag]),GetContainerNumSlots(bagTypes[bag])
		--保存
		while(true) do
			while(bag>0 and GetContainerItemLink(bagTypes[bag],slot))do
				--直到找到一个空格
				bag,slot=getPrevSlot(bagTypes,bag,slot)
			end
			while(bkBag>0 and (not shouldLoadFromBank(bkTypes[bkBag],bkSlot)))do
				bkBag,bkSlot=getPrevSlot(bkTypes,bkBag,bkSlot)
			end
			
			if(bkBag<=0 or bag <=0 or bkSlot<=0 or slot<=0)then 
				break
			end
			if (CursorHasItem() or CursorHasMoney() or CursorHasSpell()) then
				print(L["WARN"],1,0,0)
			end
			PickupContainerItem(bkTypes[bkBag],bkSlot)
			PickupContainerItem(bagTypes[bag],slot)
			--next
			bkBag,bkSlot=getPrevSlot(bkTypes,bkBag,bkSlot)
			bag,slot=getPrevSlot(bagTypes,bag,slot)
		end
	end
end


--[[
将背包按类型分组
bagGroups
bankGroups
bagTypes
packingTypeIndex
packingBags
]]
local function groupBags()
	local bagTypes={}
	bagTypes[L.TYPE_BAG]={}
	bagTypes[L.TYPE_BAG][1]=0
	for i=1,4 do
		local name=GetBagName(i)
		if(name)then
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, subType, itemStackCount,
itemEquipLoc, itemTexture = GetItemInfo(name)
			debug("Bag[",i,"]Type：",subType)
			if(bagTypes[subType]==nil)then
				bagTypes[subType]={}
			end
			local t = bagTypes[subType]
			t[table.getn(t)+1]=i
		end
	end

	local bankSlotTypes={}
	if(JPack.bankOpened)then
		bankSlotTypes[L.TYPE_BAG]={}
		bankSlotTypes[L.TYPE_BAG][1]=-1
		for i=5,11 do
			local name=GetBagName(i)
			if(name)then
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, subType, itemStackCount,
itemEquipLoc, itemTexture = GetItemInfo(name)
				if(bankSlotTypes[subType]==nil)then
					bankSlotTypes[subType]={}
				end
				local t = bankSlotTypes[subType]
				t[table.getn(t)+1]=i
			end
		end
	end
	JPack.bagSlotTypes=bagTypes
	JPack.bankSlotTypes=bankSlotTypes
	local j=1
	for k,v in pairs(bankSlotTypes) do
		JPack.bagGroups[j]=v
		j=j+1
	end
	for k,v in pairs(bagTypes) do
		JPack.bagGroups[j]=v
		j=j+1
	end
	
end

--[[
获取PackingBags的 JPack格式物品table
]]
local function getPackingItems()
	local c=1
	local items={}
	if JPackDB.asc then
		for i=1,table.getn(JPack.packingBags) do
			local num = GetContainerNumSlots(JPack.packingBags[i]) 
			for j = 1,num do
				items[c]=getJPackItem(JPack.packingBags[i],j)
				c = c+1
			end
		end
	else
		for i=table.getn(JPack.packingBags),1,-1 do
			local num = GetContainerNumSlots(JPack.packingBags[i]) 
			for j = num,1,-1 do
				items[c]=getJPackItem(JPack.packingBags[i],j)
				c = c+1
			end
		end
	end
	return items,c-1
end

--[[
开始对packingBags 进行整理
]]
local function startPack()
	local items,count = getPackingItems()
	bagSize=count
	local sorted = jsort(items)
	debug("sorted...")
	--[[for i=1,table.getn(sorted) do
		debug(getCompareStr(sorted[i]))
	end]]
	sortTo(items,sorted)
end

--[[
将 PackIndex 转换为 BagId,SlotId
]]
local function getSlotId(packIndex)
	local slot=packIndex
	if JPackDB.asc then
		for i=1,table.getn(JPack.packingBags) do
			local num=GetContainerNumSlots(JPack.packingBags[i]) 
			if(slot<=num)then
				return JPack.packingBags[i],slot
			end
			slot = slot - num
		end
	else
		for i=table.getn(JPack.packingBags),1,-1 do
			local num=GetContainerNumSlots(JPack.packingBags[i]) 
			if(slot<=num)then
				return JPack.packingBags[i],1+num-slot
			end
			slot = slot - num
		end
	end
	return -1,-1
end

--[[
oldIndex  原JPack物品位置索引
newIndex 新JPack物品位置索引
把物品从oldIndex 移动到 newIndex
]]
local function moveTo(oldIndex,newIndex)
	PickupContainerItem(getSlotId(oldIndex))
	PickupContainerItem(getSlotId(newIndex))
end

--[[
某位置是否被锁定,与blizzard函数不同的是，空格也可能被锁定
]]
local function isLocked(index)
	local il=IndexOfTable(lockedSlots,index)
	local texture, itemCount, locked, quality, readable = GetContainerItemInfo(getSlotId(index))
	if(texture==nil)then
		locked= il >0
	elseif(il>0)then
		table.remove(lockedSlots,il)
	end
	return locked
end

--[[
items 物品数组
key  待查找物品名字
return 最后一个可以移动的此物品位置
]]
local function GetLastItemIndex(items,key)
	local i=bagSize
	while(i>0)do
		if(items[i] ~= nil and not isLocked(i) and items[i].name == key)then
			return i
		end
		i= i-1
	end
	return -1
end

--[[
移动一次, 返回是否继续
]]
local function moveOnce()
	local working=false
	local i=1
	local lockCount=0
	while to[i] do
		local locked=isLocked(i)
		if(locked==nil)then locked=false end
		if(locked)then
			lockCount=lockCount+1
		end
		if(lockCount>JPACK_MAXMOVE_ONCE)then
			return true
		end
		if(current[i] == nil or to[i].name ~= current[i].name)then
			working = true
			if(not locked)then
				local slot =GetLastItemIndex(current, to[i].name)
				if(slot ~= -1)then
					moveTo(slot,i) -- 移动物品
					local x=current[slot]
					current[slot]=current[i]
					current[i]=x
					if(current[slot]==nil)then
						--锁定空格
						lockedSlots[table.getn(lockedSlots)+1]=i
					end
				end
			end
			
		end
		i=i+1
	end
	return working or lockCount>0
end

--堆叠一次，返回是否结束
local function stackOnce()
	local bags,bag,item,slotInfo
	if(JPack.bankOpened)then
		bags={11,10,9,8,7,6,5,-1,4,3,2,1,0}
	else
		bags={4,3,2,1,0}
	end
	local pendingStack={}
	local complet=true
	for i=1,#bags do
		bag = bags[i]
		for slot = GetContainerNumSlots(bag),1,-1 do
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)
			item = getJPackItem(bag,slot)
			if(item)then
				if(not locked)then
					if(itemCount < item.stackCount)then
						-- item.name ==> item.itemid
						slotInfo = pendingStack[item.itemid]
						if(slotInfo)then
							PickupContainerItem(bag,slot)
							PickupContainerItem(slotInfo[1],slotInfo[2])
							pendingStack[item.itemid]=nil
							complet = false
						else
							pendingStack[item.itemid]={bag,slot}
						end
					end
				else
					complet = false
				end
			end
		end
	end
	return complet
end



--[[
		=== GuildBank ===
		
	http://wowprogramming.com/docs/api/
			GetCurrentGuildBankTab	Returns the currently selected guild bank tab (number) 
			PickupGuildBankItem		
			GetGuildBankItemInfo(tab, slot)		返回 材质/堆叠数量/*是否锁定
			GetGuildBankItemLink
			GetGuildBankTabInfo
			GetGuildBankTabPermissions
			GetNumGuildBankTabs
]]

--堆叠一次公会银行，返回是否结束
local function GBstackOnce()
	local item,slotInfo
	local pendingStackGB={}
	local complet=true
	for slot = 98,1,-1 do
		local texture, itemCount, locked = GetGuildBankItemInfo(currentGBTab, slot)
		item = getJPackItem(currentGBTab,slot,true)
		if(item)then
			if(not locked)then
				if(itemCount < item.stackCount)then
					-- item.name ==> item.itemid
					slotInfo = pendingStack[item.itemid]
					if(slotInfo)then
						PickupGuildBankItem(currentGBTab,slot)
						PickupGuildBankItem(slotInfo[1],slotInfo[2])
						pendingStack[item.itemid]=nil
						complet = false
					else
						pendingStack[item.itemid]={currentGBTab,slot}
					end
				end
			else
				complet = false
			end
		end
	end
	return complet
end



-- TODO
















--[[===================================
		Events/slash..etc..
=====================================]]

JPack:SetScript("OnEvent", function(self, event, ...) debug(event); self[event](self, ...) end)

JPack:RegisterEvent"ADDON_LOADED"
JPack:RegisterEvent"BANKFRAME_OPENED"
JPack:RegisterEvent"BANKFRAME_CLOSED"
JPack:RegisterEvent"GUILDBANKFRAME_CLOSED"
JPack:RegisterEvent"GUILDBANKFRAME_OPENED"


function JPack:ADDON_LOADED(addon)
	if addon ~= 'JPack' then return end
	JPackDB = JPackDB or {}

	-- welcome!
	print(string.format('%s %s', version, L["HELP"]))
end

function JPack:BANKFRAME_OPENED()
	JPack.bankOpened=true
end

function JPack:BANKFRAME_CLOSED()
	JPack.bankOpened=false
end

function JPack:GUILDBANKFRAME_CLOSED()
	JPack.guildbankOpened=true
end

function JPack:GUILDBANKFRAME_OPENED()
	JPack.guildbankOpened=false
end


--[[
每帧执行，判断当前整理进度并执行相应操作
]]--
local elapsed = 0
function JPack.OnUpdate(self, el)
	elapsed = elapsed + el
	if elapsed < .1 then return end
	elapsed = 0
	--debug("OnUpdate!")
	if(JPACK_STEP==JPACK_STARTED)then
		debug('JPACK_STEP==JPACK_STARTED')
		-- 判断玩家是否打开公会银行并有相应权限 *** 需要纠正判断
		if NOGUILDBANK and JPack.guildbankOpened then
			debug('guildbankOpened')
			-- 会长直接有全部权限
			if IsGuildLeader(UnitName("player")) then
				debug('player IsGuildLeader')
				currentGBTab = GetCurrentGuildBankTab() -- 取得当前打开页
				debug('currentGBTab: ',currentGBTab)
				JPACK_STEP=JPACK_GUILDBANK_STACKING -- 直接进入工会银行堆叠
			else
				--[[currentGBTab = GetCurrentGuildBankTab() -- 取得当前打开页
				debug('currentGBTab: '..currentGBTab)
				canView, canDeposit, stacksPerDay = GetGuildBankTabPermissions(currentGBTab)
				debug('canView = '..(canView and 'true' or 'false'))
				debug('canDeposit = '..(canDeposit and 'true' or 'false'))
				debug('stacksPerDay = '..(stacksPerDay or 'nil'))
				if canView and canDeposit and stacksPerDay > 999 then -- 判断拥有全部权限
					JPACK_STEP=JPACK_GUILDBANK_STACKING -- 进入工会银行堆叠
				else
					currentGBTab=nil
					JPACK_STEP=JPACK_GUILDBANK_COMPLETE -- 无足够权限 结束公会银行操作 开始普通操作
				end]]
				JPACK_STEP=JPACK_GUILDBANK_COMPLETE
			end
		else
			-- 未打开公会银行直接开始普通整理
			JPACK_STEP=JPACK_GUILDBANK_COMPLETE
		end
		debug('guildbankOpened, JPACK_STEP= ',JPACK_STEP)
	-- 开始堆叠
	elseif(JPACK_STEP==JPACK_GUILDBANK_STACKING)then
		if(GBstackOnce()) then -- 反复堆叠, 直至全部堆叠完毕开始整理工作
			JPACK_STEP=JPACK_GUILDBANK_SORTING
		end
	-- 开始移动整理
	elseif(JPACK_STEP==JPACK_GUILDBANK_SORTING)then
		if(isGBReady())then
--[=[TODO

排序可以参考 银行的整理，但由于pick银行和pick背包都是相同的api只是背包的bagId不同 ，
而公会银行则是完全使用了另外一套api，这里处理起来有些难度。

1.  将背包分组，分组后 类似 {{1,2,3},{4,5},{6,7,8},{9,10}} 是一个bagId数组的数组，
{1,2,3} 这3背包将视为整体在一起整理，然后是 {4,5} , { 6,7,8} 。
公会银行的bagId与背包银行的bagId不知道是否有冲突。
如果有冲突可以使用 100+公会银行bagId 来进行区分

2. bagId,slotId -> jpackIndex  , jpackIndex -> bagId,slotId  ，在jpack排序过程中，
只是对一个数组进行排序，而不区分背包，所以需要将 bagId、slotId 转换为 jpackIndex，
 而在排序结束后，需要移动物品，
 在移动物品时则要把 jpackIndex 转换为 bagId,slotId 以移动物品。 
 此处同样是bagId 的问题。

2. 排序。无需修改

3.  移动物品，pickup(bag1,slot1)；pickup(bag2,slot2) ；
 这两行代码将会把 bag1,slot1 与 bag2 slot2的物品互换，
 bag2，slot2 可以没有物品，bag1，slot1 必须有物品。
 此处要做的修改是，bag1，bag2 如果是背包或银行则使用原有的pickup函数，
 如果bag1、bag2是公会银行，则使用公会银行的pickup函数。
]=]
			
			
		end
		
		
	--公会银行整理结束,开始普通整理
	elseif(JPACK_STEP==JPACK_GUILDBANK_COMPLETE)then
		if(stackOnce())then
			JPACK_STEP=JPACK_STACK_OVER
		end
	elseif(JPACK_STEP==JPACK_STACK_OVER)then
		debug("JPACK_STEP==JPACK_STACK_OVER, 开始移动到银行特殊背包")
		if(isAllBagReady())then
			debug("堆叠完毕,JPack_STEP=JPACK_STACK_OVER")
			moveToSpecialBag(1)
			JPACK_STEP = JPACK_SPEC_BANK_OVER
		end
		
	elseif(JPACK_STEP==JPACK_SPEC_BANK_OVER)then
		debug("JPACK_STEP==JPACK_SPEC_BANK_OVER, 开始移动到特殊背包")
		if(isAllBagReady())then
			moveToSpecialBag(0)
			JPACK_STEP = JPACK_SPEC_BAG_OVER
		end
		
	elseif(JPACK_STEP==JPACK_SPEC_BAG_OVER)then
		debug("JPACK_STEP==JPACK_SPEC_BAG_OVER, 开始向银行保存")
		if(isAllBagReady())then
			if(JPack.deposit)then
				debug("saveToBank()")
				saveToBank()
			end
			JPACK_STEP=JPACK_DEPOSITING
		end
	elseif(JPACK_STEP==JPACK_DEPOSITING)then
		debug("JPACK_STEP==JPACK_DEPOSITING, 开始从银行提取")
		if(isAllBagReady())then
			debug("保存物品完毕,JPack_STEP=JPACK_DEPOSITING")
			if(JPack.draw)then
				debug("loadFromBank()")
				loadFromBank()
			end
			JPACK_STEP=JPACK_START_PACK
		end
	elseif(JPACK_STEP==JPACK_START_PACK)then
		debug("开始整理,JPACK_STEP=JPACK_START_PACK")
		if(isAllBagReady())then
			JPack.packingGroupIndex=1
			JPack.packingBags=JPack.bagGroups[1]
			--计算排序
			startPack()
			JPACK_STEP=JPACK_PACKING
		end
	elseif(JPACK_STEP==JPACK_PACKING)then
		--排序结束
		--移动物品
		local continueMove=moveOnce()
		if(not continueMove)then
			JPack.packingGroupIndex=JPack.packingGroupIndex + 1
			debug("index", JPack.packingGroupIndex)
			JPack.packingBags=JPack.bagGroups[JPack.packingGroupIndex]
			debug("JPack.bagGroups . size = ",table.getn(JPack.bagGroups))
			for i=1,table.getn(JPack.bagGroups) do
				for j=1,table.getn(JPack.bagGroups[i]) do
					debug("i", i, "j", j..":", JPack.bagGroups[i][j])
				end
			end
			if(JPack.packingBags==nil)then
				--整理结束
				JPACK_STEP=JPACK_STOPPED
				JPack.bagGroups={}
				print(L["COMPLETE"])
				JPack:SetScript("OnUpdate",nil)
				current=nil
				to=nil
			else
				debug("Packing ", JPack.packingGroupIndex)
				startPack()
			end
		end
	end
end


local function pack()
	if (CursorHasItem() or CursorHasMoney() or CursorHasSpell()) then
		print(L["WARN"],2,0.28,2)
	else
		groupBags()
		JPACK_STEP=JPACK_STARTED
		elapsed = 1
		JPack:SetScript("OnUpdate", JPack.OnUpdate)
	end
end


SLASH_JPACK1 = "/jpack"
SLASH_JPACK2 = "/jp"
SlashCmdList.JPACK = function(msg)
	local a,b,c=strfind(msg, "(%S+)")
	if not c then JPack:Pack(); return end
	c = strlower(c)
	if(c=="asc")then
		JPack:Pack(nil, 1)
	elseif(c=="desc")then
		JPack:Pack(nil, 2)
	elseif(c=="deposit" or c=="save")then
		JPack:Pack(1)
	elseif(c=="draw" or c=="load")then
		JPack:Pack(2)
	elseif(c=="help")then
		local text = "%s - |cffffffff%s|r"
		print(L["Slash command"]..": /jpack |cffffffffor|r /jp")
		print(format(text, "/jp", L["Pack"]))
		print(format(text, "/jp asc", L["Set sequence to asc"]))
		print(format(text, "/jp desc", L["Set sequence to desc"]))
		print(format(text, "/jp deposit |cffffffffor|r save", L["Save to the bank"]))
		print(format(text, "/jp draw |cffffffffor|r load", L["Load from the bank"]))
		print(format(text, "/jp help", L["Print help info"]))
	else
		print(format("%s: |cffff0000%s|r , %s", L["Unknown command"], c, L["HELP"]))
	end
end


--[[===================================
			API
=====================================]]

--[[
	JPack:Pack(access, order)
	access	
			1	save
			2	load
			nil	no action
	order		
			1	asc
			2	desc
			nil	last-time-order or default
]]
function JPack:Pack(access, order)
	JPack.deposit=false
	JPack.draw=false
	if access == 1 then
		JPack.deposit=true
	elseif access == 2 then
		JPack.draw=true
	end
	if order == 1 then
		JPackDB.asc=true
	elseif order == 2 then
		JPackDB.asc=false
	end
	
	pack()
end
