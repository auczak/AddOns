-- Copyright 2008 Riccardo Belloli (belloli@email.it)
-- This file is a part of QDKP_V2 (see about.txt in the Addon's root folder)

--             ## LOGGING SYSTEM ##

 
-------------------LOG GLOBALS----------------------

--Log Types
QDKP2LOG_CONFIRMED = 1  --modify entry succesfully uploaded (see QDKP2LOG_MODIFY)
QDKP2LOG_EVENT = 2          --generic log event
QDKP2LOG_CRITICAL = 3       --generic log error (related to QDKP, to the upload or to the sync)
QDKP2LOG_MODIFY = 4        --entry that log a DKP modification and has not created/modified and not uploaded yet.
QDKP2LOG_NEWSESSION = 5  --marker of a new session (do not sync)
QDKP2LOG_LOST = 6            --modify entry that has been lost because you started a new session before uploading them.
QDKP2LOG_JOINED = 7         --player that joined the raid (either because he was invited or because he returned online)
QDKP2LOG_LEAVED = 8        --player that leaved the raid (either because he really leaved the raid or because he went offline)
QDKP2LOG_EXTERNAL=9      --this is put when QDKP detects a change in the officer/public notes amounts. When he receives the log entry, this one is replaced.
QDKP2LOG_LOOT = 10          --logging of a loot
QDKP2LOG_ABORTED = 12   --modify entry that has been deactivated
QDKP2LOG_LINK = 13           --this entry is a link to annother entry
QDKP2LOG_NODKP = 20       --Lost award (manually excluded)
QDKP2LOG_NOOFFLINE=21  --Lost award (player was offline)
QDKP2LOG_NORANK=22      --Lost award (undkp-able rank)
QDKP2LOG_NOZONE=23      --Lost award (out of zone)
QDKP2LOG_NOLOWRAID=24  --Lost award (low raid attendance - used for IronMan bonus)
QDKP2LOG_NOLIMIT=25     --Lost award (player hitted hi/low net DKP limit)
QDKP2LOG_INVALID=31    --Returned if the log has a nil type

--Log SubTypes
QDKP2LOG_RAIDAW=1
QDKP2LOG_RAIDAWMAIN=2
QDKP2LOG_ZS=3
QDKP2LOG_ZSMAIN=4

--camps for each log entry
QDKP2LOG_TYPE = 1
QDKP2LOG_TIME = 2
QDKP2LOG_ACTION = 3
QDKP2LOG_UNDO = 4
QDKP2LOG_SUBTYPE = 5 -- nil = no link, 0 don't link, 1 link
 
 
QDKP2log = {}

----------------------QDKP2log_Entry----------------------
--[[Add to the Log an entry
  Usage QDKP2log_Entry(name, action, type, [mod], [undo], [timestamp], [subtype])
    name: string, the name of the player to loc. Can be "RAID" for raid log
    action: string, the action that has to ble logged
    type: an identifier of the log entry. can be QDKP2LOG_EVENT, QDKP2LOG_CRITICAL,... (look at the beginning of the file)
    mod: optional integer, specify a gain/loss in the net DKP.
    undo: a table with this structure: {[1]=x, [2]=y, [3]=z}. used to undo that command (on click)}
          x= total increase, y= spent increase and z=hours increase
    timestamp: tells the program the time to use
    subtype: used to tell the type of the entry. nil for pure modify, 1 for raid award and 2 for zerosum.
]]--

function QDKP2log_Entry(name2,action2,type2,mod2, undo2, timestamp2,subtype)
  name2=QDKP2_GetMain(name2)

  if not QDKP2log[name2] then
    QDKP2log[name2] = {}
  end
  local net

  if not timestamp2 then
    timestamp2 = QDKP2_Timestamp()
  end
  
  local tempEntry = {type2, timestamp2, action2, undo2, subtype}
  
  local indexBegin = 1 --i use this to avoid 2 consecutive "--New session started--" Entries.
  if table.getn(QDKP2log[name2]) > 0 then
    if QDKP2log[name2][1][QDKP2LOG_TYPE] == QDKP2LOG_NEWSESSION  and type2 == QDKP2LOG_NEWSESSION then 
      indexBegin = 2
    end
  end

  --add the entry at the top of the log
  local tempLog={}
  table.insert(tempLog,tempEntry)
  local Size = table.getn(QDKP2log[name2])
  if Size > QDKP2_LOG_MAX_SIZE then Size = QDKP2_LOG_MAX_SIZE;end  --pop the last entry if i'm at the maximum log's length
  for i=indexBegin,Size do
    table.insert(tempLog,QDKP2log[name2][i])
  end
  
  QDKP2log[name2] = tempLog  
end

--two dummies for QDKP2log_Entry

function QDKP2log_Event(name,event)
  QDKP2log_Entry(name,event,QDKP2LOG_EVENT)
end

function QDKP2log_Link(name, nametolink, timestamp)
  local reportName
  if QDKP2_IsAlt(nametolink) then 
    reportName=QDKP2_GetMain(nametolink)..";"..nametolink
  else
    reportName=nametolink 
  end
  QDKP2log_Entry(name, reportName, QDKP2LOG_LINK, nil, nil, timestamp)
