TITAN_PANEL_ICON_SPACING = 4;
TITAN_PANEL_BUTTON_WIDTH_CHANGE_TOLERANCE = 10;
--TITAN_PANEL_INITIAL_PLUGINS = {"Coords", "XP", "LootType", "Clock", "Volume", "UIScale", "Trans", "AutoHide", "Bag", "GoldTracker", "AuxAutoHide", "Repair", "ItemBonuses"};
TITAN_PANEL_INITIAL_PLUGINS = {"Coords", "XP", "GoldTracker", "Clock", "Volume", "UIScale", "Trans", "AutoHide", "Bag", "AuxAutoHide", "Repair"};
--TITAN_PANEL_INITIAL_PLUGIN_LOCATION = {"Bar", "Bar", "Bar", "Bar", "Bar", "Bar", "Bar", "Bar", "AuxBar", "AuxBar", "AuxBar", "AuxBar", "AuxBar"};
TITAN_PANEL_INITIAL_PLUGIN_LOCATION = {"Bar", "Bar", "Bar", "Bar", "Bar", "Bar", "Bar", "Bar", "Bar", "AuxBar", "Bar"};

TITAN_PANEL_BUTTONS_PLUGIN_CATEGORY = {"General","Combat","Information","Interface","Profession"}
TITAN_PANEL_BUTTONS_ALIGN_LEFT = 1;
TITAN_PANEL_BUTTONS_ALIGN_CENTER = 2;
TITAN_PANEL_BUTTONS_ALIGN_RIGHT = 3;

TITAN_PANEL_BARS_SINGLE = 1;
TITAN_PANEL_BARS_DOUBLE = 2;

TITAN_PANEL_BUTTONS_INIT_FLAG = nil;
TITAN_PANEL_SELECTED = "Bar";

TITAN_PANEL_FROM_TOP = -25;
TITAN_PANEL_FROM_BOTTOM = 25;
TITAN_PANEL_FROM_BOTTOM_MAIN = 1;
TITAN_PANEL_FROM_TOP_MAIN = 1;

TITAN_PANEL_MOVE_ADDON = nil;
TITAN_PANEL_DROPOFF_ADDON = nil;
TITAN_PANEL_NEXT_ADDON = nil;
TITAN_PANEL_MOVING = 0;

TitanPanel_ButtonAdded = false; -- this may be removed soon
local TitanKillAutoHidetimer = false;

-- Register Titan Panel with RockTimer-1.0
TitanPanel = Rock:NewAddon("TitanPanel", "LibRockTimer-1.0")

TITAN_PANEL_SAVED_VARIABLES = {
	Buttons = TITAN_PANEL_INITIAL_PLUGINS,
	Location = TITAN_PANEL_INITIAL_PLUGIN_LOCATION,
	TexturePath = "Interface\\AddOns\\Titan\\Artwork\\",
	Transparency = 0.7,
	AuxTransparency = 0.7,
	Scale = 1,
	ButtonSpacing = 20,
	TooltipTrans = 1,
	TooltipFont = 1,
	DisableTooltipFont = 1,
	ScreenAdjust = TITAN_NIL,
	LogAdjust = TITAN_NIL,
	MinimapAdjust = TITAN_NIL,
	AutoHide = TITAN_NIL,
	Position = TITAN_PANEL_PLACE_TOP,
	DoubleBar = TITAN_PANEL_BARS_SINGLE,
	ButtonAlign = TITAN_PANEL_BUTTONS_ALIGN_LEFT,
	BothBars = TITAN_NIL,
	AuxScreenAdjust = TITAN_NIL,
	AuxAutoHide = TITAN_NIL,
	AuxDoubleBar = TITAN_PANEL_BARS_SINGLE,
	AuxButtonAlign = TITAN_PANEL_BUTTONS_ALIGN_LEFT,
	LockButtons = TITAN_NIL,
	VersionShown = 1,
	ToolTipsShown = 1,
	HideTipsInCombat = TITAN_NIL,
	CastingBar = TITAN_NIL
};

function TitanPanelBarButton_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_REGEN_DISABLED");
	this:RegisterEvent("PLAYER_REGEN_ENABLED");
	this:RegisterEvent("CVAR_UPDATE");
	this:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	
--register slash commands for Titan Panel
 SlashCmdList["TitanPanel"] = TitanPanel_RegisterSlashCmd;
 SLASH_TitanPanel1 = "/titanpanel";
 SLASH_TitanPanel2 = "/titan";
end

--function to handle slash commands
function TitanPanel_RegisterSlashCmd(cmd)
  if (string.lower(cmd) == "reset") then
  TitanPanel_ResetBar();
  return;
  end
  if (string.lower(cmd) == "reset tipfont") then
  TitanPanelSetVar("TooltipFont", 1);
  GameTooltip:SetScale(TitanPanelGetVar("TooltipFont"));
  DEFAULT_CHAT_FRAME:AddMessage(TITAN_PANEL_SLASH_RESP1);
  return;
  end
  if (string.lower(cmd) == "reset tipalpha") then
  TitanPanelSetVar("TooltipTrans", 1);
  local red, green, blue, _ = GameTooltip:GetBackdropColor();
	local red2, green2, blue2, _ = GameTooltip:GetBackdropBorderColor();
	GameTooltip:SetBackdropColor(red,green,blue,TitanPanelGetVar("TooltipTrans"));
	GameTooltip:SetBackdropBorderColor(red2,green2,blue2,TitanPanelGetVar("TooltipTrans"));
	DEFAULT_CHAT_FRAME:AddMessage(TITAN_PANEL_SLASH_RESP2);
  return;
  end
  if (string.lower(cmd) == "reset panelscale") then
  TitanPanelSetVar("Scale", 1);
  
  -- Adjust panel scale
		TitanPanel_SetScale();
		TitanPanel_RefreshPanelButtons();
		
		-- Adjust frame positions
		TitanMovableFrame_MoveFrames(position);
		TitanMovableFrame_AdjustBlizzardFrames();
		
		DEFAULT_CHAT_FRAME:AddMessage(TITAN_PANEL_SLASH_RESP3);
  return;
  end
  if (string.lower(cmd) == "reset spacing") then
  TitanPanelSetVar("ButtonSpacing", 20);
  TitanPanel_InitPanelButtons();
  DEFAULT_CHAT_FRAME:AddMessage(TITAN_PANEL_SLASH_RESP4);
  return;
  end
  --display help text on slash commands
   DEFAULT_CHAT_FRAME:AddMessage(LIGHTYELLOW_FONT_COLOR_CODE..TITAN_PANEL.." ("..GREEN_FONT_COLOR_CODE..TITAN_VERSION.." "..TITAN_PANEL_REVISION..LIGHTYELLOW_FONT_COLOR_CODE..")"..TITAN_PANEL_VERSION_INFO);
   DEFAULT_CHAT_FRAME:AddMessage(TITAN_PANEL_SLASH_STRING2);
   DEFAULT_CHAT_FRAME:AddMessage(TITAN_PANEL_SLASH_STRING3);
   DEFAULT_CHAT_FRAME:AddMessage(TITAN_PANEL_SLASH_STRING4);
   DEFAULT_CHAT_FRAME:AddMessage(TITAN_PANEL_SLASH_STRING5);
   DEFAULT_CHAT_FRAME:AddMessage(TITAN_PANEL_SLASH_STRING6);
   DEFAULT_CHAT_FRAME:AddMessage(TITAN_PANEL_SLASH_STRING7);
   DEFAULT_CHAT_FRAME:AddMessage(TITAN_PANEL_SLASH_STRING8);
end

function TitanPanelBarButton_OnEvent(frame)
	if frame == "TitanPanelBarButton" then
		if (event == "VARIABLES_LOADED") then
			TitanVariables_InitTitanSettings();
			DEFAULT_CHAT_FRAME:AddMessage("|cffffd700"..TITAN_PANEL.." ("..GREEN_FONT_COLOR_CODE..TITAN_VERSION.." "..TITAN_PANEL_REVISION..LIGHTYELLOW_FONT_COLOR_CODE..")"..TITAN_PANEL_VERSION_INFO);
			if ( not ServerTimeOffsets ) then
				ServerTimeOffsets = {};
			end
			if ( not ServerHourFormat ) then
				ServerHourFormat = {};
			end
				
		elseif (event == "PLAYER_ENTERING_WORLD") then
			TitanVariables_InitDetailedSettings();
					
			local realmName = GetCVar("realmName");

			if ( ServerTimeOffsets[realmName] ) then
				TitanSetVar(TITAN_CLOCK_ID, "OffsetHour", ServerTimeOffsets[realmName]);
			elseif TitanGetVar(TITAN_CLOCK_ID, "OffsetHour")~=nil then
				ServerTimeOffsets[realmName] = TitanGetVar(TITAN_CLOCK_ID, "OffsetHour");
			end
			
			if ( ServerHourFormat[realmName] ) then
				TitanSetVar(TITAN_CLOCK_ID, "Format", ServerHourFormat[realmName]);
			elseif TitanGetVar(TITAN_CLOCK_ID, "Format")~=nil then
				ServerHourFormat[realmName] = TitanGetVar(TITAN_CLOCK_ID, "Format");
			end
			
			-- Move frames
			TitanPanelFrame_ScreenAdjust();
		
			-- Init panel buttons
			TitanPanel_InitPanelBarButton();
			TitanPanel_ButtonAdded = true;
			TitanPanel_InitPanelButtons();
			TitanPanel_ButtonAdded = false;
	
			-- Adjust initial frame position
			
	TitanPanel_SetTransparent("TitanPanelBarButtonHider", TitanPanelGetVar("Position"));
						
		elseif (event == "CVAR_UPDATE") then
			if (arg1 == "USE_UISCALE" or arg1 == "WINDOWED_MODE") then
				if (TitanPlayerSettings and TitanPanelGetVar("Scale")) then
					TitanPanel_SetScale();
					TitanPanel_RefreshPanelButtons();
					-- Adjust frame positions
					TitanPanelFrame_ScreenAdjust();
				end
			end
    elseif (event == "ZONE_CHANGED_NEW_AREA") then
			-- Move frames
			TitanPanel_InitPanelButtons();			 
		elseif (event == "PLAYER_REGEN_ENABLED") then
		-- outside combat check to see if frames need correction
			 Titan_ManageFramesNew();
			 Titan_FCF_UpdateCombatLogPosition();
		elseif (event == "PLAYER_REGEN_DISABLED") then
		 -- If in combat close all control frames and menus
		   TitanUtils_CloseAllControlFrames();
			 TitanUtils_CloseRightClickMenu();	
		end
	end
