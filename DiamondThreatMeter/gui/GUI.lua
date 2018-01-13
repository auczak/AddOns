local activeModule = "Official GUI";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

DTM_ThreatListFrames = {};
DTM_PresenceListFrames = {};
DTM_RegainListFrames = {};

-- Comment to disable the GUI.
local USE_GUI = 1;
local DTM_GUI_Running = nil;
local DTM_GUI_Shown = nil;
local DTM_GUI_Ready = nil;
local eventHandlers = {};

local updateTimer = {};
local CHECK_PARTY_TIMER = 0.500;

local playerIsInParty;
local inCombatState;

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SetupGUI()                                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Setup the GUI part of DTM.                                       *
-- ********************************************************************
function DTM_SetupGUI()
    if ( DTM_GUI_Ready ) then return; end

    -- Binds threat list frames
    DTM_ThreatListFrames["target"] = DTM_GUI_TargetThreatList;
    DTM_ThreatListFrames["target"].unit = "target";
    DTM_ThreatListFrames["target"].altUnit = "targettarget"; -- In case the target is friendly, we use targettarget instead.
    DTM_ThreatListFrames["target"].warningPosition = 1;
    DTM_ThreatListFrames["target"].standbyBaseKey = "standbyTarget";
    DTM_ThreatListFrames["focus"] = DTM_GUI_FocusThreatList;
    DTM_ThreatListFrames["focus"].unit = "focus";
    DTM_ThreatListFrames["focus"].altUnit = "focustarget"; -- In case the target is friendly, we use focustarget instead.
    DTM_ThreatListFrames["focus"].warningPosition = 2;
    DTM_ThreatListFrames["focus"].standbyBaseKey = "standbyFocus";

    -- Binds presence list frames
    DTM_PresenceListFrames["player"] = DTM_GUI_PlayerOverviewList;
    DTM_PresenceListFrames["player"].unit = "player";

    -- Binds regain list frames
    DTM_RegainListFrames["player"] = DTM_GUI_PlayerRegainList;
    DTM_RegainListFrames["player"].unit = "player";

    DTM_NotifyOnThreatFlagsChange(DTM_GUI_ThreatFlagsChanged);

    -- Start the skin system and check for incompatibility.
    local erased = DTM_InitialiseSkinSystem();
    if ( erased == 1 ) then
        DTM_ChatMessage(DTM_Localise("SkinsBadVersion"));
elseif ( erased == 2 ) then
        DTM_ChatMessage(DTM_Localise("SkinsVersionUpgrade"));
    end

    -- Moves the skin manager in the right config panel and make sure it is unlocked.
    DTM_SkinManager:SetParent(DTM_ConfigurationFrame_GUIPanel);
    DTM_SkinManager:SetPoint("TOP", DTM_ConfigurationFrame_GUIPanel, "TOP", 0, -96);
    DTM_SkinManager:Show();
    DTM_SkinManager:Unlock();

    -- Define the unset position for the ring button
    DTM_RingButton.unset = {
        parent = DTM_RingButton_HoldFrame,
        point = "BOTTOMLEFT",
        ofsX = 8,
        ofsY = 4,
    };

    local ringButtonParent = DTM_GetSavedVariable("gui", "ringButtonParent");
    -- Setup the ring button if it hasn't been placed yet. Refresh its parent if it has.
    if ( ringButtonParent == "UNSET" ) then
        DTM_RingButton:UseUnsetPosition();
  else
        DTM_RingButton:UseSetPosition();
    end

    -- Register a callback to NameplateLib to sync our nameplate threat bar.
    if ( NameplateLib ) then
        DTM_InitialiseNameplates();
        NameplateLib:RegisterCallback(DTM_UpdateNameplates);
  else
        DTM_ThrowError("MAJOR", activeModule, "Cannot initialise nameplate system: NameplateLib missing.");
    end

    DTM_GUI_Ready = 1;
end

