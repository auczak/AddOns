-- **************************************************************************
-- * TitanClock.lua
-- *
-- * By: TitanMod, Dark Imakuni, Adsertor and the Titan Development Team
-- *     (HonorGoG, jaketodd422, joejanko, Lothayer, Tristanian)
-- **************************************************************************

-- ******************************** Constants *******************************
TITAN_CLOCK_ID = "Clock";
TITAN_CLOCK_FORMAT_12H = "12H";
TITAN_CLOCK_FORMAT_24H = "24H";
TITAN_CLOCK_FREQUENCY = 1;
TITAN_CLOCK_FRAME_SHOW_TIME = 0.5;

-- ******************************** Variables *******************************

-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelClockButton_OnLoad()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TitanPanelClockButton_OnLoad()
     this.registry = {
          id = TITAN_CLOCK_ID,
          builtIn = 1,
          version = TITAN_VERSION,
          menuText = TITAN_CLOCK_MENU_TEXT, 
          buttonTextFunction = "TitanPanelClockButton_GetButtonText",
          tooltipTitle = TITAN_CLOCK_TOOLTIP, 
          tooltipTextFunction = "TitanPanelClockButton_GetTooltipText",
          savedVariables = {
               OffsetHour = 0,
               Format = TITAN_CLOCK_FORMAT_12H,
               DisplayOnRightSide = 1,
          }
     };
end

-- **************************************************************************
-- NAME : TitanPanelClockButton_OnShow()
-- DESC : Create repeating timer when plugin is visible
-- **************************************************************************
function TitanPanelClockButton_OnShow()
     local hasTimer = TitanPanel:HasTimer("TitanPanel"..TITAN_CLOCK_ID)
     if (hasTimer) then
          --do nothing
     else
          TitanPanel:AddRepeatingTimer("TitanPanel"..TITAN_CLOCK_ID, 1, TitanPanelPluginHandle_OnUpdate, TITAN_CLOCK_ID, TITAN_PANEL_UPDATE_BUTTON)
     end
end

-- **************************************************************************
-- NAME : TitanPanelClockButton_OnHide()
-- DESC : Destroy repeating timer when plugin is hidden
-- **************************************************************************
function TitanPanelClockButton_OnHide()
     local hasTimer = TitanPanel:HasTimer("TitanPanel"..TITAN_CLOCK_ID)
     if (hasTimer) then
          TitanPanel:RemoveTimer("TitanPanel"..TITAN_CLOCK_ID)
     end
end

-- **************************************************************************
-- NAME : TitanPanelClockButton_GetButtonText()
-- DESC : Display time on button based on set variables
-- **************************************************************************
function TitanPanelClockButton_GetButtonText()
     -- Calculate the hour/minutes considering the offset
     local hour, minute = GetGameTime();
     local twentyfour = "";
     local offsettime = string.format("%s", TitanGetVar(TITAN_CLOCK_ID, "OffsetHour"));
     local offsethour = 0;
     local offsetmin = 0;
     local s, e, id = string.find(offsettime, '%.5');

     if (s ~= nil) then
          offsethour = string.sub(offsettime, 1, s);
          offsetmin = string.sub(offsettime, s+1);
          if offsetmin == "" or offsetmin == nil then offsetmin = "0"; end
          if offsethour == "" or offsethour == nil then offsethour = "0"; end
     
          offsethour = tonumber(offsethour);

          if (tonumber(offsettime) < 0) then offsetmin = tonumber("-" .. offsetmin); end
                    
          minute = minute + (offsetmin*6);

          if (minute > 59) then
               minute = minute - 30;
               offsethour = offsethour + 1;
          elseif (minute < 0) then
               minute = 60 + minute;
               offsethour = offsethour - 1;
          end
     else
          offsethour = TitanGetVar(TITAN_CLOCK_ID, "OffsetHour");
     end
     hour = hour + offsethour;
     
     if (hour > 23) then
          hour = hour - 24;
     elseif (hour < 0) then
          hour = 24 + hour;
     end

     -- Calculate the display text based on format 12H/24H 
     if (TitanGetVar(TITAN_CLOCK_ID, "Format") == TITAN_CLOCK_FORMAT_12H) then
          local isAM;
          if (hour >= 12) then
               isAM = false;
               hour = hour - 12;
          else
               isAM = true;
          end
          if (hour == 0) then
               hour = 12;
          end
          if (isAM) then
               return nil, format(TEXT(TIME_TWELVEHOURAM), hour, minute);
          else
               return nil, format(TEXT(TIME_TWELVEHOURPM), hour, minute);
          end
     else
          twentyfour = format(TEXT(TIME_TWENTYFOURHOURS), hour, minute);
          if (hour < 10) then
               twentyfour = "0" .. twentyfour
          end
     
          return nil, twentyfour;
     end
     
end

