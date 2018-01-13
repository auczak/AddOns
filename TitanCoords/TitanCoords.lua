-- **************************************************************************
-- * TitanCoords.lua
-- *
-- * By: TitanMod, Dark Imakuni, Adsertor and the Titan Development Team
-- *     (HonorGoG, jaketodd422, joejanko, Lothayer, Tristanian)
-- **************************************************************************

-- ******************************** Constants *******************************
TITAN_COORDS_ID = "Coords";
local OFFSET_X = 0.0022;
local OFFSET_Y = -0.0262;

-- ******************************** Variables *******************************

-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelCoordsButton_OnLoad()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TitanPanelCoordsButton_OnLoad()
     this.registry = { 
          id = TITAN_COORDS_ID,
          builtIn = 1,
          version = TITAN_VERSION,
          menuText = TITAN_COORDS_MENU_TEXT, 
          buttonTextFunction = "TitanPanelCoordsButton_GetButtonText",
          tooltipTitle = TITAN_COORDS_TOOLTIP, 
          tooltipTextFunction = "TitanPanelCoordsButton_GetTooltipText",
          icon = TITAN_ARTWORK_PATH.."TitanCoords",     
          iconWidth = 16,
          savedVariables = {
               ShowZoneText = 1,
               ShowCoordsOnMap = 1,
               ShowIcon = 1,
               ShowLabelText = 1,
               ShowColoredText = 1,
               CoordsFormat1 = 1,
               CoordsFormat2 = TITAN_NIL,
               CoordsFormat3 = TITAN_NIL
          }
     };

     this:RegisterEvent("ZONE_CHANGED");
     this:RegisterEvent("ZONE_CHANGED_INDOORS");
     this:RegisterEvent("ZONE_CHANGED_NEW_AREA");
     this:RegisterEvent("MINIMAP_ZONE_CHANGED");
     this:RegisterEvent("PLAYER_ENTERING_WORLD");
end

-- **************************************************************************
-- NAME : TitanPanelCoordsButton_OnShow()
-- DESC : Display button when plugin is visible
-- **************************************************************************
function TitanPanelCoordsButton_OnShow()
	SetMapToCurrentZone();
	TitanPanelCoords_HandleUpdater();
end

-- **************************************************************************
-- NAME : TitanPanelCoordsButton_OnHide()
-- DESC : Destroy repeating timer when plugin is hidden
-- **************************************************************************
function TitanPanelCoordsButton_OnHide()
	local hasTimer = TitanPanel:HasTimer("TitanPanel"..TITAN_COORDS_ID)
	if hasTimer then
		TitanPanel:RemoveTimer("TitanPanel"..TITAN_COORDS_ID)
	end
end

-- **************************************************************************
-- NAME : TitanPanelCoordsButton_GetButtonText(id)
-- DESC : Calculate coordinates and then display data on button
-- VARS : id = button ID
-- **************************************************************************
function TitanPanelCoordsButton_GetButtonText(id)
     local button, id = TitanUtils_GetButton(id, true);

     button.px, button.py = GetPlayerMapPosition("player");
     local locationText;
     if (TitanGetVar(TITAN_COORDS_ID, "CoordsFormat1")) then     
         locationText = format(TITAN_COORDS_FORMAT, 100 * button.px, 100 * button.py);
     elseif (TitanGetVar(TITAN_COORDS_ID, "CoordsFormat2")) then
         locationText = format(TITAN_COORDS_FORMAT2, 100 * button.px, 100 * button.py);
     elseif (TitanGetVar(TITAN_COORDS_ID, "CoordsFormat3")) then
         locationText = format(TITAN_COORDS_FORMAT3, 100 * button.px, 100 * button.py);
     end
     if (TitanGetVar(TITAN_COORDS_ID, "ShowZoneText")) then     
          if (TitanUtils_ToString(button.subZoneText) == '') then
               locationText = TitanUtils_ToString(button.zoneText)..' '..locationText;
          else
               locationText = TitanUtils_ToString(button.subZoneText)..' '..locationText;
          end
     end

     local locationRichText;
     if (TitanGetVar(TITAN_COORDS_ID, "ShowColoredText")) then     
          if (TitanPanelCoordsButton.isArena) then
               locationRichText = TitanUtils_GetRedText(locationText);          
          elseif (TitanPanelCoordsButton.pvpType == "friendly") then
               locationRichText = TitanUtils_GetGreenText(locationText);
          elseif (TitanPanelCoordsButton.pvpType == "hostile") then
               locationRichText = TitanUtils_GetRedText(locationText);
          elseif (TitanPanelCoordsButton.pvpType == "contested") then
               locationRichText = TitanUtils_GetNormalText(locationText);
          else
               locationRichText = TitanUtils_GetNormalText(locationText);
          end
     else
          locationRichText = TitanUtils_GetHighlightText(locationText);
     end

     return TITAN_COORDS_BUTTON_LABEL, locationRichText;
