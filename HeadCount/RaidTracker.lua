--[[
Project name: HeadCount
Developed by: seppyk (http://www.authority-km.com)
Website: http://www.wowace.com/wiki/HeadCount
Description: Manages tracking of raid attendance and more.
License: Creative Common Attribution-NonCommercial-ShareAlike 3.0 Unported
File: RaidTracker.lua
File description: Tracks raids.
]]

local AceOO = AceLibrary("AceOO-2.0")
local L = AceLibrary("AceLocale-2.2"):new("HeadCount")
local HeadCount = HeadCount

HeadCount.RaidTracker = AceOO.Class()

-- Current session variables
HeadCount.RaidTracker.prototype.isEnabled = nil				-- true if the raid tracker is enabled, false otherwise
HeadCount.RaidTracker.prototype.isCurrentRaidActive = nil	-- true if the current raid is active, false otherwise
HeadCount.RaidTracker.prototype.currentBossEvent = nil		-- the current boss encounter or nil if no boss encounter is active

-- Saved variables
HeadCount.RaidTracker.prototype.raidListWrapper = nil		-- the raid list wrapper

function HeadCount.RaidTracker.prototype:init(raidListWrapper)
    HeadCount.RaidTracker.super.prototype.init(self)
	
	self.isEnabled = true
	self.isCurrentRaidActive = false 
	self.currentBossEvent = AceLibrary("HeadCountBossEvent-1.0"):new()	-- initialize the boss event
	
	if (raidListWrapper) then 
		self.raidListWrapper = raidListWrapper 
	else
		self.raidListWrapper = AceLibrary("HeadCountRaidListWrapper-1.0"):new({ ["raidList"] = { }, ["numberOfRaids"] = 0 })	-- create an online player, starting in no list
	end
end

-- Saves the raid list to the db profile
function HeadCount.RaidTracker.prototype:saveRaidListWrapper() 
	HeadCount:SetRaidListWrapper(self.raidListWrapper)
end

-- Process recovery for the raid tracker
function HeadCount.RaidTracker.prototype:recover() 
	local raid = self:retrieveMostRecentRaid() 	
	if (raid) then 
		local isRaidFinalized = raid:getIsFinalized() 
		local isUnitInRaid = UnitInRaid("player")	
		
		local utcDateTimeInSeconds = HeadCount:getUTCDateTimeInSeconds()
		local activityTime = AceLibrary("HeadCountTime-1.0"):new({ ["utcDateTimeInSeconds"] = utcDateTimeInSeconds })
		
		if (isUnitInRaid) then 
			-- owner is present in raid
			if (isRaidFinalized) then 
				-- most recent raid is finalized
				HeadCount:LogDebug(string.format(L["debug.raidtracker.setup.raid.final"], L["product.name"], L["product.version.major"], L["product.version.minor"]))
				self.isCurrentRaidActive = false				
			else
				-- most recent raid is NOT finalized
				HeadCount:LogDebug(string.format(L["debug.raidtracker.setup.raid.nofinal"], L["product.name"], L["product.version.major"], L["product.version.minor"]))
				raid:recover(activityTime)
				self.isCurrentRaidActive = true
				
				-- Set proper events for recovered raid
				HeadCount:addEvent("PLAYER_REGEN_DISABLED")	-- add player combat event handling for boss kill tracking			
				HeadCount:removeEvent("PLAYER_REGEN_ENABLED")
				HeadCount:removeEvent("COMBAT_LOG_EVENT_UNFILTERED")
			end
		else
			-- owner is NOT present in raid
			if (isRaidFinalized) then 
				-- most recent raid is finalized
				HeadCount:LogDebug(string.format(L["debug.raidtracker.setup.noraid.final"], L["product.name"], L["product.version.major"], L["product.version.minor"]))
				self.isCurrentRaidActive = false							
			else
				-- most recent raid is NOT finalized
				HeadCount:LogDebug(string.format(L["debug.raidtracker.setup.noraid.nofinal"], L["product.name"], L["product.version.major"], L["product.version.minor"]))
				raid:finalize(activityTime)
				self.isCurrentRaidActive = false						
			end		
		end		
	else
		--HeadCount:LogInformation("The most recent raid does not exist.")
	end	
end

-- Determines if the current raid is endable
-- @return boolean Returns true if the current raid can be ended, false otherwise.
function HeadCount.RaidTracker.prototype:isCurrentRaidEndable()
	local isEndable = false

	local numberOfRaids = self.raidListWrapper:getNumberOfRaids()
	if ((self.isCurrentRaidActive) and (numberOfRaids > 0)) then
		-- raids exist and there is a current raid active
		isEndable = true
	end	
	
	return isEndable
end

-- Ends the current active raid if it exists
-- @param activityTime The activity time.
function HeadCount.RaidTracker.prototype:endCurrentRaid(activityTime)
	if ((activityTime) and (self.isCurrentRaidActive)) then
		-- end the currently active raid
		local currentRaid = self:retrieveMostRecentRaid()
	
		if (currentRaid) then	
			-- No raid is active, kill all boss tracking events
			HeadCount:removeEvent("PLAYER_REGEN_DISABLED")		-- disable player enter combat event
			HeadCount:removeEvent("PLAYER_REGEN_ENABLED")			-- enable player leave combat event	
			HeadCount:removeEvent("COMBAT_LOG_EVENT_UNFILTERED")	-- add combat log event					
				
			-- finalize the current raid
			currentRaid:finalize(activityTime)			
			self:setIsCurrentRaidActive(false)	
			
			-- no raid is active, clean up boss events
			self.currentBossEvent:endEvent()
		end
	end
end

-- Remove a raid.
-- @param id The raid id.
function HeadCount.RaidTracker.prototype:removeRaid(id)
	local isPresent = self.raidListWrapper:isRaidPresent(id)

	if (isPresent) then 
		-- raid is present and raid
		local raid = self.raidListWrapper:getRaidById(id)
		if ((not raid:getIsFinalized()) and (self.isCurrentRaidActive)) then		
			-- raid is not finalized, raid is active
			
			-- No raid is active, kill all boss tracking events
			HeadCount:removeEvent("PLAYER_REGEN_DISABLED")		-- disable player enter combat event
			HeadCount:removeEvent("PLAYER_REGEN_ENABLED")			-- enable player leave combat event	
			HeadCount:removeEvent("COMBAT_LOG_EVENT_UNFILTERED")	-- add combat log event					
			
			self.isCurrentRaidActive = false	-- no current raid			
			
			-- current raid is no longer active, cleanup boss event
			self.currentBossEvent:endEvent()
		end
		
		self.raidListWrapper:removeRaid(id)
	end
end

-- Remove all raids.
function HeadCount.RaidTracker.prototype:removeAllRaids() 
	-- No raid is active, kill all boss tracking events
	HeadCount:removeEvent("PLAYER_REGEN_DISABLED")		-- disable player enter combat event
	HeadCount:removeEvent("PLAYER_REGEN_ENABLED")			-- enable player leave combat event	
	HeadCount:removeEvent("COMBAT_LOG_EVENT_UNFILTERED")	-- add combat log event					
				
	self.isCurrentRaidActive = false
	self.raidListWrapper:removeAll()
	
	-- cleanup boss events
	self.currentBossEvent:endEvent()
end

-- Removes a player from a given raid.
-- @param id The raid id.
-- @param playerName The player name.
function HeadCount.RaidTracker.prototype:removePlayer(id, playerName)
	local raid = self.raidListWrapper:getRaidById(id) 	
	if (raid) then
		-- raid exists
		raid:removePlayer(playerName)
	end
end

-- Removes a boss from a given raid.
-- @param id The raid id.
-- @param bossName The boss name.
function HeadCount.RaidTracker.prototype:removeBoss(id, bossName)
	local raid = self.raidListWrapper:getRaidById(id)
	if (raid) then 
		-- raid exist
		raid:removeBoss(bossName)
	end
end

-- Removes loot from a given raid.
-- @param raidId The raid id.
-- @param lootId The loot id.
function HeadCount.RaidTracker.prototype:removeLoot(raidId, lootId) 
	local raid = self.raidListWrapper:getRaidById(raidId)
	if (raid) then 
		-- raid exists
		raid:removeLoot(lootId)
	end
end

-- Gets the current enabled status
-- @return boolean Return true if the raid tracker is enabled and false otherwise
function HeadCount.RaidTracker.prototype:getIsEnabled()
	return self.isEnabled
end

-- Sets the current enabled status
-- @param isEnabled The raid tracker enabled status
function HeadCount.RaidTracker.prototype:setIsEnabled(isEnabled)
	self.isEnabled = isEnabled
end

-- Gets the current active raid status
-- @return boolean Returns true if the current raid is active, false otherwise.
function HeadCount.RaidTracker.prototype:getIsCurrentRaidActive()
	return self.isCurrentRaidActive
end

-- Sets the current active raid status
-- @param isCurrentRaidActive The current active raid status
function HeadCount.RaidTracker.prototype:setIsCurrentRaidActive(isCurrentRaidActive) 
	self.isCurrentRaidActive = isCurrentRaidActive
end

-- Retrieves the most recent raid.
-- @return object Returns the most recently added raid or nil if none exists.
function HeadCount.RaidTracker.prototype:retrieveMostRecentRaid() 	
	local raid = self.raidListWrapper:retrieveMostRecentRaid()
	
	return raid
end

-- Retrieves the current raid id.
-- @return number Returns the current raid id
function HeadCount.RaidTracker.prototype:retrieveCurrentRaidId()
	local raidId = self.raidListWrapper:retrieveMostRecentRaidId()

	return raidId
end

-- Retrieves the ordered raid list.
-- @return table Returns the ordered raid list
function HeadCount.RaidTracker.prototype:retrieveOrderedRaidList(isDescending)	 
	local orderedRaidList = self.raidListWrapper:retrieveOrderedRaidList(isDescending) 
	
	return orderedRaidList
end

-- Sets the current raid
-- @param raid The current raid.
function HeadCount.RaidTracker.prototype:addRaid(raid) 
	local raidStartTime = raid:retrieveStartingTime():getUTCDateTimeInSeconds()
	self.raidListWrapper:addRaid(raidStartTime, raid)
end

-- Gets the number of raids
-- @return number Returns the number of raids
function HeadCount.RaidTracker.prototype:getNumberOfRaids()
	return self.raidListWrapper:getNumberOfRaids()
end

-- Gets the raid list wrapper.
-- @return object Returns the raid list wrapper.
function HeadCount.RaidTracker.prototype:getRaidListWrapper()
	return self.raidListWrapper
end

-- Gets a given raid by its id.
-- @param id The raid id.
-- @return object Returns the given raid or nil if none exists.
function HeadCount.RaidTracker.prototype:getRaidById(id) 
	return self.raidListWrapper:getRaidById(id)
end

-- Retrieve the current active raid or creates a new raid if no current raid exists.
-- @param activityTime The activity time.
-- @return object Returns the current raid.
function HeadCount.RaidTracker.prototype:retrieveCurrentRaid(activityTime) 
	local currentRaid = nil
	local isNewRaid = false
	
	if (self.isCurrentRaidActive) then
		-- a raid currently exists, process existing raid
		currentRaid = self:retrieveMostRecentRaid()
		isNewRaid = false		
	else
		-- a raid does not already exist, create a new raid, then process it
		local args = {
			["playerList"] = {
				["raidgroup"] = { }, 
				["nogroup"] = { }, 
			}, 
			["bossList"] = { }, 
			["lootList"] = { }, 
			["timeList"] = { }, 
			["raidTime"] = 0, 
			["lastActivityTime"] = activityTime, 
			["zone"] = nil, 
			["numberOfPlayers"] = 0, 
			["numberOfBosses"] = 0, 
			["isFinalized"] = false
		}

		local timePair = AceLibrary("HeadCountTimePair-1.0"):new({ ["beginTime"] = nil, ["endTime"] = nil, ["note"] = nil })			
		timePair:setBeginTime(activityTime)
		table.insert(args["timeList"], timePair)	-- insert the first time pair (includes begin time with no end time)		
		
		currentRaid = AceLibrary("HeadCountRaid-1.0"):new(args)			
		self:setIsCurrentRaidActive(true)
		self:addRaid(currentRaid)
		isNewRaid = true
		HeadCount:LogInformation(string.format(L["info.newraid"], L["product.name"], L["product.version.major"], L["product.version.minor"], HeadCount:getDateTimeAsString(currentRaid:getLastActivityTime())))			
		
		-- Set proper events for new raid (not currently in combat)
		HeadCount:addEvent("PLAYER_REGEN_DISABLED")	-- add player combat event handling for boss kill tracking			
		HeadCount:removeEvent("PLAYER_REGEN_ENABLED")
		HeadCount:removeEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
	
	return currentRaid, isNewRaid 
end

-- Process the current tracking status
-- @param zone The zone name.
function HeadCount.RaidTracker.prototype:processStatus(zone)
	assert(zone, "Unable to determine battleground status because the zone is nil.")
	
	if ((not HeadCount:IsBattlegroundTrackingEnabled()) and (HeadCount:isBattlegroundZone(zone))) then 	
		-- battleground tracking is disabled and current zone is a battleground
		if (self.isEnabled) then 
			HeadCount:LogDebug(string.format(L["debug.status.battleground.enter"], L["product.name"], L["product.version.major"], L["product.version.minor"], zone))
			self.isEnabled = false
		end		
	else
		-- battleground tracking is enabled or zone is not a battleground
		if (not self.isEnabled) then 		
			HeadCount:LogDebug(string.format(L["debug.status.battleground.leave"], L["product.name"], L["product.version.major"], L["product.version.minor"]))
			
			--[[
			local inInstance, instanceType = IsInInstance()	
			HeadCount:LogDebug("Zone: " .. zone)
			if (inInstance) then
				HeadCount:LogDebug("In instance: true")
			else
				HeadCount:LogDebug("In instance: false")
			end
		
			if (instanceType) then 
				HeadCount:LogDebug("Instance type: " .. instanceType)
			end
			--]]
			
			self.isEnabled = true
		end		
	end
end

-- Process a zone change.
-- @return string Returns the current zone name
function HeadCount.RaidTracker.prototype:processZoneChange() 
	local zone = GetRealZoneText() 

	-- update the status
	self:processStatus(zone)
	
	if (self.isEnabled) then
		-- check if the current zone is a valid raid instance zone
		self:processRaidZone(zone)
	end
	
	return zone
end

-- Processes the current raid zone.
-- If the current raid has no raid zone assigned to it, set the raid zone name.
-- @param zone The zone name.
function HeadCount.RaidTracker.prototype:processRaidZone(zone)
	if ((HeadCount:isRaidInstance()) and (self.isCurrentRaidActive)) then
		-- player is in a raid instance and a tracked raid is active
		local currentRaid = self:retrieveMostRecentRaid()
		if (not currentRaid:getZone()) then
			-- current raid zone is not set
			if (L.raidInstances[zone]) then
				currentRaid:setZone(L.raidInstances[zone])
				self:saveRaidListWrapper()	-- save the raid list
			end
		end
	end
end

-- Processing a loot update. 
-- LOOT_ITEM: %s receives loot: %s.
-- LOOT_ITEM_MULTIPLE: %s receives loot: %sx%d.
-- LOOT_ITEM_SELF: You receive loot: %s.
-- LOOT_ITEM_SELF_MULTIPLE: You receive loot: %sx%d.
-- @param message The loot message.
-- @return boolean Returns true if a boss kill or loot was successfully processed and false otherwise.
function HeadCount.RaidTracker.prototype:processLootUpdate(message) 
	local isProcessed = false

	if (self.isCurrentRaidActive) then 
		-- current raid is active
		local playerName, item, quantity = self:processLootPattern(message) 
		if (playerName) then 
			-- message matched proper loot pattern 
			local utcDateTimeInSeconds = HeadCount:getUTCDateTimeInSeconds()
			local activityTime = AceLibrary("HeadCountTime-1.0"):new({ ["utcDateTimeInSeconds"] = utcDateTimeInSeconds })	

			-- Process the loot source if it is a new boss encounter
			local isBoss, lootSource = self:processLootSource()
			local encounterName = HeadCount:retrieveBossEncounterName(lootSource)								
			
			local isBossKillProcessed = false
			if (isBoss) then
				-- loot source is valid and is a raid boss, process it for possible boss kill
				local zone = GetRealZoneText()
				isBossKillProcessed = self:addBossKill(encounterName, zone, activityTime)								
			end
			
			-- Process the loot
			local isLootProcessed = self:processLoot(playerName, item, quantity, activityTime, encounterName)
			
			isProcessed = (isBossKillProcessed or isLootProcessed)
		end
	end
	
	return isProcessed
end

-- Process the loot source
-- @return isBoss Returns if the loot source is a boss
-- @return lootSource Returns the loot source (mob name)
function HeadCount.RaidTracker.prototype:processLootSource()
	local isBoss = false
	local lootSource = HeadCount.DEFAULT_LOOT_SOURCE

	local numberOfRaidMembers = GetNumRaidMembers()
	for i = 1, numberOfRaidMembers do
		-- Raid target
		local unit = "raid" .. i .. "target"
		if (self:isBossUnitDead(unit)) then
			isBoss = true
			lootSource = UnitName(unit)
			break
		end			
	end		
	
	return isBoss, lootSource
end

-- Processing a loot
-- @param playerName The player name.
-- @param item The item string
-- @param quantity The loot quantity
-- @param activityTime The activity time.
-- @param source The loot source
-- @return boolean Returns true if loot was processed and false otherwise
function HeadCount.RaidTracker.prototype:processLoot(playerName, item, quantity, activityTime, source)
	local isProcessed = false
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(item) 
	
	local minimumLootQuality = L.itemQualityNumbers[HeadCount:GetMinimumLootQuality()] 
	local id = string.match(itemLink, "item:(%d+):")
	local numberId = tonumber(id)
	local exclusionList = HeadCount:GetExclusionList()
	if ((itemRarity >= minimumLootQuality) and (not exclusionList[numberId])) then 
		-- item dropped is greater than or equal to minimum loot quality and the item is not excluded, track it!  
		local realZoneText = GetRealZoneText()
		
		local itemId = AceLibrary("HeadCountLoot-1.0"):retrieveItemId(itemLink)	-- get the item id
		local loot = AceLibrary("HeadCountLoot-1.0"):new({ ["itemId"] = itemId, ["playerName"] = playerName, ["cost"] = 0, ["activityTime"] = activityTime, ["quantity"] = quantity, ["zone"] = realZoneText, ["source"] = source })
		local currentRaid = self:retrieveMostRecentRaid()
		
		-- Add this loot to the raid
		currentRaid:addLoot(loot)				
		
		-- Should we broadcast this loot to guild chat?
		if (HeadCount:IsLootBroadcastEnabled()) then
			-- player is in a guild and loot broadcasting is enabled, broadcast to the guild!
			HeadCount:LogGuild(string.format(L["guild.broadcast.loot"], playerName, itemLink, source))
		end

		-- Should the loot management popup window show?
		if (HeadCount:IsLootPopupEnabled()) then
			-- loot popup window should show			
			local raidId = currentRaid:retrieveStartingTime():getUTCDateTimeInSeconds()
			local lootId = currentRaid:numberOfLoots()
			HeadCount:HeadCountFrameLootManagementPopup_Show(raidId, lootId)
		end
		
		isProcessed = true
	end
	
	return isProcessed
end

-- Processes a loot message pattern
-- @param message The loot message.
-- @return string, string, number  Returns the player name, item name, and quantity or nil if the message does not match any pattern
function HeadCount.RaidTracker.prototype:processLootPattern(message) 
	local playerName = nil
	local item = nil
	local quantity = nil
	
	local multipleLootSelfRegex = HeadCount:getMULTIPLE_LOOT_SELF_REGEX()
	local lootSelfRegex = HeadCount:getLOOT_SELF_REGEX()
	local multipleLootRegex = HeadCount:getMULTIPLE_LOOT_REGEX() 
	local lootRegex = HeadCount:getLOOT_REGEX() 	
	
	if (message:match(multipleLootSelfRegex)) then 
		item, quantity = message:match(multipleLootSelfRegex) 
		playerName = UnitName("player") 
		--HeadCount:LogInformation("MULTIPLE SELF LOOT: " .. playerName .. " received loot " .. item .. "x" .. quantity)
	elseif (message:match(lootSelfRegex)) then 
		item = message:match(lootSelfRegex) 
		playerName = UnitName("player") 
		quantity = 1
		--HeadCount:LogInformation("SELF LOOT: " .. playerName .. " received loot " .. item)		
	elseif (message:match(multipleLootRegex)) then 
		playerName, item, quantity = message:match(multipleLootRegex) 
		--HeadCount:LogInformation("MULTIPLE LOOT: " .. playerName .. " received loot " .. item .. "x" .. quantity)
	elseif (message:match(lootRegex)) then 
		playerName, item = message:match(lootRegex) 
		quantity = 1
		--HeadCount:LogInformation("LOOT: " .. playerName .. " received loot " .. item) 		
	else
		--HeadCount:LogInformation("The loot message did not match any pattern.")
	end	
	
	return playerName, item, quantity
end

-- Add a boss kill.
-- @param encounterName The boss encounter name.
-- @param zone The zone name.
-- @param activityTime The boss kill time.
-- @return boolean Returns true if a boss kill was processed and false otherwise
function HeadCount.RaidTracker.prototype:addBossKill(encounterName, zone, activityTime)	
	local isProcessed = false
	local currentRaid = self:retrieveMostRecentRaid()
	if (not currentRaid:isBossPresent(encounterName)) then
		HeadCount:LogDebug(string.format(L["debug.boss.kill.complete"], L["product.name"], L["product.version.major"], L["product.version.minor"], encounterName))		
						
		self:processAttendance(activityTime)	-- update attendance
		
		local playerList = currentRaid:retrieveOrderedRaidListNames()		
		
		local args = {
			["name"] = encounterName, 
			["zone"] = zone, 
			["activityTime"] = activityTime, 
			["playerList"] = playerList
		}
			
		local boss = AceLibrary("HeadCountBoss-1.0"):new(args)									
			
		currentRaid:addBoss(boss)

		-- Should we broadcast this to guild chat?
		if (HeadCount:IsBossBroadcastEnabled()) then
			-- boss kill broadcasting is enabled
			HeadCount:LogGuild(string.format(L["guild.broadcast.bosskill"], encounterName))			
		end
		
		HeadCount:HeadCountFrame_Update()		-- update the UI			
		
		isProcessed = true
	end
	
	return isProcessed
end

-- Determines if the given unit is dead and a boss.
-- @param unit The unit.
-- @return boolean Returns true if the unit is a dead boss and false otherwise.
function HeadCount.RaidTracker.prototype:isBossUnitDead(unit)
	local isValid = false
	
	if (unit) then
		if ((UnitExists(unit)) and (UnitIsDead(unit))) then
			-- unit exists and unit is dead
			local unitName = UnitName(unit)
			if ((UnitClassification(unit) == "worldboss") and (not L.ignoreBossList[unitName])) then
				isValid = true
			end
		end	
	end
	
	return isValid
end

-------------------------------
-- ATTENDANCE TRACKING
-------------------------------
-- Process an attendance update
-- @param activityTime The current activity time.
function HeadCount.RaidTracker.prototype:processAttendance(activityTime)	
	assert(activityTime, "Unable to update attendance because the activity time is nil.")

	-- Get the current zone
	local zone = GetRealZoneText()
	
	-- update the status
	self:processStatus(zone)
	
	if (self.isEnabled) then 
		-- raid tracking is enabled
		--local utcDateTimeInSeconds = HeadCount:getUTCDateTimeInSeconds()
		--local activityTime = AceLibrary("HeadCountTime-1.0"):new({ ["utcDateTimeInSeconds"] = utcDateTimeInSeconds })
		
		if (UnitInRaid("player")) then 
			-- player is in a raid		
			local currentRaid, isNewRaid = self:retrieveCurrentRaid(activityTime)	-- retrieve the current raid or create a new raid 
			if (isNewRaid) then
				-- new raid
				HeadCount:DisableModalFrame() 	-- disable all modal frames
				
				if (UnitAffectingCombat("player")) then 
					HeadCount:PLAYER_REGEN_DISABLED()	-- call the combat event immediately
				end
			end
					
			self:processRaidZone(zone)	-- Assign zone if current raid does not have a zone assigned
			
			-- Update each member in the raid group 
			local numberOfRaidMembers = GetNumRaidMembers()
			if (numberOfRaidMembers > 0) then
				-- active in a raid		

				local trackedPlayerList = { } 
				for i = 1,numberOfRaidMembers do
					local name, rank, subgroup, level, className, fileName, zone, isOnline, isDead, role, isML = GetRaidRosterInfo(i)
					
					-- self:debugRosterMember(name, rank, subgroup, level, className, fileName, zone, isOnline, isDead, role, isML)
					if (currentRaid:isPlayerPresent(name)) then 
						-- player is already present in the player list (existing player)
						local player = currentRaid:retrievePlayer(name)
						local timeDifference = HeadCount:computeTimeDifference(activityTime, player:getLastActivityTime())					
						local moveResult
						
						if (isOnline) then
							-- CURRENT: Player is online	
							local isPresentInRaidList = HeadCount:isRaidListGroup(subgroup)					
							local isPresentInWaitList = HeadCount:isWaitListGroup(subgroup)
							
							if (isPresentInRaidList) then
								-- CURRENT: Player is in the raid list.
								moveResult = player:moveToRaidList(activityTime)
								if (moveResult) then 
									currentRaid:moveToRaidGroup(player)
									HeadCount:LogDebug(string.format(L["debug.raid.update.modifymember.raidlist"], L["product.name"], L["product.version.major"], L["product.version.minor"], name))
								end
							elseif (isPresentInWaitList) then
								-- CURRENT: Player is in the wait list.
								moveResult = player:moveToWaitList(activityTime)
								if (moveResult) then 
									currentRaid:moveToRaidGroup(player)
									HeadCount:LogDebug(string.format(L["debug.raid.update.modifymember.waitlist"], L["product.name"], L["product.version.major"], L["product.version.minor"], name)) 
								end
							else
								moveResult = player:moveToNoList(activityTime, true)
								if (moveResult) then 
									currentRaid:moveToNoGroup(player)
									HeadCount:LogDebug(string.format(L["debug.raid.update.modifymember.nolist"], L["product.name"], L["product.version.major"], L["product.version.minor"], name)) 
								end
							end
						else
							-- CURRENT: Player is offline 
							moveResult = player:moveToNoList(activityTime, false)
							if (moveResult) then 							
								currentRaid:moveToNoGroup(player)						
								HeadCount:LogDebug(string.format(L["debug.raid.update.modifymember.offline"], L["product.name"], L["product.version.major"], L["product.version.minor"], name))																										
							end
						end
						
						player:updateValues(i)	-- update player values if needed
					else
						-- CREATE NEW PLAYER
						-- player is NOT present in the player list (new player)
						local _, race = UnitRace("raid" .. i)
						local sex = UnitSex("raid" .. i)
						local guild = GetGuildInfo("raid" .. i)
						
						if (0 == level) then 
							level = UnitLevel("raid" .. i)
						end
						
						if (name) then 
							-- protect against phantom players
							local player = self:createPlayer(name, race, guild, sex, level, className, subgroup, isOnline, activityTime)			
							currentRaid:addPlayer(player)	-- add the player to the raid player list						
						end
					end	-- end raid member is existing present member or new member 
					
					-- track the player
					if (name) then 
						trackedPlayerList[name] = name	
					end
				end	-- end loop through all raid members
				
				-- TODO: Remove/cleanup members that are no longer in the raid.  
				currentRaid:processMissingPlayers(numberOfRaidMembers, trackedPlayerList, activityTime)
				
				-- Update the last activity time for the raid after member processing is fully complete
				currentRaid:setLastActivityTime(activityTime)
				HeadCount:LogDebug(string.format(L["debug.raid.update.continue"], L["product.name"], L["product.version.major"], L["product.version.minor"], HeadCount:getDateTimeAsString(activityTime)))
				--HeadCount:LogDebug(string.format(L["debug.raid.update.numberOfRaidMembers"], L["product.name"], L["product.version.major"], L["product.version.minor"], currentRaid:getNumberOfPlayers(), HeadCount:getDateTimeAsString(activityTime)))			
			else
				-- no raid active, cleanup any existing raids
				if (self.isCurrentRaidActive) then
					-- current raid is active, end it
					HeadCount:LogDebug(string.format(L["debug.raid.update.activitytime"], L["product.name"], L["product.version.major"], L["product.version.minor"], HeadCount:getDateTimeAsString(activityTime))) 					
					self:endCurrentRaid(activityTime)
					HeadCount:LogDebug(string.format(L["debug.raid.update.end"], L["product.name"], L["product.version.major"], L["product.version.minor"], HeadCount:getDateTimeAsString(activityTime)))		
				end
			end	-- end determine number of raid members
		else
			-- cleanup any existing raids
			if (self.isCurrentRaidActive) then
				-- current raid is active, end it 
				HeadCount:LogDebug(string.format(L["debug.raid.update.activitytime"], L["product.name"], L["product.version.major"], L["product.version.minor"], HeadCount:getDateTimeAsString(activityTime))) 				
				self:endCurrentRaid(activityTime)
				HeadCount:LogDebug(string.format(L["debug.raid.update.end"], L["product.name"], L["product.version.major"], L["product.version.minor"], HeadCount:getDateTimeAsString(activityTime)))					
			end
		end -- end determine if mod owner is in a raid or not
		
		HeadCount:SetRaidListWrapper(self.raidListWrapper)	-- save the raid list
	end
end

-- Manage loot updates
-- @param raidId The raid id.
-- @param lootId The loot id.
-- @param playerName The name of the player who looted the item
-- @paam source The loot source
-- @param lootCost The loot cost.
function HeadCount.RaidTracker.prototype:lootManagementUpdate(raidId, lootId, playerName, source, lootCost)	
	assert(raidId, "Unable to process loot management update because the raidId is not found.")
	assert(lootId, "Unable to process loot management update because the lootId is not found.")
	assert(playerName, "Unable to process loot management update because the player name is nil.")
	assert(source, "Unable to process loot management update because the loot source is nil.")
	assert(type(lootCost) == "number", "Unable to process loot management update because the lootCost is not a number.")
	
	local raid = self:getRaidById(raidId)
	if (raid) then
		local loot = raid:retrieveLoot(lootId)
		if (loot) then
			loot:setPlayerName(playerName)
			loot:setSource(source)
			loot:setCost(lootCost)		
			HeadCount:SetRaidListWrapper(self.raidListWrapper)	-- save the raid list	
		else
			error("Unable to process loot management update because the loot could not be found: " .. lootId)
		end
	else
		error("Unable to process loot management update because the raid could not be found: " .. raidId)
	end	
end

-- Creates a player.
-- @param name The name.
-- @param race The race.
-- @param guild The guild name.
-- @param sex The sex.
-- @param level The player level.
-- @param className The class name.
-- @param subgroup The subgroup.
-- @param isOnline The online status.
-- @param activityTime The activity time.
-- @return object Returns a player or nil if none can be created.
function HeadCount.RaidTracker.prototype:createPlayer(name, race, guild, sex, level, className, subgroup, isOnline, activityTime) 
	local player = nil
	
	local utcDateTimeInSeconds = HeadCount:getUTCDateTimeInSeconds()	
	local activityTime = AceLibrary("HeadCountTime-1.0"):new({ ["utcDateTimeInSeconds"] = utcDateTimeInSeconds })		

	local timePair = AceLibrary("HeadCountTimePair-1.0"):new({ ["beginTime"] = nil, ["endTime"] = nil, ["note"] = nil })		
	timePair:setBeginTime(activityTime) 
	
	local args = {
		["name"] = name, 
		["className"] = className, 
		["race"] = race, 
		["guild"] = guild, 
		["sex"] = sex, 
		["level"] = level, 
		["isPresentInRaidList"] = false, 
		["isPresentInWaitList"] = false, 
		["isOnline"] = true, 
		["raidListTime"] = 0, 
		["waitListTime"] = 0, 
		["offlineTime"] = 0, 
		["timeList"] = { }, 
		["lastActivityTime"] = activityTime, 
		["isFinalized"] = false	
	}
	
	if (isOnline) then
		-- CURRENT: Player is online
		if (HeadCount:isRaidListGroup(subgroup)) then
			-- CURRENT: Player is in the raid list.
			args["isPresentInRaidList"] = true
			args["isPresentInWaitList"] = false
			args["isOnline"] = true			
			
			timePair:setNote(L["Raid list"])
			table.insert(args["timeList"], timePair)	-- insert the first time pair (includes begin time with no end time)			
			
			player = AceLibrary("HeadCountPlayer-1.0"):new(args)	-- create an online player, starting in the raid list
			HeadCount:LogDebug(string.format(L["debug.raid.update.addmember.raidlist"], L["product.name"], L["product.version.major"], L["product.version.minor"], name))
		elseif (HeadCount:isWaitListGroup(subgroup)) then		
			-- CURRENT: Player is in the wait list.
			args["isPresentInRaidList"] = false
			args["isPresentInWaitList"] = true
			args["isOnline"] = true			
			
			timePair:setNote(L["Wait list"])
			table.insert(args["timeList"], timePair)	-- insert the first time pair (includes begin time with no end time)			
			
			player = AceLibrary("HeadCountPlayer-1.0"):new(args)	-- create an online player, starting in the wait list
			HeadCount:LogDebug(string.format(L["debug.raid.update.addmember.waitlist"], L["product.name"], L["product.version.major"], L["product.version.minor"], name))														
		else
			-- CURRENT: Player is in no list.
			args["isPresentInRaidList"] = false
			args["isPresentInWaitList"] = false
			args["isOnline"] = true			
			
			timePair:setNote(L["No list"])
			table.insert(args["timeList"], timePair)	-- insert the first time pair (includes begin time with no end time)			
			
			player = AceLibrary("HeadCountPlayer-1.0"):new(args)	-- create an online player, starting in no list
			HeadCount:LogDebug(string.format(L["debug.raid.update.addmember.nolist"], L["product.name"], L["product.version.major"], L["product.version.minor"], name))
		end
	else
		-- CURRENT: Player is offline
		args["isPresentInRaidList"] = false
		args["isPresentInWaitList"] = false
		args["isOnline"] = false
		
		timePair:setNote(L["Offline"])
		table.insert(args["timeList"], timePair)	-- insert the first time pair (includes begin time with no end time)			
		
		player = AceLibrary("HeadCountPlayer-1.0"):new(args)	-- create an online player, starting in no list
		HeadCount:LogDebug(string.format(L["debug.raid.update.addmember.offline"], L["product.name"], L["product.version.major"], L["product.version.minor"], name))
	end
	
	return player
end

----------------------------
-- BOSS KILL TRACKING
----------------------------
-- Process a target change.
-- @param unit The target unit (target, mouseover, focus, etc.)
function HeadCount.RaidTracker.prototype:processTargetChange(unit)
	if ((unit) and (self.isCurrentRaidActive)) then 
		-- TODO: check if unit is boss and if it is dead
		
		-- TODO: check if unit is boss target (chest)
	end
end

-- Determines if a boss is engaged.
-- @return boolean Returns true if boss is engaged and false otherwise
-- @return boolean Returns true if the boss engage check needs to be checked again and false otherwise.
function HeadCount.RaidTracker.prototype:processBossEngagement() 
	local isBossEngaged = false
	local isRecheckNeeded = false
	
	if (self.isCurrentRaidActive) then
		-- only check if boss is engaged if in an active raid
		local bossTable = self:processBossTargets()
		
		if (bossTable) then 			
			for k,v in pairs(bossTable) do
				local guid = v["guid"]
				local isDead = v["isDead"]
				if ((not isDead) and (not self.currentBossEvent:isBossPresent(guid))) then 
					-- boss is engaged, alive and boss is not present in the event tracker, add it!
					HeadCount:LogDebug(string.format(L["debug.boss.engage"], L["product.name"], L["product.version.major"], L["product.version.minor"], v["bossName"], guid))
					
					self.currentBossEvent:addBoss(v)	-- add the boss to the boss event
					
					isBossEngaged = true					
				end
			end
			
			if (isBossEngaged) then 
				HeadCount:removeEvent("PLAYER_REGEN_DISABLED")		-- disable player enter combat event
				HeadCount:addEvent("PLAYER_REGEN_ENABLED")			-- enable player leave combat event	
				HeadCount:addEvent("COMBAT_LOG_EVENT_UNFILTERED")	-- add combat log event	
			else
				-- boss is not engaged yet
				if (UnitAffectingCombat("player")) then 
					-- recheck for boss engagement
					isRecheckNeeded = true
				end
			end
		end
	else
		-- no raid is active, disable all boss kill tracking events
		HeadCount:removeEvent("PLAYER_REGEN_DISABLED")		-- disable player enter combat event
		HeadCount:removeEvent("PLAYER_REGEN_ENABLED")			-- enable player leave combat event	
		HeadCount:removeEvent("COMBAT_LOG_EVENT_UNFILTERED")	-- add combat log event	
		
		self.currentBossEvent:endEvent()
	end
	
	return isBossEngaged, isRecheckNeeded
end

-- Processes boss targets
-- @return table Returns the boss table.
-- @return number Returns the number of entries in the boss table.
function HeadCount.RaidTracker.prototype:processBossTargets() 
	local bossTable = { }
	local numberOfBosses = 0
	
	-- the current zone
	local zone = GetRealZoneText()
	
	local isBoss = false
	local guid = nil
	local bossName = nil
	local isDead = nil
	
	isBoss, guid, bossName, isDead = self:isBossUnit("target")
	if (isBoss) then 
		-- target exists, target is in combat, target is a boss mob for this zone	
		bossTable[guid] = { ["guid"] = guid, ["bossName"] = bossName, ["zone"] = zone, ["isDead"] = isDead, }		
		numberOfBosses = numberOfBosses + 1
	end
	
	isBoss, guid, bossName, isDead = self:isBossUnit("focus")
	if (isBoss) then 
		-- focus exists, focus is in combat, focus is a boss mob for this zone	
		if (not bossTable[guid]) then
			bossTable[guid] = { ["guid"] = guid, ["bossName"] = bossName, ["zone"] = zone, ["isDead"] = isDead, }		
			numberOfBosses = numberOfBosses + 1
		end
	end
	
	local numberOfRaidMembers = GetNumRaidMembers()
	if (numberOfRaidMembers > 0) then 
		for i = 1, numberOfRaidMembers do
			local raidUnit = string.format("%s%d%s", "raid", i, "target")
			
			isBoss, guid, bossName, isDead = self:isBossUnit(raidUnit)
			if (isBoss) then 
				-- raid unit target exists, raid unit target is in combat, raid unit target is a boss mob for this zone
				if (not bossTable[guid]) then
					bossTable[guid] = { ["guid"] = guid, ["bossName"] = bossName, ["zone"] = zone, ["status"] = isDead, }		
					numberOfBosses = numberOfBosses + 1
				end
			end			
		end
	end
	
	return bossTable, numberOfBosses
end

-- Determines if the current unit is a valid boss in combat
-- @param unit The target unit
-- @return boolean Returns true if the unit is a valid boss and false otherwise.
-- @return string Returns the guid.
-- @return string Returns the boss name or nil if the unit is not a valid boss.
-- @return boolean Returns if the unit is dead or alive
function HeadCount.RaidTracker.prototype:isBossUnit(unit)
	local isValid = false
	local guid = nil
	local name = nil
	local isDead = nil
	
	if (unit) then
		if (UnitExists(unit)) then
			-- unit exists
			local unitName = UnitName(unit)	
			if (UnitAffectingCombat(unit) and (UnitClassification(unit) == "worldboss") and (not L.ignoreBossList[unitName])) then
				-- boss is in combat, boss is a worldboss, boss is not on the ignore list, boss is not tracked yet
				isValid = true
				guid = self:retrieveGUID(unit)			
				name = unitName
				isDead = UnitIsDead(unit)
			-- else
				-- if (UnitAffectingCombat(unit) and (UnitName(unit) == "Stonescythe Whelp")) then
					----boss is in combat, boss is not tracked
					-- isValid = true
					-- guid = self:retrieveGUID(unit)
					-- name = unitName					
					-- isDead = UnitIsDead(unit)
				-- end
			end		
		end
	end

	return isValid, guid, name, isDead
end

-- Gets the unit GUID.
-- @param unit The unit.
-- @return string Returns the unit GUID or nil if none exists
function HeadCount.RaidTracker.prototype:retrieveGUID(unit)
	local guid = nil

	if (unit) then 
		guid = UnitGUID(unit)
		if (0 == tonumber(guid, 16)) then
			return
		end
	end
	
	return guid
end

-- Determines if the raid has wiped on a boss
-- @return boolean Returns true if there is a boss wipe and false otherwise
-- @return boolean Returns true if the boss wipe check needs to be checked again and false otherwise.
function HeadCount.RaidTracker.prototype:processBossWipe() 
	local isBossWipe = false
	local isRecheckNeeded = false
	
	if (self.isCurrentRaidActive) then 
		if (self.currentBossEvent:getIsStarted()) then
			-- only check for boss wipe if in an active raid an a boss is engaged
			HeadCount:LogDebug(string.format(L["debug.boss.wipe.check"], L["product.name"], L["product.version.major"], L["product.version.minor"]))
		
			if not UnitIsFeignDeath("player") then 
				-- get the current target list
				local _, numberOfBosses = self:processBossTargets()
				if (numberOfBosses > 0) then 
					-- alive bosses are engaged by the raid, recheck for wipe!
					isRecheckNeeded = true
				else
					-- no alive bosses are engaged by the raid, it's a wipe!
					-- no boss is engaged
					HeadCount:removeEvent("COMBAT_LOG_EVENT_UNFILTERED")	-- disable combat log event				
					HeadCount:removeEvent("PLAYER_REGEN_ENABLED")			-- disable player leave combat event
					HeadCount:addEvent("PLAYER_REGEN_DISABLED")				-- enable player enter combat event				

					-- no boss is engaged, raid has wiped
					HeadCount:LogDebug(string.format(L["debug.boss.wipe"], L["product.name"], L["product.version.major"], L["product.version.minor"]))
					
					-- destroy current boss event
					self.currentBossEvent:endEvent()
					
					isBossWipe = true										
				end
			end
		else
			-- no boss event is currently active, reset to standard event handling
			HeadCount:removeEvent("COMBAT_LOG_EVENT_UNFILTERED")	-- disable combat log event				
			HeadCount:removeEvent("PLAYER_REGEN_ENABLED")			-- disable player leave combat event
			HeadCount:addEvent("PLAYER_REGEN_DISABLED")				-- enable player enter combat event							
			
			self.currentBossEvent:endEvent()
		end
	else
		-- no raid is active, disable all boss kill tracking events
		HeadCount:removeEvent("PLAYER_REGEN_DISABLED")		-- disable player enter combat event
		HeadCount:removeEvent("PLAYER_REGEN_ENABLED")			-- enable player leave combat event	
		HeadCount:removeEvent("COMBAT_LOG_EVENT_UNFILTERED")	-- add combat log event		
				
		self.currentBossEvent:endEvent()
	end
	
	return isBossWipe, isRecheckNeeded
end

-- Determines if a boss has died
-- @param guid The mob unit guid.
-- @param mob The mob that has just died.
function HeadCount.RaidTracker.prototype:processBossDeath(guid, mob)
	if ((guid) and (mob)) then 
		if (self.isCurrentRaidActive) then 
			if (self.currentBossEvent:getIsStarted()) then		
				local isPresent = self.currentBossEvent:isBossPresent(guid)
				local isAlive = self.currentBossEvent:isBossAlive(guid)
				if ((isPresent) and (isAlive)) then 
					-- boss kill recorded!
					local encounterName = self.currentBossEvent:retrieveEncounterName()
					HeadCount:LogDebug(string.format(L["debug.boss.kill"], L["product.name"], L["product.version.major"], L["product.version.minor"], self.currentBossEvent:getBossName(guid), guid))
					self.currentBossEvent:setBossDead(guid)
					
					-- check for any new targets
					self:processBossEngagement()
					if (self.currentBossEvent:isEventComplete()) then
						-- boss event is complete!					
						HeadCount:removeEvent("COMBAT_LOG_EVENT_UNFILTERED")	-- disable combat log event				
						HeadCount:removeEvent("PLAYER_REGEN_ENABLED")			-- disable player leave combat event
						HeadCount:addEvent("PLAYER_REGEN_DISABLED")				-- enable player enter combat event	

						local utcDateTimeInSeconds = HeadCount:getUTCDateTimeInSeconds()
						local activityTime = AceLibrary("HeadCountTime-1.0"):new({ ["utcDateTimeInSeconds"] = utcDateTimeInSeconds })
						
						local zone = self.currentBossEvent:getZone()
						
						self:addBossKill(encounterName, zone, activityTime)	-- add the boss kill
						
						self.currentBossEvent:endEvent()	
					end		
				end
			else
				-- no boss event is currently active, reset to standard event handling
				HeadCount:removeEvent("COMBAT_LOG_EVENT_UNFILTERED")	-- disable combat log event				
				HeadCount:removeEvent("PLAYER_REGEN_ENABLED")			-- disable player leave combat event
				HeadCount:addEvent("PLAYER_REGEN_DISABLED")				-- enable player enter combat event							
				
				self.currentBossEvent:endEvent()			
			end
		else
			-- no raid is active, disable all boss kill tracking events
			HeadCount:removeEvent("PLAYER_REGEN_DISABLED")		-- disable player enter combat event
			HeadCount:removeEvent("PLAYER_REGEN_ENABLED")			-- enable player leave combat event	
			HeadCount:removeEvent("COMBAT_LOG_EVENT_UNFILTERED")	-- add combat log event	
			
			self.currentBossEvent:endEvent()	
		end
	end	
end

-- Sets the raid list wrapper.
-- @param raidList The raid list wrapper.
function HeadCount.RaidTracker.prototype:setRaidListWrapper(raidListWrapper)
	self.raidListWrapper = raidListWrapper
end

-- To String
-- @return string Returns the string description for this object.
function HeadCount.RaidTracker.prototype:ToString()
	return L["object.RaidTracker"]
end
