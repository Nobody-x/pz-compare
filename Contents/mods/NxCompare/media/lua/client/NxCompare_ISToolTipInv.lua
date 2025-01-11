require "ISUI/ISToolTipInv"
require "NxCompare_Utils"
require "NxCompare_ISToolTipComp"

-- TODO: compare clothes / weapons / bag stats
--  bloodLevel
--  dirtyness
--  wetness
--  stompPower
--  runSpeedModifier
--  combatSpeedModifier
--  biteDefense
--  scratchDefense
--  bulletDefense
--  waterResistance
--  temperature
--  insulation
--  windresistence

-- Base ISToolTipInv class
local Vanilla_ISToolTipInv = {}

-- Overridden methods
Vanilla_ISToolTipInv.prerender = ISToolTipInv.prerender
Vanilla_ISToolTipInv.render = ISToolTipInv.render
Vanilla_ISToolTipInv.new = ISToolTipInv.new
Vanilla_ISToolTipInv.setItem = ISToolTipInv.setItem

-- constants
local validCategories = { 
	"Weapon", 
	"Clothing", 
	"Container", 
	"AlarmClock"
}

function ISToolTipInv:prerender()
	Vanilla_ISToolTipInv.prerender(self)
	
	-- Add the compare tooltip to the UIManager when needed.
	if NxCompare_IsTooltipShown and not self.compareTooltip:getIsVisible() then
		self.compareTooltip:addToUIManager()
		self.compareTooltip:setVisible(true)
	elseif not NxCompare_IsTooltipShown and self.compareTooltip:getIsVisible() then
		self.compareTooltip:setVisible(false)
		self.compareTooltip:removeFromUIManager()
    end
end

local function updateISToolTipInv(tooltip, item)
	tooltip.compareTooltip:removeItems()
	
	if item == nil then
		return
	end
	
	-- Check if the item is from a valid category to compare.
	-- Clothing, Container or Weapon.
	if not NxCompare_Utils.in_array(item:getCategory(), validCategories) then
		return
	end
	
	-- Special check for alarm clock since we can't distringuish them from wrist watches
	if item:getCategory() == "AlarmClock" and not item:IsClothing() then
		return
	end
	
	-- Get all equipped items.
	local equippedItems = NxCompare_Utils.getEquippedItems()
	local compareTo = {}
	
	-- Equippable items
	if item:IsWeapon() then
		-- Check items in hands.
		if equippedItems["_Hands"] ~= nil then
			for i, handItem in pairs(equippedItems["_Hands"]) do
				table.insert(compareTo, handItem)
			end
		end
	end
	
	local slotDefinitions = NxCompare_Utils.getSlotDefsByAttachmentType(item:getAttachmentType())
	
	-- Item can be attached
	if not NxCompare_Utils.is_table_empty(slotDefinitions) then
		-- Check equipped items.
		if equippedItems["_Attached"] ~= nil then
			for j, slotDef in pairs(slotDefinitions) do
				if equippedItems["_Attached"][slotDef.type] ~= nil then
					table.insert(compareTo, equippedItems["_Attached"][slotDef.type])
				end
			end
		end
	end
	
	-- Special handling for clothes
	if item:IsClothing() then
		local itemBodyLoc = item:getBodyLocation()
		
		-- Special handling for watches
		if NxCompare_Utils.in_array(itemBodyLoc, {"LeftWrist", "RightWrist"}) then
			if equippedItems["LeftWrist"] ~= nil then table.insert(compareTo, equippedItems["LeftWrist"]) end
			if equippedItems["RightWrist"] ~= nil then table.insert(compareTo, equippedItems["RightWrist"]) end
		-- Special handling for rings
		elseif NxCompare_Utils.in_array(itemBodyLoc, {"Left_MiddleFinger", "Left_RingFinger", "Right_MiddleFinger", "Right_RingFinger"}) then
			if equippedItems["Left_MiddleFinger"] ~= nil then table.insert(compareTo, equippedItems["Left_MiddleFinger"]) end
			if equippedItems["Left_RingFinger"] ~= nil then table.insert(compareTo, equippedItems["Left_RingFinger"]) end
			if equippedItems["Right_MiddleFinger"] ~= nil then table.insert(compareTo, equippedItems["Right_MiddleFinger"]) end
			if equippedItems["Right_RingFinger"] ~= nil then table.insert(compareTo, equippedItems["Right_RingFinger"]) end
		-- Special handling for knee protection
		elseif NxCompare_Utils.in_array(itemBodyLoc, {"Knee_Left", "Knee_Right"}) then
			if equippedItems["Knee_Left"] ~= nil then table.insert(compareTo, equippedItems["Knee_Left"]) end
			if equippedItems["Knee_Right"] ~= nil then table.insert(compareTo, equippedItems["Knee_Right"]) end
		end
		
		-- Check for exclusive item
		for location, equippedItem in pairs(equippedItems) do
			-- We must loop over all equipped clothing to find exclusive items.
			if not location:find("^_") and equippedItem:IsClothing() then
				local _itemBodyLoc = NxCompare_Utils.getItemBodyLoc(equippedItem)
				if (_itemBodyLoc:getId() == itemBodyLoc or _itemBodyLoc:isExclusive(itemBodyLoc)) and not NxCompare_Utils.in_array(equippedItem, compareTo) then
					table.insert(compareTo, equippedItem)
				end
			end
		end
	end
	
	if item:getCategory() == "Container" and item:canBeEquipped() ~= "" then
		local _bodyLoc = item:canBeEquipped()
		
		-- Special handling for fanny packs
		if NxCompare_Utils.in_array(_bodyLoc, {"FannyPackBack", "FannyPackFront"}) then
			if equippedItems["FannyPackBack"] ~= nil then table.insert(compareTo, equippedItems["FannyPackBack"]) end
			if equippedItems["FannyPackFront"] ~= nil then table.insert(compareTo, equippedItems["FannyPackFront"]) end
		-- Common handling
		else
			if equippedItems[_bodyLoc] ~= nil then table.insert(compareTo, equippedItems[_bodyLoc]) end
		end
	end
	
	if NxCompare_Utils.in_array(item, compareTo) then
		-- Tooltip is about an equipped item.
		return
	end
	
	tooltip.compareTooltip:setItems(compareTo)
end

-- On item updated.
function ISToolTipInv:setItem(item)
	Vanilla_ISToolTipInv.setItem(self, item)
	
	updateISToolTipInv(self, item)
end


-- Panel creation function.
function ISToolTipInv:new(item)
	local o = Vanilla_ISToolTipInv.new(self, item)

	o.compareTooltip = ISNxToolTip:new()
	o.compareTooltip:setVisible(false)
	o.compareTooltip:setAlwaysOnTop(true)
	o.compareTooltip:setOwner(o)
	
	updateISToolTipInv(o, item)
	
	return o;
end
