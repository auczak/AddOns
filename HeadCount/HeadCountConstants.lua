--[[
Project name: HeadCount
Developed by: seppyk (http://www.authority-km.com)
Website: http://www.wowace.com/wiki/HeadCount
Description: Manages tracking of raid attendance and more.
License: Creative Common Attribution-NonCommercial-ShareAlike 3.0 Unported
File: HeadCountConstants.lua
File description: Constants listing
]]

local L = AceLibrary("AceLocale-2.2"):new("HeadCount")
local HeadCount = HeadCount

-- Localized boss targets
HeadCount.BOSS_TARGET = { }

-- Localized battlegrounds
HeadCount.BATTLEGROUNDS = { }

-- Default level
HeadCount.DEFAULT_LEVEL = 70

-- Item rarity colors
HeadCount.ITEM_COLORS_NO_ALPHA = { "9D9D9D", "FFFFFF", "1EFF00", "0070DD", "A335EE", "FF8000", "E6CC80", }
HeadCount.DEFAULT_COLOR_NO_ALPHA = "A335EE"

-- Default loot source
HeadCount.DEFAULT_LOOT_SOURCE = L["Trash mob"]

-- Class colors
HeadCount.CLASS_COLORS = {
	["Druid"] = { r = 1, g = 0.49, b = 0.04, }, 
	["Hunter"] =  { r = 0.67, g = 0.83, b = 0.45 },
	["Mage"] = { r = 0.41, g = 0.8, b = 0.94 },
	["Paladin"] = { r = 0.96, g = 0.55, b = 0.73 }, 
	["Priest"] = { r = 1, g = 1, b = 1 }, 
	["Rogue"] = { r = 1, g = 0.96, b = 0.41 }, 
	["Shaman"] = { r = 0.14, g = 0.35, b = 1 }, 
	["Warlock"] = { r = 0.58, g = 0.51, b = 0.79 }, 
	["Warrior"] = { r = 0.78, g = 0.61, b = 0.43 }, 
}

-- Initialize constants
function HeadCount:initializeConstants()
	-- Boss targets
	HeadCount:addHashValue(HeadCount.BOSS_TARGET, L["Cache of the Firelord"], L["Majordomo Executus"])
	HeadCount:addHashValue(HeadCount.BOSS_TARGET, L["Four Horsemen Chest"], L["The Four Horsemen"])
	HeadCount:addHashValue(HeadCount.BOSS_TARGET, L["Dust Covered Chest"], L["Chess Event"])
	
	-- Battlegrounds/arenas
	HeadCount:addHashValue(HeadCount.BATTLEGROUNDS, L["Alterac Valley"], true)
	HeadCount:addHashValue(HeadCount.BATTLEGROUNDS, L["Arathi Basin"], true)
	HeadCount:addHashValue(HeadCount.BATTLEGROUNDS, L["Eye of the Storm"], true)
	HeadCount:addHashValue(HeadCount.BATTLEGROUNDS, L["Warsong Gulch"], true)
	HeadCount:addHashValue(HeadCount.BATTLEGROUNDS, L["Blade's Edge Arena"], true)
	HeadCount:addHashValue(HeadCount.BATTLEGROUNDS, L["Nagrand Arena"], true)
	HeadCount:addHashValue(HeadCount.BATTLEGROUNDS, L["Ruins of Lordaeron"], true)
end

-- Add a hash table value
-- @param targetTable The table
-- @param key The key
-- @param value The value
function HeadCount:addHashValue(targetTable, key, value) 
	assert(type(targetTable) == "table", "Unable to add hash table value because targetTable is not a table.")
	assert(type(key) == "string", "Unable to add table value because the key is not a string.")

	targetTable[key] = value	
end

-- Add a list table value
-- @param targetTable The table
-- @param value The value
function HeadCount:addListValue(targetTable, value)
	assert(type(targetTable) == "table", "Unable to add list table value because targetTable is not a table.")

	table.insert(targetTable, value)
end

-- group values
local MINIMUM_GROUP_NUMBER = 1
local MAXIMUM_GROUP_NUMBER = 8

local RAID_MEMBER_SORT = {
	["Name"] = "Name", 
	["Start"] = "Start", 
	["End"] = "End", 
	["Total"] = "Total", 
}

-- "You receive loot: %sx%d"
local MULTIPLE_LOOT_SELF_REGEX = (LOOT_ITEM_SELF_MULTIPLE):gsub("%%sx%%d", "(.+)x(%%d+)")
		
-- "You receive loot: %s"
local LOOT_SELF_REGEX = (LOOT_ITEM_SELF):gsub("%%s", "(.+)")
		
-- %s receives loot: %sx%d.
local MULTIPLE_LOOT_REGEX = (LOOT_ITEM_MULTIPLE):gsub("%%s receives loot: %%sx%%d", "(.+) receives loot: (.+)x(%%d+)")

-- %s receives loot: %s.
local LOOT_REGEX = (LOOT_ITEM):gsub("%%s", "(.+)")

-- Gets the multiple loot self regex
-- @return string Returns the multiple loot self regex
function HeadCount:getMULTIPLE_LOOT_SELF_REGEX()
	return MULTIPLE_LOOT_SELF_REGEX
end

-- Gets the loot self regex
-- @return string Returns the loot self regex
function HeadCount:getLOOT_SELF_REGEX() 
	return LOOT_SELF_REGEX
end

-- Gets the multiple loot regex
-- @return string Returns the multiple loot regex
function HeadCount:getMULTIPLE_LOOT_REGEX() 
	return MULTIPLE_LOOT_REGEX
end

-- Gets the loot regex
-- @return string Returns the loot regex
function HeadCount:getLOOT_REGEX() 
	return LOOT_REGEX
end

-- Gets the raid member sort criteria.
-- @return table Returns the raid member sort criteria.
function HeadCount:getRAID_MEMBER_SORT()
	return RAID_MEMBER_SORT
end

-- Gets the minimum group number.
-- @return number Returns the minimum group number.
function HeadCount:getMINIMUM_GROUP_NUMBER() 
	return MINIMUM_GROUP_NUMBER
end

-- Gets the maximum group number.
-- @return number Returns the maximum group number.
function HeadCount:getMAXIMUM_GROUP_NUMBER() 
	return MAXIMUM_GROUP_NUMBER
end
