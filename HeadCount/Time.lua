--[[
Project name: HeadCount
Developed by: seppyk (http://www.authority-km.com)
Website: http://www.wowace.com/wiki/HeadCount
Description: Manages tracking of raid attendance and more.
License: Creative Common Attribution-NonCommercial-ShareAlike 3.0 Unported
File: Time.lua
File description: Time object.
]]

local AceOO = AceLibrary("AceOO-2.0")
local L = AceLibrary("AceLocale-2.2"):new("HeadCount")
local HeadCount = HeadCount

HeadCount.Time = AceOO.Class()

HeadCount.Time.prototype.utcDateTimeInSeconds = nil

function HeadCount.Time.prototype:init(args)
	self.class.super.prototype.init(self)
    
	self.utcDateTimeInSeconds = args["utcDateTimeInSeconds"]
end

-- Gets the UTC date and time in seconds.
-- @return table Returns the UTC date and time in seconds.
function HeadCount.Time.prototype:getUTCDateTimeInSeconds() 
	return self.utcDateTimeInSeconds
end

-- Sets the UTC date and time in seconds.
-- @param utcDateTime The UTC date and time in seconds.
function HeadCount.Time.prototype:setUTCDateTimeInSeconds(utcDateTimeInSeconds) 
	self.utcDateTimeInSeconds = utcDateTimeInSeconds
end

-- Gets the month.
-- @return number Returns the month.
function HeadCount.Time.prototype:getMonth()
	local utcDateTime = date("*t", self.utcDateTimeInSeconds)
	
	return utcDateTime.month
end

-- Gets the day.
-- @return number Returns the day.
function HeadCount.Time.prototype:getDay()
	local utcDateTime = date("*t", self.utcDateTimeInSeconds)
	
	return utcDateTime.day
end

-- Gets the year.
-- @return number Returns the year.
function HeadCount.Time.prototype:getYear()
	local utcDateTime = date("*t", self.utcDateTimeInSeconds)
	
	return utcDateTime.year
end

-- Gets the hour.
-- @return number Returns the hour.
function HeadCount.Time.prototype:getHour()
	local utcDateTime = date("*t", self.utcDateTimeInSeconds)
	
	return utcDateTime.hour
end

-- Gets the minute.
-- @return number Returns the minute.
function HeadCount.Time.prototype:getMinute()
	local utcDateTime = date("*t", self.utcDateTimeInSeconds)
	
	return utcDateTime.min
end

-- Gets the second.
-- @return number Returns the second.
function HeadCount.Time.prototype:getSecond()
	local utcDateTime = date("*t", self.utcDateTimeInSeconds)
	
	return utcDateTime.sec
end

-- Serialization method.
function HeadCount.Time.prototype:Serialize() 
	local s = { }
	
	for k,v in pairs(self) do
		if type(v) ~= "function" and type(v) ~= "userdata" and k ~= "header" and k ~= "btnframe" and k ~= "temp" and k ~= "theme" and k ~= "base" and k ~= "curState" then
			s[k] = v
		end
	end
	
	return s
end

-- Deserialization method.
function HeadCount.Time:Deserialize(t) 
	return self:new(t)
end

-- To String
-- @return string Returns the string description for this object.
function HeadCount.Time.prototype:ToString()
	return L["object.Time"]
end

AceLibrary:Register(HeadCount.Time, "HeadCountTime-1.0", 1) 
