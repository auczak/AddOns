TITAN_UISCALE_ID = "UIScale";
TITAN_UISCALE_FRAME_SHOW_TIME = 0.5;

TITAN_UISCALE_MIN = 0.64;
TITAN_UISCALE_MAX = 1;
TITAN_UISCALE_STEP = 0.01;

TITAN_PANELSCALE_MIN = 0.75;
TITAN_PANELSCALE_MAX = 1.25;
TITAN_PANELSCALE_STEP = 0.01;

TITAN_BUTTONSPACING_MIN = 5;
TITAN_BUTTONSPACING_MAX = 80;
TITAN_BUTTONSPACING_STEP = 1;

TITAN_TOOLTIPTRANS_MIN = 0;
TITAN_TOOLTIPTRANS_MAX = 1;
TITAN_TOOLTIPTRANS_STEP = 0.01;

TITAN_TOOLTIPFONT_MIN = 0.5;
TITAN_TOOLTIPFONT_MAX = 1.3;
TITAN_TOOLTIPFONT_STEP = 0.01;

function TitanPanelUIScaleButton_OnLoad()
	this.registry = {
		id = TITAN_UISCALE_ID,
		builtIn = 1,
		version = TITAN_VERSION,
		menuText = TITAN_UISCALE_MENU_TEXT, 
		tooltipTitle = TITAN_UISCALE_TOOLTIP, 
		tooltipTextFunction = "TitanPanelUIScaleButton_GetTooltipText", 
		icon = TITAN_ARTWORK_PATH.."TitanUIScale",
	};
end

function TitanPanelUIScaleButton_GetTooltipText()
	local panelScaleText = TitanPanelUIScale_GetSCaleText(TitanPanelGetVar("Scale"));
	local uiScaleText = TitanPanelUIScale_GetSCaleText(UIParent:GetScale());
	local buttonSpacing = TitanPanelSpacing_GetSpacing(TitanPanelGetVar("ButtonSpacing"));
	local tooltiptrans = TitanPanelTooltip_GetAlpha(TitanPanelGetVar("TooltipTrans"));
	local tooltipfont = TitanPanelTooltip_GetAlpha(TitanPanelGetVar("TooltipFont"));
	 if TitanPanelGetVar("DisableTooltipFont") then
	    tooltipfont = TITAN_UISCALE_TOOLTIP_DISABLE_TEXT;
	 end
	
	return ""..
		TITAN_UISCALE_TOOLTIP_VALUE_UI.."\t"..TitanUtils_GetHighlightText(uiScaleText).."\n"..
		TITAN_UISCALE_TOOLTIP_VALUE_PANEL.."\t"..TitanUtils_GetHighlightText(panelScaleText).."\n"..
		TITAN_UISCALE_TOOLTIP_VALUE_BUTTON.."\t"..TitanUtils_GetHighlightText(buttonSpacing).."\n"..
		TITAN_UISCALE_TOOLTIP_VALUE_TOOLTIPTRANS.."\t"..TitanUtils_GetHighlightText(tooltiptrans).."\n"..
		TITAN_UISCALE_TOOLTIP_VALUE_TOOLTIPFONT.."\t"..TitanUtils_GetHighlightText(tooltipfont).."\n"..
		TitanUtils_GetGreenText(TITAN_UISCALE_TOOLTIP_HINT1).."\n"..
		TitanUtils_GetGreenText(TITAN_UISCALE_TOOLTIP_HINT2);
end

function TitanPanelUIScaleControlSlider_OnEnter()
	local uiScale = UIParent:GetScale();
	
	this.tooltipText = TitanOptionSlider_TooltipText(TITAN_UISCALE_CONTROL_TOOLTIP_UI, TitanPanelUIScale_GetSCaleText(uiScale));
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	TitanUtils_StopFrameCounting(this:GetParent());
end

function TitanPanelUIScaleControlSlider_OnLeave()
	this.tooltipText = nil;
	GameTooltip:Hide();
	TitanUtils_StartFrameCounting(this:GetParent(), TITAN_UISCALE_FRAME_SHOW_TIME);
end

