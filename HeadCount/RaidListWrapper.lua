--[[
Project name: HeadCount
Developed by: seppyk (http://www.authority-km.com)
Website: http://www.wowace.com/wiki/HeadCount
Description: Manages tracking of raid attendance and more.
License: Creative Common Attribution-NonCommercial-ShareAlike 3.0 Unported
File: RaidListWrapper.lua
File description: Raid list wrapper object
]]

local AceOO = AceLibrary("AceOO-2.0")
local L = AceLibrary("AceLocale-2.2"):new("HeadCount")
local HeadCount = HeadCount

HeadCount.RaidListWrapper = AceOO.Class()

HeadCount.RaidListWrapper.prototype.raidList = nil				-- the raid list
HeadCount.RaidListWrapper.prototype.numberOfRaids = nil			-- number of raids

function HeadCount.RaidListWrapper.prototype:init(args)
    self.class.super.prototype.init(self)

	self.type = "HeadCountRaidListWrapper-1.0"
	self.raidList = args["raidList"]
	self.numberOfRaids = args["numberOfRaids"]
end

-- Retrieves the most recent raid.
-- @return object Returns the most recent raid or nil if none exists.
function HeadCount.RaidListWrapper.prototype:retrieveMostRecentRaid()
	local raid = nil

	local orderedRaidList = self:retrieveOrderedRaidList(true)
	local numberOfRaids = # orderedRaidList
	if (numberOfRaids > 0) then
		raid = orderedRaidList[numberOfRaids]		
	end
	
	return raid
end

function HeadCount.RaidListWrapper.prototype:retrieveMostRecentRaidId()
	local raidId = 0
	
	local raid = self:retrieveMostRecentRaid()
	if (raid) then
		raidId = raid:retrieveStartingTime():getUTCDateTimeInSeconds()
	end
	
	return raidId
end

-- Retrieves an ordered raid list.
-- @param isDescending The sort order.
-- @return table Returns an ordered raid list.
function HeadCount.RaidListWrapper.prototype:retrieveOrderedRaidList(isDescending) 
	local orderedRaidList = {}
	
	for k,v in pairs(self.raidList) do
		table.insert(orderedRaidList, v)
	end

	table.sort(orderedRaidList, function(a, b) 		
		local aKey = a:retrieveStartingTime():getUTCDateTimeInSeconds() 
		local bKey = b:retrieveStartingTime():getUTCDateTimeInSeconds() 
		
		if ((aKey) and (bKey)) then 
			if (isDescending) then
				return aKey < bKey
			else
				return bKey > aKey
			end		
		else
			HeadCount:LogError(string.format(L["error.sort.starttime"], L["product.name"]))
			return true
		end
	end)

	return orderedRaidList
end

-- Adds a raid.
-- @param raid The raid.
function HeadCount.RaidListWrapper.prototype:addRaid(id, raid) 
	if (id and raid) then 
		self.raidList[id] = raid
		self.numberOfRaids = self.numberOfRaids + 1
	end
end

-- Remove a raid.
-- @param id The raid id.
-- @return boolean Returns true if the raid was removed and false otherwise.
function HeadCount.RaidListWrapper.prototype:removeRaid(id)
	local isRemoved = false

	if (self.raidList[id]) then
		-- the raid exists
		self.raidList[id] = nil
		self.numberOfRaids = self.numberOfRaids - 1
		isRemoved = true
	end

	return isRemoved
end

-- Remove all raids
function HeadCount.RaidListWrapper.prototype:removeAll()
	self.raidList = { }	-- empty out and GC
	self.numberOfRaids = 0
end

-- Determines if a raid is present.
-- @param id The raid id.
-- @return boolean Returns true if the raid is present and false otherwise.
function HeadCount.RaidListWrapper.prototype:isRaidPresent(id) 
	local isPresent = false
	
	if (self.raidList[id]) then
		isPresent = true
	end
	
	return isPresent
end

-- Gets a raid by its id.
-- @param id The raid id.
-- @return object Returns the raid if it exists or nil otherwise.
function HeadCount.RaidListWrapper.prototype:getRaidById(id) 
	local raid = nil
	
	if (self.raidList[id]) then 
		raid = self.raidList[id]
	end
	
	return raid
end

-- Retrieves the total number of raids.
-- @return number Returns the total number of raids.
function HeadCount.RaidListWrapper.prototype:getNumberOfRaids() 
	return self.numberOfRaids
end

-- Gets the raid list.
-- @return table Returns the raid list.			
function HeadCount.RaidListWrapper.prototype:getRaidList() 
	return self.raidList
end

-- Sets the raid list.
-- @param raidList The raid list.
function HeadCount.RaidListWrapper.prototype:setRaidList(raidList) 
	self.raidList = raidList
end

-- Serialization method.
function HeadCount.RaidListWrapper.prototype:Serialize() 
	local s = { }
	
	for k,v in pairs(self) do
		if type(v) ~= "function" and type(v) ~= "userdata" and k ~= "header" and k ~= "btnframe" and k ~= "temp" and k ~= "theme" and k ~= "base" and k ~= "curState" then
			s[k] = v
		end
	end
	
	return s
end

-- Deserialization method.
function HeadCount.RaidListWrapper:Deserialize(t) 
	return self:new(t)
end

-- To String
-- @return string Returns the string description for this object.
function HeadCount.RaidListWrapper.prototype:ToString()
	return L["object.RaidListWrapper"]
end

AceLibrary:Register(HeadCount.RaidListWrapper, "HeadCountRaidListWrapper-1.0", 1)