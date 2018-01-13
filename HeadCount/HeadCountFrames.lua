--[[
Project name: HeadCount
Developed by: seppyk (http://www.authority-km.com)
Website: http://www.wowace.com/wiki/HeadCount
Description: Manages tracking of raid attendance and more.
License: Creative Common Attribution-NonCommercial-ShareAlike 3.0 Unported
File: HeadCountFrames.lua
File description: GUI application logic
]]


local L = AceLibrary("AceLocale-2.2"):new("HeadCount")
local dewdrop = AceLibrary("Dewdrop-2.0")
local HeadCount = HeadCount

local content = {
	["boss"] = "Raid bosses", 
	["raid"] = "Raid members",
	["loot"] = "Raid loot", 
	["player"] = "Player", 
	["snapshot"] = "Snapshot", 
	["default"] = "Default", 
}

local confirmType = {
	["boss"] = "boss", 
	["raid"] = "raid", 
	["member"] = "member", 
	["loot"] = "loot", 
	["endraid"] = "endraid", 
	["removeall"] = "removeall", 
}

-- ***********************************
-- MAIN FUNCTIONS
-- ***********************************
-- Main update process
function HeadCount:HeadCountFrame_Update()
	-- Update everything
	HeadCount:HeadCountFrameRaidHistoryContentScroll_Update()

	if (HeadCountFrame.contentType == content["raid"]) then
		-- members
		HeadCount:HeadCountFrameContentMembersScroll_Update()
		HeadCountFrameContentPlayer:Hide()
		HeadCountFrameContentBoss:Hide()
		HeadCountFrameContentSnapshot:Hide() 			
		HeadCountFrameContentLoot:Hide()		
		HeadCountFrameContentMembers:Show()		
	elseif (HeadCountFrame.contentType == content["boss"]) then 
		-- bosses
		HeadCount:HeadCountFrameContentBossScroll_Update()		
		HeadCountFrameContentMembers:Hide()		
		HeadCountFrameContentPlayer:Hide()
		HeadCountFrameContentSnapshot:Hide() 			
		HeadCountFrameContentLoot:Hide()				
		HeadCountFrameContentBoss:Show()		
	elseif (HeadCountFrame.contentType == content["loot"]) then 
		-- loot
		HeadCount:HeadCountFrameContentLootScroll_Update()		
		HeadCountFrameContentMembers:Hide()		
		HeadCountFrameContentPlayer:Hide()
		HeadCountFrameContentBoss:Hide()		
		HeadCountFrameContentSnapshot:Hide() 			
		HeadCountFrameContentLoot:Show()		
	elseif (HeadCountFrame.contentType == content["player"]) then
		-- player information
		HeadCount:HeadCountFrameContentPlayerScroll_Update()		
		HeadCountFrameContentMembers:Hide()
		HeadCountFrameContentBoss:Hide()		
		HeadCountFrameContentSnapshot:Hide() 			
		HeadCountFrameContentLoot:Hide()			
		HeadCountFrameContentPlayer:Show() 
	elseif (HeadCountFrame.contentType == content["snapshot"]) then
		HeadCount:HeadCountFrameContentSnapshotScroll_Update()		
		HeadCountFrameContentMembers:Hide()
		HeadCountFrameContentBoss:Hide()		
		HeadCountFrameContentLoot:Hide()		
		HeadCountFrameContentPlayer:Hide() 	
		HeadCountFrameContentSnapshot:Show() 	
	else
		-- default, hide all content frames
		HeadCountFrameContentMembers:Hide()
		HeadCountFrameContentBoss:Hide()
		HeadCountFrameContentSnapshot:Hide() 			
		HeadCountFrameContentLoot:Hide()		
		HeadCountFrameContentPlayer:Hide() 				 	
		HeadCount:HeadCountFrameContentTitleString_Show()
	end
end

-- Hide the user interface
function HeadCount:HideUserInterface()
	HeadCount:DisableModalFrame()
	
	-- close all frames	
	HeadCountFrame:Hide()	-- close the main frame
	dewdrop:Close()			-- close menus
end

-- Show the user interface
function HeadCount:ShowUserInterface()
	-- show the main frame
	HeadCountFrame:Show()
end

-- Toggle the user interface
function HeadCount:ToggleUserInterface()
	if (HeadCountFrame:IsVisible()) then
		-- frame is visible, hide it
		HeadCount:HideUserInterface()
	else
		HeadCount:ShowUserInterface()
	end
end

-- Enable to modal frame (remove/export)
function HeadCount:EnableModalFrame() 
	HeadCountFrame.isDialogDisplayed = true		
end

-- Disable to modal frame (remove/export)
function HeadCount:DisableModalFrame() 
	HeadCountFrame.isDialogDisplayed = false
	HeadCountFrameConfirm:Hide()
	HeadCountFrameExport:Hide()
	HeadCountFrameLootManagement:Hide()
	
	dewdrop:Close() -- close menus
end


-- ***********************************
-- ON LOAD FUNCTIONS
-- ***********************************
-- ON LOAD: Main frame
function HeadCount:HeadCountFrame_Load()	
end

-- ON LAOD: Loot management popup
function HeadCount:HeadCountFrameLootManagementPopup_Load()
	HeadCountFrame.isLootPopupDisplayed = false
	HeadCountFrame.lootPopupQueue = {} 
	
	getglobal(this:GetName() .. "LooterLabel"):SetText(L["Looted by"] .. ": ")
	getglobal(this:GetName() .. "SourceLabel"):SetText(L["Loot source"] .. ": ")
	getglobal(this:GetName() .. "CostLabel"):SetText(L["Loot cost"] .. ": ")
	getglobal(this:GetName() .. "SaveButton"):SetText(L["Save"])
	getglobal(this:GetName() .. "CancelButton"):SetText(L["Close"])	
end

-- ON LOAD: Confirm frame
function HeadCount:HeadCountFrameConfirm_Load()
	HeadCountFrameConfirmConfirmButton:SetText(L["remove"])
	HeadCountFrameConfirmCancelButton:SetText(L["Cancel"]) 
end

-- ON LOAD: Export frame
function HeadCount:HeadCountFrameExport_Load() 
	HeadCountFrameExportCloseButton:SetText(L["Close"])
end

-- ON LOAD: Loot management frame
function HeadCount:HeadCountFrameLootManagementTemplate_Load()
	getglobal(this:GetName() .. "LooterLabel"):SetText(L["Looted by"] .. ": ")
	getglobal(this:GetName() .. "SourceLabel"):SetText(L["Loot source"] .. ": ")
	getglobal(this:GetName() .. "CostLabel"):SetText(L["Loot cost"] .. ": ")
	getglobal(this:GetName() .. "SaveButton"):SetText(L["Save"])
	getglobal(this:GetName() .. "CancelButton"):SetText(L["Cancel"])		
end

-- ON LOAD: Main frame
function HeadCount:HeadCountFrame_Load()
	HeadCountFrame.isRaidSelected = false
	HeadCountFrame.selectedRaidId = 0	
	HeadCountFrame.isDialogDisplayed = false
end

-- ON LOAD: Raid history frame
function HeadCount:HeadCountFrameRaidHistory_Load()
	HeadCountFrameRaidHistory:SetBackdropBorderColor(0.8, 0.8, 0.8, 0.8)
	HeadCountFrameRaidHistoryTitleString:SetText(string.format(L["info.raidhistory"], 0))
end

-- ON LOAD: Raid history content frame
function HeadCount:HeadCountFrameRaidHistoryContent_Load()

end

-- ON LOAD: Content frame
function HeadCount:HeadCountFrameContent_Load() 
	HeadCountFrameContent:SetBackdropBorderColor(0.8, 0.8, 0.8, 0.8)
	HeadCountFrame.contentType = content["raid"]
	HeadCountFrameContentTitleString:Hide()
end

-- ON LOAD: Raid members
function HeadCount:HeadCountFrameContentMembers_Load()
	HeadCountFrameContentMembersNameButtonText:SetText(L["Name"])	
	HeadCountFrameContentMembersStartTimeButtonText:SetText(L["start"])	
	HeadCountFrameContentMembersEndTimeButtonText:SetText(L["end"])	
	HeadCountFrameContentMembersTotalTimeButtonText:SetText(L["Total time"])
	
	HeadCountFrameContentMembers.sortType = "Start"
	HeadCountFrameContentMembers.isDescending = true
end

-- ON LOAD: Player information
function HeadCount:HeadCountFrameContentPlayer_Load() 
	HeadCountFrameContentPlayerBackButtonText:SetText(L["Go back"])
end

-- ON LOAD: Raid bosses
function HeadCount:HeadCountFrameContentBoss_Load()
	HeadCountFrameContentBossTimeButtonText:SetText(L["Time"])
	HeadCountFrameContentBossMembersButtonText:SetText(L["Members"])
	HeadCountFrameContentBossNameButtonText:SetText(L["Name"])
end

-- ON LOAD: Snapshot information
function HeadCount:HeadCountFrameContentSnapshot_Load()
	HeadCountFrameContentSnapshotBackButtonText:SetText(L["Go back"])
end

-- ON LOAD: Title head
function HeadCount:HeadCountFrameTitleHeader_Load()
	HeadCountFrameTitleHeaderString:SetText(L["product.name"])
end

-- ON LOAD: Raid history template
function HeadCount:HeadCountFrameRaidHistoryContentTemplate_Load()
	getglobal(this:GetName() .. "MouseOver"):SetAlpha(0.3)
	getglobal(this:GetName() .. "MouseOver"):SetVertexColor(0.4, 0.4, 1.0)
				
	getglobal(this:GetName() .. "MouseSelect"):SetAlpha(0.6)
	getglobal(this:GetName() .. "MouseSelect"):SetVertexColor(0.4, 0.4, 1.0)
end

-- ON LOAD: Raid members template
function HeadCount:HeadCountFrameContentMembersTemplate_Load()
	getglobal(this:GetName() .. "MouseOver"):SetAlpha(0.3)
	getglobal(this:GetName() .. "MouseOver"):SetVertexColor(0.4, 0.4, 1.0)
end

-- ON LOAD: Raid bosses templates
function HeadCount:HeadCountFrameContentBossTemplate_Load()
	getglobal(this:GetName() .. "MouseOver"):SetAlpha(0.3)
	getglobal(this:GetName() .. "MouseOver"):SetVertexColor(0.4, 0.4, 1.0)
end
   
-- ***********************************
-- SCROLL UPDATE FUNCTIONS
-- ***********************************
-- ON UPDATE: Raid history content frame scroller
function HeadCount:HeadCountFrameRaidHistoryContentScroll_Update()
	local lineNumber
	local lineNumberOffset
	--FauxScrollFrame_Update(FRAME, NUMBER_OF_ENTRIES, NUMBER_OF_ENTRIES_DISPLAYED, ENTRY_PIXEL_HEIGHT, button, smallWidth, bigWidtth, highlightFrame, smallHighlightWidth, bigHighlightWidth) 

	local raidTracker = HeadCount:getRaidTracker() 
	local numberOfRaids = raidTracker:getNumberOfRaids()
	FauxScrollFrame_Update(HeadCountFrameRaidHistoryContentScroll, numberOfRaids, 5, 16)
	
	if (numberOfRaids > 0) then	
		local orderedRaidList = raidTracker:retrieveOrderedRaidList(true)	
		
		for lineNumber=1,5 do
			lineNumberOffset = lineNumber + FauxScrollFrame_GetOffset(HeadCountFrameRaidHistoryContentScroll)
			if (lineNumberOffset <= numberOfRaids) then				
				getglobal("HeadCountFrameRaidHistoryContentEntry" .. lineNumber .. "MouseOver"):Hide()
				getglobal("HeadCountFrameRaidHistoryContentEntry" .. lineNumber .. "HitArea"):Show()

				-- Set the raid history line text
				local position = (numberOfRaids + 1) - lineNumberOffset			
				local raid = orderedRaidList[position]
				local raidId = raid:retrieveStartingTime():getUTCDateTimeInSeconds() 
				getglobal("HeadCountFrameRaidHistoryContentEntry" .. lineNumber .. "Id"):SetText(raidId)
				getglobal("HeadCountFrameRaidHistoryContentEntry" .. lineNumber .. "Number"):SetText(position)
				getglobal("HeadCountFrameRaidHistoryContentEntry" .. lineNumber .. "Time"):SetText(HeadCount:getDateTimeAsString(raid:retrieveStartingTime()))
				
				-- Display if the active raid text if it exists
				local zone = raid:getZone()
				if ((not raid:getIsFinalized()) and (raidTracker:getIsCurrentRaidActive())) then 
					-- raid is not finalized and raid is active
					if (zone) then
						zone = zone .. " (" .. L["active"] .. ")"
					else
						zone = "(" .. L["active"] .. ")"
					end
				end
				
				getglobal("HeadCountFrameRaidHistoryContentEntry" .. lineNumber .. "Zone"):SetText(zone)				
				getglobal("HeadCountFrameRaidHistoryContentEntry" .. lineNumber):Show()
				
				-- Set the selected color bar if this raid is selected
				if (HeadCountFrame.selectedRaidId == raidId) then
					-- This line is equivalent to the currently selected raid id
					getglobal("HeadCountFrameRaidHistoryContentEntry" .. lineNumber .. "MouseSelect"):Show()
				else
					-- This line is not equivalent to the currently selected raid id, don't select it
					getglobal("HeadCountFrameRaidHistoryContentEntry" .. lineNumber .. "MouseSelect"):Hide()
				end
			else
				getglobal("HeadCountFrameRaidHistoryContentEntry" .. lineNumber):Hide()
			end
		end
		
		getglobal("HeadCountFrameRaidHistoryContent"):Show()
	else
		-- No raids exist
		getglobal("HeadCountFrameRaidHistoryContent"):Hide()	-- hide the raid history content frame
	end
	
	HeadCountFrameRaidHistoryTitleString:SetText(string.format(L["info.raidhistory"], numberOfRaids))	-- update the amount of raids text string	
end

-- ON UPDATE: Members content frame scroller
function HeadCount:HeadCountFrameContentMembersScroll_Update()
	local lineNumber
	local lineNumberOffset
	local numberOfPlayers = 0
	
	local raidId = HeadCountFrame.selectedRaidId
	local raidTracker = HeadCount:getRaidTracker()
	local raid = raidTracker:getRaidById(raidId)
	
	if (raid) then
		-- raid exists
		numberOfPlayers = raid:getNumberOfPlayers()
		FauxScrollFrame_Update(HeadCountFrameContentMembersScroll, numberOfPlayers, 10, 16)	                                     
		
		if (numberOfPlayers > 0) then	
			-- players exist in this raid
			local orderedPlayerList = raid:retrieveOrderedPlayerList(HeadCount:getRAID_MEMBER_SORT()[HeadCountFrameContentMembers.sortType], HeadCountFrameContentMembers.isDescending)		

			for lineNumber=1,10 do
				lineNumberOffset = lineNumber + FauxScrollFrame_GetOffset(HeadCountFrameContentMembersScroll)
				if (lineNumberOffset <= numberOfPlayers) then				
					getglobal("HeadCountFrameContentMembersEntry" .. lineNumber .. "MouseOver"):Hide()
					getglobal("HeadCountFrameContentMembersEntry" .. lineNumber .. "HitArea"):Show()
					local player = orderedPlayerList[lineNumberOffset]
					
					getglobal("HeadCountFrameContentMembersEntry" .. lineNumber .. "Number"):SetText(lineNumberOffset)
					getglobal("HeadCountFrameContentMembersEntry" .. lineNumber .. "Name"):SetText(player:getName())
					getglobal("HeadCountFrameContentMembersEntry" .. lineNumber .. "BeginTime"):SetText(HeadCount:getTimeAsString(player:retrieveStartingTime()))
					
					if (player:retrieveEndingTime()) then
						-- end time exists
						getglobal("HeadCountFrameContentMembersEntry" .. lineNumber .. "EndTime"):SetText(HeadCount:getTimeAsString(player:retrieveEndingTime()))
					else
						-- end time not yet set, show nothing
						getglobal("HeadCountFrameContentMembersEntry" .. lineNumber .. "EndTime"):SetText("")
					end
					
					if (raid:getIsFinalized()) then
						-- raid is finalized, show total time
						getglobal("HeadCountFrameContentMembersEntry" .. lineNumber .. "TotalTime"):SetText(HeadCount:getSecondsAsString(player:getTotalTime()))
					else
						-- raid is not finalized show nothing
						getglobal("HeadCountFrameContentMembersEntry" .. lineNumber .. "TotalTime"):SetText("")
					end
					
					getglobal("HeadCountFrameContentMembersEntry" .. lineNumber):Show()
				else
					getglobal("HeadCountFrameContentMembersEntry" .. lineNumber):Hide()
				end
			end
			
			HeadCount:HeadCountFrameContentMembers_Show(true)
		else
			-- players do not exist
			for lineNumber=1,10 do 
				getglobal("HeadCountFrameContentMembersEntry" .. lineNumber):Hide()
			end
			
			HeadCount:HeadCountFrameContentMembers_Show(false)	-- hide the members content frame
		end		
	else
		-- no raid exists under this id
		for lineNumber=1,10 do 
			getglobal("HeadCountFrameContentMembersEntry" .. lineNumber):Hide()
		end
			
		HeadCountFrame.isRaidSelected = false
		HeadCountFrame.selectedRaidId = 0			
		HeadCount:HeadCountFrameContentMembers_Show(false)		-- hide the members content frame
	end
	
	HeadCount:HeadCountFrameContentTitleString_Show()
end

-- ON UPDATE: Raid bosses frame scroller
function HeadCount:HeadCountFrameContentBossScroll_Update()
	local lineNumber
	local lineNumberOffset
	local numberOfBosses = 0
	
	local raidId = HeadCountFrame.selectedRaidId
	local raidTracker = HeadCount:getRaidTracker()
	local raid = raidTracker:getRaidById(raidId)
	
	if (raid) then
		-- raid exists
		numberOfBosses = raid:getNumberOfBosses()
		FauxScrollFrame_Update(HeadCountFrameContentBossScroll, numberOfBosses, 10, 16)	                                     
		
		if (numberOfBosses > 0) then	
			-- boss kills exist in this raid
			local orderedBossList = raid:retrieveOrderedBossList()		
			
			for lineNumber=1,10 do
				lineNumberOffset = lineNumber + FauxScrollFrame_GetOffset(HeadCountFrameContentBossScroll)
				if (lineNumberOffset <= numberOfBosses) then				
					getglobal("HeadCountFrameContentBossEntry" .. lineNumber .. "MouseOver"):Hide()
					getglobal("HeadCountFrameContentBossEntry" .. lineNumber .. "HitArea"):Show()
					local boss = orderedBossList[lineNumberOffset]
					
					getglobal("HeadCountFrameContentBossEntry" .. lineNumber .. "Number"):SetText(lineNumberOffset)
					getglobal("HeadCountFrameContentBossEntry" .. lineNumber .. "Time"):SetText(HeadCount:getTimeAsString(boss:getActivityTime()))					
					getglobal("HeadCountFrameContentBossEntry" .. lineNumber .. "Members"):SetText(boss:numberOfPlayers())
					getglobal("HeadCountFrameContentBossEntry" .. lineNumber .. "Name"):SetText(boss:getName())

					getglobal("HeadCountFrameContentBossEntry" .. lineNumber):Show()
				else
					getglobal("HeadCountFrameContentBossEntry" .. lineNumber):Hide()
				end
			end
			
			HeadCount:HeadCountFrameContentBoss_Show(true)
		else
			-- players do not exist
			for lineNumber=1,10 do 
				getglobal("HeadCountFrameContentBossEntry" .. lineNumber):Hide()
			end
			
			HeadCount:HeadCountFrameContentBoss_Show(false)	-- hide the members content frame
		end		
	else
		-- no raid exists under this id
		for lineNumber=1,10 do 
			getglobal("HeadCountFrameContentBossEntry" .. lineNumber):Hide()
		end		
		
		HeadCountFrame.isRaidSelected = false
		HeadCountFrame.selectedRaidId = 0			
		HeadCount:HeadCountFrameContentBoss_Show(false)		-- hide the members content frame
	end
	
	HeadCount:HeadCountFrameContentTitleString_Show()
end

-- ON UPDATE: Loot content frame scroller
function HeadCount:HeadCountFrameContentLootScroll_Update() 
	local lineNumber
	local lineNumberOffset
	
	local raidId = HeadCountFrame.selectedRaidId
	local raidTracker = HeadCount:getRaidTracker()
	local selectedRaid = raidTracker:getRaidById(raidId)
	
	if (selectedRaid) then 
		-- raid exists 
		local numberOfLoots = selectedRaid:numberOfLoots() 
		FauxScrollFrame_Update(HeadCountFrameContentLootScroll, numberOfLoots, 5, 40)	 
		
		if (numberOfLoots > 0) then 
			local lootList = selectedRaid:getLootList() 	
						
			for lineNumber=1,5 do
				lineNumberOffset = lineNumber + FauxScrollFrame_GetOffset(HeadCountFrameContentLootScroll)
				if (lineNumberOffset <= numberOfLoots) then 
					local loot = lootList[lineNumberOffset]
					
					getglobal("HeadCountFrameContentLootEntry" .. lineNumber .. "Id"):SetText(loot:getItemId())
					
					local texture = loot:getTexture()
					if (texture) then
						getglobal("HeadCountFrameContentLootEntry" .. lineNumber .. "TextureButton"):SetNormalTexture(texture)
					else
						getglobal("HeadCountFrameContentLootEntry" .. lineNumber .. "TextureButton"):SetNormalTexture("Interface\Icons\INV_Misc_QuestionMark")
					end
					
					getglobal("HeadCountFrameContentLootEntry" .. lineNumber .. "Number"):SetText(lineNumberOffset)
					
					local link = loot:getLink()
					if (link) then		
						getglobal("HeadCountFrameContentLootEntry" .. lineNumber .. "NameButtonText"):SetText(link)
					else
						getglobal("HeadCountFrameContentLootEntry" .. lineNumber .. "NameButtonText"):SetText(L["Item unavailable"]) 																								 
					end
					
					getglobal("HeadCountFrameContentLootEntry" .. lineNumber .. "Looter"):SetText(L["Looted by"] .. " " .. loot:getPlayerName() .. " (" .. HeadCount:getDateTimeAsString(loot:getActivityTime())  .. ")")
				
					getglobal("HeadCountFrameContentLootEntry" .. lineNumber):Show()
				else
					getglobal("HeadCountFrameContentLootEntry" .. lineNumber):Hide()
				end
			end
			
			HeadCount:HeadCountFrameContentLoot_Show(true)
		else
			for lineNumber=1,5 do 
				getglobal("HeadCountFrameContentLootEntry" .. lineNumber):Hide()
			end
			
			HeadCount:HeadCountFrameContentLoot_Show(false)
		end		
	else
		-- no raid exists under this id 
		for lineNumber=1,5 do 
			getglobal("HeadCountFrameContentLootEntry" .. lineNumber):Hide()
		end		
		
		HeadCountFrame.isRaidSelected = false
		HeadCountFrame.selectedRaidId = 0
		HeadCount:HeadCountFrameContentLoot_Show(false)
	end
	
	HeadCount:HeadCountFrameContentTitleString_Show()
end

-- ON UPDATE: Player content frame scroller
function HeadCount:HeadCountFrameContentPlayerScroll_Update() 
	local lineNumber
	local lineNumberOffset

	local raidId = HeadCountFrame.selectedRaidId
	local raidTracker = HeadCount:getRaidTracker()
	local selectedRaid = raidTracker:getRaidById(raidId)

	if (selectedRaid) then 
		-- raid exists
		local player = selectedRaid:retrievePlayer(HeadCountFrame.playerName)		
		if (player) then 
			local playerInformation, numberOfPlayerInformationLines = player:retrieveInformationList()
		
			FauxScrollFrame_Update(HeadCountFrameContentPlayerScroll, numberOfPlayerInformationLines, 10, 16)		
		
			for lineNumber=1,10 do
				lineNumberOffset = lineNumber + FauxScrollFrame_GetOffset(HeadCountFrameContentPlayerScroll)
				if (lineNumberOffset <= numberOfPlayerInformationLines) then			
					getglobal("HeadCountFrameContentPlayerEntry" .. lineNumber .. "Information"):SetText(playerInformation[lineNumberOffset])			
					getglobal("HeadCountFrameContentPlayerEntry" .. lineNumber):Show()
				else
					getglobal("HeadCountFrameContentPlayerEntry" .. lineNumber):Hide()
				end
			end
			
			HeadCountFrameContentPlayerNameString:SetText(player:getName())
			HeadCount:HeadCountFrameContentPlayer_Show(true)			
		else
			-- player does not exist
			for lineNumber=1,10 do 
				getglobal("HeadCountFrameContentPlayerEntry" .. lineNumber):Hide()
			end	
			
			HeadCount:HeadCountFrameContentPlayer_Show(false)		
		end		
	else
		-- raid does not exist
		for lineNumber=1,10 do 
			getglobal("HeadCountFrameContentPlayerEntry" .. lineNumber):Hide()
		end	
		
		HeadCountFrame.isRaidSelected = false
		HeadCountFrame.selectedRaidId = 0					
		HeadCount:HeadCountFrameContentPlayer_Show(false)
	end
	
	HeadCount:HeadCountFrameContentTitleString_Show()
end

-- ON UPDATE: Boss/snapshot frame scroller
function HeadCount:HeadCountFrameContentSnapshotScroll_Update()
	local lineNumber
	local lineNumberOffset

	local raidId = HeadCountFrame.selectedRaidId
	local raidTracker = HeadCount:getRaidTracker()
	local selectedRaid = raidTracker:getRaidById(raidId)	

	if (selectedRaid) then 
		-- raid exists
		local boss = selectedRaid:retrieveBoss(HeadCountFrame.bossName)
		if (boss) then
			local numberOfPlayers = boss:numberOfPlayers()
			local snapshotList = boss:getPlayerList()
			if (numberOfPlayers > 0) then
				FauxScrollFrame_Update(HeadCountFrameContentSnapshotScroll, numberOfPlayers, 10, 16)		
			
				for lineNumber=1,10 do
					lineNumberOffset = lineNumber + FauxScrollFrame_GetOffset(HeadCountFrameContentSnapshotScroll)
					if (lineNumberOffset <= numberOfPlayers) then			
						getglobal("HeadCountFrameContentSnapshotEntry" .. lineNumber .. "Number"):SetText(lineNumberOffset)
						getglobal("HeadCountFrameContentSnapshotEntry" .. lineNumber .. "Name"):SetText(snapshotList[lineNumberOffset])
						getglobal("HeadCountFrameContentSnapshotEntry" .. lineNumber):Show()
					else
						getglobal("HeadCountFrameContentSnapshotEntry" .. lineNumber):Hide()
					end
				end
				
				local description = boss:getName() .. " (" .. HeadCount:getDateTimeAsString(boss:getActivityTime()) .. ")"
				HeadCountFrameContentSnapshotNameString:SetText(description)
				HeadCount:HeadCountFrameContentSnapshot_Show(true)		
			else
				-- no attendees for this boss, show the header (boss name and go back, but show no entries)
				for lineNumber=1,10 do 
					getglobal("HeadCountFrameContentSnapshotEntry" .. lineNumber):Hide()
				end					
			
				local description = boss:getName() .. " (" .. HeadCount:getDateTimeAsString(boss:getActivityTime()) .. ")"
				HeadCountFrameContentSnapshotNameString:SetText(description)			
				HeadCount:HeadCountFrameContentSnapshot_Show(true)					
			end
		else
			-- boss does not exist
			for lineNumber=1,10 do 
				getglobal("HeadCountFrameContentSnapshotEntry" .. lineNumber):Hide()
			end	
			
			HeadCount:HeadCountFrameContentSnapshot_Show(false)		
		end		
	else
		-- raid does not exist
		for lineNumber=1,10 do 
			getglobal("HeadCountFrameContentSnapshotEntry" .. lineNumber):Hide()
		end	
		
		HeadCountFrame.isRaidSelected = false
		HeadCountFrame.selectedRaidId = 0					
		HeadCount:HeadCountFrameContentSnapshot_Show(false)
	end
	
	HeadCount:HeadCountFrameContentTitleString_Show()	
end

-- ***********************************
-- SHOW FUNCTIONS
-- ***********************************
-- SHOW: Toggle display of members content frame
function HeadCount:HeadCountFrameContentMembers_Show(isShowing)
	if (isShowing) then
		getglobal("HeadCountFrameContentMembersNameButton"):Show()			
		getglobal("HeadCountFrameContentMembersStartTimeButton"):Show()			
		getglobal("HeadCountFrameContentMembersEndTimeButton"):Show()				
		getglobal("HeadCountFrameContentMembersTotalTimeButton"):Show()				
	
		getglobal("HeadCountFrameContentMembers"):Show()	
	else
		for lineNumber=1,10 do 
			getglobal("HeadCountFrameContentMembersEntry" .. lineNumber):Hide()
		end
		
		getglobal("HeadCountFrameContentMembersNameButton"):Hide()			
		getglobal("HeadCountFrameContentMembersStartTimeButton"):Hide()			
		getglobal("HeadCountFrameContentMembersEndTimeButton"):Hide()				
		getglobal("HeadCountFrameContentMembersTotalTimeButton"):Hide()				
		
		getglobal("HeadCountFrameContentMembers"):Hide()	
	end
end

-- SHOW: Toggle display of the bosses content frame
function HeadCount:HeadCountFrameContentBoss_Show(isShowing)
	if (isShowing) then
		getglobal("HeadCountFrameContentBossTimeButton"):Show()	
		getglobal("HeadCountFrameContentBossMembersButton"):Show()	
		getglobal("HeadCountFrameContentBossNameButton"):Show()	
	
		getglobal("HeadCountFrameContentBoss"):Show()		
	else
		getglobal("HeadCountFrameContentBossTimeButton"):Hide()	
		getglobal("HeadCountFrameContentBossMembersButton"):Hide()	
		getglobal("HeadCountFrameContentBossNameButton"):Hide()	
	
		getglobal("HeadCountFrameContentBoss"):Hide()	
	end
end

-- SHOW: Toggle display of loot content frame
function HeadCount:HeadCountFrameContentLoot_Show(isShowing)  
	if (isShowing) then 
		getglobal("HeadCountFrameContentLoot"):Show()
	else
		getglobal("HeadCountFrameContentLoot"):Hide()
	end
end

-- SHOW: Toggle display of player content frame
function HeadCount:HeadCountFrameContentPlayer_Show(isShowing) 
	if (isShowing) then
		getglobal("HeadCountFrameContentPlayerNameString"):Show()
		getglobal("HeadCountFrameContentPlayerBackButton"):Show()
		
		getglobal("HeadCountFrameContentPlayer"):Show()	
	else
		getglobal("HeadCountFrameContentPlayerNameString"):Hide()
		getglobal("HeadCountFrameContentPlayerBackButton"):Hide()
		
		getglobal("HeadCountFrameContentPlayer"):Hide()	
	end
end

-- SHOW: Toggle display of the snapshot content frame
function HeadCount:HeadCountFrameContentSnapshot_Show(isShowing)
	if (isShowing) then
		getglobal("HeadCountFrameContentSnapshotNameString"):Show()
		getglobal("HeadCountFrameContentSnapshotBackButton"):Show()
	
		getglobal("HeadCountFrameContentSnapshot"):Show()	
	else
		getglobal("HeadCountFrameContentSnapshotNameString"):Hide()
		getglobal("HeadCountFrameContentSnapshotBackButton"):Hide()
		
		getglobal("HeadCountFrameContentSnapshot"):Hide()	
	end
end

-- SHOW: Display the correct content title string
function HeadCount:HeadCountFrameContentTitleString_Show()
	local titleString

	local raidTracker = HeadCount:getRaidTracker()
	local numberOfRaids = raidTracker:getNumberOfRaids()

	if (numberOfRaids > 0) then
		if (HeadCountFrame.isRaidSelected) then 
			local raid = raidTracker:getRaidById(HeadCountFrame.selectedRaidId)
			
			if (content["raid"] == HeadCountFrame.contentType) then
				local numberOfPlayers = raid:getNumberOfPlayers()
				
				titleString = string.format(L["info.raidmembers"], numberOfPlayers)

				HeadCountFrameContentTitleString:Show()
				HeadCountFrameContentTitleString:SetText(titleString)			
				HeadCountFrameContentMembersButton:Show()
				HeadCountFrameContentBossButton:Show()		
				HeadCountFrameContentLootButton:Show()		
			elseif (content["boss"] == HeadCountFrame.contentType) then
				local numberOfBosses = raid:getNumberOfBosses()
				
				titleString = string.format(L["info.raidbosses"], numberOfBosses)
				
				HeadCountFrameContentTitleString:Show()
				HeadCountFrameContentTitleString:SetText(titleString)
				HeadCountFrameContentMembersButton:Show()
				HeadCountFrameContentBossButton:Show()						
				HeadCountFrameContentLootButton:Show()													
			elseif (content["loot"] == HeadCountFrame.contentType) then
				local numberOfLoots = raid:numberOfLoots() 
				
				titleString = string.format(L["info.raidloot"], numberOfLoots) 
				
				HeadCountFrameContentTitleString:Show()
				HeadCountFrameContentTitleString:SetText(titleString)
				HeadCountFrameContentMembersButton:Show()
				HeadCountFrameContentBossButton:Show()						
				HeadCountFrameContentLootButton:Show()		
			elseif (content["snapshot"] == HeadCountFrame.contentType) then 
				local boss = raid:retrieveBoss(HeadCountFrame.bossName)
				local numberOfPlayers = boss:numberOfPlayers()

				titleString = string.format(L["info.boss.snapshot"], numberOfPlayers) 
				
				HeadCountFrameContentTitleString:Show()
				HeadCountFrameContentTitleString:SetText(titleString)				
				HeadCountFrameContentMembersButton:Show()
				HeadCountFrameContentBossButton:Show()						
				HeadCountFrameContentLootButton:Show()		
			
			elseif (content["player"] == HeadCountFrame.contentType) then 
				titleString = L["info.raidplayer"]
				
				HeadCountFrameContentTitleString:Show()
				HeadCountFrameContentTitleString:SetText(titleString)			
				HeadCountFrameContentMembersButton:Show()
				HeadCountFrameContentBossButton:Show()						
				HeadCountFrameContentLootButton:Show()					
			else
				HeadCountFrameContentTitleString:Hide()
			end	
		else
			-- raids exist, but none are selected
			titleString = L["info.noraidsselected"]
			HeadCountFrameContentTitleString:Show()
			HeadCountFrameContentTitleString:SetText(titleString)		
			HeadCountFrameContentMembersButton:Hide()
			HeadCountFrameContentBossButton:Hide()					
			HeadCountFrameContentLootButton:Hide()		
		end
	else
		titleString = L["info.noraidsexist"]
		HeadCountFrameContentTitleString:Show()
		HeadCountFrameContentTitleString:SetText(titleString)		
		HeadCountFrameContentMembersButton:Hide()
		HeadCountFrameContentBossButton:Hide()		
		HeadCountFrameContentLootButton:Hide()		
	end
end

-- SHOW: Display the confirm frame
-- @param frameType The frame type
-- @param raidId The raid id
function HeadCount:HeadCountFrameConfirm_Show(frameType, raidId) 
	if (not HeadCountFrame.isDialogDisplayed) then
		-- only allow display of the remove frame is it is current not being displayed	
		if (confirmType[frameType]) then
			-- removal type is valid
			local isDisplayingConfirmFrame = false								
			local raidTracker = HeadCount:getRaidTracker()
			
			if (confirmType["raid"] == frameType) then
				-- remove raid
				HeadCountFrameConfirm.frameType = confirmType["raid"]
				HeadCountFrameConfirmHeaderTitleString:SetText(L["Remove raid"])		
				HeadCountFrameConfirmInfo:SetText(L["info.remove.raid"])						
				HeadCountFrameConfirmConfirmButton:SetText(L["remove"])
				HeadCountFrameConfirmCancelButton:SetText(L["Cancel"])				

				local selectedRaid = raidTracker:getRaidById(raidId)
				local zone = selectedRaid:getZone()
				
				HeadCountFrameConfirm.description = HeadCount:getDateTimeAsString(selectedRaid:retrieveStartingTime())
				if (zone) then
					HeadCountFrameConfirm.description = HeadCountFrameConfirm.description .. " - " .. zone
				end
					
				isDisplayingConfirmFrame = true
			elseif (confirmType["member"] == frameType) then
				-- remove member
				HeadCountFrameConfirm.frameType = confirmType["member"]
				HeadCountFrameConfirmHeaderTitleString:SetText(L["Remove member"])
				HeadCountFrameConfirmInfo:SetText(L["info.remove.member"])		
				HeadCountFrameConfirmConfirmButton:SetText(L["remove"])
				HeadCountFrameConfirmCancelButton:SetText(L["Cancel"])				
				
				isDisplayingConfirmFrame = true
			elseif (confirmType["boss"] == frameType) then 
				-- remove boss
				HeadCountFrameConfirm.frameType = confirmType["boss"]
				HeadCountFrameConfirmHeaderTitleString:SetText(L["Remove boss"])
				HeadCountFrameConfirmInfo:SetText(L["info.remove.boss"])		
				HeadCountFrameConfirmConfirmButton:SetText(L["remove"])
				HeadCountFrameConfirmCancelButton:SetText(L["Cancel"])				
				
				isDisplayingConfirmFrame = true				
			elseif (confirmType["endraid"] == frameType) then
				-- end the active raid
				if (raidTracker:isCurrentRaidEndable()) then
					local currentRaid = raidTracker:retrieveMostRecentRaid()
					local zone = currentRaid:getZone()
					
					HeadCountFrameConfirm.description = HeadCount:getDateTimeAsString(currentRaid:retrieveStartingTime())
					if (zone) then
						HeadCountFrameConfirm.description = HeadCountFrameConfirm.description .. " - " .. zone
					end
					
					HeadCountFrameConfirm.frameType = confirmType["endraid"]
					HeadCountFrameConfirmHeaderTitleString:SetText(L["End raid"])
					HeadCountFrameConfirmInfo:SetText(L["info.end.raid"])
					HeadCountFrameConfirmConfirmButton:SetText(L["End raid"])
					HeadCountFrameConfirmCancelButton:SetText(L["Cancel"])

					isDisplayingConfirmFrame = true	
				else
					HeadCount:LogInformation(string.format(L["info.end.raid.noraidsexists"], L["product.name"], L["product.version.major"], L["product.version.minor"]))
				end
			elseif (confirmType["removeall"] == frameType) then 
				-- remove all raids
				HeadCountFrameConfirm.frameType = confirmType["removeall"]
				HeadCountFrameConfirmHeaderTitleString:SetText(L["Remove all"])
				HeadCountFrameConfirmInfo:SetText(L["info.remove.allraids"])
				HeadCountFrameConfirmConfirmButton:SetText(L["remove"])
				HeadCountFrameConfirmCancelButton:SetText(L["Cancel"])				
				HeadCountFrameConfirm.description = L["info.remove.allraids.warning"]
				
				isDisplayingConfirmFrame = true				
			elseif (confirmType["loot"] == frameType) then 
				-- remove loot
				HeadCountFrameConfirm.frameType = confirmType["loot"]
				HeadCountFrameConfirmHeaderTitleString:SetText(L["Remove loot"])
				HeadCountFrameConfirmInfo:SetText(L["info.remove.loot"])		
				HeadCountFrameConfirmConfirmButton:SetText(L["remove"])
				HeadCountFrameConfirmCancelButton:SetText(L["Cancel"])				
				
				isDisplayingConfirmFrame = true
			end				

			if (isDisplayingConfirmFrame) then
				-- display the frame
				HeadCountFrameConfirm.raidId = raidId
				HeadCountFrameConfirmDescription:SetText(HeadCountFrameConfirm.description)						
			
				HeadCount:EnableModalFrame() 
				HeadCountFrameConfirm:Show()
			else
				-- do not display (hide) the frame
				HeadCount:DisableModalFrame() 		
			end
		end
	end
end

-- SHOW: Display the export frame
-- @param raidId The raid id
function HeadCount:HeadCountFrameExport_Show(raidId) 
	if (not HeadCountFrame.isDialogDisplayed) then
		-- only allow display of the remove frame is it is current not being displayed	
		local raidTracker = HeadCount:getRaidTracker()
		local raid = raidTracker:getRaidById(raidId)
		
		local exportString = HeadCount:exportRaid(raid)
		
		HeadCountFrameExportHeaderTitleString:SetText(L["Export raid"])
		HeadCountFrameExportInfo:SetText(string.format(L["info.export.raid"], HeadCount:GetExportFormat()))
		
		HeadCountFrameExportDescription:SetText(HeadCount:getDateTimeAsString(raid:retrieveStartingTime()))
		HeadCountFrameExportScrollContent:SetText(exportString)
		HeadCountFrameExportScrollContent:HighlightText()
		
		HeadCount:EnableModalFrame() 
		HeadCountFrameExport:Show()		
	end
end

-- SHOW: Display the loot management frame
-- @param raidId The raid id.
-- @param lootId The lootId
function HeadCount:HeadCountFrameLootManagement_Show(raidId, lootId)
	if (not HeadCountFrame.isDialogDisplayed) then
		if ((raidId) and (lootId)) then
			HeadCountFrameLootManagement.raidId = raidId
			HeadCountFrameLootManagement.lootId = lootId
			
			local raidTracker = HeadCount:getRaidTracker()
			local raid = raidTracker:getRaidById(raidId)

			HeadCountFrameLootManagementHeaderTitleString:SetText(L["Manage loot"])
			HeadCountFrameLootManagementInfo:SetText(L["info.loot.manage"])

			local raidDescription = HeadCount:getDateTimeAsString(raid:retrieveStartingTime())
			local zone = raid:getZone()		
			if (zone) then
				-- raid zone exists
				raidDescription = raidDescription .. " - " .. zone
			end		
			HeadCountFrameLootManagementRaidDescription:SetText(raidDescription)
			
			local loot = raid:retrieveLoot(lootId)
			if (loot) then
				local link = loot:getLink()
				if (link) then		
					HeadCountFrameLootManagementLootDescription:SetText(link)
				else
					HeadCountFrameLootManagementLootDescription:SetText(L["Item unavailable"])
				end			
				
				HeadCountFrameLootManagementLooterEditBox:SetText(loot:getPlayerName())
				HeadCountFrameLootManagementSourceEditBox:SetText(loot:getSource())
				
				local lootCost = loot:getCost()
				if (lootCost) then
					HeadCountFrameLootManagementCostEditBox:SetText(lootCost)
				else
					HeadCountFrameLootManagementCostEditBox:SetText("0")
				end
			else
				error("Unable to show loot management frame because the selected loot does not exist.")
			end
			
			HeadCount:EnableModalFrame()
			HeadCountFrameLootManagement:Show()
		end
	end
end

-- SHOW: Display the loot management frame popup
-- @param raidId The raid id.
-- @param lootId The lootId
function HeadCount:HeadCountFrameLootManagementPopup_Show(raidId, lootId)	
	if ((raidId) and (lootId)) then
		if (HeadCountFrame.isLootPopupDisplayed) then
			-- loot popup is currently being displayed
			-- add item to loot popup queue
			table.insert(HeadCountFrame.lootPopupQueue, { ["raidId"] = raidId, ["lootId"] = lootId })
		else
			-- loot popup is currently NOT being displayed
			-- fill the popup frame values
			HeadCountFrame.lootManagementPopupRaidId = raidId
			HeadCountFrame.lootManagementPopupLootId = lootId
			
			local raidTracker = HeadCount:getRaidTracker()
			local raid = raidTracker:getRaidById(raidId)

			HeadCountFrameLootManagementPopupHeaderTitleString:SetText(L["Manage loot"])
			HeadCountFrameLootManagementPopupInfo:SetText(L["info.loot.manage"])			
			
			local raidDescription = HeadCount:getDateTimeAsString(raid:retrieveStartingTime())
			local zone = raid:getZone()		
			if (zone) then
				-- raid zone exists
				raidDescription = raidDescription .. " - " .. zone
			end		
			HeadCountFrameLootManagementPopupRaidDescription:SetText(raidDescription)
			
			local loot = raid:retrieveLoot(lootId)
			if (loot) then
				local link = loot:getLink()
				if (link) then		
					HeadCountFrameLootManagementPopupLootDescription:SetText(link)
				else
					HeadCountFrameLootManagementPopupLootDescription:SetText(L["Item unavailable"])
				end			
				
				HeadCountFrameLootManagementPopupLooterEditBox:SetText(loot:getPlayerName())
				HeadCountFrameLootManagementPopupSourceEditBox:SetText(loot:getSource())
				
				local lootCost = loot:getCost()
				if (lootCost) then
					HeadCountFrameLootManagementPopupCostEditBox:SetText(lootCost)
				else
					HeadCountFrameLootManagementPopupCostEditBox:SetText("0")
				end
			else
				error("Unable to show loot management popup frame because the selected loot does not exist.")
			end			
			
			HeadCountFrame.isLootPopupDisplayed = true

			-- display the popup frame
			HeadCountFrameLootManagementPopup:Show()			
		end
	end
end

-- ***********************************
-- ON CLICK FUNCTIONS
-- ***********************************
-- ON CLICK: Frame close button
function HeadCount:HeadCountFrameTitleCloseButton_Click()
	-- Main close button has been clicked
	HeadCount:HideUserInterface()
end

-- ON CLICK: End raid button
function HeadCount:HeadCountFrameRaidHistoryEndRaidButton_Click()
	local currentRaidId = HeadCount:getRaidTracker():retrieveCurrentRaidId()
	
	HeadCountFrameConfirm.description = ""
	HeadCount:HeadCountFrameConfirm_Show("endraid", currentRaidId)
end

-- ON CLICK: Remove all raids button
function HeadCount:HeadCountFrameRaidHistoryRemoveAllButton_Click() 
	HeadCountFrameConfirm.description = ""
	HeadCount:HeadCountFrameConfirm_Show("removeall", 0)
end

-- ON CLICK: Raid selected
function HeadCount:HeadCountFrameRaidHistoryContentTemplateHitArea_Click()
	local raidId = tonumber(getglobal(this:GetParent():GetName() .. "Id"):GetText())	-- save the selected raid id

	HeadCount:DisableModalFrame()
	
	HeadCountFrame.selectedRaidId = raidId 
	HeadCountFrame.isRaidSelected = true
	HeadCountFrame.contentType = content["raid"]	
	HeadCount:HeadCountFrame_Update()
end

-- ON CLICK: Raid export button
function HeadCount:HeadCountFrameRaidHistoryContentTemplateExportButton_Click() 
	local raidTracker = HeadCount:getRaidTracker() 
	local currentRaidId = raidTracker:retrieveCurrentRaidId()
	local isCurrentRaidActive = raidTracker:getIsCurrentRaidActive()
	
	local raidId = tonumber(getglobal(this:GetParent():GetName() .. "Id"):GetText())	

	if ((raidId == currentRaidId) and (isCurrentRaidActive)) then 
		-- user chose most recent raid and most recent raid is active
		HeadCount:LogInformation(string.format(L["warning.export.raid.currentraid"], L["product.name"], L["product.version.major"], L["product.version.minor"]))	
	else
		-- user did not choose the most recent raid or the most recent raid is NOT active
		HeadCount:HeadCountFrameExport_Show(raidId)		
	end
end

-- ON CLICK: Raid delete button	
function HeadCount:HeadCountFrameRaidHistoryContentTemplateDeleteButton_Click()
	local raidId = tonumber(getglobal(this:GetParent():GetName() .. "Id"):GetText())
	HeadCount:HeadCountFrameConfirm_Show("raid", raidId)
end

-- ON CLICK: Raid members button
function HeadCount:HeadCountFrameContentMembersButton_Click() 
	HeadCount:DisableModalFrame() 
	
	HeadCountFrame.contentType = content["raid"]
	HeadCount:HeadCountFrame_Update()
end

function HeadCount:HeadCountFrameContentBossButton_Click()
	HeadCount:DisableModalFrame()
	
	HeadCountFrame.contentType = content["boss"]
	HeadCount:HeadCountFrame_Update()	
end

-- ON CLICK: Raid loot button
function HeadCount:HeadCountFrameContentLootButton_Click() 
	HeadCount:DisableModalFrame()
	
	HeadCountFrame.contentType = content["loot"]
	HeadCount:HeadCountFrame_Update()
end

-- ON CLICK: Player go back button
function HeadCount:HeadCountFrameContentPlayerBackButton_Click() 
	HeadCount:DisableModalFrame() 
	
	HeadCountFrame.contentType = content["raid"]
	HeadCount:HeadCountFrame_Update()
end

-- ON CLICK: Snapshot go back button
function HeadCount:HeadCountFrameContentSnapshotBackButton_Click()
	HeadCount:DisableModalFrame()
	
	HeadCountFrame.contentType = content["boss"]
	HeadCount:HeadCountFrame_Update()
end

-- ON CLICK: Raid member name sort button
function HeadCount:HeadCountFrameContentMembersNameButton_Click()
	local raidMemberSort = HeadCount:getRAID_MEMBER_SORT()
	
	if (raidMemberSort["Name"] == HeadCountFrameContentMembers.sortType) then
		-- Current column is sort column, switch direction
		HeadCountFrameContentMembers.isDescending = not HeadCountFrameContentMembers.isDescending
	else
		HeadCountFrameContentMembers.sortType = raidMemberSort["Name"]
		HeadCountFrameContentMembers.isDescending = true
	end	
	
	HeadCount:HeadCountFrame_Update()	
end

-- ON CLICK: Raid member start time sort button
function HeadCount:HeadCountFrameContentMembersStartTimeButton_Click() 
	local raidMemberSort = HeadCount:getRAID_MEMBER_SORT()
	
	if (raidMemberSort["Start"] == HeadCountFrameContentMembers.sortType) then
		-- Current column is sort column, switch direction
		HeadCountFrameContentMembers.isDescending = not HeadCountFrameContentMembers.isDescending
	else
		HeadCountFrameContentMembers.sortType = raidMemberSort["Start"]
		HeadCountFrameContentMembers.isDescending = true
	end	
	
	HeadCount:HeadCountFrame_Update()	
end

-- ON CLICK: Raid member end time sort button
function HeadCount:HeadCountFrameContentMembersEndTimeButton_Click() 
	local raidMemberSort = HeadCount:getRAID_MEMBER_SORT()
	
	if (raidMemberSort["End"] == HeadCountFrameContentMembers.sortType) then
		-- Current column is sort column, switch direction
		HeadCountFrameContentMembers.isDescending = not HeadCountFrameContentMembers.isDescending
	else
		HeadCountFrameContentMembers.sortType = raidMemberSort["End"]
		HeadCountFrameContentMembers.isDescending = true
	end	
	
	HeadCount:HeadCountFrame_Update()	
end

-- ON CLICK: Raid member total time sort button
function HeadCount:HeadCountFrameContentMembersTotalTimeButton_Click() 
	local raidMemberSort = HeadCount:getRAID_MEMBER_SORT()
	
	if (raidMemberSort["Total"] == HeadCountFrameContentMembers.sortType) then
		-- Current column is sort column, switch direction
		HeadCountFrameContentMembers.isDescending = not HeadCountFrameContentMembers.isDescending
	else
		HeadCountFrameContentMembers.sortType = raidMemberSort["Total"]
		HeadCountFrameContentMembers.isDescending = true
	end	
	
	HeadCount:HeadCountFrame_Update()
end

-- ON CLICK: Member selected
function HeadCount:HeadCountFrameContentMembersTemplateHitArea_Click() 
	HeadCount:DisableModalFrame()
	
	HeadCountFrame.playerName = getglobal(this:GetParent():GetName() .. "Name"):GetText()
	HeadCountFrame.contentType = content["player"]
	HeadCount:HeadCountFrame_Update()
end

-- ON CLICK: Member delete button
function HeadCount:HeadCountFrameContentMembersTemplateDeleteButton_Click()
	HeadCountFrameConfirm.playerId = tonumber(getglobal(this:GetParent():GetName() .. "Number"):GetText())
	HeadCountFrameConfirm.description = getglobal(this:GetParent():GetName() .. "Name"):GetText()
		
	HeadCount:HeadCountFrameConfirm_Show("member", HeadCountFrame.selectedRaidId)
end

-- ON CLICK: Boss selected
function HeadCount:HeadCountFrameContentBossTemplateHitArea_Click() 
	HeadCount:DisableModalFrame()
	
	HeadCountFrame.bossName = getglobal(this:GetParent():GetName() .. "Name"):GetText()
	HeadCountFrame.contentType = content["snapshot"]
	HeadCount:HeadCountFrame_Update()
end

-- ON CLICK: Boss delete button
function HeadCount:HeadCountFrameContentBossTemplateDeleteButton_Click()
	HeadCountFrameConfirm.bossId = tonumber(getglobal(this:GetParent():GetName() .. "Number"):GetText())
	HeadCountFrameConfirm.description = getglobal(this:GetParent():GetName() .. "Name"):GetText()
	
	HeadCount:HeadCountFrameConfirm_Show("boss", HeadCountFrame.selectedRaidId)
end

-- ON CLICK: Loot texture button
function HeadCount:HeadCountFrameContentLootTemplateTextureButton_Click()
	local itemId = getglobal(this:GetParent():GetName() .. "Id"):GetText()

	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(itemId)
	if (not itemName) then
		-- item info is not returning, query the server
		GameTooltip:SetHyperlink("item:".. itemId ..":0:0:0:0:0:0:0")
		HeadCount:HeadCountFrame_Update()	-- refresh
	else
		-- item info did return
		if (IsShiftKeyDown()) then
			-- shift key is held down, link the item
			ChatEdit_InsertLink(itemLink)
		else
			HeadCount:HeadCountFrame_Update()	-- refresh
		end
	end
end

-- ON CLICK: Loot link button
function HeadCount:HeadCountFrameContentLootTemplateNameButton_Click()
	local itemId = getglobal(this:GetParent():GetName() .. "Id"):GetText()

	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(itemId)
	if ((itemName) and (IsShiftKeyDown())) then
		-- item is valid and shift key is held down, link the item
		ChatEdit_InsertLink(itemLink)
	end
end

-- ON CLICK: Loot management button
function HeadCount:HeadCountFrameContentLootTemplateManagementButton_Click()
	local lootId = tonumber(getglobal(this:GetParent():GetName() .. "Number"):GetText())
	local raidId = HeadCountFrame.selectedRaidId	
	
	HeadCount:HeadCountFrameLootManagement_Show(raidId, lootId)
end

-- ON CLICK: Loot delete button
function HeadCount:HeadCountFrameContentLootTemplateDeleteButton_Click() 
	HeadCountFrameConfirm.lootId = tonumber(getglobal(this:GetParent():GetName() .. "Number"):GetText())
	HeadCountFrameConfirm.description = getglobal(this:GetParent():GetName() .. "NameButtonText"):GetText()	
	
	HeadCount:HeadCountFrameConfirm_Show("loot", HeadCountFrame.selectedRaidId)
end

-- ON CLICK: Confirm button
function HeadCount:HeadCountFrameConfirmConfirmButton_Click()		
	if (confirmType["raid"] == HeadCountFrameConfirm.frameType) then
		-- remove raid		
		if (HeadCountFrame.isLootPopupDisplayed) then
			-- loot management popup is displayed and it is for the same raid,  show warning
			HeadCount:LogInformation(string.format(L["warning.loot.popup.remove.raid"], L["product.name"], L["product.version.major"], L["product.version.minor"]))	
		else
			-- loot management popup is NOT displayed, remove the raid
			HeadCount:DisableModalFrame()
			HeadCount:removeRaid(HeadCountFrameConfirm.raidId)		
		end
	elseif (confirmType["member"] == HeadCountFrameConfirm.frameType) then		                                               
		-- remove member
		HeadCount:DisableModalFrame()
		HeadCount:removePlayer(HeadCountFrameConfirm.raidId, HeadCountFrameConfirm.description)
	elseif (confirmType["boss"] == HeadCountFrameConfirm.frameType) then
		-- remove boss
		HeadCount:removeBoss(HeadCountFrameConfirm.raidId, HeadCountFrameConfirm.description)
	elseif (confirmType["loot"] == HeadCountFrameConfirm.frameType) then 
		if (HeadCountFrame.isLootPopupDisplayed) then
			-- loot management popup is displayed and it is for the same raid,  show warning
			HeadCount:LogInformation(string.format(L["warning.loot.popup.remove.loot"], L["product.name"], L["product.version.major"], L["product.version.minor"]))	
		else
			-- loot management popup is NOT displayed, remove the loot
			HeadCount:DisableModalFrame()
			HeadCount:removeLoot(HeadCountFrameConfirm.raidId, HeadCountFrameConfirm.lootId)	
		end
	elseif (confirmType["endraid"] == HeadCountFrameConfirm.frameType) then 
		-- end active raid
		HeadCount:DisableModalFrame()
		local utcDateTimeInSeconds = HeadCount:getUTCDateTimeInSeconds()
		local activityTime = AceLibrary("HeadCountTime-1.0"):new({ ["utcDateTimeInSeconds"] = utcDateTimeInSeconds })	
		HeadCount:endCurrentRaid(activityTime)
	elseif (confirmType["removeall"] == HeadCountFrameConfirm.frameType) then 
		-- remove all raids
		if (HeadCountFrame.isLootPopupDisplayed) then
			-- loot management popup is displayed, show warning
			HeadCount:LogInformation(string.format(L["warning.loot.popup.remove.removeall"], L["product.name"], L["product.version.major"], L["product.version.minor"]))	
		else
			-- loot management popup is NOT displayed, remove all raids
			HeadCount:DisableModalFrame()
			HeadCountFrame.isRaidSelected = false
			HeadCountFrame.selectedRaidId = 0		
			HeadCountFrame.contentType = content["default"]
			HeadCount:removeAllRaids()
		end
	end
end

-- ON CLICK: Cancel button
function HeadCount:HeadCountFrameConfirmCancelButton_Click()		
	HeadCount:DisableModalFrame() 
end

-- ON CLICK: Export close button
function HeadCount:HeadCountFrameExportCloseButton_Click()	
	HeadCount:DisableModalFrame() 
end

-- ON CLICK: Loot management save button
function HeadCount:HeadCountFrameLootManagementSaveButton_Click()
	local looterString = HeadCountFrameLootManagementLooterEditBox:GetText()
	local sourceString = HeadCountFrameLootManagementSourceEditBox:GetText()
	local costString = HeadCountFrameLootManagementCostEditBox:GetText()
	
	local isLooterValid = HeadCount:isString(looterString)
	local isSourceValid = HeadCount:isString(sourceString)
	local isCostValid = HeadCount:isNumber(costString)
	
	if ((isLooterValid) and (isSourceValid) and (isCostValid)) then
		HeadCount:DisableModalFrame() 
		
		local cost = tonumber(costString)
		HeadCount:lootManagementUpdate(HeadCountFrameLootManagement.raidId, HeadCountFrameLootManagement.lootId, looterString, sourceString, cost)
	else
		if (not isLooterValid) then
			HeadCount:LogInformation(string.format(L["warning.loot.manage.looter"], L["product.name"], L["product.version.major"], L["product.version.minor"]))	
		end
		
		if (not isSourceValid) then
			HeadCount:LogInformation(string.format(L["warning.loot.manage.source"], L["product.name"], L["product.version.major"], L["product.version.minor"]))	
		end
		
		if (not isCostValid) then
			HeadCount:LogInformation(string.format(L["warning.loot.manage.cost"], L["product.name"], L["product.version.major"], L["product.version.minor"]))	
		end
	end
end

-- ON CLICK: Loot management cancel button
function HeadCount:HeadCountFrameLootManagementCancelButton_Click()
	HeadCount:DisableModalFrame() 
end

-- ON CLICK: Loot management looter button
function HeadCount:HeadCountFrameLootManagementLooterButton_Click() 	
	local looterButton = getglobal("HeadCountFrameLootManagementLooterButton")
	if (dewdrop:IsOpen(looterButton)) then
		dewdrop:Close()
		if (dewdrop:IsRegistered(looterButton)) then
			dewdrop:Unregister(looterButton)
		end
	else
		if (not dewdrop:IsRegistered(looterButton)) then
			dewdrop:Register(looterButton, 'children', function(level, value, raidId) HeadCount:HeadCountFrameLootManagementLooterButton_CreateMenu(level, value) end, 'dontHook', true)	
		end
		
		dewdrop:Open(looterButton)
	end	
end

-- Sets the looter text via the dropdown menu selection
-- @param looter The looter
function HeadCount:HeadCountFrameLootManagementLooterButton_Set(looter)
	if (looter) then	
		HeadCountFrameLootManagementLooterEditBox:SetText(looter)
	end
end

-- ON CLICK: Loot management source button   
function HeadCount:HeadCountFrameLootManagementSourceButton_Click()
	local sourceButton = getglobal("HeadCountFrameLootManagementSourceButton")
	if (dewdrop:IsOpen(sourceButton)) then
		dewdrop:Close()
		if (dewdrop:IsRegistered(sourceButton)) then
			dewdrop:Unregister(sourceButton)
		end
	else
		if (not dewdrop:IsRegistered(sourceButton)) then
			dewdrop:Register(sourceButton, 'children', function(level, value) HeadCount:HeadCountFrameLootManagementSourceButton_CreateMenu(level, value) end, 'dontHook', true)	
		end
		
		dewdrop:Open(sourceButton)
	end	
end

-- Sets the source text via the dropdown menu selection
-- @param source
function HeadCount:HeadCountFrameLootManagementSourceButton_Set(source)
	if (source) then	
		HeadCountFrameLootManagementSourceEditBox:SetText(source)
	end
end

-- ON CLICK: Loot management popup save button
function HeadCount:HeadCountFrameLootManagementPopupSaveButton_Click()
	local looterString = HeadCountFrameLootManagementPopupLooterEditBox:GetText()
	local sourceString = HeadCountFrameLootManagementPopupSourceEditBox:GetText()
	local costString = HeadCountFrameLootManagementPopupCostEditBox:GetText()
	
	local isLooterValid = HeadCount:isString(looterString)
	local isSourceValid = HeadCount:isString(sourceString)
	local isCostValid = HeadCount:isNumber(costString)
	
	if ((isLooterValid) and (isSourceValid) and (isCostValid)) then
		HeadCountFrame.isLootPopupDisplayed = false
		HeadCountFrameLootManagementPopup:Hide()
	
		dewdrop:Close() -- close menus	
		
		local cost = tonumber(costString)
		HeadCount:lootManagementUpdate(HeadCountFrame.lootManagementPopupRaidId, HeadCountFrame.lootManagementPopupLootId, looterString, sourceString, cost)
	
		HeadCount:HeadCountFrameLootManagementPopup_ManageQueue()	
	else
		-- display validation warning messages
		if (not isLooterValid) then
			HeadCount:LogInformation(string.format(L["warning.loot.manage.looter"], L["product.name"], L["product.version.major"], L["product.version.minor"]))	
		end
		
		if (not isSourceValid) then
			HeadCount:LogInformation(string.format(L["warning.loot.manage.source"], L["product.name"], L["product.version.major"], L["product.version.minor"]))	
		end
		
		if (not isCostValid) then
			HeadCount:LogInformation(string.format(L["warning.loot.manage.cost"], L["product.name"], L["product.version.major"], L["product.version.minor"]))	
		end
	end
end

-- ON CLICK: Loot management popup cancel button
function HeadCount:HeadCountFrameLootManagementPopupCancelButton_Click()
	HeadCountFrame.isLootPopupDisplayed = false
	HeadCountFrameLootManagementPopup:Hide()
	
	dewdrop:Close() -- close menus	
	
	HeadCount:HeadCountFrameLootManagementPopup_ManageQueue()
end

-- ON CLICK: Loot management popup queue management
function HeadCount:HeadCountFrameLootManagementPopup_ManageQueue()
	if (HeadCount:IsLootPopupEnabled()) then
		-- loot manamgement popup is still enabled
		
		---- are there more items in queue?
		if (HeadCountFrame.lootPopupQueue) then
			local numberOfQueuedItems = # HeadCountFrame.lootPopupQueue
			if (numberOfQueuedItems > 0) then
				------ get queued ids
				local raidId = HeadCountFrame.lootPopupQueue[1]["raidId"]
				local lootId = HeadCountFrame.lootPopupQueue[1]["lootId"]
			
				------ remove item from queue (first item)
				table.remove(HeadCountFrame.lootPopupQueue, 1)
				
				------ show loot management popup window for this item	
				HeadCount:HeadCountFrameLootManagementPopup_Show(raidId, lootId)	
			end
		end		
	else
		-- loot management popup is no longer enabled
		
		-- clear the current queue
		HeadCountFrame.lootPopupQueue = {}
	end
end

-- ON CLICK: Loot management popup looter button
function HeadCount:HeadCountFrameLootManagementPopupLooterButton_Click() 	
	local looterButton = getglobal("HeadCountFrameLootManagementPopupLooterButton")
	if (dewdrop:IsOpen(looterButton)) then
		dewdrop:Close()
		if (dewdrop:IsRegistered(looterButton)) then
			dewdrop:Unregister(looterButton)
		end
	else
		if (not dewdrop:IsRegistered(looterButton)) then
			dewdrop:Register(looterButton, 'children', function(level, value, raidId) HeadCount:HeadCountFrameLootManagementPopupLooterButton_CreateMenu(level, value) end, 'dontHook', true)	
		end
		
		dewdrop:Open(looterButton)
	end	
end

-- Sets the loot management popup looter text via the dropdown menu selection
-- @param looter The looter
function HeadCount:HeadCountFrameLootManagementPopupLooterButton_Set(looter)
	if (looter) then	
		HeadCountFrameLootManagementPopupLooterEditBox:SetText(looter)
	end
end

-- ON CLICK: Loot management popup source button   
function HeadCount:HeadCountFrameLootManagementPopupSourceButton_Click()
	local sourceButton = getglobal("HeadCountFrameLootManagementPopupSourceButton")
	if (dewdrop:IsOpen(sourceButton)) then
		dewdrop:Close()
		if (dewdrop:IsRegistered(sourceButton)) then
			dewdrop:Unregister(sourceButton)
		end
	else
		if (not dewdrop:IsRegistered(sourceButton)) then
			dewdrop:Register(sourceButton, 'children', function(level, value) HeadCount:HeadCountFrameLootManagementPopupSourceButton_CreateMenu(level, value) end, 'dontHook', true)	
		end
		
		dewdrop:Open(sourceButton)
	end	
end

-- Sets the loot management popup source text via the dropdown menu selection
-- @param source
function HeadCount:HeadCountFrameLootManagementPopupSourceButton_Set(source)
	if (source) then	
		HeadCountFrameLootManagementPopupSourceEditBox:SetText(source)
	end
end

-- ***********************************
-- ON ENTER FUNCTIONS
-- ***********************************
-- ON ENTER: End active raid button
function HeadCount:HeadCountFrameRaidHistoryEndRaidButton_Enter()
	GameTooltip:SetOwner(getglobal(this:GetName()), "ANCHOR_RIGHT", -6, 0)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["End active raid"], 0.63, 0.63, 1.0)
	GameTooltip:Show()