-- ********************************************************************
-- * DTM_StartGUI()                                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Start the GUI part of DTM.                                       *
-- ********************************************************************
function DTM_StartGUI()
    DTM_SetSavedVariable("gui", "run", 1); -- Global saved variable.
    if not ( USE_GUI ) then return; end
    if not ( DTM_GUI_Ready ) then return; end
    DTM_GUI_Running = 1;
    DTM_ShowGUI();
end

-- ********************************************************************
-- * DTM_StopGUI()                                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Stop the GUI part of DTM.                                        *
-- ********************************************************************
function DTM_StopGUI()
    DTM_SetSavedVariable("gui", "run", 0); -- Global saved variable.
    if not ( USE_GUI ) then return; end
    if not ( DTM_GUI_Ready ) then return; end
    DTM_GUI_Running = nil;
    DTM_HideGUI();
end

-- ********************************************************************
-- * DTM_ShowGUI()                                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Show the GUI part of DTM. If you call this API while the GUI is  *
-- * disabled, the frames will quickly toggle but will stay hidden.   *
-- ********************************************************************
function DTM_ShowGUI()
    DTM_GUI_Shown = 1;
    DTM_GUI_Frame:Show();

    playerIsInParty = nil;
    inCombatState = nil;

    -- Show or hide threat list frames according to configuration.

    DTM_GUI_FocusChanged();

    if ( DTM_GetSavedVariable("gui", "autoDisplayTarget", "active") == "ALWAYS" ) then
        DTM_ThreatListFrames["target"]:Display();
    end
    if ( DTM_GetSavedVariable("gui", "autoDisplayFocus", "active") == "ALWAYS" ) then
        DTM_ThreatListFrames["focus"]:Display();
    end
    if ( DTM_GetSavedVariable("gui", "autoDisplayOverview", "active") == "ALWAYS" ) then
        DTM_PresenceListFrames["player"]:Display();
    end
    if ( DTM_GetSavedVariable("gui", "autoDisplayRegain", "active") == "ALWAYS" ) then
        DTM_RegainListFrames["player"]:Display();
    end
end

-- ********************************************************************
-- * DTM_HideGUI()                                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Hide the GUI part of DTM. If the GUI is not disabled, the GUI    *
-- * will reapparear just after.                                      *
-- ********************************************************************
function DTM_HideGUI()
    DTM_GUI_Shown = nil;
    -- DTM_GUI_Frame:Hide();

    -- Hide at once threat list frames.

    DTM_ThreatListFrames["target"]:Reset();
    DTM_ThreatListFrames["focus"]:Reset();
    DTM_PresenceListFrames["player"]:Reset();
    DTM_RegainListFrames["player"]:Reset();
end

-- ********************************************************************
-- * DTM_IsGUIRunning()                                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Determinates if DTM GUI is currently running.                    *
-- * Can return:                                                      *
-- *    - nil => Fullstop (set by the user)                           *
-- *    - 1 => Running                                                *
-- *    - 2 => Auto-disabled (will revert to running automatically)   *
-- *    - 3 => Emergency stop (will need user action to revert)       *
-- ********************************************************************
function DTM_IsGUIRunning()
    -- If a bug occurs while loading up DTM, this function will start
    -- to return nil like crazy >.>

    if not ( DTM_GUI_Running ) then
        return nil; -- First, not being enabled is the top priority status.
    end

    -- Check the emergency stop status.
    if ( DTM_IsEmergencyStopEnabled() ) then
        return 3;
    end

    -- Now determinate if we're in a status which causes the GUI to be effectively disabled, but still enabled.
    if ( DTM_TemporaryDisableCondition() ) then
        return 2;
    end

    -- Elsewise, consider we're in the running status.
    return 1;
end

