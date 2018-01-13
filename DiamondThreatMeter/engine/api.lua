local activeModule = "Engine API";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_UnitThreat(unit, otherUnit)                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: unit (should be a mob) to get the hate it has toward    *
-- * >> otherUnit: ...the other unit.                                 *
-- ********************************************************************
-- * Determinates the threat otherUnit has toward unit.               *
-- * Otherwise said: determinates the hate unit has toward otherUnit. *
-- * As of 1.2.0, this API accepts GUID input in the "unit" and       *
-- * "otherUnit" parameters.                                          *
-- ********************************************************************
function DTM_UnitThreat(unit, otherUnit)
    if not ( DTM_IsEngineRunning() == 1 ) then
        return 0;
    end

    if ( UnitExists(unit, otherUnit) ) and not ( UnitCanAttack(unit, otherUnit) ) then
        return 0;
    end

    local unitGUID = UnitGUID(unit);
    local otherUnitGUID = UnitGUID(otherUnit);

    if ( not unitGUID ) or ( not otherUnitGUID ) then
        unitGUID = unit;
        otherUnitGUID = otherUnit;
    end

    if ( unitGUID and otherUnitGUID ) then
        local unitData = DTM_EntityData_Get(unitGUID, nil);
        if ( unitData ) then
            local unitThreatList = unitData.threatList;
            local otherUnitData = DTM_ThreatList_GetEntity(unitThreatList, otherUnitGUID);

            if ( otherUnitData ) then
                return otherUnitData.threat or 0;
            end
        end
    end

    return 0;
end