end

function TitanPanelFrame_ScreenAdjust()
	if not InCombatLockdown() then
		TitanMovableFrame_CheckFrames(TitanPanelGetVar("Position"));
		TitanMovableFrame_MoveFrames(TitanPanelGetVar("Position"),  TitanPanelGetVar("ScreenAdjust"));
		TitanMovableFrame_AdjustBlizzardFrames();

		TitanMovableFrame_CheckFrames(TITAN_PANEL_PLACE_BOTTOM);
		TitanMovableFrame_MoveFrames(TITAN_PANEL_PLACE_BOTTOM, TitanPanelGetVar("AuxScreenAdjust"));
		TitanMovableFrame_AdjustBlizzardFrames();
	end
end


function TitanPanelBarButton_OnClick(button)
-- ensure that the right-click menu will not appear on "hidden" bottom bar(s)
local bar = this:GetName();
	if (bar == "TitanPanelAuxBarButtonHider") and (TitanPanelGetVar("BothBars")== nil) then
		return;
	end
	
	if (bar == "TitanPanelAuxBarButtonHider") and (TitanPanelGetVar("AuxDoubleBar")== 1) then
		return;
	end
	
	if (button == "LeftButton") then
		TitanUtils_CloseAllControlFrames();
		TitanUtils_CloseRightClickMenu();	
	elseif (button == "RightButton") then
		TitanUtils_CloseAllControlFrames();			
		-- Show RightClickMenu anyway
		if (TitanPanelRightClickMenu_IsVisible()) then
			TitanPanelRightClickMenu_Close();
		end
		TitanPanelRightClickMenu_Toggle();		
	end
end