end
	
-- ON ENTER: Remove all raids button
function HeadCount:HeadCountFrameRaidHistoryRemoveAllButton_Enter() 
	GameTooltip:SetOwner(getglobal(this:GetName()), "ANCHOR_RIGHT", -6, 0)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["Remove all raids"], 0.63, 0.63, 1.0)
	GameTooltip:Show()
end
	
-- ON ENTER: Raid export button				
function HeadCount:HeadCountFrameRaidHistoryContentTemplateExportButton_Enter()
	local raidId = getglobal(this:GetParent():GetName() .. "Number"):GetText()
	local raidTime = getglobal(this:GetParent():GetName() .. "Time"):GetText()
	local zone = getglobal(this:GetParent():GetName() .. "Zone"):GetText()

	GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -6, 0)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["Export raid"] .. " " .. raidId .. ": ", 0.63, 0.63, 1.0)
	GameTooltip:AddLine(raidTime, 1.0, 1.0, 1.0)
	GameTooltip:AddLine(zone, 1.0, 1.0, 1.0)
	GameTooltip:Show()
						
	getglobal(this:GetParent():GetName() .. "MouseOver"):Show()
end
	
-- ON ENTER: Raid is selected
function HeadCount:HeadCountFrameRaidHistoryContentTemplateHitArea_Enter()
	getglobal(this:GetParent():GetName() .. "MouseOver"):Show()