end


---------------------- EDIT/DELETE FUNCTIONS------------------------------------

function QDKP2_LOG_UnDoEntry(name,index,onofftog)
  local Log = QDKP2log[name][index]
  local LogType = Log[QDKP2LOG_TYPE]
  local LogSubtype = Log[QDKP2LOG_SUBTYPE]
  if LogSubtype == QDKP2LOG_RAIDAWMAIN or LogSubtype==QDKP2LOG_ZSMAIN then
    local nameList, indexList =QDKP2_GetLogIndexList(QDKP2log[name][index][QDKP2LOG_TIME])
    for i=1, table.getn(nameList) do
      name2=nameList[i]
      index2 = indexList[i]
      if not QDKP2_IsAlt(name) and name2~=name then
        QDKP2_LOG_UnDoEntry(name2,index2,onofftog)
      end
    end
  end
  
  local addsub
  
  if QDKP2_IsDKPEntry(LogType) then
    if onofftog then
      if onofftog=="on" and LogType~=QDKP2LOG_ABORTED then return; end
      if onofftog=="off" and LogType==QDKP2LOG_ABORTED then return; end
    end
    local UnDo = Log[QDKP2LOG_UNDO]
    local DTotal = UnDo[1]
    local DSpent = UnDo[2]
    local DHours = UnDo[3]
    local SetTotal = DTotal
    local SetSpent = DSpent
    local SetHours = DHours
    local DeltaDKP = 0
    local onoff=""
    if onofftog then
      onoff = onofftog
    end
    
    if onoff == "on" then
      if QDKP2_IsDeletedEntry(LogType) then
        addsub = 1
      end
    elseif onoff == "off" then
      if not QDKP2_IsDeletedEntry(LogType) then
        addsub = -1
      end
    elseif QDKP2_IsDeletedEntry(LogType) then
      addsub = 1
    elseif not QDKP2_IsDeletedEntry(LogType) then
      addsub = -1
    end
  
    if DTotal then 
      DTotal = DTotal *addsub
      DeltaDKP = DTotal
    else
      SetTotal=0
    end
  
    if DSpent then 
      DSpent = DSpent *addsub
      DeltaDKP = DeltaDKP - DSpent
    else
      SetSpent=0
    end
  
    if DHours then 
      DHours = DHours *addsub
    else
      SetHours=0
    end
  
    local ChDeltaDKP=DeltaDKP
    if name~="RAID"  then
      local maxNet=QDKP2_GetNet(name)
      local minNet=QDKP2_GetNet(name)
      --[[
      for i=index,1,-1 do
        local tmpNet = QDKP2log[name][i][QDKP2LOG_NET]
	if tmpNet and tmpNet<minNet then minNet=tmpNet; end
        if tmpNet and tmpNet>maxNet then maxNet=tmpNet; end
      end
      ]]-- disabled. It finds the minimum and maximum net in log's history. Bad when i'll add sync
      if maxNet+DeltaDKP>QDKP2_MAXIMUM_NET then
        SetTotal=SetTotal-(maxNet+DeltaDKP-QDKP2_MAXIMUM_NET )
        DTotal=SetTotal*addsub
        DeltaDKP=QDKP2_MAXIMUM_NET-maxNet
      end
      if minNet+DeltaDKP<QDKP2_MINIMUM_NET then
        SetSpent=SetSpent+(minNet+DeltaDKP-QDKP2_MINIMUM_NET)
        DSpent=SetSpent*addsub
	DeltaDKP=QDKP2_MINIMUM_NET-minNet
      end
    end
    ChDeltaDKP= ChDeltaDKP-DeltaDKP
  
  --[[  if name ~= "RAID" and QDKP2_MAXIMUM_NET~=0 then
      local actNet=QDKP2_GetNet(name)
      local oldNet=Log[QDKP2LOG_NET]
      local maxNet=actNet
      if oldNet>actNet then maxNet=oldNet; end
      if (maxNet+DeltaDKP)>QDKP2_MAXIMUM_NET  then
        if not UnDo[1] then UnDo[1]=0; end
	UnDo[1]=UnDo[1]-((maxNet+DeltaDKP)-QDKP2_MAXIMUM_NET)
	QDKP2_SetLogEntry(name,index,UnDo[1],UnDo[2],UnDo[3],Log[QDKP2LOG_ACTION])
	QDKP2_LOG_UnDoEntry(name,index,onofftog)
	return
      end
]]
    
    if name ~="RAID" then
      if SetTotal==0 then SetTotal=nil; end
      if SetSpent==0 then SetSpent=nil; end
      if SetHours==0 then SetHours=nil; end
      Log[QDKP2LOG_UNDO]={SetTotal,SetSpent,SetHours}
      local newChange=0
      if SetTotal then newChange=newChange+SetTotal; end
      if SetSpent then newChange=newChange-SetSpent; end
      QDKP2_AddTotals(name, DTotal, DSpent, DHours)
    end
  
    local newType
    if addsub==1 then
      newType = QDKP2LOG_MODIFY
    else
      newType = QDKP2LOG_ABORTED
    end
    Log[QDKP2LOG_TYPE] = newType  
    
    --if name ~= "RAID" and addsub==1 then
   --   QDKP2_SetLogEntry(name,index,UnDo[1],UnDo[2],UnDo[3],Log[QDKP2LOG_ACTION])
  --  end
  end
