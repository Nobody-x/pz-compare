require "ISUI/ISPanel"
require "NxCompare_Utils"

ISNxToolTip = ISPanel:derive("ISNxToolTip");


ISNxToolTip.Placements = {
	Right = 0,
	Left = 1,
	Above = 2,
}

--************************************************************************--
--** ISPanel:initialise
--**
--************************************************************************--

function ISNxToolTip:initialise()
	ISPanel.initialise(self);
end

function ISNxToolTip:instantiate()
	ISPanel.instantiate(self)
	self.javaObject:setConsumeMouseEvents(false)
end

function ISNxToolTip:setItems(items)
	self.compareItems = items;
end

function ISNxToolTip:removeItems()
	self.compareItems = {};
end

function ISNxToolTip:setOwner(ui)
	self.owner = ui
end

function ISNxToolTip:onMouseDown(x, y)
	return false
end

function ISNxToolTip:onMouseUp(x, y)
	return false
end

function ISNxToolTip:onRightMouseDown(x, y)
	return false
end

function ISNxToolTip:onRightMouseUp(x, y)
	return false
end


--************************************************************************--
--** ISPanel:render
--**
--************************************************************************--
function ISNxToolTip:prerender()
	self:setVisible(false)
	if self.owner and not self.owner:isReallyVisible() then
		self:removeFromUIManager()
		return
	end
	self:doLayout()
end

function ISNxToolTip:doLayout()
	local offsetY = 0
	self.compareTooltips = {}

	-- Generate all tooltips measures to determine panel size.
	for index, item in pairs(self.compareItems) do
		local tooltip = ObjectTooltip.new()
		table.insert(self.compareTooltips, tooltip)
		
		tooltip:setWidth(50)
		tooltip:setMeasureOnly(true)
		item:DoTooltip(tooltip)
		tooltip:setMeasureOnly(false)
		
		offsetY = offsetY + tooltip:getHeight() + 11
		
		if tooltip:getWidth() > self:getWidth() then
			-- Resize the panel width to the biggest tooltip.
			self:setWidth(tooltip:getWidth())
		end
		
		self:setHeight(offsetY - 11)
	end
	
	if not NxCompare_Utils.is_table_empty(self.compareItems) then
		self:setVisible(true)
	end
end

function ISNxToolTip:render()
	local ownerX = self.owner:getAbsoluteX()
	local ownerY = self.owner:getAbsoluteY()

	self:setX(ownerX + 11)
	self:setY(ownerY)

	if self.owner then
		local ownerRect = { x = self.owner:getAbsoluteX(), y = self.owner:getAbsoluteY(), width = self.owner.width, height = self.owner.height }
		self:adjustPositionToAvoidOverlap(ownerRect)
	end

	self:renderContents()
end

function ISNxToolTip:renderContents()
	local offsetY = 0
	
	-- Render all tooltips.
	for index, tooltip in pairs(self.compareTooltips) do
		if self.placement == ISNxToolTip.Placements.Left then
			-- Align tooltips right.
			tooltip:setX(self:getX() + (self:getWidth() - tooltip:getWidth()))
		else
			-- Align tooltips left.
			tooltip:setX(self:getX())
		end
		
		tooltip:setY(self:getY() + offsetY)
		
		offsetY = offsetY + tooltip:getHeight() + 11
		
		-- Render the background and the border.
		self:drawRect(tooltip:getX() - self:getX(), tooltip:getY() - self:getY(), tooltip:getWidth(), tooltip:getHeight(), self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
		self:drawRectBorder(tooltip:getX() - self:getX(), tooltip:getY() - self:getY(), tooltip:getWidth(), tooltip:getHeight(), self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
		
		-- Render the item tooltip.
		self.compareItems[index]:DoTooltip(tooltip)
	end
end

function ISNxToolTip:adjustPositionToAvoidOverlap(avoidRect)
	local myRect = { x = self.x, y = self.y, width = self.width, height = self.height }
	self.placement = ISNxToolTip.Placements.Right

	if self:overlaps(myRect, avoidRect) then
		local r = self:placeRight(myRect, avoidRect)
		if self:overlaps(r, avoidRect) then
			self.placement = ISNxToolTip.Placements.Above
			r = self:placeAbove(myRect, avoidRect)
			if self:overlaps(r, avoidRect) then
				self.placement = ISNxToolTip.Placements.Left
				r = self:placeLeft(myRect, avoidRect)
			end
		end
		self:setX(r.x)
		self:setY(r.y)
	end
end

function ISNxToolTip:overlaps(r1, r2)
	return r1.x + r1.width > r2.x and r1.x < r2.x + r2.width and
			r1.y + r1.height > r2.y and r1.y < r2.y + r2.height
end

function ISNxToolTip:placeLeft(r1, r2)
	local r = r1
	r.x = math.max(0, r2.x - r.width - 48)
	return r
end

function ISNxToolTip:placeRight(r1, r2)
	local r = r1
	r.x = r2.x + r2.width + 8
	r.x = math.min(r.x, getCore():getScreenWidth() - r.width)
	return r
end

function ISNxToolTip:placeAbove(r1, r2)
	local r = r1
	r.y = r2.y - r.height - 48
	r.y = math.max(0, r.y)
	return r
end

--************************************************************************--
--** ISPanel:new
--**
--************************************************************************--
function ISNxToolTip:new()
	local o = ISPanel.new(self, 0, 0, 0, 0);
	o:noBackground();

	o.compareTooltips = {};
	o.compareItems = {};
	
	o.placement = ISNxToolTip.Placements.Right;

	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.backgroundColor = {r=0, g=0, b=0, a=0.5};

	o.width = 0;
	o.height = 0;
	o.anchorLeft = true;
	o.anchorRight = false;
	o.anchorTop = true;
	o.anchorBottom = false;
	o.owner = nil
	o.followMouse = true
	
	return o;
end

