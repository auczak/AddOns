local activeModule = "GUI configuration intro panel";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_IntroPanel_OnLoad()
--
-- Called when the intro panel is loaded.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_IntroPanel_OnLoad(self)
    -- Registers itself as a custom tab of Blizzard Interface options.

    self.name = "DiamondThreatMeter";
    self.parent = nil; -- None, it is the root "category".

    self.okay = function(self) end;
    self.cancel = function(self) end;
    self.default = function(self) end;

    InterfaceOptions_AddCategory(self);

    -- Do the translation of stuff we have to only do once.

    DTM_ConfigurationFrame_IntroPanel_SystemPartButton:SetText( DTM_Localise("configIntroSystemPart") );
    DTM_ConfigurationFrame_IntroPanel_EnginePartButton:SetText( DTM_Localise("configIntroEnginePart") );
    DTM_ConfigurationFrame_IntroPanel_GUIPartButton:SetText( DTM_Localise("configIntroGUIPart") );
    DTM_ConfigurationFrame_IntroPanel_WarningPartButton:SetText( DTM_Localise("configIntroWarningPart") );
    DTM_ConfigurationFrame_IntroPanel_NameplatePartButton:SetText( DTM_Localise("configIntroNameplatePart") );
    DTM_ConfigurationFrame_IntroPanel_VersionPartButton:SetText( DTM_Localise("configIntroVersionPart") );

    -- Refresh as it has just loaded up.

    DTM_ConfigurationFrame_IntroPanel_Refresh(self);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_IntroPanel_Refresh(self)
--
-- Called when intro panel has to refresh its controls.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_IntroPanel_Refresh(self)
    DTM_ConfigurationFramePanel_Update(self);

    DTM_ConfigurationFrame_IntroPanel_OnUpdate(self, 0);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_IntroPanel_OnUpdate(self, elapsed)
--
-- Called when the intro config panel is updated.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_IntroPanel_OnUpdate(self, elapsed)
    -- Update here infos etc. that can vary through time.

    -- Update the ring button explanation text.
    local statusText = "";
    if ( DTM_RingButton.set ) then
        statusText = DTM_Localise("configIntroRingButtonReset");
elseif ( DTM_RingButton.moving ) then
        statusText = DTM_Localise("configIntroRingButtonMoving");
  else
        statusText = DTM_Localise("configIntroRingButtonExplain");
    end
    DTM_RingButton_HoldFrame_ExplainText:SetText(statusText);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_IntroPanel_Open()
--
-- This function allows you to open the intro panel from an external way.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_IntroPanel_Open()
    InterfaceOptionsFrame_OpenToFrame(DTM_ConfigurationFrame_IntroPanel);
end