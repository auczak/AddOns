-- Copyright 2008 Riccardo Belloli (belloli@email.it)
-- This file is a part of QDKP_V2 (see about.txt in the Addon's root folder)

--             ## QDKP2 CORE FUNCTIONS ##

QDKP2_VERSION      = "2.5.7"
QDKP2_OPTREQ       = 20507
QDKP2_DBREQ        = 20505
QDKP2_BETA         = false
QDKP2_DEBUG		=0
--Available debug sections: Core, Sync, Logging, GUI, OnDemand
QDKP2_DEBUG_SECTIONS={"Core","Sync","Logging","GUI","OnDemand"}
------------------------------COLOR GLOBALS------------------------

QDKP2_COLOR_RED    = "|cffff0000";
QDKP2_COLOR_YELLOW = "|cffffff00";
QDKP2_COLOR_GREEN  = "|cff00ff00";
QDKP2_COLOR_GREY   = "|caaaaaaaa";
QDKP2_COLOR_WHITE  = "|cffffffff";
QDKP2_COLOR_BLUE   = "|cff3366ff";
QDKP2_COLOR_CLOSE  = "|r";
  

---------------------- INDEX GLOBALS --------------------------
QDKP2_TOTAL=1
QDKP2_SPENT=1
QDKP2_HOURS=3

---------------------------GLOBALS/FLAGS INIT------------------------------

QDKP2_CHECK_RUN = 0
QDKP2_CHECK_RENEW_TIMER = 0
QDKP2_REFRESHED_GUILD_ROSTER = false
QDKP2_RESET_WARNED = false
QDKP2_PLAYER_NAME =""
QDKP2_GUILD_NAME = ""
QDKP2checkTries = 0
QDKP2_EID = 0

QDKP2_StoreVers = 0

QDKP2_TOTAL=1 
QDKP2_SPENT=2
QDKP2_HOURS=3

QDKP2_outputstyle=4

--Flags for detect true deaths of some scripted bosses
QDKP2_Julianne_Died = false
QDKP2_Romulo_Died = false

-------------------------------INIT DATA-------------------------

-- this is out from InitData func because i don't want to delete it when QDKP is upgraded.

  QDKP2externals   = {} --i don't want externals players to be cleared on version upgrade

function QDKP2_InitData()
  QDKP2raid        = {}
  QDKP2raidOffline = {}
  QDKP2raidNames   = {}

  QDKP2name        = {}
  QDKP2rank        = {}
  QDKP2rankIndex   = {}
  QDKP2class       = {}

  QDKP2_TimerBase = nil

  QDKP2note   = {}

  QDKP2stored = {}
  
  QDKP2session = {}

  QDKP2ironMan     = {}
  QDKP2ironMan_time= nil

  QDKP2_BackupDate = {}
  QDKP2_Backup     = {}

  QDKP2log         = {}

  QDKP2letters     = {}

  QDKP2_Alts       = {}
  QDKP2_AltsRestore= {} 
  
  QDKP2standby= {}
  
end
---------------------------------LOAD FUNCTIONS------------------------

-- called on starting and before ADDON_LOADED is fired (for this mod)

function QDKP2_Init()

  QDKP2:RegisterEvent("ADDON_LOADED")  --register the events i use
  QDKP2:RegisterEvent("RAID_ROSTER_UPDATE")
  QDKP2:RegisterEvent("GUILD_ROSTER_UPDATE")
  QDKP2:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
  QDKP2:RegisterEvent("CHAT_MSG_LOOT")
  QDKP2:RegisterEvent("CHAT_MSG_RAID")
  QDKP2:RegisterEvent("CHAT_MSG_RAID_WARNING")
  QDKP2:RegisterEvent("CHAT_MSG_RAID_LEADER")
  QDKP2:RegisterEvent("CHAT_MSG_MONSTER_SAY")
  QDKP2:RegisterEvent("CHAT_MSG_MONSTER_YELL")
  --QDKP2:RegisterEvent("CHAT_MSG_WHISPER")

  QDKP2_InitData()  
  
  -- Gets player and guild details
  QDKP2_PLAYER_NAME = UnitName(QDKP2_LOC_Player)
  local guildName, guildRankName, guildRankIndex = GetGuildInfo(QDKP2_LOC_Player);
  QDKP2_GUILD_NAME = guildName 
  
  QDKP2_SetLetters()
  QDKP2_SetSlashCommands()
  QDKP2_GUI_Init()
  
end

function QDKP2_OnLoad()  --fired when data in WTF dir is loaded

  if QDKP2_DBREQ>QDKP2_StoreVers then
    QDKP2_InitData()
    QDKP2_Msg(QDKP2_LOC_ClearDB)
  end
  
  --Patches
  
  --Upgrades External's database to the format used in V2.5.5
  local externalList=ListFromDict(QDKP2externals)
  if QDKP2_StoreVers<20505 and table.getn(externalList)>0 then
    QDKP2_Msg(QDKP2_COLOR_YELLOW.."Upgrading externals database to the format used from version 2.5.5")
    local newExternals={}
    for i=1, table.getn(externalList) do   
      local externalName=externalList[i]
      newExternals[externalName]={}
      newExternals[externalName].datafield=QDKP2externals[externalName]
      newExternals[externalName].class="--"
    end
    QDKP2externals=newExternals
  end

  QDKP2_StoreVers=QDKP2_DBREQ

  if QDKP2_ODS_ENABLE then
    QDKP2_OriginalChatMsgHandler=ChatFrame_MessageEventHandler   --hook the MessageEvent to hide On-Demand whispers
    ChatFrame_MessageEventHandler = QDKP2_ChatMsgHandler 
  end
  
  QDKP2_AutoBossEarnSet(QDKP2_AutoBossEarn_Default) 
  QDKP2_DetectBidSet(QDKP2_DetectBid_Default)
  QDKP2_AllGuildCheckButtonSet()
  
--I use these timers to refresh guild data (on regular basis)
  Chronos.scheduleRepeating("Refresh Guild roster", 60, QDKP2_TimeToRefresh)
  Chronos.schedule(5,GuildRoster)

  for i=1,table.getn(QDKP2_ExtAlt) do
    local extName=QDKP2_ExtAlt[i].ext
    local mainName=QDKP2_ExtAlt[i].main
    if extName then
      if mainName then
        QDKP2_NewExternal(extName,mainName)
      elseif not QDKP2_IsExternal(extName) then
        QDKP2_NewExternal(extName)
      end
    end
  end
    
  QDKP2_GUI_OnLoad()
      
  if QDKP2_TimerBase and QDKP2_TimerBase - time() < 30 then
    QDKP2_TimerOn(true)
  elseif  QDKP2_TimerBase then
    QDKP2_TimerBase=nil
  end

  if not QDKP2_OptFileVers or QDKP2_OPTREQ>QDKP2_OptFileVers then
    message(QDKP2_LOC_OldOptFile)
  elseif QDKP2_BETA then
    local mess = QDKP2_LOC_BetaWarning
    QDKP2_AskUserConf(mess,GuildRoster)
  end
  
  local LoadedMsg=QDKP2_LOC_Loaded
  if QDKP2_BETA then
    LoadedMsg=string.gsub(LoadedMsg,"$BETA","BETA")
  else
    LoadedMsg=string.gsub(LoadedMsg,"$BETA","")
  end
  LoadedMsg=string.gsub(LoadedMsg,"$VERSION",QDKP2_VERSION)
  QDKP2_Msg(LoadedMsg);
  
end


-------------------------------- EVENTS MANAGER

function QDKP2_OnEvent()

  if (event == "ADDON_LOADED") then  --fired on succesfil addon load (all stored var are ready)
    if arg1 == "QDKP_V2" then  --in arg1 you have the name of the addon loaded
      QDKP2_OnLoad()
    end
    
  elseif(event == "RAID_ROSTER_UPDATE") then  --fired on raid members add/leave, maybe even on loot change
    QDKP2_UpdateRaid()
    QDKP2_RefreshAll()
    
  elseif(event ==  "GUILD_ROSTER_UPDATE") then  --fired when a new fresh guild cache is downloaded.
    if GetNumGuildMembers(true) > 0 and arg2==nil then
      --QDKP2_Msg("Guild updated")
      QDKP2_REFRESHED_GUILD_ROSTER = true
      if not QDKP2_ACTIVE then
        QDKP2_ACTIVE = true 
        QDKP2_RefreshGuild()  --two because i need the second to rebuild alt's map
	QDKP2_RefreshGuild() 
	QDKP2_UpdateRaid()
      else
        QDKP2_RefreshGuild()
      end
    end
    
  elseif (event == "CHAT_MSG_COMBAT_HOSTILE_DEATH") then  --f. when an hostile mob dies nearby
    local _, _, MobName = string.find(arg1, QDKP2_LOC_ChatKilledTrig);
    if MobName then 
	QDKP2_BossKilled(MobName)
    end
    
  elseif (event == "CHAT_MSG_LOOT" ) then  --fired on a loot
    local name, itemlink;
    local _, _, player, link = string.find(arg1, QDKP2_LOC_ChatLootTrig); 
    
    if (player) then 
      name = player;
      itemlink = link;
    else
      local _, _, link = string.find(arg1, QDKP2_LOC_ChatMeLootTrig);
      if (link) then
        name = UnitName(QDKP2_LOC_Player);
        itemlink = link;
      end
    end
    
    if not itemlink then return; end
    if not QDKP2_IsInGuild(name) then return; end
    
    local info = QDKP2_ItemInfo(itemlink)
    
    if info.rarity >= MIN_CHARGABLE_LOOT_QUALITY and QDKP2_IsInGuild(name) then
      QDKP2_LootItem = itemlink
      QDKP2_LooterName = name
    end
    
    if info.rarity >= MIN_LISTABLE_QUALITY then
      QDKP2frame3_reasonBox:AddHistoryLine(itemlink)
    end
    
    if QDKP2_IsRaidPresent() then
      local LoggedInPvt
      local timestamp=QDKP2_Timestamp()
      
      local IsInNotLogTable
      for i=1,table.getn(QDKP2_NotLogLoots) do
        if string.lower(QDKP2_NotLogLoots[i]) == string.lower(info.name) then
	   IsInNotLogTable=true
	   break
	end
      end
      if (info.rarity >= MIN_LOGGED_LOOT_QUALITY and QDKP2_IsInGuild(name)) and not IsInNotLogTable then
        QDKP2log_Entry(name,itemlink, QDKP2LOG_LOOT, nil, nil, timestamp)
        LoggedInPvt=true
      end
      if (info.rarity >= MIN_LOGGED_RAID_LOOT_QUALITY and LoggedInPvt) and not IsInNotLogTable then
        QDKP2log_Link("RAID", name, timestamp)
      end
      QDKP2_Refresh_Log("refresh")
      local ToLog
      for i=1,table.getn(QDKP2_LogLoots) do
        local tologItem=QDKP2_LogLoots[i].item
	if string.lower(tologItem)==string.lower(info.name) then 
	   ToLog=QDKP2_LogLoots[i].level; 
	   break
	end
      end
      if ToLog then
        local timestamp=QDKP2_Timestamp()
        local stringItem=string.gsub(QDKP2_LOC_Loots,"$ITEM",itemlink)
        if ToLog >= 1 then
          QDKP2log_Entry(name,info.link, QDKP2LOG_LOOT, nil, nil, timestamp)
	  QDKP2log_Link("RAID", name, timestamp)
        end
        if ToLog == 2 then
          QDKP2_Msg(QDKP2_COLOR_BLUE..name.." "..stringItem)
        end
        if ToLog == 3 then
          message(name.." "..stringItem)
        end
        QDKP2_Refresh_Log("refresh")
      end
      for i = 1, table.getn(QDKP2_ChargeLoots) do
        if string.lower(QDKP2_ChargeLoots[i].item) == string.lower(info.name) then
	  QDKP2_OpenToolboxForCharge(name, QDKP2_ChargeLoots[i].DKP, itemlink)
	end
      end
    end 
    
  elseif event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_WARNING" or event == "CHAT_MSG_RAID_LEADER" then

    local itemLink = QDKP2_GetItemFromText(arg1)
    
    if itemLink then
      local info = QDKP2_ItemInfo(itemLink)
      if info.rarity then
        if info.rarity >= MIN_CHARGABLE_CHAT_QUALITY then
          QDKP2_ChatLootItem=itemLink
        end
        if info.rarity >= MIN_LISTABLE_QUALITY then
          QDKP2frame3_reasonBox:AddHistoryLine(itemLink)
        end
      else
        local msg=string.gsub(QDKP2_LOC_NoRarityInfo,"$ITEM",itemLink)
        QDKP2_Msg(QDKP2_COLOR_YELLOW..msg)
        QDKP2_ChatLootItem=itemLink
      end
    end
    
    if QDKP2_DetectBids then QDKP2_SearchForWinner(arg1); end
  
  elseif event == "CHAT_MSG_MONSTER_SAY" or event == "CHAT_MSG_MONSTER_YELL" then
    if arg1==QDKP2_LOC_Romulo then
      QDKP2_Romulo_Died=true
      Chronos.schedule(10,QDKP2_ResetScriptedBossDeath, "Romulo")
    end
    if arg1==QDKP2_LOC_Julianne then
      QDKP2_Julianne_Died=true
      Chronos.schedule(10,QDKP2_ResetScriptedBossDeath, "Julianne")
    end
    if QDKP2_Romulo_Died and QDKP2_Julianne_Died then
      QDKP2_BossKilled("Romulo & Julianne")
      QDKP2_ResetScriptedBossDeath("Romulo")
      QDKP2_ResetScriptedBossDeath("Julianne")
    end
  end
end

function QDKP2_GetItemFromText(txt)
  local TextToCheck = txt
  local Output
  while true do
    local _,_,item = string.find(TextToCheck, "|c(.+)|h|r")
    if item then
      TextToCheck = item.."|h|r"
      Output = "|c" .. TextToCheck
    else
      break
    end
  end
  return Output
end

function QDKP2_ResetScriptedBossDeath(name)
  setglobal("QDKP2_"..name.."_Died", false)
end

--called when a mob is killed, to check for Boss Table.
function QDKP2_BossKilled(MobName)
      for i=1,table.getn(QDKP2_Bosses) do --search the mob in the bosslist (In Options.ini)
        if string.lower(QDKP2_Bosses[i].name) == string.lower(MobName) then
          local mess=string.gsub(QDKP2_LOC_Killed, '$MOB', MobName)
          QDKP2log_Event("RAID",mess) 
	  if not QDKP2_OngoingSession() then return; end
	  if not QDKP2_DetectBids and QDKP2_PROMPT_AWDS then
            QDKP2_AskUserConf(QDKP2_LOC_WinDetect_Q, QDKP2_DetectBidSet, "on")
	  end
          if QDKP2_AutoBossEarn then --if the Autoboss is on AND the timer is on
            QDKP2_Msg(QDKP2_COLOR_BLUE..mess)
            QDKP2_GiveRaidDKP(QDKP2_Bosses[i].DKP + QDKP2_Bosses_Offset, MobName..QDKP2_LOC_Kill) --give DKP to the raid
          end
          QDKP2_Refresh_Log("refresh")
          break
        end
      end
end

function QDKP2_ChatMsgHandler(event)
    if not arg1 then 
	QDKP2_OriginalChatMsgHandler(event)
	return
    end
    local text=arg1
    local sender=arg2
    
    if event=="CHAT_MSG_WHISPER_INFORM" and string.sub(arg1,1,4)=="[Q] " and not QDKP2_OS_VIEWWHSPASW then return
    elseif event=="CHAT_MSG_WHISPER" then
	local answer = QDKP2_OD(text, sender)
	if answer then
	  for i = 1, table.getn(answer) do
		ChatThrottleLib:SendChatMessage("ALERT","QDKP2","[Q] "..answer[i],"WHISPER",nil,sender)
	  end
	  if not QDKP2_OS_VIEWWHSP then return; end
	end
    end
    QDKP2_OriginalChatMsgHandler(event)
end

----------------------------------------RAID REFRESH -------------------------------------

--this function build a new list of raid members (that are in guild), and checks for
--members who leaved/joined.

function QDKP2_UpdateRaid() 
  
  if not QDKP2_ACTIVE then
    QDKP2_Debug(1, "Update","Aborting Raid Update, i'm not ready")
    return
  end
  
  QDKP2_Debug(1, "Update","Updating Raid Data")
  
  local EnterRaid = false
  if table.getn(QDKP2raid) == 0 then
    EnterRaid = true
  end
  
  local raidList={}
  local skippedNames={} 
  local NameList = DictFromList(QDKP2raid, true) 
  local raidListNameCon = DictFromList(QDKP2raid, true)
  
  if QDKP2_IsRaidPresent() then
    for i=1, QDKP2_GetNumRaidMembers() do
      local name, rank, subgroup, level, class, fileName, zone, online = QDKP2_GetRaidRosterInfo(i);
      if zone~="Standby" then
        for i=1,table.getn(QDKP2standby) do
	  if QDKP2standby[i]==name then
	    local Msg=QDKP2_LOC_ExtJoins
	    Msg=string.gsub(Msg,"$NAME",name)
	    QDKP2_Msg(QDKP2_COLOR_YELLOW..Msg)
            QDKP2_RemRaid(name)
	    QDKP2_UpdateRaid() 
	    return
	  end
	end
      end
      
      if rank == 2 then
        QDKP2_RaidLeaderZone=zone
      end
      
      if QDKP2_IsInGuild(name) then
        table.insert(raidList,name)
        raidListNameCon[name] = false
        if not NameList[name] then
          if EnterRaid then
            QDKP2log_Entry(name, QDKP2_LOC_IsInRaid, QDKP2LOG_JOINED)
          else
            QDKP2log_Entry(name, QDKP2_LOC_JoinsRaid, QDKP2LOG_JOINED)
          end
        end
        
        if QDKP2raidOffline[name] then
          if QDKP2raidOffline[name] == "online" and not online then
            QDKP2raidOffline[name]= "offline"
            QDKP2log_Entry(name,QDKP2_LOC_GoesOffline,QDKP2LOG_LEAVED)
          elseif QDKP2raidOffline[name] == "offline" and online then
            QDKP2raidOffline[name]= "online"
            QDKP2log_Entry(name,QDKP2_LOC_GoesOnline,QDKP2LOG_JOINED)
          end
        else
          if online then
            QDKP2raidOffline[name]= "online"
          else
            QDKP2raidOffline[name]= "offline"
            QDKP2log_Entry(name,QDKP2_LOC_IsOffline,QDKP2LOG_LEAVED)
          end
        end
      elseif name then
        table.insert(skippedNames, name)
      end
    end
    
    if table.getn(QDKP2raid) ~= table.getn(raidList) and QDKP2_ALERT_NOT_IN_GUILD then
      if(table.getn(skippedNames)>1)then  --formats the skipped names
        local namesstring=""
        for i=1, table.getn(skippedNames) do
          namesstring = namesstring..skippedNames[i]
          
          if(skippedNames[i+1]~=nil)then
            namesstring=namesstring..", "
          end
        end
        local msg=string.gsub(QDKP2_LOC_NoInGuild,"$NAMES",namesstring)
        QDKP2_Msg(QDKP2_COLOR_RED..msg)
      elseif(table.getn(skippedNames) == 1) then
        local msg=string.gsub(QDKP2_LOC_NoInGuild,"$NAMES",skippedNames[1])
        QDKP2_Msg(QDKP2_COLOR_RED..msg)
      end
    end
    
    table.foreach(raidListNameCon, QDKP2_FindLeavers)
    
  elseif table.getn(QDKP2raid)>1 then -- if i had raid and now i have it no more means that i leved
    QDKP2log_Entry(QDKP2_PLAYER_NAME, QDKP2_LOC_LeavedRaid, QDKP2LOG_LEAVED)
    QDKP2raidOffline = {}
    QDKP2standby = {}
    if QDKP2_TimerBase then
      QDKP2_TimerOff()
    end
    if QDKP2frame1_ironman:GetText()==QDKP2_LOC_Finish then
      QDKP2_AskUserConf(QDKP2_LOC_FinishWithRaid, QDKP2_frame1_ironman)
    end
  end
  
  QDKP2raid = raidList
  
end

--function adds people that are in the raid and in the guild to the list.
function QDKP2_FindLeavers(name,leaved)
  if leaved then
    QDKP2log_Entry(name, QDKP2_LOC_LeavedRaid, QDKP2LOG_LEAVED)
  end
end

-----------------------------------------------------------NOTIFY----------------------------

--notifies the raid of gains
function QDKP2_NotifyAll()
  if QDKP2_IsRaidPresent() then
    for i=1, table.getn(QDKP2raid) do
      QDKP2_Notify(QDKP2raid[i])
    end    
  else
    QDKP2_Msg(QDKP2_COLOR_YELLOW..QDKP2_LOC_NotIntoARaid)
  end
end

--notifies name of his gains and spent
function QDKP2_Notify(name)
  if QDKP2_IsInGuild(name) then
    ChatThrottleLib:SendChatMessage("ALERT","QDKP2",QDKP2_MakeNotifyMsg(name), "WHISPER", nil, name);
  end
end

function QDKP2_MakeNotifyMsg(name,u3p)
  local logList=QDKP2log["RAID"]
  local SessionName="--"
  if logList then
    for i=1,table.getn(logList) do
      if QDKP2log_GetType(logList[i])==QDKP2LOG_NEWSESSION then
        SessionName=logList[i][QDKP2LOG_ACTION]
        break
      end
    end
  end
  
  local msg
  if u3p then
    msg=QDKP2_LOC_NotifyString_u3p
  else
    msg=QDKP2_LOC_NotifyString
  end

  msg=string.gsub(msg,"$NAME",QDKP2_GetName(name))
  msg=string.gsub(msg,"$GUILDNAME",QDKP2_GUILD_NAME)
  msg=string.gsub(msg,"$RANK", QDKP2rank[name])
  msg=string.gsub(msg,"$CLASS", QDKP2class[name])
  msg=string.gsub(msg,"$NET",tostring(QDKP2_GetNet(name)))
  msg=string.gsub(msg,"$TOTAL",tostring(QDKP2_GetTotal(name)))
  msg=string.gsub(msg,"$SPENT",tostring(QDKP2_GetSpent(name)))
  msg=string.gsub(msg,"$TIME",tostring(QDKP2_GetHours(name)))
  msg=string.gsub(msg,"$RAIDGAINED",tostring(QDKP2_GetRaidGain(name)))
  msg=string.gsub(msg,"$RAIDSPENT",tostring(QDKP2_GetRaidSpent(name)))
  msg=string.gsub(msg,"$RAIDTIME",tostring(QDKP2_GetRaidTime(name)))
  msg=string.gsub(msg,"$SESSIONNAME",tostring(SessionName))
  return msg
end
  
---------------------------------- DKP EDITING FUNC ----------------------

--two dummies for easier reading

function QDKP2_PlayerGains(name,amount,reason,NoLog,NoMsg)
  local logit=true   --by default, log and display a message.
  local msgit=true
  if NoLog then logit=false; end
  if NoMsg then msgit=false; end
  QDKP2_AddTotals(name, amount, nil, nil, reason, nil, logit, msgit)
end

function QDKP2_PlayerSpends(name,amount,reason,NoLog,NoMsg)
  local logit=true   --by default, log and display a message.
  local msgit=true
  if NoLog then logit=false; end
  if NoMsg then msgit=false; end
  QDKP2_AddTotals(name, nil, amount, nil, reason, nil, logit, msgit)
end

-- this adds to the value in the local varables that store the DKPs (both total and cumulative)
-- Usage = QDKP2_AddTotals(name, tot, spent, hours, reason, timestamp, ToLog, ToDisplay)
-- all arguments are optionals except for the name.
-- you can pass a string like "10%" for total and spent, and it will calculate in relation with net DKP.

function QDKP2_AddTotals(name, tot, spent, hours, reason, timestamp, logIt, msgIt)

  local OriginalName=name
  if QDKP2_Alts[name] then
    name=QDKP2_Alts[name]
  end

  if not QDKP2note[name] then 
    QDKP2_Msg(QDKP2_COLOR_RED..QDKP2_LOC_NoPlayerInChance)
    return
  end
  
  local oldTotal = QDKP2_GetTotal(name)
  local oldSpent = QDKP2_GetSpent(name)
  local oldHours = QDKP2_GetHours(name)
  
  if tot then
    tot = RoundNum(tot)
  end
  if spent then
    spent = RoundNum(spent)
  end
  if hours then
    hours = RoundNum(hours*10)/10
  end
  
  local Net=QDKP2_GetNet(name)
  local Gain=0
  if tot then Gain=Gain + tot; end
  if spent then Gain=Gain - spent; end
  local newNet=Net+Gain
  if (newNet>QDKP2_MAXIMUM_NET) then
    if not tot then tot=0; end
    tot=tot-(newNet-QDKP2_MAXIMUM_NET )
    local Msg=QDKP2_LOC_MaxNetLimit
    Msg=string.gsub(Msg,"$NAME",name)
    Msg=string.gsub(Msg,"$MAXIMUMNET",tostring(QDKP2_MAXIMUM_NET))
    QDKP2_Msg(QDKP2_COLOR_YELLOW..Msg)
    QDKP2log_Event(name, QDKP2_LOC_MaxNetLimitLog)
  end
  if (newNet<QDKP2_MINIMUM_NET) then
    if not spent then spent=0; end
    spent=spent-(QDKP2_MINIMUM_NET - newNet)
    local Msg=QDKP2_LOC_MinNetLimit
    Msg=string.gsub(Msg,"$NAME",name)
    Msg=string.gsub(Msg,"$MINIMUMNET",tostring(QDKP2_MINIMUM_NET))
    QDKP2_Msg(QDKP2_COLOR_YELLOW..Msg)
    QDKP2log_Event(name, QDKP2_LOC_MinNetLimitLog)
  end


  
  local DTotal
  local DSpent 
  local DHours 

  local Gained = 0

  local HaveModify
    
  if tot then
    if tot ~= 0 then
      DTotal = tot
      QDKP2note[name][QDKP2_TOTAL] = tot + oldTotal
      QDKP2session[name][QDKP2_TOTAL] = QDKP2session[name][QDKP2_TOTAL] + DTotal
      Gained = Gained + DTotal
      HaveModify = true
    end
  end
  if spent then
    if spent ~= 0  then
      DSpent = spent 
      QDKP2note[name][QDKP2_SPENT] = spent + oldSpent 
      QDKP2session[name][QDKP2_SPENT] = QDKP2session[name][QDKP2_SPENT] + DSpent
      Gained = Gained - DSpent
      HaveModify = true
    end
  end
  if hours then
    if hours ~= 0 then
      DHours = hours
      QDKP2note[name][QDKP2_HOURS] = hours + oldHours 
      QDKP2session[name][QDKP2_HOURS] = QDKP2session[name][QDKP2_HOURS] + DHours
      HaveModify = true
    end
  end

  if not HaveModify then return; end
  
  if logIt then 
    
    if Gained == 0 then Gained = nil; end
    
    QDKP2log_Entry(name,reason, QDKP2LOG_MODIFY, Gained , {DTotal ,DSpent, DHours}, timestamp)
    
    if msgIt then
      local description = QDKP2_GetLastLogText(name)
      QDKP2_Msg(OriginalName .. " " .. description)
    end
  end

  if QDKP2_CHANGE_NOTIFY_NEGATIVE then
    if QDKP2_GetTotal(name) - QDKP2_GetSpent(name) < 0 then
      local msg=string.gsub(QDKP2_LOC_Negative,"$NAME",OriginalName)
      QDKP2_Msg(QDKP2_COLOR_RED .. msg)
    end
  end
  
  if QDKP2_CHANGE_NOTIFY_WENT_NEGATIVE then
    if QDKP2_GetTotal(name) - QDKP2_GetSpent(name) < 0 and oldTotal - oldSpent >= 0 then
      local msg=string.gsub(QDKP2_LOC_BecomedNegative,"$NAME",OriginalName)
      QDKP2_Msg(QDKP2_COLOR_RED .. msg)
    end
  end

  QDKP2_StopCheck()
end

-- this adds to the value in the local varables that store the DKPs (both total and cumulative)
-- Usage = QDKP2_AddTotals(name, tot, spent, hours, reason, timestamp, ToLog, ToDisplay)
-- all arguments are optionals except for the name.
-- you can pass a string like "10%" for total and spent, and it will calculate in relation with net DKP.

-- QDKP2_AddTotals(name, tot, spent, hours, reason, timestamp, logIt, msgIt)
-- QDKP2_AddTotals(name,epChange,nil,nil,"EP Decay ("..W2.."%%)",nil,true)

function QDKP_decay(name, decay)

  --local OriginalName=name
 -- DEFAULT_CHAT_FRAME:AddMessage("Doing Decay for: " .. name)

  if not QDKP2note[name] then 
    QDKP2_Msg(QDKP2_COLOR_RED..QDKP2_LOC_NoPlayerInChance)
    return
  end
  
  local oldEP = QDKP2_GetTotal(name)
  local oldGP = QDKP2_GetSpent(name)
  
  local epChange=RoundNum(oldEP*decay/100)
  local gpChange=RoundNum(oldGP*decay/100)

  QDKP2_AddTotals(name,-epChange,-gpChange,nil,"EP and GP Decay ("..decay.."%%)",timestamp,true, false)

  QDKP2_Refresh_Roster("refresh")
  QDKP2_Refresh_Log("refresh")
end


function QDKP2_PayLoot(name, quota, loot, ZS)
  if not ZS then  
    local timestamp=QDKP2_Timestamp()
    QDKP2_AddTotals(name,nil,quota,nil,loot,timestamp,true, true)
    QDKP2log_Link("RAID",name,timestamp)  
  else
    QDKP2_ZeroSum(name, quota , loot)
  end
  --QDKP2_Msg(name.." "..QDKP2_GetLastLogText(QDKP2_GetMain(name)))
  if (QDKP2_SENDTRIG_CHARGE or QDKP2_SENDTRIG_MODIFY) and not ZS then 
    QDKP2_UploadAll()
  end
end

function QDKP2_SearchForWinner(txt)
  local buildWord = ""
  local stringSize=string.len(txt)
  local amount
  local name
  local str=string.lower(txt)
  local FoundTrigger
  for i=1,table.getn(QDKP2_LOC_WinTrigger) do
    if string.find(str, QDKP2_LOC_WinTrigger[i]) then
      FoundTrigger=true
      break
    end
  end
  
  if QDKP2_DetectBids and FoundTrigger then
    for i=1, stringSize do
      local char = string.sub(str,i,i)
      if (char ~= " " and char ~= "," and char ~= ".") then
        buildWord = buildWord .. char
      end
      if char == " " or char == "," or char == "." or i == stringSize then
        local numberTry = tonumber(buildWord)
        local FormatName = QDKP2_FormatName(buildWord)
        if numberTry then
          amount=numberTry
        elseif QDKP2_IsInGuild(FormatName) then
          name= FormatName
        end
        buildWord = ""
      end
    end
    if amount and name and QDKP2_ChatLootItem then
      QDKP2_OpenToolboxForCharge(name,amount,QDKP2_ChatLootItem) 
    end
  end
end

------------------------------------------ DKP AWARDING FUNCTIONS ---------------------------

--Gives DKP to the whole raid
function QDKP2_GiveRaidDKP(dkpIncrease,Reason)
 
  dkpIncrease=tonumber(dkpIncrease) 

  if not dkpIncrease or dkpIncrease==0 then return; end
  
  if QDKP2_IsRaidPresent() then
    local timeStamp = QDKP2_Timestamp()
    
    for i=1, QDKP2_GetNumRaidMembers() do
        
      local name, rank, subgroup, level, class, fileName, zone, online, isDead = QDKP2_GetRaidRosterInfo(i);
      
      if QDKP2_IsInGuild(name) then
      
      local MinRank=QDKP2_minRank(name)
      local InZone
      if (zone == QDKP2_RaidLeaderZone) or zone=="Offline" then InZone=true; end
      
        if (online or QDKP2_GIVEOFFLINE) and (MinRank or QDKP2_UNDKPABLE_RAIDBOSS) and (InZone or QDKP2_GIVEOUTZONE) and (QDKP2_GetNet(name)<QDKP2_MAXIMUM_NET  or dkpIncrease<0) then
          
          --QDKP2_AddTotals(name, dkpIncrease)
	  QDKP2log_Entry(name,Reason,QDKP2LOG_MODIFY,0, {0, nil, nil}, timeStamp ,QDKP2LOG_RAIDAW)
	
        elseif not (online or QDKP2_GIVEOFFLINE) then
          QDKP2log_Entry(name, Reason, QDKP2LOG_NOOFFLINE, nil,  {0, nil, nil}, timeStamp,QDKP2LOG_RAIDAW)

        elseif not (MinRank or QDKP2_UNDKPABLE_RAIDBOSS) then
          QDKP2log_Entry(name, Reason, QDKP2LOG_NORANK, nil,  {0, nil, nil}, timeStamp,QDKP2LOG_RAIDAW)
	  
	elseif not (InZone or QDKP2_GIVEOUTZONE) then
	  QDKP2log_Entry(name, Reason, QDKP2LOG_NOZONE, nil,  {0, nil, nil}, timeStamp,QDKP2LOG_RAIDAW)
	  
	elseif not (QDKP2_GetNet(name)<QDKP2_MAXIMUM_NET  or dkpIncrease<0) then
	  QDKP2log_Entry(name, Reason, QDKP2LOG_NOLIMIT, nil,  {0, nil, nil}, timeStamp,QDKP2LOG_RAIDAW)
	  
        end
      end
    end
    QDKP2log_Entry("RAID",Reason,QDKP2LOG_MODIFY, dkpIncrease,{0,nil,nil},timeStamp,QDKP2LOG_RAIDAWMAIN)
    QDKP2_SetLogEntry("RAID",1,dkpIncrease,"","",Reason)
    if Reason then
      local msg=QDKP2_LOC_ReceivedReas
      msg=string.gsub(msg,"$AMOUNT",tostring(dkpIncrease))
      msg=string.gsub(msg,"$REASON",Reason)
      QDKP2_Msg(QDKP2_COLOR_WHITE..msg)
    else
      local msg=string.gsub(QDKP2_LOC_Received,"$AMOUNT",tostring(dkpIncrease))
      QDKP2_Msg(QDKP2_COLOR_WHITE..msg)
    end
    QDKP2_Refresh_Roster("refresh")
    QDKP2_Refresh_Log("refresh")
    if QDKP2_SENDTRIG_RAIDAWARD then
      QDKP2_UploadAll()
    end
  else
    QDKP2_Msg(QDKP2_COLOR_YELLOW..QDKP2_LOC_NotIntoARaid)
    return
  end
end

--ZeroSum Award

function QDKP2_ZeroSum(giverName, amount, item)

  --amount=tonumber(amount)

  if not amount or amount==0 then return; end
  
  local signedName=giverName
  if QDKP2_IsAlt(giverName) then
    local mainName=QDKP2_GetMain(giverName)
    signedName= mainName..";"..giverName
  end
  
  
  if QDKP2_GetNet(giverName)==QDKP2_MINIMUM_NET then
    QDKP2_Msg(QDKP2_COLOR_RED.."Impossible to proceed with ZeroSum. "..giverName.."'s Net DKP amount is equal to the minimum cap.")
    return
  end
  if QDKP2_GetNet(giverName)-amount<QDKP2_MINIMUM_NET then
    QDKP2_Msg(QDKP2_COLOR_RED..giverName.."'s Net DKP amount is too low. The maximum amount of DKP you can charge is "..tostring(QDKP2_GetNet(giverName)-QDKP2_MINIMUM_NET)..".")
    return
  end
  
  if QDKP2_IsRaidPresent() then
    local timeStamp = QDKP2_Timestamp()
    
    for i=1, QDKP2_GetNumRaidMembers() do
        
      local name, rank, subgroup, level, class, fileName, zone, online, isDead = QDKP2_GetRaidRosterInfo(i);
      
      if QDKP2_IsInGuild(name) and name ~= giverName then
      
      local MinRank=QDKP2_minRank(name)
      
      local InZone
      if (zone == QDKP2_RaidLeaderZone) or zone=="Offline" then InZone=true; end
      
        if (online or QDKP2_GIVEOFFLINE) and (MinRank or QDKP2_UNDKPABLE_ZEROSUM) and (InZone or QDKP2_GIVEOUTZONE) and (QDKP2_GetNet(name)<QDKP2_MAXIMUM_NET or amount<0) then
          
	  QDKP2log_Entry(name,signedName,QDKP2LOG_MODIFY,0, {0, nil, nil}, timeStamp ,QDKP2LOG_ZS)
	
        elseif not (online or QDKP2_GIVEOFFLINE) then
          QDKP2log_Entry(name, signedName, QDKP2LOG_NOOFFLINE, nil,  {0, nil, nil}, timeStamp,QDKP2LOG_ZS)

        elseif not (MinRank or QDKP2_UNDKPABLE_ZEROSUM) then
          QDKP2log_Entry(name, signedName, QDKP2LOG_NORANK, nil,  {0, nil, nil}, timeStamp,QDKP2LOG_ZS)
	  
	elseif not  (InZone or QDKP2_GIVEOUTZONE) then
	  QDKP2log_Entry(name, signedName, QDKP2LOG_NOZONE, nil,  {0, nil, nil}, timeStamp,QDKP2LOG_ZS)
	  
	elseif not (QDKP2_GetNet(name)<QDKP2_MAXIMUM_NET or amount<0) then
	  QDKP2log_Entry(name, signedName, QDKP2LOG_NOLIMIT, nil,  {0, nil, nil}, timeStamp,QDKP2LOG_ZS)
	  
        end
      end
    end
    QDKP2log_Entry(giverName, item,QDKP2LOG_MODIFY, -amount,  {nil, 0, nil}, timeStamp,QDKP2LOG_ZSMAIN)
    QDKP2log_Link("RAID", signedName, timeStamp)
    QDKP2_SetLogEntry(QDKP2_GetMain(giverName),1,nil,amount,nil,item)
    if item then
      local msg=QDKP2_LOC_ZSRecReas
      msg=string.gsub(msg,"$NAME",giverName)
      msg=string.gsub(msg,"$AMOUNT",tostring(amount))
      msg=string.gsub(msg,"$REASON",item)
      QDKP2_Msg(QDKP2_COLOR_WHITE..msg)
    else
      local msg=QDKP2_LOC_ZSRec
      msg=string.gsub(msg,"$NAME",giverName)
      msg=string.gsub(msg,"$AMOUNT",tostring(amount))
      QDKP2_Msg(QDKP2_COLOR_WHITE..msg)
    end
    QDKP2_Refresh_Roster("refresh")
    QDKP2_Refresh_Log("refresh")
    if QDKP2_SENDTRIG_ZS then
      QDKP2_UploadAll()
    end
  else
    QDKP2_Msg(QDKP2_COLOR_YELLOW..QDKP2_LOC_NotIntoARaid)
    return
  end
end

  

--This update the Zerosum
function QDKP2_ZeroSum_Update(giverName,logIndex)
  local mainLog=QDKP2log[giverName][logIndex]
  local timeStamp=mainLog[QDKP2LOG_TIME]
  local Type=QDKP2log[mainLog]
  local Amount=mainLog[QDKP2LOG_UNDO][2]
  nameList, indexList = QDKP2_GetLogIndexList(timeStamp)
  local indexTable=QDKP2_RandTable(table.getn(nameList),timeStamp)
  local whoGet={}
  local whoGetIndex={}
  local whoDontGet={}
  local whoDontGetIndex={}
  for i=1,table.getn(nameList) do
    local Name=nameList[indexTable[i]]
    if Name ~= "RAID" and (Name ~= giverName or QDKP_GIVEZSTOLOOTER) then
      local Index=indexList[indexTable[i]]
      local Log=QDKP2log[Name][Index]
      local Type=QDKP2log_GetType(Log)
      if QDKP2_IsDKPEntry(Type) then
        table.insert(whoGet,Name)
        table.insert(whoGetIndex,Index)
      else
        table.insert(whoDontGet,Name)
        table.insert(whoDontGetIndex,Index)
      end
    end
  end
  local Sharer = table.getn(whoGet)
  if Sharer==0 then
    QDKP2_Msg(QDKP2_COLOR_YELLOW.."Warning: No players eligible for the share found. Shared DKP will be destroyed.")
  end
  local Share = Amount/Sharer
  local Base = math.floor(Share)
  local RestShare = RoundNum((Share-Base)*Sharer)
  local ToNoDKP=math.ceil(Amount/(Sharer+1))
  
  for i=1,Sharer do
    local Name=whoGet[i]
    local Index=whoGetIndex[i]
    local Log=QDKP2log[Name][Index]
    local Undo=Log[QDKP2LOG_UNDO]
    local Reason=Log[QDKP2LOG_ACTION]
    local MyShare=Base
    if i<=RestShare then MyShare=Base+1; end
    QDKP2_SetLogEntry(Name,Index,MyShare,Undo[2],nil,Reason,nil,true)
  end
  
  for i=1,table.getn(whoDontGet) do
    local Name=whoDontGet[i]
    local Index=whoDontGetIndex[i]
    local Log=QDKP2log[Name][Index]
    local Undo=Log[QDKP2LOG_UNDO]
    local Reason=Log[QDKP2LOG_ACTION]
    QDKP2_SetLogEntry(Name,Index,ToNoDKP,nil,nil,Reason,nil,true)
  end
end
            	    
---- timer

--called every like 1 min, it increases the timer acc by 1. if it is greater than
--QDKP2_TIME_UNTIL_UPLOAD it call th hour tick. i use this way rather than
--just using QDKP2_Chron to call QDKP2_HoursTick() every tick because in this way
--i can save QDKP2_TimerBase and thus resuming it if i get a DC

function QDKP2_CheckHours() 
  if QDKP2_TimerBase then
    --Chronos.schedule(QDKP2_TIME_BETWEEN_CHECKS, QDKP2_CheckHours)
    if QDKP2_IsRaidPresent() then
      if (time() - QDKP2_TimerBase) / 60  >= QDKP2_TIME_UNTIL_UPLOAD then
        QDKP2_TimerBase = QDKP2_TimerBase + (QDKP2_TIME_UNTIL_UPLOAD*60)
        QDKP2_HoursTick()
      end
    end
  end
end

--gives dkp on the hour
function QDKP2_HoursTick()
  
  if QDKP_TIMER_RAIDLOG_TICK then
    local msg=string.gsub(QDKP2_LOC_RaidTimerLog,"$TIME",tostring(QDKP2_TIME_UNTIL_UPLOAD/60))
    QDKP2log_Event("RAID",msg)
  end
  
  local SomeoneAwarded

  for i=1, QDKP2_GetNumRaidMembers() do
    local name, rank, subgroup, level, class, fileName, zone, online, isDead = QDKP2_GetRaidRosterInfo(i);
 
    local InZone 
    if (zone == QDKP2_RaidLeaderZone) or (zone=="Offline") then InZone=true; end
    
    if QDKP2_IsInGuild(name) then
      if (online or QDKP2_GIVEOFFLINE) and (InZone or QDKP2_GIVEOUTZONE) then
        
        local OrigHours = math.floor(QDKP2_GetRaidTime(name)+0.01)
        
        QDKP2_AddTotals(name, nil, nil, QDKP2_TIME_UNTIL_UPLOAD/60, QDKP2_LOC_TimerTick, nil, QDKP_TIMER_LOG_TICK)
        
        local NowHours = math.floor(QDKP2_GetRaidTime(name)+0.01)
                
        if NowHours ~= OrigHours then  --use this to detect if i've hit an integer (eg 2.9 + 0.2 = 3.1)
          if (QDKP2_minRank(name) or QDKP2_UNDKPABLE_TIME) and (QDKP2_GetNet(name)<QDKP2_MAXIMUM_NET  or QDKP2_dkpPerHour<0) then
            QDKP2_AddTotals(name, QDKP2_dkpPerHour, nil, nil, QDKP2_LOC_IntegerTime, nil, true, QDKP_TIMER_SHOW_AWARDS)
            SomeoneAwarded = true
          elseif not (QDKP2_minRank(name) or QDKP2_UNDKPABLE_TIME) then
            QDKP2log_Entry(name, QDKP2_LOC_IntegerTime, QDKP2LOG_NORANK, nil,  {QDKP2_dkpPerHour, nil, nil})
	    
	  elseif not (QDKP2_GetNet(name)<QDKP2_MAXIMUM_NET   or QDKP2_dkpPerHour<0) then
	    QDKP2log_Entry(name, QDKP2_LOC_IntegerTime, QDKP2LOG_NOLIMIT, nil,  {QDKP2_dkpPerHour, nil, nil})
	    
          end
        end
        
      elseif not (online or QDKP2_GIVEOFFLINE) then
        QDKP2log_Entry(name, nil, QDKP2LOG_NOOFFLINE, nil,  {nil, nil, QDKP2_TIME_UNTIL_UPLOAD/60})
	
      elseif not (InZone or QDKP2_GIVEOUTZONE) then
        QDKP2log_Entry(name, nil, QDKP2LOG_NOZONE, nil,  {nil, nil, QDKP2_TIME_UNTIL_UPLOAD/60})
      end
    end
  end
  
  QDKP2_Msg(QDKP2_COLOR_GREEN..QDKP2_LOC_HoursUpdted)
  QDKP2_Refresh_Log("refresh")
  QDKP2_Refresh_Roster("refresh")
  if (SomeoneAwarded and QDKP2_SENDTRIG_TIMER_AWARD) or QDKP2_SENDTRIG_TIMER_TICK then
    QDKP2_UploadAll()
  end
end

function QDKP2_TimerOn(DoNotControl) -- start the timer
  if QDKP2_IsRaidPresent() or DoNotControl then
    QDKP2_frame1_timer:SetText("Timer: On")
    QDKP2_frame1_onOff:SetText("OFF")
    if QDKP2_TimerBase then
      QDKP2_Msg(QDKP2_COLOR_BLUE..QDKP2_LOC_TimerResumed)
    else
      QDKP2_TimerBase = time()
      QDKP2_Msg(QDKP2_COLOR_BLUE..QDKP2_LOC_TimerStarted)
      QDKP2log_Event("RAID",QDKP2_LOC_TimerStarted)
    end
    Chronos.scheduleRepeating("Raid Timer", QDKP2_TIME_BETWEEN_CHECKS, QDKP2_CheckHours)
    QDKP2_Refresh_Log("refresh")
  else  
    QDKP2_Msg(QDKP2_COLOR_YELLOW..QDKP2_LOC_NotIntoARaid)
  end
end

function QDKP2_TimerOff() --stops the timer
  QDKP2_frame1_timer:SetText("Timer: Off")
  QDKP2_frame1_onOff:SetText("ON")
  QDKP2_Msg(QDKP2_COLOR_BLUE..QDKP2_LOC_TimerStop)
  QDKP2log_Event("RAID",QDKP2_LOC_TimerStop)
  QDKP2_TimerBase = nil
  Chronos.unscheduleByName("Raid Timer")
  QDKP2_Refresh_Log("refresh")
end

---- ironman

function QDKP2_IronManStart() --sets the ironman mark
  if QDKP2_IsRaidPresent() then
    QDKP2ironMan = QDKP2raid
    QDKP2ironMan_time = time()
    QDKP2frame1_ironman:SetText(QDKP2_LOC_Finish)
    for i=1, table.getn(QDKP2ironMan) do
      if QDKP2raidOffline[QDKP2ironMan[i]] == "offline" then
        QDKP2log_Entry(QDKP2ironMan[i],QDKP2_LOC_StartButOffline,QDKP2LOG_LEAVED)
      end
    end
    QDKP2log_Event("RAID",QDKP2_LOC_IronmanMarkPlaced)
    QDKP2_Msg(QDKP2_LOC_IronmanMarkPlaced)
    QDKP2_RefreshAll()
  else
    QDKP2_Msg(QDKP2_COLOR_YELLOW..QDKP2_LOC_NotIntoARaid)
    return
  end
end

function QDKP2_IronManWipe() --abort the ironman couting without giving anything
  QDKP2ironMan_time = nil
  QDKP2ironMan = {}
  QDKP2frame1_ironman:SetText(QDKP2_LOC_Start)
  QDKP2log_Event("RAID",QDKP2_LOC_DataWiped)
end


function QDKP2_InronManFinish(BonusDKP) --calculates who award the ironman bonus and return a list with their name.
    
  BonusDKP=tonumber(BonusDKP)
    
  local EndMark = time()
  local Timestamp=QDKP2_Timestamp()
  local awarded = 0
    
  for i=1, table.getn(QDKP2ironMan) do
    local name = QDKP2ironMan[i]
    if (QDKP2_minRank(name) or QDKP2_UNDKPABLE_IRONMAN) and (QDKP2_GetNet(name)<QDKP2_MAXIMUM_NET  or BonusDKP<0) then
      name=QDKP2_GetMain(name)
      local Log = QDKP2log[name]
      local logfinish = 0
      for j=1, table.getn(Log) do
        if Log[j][QDKP2LOG_TIME]<QDKP2ironMan_time then
          logfinish = j - 1
          break
        end
      end
        
      local nettime = 0
      local inside = QDKP2ironMan_time
        
      for j=1, logfinish do
        local w = logfinish - j + 1
          local Type=QDKP2log_GetType(Log[w])
	  
        if Type == QDKP2LOG_LEAVED and inside then
          nettime = nettime + Log[w][QDKP2LOG_TIME] - inside
          inside = nil
          out = Log[w][QDKP2LOG_TIME]
            
        elseif Type == QDKP2LOG_JOINED and out then
          inside = Log[w][QDKP2LOG_TIME]
          out = nil
        end
      end
        
      if inside or not QDKP2_IRONMAN_INWHENENDS then
        if inside then
          nettime = nettime + EndMark - inside
        end
        local Presence = (100 * nettime) / ( EndMark - QDKP2ironMan_time)
        if Presence >= QDKP2_IRONMAN_PER_REQ then
          QDKP2_AddTotals(name,BonusDKP)
	  QDKP2log_Entry(name,"Iron Man Bonus",QDKP2LOG_MODIFY,BonusDKP, {BonusDKP, nil, nil}, Timestamp ,QDKP2LOG_RAIDAW)
          awarded=awarded+1
        else
          QDKP2log_Entry(name, "Iron Man Bonus", QDKP2LOG_NOLOWRAID, nil,  {BonusDKP, nil, nil}, Timestamp,QDKP2LOG_RAIDAW)
        end
      end
    elseif not (QDKP2_minRank(name) or QDKP2_UNDKPABLE_IRONMAN) then
      QDKP2log_Entry(name, "Iron Man Bonus", QDKP2LOG_NORANK, nil,  {BonusDKP, nil, nil}, Timestamp,QDKP2LOG_RAIDAW)
      
    elseif not (QDKP2_GetNet(name)<QDKP2_MAXIMUM_NET or BonusDKP<0) then
      QDKP2log_Entry(name, "Iron Man Bonus", QDKP2LOG_NOLIMIT, nil,  {BonusDKP, nil, nil}, Timestamp,QDKP2LOG_RAIDAW)
      
    end
  end
  QDKP2log_Entry("RAID","Iron Man bonus", QDKP2LOG_MODIFY, BonusDKP, {BonusDKP,nil,nil}, Timestamp,QDKP2LOG_RAIDAWMAIN)
  if awarded==0 then
    QDKP2_Msg(QDKP2_COLOR_GREY.."No one awarded the Iron Man Bonus")
  else
    QDKP2_Msg(QDKP2_COLOR_BLUE..tonumber(awarded).." players awarded the Iron Man bonus")
  end
  QDKP2frame1_ironman:SetText("Start")
  if QDKP2_SENDTRIG_IRONMAN then
    QDKP2_UploadAll()
  end
  QDKP2ironMan_time = nil
  QDKP2ironMan = nil
  QDKP2_RefreshAll()
  return
end

-------------------------------------- UPLOAD FUNCTIONS ----------------

--this function will update all dkp changes in raid to officernotes
function QDKP2_UploadAll()
  if not QDKP2_OfficerMode() then
    QDKP2_Msg(QDKP2_COLOR_RED.."You aren't authorized to upload changes.")
    return
  end
  local guildCount=0
  local localCount=0
  local uploaded=0
  local indexList = QDKP2_GetIndexList()
  for i=1, table.getn(QDKP2name) do
    local name = QDKP2name[i]
    if (QDKP2_IsModified(name) and not QDKP2_IsAlt(name)) or (QDKP2_AltsRestore[name] and QDKP2_AltsRestore[name]=="") then
      if QDKP2_UpdateNoteByName(name, indexList) then
        if QDKP2_IsExternal(name) then
          localCount = localCount + 1
	else
	  guildCount=guildCount+1
	end
      end
      uploaded = uploaded + 1
    elseif QDKP2_AltsRestore[name] and QDKP2_AltsRestore[name]~="" then
      local index=indexList[name]
      if index then
        QDKP2_GuildRosterSetDatafield(index, QDKP2_AltsRestore[name])
        if QDKP2_IsExternal(name) then
          localCount = localCount + 1
	  QDKP2log_ConfirmEntries(name,true)
	else
	  guildCount=guildCount+1
	end
      end
      uploaded = uploaded + 1
    end
  end
  QDKP2_AltsRestore={}
  if (guildCount==0 and localCount==0) then   -- if we had no uploads
    QDKP2_Msg(QDKP2_COLOR_GREY..QDKP2_LOC_NoMod)
  elseif ((localCount+guildCount)~=uploaded) then
    local msg=string.gsub(QDKP2_LOC_Failed,"$FAILED",tostring(count-uploaded))
    QDKP2_Msg(QDKP2_COLOR_RED..msg)
    GuildRoster()
  elseif guildCount==0 then
    local msg=string.gsub(QDKP2_LOC_SucLocal,"$UPLOADED",tostring(localCount))
    QDKP2_Msg(QDKP2_COLOR_GREEN..msg)
    QDKP2log_ConfirmEntries("RAID",true)
  else
    local msg=QDKP2_LOC_Successful
    msg=string.gsub(msg,"$UPLOADED",tostring(uploaded))
    msg=string.gsub(msg,"$TIME",tostring(QDKP2_CHECK_UPLOAD_DELAY+QDKP2_CHECK_REFRESH_DELAY))
    QDKP2_Msg(QDKP2_COLOR_GREEN..msg)
    QDKP2_InitiateCheck() 
  end
  if localCount>0 then QDKP2_RefreshGuild(); end
  QDKP2_Refresh_Roster("refresh")
end

--------------------------------

--this function modifies the officer notes of <name>. Indextable is optional,
--used to keep it in case of mass upload

function QDKP2_UpdateNoteByName(name, indexList) 
  if not indexList then
    indexList = QDKP2_GetIndexList()
  end
  local index = indexList[name]

  if index then 
    local total = QDKP2_GetTotal(name)
    local spent = QDKP2_GetSpent(name)
    local net = total - spent
    local hours = QDKP2_GetHours(name)
    if QDKP2_IsExternal(name) then
      QDKP2log_ConfirmEntries(name,true)
    end
    return QDKP2_SetDKPNote(index, net, total, spent, hours)
  else
    local msg=string.gsub(QDKP2_LOC_IndexNoFound,"$NAME",name)
    QDKP2_Msg(QDKP2_COLOR_RED..msg)
    QDKP2log_Entry(name, QDKP2_LOC_IndexNoFoundLog,QDKP2LOG_CRITICAL)
    QDKP2_Refresh_Log("refresh")
  end
end

--------------------------------

--This fucntion will set a note given index and note parameters
function QDKP2_SetDKPNote(index, net, total, spent, hours)
  local output = QDKP2_MakeNote(net, total, spent, hours)
  if index then
    QDKP2_GuildRosterSetDatafield(index, output) 
  return 1
  end
end

-- This return a list in the form of [guildmember] = index, to use with QDKP2_SetDKPNote
function QDKP2_GetIndexList()
  local output = {}
  for i=1, QDKP2_GetNumGuildMembers(true) do
    local name, rank, rankIndex, level, class, zone, note, officernote,datafield, online, status = QDKP2_GetGuildRosterInfo(i);
    output[name] = i
  end
  return output
end

function QDKP2_ResetPlayer(name)    ----This deletes all local data and call guild's download. It's called when i find an error in player's value.
  QDKP2_Msg( QDKP2_COLOR_RED..name.."'s local data seems to be corrupted. Sorry, I have to reset it. (You'll lose his personal log, session data and all unuploaded changes)" )
  
  local tempRaid={}
  for i=1,table.getn(QDKP2raid) do
    local checkName=QDKP2raid[i]
    if checkName ~= name then table.insert(tempRaid,checkName); end
  end
  QDKP2raid=tempRaid
  local tempGuild={}
  for i=1,table.getn(QDKP2name) do
    local checkName=QDKP2name[i]
    if checkName ~= name then table.insert(tempGuild,checkName); end
  end
  QDKP2name=tempGuild

  QDKP2rank[name]        = nil
  QDKP2rankIndex[name]   = nil
  QDKP2class[name]       = nil

  QDKP2note[name] = nil

  QDKP2stored[name] = nil

  QDKP2ironMan[name]     = nil

  QDKP2log[name]         = nil

  QDKP2session[name]       = nil

  QDKP2_Alts[name]       = nil
  QDKP2_AltsRestore[name]= nil 
  
  QDKP2standby[name] = nil
  
  QDKP2_RefreshGuild()
  QDKP2_UpdateRaid()
  GuildRoster()
  
end
-------------------------------------- DOWNLOAD FUNCTIONS ----------------

--two dummies of QDKP_DownloadGuild for a better reading
function QDKP2_RefreshGuild()
  QDKP2_DownloadGuild(nil, false)
end

function QDKP2_NewSession(SessionName)
  QDKP2_DownloadGuild(SessionName,true)
end

--DownloadGuild will update the not-modified players if called with nil or false, will reset all as in the
--officer notes otherwise.

function QDKP2_DownloadGuild(SessionName, NewSession)
  
  if not QDKP2_ACTIVE then
    QDKP2_Debug(1, "Update","Aborting Guild Update, i'm not ready")
    return
  end
  QDKP2_Debug(1, "Update","Updating Guild Data")
  if QDKP2_OfficerMode() then
    QDKP2frame1_upload:Enable()
  else
    QDKP2frame1_upload:Disable()
  end
  
  local timeStamp = QDKP2_Timestamp()

  local sessionName
  if NewSession then
    
    if SessionName=="" then
      QDKP2_OpenInputBox(QDKP2_LOC_NewSessionQ,QDKP2_NewSession,true)
      return
    end
    QDKP2log_ConfirmEntries("RAID",false)
    QDKP2log_Entry("RAID",SessionName,QDKP2LOG_NEWSESSION,nil,nil,timeStamp)
    QDKP2session = {}
    QDKP2note = {}
    QDKP2_AltsRestore = {}
    QDKP2_StopCheck()
  end

  local QDKP2classTEMP = {}
  local QDKP2rankTEMP = {}
  local QDKP2rankIndexTEMP = {}
  QDKP2_Alts = {}
  local nameTemp = {}
    
  local num = 0
  local new = 0

  for i=1, QDKP2_GetNumGuildMembers(true) do
    
    local name, rank, rankIndex, level, class, zone, note, officernote, datafield,online, status, isInGuild = QDKP2_GetGuildRosterInfo(i)
    
    if isInGuild and QDKP2_IsExternal(name) then
      QDKP2_Msg(name.." has become a Guild Member. I'm removing the external record, please upload changes as soon as possible.")
      QDKP2_DelExternal(name)
      QDKP2stored[name]={0,0,0}
      QDKP2_DownloadGuild(SessionName, NewSession)
      return
      
    end
    
    local Hide_Rank=false
    for v=1,table.getn(QDKP2_HIDE_RANK) do
      if rank==QDKP2_HIDE_RANK[v] then 
        Hide_Rank=true
        break
      end
    end
    local Main=QDKP2_LookForAlt(datafield)

    if not Hide_Rank and level>=QDKP2_MINIMUM_LEVEL and ((not QDKP2_IsInGuild(Main) and not QDKP2_AltsRestore[name]) or QDKP2_AltsRestore[name]=="") then

      local net, total, spent, hours = QDKP2_ParseNote(datafield)
            
      if (net+spent~=total) then
        local msg=string.gsub(QDKP2_LOC_DifferentTot,"$NAME",name)
        QDKP2_Msg(QDKP2_COLOR_RED..msg)
        QDKP2_Msg(QDKP2_COLOR_BLUE..QDKP2_LOC_Net.."="..net..", "..QDKP2_LOC_Spent.."="..spent..", "..QDKP2_LOC_Total.."="..total)
      end
      
      table.insert(nameTemp,name)  --used to keep track of the order
      QDKP2rankTEMP[name] = rank
      QDKP2rankIndexTEMP[name]=rankIndex
      QDKP2classTEMP[name] = class
      
      local NewEntry = false
      if not QDKP2note[name] then 
        QDKP2note[name] = {total,spent,hours}
	QDKP2session[name]={0,0,0}
        new = new + 1
        NewEntry = true
      end
      
      --this is used to detect if someone has changed a player you are modifing
      if QDKP2stored[name] and not QDKP2_ModifiedDuringCheck then  

	  local modTotal
	  local modSpent
	  local modHours
	  local oldTotal = QDKP2stored[name][QDKP2_TOTAL] or 0
	  local oldSpent = QDKP2stored[name][QDKP2_SPENT] or 0
	  local oldHours = QDKP2stored[name][QDKP2_HOURS] or 0
          local actualTotal=QDKP2_GetTotal(name)
          local actualSpent=QDKP2_GetSpent(name)
          local actualHours=QDKP2_GetHours(name)
	  
          if (total ~= actualTotal and total ~= oldTotal) then
            local diff = RoundNum(total-oldTotal)
            if math.abs(diff) >= 0.99 then 
              QDKP2note[name][QDKP2_TOTAL] = actualTotal + diff
              QDKP2session[name][QDKP2_TOTAL] = QDKP2session[name][QDKP2_TOTAL] + diff
              QDKP2_StopCheck()
	      modTotal=diff
 --             if IsModified then
 --               QDKP2_Msg(QDKP2_COLOR_YELLOW.."Detected symultaneous editing on "..name..". Gains "..diff.." DKP")
  --            end
            end
          end
          if (spent ~= actualSpent and spent ~= oldSpent) then
            local diff = RoundNum(spent-oldSpent)
            if math.abs(diff) >= 0 then 
              QDKP2note[name][QDKP2_SPENT] = actualSpent + diff
              QDKP2session[name][QDKP2_SPENT] = QDKP2session[name][QDKP2_SPENT] + diff
              QDKP2_StopCheck()
              modSpent=diff
  --            if IsModified then 
    --            QDKP2_Msg(QDKP2_COLOR_YELLOW.."Detected symultaneous editing on "..name..". Spends "..diff.." DKP")
      --        end
            end
          end
          
          if math.abs(hours - actualHours) > 0.09  and math.abs(hours - oldHours) > 0.09 then
            local diff = RoundNum((hours-oldHours)*10)/10  --this to make the difference with only a decimal
            if math.abs(diff) > 0 then
              QDKP2note[name][QDKP2_HOURS] = actualHours + diff
              QDKP2session[name][QDKP2_HOURS] = QDKP2session[name][QDKP2_HOURS] + diff
              QDKP2_StopCheck()
              if QDKP_TIMER_LOG_TICK then
                modHours=diff
              end
--              if IsModified then
 --               QDKP2_Msg(QDKP2_COLOR_YELLOW.."Detected symultaneous editing on "..name..". Gains "..diff.." Hours")
 --             end
            end
          end
	  if modTotal or modSpent or modHours then
	    QDKP2log_Entry(name,nil,QDKP2LOG_EXTERNAL,nil,{modTotal, modSpent, modHours})
	  end
      end
      
      if NewEntry then
        if NewSession then
          QDKP2log_ConfirmEntries(name,false)
          QDKP2log_Entry(name,SessionName,QDKP2LOG_NEWSESSION,nil,nil,timeStamp)
        else
          QDKP2log_Entry(name,"Player added to Guild Roster",QDKP2LOG_NEWSESSION)
	  if QDKP2_REPORT_NEW_GUILDMEMBER then
	    local msg=QDKP2_LOC_NewGuildMember
	    msg=string.gsub(msg,"$NAME",name)
	    QDKP2_Msg(QDKP2_COLOR_YELLOW..msg)
	  end
        end
      end
      
      QDKP2stored[name] = {total,spent,hours}
      
      num=num+1

    elseif QDKP2_IsInGuild(Main) or QDKP2_AltsRestore[name] then
      if QDKP2_AltsRestore[name] then Main=QDKP2_AltsRestore[name]; end
      table.insert(nameTemp,name)
      QDKP2_Alts[name]=Main
      QDKP2rankTEMP[name] = rank
      QDKP2rankIndexTEMP[name]=rankIndex
      QDKP2classTEMP[name] = class
    end

  end
  
  QDKP2name = nameTemp
  QDKP2class=QDKP2classTEMP
  QDKP2rank=QDKP2rankTEMP
  QDKP2rankIndex=QDKP2rankIndexTEMP
  
  QDKP2_RefreshAll()
  
  QDKP2_ModifiedDuringCheck = false
  
  if NewSession then
    local msg=string.gsub(QDKP2_LOC_NewSession,"$SESSIONNAME",SessionName)
    QDKP2_Msg(msg)
  else
    if new ~= 0 and not QDKP2_REPORT_NEW_GUILDMEMBER then
      QDKP2_Msg(QDKP2_COLOR_GREEN.."Added "..new.." players.")
    end
  end

end

------------------------------------------------CHECK--------------------------

--These functions controls if guildnotes and list are updated.

function QDKP2_InitiateCheck(AddTries)
  
  if AddTries then
    QDKP2checkTries=QDKP2checkTries+1
  else
    QDKP2checkTries=0
  end

  QDKP2_CHECK_RUN = 0  --plan the check
  QDKP2_CHECK_RENEW_TIMER = 0
  QDKP2_CheckInProgress = true
  Chronos.scheduleByName("PlannedRefresh",QDKP2_CHECK_REFRESH_DELAY, QDKP2_StartPlannedRefresh) 
  Chronos.scheduleByName("Check",QDKP2_CHECK_REFRESH_DELAY+1, QDKP2_Check)
end
--this is used to detect the update to the guild rooster and delay the real
--check to give time to the changes to propagate in the local cache. (really needed?)

function QDKP2_Check()
  
  if not QDKP2_CheckInProgress then return; end
  
  if not QDKP2_REFRESHED_GUILD_ROSTER then
    QDKP2_CHECK_RUN = QDKP2_CHECK_RUN + 1
    if QDKP2_CHECK_RUN >= QDKP2_CHECK_TIMEOUT then
      QDKP2_Msg(QDKP2_COLOR_RED.."Cannot obtain an updated Guild list to check for unupdated DKP. Maybe you're lagging too much.")
      return
    end
    QDKP2_CHECK_RENEW_TIMER = QDKP2_CHECK_RENEW_TIMER+1
    if QDKP2_CHECK_RENEW_TIMER >= QDKP2_CHECK_RENEW then
      QDKP2_CHECK_RENEW_TIMER = 0
      GuildRoster()
    end
    Chronos.schedule(1.0, QDKP2_Check)
  else
    --QDKP2_AbortCurrentCheck = false
    Chronos.scheduleByName("CheckGo",QDKP2_CHECK_UPLOAD_DELAY, QDKP2_CheckGo)
  end
end

-- this will download all the officers notes , parse them and then check the
-- values.
function QDKP2_CheckGo()

  --if QDKP2_AbortCurrentCheck then return; end
  QDKP2_CheckInProgress = false
  local nok = 0
  for i=1, GetNumGuildMembers(true) do
    local name, rank, rankIndex, level, class, zone, note, officernote, online, status =  GetGuildRosterInfo(i);
    if not QDKP2_Alts[name] then
        local Datafield
        if QDKP2_OfficerOrPublic==1 then Datafield=officernote
        elseif QDKP2_OfficerOrPublic==2 then Datafield=note
        end
        local net,total,spent,hours = QDKP2_ParseNote(Datafield)
        if (QDKP2_GetNet(name) == net) and (QDKP2_GetTotal(name) == total) and (QDKP2_GetSpent(name) == spent) and (RoundNum(QDKP2_GetHours(name)*10) == RoundNum(hours*10)) then
          QDKP2log_ConfirmEntries(name,true)
        elseif QDKP2_IsModified(name) then
          if QDKP2checkTries < QDKP2_CHECK_TRIES then
            QDKP2_Msg(QDKP2_COLOR_RED.."CHECK: Some players aren't syncronized. Checking again...")
            QDKP2_InitiateCheck(1)
            return
          else
            QDKP2log_Entry(name, "CHECK: Values in officer notes aren't correct.",QDKP2LOG_CRITICAL)
            QDKP2_Msg(QDKP2_COLOR_RED..name.." is not syncronized.")
            nok = nok+1
          end
	end
    end
  end
  if nok == 0 then
    QDKP2_Msg(QDKP2_COLOR_GREEN.."CHECK: DKP are syncronized.")
    QDKP2log_ConfirmEntries("RAID",true)
  else
    QDKP2_Msg(QDKP2_COLOR_RED.."Please try to upload again.")
  end
    
  QDKP2_Refresh_Roster("refresh")
  QDKP2_Refresh_Log("refresh")
end

function QDKP2_StopCheck()

  if QDKP2_CheckInProgress then 
      QDKP2_Msg(QDKP2_COLOR_YELLOW.."Upload Check aborted due to modifications done")
      QDKP2_ModifiedDuringCheck = true
  end
    --QDKP2_AbortCurrentCheck = true
    QDKP2_CheckInProgress = false
    Chronos.unscheduleByName("PlannedRefresh")
    Chronos.unscheduleByName("Check")
    Chronos.unscheduleByName("CheckGo")
    
  --end
end

-- sets the refreshed Guild Roster flag
function QDKP2_StartPlannedRefresh()

  QDKP2_REFRESHED_GUILD_ROSTER = false
  GuildRoster()
end

---------------------------------BACKUP/RESTORE---------------

--Backup the officernotes

function QDKP2_BackUp()
  local tempBackup = {}
  QDKP2_Backup[QDKP2_PLAYER_NAME] = {}
  for i=1, QDKP2_GetNumGuildMembers(true) do
    local name, rank, rankIndex, level, class, zone, note, officernote ,datafield, online, status = QDKP2_GetGuildRosterInfo(i);
    tempBackup[i] = {name, datafield}
  end
  QDKP2_BackupDate[QDKP2_PLAYER_NAME] = date("%d/%m/%y %H:%M")
  QDKP2_Backup[QDKP2_PLAYER_NAME] = tempBackup
  QDKP2_Msg(QDKP2_COLOR_GREEN.."Backup complete. "..table.getn(tempBackup).." entries.")  
  QDKP2_RefreshBackupTime()
end

-- update the time/date of the last backup on the GUI
function QDKP2_RefreshBackupTime()
  local TimeString
  if QDKP2_Backup[QDKP2_PLAYER_NAME] then
    TimeString = "Last backup: "..QDKP2_BackupDate[QDKP2_PLAYER_NAME]
  else
    TimeString = "No backup found"
  end
  getglobal("QDKP2_frame1_BackupDate"):SetText(TimeString)
end

-- restores the backup in local
function QDKP2_Restore(DoNotAsk)

  if not QDKP2_Backup[QDKP2_PLAYER_NAME] then
    QDKP2_Msg("No backups found")
    return
  end
  if not DoNotAsk then
    local mess="Do you want to restore all\n data as in the last backup?"
    QDKP2_AskUserConf(mess,QDKP2_Restore,true)
  else
    local count = 0
    local get = 0
    local tempBackup = QDKP2_Backup[QDKP2_PLAYER_NAME]
    for i=1, table.getn(tempBackup) do
      local name = tempBackup[i][1]
      local datafield = tempBackup[i][2]
      if QDKP2_IsInGuild(name) then
        if QDKP2_IsInGuild(QDKP2_LookForAlt(datafield)) then
          QDKP2_AltsRestore[name]=QDKP2_FormatName(datafield)
        else
          local net, total, spent, hours = QDKP2_ParseNote(datafield)
          local DTotal = total  - QDKP2note[name][QDKP2_TOTAL]
          local DSpent = spent - QDKP2note[name][QDKP2_SPENT]
          local DHours = hours - QDKP2note[name][QDKP2_HOURS]
          QDKP2note[name] = {total, spent, hours}
          QDKP2session[name] = {0,0,0}
          get = get + 1
          QDKP2_StopCheck()
	  
          if DTotal==0 then DTotal = nil; end
          if DSpent==0 then DSpent = nil; end
          if DHours==0 then DHours = nil; end
          if DTotal or DSpent or DHours then
            QDKP2log_Entry(name,"backup restoring",QDKP2LOG_MODIFY,nil,{DTotal,DSpent,DHours})
          end
        end
      end
      count = count + 1
    end
    QDKP2_Msg(QDKP2_COLOR_GREEN.."Restored "..get.." entries. Send changes to upload them in officer notes.")
    QDKP2_RefreshGuild()
    QDKP2_Refresh_Roster("refresh")
    QDKP2_Refresh_Log("refresh")
  end
end

-----------------------------------------------SESSIONS MANAGEMENT-------------------------------------
--Returns the name of the ongoing session managed by the player, if present. Returns nil otherwise.
--Needs to be radically changed for V2.6
function QDKP2_OngoingSession()
 if QDKP2_TimerBase and QDKP2_OfficerMode() then return "Current Session"; end
 QDKP2_Debug(2, "Core", "OngoingSession returns nil")
end

-------------------------------------------------UTILITY--------------------------------

--formats the name properly.  ie airiena would become Airiena
function QDKP2_FormatName(name)
  local first = string.sub(name, 1,1)
  local remainder = string.sub(name, 2)
  local output = strupper(first)..strlower(remainder)
  return output
end

--Returns the first word with the right format to check for alts.
function QDKP2_LookForAlt(str)
   local first = string.sub(str, 1,1)
   local fin = string.find(str, " ") or (string.len(str) + 1)
   local remainder = string.sub(str, 2, fin - 1)
   local output = strupper(first)..strlower(remainder)
   
   if (QDKP2_AutoLinkAlts == false) then 
      return "---"  -- will not ever match a guild member name, so won't be linked
   else
      return output
   end
   
   return output
end

--Get the formatted of the player ("name" if not alt, "name (main)" if alt)
function QDKP2_GetName(name)
  if QDKP2_Alts[name] then return name.." ("..QDKP2_Alts[name]..")"
  else return name
  end
end

--get the DKP values. Used to link the alts to the main:

function QDKP2_GetTotal(name, doNotReset)
  name=QDKP2_GetMain(name)
  if not QDKP2note[name] then
    QDKP2_Msg(QDKP2_COLOR_RED..name.."doesn't seems to be in guild. Try to refresh the roster and try again")
    GuildRoster()
    return 0
  end
  local Total=QDKP2note[name][QDKP2_TOTAL]
  if not Total then 
        QDKP2_Debug(1, "GetValues","Error while getting Total amount for "..name..". Doesn't have a valid data array,")
	if doNotReset then Total=0
	else 
	  QDKP2_ResetPlayer(name)
	  Total=QDKP2_GetTotal(name,true)
	end
  end
  return Total
end

function QDKP2_GetSpent(name, doNotReset)
  name=QDKP2_GetMain(name)
  if not QDKP2note[name] then
    QDKP2_Msg(QDKP2_COLOR_RED..name.."doesn't seems to be in guild. Try to refresh the roster and try again")
    GuildRoster()
    return 0
  end
  local Spent=QDKP2note[name][QDKP2_SPENT]
  if not Spent then 
        QDKP2_Debug(1, "GetValues","Error while getting Spent amount for "..name..". Doesn't have a valid data array,")
	if doNotReset then Spent=0
	else 
	  QDKP2_ResetPlayer(name)
	  Spent=QDKP2_GetSpent(name,true)
	end
  end
  return Spent
end

function QDKP2_GetNet(name)
  return QDKP2_GetTotal(name)-QDKP2_GetSpent(name)
end

function QDKP2_GetHours(name, doNotReset)
  name=QDKP2_GetMain(name)
  if not QDKP2note[name] then
    QDKP2_Msg(QDKP2_COLOR_RED..name.."doesn't seems to be in guild. Try to refresh the roster and try again")
    GuildRoster()
    return 0
  end
  local Hours=QDKP2note[name][QDKP2_HOURS]
  if not Hours then 
        QDKP2_Debug(1, "GetValues","Error while getting Hours amount for "..name..". Doesn't have a valid data array,")
	if doNotReset then Hours=0
	else 
	  QDKP2_ResetPlayer(name)
	  Hours=QDKP2_GetHours(name,true)
	end
  end
  return Hours
end

function QDKP2_GetRaidGain(name,doNotReset)
  name=QDKP2_GetMain(name)
  if not QDKP2session[name] then
    QDKP2_Msg(QDKP2_COLOR_RED..name.."doesn't seems to be in guild. Try to refresh the roster and try again")
    GuildRoster()
    return 0
  end
  local RaidGain = QDKP2session[name][QDKP2_TOTAL]
  if not RaidGain then 
	QDKP2_Debug(1, "GetValues","Error while getting Raid Gain amount for "..name..". Doesn't have a valid data array,")
	if doNotReset then RaidGain=0
	else 
	  QDKP2_ResetPlayer(name)
	  RaidGain=QDKP2_GetRaidGain(name,true)
	end
  end
  return RaidGain
end

function QDKP2_GetRaidSpent(name,doNotReset)
  name=QDKP2_GetMain(name)
  if not QDKP2session[name] then
    QDKP2_Msg(QDKP2_COLOR_RED..name.."doesn't seems to be in guild. Try to refresh the roster and try again")
    GuildRoster()
    return 0
  end
  local RaidSpent = QDKP2session[name][QDKP2_SPENT]
  if not RaidSpent then 
	QDKP2_Debug(1, "GetValues","Error while getting Raid Spent amount for "..name..". Doesn't have a valid data array,")
	if doNotReset then RaidSpent=0
	else 
	  QDKP2_ResetPlayer(name)
	  RaidSpent=QDKP2_GetRaidSpent(name,true)
	end
  end
  return RaidSpent
end

function QDKP2_GetRaidTime(name,doNotReset)
  name=QDKP2_GetMain(name)
  if not QDKP2session[name] then
    QDKP2_Msg(QDKP2_COLOR_RED..name.."doesn't seems to be in guild. Try to refresh the roster and try again")
    GuildRoster()
    return 0
  end
  local RaidTime = QDKP2session[name][QDKP2_HOURS]
  if not RaidTime then 
	QDKP2_Debug(1, "GetValues","Error while getting Raid Time amount for "..name..". Doesn't have a valid data array,")
	if doNotReset then RaidTime=0
	else 
	  QDKP2_ResetPlayer(name)
	  RaidTime=QDKP2_GetRaidTime(name,true)
	end
  end
  return RaidTime
end

--retrun true if there is an uploaded change in the player log
function QDKP2_IsModified(name)
  if not QDKP2_IsInGuild(name) then
    return
  elseif QDKP2_Alts[name] then
    name = QDKP2_Alts[name]
  end
  if QDKP2note[name][QDKP2_TOTAL] ~= QDKP2stored[name][QDKP2_TOTAL] or QDKP2note[name][QDKP2_SPENT] ~= QDKP2stored[name][QDKP2_SPENT] or math.abs(QDKP2note[name][QDKP2_HOURS] - QDKP2stored[name][QDKP2_HOURS]) > 0.09 then
    return true
  else
    return false
  end
end


function QDKP2_CleanSession()  -- returns true if i haven't modified the session.
  for i=1, table.getn(QDKP2name) do
    local name = QDKP2name[i]
    if QDKP2_GetRaidGained(name) ~= 0 or QDKP2_GetRaidSpent(name) ~= 0 or QDKP2_GetRaidHours(name) ~= 0 then
      return false
    end
  end
  return true
end

function QDKP2_IsInRaid(namePlayer) --returns true if the player is in the raid
  for i=1, QDKP2_GetNumRaidMembers() do
    local name, rank, subgroup, level, class, fileName, zone, online = QDKP2_GetRaidRosterInfo(i);
    if name==namePlayer then 
      return true
    end
  end
end

function QDKP2_IsInGuild(name) --returns true if the player is in Guild
  if QDKP2rank[name] then
    return true
  else
    return false
  end
end

function QDKP2_IsRaidPresent()
  if QDKP2_GetNumRaidMembers() > 0 then return true
  else return false
  end
end


--returns true if name is eligable for dkp
function QDKP2_minRank(name)
  local rank = QDKP2rank[name]
  for i=1, table.getn(QDKP2_UNDKPABLE_RANK) do      --checks the rank
    if(rank==QDKP2_UNDKPABLE_RANK[i]) then
      return false
    end
  end
  return true
end

--returns a table for random indexing
function QDKP2_RandTable(n,timestamp)
  if timestamp then math.randomseed(timestamp)
  else math.randomseed(GetTime())
  end
  local output={}
  for i=1,n do
    local position=math.ceil(i*math.random())
    table.insert(output,position,i)
  end
  return output
end

--------------------------------

function QDKP2_ParseNote(incParse)
  local nettemp=0
  local spenttemp=0
  local totaltemp=0
  local hourstemp=0


  nettemp = QDKP2_ExtractNum(incParse, {"Net", "DKP", "N"})     -- Net is any number following n=, net=
  totaltemp = QDKP2_ExtractNum(incParse, {"Total","Tot","T","G"}) -- Total is any number following g=, t=, tot=, total=
  spenttemp = QDKP2_ExtractNum(incParse, {"Spent", "Spt","S"})   -- Spent is any number following s=,spt=,spent=
  hourstemp = QDKP2_ExtractNum(incParse, {"Hours","Hrs","H"})   -- Hours is any number following hours=, hrs=, h=

  --this is to fix output format with only NET field (DKP:xx)
  if spenttemp==0 and totaltemp==0 and nettemp~=0 then
    totaltemp=nettemp
  end
  
  -- fixup if we don't have spent recorded. (which is the default)  
  -- note that this means these numbers can be out of sync, so to speak, if 4 fields are saved
  if (spenttemp == 0 and (nettemp ~= totaltemp)) then
     spenttemp = totaltemp - nettemp
  end

  -- this is to fix if we don't have total field
  if (totaltemp == 0 and (nettemp ~= 0-spenttemp)) then
     totaltemp =nettemp + spenttemp
  end  
  
  return nettemp, totaltemp, spenttemp, hourstemp
end


--
-- Given string str, find and return the first number in str following the key.
-- returns 0 on not found.
--
function QDKP2_ExtractNum(str, keys)
  
  local i1, i2, tmpstr, value, key
  value = 0

  for j=1, table.getn(keys) do
    key=keys[j]
  -- find key voice
    i1, i2 = string.find(str, key..QDKP2_NOTE_DASH.."[^%d]*")
    if i1 and i2 then
      i1, i2 = string.find(str, "[%d.]*", i2+1)        -- find digits
      if (i1 == nil or i2 == nil or i2 < i1) then break; end   --control #1
      tmpstr = string.sub(str, i1, i2)
      value = tonumber(tmpstr)
      if not value then value=0; end   --control #2
      if (i1 > 1) then
        if (string.sub(str, i1-1, i1-1) == "-") then value = 0 - value; end    -- check for negatives
      end
      break
    end
  end
  return value
end

--
-- Takes a note of the form
-- {dkpinfo}text
-- and returns 2 strings: dkpinfo and text. (in that order)
-- If there appears to be no dkp info, it returns the original note for both fields
--
function QDKP2_ExtractDkpFromNote(note)
  local indexStart, indexEnd
  local retStr1, retStr2

  -- simple argument check
  if (note == nil)then
    return nil, nil
  end

  -- find braced text.  
  indexStart, indexEnd = string.find(note, "{.*}") 

  if (indexStart~=nil and indexEnd~=nil) then
    retStr1 = string.sub(note, indexStart+1, indexEnd-1)
    retStr2 = string.gsub(note, "{.*}", "")
  else
    retStr1 = note
    retStr2 = note
  end

  return retStr1, retStr2
end

--
-- Takes a note of the form
-- {dkpinfo}text
-- and replaces dkpinfo with newDkpInfo
--
-- Note: Truncates text if the resultant string is too long
--
function QDKP2_GenDkpNote(noteText, dkpText, maxLen)
  local maxNoteLen
  local truncNoteText
  local truncDkpText
  local newNote

  if (noteText==nil or dkpText==nil or maxLen==nil) then
    return noteText
  end

  -- Make sure we don't have a {} in the note/dkp text. Just cleans stuff up
  truncNoteText = string.gsub(noteText, "{.*}", "")
  truncNoteText = string.gsub(truncNoteText, "{", "")
  truncNoteText = string.gsub(truncNoteText, "}", "")
  truncDkpText = string.gsub(dkpText, "{", "")
  truncDkpText = string.gsub(truncDkpText, "}", "")

  newNote = "{"..truncDkpText.."}"
  maxNoteLen = maxLen - string.len(newNote)

  if (maxNoteLen < 0) then
    return noteText
  end

  -- Truncate note as necessary.
  truncNoteText = string.sub(truncNoteText, 1, maxNoteLen)

  newNote = newNote..truncNoteText

  return newNote
end

--------------------------------
-- Guild functions for QDKP - External's functions

function QDKP2_GetNumGuildMembers()
  local total=0
  local QDKP2ext_list=ListFromDict(QDKP2externals)
  total=total + GetNumGuildMembers(true)
  total=total + table.getn(QDKP2ext_list)
  return total
end

function QDKP2_GetGuildRosterInfo(i)
  local name,rank,rankIndex,level,class,zone,note,officernote,datafield,online,status,isinguild
  local GuildSize=GetNumGuildMembers(true)
  local QDKP2ext_list=ListFromDict(QDKP2externals)
  if i<=GuildSize then
    name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i)
    isinguild=true
  elseif i-GuildSize<=table.getn(QDKP2ext_list) then
    name=QDKP2ext_list[i-GuildSize]
    rank="*External*"
    rankIndex=255
    level=255
    class=QDKP2externals[name].class
    zone=""
    note=QDKP2externals[name].datafield
    officernote=QDKP2externals[name].datafield
    online=true
    status=""
    isinguild=false
  end
  if QDKP2_OfficerOrPublic==2 then
    datafield = QDKP2_ExtractDkpFromNote(note)
  else
    datafield = QDKP2_ExtractDkpFromNote(officernote)
  end
  return name,rank,rankIndex,level,class,zone,note,officernote,datafield,online,status,isinguild
