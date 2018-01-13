--[[
Project name: HeadCount
Developed by: seppyk (http://www.authority-km.com)
Website: http://www.wowace.com/wiki/HeadCount
Description: Manages tracking of raid attendance and more.
License: Creative Common Attribution-NonCommercial-ShareAlike 3.0 Unported
File: Loot.lua
File description: Loot object
]]

local AceOO = AceLibrary("AceOO-2.0")
local L = AceLibrary("AceLocale-2.2"):new("HeadCount")
local HeadCount = HeadCount

HeadCount.Loot = AceOO.Class()

HeadCount.Loot.prototype.itemId = nil
HeadCount.Loot.prototype.playerName = nil 
HeadCount.Loot.prototype.cost = nil
HeadCount.Loot.prototype.activityTime = nil
HeadCount.Loot.prototype.quantity = nil
HeadCount.Loot.prototype.zone = nil 
HeadCount.Loot.prototype.source = nil 

function HeadCount.Loot.prototype:init(args)
	self.class.super.prototype.init(self)

	self.type = "HeadCountLoot-1.0"
	
	self.itemId = args["itemId"]
	self.playerName = args["playerName"]	
	self.cost = args["cost"]
	self.activityTime = args["activityTime"]
	self.quantity = args["quantity"]
	self.zone = args["zone"]
	self.source = args["source"]
end

-- Gets the args structure
function HeadCount.Loot:getArgs() 
	local args = { 
		["itemId"] = nil, 
		["playerName"] = nil, 
		["cost"] = nil, 
		["activityTime"] = nil, 
		["quantity"] = nil, 
		["zone"] = nil,  
		["source"] = nil, 
	}
	
	return args
end

-- Gets an item id from a link.
-- @param link The item link.
-- @return string Returns the item id or nil if none exists
function HeadCount.Loot:retrieveItemId(link)
	local startPoint
	local endPoint
	local itemId = nil
	
	if (link) then
		itemId = string.match(link, "item:(%d+):")
	end
	
	return itemId
end

-- Gets the item id.
-- @return string Returns the item id
function HeadCount.Loot.prototype:getItemId() 
	return self.itemId
end

-- Gets the player name.
-- @return string Returns the player name.
function HeadCount.Loot.prototype:getPlayerName() 
	return self.playerName 
end

-- Sets the player name.
-- @param playerName The player name.
function HeadCount.Loot.prototype:setPlayerName(playerName) 
	self.playerName = playerName
end

-- Gets the cost
-- @return number Returns the cost.
function HeadCount.Loot.prototype:getCost()
	return self.cost
end

-- Sets the cost.
-- @param cost The cost.
function HeadCount.Loot.prototype:setCost(cost)
	self.cost = cost
end

-- Gets the activity time.
-- @return object Returns the activity time.
function HeadCount.Loot.prototype:getActivityTime() 
	return self.activityTime
end

-- Gets the quantity.
-- @return number Returns the quantity.
function HeadCount.Loot.prototype:getQuantity() 
	return self.quantity
end

-- Gets the zone.
-- @return string Returns the zone
function HeadCount.Loot.prototype:getZone() 
	return self.zone
end

-- Gets the source
-- @return string Returns the source
function HeadCount.Loot.prototype:getSource()
	return self.source
end

-- Sets the source
-- @param source The source.
function HeadCount.Loot.prototype:setSource(source)
	self.source = source
end

-- Gets the loot name.
-- @return string Returns the loot name.
function HeadCount.Loot.prototype:getName() 
	local itemName = GetItemInfo(self.itemId)

	return itemName
end

-- Gets the link.
-- @return string Returns the link.
function HeadCount.Loot.prototype:getLink() 
	local itemLink = select(2, GetItemInfo(self.itemId))
	
	return itemLink	
end

-- Retrieve the item color
-- @return string Returns the item color.
function HeadCount.Loot.prototype:retrieveColor()
	local link = self:getLink()
	local color = nil
	
	if (link) then
		color = select(3, string.find(link, "|c(%x+)|Hitem:[-%d:]+|h%[.-%]|h|r"))
	end
	
	return color
end

-- Gets the rarity.
-- @return number Returns the rarity.
function HeadCount.Loot.prototype:getRarity() 	
	local itemRarity = select(3, GetItemInfo(self.itemId))
	
	return itemRarity
end

-- Gets the item level.
-- @return number Returns the item level.
function HeadCount.Loot.prototype:getLevel() 
	local itemLevel = select(4, GetItemInfo(self.itemId)) 
	
	return itemLevel
end

-- Gets the item type.
-- @return string Returns the item type
function HeadCount.Loot.prototype:getItemType() 	
	local itemType = select(6, GetItemInfo(self.itemId))
	
	return itemType
end

-- Gets the item sub type.
-- @return string Returns the item sub type
function HeadCount.Loot.prototype:getItemSubType() 	
	local itemSubType = select(7, GetItemInfo(self.itemId))
	
	return itemSubType
end

-- Gets the texture.
-- @return string Returns the texture string
function HeadCount.Loot.prototype:getTexture() 
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, texture = GetItemInfo(self.itemId) 
	
	return texture
end

-- Retrieves the texture icon
-- @return string Returns the texture icon
function HeadCount.Loot.prototype:retrieveTextureIcon() 
	local texture = self:getTexture()
	local icon = nil
	
	if (texture) then
		icon = select(3, string.find(texture, "^.*\\(.*)$"))
	else
		icon = "Interface\Icons\INV_Misc_QuestionMark"
	end
	
	return icon
end


-- Serialization method.
function HeadCount.Loot.prototype:Serialize() 
	local s = { }
	
	for k,v in pairs(self) do
		if type(v) ~= "function" and type(v) ~= "userdata" and k ~= "header" and k ~= "btnframe" and k ~= "temp" and k ~= "theme" and k ~= "base" and k ~= "curState" then
			s[k] = v
		end
	end
	
	return s
end

-- Deserialization method.
function HeadCount.Loot:Deserialize(t) 
	return self:new(t)
end

-- To String
-- @return string Returns the string description for this object.
function HeadCount.Loot.prototype:ToString()
	return L["object.Loot"]
end

AceLibrary:Register(HeadCount.Loot, "HeadCountLoot-1.0", 1)