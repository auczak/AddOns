local activeModule = "Engine threat list";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                                API                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_ThreatList_GetEntity(threatList, guid)                       *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> threatList: the threat list to work with.                     *
-- * >> guid: the GUID of the entity to get that is on threat list.   *
-- ********************************************************************
-- * Grab the data about a given GUID that is on the specified threat *
-- * list. If not on the threat list, nil is returned.                *
-- ********************************************************************
function DTM_ThreatList_GetEntity(threatList, guid)
    local i;
    for i=1, threatList.number do
        data = threatList[i];
        if ( data.guid ) then
            if ( data.guid == guid ) then
                return data;
            end
        end
    end

    return nil;
end

-- ********************************************************************
-- * DTM_ThreatList_PickUpAndDo(threatList, func, ...)                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> threatList: the threat list to work with.                     *
-- * >> func: the function to call. name and GUID of the picked up    *
-- * entity will be passed to it.                                     *
-- * >> ... : additionnal parameters to pass to func.                 *
-- ********************************************************************
-- * Pick up every entity from threat list and execute a given func,  *
-- * passing name, GUID and threat to it as arguments.                *
-- ********************************************************************
function DTM_ThreatList_PickUpAndDo(threatList, func, ...)
    -- additionnalArgs = { ... };
    local i;
    for i=threatList.number, 1, -1 do
        data = threatList[i];
        func(data.name, data.guid, data.threat, ...);
    end
end

-- ********************************************************************
-- * DTM_ThreatList_PickUpTableAndDo(threatList, func, ...)           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> threatList: the threat list to work with.                     *
-- * >> func: the function to call. Data of the picked up entity will *
-- * be passed to it.                                                 *
-- * >> ... : additionnal parameters to pass to func.                 *
-- ********************************************************************
-- * Pick up every entity from threat list and execute a given func,  *
-- * passing the data table of the entity as argument.                *
-- ********************************************************************
function DTM_ThreatList_PickUpTableAndDo(threatList, func, ...)
    local i;
    for i=threatList.number, 1, -1 do
        data = threatList[i];
        func(data, ...);
    end
end

-- ********************************************************************
-- * DTM_ThreatList_Modify(relativeName, relativeGUID,                *
-- *                       ownerName, ownerGUID)                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> ownerName, ownerGUID: stuff about the guy who is              *
-- * looking damn threatening.                                        *
-- * >> relativeName, relativeGUID: stuff about the guy who is kinda  *
-- * annoyed by what the owner does.                                  *
-- * >> operation: one of the 4 threat operation there is currently:  *
-- * VALUE (additionnal "value" parameter required), DROP, TAUNT or,  *
-- * more recently, "SET" (additionnal "value" parameter required).   *
-- * >> value: the threat value ADDED for VALUE operation (can be <0) *
-- * and SET operation (cannot be negative with this operation).      *
-- * >> valueCoeff: the threat value MULTIPLIED for value operation.  *
-- * N.B: "value" argument can also be used for TAUNT operation; it   *
-- * tells the function the name *or* GUID of who the owner should    *
-- * taunt the relative off from. A GUID is of course better to pass. *
-- ********************************************************************
-- * Perform a threat modifying operation.                            *
-- * This function will be called A LOT of times.                     *
-- ********************************************************************

