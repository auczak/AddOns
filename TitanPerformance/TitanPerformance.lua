-- **************************************************************************
-- * TitanPerformance.lua
-- *
-- * By: TitanMod, Dark Imakuni, Adsertor and the Titan Development Team
-- *     (HonorGoG, jaketodd422, joejanko, Lothayer, Tristanian)
-- **************************************************************************

-- ******************************** Constants *******************************
TITAN_PERFORMANCE_ID = "Performance";
TITAN_PERFORMANCE_FREQUENCY = 1;
TITAN_PERF_FRAME_SHOW_TIME = 0.5;

TITAN_FPS_THRESHOLD_TABLE = {
     Values = { 20, 30 },
     Colors = { RED_FONT_COLOR, NORMAL_FONT_COLOR, GREEN_FONT_COLOR },
}
TITAN_LATENCY_THRESHOLD_TABLE = {
     Values = { PERFORMANCEBAR_LOW_LATENCY, PERFORMANCEBAR_MEDIUM_LATENCY },
     Colors = { GREEN_FONT_COLOR, NORMAL_FONT_COLOR, RED_FONT_COLOR },
}
TITAN_MEMORY_RATE_THRESHOLD_TABLE = {
     Values = { 1, 2 },
     Colors = { GREEN_FONT_COLOR, NORMAL_FONT_COLOR, RED_FONT_COLOR },
}
TITAN_MEMORY_TIMETOGC_THRESHOLD_TABLE = {
     Values = { 60, 300 },
     Colors = { RED_FONT_COLOR, NORMAL_FONT_COLOR, GREEN_FONT_COLOR },
}
TITAN_MEMORY_MENU_TOGGLE_TABLE = {
     "ShowFPS", "ShowLatency", "ShowMemory",
}

-- ******************************** Variables *******************************
local topAddOns;
local memUsageSinceGC = {};
local counter = 1; --counter for active addons

-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelPerformanceButton_OnLoad()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TitanPanelPerformanceButton_OnLoad()
     this.registry = {
          id = TITAN_PERFORMANCE_ID,
          builtIn = 1,
          version = TITAN_VERSION,
          menuText = TITAN_PERFORMANCE_MENU_TEXT, 
          buttonTextFunction = "TitanPanelPerformanceButton_GetButtonText";
          tooltipCustomFunction = TitanPanelPerformanceButton_SetTooltip;
          icon = TITAN_ARTWORK_PATH.."TitanPerformance",     
          iconWidth = 16,
          savedVariables = {
               ShowFPS = 1,
               ShowLatency = 1,
               ShowMemory = 1,
               ShowAddonMemory = TITAN_NIL,
               ShowAddonIncRate = TITAN_NIL,
               NumOfAddons = 5,
               ShowIcon = 1,
               ShowLabelText = TITAN_NIL,
               ShowColoredText = 1,
          }
     };

     this.fpsSampleCount = 0;
end

-- **************************************************************************
-- NAME : TitanPanelPerformanceButton_OnUpdate(elapsed)
-- DESC : Update button data
-- VARS : elapsed = <research>
-- **************************************************************************
function TitanPanelPerformanceButton_OnUpdate(elapsed)
	TITAN_PERFORMANCE_FREQUENCY = TITAN_PERFORMANCE_FREQUENCY - elapsed;
	if TITAN_PERFORMANCE_FREQUENCY <=0 then
		TitanPanelPluginHandle_OnUpdate(TITAN_PERFORMANCE_ID, TITAN_PANEL_UPDATE_ALL);
		TITAN_PERFORMANCE_FREQUENCY = 1;
		if not (TitanPanelRightClickMenu_IsVisible()) and TitanPanelPerfControlFrame:IsVisible() and not (MouseIsOver(TitanPanelPerfControlFrame)) then
		   TitanPanelPerfControlFrame:Hide();
		end
	end
end