end

function QDKP2_DeleteLogEntry(name,index)
  local IsModifiedBefore = QDKP2_IsModified(name)
  local tempLog = {}
  if index>1 then
    for i=1, index-1 do
      table.insert(tempLog,QDKP2log[name][i])
    end
  end
  if index<table.getn(QDKP2log[name]) then
    for i=index+1,table.getn(QDKP2log[name]) do
      table.insert(tempLog,QDKP2log[name][i])
    end
  end
  if QDKP2_Frame6:IsVisible() then
    QDKP2_Frame6:Hide()
  end
  
  QDKP2_SelectedLogIndex = 0
  QDKP2_ModifyLog=0
  
  local Log_Backup = QDKP2_CopyTable(QDKP2log)
  QDKP2log[name] = tempLog
  
end

function QDKP2_SetLogEntry(name,index,newGained,newSpent,newHours,newReason, Activate, NoProcessZs)
  local Log = QDKP2log[name][index]
  local LogType = Log[QDKP2LOG_TYPE]
  local LogSubtype = Log[QDKP2LOG_SUBTYPE]
  if LogSubtype == QDKP2LOG_RAIDAWMAIN then
    
    local nameList, indexList =QDKP2_GetLogIndexList(QDKP2log[name][index][QDKP2LOG_TIME])
    for i=1, table.getn(nameList) do
      name2=nameList[i]
      index2 = indexList[i]
      if not QDKP2_IsAlt(name) and name2 ~= name then
        QDKP2_SetLogEntry(name2,index2,newGained,newSpent,newHours,newReason)
      end
    end
  elseif LogSubtype==QDKP2LOG_ZSMAIN and not NoProcessZs then
    Log[QDKP2LOG_ACTION]=newReason
    QDKP2_SetLogEntry(name,index,nil,newSpent,nil,newReason,nil,true)
    QDKP2_ZeroSum_Update(name,index)
    return
  end
  
    name=QDKP2_GetMain(name)

    local Undo = Log[QDKP2LOG_UNDO]

    local oldGained
    local oldSpent
    local oldHours
    if not QDKP2_IsNODKPEntry(LogType) then
      oldGained = Undo[1]
      oldSpent = Undo[2]
      oldHours = Undo[3]
    end
    local Dnet = 0
    
    if not oldGained then
      oldGained = 0
    end
    if not oldSpent then
      oldSpent = 0
    end
    if not oldHours then
      oldHours = 0
    end
    if not newGained or newGained == "" then
      newGained =0
    end
    if not newSpent or newSpent == "" then
      newSpent = 0
    end
    if not newHours or newHours == "" then
      newHours = 0
    end
    
    newGained = tonumber(newGained)
    newSpent = tonumber(newSpent)
    newHours = tonumber(newHours)
    
    oldGained = tonumber(oldGained)
    oldSpent = tonumber(oldSpent)
    oldHours = tonumber(oldHours)
    
    Dnet = (newGained-oldGained) - (newSpent-oldSpent)
      
    if name~="RAID" and QDKP2_IsDKPEntry(LogType) then
      local maxNet=QDKP2_GetNet(name)
      local minNet=QDKP2_GetNet(name)
      --[[
      for i=index,1,-1 do
        local tmpNet = QDKP2log[name][i][QDKP2LOG_NET]
	if tmpNet and tmpNet<minNet then minNet=tmpNet; end
        if tmpNet and tmpNet>maxNet then maxNet=tmpNet; end
      end
      ]]-- Disabled. It serachs the maximum and minum net amounts in log history's. Bad for sync.
      if maxNet+Dnet>QDKP2_MAXIMUM_NET then
        newGained=newGained-(maxNet+Dnet-QDKP2_MAXIMUM_NET )
        Dnet=QDKP2_MAXIMUM_NET-maxNet
      end
      if minNet+Dnet<QDKP2_MINIMUM_NET then
        newSpent=newSpent+((minNet+Dnet)-QDKP2_MINIMUM_NET)
	Dnet=QDKP2_MINIMUM_NET-minNet
      end
    end
    
    if (not QDKP2_IsDeletedEntry(LogType) and not QDKP2_IsNODKPEntry(LogType) and name ~= "RAID") or Activate then
      QDKP2note[name][QDKP2_TOTAL] = QDKP2note[name][QDKP2_TOTAL] + newGained - oldGained
      QDKP2note[name][QDKP2_SPENT] = QDKP2note[name][QDKP2_SPENT] + newSpent - oldSpent
      QDKP2note[name][QDKP2_HOURS] = QDKP2note[name][QDKP2_HOURS] + newHours - oldHours
      QDKP2session[name][QDKP2_TOTAL] = QDKP2session[name][QDKP2_TOTAL] + newGained - oldGained
      QDKP2session[name][QDKP2_SPENT] = QDKP2session[name][QDKP2_SPENT] + newSpent - oldSpent
      QDKP2session[name][QDKP2_HOURS] =QDKP2session[name][QDKP2_HOURS] + newHours - oldHours  
      QDKP2_StopCheck()
    end
    
    Dgained = newGained - oldGained
    Dspent = newSpent - oldSpent
    Dhours = newHours - oldHours
    
    if Dgained ~= 0 or Dspent ~= 0 or abs(Dhours)>0.09 then
      if LogType == QDKP2LOG_CONFIRMED or Activate then
        Log[QDKP2LOG_TYPE] = QDKP2LOG_MODIFY
      end
    end
    
    if newReason == "" then
      newReason = nil
    end
    
    if LogSubtype~=QDKP2LOG_ZS then
      Log[QDKP2LOG_ACTION] = newReason
    end
    
    if newGained == 0 then newGained = nil; end
    if newSpent == 0 then newSpent = nil; end
    if newHours == 0 then newHours = nil; end
    Log[QDKP2LOG_UNDO]={newGained,newSpent,newHours}    
    