function Handle_OnUpdateAutoHide()
if (TitanPanelRightClickMenu_IsVisible()) then
	return
	end
	
	if  (TitanPanelBarButton.hide == nil) and (TitanPanelGetVar("AutoHide")) then
	TitanPanelBarButton_Hide("TitanPanelBarButton", TitanPanelGetVar("Position"));
	TitanKillAutoHidetimer = true;
	elseif (TitanPanelBarButton.hide == nil) and (not TitanPanelGetVar("AutoHide")) then
	   TitanKillAutoHidetimer = true;
	end

	if (TitanPanelAuxBarButton.hide == nil) and (TitanPanelGetVar("AuxAutoHide")) then
	TitanPanelBarButton_Hide("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM);
	TitanKillAutoHidetimer = true;
	elseif (TitanPanelAuxBarButton.hide == nil) and (not TitanPanelGetVar("AuxAutoHide")) then
	TitanKillAutoHidetimer = true;
	end

  if (TitanPanelBarButton.hide == 1) and (TitanPanelAuxBarButton.hide == 1) then
  TitanKillAutoHidetimer = true;
	end
	
	if TitanKillAutoHidetimer == true then
		local hasTimer = TitanPanel:HasTimer("TitanAutoHider")
	  if hasTimer then
		  TitanPanel:RemoveTimer("TitanAutoHider")
		 end
		 TitanKillAutoHidetimer = false;
	end
	
end

function TitanPanelAuxBarButton_OnLeave(frame)
 if (TitanPanelGetVar("AuxAutoHide")) then
 TitanPanel:AddRepeatingTimer("TitanAutoHider", 0.5, Handle_OnUpdateAutoHide)
 end
end

function TitanPanelAuxBarButtonHider_OnLeave(frame)
 if (TitanPanelGetVar("AuxAutoHide")) then
 TitanPanel:AddRepeatingTimer("TitanAutoHider", 0.5, Handle_OnUpdateAutoHide)
 end
end

function TitanPanelBarButtonHider_OnLeave(frame)
 if (TitanPanelGetVar("AutoHide")) then
 TitanPanel:AddRepeatingTimer("TitanAutoHider", 0.5, Handle_OnUpdateAutoHide)
 end
end

function TitanPanelBarButton_OnLeave(frame)
 if (TitanPanelGetVar("AutoHide")) then
 TitanPanel:AddRepeatingTimer("TitanAutoHider", 0.5, Handle_OnUpdateAutoHide)
 end
end

function TitanPanelBarButtonHider_OnEnter(frame)
      
     local hasTimer = TitanPanel:HasTimer("TitanAutoHider")
		 if hasTimer then
		  TitanPanel:RemoveTimer("TitanAutoHider")
		 end

	if (TitanPanelGetVar("AutoHide") or TitanPanelGetVar("AuxAutoHide")) then
		local frname = getglobal(frame)
		
		--if frname.isCounting ~= nil then
			--TitanUtils_StopAutoHideCounting(frame);
		--end
		
		if (frame == "TitanPanelBarButton" and TitanPanelBarButton.hide == 1) then
			if (TitanPanelBarButton.hide) then
				TitanPanelBarButton_Show("TitanPanelBarButton", TitanPanelGetVar("Position"));
			end
		else
			if (frame == "TitanPanelAuxBarButton" and TitanPanelAuxBarButton.hide == 1) then
				if (TitanPanelAuxBarButton.hide) then
					TitanPanelBarButton_Show("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM);
				end
			end
		end

		if (frame == "TitanPanelBarButtonHider" and TitanPanelBarButton.hide == 1) then
			if (TitanPanelBarButton.hide) then
				TitanPanelBarButton_Show("TitanPanelBarButton", TitanPanelGetVar("Position"));
			end
		else
			if (frame == "TitanPanelAuxBarButtonHider" and TitanPanelAuxBarButton.hide and TitanPanelAuxBarButton.hide == 1) then
				if TitanPanelGetVar("BothBars") then
					TitanPanelBarButton_Show("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM);
				end
			end
		end
	end
end

function TitanPanelRightClickMenu_BarOnClick()
	--if (UIDropDownMenuButton_GetChecked()) then
	if not this.checked then
		TitanPanel_RemoveButton(this.value);
	else
		TitanPanel_AddButton(this.value);
	end
end

function TitanPanelBarButton_ToggleAlign()
	if ( TitanPanelGetVar("ButtonAlign") == TITAN_PANEL_BUTTONS_ALIGN_CENTER ) then
		TitanPanelSetVar("ButtonAlign", TITAN_PANEL_BUTTONS_ALIGN_LEFT);
	else
		TitanPanelSetVar("ButtonAlign", TITAN_PANEL_BUTTONS_ALIGN_CENTER);
	end
	
	-- Justify button position
	TitanPanelButton_Justify();
end

function TitanPanelBarButton_ToggleAuxAlign()
	if ( TitanPanelGetVar("AuxButtonAlign") == TITAN_PANEL_BUTTONS_ALIGN_CENTER ) then
		TitanPanelSetVar("AuxButtonAlign", TITAN_PANEL_BUTTONS_ALIGN_LEFT);
	else
		TitanPanelSetVar("AuxButtonAlign", TITAN_PANEL_BUTTONS_ALIGN_CENTER);
	end
	
	-- Justify button position
	TitanPanelButton_Justify();
end

function TitanPanelBarButton_ToggleDoubleBar()
	if ( TitanPanelGetVar("DoubleBar") == TITAN_PANEL_BARS_SINGLE ) then
		TitanPanelSetVar("DoubleBar", TITAN_PANEL_BARS_DOUBLE);
		TitanPanelBarButtonHider:SetHeight(48);
	else
		TitanPanelSetVar("DoubleBar", TITAN_PANEL_BARS_SINGLE);
		TitanPanelBarButtonHider:SetHeight(24);
	end
	
	TitanMovableFrame_CheckFrames(TitanPanelGetVar("Position"));
	TitanMovableFrame_MoveFrames(TitanPanelGetVar("Position"), TitanPanelGetVar("DoubleBar"));
	TitanMovableFrame_AdjustBlizzardFrames();
	TitanPanel_InitPanelBarButton();
	TitanPanel_InitPanelButtons();		
	TitanPanel_SetTransparent("TitanPanelBarButtonHider", TitanPanelGetVar("Position"));

	if (TitanPanelGetVar("AutoHide")) then
		TitanPanelBarButton_Hide("TitanPanelBarButton", TitanPanelGetVar("Position"));
	end
	if (TitanPanelGetVar("AuxAutoHide")) then
		TitanPanelBarButton_Hide("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM);
	end		

end

function TitanPanelBarButton_ToggleAuxDoubleBar()
	if ( TitanPanelGetVar("AuxDoubleBar") == TITAN_PANEL_BARS_SINGLE ) then
		TitanPanelSetVar("AuxDoubleBar", TITAN_PANEL_BARS_DOUBLE);
		TitanPanelAuxBarButtonHider:SetHeight(48);
	else
		TitanPanelSetVar("AuxDoubleBar", TITAN_PANEL_BARS_SINGLE);
		TitanPanelAuxBarButtonHider:SetHeight(24);
	end
	TitanMovableFrame_CheckFrames(TITAN_PANEL_PLACE_BOTTOM);
	TitanMovableFrame_MoveFrames(TITAN_PANEL_PLACE_BOTTOM, 1);
	TitanMovableFrame_AdjustBlizzardFrames();
	TitanPanel_InitPanelBarButton();
	TitanPanel_InitPanelButtons();		
	TitanPanel_SetTransparent("TitanPanelAuxBarButtonHider", TITAN_PANEL_PLACE_BOTTOM);

	if (TitanPanelGetVar("AutoHide")) then
		TitanPanelBarButton_Hide("TitanPanelBarButton", TitanPanelGetVar("Position"));
	end
	if (TitanPanelGetVar("AuxAutoHide")) then
		TitanPanelBarButton_Hide("TitanPanelAuxBarButton", TitanPanelGetVar("Position"));
	end		

end

function TitanPanelBarButton_ToggleAutoHide()
	TitanPanelToggleVar("AutoHide");
	if (TitanPanelGetVar("AutoHide")) then
		TitanPanelBarButton_Hide("TitanPanelBarButton", TitanPanelGetVar("Position"));
	else
		TitanPanelBarButton_Show("TitanPanelBarButton", TitanPanelGetVar("Position"));
	end
	TitanPanelAutoHideButton_SetIcon();
	
	if (TitanPanelGetVar("BothBars")) then
	 if TitanPanelGetVar("AuxAutoHide") then
	   TitanPanelBarButton_Hide("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM);
	 end
	 if TitanPanelGetVar("AutoHide") then
	   TitanPanelBarButton_Hide("TitanPanelBarButton", TitanPanelGetVar("Position"));
	 end
	else
	 if TitanPanelGetVar("AuxAutoHide") then
	   TitanPanelBarButton_Hide("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM);
	 end
	 if TitanPanelGetVar("AutoHide") then
	   TitanPanelBarButton_Hide("TitanPanelBarButton", TitanPanelGetVar("Position"));
	 end
	end
end

function TitanPanelBarButton_ToggleLogAdjust()
TitanPanelToggleVar("LogAdjust");
end

function TitanPanelBarButton_ToggleMinimapAdjust()
TitanPanelToggleVar("MinimapAdjust");
end

function TitanPanelBarButton_ToggleButtonLock()
TitanPanelToggleVar("LockButtons");
end

function TitanPanelBarButton_ToggleAuxAutoHide()
	TitanPanelToggleVar("AuxAutoHide");
	if (TitanPanelGetVar("AuxAutoHide")) then
		if TitanPanelGetVar("BothBars") then
			TitanPanelBarButton_Hide("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM);
		end
	else
		if TitanPanelGetVar("BothBars") then
			TitanPanelBarButton_Show("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM);
		end
	end
	--Needs changing!
	TitanPanelAuxAutoHideButton_SetIcon();
end

function TitanPanelBarButton_ToggleScreenAdjust()
	TitanPanelToggleVar("ScreenAdjust");
	TitanMovableFrame_CheckFrames(TitanPanelGetVar("Position"));
	TitanMovableFrame_MoveFrames(TitanPanelGetVar("Position"), TitanPanelGetVar("ScreenAdjust"));
	TitanMovableFrame_AdjustBlizzardFrames();
end

function TitanPanelBarButton_ToggleAuxScreenAdjust()
	TitanPanelToggleVar("AuxScreenAdjust");
	TitanMovableFrame_CheckFrames(TITAN_PANEL_PLACE_BOTTOM);
	TitanMovableFrame_MoveFrames(TITAN_PANEL_PLACE_BOTTOM, TitanPanelGetVar("AuxScreenAdjust"));
	TitanMovableFrame_AdjustBlizzardFrames();
end

function TitanPanelBarButton_TogglePosition()
	if (TitanPanelGetVar("Position") == TITAN_PANEL_PLACE_TOP) then
		TitanMovableFrame_CheckFrames(TitanPanelGetVar("Position"));
		TitanPanelSetVar("Position", TITAN_PANEL_PLACE_BOTTOM);
		TitanMovableFrame_MoveFrames(TitanPanelGetVar("Position"), TitanPanelGetVar("ScreenAdjust"));
	else
		TitanMovableFrame_CheckFrames(TitanPanelGetVar("Position"));
		TitanPanelSetVar("Position", TITAN_PANEL_PLACE_TOP);
		TitanMovableFrame_MoveFrames(TitanPanelGetVar("Position"), TitanPanelGetVar("ScreenAdjust"));
	end
	
	-- Set panel position and texture
	TitanPanel_SetPosition("TitanPanelBarButton", TitanPanelGetVar("Position"));
	TitanPanel_SetTexture("TitanPanelBarButton", TitanPanelGetVar("Position"));
	TitanPanel_SetTransparent("TitanPanelBarButtonHider", TitanPanelGetVar("Position"));
	
	-- Adjust frame positions
	TitanMovableFrame_CheckFrames(TitanPanelGetVar("Position"));
	TitanMovableFrame_MoveFrames(TitanPanelGetVar("Position"), TitanPanelGetVar("ScreenAdjust"));
	TitanMovableFrame_AdjustBlizzardFrames();
	TitanPanelButton_Justify();

end

function TitanPanelBarButton_ToggleBarsShown()
	TitanPanelToggleVar("BothBars");
	TitanPanelBarButton_DisplayBarsWanted();
	TitanPanelRightClickMenu_Close();
	-- routine to handle autohide
	--old
	--if (TitanPanelGetVar("BothBars")) then
		--	TitanPanelAuxBarButton.hide = nil;
	--else
	  --TitanPanelBarButton.hide = nil;
	--end
	-- new
	if (TitanPanelGetVar("BothBars")) then
	 if TitanPanelGetVar("AuxAutoHide") then
	   TitanPanelBarButton_Hide("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM);
	 end
	 if TitanPanelGetVar("AutoHide") then
	   TitanPanelBarButton_Hide("TitanPanelBarButton", TitanPanelGetVar("Position"));
	 end
	else
	 if TitanPanelGetVar("AuxAutoHide") then
	   TitanPanelBarButton_Hide("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM);
	 end
	 if TitanPanelGetVar("AutoHide") then
	   TitanPanelBarButton_Hide("TitanPanelBarButton", TitanPanelGetVar("Position"));
	 end
	end
end
	
function TitanPanelBarButton_ToggleVersionShown()
	TitanPanelToggleVar("VersionShown");
end
	
function TitanPanelBarButton_ToggleToolTipsShown()
	TitanPanelToggleVar("ToolTipsShown");
end

function TitanPanelBarButton_ToggleToolTipsShownInCombat()
  TitanPanelToggleVar("HideTipsInCombat");
end
	
function TitanPanelBarButton_ToggleCastingBar()
	TitanPanelToggleVar("CastingBar");
	ReloadUI()
end
	
function TitanPanelBarButton_DisplayBarsWanted()
	--Need to handle top & bottom
	if (TitanPanelGetVar("BothBars")) then
		if (TitanPanelGetVar("Position") == TITAN_PANEL_PLACE_BOTTOM) then
			TitanPanelBarButton_TogglePosition();
		end

		TitanMovableFrame_CheckFrames(TITAN_PANEL_PLACE_TOP);
		TitanMovableFrame_MoveFrames(TITAN_PANEL_PLACE_TOP, TitanPanelGetVar("ScreenAdjust"));

		-- Set panel position and texture
		TitanPanel_SetPosition("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM);
		TitanPanel_SetTexture("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM);
	
		-- Adjust frame positions
		TitanMovableFrame_CheckFrames(TITAN_PANEL_PLACE_BOTTOM);
		TitanMovableFrame_MoveFrames(TITAN_PANEL_PLACE_BOTTOM, TitanPanelGetVar("AuxScreenAdjust"));
		TitanMovableFrame_AdjustBlizzardFrames();
		
	else
		TitanPanelBarButton_TogglePosition();
		TitanPanelBarButton_Hide("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM)
		TitanPanelBarButton_TogglePosition();
	end
end

function TitanPanelBarButton_Show(frame, position)
	local frName = getglobal(frame);
	local barnumber = TitanUtils_GetDoubleBar(TitanPanelGetVar("BothBars"), position);

	if (position == TITAN_PANEL_PLACE_TOP) then
		frName:ClearAllPoints();	
		frName:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 0, 0);
		frName:SetPoint("BOTTOMRIGHT", "UIParent", "TOPRIGHT", 0, -24); 
	else
		frName:ClearAllPoints();
		frName:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 0); 
		frName:SetPoint("TOPRIGHT", "UIParent", "BOTTOMRIGHT", 0, 24); 
	end
	
	frName.hide = nil;
end

function TitanPanelBarButton_Hide(frame, position)
	local frName = getglobal(frame);
	local barnumber = TitanUtils_GetDoubleBar(TitanPanelGetVar("BothBars"), position);

	if frName ~= nil then

		if (position == TITAN_PANEL_PLACE_TOP) then
			frName:ClearAllPoints();
			frName:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 0, (35*barnumber)); 
			frName:SetPoint("BOTTOMRIGHT", "UIParent", "TOPRIGHT", 0, -3);
			
		elseif  (position == TITAN_PANEL_PLACE_BOTTOM) and frame == "TitanPanelBarButton" then
			frName:ClearAllPoints();
			frName:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, (-35*barnumber)); 
			frName:SetPoint("TOPRIGHT", "UIParent", "BOTTOMRIGHT", 0, -35);
		
		else
			if TitanPanelGetVar("BothBars") == nil and frame == "TitanPanelAuxBarButton" then
				frName:ClearAllPoints();
				frName:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, (-35*barnumber)); 
				frName:SetPoint("TOPRIGHT", "UIParent", "BOTTOMRIGHT", 0, -35);
			else
				frName:ClearAllPoints();
				frName:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, (-35*barnumber)); 
				frName:SetPoint("TOPRIGHT", "UIParent", "BOTTOMRIGHT", 0, -35);
			end
		end
	
		frName.hide = 1;
	end
end

function TitanPanel_InitPanelBarButton()
	-- Set Titan Panel position/textures
	TitanPanel_SetPosition("TitanPanelBarButton", TitanPanelGetVar("Position"));
	TitanPanel_SetTexture("TitanPanelBarButton", TitanPanelGetVar("Position"));

	-- Set initial Panel Scale
	TitanPanel_SetScale();		

	-- Set initial Panel Transparency
	TitanPanelBarButton:SetAlpha(TitanPanelGetVar("Transparency"));		
	TitanPanelAuxBarButton:SetAlpha(TitanPanelGetVar("AuxTransparency"));		
end

function TitanPanel_SetPosition(frame, position)
	local frName = getglobal(frame);
	if (position == TITAN_PANEL_PLACE_TOP) then
		if frame == "TitanPanelBarButton" then
			TitanPanelBackground12:ClearAllPoints();
			TitanPanelBackground12:SetPoint("BOTTOMLEFT", "TitanPanelBackground0", "BOTTOMLEFT", 0, -25); 
		end
		frName:ClearAllPoints();
		frName:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 0, 0);
		frName:SetPoint("BOTTOMRIGHT", "UIParent", "TOPRIGHT", 0, -24);	
	else
		if frame == "TitanPanelBarButton" then
			TitanPanelBackground12:ClearAllPoints();
			TitanPanelBackground12:SetPoint("BOTTOMLEFT", "TitanPanelBackground0", "BOTTOMLEFT", 0, 25); 
		end
		frName:ClearAllPoints();
		frName:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 0); 
		frName:SetPoint("TOPRIGHT", "UIParent", "BOTTOMRIGHT", 0, 24); 
	end
end

function TitanPanel_SetTransparent(frame, position)
	local frName = getglobal(frame);
	local topBars = TitanUtils_GetDoubleBar(TitanPanelGetVar("BothBars"), TITAN_PANEL_PLACE_TOP);
	local bottomBars = TitanUtils_GetDoubleBar(TitanPanelGetVar("BothBars"), TITAN_PANEL_PLACE_BOTTOM);
	
	if (position == TITAN_PANEL_PLACE_TOP) then
		frName:ClearAllPoints();
		frName:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 0, 0);
		frName:SetPoint("BOTTOMRIGHT", "UIParent", "TOPRIGHT", 0, -24 * topBars);
		TitanPanelAuxBarButtonHider:ClearAllPoints();
		TitanPanelAuxBarButtonHider:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 0); 
		TitanPanelAuxBarButtonHider:SetPoint("TOPRIGHT", "UIParent", "BOTTOMRIGHT", 0, 24 * bottomBars); 
	elseif position == TITAN_PANEL_PLACE_BOTTOM and frame == "TitanPanelBarButtonHider" then
		frName:ClearAllPoints();
		frName:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 0); 
		frName:SetPoint("TOPRIGHT", "UIParent", "BOTTOMRIGHT", 0, 24 * bottomBars); 
		TitanPanelAuxBarButtonHider:ClearAllPoints();
		TitanPanelAuxBarButtonHider:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 0); 
		TitanPanelAuxBarButtonHider:SetPoint("TOPRIGHT", "UIParent", "BOTTOMRIGHT", 0, 0); 
	else
		frName:ClearAllPoints();
		frName:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 0); 
		frName:SetPoint("TOPRIGHT", "UIParent", "BOTTOMRIGHT", 0, 24 * bottomBars); 
	end