end
	
-- ON ENTER: Raid delete button
function HeadCount:HeadCountFrameRaidHistoryContentTemplateDeleteButton_Enter()
	local raidNumber = getglobal(this:GetParent():GetName() .. "Number"):GetText()
	local raidTime = getglobal(this:GetParent():GetName() .. "Time"):GetText()
	local zone = getglobal(this:GetParent():GetName() .. "Zone"):GetText()

	GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -6, 0)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["Remove raid"] .. " " .. raidNumber .. ": ", 0.63, 0.63, 1.0)
	GameTooltip:AddLine(raidTime, 1.0, 1.0, 1.0)
	GameTooltip:AddLine(zone, 1.0, 1.0, 1.0)
	GameTooltip:Show()
	
	getglobal(this:GetParent():GetName() .. "MouseOver"):Show()
end				
	
-- ON ENTER: Raid members button
function HeadCount:HeadCountFrameContentMembersButton_Enter() 
	local raidTracker = HeadCount:getRaidTracker()	
	local selectedRaid = raidTracker:getRaidById(HeadCountFrame.selectedRaidId)
	local raidZone = selectedRaid:getZone()

	GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -6, 0)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["View raid members"], 0.63, 0.63, 1.0)
	GameTooltip:AddLine(HeadCount:getDateTimeAsString(selectedRaid:retrieveStartingTime()), 1.0, 1.0, 1.0)
	
	if (raidZone) then
		GameTooltip:AddLine(raidZone, 1.0, 1.0, 1.0)
	end
	
	GameTooltip:AddLine(L["Number of members"] .. ": " .. selectedRaid:getNumberOfPlayers(), 1.0, 1.0, 1.0)	
	
	GameTooltip:Show()