-- ********************************************************************
-- * DTM_ToggleThreatList(unitId)                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * unitId >> the UID watched by the threat list you want to toggle. *
-- ********************************************************************
-- * Toggles display of a threat list.                                *
-- ********************************************************************
function DTM_ToggleThreatList(unitId)
    if not ( DTM_ThreatListFrames ) then return; end
    local frame = DTM_ThreatListFrames[unitId];
    if not ( frame ) then return; end
    if ( frame:IsShown() ) then
        frame:Destroy();
  else
        frame:Display();
    end
end

-- ********************************************************************
-- * DTM_TogglePresenceList(unitId)                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * unitId >> the UID you want to toggle presence list of.           *
-- ********************************************************************
-- * Toggles display of a presence list.                              *
-- ********************************************************************
function DTM_TogglePresenceList(unitId)
    if not ( DTM_PresenceListFrames ) then return; end
    local frame = DTM_PresenceListFrames[unitId];
    if not ( frame ) then return; end
    if ( frame:IsShown() ) then
        frame:Destroy();
  else
        frame:Display();
    end
end

-- ********************************************************************
-- * DTM_ToggleRegainList(unitId)                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * unitId >> the UID you want to toggle regain list of.             *
-- ********************************************************************
-- * Toggles display of a regain list.                                *
-- ********************************************************************
function DTM_ToggleRegainList(unitId)
    if not ( DTM_RegainListFrames ) then return; end
    local frame = DTM_RegainListFrames[unitId];
    if not ( frame ) then return; end
    if ( frame:IsShown() ) then
        frame:Destroy();
  else
        frame:Display();
    end
end

-- ********************************************************************
-- * DTM_RefreshConfigPanels()                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Refresh at once all configuration panels. Any unsaved change     *
-- * will be lost.                                                    *
-- ********************************************************************
function DTM_RefreshConfigPanels()
    DTM_ConfigurationFrame_IntroPanel_Refresh( DTM_ConfigurationFrame_IntroPanel );
    DTM_ConfigurationFrame_SystemPanel_Refresh( DTM_ConfigurationFrame_SystemPanel );
    DTM_ConfigurationFrame_EnginePanel_Refresh( DTM_ConfigurationFrame_EnginePanel );
    DTM_ConfigurationFrame_GUIPanel_Refresh( DTM_ConfigurationFrame_GUIPanel );
    DTM_ConfigurationFrame_WarningPanel_Refresh( DTM_ConfigurationFrame_WarningPanel );
    DTM_ConfigurationFrame_NameplatePanel_Refresh( DTM_ConfigurationFrame_NameplatePanel );
    DTM_ConfigurationFrame_VersionPanel_Refresh( DTM_ConfigurationFrame_VersionPanel );
end

-- ********************************************************************
-- * DTM_ApplyColumnSetting(object, row, setting, isHeader)           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> object: the column element that will get adjusted.            *
-- * >> row: the row the column element belongs to.                   *
-- * >> setting: the table containing settings info.                  *
-- * >> isHeader: specifies if it's a column of the header.           *
-- ********************************************************************
-- * Apply a given column config on a given column object.            *
-- * will be lost.                                                    *
-- ********************************************************************
function DTM_ApplyColumnSetting(object, row, setting, isHeader)
    local type = object:GetObjectType();

    object:ClearAllPoints();

    if not ( setting.enabled == 1 ) then
        -- Defined explicitly as hidden and should stay hidden even if shown because it has no anchor point defined. :)
        object:SetAlpha(0);
        -- object:Hide();
        return;
  else
        object:SetAlpha(1);
        -- object:Show();
    end

    if ( isHeader ) then
        if ( type == "Texture" ) then
            object:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", row:GetWidth() * setting.offset, 0);

      elseif ( type == "FontString" ) then
            object:SetJustifyH(setting.justification);
            if ( setting.justification == "LEFT" ) then
                object:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", row:GetWidth() * setting.offset, 0);
        elseif ( setting.justification == "CENTER" ) then
                object:SetPoint("BOTTOM", row, "BOTTOMLEFT", row:GetWidth() * setting.offset, 0);
        elseif ( setting.justification == "RIGHT" ) then
                object:SetPoint("BOTTOMRIGHT", row, "BOTTOMLEFT", row:GetWidth() * setting.offset, 0);
            end
      else
            -- Unknown element type.
            error("DTM_ApplyColumnSetting: unsupported object type ("..type..").", 0);
        end
  else
        if ( type == "Texture" ) then
            object:SetPoint("LEFT", row, "LEFT", row:GetWidth() * setting.offset, 0);

      elseif ( type == "FontString" ) then
            object:SetJustifyH(setting.justification);
            if ( setting.justification == "LEFT" ) then
                object:SetPoint("LEFT", row, "LEFT", row:GetWidth() * setting.offset, 0);
        elseif ( setting.justification == "CENTER" ) then
                object:SetPoint("CENTER", row, "LEFT", row:GetWidth() * setting.offset, 0);
        elseif ( setting.justification == "RIGHT" ) then
                object:SetPoint("RIGHT", row, "LEFT", row:GetWidth() * setting.offset, 0);
            end
      else
            -- Unknown element type.
            error("DTM_ApplyColumnSetting: unsupported object type ("..type..").", 0);
        end
    end
