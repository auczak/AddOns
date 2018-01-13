local activeModule = "Engine time";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local EMPTY_LIST = {
    number = 0,
};

local lookupData = {};

-- --------------------------------------------------------------------
-- **                    Time-dependant functions                    **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Engine_TimeElapsed(elapsed)        - High error protection - *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> elapsed: how much time passed since last call.                *
-- ********************************************************************
-- * Warns the engine X amount of time elapsed.                       *
-- ********************************************************************
function DTM_Engine_TimeElapsed(elapsed)
    -- Version processing.
    DTM_ProtectedCall(DTM_Version_OnUpdate, "MAJOR", elapsed);

    if not ( DTM_IsEngineRunning() == 1 ) then
        return;
    end

    -- Periodic talent/gear/... updates
    DTM_ProtectedCall(DTM_Self_Update, "MAJOR");
    DTM_ProtectedCall(DTM_Party_Update, "MAJOR");

    -- Check target of target aggro
    -- DTM_CheckTargetOfUnitChange("target");
    -- DTM_CheckTargetOfUnitChange("focus");

    -- Update the general combat events.
    DTM_ProtectedCall(DTM_CombatEvents_Update, "CRITICAL", elapsed);

    -- Update the time events.
    DTM_ProtectedCall(DTM_Time_Update, "CRITICAL", elapsed);

    -- Update the self spellcasts events.
    DTM_ProtectedCall(DTM_SelfAbility_Update, "MAJOR", elapsed);

    -- Emulation stuff.
    DTM_ProtectedCall(DTM_Emulation_OnUpdate, "MAJOR", elapsed);

    -- Inspect access update
    DTM_ProtectedCall(DTM_Access_OnUpdate, "MAJOR", elapsed);

    -- Remove outdated entities
    DTM_ProtectedCall(DTM_Maintenance_ClearOutdated, "MINOR");

    -- Handle the zonewide services
    DTM_ProtectedCall(DTM_ZoneWide_OnUpdate, "MINOR", elapsed);

    -- The crowd control monitor
    DTM_ProtectedCall(DTM_CrowdControl_OnUpdate, "MINOR", elapsed);

    -- The TPS calculator
    DTM_ProtectedCall(DTM_TPS_Update, "MAJOR", elapsed);
end

-- --------------------------------------------------------------------
-- **                   List management functions                    **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Time_GetEntityData(guid)                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of the entity whose data we'd like to acquire. *
-- ********************************************************************
-- * Grab time related events the given entity is involved with,      *
-- * via its GUID. If not time data is found, nil is returned.        *
-- ********************************************************************
function DTM_Time_GetEntityData(guid)
    local data;

    -- Try to use the lookup first.
    local lookupIndex = lookupData[guid];
    if ( lookupIndex ) and ( lookupIndex <= DTM_Time.number ) then
        data = DTM_Time[lookupIndex];
        if ( data ) and ( data.guid == guid ) then
            return data;
        end
    end

    -- If we reach this point, then it means we do not have the lookup pointer or it has changed meanwhile.
    local i;
    for i=1, DTM_Time.number do
        data = DTM_Time[i];
        if ( data.guid ) then
            if ( data.guid == guid ) then
                lookupData[guid] = i;
                return data;
            end
        end
    end
    return nil;
end