-- **************************************************************************
-- NAME : TitanPanelPerformanceButton_GetButtonText(id) 
-- DESC : Calculate performance based logic for button text
-- VARS : id = button ID
-- **************************************************************************
function TitanPanelPerformanceButton_GetButtonText(id)     
     local button = TitanPanelPerformanceButton;
     local color, fpsRichText, latencyRichText, memoryRichText;
     local showFPS = TitanGetVar(TITAN_PERFORMANCE_ID, "ShowFPS");
     local showLatency = TitanGetVar(TITAN_PERFORMANCE_ID, "ShowLatency");
     local showMemory = TitanGetVar(TITAN_PERFORMANCE_ID, "ShowMemory");

     -- Update real time data
     TitanPanelPerformanceButton_UpdateData()
     
     -- FPS text
     if ( showFPS ) then
          local fpsText = format(TITAN_FPS_FORMAT, button.fps);
          if ( TitanGetVar(TITAN_PERFORMANCE_ID, "ShowColoredText") ) then     
               color = TitanUtils_GetThresholdColor(TITAN_FPS_THRESHOLD_TABLE, button.fps);
               fpsRichText = TitanUtils_GetColoredText(fpsText, color);
          else
               fpsRichText = TitanUtils_GetHighlightText(fpsText);
          end
     end

     -- Latency text
     if ( showLatency ) then
          local latencyText = format(TITAN_LATENCY_FORMAT, button.latency);     
          if ( TitanGetVar(TITAN_PERFORMANCE_ID, "ShowColoredText") ) then     
               color = TitanUtils_GetThresholdColor(TITAN_LATENCY_THRESHOLD_TABLE, button.latency);
               latencyRichText = TitanUtils_GetColoredText(latencyText, color);
          else
               latencyRichText = TitanUtils_GetHighlightText(latencyText);
          end
     end

     -- Memory text
     if ( showMemory ) then
          local memoryText = format(TITAN_MEMORY_FORMAT, button.memory/1024);
          memoryRichText = TitanUtils_GetHighlightText(memoryText);
     end
     
     if ( showFPS ) then
          if ( showLatency ) then
               if ( showMemory ) then
                    return TITAN_FPS_BUTTON_LABEL, fpsRichText, TITAN_LATENCY_BUTTON_LABEL, latencyRichText, TITAN_MEMORY_BUTTON_LABEL, memoryRichText;
               else
                    return TITAN_FPS_BUTTON_LABEL, fpsRichText, TITAN_LATENCY_BUTTON_LABEL, latencyRichText;
               end
          else
               if ( showMemory ) then
                    return TITAN_FPS_BUTTON_LABEL, fpsRichText, TITAN_MEMORY_BUTTON_LABEL, memoryRichText;
               else
                    return TITAN_FPS_BUTTON_LABEL, fpsRichText;
               end
          end
     else
          if ( showLatency ) then
               if ( showMemory ) then
                    return TITAN_LATENCY_BUTTON_LABEL, latencyRichText, TITAN_MEMORY_BUTTON_LABEL, memoryRichText;
               else
                    return TITAN_LATENCY_BUTTON_LABEL, latencyRichText;
               end
          else
               if ( showMemory ) then
                    return TITAN_MEMORY_BUTTON_LABEL, memoryRichText;
               else
                    return;
               end
          end
     end
end