end

function TitanPanel_SetTexture(frame, position)
	local frName = getglobal(frame);
	local barnumber = TitanUtils_GetDoubleBar(TitanPanelGetVar("BothBars"), position);
	
	if frame == "TitanPanelBarButton" then
		local pos = TitanUtils_Ternary(position == TITAN_PANEL_PLACE_TOP, "Top", "Bottom");
		for i = 0, 11 do
			getglobal("TitanPanelBackground"..i):SetTexture(TitanPanelGetVar("TexturePath").."TitanPanelBackground"..pos..math.fmod(i, 2));
		end
		for i = 12, 22 do
			if barnumber == 2 then
				TitanPanelBarButtonHider:SetHeight(48);
				getglobal("TitanPanelBackground"..i):SetTexture(TitanPanelGetVar("TexturePath").."TitanPanelBackground"..pos..math.fmod(i, 2));
			else
				TitanPanelBarButtonHider:SetHeight(24);
				getglobal("TitanPanelBackground"..i):SetTexture();
			end
		end
	else
		local pos = TitanUtils_Ternary(position == TITAN_PANEL_PLACE_BOTTOM, "Top", "Bottom");
		for i = 0, 11 do
			getglobal("TitanPanelBackgroundAux"..i):SetTexture(TitanPanelGetVar("TexturePath").."TitanPanelBackground".."Bottom"..math.fmod(i, 2));
		end
		for i = 12, 22 do
			if barnumber == 2 then
				TitanPanelAuxBarButtonHider:SetHeight(48);
				getglobal("TitanPanelBackgroundAux"..i):SetTexture(TitanPanelGetVar("TexturePath").."TitanPanelBackground".."Bottom"..math.fmod(i, 2));
			else
				TitanPanelAuxBarButtonHider:SetHeight(24);
				getglobal("TitanPanelBackgroundAux"..i):SetTexture();
			end
		end
	end
end

