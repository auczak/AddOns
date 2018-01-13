local activeModule = "Engine I/O";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local DTM_Engine_Ready = nil;
local DTM_Engine_Running = nil;
local eventHandlers = { };

DTM_Entity = { -- THE most important table, which contains entities and their threat data for local player's vicinity.
    number = 0,
};
DTM_Events = { -- Table containing general combat events waiting to be confirmed as successful (due to chances of missing).
    number = 0, -- Also contains pending NPC special threat modifying abilities triggered by yells/emotes.
};
DTM_Time = { -- Table containing time related stuff, such as the threat countdown for fade, invisibility, misdirection effects.
    number = 0,
};
DTM_Stance = {}; -- Table containing the current stance of various entities.
DTM_Talents = { -- Table containing the current talent set of various entities.
    number = 0,
};
DTM_Stats = {}; -- Table containing some important stat data for scaling threat generation for party/raid members' pets.
DTM_Items = { -- Table containing the current items equiped by various entities.
    number = 0,
};
DTM_Sets = { -- Table containing the current sets equipped by various entities.
    number = 0,
};
DTM_Update = {}; -- Table containing clock data, which is used to throttle stuff such as sending for warriors periodically their new stance on the network.
DTM_Combat = {}; -- Remember last combat state of various entities.
DTM_SelfCast = { -- Table buffering spellcasts of the local player that can't be detected in the combat log.
    number = 0,
};
DTM_Emulation = {}; -- Sets whether we want to emulate or not some popular ThreatMeter AddOns, to make as if their main features are running on our client.
DTM_ThreatFlagsCallback = { -- A table of callbacks to call when an entity's threat flags change.
    number = 0,
};
DTM_Symbols = {}; -- Table remembering symbols currently put on various GUIDs.
DTM_Death = {}; -- Table remembering the time of death of nearby entities.

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SetupEngine()                                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Set up the engine part of DTM.                                   *
-- ********************************************************************
function DTM_SetupEngine()
    if ( DTM_Engine_Ready ) then return; end

    -- Combat parse callback
    DTM_RegisterCombatParseCallback(DTM_Combat_Event);

    -- Starts all previous emulations.
    local name, description, _, emulable;
    for i=1, DTM_Emulation_GetNumberOfEmulableAddOns() do
        name, description, _, emulable = DTM_Emulation_GetEmulableAddOnData(i);
        if ( emulable ) then
            DTM_SetEmulationState(name, DTM_GetSavedVariable("engine", "emulation:"..name, "active"), DTM_GetSavedVariable("engine", "spoof:"..name, "active"));
        end
    end

    -- Initial unit list.
    DTM_RebuildUnitList();

    -- Access module needs a hook to NotifyInspect function.
    hooksecurefunc("NotifyInspect", DTM_Access_OnInspectRequest);
    hooksecurefunc("ClearInspectPlayer", DTM_Access_OnTalentsInterrupt);

    DTM_Engine_Ready = 1;
end

-- ********************************************************************
-- * DTM_StartEngine()                                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Start the engine part of DTM.                                    *
-- ********************************************************************
function DTM_StartEngine()
    DTM_SetSavedVariable("engine", "run", 1); -- Global saved variable.
    if not ( DTM_Engine_Ready ) then return; end
    DTM_Engine_Running = 1;
    DTM_Engine_Frame:Show();
end

-- ********************************************************************
-- * DTM_StopEngine()                                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Stop the engine part of DTM.                                     *
-- ********************************************************************
function DTM_StopEngine()
    DTM_SetSavedVariable("engine", "run", 0); -- Global saved variable.
    DTM_Engine_Running = nil;
    DTM_Engine_Frame:Hide();
end

-- ********************************************************************
-- * DTM_IsEngineRunning()                                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Determinates if DTM engine is currently running.                 *
-- * Can return:                                                      *
-- *    - nil => Fullstop (set by the user)                           *
-- *    - 1 => Running                                                *
-- *    - 2 => Auto-disabled (will revert to running automatically)   *
-- *    - 3 => Emergency stop (will need user action to revert)       *
-- ********************************************************************
function DTM_IsEngineRunning()
    -- If a bug occurs while loading up DTM, this function will start
    -- to return nil like crazy >.>

    if not ( DTM_Engine_Running ) then
        return nil; -- First, not being enabled is the top priority status.
    end

    -- Check the emergency stop status.
    if ( DTM_IsEmergencyStopEnabled() ) then
        return 3;
    end

    -- Now determinate if we're in a status which causes the engine to be effectively disabled, but still enabled.
    if ( DTM_TemporaryDisableCondition() ) then
        return 2;
    end

    -- Elsewise, consider we're in the running status.
    return 1;
