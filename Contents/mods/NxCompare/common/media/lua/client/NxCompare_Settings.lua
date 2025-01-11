-- ModOptions compatibility.

-- Global to observe toggleCompareTooltips key events.
NxCompare_IsTooltipShown = false


-- Key-bind declaration.
local toggleCompareTooltipsTab = {
  key = Keyboard.KEY_LSHIFT,
  name = "toogleCompareTooltips",
}

if ModOptions and ModOptions.AddKeyBinding then
	-- Adding key-bind to the [UI] menu
	ModOptions:AddKeyBinding("[UI]", toggleCompareTooltipsTab);
end


-- Key press observers.
local function KeyDown(key)
	if key == toggleCompareTooltipsTab.key then
        NxCompare_IsTooltipShown = true
	end
end

local function KeyUp(key)
	if key == toggleCompareTooltipsTab.key then
        NxCompare_IsTooltipShown = false
	end
end

Events.OnKeyStartPressed.Add(KeyDown)
Events.OnKeyPressed.Add(KeyUp)