-- ********************************************************************
-- * DTM_Time_AddEvent(name, guid, effect, cancelTrigger,             *
-- *                   duration, ticks, operation, list,              *
-- *                   aggroName, aggroGUID)                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the entity affected by event. (Omittable)   *
-- * >> guid: the GUID of the entity affected by event.               *
-- * >> effect: the effect internal name linked to the event.         *
-- * >> cancelTrigger: if set, the event will fire if effect cancels. *
-- * >> duration: duration of the event. Periodic stuff will have its *
-- * effect split evenly between the given number of ticks.           *
-- * For temporary/other events, that is the delay before the event   *
-- * fires or backfires (in case of temporary ones).                  *
-- * >> ticks: for periodic events, the "portion number" the event    *
-- * will be divided in.                                              *
-- * >> operation: the threat operation to perform in the event.      *
-- * >> list: the entities that will have their threat list modified  *
-- * by the threat operation. For value modifying threat events, a    *
-- * value field must be present for each entity that will have its   *
-- * threat list modified. A GUID field for each entity must be of    *
-- * course there; a name field is optionnal but recommanded.         *
-- * list argument can be nil for some threat operations.             *
-- * >> aggroName, aggroGUID: these parameters are only to be provided*
-- * when operation is CONFIRM_AGGRO, DEFENSIVE_AGGRO or REFLECT.     *
-- * It points to who gets aggro or who has a NPC taunted off of him  *
-- * or, in case of REFLECT, who is to be credited for the reflect's  *
-- * threat.                                                          *
-- ********************************************************************
-- * Adds a threat event about a given unit with specified GUID.      *
-- * operation can be one of the following:                           *
-- * - DROP remove the owner from threat list of all entities in list.*
-- * - MULTIPLY_THREAT: threat level is modified by a value           *
-- * which is a % of threat level at the beginning of the event, over *
-- * the given duration and a given number of ticks.                  *
-- * - ADDITIVE_THREAT: threat level is modified by a value           *
-- * (though not going below 0 minimum), over the given duration and  *
-- * a given number of ticks.                                         *
-- * - REDIRECTION: this event, while active, will be taken in account*
-- * in the combat event handler: a % of threat will be redirected    *
-- * from the guy who has this event enabled on his ass to each entity*
-- * in the list. The event itself does not generate any threat and   *
-- * has no tick/trigger effect.                                      *
-- * - CONFIRM_AGGRO: this event sets the current aggro of entity     *
-- * affected to a new aggro target given by aggroName and aggroGUID  *
-- * extra parameters.                                                *
-- * - DEFENSIVE_TAUNT: Any <effect> debuff occuring while this event *
-- * is running will cause the unit getting it to be taunted off the  *
-- * <aggroGUID> unit and go toward <guid> unit.                      *
-- * - EFFECT_CACHE: if the engine wants to know if an unit has a     *
-- * given effect active on it, it'll say yes at once if it sees the  *
-- * unit has an EFFECT_CACHE event tied to this effect.              *
-- * - REFLECT: <aggroGUID> has reflected toward <guid> a spell whose *
-- * id is stored into the <effect> parameter. The event itself does  *
-- * not generate any threat and has no tick/trigger effect.          *
-- ********************************************************************
function DTM_Time_AddEvent(name, guid, effect, cancelTrigger, duration, ticks, operation, list, aggroName, aggroGUID)
    local entityData = DTM_Time_GetEntityData(guid);
    if not ( entityData ) then
        DTM_Time.number = DTM_Time.number + 1;
        DTM_Time[DTM_Time.number] = {
            name = name,
            guid = guid,
            events = {
                number = 0,
            }
        };
        entityData = DTM_Time[DTM_Time.number];
    end

    local listEntityData, listThreatList, threatData;
    local currentThreat, endThreat;
    local totalValue, tickValue;
    local tickDuration = duration / (ticks or 1);
    local threatOperation = operation;

    -- Work out the list.
    if not ( list ) then
        list = EMPTY_LIST;
    end
    for i=1, list.number do
        if ( operation == "MULTIPLY_THREAT" ) then
            listEntityData = DTM_EntityData_Get(list[i].guid, 1);
            listEntityData.name = listEntityData.name or list[i].name;
            listThreatList = listEntityData.threatList;
            threatData = DTM_ThreatList_GetEntity(listThreatList, guid);
            if ( threatData ) then
                currentThreat = threatData.threat or 0;
          else
                currentThreat = 0;
            end

            threatOperation = "VALUE";
            endThreat = currentThreat * list[i].value;
            totalValue = endThreat - currentThreat;
            tickValue = totalValue / (ticks or 1);
            list[i].value = tickValue;

    elseif ( operation == "ADDITIVE_THREAT" ) then
            threatOperation = "VALUE";
            totalValue = list[i].value;
            tickValue = totalValue / (ticks or 1);
            list[i].value = tickValue;
        end
    end

    local entityEvents = entityData.events;
    entityEvents.number = entityEvents.number + 1;
    entityEvents[entityEvents.number] = {
        effect = effect,
        cancelTrigger = cancelTrigger,
        nextTick = tickDuration,
        tickDuration = tickDuration,
        remainingTicks = (ticks or 1),
        operation = threatOperation,
        targets = list,
        aggroName = aggroName,
        aggroGUID = aggroGUID,
    };
