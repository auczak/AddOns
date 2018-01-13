-- Constants
TITAN_PANEL_UPDATE_BUTTON = 1;
TITAN_PANEL_UPDATE_TOOLTIP = 2;
TITAN_PANEL_UPDATE_ALL = 3;
TITAN_PANEL_LABEL_SEPARATOR = "  "

TITAN_PANEL_BUTTON_TYPE_TEXT = 1;
TITAN_PANEL_BUTTON_TYPE_ICON = 2;
TITAN_PANEL_BUTTON_TYPE_COMBO = 3;
TITAN_PANEL_BUTTON_TYPE_CUSTOM = 4;
local TITAN_BUTTON_DOWN;

function TitanOptionSlider_TooltipText(text, value) 
	return text .. GREEN_FONT_COLOR_CODE .. value .. FONT_COLOR_CODE_CLOSE;
end

function TitanPanelButton_OnLoad(isChildButton)
	if (isChildButton) then
		this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		TitanPanelDetectPluginMethod(this:GetName(), 1);
	else 
		TitanUtils_RegisterPlugin(this.registry);		
		local plugin = TitanUtils_GetPlugin();
		if (plugin) then
			this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
			-- make sure that plugin has a valid id before detecting its methods
			if (plugin.id) then
			TitanPanelDetectPluginMethod(plugin.id);
			end
		end
	end
end

function TitanPanelPluginHandle_OnUpdate(id, updateType)
-- id is required
	if (id) then
  	local Titanpluginframe = getglobal ("TitanPanel"..id.."Button");

			if (updateType == TITAN_PANEL_UPDATE_BUTTON) or (updateType == TITAN_PANEL_UPDATE_ALL) then
 				TitanPanelButton_UpdateButton(id);
			end

			if ((updateType == TITAN_PANEL_UPDATE_TOOLTIP) or (updateType == TITAN_PANEL_UPDATE_ALL)) and MouseIsOver(Titanpluginframe) then
			    if (TitanPanelRightClickMenu_IsVisible()) or TITAN_PANEL_MOVING == 1 then
					return
					end
   			TitanPanelButton_SetTooltip(id);
			end
	end
end

function TitanPanelDetectPluginMethod(id, isChildButton)
-- detect button methods and inject a delay for dragging while keeping their code intact
local TitanPluginframe = getglobal("TitanPanel"..id.."Button");
  if isChildButton ~= nil then
    TitanPluginframe = getglobal(id);
  end
	local TITAN_PREVENT_CLICK;
	if TitanPluginframe:HasScript("OnClick") then
		local OnClick = TitanPluginframe:GetScript("OnClick")
		TitanPluginframe:SetScript("OnClick", function(...)
			if OnClick and (not TITAN_BUTTON_DOWN or GetTime() < TITAN_BUTTON_DOWN + 0.3) and (not TITAN_PREVENT_CLICK or GetTime() > TITAN_PREVENT_CLICK) then
				OnClick(...)
			end
			TITAN_BUTTON_DOWN = nil
		end)
	end
	local OnMouseDown = TitanPluginframe:GetScript("OnMouseDown")
	TitanPluginframe:SetScript("OnMouseDown", function(...)
		if arg1 == "LeftButton" and not IsShiftKeyDown() and not IsControlKeyDown() and not IsAltKeyDown() then
			TITAN_BUTTON_DOWN = GetTime();
			 if isChildButton ~= nil then
    			TitanPanelButton_OnMouseDown(arg1, id);
    	 else
    	    TitanPanelButton_OnMouseDown(arg1);
  		 end
		end
		if OnMouseDown then
			OnMouseDown(...)
		end
	end)
	local OnMouseUp = TitanPluginframe:GetScript("OnMouseUp")
	TitanPluginframe:SetScript("OnMouseUp", function(...)
		if arg1 == "LeftButton" then
		  if isChildButton ~= nil then
				     TitanPanelButton_OnMouseUp(arg1, id)
				  end 
			if not TitanPanelButton_OnMouseUp(arg1) then
				if OnMouseUp then
					OnMouseUp(...)
				end
			else
				TITAN_PREVENT_CLICK = GetTime() + 0.05
			end
		elseif OnMouseUp then
			OnMouseUp(...)
		end
	end)