end

----------------------PURGE FUNCTIONS ---------------------------------------

-- purging function based on days before now. 
-- it's based on the time() function, wich gives the second after the epoch

function QDKP2_LOG_PurgeDays(days, Sure)
  if not Sure then
    mess = "Do you want to cancell all log entries\n older than "..days.." days?" 
    QDKP2_AskUserConf(mess,QDKP2_LOG_PurgeDays, days, true)
    return
  end
  local LogList = ListFromDict(QDKP2log)
  local tempLog = {}
  local MyTime = time()
  for i=1, table.getn(LogList) do
    local Name=LogList[i]
    if QDKP2_IsInGuild(Name) or Name=="RAID" then       -- don't process ppl no more in guild (delete them)
      local Log = QDKP2log[Name]
      local LogSize = table.getn(Log)
      local tempNameLog = {}
      for j=1, LogSize do
        local index = LogSize - j + 1
        local LogTime=Log[j][QDKP2LOG_TIME]
        if (MyTime-LogTime)/86400 < days then --keep only the entries with less than (days) (in a day we have 86400 seconds).
          table.insert(tempNameLog, Log[j])
        else
          break
        end
      end
      tempLog[Name] = tempNameLog
    end
  end

  QDKP2log = tempLog
  QDKP2_Refresh_Log("refresh")
end

function QDKP2_LOG_PurgeDeleted(Sure)
  if not Sure then
    mess = "Do you want to cancell\n all deactivated log entries?" 
    QDKP2_AskUserConf(mess, QDKP2_LOG_PurgeDeleted, true)
    return
  end
  local LogList = ListFromDict(QDKP2log)
  local logLength = table.getn(LogList)
  local tempLog = {}
  for i=1, logLength do
    local Name = LogList[i]
    if QDKP2_IsInGuild(Name) or Name=="RAID" then       -- don't process ppl no more in guild (delete them)
      local Log = QDKP2log[Name]
      local LogSize = table.getn(Log) 
      local tempNameLog = {}
      for j=1, LogSize do
        local logType = Log[j][QDKP2LOG_TYPE]
        if logType ~= QDKP2LOG_ABORTED and logType ~= QDKP2LOG_LOST then
          table.insert(tempNameLog, Log[j])
        end
      end
      tempLog[Name] = tempNameLog
    end
  end
  QDKP2log = tempLog
  QDKP2_Refresh_Log("refresh")
  end
  
function QDKP2_LOG_PurgeSessions(number,Sure)
  if not Sure then
    mess = "Do you want to cancell all log entries\n except for last "..number.." sessions?" 
    QDKP2_AskUserConf(mess,QDKP2_LOG_PurgeSessions, number, true)
    return
  end
  local LogList = ListFromDict(QDKP2log)
  local tempLog = {}
  for i=1, table.getn(LogList) do
    local Name = LogList[i]
    if QDKP2_IsInGuild(Name) or Name=="RAID" then       -- don't process ppl no more in guild (delete them)
      local Log = QDKP2log[Name]
      local LogSize = table.getn(Log)
      local logSession = 0
      local tempNameLog = {}
      for j=1, LogSize do
        table.insert(tempNameLog, Log[j])
        local logType = Log[j][QDKP2LOG_TYPE]
        if logType == QDKP2LOG_NEWSESSION then
          logSession = logSession + 1
          if logSession >= number then
            break
          end
        end
      end
      tempLog[Name] = tempNameLog
    end
  end
  QDKP2log = tempLog
  QDKP2_Refresh_Log("refresh")
end  

  
function QDKP2_LOG_PurgeWipe(Sure)
  if not Sure then
    mess = "Do you want to cancel\n all the log data?" 
    QDKP2_AskUserConf(mess,QDKP2_LOG_PurgeWipe, true)
    return
  end  
  QDKP2log = {}
  QDKP2_Refresh_Log("refresh")
end


;---------------------------------- QUERY FUNCTIONS -------------------------------


