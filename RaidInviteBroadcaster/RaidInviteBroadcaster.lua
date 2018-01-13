-- RaidInviteBroadcaster.lua
-- Formerly Amnith's Invite Broadcaster (amnib) by Amnith
-- v5.2

RaidInviteBroadcasterDB = {}

local version = GetAddOnMetadata("RaidInviteBroadcaster", "Version");

local acceptInvites = true
local assistGuildRankIndexMax = -1
local currentInstance
local debugLevel = 0
local guildOfficerList = {}
local guildRosterUpdated = false
local instanceText = ""
local keyword = "invite"
local msg
local sender

local function Print(pre, green, text)
	if green == "" then green = "Raid Invite Broadcaster" end
	DEFAULT_CHAT_FRAME:AddMessage(pre..GREEN_FONT_COLOR_CODE..green..FONT_COLOR_CODE_CLOSE..": "..text)
end

local function DebugMsg(level, text)
  if debugLevel < level then return end
  Print("","",GRAY_FONT_COLOR_CODE..date("%H:%M:%S")..RED_FONT_COLOR_CODE.." DEBUG: "..FONT_COLOR_CODE_CLOSE..text)
end

-- Creates a table of guild officers at or above the designated rank
local function CreateOfficerList(oRankMax) 
	local numgMembers = GetNumGuildMembers()
	DebugMsg(3, string.format("GetNumGuildMembers=%s", numgMembers or "nil"))
	local gOfficerList = {}
	for i=1, numgMembers do
		local name, rank, rankIndex, level, more = GetGuildRosterInfo(i)
		if  rankIndex <= oRankMax then
		  if name then gOfficerList[name] = rankIndex end
      DebugMsg(3, string.format("gName=%s gRank=%s gRankIndex=%s", name or "nil", rank or "nil", gOfficerList[name] or "nil"))
		end
  end
  return gOfficerList
end

local gRoster = CreateFrame("Frame")
gRoster:RegisterEvent("GUILD_ROSTER_UPDATE")
gRoster:SetScript("OnEvent", function(self, event, ...)
  if event == "GUILD_ROSTER_UPDATE" then
    DebugMsg(1, "GUILD_ROSTER_UPDATE")
    guildRosterUpdated = true
    guildOfficerList = CreateOfficerList(assistGuildRankIndexMax)
  end
end)

-- Initializes the saved variables
local addon = CreateFrame"Frame"
addon:RegisterEvent"PLAYER_LOGIN"
addon:SetScript("OnEvent", function(self)
	if RaidInviteBroadcasterDB.debug then
		debugLevel = RaidInviteBroadcasterDB.debug
	else
		RaidInviteBroadcasterDB.debug = debugLevel
	end
	DebugMsg(1, string.format("RaidInviteBroadcasterDB.debug=%s", tostring(RaidInviteBroadcasterDB.debug) or "nil"))

	DebugMsg(1, string.format("RaidInviteBroadcasterDB.accept=%s", tostring(RaidInviteBroadcasterDB.accept) or "nil"))
	if RaidInviteBroadcasterDB.accept then
		acceptInvites = RaidInviteBroadcasterDB.accept
	else
		RaidInviteBroadcasterDB.accept = acceptInvites
	end

	DebugMsg(1, string.format("RaidInviteBroadcasterDB.instance=%s", RaidInviteBroadcasterDB.instance or "nil"))
	if RaidInviteBroadcasterDB.instance then 
		currentInstance = RaidInviteBroadcasterDB.instance
		instanceText = string.format(" for %s", currentInstance)
	end
	
	if RaidInviteBroadcasterDB.accept then
	  local invites = "enabled"
		Print("", "", string.format("Auto-invites are currently %s%s.", invites, instanceText))
	end
	
	DebugMsg(1, string.format("RaidInviteBroadcasterDB.assistRankMax=%s", RaidInviteBroadcasterDB.assistRankMax or "nil"))
	if RaidInviteBroadcasterDB.assistRankMax then
	  assistGuildRankIndexMax = RaidInviteBroadcasterDB.assistRankMax	  
	else
	  RaidInviteBroadcasterDB.assistRankMax = assistGuildRankIndexMax
	end
  DebugMsg(1, string.format("Max Guild Rank for assist=%s", assistGuildRankIndexMax or "nil"))

	DebugMsg(1, string.format("RaidInviteBroadcasterDB.inviteKeyword=%s", RaidInviteBroadcasterDB.inviteKeyword or "nil"))  
	if RaidInviteBroadcasterDB.inviteKeyword then
		keyword = RaidInviteBroadcasterDB.inviteKeyword
	else
		RaidInviteBroadcasterDB.inviteKeyword = keyword
	end
end)