end

function TitanPanelButton_OnShow()	
	local id = TitanUtils_GetButtonID();
	if (id) then		
		TitanPanelButton_UpdateButton(id, 1);
	end
end

function TitanPanelButton_OnClick(button, isChildButton)

	local id = TitanUtils_Ternary(isChildButton, TitanUtils_GetParentButtonID(), TitanUtils_GetButtonID());
	
	if (id) then
		local controlFrame = TitanUtils_GetControlFrame(id);
		local rightClickMenu = getglobal("TitanPanelRightClickMenu");
	
		if (button == "LeftButton") then
			local isControlFrameShown;
			if (not controlFrame) then
				isControlFrameShown = false;
			elseif (controlFrame:IsVisible()) then
				isControlFrameShown = false;
			else
				isControlFrameShown = true;
			end
			
			TitanUtils_CloseAllControlFrames();	
			TitanPanelRightClickMenu_Close();	
		
			local position = TitanPanelGetVar("Position");
			local scale = TitanPanelGetVar("Scale");
			if (isControlFrameShown) then
				local buttonCenter = (this:GetLeft() + this:GetRight()) / 2 * scale;
				local controlFrameRight = buttonCenter + controlFrame:GetWidth() / 2;
				if ( position == TITAN_PANEL_PLACE_TOP ) then 
					controlFrame:ClearAllPoints();
					controlFrame:SetPoint("TOP", "UIParent", "TOPLEFT", buttonCenter, -24 * scale);	
					
					-- Adjust control frame position if it's off the screen
					local offscreenX, offscreenY = TitanUtils_GetOffscreen(controlFrame);
					if ( offscreenX == -1 ) then
						controlFrame:ClearAllPoints();
						controlFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 0, -24 * scale);	
					elseif ( offscreenX == 1 ) then
						controlFrame:ClearAllPoints();
						controlFrame:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", 0, -24 * scale);	
					end							
				else
					controlFrame:ClearAllPoints();
					controlFrame:SetPoint("BOTTOM", "UIParent", "BOTTOMLEFT", buttonCenter, 24 * scale); 

					-- Adjust control frame position if it's off the screen
					local offscreenX, offscreenY = TitanUtils_GetOffscreen(controlFrame);
					if ( offscreenX == -1 ) then
						controlFrame:ClearAllPoints();
						controlFrame:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 24 * scale);	
					elseif ( offscreenX == 1 ) then
						controlFrame:ClearAllPoints();
						controlFrame:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", 0, 24 * scale);	
					end							
				end
				
				controlFrame:Show();
			end	
		elseif (button == "RightButton") then
			TitanUtils_CloseAllControlFrames();	
		
			-- Show RightClickMenu anyway
			if (TitanPanelRightClickMenu_IsVisible()) then
				TitanPanelRightClickMenu_Close();
			end
			TitanPanelRightClickMenu_Toggle();
		end

		GameTooltip:Hide();
	end
end

function TitanPanelButton_OnEnter(isChildButton)
	local id = TitanUtils_Ternary(isChildButton, TitanUtils_GetParentButtonID(), TitanUtils_GetButtonID());
	
	if (id) then
	local hasTimer = TitanPanel:HasTimer("TitanAutoHider")
		 if hasTimer then
		  TitanPanel:RemoveTimer("TitanAutoHider")
		 end
			--TITAN_PANEL_DROPOFF_ADDON = id;
		--TitanUtils_StopAutoHideCounting(this:GetName());
		local controlFrame = TitanUtils_GetControlFrame(id);
		if (controlFrame and controlFrame:IsVisible()) then
			return;
		elseif (TitanPanelRightClickMenu_IsVisible()) then
			return;
		else
			TitanPanelButton_SetTooltip(id);
		end	
	end