-- QDKP2log_GetModEntryText(Log,name) 
-- Returns the log's human-readable description.
function QDKP2log_GetModEntryText(Log,name)
  local Type = Log[QDKP2LOG_TYPE]
  local LinkedName
  local AltLinkedName
  if Type == QDKP2LOG_LINK then
    LinkedName, AltLinkedName=QDKP2log_GetLinkedPlayer(Log)
    Log=QDKP2_FindLog(QDKP2log[LinkedName],Log[QDKP2LOG_TIME])
    if not Log then return "*Invalid: Missing link destination*"; end
    Type = Log[QDKP2LOG_TYPE]
  end

  local output = ""
  
  if AltLinkedName then output=output..AltLinkedName.." ("..LinkedName..") "
  elseif LinkedName then output=output..LinkedName.." "
  end
  
  local reason = Log[QDKP2LOG_ACTION]
  
  local subtype = Log[QDKP2LOG_SUBTYPE]
  if subtype == QDKP2LOG_ZS then
    LinkedName, AltLinkedName=QDKP2log_GetLinkedPlayer(Log)
    local LinkLog=QDKP2_FindLog(QDKP2log[LinkedName],Log[QDKP2LOG_TIME])
    if not LinkLog then return "*Invalid: Missing link to main entry*"; end
    reason=LinkLog[QDKP2LOG_ACTION]
  end
  

  
  if QDKP2_IsDKPEntry(Type) or Type==QDKP2LOG_EXTERNAL then
    
    local Undo=Log[QDKP2LOG_UNDO]
  
    if not Undo then return "*Invalid: DKP entry and no UnDo field*"; end
  
    if (not Undo[1] and not Undo[2] and not Undo[3]) then
      if subtype==QDKP2LOG_ZS or subtype==RAIDAW then 
         Undo={0,nil,nil}
      else return "*Invalid: DKP entry and empty UnDo field*"
      end
    end
    
    local gained =  Undo[1]
    local spent =  Undo[2]
    local hours =  Undo[3]
    
    if Type==QDKP2LOG_EXTERNAL then
      output=output .. QDKP2_LOC_ExtMod
    elseif reason then
      if subtype == QDKP2LOG_RAIDAW then
        output=output .. QDKP2_LOC_RaidAwReas
      elseif subtype==QDKP2LOG_RAIDAWMAIN then
        output=output .. QDKP2_LOC_RaidAwMainReas
      elseif subtype == QDKP2LOG_ZS then
        output = output .. QDKP2_LOC_ZeroSumAwReas
      elseif subtype == QDKP2LOG_ZSMAIN then
        output = output .. QDKP2_LOC_ZeroSumSpReas
      else
        output= output .. QDKP2_LOC_GenericReas
      end
      output=string.gsub(output,"$REASON",reason)      
    else
      if subtype == QDKP2LOG_RAIDAW then
        output=output .. QDKP2_LOC_RaidAw
      elseif subtype==QDKP2LOG_RAIDAWMAIN then
        output=output .. QDKP2_LOC_RaidAwMain
      elseif subtype == QDKP2LOG_ZS then
        output = output .. QDKP2_LOC_ZeroSumAw
      elseif subtype == QDKP2LOG_ZSMAIN then
        output = output .. QDKP2_LOC_ZeroSumSp
      else
        output = output .. QDKP2_LOC_Generic
      end
    end
    
    if subtype == QDKP2LOG_ZS or subtype == QDKP2LOG_ZSMAIN then
      local giver=""
      if AltLinkedName then giver=AltLinkedName.." ("..LinkedName..")"
      elseif LinkedName then giver=LinkedName
      end
      output=string.gsub(output,"$GIVER",giver)
      output=string.gsub(output,"$AMOUNT",tostring(gained))
      output=string.gsub(output,"$SPENT",tostring(spent))
    end
    
    local AwardSpendText=QDKP2_GetAwardSpendText(gained, spent, hours)    
    output=string.gsub(output,"$AWARDSPENDTEXT",AwardSpendText)

  elseif Type==QDKP2LOG_NEWSESSION then
    output=output .. QDKP2_LOC_NewSess
    if reason then
      output=string.gsub(output,"$SESSIONNAME",reason)
    else
      output=string.gsub(output,"$SESSIONNAME",QDKP2_LOC_NoSessName)
    end

  elseif Type==QDKP2LOG_LOOT then
    output=output .. "Loots "..reason

  elseif QDKP2_IsNODKPEntry(Type) then
  
    local Undo=Log[QDKP2LOG_UNDO]

    if not Undo then Undo={0,nil,nil}; end
	
    if (not Undo[1] and not Undo[2] and not Undo[3]) then
      Undo={0,nil,nil}
    end
    
    local gained = Undo[1]
    local hours = Undo[3]
    local subtype = Log[QDKP2LOG_SUBTYPE]
    local whynot
    if Type==QDKP2LOG_NOOFFLINE then
      whynot = QDKP2_LOC_Offline
    elseif Type==QDKP2LOG_NORANK then
      whynot = QDKP2_LOC_NoRank
    elseif Type==QDKP2LOG_NOZONE then
      whynot = QDKP2_LOC_NoZone
    elseif Type==QDKP2LOG_NOLOWRAID then
      whynot = QDKP2_LOC_LowAtt
    elseif Type==QDKP2LOG_NODKP then
      whynot= QDKP2_LOC_ManualRem
    elseif Type==QDKP2LOG_NOLIMIT then
      whynot= QDKP2_LOC_NetLimit
    end
    if gained then 
      if reason then
        if subtype==QDKP2LOG_RAIDAW then
          output = output .. QDKP2_LOC_NoDKPRaidReas
	else
	  output = output .. QDKP2_LOC_NoDKPZSReas
	end
	output = string.gsub(output,"$REASON",reason)	
      else
        if subtype==QDKP2LOG_RAIDAW then
          output = output .. QDKP2_LOC_NoDKPRaid
	else
	  output = output .. QDKP2_LOC_NoDKPZS
	end
      end
      output = string.gsub(output,"$AMOUNT",gained)
    elseif hours then
      output = output .. QDKP2_LOC_NoTick
    end
    
    if subtype == QDKP2LOG_ZS or subtype == QDKP2LOG_ZSMAIN then
      local giver=""
      if AltLinkedName then giver=AltLinkedName.." ("..LinkedName..")"
      elseif LinkedName then giver=LinkedName
      end
      output=string.gsub(output,"$GIVER",giver)
    end
    
    output = string.gsub(output,"$WHYNOT",whynot)

  else
    output = reason
  end
  
  return output