-- **************************************************************************
-- NAME : TitanPanelClockButton_GetTooltipText()
-- DESC : Display tooltip text
-- **************************************************************************
function TitanPanelClockButton_GetTooltipText()
     local clockText = TitanPanelClock_GetOffsetText(TitanGetVar(TITAN_CLOCK_ID, "OffsetHour"));     
     return ""..
          TITAN_CLOCK_TOOLTIP_VALUE.."\t"..TitanUtils_GetHighlightText(clockText).."\n"..
          TitanUtils_GetGreenText(TITAN_CLOCK_TOOLTIP_HINT1).."\n"..
          TitanUtils_GetGreenText(TITAN_CLOCK_TOOLTIP_HINT2);
end

-- **************************************************************************
-- NAME : TitanPanelClockControlSlider_OnEnter()
-- DESC : Display slider tooltip
-- **************************************************************************
function TitanPanelClockControlSlider_OnEnter()
     this.tooltipText = TitanOptionSlider_TooltipText(TITAN_CLOCK_CONTROL_TOOLTIP, TitanPanelClock_GetOffsetText(TitanGetVar(TITAN_CLOCK_ID, "OffsetHour")));
     GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
     GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
     TitanUtils_StopFrameCounting(this:GetParent());
end

-- **************************************************************************
-- NAME : TitanPanelClockControlSlider_OnLeave()
-- DESC : Hide slider tooltip
-- **************************************************************************
function TitanPanelClockControlSlider_OnLeave()
     this.tooltipText = nil;
     GameTooltip:Hide();
     TitanUtils_StartFrameCounting(this:GetParent(), TITAN_CLOCK_FRAME_SHOW_TIME);
end

-- **************************************************************************
-- NAME : TitanPanelClockControlSlider_OnShow()
-- DESC : Display slider tooltip options
-- **************************************************************************
function TitanPanelClockControlSlider_OnShow()
     getglobal(this:GetName().."Text"):SetText(TitanPanelClock_GetOffsetText(TitanGetVar(TITAN_CLOCK_ID, "OffsetHour")));
     getglobal(this:GetName().."High"):SetText(TITAN_CLOCK_CONTROL_LOW);
     getglobal(this:GetName().."Low"):SetText(TITAN_CLOCK_CONTROL_HIGH);
     this:SetMinMaxValues(-12, 12);
     this:SetValueStep(0.5);
     this:SetValue(0 - TitanGetVar(TITAN_CLOCK_ID, "OffsetHour"));

     position = TitanUtils_GetRealPosition(TITAN_CLOCK_ID);
     
     TitanPanelClockControlFrame:SetPoint("BOTTOMRIGHT", "TitanPanel" .. TitanUtils_GetWhichBar(TITAN_CLOCK_ID) .."Button", "TOPRIGHT", 0, 0);
     if (position == TITAN_PANEL_PLACE_TOP) then 
          TitanPanelClockControlFrame:ClearAllPoints();
          TitanPanelClockControlFrame:SetPoint("TOPLEFT", "TitanPanel" .. TitanUtils_GetWhichBar(TITAN_CLOCK_ID) .."Button", "BOTTOMLEFT", UIParent:GetRight() - TitanPanelClockControlFrame:GetWidth(), -4);
     else
          TitanPanelClockControlFrame:ClearAllPoints();
          TitanPanelClockControlFrame:SetPoint("BOTTOMLEFT", "TitanPanel" .. TitanUtils_GetWhichBar(TITAN_CLOCK_ID) .."Button", "TOPLEFT", UIParent:GetRight() - TitanPanelClockControlFrame:GetWidth(), 0);
     end          

end

-- **************************************************************************
-- NAME : TitanPanelClockControlSlider_OnValueChanged(arg1)
-- DESC : Display slider tooltip text
-- VARS : arg1 = positive or negative change to apply
-- **************************************************************************
function TitanPanelClockControlSlider_OnValueChanged(arg1)
     getglobal(this:GetName().."Text"):SetText(TitanPanelClock_GetOffsetText(0 - this:GetValue()));
     local tempval = this:GetValue();
     
     if arg1 == -1 then
          this:SetValue(tempval + 0.5);
     end
     
     if arg1 == 1 then
          this:SetValue(tempval - 0.5);
     end
     
     TitanSetVar(TITAN_CLOCK_ID, "OffsetHour", 0 - this:GetValue());
     local realmName = GetCVar("realmName");
     if ( ServerTimeOffsets[realmName] ) then
          ServerTimeOffsets[realmName] = TitanGetVar(TITAN_CLOCK_ID, "OffsetHour");
     end
     TitanPanelButton_UpdateButton(TITAN_CLOCK_ID);

     -- Update GameTooltip
     if (this.tooltipText) then
          this.tooltipText = TitanOptionSlider_TooltipText(TITAN_CLOCK_CONTROL_TOOLTIP, TitanPanelClock_GetOffsetText(TitanGetVar(TITAN_CLOCK_ID, "OffsetHour")));
          GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
     end
end