end

function QDKP2_GuildRosterSetDatafield(i, data)
  local GuildSize=GetNumGuildMembers(true)
  local QDKP2ext_list=ListFromDict(QDKP2externals)
  if i<=GuildSize then
    local name,rank,rankIndex,level,class,zone,note,officernote,online,status,isinguild
    local dkpnote
    name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i)
    if QDKP2_OfficerOrPublic==2 then
      dkpnote = QDKP2_GenDkpNote(note, data, 31)
      GuildRosterSetPublicNote(i, dkpnote)
    else
      dkpnote = QDKP2_GenDkpNote(officernote, data, 31)
      GuildRosterSetOfficerNote(i, dkpnote)
    end
  elseif i-GuildSize<=table.getn(QDKP2ext_list) then
    name=QDKP2ext_list[i-GuildSize]
    QDKP2externals[name].datafield=data
  end
end

function QDKP2_NewExternal(name,data)
  QDKP2externals[name]={}
  if text then
    QDKP2externals[name].datafield=data
  else
    QDKP2externals[name].datafield=""
  end
  QDKP2externals[name].class="--"
end

function QDKP2_DelExternal(name)
  if not QDKP2externals[name] then
    QDKP2_Msg(QDKP2_COLOR_RED..name.." isn't an external.")
    return
  end
  QDKP2externals[name]=nil
  QDKP2_Msg(name.." has been removed from Guild Roster as External.")