end

function TitanPanelButton_OnLeave(isChildButton)
	local id = TitanUtils_Ternary(isChildButton, TitanUtils_GetParentButtonID(), TitanUtils_GetButtonID());
	
	if (id) then
	--TITAN_PANEL_DROPOFF_ADDON = nil;
		--TitanUtils_StartAutoHideCounting();
		GameTooltip:Hide();
		-- routine to handle autohide
		local plugin = TitanUtils_GetCurrentIndex(TitanPanelSettings.Buttons,id);
		if (TitanPanelGetVar("AutoHide")) and TitanPanelSettings.Location[plugin] == "Bar" then
		TitanPanel:AddRepeatingTimer("TitanAutoHider", 0.5, Handle_OnUpdateAutoHide)
		end
		if (TitanPanelGetVar("AuxAutoHide")) and TitanPanelSettings.Location[plugin] == "AuxBar" then
		TitanPanel:AddRepeatingTimer("TitanAutoHider", 0.5, Handle_OnUpdateAutoHide)
		end
	end
	   if not TitanPanelGetVar("DisableTooltipFont") then
			-- reset original Tooltip Scale
			GameTooltip:SetScale(TitanTooltipOrigScale);
			TitanTooltipScaleSet = 0;
		 end
		 TITAN_BUTTON_DOWN = nil;
end

function TitanPanelButton_UpdateButton(id, setButtonWidth) 
	local button, id = TitanUtils_GetButton(id, true);
	
	if ( TitanPanelButton_IsText(id) ) then
		-- Update textButton
		TitanPanelButton_SetButtonText(id);
		TitanPanelButton_SetTextButtonWidth(id, setButtonWidth);	
		
	elseif ( TitanPanelButton_IsIcon(id) ) then
		-- Update iconButton
		TitanPanelButton_SetButtonIcon(id);
		TitanPanelButton_SetIconButtonWidth(id);	
		
	elseif ( TitanPanelButton_IsCombo(id) ) then
		-- Update comboButton
		TitanPanelButton_SetButtonText(id);
		TitanPanelButton_SetButtonIcon(id);
		TitanPanelButton_SetComboButtonWidth(id, setButtonWidth);
	end
end

function TitanPanelButton_UpdateTooltip() 
	if (GameTooltip:IsOwned(this)) then
		local id = TitanUtils_GetButtonID();
		TitanPanelButton_SetTooltip(id);
	end
end

-- id is required
function TitanPanelButton_SetButtonText(id) 
	if (id and TitanUtils_IsPluginRegistered(id)) then
		local button = TitanUtils_GetButton(id);
		local buttonText = getglobal(button:GetName().."Text");
		local buttonTextFunction = getglobal(TitanUtils_GetPlugin(id).buttonTextFunction);
		if (buttonTextFunction) then
			local label1, value1, label2, value2, label3, value3, label4, value4 = buttonTextFunction(id);	
			local text = "";
			if ( label1 and not ( label2 or label3 or label4 or value1 or value2 or value3 or value4 ) ) then
				text = label1;
			elseif (TitanGetVar(id, "ShowLabelText")) then
				if (label1 or value1) then
					text = TitanUtils_ToString(label1)..TitanUtils_ToString(value1);
					if (label2 or value2) then
						text = text..TITAN_PANEL_LABEL_SEPARATOR..TitanUtils_ToString(label2)..TitanUtils_ToString(value2);
						if (label3 or value3) then
							text = text..TITAN_PANEL_LABEL_SEPARATOR..TitanUtils_ToString(label3)..TitanUtils_ToString(value3);
							if (label4 or value4) then
								text = text..TITAN_PANEL_LABEL_SEPARATOR..TitanUtils_ToString(label4)..TitanUtils_ToString(value4);
							end
						end
					end
				end
			else
				if (value1) then
					text = TitanUtils_ToString(value1);
					if (value2) then
						text = text..TITAN_PANEL_LABEL_SEPARATOR..TitanUtils_ToString(value2);
						if (value3) then
							text = text..TITAN_PANEL_LABEL_SEPARATOR..TitanUtils_ToString(value3);
							if (value4) then
								text = text..TITAN_PANEL_LABEL_SEPARATOR..TitanUtils_ToString(value4);
							end
						end
					end
				end
			end
			buttonText:SetText(text);			
		end	
	end
