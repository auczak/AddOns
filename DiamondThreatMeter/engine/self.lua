local activeModule = "Engine self";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                               API                              **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Self_Update()                                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Does periodic operations on self, such as talents grab.          *
-- ********************************************************************
function DTM_Self_Update()
    local updateTimer;

    updateTimer = DTM_Update["SELF_TALENTS"] or 0;
    if ( GetTime() > updateTimer ) then
        -- Grabbing self talents is always instantaneous and do not really use the access engine.
        DTM_TalentsBuffer_Grab("player");
        DTM_Update["SELF_TALENTS"] = GetTime() + DTM_GetSavedVariable("engine", "selfTalentsUpdateInterval", "active");
    end

    updateTimer = DTM_Update["SELF_GEAR"] or 0;
    if ( GetTime() > updateTimer ) then
        -- Grabbing self gear is always instantaneous and do not really use the access engine.
        DTM_ItemsBuffer_Grab("player");
        DTM_Update["SELF_GEAR"] = GetTime() + DTM_GetSavedVariable("engine", "selfGearUpdateInterval", "active");
    end

    updateTimer = DTM_Update["NOTIFY_TALENTS"] or 0;
    if ( GetTime() > updateTimer ) then
        -- Warn your group of your talents.
        DTM_TalentsBuffer_NotifyTalents();
        DTM_Update["NOTIFY_TALENTS"] = GetTime() + DTM_GetSavedVariable("engine", "talentsNotifyInterval", "active");
    end

    -- ***** Class dependant stuff *****

    local _, myClass = UnitClass("player");

    -- If we are a class with a pet, we tell periodically our pet's AP/LV.
    updateTimer = DTM_Update["SELF_STATS"] or 0;
    if ( GetTime() > updateTimer ) and ( myClass == "HUNTER" or myClass == "WARLOCK" ) then
        -- DTM_StatsBuffer_Grab("player");
        DTM_StatsBuffer_Grab("pet");
        DTM_Update["SELF_STATS"] = GetTime() + DTM_GetSavedVariable("engine", "statsUpdateInterval", "active");
    end

    -- We periodically send a stance update if we are a WARRIOR class (b/c stance cannot be directly determined for this class).
    updateTimer = DTM_Update["SELF_STANCE"] or 0;
    if ( GetTime() > updateTimer ) and ( myClass == "WARRIOR" ) then
        DTM_StanceBuffer_NotifyStance( DTM_GetStance(nil, "player") );
        DTM_Update["SELF_STANCE"] = GetTime() + DTM_GetSavedVariable("engine", "stanceNotifyInterval", "active");
    end
end

-- --------------------------------------------------------------------
-- **                             Functions                          **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Self_GetAggroGainThreshold(unit)                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * unit: the unit you might get aggro of.                           *
-- ********************************************************************
-- * Determinates the % of threat relative to the guy who has         *
-- * currently the aggro of a given unit to have in order to grab     *
-- * <unit>'s aggro, by checking if you are in melee range.           *
-- ********************************************************************
function DTM_Self_GetAggroGainThreshold(unit)
    if not ( unit ) then return 1.3; end
    local inMelee = CheckInteractDistance(unit, 3);
    if ( inMelee ) then
        return 1.1;
  else
        return 1.3;
    end
end