end

-- --------------------------------------------------------------------
-- **                           Functions                            **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_GUI_RegisterEvent(event, handler)                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> event: the event to be notified of.                           *
-- * >> handler: the function which will get fired.                   *
-- ********************************************************************
-- * Start the engine part of DTM.                                    *
-- ********************************************************************
function DTM_GUI_RegisterEvent(event, handler)
    eventHandlers[event] = handler;
    DTM_GUI_Frame:RegisterEvent(event);
end

-- ********************************************************************
-- * DTM_GUI_IsWarningApplicable(NPCClassification, NPCLevel)         *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> NPCClassification: the classification of the NPC.             *
-- * >> NPCLevel: its level.                                          *
-- ********************************************************************
-- * Determinates if, against a given NPC, warning should be enabled. *
-- * Saved vars "bossWarning" and "warningThreshold" will determinate *
-- * the outcome of this option.                                      *
-- ********************************************************************
function DTM_GUI_IsWarningApplicable(NPCClassification, NPCLevel)
    local warningEnabled = DTM_GetSavedVariable("gui", "bossWarning", "active");
    if ( warningEnabled ~= 1 ) then return nil; end

    local warningThreshold = DTM_GetSavedVariable("gui", "warningThreshold", "active");
    if not ( warningThreshold ) then return nil; end

    -- Ok, let's interpret the warning threshold string.

    local warningClassification, warningLevelDifference = strsplit("_", warningThreshold, 2);

    -- Check first if classification matches.

    if ( warningClassification ) then
        if not ( NPCClassification ) then return nil; end
        if ( warningClassification == "BOSS" and not ( NPCClassification == "worldboss" ) ) then return nil; end
        if ( warningClassification == "ELITE" and not ( NPCClassification == "elite" or NPCClassification == "rareelite" or NPCClassification == "worldboss" ) ) then return nil; end
    end

    -- Check then if level matches, given the NPC is not a boss. If that's the case, we ignore the level requirement.

    if ( warningLevelDifference ) and not ( NPCClassification == "worldboss" ) then
        warningLevelDifference = tonumber(warningLevelDifference) or 0;
        if not ( NPCLevel ) then return nil; end
        if ( (NPCLevel - UnitLevel("player")) < warningLevelDifference ) then return nil; end
    end

    return 1;
end