end

-- ********************************************************************
-- * DTM_Time_DeleteEntityData(index)                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> index: index in the time list to delete.                      *
-- ********************************************************************
-- * Delete time related events at the specified index.               *
-- ********************************************************************
function DTM_Time_DeleteEntityData(index)
    local i;
    DTM_Time.number = DTM_Time.number - 1;
    for i=index, DTM_Time.number do
        DTM_Time[i] = DTM_Time[i+1];
        DTM_Time[i+1] = nil;
    end
end

-- ********************************************************************
-- * DTM_Time_DeleteEntityDataByGUID(guid)                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: GUID of the entity we wish to remove.                   *
-- ********************************************************************
-- * Delete time related events of a given entity with given GUID.    *
-- ********************************************************************
function DTM_Time_DeleteEntityDataByGUID(guid)
    local i;
    for i=DTM_Time.number, 1, -1 do
        if ( DTM_Time[i].guid == guid ) then
            DTM_Time_DeleteEntityData(i);
        end
    end
end

-- ********************************************************************
-- * DTM_Time_DeleteEntityEvent(entityTimeData, index)                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> entityTimeData: the event table to work with.                 *
-- * >> index: index of the event to delete.                          *
-- ********************************************************************
-- * Delete an event in the given event table.                        *
-- ********************************************************************
function DTM_Time_DeleteEntityEvent(entityTimeData, index)
    local i;
    entityTimeData.number = entityTimeData.number - 1;
    for i=index, entityTimeData.number do
        entityTimeData[i] = entityTimeData[i+1];
        entityTimeData[i+1] = nil;
    end
end

-- --------------------------------------------------------------------
-- **                     Application functions                      **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Time_Update(elapsed)                                         *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> elapsed: how much time passed since last call.                *
-- ********************************************************************
-- * Update the events related to time.                               *
-- ********************************************************************
function DTM_Time_Update(elapsed)
    local i, ii;
    local entityData, entityEvents, eventData;

    for i=DTM_Time.number, 1, -1 do
        entityData = DTM_Time[i];
        entityEvents = entityData.events;

        for ii=entityEvents.number, 1, -1 do
            eventData = entityEvents[ii];

            eventData.nextTick = eventData.nextTick - elapsed;
            if ( eventData.nextTick <= 0.000 ) then
                eventData.nextTick = eventData.nextTick + eventData.tickDuration;
                eventData.remainingTicks = eventData.remainingTicks - 1;

                -- Fire the event's effect.
                DTM_Time_ApplyEvent(entityData.name, entityData.guid, eventData);

                if ( eventData.remainingTicks <= 0 ) then
                    DTM_Time_DeleteEntityEvent(entityEvents, ii);
                end
            end
        end     
    end
end

-- ********************************************************************
-- * DTM_Time_EffectLost(name, guid, effect)                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the entity who lost the effect.             *
-- * >> guid: the GUID of the entity who lost the effect.             *
-- * >> effect: the effect internal name.                             *
-- ********************************************************************
-- * Fired when an entity loses an effect. We'll search in the entity *
-- * time event table for events tied to that effect, delete them,    *
-- * and, if their trigger flag is set, apply them once.              *
-- * Also remove the effect from the entity's effect cache.           *
-- ********************************************************************
function DTM_Time_EffectLost(name, guid, effect)
    local i;
    local entityData, entityEvents, eventData;
    entityData = DTM_Time_GetEntityData(guid);

    if ( entityData ) then
        entityEvents = entityData.events;

        for i=entityEvents.number, 1, -1 do
            eventData = entityEvents[i];

            if ( eventData.effect == effect ) then
                if ( eventData.cancelTrigger ) then
                    DTM_Time_ApplyEvent(name, guid, eventData);
                end

                DTM_Time_DeleteEntityEvent(entityEvents, i);
            end
        end     
    end
end

