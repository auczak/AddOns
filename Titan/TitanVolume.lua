TITAN_VOLUME_ID = "Volume";
TITAN_VOLUME_FRAME_SHOW_TIME = 0.5;

function TitanPanelVolumeButton_OnLoad()
	this.registry = { 
		id = TITAN_VOLUME_ID,
		builtIn = 1,
		version = TITAN_VERSION,
		menuText = TITAN_VOLUME_MENU_TEXT, 
		tooltipTitle = TITAN_VOLUME_TOOLTIP, 
		tooltipTextFunction = "TitanPanelVolumeButton_GetTooltipText",
		iconWidth = 32,
		iconButtonWidth = 18,
	};
end

function TitanPanelVolumeButton_OnShow()
	TitanPanelVolume_SetVolumeIcon();
end

function TitanPanelVolumeButton_OnEnter()
	-- Confirm master volume value
	TitanPanelMasterVolumeControlSlider:SetValue(1 - GetCVar("Sound_MasterVolume"));
	TitanPanelAmbienceVolumeControlSlider:SetValue(1 - GetCVar("Sound_AmbienceVolume"));
	TitanPanelSoundVolumeControlSlider:SetValue(1 - GetCVar("Sound_SFXVolume"));
	TitanPanelMusicVolumeControlSlider:SetValue(1 - GetCVar("Sound_MusicVolume"));
	TitanPanelMicrophoneVolumeControlSlider:SetValue(1 - GetCVar("OutboundChatVolume"));
	TitanPanelSpeakerVolumeControlSlider:SetValue(1 - GetCVar("InboundChatVolume"));
	TitanPanelVolume_SetVolumeIcon();
	reset_Master = GetCVar("Sound_MasterVolume");
	reset_Ambience = GetCVar("Sound_AmbienceVolume");
	reset_Sound = GetCVar("Sound_SFXVolume");
	reset_Music = GetCVar("Sound_MusicVolume");
	reset_Microphone = GetCVar("OutboundChatVolume");
	reset_Speaker = GetCVar("InboundChatVolume");
	SetCVar("Sound_MasterVolume", 0);
	SetCVar("Sound_AmbienceVolume", 0);
	SetCVar("Sound_SFXVolume", 0);
	SetCVar("Sound_MusicVolume", 0);
	SetCVar("OutboundChatVolume", 0);
	SetCVar("InboundChatVolume", 0);
	SetCVar("Sound_MasterVolume", reset_Master);
	SetCVar("Sound_AmbienceVolume", reset_Ambience);
	SetCVar("Sound_SFXVolume", reset_Sound);
	SetCVar("Sound_MusicVolume", reset_Music);
	SetCVar("OutboundChatVolume", reset_Microphone);
	SetCVar("InboundChatVolume", reset_Speaker);
end

-- 'Master' 
function TitanPanelMasterVolumeControlSlider_OnEnter()
	this.tooltipText = TitanOptionSlider_TooltipText(TITAN_VOLUME_CONTROL_TOOLTIP, TitanPanelVolume_GetVolumeText(GetCVar("Sound_MasterVolume")));
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	TitanUtils_StopFrameCounting(this:GetParent());
end

function TitanPanelMasterVolumeControlSlider_OnLeave()
	this.tooltipText = nil;
	GameTooltip:Hide();
	TitanUtils_StartFrameCounting(this:GetParent(), TITAN_VOLUME_FRAME_SHOW_TIME);
end

function TitanPanelMasterVolumeControlSlider_OnShow()
        
	getglobal(this:GetName().."Text"):SetText(TitanPanelVolume_GetVolumeText(GetCVar("Sound_MasterVolume")));
	getglobal(this:GetName().."High"):SetText(TITAN_VOLUME_CONTROL_LOW);
	getglobal(this:GetName().."Low"):SetText(TITAN_VOLUME_CONTROL_HIGH);
	this:SetMinMaxValues(0, 1);
	this:SetValueStep(0.01);
	this:SetValue(1 - GetCVar("Sound_MasterVolume"));