end
	
-- ON ENTER: Raid boss button	
function HeadCount:HeadCountFrameContentBossButton_Enter() 
	local raidTracker = HeadCount:getRaidTracker()
	local selectedRaid = raidTracker:getRaidById(HeadCountFrame.selectedRaidId)
	local raidZone = selectedRaid:getZone()
	
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -6, 0)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["View raid bosses"], 0.63, 0.63, 1.0)
	GameTooltip:AddLine(HeadCount:getDateTimeAsString(selectedRaid:retrieveStartingTime()), 1.0, 1.0, 1.0)
	if (raidZone) then
		GameTooltip:AddLine(raidZone, 1.0, 1.0, 1.0)
	end
	GameTooltip:AddLine(L["Number of bosses"] .. ": " .. selectedRaid:getNumberOfBosses(), 1.0, 1.0, 1.0)		
	
	GameTooltip:Show()
end
	
-- ON ENTER: Raid loot button
function HeadCount:HeadCountFrameContentLootButton_Enter() 
	local raidTracker = HeadCount:getRaidTracker()	
	local selectedRaid = raidTracker:getRaidById(HeadCountFrame.selectedRaidId)
	local raidZone = selectedRaid:getZone()
	
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -6, 0)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["View raid loot"], 0.63, 0.63, 1.0)
	GameTooltip:AddLine(HeadCount:getDateTimeAsString(selectedRaid:retrieveStartingTime()), 1.0, 1.0, 1.0)
	if (raidZone) then
		GameTooltip:AddLine(raidZone, 1.0, 1.0, 1.0)
	end
	GameTooltip:AddLine(L["Number of items"] .. ": " .. selectedRaid:numberOfLoots(), 1.0, 1.0, 1.0)	
	
	GameTooltip:Show()
