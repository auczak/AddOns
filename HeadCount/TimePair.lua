--[[
Project name: HeadCount
Developed by: seppyk (http://www.authority-km.com)
Website: http://www.wowace.com/wiki/HeadCount
Description: Manages tracking of raid attendance and more.
License: Creative Common Attribution-NonCommercial-ShareAlike 3.0 Unported
File: TimePair.lua
File description: A begin and ending time pair.
]]

local AceOO = AceLibrary("AceOO-2.0")
local L = AceLibrary("AceLocale-2.2"):new("HeadCount")
local HeadCount = HeadCount

HeadCount.TimePair = AceOO.Class()

HeadCount.TimePair.prototype.beginTime = nil
HeadCount.TimePair.prototype.endTime = nil
HeadCount.TimePair.prototype.note = nil

function HeadCount.TimePair.prototype:init(args)
	self.class.super.prototype.init(self)
	
	self.type = "HeadCountTimePair-1.0"
	self.beginTime = args["beginTime"]
	self.endTime = args["endTime"]
	self.note = args["note"]
end

-- Gets the begin time.
-- @return number Returns the begin time.
function HeadCount.TimePair.prototype:getBeginTime() 
	return self.beginTime
end

-- Sets the begin time.
-- @param beginTime The begin time.
function HeadCount.TimePair.prototype:setBeginTime(beginTime)
	self.beginTime = beginTime
end

-- Gets the end time.
-- @return number Returns the end time.
function HeadCount.TimePair.prototype:getEndTime() 
	return self.endTime
end

-- Sets the end time.
-- @param endTime The begin time.
function HeadCount.TimePair.prototype:setEndTime(endTime)
	self.endTime = endTime
end

-- Gets the note.
-- @return string Returns the note
function HeadCount.TimePair.prototype:getNote() 
	return self.note
end

-- Sets the note.
-- @param note The note.
function HeadCount.TimePair.prototype:setNote(note) 
	self.note = note
end

-- Serialization method.
function HeadCount.TimePair.prototype:Serialize() 
	local s = { }
	
	for k,v in pairs(self) do
		if type(v) ~= "function" and type(v) ~= "userdata" and k ~= "header" and k ~= "btnframe" and k ~= "temp" and k ~= "theme" and k ~= "base" and k ~= "curState" then
			s[k] = v
		end
	end
	
	return s
end

-- Deserialization method.
function HeadCount.TimePair:Deserialize(t) 
	return self:new(t)
end

-- To String
-- @return string Returns the string description for this object.
function HeadCount.TimePair.prototype:ToString()
	return L["object.TimePair"]
end

AceLibrary:Register(HeadCount.TimePair, "HeadCountTimePair-1.0", 1) 