end

--dummy of GetModEntryText, 
--Returns the description of the last log entry of name.
function QDKP2_GetLastLogText(name)
  return QDKP2log_GetModEntryText(QDKP2log[name][1],name)
end


function QDKP2_GetAwardSpendText(gained, spent, hours)
  local output
  if gained then
    if spent then
      if hours then
        output=QDKP2_LOC_GainsSpendsEarns
      else
        output=QDKP2_LOC_GainsSpends
      end
    else
      if hours then
        output=QDKP2_LOC_GainsEarns
      else
        output=QDKP2_LOC_Gains
      end
    end
  else
    if spent then
      if hours then
        output=QDKP2_LOC_SpendsEarns
      else
        output=QDKP2_LOC_Spends
      end
    else
      if hours then
        output=QDKP2_LOC_Earns
      else
        output=""
      end
    end
  end
  
  if gained then
    output=string.gsub(output,"$GAIN",gained)
  end
  if spent then
    output=string.gsub(output,"$SPEND",spent)
  end
  if hours then
    output=string.gsub(output,"$HOUR",hours)
  end
  return output
end
    
--returns the date and time for the log voice passed
function QDKP2log_GetModEntryDateTime(Log)
  local Time=Log[QDKP2LOG_TIME]
  if not Time then return "Invalid Timestamp"; end
  local datestring = ""
  local entryTime = math.floor(Time)
  if not entryTime then return "Invalid Timestamp"; end
  local nowTime = time()
  if date("%x",nowTime) == date("%x",entryTime) or nowTime-entryTime < 3600 * QDKP2_DATE_TIME_TO_HOURS then
    datestring = date("%H:%M:%S",entryTime)
  elseif nowTime-entryTime < 86400 * QDKP2_DATE_TIME_TO_DAYS + tonumber(date("%H",nowTime))*3600 + tonumber(date("%M",nowTime))*60 then
    datestring = date("%a %H:%M",entryTime)
  else
    datestring = date("%d/%m %H:%M",entryTime)
  end
  return datestring
end


-- Returns the linked log if is a link, and the log itself if not.
function QDKP2_CheckLogLink(Log)
  if Log[QDKP2LOG_TYPE]==QDKP2LOG_LINK then
    local name=QDKP2log_GetLinkedPlayer(Log)
    return QDKP2_FindLog(QDKP2log[name],Log[QDKP2LOG_TIME])
  else
    return Log
  end
end

--returns the net change of given log entry.
function QDKP2log_GetChange(LogEntry)
	local Type=LogEntry[QDKP2LOG_TYPE]
	if not QDKP2_IsActiveDKPEntry(Type) then return 0; end
	local UnDo=LogEntry[QDKP2LOG_UNDO]
	if not UnDo then return 0; end
	local Total=UnDo[1]
	local Spent=UnDo[2]
	if not Total and not Spent then return 0; end
	if not Total then Total=0; end
	if not Spent then Spent=0; end
	return Total-Spent
end

-- returns a list with the net amounts history for each log voice.
function QDKP2log_GetNetAmounts(name)
        if not QDKP2_IsInGuild(name) then return {},{}; end
	local Net=QDKP2_GetNet(name)
	local Nets={}
	local Changes={}
	local Log=QDKP2log[name]
	if not Log then return {}; end
	for i=1,table.getn(Log),1 do
		local LogEntry=Log[i]
		local Change=QDKP2log_GetChange(LogEntry)
		table.insert(Nets,Net)
		table.insert(Changes,Change)
		if Change then Net=Net-Change; end
	end
	return Nets,Changes
end

--Returns the names used in links, made in the form "name" or "mainName;altName".

function QDKP2log_GetLinkedPlayer(Log)
	local Text=Log[QDKP2LOG_ACTION]
	if not Text then return nil; end
	if string.find(Text,";") then
		local _,_,Link,AltLink = string.find(Text,"(.+);(.+)")
		return Link,AltLink
	else
		return Text
	end
end

--Returns the type of the log
function QDKP2log_GetType(Log)
  local Type
  if Log then Type=Log[QDKP2LOG_TYPE]; end
  if not Type then Type=QDKP2LOG_INVALID; end
  return Type
