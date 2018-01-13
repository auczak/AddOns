--[[
Project name: HeadCount
Developed by: seppyk (http://www.authority-km.com)
Website: http://www.wowace.com/wiki/HeadCount
Description: Manages tracking of raid attendance and more.
License: Creative Common Attribution-NonCommercial-ShareAlike 3.0 Unported
File: HeadCount.lua
File description: Core  application logic / event handling
]]

local MAJOR_VERSION = "HeadCount-1.0"
local MINOR_VERSION = tonumber(("$Revision: 40 $"):match("%d+"))

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary.") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

local L = AceLibrary("AceLocale-2.2"):new("HeadCount")

HeadCount = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceEvent-2.0", "AceDB-2.0", "FuBarPlugin-2.0")
local HeadCount = HeadCount

HeadCount:RegisterDB("HeadCountDB", "HeadCountDBPC")

local raidTracker = nil

-- Gets the raid tracker.
-- @return object Returns the raid tracker.
function HeadCount:getRaidTracker() 
	return raidTracker
end

-- Automatically called when the  addon is initialized
function HeadCount:OnInitialize()
	self:RegisterDefaults("profile", self:getDefaultOptions())
	self:RegisterChatCommand(L["console.commands"], self:getOptions())
	self.OnMenuRequest = self:getOptions()	-- fubar options menu
	
	HeadCount:initializeConstants()
	
	self:LogInformation(string.format(L["info.initialization.complete"], L["product.name"], L["product.version.major"], L["product.version.minor"]))
	self:LogInformation(string.format(L["product.usage"], L["product.name"], L["product.version.major"], L["product.version.minor"])) 
end

-----------------------------------------------------
-- ADDON ENABLED
-----------------------------------------------------
-- Automatically called when the  addon is enabled
function HeadCount:OnEnable()
	self:RegisterSelfEvents()	-- register the main events

	if (raidTracker) then
		raidTracker:recover()	-- process recovery for the raid tracker		
		HeadCount:RAID_ROSTER_UPDATE(true)	-- update attendance and the UI immediately
	else
		RequestRaidInfo()
	end
	
	self:LogDebug(string.format(L["debug.mod.enable"], L["product.name"], L["product.version.major"], L["product.version.minor"]))		
end

-- Register self events
function HeadCount:RegisterSelfEvents()
	-- Core events (always enabled)
	HeadCount:addEvent("RAID_ROSTER_UPDATE")
	HeadCount:addEvent("ZONE_CHANGED_NEW_AREA") 
	HeadCount:addEvent("CHAT_MSG_LOOT") 
	HeadCount:addEvent("UPDATE_INSTANCE_INFO")
	HeadCount:addEvent("PLAYER_ENTERING_WORLD")
end

-- Automatically called when the UPDATE_INSTANCE_INFO event is triggered
function HeadCount:UPDATE_INSTANCE_INFO() 
	if (not raidTracker) then
		HeadCount:removeEvent("UPDATE_INSTANCE_INFO")
		
		-- Setup the raid tracker
		local raidListWrapper = HeadCount:GetRaidListWrapper() 	
		raidTracker = self.RaidTracker:new(raidListWrapper)	-- instantiate a new raid tracker 			
		raidTracker:recover()	-- process recovery for the raid tracker		

		if ((raidTracker:getIsCurrentRaidActive()) and (UnitAffectingCombat("player"))) then 
			-- raid was recovered, continuing raid
			-- player is in combat upon login/reload
			HeadCount:PLAYER_REGEN_DISABLED()	-- call the combat event immediately
		end

		HeadCount:RAID_ROSTER_UPDATE(true)	-- update initial attendance and the UI immediately
	end	
end

-----------------------------------------------------
-- ADDON DISABLED
-----------------------------------------------------
-- Automatically called when the  addon is disabled
function HeadCount:OnDisable()
	HeadCount:RAID_ROSTER_UPDATE(true)	-- update attendance and the UI immediately
	
	self:LogDebug(string.format(L["debug.mod.disable"], L["product.name"], L["product.version.major"], L["product.version.minor"]))		
end

-----------------------------------------------------
-- LOOT MESSAGE
-----------------------------------------------------
-- Automatically called when the CHAT_MSG_LOOT event is triggered
function HeadCount:CHAT_MSG_LOOT(message) 
	if (raidTracker) then		
		local isProcessed = raidTracker:processLootUpdate(message)
		if (isProcessed) then
			HeadCount:RAID_ROSTER_UPDATE(true)	-- update attendance and the UI immediately	
		end
	end
end

-----------------------------------------------------
-- ZONE CHANGE
-----------------------------------------------------  
-- Automatically called when the PLAYER_ENTERING_WORLD event is triggered
function HeadCount:PLAYER_ENTERING_WORLD() 
	if (raidTracker) then
		local zone = GetRealZoneText()
		raidTracker:processStatus(zone)
	end
end

-- Automatically called when the ZONE_CHANGED_NEW_AREA event is triggered
function HeadCount:ZONE_CHANGED_NEW_AREA() 
	if (raidTracker) then
		raidTracker:processZoneChange() 
		HeadCount:RAID_ROSTER_UPDATE(true)	-- update attendance and the UI immediately		
	end
end	

-----------------------------------------------------
-- BOSS KILL
-----------------------------------------------------  
function HeadCount:PLAYER_REGEN_DISABLED() 
	if (raidTracker) then 
		local isBossEngaged, isRecheckNeeded = raidTracker:processBossEngagement()	-- player is in combat, check for boss engagement
		if (isRecheckNeeded) then
			-- boss engagement unclear, recheck for boss engagement in 1 second
			HeadCount:ScheduleEvent("PLAYER_REGEN_DISABLED", 1)
		end
	end
end

-- Automatically called when the COMBAT_LOG_EVENT_UNFILTERED event is triggered
function HeadCount:COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
	if ((raidTracker) and (("UNIT_DIED" == event) or ("PARTY_KILL" == event))) then 
		raidTracker:processBossDeath(destGUID, destName)	-- something died
	end
end

-- Player is not in combat.
function HeadCount:PLAYER_REGEN_ENABLED()
	if (raidTracker) then
		local isBossWipe, isRecheckNeeded = raidTracker:processBossWipe()	-- player is out of combat, check for wipe
		if (isRecheckNeeded) then 
			-- boss wipe unclear, recheck for boss wipe in 2 seconds
			HeadCount:ScheduleEvent("PLAYER_REGEN_ENABLED", 2)		
		end
	end
end

-----------------------------------------------------
-- RAID UPDATE
-----------------------------------------------------  
-- Automatically called when the  RAID_ROSTER_UPDATE event is triggered
-- @param isForcedUpdate The forced update status
function HeadCount:RAID_ROSTER_UPDATE(isForcedUpdate)	
	if (raidTracker) then		
		local utcDateTimeInSeconds = HeadCount:getUTCDateTimeInSeconds()
		local activityTime = AceLibrary("HeadCountTime-1.0"):new({ ["utcDateTimeInSeconds"] = utcDateTimeInSeconds })
		
		if ((UnitInRaid("player")) and (raidTracker:getIsCurrentRaidActive()) and (not isForcedUpdate)) then
			--HeadCount:LogInformation("Raid is currently active.")
			local raid = raidTracker:retrieveMostRecentRaid() 			
			local lastActivityTime = raid:getLastActivityTime()
			local timeDifference = HeadCount:computeTimeDifference(activityTime, lastActivityTime) 
			local delay = HeadCount:GetDelay()
			
			if (timeDifference >= delay) then
				-- attendance call is valid
				--HeadCount:LogInformation("VALID: Delay (" .. delay .. ") | Time difference (" .. timeDifference .. ")")
				
				if (HeadCount:IsEventScheduled("HeadCount_RAID_ROSTER_UPDATE")) then
					--HeadCount:LogInformation("HeadCount_RAID_ROSTER_UPDATE is scheduled, canceling.")
					HeadCount:CancelScheduledEvent("HeadCount_RAID_ROSTER_UPDATE")
				end

				--HeadCount:LogInformation("Processing attendance.")
				raidTracker:processAttendance(activityTime)	-- update the attendance
				HeadCount:HeadCountFrame_Update()			-- update the UI											
			else
				-- attendance call is invalid
				--HeadCount:LogInformation("INVALID: Delay (" .. delay .. ") | Time difference (" .. timeDifference .. ")")
				
				if (not HeadCount:IsEventScheduled("HeadCount_RAID_ROSTER_UPDATE")) then
					--HeadCount:LogInformation("HeadCount_RAID_ROSTER_UPDATE is not scheduled, scheduling.")
					HeadCount:ScheduleEvent("HeadCount_RAID_ROSTER_UPDATE", self.RAID_ROSTER_UPDATE, (delay - timeDifference), self)
				end
			end
		else
			--HeadCount:LogInformation("Raid is currently inactive or a forced raid update is occurring.")
			--HeadCount:LogInformation("Processing attendance.")
			raidTracker:processAttendance(activityTime)	-- update the raid attendance
			HeadCount:HeadCountFrame_Update()			-- update the UI							
		end	
	end
end

-----------------------------------------------------
-- MISCELLANEOUS
-----------------------------------------------------  
-- Ends the current raid
-- @param activityTime The activity time.
function HeadCount:endCurrentRaid(activityTime) 
	if (raidTracker) then
		raidTracker:endCurrentRaid(activityTime)
		HeadCount:RAID_ROSTER_UPDATE(true)	-- update attendance and the UI immediately
	end
end

-- Remove a raid.
-- @param raidId The raid id.
function HeadCount:removeRaid(raidId)
	if (raidTracker) then
		raidTracker:removeRaid(raidId)
		HeadCount:RAID_ROSTER_UPDATE(true)	-- update attendance and the UI immediately		
	end
end

-- Remove all raids.
function HeadCount:removeAllRaids() 
	if (raidTracker) then
		raidTracker:removeAllRaids()
		HeadCount:RAID_ROSTER_UPDATE(true)	-- update attendance and the UI immediately		
	end
end

-- Remove a player from a raid.
-- @param raidId The raid id.
-- @param playerName The player name.
function HeadCount:removePlayer(raidId, playerName) 
	if (raidTracker) then
		raidTracker:removePlayer(raidId, playerName)
		HeadCount:RAID_ROSTER_UPDATE(true)	-- update attendance and the UI immediately		
	end
end

-- Remove a boss from a raid.
-- @param raidId The raid id.
-- @param bossName The boss name.
function HeadCount:removeBoss(raidId, bossName) 
	if (raidTracker) then
		raidTracker:removeBoss(raidId, bossName)
		HeadCount:RAID_ROSTER_UPDATE(true)	-- update attendance and the UI immediately		
	end
end

-- Remove loot from a raid
-- @param raidId The raid id.
-- @param lootId The loot id.
function HeadCount:removeLoot(raidId, lootId) 
	if (raidTracker) then
		raidTracker:removeLoot(raidId, lootId) 
		HeadCount:RAID_ROSTER_UPDATE(true)	-- update attendance and the UI immediately		
	end
end

-- Loot management update
-- @param raidId The raid id
-- @param lootId The loot id
-- @param playerName The name of the player who looted the item
-- @paam source The loot source
-- @param lootCost The loot cost
function HeadCount:lootManagementUpdate(raidId, lootId, playerName, source, lootCost)	
	if (raidTracker) then
		raidTracker:lootManagementUpdate(raidId, lootId, playerName, source, lootCost)	
		HeadCount:HeadCountFrame_Update()			-- update the UI	
	end
end

-----------------------------------------------------
-- EVENT HANDLING
-----------------------------------------------------  
-- Adds a registered event
-- @param event The event name
-- @param functionName The function name
function HeadCount:addEvent(event, functionName) 
	if ((event) and (not HeadCount:IsEventRegistered(event))) then 
		-- event is not registered
		--HeadCount:LogDebug(string.format(L["debug.event.register"], L["product.name"], L["product.version.major"], L["product.version.minor"], event))	
		if (functionName) then
			HeadCount:RegisterEvent(event, functionName)
		else
			HeadCount:RegisterEvent(event)
		end
	end
end

-- Removes a registered event.
-- @param event The event name.
function HeadCount:removeEvent(event)
	if ((event) and (HeadCount:IsEventRegistered(event))) then 
		-- event is registered, unregister it
		--HeadCount:LogDebug(string.format(L["debug.event.unregister"], L["product.name"], L["product.version.major"], L["product.version.minor"], event))
		HeadCount:UnregisterEvent(event)
	end
end

-----------------------------------------------------
-- LOGGING
-----------------------------------------------------  
-- Logs a debug message for a roster member
function HeadCount:debugRosterMember(name, rank, subgroup, level, className, fileName, zone, isOnline, isDead, role, isML) 
	local memberString = "[name: %s, rank: %d, subgroup: %d, level: %s, class: %s, fileName: %s, zone: %s, isOnline: %s, isDead: %s, role: %s, isML: %s]"

	local isMemberOnline = HeadCount:convertBooleanToString(isOnline)		
	local isMemberDead = HeadCount:convertBooleanToString(isDead)		
	local isMasterLooter = HeadCount:convertBooleanToString(isML)
	local memberRole
	if (role) then
		memberRole = role
	else
		memberRole = L["None"]
	end
		
	self:LogDebug(string.format(memberString, name, rank, subgroup, level, className, fileName, zone, isMemberOnline, isMemberDead, memberRole, isMasterLooter))	
end

-- Logs a debug message to the default chat frame
-- @param message The message.
-- @red The red color for this message.
-- @green The green color for this message.
-- @blue The blue color for this message.
function HeadCount:LogDebug(message, red, green, blue)
	if (self.db.profile.isDebugEnabled) then
		DEFAULT_CHAT_FRAME:AddMessage(message, red, green, blue)
	end
end

-- Logs a information message to the default chat frame
-- @param message The message.
-- @red The red color for this message.
-- @green The green color for this message.
-- @blue The blue color for this message.
function HeadCount:LogInformation(message, red, green, blue)
	DEFAULT_CHAT_FRAME:AddMessage(message, red, green, blue)
end

-- Logs a information message to the default chat frame with default colors
-- @param message The message.
function HeadCount:LogInformation(message)
	DEFAULT_CHAT_FRAME:AddMessage(message, 1.0, 1.0, 1.0)
end

-- Logs a warning message to the default chat frame with default colors
-- @param message The message.
function HeadCount:LogWarning(message)
	DEFAULT_CHAT_FRAME:AddMessage(message, 1.0, 1.0, 1.0)
end

-- Logs a message to the error chat frame
-- @param message The message.
-- @red The red color for this message.
-- @green The green color for this message.
-- @blue The blue color for this message.
function HeadCount:LogError(message, red, green, blue)
	UIErrorsFrame:AddMessage(message, red, green, blue)
end

-- Logs a message to guild chat
-- @param message The message.
function HeadCount:LogGuild(message)
	assert(message, "Unable to send guild message because the message is nil.")
	
	if (IsInGuild()) then
		SendChatMessage(message, "GUILD", nil, nil)
	end
end

----------------------------
-- FUBAR
----------------------------
HeadCount.hasNoText = true
HeadCount.hasIcon = "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01"
HeadCount.hasNoColor = true
HeadCount.defaultPosition = "CENTER"
HeadCount.defaultMinimapPosition = 285
HeadCount.clickableTooltip = false
HeadCount.tooltipHiddenWhenEmpty = true
HeadCount.independentProfile = true
HeadCount.hideWithoutStandby = true
HeadCount.cannotDetachTooltip = true
HeadCount.blizzardTooltip = true

-- Minimap hover tooltip display
function HeadCount:OnTooltipUpdate()
	GameTooltip:AddLine("|cFF9999FF" .. L["product.name"])
	GameTooltip:AddLine("")
	GameTooltip:AddLine(L["minimap.frame"], 0.2, 1, 0.2)
	GameTooltip:AddLine(L["minimap.configuration"], 0.2, 1, 0.2)
	GameTooltip:AddLine(L["minimap.button.rotate"], 0.2, 1, 0.2)
	GameTooltip:AddLine(L["minimap.button.drag"], 0.2, 1, 0.2)
end 

-- Minimap click display
function HeadCount:OnClick()
	if (UnitInRaid("player")) then
		HeadCount:RAID_ROSTER_UPDATE(true)	-- update attendance and the UI immediately
	end
	
	HeadCount:ToggleUserInterface()
end
