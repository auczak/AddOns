--[[
Project name: HeadCount
Developed by: seppyk (http://www.authority-km.com)
Website: http://www.wowace.com/wiki/HeadCount
Description: Manages tracking of raid attendance and more.
License: Creative Common Attribution-NonCommercial-ShareAlike 3.0 Unported
File: BossEvent.lua
File description: Tracks boss event information.
]]

local AceOO = AceLibrary("AceOO-2.0")
local L = AceLibrary("AceLocale-2.2"):new("HeadCount")
local HeadCount = HeadCount

HeadCount.BossEvent = AceOO.Class()

HeadCount.BossEvent.prototype.bossList = nil
HeadCount.BossEvent.prototype.numberOfBosses = nil
HeadCount.BossEvent.prototype.isStarted = nil

-- Main constructor
function HeadCount.BossEvent.prototype:init()
    self.class.super.prototype.init(self)

	self.type = "HeadCountBossEvent-1.0"
	self.bossList = { }
	self.numberOfBosses = 0
	self.isStarted = false
end

-- Starts the boss event.
-- @param boss The boss table entry.
function HeadCount.BossEvent.prototype:addBoss(boss)
	local guid = boss["guid"]
	local bossName = boss["bossName"]
	local zone = boss["zone"]
	
	if (guid and bossName and zone) then 
		-- add or readd the boss to the boss list
		self.bossList[guid] = boss
		self.numberOfBosses = self.numberOfBosses + 1
		self.isStarted = true	-- event is started
	end
end

-- Determines if the boss event is complete
-- @return boolean Returns true if the boss event is complete and false otherwise.
function HeadCount.BossEvent.prototype:isEventComplete()
	local isComplete = false
	local numberOfDeadBosses = 0
	
	if ((self.isStarted) and (self.numberOfBosses > 0)) then
		-- boss event is started
		for k,v in pairs(self.bossList) do
			if (self:isBossDead(k)) then
				numberOfDeadBosses = numberOfDeadBosses + 1
			end
		end
		
		if (numberOfDeadBosses == self.numberOfBosses) then 
			-- All bosses in the boss list are dead, boss event is complete.
			isComplete = true
		end
	end
	
	return isComplete
end

-- Ends the boss event.
function HeadCount.BossEvent.prototype:endEvent() 
	if (self.isStarted) then 
		-- boss event is started
		self.bossList = { }	-- clear the boss list
		self.numberOfBosses = 0
		self.isStarted = false
	end
end

-- Retireves the boss by its name.
-- @param guid The boss guid
-- @return table Returns the boss.
function HeadCount.BossEvent.prototype:retrieveBoss(guid)
	local bossTable = nil
	
	if (self.bossList[guid]) then
		-- boss exists
		bossTable = self.bossList[guid]			
	end
	
	return boss
end

-- Determines if the boss is present.
-- @param guid The boss guid
-- @return boolean Returns true if the boss is present and false otherwise.
function HeadCount.BossEvent.prototype:isBossPresent(guid)
	local isPresent = false
	
	if (self.bossList[guid]) then 
		isPresent = true
	end
	
	return isPresent
end

-- Gets the boss name by its name
-- @param guid The boss guid
-- @return string Returns the boss name or nil if it does not exist
function HeadCount.BossEvent.prototype:getBossName(guid)
	local name = nil
	
	if (self.bossList[guid]) then 
		name = self.bossList[guid]["bossName"]
	end

	return name
end

-- Gets the boss zone by its name
-- @param guid The boss guid
-- @return string Returns the boss zone.
function HeadCount.BossEvent.prototype:getZone(guid)
	local zone = nil
	
	if (self.bossList[guid]) then 
		zone = self.bossList[guid]["zone"]
	end

	return zone
end

-- Sets the given boss to dead.
-- @param guid The boss guid
function HeadCount.BossEvent.prototype:setBossDead(guid)
	if (self.bossList[guid]) then 
		-- boss exists
		self.bossList[guid]["isDead"] = true	-- boss is dead
	end
end

-- Gets the boss alive status by its name
-- @param guid The boss guid
-- @return boolean Returns true if the boss is alive and false otherwise.
function HeadCount.BossEvent.prototype:isBossAlive(guid)
	local isAlive = false
	
	if (self.bossList[guid]) then 
		if (not self.bossList[guid]["isDead"]) then 
			-- boss is alive
			isAlive = true
		end
	end
	
	return isAlive
end

-- Gets the boss dead status by its name
-- @param guid The boss guid
-- @return boolean Returns true if the boss is dead and false otherwise.
function HeadCount.BossEvent.prototype:isBossDead(guid)
	local isDead = false
	
	if (self.bossList[guid]) then 
		if (self.bossList[guid]["isDead"]) then 
			-- boss is alive
			isDead = true
		end
	end
	
	return isDead
end

-- Gets the boss list
-- @return table Returns the boss list.
function HeadCount.BossEvent.prototype:getBossList()
	return self.bossList
end

-- Gets the event started status
-- @return boolean Returns true if the boss event is started and false otherwise.
function HeadCount.BossEvent.prototype:getIsStarted() 
	return self.isStarted
end

-- Retrieves the encounter name.
-- @return string Returns the encounter name.
function HeadCount.BossEvent.prototype:retrieveEncounterName() 
	local encounterName = nil
	
	for k,v in pairs(self.bossList) do
		local bossName = v["bossName"]	-- boss name
	
		encounterName = HeadCount:retrieveBossEncounterName(bossName)	
		break
	end	
		
	return encounterName
end

-- To String
-- @return string Returns the string description for this object.
function HeadCount.BossEvent.prototype:ToString()
	return L["object.Boss"]
end

AceLibrary:Register(HeadCount.BossEvent, "HeadCountBossEvent-1.0", 1)