-- As people whisper, the group is converted to raid, the player is set to master looter and the loot threshold is set to Rare
local inviter = CreateFrame"Frame"
inviter:RegisterEvent"CHAT_MSG_WHISPER"
inviter:RegisterEvent"CHAT_MSG_BN_WHISPER"
inviter:SetScript("OnEvent", function(self, event, ...)
	sender = nil
  if event == "CHAT_MSG_WHISPER" then
      DebugMsg(1, "CHAT_MSG_WHISPER")
      msg = select(1, ...)
      sender = select(2, ...)
      DebugMsg(2, string.format("Sender=%s Whisper=%s", sender or "nil", msg or "nil"))
  elseif event == "CHAT_MSG_BN_WHISPER" then
  		DebugMsg(1, "CHAT_MSG_BN_WHISPER")
  		msg = select(1,...)
  		local presenceID = select(13,...)
  		local _, _, _, _, toon, _, game = BNGetFriendInfoByID(presenceID)
  		DebugMsg(2, string.format("Sender=%s Game=%s Whisper=%s", toon or "nil", game or "nil", msg or "nil"))
  		if game == "WoW" then sender = toon end
  end
  
	if string.match(string.lower(msg), keyword) and sender and acceptInvites then
		InviteUnit(sender)		
		if UnitInRaid("player") then
  		if GetLootMethod() == "master" then
			  if GetLootThreshold() ~= 3 then SetLootThreshold(3) end
		  else
			  SetLootMethod("master", UnitName("player"))		
		  end
		else
		  ConvertToRaid()
		end
	end
end)

-- automatically promotes to raid assistant those officers above or equal to a set rank and members designated as main tanks
-- if invites are turned off then auto promotes are also deactivated
local promoter = CreateFrame"Frame"
promoter:RegisterEvent"GROUP_ROSTER_UPDATE"
promoter:SetScript("OnEvent", function(self)
  DebugMsg(1, "GROUP_ROSTER_UPDATE")
  if not acceptInvites or not UnitIsGroupLeader("player") or assistGuildRankIndexMax == -1 then return end
    for i=1,GetNumGroupMembers() do
    local rUnit = "raid"..i
    if UnitExists(rUnit) then
      local rName,rRank,_,_,_,_,_,_,_,rRole,_ = GetRaidRosterInfo(i)
      DebugMsg(3, string.format("rUnit=%s rName=%s rRank=%s rRole=%s", rUnit or "nil", rName or "nil", rRank or "nil", rRole or "nil"))
      if rRank == 0 then 
        if string.lower(rRole or "") == "maintank" then
          PromoteToAssistant(rUnit)
          DebugMsg(2, "Main Tank "..GRAY_FONT_COLOR_CODE..rName..FONT_COLOR_CODE_CLOSE.." promoted to assistant.")
        elseif guildOfficerList[rName] then
          PromoteToAssistant(rUnit)       
          DebugMsg(2, "Officer "..GRAY_FONT_COLOR_CODE..rName..FONT_COLOR_CODE_CLOSE.." promoted to assistant.")
        end
      end
-- Automated demotions are extremely annoying
--[[  if rRank == 0 and string.lower(rRole or "") == "maintank" then
        PromoteToAssistant(rUnit)
      elseif rRank == 0 and (rgName == lgName) and (rgRankIndex <= assistGuildRankIndexMax) then
        PromoteToAssistant(rUnit)       
      elseif rRank > 0 and not (string.lower(rRole or "") == "maintank") and not ((rgName == lgName) and (rgRankIndex <= assistGuildRankIndexMax)) then
        DemoteAssistant(rUnit)       
      end ]]--
    end
  end      
end)

local function showHelp()
	Print("", "", "/ib, /rib")
	Print("- ", "/ib start [instance]",  "Starts the auto-invites and broadcasts to the guild if an instance is specified.")
	Print("- ", "/ib stop", "Stops the auto-invites and auto-promotions.")
	Print("- ", "/ib announce", "Announces the previously started instance invite.")
	Print("- ", "/ib rank number", "Sets auto-promotion to Assistant for all main tanks and guild ranks less than or equal to number.  Set number to -1 to disable auto-promotion.")
	Print("- ", "/ib keyword word", "Sets the keyword which must be whispered to you for an invite.  It must be a single word, not a phrase.  The default keyword is invite.")
	Print("- ", "/ib version", "Displays the version of Raid Invite Broadcaster you are using.")
