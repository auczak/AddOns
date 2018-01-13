--[[
Project name: HeadCount
Developed by: seppyk (http://www.authority-km.com)
Website: http://www.wowace.com/wiki/HeadCount
Description: Manages tracking of raid attendance and more.
License: Creative Common Attribution-NonCommercial-ShareAlike 3.0 Unported
File: HeadCountUtil.lua
File description: Utility functions
]]

local L = AceLibrary("AceLocale-2.2"):new("HeadCount")
local HeadCount = HeadCount

-- Converts a string to a proper name (first letter capitalized, remainder of string in lower case).
-- @param originalString The original string to convert.
function HeadCount:convertStringToProperName(originalString)
	return string.gsub(string.lower(originalString), "%a", string.upper, 1)	-- string in all lowercase except for first letter in uppercase
end

-- Splits a string by a given pattern.
-- @param originalString The original string.
-- @param pattern The delimiter pattern.
-- @return table Returns a table of the split string.
function HeadCount:split(originalString, pattern)
	local temp = {}
	local fPattern = "(.-)" .. pattern
	local lastEnd = 1
	local s, e, cap = originalString:find(fPattern, 1)
	while s do
		if ((s ~= 1) or (cap ~= "")) then
			table.insert(temp, cap)
		end

		lastEnd = e + 1
		s, e, cap = originalString:find(fPattern, lastEnd)
	end
   
	if (lastEnd <= # originalString) then
		cap = originalString:sub(lastEnd)
		table.insert(temp, cap)
	end
	
	return temp
end

-- Gets the current UTC date and time in seconds
-- @return Returns the current UTC date and time in seconds.
function HeadCount:getUTCDateTimeInSeconds() 
	local utcDateTime = date("!*t")
	
	return time(utcDateTime)
end

-- Gets the display date and time as a string
-- @param activityTime The activity time.
-- @return string Returns the display date and time as a string
function HeadCount:getDateTimeAsString(activityTime) 
	-- TODO: Add locale to this method to display time in various localized formats
	local currentSeconds = activityTime:getUTCDateTimeInSeconds()	-- UTC date and time in seconds

	local displayTimezoneDifferenceInSeconds = HeadCount:GetTimezone() * 60 * 60 -- seconds
	currentSeconds = currentSeconds + displayTimezoneDifferenceInSeconds			 -- display time in seconds
	local displayDateTime = date("*t", currentSeconds)
	
	local datetimeString = nil
	if (HeadCount:IsTimeFormatEnabled()) then 
		-- 24 hour clock
		datetimeString =  displayDateTime.month .. "/" .. displayDateTime.day .. "/" .. displayDateTime.year .. " " .. string.format("%02d", displayDateTime.hour) .. ":" .. string.format("%02d", displayDateTime.min) .. ":" .. string.format("%02d", displayDateTime.sec)		
	else
		-- 12 hour clock 
		local hour = displayDateTime.hour
		if (displayDateTime.hour <= 11) then 
			-- 00:00 - 11:59  (am) 
			if (0 == displayDateTime.hour) then 
				hour = displayDateTime.hour + 12 
			end 
			
			datetimeString =  displayDateTime.month .. "/" .. displayDateTime.day .. "/" .. displayDateTime.year .. " " .. string.format("%d", hour) .. ":" .. string.format("%02d", displayDateTime.min) .. ":" .. string.format("%02d", displayDateTime.sec) .. L["am"]			
		else
			-- 12:00 - 23:59 (pm)
			if (displayDateTime.hour >= 13) then 
				hour = displayDateTime.hour - 12
			end
			
			datetimeString =  displayDateTime.month .. "/" .. displayDateTime.day .. "/" .. displayDateTime.year .. " " .. string.format("%d", hour) .. ":" .. string.format("%02d", displayDateTime.min) .. ":" .. string.format("%02d", displayDateTime.sec) .. L["pm"]			
		end
	end
	
	return datetimeString
end

-- Gets the date and time as a EQdkp string
-- @param activityTime The activity time.
-- @return string Returns the display date and time as a EQdkp string
function HeadCount:getEQdkpDateTimeAsString(activityTime) 
	local dateTimeString = nil
		
	if (activityTime) then 
		local currentSeconds = activityTime:getUTCDateTimeInSeconds()		-- UTC date and time in seconds

		local displayTimezoneDifferenceInSeconds = HeadCount:GetTimezone() * 60 * 60 -- seconds
		currentSeconds = currentSeconds + displayTimezoneDifferenceInSeconds			 -- display time in seconds
		local displayDateTime = date("*t", currentSeconds)
		
		assert(displayDateTime.year >= 1000, "HeadCount does not support low-value years.")
		local millenium = math.floor(displayDateTime.year / 1000)
		local year = displayDateTime.year - (millenium * 1000)

		dateTimeString =  string.format("%02d", displayDateTime.month) .. "/" .. string.format("%02d", displayDateTime.day) .. "/" .. string.format("%02d", year) .. " " .. string.format("%02d", displayDateTime.hour) .. ":" .. string.format("%02d", displayDateTime.min) .. ":" .. string.format("%02d", displayDateTime.sec)			
	end
	
	return dateTimeString
end


-- Gets the display date as a string
-- @param currentTime The current time.
-- @return Returns the display time as a string
function HeadCount:getDateAsString(currentTime) 
	-- TODO: Add locale to this method to display time in various localized formats
	local currentSeconds = currentTime:getUTCDateTimeInSeconds()		-- UTC date and time in seconds
	
	local displayTimezoneDifferenceInSeconds = HeadCount:GetTimezone() * 60 * 60 -- seconds
	currentSeconds = currentSeconds + displayTimezoneDifferenceInSeconds			 -- display time in seconds
	local displayDateTime = date("*t", currentSeconds)
	
	return displayDateTime.month .. "/" .. displayDateTime.day .. "/" .. displayDateTime.year
end

-- Gets the display time as a string
-- @param activityTime The activity time.
-- @return Returns the display time as a string
function HeadCount:getTimeAsString(activityTime) 
	-- TODO: Add locale to this method to display time in various localized formats
	local timeString = "00:00:00"
	
	if (activityTime) then	
		local currentSeconds = activityTime:getUTCDateTimeInSeconds()		-- UTC date and time in seconds
	
		local displayTimezoneDifferenceInSeconds = HeadCount:GetTimezone() * 60 * 60 -- seconds
		currentSeconds = currentSeconds + displayTimezoneDifferenceInSeconds			 -- display time in seconds
		local displayDateTime = date("*t", currentSeconds)
		
		local datetimeString = nil
		if (HeadCount:IsTimeFormatEnabled()) then 
			-- 24 hour clock
			timeString = string.format("%02d", displayDateTime.hour) .. ":" .. string.format("%02d", displayDateTime.min) .. ":" .. string.format("%02d", displayDateTime.sec) 
		else
			-- 12 hour clock 
			local hour = displayDateTime.hour
			if (displayDateTime.hour <= 11) then 
				-- 00:00 - 11:59  (am) 
				if (0 == displayDateTime.hour) then 
					hour = displayDateTime.hour + 12 
				end 
			
				timeString = string.format("%d", hour) .. ":" .. string.format("%02d", displayDateTime.min) .. ":" .. string.format("%02d", displayDateTime.sec) .. L["am"]
			else
				-- 12:00 - 23:59 (pm)
				if (displayDateTime.hour >= 13) then 
					hour = displayDateTime.hour - 12
				end
			
				timeString = string.format("%d", hour) .. ":" .. string.format("%02d", displayDateTime.min) .. ":" .. string.format("%02d", displayDateTime.sec) .. L["pm"]
			end
		end
	end
	
	return timeString
end

-- Gets a time string based on number of seconds.
-- @param totalSeconds The total seconds.
function HeadCount:getSecondsAsString(totalSeconds) 
	local secondsString = nil
	local remainingSeconds
	
	if (totalSeconds > 0) then
		local numberOfHours = math.floor(totalSeconds / 3600)			
		remainingSeconds = totalSeconds - (numberOfHours * 3600)
	
		local numberOfMinutes = math.floor(remainingSeconds / 60)
		remainingSeconds = remainingSeconds - (numberOfMinutes * 60)
		
		secondsString = string.format("%02d:%02d:%02d", numberOfHours, numberOfMinutes, remainingSeconds)
	else
		secondsString = "00:00:00" 
	end
	
	return secondsString	
end

-- Computes the time difference between a current date and an original date.
-- @param currentTime The current time.
-- @param originalTime The original time.
-- @return number Returns the time difference in seconds between the current date and an original date.
function HeadCount:computeTimeDifference(currentTime, originalTime) 
	local timeDifference = 0
	
	if ((currentTime) and (originalTime)) then
		local currentSeconds = currentTime:getUTCDateTimeInSeconds()
		local originalSeconds = originalTime:getUTCDateTimeInSeconds()
			
		timeDifference = difftime(currentSeconds, originalSeconds)
	end
	
	return timeDifference
end
	
-- Converts a boolean value to its localized string equivalent.
-- @param booleanValue The boolean value.
-- @return string Returns "true" if the boolean value is true, "false" otherwise
function HeadCount:convertBooleanToString(booleanValue) 
	if (booleanValue) then
		-- boolean value is not nil -> true
		return L["true"]
	else
		-- boolean value is nil -> false
		return L["false"]		
	end
end

-- Converts a boolean value to its localized string equivalent.
-- @param booleanValue The boolean value.
-- @return string Returns "true" if the boolean value is true, "false" otherwise
function HeadCount:convertBooleanToYesNoString(booleanValue) 
	if (booleanValue) then
		-- boolean value is not nil -> true
		return L["Yes"]
	else
		-- boolean value is nil -> false
		return L["No"]		
	end
end

-- Determines if a given string is a number
-- @param numberString The number string.
-- @return boolean Returns true if the string is a valid number and false otherwise.
function HeadCount:isNumber(numberString)
	local isValid = false
	
	if (numberString) then
		isValid = string.find(numberString, "^(%d+%.?%d*)$")
	end
	
	return isValid
end

-- Determines if the given string is non-empty
-- @param value The string.
-- @return boolean Returns true if the string is a valid string and false otherwise.
function HeadCount:isString(value)
	local isValid = false

	if ((value) and (string.len(value) > 0)) then
		-- string is not null and greater than 0 characters
		isValid = true
	end
	
	return isValid
end

-- Determines if the player is in a raid instance
-- @return boolean Returns true if the player is in a raid instance and false otherwise.
function HeadCount:isRaidInstance()
	local isPresent = false

	local isPresentInInstance, instanceType = IsInInstance()	
	if ((isPresentInInstance) and (instanceType == "raid")) then
		-- player is in a raid instance
		isPresent = true
	end
	
	return isPresent
end

-- Determines the boss encounter name
-- @param name The boss name
-- @return encounterName Returns the boss encounter name
function HeadCount:retrieveBossEncounterName(name)
	assert(name, "Unable to retrieve boss encounter name because the name is nil.")
	
	local encounterName = nil
	
	if (L.bossEncounterList[name]) then
		-- special boss encounter name
		encounterName = L.bossEncounterList[name]
	else
		-- encounter name is the boss
		encounterName = name
	end		
	
	return encounterName
end

-- Determines if the zone is a battleground/arena zone
function HeadCount:isBattlegroundZone(zone) 
	assert(zone, "Unable to determine if zone is a battleground because the zone is nil.")

	local isBattleground = false

	local inInstance, instanceType = IsInInstance()	
	if ((HeadCount.BATTLEGROUNDS[zone]) or (instanceType == "pvp") or (instanceType == "arena")) then 
		-- zone is a battleground or arena
		isBattleground = true
	end
	
	return isBattleground
end

-- Retrieves the item color based on item rarity
function HeadCount:retrieveItemColor(rarity)
	local color = HeadCount.DEFAULT_COLOR_NO_ALPHA
	
	if (rarity) then
		if ((rarity >= 0) and (rarity <= 6)) then
			local lookupRarity = rarity + 1	
			color = HeadCount.ITEM_COLORS_NO_ALPHA[lookupRarity]
		end
	end
	
	return color
end

-- Escape characters into XML entities
-- @param value The string to convert
-- @return string Returns the converted entity string
function HeadCount:convertToXMLEntities(value)
	local xmlString = nil
   
	if (value) then 
		xmlString = value
        xmlString = string.replace(xmlString, "&", "&amp;" )
        xmlString = string.replace(xmlString,  "<", "&lt;" )
        xmlString = string.replace(xmlString,  ">", "&gt;" )
        xmlString = string.replace(xmlString,  "\"", "&quot;" )
        xmlString = string.replace(xmlString,  "'", "&apos;" )
	end
   
	return xmlString   	
end

-- Converts a time to a W3C international standard date and time string  (ISO 8601)
-- @param activityTime The activity time.
-- @return string Returns the display date and time as a ISO 8601 string
function HeadCount:getDateTimeAsXMLString(activityTime)
   local dateTimeString = nil
      
	if (activityTime) then
		local currentSeconds = activityTime:getUTCDateTimeInSeconds()      -- UTC date and time in seconds

		local displayDateTime = date("*t", currentSeconds)

		-- Example: July 7, 2008 3:46:42 UTC is equivalent to 2008-07-07T03:46:42Z
		dateTimeString =  string.format("%04d", displayDateTime.year) .. "-" .. string.format("%02d", displayDateTime.month) .. "-" .. string.format("%02d", displayDateTime.day) .. "T" .. string.format("%02d", displayDateTime.hour) .. ":" .. string.format("%02d", displayDateTime.min) .. ":" .. string.format("%02d", displayDateTime.sec) .. "Z"
	end
   
	return dateTimeString
end 