end

function QDKP2_IsExternal(name)
  if QDKP2externals[name] then return true;
  else return false
  end
end
  
-- Raid Functions for QDKP


function QDKP2_GetRaidRosterInfo(i)
 local name, rank, subgroup, level, class, fileName, zone, online
 local RaidSize=GetNumRaidMembers()
 if not (i > RaidSize) then
   name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i)
   if QDKP2_IsExternal(name) then QDKP2externals[name].class=class; end
 elseif not (i- RaidSize > table.getn(QDKP2standby)) then
   name=QDKP2standby[i-RaidSize]
   for j=1,QDKP2_GetNumGuildMembers() do
     local nameGuild,rankGuild,rankIndexGuild,levelGuild,classGuild,zoneGuild,noteGuild,officernoteGuild,datafieldGuild,onlineGuild,statusGuild,isinguildGuild=QDKP2_GetGuildRosterInfo(j)
     if name==nameGuild then 
       level=levelGuild
       class=classGuild
       online=onlineGuild
       zone="Standby"
       break
     end
   end
 end
 return name, rank, subgroup, level, class, fileName, zone, online
end

function QDKP2_GetNumRaidMembers()
 local total=0
 total=total + GetNumRaidMembers()
 total=total + table.getn(QDKP2standby)
 return total