-- **************************************************************************
-- NAME : TitanPanelPerformanceButton_SetTooltip()
-- DESC : Display tooltip text
-- **************************************************************************
function TitanPanelPerformanceButton_SetTooltip()
     local showFPS = TitanGetVar(TITAN_PERFORMANCE_ID, "ShowFPS");
     local showLatency = TitanGetVar(TITAN_PERFORMANCE_ID, "ShowLatency");
     local showMemory = TitanGetVar(TITAN_PERFORMANCE_ID, "ShowMemory");
     local showAddonMemory = TitanGetVar(TITAN_PERFORMANCE_ID, "ShowAddonMemory");

     -- Tooltip title
     GameTooltip:SetText(TITAN_PERFORMANCE_TOOLTIP, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

     -- FPS tooltip
     if ( showFPS ) then
          local fpsText = format(TITAN_FPS_FORMAT, TitanPanelPerformanceButton.fps);
          local avgFPSText = format(TITAN_FPS_FORMAT, TitanPanelPerformanceButton.avgFPS);
          local minFPSText = format(TITAN_FPS_FORMAT, TitanPanelPerformanceButton.minFPS);
          local maxFPSText = format(TITAN_FPS_FORMAT, TitanPanelPerformanceButton.maxFPS);     
          
          GameTooltip:AddLine("\n");
          GameTooltip:AddLine(TitanUtils_GetHighlightText(TITAN_FPS_TOOLTIP));
          GameTooltip:AddDoubleLine(TITAN_FPS_TOOLTIP_CURRENT_FPS, TitanUtils_GetHighlightText(fpsText));
          GameTooltip:AddDoubleLine(TITAN_FPS_TOOLTIP_AVG_FPS, TitanUtils_GetHighlightText(avgFPSText));
          GameTooltip:AddDoubleLine(TITAN_FPS_TOOLTIP_MIN_FPS, TitanUtils_GetHighlightText(minFPSText));
          GameTooltip:AddDoubleLine(TITAN_FPS_TOOLTIP_MAX_FPS, TitanUtils_GetHighlightText(maxFPSText));
     end

     -- Latency tooltip
     if ( showLatency ) then
          local latencyText = format(TITAN_LATENCY_FORMAT, TitanPanelPerformanceButton.latency);
          local bandwidthInText = format(TITAN_LATENCY_BANDWIDTH_FORMAT, TitanPanelPerformanceButton.bandwidthIn);
          local bandwidthOutText = format(TITAN_LATENCY_BANDWIDTH_FORMAT, TitanPanelPerformanceButton.bandwidthOut);
          
          GameTooltip:AddLine("\n");
          GameTooltip:AddLine(TitanUtils_GetHighlightText(TITAN_LATENCY_TOOLTIP));
          GameTooltip:AddDoubleLine(TITAN_LATENCY_TOOLTIP_LATENCY, TitanUtils_GetHighlightText(latencyText));
          GameTooltip:AddDoubleLine(TITAN_LATENCY_TOOLTIP_BANDWIDTH_IN, TitanUtils_GetHighlightText(bandwidthInText));
          GameTooltip:AddDoubleLine(TITAN_LATENCY_TOOLTIP_BANDWIDTH_OUT, TitanUtils_GetHighlightText(bandwidthOutText));
     end

     -- Memory tooltip
     if ( showMemory ) then
          local memoryText = format(TITAN_MEMORY_FORMAT, TitanPanelPerformanceButton.memory/1024);
          local initialMemoryText = format(TITAN_MEMORY_FORMAT, TitanPanelPerformanceButton.initialMemory/1024);
          --local gcThresholdText = format(TITAN_MEMORY_FORMAT, this.gcThreshold/1024);
          local sessionTime = time() - TitanPanelPerformanceButton.startSessionTime;          
          local rateRichText, timeToGCRichText, rate, timeToGC, color;     
          if ( sessionTime == 0 ) then
               rateRichText = TitanUtils_GetHighlightText("N/A");
          else
               rate = (TitanPanelPerformanceButton.memory - TitanPanelPerformanceButton.initialMemory) / sessionTime;
               color = TitanUtils_GetThresholdColor(TITAN_MEMORY_RATE_THRESHOLD_TABLE, rate);
               rateRichText = TitanUtils_GetColoredText(format(TITAN_MEMORY_RATE_FORMAT, rate), color);
          end     
          if ( TitanPanelPerformanceButton.memory == TitanPanelPerformanceButton.initialMemory ) then
               timeToGCRichText = TitanUtils_GetHighlightText("N/A");
          else
               --timeToGC = (this.gcThreshold - this.memory) / (this.memory - this.initialMemory) * sessionTime;
               --color = TitanUtils_GetThresholdColor(TITAN_MEMORY_TIMETOGC_THRESHOLD_TABLE, timeToGC);
               --timeToGCRichText = TitanUtils_GetColoredText(TitanUtils_GetAbbrTimeText(timeToGC), color);
          end     
     
          GameTooltip:AddLine("\n");
          GameTooltip:AddLine(TitanUtils_GetHighlightText(TITAN_MEMORY_TOOLTIP));
          GameTooltip:AddDoubleLine(TITAN_MEMORY_TOOLTIP_CURRENT_MEMORY, TitanUtils_GetHighlightText(memoryText));
          GameTooltip:AddDoubleLine(TITAN_MEMORY_TOOLTIP_INITIAL_MEMORY, TitanUtils_GetHighlightText(initialMemoryText));
          GameTooltip:AddDoubleLine(TITAN_MEMORY_TOOLTIP_INCREASING_RATE, rateRichText);
          --GameTooltip:AddLine("\n");
          --GameTooltip:AddLine(TitanUtils_GetHighlightText(TITAN_MEMORY_TOOLTIP_GC_INFO));
          --GameTooltip:AddDoubleLine(TITAN_MEMORY_TOOLTIP_GC_THRESHOLD, TitanUtils_GetHighlightText(gcThresholdText));
          --GameTooltip:AddDoubleLine(TITAN_MEMORY_TOOLTIP_TIME_TO_GC, timeToGCRichText);
     end
     
	if ( showAddonMemory == 1 ) then
		local i;
	     --if topAddOns then
			--for i,addon in pairs(topAddOns) do
				-- addon.value = 0
			--end
		--else
			topAddOns = {}
			-- scan how many addons are active
			local count = GetNumAddOns();
			local ActiveAddons = 0;
			for i=1, count do
				if IsAddOnLoaded(i) then
					ActiveAddons = ActiveAddons + 1;
				end
			end

			if ActiveAddons < TitanGetVar(TITAN_PERFORMANCE_ID, "NumOfAddons") then
				counter = ActiveAddons;
			else
				counter = TitanGetVar(TITAN_PERFORMANCE_ID, "NumOfAddons");
			end
			--set the counter to the proper number of active addons that are being monitored
			for i=1, counter do
				topAddOns[i] = {name = '', value = 0}
			end
		--end

		Stats_UpdateAddonsList(self, GetCVar('scriptProfile') == '1' and not IsModifierKeyDown())
	end     

	GameTooltip:AddLine(TitanUtils_GetGreenText(TITAN_PERFORMANCE_TOOLTIP_HINT));
end

-- **************************************************************************
-- NAME : TitanPanelRightClickMenu_PreparePerformanceMenu()
-- DESC : Display rightclick menu options
-- **************************************************************************
function TitanPanelRightClickMenu_PreparePerformanceMenu()
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		TitanPanelPerfControlFrame:Show();
	else
		TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_PERFORMANCE_ID].menuText);
		TitanPanelRightClickMenu_AddToggleVar(TITAN_PERFORMANCE_MENU_SHOW_FPS, TITAN_PERFORMANCE_ID, "ShowFPS");
		TitanPanelRightClickMenu_AddToggleVar(TITAN_PERFORMANCE_MENU_SHOW_LATENCY, TITAN_PERFORMANCE_ID, "ShowLatency");
     	TitanPanelRightClickMenu_AddToggleVar(TITAN_PERFORMANCE_MENU_SHOW_MEMORY, TITAN_PERFORMANCE_ID, "ShowMemory");
     	TitanPanelRightClickMenu_AddSpacer();
     
     	TitanPanelRightClickMenu_AddTitle(TITAN_PERFORMANCE_ADDONS);
     	TitanPanelRightClickMenu_AddToggleVar(TITAN_PERFORMANCE_MENU_SHOW_ADDONS, TITAN_PERFORMANCE_ID, "ShowAddonMemory");
		TitanPanelRightClickMenu_AddToggleVar(TITAN_PERFORMANCE_MENU_SHOW_ADDON_RATE, TITAN_PERFORMANCE_ID, "ShowAddonIncRate");
		local info, temp;
		temp = TitanGetVar(TITAN_PERFORMANCE_ID, "NumOfAddons");
		info = {};
		info.text = TITAN_PERFORMANCE_CONTROL_TOOLTIP..LIGHTYELLOW_FONT_COLOR_CODE..tostring(temp);
		info.hasArrow = 1;
     	UIDropDownMenu_AddButton(info);
		
		TitanPanelRightClickMenu_AddSpacer();
		
		if ( GetCVar("scriptProfile") == "1" ) then
		TitanPanelRightClickMenu_AddTitle(TITAN_PERFORMANCE_MENU_CPUPROF_LABEL..": "..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_ENABLED);
		info = {};
		info.text = TITAN_PERFORMANCE_MENU_CPUPROF_LABEL_OFF..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_RELOADUI;
		info.func = function()
		 SetCVar("scriptProfile", "0", 1)
		 ReloadUI()
		 end
		UIDropDownMenu_AddButton(info);
		else
		TitanPanelRightClickMenu_AddTitle(TITAN_PERFORMANCE_MENU_CPUPROF_LABEL..": "..RED_FONT_COLOR_CODE..TITAN_PANEL_MENU_DISABLED);
		info = {};
		info.text = TITAN_PERFORMANCE_MENU_CPUPROF_LABEL_ON..GREEN_FONT_COLOR_CODE..TITAN_PANEL_MENU_RELOADUI;
		info.func = function()
		 SetCVar("scriptProfile", "1", 1)
		 ReloadUI()
		 end
		UIDropDownMenu_AddButton(info);
		end
		
		
     	TitanPanelRightClickMenu_AddSpacer();
     	TitanPanelRightClickMenu_AddToggleIcon(TITAN_PERFORMANCE_ID);
     	TitanPanelRightClickMenu_AddToggleLabelText(TITAN_PERFORMANCE_ID);
     	TitanPanelRightClickMenu_AddToggleColoredText(TITAN_PERFORMANCE_ID);
     
     	TitanPanelRightClickMenu_AddSpacer();
     	TitanPanelRightClickMenu_AddCommand(TITAN_PANEL_MENU_HIDE, TITAN_PERFORMANCE_ID, TITAN_PANEL_MENU_FUNC_HIDE);
     end