end

function TitanPanelMasterVolumeControlSlider_OnValueChanged(arg1)
getglobal(this:GetName().."Text"):SetText(TitanPanelVolume_GetVolumeText(1 - this:GetValue()));

local tempval = this:GetValue();
	
	if arg1 == -1 then
	  this:SetValue(tempval + 0.01);
	end
	
	if arg1 == 1 then
	  this:SetValue(tempval - 0.01);
	end
	SetCVar("Sound_MasterVolume", 1 - this:GetValue());
	
	TitanPanelVolume_SetVolumeIcon();

	-- Update GameTooltip
	if (this.tooltipText) then
		this.tooltipText = TitanOptionSlider_TooltipText(TITAN_VOLUME_CONTROL_TOOLTIP, TitanPanelVolume_GetVolumeText(1 - this:GetValue()));
		GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	end
end
-- 'Music'
function TitanPanelMusicVolumeControlSlider_OnEnter()
	this.tooltipText = TitanOptionSlider_TooltipText(TITAN_VOLUME_CONTROL_TOOLTIP, TitanPanelVolume_GetVolumeText(GetCVar("Sound_MusicVolume")));
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	TitanUtils_StopFrameCounting(this:GetParent());
end

function TitanPanelMusicVolumeControlSlider_OnLeave()
	this.tooltipText = nil;
	GameTooltip:Hide();
	TitanUtils_StartFrameCounting(this:GetParent(), TITAN_VOLUME_FRAME_SHOW_TIME);
end

function TitanPanelMusicVolumeControlSlider_OnShow()
        
	getglobal(this:GetName().."Text"):SetText(TitanPanelVolume_GetVolumeText(GetCVar("Sound_MusicVolume")));
	getglobal(this:GetName().."High"):SetText(TITAN_VOLUME_CONTROL_LOW);
	getglobal(this:GetName().."Low"):SetText(TITAN_VOLUME_CONTROL_HIGH);
	this:SetMinMaxValues(0, 1);
	this:SetValueStep(0.01);
	this:SetValue(1 - GetCVar("Sound_MusicVolume"));
end

function TitanPanelMusicVolumeControlSlider_OnValueChanged(arg1)
getglobal(this:GetName().."Text"):SetText(TitanPanelVolume_GetVolumeText(1 - this:GetValue()));
local tempval = this:GetValue();
	
	if arg1 == -1 then
	  this:SetValue(tempval + 0.01);
	end
	
	if arg1 == 1 then
	  this:SetValue(tempval - 0.01);
	end

	SetCVar("Sound_MusicVolume", 1 - this:GetValue());
	
	
	-- Update GameTooltip
	if (this.tooltipText) then
		this.tooltipText = TitanOptionSlider_TooltipText(TITAN_VOLUME_CONTROL_TOOLTIP, TitanPanelVolume_GetVolumeText(1 - this:GetValue()));
		GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	end
end
-- 'Sound'
function TitanPanelSoundVolumeControlSlider_OnEnter()
	this.tooltipText = TitanOptionSlider_TooltipText(TITAN_VOLUME_CONTROL_TOOLTIP, TitanPanelVolume_GetVolumeText(GetCVar("Sound_SFXVolume")));
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	TitanUtils_StopFrameCounting(this:GetParent());
end

function TitanPanelSoundVolumeControlSlider_OnLeave()
	this.tooltipText = nil;
	GameTooltip:Hide();
	TitanUtils_StartFrameCounting(this:GetParent(), TITAN_VOLUME_FRAME_SHOW_TIME);
end

function TitanPanelSoundVolumeControlSlider_OnShow()
        
	getglobal(this:GetName().."Text"):SetText(TitanPanelVolume_GetVolumeText(GetCVar("Sound_SFXVolume")));
	getglobal(this:GetName().."High"):SetText(TITAN_VOLUME_CONTROL_LOW);
	getglobal(this:GetName().."Low"):SetText(TITAN_VOLUME_CONTROL_HIGH);
	this:SetMinMaxValues(0, 1);
	this:SetValueStep(0.01);
	this:SetValue(1 - GetCVar("Sound_SFXVolume"));