end
	
-- ON ENTER: Raid member selection
function HeadCount:HeadCountFrameContentMembersTemplateHitArea_Enter()
	getglobal(this:GetParent():GetName() .. "MouseOver"):Show()
end
	
-- ON ENTER: Raid member delete button
function HeadCount:HeadCountFrameContentMembersTemplateDeleteButton_Enter()
	local raidTracker = HeadCount:getRaidTracker()	
	local selectedRaid = raidTracker:getRaidById(HeadCountFrame.selectedRaidId)
	local raidZone = selectedRaid:getZone()
	
	local playerId = getglobal(this:GetParent():GetName() .. "Number"):GetText()
	local playerName = getglobal(this:GetParent():GetName() .. "Name"):GetText()

	GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -6, 0)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["Remove member"] .. " " .. playerId .. ": ", 0.63, 0.63, 1.0)
	GameTooltip:AddLine(playerName, 1.0, 1.0, 1.0)
	GameTooltip:AddLine(HeadCount:getDateTimeAsString(selectedRaid:retrieveStartingTime()), 1.0, 1.0, 1.0)
	
	if (raidZone) then
		GameTooltip:AddLine(raidZone, 1.0, 1.0, 1.0)
	end
	
	GameTooltip:Show()
						
	getglobal(this:GetParent():GetName() .. "MouseOver"):Show()