function TitanPanelUIScaleControlSlider_OnShow()	
	local uiScale = UIParent:GetScale();
	local min = TITAN_UISCALE_MIN;
	local max = TITAN_UISCALE_MAX;
	local step = TITAN_UISCALE_STEP;
	
	getglobal(this:GetName().."Text"):SetText(TitanPanelUIScale_GetSCaleText(uiScale));
	getglobal(this:GetName().."High"):SetText(TITAN_UISCALE_CONTROL_LOW_UI);
	getglobal(this:GetName().."Low"):SetText(TITAN_UISCALE_CONTROL_HIGH_UI);
	this:SetMinMaxValues(min, max);
	this:SetValueStep(step);
	this:SetValue(min + max - uiScale);
	this.previousValue = this:GetValue();

	position = TitanUtils_GetRealPosition(TITAN_UISCALE_ID);
	
	TitanPanelUIScaleControlFrame:SetPoint("BOTTOMRIGHT", "TitanPanel" .. TitanUtils_GetWhichBar(TITAN_UISCALE_ID) .."Button", "TOPRIGHT", 0, 0);
	if (position == TITAN_PANEL_PLACE_TOP) then 
		TitanPanelUIScaleControlFrame:ClearAllPoints();
		TitanPanelUIScaleControlFrame:SetPoint("TOPLEFT", "TitanPanel" .. TitanUtils_GetWhichBar(TITAN_UISCALE_ID) .."Button", "BOTTOMLEFT", UIParent:GetRight() - TitanPanelUIScaleControlFrame:GetWidth(), -4);
	else
		TitanPanelUIScaleControlFrame:ClearAllPoints();
		TitanPanelUIScaleControlFrame:SetPoint("BOTTOMLEFT", "TitanPanel" .. TitanUtils_GetWhichBar(TITAN_UISCALE_ID) .."Button", "TOPLEFT", UIParent:GetRight() - TitanPanelUIScaleControlFrame:GetWidth(), 0);
	end		

end

function TitanPanelUIScaleControlSlider_OnValueChanged(arg1)
 
	if arg1 == -1 then
	  this:SetValue(this:GetValue() + TITAN_UISCALE_STEP*2);
	end
	
	if arg1 == 1 then
	  this:SetValue(this:GetValue() - TITAN_UISCALE_STEP*2);
	end
  
	if (this:GetValue() ~= this.previousValue) then
		this.previousValue = this:GetValue();

		-- Set UI scale
		local min = TITAN_UISCALE_MIN;
		local max = TITAN_UISCALE_MAX;
		local uiScale = min + max - this:GetValue();
		SetCVar("useUiScale", 1, USE_UISCALE);
		SetCVar("uiScale", uiScale);
		
		-- Adjust panel scale
		TitanPanel_SetScale();
		TitanPanel_RefreshPanelButtons();

		-- Update slider value text
		getglobal(this:GetName().."Text"):SetText(TitanPanelUIScale_GetSCaleText(uiScale));

		-- Update GameTooltip
		if (this.tooltipText) then  
			this.tooltipText = TitanOptionSlider_TooltipText(TITAN_UISCALE_CONTROL_TOOLTIP_UI, TitanPanelUIScale_GetSCaleText(uiScale));
			GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
		end
	end
end

function TitanPanelPanelScaleControlSlider_OnEnter()
	local scale = TitanPanelGetVar("Scale");
	
	this.tooltipText = TitanOptionSlider_TooltipText(TITAN_UISCALE_CONTROL_TOOLTIP_PANEL, TitanPanelUIScale_GetSCaleText(scale));
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	TitanUtils_StopFrameCounting(this:GetParent());
end

function TitanPanelPanelScaleControlSlider_OnLeave()
	this.tooltipText = nil;
	GameTooltip:Hide();
	TitanUtils_StartFrameCounting(this:GetParent(), TITAN_UISCALE_FRAME_SHOW_TIME);
end

function TitanPanelPanelScaleControlSlider_OnShow()	
	local scale = TitanPanelGetVar("Scale");
	local min = TITAN_PANELSCALE_MIN;
	local max = TITAN_PANELSCALE_MAX;
	local step = TITAN_PANELSCALE_STEP;
	
	getglobal(this:GetName().."Text"):SetText(TitanPanelUIScale_GetSCaleText(scale));
	getglobal(this:GetName().."High"):SetText(TITAN_UISCALE_CONTROL_LOW_PANEL);
	getglobal(this:GetName().."Low"):SetText(TITAN_UISCALE_CONTROL_HIGH_PANEL);
	this:SetMinMaxValues(min, max);
	this:SetValueStep(step);
	this:SetValue(min + max - scale);
	this.previousValue = this:GetValue();
