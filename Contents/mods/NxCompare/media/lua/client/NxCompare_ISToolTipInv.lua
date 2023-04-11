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
local validCategories = { "Weapon", "Clothing", "Container" }

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
	
	-- Get all equipped items.
	local equippedItems = NxCompare_Utils.getEquippedItems()
	local compareTo = {}
	
	
	-- Equippable items
	
	if not item:IsClothing() and (item:getCategory() ~= "Food" or item:getScriptItem():isCantEat()) then
	
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
	
	if item:IsClothing() then
		local _bodyLoc = item:getBodyLocation()
		
		if equippedItems[_bodyLoc] ~= nil then table.insert(compareTo, equippedItems[_bodyLoc]) end
	end
	
	if item:getCategory() == "Container" and item:canBeEquipped() ~= "" then
		local _bodyLoc = item:canBeEquipped()
		
		if NxCompare_Utils.in_array(_bodyLoc, {"FannyPackBack", "FannyPackFront"}) then
			if equippedItems["FannyPackBack"] ~= nil then table.insert(compareTo, equippedItems["FannyPackBack"]) end
			if equippedItems["FannyPackFront"] ~= nil then table.insert(compareTo, equippedItems["FannyPackFront"]) end
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