end

-- id is required
function TitanPanelButton_SetButtonIcon(id) 	
	if (id and TitanUtils_IsPluginRegistered(id)) then
		local button = TitanUtils_GetButton(id);
		local icon = getglobal(button:GetName().."Icon");			
		local iconTexture = TitanUtils_GetPlugin(id).icon;
		local iconWidth = TitanUtils_GetPlugin(id).iconWidth;
		
		if (iconTexture) then
			icon:SetTexture(iconTexture);
		end
		if (iconWidth) then
			icon:SetWidth(iconWidth);
		end
	end
end

-- id is required
function TitanPanelButton_SetTextButtonWidth(id, setButtonWidth) 
	if (id) then
		local button = TitanUtils_GetButton(id);
		local text = getglobal(button:GetName().."Text");
		if ( setButtonWidth or
				button:GetWidth() == 0 or 
				button:GetWidth() - text:GetWidth() > TITAN_PANEL_BUTTON_WIDTH_CHANGE_TOLERANCE or 
				button:GetWidth() - text:GetWidth() < -TITAN_PANEL_BUTTON_WIDTH_CHANGE_TOLERANCE ) then
			button:SetWidth(text:GetWidth());
			TitanPanelButton_Justify();
		end
	end
end

-- id is required
function TitanPanelButton_SetIconButtonWidth(id) 
	if (id) then
		local button = TitanUtils_GetButton(id);
		local icon = getglobal(button:GetName().."Icon");	
		if ( TitanUtils_GetPlugin(id).iconButtonWidth ) then
			button:SetWidth(TitanUtils_GetPlugin(id).iconButtonWidth);
		end		
	end
end

-- id is required
function TitanPanelButton_SetComboButtonWidth(id, setButtonWidth) 
	if (id) then
		local button = TitanUtils_GetButton(id);
		local text = getglobal(button:GetName().."Text");
		local icon = getglobal(button:GetName().."Icon");	
		local iconWidth, iconButtonWidth, newButtonWidth;
		
		-- Get icon button width
		iconButtonWidth = 0;
		if ( TitanUtils_GetPlugin(id).iconButtonWidth ) then
			iconButtonWidth = TitanUtils_GetPlugin(id).iconButtonWidth;
		elseif ( icon:GetWidth() ) then
			iconButtonWidth = icon:GetWidth();
		end

		if ( TitanGetVar(id, "ShowIcon") and ( iconButtonWidth ~= 0 ) ) then
			icon:Show();
			text:ClearAllPoints();
			text:SetPoint("LEFT", icon:GetName(), "RIGHT", 2, 1);
			
			newButtonWidth = text:GetWidth() + iconButtonWidth + 2;
		else
			icon:Hide();
			text:ClearAllPoints();
			text:SetPoint("LEFT", button:GetName(), "Left", 0, 1);
			
			newButtonWidth = text:GetWidth();
		end
		
		if ( setButtonWidth or
				button:GetWidth() == 0 or 
				button:GetWidth() - newButtonWidth > TITAN_PANEL_BUTTON_WIDTH_CHANGE_TOLERANCE or 
				button:GetWidth() - newButtonWidth < -TITAN_PANEL_BUTTON_WIDTH_CHANGE_TOLERANCE ) then
			button:SetWidth(newButtonWidth);
			TitanPanelButton_Justify();
		end			
	end
