local activeModule = "GUI configuration nameplate panel";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local saveSchema = {
    [1] = {
        part = "gui",
        key = "nameplatesBarDisplay",
        method = "BOOLEAN_CONTROL",
        value = "DTM_ConfigurationFrame_NameplatePanel_UseNameplateCheckButton",
    },
};

local defaultSchema = saveSchema; -- Indeed, one schema only is enough.
local updateSchema = saveSchema; -- It's simply the reverse way.

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_NameplatePanel_OnLoad()
--
-- Called when the nameplate panel is loaded.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_NameplatePanel_OnLoad(self)
    -- Registers itself as a custom tab of Blizzard Interface options.

    self.name = DTM_Localise("configNameplateCategory");
    self.parent = "DiamondThreatMeter";

    self.okay = function(self)
                    DTM_ConfigurationFramePanel_Save(self, saveSchema);
                end;
    self.cancel = function(self) DTM_ConfigurationFrame_NameplatePanel_Refresh(self); end;
    self.default = function(self)
                       DTM_ConfigurationFramePanel_Default(self, defaultSchema);
                       DTM_ConfigurationFrame_NameplatePanel_Refresh(self);
                   end;

    InterfaceOptions_AddCategory(self);

    -- Configure regular widgets.

    -- Then we do the translation of stuff we need to only do once.

    DTM_ConfigurationFramePanel_SetTextAndTooltip(DTM_ConfigurationFrame_NameplatePanel_UseNameplateCheckButton, "configNameplateToggle", "configTooltipNameplateExplain");
    DTM_ConfigurationFrame_NameplatePanel_Explain:SetText( DTM_Localise("configNameplateExplain") );

    -- Refresh as it has just loaded up.

    DTM_ConfigurationFrame_NameplatePanel_Refresh(self);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_NameplatePanel_OnUpdate(self, elapsed)
--
-- Called when the display panel is updated.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_NameplatePanel_OnUpdate(self, elapsed)
    -- Update here infos etc. that can vary through time.


end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_NameplatePanel_Refresh(self)
--
-- Called when the display panel has to refresh its controls.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_NameplatePanel_Refresh(self)
    DTM_ConfigurationFramePanel_Update(self, updateSchema);

    -- Run the OnUpdate handler.

    DTM_ConfigurationFrame_NameplatePanel_OnUpdate(self, 0);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_NameplatePanel_Open()
--
-- This function allows you to open the display panel from an external way.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_NameplatePanel_Open()
    InterfaceOptionsFrame_OpenToFrame(DTM_ConfigurationFrame_NameplatePanel);
end