end

-- **************************************************************************
-- NAME : TitanPanelCoordsButton_GetTooltipText()
-- DESC : Display tooltip text
-- **************************************************************************
function TitanPanelCoordsButton_GetTooltipText()
     local pvpInfoRichText;

     pvpInfoRichText = "";
     if (this.pvpType == "sanctuary") then
          pvpInfoRichText = TitanUtils_GetGreenText(SANCTUARY_TERRITORY);
     elseif (this.pvpType == "arena") then
          this.subZoneText = TitanUtils_GetRedText(this.subZoneText);
          pvpInfoRichText = TitanUtils_GetRedText(CONTESTED_TERRITORY);
     elseif (this.pvpType == "friendly") then
          pvpInfoRichText = TitanUtils_GetGreenText(format(FACTION_CONTROLLED_TERRITORY, this.factionName));
     elseif (this.pvpType == "hostile") then
          pvpInfoRichText = TitanUtils_GetRedText(format(FACTION_CONTROLLED_TERRITORY, this.factionName));
     elseif (this.pvpType == "contested") then
          pvpInfoRichText = TitanUtils_GetRedText(CONTESTED_TERRITORY);
     else
          --pvpInfoRichText = TitanUtils_GetNormalText(CONTESTED_TERRITORY);
     end

     return ""..
          TITAN_COORDS_TOOLTIP_ZONE.."\t"..TitanUtils_GetHighlightText(this.zoneText).."\n"..
          TitanUtils_Ternary((this.subZoneText == ""), "", TITAN_COORDS_TOOLTIP_SUBZONE.."\t"..TitanUtils_GetHighlightText(this.subZoneText).."\n")..          
          TitanUtils_Ternary((pvpInfoRichText == ""), "", TITAN_COORDS_TOOLTIP_PVPINFO.."\t"..pvpInfoRichText.."\n")..
          "\n"..
          TitanUtils_GetHighlightText(TITAN_COORDS_TOOLTIP_HOMELOCATION).."\n"..
          TITAN_COORDS_TOOLTIP_INN.."\t"..TitanUtils_GetHighlightText(GetBindLocation()).."\n"..
          TitanUtils_GetGreenText(TITAN_COORDS_TOOLTIP_HINTS_1).."\n"..
          TitanUtils_GetGreenText(TITAN_COORDS_TOOLTIP_HINTS_2);
end

-- **************************************************************************
-- NAME : TitanPanelCoordsButton_OnEvent()
-- DESC : Parse events registered to plugin and act on them
-- **************************************************************************
function TitanPanelCoordsButton_OnEvent()
     if (event == "ZONE_CHANGED_NEW_AREA") then
          SetMapToCurrentZone();
     end
     TitanPanelCoordsButton_UpdateZoneInfo();
     TitanPanelButton_UpdateButton(TITAN_COORDS_ID);
     TitanPanelButton_UpdateTooltip();
     TitanPanelCoords_HandleUpdater();
end

-- **************************************************************************
-- NAME : TitanPanelCoords_HandleUpdater()
-- DESC : Check to see if you are inside an instance
-- **************************************************************************
function TitanPanelCoords_HandleUpdater()
	local hasTimer = TitanPanel:HasTimer("TitanPanel"..TITAN_COORDS_ID)
	local inInstance, instanceType = IsInInstance();

 	if inInstance and instanceType ~= "pvp" then --player is in an instance, so destroy timer if it exists
		if hasTimer then
			TitanPanel:RemoveTimer("TitanPanel"..TITAN_COORDS_ID)
		end
	else
		if hasTimer then
		-- do nothing as the timer is already in place and updating
		elseif TitanPanelCoordsButton:IsVisible() then
		TitanPanel:AddRepeatingTimer("TitanPanel"..TITAN_COORDS_ID, 1, TitanPanelPluginHandle_OnUpdate, TITAN_COORDS_ID, TITAN_PANEL_UPDATE_BUTTON);
		end
	end

