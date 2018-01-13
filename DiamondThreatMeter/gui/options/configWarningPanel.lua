local activeModule = "GUI configuration warning panel";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local saveSchema = {
    [1] = {
        part = "gui",
        key = "bossWarning",
        method = "BOOLEAN_CONTROL",
        value = "DTM_ConfigurationFrame_WarningPanel_UseWarningCheckButton",
    },
    [2] = {
        part = "gui",
        key = "warningPosX",
        method = "NUMERIC_CONTROL",
        value = "DTM_ConfigurationFrame_WarningPanel_XSlider",
    },
    [3] = {
        part = "gui",
        key = "warningPosY",
        method = "NUMERIC_CONTROL",
        value = "DTM_ConfigurationFrame_WarningPanel_YSlider",
    },
    [4] = {
        part = "gui",
        key = "warningLimit",
        method = "NUMERIC_CONTROL",
        value = "DTM_ConfigurationFrame_WarningPanel_LimitSlider",
    },
    [5] = {
        part = "gui",
        key = "warningCancelLimit",
        method = "NUMERIC_CONTROL",
        value = "DTM_ConfigurationFrame_WarningPanel_CancelLimitSlider",
    },
};

local defaultSchema = saveSchema; -- Indeed, one schema only is enough.
local updateSchema = saveSchema; -- It's simply the reverse way.

local warningThresholdList = {
    [1] = "BOSS",
    [2] = "ELITE_2",
    [3] = "ELITE_1",
    [4] = "ELITE_0",
    [5] = "ELITE",
    [6] = "NORMAL_2",
    [7] = "NORMAL_0",
    [8] = "NORMAL",
};

local warningSoundList = {
    [1] = "NONE",
    [2] = "WEIRD",
    [3] = "BUZZER",
    [4] = "PEASANT",
    [5] = "ALARM",
};

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_WarningPanel_OnLoad()
--
-- Called when the warning panel is loaded.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_WarningPanel_OnLoad(self)
    -- Registers itself as a custom tab of Blizzard Interface options.

    self.name = DTM_Localise("configWarningCategory");
    self.parent = "DiamondThreatMeter";

    self.okay = function(self)
                    DTM_ConfigurationFrame_WarningPanel_CheckCancelLimitSliderValue();
                    DTM_ConfigurationFramePanel_Save(self, saveSchema);
                end;
    self.cancel = function(self) DTM_ConfigurationFrame_WarningPanel_Refresh(self); end;
    self.default = function(self)
                       DTM_ConfigurationFramePanel_Default(self, defaultSchema);
                       DTM_ConfigurationFrame_WarningPanel_Refresh(self);
                   end;

    InterfaceOptions_AddCategory(self);

    -- Configure regular widgets.

    DTM_ConfigurationFramePanel_SetSlider(DTM_ConfigurationFrame_WarningPanel_XSlider,
                                          0.00, 1.00, 0.01,
                                          "", DTM_Localise("configWarningLeft"), DTM_Localise("configWarningRight"),
                                          "", nil);

    DTM_ConfigurationFramePanel_SetSlider(DTM_ConfigurationFrame_WarningPanel_YSlider,
                                          0.00, 1.00, 0.01,
                                          "", DTM_Localise("configWarningDown"), DTM_Localise("configWarningUp"),
                                          "", nil);

    DTM_ConfigurationFramePanel_SetSlider(DTM_ConfigurationFrame_WarningPanel_LimitSlider,
                                          0, 40, 1,
                                          "%d%%", "0%", "40%",
                                          DTM_Localise("configWarningLimit"), DTM_Localise("configTooltipWarningLimitExplain"));

    DTM_ConfigurationFramePanel_SetSlider(DTM_ConfigurationFrame_WarningPanel_CancelLimitSlider,
                                          10, 50, 1,
                                          "%d%%", "10%", "50%",
                                          DTM_Localise("configWarningCancelLimit"), DTM_Localise("configTooltipWarningCancelLimitExplain"));

    -- Populate the special warning threshold dropdown.

    DTM_ConfigurationFrame_WarningPanel_BuildWarningThresholdDropdown();

    -- Populate the special warning sound dropdown.

    DTM_ConfigurationFrame_WarningPanel_BuildWarningSoundDropdown();

    -- Then we do the translation of stuff we need to only do once.

    DTM_ConfigurationFramePanel_SetTextAndTooltip(DTM_ConfigurationFrame_WarningPanel_UseWarningCheckButton, "configWarningToggle", "configTooltipWarningExplain");
    DTM_ConfigurationFramePanel_SetTextAndTooltip(DTM_ConfigurationFrame_WarningPanel_PreviewWarningButton, "configWarningEnablePreview", "configTooltipPreviewExplain");
    DTM_ConfigurationFrame_WarningPanel_Explain110:SetText( DTM_Localise("configWarningExplain110") );
    DTM_ConfigurationFrame_WarningPanel_Explain130:SetText( DTM_Localise("configWarningExplain130") );
    DTM_ConfigurationFrame_WarningPanel_PositionTitle:SetText( DTM_Localise("configWarningPosition") );

    -- Refresh as it has just loaded up.

    DTM_ConfigurationFrame_WarningPanel_Refresh(self);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_WarningPanel_OnUpdate(self, elapsed)