end

function TitanPanelPanelScaleControlSlider_OnValueChanged(arg1)

  if arg1 == -1 then
	  this:SetValue(this:GetValue() + TITAN_PANELSCALE_STEP*2);
	end
	
	if arg1 == 1 then
	  this:SetValue(this:GetValue() - TITAN_PANELSCALE_STEP*2);
	end

	if (this:GetValue() ~= this.previousValue) then
		this.previousValue = this:GetValue();

		local position = 1;
		
		local i = TitanPanel_GetButtonNumber(TITAN_UISCALE_ID);
		if TitanPanelSettings.Location[i] == "Bar" and TitanPanelGetVar("BothBars") then
			position = 1;
		elseif TitanPanelSettings.Location[i] == "Bar" then
			position = TitanPanelGetVar("Position");
		else
			position = 2;
		end

		-- Set panel scale
		local min = TITAN_PANELSCALE_MIN;
		local max = TITAN_PANELSCALE_MAX;
		local scale = min + max - this:GetValue();
		TitanPanelSetVar("Scale", scale);
		
		-- Adjust panel scale
		TitanPanel_SetScale();
		TitanPanel_RefreshPanelButtons();
		
		-- Adjust frame positions
		TitanMovableFrame_MoveFrames(position);
		TitanMovableFrame_AdjustBlizzardFrames();
		
		-- Update slider value text
		getglobal(this:GetName().."Text"):SetText(TitanPanelUIScale_GetSCaleText(scale));

		-- Update GameTooltip
		if (this.tooltipText) then  --??
			this.tooltipText = TitanOptionSlider_TooltipText(TITAN_UISCALE_CONTROL_TOOLTIP_PANEL, TitanPanelUIScale_GetSCaleText(scale));
			GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
		end
	end
end

function TitanPanelUIScale_GetSCaleText(scale)
	return tostring(floor(100 * scale + 0.5)) .. "%";
end

function TitanPanelSpacing_GetSpacing(spacing)
	return tostring(floor((100 * spacing) /80)) .. "%";
end

function TitanPanelTooltip_GetAlpha(alpha)
	return tostring(floor(100 * alpha)) .. "%";
end

function TitanPanelUIScaleControlFrame_OnLoad()
  getglobal(this:GetName().."Title"):SetText(TITAN_UISCALE_MENU_TEXT);
	getglobal(this:GetName().."UITitle"):SetText(TITAN_UISCALE_CONTROL_TITLE_UI);
	getglobal(this:GetName().."PanelTitle"):SetText(TITAN_UISCALE_CONTROL_TITLE_PANEL);
	getglobal(this:GetName().."ButtonSpacingTitle"):SetText(TITAN_UISCALE_CONTROL_TITLE_BUTTON);
	getglobal(this:GetName().."TooltipTransTitle"):SetText(TITAN_UISCALE_CONTROL_TITLE_TOOLTIPTRANS);
	getglobal(this:GetName().."TooltipFontTitle"):SetText(TITAN_UISCALE_CONTROL_TITLE_TOOLTIPFONT);
	this:SetBackdropBorderColor(1, 1, 1);
	this:SetBackdropColor(0, 0, 0, 1);
end

function TitanPanelUIScaleControlFrame_OnShow()
	this:SetScale(UIParent:GetEffectiveScale());
end

function TitanPanelUIScaleControlFrame_OnUpdate(elapsed)
	TitanUtils_CheckFrameCounting(this, elapsed);
end

function TitanPanelRightClickMenu_PrepareUIScaleMenu()
	TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_UISCALE_ID].menuText);
	TitanPanelRightClickMenu_AddCommand(TITAN_PANEL_MENU_HIDE, TITAN_UISCALE_ID, TITAN_PANEL_MENU_FUNC_HIDE);
end

