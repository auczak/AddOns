-- Copyright 2008 Riccardo Belloli (belloli@email.it)
-- This file is a part of QDKP_V2 (see about.txt in the Addon's root folder)

--          ## GUI FUNCTIONS ##


-------------------GUI Constants-------------------------------

QDKP2_numFrame2entries = 20
QDKP2_numFrame5entries = 25
QDKP2_numRaidOnLastUpdate=0
QDKP2_ListIndex = 1
QDKP2_LogIndex = 1
QDKP2_SelectedPlayerIndex = 1
QDKP2_SelectedPlayer = nil
QDKP2log_show = nil
QDKP2_SelectedLogIndex=0
QDKP2_ModifyPlayer=nil
QDKP2_ModifyLog=nil
QDKP2_FramesOpen = {}
QDKP2_Order="Alpha"

------------------------------------- INIT ----------------------------------
function QDKP2_GUI_Init()
end

------------------------------------- ON LOAD ----------------------------------------
function QDKP2_GUI_OnLoad()
  if QDKP2ironMan_time then
    QDKP2frame1_ironman:SetText("Finish")
  end
  QDKP2_frame1_dkpAwardRaidSet(QDKP2_dkpAwardRaid)
  QDKP2_frame1_dkpPerHourSet(QDKP2_dkpPerHour)
  QDKP2_RefreshAll()
  QDKP2_Frame2_Header:SetText("Roster")
  QDKP2_Frame4_Header:SetText("Set Player Amounts")
  QDKP2_Frame6_Header:SetText("Modify Entry Value")
  QDKP2_RefreshBackupTime()
end


----------------------------------------TOGGLES------------------------
--Brings up popup GUI
function QDKP2_Toggle_Main(showFrame) --showFrame is optional
  if QDKP2_OfficerMode() then QDKP2_Toggle(1)
  else QDKP2_Refresh_Roster("toggle")
  end
end

---------------------------------------

--Toggles the quickbutton frame (frame0) from moveable to non moveable and visa versa
function QDKP2_ToggleMoveable()
  if(QDKP2_QuickButton:IsMovable()) then
    QDKP2_QuickButton:SetMovable(false);
  else
    QDKP2_QuickButton:SetMovable(true);
  end
end

---------------------------------------

--toggles it so that it will hide windows past closed window, but shows them if that one is opened again
function QDKP2_SmartToggle(toggleFrame)
  QDKP2_SetLootCharge(nil)
  if(QDKP2_FramesOpen[toggleFrame]) then
    QDKP2_FramesOpen[toggleFrame]=false
  else
    QDKP2_FramesOpen[toggleFrame]=true
  end
  
  for i=1, 6 do
    local incFrame = getglobal("QDKP2_Frame"..i)
    if(QDKP2_FramesOpen[i]) then
      if QDKP2_OfficerMode() or (i==2 or i==5) then 
        incFrame:Show()
      end
    else
      incFrame:Hide()
    end
  end
end


--toggles target frame.. secondvar is optional
function QDKP2_Toggle(frameNum, showFrame)
  QDKP2_SetLootCharge(nil)
  local incFrame = getglobal("QDKP2_Frame"..frameNum)
  if incFrame then
    if showFrame==true then
      if QDKP2_OfficerMode() or (frameNum==2 or frameNum==5) then 
        incFrame:Show()
        QDKP2_FramesOpen[frameNum] = true
      end
    elseif showFrame==false then
      incFrame:Hide();
      QDKP2_FramesOpen[frameNum] = false
    else
      if incFrame:IsVisible() then
        incFrame:Hide();
        QDKP2_FramesOpen[frameNum] = false
      else
        if QDKP2_OfficerMode() or (frameNum==2 or frameNum==5) then 
	  incFrame:Show()
          QDKP2_FramesOpen[frameNum] = true
	end
      end
    end
  end
end

---------------------------------------

--Toglges all frames after index off, but only first on
function QDKP2_ToggleOffAfter(index)
  QDKP2_SetLootCharge(nil)
  if index==1 then
    QDKP2_RefreshBackupTime()
  end
  
  local temp = getglobal("QDKP2_Frame"..index)
  local isOn = false
  if(temp:IsVisible() ) then
    isOn = true
    local incFrame = getglobal("QDKP2_Frame"..index)
    incFrame:Hide();
  else
    local incFrame = getglobal("QDKP2_Frame"..index)
    if QDKP2_OfficerMode() or (index==2 or index==5) then incFrame:Show(); end
  end 
  
  if index <= 1 and isOn then
    QDKP2_SelectedPlayer = ""
    QDKP2_Refresh_Log("hide")
    QDKP2_Refresh_ModifyPane("hide")
  end
  if index == 5 and isOn then
    QDKP2_Refresh_Log("hide")
    QDKP2_Refresh_ModifyPane("hide")
  end
  for i=index, 4 do
    local incFrame = getglobal("QDKP2_Frame"..i)
    if(isOn == true ) then
      incFrame:Hide();
    end
    
  end
end

---------------------------------------

--Toggles all frames after index off/on
function QDKP2_ToggleAfter(index)
  QDKP2_SetLootCharge(nil)
  local temp = getglobal("QDKP2_Frame"..index)
  local isOn = false
  if(temp:IsVisible() ) then
    isOn = true
    local incFrame = getglobal("QDKP2_Frame"..index)
    incFrame:Hide();
  else
    local incFrame = getglobal("QDKP2_Frame"..index)
    if QDKP2_OfficerMode() or (index==2 or index==5) then incFrame:Show(); end
  end
  if index <= 1 and isOn then
    QDKP2_SelectedPlayer = ""
    QDKP2_Refresh_Log("hide")
    QDKP2_Refresh_ModifyPane("hide")
    QDKP2_ReportBox:Hide()
  end
  if index == 5 and isOn then
    QDKP2_Refresh_Log("hide")
    QDKP2_Refresh_ModifyPane("hide")
    QDKP2_ReportBox:Hide()
  end
  for i=index, 4 do
    local incFrame = getglobal("QDKP2_Frame"..i)
    if(isOn == true ) then
      incFrame:Hide();
    else
      if QDKP2_OfficerMode() or (i==2 or i==5) then incFrame:Show(); end
    end
  end
end

---------------------------------------

--Toggles the button that sets all raid or all guild
function QDKP2_AllGuildCheckButtonSet(todo)
  QDKP2_ListIndex = 1
  QDKP2_SelectedPlayerIndex = 1
  QDKP2_SelectedPlayer =""
  
  if todo=="toggle" then
    if(QDKP2frame2_guildCheckButton:GetChecked()==1) then
      QDKP2_ShowAllGuild = true
    else
      QDKP2_ShowAllGuild = false
    end
  elseif todo=="on" then
    QDKP2_ShowAllGuild = true
    QDKP2frame2_guildCheckButton:SetChecked(1)
  elseif todo=="off" then
    QDKP2_ShowAllGuild = false
    QDKP2frame2_guildCheckButton:SetChecked(0)
  end
  
  QDKP2_Refresh_Roster("refresh")
  
end

function QDKP2_AutoBossEarnSet(todo)
  if todo == "toggle" then  
    if (QDKP2frame1_UseBossMod:GetChecked()==1) then
      QDKP2_AutoBossEarn = true
      QDKP2_Msg(QDKP2_COLOR_YELLOW.."Auto Boss Award enabled")
    else
      QDKP2_AutoBossEarn = false
      QDKP2_Msg(QDKP2_COLOR_YELLOW.."Auto Boss Award disabled")
    end
  elseif todo == "on" then
    QDKP2_AutoBossEarn = true
    QDKP2frame1_UseBossMod:SetChecked(1)
    QDKP2_Msg(QDKP2_COLOR_YELLOW.."Auto Boss Award enabled")
  elseif todo == "off" then
    QDKP2_AutoBossEarn = false
    QDKP2frame1_UseBossMod:SetChecked(0)
    QDKP2_Msg(QDKP2_COLOR_YELLOW.."Auto Boss Award disabled")
  end
end

function QDKP2_DetectBidSet(todo)
  if todo == "toggle" then  
    if (QDKP2frame1_DetectBids:GetChecked()==1) then
      QDKP2_DetectBidSet("on")
    else
      QDKP2_DetectBidSet("off")
    end
  elseif todo == "on" then
    QDKP2_DetectBids = true
    QDKP2frame1_DetectBids:SetChecked(1)
    QDKP2_Msg(QDKP2_COLOR_YELLOW.."Winner Detection enabled")
  elseif todo == "off" then
    QDKP2_DetectBids = false
    QDKP2frame1_DetectBids:SetChecked(0)
    QDKP2_Msg(QDKP2_COLOR_YELLOW.."Winner Detection disabled")
  end
end
------------------------------------SCROLL UP/DOWN-------------

--function moves the list up and down
function QDKP2_ScrollList(inc)
  local numEntries
  if(QDKP2_ShowAllGuild) then      --checks which list and ordinate it
    QDKP2name=QDKP2_SortList(QDKP2name)
    numEntries = table.getn(QDKP2name)
  else
    QDKP2raid=QDKP2_SortList(QDKP2raid)
    numEntries = table.getn(QDKP2raid)
  end
  if numEntries>0 then
    if(inc == "+")then
      QDKP2_ListIndex = QDKP2_ListIndex + 10
    elseif (inc == "-") then
      QDKP2_ListIndex = QDKP2_ListIndex - 10
    else
      QDKP2_ListIndex = QDKP2_ListIndex + inc
    end
  
    if QDKP2_ListIndex < 1 then QDKP2_ListIndex = 1; end
    if QDKP2_ListIndex > numEntries then QDKP2_ListIndex = numEntries; end

    QDKP2_Refresh_Roster("refresh")  -- refreshes the change
  end
end

function QDKP2_ScrollList_Log(inc)

  local numEntr = 1
  if QDKP2log[QDKP2log_show] then
    numEntr = table.getn(QDKP2log[QDKP2log_show])
  end

  if(inc == "+")then
    QDKP2_LogIndex = QDKP2_LogIndex + 10
  elseif (inc == "-") then
    QDKP2_LogIndex = QDKP2_LogIndex - 10
  elseif(inc == "top")then
    QDKP2_LogIndex = 1
  elseif(inc == "bottom")then
    if numEntr > 20 then
      QDKP2_LogIndex = numEntr - 10
    end
  else
    QDKP2_LogIndex = QDKP2_LogIndex + inc
  end

  if QDKP2_LogIndex < 1 then QDKP2_LogIndex = 1; end
  if QDKP2_LogIndex > numEntr then QDKP2_LogIndex = numEntr; end
  
  QDKP2_Refresh_Log("refresh")  -- refreshes the change
end
 

------------------------------------------REFRESHES---------

function QDKP2_RefreshAll()
  QDKP2_Refresh_Roster("refresh")
  QDKP2_Refresh_Log("refresh")
  QDKP2_Refresh_Toolbox("refresh")
  QDKP2_Refresh_ModifyPane("refresh")  
end

---------------------------------------

--Manages the roster window
--todo can be "show", "hide", "toggle" and "refresh"
function QDKP2_Refresh_Roster(todo)
  if todo=="show" then
   QDKP2_Toggle(2, true)
   QDKP2_Refresh_Roster("refresh")
  elseif todo=="hide" then
   QDKP2_FramesOpen[2]=false
   QDKP2_Frame2:Hide()
  elseif todo=="toggle" then
   if QDKP2_Frame2:IsVisible() then
     QDKP2_Refresh_Roster("hide")
   else
     QDKP2_Refresh_Roster("show")
   end
  elseif todo=="refresh" then
    if not QDKP2_Frame2:IsVisible() then return; end
    QDKP2_Debug(2, "Refresh","Refreshing Roster")
    local Complete=QDKP2_OfficerMode()
    local numEntries
    if(QDKP2_ShowAllGuild) then      --checks which list and sort it
      QDKP2name=QDKP2_SortList(QDKP2name)
      numEntries = table.getn(QDKP2name)
        else
      QDKP2raid=QDKP2_SortList(QDKP2raid)
      numEntries = table.getn(QDKP2raid)
    end
    
    for i=1, QDKP2_numFrame2entries do  --fills in the list data
      local indexAt = QDKP2_ListIndex-1+i  --minus one to offset the +i which is also indexed at 1
      
      local r    --sets the colors
      local g
      local b
      local a=1
      
      if((i>=6 and i<=10) or (i>=16 and i<=20) )then
        r=0
        g=1
        b=0
      else
        r=1
        g=1
        b=1
      end
      getglobal("QDKP2_frame2_entry"..i.."_name"):SetVertexColor(r, g, b, a)
      getglobal("QDKP2_frame2_entry"..i.."_rank"):SetVertexColor(r, g, b, a)
      getglobal("QDKP2_frame2_entry"..i.."_class"):SetVertexColor(r, g, b, a)
      --getglobal("QDKP2_frame2_entry"..i.."_net"):SetVertexColor(r, g, b, a)
      getglobal("QDKP2_frame2_entry"..i.."_total"):SetVertexColor(r, g, b, a)
      getglobal("QDKP2_frame2_entry"..i.."_spent"):SetVertexColor(r, g, b, a)
      getglobal("QDKP2_frame2_entry"..i.."_hours"):SetVertexColor(r, g, b, a)
      getglobal("QDKP2_frame2_entry"..i.."_deltatotal"):SetVertexColor(r, g, b, a)
      getglobal("QDKP2_frame2_entry"..i.."_deltaspent"):SetVertexColor(r, g, b, a)
      getglobal("QDKP2_frame2_entry"..i.."_deltahours"):SetVertexColor(r, g, b, a)
      
      if (indexAt <= numEntries) then
        
        local tempName 
        if(QDKP2_ShowAllGuild) then      --checks which list and ordinate it
          tempName=QDKP2name[indexAt]
        else
          tempName=QDKP2raid[indexAt]
        end

        local ModifyColor = false

	if QDKP2_USE_CLASS_BASED_COLORS and QDKP2class[tempName] then
		  local colors=RAID_CLASS_COLORS[string.upper(QDKP2class[tempName])]
		  if colors then
		    r=colors.r
		    g=colors.g
		    b=colors.b
		  else   --Class not readable
		    r=0.8
		    g=0.9
		    b=0.1
		end
		ModifyColor = true
	else
		if QDKP2_IsModified(tempName) then
		  r=0.27
		  g=0.92
		  b=1
		  ModifyColor = true
		elseif QDKP2_IsStandby(tempName) then
		  r=1
		  g=0.7
		  b=0
		  ModifyColor=true
		elseif QDKP2_IsAlt(tempName) then
		  r=1
		  g=0.3
		  b=1
		  ModifyColor = true
		elseif QDKP2_IsExternal(tempName) then
		  r=0.4
		  g=0.4
		  b=1
		  ModifyColor = true
		end
	        
        end
	
        if tempName == QDKP2_SelectedPlayer then
          a=0.7
          ModifyColor = true
        end
        
        if ModifyColor then
          getglobal("QDKP2_frame2_entry"..i.."_name"):SetVertexColor(r, g, b, a)
          getglobal("QDKP2_frame2_entry"..i.."_rank"):SetVertexColor(r, g, b, a)
          getglobal("QDKP2_frame2_entry"..i.."_class"):SetVertexColor(r, g, b, a)
          --getglobal("QDKP2_frame2_entry"..i.."_net"):SetVertexColor(r, g, b, a)
          getglobal("QDKP2_frame2_entry"..i.."_total"):SetVertexColor(r, g, b, a)
          getglobal("QDKP2_frame2_entry"..i.."_spent"):SetVertexColor(r, g, b, a)
          getglobal("QDKP2_frame2_entry"..i.."_hours"):SetVertexColor(r, g, b, a)
          getglobal("QDKP2_frame2_entry"..i.."_deltatotal"):SetVertexColor(r, g, b, a)
          getglobal("QDKP2_frame2_entry"..i.."_deltaspent"):SetVertexColor(r, g, b, a)
          getglobal("QDKP2_frame2_entry"..i.."_deltahours"):SetVertexColor(r, g, b, a)
        end
        
        
        getglobal("QDKP2_frame2_entry"..i.."_name"):SetText(QDKP2_GetName(tempName));
        getglobal("QDKP2_frame2_entry"..i.."_rank"):SetText(QDKP2rank[tempName]);
        getglobal("QDKP2_frame2_entry"..i.."_class"):SetText(QDKP2class[tempName]);
        --getglobal("QDKP2_frame2_entry"..i.."_net"):SetText(QDKP2_GetNet(tempName));
        getglobal("QDKP2_frame2_entry"..i.."_total"):SetText(QDKP2_GetTotal(tempName));
        getglobal("QDKP2_frame2_entry"..i.."_spent"):SetText(QDKP2_GetSpent(tempName));

	-- Modified entry for EPGP Ratio Display
        
        --if QDKP2_RATIO_RANK[QDKP2rank[tempName]] then 
            if QDKP2_GetSpent(tempName) ~= 0 then
                QDKP2ratio = QDKP2_GetTotal(tempName) / QDKP2_GetSpent(tempName);
            else
                QDKP2ratio = QDKP2_GetTotal(tempName);
            end
        --else    
            --QDKP2ratio = 0;
        --end

	
	getglobal("QDKP2_frame2_entry"..i.."_ratio"):SetJustifyH("RIGHT");
        getglobal("QDKP2_frame2_entry"..i.."_ratio"):SetText(string.format("%8.3f",QDKP2_GetPRRatio(tempName)));
            
        -- End of added entry for EPGP Ratio Display

        getglobal("QDKP2_frame2_entry"..i.."_hours"):SetText(QDKP2_GetHours(tempName));
        getglobal("QDKP2_frame2_entry"..i.."_deltatotal"):SetText(QDKP2_GetRaidGain(tempName));
        getglobal("QDKP2_frame2_entry"..i.."_deltaspent"):SetText(QDKP2_GetRaidSpent(tempName));
        getglobal("QDKP2_frame2_entry"..i.."_deltahours"):SetText(QDKP2_GetRaidTime(tempName));
        
        getglobal("QDKP2_frame2_entry"..i):Show();
      else
        getglobal("QDKP2_frame2_entry"..i):Hide();
      end
    end
    local totalsText = "Raid "..table.getn(QDKP2raid).." / Guild "..table.getn(QDKP2name)
    QDKP2_Frame2_totals:SetText(totalsText);
    if Complete then
      QDKP2frame2_newExternal:Show()
      QDKP2frame2_remExternal:Show()
      QDKP2frame2_newStandby:Show()
      QDKP2frame2_remStandby:Show()
      QDKP2frame2_postExternal:Show()
      QDKP2frame2_SetClearAlt:Show()
      QDKP2_Frame2_Externals:Show()
      QDKP2_Frame2_Standby:Show()
      QDKP2_Frame2_Alts:Show()
      --QDKP2frame2_showRaidLog:Hide()
    else
      QDKP2frame2_newExternal:Hide()
      QDKP2frame2_remExternal:Hide()
      QDKP2frame2_newStandby:Hide()
      QDKP2frame2_remStandby:Hide()
      QDKP2frame2_postExternal:Hide()
      QDKP2frame2_SetClearAlt:Hide()
      QDKP2_Frame2_Externals:Hide()
      QDKP2_Frame2_Standby:Hide()
      QDKP2_Frame2_Alts:Hide()
      --QDKP2frame2_showRaidLog:Show()
    end
    if QDKP2_SelectedPlayer~="" and QDKP2_IsExternal(QDKP2_SelectedPlayer) then
      QDKP2frame2_remExternal:Enable()
    else
      QDKP2frame2_remExternal:Disable()
    end
    if QDKP2_SelectedPlayer~="" and not QDKP2_IsInRaid(QDKP2_SelectedPlayer) then
      QDKP2frame2_newStandby:Enable()
    else
      QDKP2frame2_newStandby:Disable()
    end
    if QDKP2_SelectedPlayer~="" and QDKP2_IsStandby(QDKP2_SelectedPlayer) then
      QDKP2frame2_remStandby:Enable()
    else
      QDKP2frame2_remStandby:Disable()
    end
  end
end

--FRAME 3 & 4 (Toolbox)
--todo can be "show", "hide", "toggle" and "refresh".
--"show" (and "toggle" if opens) will refresh aswell.
--"show" only works for frame 3, "refresh" and "hide" for both.
function QDKP2_Refresh_Toolbox(todo)
  if todo=="show" then
   QDKP2_Toggle(3, true)
   QDKP2_Refresh_Log("refresh")
  elseif todo=="hide" then
   QDKP2_FramesOpen[3]=false
   QDKP2_FramesOpen[4]=false
   QDKP2_Frame3:Hide()
   QDKP2_Frame4:Hide()
  elseif todo=="toggle" then
   if QDKP2_Frame3:IsVisible() then
     QDKP2_Refresh_Log("hide")
   else
     QDKP2_Refresh_Log("show")
   end
  elseif todo=="refresh" then
    if not (QDKP2_Frame3:IsVisible() or QDKP2_Frame4:IsVisible()) then return; end
    if not QDKP2_ModifyPlayer or not QDKP2_IsInGuild(QDKP2_ModifyPlayer) then return; end
    QDKP2_Debug(2, "Refresh","Refreshing Toolbox")
    QDKP2_Frame3_Header:SetText(QDKP2_GetName(QDKP2_ModifyPlayer))
    --QDKP2frame3_dkp:SetText("")
    --QDKP2frame3_For:SetText("")
    QDKP2frame4_TotalBox:SetText(tostring(QDKP2_GetTotal(QDKP2_ModifyPlayer)))
    QDKP2frame4_NetBox:SetText(tostring(QDKP2_GetNet(QDKP2_ModifyPlayer)))
    QDKP2frame4_HoursBox:SetText(tostring(QDKP2_GetHours(QDKP2_ModifyPlayer)))
  end
end
  
  
--FRAME 5 (Log)
--Manages the Log
--todo can be "show", "hide", "toggle" and "refresh".
--"show" (and "toggle" if opens) will refresh aswell.
function QDKP2_Refresh_Log(todo)
  if not QDKP2log_show then return; end

  if todo=="show" then
   QDKP2_Toggle(5, true)
   QDKP2_Refresh_Log("refresh")
  elseif todo=="hide" then
   QDKP2_FramesOpen[5]=false
   QDKP2_Frame5:Hide()
  elseif todo=="toggle" then
   QDKP2_Toggle(5)
   if QDKP2_Frame5:IsVisible() then
     QDKP2_Refresh_Log("refresh")
    end
  elseif todo=="refresh" then
    if not QDKP2_Frame5:IsVisible() then return; end
    if not QDKP2log_show or (not QDKP2_IsInGuild(QDKP2log_show) and not QDKP2log_show=="RAID")  then return; end
    QDKP2_Debug(2, "Refresh","Refreshing Log")
    local Log = QDKP2log[QDKP2log_show]
    local NetAmounts, Changes=QDKP2log_GetNetAmounts(QDKP2log_show)
        --QDKP2_Msg(tostring(table.getn(Changes)).."; "..tostring(table.getn(Net)))

    if not Log then Log = {}; end
      
    local numEntries = table.getn(Log)
    
    for i=1, QDKP2_numFrame5entries do  --fills in the list data
      local indexAt = QDKP2_LogIndex-1+i  --minus one to offset the +i which is also indexed at 1
      
      local r    --sets the colors
      local g
      local b
      local a
      

      r=1
      g=0
      b=0
      a=1

      getglobal("QDKP2_frame5_entry"..i.."_date"):SetVertexColor(r, g, b, a)
      getglobal("QDKP2_frame5_entry"..i.."_net"):SetVertexColor(r, g, b, a)
      getglobal("QDKP2_frame5_entry"..i.."_mod"):SetVertexColor(r, g, b, a)
      getglobal("QDKP2_frame5_entry"..i.."_action"):SetVertexColor(r, g, b, a)
      
      if (indexAt <= numEntries) then
        local OriginalLog=Log[indexAt]
	local LogEntry = QDKP2_CheckLogLink(OriginalLog)
	local Change=Changes[indexAt]
	local Net=NetAmounts[indexAt]
        if not LogEntry then
          QDKP2_DeleteLogEntry(QDKP2log_show,indexAt)
          QDKP2_Refresh_Log("refresh")
          return
        end
	
	local  Type=QDKP2log_GetType(LogEntry)

        if Type==QDKP2LOG_CONFIRMED then
          r=0.3
          g=1
          b=0.3
          a=1
        elseif Type==QDKP2LOG_JOINED or Type==QDKP2LOG_LEAVED then
          r=1
          g=0.6
          b=0
          a=1
        elseif Type == QDKP2LOG_CRITICAL then
          r=1
          g=0.3
          b=0.3
          a=1
        elseif Type == QDKP2LOG_MODIFY then
          r=0.4
          g=1
          b=1
          a=1      
        elseif Type == QDKP2LOG_NEWSESSION then
          r=0.4
          g=0.4
          b=1
          a=1
        elseif Type == QDKP2LOG_LOST then
          r=0.5
          g=0.3
          b=0.5
          a=1
	elseif Type == QDKP2LOG_ABORTED then
          r=0.6
          g=0.6
          b=0.6
          a=1
        elseif Type == QDKP2LOG_LOOT then
          r=1
          g=1
          b=0
          a=1
        elseif Type == QDKP2LOG_EVENT or Type == QDKP2LOG_EXTERNAL or Type==QDKP2LOG_INVALID then
          r=1
          g=1
          b=1
          a=1
        elseif QDKP2_IsNODKPEntry(Type) then
          r=1
          g=0.5
          b=0.5
          a=1
        end
        
        if QDKP2_SelectedLogIndex == indexAt then
          a=0.7
        end
        
        getglobal("QDKP2_frame5_entry"..i.."_date"):SetVertexColor(r, g, b, a)
        getglobal("QDKP2_frame5_entry"..i.."_action"):SetVertexColor(r, g, b, a)
        if netto then
          if tonumber(Net) < 0 then
            r=1
            g=0.3
            b=0.3
            a=1
          end
        end
        
        getglobal("QDKP2_frame5_entry"..i.."_net"):SetVertexColor(r, g, b, a)
        
        if Change then
          if Type == QDKP2LOG_LOST or Type == QDKP2LOG_ABORTED then
            r=0.6
            g=0.6
            b=0.6
            a=1
          elseif tonumber(Change) > 0 then
            r=0
            g=1
            b=0
            a=1
          elseif tonumber(Change) < 0 then
            r=1
            g=0.3
            b=0.3
            a=1
          else
            r=1
            g=1
            b=1
            a=1
          end
        end
        getglobal("QDKP2_frame5_entry"..i.."_mod"):SetVertexColor(r, g, b, a)
        
        local datestring = QDKP2log_GetModEntryDateTime(LogEntry)
        
        getglobal("QDKP2_frame5_entry"..i.."_date"):SetText(datestring);
        if Net and not (QDKP2log_show=="RAID") then
          getglobal("QDKP2_frame5_entry"..i.."_net"):SetText(Net);
        else
          getglobal("QDKP2_frame5_entry"..i.."_net"):SetText("")
        end
        if Change and Change~=0 and not (QDKP2log_show=="RAID") then
          getglobal("QDKP2_frame5_entry"..i.."_mod"):SetText(Change);
        else
          getglobal("QDKP2_frame5_entry"..i.."_mod"):SetText("");
        end
        
        local description=QDKP2log_GetModEntryText(OriginalLog, QDKP2log_show)
        
        getglobal("QDKP2_frame5_entry"..i.."_action"):SetText(description);
        
        getglobal("QDKP2_frame5_entry"..i):Show();
      else
        getglobal("QDKP2_frame5_entry"..i):Hide();
      end
    end
    
    QDKP2_Frame5_Header:SetText(QDKP2log_show .. "'s Log")
    
    if QDKP2log[QDKP2log_show] then
      if QDKP2log[QDKP2log_show][QDKP2_SelectedLogIndex] then
        local SelectedType = QDKP2log_GetType(QDKP2log[QDKP2log_show][QDKP2_SelectedLogIndex])
      end
    end
  end
end

--FRAME 6 (The modify pane)
--Manages the Modify pane, the one that let you change the log's modify entries.
--todo can be "show", "hide", "toggle" and "refresh".
--"show" (and "toggle" if opens) will refresh aswell.

function QDKP2_Refresh_ModifyPane(todo)
  if todo=="show" then
   QDKP2_Toggle(6, true)
   QDKP2_Refresh_ModifyPane("refresh")
  elseif todo=="hide" then
   QDKP2_FramesOpen[6]=false
   QDKP2_Frame6:Hide()
  elseif todo=="toggle" then
   if QDKP2_Frame6:IsVisible() then
     QDKP2_Refresh_ModifyPane("hide")
   else
     QDKP2_Refresh_ModifyPane("show")
   end
  elseif todo=="refresh" and QDKP2_ModifyPlayer and QDKP2_SelectedLogIndex then
      if not QDKP2_Frame6:IsVisible() then return; end
      QDKP2_Debug(2, "Refresh","Refreshing Modify Pane")
      local LogList= QDKP2log[QDKP2_ModifyPlayer]
      if not LogList then return; end
      local Log=LogList[QDKP2_ModifyLog]
      if not Log then return; end
      local Undo=Log[QDKP2LOG_UNDO]
      if not Undo then return; end
      local gained = Undo[1]
      local spent = Undo[2]
      local hours = Undo[3]
      local reason = Log[QDKP2LOG_ACTION]
      local Type = QDKP2log_GetType(Log)
      local Subtype=Log[QDKP2LOG_SUBTYPE]
      
      QDKP2frame6_GainedBox:Show()
      QDKP2frame6_SpentBox:Show()
      QDKP2frame6_HoursBox:Show()
      QDKP2frame6_ReasonBox:Show()
      QDKP2frame6_gained:Show()
      QDKP2frame6_spent:Show()
      QDKP2frame6_hours:Show()
      QDKP2Frame6_Delete:Show()
      QDKP2Frame6_Set:Show()
      QDKP2Frame6_Activate:Hide()
      QDKP2Frame6_OpenMain:Hide()
      
      if gained then
        QDKP2frame6_GainedBox:SetText(gained)
      else
        QDKP2frame6_GainedBox:SetText("")
      end
      if spent then
        QDKP2frame6_SpentBox:SetText(spent)
      else
        QDKP2frame6_SpentBox:SetText("")
      end
      if hours then
        QDKP2frame6_HoursBox:SetText(hours)
      else
        QDKP2frame6_HoursBox:SetText("")
      end
      if reason then
        QDKP2frame6_ReasonBox:SetText(reason)
      else
        QDKP2frame6_ReasonBox:SetText("")
      end
      
      if Subtype==QDKP2LOG_RAIDAW or Subtype==QDKP2LOG_ZS or QDKP2_IsNODKPEntry(Type) then
        if hours and not gained then
	  QDKP2_Refresh_ModifyPane("hide")
	end
        QDKP2frame6_GainedBox:Hide()
        QDKP2frame6_SpentBox:Hide()
        QDKP2frame6_HoursBox:Hide()
        QDKP2frame6_ReasonBox:Hide()
        QDKP2frame6_gained:Hide()
        QDKP2frame6_spent:Hide()
	QDKP2frame6_hours:Hide()
        QDKP2Frame6_Delete:Hide()
        QDKP2Frame6_Set:Hide()
        QDKP2Frame6_Activate:Show()
        QDKP2Frame6_OpenMain:Show()
      end
      
      if Subtype==QDKP2LOG_RAIDAWMAIN then
	QDKP2frame6_SpentBox:Hide()
        QDKP2frame6_HoursBox:Hide()
        QDKP2frame6_spent:Hide()
	QDKP2frame6_hours:Hide()
      elseif Subtype==QDKP2LOG_ZSMAIN then
	QDKP2frame6_GainedBox:Hide()
        QDKP2frame6_HoursBox:Hide()
        QDKP2frame6_gained:Hide()
	QDKP2frame6_hours:Hide()
      end
      
      if QDKP2_IsNODKPEntry(Type) then
        QDKP2Frame6_Activate:SetText("Include")
      else
        QDKP2Frame6_Activate:SetText("Exclude")
      end
      
      if QDKP2_IsDeletedEntry(Type) then
        QDKP2Frame6_Delete:SetText("Activate Entry")
      elseif QDKP2_IsDKPEntry(Type) then
        QDKP2Frame6_Delete:SetText("Deactivate Entry")
      end
  end
end

-----------------------------------------ON CLICK--------

function QDKP2_OpenReport(arg1)
  local buttonName = this:GetName()
  local indexFromButton = 0
  
  local LogList = {}
  
  if QDKP2log[QDKP2_ModifyPlayer] then
    LogList = QDKP2log[QDKP2_ModifyPlayer]
  end
  
  for i=1, QDKP2_numFrame5entries do
    local button = "QDKP2_frame5_entry"..i
    if(buttonName==button) then
      indexFromButton = i
    end
  end
  local x,y = GetCursorPosition()
  QDKP2_ReportBox:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT" , x+100, y+45);
  QDKP2_ReportBox:Show()
  QDKP2_ReportName = QDKP2log_show
  QDKP2_ReportIndex = indexFromButton + QDKP2_LogIndex - 1
  QDKP2_SelectedLogIndex = QDKP2_ReportIndex
  QDKP2_Refresh_ModifyPane("hide")
  QDKP2_Refresh_Log("refresh")
end

function QDKP2_OpenLog(arg1)
  local buttonName = this:GetName()
  local indexFromButton = 0
  local tableList = QDKP2_RaidorGuildList()
  for i=1, QDKP2_numFrame2entries do
    local button = "QDKP2_frame2_entry"..i
    if(buttonName==button) then
      indexFromButton = i
    end
  end
  QDKP2_SelectedPlayerIndex = indexFromButton + QDKP2_ListIndex - 1  --index was off by 1 somehow
  local name = tableList[QDKP2_SelectedPlayerIndex]
  QDKP2_PopupLog(name)
  QDKP2_ChangeSelectPlayer(name)  
  QDKP2_Refresh_Roster("refresh")
end
  
--Called when a player is cicked
function QDKP2_Frame2_OnClick(arg1)
  if( getglobal("QDKP2_Frame3"):IsVisible() ) then
    --do nothing
  else
    QDKP2frame3_reasonBox:SetText("")
    QDKP2frame3_dkpBox:SetText("")
    QDKP2_Toggle(3, true)
  end

  local buttonName = this:GetName()
  local indexFromButton = 0
  local tableList = QDKP2_RaidorGuildList()
  
  for i=1, QDKP2_numFrame2entries do
    local button = "QDKP2_frame2_entry"..i
    if(buttonName==button) then
      indexFromButton = i
    end
  end
  
  QDKP2_SelectedPlayerIndex = indexFromButton + QDKP2_ListIndex - 1  --index was off by 1 somehow

  local name = tableList[QDKP2_SelectedPlayerIndex]
  QDKP2_ChangeSelectPlayer(name)
  QDKP2_Refresh_Roster("refresh")
  QDKP2_Refresh_Log("refresh")
end

function QDKP2_ChangeSelectPlayer(name)  
  if name=="RAID" then return; end	
  QDKP2_SelectedPlayer=name
  QDKP2_ModifyPlayer=name
  QDKP2_Refresh_Toolbox("refresh")
  if QDKP2log_show ~= name then
    local nameLog = QDKP2_GetMain(name)
    QDKP2log_show = nameLog
    QDKP2_LogIndex = 1
    QDKP2_SelectedLogIndex = -1
    QDKP2_ModifyLog=-1
    QDKP2_Refresh_ModifyPane("hide")
  end
end

function QDKP2Log_OnClick(arg1)

  local buttonName = this:GetName()
  local indexFromButton = 0
  
  for i=1, QDKP2_numFrame5entries do
    local button = "QDKP2_frame5_entry"..i
    if(buttonName==button) then
      indexFromButton = i
    end
  end
  
  local LogIndex = indexFromButton + QDKP2_LogIndex - 1  --index was off by 1 somehow
  QDKP2_ModifyPlayer=QDKP2log_show
  QDKP2_SelectedLogIndex = LogIndex
  QDKP2_LOG_SelectLogIndex(LogIndex)
end

    
--called when a log entry is clicked
function QDKP2_LOG_SelectLogIndex(LogIndex)
  QDKP2_ReportBox:Hide();
  QDKP2_Refresh_ModifyPane("hide")
  
  if QDKP2_LootToPay and QDKP2_Frame3:IsVisible() then
    QDKP2_ToggleOffAfter(3)
  end
  QDKP2_SetLootCharge(nil)
  
  if not LogIndex then
    QDKP2_SelectedLogIndex = nil
  else
  
    QDKP2_ModifyLog=LogIndex
    
    local LogList = QDKP2log[QDKP2_ModifyPlayer]
    local Log = LogList[LogIndex]
    local LogType = QDKP2log_GetType(Log)
    
    if LogType==QDKP2LOG_LINK then
      QDKP2_ModifyPlayer=QDKP2log_GetLinkedPlayer(Log)
      local LinkLogIndex=QDKP2_FindLogIndex(QDKP2log[QDKP2_ModifyPlayer],Log[QDKP2LOG_TIME])
      QDKP2_RefreshAll()
      QDKP2_LOG_SelectLogIndex(LinkLogIndex)
      return

    elseif (QDKP2_IsDKPEntry(LogType) or QDKP2_IsNODKPEntry(LogType)) and not (LogType==QDKP2LOG_LOST) then
      QDKP2_Refresh_ModifyPane("show")

    elseif LogType == QDKP2LOG_LOOT then
      
      local loot = Log[QDKP2LOG_ACTION]
      local name = QDKP2_ModifyPlayer
      
      QDKP2_ModifyPlayer = name
      QDKP2_Refresh_Toolbox("show")
      QDKP2_SetLootCharge(loot)
      
    elseif LogType == QDKP2LOG_NEWSESSION then
      local OldSessName=Log[QDKP2LOG_ACTION]
      QDKP2_OpenInputBox("Enter the new name of the session",QDKP2log_SetNewSessionName,Log)
      if OldSessName then
        QDKP2_InputBox_Data:SetText(OldSessName)
      else
        QDKP2_InputBox_Data:SetText("")
      end
    end  
  end
  
  QDKP2_Refresh_Roster("refresh")
  QDKP2_Refresh_Log("refresh")
  
end

----------------------------- MINIMAP BUTTON --------------------
  function QDKP2_MiniBtn_Click(arg1,arg2)
    QDKP2_Toggle_Main()
  end

  function QDKP2_MiniBtn_LabelOn(arg1,arg2)
    if this.Dragging then return; end
    GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT");
    GameTooltip:AddLine("Quick DKP "..tostring(QDKP2_VERSION))
    GameTooltip:AddLine("CLICK: Show/Hide QDKP",.8,.8,.8,1)
    GameTooltip:AddLine("SHIFT+CLICK: Drag this button",.8,.8,.8,1)
    GameTooltip:Show()
  end
	
  function QDKP2_MiniBtn_LabelOff(arg1,arg2)
    GameTooltip:Hide()
  end
  
  function QDKP2_MiniBtn_DragOn(arg1,arg2)
  if IsShiftKeyDown()then
    this.Dragging = true;
    QDKP2_MiniBtn_LabelOff();
  end
  end
  
  function QDKP2_MiniBtn_DragOff(arg1,arg2)
    this:StopMovingOrSizing();
    this.Dragging = nil;
    this.Moving = nil;
  end
  
  function QDKP2_MiniBtn_Press(arg1,arg2)
    QDKP2_MiniBtnIcon:SetTexCoord(-0.05,0.95,-0.05,0.95)
  end
  
  function QDKP2_MiniBtn_Release(arg1,arg2)
    QDKP2_MiniBtnIcon:SetTexCoord(0,1,0,1)
  end
  
 function QDKP2_MiniBtn_Update(arg1,arg2)
  if not this.Dragging then
    return;
  end
  local MapScale = Minimap:GetEffectiveScale();
  local CX, CY = GetCursorPosition();
  local X, Y = (Minimap:GetRight() - 70) * MapScale, (Minimap:GetTop() - 70) * MapScale;
  local Dist = sqrt(math.pow(X - CX, 2) + math.pow(Y - CY, 2)) / MapScale;
  local Scale = this:GetEffectiveScale();
  if(Dist <= 90)then
    if this.Moving then
      this:StopMovingOrSizing();
      this.Moving = nil;
    end
    local Angle = atan2(CY - Y, X - CX) - 90;
    this:ClearAllPoints();
    this:SetPoint("CENTER", Minimap, "TOPRIGHT", (sin(Angle) * 80 - 70) * MapScale / Scale, (cos(Angle) * 77 - 73) * MapScale / Scale);
    
  elseif not this.Moving then
    this:ClearAllPoints();
    this:SetPoint("CENTER", UIParent, "BOTTOMLEFT",CX / Scale, CY / Scale);
    this:StartMoving();
    this.Moving = true;
  end
end

------------------------------------------Frame1---------

--Allows for the up and down arrows to work on frame 1  "+" = up, "-" = down... duh

function QDKP2_frame1_DownloadData()
  QDKP2_NewSession("")
end

function QDKP2_frame1_dkpAwardRaidSet(todo)
  if not todo then
    QDKP2_dkpAwardRaid = 0
  elseif todo=="+" then
    QDKP2_dkpAwardRaid = QDKP2_dkpAwardRaid + 1
  elseif todo=="-" then
    QDKP2_dkpAwardRaid = QDKP2_dkpAwardRaid - 1
  else
    QDKP2_dkpAwardRaid = todo
  end
  --64:SetText(QDKP2_dkpAwardRaid)
  QDKP2_RaidDKPBox:SetText(QDKP2_dkpAwardRaid)
end

--increases and decreases the value of the DKP per hr
function QDKP2_frame1_dkpPerHourSet(todo)
  if not todo then
    QDKP2_dkpPerHour = 0
  elseif todo=="+" then
    QDKP2_dkpPerHour = QDKP2_dkpPerHour + 1
  elseif todo=="-" then
    QDKP2_dkpPerHour = QDKP2_dkpPerHour - 1
  else
    QDKP2_dkpPerHour = todo
  end
  QDKP2frame1_dkpBox_perhr_text:SetText(QDKP2_dkpPerHour)
end

---------------------------------------

--gives awards DKP
function QDKP2_frame1_award()
  local mess = "Write the reason of the award\n(leave blank for none)"
  QDKP2_OpenInputBox(mess,QDKP2_GUI_GiveRaidDKP)
end

function QDKP2_GUI_GiveRaidDKP(reason)
  --local dkpIncrease = QDKP2frame1_dkpBox_text:GetText()
  local dkpIncrease = QDKP2_RaidDKPBox:GetText()
  QDKP2_GiveRaidDKP(dkpIncrease,reason)
end


---------------------------------------

--givs Ironman Bonus
function QDKP2_frame1_ironman(Sure)

  if QDKP2frame1_ironman:GetText()=="Start" then
    QDKP2_IronManStart()
    local mess="Do you also want to start a new session?"
    QDKP2_AskUserConf(mess, QDKP2_NewSession, "")
  else
    --local BonusDKP = tonumber(QDKP2frame1_dkpBox_text:GetText())
    local BonusDKP = tonumber(QDKP2_RaidDKPBox:GetText())
    
    if BonusDKP == 0 then
      if not Sure then
        local mess = "The Raid Bonus is set to 0.\n Do you want to discard IronMan data?"
        QDKP2_AskUserConf(mess, QDKP2_frame1_ironman, true)
        return
      end
      QDKP2_Msg("IronMan data discarded")
      QDKP2_IronManWipe()
    else
      if not Sure then
        --local mess = "Close the IronMan bonus and\n award to the winners "..QDKP2frame1_dkpBox_text:GetText().." DKP?"
	local mess = "Close the IronMan bonus and\n award to the winners "..QDKP2_RaidDKPBox:GetText().." DKP?"
        QDKP2_AskUserConf(mess, QDKP2_frame1_ironman, true)
        return
      end
      QDKP2_InronManFinish(BonusDKP)
    end
    if QDKP2_TimerBase then
      local mess = "The Raid Timer is still active.\n Do you want to turn it off?"
      QDKP2_AskUserConf(mess,QDKP2_TimerOff)
    end
  end
end
---------------------------------------

--toggles the off/on button for the timer
function QDKP2_frame1_offOnToggle(todo)
  local frame = getglobal("QDKP2_frame1_onOff")
  if(frame:GetText()=="OFF")then
    QDKP2_TimerOff()
  else
    QDKP2_TimerOn()
  end
end

----------------------------------------FRAME 2 ------------

--Sorts by name
function QDKP2_frame2_sort_by_name()

  QDKP2_Order="Alpha"

  QDKP2_Refresh_Roster("refresh")
end

--sorts by class and net
function QDKP2_frame2_sort_by_class()

  QDKP2_Order="Class"

  QDKP2_Refresh_Roster("refresh")
end

--sorts by rank and name
function QDKP2_frame2_sort_by_rank()

  QDKP2_Order="Rank"

  QDKP2_Refresh_Roster("refresh")
  
end

--sort by net
function QDKP2_frame2_sort_by_net()
  
  QDKP2_Order = "Net"
  
  QDKP2_Refresh_Roster("refresh")
  
end

-- sort by priority
function QDKP2_frame2_sort_by_priority()
  
  QDKP2_Order = "Priority"
  
  QDKP2_Refresh_Roster("refresh")
  
end

-- sort by Hours
function QDKP2_frame2_sort_by_hours()
  
  QDKP2_Order = "Hours"
  
  QDKP2_Refresh_Roster("refresh")
  
end

-- sort by ep
function QDKP2_frame2_sort_by_ep()
  
  QDKP2_Order = "EP"
  
  QDKP2_Refresh_Roster("refresh")
  
end

-- sort by gp
function QDKP2_frame2_sort_by_gp()
  
  QDKP2_Order = "GP"
  
  QDKP2_Refresh_Roster("refresh")
  
end

--Externals Managing
function QDKP2_AddExternal(name)
  if not name then
    local mess = "Enter the name of the External Member"
    QDKP2_OpenInputBox(mess, QDKP2_AddExternal)
    return
  end
  name=QDKP2_FormatName(name)
  if QDKP2_IsInGuild(name) then QDKP2_Msg(QDKP2_COLOR_RED..'The given player is already in the guild')
  else
    QDKP2_NewExternal(QDKP2_FormatName(name))
    QDKP2_DownloadGuild(nil,false)  
    QDKP2_UpdateRaid() 
    QDKP2_Refresh_Roster("refresh")
  end
end

function QDKP2_RemExternal(sure)
  if not QDKP2_SelectedPlayer then return; end
  if not QDKP2_IsExternal(QDKP2_SelectedPlayer) then return; end
  if not sure then
    local mess = "Really remove ".. QDKP2_SelectedPlayer .. "\nfrom Guild Roster?"
    QDKP2_AskUserConf(mess, QDKP2_RemExternal, QDKP2_SelectedPlayer, true)
    return
  end
  QDKP2_DelExternal(QDKP2_SelectedPlayer)
  QDKP2_DownloadGuild(nil,false)
  QDKP2_UpdateRaid() 
  QDKP2_Refresh_Roster("refresh")
end

--Standby

--Alts
function QDKP2_SetClearAlt(main,sure1,sure2)
  if not QDKP2_SelectedPlayer or QDKP2_SelectedPlayer=="" then return; end
  if not sure1 then
    local mess="Enter the name of the Main Character\n(Leave blank to clear the Alt status)"
    QDKP2_OpenInputBox(mess, QDKP2_SetClearAlt,true)
    return
  end
  if not main then 
    QDKP2_AltsRestore[QDKP2_SelectedPlayer]=""
    local alts=ListFromDict(QDKP2_Alts)
    local newalts={}
    for i=1, table.getn(alts) do
      if not (QDKP2_SelectedPlayer==alts[i]) then
	newalts[alts[i]]=QDKP2_Alts[alts[i]]
      end
      QDKP2_Alts=newalts
    end
  else
    main=QDKP2_FormatName(main)
    if not QDKP2_IsInGuild(main) then
      QDKP2_Msg(QDKP2_COLOR_RED..main.." is not a valid Guildmember name.")
      return
    end
    if main==QDKP2_SelectedPlayer then
      QDKP2_Msg(QDKP2_COLOR_RED.."An alt's Main must be different from the alt himself.")
      return
    end
    if QDKP2_Alts[main] then
      QDKP2_Msg(QDKP2_COLOR_RED.."You can't define an alt as a Main.")
      return  
    end
    if not sure2 and not QDKP2_Alts[QDKP2_SelectedPlayer] then
      local mess="Are you sure you want to set\n "..QDKP2_SelectedPlayer.." as an Alt?\nHis DKP amounts will be erased."
      QDKP2_AskUserConf(mess, QDKP2_SetClearAlt, main, true,true)
      return
    end
    QDKP2_AltsRestore[QDKP2_SelectedPlayer]=main
  end
  QDKP2_DownloadGuild(nil,false)
  QDKP2_Refresh_Toolbox("refresh")
  QDKP2_Refresh_Roster("refresh")
  QDKP2_Msg("Upload Changes to store the modifications.")
end
----------------------------------------FRAME 3 ------------



function QDKP2_PopupTB(name)
  QDKP2_ChangeSelectPlayer(name)
  QDKP2_Toggle(3,true)
end
  
--Modifies info in pane 2 from pane 3
function QDKP2_frame3_awardspend(inctype,Sure)
  local list = QDKP2_RaidorGuildList()
  local name = QDKP2_ModifyPlayer
  
  local change = QDKP2frame3_dkpBox:GetText()
  
  if string.sub(change, strlen(change))=="%" then
    local perc = tonumber(string.sub(change, 1, strlen(change)-1))
    if perc then
      if (inctype=="-") then
	  change=QDKP2_GetSpent(name)*perc/100    -- GP
      elseif (inctype=="+") then
	  change=QDKP2_GetTotal(name)*perc/100	  -- EP
      end
      --change=QDKP2_GetNet(name)*perc/100
    end
  end
  
  change=tonumber(change)
  
  if not change or change == 0 then return; end
  
  local loot = QDKP2_LootToPay
  
  local reason = QDKP2frame3_reasonBox:GetText()
  if reason == "" then reason = nil; end
  if(inctype=="+") then
    if loot and not Sure then
      local mess = "Really Give DKP for the\n loot of an object?"
      QDKP2_AskUserConf(mess, QDKP2_frame3_awardspend, "+", true)
      return
    end
    if loot then
      QDKP2_PayLoot(name, -change, loot)
    else
      QDKP2_PlayerGains(name,change, reason)
    end
    
  elseif(inctype=="-")then
    if loot then 
      QDKP2_PayLoot(name, change, loot)
    else
      QDKP2_PlayerSpends(name,change, reason)
    end
  
  elseif inctype=="zs" then
    if loot then 
      QDKP2_PayLoot(name, change, loot, true)
    else
      QDKP2_ZeroSum(name, change , reason)
    end
  end
  
  

  QDKP2frame4_TotalBox:SetText(QDKP2_GetTotal(name))
  QDKP2frame4_NetBox:SetText(QDKP2_GetNet(name))
  
  QDKP2_Refresh_Roster("refresh")
  QDKP2_Refresh_Log("refresh")
  
  if loot then
    QDKP2_ToggleOffAfter(3)
    QDKP2_SetLootCharge(nil)
  end
end

function QDKP2_frame3_ResetChanges(Sure)
  local name = QDKP2_ModifyPlayer
  if not Sure then
    local mess = "Do you want to reset "..name.."'s\n counters, download the values in officer\n notes and start a new session for him?"
    QDKP2_AskUserConf(mess,QDKP2_frame3_ResetChanges,true)
  else
    name=QDKP2_GetMain(name)
    QDKP2_StopCheck()
    QDKP2_ResetPlayer(name)
  end
end
---------------------------------------

function QDKP2_SetDKPbox(Value)
  QDKP2frame3_dkpBox:SetText(Value)
end

function QDKP2_SetLootCharge(item)
  if QDKP2_LootToPay or item then
    if not item then
      QDKP2frame3_reasonBox:SetText("")
    else
      QDKP2frame3_reasonBox:SetText(item)
    end
    QDKP2_LootToPay = item
    QDKP2_CancelFirstOnChange=true
  end
end
  

function QDKP2_Frame3_OnEnter()
          if QDKP2_LootToPay then
	    if QDKP2_CHARGEWITHZS  then
	      QDKP2_frame3_awardspend("zs")
	   else
	     QDKP2_frame3_awardspend("-")
	  end
	end
end
  
--QDKP2_OpenToolboxForCharge
--Opens the toolbox to charge a player for a loot. all parameters are optionals
--usage f([name],[amount],[item]) 
--name=valid name of a player in guild
--amount=the amount of DKP to charge to the player
--item=The reason of the charge (e.g. item link)

function QDKP2_OpenToolboxForCharge(name,amount,item) 
  if QDKP2_Frame3:IsVisible() then
    --do nothing
  else
    QDKP2_Toggle(3, true)
  end
  if name then
    QDKP2_ChangeSelectPlayer(name) 
    QDKP2_Frame3_Header:SetText(QDKP2_GetName(name))
    QDKP2frame4_TotalBox:SetText(tostring(QDKP2_GetTotal(name)))
    QDKP2frame4_NetBox:SetText(tostring(QDKP2_GetNet(name)))
    QDKP2frame4_HoursBox:SetText(tostring(QDKP2_GetHours(name)))
  end
  if item then
    QDKP2_SetLootCharge(item)
  end
  if amount then
    Chronos.schedule(0.01,QDKP2_SetDKPbox,amount)
  else
    Chronos.schedule(0.01,QDKP2_SetDKPbox,"")
  end
end
    
    


---------------------------------------

--notifies the selected target
function QDKP2_frame3_notifyTarget(SendReport)   
  local list = QDKP2_RaidorGuildList()
  local name = QDKP2_ModifyPlayer
  QDKP2_Notify(name)
  if SendReport == nil then
    local mess = "Do you want to report also\n the log of the last session?"
    QDKP2_AskUserConf(mess,QDKP2_MakeAndSendReport, name ,"Session", 1,"WHISPER",name)
  end
end

----------------------------------------FRAME 4 ------------

--sets data from frame 4
function QDKP2_frame4_setinfo()
  local net = getglobal("QDKP2frame4_NetBox"):GetText()
  local total = getglobal("QDKP2frame4_TotalBox"):GetText()
  local hours = getglobal("QDKP2frame4_HoursBox"):GetText()
  local tableList = QDKP2_RaidorGuildList()
  
  local name = QDKP2_ModifyPlayer
  
  if net=="" then net = nil; else net = tonumber(net); end
  if total=="" then total = nil; else total = tonumber(total); end
  if hours=="" then hours = nil; else hours = tonumber(hours); end
  
  local DTotal = total - QDKP2_GetTotal(name)
  local DSpent = total - net - QDKP2_GetSpent(name)
  local DHours = hours - QDKP2_GetHours(name)
  
  QDKP2_AddTotals(name, DTotal, DSpent, DHours, "Manual edit", nil, true)
  
  QDKP2_Refresh_Roster("refresh")
  QDKP2_Refresh_Log("refresh")
  
end




---------------------------------------

--gives selected player 1 hour
function QDKP2_frame4_give1hour()
  local list = QDKP2_RaidorGuildList()
  local name = QDKP2_ModifyPlayer
  QDKP2_AddTotals(name, nil, nil, 1, nil, true, false)
  
  QDKP2frame4_HoursBox:SetText(QDKP2_GetHours(name))
  QDKP2_StopCheck()
  
  QDKP2_Refresh_Roster("refresh")
  QDKP2_Refresh_Log("refresh")
end

---------------------------------------Frame Utility---------------

--Figures out which list is needed and is returned
function QDKP2_RaidorGuildList()
  local tableList
  if(QDKP2_ShowAllGuild) then  --checks which list is toggled
    tableList = QDKP2name
  else
    tableList = QDKP2raid
  end
  return tableList
end

--------------------------------------Frame 5---------------------------------

function QDKP2_PopupLog(name)

  local usedName
  
  if name then usedName = name
  else usedName = QDKP2_SelectedPlayer
  end

  usedName=QDKP2_GetMain(usedName)
  
  if usedName == QDKP2log_show then
    QDKP2_Refresh_Log("toggle")
    return
  end
  
  QDKP2_ChangeSelectPlayer(usedName)
  QDKP2log_show = usedName
  QDKP2_LogIndex = 1
  QDKP2_Refresh_Log("show")
  QDKP2_Refresh_ModifyPane("hide")
  QDKP2_Refresh_Roster("refresh")
  
end

function QDKP2_ChangeReportType(reportType)
  local checkName = this:GetName()
  for i=1,7 do
    local toCheck = "QDKP2frame2_ReportType"..i
    if toCheck == checkName then
      getglobal(toCheck):SetChecked(true)
    else
      getglobal(toCheck):SetChecked(false)
    end
  end
  QDKP2_ReportType = reportType
end

function QDKP2_ChangeReportChannel(reportChannel)
  local checkName = this:GetName()
  for i=1,6 do
    local toCheck = "QDKP2frame2_ReportChannel"..i
    if toCheck == checkName then
      getglobal(toCheck):SetChecked(true)
    else
      getglobal(toCheck):SetChecked(false)
    end
  end
  QDKP2_ReportChannel = reportChannel
end

function QDKP2_ReportGo()
  if QDKP2_ReportType and QDKP2_ReportChannel then
    QDKP2_ReportBox:Hide()
    QDKP2_MakeAndSendReport(QDKP2_ReportName,QDKP2_ReportType,QDKP2_ReportIndex,QDKP2_ReportChannel)
  end
end
----------------------------------------------- Frame 6 -----------------------------------
-- This will delete (undo) the selected log entry
function QDKP2_frame6_UnDo()
  local Type = QDKP2log_GetType(QDKP2log[QDKP2_ModifyPlayer][QDKP2_ModifyLog])
  local onoff  
  if QDKP2_IsDeletedEntry(Type) then
    onoff = "on"
  else
    onoff = "off"
  end
  QDKP2_LOG_UnDoEntry(QDKP2_ModifyPlayer,QDKP2_ModifyLog,onoff)
  QDKP2_Refresh_Roster("refresh")
  QDKP2_Refresh_Log("refresh")
  QDKP2_Refresh_ModifyPane("refresh")
end


function QDKP2_frame6_ActivateDeactivate(sure)
  local Log=QDKP2log[QDKP2_ModifyPlayer][QDKP2_ModifyLog]
  local Type=QDKP2log_GetType(Log)
  local Subtype=Log[QDKP2LOG_SUBTYPE]
  local MainName
  if Subtype==QDKP2LOG_RAIDAW then MainName="RAID"
  elseif Subtype==QDKP2LOG_ZS then MainName=QDKP2log_GetLinkedPlayer(Log)
  end
  if Log[QDKP2LOG_UNDO][3] and not Log[QDKP2LOG_UNDO][1] then
   return
  else
    local MainIndex=QDKP2_FindLogIndex(QDKP2log[MainName],Log[QDKP2LOG_TIME])
    local MainType=QDKP2log_GetType(QDKP2log[MainName][MainIndex])
    if QDKP2_IsNODKPEntry(Type) then
      if not sure then
        QDKP2_AskUserConf("\nDo you want to award\n  "..QDKP2_ModifyPlayer.." anyway?", QDKP2_frame6_ActivateDeactivate, true)
        return
      end
      Log[QDKP2LOG_TYPE]=QDKP2LOG_ABORTED
      if MainType~=QDKP2LOG_ABORTED then
        QDKP2_LOG_UnDoEntry(QDKP2_ModifyPlayer,QDKP2_ModifyLog,"on")
      end
    else
      QDKP2_LOG_UnDoEntry(QDKP2_ModifyPlayer,QDKP2_ModifyLog,"off")
      Log[QDKP2LOG_TYPE]=QDKP2LOG_NODKP
    end
    if Subtype==QDKP2LOG_ZS then
      QDKP2_ZeroSum_Update(MainName,MainIndex)
    end
  end
  QDKP2_Refresh_Log("refresh")
  QDKP2_Refresh_Roster("refresh")
  QDKP2_Refresh_ModifyPane("refresh")
end
  
function QDKP2_frame6_OpenMain()
  local Log=QDKP2log[QDKP2_ModifyPlayer][QDKP2_ModifyLog]
  local Subtype=Log[QDKP2LOG_SUBTYPE]
  local MainIndex
  if Subtype==QDKP2LOG_RAIDAW then
    QDKP2_ModifyPlayer="RAID"
  elseif Subtype==QDKP2LOG_ZS then
    QDKP2_ModifyPlayer=QDKP2log_GetLinkedPlayer(Log)
  end
  
  MainIndex=QDKP2_FindLogIndex(QDKP2log[QDKP2_ModifyPlayer],Log[QDKP2LOG_TIME])
  
  QDKP2_ModifyLog=MainIndex
  
  QDKP2_Refresh_ModifyPane("refresh")
  QDKP2_Refresh_Toolbox("hide")
end

function QDKP2_frame6_setEntry()
    local gained = tonumber(QDKP2frame6_GainedBox:GetText())
    local spent = tonumber(QDKP2frame6_SpentBox:GetText())
    local hours = tonumber(QDKP2frame6_HoursBox:GetText())
    local reason = (QDKP2frame6_ReasonBox:GetText())
    local Log=QDKP2log[QDKP2_ModifyPlayer][QDKP2_ModifyLog]
    if Log[QDKP2LOG_SUBTYPE]==QDKP2LOG_RAIDAWMAIN and (not gained or gained==0) then return; end
    if Log[QDKP2LOG_SUBTYPE]==QDKP2LOG_ZSMAIN and  (not spent  or spent==0) then return; end
   
    local oldreason = Log[QDKP2LOG_ACTION]
    local oldtime =Log[QDKP2LOG_TIME]
    QDKP2_SetLogEntry(QDKP2_ModifyPlayer,QDKP2_ModifyLog,gained,spent,hours,reason)
  QDKP2_Refresh_Log("refresh")
  QDKP2_Refresh_Roster("refresh")
  QDKP2_Refresh_ModifyPane("refresh")
end


----------------------------------------------- VAR ----------------------------

function QDKP2_OpenInputBox(text,func,arg2,arg3,arg4,arg5)

  QDKP2_InputBox_text:SetText(text)
  QDKP2_InputBox_Data:SetText("")
  QDKP2_InputBox_Data:SetFocus()
  QDKP2_InputBox:Show()
  QDKP2_InputBox_func=func
  QDKP2_InputBox_arg2=arg2
  QDKP2_InputBox_arg3=arg3
  QDKP2_InputBox_arg4=arg4
  QDKP2_InputBox_arg5=arg5
end

function QDKP2_InputBox_OnEnter()
  QDKP2_InputBox:Hide()
  local data=QDKP2_InputBox_Data:GetText()
  if data == "" then data = nil; end
  QDKP2_InputBox_func(data,QDKP2_InputBox_arg2,QDKP2_InputBox_arg3,QDKP2_InputBox_arg4,QDKP2_InputBox_arg5)
end



function QDKP2_AskUserConf(text,func,arg1,arg2,arg3,arg4,arg5)
  
  QDKP2_WarningBox_text:SetText(text)  
  QDKP2_WarningBox:Show()
  QDKP2_WarningBox_func=func
  QDKP2_WarningBox_arg1=arg1
  QDKP2_WarningBox_arg2=arg2
  QDKP2_WarningBox_arg3=arg3
  QDKP2_WarningBox_arg4=arg4  
  QDKP2_WarningBox_arg5=arg5 
end

function QDKP2_AskUserConf_OnEnter(PressedYes)
  QDKP2_WarningBox:Hide()
  if PressedYes then
    QDKP2_WarningBox_func(QDKP2_WarningBox_arg1, QDKP2_WarningBox_arg2, QDKP2_WarningBox_arg3, QDKP2_WarningBox_arg4, QDKP2_WarningBox_arg5)
  end
end
  