-- ********************************************************************
-- * DTM_GUI_CheckWarningDistance(enemyUnit, aggroDistance)           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> enemyUnit: the unit that might trigger the warning.           *
-- * >> aggroDistance: the unit's aggro distance policy.              *
-- ********************************************************************
-- * Determinates if we are at good distance from an enemy unit to    *
-- * make possible a warning display.                                 *
-- ********************************************************************
function DTM_GUI_CheckWarningDistance(enemyUnit, aggroDistance)
    if not ( enemyUnit ) or not ( aggroDistance ) then return nil; end

    local inMelee = CheckInteractDistance(enemyUnit, 3);
    local atRange = not inMelee;

    if ( aggroDistance == "ANY" ) then return 1; end
    if ( aggroDistance == "MELEE" and inMelee ) then return 1; end
    if ( aggroDistance == "RANGED" and atRange ) then return 1; end
    return nil;
end

-- ********************************************************************
-- * DTM_GUI_FormatThreatValue(value)                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> value: a number denoting threat value.                        *
-- ********************************************************************
-- * Formats a threat value to be displayed in a threat list row.     *
-- ********************************************************************
function DTM_GUI_FormatThreatValue(value)
    if type(value) ~= "number" then return "???"; end

    value = floor(value + .5); -- We don't care about floating threat values.

    if ( DTM_GetCurrentSkinSetting("Text", "ShortFigures") == 1 ) then
        if ( math.abs(value) >= 1000000 ) then
            value = value / 1000000;
            return format("%.1fM", value);

    elseif ( math.abs(value) >= 10000 ) then
            value = value / 1000;
            return format("%.1fk", value);
      else
            return tostring(value);
        end
  else
        return tostring(value);
    end
end

-- --------------------------------------------------------------------
-- **                           Handlers                             **
-- --------------------------------------------------------------------

function DTM_GUI_OnLoad(self)
    DTM_GUI_RegisterEvent("PLAYER_FOCUS_CHANGED", DTM_GUI_FocusChanged);
end

function DTM_GUI_OnEvent(self, event, ...)
    if not ( event ) then return 0; end

    if ( DTM_IsGUIRunning() ~= 1 ) then
        return 0;
    end

    if ( eventHandlers[event] ) then
        eventHandlers[event](...);
        return 1;
    end

    return 2;
end

function DTM_GUI_OnUpdate(self, elapsed)
    -- Toggles for the GUI display.
    local status = DTM_IsGUIRunning();
    if ( DTM_GUI_Shown ) and ( status ~= 1 ) then
        DTM_HideGUI();
        return;

elseif not ( DTM_GUI_Shown ) and ( status == 1 ) then
        DTM_ShowGUI();
    end

    if ( GetTime() >= (updateTimer["CHECK_PARTY"] or 0) ) then
        updateTimer["CHECK_PARTY"] = GetTime() + CHECK_PARTY_TIMER;

        local inParty = ( GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 );
        if ( inParty ~= playerIsInParty ) then
            if ( DTM_GetSavedVariable("gui", "autoDisplayTarget", "active") == "JOIN_PARTY" ) then
                if ( inParty ) then
                    -- Player entered a party.
                    DTM_ThreatListFrames["target"]:Display();
              else
                    -- Player left a party.
                    DTM_ThreatListFrames["target"]:Destroy();
                end
            end

            if ( DTM_GetSavedVariable("gui", "autoDisplayOverview", "active") == "JOIN_PARTY" ) then
                if ( inParty ) then
                    -- Player entered a party.
                    DTM_PresenceListFrames["player"]:Display();
              else
                    -- Player left a party.
                    DTM_PresenceListFrames["player"]:Destroy();
                end
            end

            if ( DTM_GetSavedVariable("gui", "autoDisplayRegain", "active") == "JOIN_PARTY" ) then
                if ( inParty ) then
                    -- Player entered a party.
                    DTM_RegainListFrames["player"]:Display();
              else
                    -- Player left a party.
                    DTM_RegainListFrames["player"]:Destroy();
                end
            end

            playerIsInParty = inParty;
        end
    end

    local inCombat = UnitAffectingCombat("player");
    if ( inCombat ~= inCombatState ) then
        if ( DTM_GetSavedVariable("gui", "autoDisplayTarget", "active") == "ENTER_COMBAT" ) then
            if ( inCombat ) then
                -- Player entered combat.
                DTM_ThreatListFrames["target"]:Display();
          else
                -- Player left combat.
                DTM_ThreatListFrames["target"]:Destroy();
            end
        end

        if ( DTM_GetSavedVariable("gui", "autoDisplayOverview", "active") == "ENTER_COMBAT" ) then
            if ( inCombat ) then
                -- Player entered combat.
                DTM_PresenceListFrames["player"]:Display();
          else
                -- Player left combat.
                DTM_PresenceListFrames["player"]:Destroy();
            end
        end

        if ( DTM_GetSavedVariable("gui", "autoDisplayRegain", "active") == "ENTER_COMBAT" ) then
            if ( inCombat ) then
                -- Player entered combat.
                DTM_RegainListFrames["player"]:Display();
          else
                -- Player left combat.
                DTM_RegainListFrames["player"]:Destroy();
            end
        end

        inCombatState = inCombat;
    end
