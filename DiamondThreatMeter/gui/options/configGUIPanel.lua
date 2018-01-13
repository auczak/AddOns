local activeModule = "GUI configuration GUI panel";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local saveSchema = {
    [1] = {
        part = "gui",
        key = "autoDisplayTarget",
        method = "DROPLIST_CONTROL",
        value = "DTM_ConfigurationFrame_GUIPanel_AutoDisplayTargetDropDown",
        list = {
            [1] = "ALWAYS",
            [2] = "JOIN_PARTY",
            [3] = "ENTER_COMBAT",
            [4] = "NEVER",
        },
    },
    [2] = {
        part = "gui",
        key = "autoDisplayFocus",
        method = "DROPLIST_CONTROL",
        value = "DTM_ConfigurationFrame_GUIPanel_AutoDisplayFocusDropDown",
        list = {
            [1] = "ALWAYS",
            [2] = "ON_CHANGE",
            [3] = "NEVER",
        },
    },
    [3] = {
        part = "gui",
        key = "autoDisplayOverview",
        method = "DROPLIST_CONTROL",
        value = "DTM_ConfigurationFrame_GUIPanel_AutoDisplayOverviewDropDown",
        list = {
            [1] = "ALWAYS",
            [2] = "JOIN_PARTY",
            [3] = "ENTER_COMBAT",
            [4] = "NEVER",
        },
    },
    [4] = {
        part = "gui",
        key = "autoDisplayRegain",
        method = "DROPLIST_CONTROL",
        value = "DTM_ConfigurationFrame_GUIPanel_AutoDisplayRegainDropDown",
        list = {
            [1] = "ALWAYS",
            [2] = "JOIN_PARTY",
            [3] = "ENTER_COMBAT",
            [4] = "NEVER",
        },
    },
};

local defaultSchema = saveSchema; -- Indeed, one schema only is enough.
local updateSchema = saveSchema; -- It's simply the reverse way.

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_GUIPanel_OnLoad()
--
-- Called when the GUI config panel is loaded.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_GUIPanel_OnLoad(self)
    -- Registers itself as a custom tab of Blizzard Interface options.

    self.name = DTM_Localise("configGUICategory");
    self.parent = "DiamondThreatMeter";

    self.okay = function(self)
                    DTM_ConfigurationFramePanel_Save(self, saveSchema);
                end;
    self.cancel = function(self) DTM_ConfigurationFrame_GUIPanel_Refresh(self); end;
    self.default = function(self)
                       DTM_ConfigurationFramePanel_Default(self, defaultSchema);
                       DTM_ConfigurationFrame_GUIPanel_Refresh(self);
                   end;

    InterfaceOptions_AddCategory(self);

    -- Configure regular widgets.

    DTM_ConfigurationFramePanel_SetDropDown(DTM_ConfigurationFrame_GUIPanel_AutoDisplayTargetDropDown, 128,
                                            {DTM_Localise("configGUIAutoDisplayAlways"),     DTM_Localise("configGUIAutoDisplayOnJoin"),     DTM_Localise("configGUIAutoDisplayOnCombat"),     DTM_Localise("configGUIAutoDisplayNever")},
                                            {DTM_Localise("configTooltipAutoDisplayAlways"), DTM_Localise("configTooltipAutoDisplayOnJoin"), DTM_Localise("configTooltipAutoDisplayOnCombat"), DTM_Localise("configTooltipAutoDisplayNever")});

    DTM_ConfigurationFramePanel_SetDropDown(DTM_ConfigurationFrame_GUIPanel_AutoDisplayFocusDropDown, 128,
                                            {DTM_Localise("configGUIAutoDisplayAlways"),     DTM_Localise("configGUIAutoDisplayOnChange"),     DTM_Localise("configGUIAutoDisplayNever")},
                                            {DTM_Localise("configTooltipAutoDisplayAlways"), DTM_Localise("configTooltipAutoDisplayOnChange"), DTM_Localise("configTooltipAutoDisplayNever")});

    DTM_ConfigurationFramePanel_SetDropDown(DTM_ConfigurationFrame_GUIPanel_AutoDisplayOverviewDropDown, 128,
                                            {DTM_Localise("configGUIAutoDisplayAlways"),     DTM_Localise("configGUIAutoDisplayOnJoin"),     DTM_Localise("configGUIAutoDisplayOnCombat"),     DTM_Localise("configGUIAutoDisplayNever")},
                                            {DTM_Localise("configTooltipAutoDisplayAlways"), DTM_Localise("configTooltipAutoDisplayOnJoin"), DTM_Localise("configTooltipAutoDisplayOnCombat"), DTM_Localise("configTooltipAutoDisplayNever")});

    DTM_ConfigurationFramePanel_SetDropDown(DTM_ConfigurationFrame_GUIPanel_AutoDisplayRegainDropDown, 128,
                                            {DTM_Localise("configGUIAutoDisplayAlways"),     DTM_Localise("configGUIAutoDisplayOnJoin"),     DTM_Localise("configGUIAutoDisplayOnCombat"),     DTM_Localise("configGUIAutoDisplayNever")},
                                            {DTM_Localise("configTooltipAutoDisplayAlways"), DTM_Localise("configTooltipAutoDisplayOnJoin"), DTM_Localise("configTooltipAutoDisplayOnCombat"), DTM_Localise("configTooltipAutoDisplayNever")});

    -- Then we do the translation of stuff we need to only do once.

    DTM_ConfigurationFrame_GUIPanel_AutoDisplayTargetDropDownCaption:SetText( DTM_Localise("configGUIAutoDisplayTarget") );
    DTM_ConfigurationFrame_GUIPanel_AutoDisplayFocusDropDownCaption:SetText( DTM_Localise("configGUIAutoDisplayFocus") );
    DTM_ConfigurationFrame_GUIPanel_AutoDisplayOverviewDropDownCaption:SetText( DTM_Localise("configGUIAutoDisplayOverview") );
    DTM_ConfigurationFrame_GUIPanel_AutoDisplayRegainDropDownCaption:SetText( DTM_Localise("configGUIAutoDisplayRegain") );
    DTM_ConfigurationFrame_GUIPanel_AutoDisplayTitle:SetText( DTM_Localise("configGUIAutoDisplay") );

    -- Refresh as it has just loaded up.

    DTM_ConfigurationFrame_GUIPanel_Refresh(self);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_GUIPanel_OnUpdate(self, elapsed)
