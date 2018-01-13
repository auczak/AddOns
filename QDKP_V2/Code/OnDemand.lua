-- Copyright 2008 Riccardo Belloli (belloli@email.it)
-- This file is a part of QDKP_V2 (see about.txt in the Addon's root folder)

--             ## ON-DEMAND FUNCTIONS ##


function QDKP2_OD_Parse(text)
  local Phrase1
  local Phrase2
  local Phrase3
  if strlen(text)<=2 then return;end
  local i1=strfind(text," ")
  if not i1 then return text, nil, nil;  end
  Phrase1=strsub(text,1,i1-1)
  local i2=strfind(text," ",i1+1)
  if i2 then 
    Phrase2=strsub(text,i1+1,i2-1)
  elseif strlen(strsub(text,i1+1))>0 then
    Phrase2=strsub(text,i1+1)
  end
  if i2 then
    local i3=strfind(text," ",i2+1)
    if i3 then 
      Phrase3=strsub(text,i2+1,i3)
    elseif strlen(strsub(text,i2+1))>0 then
      Phrase3=strsub(text,i2+1)
    end
  end
  return Phrase1, Phrase2, Phrase3  
end


function QDKP2_OD(text, sender)
  
  local P1,P2,P3=QDKP2_OD_Parse(text)
  
  if not P1 then return; end
  if strlower(P1)=="?dkp" then
    if not QDKP2_IsInGuild(sender) and not QDKP_OD_EXT then
      return {"QDKP2 - Only GuildMembers can use the On-Demand whisper system."}
    end
    if not P2 then P2=sender
    else P2 = QDKP2_FormatName(P2)
    end
    if not QDKP2_NOD then
      return {"QDKP2 - This feature is disabled."}
    elseif not (P2==sender or QDKP2_IOD_REQALL) then
      return {"QDKP2 - You can't ask for other player's data."} 
    elseif not QDKP2_IsInGuild(P2) then
      return {"QDKP2 - "..P2..": Invalid Guild Member Name."}
    else
      if P2==sender then
        return {QDKP2_MakeNotifyMsg(P2)}
      else
        return {QDKP2_MakeNotifyMsg(P2,true)}
      end
    end
  
  elseif strlower(P1)=="?report" or strlower(P1)=="?log" then
    if not QDKP2_IsInGuild(sender) and not QDKP_OD_EXT then
      return {"QDKP2 - Only GuildMembers can use the On-Demand whisper system."}
    end
    if not P2 then P2=sender
    else P2 = QDKP2_FormatName(P2)
    end
    if P2=="Raid" then P2="RAID"; end
    if not QDKP2_ROD then
      return {"QDKP2 - This feature is disabled."}
    elseif not (P2==sender or QDKP2_IOD_REQALL) then
      return {"QDKP2 - You can't ask for other player's data."} 
    elseif not (QDKP2_IsInGuild(P2) or P2 == "RAID") then
      return {"QDKP2 - "..P2..": Invalid Guild Member Name."}
    else
      if not P3 then P3="current"
      else P3 = strlower(P3)
      end
      local reportType
      local index=1
      if P3=="current" or P3=="last" then
        reportType="Session"
      elseif P3=="previous" then
        reportType="Session"
        index=QDKP2_CL_FindReportIndex(P2)
	if not index then return {"QDKP2 - Just one session in "..P2.."'s Log."}; end
	index = index +1
      elseif P3=="all" then
        reportType="All"
      else
        return {'QDKP2 - Wrong report type. Usage: "?report <name> current-previous-all"'} 
      end
      local Report=QDKP2_GetReport(P2,reportType,index)
      if Report and table.getn(Report)>0 then
        return Report
      else
        return {'QDKP2 - No data in '..P2.."'s Log."}
      end
    end
    
  elseif strlower(P1)=="?prices" or strlower(P1)=="?price" then
    if not QDKP2_IsInGuild(sender) and not QDKP_OD_EXT then
      return {"QDKP2 - Only GuildMembers can use the On-Demand whisper system."}
    end
    if not QDKP2_POD then return {"QDKP2 - This feature is disabled."}; end
    local arg=string.lower(string.sub(text,8))
    local output={}
    if not arg then return {"QDKP2 - You must give a keyword to search for."}; end
    if string.len(arg)<QDKP2_POD_MINKEYWORD then return {"QDKP2 - Search keyword must be longer than "..tostring(QDKP2_POD_MINKEYWORD).." chars."}; end
    local results=0
    for i=1,table.getn(QDKP2_ChargeLoots) do
      if strfind(string.lower(QDKP2_ChargeLoots[i].item), arg) then
        table.insert(output,"["..QDKP2_ChargeLoots[i].item.."], "..tostring(QDKP2_ChargeLoots[i].DKP).." DKP")
	results=results+1
      end
      if results>QDKP2_POD_MAXRESULTS then
        table.insert(output,"Max result limit hit. Please refine your search.")
	return output
      end
    end
    if table.getn(output)>0 then
      return output
    else
      return {"QDKP2 - No results for the given keyword"}
    end
      
  elseif strlower(P1)=="?award" or strlower(P1)=="?awards" or strlower(P1)=="?bossaward"or strlower(P1)=="?bossawards" then
    if not QDKP2_IsInGuild(sender) and not QDKP_OD_EXT then
      return {"QDKP2 - Only GuildMembers can use the On-Demand whisper system."}
    end
    if not QDKP2_AOD then return {"QDKP2 - This feature is disabled."}; end
    local arg=string.lower(string.sub(text,8))
    local output={}
    if not arg then return {"QDKP2 - You must give a keyword to search for."}; end
    if string.len(arg)<QDKP2_AOD_MINKEYWORD then return {"QDKP2 - Search keyword must be longer than "..tostring(QDKP2_AOD_MINKEYWORD).." chars."}; end
    local results=0
    for i=1,table.getn(QDKP2_Bosses) do
      if strfind(string.lower(QDKP2_Bosses[i].name), arg) then
        table.insert(output,'"'..QDKP2_Bosses[i].name..'", '..tostring(QDKP2_Bosses[i].DKP).." DKP")
	results=results+1
      end
      if results>QDKP2_AOD_MAXRESULTS then
        table.insert(output,"Max result limit hit. Please refine your search.")
	return output
      end
    end
    if table.getn(output)>0 then
      return output
    else
      return {"QDKP2 - No results for the given keyword"}
    end
  
  elseif (strlower(P1)=="?classdkp" or strlower(P1)=="?dkpclass") then
    if not QDKP2_IsInGuild(sender) and not QDKP_OD_EXT then
      return {"QDKP2 - Only GuildMembers can use the On-Demand whisper system."}
    end
    if not QDKP2_COD then return {"QDKP2 - This feature is disabled."}; end
    local arg=(P2 and string.lower(P2)) or (QDKP2class[sender] and string.lower(QDKP2class[sender]))
    if not arg or arg=="--" then return {"QDKP2 - You must provide the class to report."}; end
    local class
    if arg=="druid" then
      class="Druid"
    elseif arg=="hunter" then
      class="Hunter"
    elseif arg=="mage" then
      class="Mage"
    elseif arg=="paladin" then
      class="Paladin"
    elseif arg=="priest" then
      class="Priest"
    elseif arg=="rogue" then
      class="Rogue"
    elseif arg=="shaman" then
      class="Shaman" 
    elseif arg=="warlock" then
      class="Warlock"
    elseif arg=="warrior" then
      class="Warrior"
    else
      return {"QDKP2 - You must specify a valid class name."}
    end
    local output={"QDKP2 - DKP Top score for "..class.." class:"}
    local list={}
    for i = 1,table.getn(QDKP2name) do
      local name=QDKP2name[i]
      local classAct=QDKP2class[name]
      if classAct==class then
        table.insert(list,name)
      end
    end
    if table.getn(list)==0 then return {"QDKP2 - No Guild Members of the given class"}; end
    list=QDKP2_netSort(list)
    for i=1,table.getn(list) do
      if i > QDKP2_LOD_MAXLEN then break; end
      local name=list[i]
      local DKP=QDKP2_GetNet(name)
      table.insert(output,QDKP2_GetName(name).." - "..tostring(DKP).." DKP")
    end
    return output
  
  elseif (strlower(P1)=="?rankdkp" or strlower(P1)=="?dkprank") then
    if not QDKP2_IsInGuild(sender) and not QDKP_OD_EXT then
      return {"QDKP2 - Only GuildMembers can use the On-Demand whisper system."}
    end
    if not QDKP2_KOD then return {"QDKP2 - This feature is disabled."}; end
    local rank=(P2 and string.lower(P2)) or (QDKP2rank[sender] and string.lower(QDKP2rank[sender]))
    if not rank then return {"QDKP2 - You must provide the rank to report."}; end
    if rank=="external" then rank="*external*"; end
    local output={"QDKP2 - DKP Top score for "..rank.." rank:"}
    local list={}
    for i = 1,table.getn(QDKP2name) do
      local name=QDKP2name[i]
      local rankAct=string.lower(QDKP2rank[name])
      if rankAct==rank then
        table.insert(list,name)
      end
    end
    if table.getn(list)==0 then return {"QDKP2 - No Guild Members of the given rank"}; end
    list=QDKP2_netSort(list)
    for i=1,table.getn(list) do
      if i > QDKP2_LOD_MAXLEN then break; end
      local name=list[i]
      local DKP=QDKP2_GetNet(name)
      table.insert(output,QDKP2_GetName(name).." - "..tostring(DKP).." DKP")
    end
    return output
  
  elseif strlower(P1)=="?help" or strlower(P1)=="?commands" or strlower(P1)=="?command"  or strlower(P1)=="?keyword"  or strlower(P1)=="?keywords" then
    if not QDKP2_IsInGuild(sender) and not QDKP_OD_EXT then
      return {"QDKP2 - Only GuildMembers can use the On-Demand whisper system."}
    end
    local output={  "QDKP2 - On Demand enabled keywords list:"}
    if QDKP2_NOD then table.insert(output, '"?dkp <name>"'); end
    if QDKP2_COD then table.insert(output, '"?classdkp <class>"'); end
    if QDKP2_KOD then table.insert(output, '"?rankdkp <rank>"'); end
    if QDKP2_ROD then table.insert(output, '"?log <name> <session>"'); end
    if QDKP2_POD then table.insert(output, '"?prices <keywords>"'); end
    if QDKP2_AOD then table.insert(output, '"?award <keywords>"'); end
    if table.getn(output)==1 then output={"QDKP2 - No On Demand enabled keywords."}; end
    return output
  end
end