end

-- **************************************************************************
-- NAME : TitanPanelCoordsButton_OnClick(button)
-- DESC : Copies coordinates to chat line for shift-LeftClick
-- VARS : button = value of action
-- **************************************************************************
function TitanPanelCoordsButton_OnClick(button)
     if (button == "LeftButton" and IsShiftKeyDown()) then
          if (ChatFrameEditBox:IsVisible()) then
             if (TitanGetVar(TITAN_COORDS_ID, "CoordsFormat1")) then
                 message = TitanUtils_ToString(this.zoneText).." "..
                    format(TITAN_COORDS_FORMAT, 100 * this.px, 100 * this.py);
             elseif (TitanGetVar(TITAN_COORDS_ID, "CoordsFormat2")) then
                 message = TitanUtils_ToString(this.zoneText).." "..
                    format(TITAN_COORDS_FORMAT2, 100 * this.px, 100 * this.py);
             elseif (TitanGetVar(TITAN_COORDS_ID, "CoordsFormat3")) then
                 message = TitanUtils_ToString(this.zoneText).." "..
                    format(TITAN_COORDS_FORMAT3, 100 * this.px, 100 * this.py);
             end
               ChatFrameEditBox:Insert(message);
          end
     end
end

-- **************************************************************************
-- NAME : TitanPanelCoordsButton_UpdateZoneInfo()
-- DESC : Update data on button
-- **************************************************************************
function TitanPanelCoordsButton_UpdateZoneInfo()
     this.zoneText = GetZoneText();
     this.subZoneText = GetSubZoneText();
     this.minimapZoneText = GetMinimapZoneText();
     this.pvpType, _, this.factionName = GetZonePVPInfo();
end

-- **************************************************************************
-- NAME : TitanPanelRightClickMenu_PrepareCoordsMenu()
-- DESC : Display rightclick menu options
-- **************************************************************************
function TitanPanelRightClickMenu_PrepareCoordsMenu()
     TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_COORDS_ID].menuText);
     
     local info = {};
     info.text = TITAN_COORDS_MENU_SHOW_ZONE_ON_PANEL_TEXT;
     info.func = TitanPanelCoordsButton_ToggleDisplay;
     info.checked = TitanGetVar(TITAN_COORDS_ID, "ShowZoneText");
     UIDropDownMenu_AddButton(info);

     info = {};
     info.text = TITAN_COORDS_MENU_SHOW_COORDS_ON_MAP_TEXT;
     info.func = TitanPanelCoordsButton_ToggleCoordsOnMap;
     info.checked = TitanGetVar(TITAN_COORDS_ID, "ShowCoordsOnMap");
     UIDropDownMenu_AddButton(info);
     
     TitanPanelRightClickMenu_AddSpacer();
     
		 TitanPanelRightClickMenu_AddTitle(TITAN_COORDS_FORMAT_COORD_LABEL);
		 
		 info = {};
		 info.text = TITAN_COORDS_FORMAT_LABEL;
     info.func = function()
     TitanSetVar(TITAN_COORDS_ID, "CoordsFormat1", 1);
     TitanSetVar(TITAN_COORDS_ID, "CoordsFormat2", nil);
     TitanSetVar(TITAN_COORDS_ID, "CoordsFormat3", nil);
     end
     info.checked = TitanGetVar(TITAN_COORDS_ID, "CoordsFormat1");
     UIDropDownMenu_AddButton(info);
     
     info = {};
		 info.text = TITAN_COORDS_FORMAT2_LABEL;
     info.func = function()
     TitanSetVar(TITAN_COORDS_ID, "CoordsFormat1", nil);
     TitanSetVar(TITAN_COORDS_ID, "CoordsFormat2", 1);
     TitanSetVar(TITAN_COORDS_ID, "CoordsFormat3", nil);
     end
     info.checked = TitanGetVar(TITAN_COORDS_ID, "CoordsFormat2");
     UIDropDownMenu_AddButton(info);
     
     info = {};
		 info.text = TITAN_COORDS_FORMAT3_LABEL;
     info.func = function()
     TitanSetVar(TITAN_COORDS_ID, "CoordsFormat1", nil);
     TitanSetVar(TITAN_COORDS_ID, "CoordsFormat2", nil);
     TitanSetVar(TITAN_COORDS_ID, "CoordsFormat3", 1);
     end
     info.checked = TitanGetVar(TITAN_COORDS_ID, "CoordsFormat3");
     UIDropDownMenu_AddButton(info);

     TitanPanelRightClickMenu_AddSpacer();
     TitanPanelRightClickMenu_AddToggleIcon(TITAN_COORDS_ID);
     TitanPanelRightClickMenu_AddToggleLabelText(TITAN_COORDS_ID);
     TitanPanelRightClickMenu_AddToggleColoredText(TITAN_COORDS_ID);


     TitanPanelRightClickMenu_AddSpacer();
     TitanPanelRightClickMenu_AddCommand(TITAN_PANEL_MENU_HIDE, TITAN_COORDS_ID, TITAN_PANEL_MENU_FUNC_HIDE);