function DTM_ThreatList_Modify(relativeName, relativeGUID, ownerName, ownerGUID, operation, value, valueCoeff)
    if ( ownerGUID == relativeGUID ) then return; end -- Cannot generate threat for self.
    if ( tonumber(ownerGUID) == 0 or tonumber(relativeGUID) == 0 ) then return; end -- Must have a relative and an owner.

    -- STEP 1 - Check the relative has the owner in its threat list.

    local relativeData = DTM_EntityData_Get(relativeGUID, 1);
    local threatList = relativeData.threatList;
    relativeData.name = relativeName;

    local ownerData = DTM_ThreatList_GetEntity(threatList, ownerGUID);
    local ownerPtr = DTM_GetUnitPointer(ownerGUID);
    local ownerClass = nil;
    local isInGroup = nil;

    if ( ownerPtr ) then
        isInGroup = UnitInParty(ownerPtr) or UnitInRaid(ownerPtr) or UnitIsUnit(ownerPtr, "pet") or UnitIsUnit(ownerPtr, "player");
        _, ownerClass = UnitClass(ownerPtr);
        if not ( UnitIsPlayer(ownerPtr) ) then
            ownerClass = nil;
        end
    end

    if not ( ownerData ) then
        threatList.number = threatList.number + 1;
        threatList[threatList.number] = {
                                            name = ownerName,
                                            guid = ownerGUID,
                                            class = ownerClass,
                                            flag = isInGroup,
                                            threat = 0,
                                            tps = 0,
                                            -- tpsUpdate = 0,
                                            history = { },
                                        };
        ownerData = threatList[threatList.number];
  else
        -- Grabbing incomplete data is good ! =)
        ownerData.flag = ownerData.flag or isInGroup;
        ownerData.class = ownerData.class or ownerClass;
        -- Refreshing is also good ! The owner could indeed change its name in-between.
        ownerData.name = ownerName or ownerData.name;
    end

    -- STEP 2 - Now check the owner has the relative in its presence list.

    local ownerEntityData = DTM_EntityData_Get(ownerGUID, 1);
    local presenceList = ownerEntityData.presenceList;
    ownerEntityData.name = ownerName;

    local relativePresenceData = DTM_ThreatList_GetEntity(presenceList, relativeGUID);

    if not ( relativePresenceData ) then
        presenceList.number = presenceList.number + 1;
        presenceList[presenceList.number] = {
                                                name = relativeName,
                                                guid = relativeGUID,
                                                threat = 0,
                                                tps = 0,
                                            };
        relativePresenceData = presenceList[presenceList.number];
  else
        -- Refresh name, the relative could indeed change its name in-between.
        relativePresenceData.name = relativeName or relativePresenceData.name;
    end

    -- STEP 3 - Update threat.

    if ( operation == "SET" ) then
        ownerData.threat = max(0, value or 0);
        DTM_TPS_AddToHistory(ownerData.history, ownerData.threat);
        relativePresenceData.threat = ownerData.threat;
        return;
    end
    if ( operation == "VALUE" ) then
        if ( value ) then
            ownerData.threat = max(0, ownerData.threat + value);
        end  
        if ( valueCoeff ) then
            ownerData.threat = ownerData.threat * valueCoeff;
        end
        DTM_TPS_AddToHistory(ownerData.history, ownerData.threat);
        relativePresenceData.threat = ownerData.threat;
        return;
    end
    if ( operation == "DROP" ) then
        DTM_ThreatList_DeleteByGUID(threatList, ownerGUID);
        DTM_ThreatList_DeleteByGUID(presenceList, relativeGUID);
        DTM_Trace("THREAT_EVENT", "[%s] is dropped from [%s] threat list.", 1, ownerName or '?', relativeName or '?');
        return;
    end
    if ( operation == "TAUNT" ) then
        local relativePtr = DTM_GetUnitPointer(relativeGUID);
        local relativeTargetPtr = nil;
        local relativeTargetName = relativeData.aggroName;
        local relativeTargetGUID = relativeData.aggroGUID;

        if ( value ) then
            -- We have the "value" argument given, so the function knows specifically who the owner is taunting relative off.
            relativeTargetPtr = DTM_GetUnitPointer(value);
            if ( relativeTargetPtr ) then
                relativeTargetName = UnitName(relativeTargetPtr) or relativeTargetName;
                relativeTargetGUID = UnitGUID(relativeTargetPtr) or relativeTargetGUID;
            end
      else
            -- Try to get who the mob is targetting.
            if ( relativePtr ) then
                relativeTargetPtr = relativePtr.."target";
                if ( UnitCanAttack(relativePtr, relativeTargetPtr) ) then
                    relativeTargetName = UnitName(relativeTargetPtr) or relativeTargetName;
                    relativeTargetGUID = UnitGUID(relativeTargetPtr) or relativeTargetGUID;
                end
            end
        end

        -- We can make additionnal checks if we have a pointer to the unit who gets its ass saved.
        if ( relativePtr ) and ( relativeTargetPtr ) and ( UnitExists( relativeTargetPtr ) ) then
            local invalid = nil;

            -- We can't pull a non-hostile unit from an entity with taunt.
            if not ( UnitCanAttack(relativePtr, relativeTargetPtr) ) then invalid = 1; end

            -- We can't pull something off a dead unit.
            if ( UnitIsDeadOrGhost(relativePtr) ) then invalid = 1; end

            if ( invalid ) then
                relativeTargetName = nil;
                relativeTargetGUID = nil;
            end
        end

        -- OK, set owner's threat to be as high as the guy we taunted the entity off.
        if ( relativeTargetGUID ) then
            local relativeTargetData = DTM_ThreatList_GetEntity(threatList, relativeTargetGUID);
            if ( relativeTargetData ) then
                ownerData.threat = max(ownerData.threat, relativeTargetData.threat);
                relativePresenceData.threat = ownerData.threat;
                DTM_TPS_AddToHistory(ownerData.history, ownerData.threat);
                DTM_Trace("THREAT_EVENT", "[%s] is taunting [%s] off [%s].", 1, ownerName or '?', relativeName or '?', relativeTargetName or '?');
            end
        end
        return;
    end
