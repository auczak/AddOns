-- Copyright 2008 Riccardo Belloli (belloli@email.it)
-- This file is a part of QDKP_V2 (see about.txt in the Addon's root folder)

--      ## COMMAND LINE INTERPRETER ##


 -- Setup slash commands.
function QDKP2_SetSlashCommands()
  SLASH_QDKP21 = "/dkp"
  SLASH_QDKP22 = "/qdkp2"
  SLASH_QDKP23 = "/qdkp"
  SlashCmdList["QDKP2"] = function(msg)
  QDKP2_CL_ProcessCommand(msg);
  end
end


function QDKP2_CL_ProcessCommand(text)
  
  local Words=QDKP2_CL_WordParser(text) --get a list of the word of the command, lowcased
  
  local W1=Words[1]
  local W2=Words[2]
  local W3=Words[3]
  local W4=Words[4]
  local W5=Words[5]
  
  if (W1=="new" and W2=="session") or (W1=="newsession") then
    local i=string.find(string.lower(text),"session")
    local sessionName=string.sub(text,i+8)
    QDKP2_NewSession(sessionName)
    return
    
  elseif W1=="upload" or W1=="send" or W1=="sync" or W1=="syncronize" then
    QDKP2_UploadAll()
    return
    
  elseif W1=="timer" or W1=="tim" or W1=="t" then 
    if W2=="on" then 
      QDKP2_TimerOn()
      return
    elseif W2=="off" then
      QDKP2_TimerOff()
      return
    end
    
    
  elseif W1=="ironman" or W1=="im" or W1=="ironm" then
    if W2=="start" then
      QDKP2_IronManStart()
      return
    elseif W2=="stop" and tonumber(W3) then
      QDKP2_InronManFinish(tonumber(W3))
      return
    elseif W2=="wipe" then
      QDKP2_IronManWipe()
      return
    end
    
  elseif (W1=="autoboss" or W1=="boss") then
    if QDKP2_CL_IsLegalOnOfT(W2) then 
      QDKP2_AutoBossEarnSet(W2);
      return
    end
    
  elseif W1=="detectwin" or W1=="detectwinners" then
    if QDKP2_CL_IsLegalOnOfT(W2) then
      QDKP2_DetectBidSet(W2)
      return
    end
    
  elseif W1=="gui" then
    if not W2 or W2=="toggle" then
      QDKP2_ToggleOffAfter(1)
      return
    elseif W2=="show" or W2=="on" then 
      QDKP2_Toggle(1, true)
      return
    elseif W2=="hide" or W2=="off" then
      QDKP2_Toggle(1,false)
      return
    end
    
  elseif W1=="roster" then
    if not W2 or W2=="toggle" then
      QDKP2_Refresh_Roster("toggle")
      return
    elseif W2=="show" or W2=="on" then 
      QDKP2_Refresh_Roster("show")
      return
    elseif W2=="hide" or W2=="off" then
      QDKP2_Refresh_Roster("hide")
      return
    end
    
  elseif W1=="log" then
    if not W2 or W2=="toggle" then
      QDKP2_Refresh_Log("toggle")
      return
    elseif W2=="show" or W2=="on" then 
      QDKP2_Refresh_Log("show")
      return
    elseif W2=="hide" or W2=="off" then
      QDKP2_Refresh_Log("hide")
      return
    end
    
  elseif W1=="toolbox" or W1=="tb" then
    if not W2 or W2=="toggle" then
      QDKP2_ToggleOffAfter(3)
      return
    elseif W2=="show" or W2=="on" then 
      QDKP2_Toggle(3, true)
      return
    elseif W2=="hide" or W2=="off" then
      QDKP2_Toggle(3,false)
      return
    end
        
  elseif W1=="showlog" and W2 then
    W2=QDKP2_FormatName(W2)
    if W2=="Raid" then QDKP2_PopupLog("RAID")
    elseif QDKP2_IsInGuild(W2) then QDKP2_PopupLog(W2)
    else QDKP2_Msg(QDKP2_COLOR_RED.."No matching with that guildmember name.")
    end
    return
    
  elseif (W1=="showtoolbox" or W1=="showtb") and W2 then
    W2=QDKP2_FormatName(W2)
    if QDKP2_IsInGuild(W2) then QDKP2_PopupTB(W2);
    else QDKP2_Msg(QDKP2_COLOR_RED.."No matching with that guildmember name.")
    end
    return
    
  elseif W1=="raid" and (W2=="awards" or W2=="award") and W3 then
    local amount=tonumber(W3)
    if amount then
      if W4=="for" then
        local i=string.find(lower(text),"for")
        local reason=string.sub(text,i+4)
        QDKP2_GiveRaidDKP(amount,reason)
      else
        QDKP2_GiveRaidDKP(amount)
      end
    else QDKP2_Msg(QDKP2_COLOR_RED.."Requested a valid DKP amount.")
    end
    return
    
    
  elseif W1=="do" and (W3=="spend" or W3=="spends" or W3=="-") and W2 and W4 then
    local amount = tonumber(W4)
    if amount then
      W2=QDKP2_FormatName(W2)
      if QDKP2_IsInGuild(W2) then 
	local _,_,reason=string.find(text," for (.+)")
	QDKP2_PlayerSpends(W2,amount, reason)
        QDKP2_RefreshAll()
      else QDKP2_Msg(QDKP2_COLOR_RED.."No matching with that guildmember name.")
      end
    else QDKP2_Msg(QDKP2_COLOR_RED.."Invalid DKP amount.")
    end
    return
    
  elseif W1=="do" and (W3=="award" or W3=="awards" or W3=="+" or W3=="gain" or W3=="gains") and W2 and W4 then
    W2=QDKP2_FormatName(W2)
    local amount = tonumber(W4)
    if amount then
      W2=QDKP2_FormatName(W2)
      if QDKP2_IsInGuild(W2) then 
	local _,_,reason=string.find(text," for (.+)")
	QDKP2_PlayerGains(W2, amount, reason)
        QDKP2_RefreshAll()
      else QDKP2_Msg(QDKP2_COLOR_RED.."No matching with that guildmember name.")
      end
    else QDKP2_Msg(QDKP2_COLOR_RED.."Invalid DKP amount.")
    end
    return

 elseif W1=="do" and (W3=="zerosum" or W3=="zs") and W2 and W4 then
    W2=QDKP2_FormatName(W2)
    local amount = tonumber(W4)
    if amount then
      W2=QDKP2_FormatName(W2)
      if QDKP2_IsInGuild(W2) then 
	local _,_,reason=string.find(text," for (.+)")
	QDKP2_ZeroSum(W2, amount , reason)
        QDKP2_RefreshAll()
      else QDKP2_Msg(QDKP2_COLOR_RED.."No matching with that guildmember name.")
      end
    else QDKP2_Msg(QDKP2_COLOR_RED.."Invalid DKP amount.")
    end
    return


  elseif W1=="do" then
    QDKP2_Msg(QDKP2_COLOR_YELLOW..'Usage: "do <name> gain|spend|zerosum <amount> [for <reason>]"')
    return
    
  elseif W1=="set" and W2 and W3 and W4 then
    local amount = tonumber(W4)
    if amount then
      W2=QDKP2_FormatName(W2)
      if QDKP2_IsInGuild(W2) then 
        if W3=="total" then
          QDKP2_AddTotals(W2, amount - QDKP2_GetTotal(W2), nil, nil, "Command Line editing", nil, true, true)
          return
        elseif W3=="spent" then
          QDKP2_AddTotals(W2, nil,  amount - QDKP2_GetSpent(W2), nil, "Command Line editing", nil, true, true)
          return
        elseif W3=="hours" then
          QDKP2_AddTotals(W2, nil, nil,  amount - QDKP2_GetHours(W2), "Command Line editing", nil, true, true)
          return
        end
      else 
        QDKP2_Msg(QDKP2_COLOR_RED.."No matching with that guildmember name.")
        return
      end
    else 
      QDKP2_Msg(QDKP2_COLOR_RED.."Invalid amount.")
      return
    end
    
  elseif (W1=="decay" or W1=="guilddecay" or W1=="raiddecay") and W2 and tonumber(W2) then
    local NameList
    if W1=="raiddecay" then 
      if GetNumRaidMembers()>0 then
        NameList=QDKP2raid
      else
        QDKP2_Msg(QDKP2_COLOR_RED..QDKP2_LOC_NotIntoARaid)
        return
      end
    else 
      NameList=QDKP2name
    end
    for i=1,table.getn(NameList) do
      local name=NameList[i]

      if not QDKP2_IsAlt(name) then 
	QDKP_decay(name, tonumber(W2))
      end
    end
    if W1=="raiddecay" then QDKP2_Msg(QDKP2_COLOR_WHITE.."Raid members' DKP has been cutted down by "..W2.."%")
    else QDKP2_Msg(QDKP2_COLOR_WHITE.."Guild Members' DKP has been cutted down by "..W2.."%")
    end
    QDKP2_Refresh_Roster("refresh")
    QDKP2_Refresh_Log("refresh")
    return



  elseif W1=="getvalues" or W1=="getvalue" then
    W2=QDKP2_FormatName(W2)
    if QDKP2_IsInGuild(W2) then 
      QDKP2_Msg(W2.." values:")
      QDKP2_Msg("Net="..tostring(QDKP2_Net(W2)).." DKP")
      QDKP2_Msg("Total="..tostring(QDKP2_Total(W2)).." DKP")
      QDKP2_Msg("Spent="..tostring(QDKP2_Spent(W2)).." DKP")
      QDKP2_Msg("Time="..tostring(QDKP2_Hours(W2)).." Hours")
    else QDKP2_Msg(QDKP2_COLOR_RED.."No matching with that guildmember name.")
    end
    return
    
  elseif W1=="notify" then
    W2=QDKP2_FormatName(W2)
    if QDKP2_IsInGuild(W2) then QDKP2_Notify(W2)
    else QDKP2_Msg(QDKP2_COLOR_RED.."No matching with that guildmember name.")
    end
    return
    
  elseif W1=="notifyall" then
    QDKP2_NotifyAll()
    return
    
  elseif W1=="purgelog" and W2 then
    amount=tonumber(W3)
    if W2=="all" then
      QDKP2_LOG_PurgeWipe(true)
      QDKP2_Msg(QDKP2_COLOR_WHITE.."Log Wiped.")
      return
    elseif W2=="deleted" then
      QDKP2_LOG_PurgeDeleted(true)
      QDKP2_Msg(QDKP2_COLOR_WHITE.."Deleted log's entries purged.")
      return
    elseif W2=="sessions" and amount then
      QDKP2_LOG_PurgeSessions(amount,true)
      QDKP2_Msg(QDKP2_COLOR_WHITE.."Old sessions' purged.")
      return
    elseif W2=="days" and amount then
      QDKP2_LOG_PurgeDays(amount,true)
      QDKP2_Msg(QDKP2_COLOR_WHITE.."Old entries purged.")
      return
    end
    
  elseif W1=="charge" then
    if W2=="loot" then
      QDKP2_BIND_ChargeLastLoot()
      return
    elseif W2=="chat" then
      QDKP2_BIND_ChargeLastSeen()
      return
    end
    
  elseif W1=="report" and W2 and W3 and W4 then
    W2=QDKP2_FormatName(W2)
    local Target=W2
    if QDKP2_IsInGuild(W2) then Target=W2
    elseif W2=="Raid" then Target="RAID"
    else 
      QDKP2_Msg(QDKP2_COLOR_RED.."No matching with that guildmember name.")
      return
    end
    local index=1
    local Type=""
    if W3=="current" or W3=="last" then
      Type="Session"
    elseif W3=="previous" then
      Type="Session"
      index=QDKP2_CL_FindReportIndex(Target)
      if not index then
        QDKP2_Msg(QDKP2_COLOR_RED.."Just one session in "..Target.."'s log.")
        return 
      end
      index=index+1
    elseif W3=="all" then
      Type="All"
    else
      QDKP2_Msg(QDKP2_COLOR_RED.."Wrong Report Type")
      return
    end
    local channel
    if W4=="say" or W4=="s" then channel="SAY"
    elseif W4=="yell" or W4=="y" then channel="YELL"
    elseif W4=="guild" or W4=="g" then channel="GUILD"
    elseif W4=="raid" or W4=="r" then channel="RAID"
    elseif W4=="officer" or W4=="o" then channel="OFFICER"
    elseif W4=="channel" then channel="CHANNEL"
    elseif W4=="whisper" or W4=="w" then channel="WHISPER"
    else 
      QDKP2_Msg(QDKP2_COLOR_RED.."Wrong channel")
      return
    end
    
    if channel=="CHANNEL" and not W5 then
      QDKP2_Msg(QDKP2_COLOR_YELLOW.."You must include a channel name or number where you want to post the report into.")
      return
    end      
    if channel=="WHISPER" and not W5 then
      QDKP2_Msg(QDKP2_COLOR_YELLOW.."You must include a player name you want to send the report to.")
      return
    end      
    QDKP2_MakeAndSendReport(Target,Type,index,channel,W5) 
    return
    
  elseif W1=="resethours" then
    QDKP2_resetAllGuildHours()
    return
    
  elseif not W1 or W1=="" or W1=="help" then 
    QDKP2_CL_Help()
    return
    
  elseif W1=="makealt" then
    if not W2 or not W3 or W4 then 
      QDKP2_Msg(QDKP2_COLOR_YELLOW..'Usage: "makealt <altName> <mainName>"')
      return
    end
    
    W2=QDKP2_FormatName(W2)
    W3=QDKP2_FormatName(W3)
    
    if not QDKP2_IsInGuild(W2) then QDKP2_Msg(QDKP2_COLOR_RED..W2..': No matching with that guildmember name.')
    elseif not QDKP2_IsInGuild(W3) then QDKP2_Msg(QDKP2_COLOR_RED..W3..': No matching with that guildmember name.')
    elseif W2==W3 then QDKP2_Msg(QDKP2_COLOR_RED.."An alt's Main must be different from the alt himself.")
    elseif QDKP2_Alts[W3] then QDKP2_Msg(QDKP2_COLOR_RED.."You can't define an alt as a Main.")
    else
      QDKP2_AltsRestore[W2]=W3
      QDKP2_DownloadGuild(nil,false)
      QDKP2_Refresh_Toolbox("refresh")
      QDKP2_Refresh_Roster("refresh")
      QDKP2_Msg(QDKP2_COLOR_WHITE.."Upload Changes to store the modifications.")
    end
    return
  
  elseif W1=="clearalt" then
    if not W2 or W3 then
      QDKP2_Msg(QDKP2_COLOR_YELLOW..'Usage: "clearalt <altName>"')
      return
    end    
    W2=QDKP2_FormatName(W2)
    if not QDKP2_IsInGuild(W2) then QDKP2_Msg(QDKP2_COLOR_RED..'No matching with that guildmember name.')
    elseif not QDKP2_Alts[W2] then QDKP2_Msg(QDKP2_COLOR_RED.."That player is not an alt.")
    else
      QDKP2_AltsRestore[W2]=""
      local alts=ListFromDict(QDKP2_Alts)
      local newalts={}
      for i=1, table.getn(alts) do
        if not (W2==alts[i]) then  
	  newalts[alts[i]]=QDKP2_Alts[alts[i]]
        end
        QDKP2_Alts=newalts
      end
      QDKP2_DownloadGuild(nil,false)
      QDKP2_Refresh_Toolbox("refresh")
      QDKP2_Refresh_Roster("refresh")
      QDKP2_Msg(QDKP2_COLOR_WHITE.."Upload Changes to store the modifications.")
    end
    return
  
  elseif W1=="addexternal" then
    if not W2 or W3 then 
      QDKP2_Msg(QDKP2_COLOR_YELLOW..'Usage: "addexternal <name>"')
      return
    end
    W2=QDKP2_FormatName(W2)
    if QDKP2_IsInGuild(W2) then QDKP2_Msg(QDKP2_COLOR_RED..'The given player is already in the guild')
    else
      QDKP2_NewExternal(W2)
      QDKP2_DownloadGuild(nil,false)  
      QDKP2_UpdateRaid() 
      QDKP2_Refresh_Roster("refresh")
    end    
    return
    
  elseif W1=="remexternal" then
    if not W2 or W3 then
      QDKP2_Msg(QDKP2_COLOR_YELLOW..'Usage: "remexternal <name>"')
      return
    end
    W2=QDKP2_FormatName(W2)
    if not QDKP2externals[W2] then QDKP2_Msg(QDKP2_COLOR_RED..'The given player is not an external.')
    else
      QDKP2_DelExternal(W2)
      QDKP2_DownloadGuild(nil,false)
      QDKP2_UpdateRaid() 
      QDKP2_Refresh_Roster("refresh")
    end
    return
    
  elseif W1=="addraid" then
    if not W2 or W3 then
      QDKP2_Msg(QDKP2_COLOR_YELLOW..'Usage: "addraid <name>"')
      return
    end
    W2=QDKP2_FormatName(W2)
    if not QDKP2_IsInGuild(W2) then QDKP2_Msg(QDKP2_COLOR_RED..'The given player is not in the Guild')
    elseif QDKP2_IsInRaid(W2) then QDKP2_Msg(QDKP2_COLOR_RED..'The given player is already in the Raid')
    else
      QDKP2_AddRaid(W2)
      QDKP2_Refresh_Roster("refresh")
      QDKP2_Msg(W2.." added to the raid")
    end
    return

  elseif W1=="remraid" then
    if not W2 or W3 then
      QDKP2_Msg(QDKP2_COLOR_YELLOW..'Usage: "remraid <name>"')
      return
    end
    W2=QDKP2_FormatName(W2)
    QDKP2_RemRaid(W2)
    QDKP2_Refresh_Roster("refresh")    
    return
  
  elseif W1=="classdkp" then
  if not W2 or not W3 then
    QDKP2_Msg(QDKP2_COLOR_YELLOW..'Usage: "classdkp <class> say|yell|guild|officer|channel|whisper [whispername|channelnumber]"')
    return
  end
    local class
    if W2=="druid" then
      class="Druid"
    elseif W2=="hunter" then
      class="Hunter"
    elseif W2=="mage" then
      class="Mage"
    elseif W2=="paladin" then
      class="Paladin"
    elseif W2=="priest" then
      class="Priest"
    elseif W2=="rogue" then
      class="Rogue"
    elseif W2=="shaman" then
      class="Shaman" 
    elseif W2=="warlock" then
      class="Warlock"
    elseif W2=="warrior" then
      class="Warrior"
    else
      QDKP2_Msg(QDKP2_COLOR_RED..'You have to specify a valid class name.')
      return
    end
    local output={"QDKP2 - Top Score of "..class.."'s net DKP"}
    local list={}
    for i = 1,table.getn(QDKP2name) do
      local name=QDKP2name[i]
      local classAct=QDKP2class[name]
      if classAct==class then
        table.insert(list,name)
      end
    end
    if table.getn(list)==0 then 
      QDKP2_Msg(QDKP2_COLOR_RED..'No Guild Members for the given class')
      return
    end
    list=QDKP2_netSort(list)
    for i=1,table.getn(list) do
      if i > 10 then break; end
      local name=list[i]
      local DKP=QDKP2_GetNet(name)
      table.insert(output,QDKP2_GetName(name).." - "..tostring(DKP).." DKP")
    end
    local channel
    if W3=="say" or W3=="s" then channel="SAY"
    elseif W3=="yell" or W3=="y" then channel="YELL"
    elseif W3=="guild" or W3=="g" then channel="GUILD"
    elseif W3=="officer" or W3=="o" then channel="OFFICER"
    elseif W3=="channel" then channel="CHANNEL"
    elseif W4=="raid" or W4=="r" then channel="RAID"
    elseif W3=="whisper" or W3=="w" then channel="WHISPER"
    else 
      QDKP2_Msg(QDKP2_COLOR_RED.."Wrong channel")
      return
    end
    if channel=="CHANNEL" and not W4 then
      QDKP2_Msg(QDKP2_COLOR_YELLOW.."You must include a channel name or number where you want to post the report into.")
      return
    end      
    if channel=="WHISPER" and not W4 then
      QDKP2_Msg(QDKP2_COLOR_YELLOW.."You must include a player name you want to send the report to.")
      return
    end      
    QDKP2_SendList(output,channel,W4)
    return
    
  elseif W1=="rankdkp" then
  if not W2 or not W3 then
    QDKP2_Msg(QDKP2_COLOR_YELLOW..'Usage: "classdkp <class> say|yell|guild|officer|channel|whisper [whispername|channelnumber]"')
    return
  end
    local output={"QDKP2 - Top Score of "..W2.."'s net DKP"}
    local list={}
    for i = 1,table.getn(QDKP2name) do
      local name=QDKP2name[i]
      local rankAct=string.lower(QDKP2rank[name])
      if rankAct==W2 then
        table.insert(list,name)
      end
    end
    if table.getn(list)==0 then 
      QDKP2_Msg(QDKP2_COLOR_RED.."No Guild Members for the given rank")
      return
    end
    list=QDKP2_netSort(list)
    for i=1,table.getn(list) do
      if i > 10 then break; end
      local name=list[i]
      local DKP=QDKP2_GetNet(name)
      table.insert(output,QDKP2_GetName(name).." - "..tostring(DKP).." DKP")
    end
    local channel
    if W3=="say" or W3=="s" then channel="SAY"
    elseif W3=="yell" or W3=="y" then channel="YELL"
    elseif W3=="guild" or W3=="g" then channel="GUILD"
    elseif W3=="officer" or W3=="o" then channel="OFFICER"
    elseif W3=="channel" then channel="CHANNEL"
    elseif W4=="raid" or W4=="r" then channel="RAID"
    elseif W3=="whisper" or W3=="w" then channel="WHISPER"
    else 
      QDKP2_Msg(QDKP2_COLOR_RED.."Wrong channel")
      return
    end
    if channel=="CHANNEL" and not W4 then
      QDKP2_Msg(QDKP2_COLOR_YELLOW.."You must include a channel name or number where you want to post the report into.")
      return
    end      
    if channel=="WHISPER" and not W4 then
      QDKP2_Msg(QDKP2_COLOR_YELLOW.."You must include a player name you want to send the report to.")
      return
    end      
    QDKP2_SendList(output,channel,W4)
    return
    
  end
  
  QDKP2_Msg(QDKP2_COLOR_RED..'Wrong sintax or command. Enter "/qdkp help" to see the commands list.')
end

function QDKP2_CL_Help()
  QDKP2_Msg("USE /qdkp2 or /qdkp or /dkp and one of these commands:")
  QDKP2_Msg("-------------------------")
  QDKP2_Msg("newsession [<sessionname>]")
  QDKP2_Msg("upload")
  QDKP2_Msg("timer on|off")
  QDKP2_Msg("ironman on|off|wipe")
  QDKP2_Msg("autoboss on|toggle|off")
  QDKP2_Msg("detectwin on|toggle|off")
  QDKP2_Msg("gui [show|toggle|Hide]")
  QDKP2_Msg("list [show|toggle|Hide]")
  QDKP2_Msg("log [show|toggle|Hide]")
  QDKP2_Msg("toolbox [show|toggle|Hide]")
  QDKP2_Msg("showlog <player>|RAID")
  QDKP2_Msg("showtoolbox <player>")
  QDKP2_Msg("do <player> spend|award|zerosum <dkp> [for <reason>]")
  QDKP2_Msg("set <player> total|spent|hours <amount>")
  QDKP2_Msg("decay <amount%>")
  QDKP2_Msg("raiddecay <amount%>")
  QDKP2_Msg("getvalues <player>")
  QDKP2_Msg("purgelog sessions|days|deleted|all [days or sessions]")
  QDKP2_Msg("makealt <altName> <mainName>")
  QDKP2_Msg("clearalt <altName>")
  QDKP2_Msg("addexternal <name>")
  QDKP2_Msg("remexternal <name>")
  QDKP2_Msg("addraid <name>")
  QDKP2_Msg("remraid [<name>]")
  QDKP2_Msg("notify <player>")
  QDKP2_Msg("notifyall")
  QDKP2_Msg("report <player>|Raid current|last|all say|yell|guild|officer|Raid|channel|whisper [whispername|channelnumber]")
  QDKP2_Msg("classdkp <class> say|yell|guild|officer|raid|channel|whisper [whispername|channelnumber]")
  QDKP2_Msg("rankdkp <class> say|yell|guild|officer|raid|channel|whisper [whispername|channelnumber]")
  QDKP2_Msg("charge loot|chat")
  QDKP2_Msg("resethours")
  QDKP2_Msg("------------------------")
  QDKP2_Msg("text inside [] means optional argument, | means multiple choice.")
  QDKP2_Msg("For more info read the mod's manual")
end

------- MISC FUNCTIONS ----------------

function QDKP2_CL_WordParser(text)
  local start=1
  local output={}
  for i=1,string.len(text) do
    if string.sub(text,i,i)==" " then
      table.insert(output,string.lower(string.sub(text,start,i-1)))
      start=i+1
    end
  end
  table.insert(output,string.lower(string.sub(text,start,string.len(text))))
  return output
end

--sets all hours to zero in the guild
function QDKP2_resetAllGuildHours()
	for i=1, table.getn(QDKP2name) do
    if not QDKP2_Alts[name] then
  		local name = QDKP2name[i]
  		local hour = QDKP2note[name][QDKP2_HOURS]
      if hour then
        --QDKP2session[name][QDKP2_HOURS] = QDKP2session[name][QDKP2_HOURS] - hour
        QDKP2note[name][QDKP2_HOURS] = 0
        QDKP2log_Entry(name,"Raiding hours has been resetted. (Was "..hour..")",QDKP2LOG_EVENT)
      end
    end
	end
  QDKP2_Msg(QDKP2_COLOR_WHITE.."Raiding hours resetted");
  QDKP2_StopCheck()
  QDKP2_Refresh_Roster("refresh")
  QDKP2_Refresh_Log("refresh")
end

--returns true if arg is "on" or "off" or "toggle"
function QDKP2_CL_IsLegalOnOfT(arg)
  if arg=="on" or arg=="off" or arg=="toggle" then return true;
  else return false;
  end
end

--returns the first index that is a newsession
function QDKP2_CL_FindReportIndex(name)
  local Log=QDKP2log[name]
  local index
  for i=1,table.getn(Log) do
    if Log[i][QDKP2LOG_TYPE]==QDKP2LOG_NEWSESSION then 
      index=i
      break
    end
  end
  QDKP2_Msg(index)
  QDKP2_Msg(table.getn(Log))
  if index<table.getn(Log) then 
    return index
  else return; end
end
    
    
  
