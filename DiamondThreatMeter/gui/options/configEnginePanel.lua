local activeModule = "GUI configuration engine panel";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local MAX_EMULATION_ROWS = 2;

local saveSchema = {
    [1] = {
        part = "engine",
        key = "aggroValidationDelay",
        method = "NUMERIC_CONTROL",
        value = "DTM_ConfigurationFrame_EnginePanel_AggroDelaySlider",
    },

    [2] = {
        part = "engine",
        key = "checkZoneWideCombat",
        method = "NUMERIC_CONTROL",
        value = "DTM_ConfigurationFrame_EnginePanel_ZoneWideCheckRateSlider",
    },

    [3] = {
        part = "engine",
        key = "tpsUpdateRate",
        method = "NUMERIC_CONTROL",
        value = "DTM_ConfigurationFrame_EnginePanel_TPSUpdateRateSlider",
    },

    [4] = {
        part = "engine",
        key = "detectUnitReset",
        method = "BOOLEAN_CONTROL",
        value = "DTM_ConfigurationFrame_EnginePanel_DetectResetCheckButton",
    },

    [5] = {
        part = "engine",
        key = "workMethod",
        method = "DROPLIST_CONTROL",
        value = "DTM_ConfigurationFrame_EnginePanel_WorkMethodDropDown",
        list = {
            [1] = "PARSE",
            [2] = "HYBRID",
            [3] = "NATIVE",
        },
    },
};

local defaultSchema = saveSchema; -- Indeed, one schema only is enough.
local updateSchema = saveSchema; -- It's simply the reverse way.

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_EnginePanel_OnLoad()
--
-- Called when the engine config panel is loaded.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_EnginePanel_OnLoad(self)
    -- Registers itself as a custom tab of Blizzard Interface options.

    self.name = DTM_Localise("configEngineCategory");
    self.parent = "DiamondThreatMeter";

    self.okay = function(self)
                    DTM_ConfigurationFramePanel_Save(self, saveSchema);
                    DTM_ConfigurationFrame_EnginePanel_SaveEmulation();
                end;
    self.cancel = function(self) DTM_ConfigurationFrame_EnginePanel_Refresh(self); end;
    self.default = function(self)
                       DTM_ConfigurationFramePanel_Default(self, defaultSchema);
                       DTM_ConfigurationFrame_EnginePanel_DefaultEmulation();
                       DTM_ConfigurationFrame_EnginePanel_Refresh(self);
                   end;

    InterfaceOptions_AddCategory(self);

    -- Configure regular widgets.

    DTM_ConfigurationFramePanel_SetSlider(DTM_ConfigurationFrame_EnginePanel_AggroDelaySlider,
                                          0.000, 3.000, 0.100,
                                          "%.1f s", "0 s", "3 s",
                                          DTM_Localise("configAggroDelaySlider"), DTM_Localise("configTooltipAggroDelayExplain"));

    DTM_ConfigurationFramePanel_SetSlider(DTM_ConfigurationFrame_EnginePanel_ZoneWideCheckRateSlider,
                                          0.000, 10.000, 1.000,
                                          function(value) if ( value <= 0 ) then return "OFF"; else return string.format("%.0f s", value); end end, "OFF", "10 s",
                                          DTM_Localise("configZoneWideCheckRateSlider"), DTM_Localise("configTooltipZoneWideCheckRateExplain"));

    DTM_ConfigurationFramePanel_SetSlider(DTM_ConfigurationFrame_EnginePanel_TPSUpdateRateSlider,
                                          0.000, 5.000, 0.500,
                                          function(value) if ( value <= 0 ) then return "OFF"; else return string.format("%.1f s", value); end end, "OFF", "5 s",
                                          DTM_Localise("configTPSUpdateRateSlider"), DTM_Localise("configTooltipTPSUpdateRateExplain"));

    if ( DTM_OnWotLK() ) then
        DTM_ConfigurationFramePanel_SetDropDown(DTM_ConfigurationFrame_EnginePanel_WorkMethodDropDown, 128,
                                                {DTM_Localise("configWorkMethodAnalyze"),        DTM_Localise("configWorkMethodHybrid"),        DTM_Localise("configWorkMethodNative")},
                                                {DTM_Localise("configTooltipWorkMethodAnalyze"), DTM_Localise("configTooltipWorkMethodHybrid"), DTM_Localise("configTooltipWorkMethodNative")},
                                                {nil, nil, nil});
  else
        DTM_ConfigurationFramePanel_SetDropDown(DTM_ConfigurationFrame_EnginePanel_WorkMethodDropDown, 128,
                                                {DTM_Localise("configWorkMethodAnalyze"),        DTM_Localise("configWorkMethodHybrid"),        DTM_Localise("configWorkMethodNative")},
                                                {DTM_Localise("configTooltipWorkMethodAnalyze"), DTM_Localise("configTooltipWorkMethodHybrid"), DTM_Localise("configTooltipWorkMethodNative")},
                                                {nil, 1, 1});
    end

    -- Then we do the translation of stuff we need to only do once.

    DTM_ConfigurationFramePanel_SetTextAndTooltip(DTM_ConfigurationFrame_EnginePanel_DetectResetCheckButton, "configDetectReset", "configTooltipDetectResetExplain");
    DTM_ConfigurationFrame_EnginePanel_WorkMethodDropDownCaption:SetText( DTM_Localise("configWorkMethod") );
    DTM_ConfigurationFrame_EnginePanel_EmulationPanelTitle:SetText( DTM_Localise("configEngineEmulation") );

    -- Build the emulation rows, and resize the emulation frame to the maximum emulation rows at once.

    local numEmu = DTM_Emulation_GetNumberOfEmulableAddOns();
    local name, desc, spoof, emulable;

    self.emulationRow = { };

    for i=1, MAX_EMULATION_ROWS do
        self.emulationRow[i] = CreateFrame("Frame", self:GetName().."_EmulationRow"..i, DTM_ConfigurationFrame_EnginePanel_EmulationPanel, "DTM_ConfigurationFrame_EmulationRowTemplate");

        if ( i <= numEmu ) then
            self.emulationRow[i].id = i;

            name, desc, spoof, emulable = DTM_Emulation_GetEmulableAddOnData(i);
 
            self.emulationRow[i].name = name;
            self.emulationRow[i].desc = desc;
            self.emulationRow[i].canSpoof = spoof;
            self.emulationRow[i].canEmulate = 1; -- We do not know yet.

            self.emulationRow[i].enableButton = getglobal(self.emulationRow[i]:GetName().."EnableCheckButton");
            self.emulationRow[i].spoofButton = getglobal(self.emulationRow[i]:GetName().."SpoofCheckButton");

            DTM_ConfigurationFramePanel_SetTextAndTooltip(self.emulationRow[i].enableButton, "configEmuEnable", "configTooltipEmulationExplain");
            DTM_ConfigurationFramePanel_SetTextAndTooltip(self.emulationRow[i].spoofButton, "configEmuSpoof", "configTooltipSpoofExplain");
        end
    end

    DTM_ConfigurationFrame_EnginePanel_EmulationPanel:SetHeight( 16 + 36 * MAX_EMULATION_ROWS );

    -- Okay, update its display.

    DTM_ConfigurationFrame_EnginePanel_Refresh(self);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_EnginePanel_OnUpdate(self, elapsed)