-- ********************************************************************
-- * DTM_UnitThreatListSize(unit)                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: unit (should be a mob) to get the threat list size from.*
-- ********************************************************************
-- * Returns the size of the threat list determined by DTM for the    *
-- * given NPC (or even PC if it's no belonging to our raid).         *
-- * As of 1.2.0, this API accepts GUID input in "unit" parameter.    *
-- ********************************************************************

function DTM_UnitThreatListSize(unit)
    if ( unit == "test" ) then
        -- Test support.
        return 3;
    end

    local guid = UnitGUID(unit);

    if ( not guid ) then
        guid = unit;
    end

    if ( guid ) and ( DTM_IsEngineRunning() == 1 ) then
        local entityData = DTM_EntityData_Get(guid, nil);
        if ( entityData ) then
            local threatList = entityData.threatList;
            if ( threatList ) then
                return threatList.number or 0;
            end
        end
    end

    return 0;
end

-- ********************************************************************
-- * DTM_UnitThreatList(unit, index)                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: unit (should be a mob) to get the threat list data from.*
-- * >> index: ...of the element of the list to grab.                 *
-- ********************************************************************
-- * Grab an element in the threat list of a given NPC (or even PC).  *
-- * As of 1.2.0, this API accepts GUID input in "unit" parameter.    *
-- * Returns:                                                         *
-- * 1 - Name of the entity that unit doesn't like.                   *
-- * 2 - GUID of the entity.                                          *
-- * 3 - Threat of the entity toward the mob.                         *
-- * 4 - Class of the entity (nil if unknown or not a player).        *
-- * 5 - Flag indicating if the entity belongs to our group.          *
-- * 6 - TPS calculated by the engine.                                *
-- ********************************************************************

function DTM_UnitThreatList(unit, index)
    if ( unit == "test" ) then
        -- Test support.
        if ( index == 1 ) then
            return DTM_Localise("Foo"), -2, 10932, "WARRIOR", nil, 595;
      elseif ( index == 2 ) then
            return DTM_Localise("Bar"), -3, 9841, "PRIEST", 1, 191;
      elseif ( index == 3 ) then
            return UnitName("player"), UnitGUID("player"), 2500, select(2, UnitClass("player")), 1, 266;
        end
    end

    local guid = UnitGUID(unit);

    if ( not guid ) then
        guid = unit;
    end

    if ( guid ) and ( DTM_IsEngineRunning() == 1 ) then
        local entityData = DTM_EntityData_Get(guid, nil);
        if ( entityData ) then
            local threatList = entityData.threatList;
            if ( threatList ) then
                DTM_ThreatList_Sort(threatList);
                return threatList[index].name or "???", threatList[index].guid or "???", threatList[index].threat or 0, threatList[index].class or nil, threatList[index].flag or nil, threatList[index].tps or 0;
            end
        end
    end

    return "???", "???", 0, nil, nil, 0;
end

-- ********************************************************************
-- * DTM_UnitThreatGetAggro(unit)                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: unit (should be a mob) to get the aggro data from.      *
-- ********************************************************************
-- * Get name and GUID of the unit the specified unit has aggro on.   *
-- * As of 1.2.0, this API accepts GUID input in "unit" parameter.    *
-- ********************************************************************

function DTM_UnitThreatGetAggro(unit)
    if ( unit == "test" ) then
        -- Test support.
        return DTM_Localise("Bar"), -3;
    end

    local guid = UnitGUID(unit);

    if ( not guid ) then
        guid = unit;
    end

    if ( guid ) and ( DTM_IsEngineRunning() == 1 ) then
        local entityData = DTM_EntityData_Get(guid, nil);
        if ( entityData ) then
            local threatList = entityData.threatList;
            return threatList.aggroName or nil, threatList.aggroGUID or nil;
        end
    end

    return nil;
end

-- ********************************************************************
-- * DTM_UnitThreatFlags(unit)                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: unit (should be a mob) to get threat flags of.          *
-- ********************************************************************
-- * Get the special threat flags active on a unit.                   *
-- * Returns:                                                         *
-- *    - No threat list flag (can be 1 "YES" or 0 "NO")              *
-- *    - Warning overide (can be 1 "Force warning ON",               *
-- *                              0 "Use user's settings",            *
-- *                             -1 "Force warning OFF")              *
-- *    - Aggro delay: the time the engine will wait after an unit    *
-- * changed its target before considering the unit switched its      *
-- * aggro to its new target.                                         *
-- *    - Aggro distance: either "ANY", "MELEE", "RANGED" or "NONE".  *
-- * it specifies when you can grab aggro of the unit.                *
-- *                                                                  *
-- * All returns will be nil if the unit doesn't exist.               *
-- * These flags can be modified mid-battle if a boss yells or does   *
-- * something special. Your threat GUI can register itself to the    *
-- * engine to be notified of such events.                            *
-- ********************************************************************

function DTM_UnitThreatFlags(unit)
    local guid = UnitGUID(unit);

    if ( (tonumber(guid) or 0) > 0 ) and ( DTM_IsEngineRunning() == 1 ) then
        local noThreatListFlag, warningOverideFlag, aggroDelay, aggroDistance;

        local entityData = DTM_EntityData_Get(guid, nil);
        if ( entityData ) then
            noThreatListFlag = entityData.noThreatList;
            warningOverideFlag = entityData.warningOveride;
            aggroDelay = entityData.aggroDelay;
            aggroDistance = entityData.aggroDistance;
        end

        local npcData = DTM_GetNPCAbilityData(UnitName(unit));
        if ( npcData ) then
            if not ( noThreatListFlag ) then
                noThreatListFlag = npcData.noThreatList;
            end
            if not ( warningOverideFlag ) then
                warningOverideFlag = npcData.warningOveride;
            end
            if not ( aggroDelay ) then
                aggroDelay = npcData.aggroDelay;
            end
            if not ( aggroDistance ) then
                aggroDistance = npcData.aggroDistance;
            end
        end

        return noThreatListFlag or 0, warningOverideFlag or 0, aggroDelay or DTM_GetSavedVariable("engine", "aggroValidationDelay", "active"), aggroDistance or "ANY";
    end

    return nil, nil, 0, "NONE";
end

-- ********************************************************************
-- * DTM_UnitPresenceListSize(unit)                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: unit to get the presence list size from.                *
-- ********************************************************************
-- * Returns the size of the presence list determined by DTM for the  *
-- * given PC (or even NPC). A presence list is the list of entities  *
-- * that have the unit on their threat list.                         *
-- * As of 1.2.0, this API accepts GUID input in "unit" parameter.    *
-- ********************************************************************

function DTM_UnitPresenceListSize(unit)
    local myGUID = UnitGUID(unit);

    if ( not myGUID ) then
        myGUID = unit;
    end

    if ( myGUID ) and ( DTM_IsEngineRunning() == 1 ) then
        local entityData = DTM_EntityData_Get(myGUID, nil);
        if ( entityData ) then
            local presenceList = entityData.presenceList;
            if ( presenceList ) then
                return presenceList.number or 0;
            end
        end
    end

    return 0;
end

-- ********************************************************************
-- * DTM_UnitPresenceList(unit, index)                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: unit to get the presence list data from.                *
-- * >> index: ...of the element of the list to grab.                 *
-- ********************************************************************
-- * Grab an element in the presence list of a given PC or NPC.       *
-- * As of 1.2.0, this API accepts GUID input in "unit" parameter.    *
-- * Returns:                                                         *
-- * 1 - Name of the entity that's angry with unit.                   *
-- * 2 - GUID of the entity                                           *
-- * 3 - Threat of unit toward the entity.                            *
-- * 4 - Ratio of aggro threat of unit toward the entity (can be nil).*
-- * 5 - Flag indicating if unit has aggro of the entity (1 or nil).  *
-- * 6 - TPS calculated by the engine.                                *
-- ********************************************************************

function DTM_UnitPresenceList(unit, index)
    local myGUID = UnitGUID(unit);

    if ( not myGUID ) then
        myGUID = unit;
    end

    if ( myGUID ) and ( DTM_IsEngineRunning() == 1 ) then
        local entityData = DTM_EntityData_Get(myGUID, nil);
        if ( entityData ) then
            local presenceList = entityData.presenceList;
            if ( presenceList ) then
                DTM_ThreatList_Sort(presenceList);

                local name, guid, threat, ratio, hasAggro, tps;

                name = presenceList[index].name or "???";
                guid = presenceList[index].guid or "???";
                threat = presenceList[index].threat or 0;
                ratio = nil;
                hasAggro = nil;
                tps = presenceList[index].tps or 0;

                local angryGuyData = DTM_EntityData_Get(guid, nil);
                if ( angryGuyData ) then
                    local i;
                    local threatList = angryGuyData.threatList;

                    if ( threatList.aggroGUID == myGUID ) then
                        hasAggro = 1;
                        ratio = 1;
                  else
                        for i=1, threatList.number do
                            if ( threatList[i].guid == threatList.aggroGUID ) and ( (threatList[i].threat or 0) > 0 ) then
                                ratio = threat / threatList[i].threat;
                            end
                        end
                    end
                end

                return name, guid, threat, ratio, hasAggro, tps;
            end
        end
    end

    return "???", "???", 0, nil, nil, 0;
end

-- ********************************************************************
-- * DTM_FindGUIDFromName(name)                                       *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name you want to resolve.                           *
-- ********************************************************************
-- * Gets the GUID associated to the given name.                      *
-- * Will not work if there is no threat data linked to <name>.       *
-- * In case several instances exist, the first one is returned.      *
-- * The second return value returns the number of collisions.        *
-- ********************************************************************

function DTM_FindGUIDFromName(name)
    local guid, matches = nil, 0;

    DTM_EntityData_PickUpAndDo( function(myName, myGUID, threatList, presenceList)
                                    if ( myName == name ) then
                                        if ( not guid ) then guid = myGUID; end
                                        matches = matches + 1;
                                    end
                                end );

    return guid, matches;
end

-- ********************************************************************
-- * DTM_NotifyOnThreatFlagsChange(func)                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> func: the function to call.                                   *
-- ********************************************************************
-- * Registers an arbitrary function to be run whenever DTM detects   *
-- * that an unit's threat flags have changed.                        *
-- *                                                                  *
-- * 3 arguments are sent to this function: the unitName,             *
-- * the unitGUID and the flag that changed.                          *
-- * The flag's new value should be immediately available via         *
-- * UnitThreatFlags(unit) API.                                       *
-- * Flag can be: NO_THREAT_LIST, WARNING_OVERIDE, AGGRO_DELAY or     *
-- *              AGGRO_DISTANCE.                                     *
-- ********************************************************************

function DTM_NotifyOnThreatFlagsChange(func)
    if ( type(func) ~= "function" ) then return nil; end
    DTM_ThreatFlagsCallback.number = DTM_ThreatFlagsCallback.number + 1;
    DTM_ThreatFlagsCallback[DTM_ThreatFlagsCallback.number] = func;
    return 1;
end