end

-- --------------------------------------------------------------------
-- **                           Functions                            **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Engine_RegisterEvent(event, handler)                         *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> event: the event to be notified of.                           *
-- * >> handler: the function which will get fired.                   *
-- ********************************************************************
-- * Registers an event and its associated handler on engine frame.   *
-- ********************************************************************
function DTM_Engine_RegisterEvent(event, handler)
    eventHandlers[event] = handler;
    DTM_Engine_Frame:RegisterEvent(event);
end

-- --------------------------------------------------------------------
-- **                            Handlers                            **
-- --------------------------------------------------------------------

function DTM_Engine_OnLoad(self)
    DTM_Engine_RegisterEvent("CHAT_MSG_ADDON", DTM_Network_OnPacketReceived);

    DTM_Engine_RegisterEvent("PLAYER_TARGET_CHANGED", DTM_PlayerTargetChanged);
    DTM_Engine_RegisterEvent("PLAYER_FOCUS_CHANGED", DTM_PlayerFocusChanged);
    DTM_Engine_RegisterEvent("UPDATE_MOUSEOVER_UNIT", DTM_PlayerMouseoverChanged);
    DTM_Engine_RegisterEvent("UNIT_TARGET", DTM_UnitTargetChanged);

    -- These events will ask an unit list reconstruction.
    DTM_Engine_RegisterEvent("PARTY_MEMBERS_CHANGED", DTM_RebuildUnitList);
    DTM_Engine_RegisterEvent("RAID_ROSTER_UPDATE", DTM_RebuildUnitList);

    DTM_Engine_RegisterEvent("CHAT_MSG_MONSTER_YELL", DTM_OnCreatureMessage);
    DTM_Engine_RegisterEvent("CHAT_MSG_MONSTER_EMOTE", DTM_OnCreatureMessageDoReplace);
    DTM_Engine_RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", DTM_OnCreatureMessage);

    DTM_Engine_RegisterEvent("UNIT_SPELLCAST_SENT", DTM_SelfCast_Register);
    DTM_Engine_RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", DTM_SelfCast_Success);
    DTM_Engine_RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", DTM_SelfCast_Interrupt);
    DTM_Engine_RegisterEvent("UNIT_SPELLCAST_FAILED", DTM_SelfCast_Interrupt);
    DTM_Engine_RegisterEvent("UI_ERROR_MESSAGE", DTM_SelfCast_OnErrorMessage); -- For feign death resists.

    DTM_Engine_RegisterEvent("INSPECT_TALENT_READY", DTM_Access_OnTalentsReceipt);

    DTM_Engine_RegisterEvent("RAID_TARGET_UPDATE", DTM_SymbolsBuffer_RaidTargetUpdated);

    DTM_Engine_RegisterEvent("UNIT_FLAGS", DTM_UnitFlagsChanged);

    -- WotLK-only event
    if ( DTM_OnWotLK() ) then
        DTM_Engine_RegisterEvent("UNIT_THREAT_LIST_UPDATE", DTM_Native_OnThreatListUpdate);
    end

    -- Test events.
    -- DTM_Engine_RegisterEvent("UNIT_FLAGS", function() DTM_ChatMessage(format("UNIT_FLAGS fired. {%s,%s}", date(), tostring(arg1))); end);
    -- DTM_Engine_RegisterEvent("UNIT_DYNAMIC_FLAGS", function() DTM_ChatMessage(format("UNIT_DYNAMIC_FLAGS fired. {%s,%s}", date(), tostring(arg1))); end);
end

function DTM_Engine_OnEvent(self, event, ...)
    if not ( event ) then return 0; end

    local handlerFunc = eventHandlers[event];
    if ( handlerFunc ) then
        DTM_ProtectedCall(handlerFunc, "MAJOR", ...);
        return 1;
    end

    return 2;
end

-- --------------------------------------------------------------------
-- **                             Events                             **
-- --------------------------------------------------------------------

-- See the corresponding modules for the other event handlers.