end

-- **************************************************************************
-- NAME : TitanPanelPerformanceButton_UpdateData()
-- DESC : Update button data
-- **************************************************************************
function TitanPanelPerformanceButton_UpdateData()
     local button = TitanPanelPerformanceButton;
     local showFPS = TitanGetVar(TITAN_PERFORMANCE_ID, "ShowFPS");
     local showLatency = TitanGetVar(TITAN_PERFORMANCE_ID, "ShowLatency");
     local showMemory = TitanGetVar(TITAN_PERFORMANCE_ID, "ShowMemory");
     local showAddonMemory = TitanGetVar(TITAN_PERFORMANCE_ID, "ShowAddonMemory");
     
     -- FPS Data
     if ( showFPS ) then
          button.fps = GetFramerate();     
          button.fpsSampleCount = button.fpsSampleCount + 1;
          if (button.fpsSampleCount == 1) then
               button.minFPS = button.fps;
               button.maxFPS = button.fps;
               button.avgFPS = button.fps;
          else
               if (button.fps < button.minFPS) then
                    button.minFPS = button.fps;
               elseif (button.fps > button.maxFPS) then
                    button.maxFPS = button.fps;
               end
               button.avgFPS = (button.avgFPS * (button.fpsSampleCount - 1) + button.fps) / button.fpsSampleCount;
          end
     end

     -- Latency Data
     if ( showLatency ) then
          button.bandwidthIn, button.bandwidthOut, button.latency = GetNetStats();
     end

     -- Memory data
     if ( showMemory ) or (showAddonMemory == 1) then
          local previousMemory = button.memory;     
          button.memory, button.gcThreshold = gcinfo();          
          if ( not button.startSessionTime ) then
               -- Initial data
               local i;
               button.startSessionTime = time();     
               button.initialMemory = button.memory;
               
               for i = 1, GetNumAddOns() do               
								memUsageSinceGC[GetAddOnInfo(i)] = GetAddOnMemoryUsage(i)
               end
               
          elseif (previousMemory and button.memory and previousMemory > button.memory) then
               -- Reset data after garbage collection
               local k,i;
               button.startSessionTime = time();
               button.initialMemory = button.memory;
               
               for k in pairs(memUsageSinceGC) do
								memUsageSinceGC[k] = nil
               end
               
               for i = 1, GetNumAddOns() do
								memUsageSinceGC[GetAddOnInfo(i)] = GetAddOnMemoryUsage(i)
               end
          
          
          end
     end