function TitanPanelButtonSpacingControlSlider_OnEnter()
this.tooltipText = TitanOptionSlider_TooltipText(TITAN_UISCALE_CONTROL_TOOLTIP_BUTTON, TitanPanelSpacing_GetSpacing(TitanPanelGetVar("ButtonSpacing")));
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	TitanUtils_StopFrameCounting(this:GetParent());
end

function TitanPanelButtonSpacingControlSlider_OnLeave()
this.tooltipText = nil;
	GameTooltip:Hide();
	TitanUtils_StartFrameCounting(this:GetParent(), TITAN_UISCALE_FRAME_SHOW_TIME);
end

function TitanPanelButtonSpacingControlSlider_OnShow()
	local min = TITAN_BUTTONSPACING_MIN;
	local max = TITAN_BUTTONSPACING_MAX;
	local step = TITAN_BUTTONSPACING_STEP;
	
	getglobal(this:GetName().."Text"):SetText(TitanPanelSpacing_GetSpacing(TitanPanelGetVar("ButtonSpacing")));
	getglobal(this:GetName().."High"):SetText(TITAN_UISCALE_CONTROL_LOW_BUTTON);
	getglobal(this:GetName().."Low"):SetText(TITAN_UISCALE_CONTROL_HIGH_BUTTON);
	this:SetMinMaxValues(min,max);
	this:SetValueStep(step);
	this:SetValue(max + min - TitanPanelGetVar("ButtonSpacing"));
end

function TitanPanelButtonSpacingControlSlider_OnValueChanged(arg1)

	local min = TITAN_BUTTONSPACING_MIN;
	local max = TITAN_BUTTONSPACING_MAX;
	local step = TITAN_BUTTONSPACING_STEP;
	local tempval = this:GetValue();
	
	if arg1 == -1 then
	  this:SetValue(tempval + step);
	end
	
	if arg1 == 1 then
	  this:SetValue(tempval - step);
	end
	
	getglobal(this:GetName().."Text"):SetText(TitanPanelSpacing_GetSpacing(max + min - this:GetValue()));
	TitanPanelSetVar("ButtonSpacing", max + min - this:GetValue())
	TitanPanel_InitPanelButtons();
	-- Update GameTooltip
	if (this.tooltipText) then
		  this.tooltipText = TitanOptionSlider_TooltipText(TITAN_UISCALE_CONTROL_TOOLTIP_BUTTON, TitanPanelSpacing_GetSpacing(max + min - this:GetValue()));
		GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	end
end

function TitanPanelTooltipTransControlSlider_OnEnter()
this.tooltipText = TitanOptionSlider_TooltipText(TITAN_UISCALE_CONTROL_TOOLTIP_TOOLTIPTRANS, TitanPanelTooltip_GetAlpha(TitanPanelGetVar("TooltipTrans")));
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	TitanUtils_StopFrameCounting(this:GetParent());
end

function TitanPanelTooltipTransControlSlider_OnLeave()
this.tooltipText = nil;
	GameTooltip:Hide();
	TitanUtils_StartFrameCounting(this:GetParent(), TITAN_UISCALE_FRAME_SHOW_TIME);
end

function TitanPanelTooltipTransControlSlider_OnShow()
	local min = TITAN_TOOLTIPTRANS_MIN;
	local max = TITAN_TOOLTIPTRANS_MAX;
	local step = TITAN_TOOLTIPTRANS_STEP;
		
	getglobal(this:GetName().."Text"):SetText(TitanPanelTooltip_GetAlpha(TitanPanelGetVar("TooltipTrans")));
	getglobal(this:GetName().."High"):SetText(TITAN_UISCALE_CONTROL_LOW_TOOLTIPTRANS);
	getglobal(this:GetName().."Low"):SetText(TITAN_UISCALE_CONTROL_HIGH_TOOLTIPTRANS);
	this:SetMinMaxValues(min,max);
	this:SetValueStep(step);
	this:SetValue(max + min - TitanPanelGetVar("TooltipTrans"));
end