end
	
-- ON ENTER: Raid boss selection	
function HeadCount:HeadCountFrameContentBossTemplateHitArea_Enter()
	getglobal(this:GetParent():GetName() .. "MouseOver"):Show()
end

-- ON ENTER: Raid boss delete button
function HeadCount:HeadCountFrameContentBossTemplateDeleteButton_Enter()
	local raidTracker = HeadCount:getRaidTracker()	
	local selectedRaid = raidTracker:getRaidById(HeadCountFrame.selectedRaidId)
	local raidZone = selectedRaid:getZone()
	
	local bossId = getglobal(this:GetParent():GetName() .. "Number"):GetText()
	local bossName = getglobal(this:GetParent():GetName() .. "Name"):GetText()

	GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -6, 0)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["Remove boss"] .. " " .. bossId .. ": ", 0.63, 0.63, 1.0)
	GameTooltip:AddLine(bossName, 1.0, 1.0, 1.0)
	GameTooltip:AddLine(HeadCount:getDateTimeAsString(selectedRaid:retrieveStartingTime()), 1.0, 1.0, 1.0)
	
	if (raidZone) then
		GameTooltip:AddLine(raidZone, 1.0, 1.0, 1.0)
	end
	
	GameTooltip:Show()
						
	getglobal(this:GetParent():GetName() .. "MouseOver"):Show()	
end
	
-- ON ENTER: Raid loot texture button.
function HeadCount:HeadCountFrameContentLootTemplateTextureButton_Enter() 
	local link = getglobal(this:GetParent():GetName() .. "NameButtonText"):GetText()
	local itemId = getglobal(this:GetParent():GetName() .. "Id"):GetText()
	
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(itemId)

	if ((link) and (link ~= L["Item unavailable"])) then
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -6, 0)
		GameTooltip:ClearLines()
		GameTooltip:SetHyperlink(link)
		GameTooltip:AddLine(L["Item level"] .. ": " .. itemLevel, 1.0, 1.0, 1.0)				
		GameTooltip:Show()
	else
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -6, 0)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L["Item unavailable"], 0.63, 0.63, 1.0)
		GameTooltip:AddLine(L["info.item.unsafe"] .. " (" .. itemId .. ")", 1.0, 1.0, 1.0)		
		GameTooltip:AddLine(L["info.item.query"], 1.0, 1.0, 1.0)
		GameTooltip:AddLine(L["info.item.requery"], 1.0, 1.0, 1.0)		
		GameTooltip:Show()	
	end
end	

-- ON ENTER: Raid loot management button	
function HeadCount:HeadCountFrameContentLootTemplateManagementButton_Enter() 
	local raidTracker = HeadCount:getRaidTracker()	
	local selectedRaid = raidTracker:getRaidById(HeadCountFrame.selectedRaidId)

	local lootName = getglobal(this:GetParent():GetName() .. "NameButtonText"):GetText()
	local lootId = tonumber(getglobal(this:GetParent():GetName() .. "Number"):GetText())
	local loot = selectedRaid:retrieveLoot(lootId)
	
	local cost = loot:getCost()
	if (not cost) then
		cost = 0
	end
	
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -6, 0)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["Manage loot"] .. ": ", 0.63, 0.63, 1.0)	
	GameTooltip:AddLine(lootName)
	GameTooltip:AddLine(L["Looted by"] .. ": " .. loot:getPlayerName(), 1.0, 1.0, 1.0)	
	
	local lootSource = loot:getSource()
	if (lootSource) then
		GameTooltip:AddLine(L["Source"] .. ": " .. lootSource, 1.0, 1.0, 1.0)	
	else
		GameTooltip:AddLine(L["Source"] .. ": " .. L["Trash mob"], 1.0, 1.0, 1.0)	
	end
	
	GameTooltip:AddLine(L["Loot cost"] .. ": " .. cost, 1.0, 1.0, 1.0)	
	
	GameTooltip:Show()	
end

-- ON ENTER: Raid loot delete button	
function HeadCount:HeadCountFrameContentLootTemplateDeleteButton_Enter() 
	local raidTracker = HeadCount:getRaidTracker()	
	local selectedRaid = raidTracker:getRaidById(HeadCountFrame.selectedRaidId)
	
	local lootName = getglobal(this:GetParent():GetName() .. "NameButtonText"):GetText()
	local lootId = tonumber(getglobal(this:GetParent():GetName() .. "Number"):GetText())
	local loot = selectedRaid:retrieveLoot(lootId)

	local cost = loot:getCost()
	if (not cost) then
		cost = 0
	end
	
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -6, 0)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["Remove loot"] .. ": ", 0.63, 0.63, 1.0)
	GameTooltip:AddLine(lootName)
	GameTooltip:AddLine(L["Looted by"] .. ": " .. loot:getPlayerName(), 1.0, 1.0, 1.0)	
	
	local lootSource = loot:getSource()
	if (lootSource) then
		GameTooltip:AddLine(L["Source"] .. ": " .. lootSource, 1.0, 1.0, 1.0)	
	else
		GameTooltip:AddLine(L["Source"] .. ": " .. L["Trash mob"], 1.0, 1.0, 1.0)	
	end
	
	GameTooltip:AddLine(L["Loot cost"] .. ": " .. cost, 1.0, 1.0, 1.0)	
	
	GameTooltip:Show()
end
	
-- ***********************************
-- ON LEAVE FUNCTIONS
-- ***********************************
-- ON LEAVE: End active raid button
function HeadCount:HeadCountFrameRaidHistoryEndRaidButton_Leave()
	GameTooltip:Hide()
end

-- ON LEAVE: Remove all raids button
function HeadCount:HeadCountFrameRaidHistoryRemoveAllButton_Leave() 
	GameTooltip:Hide()
end

-- ON LEAVE: Raid is selected	
function HeadCount:HeadCountFrameRaidHistoryContentTemplateHitArea_Leave()
	getglobal(this:GetParent():GetName() .. "MouseOver"):Hide()
end

-- ON LEAVE: Raid export button
function HeadCount:HeadCountFrameRaidHistoryContentTemplateExportButton_Leave()
	getglobal(this:GetParent():GetName() .. "MouseOver"):Hide()
	GameTooltip:Hide()
end

-- ON LEAVE: Raid delete button		
function HeadCount:HeadCountFrameRaidHistoryContentTemplateDeleteButton_Leave()
	getglobal(this:GetParent():GetName() .. "MouseOver"):Hide()
	GameTooltip:Hide()
end

-- ON LEAVE: Raid members button
function HeadCount:HeadCountFrameContentMembersButton_Leave() 
	GameTooltip:Hide()
end

-- ON LEAVE: Raid boss button
function HeadCount:HeadCountFrameContentBossButton_Leave()
	GameTooltip:Hide()
end

-- ON LEAVE: Raid loot button
function HeadCount:HeadCountFrameContentLootButton_Leave() 
	GameTooltip:Hide()
end

-- ON LEAVE: Raid member selection
function HeadCount:HeadCountFrameContentMembersTemplateHitArea_Leave()
	getglobal(this:GetParent():GetName() .. "MouseOver"):Hide();
end

-- ON LEAVE: Raid member delete button
function HeadCount:HeadCountFrameContentMembersTemplateDeleteButton_Leave()
	getglobal(this:GetParent():GetName() .. "MouseOver"):Hide()
	GameTooltip:Hide()
end			