-- ********************************************************************
-- * DTM_Time_EffectGain(name, guid, effect)                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the entity who gained the effect.           *
-- * >> guid: the GUID of the entity who gained the effect.           *
-- * >> effect: the effect internal name.                             *
-- ********************************************************************
-- * Fired when an entity gains an effect. This will allow us to      *
-- * memorize effects with ambigous name. The only known situation    *
-- * this feature should be used is against Kalecdos threat modifying *
-- * debuff called Wild Magic. But! There are multiple versions of    *
-- * this debuff, which share the same name but do not cause a threat *
-- * modification.                                                    *
-- ********************************************************************
function DTM_Time_EffectGain(name, guid, effect)
    local effectClass, effectAlwaysActive, effectEffect = DTM_Effects_GetData(effect);
    if ( effectEffect ) then
        if ( effectEffect.cache ) and ( effectEffect.duration ) then
            DTM_Time_AddEvent(name, guid, effect, nil, effectEffect.duration, nil, "EFFECT_CACHE", nil);
            DTM_Trace("THREAT_EVENT", "[%s] effect has been cached on [%s] for %d sec.", 1, effect, name, effectEffect.duration);
        end
    end
end

-- ********************************************************************
-- * DTM_ApplyEvent(ownerName, ownerGUID, eventData)                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> ownerName: the name of the guy who will be affected on TLists.*
-- * >> ownerGUID: the GUID of the guy who will be affected on TLists.*
-- * >> eventData: the data of the event.                             *
-- ********************************************************************
-- * Fires a threat modifying event effect.                           *
-- ********************************************************************
function DTM_Time_ApplyEvent(ownerName, ownerGUID, eventData)
    local eventOperation = eventData.operation;
    local eventRelativeList = eventData.targets;

    if ( eventOperation == "DROP" ) then
        for i=1, eventRelativeList.number do
            DTM_ThreatList_Modify(eventRelativeList[i].name, eventRelativeList[i].guid, ownerName, ownerGUID, "DROP", nil, nil);
        end
elseif ( eventOperation == "VALUE" ) then
        for i=1, eventRelativeList.number do
            DTM_ThreatList_Modify(eventRelativeList[i].name, eventRelativeList[i].guid, ownerName, ownerGUID, "VALUE", eventRelativeList[i].value, nil);
        end
elseif ( eventOperation == "REDIRECTION" ) then
        -- Does nothing, this is a passive effect used by the general combat parser.

elseif ( eventOperation == "CONFIRM_AGGRO" ) then
        -- We confirm the mob has chosen a new aggro target.
        DTM_Aggro_Set(ownerName, ownerGUID, eventData.aggroName, eventData.aggroGUID);

elseif ( eventOperation == "DEFENSIVE_TAUNT" ) then
        -- Does nothing, this is a passive effect used by the general combat parser.

elseif ( eventOperation == "EFFECT_CACHE" ) then
        -- Does nothing by itself, it's used to distinguish between effects sharing the same name.

elseif ( eventOperation == "REFLECT" ) then
        -- Does nothing, this is a passive effect used by the general combat parser.
    end
end

-- ********************************************************************
-- * DTM_Time_GetRedirectionData(guid)                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of the entity who is going to have its threat  *
-- * redirected.                                                      *
-- ********************************************************************
-- * Check if there is an active REDIRECTION event on given unit.     *
-- * Nil if not. Otherwise, the redirection effect internal name and  *
-- * the list of entities the threat is redirected to is returned.    *
-- ********************************************************************
function DTM_Time_GetRedirectionData(guid)
    local entityData = DTM_Time_GetEntityData(guid);

    if ( entityData ) then
        local entityEvents = entityData.events;
        local eventData;

        for i=1, entityEvents.number do
            eventData = entityEvents[i];

            if ( eventData.operation == "REDIRECTION" ) then
                return eventData.effect, eventData.targets;
            end
        end
    end

    return nil, nil;
end