end

function QDKP2_AddRaid(name)
  table.insert(QDKP2standby,name)
  QDKP2_UpdateRaid() 
end

function QDKP2_RemRaid(name)
  local Index=QDKP2_IsStandby(name)
  if Index then
    table.remove(QDKP2standby,Index)
    QDKP2_UpdateRaid() 
  end
end
  
function QDKP2_IsStandby(name)
  for i=1,table.getn(QDKP2standby) do
    if QDKP2standby[i]==name then
      return i
    end
  end
end
  
--prints to the Guild Channel a list of Externals' DKP amounts.  
  
function QDKP2_PostExternals(channel,subChannel)
  local lines={}
  local QDKP2ext_list=ListFromDict(QDKP2externals)
  if table.getn(QDKP2ext_list)==0 then return;end
  table.insert(lines, QDKP2_LOC_ExtPost)
  for i=1, table.getn(QDKP2ext_list) do
    local Name=QDKP2ext_list[i]
    if not QDKP2_Alts[Name] then
      local Net=QDKP2_GetNet(Name)
      local Spent=QDKP2_GetSpent(Name)
      local Total=QDKP2_GetTotal(Name)
      local Hours=QDKP2_GetHours(Name)
      local msg=QDKP2_LOC_ExtLine
      msg=string.gsub(msg,"$NAME", Name)
      msg=string.gsub(msg,"$NET", Net)
      msg=string.gsub(msg,"$SPENT", Spent)
      msg=string.gsub(msg,"$TOTAL", Total)
      msg=string.gsub(msg,"$HOURS", Hours)
      table.insert(lines, msg)
    end
  end
  for i=1, table.getn(lines) do
    ChatThrottleLib:SendChatMessage("ALERT","QDKP2",lines[i],channel,nil,subChannel)
  end