-- ON LEAVE: Raid boss selection
function HeadCount:HeadCountFrameContentBossTemplateHitArea_Leave()
	getglobal(this:GetParent():GetName() .. "MouseOver"):Hide();
end

-- ON LEAVE: Raid boss delete button
function HeadCount:HeadCountFrameContentBossTemplateDeleteButton_Leave()
	getglobal(this:GetParent():GetName() .. "MouseOver"):Hide()
	GameTooltip:Hide()
end

-- ON LEAVE: Raid loot texture button.
function HeadCount:HeadCountFrameContentLootTemplateTextureButton_Leave() 
	GameTooltip:Hide()
end

-- ON LEAVE: Raid loot management button.
function HeadCount:HeadCountFrameContentLootTemplateManagementButton_Leave()
	GameTooltip:Hide()
end

-- ON LEAVE: Raid loot delete button.
function HeadCount:HeadCountFrameContentLootTemplateDeleteButton_Leave() 	
	GameTooltip:Hide()
end

-- ***********************************
-- ON VERTICAL SCROLL FUNCTIONS
-- ***********************************
-- ON VERTICAL SCROLL: Raid history content scroll
function HeadCount:HeadCountFrameRaidHistoryContentScroll_VerticalScroll()
	FauxScrollFrame_OnVerticalScroll(16, function() HeadCount:HeadCountFrameRaidHistoryContentScroll_Update() end)
end

-- ON VERTICAL SCROLL: Content members scroll
function HeadCount:HeadCountFrameContentMembersScroll_VerticalScroll()
	FauxScrollFrame_OnVerticalScroll(16, function() HeadCount:HeadCountFrameContentMembersScroll_Update() end)
end

-- ON VERTICAL SCROLL: Content boss scroll
function HeadCount:HeadCountFrameContentBossScroll_VerticalScroll()
	FauxScrollFrame_OnVerticalScroll(16, function() HeadCount:HeadCountFrameContentBossScroll_Update() end)
end

-- ON VERTICAL SCROLL: Content loot scroll
function HeadCount:HeadCountFrameContentLootScroll_VerticalScroll()
	FauxScrollFrame_OnVerticalScroll(40, function() HeadCount:HeadCountFrameContentLootScroll_Update() end)
end

-- ON VERTICAL SCROLL: Content snapshot scroll
function HeadCount:HeadCountFrameContentSnapshotScroll_VerticalScroll()
	FauxScrollFrame_OnVerticalScroll(16, function() HeadCount:HeadCountFrameContentSnapshotScroll_Update() end)
end

-- ON VERTICAL SCROLL: Content player scroll
function HeadCount:HeadCountFrameContentPlayerScroll_VerticalScroll()
	FauxScrollFrame_OnVerticalScroll(16, function() HeadCount:HeadCountFrameContentPlayerScroll_Update() end)
end