--
-- Called when the display panel is updated.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_WarningPanel_OnUpdate(self, elapsed)
    -- Update here infos etc. that can vary through time.

    -- The preview button

    local button = DTM_ConfigurationFrame_WarningPanel_PreviewWarningButton;
    if ( button.enabled ) then
        button:SetText( DTM_Localise("configWarningDisablePreview") );
        local newX, newY;
        newX = DTM_ConfigurationFrame_WarningPanel_XSlider:GetValue() * UIParent:GetWidth();
        newY = DTM_ConfigurationFrame_WarningPanel_YSlider:GetValue() * UIParent:GetHeight();
        DTM_ConfigurationFrame_GhostRow:SetPosition(newX, newY, 2.0);
  else
        button:SetText( DTM_Localise("configWarningEnablePreview") );
    end
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_WarningPanel_Refresh(self)
--
-- Called when the display panel has to refresh its controls.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_WarningPanel_Refresh(self)
    DTM_ConfigurationFramePanel_Update(self, updateSchema);

    -- Run the OnUpdate handler.

    DTM_ConfigurationFrame_WarningPanel_OnUpdate(self, 0);

    -- Check the cancel limit slider has a decent value.

    DTM_ConfigurationFrame_WarningPanel_CheckCancelLimitSliderValue();
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_WarningPanel_Open()
--
-- This function allows you to open the display panel from an external way.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_WarningPanel_Open()
    InterfaceOptionsFrame_OpenToFrame(DTM_ConfigurationFrame_WarningPanel);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_WarningPanel_BuildWarningThresholdDropdown()
--
-- This function will populate the warning threshold dropdown.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_WarningPanel_BuildWarningThresholdDropdown()
    local localisedTable = {};
    local localisedTooltip = {};

    local k, v;
    local classification, level;
    local classificationString, signString;

    for k, v in ipairs(warningThresholdList) do
        localisedTable[k] = "?";
        localisedTooltip[k] = "";
        classificationString = "?";

        classification, level = strsplit("_", v, 2);
        if ( classification ) then
            if ( classification == "BOSS" ) then classificationString = DTM_Localise("configWarningBossTag"); end
            if ( classification == "ELITE" ) then classificationString = DTM_Localise("configWarningEliteTag"); end
            if ( classification == "NORMAL" ) then classificationString = DTM_Localise("configWarningNormalTag"); end

            localisedTable[k] = classificationString;
            if ( level ) then
                if ( (tonumber(level) or 0) >= 0 ) then signString = "+"; else signString = "-"; end
                localisedTable[k] = localisedTable[k].." "..signString..level.." "..DTM_Localise("configWarningLevelTag").." "..DTM_Localise("configWarningAndMoreTag");
                localisedTooltip[k] = format(DTM_Localise("configWarningClassificationAndLevel"), classificationString, signString, level);
          else
                localisedTooltip[k] = format(DTM_Localise("configWarningClassification"), classificationString);
            end
        end
    end

    DTM_ConfigurationFramePanel_SetDropDown(DTM_ConfigurationFrame_WarningPanel_WarningThresholdDropDown, 160,
                                            localisedTable,
                                            localisedTooltip);

    -- Add the dropdown to the save schema.

    saveSchema[#saveSchema + 1] = {
        part = "gui",
        key = "warningThreshold",
        method = "DROPLIST_CONTROL",
        value = "DTM_ConfigurationFrame_WarningPanel_WarningThresholdDropDown",
        list = warningThresholdList,
    };

    -- Translate the caption

    DTM_ConfigurationFrame_WarningPanel_WarningThresholdDropDownCaption:SetText( DTM_Localise("configWarningThreshold") );
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_WarningPanel_BuildWarningSoundDropdown()
--
-- This function will populate the warning sound dropdown.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_WarningPanel_BuildWarningSoundDropdown()
    local localisedTable = {};
    local localisedTooltip = {};

    local k, v;
    for k, v in ipairs(warningSoundList) do
        localisedTable[k] = DTM_Localise("sound:"..v);
    end

    DTM_ConfigurationFramePanel_SetDropDown(DTM_ConfigurationFrame_WarningPanel_WarningSoundDropDown, 152,
                                            localisedTable,
                                            localisedTooltip);

    -- Add the dropdown to the save schema.

    saveSchema[#saveSchema + 1] = {
        part = "gui",
        key = "warningSound",
        method = "DROPLIST_CONTROL",
        value = "DTM_ConfigurationFrame_WarningPanel_WarningSoundDropDown",
        list = warningSoundList,
    };

    -- Translate the caption

    DTM_ConfigurationFrame_WarningPanel_WarningSoundDropDownCaption:SetText( DTM_Localise("configWarningSound") );
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_WarningPanel_ToggleWarningPreview()
--
-- This function gets called when preview warning button is clicked.
-----------------------------------------------------------------------------
function DTM_ConfigurationFrame_WarningPanel_ToggleWarningPreview(self)
    self.enabled = not self.enabled;
    if ( self.enabled ) then
        DTM_ConfigurationFrame_GhostRow:Activate();

        -- Test the warning sound
        local warningSound = warningSoundList[ UIDropDownMenu_GetSelectedID(DTM_ConfigurationFrame_WarningPanel_WarningSoundDropDown) or 1 ] or 'NONE';
        if ( warningSound ~= "NONE" ) then
            DTM_PlaySound(warningSound);
        end
  else
        DTM_ConfigurationFrame_GhostRow:Destroy();
    end
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_WarningPanel_CheckCancelLimitSliderValue()
--
-- Checks cancel limit slider has a correct value. That is, any value equal
-- or above limit slider's value.
-----------------------------------------------------------------------------
function DTM_ConfigurationFrame_WarningPanel_CheckCancelLimitSliderValue()
    local constraintedSlider = DTM_ConfigurationFrame_WarningPanel_CancelLimitSlider;
    local masterSlider = DTM_ConfigurationFrame_WarningPanel_LimitSlider;

    if ( constraintedSlider:GetValue() < masterSlider:GetValue() ) then
        constraintedSlider:SetValue( masterSlider:GetValue() );
    end
end