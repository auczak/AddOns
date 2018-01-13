local activeModule = "Engine zonewide services";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local processData = {
    status = "READY",
    timeStarted = 0,
};

local validApplies = {};
local globalEnemyList = {};

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_ZoneWide_CheckRaidCombat(callback)                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> callback: function to call once the whole process has been    *
-- * finished.                                                        *
-- ********************************************************************
-- * This function ensures party members that are close to you are    *
-- * added to the threat lists of the mobs that are engaged in combat.*
-- * This function has no effect outside of a PvE instance and should *
-- * be called at a reasonable rate. This function only completes     *
-- * threat lists with raid members that are in combat. This function *
-- * silently fails if called out of a valid context or while you're  *
-- * out of combat.                                                   *
-- ********************************************************************

function DTM_ZoneWide_CheckRaidCombat(callback)
    if not ( DTM_ZoneWide_CanCheckRaidCombat() == "OK" ) then return nil; end

    processData.status = "CLEANUP";
    processData.timeStarted = GetTime();
    processData.callback = callback;

    return 1;
end

-- ********************************************************************
-- * DTM_ZoneWide_CanCheckRaidCombat()                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * This function determinates if you can send a zonewide combat     *
-- * check request to the engine of DTM.                              *
-- ********************************************************************

function DTM_ZoneWide_CanCheckRaidCombat()
    local enabled = DTM_GetSavedVariable("engine", "checkZoneWideCombat", "active") > 0;
    if ( not enabled ) then return "DISABLED"; end

    -- WotLK beta: to avoid conflicts, zone-wide combat checks are currently disabled, to see if native threat meter provides this service itself.
    if ( DTM_OnWotLK() ) then return "DISABLED"; end

    if ( not UnitAffectingCombat("player") ) then return "INVALID"; end
    if ( (GetNumPartyMembers() + GetNumRaidMembers()) == 0 ) then return "INVALID"; end

    local inInstance, instanceType = IsInInstance();
    if ( instanceType ~= "party" and instanceType ~= "raid" ) then
        return "INVALID";
    end

    if ( processData.status ~= "READY" ) then return "BUSY"; end

    return "OK";
end

-- ********************************************************************
-- * DTM_ZoneWide_CancelRaidCombatCheck()                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- *     <none>                                                       *
-- ********************************************************************
-- * Cancels a currently running raid combat check.                   *
-- * This function is important to be called when resetting threat    *
-- * data or it could make garbage apparear in the new threat table   *
-- * if the reset is done when a raid combat check is running.        *
-- ********************************************************************

function DTM_ZoneWide_CancelRaidCombatCheck()
    if not ( processData.status == "READY" ) then return nil; end

    if ( type(processData.callback) == "function" ) then processData.callback(nil); end
    processData.status = "READY";
end

-- --------------------------------------------------------------------
-- **                            Handler                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_ZoneWide_OnUpdate(elapsed)                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> elapsed: the time that elapsed since last call.               *
-- ********************************************************************
-- * Gets called periodically to check for end of processing.         *
-- ********************************************************************

function DTM_ZoneWide_OnUpdate(elapsed)
    local i;

    if ( processData.status == "CLEANUP" ) then
        -- First step: clean up the tables with which we'll work.
        local k, v;
        for k, v in pairs(validApplies) do validApplies[k] = nil; end
        for k, v in pairs(globalEnemyList) do globalEnemyList[k] = nil; end
        processData.status = "LISTING";

elseif ( processData.status == "LISTING" ) then
        -- Second step: determinate the list of raid members that are close to us and in combat, so affected by the zonewide combat.
        local totalIndex, baseUID, UID = 0, nil, nil, nil;

        if ( GetNumRaidMembers() > 0 ) then
            totalIndex = GetNumRaidMembers();
            baseUID = "raid";
      else
            if ( GetNumPartyMembers() > 0 ) then
                totalIndex = GetNumPartyMembers();
                baseUID = "party";
            end
        end

        for i=1, totalIndex do
            UID = baseUID..i;
            if ( UnitExists(UID) and UnitCanAssist("player", UID) and UnitAffectingCombat(UID) and CheckInteractDistance(UID, 4) ) then
                validApplies[#validApplies+1] = UnitGUID(UID).."|"..UnitName(UID);
            end

            UID = baseUID..i.."pet";
            if ( UnitExists(UID) and UnitCanAssist("player", UID) and UnitAffectingCombat(UID) and CheckInteractDistance(UID, 4) ) then
                validApplies[#validApplies+1] = UnitGUID(UID).."|"..UnitName(UID);
            end
        end

        processData.status = "BUILDING";
        processData.index = 1;

elseif ( processData.status == "BUILDING" ) then
        -- Third step: determinate the global enemy list by merging all applies' presence lists.
        -- This step is subdivided in sub-steps: 1 apply is worked on each OnUpdate call to lift the processor usage.
 
        if ( processData.index > #validApplies ) then
            processData.status = "APPLY";
            processData.index = 1;
      else
            local applyGUID, applyName = strsplit("|", validApplies[processData.index], 2);
            local applyData = DTM_EntityData_Get(applyGUID, nil);
            if ( applyData ) then
                local applyPresenceList = applyData.presenceList;
                for i=1, applyPresenceList.number do
                    globalEnemyList[applyPresenceList[i].guid] = applyPresenceList[i].name or globalEnemyList[applyPresenceList[i].guid];
                end
            end
            processData.index = processData.index + 1;
        end

elseif ( processData.status == "APPLY" ) then
        -- Last step: merge the global enemy list to each apply's presence list!
        -- This step is subdivided in sub-steps: 1 apply is worked on each OnUpdate call to lift the processor usage.

        if ( processData.index > #validApplies ) then
            -- The end of the process.
            if ( type(processData.callback) == "function" ) then processData.callback(1); end
            processData.status = "READY";
      else
            local applyGUID, applyName = strsplit("|", validApplies[processData.index], 2);
            local applyPointer = DTM_GetUnitPointer(applyGUID); -- Used to prevent zonewide application if the apply died in between.
            if ( applyPointer ) and ( UnitAffectingCombat(applyPointer) ) then
                local enemyGUID, enemyName;
                for enemyGUID, enemyName in pairs(globalEnemyList) do
                    -- If the enemy has died in between, it'd be quite confusing if it's once again added !
                    if not ( DTM_Combat_UnitHasDiedRecently(enemyGUID) ) then
                        -- If we can get a pointer to the enemy, ensure it can attack the apply before adding the apply to its list !
                        local enemyPointer = DTM_GetUnitPointer(enemyGUID);
                        if not ( enemyPointer ) or ( UnitCanAttack(applyPointer, enemyPointer) ) then
                            DTM_ThreatList_Modify(enemyName, enemyGUID, applyName, applyGUID, "VALUE", 0, nil);
                        end
                    end
                end
            end
            processData.index = processData.index + 1;
        end
    end
end