end

local function setAcceptInvites(value)
	acceptInvites = value
	RaidInviteBroadcasterDB.accept = value
	if value then 
		Print("", "", "Auto-invites enabled, type /ib stop to disable.")
	else
		Print("", "", "Auto-invites disabled, type /ib start to enable.")
	end
end

local function broadcastInvite(instance)
	if not instance then return end
	SendChatMessage(string.format("Invites for %s have started. For an invite, please whisper me the word '%s'.", instance, keyword), "GUILD")
	setAcceptInvites(true)
end

 -- Slash command handler
SLASH_RaidInviteBroadcaster1, SLASH_RaidInviteBroadcaster2, SLASH_RaidInviteBroadcaster3 = '/ib', '/rib', '/raidinvitebroadcaster'; 
function SlashCmdList.RaidInviteBroadcaster(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	local msgString
	if string.lower(command) == "start" then
		if #rest >0 then 
			broadcastInvite(rest)
			currentInstance = rest
			RaidInviteBroadcasterDB.instance = rest
		end
		setAcceptInvites(true)
	
	elseif string.lower(command) == "stop" then
		setAcceptInvites(false)
		currentInstance = nil
		RaidInviteBroadcasterDB.instance = nil
	
	elseif string.lower(command) == "announce" then 
		if currentInstance and acceptInvites then 
			broadcastInvite(currentInstance)
		else
			Print("", "", "You have no instance invites started. To start an invite, please use /ib start <instance>.")
		end
	
	elseif string.lower(command) == "rank" then 
		local setRank = tonumber(rest)
		if not setRank then
			Print("", "", "The rank command requires a number parameter.  Please use the format /ib rank number.")
		else
		  if guildRosterUpdated then 
		    assistGuildRankIndexMax = setRank
		    RaidInviteBroadcasterDB.assistRankMax = setRank
		    guildOfficerList = CreateOfficerList(setRank)	        
			  Print("", "", string.format("Maximum guild rank for auto-promotion set to %s.", setRank))
			  if setRank < 0 then
			    msgString = "Officers will not be auto-promoted."
			  else
			    msgString = "The following officer levels will be auto-promoted: "
          for i=0, setRank do
            msgString = msgString..i.."-"..GuildControlGetRankName(i+1).."  "
          end
        end
        Print("","",msgString)
      else
        Print("","","The guild roster is waiting for an update from the server.  Please wait a moment then try the command again.")
      end
		end
	
	elseif string.lower(command) == "keyword" then 
		local setWord = rest
		if not setWord or setWord == "" or string.match(setWord, " ") then
			Print("", "", "The keyword command requires a single word as a parameter.  Please use the format /ib keyword word.")
		elseif keyword == setWord then
			Print("", "", string.format("Keyword was already set to '%s'.", setWord))
		else
			keyword = setWord
			RaidInviteBroadcasterDB.inviteKeyword = setWord
		  Print("", "", string.format("Keyword for invites is set to '%s'.  If you have already started invites, you may want to type '/ib announce' to alert your guild to the new keyword.", setWord))
		end
	
	elseif string.lower(command) == "version" then 
		Print("", "", "Version "..version)
	
	elseif string.lower(command) == "debug" then
	  local setLevel = tonumber(rest)
	  if not setLevel or setLevel < 0 or setLevel > 3 then 
	  	Print("", "", "The debug command requires a number parameter of 0-3.  Please use the format /ib debug number.")
	  	Print("", "Valid Parameters", "")
	  	Print("- ", "/ib debug 0", "Deactivate debug messages")
	  	Print("- ", "/ib debug 1", "Basic debug messages")
	  	Print("- ", "/ib debug 2", "General debug messages")
	  	Print("- ", "/ib debug 3", "Verbose debug messages")
	  else
			debugLevel = setLevel
			RaidInviteBroadcasterDB.debug = setLevel
			local debugModeString
	  	if debugLevel == 0 then
	    	debugModeString = "deactivated"
	  	else
	    	debugModeString = string.format("set to level %s", debugLevel)
	  	end
	  	Print("", "", RED_FONT_COLOR_CODE.."Debug mode "..FONT_COLOR_CODE_CLOSE..debugModeString..".")
	  end
	
	else
		showHelp()
	end
end