end

-- id is required
function TitanPanelButton_SetTooltip(id)
   this.tooltipCustomFunction = nil;
	if (id and TitanUtils_IsPluginRegistered(id)) then
		local plugin = TitanUtils_GetPlugin(id);		
		if ( plugin.tooltipCustomFunction ) then
			this.tooltipCustomFunction = plugin.tooltipCustomFunction;
			TitanTooltip_SetPanelTooltip(id);
		elseif ( plugin.tooltipTitle ) then
			this.tooltipTitle = plugin.tooltipTitle;	
			local tooltipTextFunc = getglobal(plugin.tooltipTextFunction);
			if ( tooltipTextFunc ) then
				this.tooltipText = tooltipTextFunc();
			end
			TitanTooltip_SetPanelTooltip(id);
		end
	end
end

function TitanPanelButton_GetType(id)
	-- id is required
	if (not id) then
		return;
	end
	
	local button = TitanUtils_GetButton(id);
	local type;
	if button then
		local text = getglobal(button:GetName().."Text");
		local icon = getglobal(button:GetName().."Icon");

		if (text and icon) then
			type = TITAN_PANEL_BUTTON_TYPE_COMBO;
		elseif (text and not icon) then
			type = TITAN_PANEL_BUTTON_TYPE_TEXT;
		elseif (not text and icon) then
			type = TITAN_PANEL_BUTTON_TYPE_ICON;
		elseif (not text and not icon) then
			type = TITAN_PANEL_BUTTON_TYPE_CUSTOM;
		end
	else
		type = TITAN_PANEL_BUTTON_TYPE_COMBO;
	end
	
	return type;
end

function TitanPanelButton_IsText(id) 
	if (TitanPanelButton_GetType(id) == TITAN_PANEL_BUTTON_TYPE_TEXT) then
		return 1;
	end
end

function TitanPanelButton_IsIcon(id)
	if (TitanPanelButton_GetType(id) == TITAN_PANEL_BUTTON_TYPE_ICON) then
		return 1;
	end
end

function TitanPanelButton_IsCombo(id)
	if (TitanPanelButton_GetType(id) == TITAN_PANEL_BUTTON_TYPE_COMBO) then
		return 1;
	end
end

function TitanPanelButton_IsCustom(id)
	if (TitanPanelButton_GetType(id) == TITAN_PANEL_BUTTON_TYPE_CUSTOM) then
		return 1;
	end
end

function TitanPanelButton_OnMouseDown(button, ChildButton)
	if TitanPanelGetVar("LockButtons") or InCombatLockdown() then
	return;
	end
	local frameparent;
	local frname = getglobal("TitanPanel" .. TitanUtils_GetButtonID() .. "Button");
	if ChildButton ~=nil then
	  local framechild = getglobal(ChildButton);
	  frameparent = TitanUtils_GetButtonID(framechild:GetParent():GetName());
	  frname = getglobal("TitanPanel"..frameparent.."Button");
	end
	if( button == "LeftButton") and not IsShiftKeyDown() and not IsControlKeyDown() and not IsAltKeyDown() then
	  local i,j;
	  for i, j in pairs(TitanPanelSettings.Buttons) do
	  local pluginid = getglobal("TitanPanel"..TitanPanelSettings.Buttons[i].."Button");
	  pluginid:ClearAllPoints();
	  end
		frname:StartMoving();
		frname.isMoving = true;
		GameTooltip:Hide();
		TITAN_PANEL_MOVE_ADDON = TitanUtils_GetButtonID();
		if ChildButton ~=nil then
		  TITAN_PANEL_MOVE_ADDON = frameparent;
		end
		TITAN_PANEL_MOVING = 1;
	end
end