-- **************************************************************************
-- NAME : TitanPanelClockControlCheckButton_OnShow() 
-- DESC : Define clock hour options
-- **************************************************************************
function TitanPanelClockControlCheckButton_OnShow()     
     TitanPanelClockControlCheckButtonText:SetText(TITAN_CLOCK_CHECKBUTTON);
     
     if (TitanGetVar(TITAN_CLOCK_ID, "Format") == TITAN_CLOCK_FORMAT_24H) then
          this:SetChecked(1);
     else
          this:SetChecked(0);
     end
end

-- **************************************************************************
-- NAME : TitanPanelClockControlCheckButton_OnClick()
-- DESC : Toggle clock hour option
-- **************************************************************************
function TitanPanelClockControlCheckButton_OnClick()
     if (this:GetChecked()) then
          TitanSetVar(TITAN_CLOCK_ID, "Format", TITAN_CLOCK_FORMAT_24H);
     else
          TitanSetVar(TITAN_CLOCK_ID, "Format", TITAN_CLOCK_FORMAT_12H);
     end
     local realmName = GetCVar("realmName");
     if ( ServerHourFormat[realmName] ) then
          ServerHourFormat[realmName] = TitanGetVar(TITAN_CLOCK_ID, "Format");
     end

     TitanPanelButton_UpdateButton(TITAN_CLOCK_ID);
end

-- **************************************************************************
-- NAME : TitanPanelClockControlCheckButton_OnEnter()
-- DESC : Display clock hour option tooltip
-- **************************************************************************
function TitanPanelClockControlCheckButton_OnEnter()
     this.tooltipText = TITAN_CLOCK_CHECKBUTTON_TOOLTIP;
     GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
     GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
     TitanUtils_StopFrameCounting(this:GetParent());
end

-- **************************************************************************
-- NAME : TitanPanelClockControlCheckButton_OnLeave()
-- DESC : Hide clock hour option tooltip
-- **************************************************************************
function TitanPanelClockControlCheckButton_OnLeave()
     this.tooltipText = nil;
     GameTooltip:Hide();
     TitanUtils_StartFrameCounting(this:GetParent(), TITAN_CLOCK_FRAME_SHOW_TIME);
end

-- **************************************************************************
-- NAME : TitanPanelClock_GetOffsetText(offset)
-- DESC : Get hour offset value and return
-- VARS : offset = hour offset from server time
-- **************************************************************************
function TitanPanelClock_GetOffsetText(offset)
     if (offset > 0) then
          return "+" .. tostring(offset);
     else
          return tostring(offset);
     end
end

-- **************************************************************************
-- NAME : TitanPanelClockControlFrame_OnLoad()
-- DESC : Create clock option frame
-- **************************************************************************
function TitanPanelClockControlFrame_OnLoad()
     getglobal(this:GetName().."Title"):SetText(TITAN_CLOCK_CONTROL_TITLE);
     this:SetBackdropBorderColor(1, 1, 1);
     this:SetBackdropColor(0, 0, 0, 1);
end

-- **************************************************************************
-- NAME : TitanPanelClockControlFrame_OnUpdate(elapsed)
-- DESC : If dropdown is visible, see if its timer has expired.  If so, hide frame
-- VARS : elapsed = <research>
-- **************************************************************************
function TitanPanelClockControlFrame_OnUpdate(elapsed)
     TitanUtils_CheckFrameCounting(this, elapsed);
end

-- **************************************************************************
-- NAME : TitanPanelRightClickMenu_PrepareClockMenu()
-- DESC : Generate clock right click menu options
-- **************************************************************************
function TitanPanelRightClickMenu_PrepareClockMenu()
     TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_CLOCK_ID].menuText);
     
     info = {};
     info.text = TITAN_CLOCK_MENU_DISPLAY_ON_RIGHT_SIDE;
     info.func = TitanPanelClockButton_ToggleRightSideDisplay;
     info.checked = TitanGetVar(TITAN_CLOCK_ID, "DisplayOnRightSide");
     UIDropDownMenu_AddButton(info);

     TitanPanelRightClickMenu_AddSpacer();     
     TitanPanelRightClickMenu_AddCommand(TITAN_PANEL_MENU_HIDE, TITAN_CLOCK_ID, TITAN_PANEL_MENU_FUNC_HIDE);
end

-- **************************************************************************
-- NAME : TitanPanelClockButton_ToggleRightSideDisplay()
-- DESC : Add clock button to bar
-- **************************************************************************
function TitanPanelClockButton_ToggleRightSideDisplay()
     TitanToggleVar(TITAN_CLOCK_ID, "DisplayOnRightSide");
     TITAN_PANEL_SELECTED = TitanUtils_GetWhichBar(TITAN_CLOCK_ID);
     TitanPanel_RemoveButton(TITAN_CLOCK_ID);
     --TitanDebug(TITAN_PANEL_SELECTED);
     TitanPanel_AddButton(TITAN_CLOCK_ID);
     -- TitanPanelButton_UpdateButton(TITAN_BAG_ID);
end