function TitanPanel_InitPanelButtons()
	local button, leftButton, rightButton, leftAuxButton, rightAuxButton, leftDoubleButton, rightDoubleButton, leftAuxDoubleButton, rightAuxDoubleButton;
	local nextLeft, nextAuxLeft
	local leftside, auxleftside;
	local newButtons = {};
	local newLocations = {};
	local scale = TitanPanelGetVar("Scale");
	local isClockOnRightSide;

	TitanPanelBarButton_DisplayBarsWanted();
	-- routine to handle autohide
	--old
	--if (TitanPanelGetVar("BothBars")) then
	--TitanPanelAuxBarButton.hide = nil;
	--else
	--TitanPanelBarButton.hide = nil;
	--end
	
	-- new
	if (TitanPanelGetVar("BothBars")) then
	 if TitanPanelGetVar("AuxAutoHide") then
	   TitanPanelBarButton_Hide("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM);
	 end
	 if TitanPanelGetVar("AutoHide") then
	   TitanPanelBarButton_Hide("TitanPanelBarButton", TitanPanelGetVar("Position"));
	 end
	else
	 if TitanPanelGetVar("AuxAutoHide") then
	   TitanPanelBarButton_Hide("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM);
	 end
	 if TitanPanelGetVar("AutoHide") then
	   TitanPanelBarButton_Hide("TitanPanelBarButton", TitanPanelGetVar("Position"));
	 end
	end
	
	-- Position Clock first if it's displayed on the far right side
	if ( TitanUtils_TableContainsValue(TitanPanelSettings.Buttons, TITAN_CLOCK_ID) and TitanGetVar(TITAN_CLOCK_ID, "DisplayOnRightSide") ) then
		isClockOnRightSide = 1;
		button = TitanUtils_GetButton(TITAN_CLOCK_ID);
		local i = TitanPanel_GetButtonNumber(TITAN_CLOCK_ID)
		
		if TitanPanelSettings.Location[i] == nil then
			TitanPanelSettings.Location[i] = "Bar";
		end
		if TitanPanelSettings.Location[i] == "AuxBar" then
			button:ClearAllPoints();
			button:SetPoint("RIGHT", "TitanPanel" .. TitanPanelSettings.Location[i] .."Button", "RIGHT", -(TitanPanelGetVar("ButtonSpacing")) / 2 * scale, TITAN_PANEL_FROM_BOTTOM_MAIN);
			rightAuxButton = button;
		else
			button:ClearAllPoints();
			button:SetPoint("RIGHT", "TitanPanel" .. TitanPanelSettings.Location[i] .."Button", "RIGHT", -(TitanPanelGetVar("ButtonSpacing")) / 2 * scale, TITAN_PANEL_FROM_TOP_MAIN);
			rightButton = button;
		end
	end
	
	-- Position all the buttons 
	--for index, id in pairs(TitanPanelSettings.Buttons) do 
	for i = 1, table.maxn(TitanPanelSettings.Buttons) do 

		id = TitanPanelSettings.Buttons[i];
		if ( TitanUtils_IsPluginRegistered(id) ) then
			local i = TitanPanel_GetButtonNumber(id);
			
			if(TitanPanelSettings.Location[i] == nil) then
				if id ~= "AuxAutoHide" then
					TitanPanelSettings.Location[i] = "Bar";
				else
					TitanPanelSettings.Location[i] = "AuxBar";
				end
			end
		
			button = TitanUtils_GetButton(id);

			if ( id == TITAN_CLOCK_ID and isClockOnRightSide ) then
				-- Do nothing, since it's already positioned
			elseif ( TitanPanelButton_IsIcon(id) ) then	
			
				if ( rightAuxButton and TitanPanelSettings.Location[i] == "AuxBar" ) then
					button:ClearAllPoints();
					button:SetPoint("RIGHT", rightAuxButton:GetName(), "LEFT", -TITAN_PANEL_ICON_SPACING * scale, 0); 
				elseif ( not rightButton ) then
					button:ClearAllPoints();
					button:SetPoint("RIGHT", "TitanPanel" .. TitanPanelSettings.Location[i] .."Button", "RIGHT", -(TitanPanelGetVar("ButtonSpacing")) / 2 * scale, TITAN_PANEL_FROM_TOP_MAIN); 
				else
					if ( not rightAuxButton and TitanPanelSettings.Location[i] == "AuxBar") then
						button:ClearAllPoints();
						button:SetPoint("RIGHT", "TitanPanel" .. TitanPanelSettings.Location[i] .."Button", "RIGHT", -(TitanPanelGetVar("ButtonSpacing")) / 2 * scale, TITAN_PANEL_FROM_BOTTOM_MAIN); 
					elseif TitanPanelSettings.Location[i] == "AuxBar" then
						button:ClearAllPoints();
						button:SetPoint("RIGHT", rightAuxButton:GetName(), "LEFT", -TITAN_PANEL_ICON_SPACING * scale, 0); 
					else
						button:ClearAllPoints();
						button:SetPoint("RIGHT", rightButton:GetName(), "LEFT", -TITAN_PANEL_ICON_SPACING * scale, 0); 
					end
				end

				if TitanPanelSettings.Location[i] == "AuxBar" then
					rightAuxButton = button;
				else
					rightButton = button;
				end
			else			
			
				if ( TitanPanelSettings.Location[i] == "AuxBar" ) then
					if (nextAuxLeft == "Double") then
						button:ClearAllPoints();
						button:SetPoint("LEFT", leftAuxDoubleButton:GetName(), "RIGHT", (TitanPanelGetVar("ButtonSpacing")) * scale, 0);
						nextAuxLeft = "Main"
						leftAuxDoubleButton = button;
					elseif (nextAuxLeft == "DoubleFirst") then
						button:ClearAllPoints();
						button:SetPoint("LEFT", "TitanPanel" .. TitanPanelSettings.Location[i] .."Button", "LEFT", (TitanPanelGetVar("ButtonSpacing")) / 2 * scale, TITAN_PANEL_FROM_BOTTOM);
						nextAuxLeft = "Main"
						leftAuxDoubleButton = button;
					elseif (nextAuxLeft == "Main") then
						button:ClearAllPoints();
						button:SetPoint("LEFT", leftAuxButton:GetName(), "RIGHT", (TitanPanelGetVar("ButtonSpacing")) * scale, 0);
						nextAuxLeft = TitanPanel_Nextbar("AuxDoubleBar");
						leftAuxButton = button;
					else
						button:ClearAllPoints();
						button:SetPoint("LEFT", "TitanPanel" .. TitanPanelSettings.Location[i] .."Button", "LEFT", (TitanPanelGetVar("ButtonSpacing")) / 2 * scale, TITAN_PANEL_FROM_BOTTOM_MAIN);
						nextAuxLeft = TitanPanel_Nextbar("AuxDoubleBar");
						if nextAuxLeft == "Double" then
							nextAuxLeft = "DoubleFirst";
						end
						leftAuxButton = button;
					end
				else
					if (nextLeft == "Double") then
						button:ClearAllPoints();
						button:SetPoint("LEFT", leftDoubleButton:GetName(), "RIGHT", (TitanPanelGetVar("ButtonSpacing")) * scale, 0);
						nextLeft = "Main"
						leftDoubleButton = button;
					elseif (nextLeft == "DoubleFirst") then
						button:ClearAllPoints();
						if TitanPanelGetVar("Position") == TITAN_PANEL_PLACE_TOP then
							button:SetPoint("LEFT", "TitanPanel" .. TitanPanelSettings.Location[i] .."Button", "LEFT", (TitanPanelGetVar("ButtonSpacing")) / 2 * scale, TITAN_PANEL_FROM_TOP);
						else
							button:SetPoint("LEFT", "TitanPanel" .. TitanPanelSettings.Location[i] .."Button", "LEFT", (TitanPanelGetVar("ButtonSpacing")) / 2 * scale, TITAN_PANEL_FROM_BOTTOM);
						end
						nextLeft = "Main"
						leftDoubleButton = button;
					elseif (nextLeft == "Main") then
						button:ClearAllPoints();
						button:SetPoint("LEFT", leftButton:GetName(), "RIGHT", (TitanPanelGetVar("ButtonSpacing")) * scale, 0);
						nextLeft = TitanPanel_Nextbar("DoubleBar");
						leftButton = button;
					else
						button:ClearAllPoints();
						button:SetPoint("LEFT", "TitanPanel" .. TitanPanelSettings.Location[i] .."Button", "LEFT", (TitanPanelGetVar("ButtonSpacing")) / 2 * scale, TITAN_PANEL_FROM_TOP_MAIN);
						nextLeft = TitanPanel_Nextbar("DoubleBar");
						if nextLeft == "Double" then
							nextLeft = "DoubleFirst";
						end
						leftButton = button;
					end
				end

			end
			table.insert(newButtons, id);
			table.insert(newLocations, TitanPanelSettings.Location[i]);
			button:Show();
		end
	end
	-- table.sort (newButtons);
	-- Set TitanPanelSettings.Buttons
	TitanPanelSettings.Buttons = newButtons;
	TitanPanelSettings.Location = newLocations;
	
	-- Set panel button init flag
	TITAN_PANEL_BUTTONS_INIT_FLAG = 1;
	TitanPanelButton_Justify();
end

function TitanPanel_Nextbar(var)
	if TitanPanelGetVar(var) == TITAN_PANEL_BARS_DOUBLE then
		return "Double";
	else
		return "Main";
	end
end

function TitanPanel_RemoveButton(id)
	if ( not TitanPanelSettings ) then
		return;
	end 
	
	local i = TitanPanel_GetButtonNumber(id)
	local currentButton = TitanUtils_GetButton(id);
	currentButton:Hide();	
	
	-- safeguard to destroy any active plugin timers based on a fixed naming convention : TitanPanel..id, eg. "TitanPanelClock"
	-- this prevents "rogue" timers being left behind by lack of an OnHide check
	local hasTimer = TitanPanel:HasTimer("TitanPanel"..id)
	  if hasTimer then
		  TitanPanel:RemoveTimer("TitanPanel"..id)
		end	

	TitanPanel_ReOrder(i);
	table.remove(TitanPanelSettings.Buttons, TitanUtils_GetCurrentIndex(TitanPanelSettings.Buttons, id));
	--table.remove(TitanPanelSettings.Location, i);
	TitanPanel_InitPanelButtons();
end

function TitanPanel_AddButton(id)
	if (not TitanPanelSettings) then
		return;
	end 

	local i = TitanPanel_GetButtonNumber(id)
	TitanPanelSettings.Location[i] = TITAN_PANEL_SELECTED;
	local j,k;
	if TITAN_PANEL_SELECTED ~= "Bar" and TITAN_PANEL_SELECTED ~= "AuxBar" then
	j = TitanPanel_GetButtonNumber(TITAN_PANEL_SELECTED);
	k = TitanPanelSettings.Location[j];
	TitanPanelSettings.Location[i] = k;
	end
	
	table.insert(TitanPanelSettings.Buttons, id);	
	--table.insert(TitanPanelSettings.Location, TITAN_PANEL_SELECTED);
	TitanPanel_ButtonAdded = true;
	TitanPanel_InitPanelButtons();
	TitanPanel_ButtonAdded = false;
end

function TitanPanel_ReOrder(index)
	for i = index, table.getn(TitanPanelSettings.Buttons) do		
		TitanPanelSettings.Location[i] = TitanPanelSettings.Location[i+1]
	end
end

function TitanPanel_GetButtonNumber(id)
	if (TitanPanelSettings) then
		for i = 1, table.getn(TitanPanelSettings.Buttons) do		
			if(TitanPanelSettings.Buttons[i] == id) then
				return i;
			end	
		end
		return table.getn(TitanPanelSettings.Buttons)+1;
	else
		return 0;
	end
end

function TitanPanel_RefreshPanelButtons()
	if (TitanPanelSettings) then
		for i = 1, table.getn(TitanPanelSettings.Buttons) do		
			TitanPanelButton_UpdateButton(TitanPanelSettings.Buttons[i], 1);		
		end
	end
end

function TitanPanelButton_Justify()	
	if ( not TITAN_PANEL_BUTTONS_INIT_FLAG or not TitanPanelSettings ) then
		return;
	end

	-- Check if clock displayed on the far right side
	local isClockOnRightSide;
	if ( TitanUtils_TableContainsValue(TitanPanelSettings.Buttons, TITAN_CLOCK_ID) and TitanGetVar(TITAN_CLOCK_ID, "DisplayOnRightSide") ) then
		isClockOnRightSide = 1;
	end
	
	local firstLeftButton = TitanUtils_GetFirstButton(TitanPanelSettings.Buttons, 1, nil, isClockOnRightSide);
	local secondLeftButton;
	local scale = TitanPanelGetVar("Scale");
	local leftWidth = 0;
	local rightWidth = 0;
	local leftDoubleWidth = 0;
	local rightDoubleWidth = 0;
	local counter = 0;
	local triggered = 0;
	if ( firstLeftButton ) then
		if ( TitanPanelGetVar("ButtonAlign") == TITAN_PANEL_BUTTONS_ALIGN_LEFT ) then
			counter = 0;
			triggered = 0;
			for index, id in pairs(TitanPanelSettings.Buttons) do
				local button = TitanUtils_GetButton(id);
						
						-- failsafe check to remove plugins "inside plugins"
						   if button == nil then
						    break;
						   end
				
				if ( not button:GetWidth() ) then 
					return; 
				end
				if TitanUtils_GetWhichBar(id) == "Bar" then
					if TitanPanelGetVar("DoubleBar") == 2 and mod(counter,2) == 1 and not TitanPanelButton_IsIcon(id) then
						if triggered == 0 then
							secondLeftButton = button;
							triggered = 1;
						end
					end
					if ( TitanPanelButton_IsIcon(id) or (id == TITAN_CLOCK_ID and isClockOnRightSide) ) then
						-- Do nothing
					else
						counter = counter + 1;
					end
				end
			end

			firstLeftButton:ClearAllPoints();
			firstLeftButton:SetPoint("LEFT", "TitanPanelBarButton", "LEFT", (TitanPanelGetVar("ButtonSpacing")) / 2 * scale, TITAN_PANEL_FROM_TOP_MAIN); 
			if triggered == 1 then
				secondLeftButton:ClearAllPoints();
				if TitanPanelGetVar("Position") == TITAN_PANEL_PLACE_TOP then
					secondLeftButton:SetPoint("LEFT", "TitanPanelBarButton", "LEFT", (TitanPanelGetVar("ButtonSpacing")) / 2 * scale, TITAN_PANEL_FROM_TOP);
				else
					secondLeftButton:SetPoint("LEFT", "TitanPanelBarButton", "LEFT", (TitanPanelGetVar("ButtonSpacing")) / 2 * scale, TITAN_PANEL_FROM_BOTTOM);
				end
			end

		elseif ( TitanPanelGetVar("ButtonAlign") == TITAN_PANEL_BUTTONS_ALIGN_CENTER ) then
			leftWidth = 0;
			rightWidth = 0;
			leftDoubleWidth = 0;
			rightDoubleWidth = 0;
			counter = 0;
			triggered = 0;
			for index, id in pairs(TitanPanelSettings.Buttons) do
				local button = TitanUtils_GetButton(id);
				
				if ( not button:GetWidth() ) then 
					return; 
				end
				if TitanUtils_GetWhichBar(id) == "Bar" then
					if TitanPanelGetVar("DoubleBar") == 2 and mod(counter,2) == 1 and not TitanPanelButton_IsIcon(id) then
						if triggered == 0 then
							secondLeftButton = button;
							triggered = 1;
						end
						if ( TitanPanelButton_IsIcon(id) or (id == TITAN_CLOCK_ID and isClockOnRightSide) ) then
							rightDoubleWidth = rightDoubleWidth + TITAN_PANEL_ICON_SPACING + button:GetWidth();
						else
							counter = counter + 1;
							leftDoubleWidth = leftDoubleWidth + (TitanPanelGetVar("ButtonSpacing")) + button:GetWidth();
						end
					else
						if ( TitanPanelButton_IsIcon(id) or (id == TITAN_CLOCK_ID and isClockOnRightSide) ) then
							rightWidth = rightWidth + TITAN_PANEL_ICON_SPACING + button:GetWidth();
						else
							counter = counter + 1;
							leftWidth = leftWidth + (TitanPanelGetVar("ButtonSpacing")) + button:GetWidth();
						end
					end
				end
			end

			firstLeftButton:ClearAllPoints();
			firstLeftButton:SetPoint("LEFT", "TitanPanelBarButton", "CENTER", 0 - leftWidth / 2, TITAN_PANEL_FROM_TOP_MAIN); 
			if triggered == 1 then
				secondLeftButton:ClearAllPoints();
				if TitanPanelGetVar("Position") == TITAN_PANEL_PLACE_TOP then
					secondLeftButton:SetPoint("LEFT", "TitanPanelBarButton", "CENTER", 0 - leftDoubleWidth / 2, TITAN_PANEL_FROM_TOP);
				else
					secondLeftButton:SetPoint("LEFT", "TitanPanelBarButton", "CENTER", 0 - leftDoubleWidth / 2, TITAN_PANEL_FROM_BOTTOM);
				end
			end
		end
	end

	local firstLeftButton = TitanUtils_GetFirstAuxButton(TitanPanelSettings.Buttons, 1, nil, isClockOnRightSide);
	secondLeftButton = nil;
	if ( firstLeftButton ) then
		if ( TitanPanelGetVar("AuxButtonAlign") == TITAN_PANEL_BUTTONS_ALIGN_LEFT ) then
			triggered = 0;
			counter = 0;
			for index, id in pairs(TitanPanelSettings.Buttons) do
				local button = TitanUtils_GetButton(id);
				
				if ( not button:GetWidth() ) then 
					return; 
				end
				if TitanUtils_GetWhichBar(id) == "AuxBar" then
					if TitanPanelGetVar("AuxDoubleBar") == 2 and mod(counter,2) == 1 and not TitanPanelButton_IsIcon(id) then
						if triggered == 0 then
							secondLeftButton = button;
							triggered = 1;
						end
					end
					if ( TitanPanelButton_IsIcon(id) or (id == TITAN_CLOCK_ID and isClockOnRightSide) ) then
						-- Do nothing
					else
						counter = counter + 1;
					end
				end
			end

			firstLeftButton:ClearAllPoints();
			firstLeftButton:SetPoint("LEFT", "TitanPanelAuxBarButton", "LEFT", (TitanPanelGetVar("ButtonSpacing")) / 2 * scale, TITAN_PANEL_FROM_BOTTOM_MAIN); 
			if triggered == 1 then
				secondLeftButton:ClearAllPoints();
				secondLeftButton:SetPoint("LEFT", "TitanPanelAuxBarButton", "LEFT", (TitanPanelGetVar("ButtonSpacing")) / 2 * scale, TITAN_PANEL_FROM_BOTTOM);
			end
		elseif ( TitanPanelGetVar("AuxButtonAlign") == TITAN_PANEL_BUTTONS_ALIGN_CENTER ) then
			leftWidth = 0;
			rightWidth = 0;
			leftDoubleWidth = 0;
			rightDoubleWidth = 0;
			counter = 0;
			triggered = 0;
			for index, id in pairs(TitanPanelSettings.Buttons) do
				local button = TitanUtils_GetButton(id);
				
				if ( not button:GetWidth() ) then 
					return; 
				end
				if TitanUtils_GetWhichBar(id) == "AuxBar" then
					if TitanPanelGetVar("AuxDoubleBar") == 2 and mod(counter,2) == 1 and not TitanPanelButton_IsIcon(id) then
						if triggered == 0 then
							secondLeftButton = button;
							triggered = 1;
						end
						if ( TitanPanelButton_IsIcon(id) or (id == TITAN_CLOCK_ID and isClockOnRightSide) ) then
							rightDoubleWidth = rightDoubleWidth + TITAN_PANEL_ICON_SPACING + button:GetWidth();
						else
							counter = counter + 1;
							leftDoubleWidth = leftDoubleWidth + (TitanPanelGetVar("ButtonSpacing")) + button:GetWidth();
						end
					else
						if ( TitanPanelButton_IsIcon(id) or (id == TITAN_CLOCK_ID and isClockOnRightSide) ) then
							rightWidth = rightWidth + TITAN_PANEL_ICON_SPACING + button:GetWidth();
						else
							counter = counter + 1;
							leftWidth = leftWidth + (TitanPanelGetVar("ButtonSpacing")) + button:GetWidth();
						end
					end
				end
			end

			firstLeftButton:ClearAllPoints();
			firstLeftButton:SetPoint("LEFT", "TitanPanelAuxBarButton", "CENTER", 0 - leftWidth / 2, TITAN_PANEL_FROM_BOTTOM_MAIN); 
			if triggered == 1 then
				secondLeftButton:ClearAllPoints();
				secondLeftButton:SetPoint("LEFT", "TitanPanelAuxBarButton", "CENTER", 0 - leftDoubleWidth / 2, TITAN_PANEL_FROM_BOTTOM);
			end
		end
	end

end

function TitanPanel_SetScale()
	local scale = TitanPanelGetVar("Scale");
	TitanPanelBarButton:SetScale(scale);
	TitanPanelAuxBarButton:SetScale(scale);

	for index, value in pairs(TitanPlugins) do
		if index ~= nil then
			TitanUtils_GetButton(index):SetScale(scale);
		end
	end
end

function TitanPanelRightClickMenu_Customize() 
	StaticPopupDialogs["CUSTOMIZATION_FEATURE_COMING_SOON"] = {
		text = TEXT(CUSTOMIZATION_FEATURE_COMING_SOON),
		button1 = TEXT(OKAY),
		showAlert = 1,
		timeout = 0,
	};
	StaticPopup_Show("CUSTOMIZATION_FEATURE_COMING_SOON");
end

function TitanPanel_LoadError(ErrorMsg) 
	StaticPopupDialogs["LOADING_ERROR"] = {
		text = ErrorMsg,
		button1 = TEXT(OKAY),
		showAlert = 1,
		timeout = 0,
	};
	StaticPopup_Show("LOADING_ERROR");
end

function TitanPanel_istexture(path)
if TitanPanelGetVar("TexturePath") == path then
return 1;
end
return nil;
end

function TitanPanel_SetCustomTexture()
if this.value == TitanPanelGetVar("TexturePath") then
else
TitanPanelSetVar("TexturePath", this.value);
TitanPanel_SetTexture("TitanPanelBarButton", TITAN_PANEL_PLACE_TOP);
TitanPanel_SetTexture("TitanPanelAuxBarButton", TITAN_PANEL_PLACE_BOTTOM);
end
end

function TitanPanelRightClickMenu_PrepareBarMenu()
	-- Level 2
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		TitanPanel_BuildPluginsMenu();
		TitanPanel_BuildOtherPluginsMenu();
		TitanPanel_OptionsMenu();
		TitanPanel_LoadServerSettingsMenu();
		return;
	end
	
	-- Level 3
	if ( UIDROPDOWNMENU_MENU_LEVEL == 3 ) then
		TitanPanel_LoadPlayerSettingsMenu();
		return;
	end

	-- Level 1
	TitanPanel_MainMenu()
end

function TitanPanel_MainMenu()
	local info = {};
	local checked;
	local plugin;
	local frame = this:GetName();
	local frname = getglobal(frame);

	TitanPanelRightClickMenu_AddTitle(TITAN_PANEL_MENU_TITLE);

	if frame == "TitanPanelBarButton" or frame == "TitanPanelBarButtonHider" then
		info = {};
		info.text = TITAN_PANEL_MENU_BUILTINS;
		info.value = "Builtins";
		info.hasArrow = 1;
		UIDropDownMenu_AddButton(info);
	else
		info = {};
		info.text = TITAN_PANEL_MENU_BUILTINS;
		info.value = "BuiltinsAux";
		info.hasArrow = 1;
		UIDropDownMenu_AddButton(info);
	end

	TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL);
	TitanPanelRightClickMenu_AddTitle(TITAN_PANEL_MENU_PLUGINS);


	for index, id in pairs(TITAN_PANEL_MENU_CATEGORIES) do
		info = {};
		info.text = TITAN_PANEL_MENU_CATEGORIES[index];
		info.value = "Addons_" .. TITAN_PANEL_BUTTONS_PLUGIN_CATEGORY[index];
		info.hasArrow = 1;
		UIDropDownMenu_AddButton(info);
	end

	TitanPanelRightClickMenu_AddSpacer();	

	if frame == "TitanPanelBarButton" or frame == "TitanPanelBarButtonHider" then
		info = {};
		info.text = TITAN_PANEL_MENU_OPTIONS;
		info.value = "Options";
		info.hasArrow = 1;
		UIDropDownMenu_AddButton(info);
	else
		info = {};
		info.text = TITAN_PANEL_MENU_OPTIONS;
		info.value = "OptionsAux";
		info.hasArrow = 1;
		UIDropDownMenu_AddButton(info);
	end
	
	-- texture settings option menu
	info = {};
	info.text = TITAN_PANEL_MENU_TEXTURE_SETTINGS;
	info.value = "SkinSettings";
	info.hasArrow = 1;
	UIDropDownMenu_AddButton(info);
	
	info = {};
	info.text = TITAN_PANEL_MENU_LOAD_SETTINGS;
	info.value = "Settings";
	info.hasArrow = 1;
	-- lock this menu in combat
	if InCombatLockdown() then
		info.disabled = 1;
		info.hasArrow = nil;
		info.text = info.text.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN;
		end
	UIDropDownMenu_AddButton(info);
end

function TitanPanel_OptionsMenu()
	local info = {};
	local i,e;
	-- texture selection option menu
	if ( UIDROPDOWNMENU_MENU_VALUE == "SkinSettings" ) then
	   for i,e in pairs(TITAN_CUSTOM_TEXTURES) do
	     info.text = e.name;
	     info.value = e.path;
	     info.func = TitanPanel_SetCustomTexture;
			 info.checked = TitanPanel_istexture(e.path);
			 UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL);
			  if e.path == "Interface\\AddOns\\Titan\\Artwork\\" then
			  TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL);
			  TitanPanelRightClickMenu_AddTitle(TITAN_PANEL_MENU_SKINS, UIDROPDOWNMENU_MENU_LEVEL);
			  end
	   end
	end

	if ( UIDROPDOWNMENU_MENU_VALUE == "OptionsAux" ) then
   -- Panel Category	
	TitanPanelRightClickMenu_AddTitle(TITAN_PANEL_MENU_OPTIONS_PANEL, UIDROPDOWNMENU_MENU_LEVEL)
	  -- Auto-Hide
		info = {};
		info.text = TITAN_PANEL_MENU_AUTOHIDE;
		info.func = TitanPanelBarButton_ToggleAuxAutoHide;
		info.checked = TitanPanelGetVar("AuxAutoHide");
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
   -- Center text
		info = {};
		info.text = TITAN_PANEL_MENU_CENTER_TEXT;
		info.func = TitanPanelBarButton_ToggleAuxAlign;
		info.checked = (TitanPanelGetVar("AuxButtonAlign") == TITAN_PANEL_BUTTONS_ALIGN_CENTER);
		info.keepShownOnClick = 1;
			-- lock this item in combat
				if InCombatLockdown() then
				info.disabled = 1;
				info.text = info.text.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN;
				end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Lock buttons
		info = {};
		info.text = TITAN_PANEL_MENU_LOCK_BUTTONS;
		info.func = TitanPanelBarButton_ToggleButtonLock;
		info.checked = TitanPanelGetVar("LockButtons");
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Show plugin versions
		info = {};
		info.text = TITAN_PANEL_MENU_VERSION_SHOWN;
		info.func = TitanPanelBarButton_ToggleVersionShown;
		info.checked = TitanPanelGetVar("VersionShown");
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Reset Panel to default
		info = {};
		info.text = TITAN_PANEL_MENU_RESET.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_RELOADUI;
		info.func = TitanPanel_ResetBar;
				-- lock this item in combat
				if InCombatLockdown() then
				info.disabled = 1;
				info.text = info.text.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN;
				end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Bars Category
		TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL);
		TitanPanelRightClickMenu_AddTitle(TITAN_PANEL_MENU_OPTIONS_BARS, UIDROPDOWNMENU_MENU_LEVEL);
		-- Display on top
		info = {};
		info.text = TITAN_PANEL_MENU_DISPLAY_ONTOP;
		info.func = TitanPanelBarButton_TogglePosition;
		info.checked = (TitanPanelGetVar("Position") == TITAN_PANEL_PLACE_TOP);
		info.disabled = TitanPanelGetVar("BothBars")
		info.keepShownOnClick = 1;
		    -- lock this item in combat
				if InCombatLockdown() then
				info.disabled = 1;
				info.text = info.text.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN;
				end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	  -- Display both bars
		info = {};
		info.text = TITAN_PANEL_MENU_DISPLAY_BOTH;
		info.func = TitanPanelBarButton_ToggleBarsShown;
		info.checked = TitanPanelGetVar("BothBars");
		info.keepShownOnClick = 1;
		    -- lock this item in combat
				if InCombatLockdown() then
				info.disabled = 1;
				info.text = info.text.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN;
				end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Double Bar
		info = {};
		info.text = TITAN_PANEL_MENU_DOUBLE_BAR;
		info.func = TitanPanelBarButton_ToggleAuxDoubleBar;
		info.checked = TitanPanelGetVar("AuxDoubleBar") == TITAN_PANEL_BARS_DOUBLE;
		info.keepShownOnClick = 1;
		    -- lock this item in combat
				if InCombatLockdown() then
				info.disabled = 1;
				info.text = info.text.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN;
				end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Tooltips Category
		TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL);
		TitanPanelRightClickMenu_AddTitle(TITAN_PANEL_MENU_OPTIONS_TOOLTIPS, UIDROPDOWNMENU_MENU_LEVEL);
		-- Show tooltips
		info = {};
		info.text = TITAN_PANEL_MENU_TOOLTIPS_SHOWN;
		info.func = TitanPanelBarButton_ToggleToolTipsShown;
		info.checked = TitanPanelGetVar("ToolTipsShown");
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Hide tooltips in combat
		info = {};
		info.text = TITAN_PANEL_MENU_TOOLTIPS_SHOWN_IN_COMBAT;
		info.func = TitanPanelBarButton_ToggleToolTipsShownInCombat;
		info.checked = TitanPanelGetVar("HideTipsInCombat");
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Frames Category
		TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL);
		TitanPanelRightClickMenu_AddTitle(TITAN_PANEL_MENU_OPTIONS_FRAMES, UIDROPDOWNMENU_MENU_LEVEL);
		-- Disable Screen Adjust
		info = {};
		info.text = TITAN_PANEL_MENU_DISABLE_PUSH;
		info.func = TitanPanelBarButton_ToggleAuxScreenAdjust;
		info.checked = TitanPanelGetVar("AuxScreenAdjust");
		info.keepShownOnClick = 1;
		    -- lock this item in combat
				if InCombatLockdown() then
				info.disabled = 1;
				info.text = info.text.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN;
				end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Disable Minimap Adjust
		info = {};
		info.text = TITAN_PANEL_MENU_DISABLE_MINIMAP_PUSH;
		info.func = TitanPanelBarButton_ToggleMinimapAdjust;
		info.checked = TitanPanelGetVar("MinimapAdjust");
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Automatic log adjust
		info = {};
		info.text = TITAN_PANEL_MENU_DISABLE_LOGS;
		info.func = TitanPanelBarButton_ToggleLogAdjust;
		info.checked = TitanPanelGetVar("LogAdjust");
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Move Casting Bar
		info = {};
		info.text = TITAN_PANEL_MENU_CASTINGBAR.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_RELOADUI;
		info.func = TitanPanelBarButton_ToggleCastingBar;
		info.checked = TitanPanelGetVar("CastingBar");
		info.keepShownOnClick = 1;
		   -- lock this item in combat
				if InCombatLockdown() then
				info.disabled = 1;
				info.text = info.text.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN;
				end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

	end
	
	if ( UIDROPDOWNMENU_MENU_VALUE == "Options" ) then
	  -- Panel Category	
	TitanPanelRightClickMenu_AddTitle(TITAN_PANEL_MENU_OPTIONS_PANEL, UIDROPDOWNMENU_MENU_LEVEL)
	  -- Auto-Hide
		info = {};
		info.text = TITAN_PANEL_MENU_AUTOHIDE;
		info.func = TitanPanelBarButton_ToggleAutoHide;
		info.checked = TitanPanelGetVar("AutoHide");
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
   -- Center text
		info = {};
		info.text = TITAN_PANEL_MENU_CENTER_TEXT;
		info.func = TitanPanelBarButton_ToggleAlign;
		info.checked = (TitanPanelGetVar("ButtonAlign") == TITAN_PANEL_BUTTONS_ALIGN_CENTER);
		info.keepShownOnClick = 1;
		    -- lock this item in combat
				if InCombatLockdown() then
				info.disabled = 1;
				info.text = info.text.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN;
				end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Lock buttons
		info = {};
		info.text = TITAN_PANEL_MENU_LOCK_BUTTONS;
		info.func = TitanPanelBarButton_ToggleButtonLock;
		info.checked = TitanPanelGetVar("LockButtons");
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Show plugin versions
		info = {};
		info.text = TITAN_PANEL_MENU_VERSION_SHOWN;
		info.func = TitanPanelBarButton_ToggleVersionShown;
		info.checked = TitanPanelGetVar("VersionShown");
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Reset Panel to default
		info = {};
		info.text = TITAN_PANEL_MENU_RESET.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_RELOADUI;
		info.func = TitanPanel_ResetBar;
		    -- lock this item in combat
				if InCombatLockdown() then
				info.disabled = 1;
				info.text = info.text.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN;
				end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Bars Category
		TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL);
		TitanPanelRightClickMenu_AddTitle(TITAN_PANEL_MENU_OPTIONS_BARS, UIDROPDOWNMENU_MENU_LEVEL);
		-- Display on top
		info = {};
		info.text = TITAN_PANEL_MENU_DISPLAY_ONTOP;
		info.func = TitanPanelBarButton_TogglePosition;
		info.checked = (TitanPanelGetVar("Position") == TITAN_PANEL_PLACE_TOP);
		info.disabled = TitanPanelGetVar("BothBars")
		info.keepShownOnClick = 1;
		    -- lock this item in combat
				if InCombatLockdown() then
				info.disabled = 1;
				info.text = info.text.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN;
				end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	  -- Display both bars
		info = {};
		info.text = TITAN_PANEL_MENU_DISPLAY_BOTH;
		info.func = TitanPanelBarButton_ToggleBarsShown;
		info.checked = TitanPanelGetVar("BothBars");
		info.keepShownOnClick = 1;
		    -- lock this item in combat
				if InCombatLockdown() then
				info.disabled = 1;
				info.text = info.text.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN;
				end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Double Bar
		info = {};
		info.text = TITAN_PANEL_MENU_DOUBLE_BAR;
		info.func = TitanPanelBarButton_ToggleDoubleBar;
		info.checked = TitanPanelGetVar("DoubleBar") == TITAN_PANEL_BARS_DOUBLE;
		info.keepShownOnClick = 1;
		    -- lock this item in combat
				if InCombatLockdown() then
				info.disabled = 1;
				info.text = info.text.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN;
				end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Tooltips Category
		TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL);
		TitanPanelRightClickMenu_AddTitle(TITAN_PANEL_MENU_OPTIONS_TOOLTIPS, UIDROPDOWNMENU_MENU_LEVEL);
		-- Show tooltips
		info = {};
		info.text = TITAN_PANEL_MENU_TOOLTIPS_SHOWN;
		info.func = TitanPanelBarButton_ToggleToolTipsShown;
		info.checked = TitanPanelGetVar("ToolTipsShown");
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Hide tooltips in combat
		info = {};
		info.text = TITAN_PANEL_MENU_TOOLTIPS_SHOWN_IN_COMBAT;
		info.func = TitanPanelBarButton_ToggleToolTipsShownInCombat;
		info.checked = TitanPanelGetVar("HideTipsInCombat");
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Frames Category
		TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL);
		TitanPanelRightClickMenu_AddTitle(TITAN_PANEL_MENU_OPTIONS_FRAMES, UIDROPDOWNMENU_MENU_LEVEL);
		-- Disable Screen Adjust
		info = {};
		info.text = TITAN_PANEL_MENU_DISABLE_PUSH;
		info.func = TitanPanelBarButton_ToggleScreenAdjust;
		info.checked = TitanPanelGetVar("ScreenAdjust");
		info.keepShownOnClick = 1;
		    -- lock this item in combat
				if InCombatLockdown() then
				info.disabled = 1;
				info.text = info.text.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN;
				end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Disable Minimap Adjust
		info = {};
		info.text = TITAN_PANEL_MENU_DISABLE_MINIMAP_PUSH;
		info.func = TitanPanelBarButton_ToggleMinimapAdjust;
		info.checked = TitanPanelGetVar("MinimapAdjust");
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Automatic log adjust
		info = {};
		info.text = TITAN_PANEL_MENU_DISABLE_LOGS;
		info.func = TitanPanelBarButton_ToggleLogAdjust;
		info.checked = TitanPanelGetVar("LogAdjust");
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		-- Move Casting Bar
		info = {};
		info.text = TITAN_PANEL_MENU_CASTINGBAR.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_RELOADUI;
		info.func = TitanPanelBarButton_ToggleCastingBar;
		info.checked = TitanPanelGetVar("CastingBar");
		info.keepShownOnClick = 1;
		   -- lock this item in combat
			 if InCombatLockdown() then
			 info.disabled = 1;
			 info.text = info.text.." "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN;
			 end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	end