-- ********************************************************************
-- * DTM_Time_GetDefensiveTauntData(name)                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the internal name of the defensive taunt debuff to get  *
-- * data about.                                                      *
-- ********************************************************************
-- * Check if there is an active DEFENSIVE_TAUNT event going on that  *
-- * is named internally <name>. If so, return the name and GUID of   *
-- * the guy who issued the taunt event and the name and GUID of the  *
-- * guy who benefits the defensive taunt.                            *
-- ********************************************************************
function DTM_Time_GetDefensiveTauntData(name)
    local i, ii;
    local entityData, entityEvents, eventData;

    for i=1, DTM_Time.number do
        entityData = DTM_Time[i];
        entityEvents = entityData.events;

        for ii=1, entityEvents.number do
            eventData = entityEvents[ii];

            if ( eventData.operation == "DEFENSIVE_TAUNT" ) then
                return entityData.name, entityData.guid, eventData.aggroName, eventData.aggroGUID;
            end
        end
    end

    return nil, nil, nil, nil;
end

-- ********************************************************************
-- * DTM_Time_GetEffectCacheData(guid, effect)                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of the guy who is checked.                     *
-- * >> effect: the internal name of the effect to get data for.      *
-- ********************************************************************
-- * This allows you to check if an effect that is flagged as cached  *
-- * (its "cache" field is set in effects.lua database file)          *
-- * is active on a given entity.                                     *
-- * If so, returns the time amount left. If not, return nil.         *
-- ********************************************************************
function DTM_Time_GetEffectCacheData(guid, effect)
    local i;
    local entityData = DTM_Time_GetEntityData(guid);

    if ( entityData ) then
        local entityEvents, eventData;
        entityEvents = entityData.events;

        for i=1, entityEvents.number do
            eventData = entityEvents[i];

            if ( eventData.effect == effect ) and ( eventData.operation == "EFFECT_CACHE" ) then
                return eventData.tickDuration;
            end
        end
    end

    return nil;
end

-- ********************************************************************
-- * DTM_Time_GetReflecterInfo(guid, id, remove)                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of the guy who ate his spell in the face.      *
-- * >> id: the ID of the ability that got reflected.                 *
-- * >> remove: remove reflect data after reading them ?              *
-- ********************************************************************
-- * Determinates who reflected a spell onto someone.                 *
-- * Returns name, guid of the reflecter or nil, nil if not found.    *
-- ********************************************************************
function DTM_Time_GetReflecterInfo(guid, id, remove)
    local i;
    local entityData = DTM_Time_GetEntityData(guid);

    if ( entityData ) and ( id ) then
        local entityEvents, eventData;
        entityEvents = entityData.events;

        for i=entityEvents.number, 1, -1 do
            eventData = entityEvents[i];

            if ( eventData.effect == id ) and ( eventData.operation == "REFLECT" ) then
                local name, guid = eventData.aggroName, eventData.aggroGUID;
                if ( remove ) then
                    DTM_Time_DeleteEntityEvent(entityEvents, i);
                end
                return name, guid;
            end
        end
    end

    return nil, nil;
end

-- ********************************************************************
-- * DTM_Time_RemoveFromList(ownerGUID, effect, relativeGUID)         *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> ownerGUID: the GUID of the guy whose events are queried.      *
-- * >> effect: effect internal name which is going to be searched.   *
-- * >> relativeGUID: the GUID of the guy to remove from all events   *
-- * matching <effect> as linked event 's list.                       *
-- ********************************************************************
-- * Explore the event list of <ownerGUID> guy. Pick up all its       *
-- * events that are linked to <effect> effect. Remove from the picked*
-- * events' targets list all guys that have <relativeGUID> as GUID.  *
-- ********************************************************************
function DTM_Time_RemoveFromList(ownerGUID, effect, relativeGUID)
    local entityData = DTM_Time_GetEntityData(ownerGUID);
    local i, ii, iii;

    if ( entityData ) then
        local entityEvents = entityData.events;
        local eventData, list;

        for i=1, entityEvents.number do
            eventData = entityEvents[i];

            if ( eventData.effect == effect ) then
                list = eventData.targets;
                
                for ii=list.number, 1, -1 do
                    if ( list[ii].guid == relativeGUID ) then
                        list.number = list.number - 1;
                        for iii=ii, list.number do
                            list[iii] = list[iii+1];
                            list[iii+1] = nil;
                        end
                    end
                end
            end
        end
    end
end