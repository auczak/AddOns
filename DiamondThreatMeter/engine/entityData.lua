local activeModule = "Engine entity data";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_EntityData_Get(guid, writeMode)                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of the entity whose data we'd like to acquire. *
-- * >> writeMode: if set, if data about this entity is not available,*
-- * create a new table (=> if set, ensure the function will return   *
-- * a table and not nil)                                             *
-- ********************************************************************
-- * Grab the entity data of an entity based on its GUID.             *
-- * If no entity data is found, a basic and empty table is created   *
-- * and returned for this GUID, provided writeMode is set.           *
-- * If an empty table was created, the second return value is 1.     *
-- * Elsewise it is nil.                                              *
-- ********************************************************************
function DTM_EntityData_Get(guid, writeMode)
    if not ( guid ) or ( guid == "number" ) then return nil, nil; end -- Illegal.

    local data = DTM_Entity[guid];

    if ( data ) then
        if ( writeMode ) then
            data.lastUpdate = GetTime();
        end
        return data, nil;

elseif ( writeMode ) then
        -- If no data, we create a basic entry, if writeMode is set.

        DTM_Entity.number = DTM_Entity.number + 1;
        DTM_Entity[guid] = {
            guid = guid,
            threatList = {
                number = 0,
                aggroName = nil,
                aggroGUID = nil,
            },
            presenceList = { -- The presence list is like the invert of threat list: it lists all entities that have you on their threat list.
                number = 0,  -- The threat list APIs work on it, but you must interpret what you do with it differently.
            },
            crowdControl = { -- The list of crowd control currently active on the unit. The entries in this table are indexed with the CC's name and its value
            },               -- is the expected time remaining.
            lastUpdate = GetTime(),
        };
        return DTM_Entity[guid], 1;
    end

    return nil, nil;
end

-- ********************************************************************
-- * DTM_EntityData_PickUpAndDo(func, ...)                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> func: the function to call. Name, GUID, threat list and       *
-- * presence list of the picked up entity will be passed to it.      *
-- * >> ... : additionnal parameters to pass to func.                 *
-- ********************************************************************
-- * Pick up every entity, and execute a given function, passing      *
-- * entity's name, GUID, threat/presence tables to it as arguments.  *
-- ********************************************************************
function DTM_EntityData_PickUpAndDo(func, ...)
    local k, data;
    for k, data in pairs(DTM_Entity) do
    if ( k ~= "number" ) then
        func(data.name, data.guid, data.threatList, data.presenceList, ...);
    end
    end
end

-- ********************************************************************
-- * DTM_EntityData_PickUpTableAndDo(func, ...)                       *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> func: the function to call. Data of the pickup entity will    *
-- * be passed to it.                                                 *
-- * >> ... : additionnal parameters to pass to func.                 *
-- ********************************************************************
-- * Same as PickUpAndDo, but pass the entity data table instead      *
-- * of only some of its fields.                                      *
-- ********************************************************************
function DTM_EntityData_PickUpTableAndDo(func, ...)
    local k, data;
    for k, data in pairs(DTM_Entity) do
    if ( k ~= "number" ) then
        func(data, ...);
    end
    end
end

-- ********************************************************************
-- * DTM_EntityData_Delete(guid)                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: GUID of the entity in the entity table to delete.       *
-- ********************************************************************
-- * Delete the entity data of an entity based on its GUID.           *
-- * Calling this will cause events tied to the entity to be          *
-- * also removed. Will also remove pending combat events affecting   *
-- * this unit.                                                       *
-- ********************************************************************
function DTM_EntityData_Delete(guid)
    if not ( guid ) or ( guid == "number" ) then return; end -- Illegal.

    -- First remove all kinds of timed events about this GUID.
    DTM_Time_DeleteEntityDataByGUID(guid);
    DTM_CombatEvents_Remove(nil, guid, nil);
    DTM_CombatEvents_Remove(nil, nil, guid);

    local i, threatList, presenceList;

    -- Remove all instances of this entity on presence/threat lists.
    DTM_EntityData_PickUpAndDo( function(name, guid, threatList, presenceList, myGUID)
                                    DTM_ThreatList_DeleteByGUID(presenceList, myGUID);
                                    DTM_ThreatList_DeleteByGUID(threatList, myGUID);
                                end , guid );

    -- Check there is indeed entity data to remove.
    if not ( DTM_Entity[guid] ) then
        return;
    end

    DTM_Trace("MAINTENANCE", "Removing [%s] threat data.", 1, DTM_Entity[guid].name or "<?>");

    DTM_Entity.number = DTM_Entity.number - 1;
    DTM_Entity[guid] = nil;
end

-- ********************************************************************
-- * DTM_EntityData_DeleteByGUID(guid)                 - DEPRECATED - *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: GUID of the entity in the entity table to delete.       *
-- ********************************************************************
-- * Delete the entity data of an entity based on its GUID.           *
-- * Due to the changes performed on entityData management, this      *
-- * function is just a mirror to the Delete one.                     *
-- ********************************************************************
function DTM_EntityData_DeleteByGUID(guid)
    DTM_EntityData_Delete(guid);
end

-- ********************************************************************
-- * DTM_EntityData_Reset(noFeedback)                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> noFeedback: set this parameter to prevent a message notifying *
-- * threat data has been reset from popping up.                      *
-- ********************************************************************
-- * Perform a reset of current entities data. All threat lists will  *
-- * be erased upon calling this function.                            *
-- ********************************************************************
function DTM_EntityData_Reset(noFeedback)
    DTM_Entity = {
        number = 0,
    };
    DTM_ZoneWide_CancelRaidCombatCheck(); -- Prevent "contamination" if we are in the middle of a combat check process.

    if ( not noFeedback ) then
        DTM_ChatMessage(DTM_Localise("ResetEntityData"), 1);
    end
end

-- ********************************************************************
-- * DTM_EntityData_HandleFlagChange(unitName, guid, flag, value)     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unitName: the name of the guy who issued the flag change.     *
-- * >> guid: the guid of the guy who issued the flag change.         *
-- * >> flag: the flag affected.                                      *
-- * >> value: the new value of the flag.                             *
-- ********************************************************************
-- * Gets called when an ability/yell causes a NPC to change one of   *
-- * its special threat flags, such as noThreatList, warningOveride   *
-- * etc. which could be useful to GUIs.                              *
-- ********************************************************************
function DTM_EntityData_HandleFlagChange(unitName, guid, flag, value)
    local entityData = DTM_EntityData_Get(guid, 1);
    entityData.name = entityData.name or unitName;

    DTM_Trace("THREAT_EVENT", "[%s] changed its [%s] threat list flag.", 1, unitName, flag);

    if ( flag == "NO_THREAT_LIST" ) then
        entityData.noThreatList = value;
elseif ( flag == "WARNING_OVERIDE" ) then
        entityData.warningOveride = value;
elseif ( flag == "AGGRO_DELAY" ) then
        entityData.aggroDelay = value;
elseif ( flag == "AGGRO_DISTANCE" ) then
        entityData.aggroDistance = value;
    end

    -- Notifies those who have registered for such an event.

    for i=1, DTM_ThreatFlagsCallback.number do
        DTM_ThreatFlagsCallback[i](unitName, guid, flag);
    end
end