-- ***********************************
-- DROP DOWN MENUS
-- ***********************************
-- CREATE MENU: The loot management looter menu
-- @param level The drop down menu level
-- @param value The drop down menu value
function HeadCount:HeadCountFrameLootManagementLooterButton_CreateMenu(level, value)
	local raidTracker = HeadCount:getRaidTracker()	
	local raid = raidTracker:getRaidById(HeadCountFrameLootManagement.raidId)
	local playerList = raid:retrievePlayerListByClass()
	--HeadCountFrameLootManagement.lootId = lootId	
	
	if (1 == level) then
		dewdrop:AddLine('text', L["Looted by"] .. ":", 'isTitle', true)	
		
		if ((# playerList["Druid"]) > 0) then
			dewdrop:AddLine('text', L["Druid"],
							'textR', HeadCount.CLASS_COLORS["Druid"].r, 
							'textG', HeadCount.CLASS_COLORS["Druid"].g, 
							'textB', HeadCount.CLASS_COLORS["Druid"].b, 
							'hasArrow', true,
							'value', "druid",
							'tooltipTitle', L["Druid"],
							'tooltipText', L["Druid players"]
							)	
		else
			dewdrop:AddLine('text', L["Druid"],	'disabled', true, 'tooltipTitle', L["Druid"], 'tooltipText', L["Druid players"])			
		end

		if ((# playerList["Hunter"]) > 0) then		
			dewdrop:AddLine('text', L["Hunter"],
							'textR', HeadCount.CLASS_COLORS["Hunter"].r, 
							'textG', HeadCount.CLASS_COLORS["Hunter"].g, 
							'textB', HeadCount.CLASS_COLORS["Hunter"].b, 		
							'hasArrow', true,
							'value', "hunter",
							'tooltipTitle', L["Hunter"],
							'tooltipText', L["Hunter players"]
							)		
		else
			dewdrop:AddLine('text', L["Hunter"], 'disabled', true, 'tooltipTitle', L["Hunter"], 'tooltipText', L["Hunter players"])					
		end

		if ((# playerList["Mage"]) > 0) then				
			dewdrop:AddLine('text', L["Mage"],
							'textR', HeadCount.CLASS_COLORS["Mage"].r, 
							'textG', HeadCount.CLASS_COLORS["Mage"].g, 
							'textB', HeadCount.CLASS_COLORS["Mage"].b, 				
							'hasArrow', true,
							'value', "mage",
							'tooltipTitle', L["Mage"],
							'tooltipText', L["Mage players"]
							)
		else
			dewdrop:AddLine('text', L["Mage"], 'disabled', true, 'tooltipTitle', L["Mage"], 'tooltipText', L["Mage players"])					
		end
		
		if ((# playerList["Paladin"]) > 0) then								
			dewdrop:AddLine('text', L["Paladin"],
							'textR', HeadCount.CLASS_COLORS["Paladin"].r, 
							'textG', HeadCount.CLASS_COLORS["Paladin"].g, 
							'textB', HeadCount.CLASS_COLORS["Paladin"].b, 						
							'hasArrow', true,
							'value', "paladin",
							'tooltipTitle', L["Paladin"],
							'tooltipText', L["Paladin players"]
							)			
		else
			dewdrop:AddLine('text', L["Paladin"], 'disabled', true, 'tooltipTitle', L["Paladin"], 'tooltipText', L["Paladin players"])					
		end

		if ((# playerList["Priest"]) > 0) then								
			dewdrop:AddLine('text', L["Priest"],
							'textR', HeadCount.CLASS_COLORS["Priest"].r, 
							'textG', HeadCount.CLASS_COLORS["Priest"].g, 
							'textB', HeadCount.CLASS_COLORS["Priest"].b, 								
							'hasArrow', true,
							'value', "priest",
							'tooltipTitle', L["Priest"],
							'tooltipText', L["Priest players"]
							)		
		else
			dewdrop:AddLine('text', L["Priest"], 'disabled', true, 'tooltipTitle', L["Priest"], 'tooltipText', L["Priest players"])
		end

		if ((# playerList["Rogue"]) > 0) then								
		dewdrop:AddLine('text', L["Rogue"],
						'textR', HeadCount.CLASS_COLORS["Rogue"].r, 
						'textG', HeadCount.CLASS_COLORS["Rogue"].g, 
						'textB', HeadCount.CLASS_COLORS["Rogue"].b, 										
						'hasArrow', true,
						'value', "rogue",
						'tooltipTitle', L["Rogue"],
						'tooltipText', L["Rogue players"]
						)		
		else
			dewdrop:AddLine('text', L["Rogue"], 'disabled', true, 'tooltipTitle', L["Rogue"], 'tooltipText', L["Rogue players"])
		end

		if ((# playerList["Shaman"]) > 0) then								
			dewdrop:AddLine('text', L["Shaman"],
							'textR', HeadCount.CLASS_COLORS["Shaman"].r, 
							'textG', HeadCount.CLASS_COLORS["Shaman"].g, 
							'textB', HeadCount.CLASS_COLORS["Shaman"].b, 												
							'hasArrow', true,
							'value', "shaman",
							'tooltipTitle', L["Shaman"],
							'tooltipText', L["Shaman players"]
							)		
		else
			dewdrop:AddLine('text', L["Shaman"], 'disabled', true, 'tooltipTitle', L["Shaman"], 'tooltipText', L["Shaman players"])
		end

		if ((# playerList["Warlock"]) > 0) then								
			dewdrop:AddLine('text', L["Warlock"],
							'textR', HeadCount.CLASS_COLORS["Warlock"].r, 
							'textG', HeadCount.CLASS_COLORS["Warlock"].g, 
							'textB', HeadCount.CLASS_COLORS["Warlock"].b, 														
							'hasArrow', true,
							'value', "warlock",
							'tooltipTitle', L["Warlock"],
							'tooltipText', L["Warlock players"]
							)
		else
			dewdrop:AddLine('text', L["Warlock"], 'disabled', true, 'tooltipTitle', L["Warlock"], 'tooltipText', L["Warlock players"])
		end
						
		if ((# playerList["Warrior"]) > 0) then								
			dewdrop:AddLine('text', L["Warrior"],
							'textR', HeadCount.CLASS_COLORS["Warrior"].r, 
							'textG', HeadCount.CLASS_COLORS["Warrior"].g, 
							'textB', HeadCount.CLASS_COLORS["Warrior"].b, 																
							'hasArrow', true,
							'value', "warrior",
							'tooltipTitle', L["Warrior"],
							'tooltipText', L["Warrior players"]
							)
		else
			dewdrop:AddLine('text', L["Warrior"], 'disabled', true, 'tooltipTitle', L["Warrior"], 'tooltipText', L["Warrior players"])
		end
					
		dewdrop:AddLine()					
		dewdrop:AddLine('text', L["Bank"],
						'hasArrow', false,
						'closeWhenClicked', true, 
						'value', "bank",
						'tooltipTitle', L["Bank"],
						'tooltipText', L["Assign loot to bank"], 
						'func', function(looter) HeadCount:HeadCountFrameLootManagementLooterButton_Set(looter) end, 
						'arg1', L["Bank"]						
						)
		dewdrop:AddLine('text', L["Disenchanted"],
						'hasArrow', false,
						'closeWhenClicked', true, 
						'value', "bank",
						'tooltipTitle', L["Disenchanted"],
						'tooltipText', L["Assign loot as disenchanted"], 
						'func', function(looter) HeadCount:HeadCountFrameLootManagementLooterButton_Set(looter) end, 
						'arg1', L["Disenchanted"]												
						)										
		dewdrop:AddLine('text', L["Offspec"],
						'hasArrow', false,
						'closeWhenClicked', true, 						
						'value', "bank",
						'tooltipTitle', L["Offspec"],
						'tooltipText', L["Assign loot as offspec"], 
						'func', function(looter) HeadCount:HeadCountFrameLootManagementLooterButton_Set(looter) end, 
						'arg1', L["Offspec"]
						)																
		dewdrop:AddLine()
		dewdrop:AddLine('text', L["Close menu"], 
						'closeWhenClicked', true, 
						'tooltipTitle', L["Close menu"],
						'tooltipText', L["Close the menu"]
						)		
	elseif (level == 2) then
		if (value == "druid") then
			for k,v in ipairs(playerList["Druid"]) do
				HeadCount:HeadCountFrameLootManagementLooterButton_AddPlayerLine("Druid", v)			
			end		
		elseif (value == "hunter") then
			for k,v in ipairs(playerList["Hunter"]) do
				HeadCount:HeadCountFrameLootManagementLooterButton_AddPlayerLine("Hunter", v)			
			end		
		elseif (value == "mage") then
			for k,v in ipairs(playerList["Mage"]) do
				HeadCount:HeadCountFrameLootManagementLooterButton_AddPlayerLine("Mage", v)			
			end	
		elseif (value == "paladin") then
			for k,v in ipairs(playerList["Paladin"]) do
				HeadCount:HeadCountFrameLootManagementLooterButton_AddPlayerLine("Paladin", v)
			end				
		elseif (value == "priest") then
			for k,v in ipairs(playerList["Priest"]) do
				HeadCount:HeadCountFrameLootManagementLooterButton_AddPlayerLine("Priest", v)
			end				
		elseif (value == "rogue") then
			for k,v in ipairs(playerList["Rogue"]) do
				HeadCount:HeadCountFrameLootManagementLooterButton_AddPlayerLine("Rogue", v)			
			end				
		elseif (value == "shaman") then
			for k,v in ipairs(playerList["Shaman"]) do
				HeadCount:HeadCountFrameLootManagementLooterButton_AddPlayerLine("Shaman", v)
			end										
		elseif (value == "warlock") then
			for k,v in ipairs(playerList["Warlock"]) do
				HeadCount:HeadCountFrameLootManagementLooterButton_AddPlayerLine("Warlock", v)
			end							
		elseif (value == "warrior") then
			for k,v in ipairs(playerList["Warrior"]) do
				HeadCount:HeadCountFrameLootManagementLooterButton_AddPlayerLine("Warrior", v)
			end				
		end
	end						
end

-- Add a player line to the looted by drop down menu
-- @param className The class name.
-- @param playerName The player name
function HeadCount:HeadCountFrameLootManagementLooterButton_AddPlayerLine(className, playerName)
	dewdrop:AddLine('text', playerName,
					'textR', HeadCount.CLASS_COLORS[className].r, 
					'textG', HeadCount.CLASS_COLORS[className].g, 
					'textB', HeadCount.CLASS_COLORS[className].b, 				
					'closeWhenClicked', true, 
					'tooltipTitle', L[className], 
					'tooltipText', playerName, 
					'func', function(looter) HeadCount:HeadCountFrameLootManagementLooterButton_Set(looter) end, 
					'arg1', playerName)			
end

function HeadCount:HeadCountFrameLootManagementPopupLooterButton_CreateMenu(level, value)
	local raidTracker = HeadCount:getRaidTracker()	
	local raid = raidTracker:getRaidById(HeadCountFrame.lootManagementPopupRaidId)
	local playerList = raid:retrievePlayerListByClass()
	--HeadCountFrameLootManagement.lootId = lootId	
	
	if (1 == level) then
		dewdrop:AddLine('text', L["Looted by"] .. ":", 'isTitle', true)	
		
		if ((# playerList["Druid"]) > 0) then
			dewdrop:AddLine('text', L["Druid"],
							'textR', HeadCount.CLASS_COLORS["Druid"].r, 
							'textG', HeadCount.CLASS_COLORS["Druid"].g, 
							'textB', HeadCount.CLASS_COLORS["Druid"].b, 
							'hasArrow', true,
							'value', "druid",
							'tooltipTitle', L["Druid"],
							'tooltipText', L["Druid players"]
							)	
		else
			dewdrop:AddLine('text', L["Druid"],	'disabled', true, 'tooltipTitle', L["Druid"], 'tooltipText', L["Druid players"])			
		end

		if ((# playerList["Hunter"]) > 0) then		
			dewdrop:AddLine('text', L["Hunter"],
							'textR', HeadCount.CLASS_COLORS["Hunter"].r, 
							'textG', HeadCount.CLASS_COLORS["Hunter"].g, 
							'textB', HeadCount.CLASS_COLORS["Hunter"].b, 		
							'hasArrow', true,
							'value', "hunter",
							'tooltipTitle', L["Hunter"],
							'tooltipText', L["Hunter players"]
							)		
		else
			dewdrop:AddLine('text', L["Hunter"], 'disabled', true, 'tooltipTitle', L["Hunter"], 'tooltipText', L["Hunter players"])					
		end

		if ((# playerList["Mage"]) > 0) then				
			dewdrop:AddLine('text', L["Mage"],
							'textR', HeadCount.CLASS_COLORS["Mage"].r, 
							'textG', HeadCount.CLASS_COLORS["Mage"].g, 
							'textB', HeadCount.CLASS_COLORS["Mage"].b, 				
							'hasArrow', true,
							'value', "mage",
							'tooltipTitle', L["Mage"],
							'tooltipText', L["Mage players"]
							)
		else
			dewdrop:AddLine('text', L["Mage"], 'disabled', true, 'tooltipTitle', L["Mage"], 'tooltipText', L["Mage players"])					
		end
		
		if ((# playerList["Paladin"]) > 0) then								
			dewdrop:AddLine('text', L["Paladin"],
							'textR', HeadCount.CLASS_COLORS["Paladin"].r, 
							'textG', HeadCount.CLASS_COLORS["Paladin"].g, 
							'textB', HeadCount.CLASS_COLORS["Paladin"].b, 						
							'hasArrow', true,
							'value', "paladin",
							'tooltipTitle', L["Paladin"],
							'tooltipText', L["Paladin players"]
							)			
		else
			dewdrop:AddLine('text', L["Paladin"], 'disabled', true, 'tooltipTitle', L["Paladin"], 'tooltipText', L["Paladin players"])					
		end

		if ((# playerList["Priest"]) > 0) then								
			dewdrop:AddLine('text', L["Priest"],
							'textR', HeadCount.CLASS_COLORS["Priest"].r, 
							'textG', HeadCount.CLASS_COLORS["Priest"].g, 
							'textB', HeadCount.CLASS_COLORS["Priest"].b, 								
							'hasArrow', true,
							'value', "priest",
							'tooltipTitle', L["Priest"],
							'tooltipText', L["Priest players"]
							)		
		else
			dewdrop:AddLine('text', L["Priest"], 'disabled', true, 'tooltipTitle', L["Priest"], 'tooltipText', L["Priest players"])
		end

		if ((# playerList["Rogue"]) > 0) then								
		dewdrop:AddLine('text', L["Rogue"],
						'textR', HeadCount.CLASS_COLORS["Rogue"].r, 
						'textG', HeadCount.CLASS_COLORS["Rogue"].g, 
						'textB', HeadCount.CLASS_COLORS["Rogue"].b, 										
						'hasArrow', true,
						'value', "rogue",
						'tooltipTitle', L["Rogue"],
						'tooltipText', L["Rogue players"]
						)		
		else
			dewdrop:AddLine('text', L["Rogue"], 'disabled', true, 'tooltipTitle', L["Rogue"], 'tooltipText', L["Rogue players"])
		end

		if ((# playerList["Shaman"]) > 0) then								
			dewdrop:AddLine('text', L["Shaman"],
							'textR', HeadCount.CLASS_COLORS["Shaman"].r, 
							'textG', HeadCount.CLASS_COLORS["Shaman"].g, 
							'textB', HeadCount.CLASS_COLORS["Shaman"].b, 												
							'hasArrow', true,
							'value', "shaman",
							'tooltipTitle', L["Shaman"],
							'tooltipText', L["Shaman players"]
							)		
		else
			dewdrop:AddLine('text', L["Shaman"], 'disabled', true, 'tooltipTitle', L["Shaman"], 'tooltipText', L["Shaman players"])
		end

		if ((# playerList["Warlock"]) > 0) then								
			dewdrop:AddLine('text', L["Warlock"],
							'textR', HeadCount.CLASS_COLORS["Warlock"].r, 
							'textG', HeadCount.CLASS_COLORS["Warlock"].g, 
							'textB', HeadCount.CLASS_COLORS["Warlock"].b, 														
							'hasArrow', true,
							'value', "warlock",
							'tooltipTitle', L["Warlock"],
							'tooltipText', L["Warlock players"]
							)
		else
			dewdrop:AddLine('text', L["Warlock"], 'disabled', true, 'tooltipTitle', L["Warlock"], 'tooltipText', L["Warlock players"])
		end
						
		if ((# playerList["Warrior"]) > 0) then								
			dewdrop:AddLine('text', L["Warrior"],
							'textR', HeadCount.CLASS_COLORS["Warrior"].r, 
							'textG', HeadCount.CLASS_COLORS["Warrior"].g, 
							'textB', HeadCount.CLASS_COLORS["Warrior"].b, 																
							'hasArrow', true,
							'value', "warrior",
							'tooltipTitle', L["Warrior"],
							'tooltipText', L["Warrior players"]
							)
		else
			dewdrop:AddLine('text', L["Warrior"], 'disabled', true, 'tooltipTitle', L["Warrior"], 'tooltipText', L["Warrior players"])
		end
					
		dewdrop:AddLine()					
		dewdrop:AddLine('text', L["Bank"],
						'hasArrow', false,
						'closeWhenClicked', true, 
						'value', "bank",
						'tooltipTitle', L["Bank"],
						'tooltipText', L["Assign loot to bank"], 
						'func', function(looter) HeadCount:HeadCountFrameLootManagementPopupLooterButton_Set(looter) end, 
						'arg1', L["Bank"]						
						)
		dewdrop:AddLine('text', L["Disenchanted"],
						'hasArrow', false,
						'closeWhenClicked', true, 
						'value', "bank",
						'tooltipTitle', L["Disenchanted"],
						'tooltipText', L["Assign loot as disenchanted"], 
						'func', function(looter) HeadCount:HeadCountFrameLootManagementPopupLooterButton_Set(looter) end, 
						'arg1', L["Disenchanted"]												
						)										
		dewdrop:AddLine('text', L["Offspec"],
						'hasArrow', false,
						'closeWhenClicked', true, 						
						'value', "bank",
						'tooltipTitle', L["Offspec"],
						'tooltipText', L["Assign loot as offspec"], 
						'func', function(looter) HeadCount:HeadCountFrameLootManagementPopupLooterButton_Set(looter) end, 
						'arg1', L["Offspec"]
						)																
		dewdrop:AddLine()
		dewdrop:AddLine('text', L["Close menu"], 
						'closeWhenClicked', true, 
						'tooltipTitle', L["Close menu"],
						'tooltipText', L["Close the menu"]
						)		
	elseif (level == 2) then
		if (value == "druid") then
			for k,v in ipairs(playerList["Druid"]) do
				HeadCount:HeadCountFrameLootManagementPopupLooterButton_AddPlayerLine("Druid", v)			
			end		
		elseif (value == "hunter") then
			for k,v in ipairs(playerList["Hunter"]) do
				HeadCount:HeadCountFrameLootManagementPopupLooterButton_AddPlayerLine("Hunter", v)			
			end		
		elseif (value == "mage") then
			for k,v in ipairs(playerList["Mage"]) do
				HeadCount:HeadCountFrameLootManagementPopupLooterButton_AddPlayerLine("Mage", v)			
			end	
		elseif (value == "paladin") then
			for k,v in ipairs(playerList["Paladin"]) do
				HeadCount:HeadCountFrameLootManagementPopupLooterButton_AddPlayerLine("Paladin", v)
			end				
		elseif (value == "priest") then
			for k,v in ipairs(playerList["Priest"]) do
				HeadCount:HeadCountFrameLootManagementPopupLooterButton_AddPlayerLine("Priest", v)
			end				
		elseif (value == "rogue") then
			for k,v in ipairs(playerList["Rogue"]) do
				HeadCount:HeadCountFrameLootManagementPopupLooterButton_AddPlayerLine("Rogue", v)			
			end				
		elseif (value == "shaman") then
			for k,v in ipairs(playerList["Shaman"]) do
				HeadCount:HeadCountFrameLootManagementPopupLooterButton_AddPlayerLine("Shaman", v)
			end										
		elseif (value == "warlock") then
			for k,v in ipairs(playerList["Warlock"]) do
				HeadCount:HeadCountFrameLootManagementPopupLooterButton_AddPlayerLine("Warlock", v)
			end							
		elseif (value == "warrior") then
			for k,v in ipairs(playerList["Warrior"]) do
				HeadCount:HeadCountFrameLootManagementPopupLooterButton_AddPlayerLine("Warrior", v)
			end				
		end
	end						
end

-- Add a player line to the looted by drop down menu
-- @param className The class name.
-- @param playerName The player name
function HeadCount:HeadCountFrameLootManagementPopupLooterButton_AddPlayerLine(className, playerName)
	dewdrop:AddLine('text', playerName,
					'textR', HeadCount.CLASS_COLORS[className].r, 
					'textG', HeadCount.CLASS_COLORS[className].g, 
					'textB', HeadCount.CLASS_COLORS[className].b, 				
					'closeWhenClicked', true, 
					'tooltipTitle', L[className], 
					'tooltipText', playerName, 
					'func', function(looter) HeadCount:HeadCountFrameLootManagementPopupLooterButton_Set(looter) end, 
					'arg1', playerName)			
end

-- CREATE MENU: The loot management source menu
function HeadCount:HeadCountFrameLootManagementSourceButton_CreateMenu(level, value)
	local raidTracker = HeadCount:getRaidTracker()	
	local raid = raidTracker:getRaidById(HeadCountFrameLootManagement.raidId)
	
	local bossList = raid:retrieveOrderedBossList() 
	
	if (1 == level) then
		dewdrop:AddLine('text', L["Loot source"] .. ":", 'isTitle', true)	
	
		for k,v in ipairs(bossList) do
			dewdrop:AddLine('text', v:getName(),		
							'closeWhenClicked', true, 
							'tooltipTitle', L["Boss"], 
							'tooltipText', v:getName(), 
							'func', function(source) HeadCount:HeadCountFrameLootManagementSourceButton_Set(source) end, 
							'arg1', v:getName())			
		end
		
		if (# bossList > 0) then
			dewdrop:AddLine()
		end
		
		dewdrop:AddLine('text', L["Trash mob"],		
						'closeWhenClicked', true, 
						'tooltipTitle', L["Trash mob"], 
						'tooltipText', L["Trash mob"], 
						'func', function(source) HeadCount:HeadCountFrameLootManagementSourceButton_Set(source) end, 
						'arg1', L["Trash mob"])	
		dewdrop:AddLine()
		
		dewdrop:AddLine('text', L["Close menu"], 
						'closeWhenClicked', true, 
						'tooltipTitle', L["Close menu"],
						'tooltipText', L["Close the menu"]
						)		
	end						
end

-- CREATE MENU: The loot management popup source menu
function HeadCount:HeadCountFrameLootManagementPopupSourceButton_CreateMenu(level, value)
	local raidTracker = HeadCount:getRaidTracker()	
	local raid = raidTracker:getRaidById(HeadCountFrame.lootManagementPopupRaidId)
	
	local bossList = raid:retrieveOrderedBossList() 
	
	if (1 == level) then
		dewdrop:AddLine('text', L["Loot source"] .. ":", 'isTitle', true)	
	
		for k,v in ipairs(bossList) do
			dewdrop:AddLine('text', v:getName(),		
							'closeWhenClicked', true, 
							'tooltipTitle', L["Boss"], 
							'tooltipText', v:getName(), 
							'func', function(source) HeadCount:HeadCountFrameLootManagementPopupSourceButton_Set(source) end, 
							'arg1', v:getName())			
		end
		
		if ((# bossList) > 0) then
			dewdrop:AddLine()
		end
		
		dewdrop:AddLine('text', L["Trash mob"],		
						'closeWhenClicked', true, 
						'tooltipTitle', L["Trash mob"], 
						'tooltipText', L["Trash mob"], 
						'func', function(source) HeadCount:HeadCountFrameLootManagementPopupSourceButton_Set(source) end, 
						'arg1', L["Trash mob"])	
		dewdrop:AddLine()
		
		dewdrop:AddLine('text', L["Close menu"], 
						'closeWhenClicked', true, 
						'tooltipTitle', L["Close menu"],
						'tooltipText', L["Close the menu"]
						)		
	end						
end