end

-- **************************************************************************
-- NAME : TitanPanelPerformanceButton_ResetMemory()
-- DESC : Reset the memory monitoring values
-- **************************************************************************
function TitanPanelPerformanceButton_ResetMemory()
     local button = TitanPanelPerformanceButton;
     button.memory, button.gcThreshold = gcinfo();     
     button.initialMemory = button.memory;
     button.startSessionTime = time();
end

-- **************************************************************************
-- NAME : Stats_UpdateAddonsList(self, watchingCPU)
-- DESC : Execute garbage collection for Leftclick on button
-- **************************************************************************
function Stats_UpdateAddonsList(self, watchingCPU)
	if(watchingCPU) then
		UpdateAddOnCPUUsage()
	else
		UpdateAddOnMemoryUsage()
	end

	local total = 0
	local i,j,k;
	local showAddonRate = TitanGetVar(TITAN_PERFORMANCE_ID, "ShowAddonIncRate");
	for i=1, GetNumAddOns() do
		local value = (watchingCPU and GetAddOnCPUUsage(i)) or GetAddOnMemoryUsage(i)
		local name = GetAddOnInfo(i)
		total = total + value

		for j,addon in ipairs(topAddOns) do
			if(value > addon.value) then                                                                                                                                                                                                                                         
				for k = counter, 1, -1 do
					if(k == j) then
						topAddOns[k].value = value
						topAddOns[k].name = GetAddOnInfo(i)
						break
					elseif(k ~= 1) then
						topAddOns[k].value = topAddOns[k-1].value
						topAddOns[k].name = topAddOns[k-1].name
					end
				end
				break
			end
		end
	end

	--GameTooltip:AddLine('-------------------------------------------------------')
	GameTooltip:AddLine(' ')

	if (total > 0) then
		if(watchingCPU) then
			GameTooltip:AddLine('|cffffffff'..TITAN_PERFORMANCE_ADDON_CPU_USAGE_LABEL)
		else
			GameTooltip:AddLine('|cffffffff'..TITAN_PERFORMANCE_ADDON_MEM_USAGE_LABEL)
		end
                
		if not watchingCPU then
			if (showAddonRate == 1) then
				GameTooltip:AddDoubleLine(LIGHTYELLOW_FONT_COLOR_CODE..TITAN_PERFORMANCE_ADDON_NAME_LABEL,LIGHTYELLOW_FONT_COLOR_CODE..TITAN_PERFORMANCE_ADDON_USAGE_LABEL.."/"..TITAN_PERFORMANCE_ADDON_RATE_LABEL..":")
			else
				GameTooltip:AddDoubleLine(LIGHTYELLOW_FONT_COLOR_CODE..TITAN_PERFORMANCE_ADDON_NAME_LABEL,LIGHTYELLOW_FONT_COLOR_CODE..TITAN_PERFORMANCE_ADDON_USAGE_LABEL..":")
			end
		end
		
		if watchingCPU then
		   GameTooltip:AddDoubleLine(LIGHTYELLOW_FONT_COLOR_CODE..TITAN_PERFORMANCE_ADDON_NAME_LABEL,LIGHTYELLOW_FONT_COLOR_CODE..TITAN_PERFORMANCE_ADDON_USAGE_LABEL..":")
		end
                                   
		for _,addon in ipairs(topAddOns) do
			if(watchingCPU) then
			  local diff = addon.value/total * 100;
			  local incrate = "";
			    incrate = format("(%.2f%%)", diff);
			    if (showAddonRate == 1) then 
			    GameTooltip:AddDoubleLine(NORMAL_FONT_COLOR_CODE..addon.name," |cffffffff"..format("%.3f",addon.value)..TITAN_MILLISECOND.." "..GREEN_FONT_COLOR_CODE..incrate);
			    else
				  GameTooltip:AddDoubleLine(NORMAL_FONT_COLOR_CODE..addon.name," |cffffffff"..format("%.3f",addon.value)..TITAN_MILLISECOND);
				  end
			else
				local diff = addon.value - (memUsageSinceGC[addon.name])
				if diff < 0 or memUsageSinceGC[addon.name]== 0 then
					memUsageSinceGC[addon.name] = addon.value;
				end
				local incrate = "";
				if diff > 0 then
					incrate = format("(+%.2f) "..TITAN_KILOBYTES_PER_SECOND, diff);
				end 
				if (showAddonRate == 1) then                                           
					GameTooltip:AddDoubleLine(NORMAL_FONT_COLOR_CODE..addon.name," |cffffffff"..format(TITAN_MEMORY_FORMAT, addon.value/1000).." "..GREEN_FONT_COLOR_CODE..incrate)
				else
					GameTooltip:AddDoubleLine(NORMAL_FONT_COLOR_CODE..addon.name," |cffffffff"..format(TITAN_MEMORY_FORMAT, addon.value/1000))
				end
			end
		end

		--GameTooltip:AddLine('-------------------------------------------------------')
		GameTooltip:AddLine(' ')
		if(watchingCPU) then
			GameTooltip:AddDoubleLine(LIGHTYELLOW_FONT_COLOR_CODE..TITAN_PERFORMANCE_ADDON_TOTAL_CPU_USAGE_LABEL, format("%.3f",total)..TITAN_MILLISECOND)
		else
			GameTooltip:AddDoubleLine(LIGHTYELLOW_FONT_COLOR_CODE..TITAN_PERFORMANCE_ADDON_TOTAL_MEM_USAGE_LABEL,format(TITAN_MEMORY_FORMAT, total/1000))
		end
	end
	--GameTooltip:Show()