end

-- --------------------------------------------------------------------
-- **                             Events                             **
-- --------------------------------------------------------------------

-----------------------------------------------------------------------------
-- DTM_GUI_FocusChanged()
--
-- Gets called when the player changes focus.
-----------------------------------------------------------------------------

function DTM_GUI_FocusChanged()
    if not ( DTM_GetSavedVariable("gui", "autoDisplayFocus", "active") == "ON_CHANGE" ) then
        return;
    end

    if ( UnitExists("focus") ) then
        DTM_ThreatListFrames["focus"]:Display();
  else
        DTM_ThreatListFrames["focus"]:Destroy();
    end
end

-----------------------------------------------------------------------------
-- DTM_GUI_ThreatFlagsChanged(name, guid, flag)
--
-- Gets called when an entity known by DTM engine has changed its threat flags.
-----------------------------------------------------------------------------

function DTM_GUI_ThreatFlagsChanged(name, guid, flag)
    local unit, threatListFrame;

    if ( flag == "AGGRO_DELAY" ) then return; end -- Aggro delay doesn't need a threat list reset.

    for unit, threatListFrame in pairs(DTM_ThreatListFrames) do
        if ( threatListFrame.activeUnit ) and ( UnitGUID(threatListFrame.activeUnit) == guid ) then
            -- This threat list should be monitoring the unit who got its flags changed.
            -- Simply ask a complete reset of the threat list, it's probably the simplest way.
            threatListFrame.needReset = 1;
        end
    end
end

-----------------------------------------------------------------------------
-- DTM_GUI_OnSkinEvent(event)
--
-- Gets called when an "event" is fired by the skin management system.
-----------------------------------------------------------------------------

function DTM_GUI_OnSkinEvent(event)
    if ( event == "SKIN_UPDATED" ) then
        -- We have to update the skins management panel, because we did some management operations on the skins list.
        DTM_SkinManager_Update();

elseif ( event == "SKIN_REFRESH" ) then
        -- All elements of the GUI that are skinned have to recompute their display, because the active skin has been changed.
        for unit, frame in pairs(DTM_ThreatListFrames) do frame:ApplySkin(); end
        for unit, frame in pairs(DTM_PresenceListFrames) do frame:ApplySkin(); end
        for unit, frame in pairs(DTM_RegainListFrames) do frame:ApplySkin(); end
        DTM_SkinEditor_TestList:ApplySkin();
        DTM_ConfigurationFrame_GhostRow:ApplySkin();

        -- Also, since the event can also be caused by a selection in the skin dropdown, we have to update the skin manager.
        DTM_SkinManager_Update();

elseif ( event == "SKIN_RESET_NEEDED" ) then
        -- Threat lists need to be re-opened because changes that can only be visible when re-opening have been applied.
        for unit, frame in pairs(DTM_ThreatListFrames) do frame.needReset = 1; end
        DTM_SkinEditor_TestList.needReset = 1;
    end
end