end


------------------------------- Alts Functions -------------------------

--returns the main of a character. if he's not an alt, then returns the name as it is.
function QDKP2_GetMain(name) 
    return QDKP2_Alts[name] or name
end

--returns the name of the main if is a alt, nil otherwise.
function QDKP2_IsAlt(name)
  return QDKP2_Alts[name]
end

------------------------------
function QDKP2_Debug(level,system,text)
	level=level or 1
	if level>QDKP2_DEBUG then return; end
	system=system or "General"
	text=text or "nil"
	DEFAULT_CHAT_FRAME:AddMessage(QDKP2_COLOR_YELLOW.."<QDKP2-DBG> "..system..": "..QDKP2_COLOR_WHITE..tostring(text)..QDKP2_COLOR_CLOSE);
end

--------------------------------

--appends spaces to the end to help formating in lists
function QDKP2_AppendSpace(text, number)
  local temp = ""
  for i=0, number do
    temp = temp.." "  --adds x number of spaces
  end
  text = text..temp   --adds spaces to text
  return text 
end

--return a copy of the listst
function QDKP2_CopyTable(list)
  local output = {}
  for i = 1, table.getn(list) do
    local item = list[i]
    table.insert(output, item)
  end
  return output
end

-- Invert a list
function QDKP2_Invert(list)
  local output = {}
  for i=table.getn(list), 1, -1 do
    table.insert(output,list[i])
  end
  return output