end


-- **************************************************************************
-- NAME : TitanPanelPerformanceButton_OnClick()
-- DESC : Execute garbage collection for Leftclick on button
-- **************************************************************************
function TitanPanelPerformanceButton_OnClick()
	if arg1== "LeftButton" then
     	collectgarbage('collect');
	end
end

-- **************************************************************************
-- NAME : TitanPanelPerfControlSlider_OnEnter()
-- DESC : Display tooltip on entering slider
-- **************************************************************************
function TitanPanelPerfControlSlider_OnEnter()
     this.tooltipText = TitanOptionSlider_TooltipText(TITAN_PERFORMANCE_CONTROL_TOOLTIP, TitanGetVar(TITAN_PERFORMANCE_ID, "NumOfAddons"));
     GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
     GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
     TitanUtils_StopFrameCounting(this:GetParent());
end

-- **************************************************************************
-- NAME : TitanPanelPerfControlSlider_OnLeave()
-- DESC : Hide tooltip after leaving slider
-- **************************************************************************
function TitanPanelPerfControlSlider_OnLeave()
     this.tooltipText = nil;
     GameTooltip:Hide();
     TitanUtils_StartFrameCounting(this:GetParent(), TITAN_TRANS_FRAME_SHOW_TIME);
end

-- **************************************************************************
-- NAME : TitanPanelPerfControlSlider_OnShow()
-- DESC : Display slider tooltip
-- **************************************************************************
function TitanPanelPerfControlSlider_OnShow()     
     getglobal(this:GetName().."Text"):SetText(TitanGetVar(TITAN_PERFORMANCE_ID, "NumOfAddons"));
     getglobal(this:GetName().."High"):SetText(TITAN_PERFORMANCE_CONTROL_LOW);
     getglobal(this:GetName().."Low"):SetText(TITAN_PERFORMANCE_CONTROL_HIGH);
     this:SetMinMaxValues(1, 40);
     this:SetValueStep(1);
     this:SetValue(41 - TitanGetVar(TITAN_PERFORMANCE_ID, "NumOfAddons"));
     
	--position = TitanUtils_GetRealPosition(TITAN_PERFORMANCE_ID);
	--TitanPanelPerfControlFrame:SetPoint("BOTTOMRIGHT", "TitanPanel" .. TitanUtils_GetWhichBar(TITAN_PERFORMANCE_ID) .."Button", "TOPRIGHT", 0, 0);
	--if (position == TITAN_PANEL_PLACE_TOP) then 
		TitanPanelPerfControlFrame:ClearAllPoints();
		--TitanPanelPerfControlFrame:SetPoint("TOPLEFT", "TitanPanel" .. TitanUtils_GetWhichBar(TITAN_PERFORMANCE_ID) .."Button", "BOTTOMLEFT", UIParent:GetRight() - TitanPanelPerfControlFrame:GetWidth(), -4);
		TitanPanelPerfControlFrame:SetPoint("LEFT", "DropDownList1Button9ExpandArrow","RIGHT", 9/DropDownList1Button9ExpandArrow:GetScale(),0);
		local offscreenX, offscreenY = TitanUtils_GetOffscreen(TitanPanelPerfControlFrame);
		if offscreenX == -1 or offscreenX == 0 then
		  TitanPanelPerfControlFrame:ClearAllPoints();
			TitanPanelPerfControlFrame:SetPoint("LEFT", "DropDownList1Button9ExpandArrow","RIGHT", 9/DropDownList1Button9ExpandArrow:GetScale(),0);
		else
		  TitanPanelPerfControlFrame:ClearAllPoints();
			TitanPanelPerfControlFrame:SetPoint("RIGHT", "DropDownList1","LEFT", 3/DropDownList1Button9ExpandArrow:GetScale(),0);
		end             
	--else
		--TitanPanelPerfControlFrame:ClearAllPoints();
		--TitanPanelPerfControlFrame:SetPoint("BOTTOMLEFT", "TitanPanel" .. TitanUtils_GetWhichBar(TITAN_PERFORMANCE_ID) .."Button", "TOPLEFT", UIParent:GetRight() - TitanPanelPerfControlFrame:GetWidth(), 0);
	--end          