end


-- return true if the log entry is a Deleted entry

function QDKP2_IsDKPEntry(Type)
 if Type == QDKP2LOG_LOST or Type == QDKP2LOG_ABORTED or Type == QDKP2LOG_MODIFY or Type == QDKP2LOG_CONFIRMED then
   return true
 end
end

function QDKP2_IsActiveDKPEntry(Type)
  if Type == QDKP2LOG_MODIFY or Type == QDKP2LOG_CONFIRMED then return true; end
end

function QDKP2_IsDeletedEntry(Type)
  if Type == QDKP2LOG_LOST or Type == QDKP2LOG_ABORTED then
    return true
  end
end

function QDKP2_IsNODKPEntry(Type)
  if Type == QDKP2LOG_NODKP or Type == QDKP2LOG_NOOFFLINE or Type == QDKP2LOG_NORANK or Type == QDKP2LOG_NOZONE or Type == QDKP2LOG_NOLOWRAID or Type == QDKP2LOG_NOLIMIT then 
    return true 
  end
end

function QDKP2_Timestamp() --returns a timestamp with a Entry ID, to avoid collisions on linked items
  QDKP2_EID=QDKP2_EID+0.01
  return time()+QDKP2_EID
end


----------------------------SEARCH-----------------

--/script QDKP2_FindLog(QDKP2log["Thebreaker"],1181137456.008)

--this function returns the index of the Log with the given coordinates
--id do a iterative research to find the entry in a ordinate list.
function QDKP2_FindLogIndex(LogList,timestamp)
  if not LogList or table.getn(LogList)==0 then return; end
  local a=1
  local b=table.getn(LogList)
  if LogList[a][QDKP2LOG_TIME]<timestamp or LogList[b][QDKP2LOG_TIME]>timestamp then return; end
  if LogList[a][QDKP2LOG_TIME]==timestamp then return a; end
  if LogList[b][QDKP2LOG_TIME]==timestamp then return b; end
  if b==1 or b==2 then return; end
  while (b-a) > 1 do
    local c=math.floor((a+b)/2)
    local ts=LogList[c][QDKP2LOG_TIME]
    if ts==timestamp then return c
    elseif ts>timestamp then a=c
    elseif ts<timestamp then b=c
    end
  end
end


--Dummy of FindLogIndex that returns the log and not the index
function QDKP2_FindLog(LogList,timestamp)
  local index=QDKP2_FindLogIndex(LogList,timestamp)
  return LogList[index]
end


--this searchs the whole log for entry that have the given timestamp and
--returns a list of logs and name
-- { NameList , LogList}
function QDKP2_GetLogList(timestamp)
  local nameList = {}
  local logList={}
  local LogNames=ListFromDict(QDKP2log)
  for i=1, table.getn(LogNames) do
    local name = LogNames[i]
    local log = QDKP2_FindLog(QDKP2log[name], timestamp)
    if log then
      table.insert(nameList, name)
      table.insert(logList, log)
    end
  end
  return nameList, logList
end
 

--this searchs the whole log for entry that have the given timestamp and
--returns a list of logs and name
-- { NameList , IndexList}
function QDKP2_GetLogIndexList(timestamp)
  local nameList = {}
  local indexList={}
  local LogNames=ListFromDict(QDKP2log)
  for i=1, table.getn(LogNames) do
    local name = LogNames[i]
    local index = QDKP2_FindLogIndex(QDKP2log[name], timestamp)
    if index then
      table.insert(nameList, name)
      table.insert(indexList, index)
    end
  end
  return nameList, indexList
end
;---------------------------------- UTILITY ---------------------------------

function QDKP2log_SetNewSessionName(NewSessionName,Log)
  local timeStamp = Log[QDKP2LOG_TIME]
  local nameList,logList=QDKP2_GetLogList(timeStamp)
  for i=1,table.getn(logList) do
    logList[i][QDKP2LOG_ACTION]=NewSessionName
  end
  QDKP2_Refresh_Log("refresh")
end

-- Called after a confirmed upload or reset, change the log_type of all the last QDKP2LOG_MODIFY to a new type.
-- if called wit true will change them in QDKP2LOG_CONFIRMED, with false with QDKP2LOG_LOST

function QDKP2log_ConfirmEntries(name,successup)
  local UploadProblems = false
  local HasBeenConfirmed = false
  local LogList = QDKP2log[name]
  local entries = 0
  if LogList then
    entries = table.getn(LogList)
  end
  
  for i=1, entries do  
    local Type = LogList[i][QDKP2LOG_TYPE]
    if Type == QDKP2LOG_CRITICAL and not HasBeenConfirmed then
      UploadProblems = true               --if i had problems on the upload remind that
    elseif Type == QDKP2LOG_MODIFY and successup then
       LogList[i][QDKP2LOG_TYPE] = QDKP2LOG_CONFIRMED   --change all the logtype for the entry after the last confirmed align
    elseif Type == QDKP2LOG_MODIFY and not successup then
       LogList[i][QDKP2LOG_TYPE] = QDKP2LOG_LOST
    end
    if Type == QDKP2LOG_NEWSESSION or Type==QDKP2LOG_CONFIRMED then
      HasBeenConfirmed = true
    end
  end

  if UploadProblems then
    QDKP2log_Entry(name,"CHECK: Now the values are aligned",QDKP2LOG_NEWSESSION) --if i had problems specify that now i am ok
    QDKP2_Msg(QDKP2_COLOR_GREEN..name.." is now correctly aligned with officernotes.")
    QDKP2_Refresh_Log("refresh")
  end