function TitanPanelButton_OnMouseUp(button, ChildButton)
  if TitanPanelGetVar("LockButtons") then
	return;
	end
  local i, frameparent;
  local nonmovableFrom = false;
  local nonmovableTo = false;
	local frname = getglobal("TitanPanel" .. TitanUtils_GetButtonID() .. "Button");
	if ChildButton ~=nil then
	  local framechild = getglobal(ChildButton);
	  frameparent = TitanUtils_GetButtonID(framechild:GetParent():GetName());
	  frname = getglobal("TitanPanel"..frameparent.."Button");
	end
	if( button == "LeftButton" and TITAN_PANEL_MOVING == 1 ) then
		frname:StopMovingOrSizing();
		frname.isMoving = false;	  
		TitanUtils_CloseRightClickMenu();
		TITAN_PANEL_MOVING = 0;
		
		local i,j;
	  for i, j in pairs(TitanPanelSettings.Buttons) do
	  local pluginid = getglobal("TitanPanel"..TitanPanelSettings.Buttons[i].."Button");
	  if (MouseIsOver(pluginid)) and frname ~= pluginid then
	  TITAN_PANEL_DROPOFF_ADDON = TitanPanelSettings.Buttons[i];
	  end
	  end
		
		for i, _ in ipairs(TITAN_PANEL_NONMOVABLE_PLUGINS) do
		  if TITAN_PANEL_MOVE_ADDON == TITAN_PANEL_NONMOVABLE_PLUGINS[i] then
		   nonmovableFrom = true;
		  end
		  if TITAN_PANEL_DROPOFF_ADDON == TITAN_PANEL_NONMOVABLE_PLUGINS[i] then
		   nonmovableTo = true;
		  end
		end
		
		if (nonmovableTo == true and nonmovableFrom == false) or (nonmovableTo == false and nonmovableFrom == true) then
		TITAN_PANEL_DROPOFF_ADDON = nil;
		end
		
		-- protect AuxAutoHide and Clock
		if (TITAN_PANEL_MOVE_ADDON == "AuxAutoHide" or TITAN_PANEL_DROPOFF_ADDON == "AuxAutoHide") then
		TITAN_PANEL_DROPOFF_ADDON = nil;
		end
		
		if (TITAN_PANEL_MOVE_ADDON == "Clock" or TITAN_PANEL_DROPOFF_ADDON == "Clock") then
		TITAN_PANEL_DROPOFF_ADDON = nil;
		end
		
		local dropoff = TitanUtils_GetCurrentIndex(TitanPanelSettings.Buttons,TITAN_PANEL_DROPOFF_ADDON);
		local pickup = TitanUtils_GetCurrentIndex(TitanPanelSettings.Buttons,TITAN_PANEL_MOVE_ADDON);
		local dropoffbar = TitanUtils_GetWhichBar(TITAN_PANEL_DROPOFF_ADDON);
		local pickupbar = TitanUtils_GetWhichBar(TITAN_PANEL_MOVE_ADDON);
		local side = TitanPanel_GetPluginSide(TITAN_PANEL_DROPOFF_ADDON);
	  local nextaddon = TitanUtils_GetNextButtonOnBar(dropoffbar,TITAN_PANEL_DROPOFF_ADDON,side);

		if dropoff ~= nil and dropoff ~= "" then
			TitanPanelSettings.Buttons[dropoff] = TITAN_PANEL_MOVE_ADDON;
			TitanPanelSettings.Location[dropoff] = dropoffbar;
			TitanPanelSettings.Buttons[pickup] = TITAN_PANEL_DROPOFF_ADDON;
			TitanPanelSettings.Location[pickup] = pickupbar;
		end	
		
			TitanPanel_InitPanelButtons();
			TITAN_PANEL_MOVE_ADDON = nil;
			TITAN_PANEL_DROPOFF_ADDON = nil;
			TITAN_PANEL_NEXT_ADDON = nil;
	end
end