--
-- Called when the engine config panel is updated.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_EnginePanel_OnUpdate(self, elapsed)
    -- Update here infos etc. that can vary through time.

    -- We first update the toggle button text and caption.
    local status = DTM_IsEngineRunning();
    if ( status ) then -- Non-nil states will show up a disable command.
        DTM_ConfigurationFrame_EnginePanel_ToggleButton:SetText( DTM_Localise("configEngineDisable") );
        if ( status == 1 ) then
            DTM_ConfigurationFrame_EnginePanel_ToggleButtonCaption:SetText( DTM_Localise("configEngineDisableCaption") );
      elseif ( status == 2 ) then
            DTM_ConfigurationFrame_EnginePanel_ToggleButtonCaption:SetText( DTM_Localise("configEnginePaused") );
      elseif ( status == 3 ) then
            DTM_ConfigurationFrame_EnginePanel_ToggleButtonCaption:SetText( DTM_Localise("configEngineEmergencyStop") );
        end
  else
        DTM_ConfigurationFrame_EnginePanel_ToggleButton:SetText( DTM_Localise("configEngineEnable") );
        DTM_ConfigurationFrame_EnginePanel_ToggleButtonCaption:SetText( DTM_Localise("configEngineEnableCaption") );
    end
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_EnginePanel_Refresh(self)
--
-- Called when the engine config panel has to refresh its controls.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_EnginePanel_Refresh(self)
    -- In this function we first do tasks common to all config panels.

    DTM_ConfigurationFramePanel_Update(self, updateSchema);

    -- Update emulation rows.

    local row;

    for i=1, MAX_EMULATION_ROWS do
        row = self.emulationRow[i];
        if ( row.id ) then
            local _, _, _, emulable = DTM_Emulation_GetEmulableAddOnData(row.id);
            row.canEmulate = emulable;

            if ( row.canEmulate ) then
                getglobal(row:GetName().."Text"):SetText(row.name.."|cffffffff - "..row.desc.."|r");

                key = "emulation:"..row.name;
                if ( DTM_GetSavedVariable("engine", key, "modified") == 1 ) then
                    row.enableButton:SetChecked(1);
              else
                    row.enableButton:SetChecked(nil);
                end
                row.enableButton:Enable();
                row.enableButton:SetAlpha(1.0);

                if ( row.canSpoof ) then
                    key = "spoof:"..row.name;
                    if ( DTM_GetSavedVariable("engine", key, "modified") == 1 ) then
                        row.spoofButton:SetChecked(1);
                  else
                        row.spoofButton:SetChecked(nil);
                    end
                    row.spoofButton:Enable();
                    row.spoofButton:SetAlpha(1.0);
              else
                    row.spoofButton:Disable();
                    row.spoofButton:SetAlpha(0.5);
                end
          else
                getglobal(row:GetName().."Text"):SetText(row.name.."|cffffffff - "..format(DTM_Localise("configEngineNotEmulable"), row.name).."|r");

                row.enableButton:Disable();
                row.enableButton:SetAlpha(0.5);
                row.spoofButton:Disable();
                row.spoofButton:SetAlpha(0.5);
            end

            row:SetPoint("TOPLEFT", DTM_ConfigurationFrame_EnginePanel_EmulationPanel, "TOPLEFT", 8, -8-(i-1)*36);

            row:Show();
      else
            row:Hide();
        end
    end

    -- Fire the OnUpdate handler.

    DTM_ConfigurationFrame_EnginePanel_OnUpdate(self, 0);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_EnginePanel_SaveEmulation()
