local activeModule = "Engine maintenance";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_CheckUnitReset(unit)                                         *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit to check.                                      *
-- ********************************************************************
-- * Check if we should reset given unit's threat list.               *
-- * This API will silently fail if the appropriate saved variable is *
-- * not set.                                                         *
-- ********************************************************************
function DTM_CheckUnitReset(unit)
    if not ( UnitIsVisible(unit) ) then return; end
    if ( UnitIsPlayer(unit) ) then return; end

    local detectUnitReset = DTM_GetSavedVariable("engine", "detectUnitReset", "active");
    if not ( detectUnitReset == 1 ) then
        return;
    end

    local unitTarget = unit.."target";
    if not ( UnitExists(unitTarget) ) and not ( UnitIsTapped(unit) ) and not ( UnitAffectingCombat(unit) ) then
        DTM_EntityData_DeleteByGUID(UnitGUID(unit));
        DTM_Trace("MAINTENANCE", "[%s]'s threat data has been reset.", 1, UnitName(unit));
    end
end

-- ********************************************************************
-- * DTM_Maintenance_ClearOutdated()                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * This function, when called periodically, allows DTM to maintain  *
-- * only data of entities we have heard something about at least     *
-- * 600 sec. before.                                                 *
-- ********************************************************************
function DTM_Maintenance_ClearOutdated()
    if ( DTM_GetSavedVariable("engine", "detectUnitReset", "active") ~= 1 ) then return; end

    local updateTimer = DTM_Update["CHECK_OUTDATED_DATA"] or 0;
    if ( GetTime() < updateTimer ) then
        return;
    end
    DTM_Update["CHECK_OUTDATED_DATA"] = GetTime() + DTM_GetSavedVariable("engine", "checkOutdatedInterval", "active");

    DTM_EntityData_PickUpTableAndDo( function(data, threshold)
                                         if ( (GetTime() - data.lastUpdate) > threshold ) then
                                             DTM_Trace("MAINTENANCE", "[%s] has been removed from DB, as no info about it were acquired for %d sec.", 1, data.name, threshold);
                                             DTM_EntityData_Delete(data.guid);
                                         end
                                     end , DTM_GetSavedVariable("engine", "outdatedThreshold", "active") );

    DTM_EntityData_PickUpTableAndDo( function(data, threshold)
                                         if ( (GetTime() - data.lastUpdate) > threshold ) and ( data.threatList.number <= 0 ) then
                                             DTM_Trace("MAINTENANCE", "[%s] has been removed from DB, as its threat list is empty and no info about it were acquired for %d sec.", 1, data.name, threshold);
                                             DTM_EntityData_Delete(data.guid);
                                         end
                                     end , DTM_GetSavedVariable("engine", "outdatedThresholdEmpty", "active") );
end