end

-----------------------

function QDKP2_ItemInfo(link)
  --local _, _, id = string.find(link, "item:(%d+):");
  local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, invTexture = GetItemInfo(link);
  local info = {};

  info.name = itemName;
  info.link = itemLink;
  info.rarity = itemRarity;

  return info;
end

--------------------------------
function QDKP2_OfficerMode()
 -- if true then return true; end
    if QDKP2_OfficerOrPublic==2 then
      return CanEditPublicNote()
    else
      return CanEditOfficerNote()
    end
end
 -------------------------------- List services

--returns a list with all the key of the dictionary passed.
function ListFromDict(dict)
  ListFromDict_output = {}
  table.foreach(dict,ListFromDict_add)
  return ListFromDict_output 
end

function ListFromDict_add(key,value)
  table.insert(ListFromDict_output , key)
end

--returns a dictionary from a list. all index 
function DictFromList(list,content)
  local output = {}
  for i=1,table.getn(  list ) do
    output[list[i]] = content
  end
  return output
end
--------------------------------

function RoundNum(number)
  local CeilValue = math.ceil(number)
  local FloorValue = math.floor(number)
  if abs(number - CeilValue) < abs(number - FloorValue) then
    return CeilValue
  else
    return FloorValue
  end
end

--I took this from RBDKP (a similar DKP mod) with no modification.  Why change something perfect.
function QDKP2_GetArgs(message, separator)
  local args = {};
  local i = 0;

  for value in string.gmatch(message, "[^"..separator.."]+") do
    i = i + 1;
    args[i] = value;
  end

  return args;