function TitanPanelTooltipTransControlSlider_OnValueChanged(arg1)
	local min = TITAN_TOOLTIPTRANS_MIN;
	local max = TITAN_TOOLTIPTRANS_MAX;
	local step = TITAN_TOOLTIPTRANS_STEP;
	local tempval = this:GetValue();
	
	if arg1 == -1 then
	  this:SetValue(tempval + step);
	end
	
	if arg1 == 1 then
	  this:SetValue(tempval - step);
	end
	
	getglobal(this:GetName().."Text"):SetText(TitanPanelTooltip_GetAlpha(max + min - this:GetValue()));
	TitanPanelSetVar("TooltipTrans", max + min - this:GetValue())
	-- Update GameTooltip
	if (this.tooltipText) then
		this.tooltipText = TitanOptionSlider_TooltipText(TITAN_UISCALE_CONTROL_TOOLTIP_TOOLTIPTRANS, TitanPanelTooltip_GetAlpha(max + min - this:GetValue()));
		GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	end
end


function TitanPanelTooltipFontControlSlider_OnEnter()
this.tooltipText = TitanOptionSlider_TooltipText(TITAN_UISCALE_CONTROL_TOOLTIP_TOOLTIPFONT, TitanPanelTooltip_GetAlpha(TitanPanelGetVar("TooltipFont")));
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	TitanUtils_StopFrameCounting(this:GetParent());
end

function TitanPanelTooltipFontControlSlider_OnLeave()
this.tooltipText = nil;
	GameTooltip:Hide();
	TitanUtils_StartFrameCounting(this:GetParent(), TITAN_UISCALE_FRAME_SHOW_TIME);
end

function TitanPanelTooltipFontControlSlider_OnShow()
	local min = TITAN_TOOLTIPFONT_MIN;
	local max = TITAN_TOOLTIPFONT_MAX;
	local step = TITAN_TOOLTIPFONT_STEP;
		
	getglobal(this:GetName().."Text"):SetText(TitanPanelTooltip_GetAlpha(TitanPanelGetVar("TooltipFont")));
	getglobal(this:GetName().."High"):SetText(TITAN_UISCALE_CONTROL_LOW_TOOLTIPFONT);
	getglobal(this:GetName().."Low"):SetText(TITAN_UISCALE_CONTROL_HIGH_TOOLTIPFONT);
	this:SetMinMaxValues(min,max);
	this:SetValueStep(step);
	this:SetValue(max + min - TitanPanelGetVar("TooltipFont"));
end

function TitanPanelTooltipFontControlSlider_OnValueChanged(arg1)
	local min = TITAN_TOOLTIPFONT_MIN;
	local max = TITAN_TOOLTIPFONT_MAX;
	local step = TITAN_TOOLTIPFONT_STEP;
	local tempval = this:GetValue();
	
	if arg1 == -1 then
	  this:SetValue(tempval + step*2);
	end
	
	if arg1 == 1 then
	  this:SetValue(tempval - step*2);
	end
	
	getglobal(this:GetName().."Text"):SetText(TitanPanelTooltip_GetAlpha(max + min - this:GetValue()));
	local varset = tonumber(format("%.2f", max + min - this:GetValue()));
	TitanPanelSetVar("TooltipFont", varset)
	-- Update GameTooltip
	if (this.tooltipText) then
		this.tooltipText = TitanOptionSlider_TooltipText(TITAN_UISCALE_CONTROL_TOOLTIP_TOOLTIPFONT, TitanPanelTooltip_GetAlpha(max + min - this:GetValue()));
		GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	end
end


function TitanPanelTooltipFontCheckButton_OnShow()
TitanPanelTooltipFontCheckButtonText:SetText(TITAN_UISCALE_TOOLTIP_DISABLE_TEXT);
     
     if TitanPanelGetVar("DisableTooltipFont") then
          this:SetChecked(1);
     else
          this:SetChecked(0);
     end
end

function TitanPanelTooltipFontCheckButton_OnClick()
  TitanPanelToggleVar("DisableTooltipFont");
end

function TitanPanelTooltipFontCheckButton_OnEnter()
  this.tooltipText = TITAN_UISCALE_TOOLTIP_DISABLE_TOOLTIP;
     GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
     GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
     TitanUtils_StopFrameCounting(this:GetParent());
end

function TitanPanelTooltipFontCheckButton_OnLeave()
  this.tooltipText = nil;
     GameTooltip:Hide();
     TitanUtils_StartFrameCounting(this:GetParent(), TITAN_UISCALE_FRAME_SHOW_TIME);
end