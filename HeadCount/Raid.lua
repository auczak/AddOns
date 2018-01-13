--[[
Project name: HeadCount
Developed by: seppyk (http://www.authority-km.com)
Website: http://www.wowace.com/wiki/HeadCount
Description: Manages tracking of raid attendance and more.
License: Creative Common Attribution-NonCommercial-ShareAlike 3.0 Unported
File: Raid.lua
File description: Raid object
]]

local AceOO = AceLibrary("AceOO-2.0")
local L = AceLibrary("AceLocale-2.2"):new("HeadCount")
local HeadCount = HeadCount

HeadCount.Raid = AceOO.Class()

HeadCount.Raid.prototype.playerList = nil
HeadCount.Raid.prototype.bossList = nil
HeadCount.Raid.prototype.lootList = nil
HeadCount.Raid.prototype.timeList = nil
HeadCount.Raid.prototype.raidTime = nil
HeadCount.Raid.prototype.lastActivityTime = nil
HeadCount.Raid.prototype.zone = nil
HeadCount.Raid.prototype.numberOfBosses = nil
HeadCount.Raid.prototype.numberOfPlayers = nil
HeadCount.Raid.prototype.isFinalized = nil

--function HeadCount.Raid.prototype:init(activityTime)
function HeadCount.Raid.prototype:init(args)
    self.class.super.prototype.init(self)

	self.type = "HeadCountRaid-1.0"
	self.playerList = args["playerList"]
	self.bossList = args["bossList"]
	self.lootList = args["lootList"]
	self.timeList = args["timeList"]
	self.raidTime = args["raidTime"]
	self.lastActivityTime = args["lastActivityTime"]
	self.zone = args["zone"]
	self.numberOfPlayers = args["numberOfPlayers"]
	self.numberOfBosses = args["numberOfBosses"]
	self.isFinalized = args["isFinalized"]
end

-- Adds a boss to the boss list
-- @param boss The boss to add to the boss list
function HeadCount.Raid.prototype:addBoss(boss)
	if (boss) then
		local name = boss:getName()
		
		if (not self:isBossPresent(name)) then
			-- boss is not present, add it
			self.bossList[name] = boss
			self.numberOfBosses = self.numberOfBosses + 1					
		end
	end
end

-- Removes a boss from the boss list.
-- @param bossName The boss name to remove from the boss list.
function HeadCount.Raid.prototype:removeBoss(bossName)
	local isPresent = self:isBossPresent(bossName)
	
	if (isPresent) then
		self.bossList[bossName] = nil
		self.numberOfBosses = self.numberOfBosses - 1
	end
end

-- Determines if a boss is present in the boss list
-- @param bossName The boss name to check for in the boss list.
-- @return boolean Returns true if the boss is present, false otherwise.
function HeadCount.Raid.prototype:isBossPresent(bossName)
	local isPresent = false

	if (self.bossList[bossName]) then
		isPresent = true
	end

	return isPresent
end

-- Retrieves a boss from the boss list.
-- @param bossName The boss name.
-- @return object Returns a boss from the boss list or nil if the player does not exist.
function HeadCount.Raid.prototype:retrieveBoss(bossName) 
	local boss = nil 
	local isPresent = self:isBossPresent(bossName)
	
	if (isPresent) then
		-- boss exists
		boss = self.bossList[bossName]
	end
	
	return boss
end

-- Adds a player to the player list
-- @param player The player to add to the player list
function HeadCount.Raid.prototype:addPlayer(player)
	if (player) then
		-- player exists
		local name = player:getName()
		
		if ((not self.playerList["raidgroup"][name]) and (not self.playerList["nogroup"][name])) then
			-- player is not in the player list
			local isPlayerInRaidList = player:getIsPresentInRaidList()
			local isPlayerInWaitList = player:getIsPresentInWaitList()
			if (isPlayerInRaidList or isPlayerInWaitList) then
				-- player is currently in the raid 
				self.playerList["raidgroup"][name] = player
			else
				-- player is currently NOT in the raid
				self.playerList["nogroup"][name] = player
			end
		
			self.numberOfPlayers = self.numberOfPlayers + 1	
		end
	end
end

-- Removes a player from the player list
-- @param playerName The player name to remove from the player list
function HeadCount.Raid.prototype:removePlayer(playerName)
	local isPresent, groupName = self:isPlayerPresent(playerName) 

	if (isPresent) then 
		-- player is being tracked, remove them
		self.playerList[groupName][playerName] = nil
		self.numberOfPlayers = self.numberOfPlayers - 1
	end
end

-- Retrieves an ordered boss list.
-- @return table Returns an ordered boss list.
function HeadCount.Raid.prototype:retrieveOrderedBossList() 
	-- Sort the player list by the given criteria
	local orderedBossList = {}
	
	for k,v in pairs(self.bossList) do
		table.insert(orderedBossList, v)
	end

	table.sort(orderedBossList, function(a, b) 
		local aActivityTime = a:getActivityTime()
		local bActivityTime = b:getActivityTime()

		if ((aActivityTime) and (aActivityTime)) then
			-- both a and b have valid activity times
			local aSeconds = aActivityTime:getUTCDateTimeInSeconds()
			local bSeconds = bActivityTime:getUTCDateTimeInSeconds()	
			
			return aSeconds < bSeconds
		end
	end)	

	return orderedBossList
end

-- Determines if a player is present in the player list
-- @param playerName The player name to check for in the player list.
-- @return boolean Returns true if the player is present, false otherwise.
function HeadCount.Raid.prototype:isPlayerPresent(playerName) 
	local isPresent = false
	local groupName = nil
	
	if (self.playerList["raidgroup"][playerName]) then 
		-- player is present in the raid group 
		isPresent = true
		groupName = "raidgroup"
	elseif (self.playerList["nogroup"][playerName]) then 
		-- player is present in the missing group 
		isPresent = true
		groupName = "nogroup"
	end
	
	return isPresent, groupName
end

-- Retrieves a player from the player list.
-- @param playerName The player name key.
-- @return object Returns a player from the player list or nil if the player does not exist.
function HeadCount.Raid.prototype:retrievePlayer(playerName) 
	local player = nil 
	local isPresent, groupName = self:isPlayerPresent(playerName)
	
	if (isPresent) then
		-- player exists
		player = self.playerList[groupName][playerName]
	end
	
	return player
end

-- Retrieves the player list by class
-- @return table Returns a player list table.
function HeadCount.Raid.prototype:retrievePlayerListByClass()
	local playerListByClass = {
		["Druid"] = {},  
		["Hunter"] = {},  
		["Mage"] = {},  
		["Paladin"] = {},  
		["Priest"] = {},  
		["Rogue"] = {},  
		["Shaman"] = {}, 
		["Warlock"] = {},  
		["Warrior"] = {}, 
	}

	for k,v in pairs(self.playerList) do 
		for i,j in pairs(self.playerList[k]) do 
			local playerName = j:getName() 
			local className = j:getClassName()
			if (L["Druid"] == className) then
				table.insert(playerListByClass["Druid"], playerName)
			elseif (L["Hunter"] == className) then
				table.insert(playerListByClass["Hunter"], playerName)
			elseif (L["Mage"] == className) then
				table.insert(playerListByClass["Mage"], playerName)
			elseif (L["Paladin"] == className) then
				table.insert(playerListByClass["Paladin"], playerName)
			elseif (L["Priest"] == className) then 
				table.insert(playerListByClass["Priest"], playerName)
			elseif (L["Rogue"] == className) then 
				table.insert(playerListByClass["Rogue"], playerName)			
			elseif (L["Shaman"] == className) then
				table.insert(playerListByClass["Shaman"], playerName)
			elseif (L["Warlock"] == className) then 
				table.insert(playerListByClass["Warlock"], playerName)
			else
				-- warrior
				table.insert(playerListByClass["Warrior"], playerName)
			end
		end		
	end
	
	return playerListByClass
end

-- Retrieves an ordered player list.
-- @param sortType The sort type.
-- @param isDescending The sort order.
-- @return table Returns an ordered player list.
function HeadCount.Raid.prototype:retrieveOrderedPlayerList(sortType, isDescending) 
	-- Sort the player list by the given criteria
	local orderedPlayerList = {}
	
	for k,v in pairs(self.playerList["raidgroup"]) do
		table.insert(orderedPlayerList, v)
	end

	for k,v in pairs(self.playerList["nogroup"]) do
		table.insert(orderedPlayerList, v)
	end
	
	local raidMemberSort = HeadCount:getRAID_MEMBER_SORT()
	
	if (raidMemberSort[sortType]) then
		-- sort type is valid
		if (raidMemberSort["Name"] == sortType) then
			self:sortPlayerListByName(orderedPlayerList, isDescending)
		elseif (raidMemberSort["Start"] == sortType) then 
			self:sortPlayerListByStartTime(orderedPlayerList, isDescending)
		elseif (raidMemberSort["End"] == sortType) then 
			self:sortPlayerListByEndTime(orderedPlayerList, isDescending)
		elseif (raidMemberSort["Total"] == sortType) then 
			if (self.isFinalized) then
				-- raid is finalized, sort by actual total time
				self:sortPlayerListByTotalTime(orderedPlayerList, isDescending, isFinalized)
			else
				-- raid is not finalized, sort by name
				self:sortPlayerListByName(orderedPlayerList, isDescending)			
			end
		end
	end
	
	return orderedPlayerList
end

-- Retrieves an ordered active player list from only the raid list group.
-- @return table Returns an ordered player list.
function HeadCount.Raid.prototype:retrieveOrderedRaidListNames()
	-- Sort the player list by the given criteria
	local orderedPlayerList = {}
	
	for k,v in pairs(self.playerList["raidgroup"]) do
		if (v:getIsPresentInRaidList()) then
			-- player is present in the raid list
			table.insert(orderedPlayerList, v:getName())
		end
	end

	table.sort(orderedPlayerList, function(a, b)
		return a < b
	end)
	
	return orderedPlayerList
end

-- Sorts a player list by name
-- @param orderedPlayerList The ordered player list.
-- @param isDescending The sort order.
-- @return table Returns the sorted player list by name
function HeadCount.Raid.prototype:sortPlayerListByName(orderedPlayerList, isDescending) 
	if (orderedPlayerList) then
		table.sort(orderedPlayerList, function(a, b) 
			local aName = a:getName()
			local bName = b:getName()
					
			if ((aName) and (bName)) then
				-- both a and b have valid names			
				if (isDescending) then
					return aName < bName
				else
					return aName > bName
				end
			else			
				HeadCount:LogError(string.format(L["error.sort.name"], L["product.name"]))
				return true
			end
		end)
	end 
end

-- Sorts a player list by start time
-- @param orderedPlayerList The ordered player list.
-- @param isDescending The sort order.
-- @return table Returns the sorted player list by start time.
function HeadCount.Raid.prototype:sortPlayerListByStartTime(orderedPlayerList, isDescending) 
	if (orderedPlayerList) then
		table.sort(orderedPlayerList, function(a, b) 
			local aBeginTime = a:retrieveStartingTime()
			local bBeginTime = b:retrieveStartingTime()

			if ((aBeginTime) and (bBeginTime)) then
				-- both a and b have valid end times
				local aSeconds = aBeginTime:getUTCDateTimeInSeconds()
				local bSeconds = bBeginTime:getUTCDateTimeInSeconds()	
				
				if (aSeconds ~= bSeconds) then		
					-- times are not equal
					if (isDescending) then
						return aSeconds < bSeconds
					else
						return aSeconds > bSeconds
					end
				else
					-- times are equivalent, sort by secondary value (player name)
					return a:getName() < b:getName()									
				end
			else
				if (aBeginTime) then 
					-- a has an end time, b does not
					if (isDescending) then 
						return true
					else
						return false
					end
				elseif (bBeginTime) then 
					-- b has an end time, a does not		
					if (isDescending) then 
						return false
					else
						return true
					end
				else
					-- neither a nor b have an end time, sort by secondary value (player name)
					return a:getName() < b:getName()
				end			
			end
		end)
	end 
end

-- Sorts a player list by end time
-- @param orderedPlayerList The ordered player list.
-- @param isDescending The sort order.
-- @return table Returns the sorted player list by end time.
function HeadCount.Raid.prototype:sortPlayerListByEndTime(orderedPlayerList, isDescending)
	if (orderedPlayerList) then
		table.sort(orderedPlayerList, function(a, b) 
			local aEndTime = a:retrieveEndingTime()
			local bEndTime = b:retrieveEndingTime()
			
			if ((aEndTime) and (bEndTime)) then
				-- both a and b have valid end times
				local aSeconds = aEndTime:getUTCDateTimeInSeconds()
				local bSeconds = bEndTime:getUTCDateTimeInSeconds()

				if (aSeconds ~= bSeconds) then		
					-- times are not equal
					if (isDescending) then
						return aSeconds < bSeconds
					else
						return aSeconds > bSeconds
					end
				else
					-- times are equivalent, sort by secondary value (player name)
					return a:getName() < b:getName()									
				end				
			else
				if (aEndTime) then 
					-- a has an end time, b does not
					if (isDescending) then 
						return true
					else
						return false
					end
				elseif (bEndTime) then 
					-- b has an end time, a does not		
					if (isDescending) then 
						return false
					else
						return true
					end
				else
					-- neither a nor b have an end time, sort by secondary value (player name)
					return a:getName() < b:getName()
				end
			end
		end)
	end
end

-- Sorts a player list by total time
-- @param orderedPlayerList The ordered player list.
-- @param isDescending The sort order.
-- @return table Returns the sorted player list by total time.
function HeadCount.Raid.prototype:sortPlayerListByTotalTime(orderedPlayerList, isDescending) 
	if (orderedPlayerList) then
		table.sort(orderedPlayerList, function(a, b) 
			local aTotalTime = a:getTotalTime()
			local bTotalTime = b:getTotalTime()
			
			if (aTotalTime ~= bTotalTime) then
				if (isDescending) then
					return aTotalTime < bTotalTime
				else
					return aTotalTime > bTotalTime
				end
			else
				return a:getName() < b:getName()
			end
		end)
	end		
end
			
-- Gets the number of players in the player list.
-- @return number Returns the number of players in the player list.
function HeadCount.Raid.prototype:getNumberOfPlayers() 
	return self.numberOfPlayers
end

-- Adds a loot to the loot list
-- @param loot The loot to add to the loot list
function HeadCount.Raid.prototype:addLoot(loot) 
	if (loot) then 
		table.insert(self.lootList, loot)
	end
end

-- Removes a loot from the loot list
-- @param lootId The loot id.
function HeadCount.Raid.prototype:removeLoot(lootId) 
	local numberOfLoots = # self.lootList
	
	if (self.lootList[lootId]) then
		-- the raid exists
		table.remove(self.lootList, lootId)	-- remove the raid
	end
end

-- Retrieves a piece of loot by its loot id.
-- @param lootId The loot id
-- @return object A loot object or nil if the given loot does not exist
function HeadCount.Raid.prototype:retrieveLoot(lootId)
	local loot = nil
	
	if (self.lootList[lootId]) then
		loot = self.lootList[lootId]
	end
	
	return loot
end

-- Determines the number of loots.
-- @return number Returns the number of loots.
function HeadCount.Raid.prototype:numberOfLoots() 
	return # self.lootList
end

-- Gets the player list.
-- @return table Returns the player list.
function HeadCount.Raid.prototype:getPlayerList()
	return self.playerList
end

-- Sets the player list.
-- @param playerList The player list
function HeadCount.Raid.prototype:setPlayerList(playerList)
	self.playerList = playerList
end

-- Gets the boss list.
-- @return table Returns the boss list.
function HeadCount.Raid.prototype:getBossList()
	return self.bossList
end

-- Sets the boss list.
-- @param bossList The boss list.
function HeadCount.Raid.prototype:setBossList(bossList) 
	self.bossList = bossList
end

-- Determines the number of bosses.
-- @return number Returns the number of loots.
function HeadCount.Raid.prototype:getNumberOfBosses()
	local totalBosses = 0
	
	if (self.numberOfBosses) then
		totalBosses = self.numberOfBosses
	end
	
	return totalBosses
end

-- Gets the loot list.
-- @return table Returns the loot list.
function HeadCount.Raid.prototype:getLootList()
	return self.lootList
end

-- Sets the loot list.
-- @param lootList The loot list
function HeadCount.Raid.prototype:setLootList(lootList)
	self.lootList = lootList
end

-- Gets the time list.
-- @return table Returns the time list.
function HeadCount.Raid.prototype:getTimeList()
	return self.timeList
end

-- Sets the time list.
-- @param timeList The time list
function HeadCount.Raid.prototype:setTimeList(timeList)
	self.timeList = timeList
end

-- Gets the raid time.
-- @return number Returns the raid time.
function HeadCount.Raid.prototype:getRaidTime() 
	return self.raidTime
end

-- Sets the raid time.
-- @param raidTime The raid time.
function HeadCount.Raid.prototype:setRaidTime(raidTime)
	self.raidTime = raidTime
end

-- Adds to the raid time.
-- @param numberOfSeconds
function HeadCount.Raid.prototype:addToRaidTime(numberOfSeconds) 
	self.raidTime = self.raidTime + numberOfSeconds
end

-- Gets the begin time for the raid.
-- @return object Returns the raid start time or nil if none exists
function HeadCount.Raid.prototype:retrieveStartingTime()
	return self.timeList[1]:getBeginTime()
end

-- Gets the end time for the raid.
-- @return number Returns the raid end time or nil if none exists
function HeadCount.Raid.prototype:retrieveEndingTime()
	local numberOfTimes = # self.timeList
	
	return self.timeList[numberOfTimes]:getEndTime()
end

-- Gets the last activity time.
-- @return number Returns the last activity time.
function HeadCount.Raid.prototype:getLastActivityTime()
	return self.lastActivityTime
end

-- Sets the last activity time.
-- @param lastActivityTime The last activity time.
function HeadCount.Raid.prototype:setLastActivityTime(lastActivityTime) 
	self.lastActivityTime = lastActivityTime
end

-- Gets the zone.
-- @return string Returns the zone name.
function HeadCount.Raid.prototype:getZone()
	return self.zone
end

-- Sets the zone.
-- @param zone The zone name.
function HeadCount.Raid.prototype:setZone(zone)
	self.zone = zone
end

-- Gets the finalized status.
-- @return boolean Returns the finalized status.
function HeadCount.Raid.prototype:getIsFinalized() 
	return self.isFinalized
end

-- Sets the finalized status.
-- @param isFinalized The finalized status
function HeadCount.Raid.prototype:setIsFinalized(isFinalized) 
	self.isFinalized = isFinalized 
end

-- Finalize a raid
-- @param currentTime The finalization time.
function HeadCount.Raid.prototype:finalize(currentTime) 
	if (not self.isFinalized) then
		-- finalize the player list
		for k,v in pairs(self.playerList["raidgroup"]) do 		
			self.playerList["raidgroup"][k]:finalize(currentTime)
		end

		for k,v in pairs(self.playerList["nogroup"]) do 		
			self.playerList["nogroup"][k]:finalize(currentTime)
		end
		
		-- Finalize the raid time
		local numberOfRaidTimePairs = # self.timeList
		local lastBeginTime = self.timeList[numberOfRaidTimePairs]:getBeginTime()
		local lastEndTime = self.timeList[numberOfRaidTimePairs]:getEndTime()
		if (not lastEndTime) then
			-- ending raid time is not yet set
			self.timeList[numberOfRaidTimePairs]:setEndTime(currentTime)
			
			local timeDifference = HeadCount:computeTimeDifference(currentTime, lastBeginTime)
			self:addToRaidTime(timeDifference)		
		end

		-- Add to the total raid time

		self.lastActivityTime = currentTime
		self.isFinalized = true
	end
end

-- Move a player to the raid group player list.
-- @param player The player
function HeadCount.Raid.prototype:moveToRaidGroup(player) 
	if (player) then
		local playerName = player:getName()		
		local isPresent, groupName = self:isPlayerPresent(playerName) 
		if ((isPresent) and ("nogroup" == groupName)) then 
			-- player is present  
			-- player is in no group, add to the raid group
			self.playerList[groupName][playerName] = nil 
			self.playerList["raidgroup"][playerName] = player
		else 
			-- player is not present, add him
			self:addPlayer(player)
		end
	end
end

-- Move a player to the no group player list.
-- @param player The player
function HeadCount.Raid.prototype:moveToNoGroup(player) 
	if (player) then 
		local playerName = player:getName() 
		local isPresent, groupName = self:isPlayerPresent(playerName) 
		if ((isPresent) and ("raidgroup" == groupName)) then 
			self.playerList[groupName][playerName] = nil 
			self.playerList["nogroup"][playerName] = player
		else 
			-- player is not present 
			self:addPlayer(player)
		end
	end
end

-- Process players who may have left the raid.
-- @param numberOfRaidMembers The number of members currently in the actual raid.
-- @param trackedPlayerList The list of members currently in the actual raid.
-- @param activityTime The activity time.
function HeadCount.Raid.prototype:processMissingPlayers(numberOfRaidMembers, trackedPlayerList, activityTime) 
	for k,v in pairs(self.playerList) do 
		for i,j in pairs(self.playerList[k]) do 
			local playerName = j:getName() 
			if ((not trackedPlayerList[playerName]) and (not j:getIsFinalized())) then 
				-- player is not currently in the actual raid and they haven't been finalized
				if (j:finalize(activityTime)) then 
					HeadCount:LogDebug(string.format(L["debug.raid.update.modifymember.leave"], L["product.name"], L["product.version.major"], L["product.version.minor"], playerName)) 
				end
			end
		end		
	end
end

-- Processes a begin time
-- @param activityTime The activity time.
-- @param note The note
function HeadCount.Raid.prototype:processBeginTime(activityTime, note) 
	if (activityTime) then
		local numberOfRaidTimePairs = # self.timeList	-- get the total number of current time pairs
		local lastBeginTime = self.timeList[numberOfRaidTimePairs]:getBeginTime()
		local lastEndTime = self.timeList[numberOfRaidTimePairs]:getEndTime()

		if ((lastBeginTime) and (lastEndTime)) then 
			-- both time values exist for the most recent pair, start a new pair
			local timePair = AceLibrary("HeadCountTimePair-1.0"):new({ ["beginTime"] = nil, ["endTime"] = nil, ["note"] = nil })	
			timePair:setBeginTime(activityTime) 
			timePair:setNote(note)
			table.insert(self.timeList, timePair)
		elseif ((not lastBeginTime) and (not lastEndTime)) then
			-- most recent pair contains no time values
			self.timeList[numberOfRaidTimePairs]:setBeginTime(activityTime)
			self.timeList[numberOfRaidTimePairs]:setNote(note)
		end
	end
end

-- Processes an end time
-- @param activityTime The activity time.
function HeadCount.Raid.prototype:processEndTime(activityTime) 
	if (activityTime) then
		local numberOfRaidTimePairs = # self.timeList	-- get the total number of current time pairs
		local lastBeginTime = self.timeList[numberOfRaidTimePairs]:getBeginTime()
		local lastEndTime = self.timeList[numberOfRaidTimePairs]:getEndTime()
		
		if ((lastBeginTime) and (not lastEndTime)) then
			-- the most recent beginning time exists
			-- no recent end time exists, add it
			self.timeList[numberOfRaidTimePairs]:setEndTime(activityTime)
		end		
	end
end

-- Recover from a fault.
-- @param activityTime The activity time.
function HeadCount.Raid.prototype:recover(activityTime) 
	for k,v in pairs(self.playerList) do 
		for i,j in pairs(self.playerList[k]) do 	
			local player = self.playerList[k][i]
			player:recover(activityTime, self.lastActivityTime)		
		end
	end
	
	local timeIndex = # self.timeList
	local lastBeginTime = self.timeList[timeIndex]:getBeginTime() 
	local lastEndTime = self.timeList[timeIndex]:getEndTime()
	
	if ((lastBeginTime) and (not lastEndTime)) then 
		local timeDifference = HeadCount:computeTimeDifference(self.lastActivityTime, lastBeginTime)	
		self:addToRaidTime(timeDifference)		
		self:processEndTime(self.lastActivityTime)
	end

	self:processBeginTime(activityTime, L["Recovery"])
	self:setLastActivityTime(activityTime)
	self:setIsFinalized(false)
end

-- Serialization method.
function HeadCount.Raid.prototype:Serialize() 
	local s = { }
	
	for k,v in pairs(self) do
		if type(v) ~= "function" and type(v) ~= "userdata" and k ~= "header" and k ~= "btnframe" and k ~= "temp" and k ~= "theme" and k ~= "base" and k ~= "curState" then
			s[k] = v
		end
	end
	
	return s
end

-- Deserialization method.
function HeadCount.Raid:Deserialize(t) 
	return self:new(t)
end

-- To String
-- @return string Returns the string description for this object.
function HeadCount.Raid.prototype:ToString()
	return L["object.Raid"]
end

AceLibrary:Register(HeadCount.Raid, "HeadCountRaid-1.0", 1)