end

---------------------------------------------OUTPUT UTILITY--------------------------

--puts the data back into a note
function QDKP2_MakeNote(incNet, incTotal, incSpent, incHours)

  incNet=RoundNum(incNet)
  incTotal=RoundNum(incTotal)
  incSpent=RoundNum(incSpent)
  incHours=RoundNum(incHours*10)/10

  if(QDKP2_outputstyle==1)then       --Net:xx Tot:xx Hrs:xx
    return "Net"..QDKP2_NOTE_DASH..incNet..QDKP2_NOTE_BREAK.."Tot"..QDKP2_NOTE_DASH..incTotal..QDKP2_NOTE_BREAK.."Hrs"..QDKP2_NOTE_DASH..incHours
  elseif(QDKP2_outputstyle==2) then  --Net:xx Tot:xx Spent:xx
    return "Net"..QDKP2_NOTE_DASH..incNet..QDKP2_NOTE_BREAK.."Tot"..QDKP2_NOTE_DASH..incTotal..QDKP2_NOTE_BREAK.."Spent"..QDKP2_NOTE_DASH..incSpent
  elseif(QDKP2_outputstyle==3)then    --Net:xx Spent:xx
    return "Net"..QDKP2_NOTE_DASH..incNet..QDKP2_NOTE_BREAK.."Spent"..QDKP2_NOTE_DASH..incSpent
  elseif(QDKP2_outputstyle==4)then    --Net:xx T:xx S:xx
    return "Net"..QDKP2_NOTE_DASH..incNet..QDKP2_NOTE_BREAK.."T"..QDKP2_NOTE_DASH..incTotal..QDKP2_NOTE_BREAK.."S"..QDKP2_NOTE_DASH..incSpent
  elseif(QDKP2_outputstyle==5)then    --Net:xx T:xx H:xx
    return "Net"..QDKP2_NOTE_DASH..incNet..QDKP2_NOTE_BREAK.."T"..QDKP2_NOTE_DASH..incTotal..QDKP2_NOTE_BREAK.."H"..QDKP2_NOTE_DASH..incHours
  elseif(QDKP2_outputstyle==6)then    --N:xx T:xx S:xx H:xx
    return "N"..QDKP2_NOTE_DASH..incNet..QDKP2_NOTE_BREAK.."T"..QDKP2_NOTE_DASH..incTotal..QDKP2_NOTE_BREAK.."S"..QDKP2_NOTE_DASH..incSpent..QDKP2_NOTE_BREAK.."H"..QDKP2_NOTE_DASH..incHours
  elseif(QDKP2_outputstyle==7) then  --N:xx T:xx
    return "N"..QDKP2_NOTE_DASH..incNet..QDKP2_NOTE_BREAK.." T"..QDKP2_NOTE_DASH..incTotal
  end