end

function TitanPanel_LoadServerSettingsMenu()
	local info = {};
	local servers = {};
	local server = nil;
	local s, e, ident;


	if ( UIDROPDOWNMENU_MENU_VALUE == "Settings" ) then
		for index, id in pairs(TitanSettings.Players) do
			s, e, ident = string.find(index, "@");
			if s ~= nil then
				server = string.sub(index, s+1);
			else
				server = "Unknown";
			end
			
			if TitanUtils_GetCurrentIndex(servers, server) == nil then
				table.insert(servers, server);	
				info = {};
				info.text = server;
				info.value = server;
				info.hasArrow = 1;
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end
		end
	end
end

function TitanPanel_LoadPlayerSettingsMenu()
	local info = {};
	local player = nil;
	local server = nil;
	local s, e, ident;


	for index, id in pairs(TitanSettings.Players) do
		s, e, ident = string.find(index, "@");
		if s ~= nil then
			server = string.sub(index, s+1);
			player = string.sub(index, 1, s-1);
		else
			server = "Unknown";
			player = "Unknown";
		end
		
		if server == UIDROPDOWNMENU_MENU_VALUE then
			info = {};
			info.text = player;
			info.value = index;
			info.func = TitanVariables_UseSettings;
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		end
	end
end

function TitanPanel_BuildOtherPluginsMenu()
	local info = {};
	local checked;
	local plugin;
	local frame = this:GetName();
	local frname = getglobal(frame);

	for index, id in pairs(TitanPluginsIndex) do
		plugin = TitanUtils_GetPlugin(id);
		if not plugin.category then
			plugin.category = "General";
		end
			
		if ( UIDROPDOWNMENU_MENU_VALUE == "Addons_" .. plugin.category ) then
			if (not plugin.builtIn) then
				checked = nil;
				if ( TitanPanel_IsPluginShown(id) ) then
					checked = 1;
				end
				
				info = {};
				if plugin.version ~= nil and TitanPanelGetVar("VersionShown") then
					info.text = plugin.menuText .. TitanUtils_GetGreenText(" (v" .. plugin.version .. ")");
				else
					info.text = plugin.menuText;
				end
				info.value = id;
				info.func = TitanPanelRightClickMenu_BarOnClick;
				info.checked = checked;
				info.keepShownOnClick = 1;
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end
		end
	end
