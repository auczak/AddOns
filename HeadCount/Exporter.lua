--[[
Project name: HeadCount
Developed by: seppyk (http://www.authority-km.com)
Website: http://www.wowace.com/wiki/HeadCount
Description: Manages tracking of raid attendance and more.
License: Creative Common Attribution-NonCommercial-ShareAlike 3.0 Unported
File: Exporter.lua
File description: Raid exporting
]]

local L = AceLibrary("AceLocale-2.2"):new("HeadCount")
local HeadCount = HeadCount

-- Exports a given raid in the configured format
-- @param raid The raid
-- @return string Returns the exported raid string
function HeadCount:exportRaid(raid)
	assert(raid, "Unable to export the raid because the raid is nil.")
	
	local exportString = nil
	
	local exportFormat = HeadCount:GetExportFormat()
	assert(exportFormat, "Unable to export raid because the export format is nil.")

	-- TODO: May want to convert this into a hash table of functions for better lookup time eventually to avoid an ever-growing switch-case statement
	if ("EQdkp" == exportFormat) then
		-- EQdkp
		exportString = HeadCount:exportEQdkp(raid) 
	elseif ("phpBB_ItemStats" == exportFormat) then
		exportString = HeadCount:exportPhpBBItemStats(raid)
	elseif ("CSV" == exportFormat) then
		exportString = HeadCount:exportCSV(raid)
	elseif ("XML" == exportFormat) then
		exportString = HeadCount:exportXML(raid)
	else
		-- phpBB
		exportString = HeadCount:exportPhpBB(raid) 
	end
	
	return exportString
end

-- Export a given raid in XML format
-- @param raid The raid
-- @return string Returns the exported XML string
function HeadCount:exportXML(raid)
	assert(raid, "Unable to export the raid into XML format because the raid is nil.")

	local exportString = ""   -- initialize as empty string	
	
	-- <raid>
	local zone = HeadCount:convertToXMLEntities(raid:getZone())
	local startTime = HeadCount:getDateTimeAsXMLString(raid:retrieveStartingTime())
	local endTime = HeadCount:getDateTimeAsXMLString(raid:retrieveEndingTime())

    local playerList = raid:retrieveOrderedPlayerList("Name", true)   
    local bossList = raid:retrieveOrderedBossList()
	local lootList = raid:getLootList()

	-- export raid information
	-- <raid>
	exportString = exportString .. '<raid generatedFrom="' .. L["product.name"].. '" majorVersion="' .. L["product.version.major"] .. '" minorVersion="' ..  L["product.version.minor"] .. '" releaseVersion="' .. L["product.version.release"] .. '">' .. "\n"
	if (zone) then
		exportString = exportString .. "\t<zone>" .. zone .. "</zone>\n"
	else
		exportString = exportString .. "\t<zone />\n"
	end
	
	exportString = exportString .. "\t<start>" .. startTime .. "</start>\n"
	exportString = exportString .. "\t<end>" .. endTime .. "</end>\n"   

	-- export player information
	-- <players>
	if ((playerList) and (# playerList > 0))then
		exportString = exportString .. "\t<players>\n"
      
		for k,v in ipairs(playerList) do			
			local name = HeadCount:convertToXMLEntities(v:getName())			
			local className = HeadCount:convertToXMLEntities(v:getClassName())			
			local guild = HeadCount:convertToXMLEntities(v:getGuild())			
			local race = HeadCount:convertToXMLEntities(v:getRace())			
			local sex = HeadCount:convertToXMLEntities(v:getRealSex())			
			local level = HeadCount:convertToXMLEntities(v:getLevel())			
			local raidDuration = HeadCount:convertToXMLEntities(v:getRaidListTime())			
			local waitDuration = HeadCount:convertToXMLEntities(v:getWaitListTime())			
			local offlineDuration = HeadCount:convertToXMLEntities(v:getOfflineTime())
			local timeList = v:getTimeList()

			exportString = exportString .. "\t\t<player>" .. "\n"
			exportString = exportString .. "\t\t\t<name>" .. name .. "</name>\n"
			exportString = exportString .. "\t\t\t<class>" .. className .. "</class>\n"
			
			if (guild) then
				exportString = exportString .. "\t\t\t<guild>" .. guild.. "</guild>\n"
			else
				exportString = exportString .. "\t\t\t<guild />\n"
			end
			
			exportString = exportString .. "\t\t\t<race>" .. race .. "</race>\n"
			exportString = exportString .. "\t\t\t<sex>" .. sex.. "</sex>\n"
			
			if (level) then
				exportString = exportString .. "\t\t\t<level>" .. level .. "</level>\n"
			else
				exportString = exportString .. "\t\t\t<level />\n"
			end
			
			exportString = exportString .. "\t\t\t<raidDuration>" .. raidDuration .. "</raidDuration>\n"   
			exportString = exportString .. "\t\t\t<waitDuration>" .. waitDuration .. "</waitDuration>\n"   
			exportString = exportString .. "\t\t\t<offlineDuration>" .. offlineDuration .. "</offlineDuration>\n"   
		 	 
			if (timeList and (# timeList > 0)) then
				exportString = exportString .. "\t\t\t<attendance>" .. "\n"
           
				for r,s in ipairs(timeList) do
					local beginTime = HeadCount:getDateTimeAsXMLString(s:getBeginTime())
					local endTime = HeadCount:getDateTimeAsXMLString(s:getEndTime())					
					local note = HeadCount:convertToXMLEntities(s:getNote())
               
					if ((beginTime) and (endTime)) then
						exportString = exportString .. "\t\t\t\t<event>\n"
						exportString = exportString .. "\t\t\t\t\t<note>" .. note .. "</note>\n"
						exportString = exportString .. "\t\t\t\t\t<start>" .. beginTime .. "</start>\n"   
						exportString = exportString .. "\t\t\t\t\t<end>" .. endTime .. "</end>\n"                 
						exportString = exportString .. "\t\t\t\t</event>\n"				
					end
				end
           
				exportString = exportString .. "\t\t\t</attendance>\n"
			else
				exportString = exportString .. "\t\t\t<attendance />\n"   
			end
			
			exportString = exportString .. "\t\t</player>\n"
		end
      
		exportString = exportString .. "\t</players>\n"
	else
		exportString = exportString .. "\t<players />\n"
	end

	-- export boss information
	-- <bossKills>
	if ((bossList) and (# bossList > 0)) then
		exportString = exportString .. "\t<bossKills>\n"
		
		for k,v in ipairs(bossList) do		
			local bossName = HeadCount:convertToXMLEntities(v:getName())		 
			local bossZone = HeadCount:convertToXMLEntities(v:getZone())
			local bossTime = HeadCount:getDateTimeAsXMLString(v:getActivityTime())
			local bossPlayerList = v:getPlayerList()
         
			exportString = exportString .. "\t\t<boss>\n"
			exportString = exportString .. "\t\t\t<name>" .. bossName .. "</name>\n"
			
			if (bossZone) then 
				exportString = exportString .. "\t\t\t<zone>" .. bossZone .. "</zone>\n"
			else
				exportString = exportString .. "\t\t\t<zone />\n"
			end
			
			exportString = exportString .. "\t\t\t<time>" .. bossTime .. "</time>\n"

			if ((bossPlayerList) and (# bossPlayerList > 0)) then
				exportString = exportString .. "\t\t\t<players>\n"
   
				for r,s in ipairs(bossPlayerList) do			
					exportString = exportString .. "\t\t\t\t<player>" .. HeadCount:convertToXMLEntities(s) .. "</player>\n"
				end
           
				exportString = exportString .. "\t\t\t</players>\n"   
			else
				exportString = exportString .. "\t\t\t<players />\n"
			end
         
			exportString = exportString .. "\t\t</boss>\n"   
		end
		
		exportString = exportString .. "\t</bossKills>\n"
	else
		exportString = exportString .. "\t<bossKills />\n"
	end

	-- export loot information
	-- <loot>
	if ((lootList) and (# lootList > 0)) then
		exportString = exportString .. "\t<loot>\n"
     
		for k,v in ipairs(lootList) do
			local itemId  = HeadCount:convertToXMLEntities(v:getItemId())
			local lootZone = HeadCount:convertToXMLEntities(v:getZone())		 
			local itemQuantity = HeadCount:convertToXMLEntities(v:getQuantity())
			local itemLooter = HeadCount:convertToXMLEntities(v:getPlayerName())
			local lootTime = HeadCount:getDateTimeAsXMLString(v:getActivityTime())		 
			local itemCost = HeadCount:convertToXMLEntities(v:getCost())
			local lootSource = HeadCount:convertToXMLEntities(v:getSource())
			
			local itemName = HeadCount:convertToXMLEntities(v:getName())			
			local itemRarity = HeadCount:convertToXMLEntities(v:getRarity())
			local itemLevel = HeadCount:convertToXMLEntities(v:getLevel()) 
			local itemType = HeadCount:convertToXMLEntities(v:getItemType())  
			local itemSubType = HeadCount:convertToXMLEntities(v:getItemSubType())  
			local itemTexture = HeadCount:convertToXMLEntities(v:getTexture())  
			
			exportString = exportString .. "\t\t<item>\n"
			exportString = exportString .. "\t\t\t<id>" .. itemId .. "</id>\n"     
			
			if (itemName) then
				exportString = exportString .. "\t\t\t<name>" .. itemName .. "</name>\n"         
			else
				exportString = exportString .. "\t\t\t<name>" .. L["Item unavailable"] .. "</name>\n"         
			end
			
			exportString = exportString .. "\t\t\t<looter>" .. itemLooter .. "</looter>\n"

			if (lootSource) then
				exportString = exportString .. "\t\t\t<source>" .. lootSource.. "</source>\n"
			else
				exportString = exportString .. "\t\t\t<source />\n"
			end
			
			exportString = exportString .. "\t\t\t<time>" .. lootTime .. "</time>\n"
			exportString = exportString .. "\t\t\t<zone>" .. lootZone .. "</zone>\n"     
			exportString = exportString .. "\t\t\t<quantity>" .. itemQuantity .. "</quantity>\n"   			
			exportString = exportString .. "\t\t\t<cost>" .. itemCost .. "</cost>\n"         

			if (itemRarity) then
				exportString = exportString .. "\t\t\t<rarity>" .. itemRarity .. "</rarity>\n"
			else
				exportString = exportString .. "\t\t\t<rarity />\n"
			end
			
			if (itemLevel) then
				exportString = exportString .. "\t\t\t<level>" .. itemLevel .. "</level>\n"
			else
				exportString = exportString .. "\t\t\t<level />\n"
			end
			
			if (itemType) then
				exportString = exportString .. "\t\t\t<type>" .. itemType .. "</type>\n"
			else
				exportString = exportString .. "\t\t\t<type />\n"
			end

			if (itemSubType) then
				exportString = exportString .. "\t\t\t<subType>" .. itemSubType .. "</subType>\n"
			else
				exportString = exportString .. "\t\t\t<subType />\n"
			end

			if (itemTexture) then
				exportString = exportString .. "\t\t\t<texture>" .. itemTexture .. "</texture>\n"
			else
				exportString = exportString .. "\t\t\t<texture />\n"
			end
			
			exportString = exportString .. "\t\t</item>\n"
		end     
	
		exportString = exportString .. "\t</loot>\n"
	else
		exportString = exportString .. "\t<loot />\n"
	end
   
	exportString = exportString .. "</raid>\n" 	
	
	return exportString
end

-- Export a given raid in CSV format
-- @param raid The raid
-- @return string Returns the exported CSV string
function HeadCount:exportCSV(raid)
	assert(raid, "Unable to export the raid into CSV format because the raid is nil.")
   
	local exportString = ""   -- initialize as empty string
   
	local zone = raid:getZone()
      
    local raidStartTime = raid:retrieveStartingTime()
    local raidEndTime = raid:retrieveEndingTime()      

    -- output the field list
    exportString = L["Zone"] .. "," .. L["Date"] .. "," .. L["Length"] .. "," .. L["Player"] .. "," .. L["Raid list time"] .. "," .. L["Wait list time"] .. "," .. L["Offline time"] .. "\n"
   
    local orderedPlayerList = raid:retrieveOrderedPlayerList("Name", true)   
	if ((# orderedPlayerList) > 0) then
		for k,v in ipairs(orderedPlayerList) do
			local raidListTime = v:getRaidListTime()
			local waitListTime = v:getWaitListTime()
			local offlineTime = v:getOfflineTime()  
		 
			-- zone
			if (zone) then
				exportString = exportString .. "\"" .. zone .. "\","
			else
				exportString = exportString .. "\"" .. L["None"] .. "\","
			end
			
			-- date
			exportString = exportString .. HeadCount:getDateAsString(raidStartTime) .. ","
			
			-- length
			local timeDifference = HeadCount:computeTimeDifference(raidEndTime, raidStartTime)
			exportString = exportString .. HeadCount:getSecondsAsString(timeDifference) .. ","

			-- player name
			exportString = exportString .. "\"" .. v:getName() .. "\","
			
			-- raid list time
			exportString = exportString .. HeadCount:getSecondsAsString(raidListTime) .. ","
			
			-- wait list time
			exportString = exportString .. HeadCount:getSecondsAsString(waitListTime) .. ","
			
			-- offline time
			exportString = exportString .. HeadCount:getSecondsAsString(offlineTime) .. "\n"
      end
   end   
   
   return exportString
end 

-- Export a given raid in phpBB format with item stats
-- @param raid The raid
-- @return string Returns the exported phpBB string
function HeadCount:exportPhpBBItemStats(raid) 
	assert(raid, "Unable to export the raid into phpBB format because the raid is nil.")
	
	local exportString = ""	-- initialize as empty string
	
	local zone = raid:getZone()
	if (zone) then
		exportString = exportString .. "[b][u]" .. zone .. "[/b][/u]\n"   
	end 
		
    local raidStartTime = raid:retrieveStartingTime()
    local raidEndTime = raid:retrieveEndingTime()		
	exportString = exportString .. "[i]" .. HeadCount:getDateTimeAsString(raidStartTime) .. " - " .. HeadCount:getDateTimeAsString(raidEndTime) .."[/i]\n\n"
	
    local orderedPlayerList = raid:retrieveOrderedPlayerList("Name", true)	
    exportString = exportString .. "[b]" .. L["Players"] .. ":[/b]\n"
	if ((# orderedPlayerList) > 0) then 
		exportString = exportString .. "[list]\n"
		for k,v in ipairs(orderedPlayerList) do
			local waitTime = v:getWaitListTime()
			local offlineTime = v:getOfflineTime()		
			exportString = exportString .. "[*]" .. v:getName() .. " [i](" .. v:getClassName() .. ")[/i]\n"
			exportString = exportString .. "[i]" .. L["Raid"] .. ": " .. HeadCount:getSecondsAsString(v:getRaidListTime()) .. ", [/i]"
			exportString = exportString .. "[i]" .. L["Standby"] .. ": " .. HeadCount:getSecondsAsString(v:getWaitListTime()) .. ", [/i]"
			exportString = exportString .. "[i]" .. L["Offline"] .. ": " .. HeadCount:getSecondsAsString(v:getOfflineTime()) .. "[/i]\n"
		end
		exportString = exportString .. "[/list]\n\n"
	else
		exportString = exportString .. L["None"] .. "\n\n"
	end

    if (raid:getBossList()) then
        -- boss list is present	
		exportString = exportString .. "[b]" .. L["Boss kills"] .. ":[/b]\n"
        local orderedBossList = raid:retrieveOrderedBossList()
		
		if ((# orderedBossList) > 0) then
			exportString = exportString .. "[list]\n"		
			for k,v in ipairs(orderedBossList) do
				exportString = exportString .. "[*]" .. v:getName() .. " at " .. HeadCount:getDateTimeAsString(v:getActivityTime()) .. "\n"
			end
			exportString = exportString .. "[/list]\n\n"
		else
			exportString = exportString .. L["None"] .. "\n\n"
		end
    end

	local lootList = raid:getLootList()
    exportString = exportString .. "[b]" .. L["Loot"] .. ":[/b]\n"
    
	if ((# lootList) > 0) then
		exportString = exportString .. "[list]\n"	
	    for k,v in ipairs(raid:getLootList()) do
			local lootName = v:getName()
			local color = HeadCount:retrieveItemColor(v:getRarity())
			if (lootName) then
				exportString = exportString .. "[*] [item]" .. lootName .. "[/item] by " .. v:getPlayerName() .. "\n"
			else
				exportString = exportString .. "[*] " .. L["Item unavailable"] .. " by " .. v:getPlayerName() .. "\n"		
			end	
	    end
	    exportString = exportString .. "[/list]\n"	
	else
		exportString = exportString .. L["None"] .. "\n"	
	end
	
	return exportString
end

-- Export a given raid in phpBB format
-- @param raid The raid
-- @return string Returns the exported phpBB string
function HeadCount:exportPhpBB(raid) 
	assert(raid, "Unable to export the raid into phpBB format because the raid is nil.")
	
	local exportString = ""	-- initialize as empty string
	
	local zone = raid:getZone()
	if (zone) then
		exportString = exportString .. "[b][u]" .. zone .. "[/b][/u]\n"   
	end 
		
    local raidStartTime = raid:retrieveStartingTime()
    local raidEndTime = raid:retrieveEndingTime()		
	exportString = exportString .. "[i]" .. HeadCount:getDateTimeAsString(raidStartTime) .. " - " .. HeadCount:getDateTimeAsString(raidEndTime) .."[/i]\n\n"
	
    local orderedPlayerList = raid:retrieveOrderedPlayerList("Name", true)	
    exportString = exportString .. "[b]" .. L["Players"] .. ":[/b]\n"
	if ((# orderedPlayerList) > 0) then 
		exportString = exportString .. "[list]\n"
		for k,v in ipairs(orderedPlayerList) do
			local waitTime = v:getWaitListTime()
			local offlineTime = v:getOfflineTime()		
			exportString = exportString .. "[*]" .. v:getName() .. " [i](" .. v:getClassName() .. ")[/i]\n"
			exportString = exportString .. "[i]" .. L["Raid"] .. ": " .. HeadCount:getSecondsAsString(v:getRaidListTime()) .. ", [/i]"
			exportString = exportString .. "[i]" .. L["Standby"] .. ": " .. HeadCount:getSecondsAsString(v:getWaitListTime()) .. ", [/i]"
			exportString = exportString .. "[i]" .. L["Offline"] .. ": " .. HeadCount:getSecondsAsString(v:getOfflineTime()) .. "[/i]\n"
		end
		exportString = exportString .. "[/list]\n\n"
	else
		exportString = exportString .. L["None"] .. "\n\n"
	end

    if (raid:getBossList()) then
        -- boss list is present	
		exportString = exportString .. "[b]" .. L["Boss kills"] .. ":[/b]\n"
        local orderedBossList = raid:retrieveOrderedBossList()
		
		if ((# orderedBossList) > 0) then
			exportString = exportString .. "[list]\n"		
			for k,v in ipairs(orderedBossList) do
				exportString = exportString .. "[*]" .. v:getName() .. " at " .. HeadCount:getDateTimeAsString(v:getActivityTime()) .. "\n"
			end
			exportString = exportString .. "[/list]\n\n"
		else
			exportString = exportString .. L["None"] .. "\n\n"
		end
    end

	local lootList = raid:getLootList()
    exportString = exportString .. "[b]" .. L["Loot"] .. ":[/b]\n"
    
	if ((# lootList) > 0) then
		exportString = exportString .. "[list]\n"	
	    for k,v in ipairs(raid:getLootList()) do
			local lootName = v:getName()
			local color = HeadCount:retrieveItemColor(v:getRarity())
			if (lootName) then
				exportString = exportString .. "[*] [url=http://www.wowhead.com/?item=" .. v:getItemId() .. "][color=#" .. color .. "][b]" .. lootName .. "[/b][/color][/url] by " .. v:getPlayerName() .. "\n"
			else
				exportString = exportString .. "[*] [url=http://www.wowhead.com/?item=" .. v:getItemId() .. "][b]" .. L["Item unavailable"] .. "[/b][/url] by " .. v:getPlayerName() .. "\n"		
			end	
	    end
	    exportString = exportString .. "[/list]\n"	
	else
		exportString = exportString .. L["None"] .. "\n"	
	end
	
	return exportString
end

-- Export a given raid in EQdkp format
-- @param raid The raid
-- @return string Returns the exported EQdkp string
function HeadCount:exportEQdkp(raid) 
	assert(raid, "Unable to export the raid into EQdkp format because the raid is nil.")
	
	local raidStartTime = raid:retrieveStartingTime()	-- raid start time
	local raidEndTime = raid:retrieveEndingTime()		-- raid end time

	local exportString = "<RaidInfo>"	
	exportString = exportString .. "<key>" .. HeadCount:getEQdkpDateTimeAsString(raidStartTime) .. "</key>"
	exportString = exportString .. "<start>" .. HeadCount:getEQdkpDateTimeAsString(raidStartTime)  .. "</start>"
	exportString = exportString .. "<end>" .. HeadCount:getEQdkpDateTimeAsString(raidEndTime) .. "</end>"		
			
	local zone = raid:getZone()	-- raid zone
	if (zone) then 
		exportString = exportString .. "<zone>" .. zone .. "</zone>"	
	end
		
	local orderedPlayerList = raid:retrieveOrderedPlayerList("Name", true) 		
	exportString = exportString .. "<PlayerInfos>"
	for k,v in ipairs(orderedPlayerList) do
		exportString = exportString .. "<key" .. k .. ">"
		exportString = exportString .. "<name>" .. v:getName() .. "</name>"
		exportString = exportString .. "<race>" .. v:getRace() .. "</race>"
		if (v:getGuild()) then
			exportString = exportString .. "<guild>" .. v:getGuild() .. "</guild>"
		end
		exportString = exportString .. "<sex>" .. v:getSex() .. "</sex>"
		exportString = exportString .. "<class>" .. string.upper(v:getClassName()) .. "</class>"
		if (v:getLevel() > 0) then
			exportString = exportString .. "<level>" .. v:getLevel() .. "</level>"
		else
			exportString = exportString .. "<level>" .. HeadCount.DEFAULT_LEVEL .. "</level>"
		end
		exportString = exportString .. "</key" .. k .. ">"
	end
	exportString = exportString .. "</PlayerInfos>"

	-- <BossKills>
	-- 	<key1><name>%bossname%</name><time>%date%</time><attendees><key1><name>%playername1%</name><name>%playername2%</name></key1></attendees></key1>
	-- 	<key2><name>%bossname%</name><time>%date%</time><attendees><key1><name>%playername1%</name><name>%playername2%</name></key1></attendees></key2>	
	-- </BossKills>	
	exportString = exportString .. "<BossKills>"
	if (raid:getBossList()) then 
		-- boss list is present
		local orderedBossList = raid:retrieveOrderedBossList()
		for k,v in ipairs(orderedBossList) do 
			exportString = exportString .. "<key" .. k .. ">"
			exportString = exportString .. "<name>" .. v:getName() .. "</name>"
			exportString = exportString .. "<time>" .. HeadCount:getEQdkpDateTimeAsString(v:getActivityTime()) .. "</time>"
			exportString = exportString .. "<attendees>"
			
			local attendeeList = v:getPlayerList()
			for attendeeIndex,attendeeName in ipairs(attendeeList) do
				exportString = exportString .. "<key" .. attendeeIndex .. ">"
				exportString = exportString .. "<name>" .. attendeeName .. "</name>"
				exportString = exportString .. "</key" .. attendeeIndex .. ">"
			end
			
			exportString = exportString .. "</attendees>"
			exportString = exportString .. "</key" .. k .. ">"
		end
	end
	exportString = exportString .. "</BossKills>"		
		
	if (zone) then 
		exportString = exportString .. "<note><![CDATA[ - Zone: " .. zone .. "]]></note>"	
	else
		exportString = exportString .. "<note></note>"
	end
		
	exportString = exportString .. "<Join>"
	for k,v in ipairs(orderedPlayerList) do
		exportString = exportString .. "<key" .. k .. ">"
		exportString = exportString .. "<player>" .. v:getName() .. "</player>"
		exportString = exportString .. "<race>" .. v:getRace() .. "</race>"
		exportString = exportString .. "<class>" .. string.upper(v:getClassName()) .. "</class>"
		exportString = exportString .. "<sex>" .. v:getSex() .. "</sex>"			
		if (v:getLevel() > 0) then
			exportString = exportString .. "<level>" .. v:getLevel() .. "</level>"
		else
			exportString = exportString .. "<level>" .. HeadCount.DEFAULT_LEVEL .. "</level>"
		end
		exportString = exportString .. "<time>" ..HeadCount:getEQdkpDateTimeAsString(v:retrieveStartingTime()) .. "</time>"			
		exportString = exportString .. "</key" .. k .. ">"
	end		
	exportString = exportString .. "</Join>"

	exportString = exportString .. "<Leave>"
	for k,v in ipairs(orderedPlayerList) do
		exportString = exportString .. "<key" .. k .. ">"
		exportString = exportString .. "<player>" .. v:getName() .. "</player>"			
		exportString = exportString .. "<time>" .. HeadCount:getEQdkpDateTimeAsString(v:retrieveEndingTime()) .. "</time>"
		exportString = exportString .. "</key" .. k .. ">"
	end		
	exportString = exportString .. "</Leave>"
		
	exportString = exportString .. "<Loot>"
	for k,v in ipairs(raid:getLootList()) do
		exportString = exportString .. "<key" .. k .. ">"
		
		local lootName = v:getName()
		if (lootName) then
			exportString = exportString .. "<ItemName>" .. lootName .. "</ItemName>"
		end
		
		local lootId = v:getItemId() 
		if (lootId) then
			exportString = exportString .. "<ItemID>" .. lootId .. "</ItemID>" 
		end
		
		local textureIcon = v:retrieveTextureIcon()
		if (textureIcon) then 
			exportString = exportString .. "<Icon>" .. textureIcon .. "</Icon>" 
		end
		
		local lootItemType = v:getItemType()
		if (lootItemType) then
			exportString = exportString .. "<Class>" .. lootItemType .. "</Class>"
		end
		
		local lootItemSubType = v:getItemSubType()
		if (lootItemSubType) then
			exportString = exportString .. "<SubClass>" .. lootItemSubType .. "</SubClass>"
		end
		
		local lootColor = v:retrieveColor()
		if (lootColor) then
			exportString = exportString .. "<Color>" .. lootColor .. "</Color>"
		end
		exportString = exportString .. "<Count>" .. v:getQuantity() .. "</Count>"
		exportString = exportString .. "<Player>" .. v:getPlayerName() .. "</Player>"
		
		local lootCost = v:getCost()
		if (not lootCost) then
			lootCost = 0
		end				
		exportString = exportString .. "<Costs>" .. lootCost .. "</Costs>"
		exportString = exportString .. "<Time>" .. HeadCount:getEQdkpDateTimeAsString(v:getActivityTime()) .. "</Time>"
		
		local lootNote = "<![CDATA["		
		local lootZone = v:getZone()
		if (lootZone) then 
			-- loot zone present
			lootNote = lootNote .. " - Zone: " .. lootZone	-- add to note
			exportString = exportString .. "<Zone>" .. lootZone .. "</Zone>"	
		else
			exportString = exportString .. "<Zone />"
		end			
		
		local lootSource = v:getSource()
		if (lootSource) then
			-- loot source present
			lootNote = lootNote .. " - Boss: " .. lootSource -- add to note
			exportString = exportString .. "<Boss>" .. lootSource .. "</Boss>"
		else
			exportString = exportString .. "<Boss />"
		end
		
		lootNote = lootNote .. " - " .. lootCost .. " DKP]]>"	-- add cost to note
		exportString = exportString .. "<Note>" .. lootNote .. "</Note>"
		exportString = exportString .. "</key" .. k .. ">"			
	end		
	exportString = exportString .. "</Loot>"
		
	exportString = exportString .. "</RaidInfo>"
	
	return exportString	
end