end
 
-------------------------------- REPORTS -----------------------------------

--this will create the report and send it on the given channel (GetReport+SendList)
function QDKP2_MakeAndSendReport(name,reportType,index,channel,channelSub) 
  local reportList = QDKP2_GetReport(name,reportType,index)
  QDKP2_SendList(reportList,channel,channelSub)
end

function QDKP2_SendListGetChannelSub(channelSub,List,channel)
  QDKP2_SendList(List,channel,channelSub)
end

function QDKP2_SendList(List,channel,channelSub)
  if channel == "CHANNEL" and not channelSub then
    QDKP2_OpenInputBox("Please enter the number of the channel\n to send the report",QDKP2_SendListGetChannelSub, List, channel)
    return
  end  
  if channel == "WHISPER" and not channelSub then
    QDKP2_OpenInputBox("Please enter the name of the player\n to send the report",QDKP2_SendListGetChannelSub, List, channel)
    return
  end
  for i=1, table.getn(List) do
    ChatThrottleLib:SendChatMessage("ALERT", "QDKP2", List[i], channel ,nil, channelSub)
 end
end



function QDKP2_GetReport(name,reportType,index)
  if not index then index = 1; end
  LogList=QDKP2log[name]
  if not LogList then return; end
  LogLength = table.getn(LogList)
  if LogLength == 0 then return; end
  local reportList = {}
  
  if reportType == "All" then
    reportList = QDKP2_Invert(LogList)
    
  elseif reportType == "All after index" then
    for i=index, 1, -1 do
      table.insert(reportList, LogList[i])
    end
    
  elseif reportType == "All untill index" then
    for i=LogLength, index, -1 do
      table.insert(reportList, LogList[i])
    end
    
  elseif reportType == "Session" then
    local c
    for i=index, LogLength do
      sessionStart=i
      if LogList[i][QDKP2LOG_TYPE] == QDKP2LOG_NEWSESSION then
        break
      end
    end
    table.insert(reportList, LogList[sessionStart])
    for i=sessionStart-1, 1, -1 do
      if LogList[i][QDKP2LOG_TYPE] == QDKP2LOG_NEWSESSION then
        break
      end
      table.insert(reportList, LogList[i])
    end
    
  elseif reportType == "Session after index" then
    table.insert(reportList, LogList[index])
    for i=index-1, 1, -1 do
      if LogList[i][QDKP2LOG_TYPE] == QDKP2LOG_NEWSESSION then
        break
      end
      table.insert(reportList, LogList[i])
    end
    
  elseif reportType == "Session untill index" then
    for i=index, LogLength do
      table.insert(reportList, LogList[i])
      if LogList[i][QDKP2LOG_TYPE] == QDKP2LOG_NEWSESSION then
        break
      end
    end
    reportList=QDKP2_Invert(reportList)
    
  elseif reportType == "index" then
    table.insert(reportList, LogList[index])
  end
  
  local header = "<QDKP2>"..QDKP2_Reports_Header
  header = string.gsub(header, '$NAME', name)
  header = string.gsub(header, '$TYPE', reportType)
  
  local tail = "<QDKP2>"..QDKP2_Reports_Tail
  
  return QDKP2_GetReportLines(name, reportList, header, tail)  
end

function QDKP2_GetReportLines(name, LogList, header, tail) --returns a list with the lines of the report

  local output = {}
  if header then
    output = {}
    if name == "RAID" then
      output = {header,
              "   Time      Action",
              "-----------------------------",
              }
    else
      output = {header,
              "   Time     Net      Action",
              "--------------------------------------",
              }
    end
  end
  
  local Nets= QDKP2log_GetNetAmounts(name)
  local NoUploadedYet
  for i=1, table.getn(LogList)  do
    local OriginalLog = LogList[i]
    local Log = QDKP2_CheckLogLink(OriginalLog)
	
    local Type = Log[QDKP2LOG_TYPE]

    if not QDKP2_IsDeletedEntry(Type) then
      local action=QDKP2log_GetModEntryText(OriginalLog,name)
      local net = Nets[table.getn(Nets)-i+1]
      local datetime = QDKP2log_GetModEntryDateTime(Log)
      local str
      if net and name ~= "RAID" then
        str=datetime.." <"..net.."> "..action
      else
        str=datetime.." - "..action
      end
      str=str.."."
      if Type==QDKP2LOG_MODIFY then 
        str=str.." (*)"
        NoUploadedYet=true
      end
      table.insert(output, str)
    end
  end
  
  if tail then
    table.insert(output, "--------------------------------")
    if NoUploadedYet then
      table.insert(output, "(*): This voice has not been syncronized yet.")
    end
    table.insert(output, tail)
  end
  return output
end
    