end

function TitanPanel_BuildPluginsMenu()
	local info = {};
	local checked;
	local plugin;

	if ( UIDROPDOWNMENU_MENU_VALUE == "Builtins" ) then
		TitanPanelRightClickMenu_AddTitle(TITAN_PANEL_MENU_LEFT_SIDE, UIDROPDOWNMENU_MENU_LEVEL);
		
		for index, id in pairs(TitanPluginsIndex) do
			plugin = TitanUtils_GetPlugin(id);
			if ( plugin.builtIn and ( TitanPanel_GetPluginSide(id) == "Left") ) then
				checked = nil;
				if ( TitanPanel_IsPluginShown(id) ) then
					checked = 1;
				end
		
				info = {};
				if plugin.menuText ~= nil and plugin.version ~= nil and TitanPanelGetVar("VersionShown") then
					info.text = plugin.menuText .. TitanUtils_GetGreenText(" (v" .. plugin.version .. ")");
				elseif plugin.menuText ~= nil then
					info.text = plugin.menuText;
				else
					info.text = plugin.id;
				end
				info.value = id;
				info.func = TitanPanelRightClickMenu_BarOnClick;
				info.checked = checked;
				info.keepShownOnClick = 1;
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end
		end
		
		TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL);
		TitanPanelRightClickMenu_AddTitle(TITAN_PANEL_MENU_RIGHT_SIDE, UIDROPDOWNMENU_MENU_LEVEL);
	
		for index, id in pairs(TitanPluginsIndex) do
			plugin = TitanUtils_GetPlugin(id);
			if ( plugin.builtIn and ( TitanPanel_GetPluginSide(id) == "Right") ) then
				checked = nil;
				if ( TitanPanel_IsPluginShown(id) ) then
					checked = 1;
				end
		
				if id ~= "AuxAutoHide" then
					info = {};
					if plugin.version ~= nil and TitanPanelGetVar("VersionShown") then
						info.text = plugin.menuText .. TitanUtils_GetGreenText(" (v" .. plugin.version .. ")");
					else
						info.text = plugin.menuText;
					end
					info.value = id;
					info.func = TitanPanelRightClickMenu_BarOnClick;
					info.checked = checked;
					info.keepShownOnClick = 1;
					UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
				end
			end
		end
	end		
	if ( UIDROPDOWNMENU_MENU_VALUE == "BuiltinsAux" ) then
		TitanPanelRightClickMenu_AddTitle(TITAN_PANEL_MENU_LEFT_SIDE, UIDROPDOWNMENU_MENU_LEVEL);
		
		for index, id in pairs(TitanPluginsIndex) do
			plugin = TitanUtils_GetPlugin(id);
			if ( plugin.builtIn and ( TitanPanel_GetPluginSide(id) == "Left") ) then
				checked = nil;
				if ( TitanPanel_IsPluginShown(id) ) then
					checked = 1;
				end
		
				info = {};
				if plugin.version ~= nil and TitanPanelGetVar("VersionShown") then
					info.text = plugin.menuText .. TitanUtils_GetGreenText(" (v" .. plugin.version .. ")");
				else
					info.text = plugin.menuText;
				end
				info.value = id;
				info.func = TitanPanelRightClickMenu_BarOnClick;
				info.checked = checked;
				info.keepShownOnClick = 1;
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end
		end
		
		TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL);	
		TitanPanelRightClickMenu_AddTitle(TITAN_PANEL_MENU_RIGHT_SIDE, UIDROPDOWNMENU_MENU_LEVEL);
	
		for index, id in pairs(TitanPluginsIndex) do
			plugin = TitanUtils_GetPlugin(id);
			if ( plugin.builtIn and ( TitanPanel_GetPluginSide(id) == "Right") ) then
				checked = nil;
				if ( TitanPanel_IsPluginShown(id) ) then
					checked = 1;
				end
		
				if id ~= "AutoHide" then
					info = {};
					if plugin.version ~= nil and TitanPanelGetVar("VersionShown") then
						info.text = plugin.menuText .. TitanUtils_GetGreenText(" (v" .. plugin.version .. ")");
					else
						info.text = plugin.menuText;
					end
					info.value = id;
					info.func = TitanPanelRightClickMenu_BarOnClick;
					info.checked = checked;
					info.keepShownOnClick = 1;
					UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
				end
			end
		end
	end
