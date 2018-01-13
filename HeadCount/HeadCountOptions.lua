--[[
Project name: HeadCount
Developed by: seppyk (http://www.authority-km.com)
Website: http://www.wowace.com/wiki/HeadCount
Description: Manages tracking of raid attendance and more.
License: Creative Common Attribution-NonCommercial-ShareAlike 3.0 Unported
File: HeadCountOptions.lua
File description: Options listing
]]

local L = AceLibrary("AceLocale-2.2"):new("HeadCount")
local HeadCount = HeadCount

local partyGroups = { "1", "2", "3", "4", "5", "6", "7", "8", }
local exportFormats = { 
	["EQdkp"] = "EQdkp", 
	["phpBB"] = "phpBB",
	["phpBB_ItemStats"] = "phpBB_ItemStats", 
	["CSV"] = "CSV", 
	["XML"] = "XML", 
}

-- configuration options
local options = { 
    type = "group", 
	handler = HeadCount, 
    args = {
        gui = {
            type = "execute", 
            name = L["console.command.gui.name"],
            desc = L["console.command.gui.description"],
			func = "ToggleUI", 
			order = 1, 
        },	
		attendance = {
			type = "group", 
			name = L["console.command.attendance.name"], 
			desc = L["console.command.attendance.description"], 
			order = 2, 
		    args = {
				raidlistgroups = { 
					type = "text", 
					name = L["console.command.attendance.raidlistgroups.name"], 
					desc = L["console.command.attendance.raidlistgroups.description"], 
					usage = L["console.usage.groups"], 
					multiToggle = true, 
					get = "GetRaidListGroups", 
					set = "SetRaidListGroups", 
					validate = partyGroups, 
					order = 1, 					
				}, 
				waitlistgroups = { 
					type = "text", 
					name = L["console.command.attendance.waitlistgroups.name"], 
					desc = L["console.command.attendance.waitlistgroups.description"], 
					usage = L["console.usage.groups"], 
					multiToggle = true, 
					get = "GetWaitListGroups", 
					set = "SetWaitListGroups",
					validate = partyGroups,  					
					order = 2, 					
				}, 
				delay = {
					type = "range", 
					name = L["console.command.attendance.delay.name"], 
					desc = L["console.command.attendance.delay.description"], 
					get = "GetDelay", 
					set = "SetDelay", 
					min = 0, 
					max = 20, 
					step = 1, 
					order = 3, 
				}, 
				bgtracking = {
					type = "toggle", 
					name = L["console.command.attendance.bgtracking.name"], 
					desc = L["console.command.attendance.bgtracking.description"], 
					get = "IsBattlegroundTrackingEnabled", 
					set = "ToggleBattlegroundTracking", 
					order = 4, 
				}, 
				-- autoselection = {
					-- type = "toggle", 
					-- name = L["console.command.attendance.autoselection.name"], 
					-- desc = L["console.command.attendance.autoselection.description"], 
					-- get = "IsAutomaticGroupSelectionEnabled", 
					-- set = "ToggleAutomaticGroupSelection", 
					-- order = 3, 
				-- }, 
			}, 
		}, 
		["time"] = {
			type = "group", 
			name = L["console.command.time.name"], 
			desc = L["console.command.time.description"], 
			order = 3, 
			args = {
				timetotals = { 
					type = "group", 
					name = L["console.command.time.timetotals.name"], 
					desc = L["console.command.time.timetotals.description"], 
					order = 1, 
					args = {
						raidlisttime = {
							type = "toggle", 
							name = L["console.command.time.timetotals.raidlisttime.name"], 
							desc = L["console.command.time.timetotals.raidlisttime.description"], 
							get = "IsRaidListTimeEnabled", 
							set = "ToggleRaidListTime", 
							order = 1, 
						}, 
						waitlisttime = {
							type = "toggle", 
							name = L["console.command.time.timetotals.waitlisttime.name"], 
							desc = L["console.command.time.timetotals.waitlisttime.description"], 							
							get = "IsWaitListTimeEnabled", 
							set = "ToggleWaitListTime", 							
							order = 2, 
						}, 
						offlinetime = {
							type = "toggle", 
							name = L["console.command.time.timetotals.offlinetime.name"], 
							desc = L["console.command.time.timetotals.offlinetime.description"], 							
							get = "IsOfflineTimeEnabled", 
							set = "ToggleOfflineTime", 
							order = 3, 
						}, 
					}, 
				}, 
				timezone = { 
					type = "range", 
					name = L["console.command.time.timezone.name"], 
					desc = L["console.command.time.timezone.description"], 
					get = "GetTimezone", 
					set = "SetTimezone", 
					min = -10 ,
					max = 14, 
					step = 1, 
					order = 2, 
				},
				timeformat = { 
					type = "toggle", 
					name = L["console.command.time.timeformat.name"], 
					desc = L["console.command.time.timeformat.description"], 
					get = "IsTimeFormatEnabled", 
					set = "ToggleTimeFormat", 
					order = 3, 
				}, 
			},
		},
		loot = {
			type = "group", 
			name = L["console.command.loot.name"], 
			desc = L["console.command.loot.description"], 
			order = 4, 
		    args = {
				minimum = {
					type = "text",
					name = L["console.command.loot.minimum.name"],
					desc = L["console.command.loot.minimum.description"], 
					usage = L["console.usage.item.quality"], 
					get = "GetMinimumLootQuality",
					set = "SetMinimumLootQuality", 
					validate = L.itemQuality, 
					order = 1, 
				},	
				popup = { 
					type = "toggle", 
					name = L["console.command.loot.popup.name"], 
					desc = L["console.command.loot.popup.description"], 
					get = "IsLootPopupEnabled", 
					set = "ToggleLootPopup", 
					order = 2, 
				}, 
				exclude = {
					type = "execute", 
					name = L["console.command.loot.exclude.name"], 
					desc = L["console.command.loot.exclude.description"], 
					func = "ManageExclusionList", 
					order = 3, 
				}, 
			}, 
		}, 
		export = {
			type = "group", 
			name = L["console.command.export.name"], 
			desc = L["console.command.export.description"], 
			order = 5, 
			args = {
				["format"] = {
					type = "text", 
					name = L["console.command.export.format.name"], 
					desc = L["console.command.export.format.description"], 
					usage = L["console.command.export.format.usage"], 
					get = "GetExportFormat", 
					set = "SetExportFormat", 
					validate = exportFormats,					
					order = 1, 
				}, 										
			}, 
		}, 
		reporting = {
			type = "group", 
			name = L["console.command.reporting.name"], 
			desc = L["console.command.reporting.description"], 
			order = 5, 
			args = {
				bosskills = {
					type = "toggle", 
					name = L["console.command.reporting.bosskills.name"], 
					desc = L["console.command.reporting.bosskills.description"], 
					get = "IsBossBroadcastEnabled", 
					set = "ToggleBossBroadcast", 
					order = 1, 
				}, 
				loot = {
					type = "toggle", 
					name = L["console.command.reporting.loot.name"], 
					desc = L["console.command.reporting.loot.description"], 
					get = "IsLootBroadcastEnabled", 
					set = "ToggleLootBroadcast", 
					order = 2, 
				}, 				
			}, 		
		}, 
        ["debug"] = {
            type = "toggle", 
            name = L["console.command.debug.name"],
            desc = L["console.command.debug.description"],
            get = "IsDebugEnabled",
            set = "ToggleDebugEnabled", 
			order = 7, 
        }, 
		exclude = { 
			type = "group", 
			name = L["console.command.exclude.name"], 
			desc = L["console.command.exclude.description"], 			
			guiHidden = true, 
			order = 8, 
			args = { 
				add = {
					type = "text", 
					name = L["console.command.exclude.add.name"], 
					desc = L["console.command.exclude.add.description"], 
					usage = L["console.usage.exclude"], 
					message = L["console.command.exclude.add.set"],
					get = "GetExcludeText", 
					set = "AddToExclusionList", 
					validate = "ValidateAddToExclusionList", 
					order = 1, 
				}, 
				["remove"] = {
					type = "text", 
					name = L["console.command.exclude.remove.name"], 
					desc = L["console.command.exclude.remove.description"], 
					usage = L["console.usage.exclude"], 
					message = L["console.command.exclude.remove.set"],
					get = "GetExcludeText", 
					set = "RemoveFromExclusionList", 
					validate = "ValidateRemoveFromExclusionList", 
					order = 2, 
				}, 				
		        ["list"] = {
		            type = "execute", 
		            name = L["console.command.exclude.list.name"],
		            desc = L["console.command.exclude.list.description"],
					func = "DisplayExclusionList", 
					order = 3, 
		        },	
			}, 
		}, 
    },
}

-- Gets the options.
-- @return table Returns the options.
function HeadCount:getOptions()
	return options
end

-- default configuration options
local defaultOptions = { 
	raidListGroups = { ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true, ["5"] = true, ["6"] = false, ["7"] = false, ["8"] = false, }, 
	waitListGroups = { ["1"] = false, ["2"] = false, ["3"] = false, ["4"] = false, ["5"] = false, ["6"] = true, ["7"] = true, ["8"] = true, }, 
	isAutomaticGroupSelectionEnabled = true, 
	delay = 5,	-- default delay value of 5 seconds
	isBattlegroundTrackingEnabled = false, 
	timezone = -5, -- "-5 GMT, Eastern Standard Time" 
	isTimeFormatEnabled = true, 
	isRaidListTimeEnabled = true, 
	isWaitListTimeEnabled = false, 
	isOfflineTimeEnabled = false, 
	minimumLootQuality = L.itemQuality[5],
	isLootPopupEnabled = false, 
	isLootBroadcastEnabled = false, 
	isBossBroadcastEnabled = false, 
	exportFormat = exportFormats["EQdkp"], 
	isDebugEnabled = false, 
	raidListWrapper = nil, 
	exclusionList = { 
		[20725] = true, -- Nexus Crystal
		[22450] = true, -- Void Crystal
		[29434] = true, -- Badge of Justice
		[30311] = true, -- Warp Slicer
		[30312] = true, -- Infinity Blade
		[30313] = true, -- Staff of Disintegration
		[30314] = true, -- Phaseshift Bulwark
		[30316] = true, -- Devastation
		[30317] = true, -- Cosmic Infuser
		[30318] = true, -- Netherstrand Longbow
		[30319] = true, -- Nether Spike
		[30320] = true, -- Bundle of Nether Spikes		
	}, 
}

-- Gets the default options.
-- @return table Returns the default options.             
function HeadCount:getDefaultOptions()
	return defaultOptions
end

-- *** CONFIGURATION MENU ***
-- Opens the configuration menu
function HeadCount:ToggleUI() 
	if (UnitInRaid("player")) then
		HeadCount:RAID_ROSTER_UPDATE()	-- update attendance and the UI immediately
	end
	
	HeadCount:ToggleUserInterface()
end

-- *** OPTIONS API ***
function HeadCount:isGroupNumberAssigned(groupNumber)
	local isGroupNumberValid = false
	
	if (HeadCount:isRaidListGroup(groupNumber) or HeadCount:isWaitListGroup(groupNumber)) then
		-- the group number is in the raid list or wait list
		isGroupNumberValid = true
	end
	
	return isGroupNumberValid
end

-- Determines if a party group number is assigned to the raid list group.
-- @param groupNumber The group number.
-- @return boolean Returns true if the group number is assigned to the raid list, false otherwise.
function HeadCount:isRaidListGroup(groupNumber) 
	local isGroupNumberValid = false

	assert(type(groupNumber), "string", string.format(L["error.type.string"], L["product.name"], "isRaidListGroup"))
	
	local groupString = string.format("%d", groupNumber)
	if (self.db.profile.raidListGroups[groupString]) then
		isGroupNumberValid = true
	end
	
	return isGroupNumberValid
end

-- Determines if a party group number is assigned to the wait list group.
-- @return boolean Returns true if the group number is assigned to the wait list, false otherwise.
function HeadCount:isWaitListGroup(groupNumber) 
	local isGroupNumberValid = false

	assert(type(groupNumber), "string", string.format(L["error.type.string"], L["product.name"], "isWaitListGroup"))

	local groupString = string.format("%d", groupNumber)	
	if (self.db.profile.waitListGroups[groupString]) then
		isGroupNumberValid = true
	end
	
	return isGroupNumberValid
end

-- *** ATTENDANCE TRACKING ***
-- Gets the raid list groups table.
-- @return table Returns the raid list groups table.
function HeadCount:GetRaidListGroupsTable() 
	return self.db.profile.raidListGroups
end

-- Gets the raid list groups status.
-- @param key The raid list group key.
-- @return boolean Returns the raid list group status value.
function HeadCount:GetRaidListGroups(key) 
	return self.db.profile.raidListGroups[key]
end

-- Sets the raid list groups.
-- @param key The raid list group key.
-- @param value The raid list group status.
function HeadCount:SetRaidListGroups(key, value) 
	self.db.profile.raidListGroups[key] = value
	
	if (value) then
		self.db.profile.waitListGroups[key] = false
	end

	HeadCount:RAID_ROSTER_UPDATE()	-- update attendance and the UI immediately
end

-- Gets the wait list groups status.
-- @return boolean Returns true if this group is a member of the wait list, false otherwise.
function HeadCount:GetWaitListGroups(key) 
	return self.db.profile.waitListGroups[key]
end

-- Sets the wait list groups.
-- @param key The wait list group key.
-- @param value The wait list group status.
function HeadCount:SetWaitListGroups(key, value) 
	self.db.profile.waitListGroups[key] = value
	
	if (value) then
		self.db.profile.raidListGroups[key] = false 
	end

	HeadCount:RAID_ROSTER_UPDATE()	-- update attendance and the UI immediately	
end

-- Gets the attendance delay value.
-- @return number Returns the attendance delay value
function HeadCount:GetDelay()
	return self.db.profile.delay
end

-- Sets the attendance delay.
-- @param delay The attendance delay value
function HeadCount:SetDelay(delay)
	self.db.profile.delay = delay
end
					
-- Gets the automatic group selection
-- @return boolean Returns true if automatic group selection is enabled and false otherwise
function HeadCount:IsAutomaticGroupSelectionEnabled()
	return self.db.profile.isAutomaticGroupSelectionEnabled
end

-- Sets/toggles automatic group selection
function HeadCount:ToggleAutomaticGroupSelection()
	self.db.profile.isAutomaticGroupSelectionEnabled = not self.db.profile.isAutomaticGroupSelectionEnabled
end

-- Gets the battleground tracking status
-- @return boolean Returns true if battleground tracking is enabled and false otherwise.
function HeadCount:IsBattlegroundTrackingEnabled()
	return self.db.profile.isBattlegroundTrackingEnabled
end

-- Sets/toggles battleground tracking
function HeadCount:ToggleBattlegroundTracking()
	self.db.profile.isBattlegroundTrackingEnabled = not self.db.profile.isBattlegroundTrackingEnabled
	
	HeadCount:RAID_ROSTER_UPDATE()	-- update attendance and the UI immediately		
end

-- *** TIME ***
-- Gets the time zone difference (from UTC).
-- @return number Returns the time zone difference.
function HeadCount:GetTimezone() 
	return self.db.profile.timezone
end

-- Sets the time zone difference (from UTC).
-- @param timezone Sets the time zone difference.
function HeadCount:SetTimezone(timezone)
	self.db.profile.timezone = timezone
	HeadCount:HeadCountFrame_Update()	-- display change, update the UI
end

-- Gets the time format status
-- @return boolean Returns true if in 24-hour time format, false for 12-hour time format.
function HeadCount:IsTimeFormatEnabled() 
	return self.db.profile.isTimeFormatEnabled
end

-- Sets/toggles the time format status
function HeadCount:ToggleTimeFormat() 
	self.db.profile.isTimeFormatEnabled = not self.db.profile.isTimeFormatEnabled
	HeadCount:HeadCountFrame_Update()	-- display change, update the UI
end

-- Gets the raid list time status.
-- @return boolean Returns true if raid list time is enabled and false otherwise.
function HeadCount:IsRaidListTimeEnabled()
	return self.db.profile.isRaidListTimeEnabled
end

-- Sets/toggles the raid list time status.
function HeadCount:ToggleRaidListTime()
	self.db.profile.isRaidListTimeEnabled = not self.db.profile.isRaidListTimeEnabled
	HeadCount:HeadCountFrame_Update()
end

-- Gets the wait list time status.
-- @return boolean Returns true if wait list time is enabled and false otherwise.
function HeadCount:IsWaitListTimeEnabled()
	return self.db.profile.isWaitListTimeEnabled
end

-- Sets/toggles the wait list time status.
function HeadCount:ToggleWaitListTime()
	self.db.profile.isWaitListTimeEnabled = not self.db.profile.isWaitListTimeEnabled
	HeadCount:HeadCountFrame_Update()
end

-- Gets the offline time status.
-- @return boolean Returns true if offline time is enabled and false otherwise.
function HeadCount:IsOfflineTimeEnabled() 
	return self.db.profile.isOfflineTimeEnabled
end

-- Sets/toggles the offline time status.
function HeadCount:ToggleOfflineTime()
	self.db.profile.isOfflineTimeEnabled = not self.db.profile.isOfflineTimeEnabled
	HeadCount:HeadCountFrame_Update()
end

-- *** LOOT TRACKING ***
-- Gets the minimum loot tracking quality.
-- @return string Returns the minimum loot tracking quality.
function HeadCount:GetMinimumLootQuality()
	return self.db.profile.minimumLootQuality
end

-- Sets the minimum loot tracking quality.
-- @param minimumLootQuality The minimum loot quality.
function HeadCount:SetMinimumLootQuality(minimumLootQuality)
	self.db.profile.minimumLootQuality = self:convertStringToProperName(minimumLootQuality)
end

-- Gets the loot popup status
-- @return boolean Returns true if the loot popup is enabled and false otherwise
function HeadCount:IsLootPopupEnabled()
	return self.db.profile.isLootPopupEnabled
end

-- Sets/toggles the loot popup status
function HeadCount:ToggleLootPopup()
	self.db.profile.isLootPopupEnabled = not self.db.profile.isLootPopupEnabled
end

-- Gets the loot broadcast status
-- @return boolean Returns true if loot broadcast is enabled and false otherwise.
function HeadCount:IsLootBroadcastEnabled()
	return self.db.profile.isLootBroadcastEnabled
end

-- Sets/toggles loot broadcast
function HeadCount:ToggleLootBroadcast()
	self.db.profile.isLootBroadcastEnabled = not self.db.profile.isLootBroadcastEnabled
end

-- Manage the exclusion list.
function HeadCount:ManageExclusionList()
	HeadCount:LogInformation(string.format(L["info.exclude.loot.manage"], L["product.name"], L["product.version.major"], L["product.version.minor"]))
end

-- Gets the boss kill broadcast status
-- @return boolean Returns true if loot broadcast is enabled and false otherwise.
function HeadCount:IsBossBroadcastEnabled()
	return self.db.profile.isBossBroadcastEnabled
end

-- Sets/toggles the boss broadcast
function HeadCount:ToggleBossBroadcast()
	self.db.profile.isBossBroadcastEnabled = not self.db.profile.isBossBroadcastEnabled
end
					
-- Gets the export format.
-- @return string Returns the export format.
function HeadCount:GetExportFormat()
	return self.db.profile.exportFormat
end

-- Sets the export format.
-- @param exportFormat The export format.
function HeadCount:SetExportFormat(exportFormat) 
	self.db.profile.exportFormat = exportFormat
end

-- *** DEBUG ***
-- Gets the debug mode status
-- @return boolean Returns true if the debug flag is enabled, false otherwise.
function HeadCount:IsDebugEnabled() 
	return self.db.profile.isDebugEnabled
end

-- Sets/toggles the debug mode status
function HeadCount:ToggleDebugEnabled() 
    self.db.profile.isDebugEnabled = not self.db.profile.isDebugEnabled
end

-- Gets the raid list wrapper.
-- @return table Returns the raid list wrapper.
function HeadCount:GetRaidListWrapper() 
	return self.db.profile.raidListWrapper
end

-- Sets the raid list wrapper.
-- @param raidListWrapper The raid list wrapper.
function HeadCount:SetRaidListWrapper(raidListWrapper) 
	self.db.profile.raidListWrapper = raidListWrapper
end

-- Gets the exclusion list
-- @return table
function HeadCount:GetExclusionList()
	return self.db.profile.exclusionList
end

-- Sets the exclusion list.
-- @param exclusionList The exclusion list.
function HeadCount:SetExclusionList(exclusionList)
	self.db.profile.exclusionList = exclusionList
end

-- Gets the add exclusion
-- @return string
function HeadCount:GetExcludeText() 
	local numberOfExcludedItems = 0

	for k,v in pairs(self.db.profile.exclusionList) do
		numberOfExcludedItems = numberOfExcludedItems + 1
	end

	return string.format(L["info.exclude.number"], numberOfExcludedItems)
end 

-- Adds an item to the exclusion list
-- @param name The loot name or link
function HeadCount:AddToExclusionList(name) 	
	local args = AceLibrary("HeadCountLoot-1.0"):getArgs()
	local id = string.match(name, "item:(%d+):")	

	local numberId = tonumber(id)
	self.db.profile.exclusionList[numberId] = true
end

-- Validates addition to the exclusion list.
-- @param name The loot link.
function HeadCount:ValidateAddToExclusionList(name) 
	local isValid = false
	local _, _, link = string.find(name, "(|c%x+|Hitem:[-%d:]+|h%[.-%]|h|r)")
	local id = string.match(name, "item:(%d+):")
	
	if ((link) and (id)) then 
		-- item passed in is a link		
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(id)
		if (itemName) then
			-- lookup for base item valid
			local numberId = tonumber(id)
			if (self.db.profile.exclusionList[numberId]) then
				-- item is in the exclusion list
				HeadCount:LogWarning(string.format(L["error.exclude.duplicate"], L["product.name"], L["product.version.major"], L["product.version.minor"], itemLink))				
			else
				isValid = true
			end
		end
	end
	
	return isValid
end

-- Removes an item from the exclusion list.
-- @param link The loot link.
function HeadCount:RemoveFromExclusionList(link) 
	local id = string.match(link, "item:(%d+):")	

	local numberId = tonumber(id)
	self.db.profile.exclusionList[numberId] = nil
end

-- Validates removal from the exclusion list.
-- @param link The loot link.
function HeadCount:ValidateRemoveFromExclusionList(link)
	local isValid = false
	local _, _, linkName = string.find(link, "(|c%x+|Hitem:[-%d:]+|h%[.-%]|h|r)")
	local id = string.match(link, "item:(%d+):")

	if ((linkName) and (id)) then 
		-- item passed in is a link
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(id)
		if (itemName) then 
			local numberId = tonumber(id)
			if (self.db.profile.exclusionList[numberId]) then
				-- item is in the exclusion list
				isValid = true
			else
				HeadCount:LogWarning(string.format(L["error.exclude.missing"], L["product.name"], L["product.version.major"], L["product.version.minor"], itemLink))				
			end
		end
	end	
	
	return isValid
end

function HeadCount:DisplayExclusionList() 
	local numberOfExcludedItems = 0

	for k,v in pairs(self.db.profile.exclusionList) do
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(k)
		if (itemLink) then
			HeadCount:LogInformation(string.format(L["info.exclude.loot"], L["product.name"], L["product.version.major"], L["product.version.minor"], itemLink, k))
		else
			HeadCount:LogInformation(string.format(L["info.exclude.loot"], L["product.name"], L["product.version.major"], L["product.version.minor"], L["Item unavailable"], k))
		end
		
		numberOfExcludedItems = numberOfExcludedItems + 1
	end

	HeadCount:LogInformation(string.format(L["info.exclude.loot.title"], L["product.name"], L["product.version.major"], L["product.version.minor"], numberOfExcludedItems))
end