end

function TitanPanelSoundVolumeControlSlider_OnValueChanged(arg1)
getglobal(this:GetName().."Text"):SetText(TitanPanelVolume_GetVolumeText(1 - this:GetValue()));
local tempval = this:GetValue();
	
	if arg1 == -1 then
	  this:SetValue(tempval + 0.01);
	end
	
	if arg1 == 1 then
	  this:SetValue(tempval - 0.01);
	end
	
	SetCVar("Sound_SFXVolume", 1 - this:GetValue());
	
	-- Update GameTooltip
	if (this.tooltipText) then
		this.tooltipText = TitanOptionSlider_TooltipText(TITAN_VOLUME_CONTROL_TOOLTIP, TitanPanelVolume_GetVolumeText(1 - this:GetValue()));
		GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	end
end
-- 'Ambience'
function TitanPanelAmbienceVolumeControlSlider_OnEnter()
	this.tooltipText = TitanOptionSlider_TooltipText(TITAN_VOLUME_CONTROL_TOOLTIP, TitanPanelVolume_GetVolumeText(GetCVar("Sound_AmbienceVolume")));
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	TitanUtils_StopFrameCounting(this:GetParent());
end

function TitanPanelAmbienceVolumeControlSlider_OnLeave()
	this.tooltipText = nil;
	GameTooltip:Hide();
	TitanUtils_StartFrameCounting(this:GetParent(), TITAN_VOLUME_FRAME_SHOW_TIME);
end

function TitanPanelAmbienceVolumeControlSlider_OnShow()
        
	getglobal(this:GetName().."Text"):SetText(TitanPanelVolume_GetVolumeText(GetCVar("Sound_AmbienceVolume")));
	getglobal(this:GetName().."High"):SetText(TITAN_VOLUME_CONTROL_LOW);
	getglobal(this:GetName().."Low"):SetText(TITAN_VOLUME_CONTROL_HIGH);
	this:SetMinMaxValues(0, 1);
	this:SetValueStep(0.01);
	this:SetValue(1 - GetCVar("Sound_AmbienceVolume"));
end

function TitanPanelAmbienceVolumeControlSlider_OnValueChanged(arg1)
getglobal(this:GetName().."Text"):SetText(TitanPanelVolume_GetVolumeText(1 - this:GetValue()));
local tempval = this:GetValue();
	
	if arg1 == -1 then
	  this:SetValue(tempval + 0.01);
	end
	
	if arg1 == 1 then
	  this:SetValue(tempval - 0.01);
	end
	SetCVar("Sound_AmbienceVolume", 1 - this:GetValue());
	
	
	-- Update GameTooltip
	if (this.tooltipText) then
		this.tooltipText = TitanOptionSlider_TooltipText(TITAN_VOLUME_CONTROL_TOOLTIP, TitanPanelVolume_GetVolumeText(1 - this:GetValue()));
		GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	end
end
function TitanPanelVolume_GetVolumeText(volume)
	return tostring(floor(100 * volume + 0.5)) .. "%";
end
-- 'Microphone'
function TitanPanelMicrophoneVolumeControlSlider_OnEnter()
	this.tooltipText = TitanOptionSlider_TooltipText(TITAN_VOLUME_CONTROL_TOOLTIP, TitanPanelVolume_GetVolumeText(GetCVar("OutboundChatVolume")));
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	TitanUtils_StopFrameCounting(this:GetParent());
end

function TitanPanelMicrophoneVolumeControlSlider_OnLeave()
	this.tooltipText = nil;
	GameTooltip:Hide();
	TitanUtils_StartFrameCounting(this:GetParent(), TITAN_VOLUME_FRAME_SHOW_TIME);
end