end



--makes a pretty display only the user can see
function QDKP2_Msg(msg)
  DEFAULT_CHAT_FRAME:AddMessage(QDKP2_COLOR_YELLOW.."<QDKP2> "..QDKP2_COLOR_WHITE..tostring(msg)..QDKP2_COLOR_CLOSE);
end

---------------------------------


-- returns true if you have unuploaded changes, nil otherwise.
function QDKP2_UnuploadedChanges()
  for i=1, table.getn(QDKP2name) do
    if QDKP2_IsModified(QDKP2name[i]) then
      return true
    end
  end
end

-- this is used to refresh the guild cache update timeout
function QDKP2_TimeToRefresh()
  if GetNumGuildMembers(true)>0 then GuildRoster(); end
end

---------------------------------

function QDKP2_SetLetters()
  QDKP2letters["a"]=1
  QDKP2letters["b"]=2
  QDKP2letters["c"]=3
  QDKP2letters["d"]=4
  QDKP2letters["e"]=5
  QDKP2letters["f"]=6
  QDKP2letters["g"]=7
  QDKP2letters["h"]=8
  QDKP2letters["i"]=9
  QDKP2letters["j"]=10
  QDKP2letters["k"]=11
  QDKP2letters["l"]=12
  QDKP2letters["m"]=13
  QDKP2letters["n"]=14
  QDKP2letters["o"]=15
  QDKP2letters["p"]=16
  QDKP2letters["q"]=17
  QDKP2letters["r"]=18
  QDKP2letters["s"]=19
  QDKP2letters["t"]=20
  QDKP2letters["u"]=21
  QDKP2letters["v"]=22
  QDKP2letters["w"]=23
  QDKP2letters["x"]=24
  QDKP2letters["y"]=25
  QDKP2letters["z"]=26
end

--------------------------------------------SORTING ALGORITHMS--------------------------


-- Perform all sorting at once. Values the sorting by category- highest power of 2 is most important.
-- When a new sorting category is used (say, rank), it will be incresed to max (8) and the others will be
-- adjusted downwards accordingly
QDKP2_Sort_Lastn = 0
QDKP2_Sort_Alpha = 64
QDKP2_Sort_Rank  = 32
QDKP2_Sort_Class = 16
QDKP2_Sort_EP = 4
QDKP2_Sort_GP = 2
QDKP2_Sort_Priority = 8
QDKP2_Sort_Hours = 1

-- Incoming val1, val2 are names.
function QDKP2_Sort_Comparitor(val1, val2)
   local compare = 0;
   local test1, test2, increment

   -- Alpha
   test1 = val1
   test2 = val2
   increment = QDKP2_Sort_Alpha
   if (test1 < test2) then compare = compare - increment; elseif (test1 > test2) then compare = compare + increment; end

   -- Rank
   test1 = QDKP2rankIndex[val1]
   test2 = QDKP2rankIndex[val2]
   increment = QDKP2_Sort_Rank
   if (test1 < test2) then compare = compare - increment; elseif (test1 > test2) then compare = compare + increment; end

   -- Class
   test1 = QDKP2class[val1]
   test2 = QDKP2class[val2]
   increment = QDKP2_Sort_Class
   if (test1 < test2) then compare = compare - increment; elseif (test1 > test2) then compare = compare + increment; end

   -- EP (Note the reversal so higher net comes first)  ------- / Total in orig mod
   test2 = QDKP2_GetTotal(val1)
   test1 = QDKP2_GetTotal(val2)
   increment = QDKP2_Sort_EP
   if (test1 < test2) then compare = compare - increment; elseif (test1 > test2) then compare = compare + increment; end

   -- GP (Note the reversal so higher net comes first)  ------- / Spent in orig mod
   test2 = QDKP2_GetSpent(val1)
   test1 = QDKP2_GetSpent(val2)
   increment = QDKP2_Sort_GP
   if (test1 < test2) then compare = compare - increment; elseif (test1 > test2) then compare = compare + increment; end

   -- Priority (Note the reversal so higher net comes first)  
   test2 = QDKP2_GetPRRatio(val1)
   test1 = QDKP2_GetPRRatio(val2)
   increment = QDKP2_Sort_Priority
   if (test1 < test2) then compare = compare - increment; elseif (test1 > test2) then compare = compare + increment; end

   -- Net (Note the reversal so higher net comes first)
   --test2 = QDKP2_GetNet(val1)
   --test1 = QDKP2_GetNet(val2)
   --increment = QDKP2_Sort_Net
   --if (test1 < test2) then compare = compare - increment; elseif (test1 > test2) then compare = compare + increment; end

   if (compare < 0) then return true; end
   return false
end

---- ADDED TO GET PRIORITY RATIO
function QDKP2_GetPRRatio(name)
  name=QDKP2_GetMain(name)

  if not QDKP2note[name] then
    QDKP2_Msg(QDKP2_COLOR_RED..name.."doesn't seems to be in guild. Try to refresh the roster and try again")
    GuildRoster()
    return 0
  end

  local QDKP2ratio = 0
  
  if QDKP2_GetSpent(name) ~= 0 then
      QDKP2ratio = QDKP2_GetTotal(name) / QDKP2_GetSpent(name);
  else
      QDKP2ratio = QDKP2_GetTotal(name);
  end

  return QDKP2ratio
end

function QDKP2_SortList(List)
  local n
  local lastmax

  -- Quick check to see if we actually need to resort. (MUCH faster interface this way)
  n = table.getn(List)
  if (n == QDKP2_Sort_Lastn) then
     if (QDKP2_Order == "Alpha" and QDKP2_Sort_Alpha == 32)then return List; end
     if (QDKP2_Order == "Rank" and QDKP2_Sort_Rank == 32)then return List; end
     if (QDKP2_Order == "Class" and QDKP2_Sort_Class == 32)then return List; end
     if (QDKP2_Order == "Net" and QDKP2_Sort_Net == 32)then return List; end
     if (QDKP2_Order == "Hours" and QDKP2_Sort_Net == 32)then return List; end
     if (QDKP2_Order == "Priority" and QDKP2_Sort_Net == 32)then return List; end
  end

  -- Fixup valuation of ordering. (which is most important?)
  if (QDKP2_Order == "Alpha") then lastmax = QDKP2_Sort_Alpha; end
  if (QDKP2_Order == "Rank") then lastmax = QDKP2_Sort_Rank; end
  if (QDKP2_Order == "Class") then lastmax = QDKP2_Sort_Class; end
  if (QDKP2_Order == "EP") then lastmax = QDKP2_Sort_EP; end
  if (QDKP2_Order == "GP") then lastmax = QDKP2_Sort_GP; end
  if (QDKP2_Order == "Hours") then lastmax = QDKP2_Sort_Class; end
  if (QDKP2_Order == "Priority") then lastmax = QDKP2_Sort_Priority; end
  if (QDKP2_Sort_Alpha > lastmax) then QDKP2_Sort_Alpha = QDKP2_Sort_Alpha / 2; end
  if (QDKP2_Sort_Rank > lastmax) then QDKP2_Sort_Rank = QDKP2_Sort_Rank / 2; end
  if (QDKP2_Sort_Class > lastmax) then QDKP2_Sort_Class = QDKP2_Sort_Class / 2; end
  if (QDKP2_Sort_EP > lastmax) then QDKP2_Sort_EP = QDKP2_Sort_EP / 2; end
  if (QDKP2_Sort_GP > lastmax) then QDKP2_Sort_GP = QDKP2_Sort_GP / 2; end
  if (QDKP2_Sort_Hours > lastmax) then QDKP2_Sort_Hours = QDKP2_Sort_Hours / 2; end
  if (QDKP2_Sort_Priority > lastmax) then QDKP2_Sort_Priority = QDKP2_Sort_Priority / 2; end
  if (QDKP2_Order == "Alpha") then QDKP2_Sort_Alpha = 64; end
  if (QDKP2_Order == "Rank") then QDKP2_Sort_Rank = 64; end
  if (QDKP2_Order == "Class") then QDKP2_Sort_Class = 64; end
  if (QDKP2_Order == "EP") then QDKP2_Sort_EP = 64; end
  if (QDKP2_Order == "GP") then QDKP2_Sort_GP = 64; end
  if (QDKP2_Order == "Hours") then QDKP2_Sort_Class = 64; end
  if (QDKP2_Order == "Priority") then QDKP2_Sort_Priority = 64; end

  table.sort(List, QDKP2_Sort_Comparitor)

  return List
end
 