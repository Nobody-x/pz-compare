-- ModOptions compatibility.

-- Global to observe toggleCompareTooltips key events.
NxCompare_IsTooltipShown = false


-- Store all configs.
local config = {
  toggleCompareTooltips = nil
}


-- Configuration settings build
local function buildConfig() 
	local options = PZAPI.ModOptions:create("nxcompare", "Nx's Compare items")
	
	config.toggleCompareTooltips = options:addKeyBind("0", getText("UI_options_nxcompare_toogleCompareTooltips"), Keyboard.KEY_LSHIFT)
end


-- Key press observers.
local function KeyDown(key)
	if key == config.toggleCompareTooltips.key then
        NxCompare_IsTooltipShown = true
	end
end

local function KeyUp(key)
	if key == config.toggleCompareTooltips.key then
        NxCompare_IsTooltipShown = false
	end
end


-- Handle settings
buildConfig()
Events.OnKeyStartPressed.Add(KeyDown)
Events.OnKeyPressed.Add(KeyUp)