function TitanPanelMicrophoneVolumeControlSlider_OnShow()
        
	getglobal(this:GetName().."Text"):SetText(TitanPanelVolume_GetVolumeText(GetCVar("OutboundChatVolume")));
	getglobal(this:GetName().."High"):SetText(TITAN_VOLUME_CONTROL_LOW);
	getglobal(this:GetName().."Low"):SetText(TITAN_VOLUME_CONTROL_HIGH);
	this:SetMinMaxValues(-1.50, 0.75);
	this:SetValueStep(0.01);
	this:SetValue(1 - GetCVar("OutboundChatVolume"));
end

function TitanPanelMicrophoneVolumeControlSlider_OnValueChanged(arg1)
getglobal(this:GetName().."Text"):SetText(TitanPanelVolume_GetVolumeText(1 - this:GetValue()));
local tempval = this:GetValue();
	
	if arg1 == -1 then
	  this:SetValue(tempval + 0.02);
	end
	
	if arg1 == 1 then
	  this:SetValue(tempval - 0.02);
	end
	SetCVar("OutboundChatVolume", 1 - this:GetValue());
	
	
	-- Update GameTooltip
	if (this.tooltipText) then
		this.tooltipText = TitanOptionSlider_TooltipText(TITAN_VOLUME_CONTROL_TOOLTIP, TitanPanelVolume_GetVolumeText(1 - this:GetValue()));
		GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	end
end
function TitanPanelVolume_GetVolumeText(volume)
	return tostring(floor(100 * volume + 0.5)) .. "%";
end
-- 'Speaker'
function TitanPanelSpeakerVolumeControlSlider_OnEnter()
	this.tooltipText = TitanOptionSlider_TooltipText(TITAN_VOLUME_CONTROL_TOOLTIP, TitanPanelVolume_GetVolumeText(GetCVar("InboundChatVolume")));
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	TitanUtils_StopFrameCounting(this:GetParent());
end

function TitanPanelSpeakerVolumeControlSlider_OnLeave()
	this.tooltipText = nil;
	GameTooltip:Hide();
	TitanUtils_StartFrameCounting(this:GetParent(), TITAN_VOLUME_FRAME_SHOW_TIME);
end

function TitanPanelSpeakerVolumeControlSlider_OnShow()
        
	getglobal(this:GetName().."Text"):SetText(TitanPanelVolume_GetVolumeText(GetCVar("InboundChatVolume")));
	getglobal(this:GetName().."High"):SetText(TITAN_VOLUME_CONTROL_LOW);
	getglobal(this:GetName().."Low"):SetText(TITAN_VOLUME_CONTROL_HIGH);
	this:SetMinMaxValues(0, 1);
	this:SetValueStep(0.01);
	this:SetValue(1 - GetCVar("InboundChatVolume"));
end

function TitanPanelSpeakerVolumeControlSlider_OnValueChanged(arg1)
getglobal(this:GetName().."Text"):SetText(TitanPanelVolume_GetVolumeText(1 - this:GetValue()));
local tempval = this:GetValue();
	
	if arg1 == -1 then
	  this:SetValue(tempval + 0.01);
	end
	
	if arg1 == 1 then
	  this:SetValue(tempval - 0.01);
	end
	SetCVar("InboundChatVolume", 1 - this:GetValue());
	
	
	-- Update GameTooltip
	if (this.tooltipText) then
		this.tooltipText = TitanOptionSlider_TooltipText(TITAN_VOLUME_CONTROL_TOOLTIP, TitanPanelVolume_GetVolumeText(1 - this:GetValue()));
		GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1);
	end
end
function TitanPanelVolume_GetVolumeText(volume)
	return tostring(floor(100 * volume + 0.5)) .. "%";
end