end

-- **************************************************************************
-- NAME : TitanPanelCoordsButton_ToggleDisplay()
-- DESC : Set option to show zone text
-- **************************************************************************
function TitanPanelCoordsButton_ToggleDisplay()
     TitanToggleVar(TITAN_COORDS_ID, "ShowZoneText");
     TitanPanelButton_UpdateButton(TITAN_COORDS_ID);     
end

-- **************************************************************************
-- NAME : TitanPanelCoordsButton_ToggleCoordsOnMap()
-- DESC : Set option to show coordinates on map
-- **************************************************************************
function TitanPanelCoordsButton_ToggleCoordsOnMap()
     TitanToggleVar(TITAN_COORDS_ID, "ShowCoordsOnMap");
     if (TitanGetVar(TITAN_COORDS_ID, "ShowCoordsOnMap")) then
          TitanMapCursorCoords:Show();
          TitanMapPlayerCoords:Show();
     else
          TitanMapCursorCoords:Hide();
          TitanMapPlayerCoords:Hide();
     end
end

-- **************************************************************************
-- NAME : TitanPanelCoordsButton_ToggleColor()
-- DESC : Set option to show colored text
-- **************************************************************************
function TitanPanelCoordsButton_ToggleColor()
     TitanToggleVar(TITAN_COORDS_ID, "ShowColoredText");
     TitanPanelButton_UpdateButton(TITAN_COORDS_ID);
end

-- **************************************************************************
-- NAME : TitanMapFrame_OnUpdate()
-- DESC : Update coordinates on map
-- **************************************************************************
function TitanMapFrame_OnUpdate()
  if not (TitanGetVar(TITAN_COORDS_ID, "ShowCoordsOnMap")) then
  return;
  end
     if (TitanGetVar(TITAN_COORDS_ID, "ShowCoordsOnMap")) then
          local x, y = GetCursorPosition();
          x = x / WorldMapFrame:GetScale();
          y = y / WorldMapFrame:GetScale();
     
          this.px, this.py = GetPlayerMapPosition("player");
          local centerX, centerY = WorldMapFrame:GetCenter();
          local width = WorldMapButton:GetWidth();
          local height = WorldMapButton:GetHeight();
          local adjustedX = (x - (centerX - (width/2))) / width;
          local adjustedY = (centerY + (height/2) - y ) / height;
          local cx = (adjustedX + OFFSET_X);
          local cy = (adjustedY + OFFSET_Y);
     
          local cursorCoordsText = format(TITAN_COORDS_MAP_COORDS_TEXT, 100 * cx, 100 * cy);
          local playerCoordsText = format(TITAN_COORDS_MAP_COORDS_TEXT, 100 * this.px, 100 * this.py);               
          TitanMapCursorCoords:SetText(format(TITAN_COORDS_MAP_CURSOR_COORDS_TEXT, TitanUtils_GetHighlightText(cursorCoordsText)));
          TitanMapPlayerCoords:SetText(format(TITAN_COORDS_MAP_PLAYER_COORDS_TEXT, TitanUtils_GetHighlightText(playerCoordsText)));
     end
end
