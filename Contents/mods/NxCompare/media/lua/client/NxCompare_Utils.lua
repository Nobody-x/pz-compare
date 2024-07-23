require "NPCs/BodyLocations"

NxCompare_Utils = {}

local bodyLocationGroup = BodyLocations.getGroup("Human");


-- Compute all equipped items indexed by their body part, hand location or attached slot.
-- TODO: Save equipped items until the player add/remove something instead of computing each item every time.
NxCompare_Utils.getEquippedItems = function()
	local equippedItems = {}

	local playerObj = getPlayer()
	local primaryItem = playerObj:getPrimaryHandItem()
	local secondaryItem = playerObj:getSecondaryHandItem()
	
	if primaryItem or secondaryItem then
		-- Init hand items table.
		equippedItems["_Hands"] = {}
		
		if primaryItem then 
			if primaryItem:IsWeapon() then
				-- Only compare weapons in hand.
				equippedItems["_Hands"].RightHand = primaryItem
			end
		end
		
		if secondaryItem and primaryItem ~= secondaryItem then 
			if secondaryItem:IsWeapon() then
				-- Only compare weapons in hand.
				equippedItems["_Hands"].LeftHand = secondaryItem
			end
		end
	end
	
	local inventoryList = playerObj:getInventory():getItems()
	
	if inventoryList ~= nil then
		for i = 0, inventoryList:size() - 1 do
			local item = inventoryList:get(i)
			
			-- Ignore in hands items.
			if item ~= primaryItem and item ~= secondaryItem then
				-- Add equipped clothes and backpacks.
				if item:IsClothing() and item:isEquipped() then
					equippedItems[item:getBodyLocation()] = item
				end
				
				if item:getCategory() == "Container" and playerObj:isEquipped(item) and item:canBeEquipped() ~= "" then
					equippedItems[item:canBeEquipped()] = item
				end
			end
		end
	end
	
	-- Key binds
	local attachedItemsList = playerObj:getAttachedItems()
	if attachedItemsList ~= nil then
		-- Init attached items table.
		equippedItems["_Attached"] = {}
		for i = 0, attachedItemsList:size() - 1 do
			local item = attachedItemsList:getItemByIndex(i)
			if item ~= primaryItem and item ~= secondaryItem then
				equippedItems["_Attached"][item:getAttachedSlotType()] = item
			end
		end
	end
	
	return equippedItems
end

NxCompare_Utils.getSlotDefsByAttachmentType = function(attachmentType)
	local slots = {}

	for slot, slotDef in ipairs(ISHotbarAttachDefinition) do
		for def, name in pairs(slotDef.attachments) do
			if def == attachmentType then
				slots[slotDef.type] = slotDef
			end
		end
	end
	
	return slots
end

NxCompare_Utils.getItemBodyLoc = function(item)
	return bodyLocationGroup:getLocation(item:getBodyLocation())
end


--************************************************************************--
--** UTILITIES
--**
--************************************************************************--

-- Can't use the next() function so had to create this one.
NxCompare_Utils.is_table_empty = function(t)
	for index, value in pairs(t) do
		return fale
	end

	return true
end


-- PHP like in_array function.
NxCompare_Utils.in_array = function(needle, haystack)
	for index, value in pairs(haystack) do
		if value == needle then
			return true
		end
	end

	return false
end


-- Print table values with indexes.
NxCompare_Utils.debug_table = function(t)
	for index, value in pairs(t) do
		print("Index : ", index, "; Value : ", value, ";")
	end
end