function TitanPanelVolumeControlFrame_OnLoad()
	getglobal(this:GetName().."Title"):SetText(TITAN_VOLUME_CONTROL_TITLE);
	getglobal(this:GetName().."MasterTitle"):SetText(TITAN_VOLUME_MASTER_CONTROL_TITLE);
	getglobal(this:GetName().."MusicTitle"):SetText(TITAN_VOLUME_MUSIC_CONTROL_TITLE);
	getglobal(this:GetName().."SoundTitle"):SetText(TITAN_VOLUME_SOUND_CONTROL_TITLE);
	getglobal(this:GetName().."AmbienceTitle"):SetText(TITAN_VOLUME_AMBIENCE_CONTROL_TITLE);
	getglobal(this:GetName().."MicrophoneTitle"):SetText(TITAN_VOLUME_MICROPHONE_CONTROL_TITLE);
	getglobal(this:GetName().."SpeakerTitle"):SetText(TITAN_VOLUME_SPEAKER_CONTROL_TITLE);
	this:SetBackdropBorderColor(1, 1, 1);
	this:SetBackdropColor(0, 0, 0, 1);
end

function TitanPanelVolumeControlFrame_OnUpdate(elapsed)
	TitanUtils_CheckFrameCounting(this, elapsed);
end

function TitanPanelVolume_SetVolumeIcon()
	local icon = getglobal("TitanPanelVolumeButtonIcon");
	local masterVolume = tonumber(GetCVar("Sound_MasterVolume"));
	if (masterVolume <= 0) then
		icon:SetTexture(TITAN_ARTWORK_PATH.."TitanVolumeMute");
	elseif (masterVolume < 0.33) then
		icon:SetTexture(TITAN_ARTWORK_PATH.."TitanVolumeLow");
	elseif (masterVolume < 0.66) then
		icon:SetTexture(TITAN_ARTWORK_PATH.."TitanVolumeMedium");
	else
		icon:SetTexture(TITAN_ARTWORK_PATH.."TitanVolumeHigh");
	end	
end

function TitanPanelVolumeButton_GetTooltipText()
	local volumeMasterText = TitanPanelVolume_GetVolumeText(GetCVar("Sound_MasterVolume"));
	local volumeSoundText = TitanPanelVolume_GetVolumeText(GetCVar("Sound_SFXVolume"));
	local volumeMusicText = TitanPanelVolume_GetVolumeText(GetCVar("Sound_MusicVolume"));
	local volumeAmbienceText = TitanPanelVolume_GetVolumeText(GetCVar("Sound_AmbienceVolume"));
	local volumeMicrophoneText = TitanPanelVolume_GetVolumeText(GetCVar("OutboundChatVolume"));
	local volumeSpeakerText = TitanPanelVolume_GetVolumeText(GetCVar("InboundChatVolume"));
	return ""..
		TITAN_VOLUME_MASTER_TOOLTIP_VALUE.."\t"..TitanUtils_GetHighlightText(volumeMasterText).."\n"..
		TITAN_VOLUME_SOUND_TOOLTIP_VALUE.."\t"..TitanUtils_GetHighlightText(volumeSoundText).."\n"..
		TITAN_VOLUME_MUSIC_TOOLTIP_VALUE.."\t"..TitanUtils_GetHighlightText(volumeMusicText).."\n"..
		TITAN_VOLUME_AMBIENCE_TOOLTIP_VALUE.."\t"..TitanUtils_GetHighlightText(volumeAmbienceText).."\n"..
		TITAN_VOLUME_MICROPHONE_TOOLTIP_VALUE.."\t"..TitanUtils_GetHighlightText(volumeMicrophoneText).."\n"..
		TITAN_VOLUME_SPEAKER_TOOLTIP_VALUE.."\t"..TitanUtils_GetHighlightText(volumeSpeakerText).."\n"..
		TitanUtils_GetGreenText(TITAN_VOLUME_TOOLTIP_HINT1).."\n"..
		TitanUtils_GetGreenText(TITAN_VOLUME_TOOLTIP_HINT2);
end

function TitanPanelRightClickMenu_PrepareVolumeMenu()
	TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_VOLUME_ID].menuText);
	TitanPanelRightClickMenu_AddCommand(TITAN_PANEL_MENU_HIDE, TITAN_VOLUME_ID, TITAN_PANEL_MENU_FUNC_HIDE);
end
