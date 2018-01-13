--[[
Project name: HeadCount
Developed by: seppyk (http://www.authority-km.com)
Website: http://www.wowace.com/wiki/HeadCount
Description: Manages tracking of raid attendance and more.
License: Creative Common Attribution-NonCommercial-ShareAlike 3.0 Unported
File: Boss.lua
File description: Boss object
]]

local AceOO = AceLibrary("AceOO-2.0")
local L = AceLibrary("AceLocale-2.2"):new("HeadCount")
local HeadCount = HeadCount

HeadCount.Boss = AceOO.Class()

HeadCount.Boss.prototype.name = nil
HeadCount.Boss.prototype.zone = nil
HeadCount.Boss.prototype.activityTime = nil
HeadCount.Boss.prototype.playerList = nil

-- Main constructor
function HeadCount.Boss.prototype:init(args)
    self.class.super.prototype.init(self)

	self.type = "HeadCountBoss-1.0"
	
	self.name = args["name"]
	self.zone = args["zone"]
	self.activityTime = args["activityTime"]
	self.playerList = args["playerList"]
end

-- Serialization method.
function HeadCount.Boss.prototype:Serialize() 
	local s = { }
	
	for k,v in pairs(self) do
		if type(v) ~= "function" and type(v) ~= "userdata" and k ~= "header" and k ~= "btnframe" and k ~= "temp" and k ~= "theme" and k ~= "base" and k ~= "curState" then
			s[k] = v
		end
	end
	
	return s
end

-- Gets the boss name
-- @return string Returns the boss name.
function HeadCount.Boss.prototype:getName()
	return self.name
end

-- Gets the boss zone
-- @return string Returns the boss zone.
function HeadCount.Boss.prototype:getZone()
	return self.zone
end

-- Gets the activity time.
-- @return object Returns the boss kill activity time.
function HeadCount.Boss.prototype:getActivityTime()
	return self.activityTime
end

-- Gets the player list.
-- @return table Returns the player list.
function HeadCount.Boss.prototype:getPlayerList()
	return self.playerList
end

-- Gets the total number of players present for this boss kill
-- @return number Returns the number of players.
function HeadCount.Boss.prototype:numberOfPlayers()
	local totalPlayers = 0
	
	if (self.playerList) then
		totalPlayers = # self.playerList
	end
	
	return totalPlayers
end

-- Deserialization method.
function HeadCount.Boss:Deserialize(t) 
	return self:new(t)
end

-- To String
-- @return string Returns the string description for this object.
function HeadCount.Boss.prototype:ToString()
	return L["object.Boss"]
end

AceLibrary:Register(HeadCount.Boss, "HeadCountBoss-1.0", 1)