end

-- ********************************************************************
-- * DTM_ThreatList_Delete(threatList, index)                         *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> threatList: the threat list to work with.                     *
-- * >> index: index of the entity to delete from the threat list.    *
-- ********************************************************************
-- * Delete the specified entity from the given threat list by index. *
-- ********************************************************************
function DTM_ThreatList_Delete(threatList, index)
    local i;
    threatList.number = threatList.number - 1;
    for i=index, threatList.number do
        threatList[i] = threatList[i+1];
        threatList[i+1] = nil;
    end
end

-- ********************************************************************
-- * DTM_ThreatList_DeleteByGUID(threatList, guid)                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> threatList: the threat list to work with.                     *
-- * >> guid: GUID of the entity in the threat list to delete.        *
-- ********************************************************************
-- * Delete the specified entity from the given threat list by GUID.  *
-- ********************************************************************
function DTM_ThreatList_DeleteByGUID(threatList, guid)
    local i;
    for i=threatList.number, 1, -1 do
        if ( threatList[i].guid == guid ) then
            DTM_ThreatList_Delete(threatList, i);
        end
    end
end

-- ********************************************************************
-- * DTM_ThreatList_Reset(threatList)                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> threatList: the threat list to reset.                         *
-- ********************************************************************
-- * Reset the specified threat list.                                 *
-- ********************************************************************
function DTM_ThreatList_Reset(threatList)
    threatList = {
        number = 0,
    };
end

-- ********************************************************************
-- * DTM_ThreatList_Sort(threatList)                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> threatList: the threat list to sort.                          *
-- ********************************************************************
-- * Sorts a threat list in increasing order.                         *
-- ********************************************************************
function DTM_ThreatList_Sort(threatList)
    if not ( threatList ) then return; end
    if not ( threatList.number > 0 ) then return; end

    local i, ii, redo, count, tmp;
    i = 0;
    redo = nil;
    count = 0;

    repeat
        count = count + 1;
        if not ( redo ) then
            i = i + 1;
        end
        redo = nil;

        for ii = i+1, threatList.number do
            if ( threatList[i].threat < threatList[ii].threat ) then
                tmp = threatList[i];
                threatList[i] = threatList[ii];
                threatList[ii] = tmp;

                redo = 1;
                break;
            end
        end
    until ( i >= threatList.number ) or ( count > 50 );
end