local activeModule = "GUI configuration system panel";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local saveSchema = {
    [1] = {
        part = "system",
        key = "noTemporaryStop",
        method = "BOOLEAN_CONTROL",
        value = "DTM_ConfigurationFrame_SystemPanel_AlwaysEnabledCheckButton",
    },
};

local defaultSchema = saveSchema; -- Indeed, one schema only is enough.
local updateSchema = saveSchema; -- It's simply the reverse way.

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_SystemPanel_OnLoad()
--
-- Called when the system config panel is loaded.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_SystemPanel_OnLoad(self)
    -- Registers itself as a custom tab of Blizzard Interface options.

    self.name = DTM_Localise("configSystemCategory");
    self.parent = "DiamondThreatMeter";

    self.okay = function(self)
                    DTM_ConfigurationFramePanel_Save(self, saveSchema);
                end;
    self.cancel = function(self) DTM_ConfigurationFrame_SystemPanel_Refresh(self); end;
    self.default = function(self)
                       DTM_ConfigurationFramePanel_Default(self, defaultSchema);
                       DTM_ConfigurationFrame_SystemPanel_Refresh(self);
                   end;

    InterfaceOptions_AddCategory(self);

    -- Then we do the translation of stuff we need to only do once.

    DTM_ConfigurationFramePanel_SetTextAndTooltip(DTM_ConfigurationFrame_SystemPanel_AlwaysEnabledCheckButton, "configSystemAlwaysEnabled", "configTooltipAlwaysEnabledExplain");
    DTM_ConfigurationFramePanel_SetTextAndTooltip(DTM_ConfigurationFrame_SystemPanel_QuickConfigButton, "configSystemQuickConfig", "configTooltipQuickConfigExplain");
    DTM_ConfigurationFramePanel_SetTextAndTooltip(DTM_ConfigurationFrame_SystemPanel_BindingsButton, "configSystemBindings", nil);
    DTM_ConfigurationFramePanel_SetTextAndTooltip(DTM_ConfigurationFrame_SystemPanel_ErrorLogButton, "configSystemErrorLog", nil);
    DTM_ConfigurationFramePanel_SetTextAndTooltip(DTM_ConfigurationFrame_SystemPanel_ResetSavedVarsButton, "configSystemResetSavedVars", "configTooltipResetSavedVarsExplain");
    DTM_ConfigurationFramePanel_SetTextAndTooltip(DTM_ConfigurationFrame_SystemPanel_ResetNPCDataButton, "configSystemResetNPCData", "configTooltipResetNPCDataExplain");
    DTM_ConfigurationFramePanel_SetTextAndTooltip(DTM_ConfigurationFrame_SystemPanel_ResetAllButton, "configSystemResetAll", "configTooltipResetAllExplain");
    DTM_ConfigurationFrame_SystemPanel_ConfigManagementTitle:SetText( DTM_Localise("configSystemManagementHeader") );

    -- Refresh as it has just loaded up.

    DTM_ConfigurationFrame_SystemPanel_Refresh(self);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_SystemPanel_OnUpdate(self, elapsed)
--
-- Called when the system config panel is updated.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_SystemPanel_OnUpdate(self, elapsed)
    -- Update here infos etc. that can vary through time.

    local status = DTM_IsEmergencyStopEnabled();
    if not ( status ) then
        DTM_ConfigurationFrame_SystemPanel_ToggleButton:SetText( DTM_Localise("configSystemDisable") );
        DTM_ConfigurationFrame_SystemPanel_ToggleButtonCaption:SetText( DTM_Localise("configSystemDisableCaption") );
  else
        DTM_ConfigurationFrame_SystemPanel_ToggleButton:SetText( DTM_Localise("configSystemEnable") );
        DTM_ConfigurationFrame_SystemPanel_ToggleButtonCaption:SetText( DTM_Localise("configSystemEnableCaption") );
    end
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_SystemPanel_Refresh(self)
--
-- Called when the system config panel has to refresh its controls.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_SystemPanel_Refresh(self)
    DTM_ConfigurationFramePanel_Update(self, updateSchema);

    -- The special profile drop down.
    DTM_ConfigurationFrame_SystemPanel_BuildProfileDropdown();

    -- Run the OnUpdate handler.

    DTM_ConfigurationFrame_SystemPanel_OnUpdate(self, 0);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_SystemPanel_Open()
--
-- This function allows you to open the system panel from an external way.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_SystemPanel_Open()
    InterfaceOptionsFrame_OpenToFrame(DTM_ConfigurationFrame_SystemPanel);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_SystemPanel_BuildProfileDropdown()
--
-- This function will (re)populate the profile selection dropdown.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_SystemPanel_BuildProfileDropdown()
    local dropDown = DTM_ConfigurationFrame_SystemPanel_ProfileDropDown;

    local localisedTable = {};
    local localisedTooltip = {};

    local numProfiles = DTM_GetNumProfiles();
    local name, server, i;

    for i=1, numProfiles do
        localisedTable[i] = "?";
        localisedTooltip[i] = "";

        name, server, _ = DTM_GetProfileInfo(i);

        if ( name and server ) then
            localisedTable[i] = string.format("%s (%s)", name, server);
            localisedTooltip[i] = string.format(DTM_Localise("configTooltipModifiedProfileExplain"), name, server);
        end
    end

    dropDown.valueList = localisedTable;
    dropDown.tooltipList = localisedTooltip;

    local initializeDropDown = function()
                                   local dropDown = getglobal(UIDROPDOWNMENU_INIT_MENU);
                                   if not ( dropDown.valueList ) then return; end
                                   local info = UIDropDownMenu_CreateInfo();
                                   for i=1, #dropDown.valueList do
                                       info.text = dropDown.valueList[i];
                                       if ( not DTM_OnWotLK() ) then
                                           info.func = function(dropDown, index) DTM_ConfigurationFrame_SystemPanel_OnProfileChanged(dropDown, index); end;
                                     else
                                           info.func = function(self, dropDown, index) DTM_ConfigurationFrame_SystemPanel_OnProfileChanged(dropDown, index); end;
                                       end
                                       info.arg1 = dropDown;
                                       info.arg2 = i;
                                       info.checked = nil;
                                       info.tooltipTitle = info.text;
                                       if ( dropDown.tooltipList ) then
                                           info.tooltipText = dropDown.tooltipList[i] or nil;
                                     else
                                           info.tooltipText = nil;
                                       end
                                       UIDropDownMenu_AddButton(info);
	                           end
                               end;
    UIDropDownMenu_Initialize(dropDown, initializeDropDown);
    if ( DTM_OnWotLK() ) then
        UIDropDownMenu_SetWidth(dropDown, 256);
  else
        UIDropDownMenu_SetWidth(256, dropDown); -- You were bad on this one, Blizz ! Boooh !
    end

    -- Select the right entry

    local modifiedName, modifiedServer, _ = DTM_GetModifiedProfile();
    UIDropDownMenu_SetSelectedName(dropDown, string.format("%s (%s)", modifiedName, modifiedServer));

    -- Translate the caption

    getglobal(dropDown:GetName().."Caption"):SetText( DTM_Localise("configSystemModifiedProfile") );
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_SystemPanel_OnProfileChanged(dropDown, index)
--
-- This function gets called when the modified profile is changed.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_SystemPanel_OnProfileChanged(dropDown, index)
    DTM_SetModifiedProfile(index);

    DTM_RefreshConfigPanels();

    -- UIDropDownMenu_SetSelectedID(dropDown, index); -- Not needed.
end