--
-- Called when the GUI config panel is updated.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_GUIPanel_OnUpdate(self, elapsed)
    -- Update here infos etc. that can vary through time.

    -- We first update the toggle button text and caption.
    local status = DTM_IsGUIRunning();
    if ( status ) then -- Non-nil states will show up a disable command.
        DTM_ConfigurationFrame_GUIPanel_ToggleButton:SetText( DTM_Localise("configGUIDisable") );
        if ( status == 1 ) then
            DTM_ConfigurationFrame_GUIPanel_ToggleButtonCaption:SetText( DTM_Localise("configGUIDisableCaption") );
      elseif ( status == 2 ) then
            DTM_ConfigurationFrame_GUIPanel_ToggleButtonCaption:SetText( DTM_Localise("configGUIPaused") );
      elseif ( status == 3 ) then
            DTM_ConfigurationFrame_GUIPanel_ToggleButtonCaption:SetText( DTM_Localise("configGUIEmergencyStop") );
        end
  else
        DTM_ConfigurationFrame_GUIPanel_ToggleButton:SetText( DTM_Localise("configGUIEnable") );
        DTM_ConfigurationFrame_GUIPanel_ToggleButtonCaption:SetText( DTM_Localise("configGUIEnableCaption") );
    end
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_GUIPanel_Refresh(self)
--
-- Called when the GUI config panel has to refresh its controls.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_GUIPanel_Refresh(self)
    DTM_ConfigurationFramePanel_Update(self, updateSchema);

    -- Run the OnUpdate handler.

    DTM_ConfigurationFrame_GUIPanel_OnUpdate(self, 0);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_GUIPanel_Open()
--
-- This function allows you to open the GUI panel from an external way.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_GUIPanel_Open()
    InterfaceOptionsFrame_OpenToFrame(DTM_ConfigurationFrame_GUIPanel);
end