--
-- Called when the engine config panel is saved, this function special
-- purpose is to save emulation switches.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_EnginePanel_SaveEmulation()
    local i;
    local row;

    for i=1, MAX_EMULATION_ROWS do
        row = DTM_ConfigurationFrame_EnginePanel.emulationRow[i];
        if ( row.id ) and ( row.canEmulate ) then
            key = "emulation:"..row.name;
            if ( row.enableButton:GetChecked() == 1 ) then
                DTM_SetSavedVariable("engine", key, 1, "modified");
          else
                DTM_SetSavedVariable("engine", key, 0, "modified");
            end

            key = "spoof:"..row.name;
            if ( row.spoofButton:GetChecked() == 1 ) and ( row.canSpoof ) then
                DTM_SetSavedVariable("engine", key, 1, "modified");
          else
                DTM_SetSavedVariable("engine", key, 0, "modified");
            end
        end
    end

    DTM_ConfigurationFrame_EnginePanel_RestartEmulation();
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_EnginePanel_DefaultEmulation()
--
-- Called when the engine config panel is defaulted, this function special
-- purpose is to use default emulation switches.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_EnginePanel_DefaultEmulation()
    local num = DTM_Emulation_GetNumberOfEmulableAddOns();
    local i;
    local key;

    for i=1, num do
        name, desc, spoof, emulable = DTM_Emulation_GetEmulableAddOnData(i);
        key = "emulation:"..name;
        DTM_SetSavedVariable("engine", key, DTM_GetDefaultSavedVariable("engine", key), "modified");
        if ( spoof ) then
            key = "spoof:"..name;
            DTM_SetSavedVariable("engine", key, DTM_GetDefaultSavedVariable("engine", key), "modified");
        end
    end

    DTM_ConfigurationFrame_EnginePanel_RestartEmulation();
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_EnginePanel_RestartEmulation()
--
-- Called when the engine config panel is refreshed or cancelled;
-- this function restarts all appropriate emulation modules.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_EnginePanel_RestartEmulation()
    local num = DTM_Emulation_GetNumberOfEmulableAddOns();
    local i;

    for i=1, num do
        name, desc, spoof, emulable = DTM_Emulation_GetEmulableAddOnData(i);
        DTM_SetEmulationState(name, DTM_GetSavedVariable("engine", "emulation:"..name, "active"), DTM_GetSavedVariable("engine", "spoof:"..name, "active"));
    end
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_EnginePanel_Open()
--
-- This function allows you to open the engine panel from an external way.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_EnginePanel_Open()
    InterfaceOptionsFrame_OpenToFrame(DTM_ConfigurationFrame_EnginePanel);
end