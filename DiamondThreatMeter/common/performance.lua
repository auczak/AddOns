local activeModule = "Performance";

-- --------------------------------------------------------------------
-- **                       Performance data                         **
-- --------------------------------------------------------------------

-- This module provides some miscellaneous function to evaluate DTM's CPU performances among versions.
-- You can also compare them to the total AddOn CPU usage.

local testData = {
    amount = 100,
    amountType = "DAMAGE",
    amountTiming = "INSTANT",
    powerType = "HP",
    special = nil,
    effect = {type = "MULTIPLY_THREAT", target = "GLOBAL_THREAT", value = 2.0, owner = "ACTOR", relative = "TARGET"},
    rank = nil,
    sourceName = "Test1",
    sourceGUID = 1,
    sourceFlags = COMBATLOG_OBJECT_TYPE_PLAYER,
    targetName = "Test2",
    targetGUID = 2,
    ability = "DEFAULT",
    timestamp = 0,
    delay = 0,
};

-- --------------------------------------------------------------------
-- **                        Performance API                         **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Performance_CanEvaluate()                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Determinates if WoW is configured to enable UI perf. evaluation. *
-- ********************************************************************

function DTM_Performance_CanEvaluate()
    if ( GetCVar("scriptProfile") == "0" ) then
        return nil;
  else
        return 1;
    end
end

-- ********************************************************************
-- * DTM_Performance_Switch(flag)                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> flag: do we turn ON or OFF the performance fonctionnality ?   *
-- ********************************************************************
-- * Turn ON or OFF the performance utility and restart the UI.       *
-- ********************************************************************

function DTM_Performance_Switch(flag)
    if ( flag ) and not ( DTM_Performance_CanEvaluate() ) then
        SetCVar("scriptProfile", "1");
        ReloadUI();

elseif not ( flag ) and ( DTM_Performance_CanEvaluate() ) then
        SetCVar("scriptProfile", "0");
        ReloadUI();
    end
end

-- ********************************************************************
-- * DTM_Performance_TestFunction(func, ...)                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> func: a direct reference to the function to test.             *
-- * >> ...: additionnal arguments to pass to it.                     *
-- ********************************************************************
-- * Runs a given function, and grab CPU time it used.                *
-- * As this function is called out of a context and 1000 times,      *
-- * the value this function determinates has no meaning when matched *
-- * against the total CPU usage or DTM CPU usage.                    *
-- * It can be used to compare different ways of doing the same       *
-- * thing, however, and choosing the most efficient one.             *
-- ********************************************************************

function DTM_Performance_TestFunction(func, ...)
    if not ( DTM_Performance_CanEvaluate() ) then
        DTM_ChatMessage("Enable performance evaluation first.", 1);
        return;
    end

    -- OK, let's rock !
    ResetCPUUsage();
    local i;
    for i=1, 1000 do
        func(...);
    end
    UpdateAddOnCPUUsage();

    -- Hum so?

    local cpuTime = GetFunctionCPUUsage(func, 1);
    DTM_ChatMessage(format("This function has a CPU usage of: %.5f", cpuTime), 1);
end

-- ********************************************************************
-- * DTM_Performance_TestCombatEvent()                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Runs the combat event apply function with a dummy test event,    *
-- * and grab CPU time it used.                                       *
-- * As this function is called out of a context and 1000 times,      *
-- * the value this function determinates has no meaning when matched *
-- * against the total CPU usage or DTM CPU usage.                    *
-- * It can be used to compare different ways of doing the same       *
-- * thing, however, and choosing the most efficient one.             *
-- ********************************************************************

function DTM_Performance_TestCombatEvent()
    if not ( DTM_Performance_CanEvaluate() ) then
        DTM_ChatMessage("Enable performance evaluation first.", 1);
        return;
    end

    -- OK, let's rock !
    ResetCPUUsage();
    local i;
    for i=1, 1000 do
        DTM_CombatEvents_Apply(testData);
    end
    UpdateAddOnCPUUsage();

    -- Hum so?
    local cpuTime = GetFunctionCPUUsage(DTM_CombatEvents_Apply, 1);
    DTM_ChatMessage(format("Combat event application function has had\na CPU usage of (1000 exec): %.5f", cpuTime), 1);
end

-- --------------------------------------------------------------------
-- **                     Performance functions                      **
-- --------------------------------------------------------------------

function DTM_SIMULATE_SOULSHATTER()
    local fakeEvent = {Timestamp = 0,
                       Actor = { Name = UnitName("player"), GUID = UnitGUID("player"), Flags = COMBATLOG_OBJECT_TYPE_PLAYER },
                       Target = { Name = UnitName("target"), GUID = UnitGUID("target"), Flags = COMBATLOG_OBJECT_TYPE_NPC },
                       Outcome = "CAST_SUCCESS",
                       Class = "ABILITY",
                       Ability = { Name = "Brise-âme", Id = 1, School = 0 }};
    DTM_Combat_Event(fakeEvent);
end