end

function TitanPanel_IsPluginShown(id)
	if ( id and TitanPanelSettings ) then
		return TitanUtils_TableContainsValue(TitanPanelSettings.Buttons, id);
	end
end

function TitanPanel_GetPluginSide(id)
	if ( id == TITAN_CLOCK_ID and TitanGetVar(TITAN_CLOCK_ID, "DisplayOnRightSide") ) then
		return "Right";
	elseif ( TitanPanelButton_IsIcon(id) ) then
		return "Right";
	else
		return "Left";
	end
end

function TitanPanel_ResetBar()
	local playerName = UnitName("player");
	local serverName = GetCVar("realmName");

	TitanCopyPlayerSettings = TitanSettings.Players[playerName.."@"..serverName];
	TitanCopyPluginSettings = TitanCopyPlayerSettings["Plugins"];

	for index, id in pairs (TitanPanelSettings["Buttons"]) do
		local currentButton = TitanUtils_GetButton(TitanPanelSettings["Buttons"][index]);
		currentButton:Hide();					
	end

	TitanSettings.Players[playerName.."@"..serverName] = {};
	TitanSettings.Players[playerName.."@"..serverName].Plugins = {};
	TitanSettings.Players[playerName.."@"..serverName].Panel = {}
	TitanSettings.Players[playerName.."@"..serverName].Panel.Buttons = TITAN_PANEL_INITIAL_PLUGINS;
	TitanSettings.Players[playerName.."@"..serverName].Panel.Locations = TITAN_PANEL_INITIAL_PLUGIN_LOCATION;
	
	TITAN_FIRST_LOAD = 1;		

	-- Set global variables
	TitanPlayerSettings = TitanSettings.Players[playerName.."@"..serverName];
	TitanPluginSettings = TitanPlayerSettings["Plugins"];
	TitanPanelSettings = TitanPlayerSettings["Panel"];	

	ReloadUI()
end

TitanPanelDetails = {
	name = "Titan Panel (Multibar)",
	description = "Adds a control panel/info box at the top and bottom of the screen.",
	version = TITAN_VERSION,
	releaseDate = TITAN_LAST_UPDATED,
	author = "Titan Development Team",
	email = "",
	website = "http://ui.worldofwar.net/ui.php?id=1442",
	category = MYADDONS_CATEGORY_BARS,
	frame = "TitanPanel",
	optionsframe = "",
};

TitanPanelHelp = {};
TitanPanelHelp[1] = "Titan Panel adds a control panel/info box at the top and bottom of the screen.\n\nFeatures include:\n1. Ammo/Thrown counter\n2. Bag\n3. Experience (XP)\n4. FPS\n5. Latency\n6. Location\n7. Loot Type\n8. Memory\n9. Gold Tracker\n10. PvP Honor\n11. Clock\n\nAlso build-in controls allow you to:\n1. Adjust master sound volume\n2. Adjust UI Scale\n3. Adjust panel transparency\n4. Toggle auto-hide on/off\n\nFully support plug-ins system. All modules on the panel are plug-n-play. Allows other developers to create plugins to import the new features.\n\n\nThanks go to\n- Sotakone, for providing a bug fix for German clients\n- Kilan, for submitting code which makes Titan Panel save per-realm-per-character";

function TitanPanelFrame_OnLoad()
	-- Register the events that need to be watched
	this:RegisterEvent("VARIABLES_LOADED");
end

function TitanPanelFrame_OnEvent()
	if(event == "VARIABLES_LOADED") then
		-- Check if myAddOns is loaded
		if(myAddOnsFrame_Register) then
			-- Register the addon in myAddOns
			myAddOnsFrame_Register(TitanPanelDetails, TitanPanelHelp);
		end
	end
end