end

-- **************************************************************************
-- NAME : TitanPanelPerfControlSlider_OnValueChanged(arg1)
-- DESC : Display slider tooltip text
-- VARS : arg1 = positive or negative change to apply
-- **************************************************************************
function TitanPanelPerfControlSlider_OnValueChanged(arg1)
     getglobal(this:GetName().."Text"):SetText(41 - this:GetValue());
     
     if arg1 == -1 then
		this:SetValue(this:GetValue() + 1);
     end
     
     if arg1 == 1 then
		this:SetValue(this:GetValue() - 1);
     end
     
     TitanSetVar(TITAN_PERFORMANCE_ID, "NumOfAddons", 41 - this:GetValue());
     topAddOns = {};
     -- scan how many addons are active
	local count = GetNumAddOns();
	local ActiveAddons = 0;
	for i=1, count do
		if IsAddOnLoaded(i) then
			ActiveAddons = ActiveAddons + 1;
		end
	end
               
	if ActiveAddons < TitanGetVar(TITAN_PERFORMANCE_ID, "NumOfAddons") then
		counter = ActiveAddons;
	else
		counter = TitanGetVar(TITAN_PERFORMANCE_ID, "NumOfAddons");
	end
	--set the counter to the proper number of active addons that are being monitored
                
     for i=1, counter do
			topAddOns[i] = {name = '', value = 0}
     end
     
     -- Update GameTooltip
     if (this.tooltipText) then
          this.tooltipText = TitanOptionSlider_TooltipText(TITAN_PERFORMANCE_CONTROL_TOOLTIP, 41 - this:GetValue());
          GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
     end
end

-- **************************************************************************
-- NAME : TitanPanelPerfControlFrame_OnLoad()
-- DESC : Create performance option frame
-- **************************************************************************
function TitanPanelPerfControlFrame_OnLoad()
     getglobal(this:GetName().."Title"):SetText(TITAN_PERFORMANCE_CONTROL_TITLE);
     this:SetBackdropBorderColor(1, 1, 1);
     this:SetBackdropColor(0, 0, 0, 1);
end

-- **************************************************************************
-- NAME : TitanPanelPerfControlFrame_OnUpdate(elapsed)
-- DESC : If dropdown is visible, see if its timer has expired.  If so, hide frame
-- VARS : elapsed = <research>
-- **************************************************************************
function TitanPanelPerfControlFrame_OnUpdate(elapsed)
     TitanUtils_CheckFrameCounting(this, elapsed);
end