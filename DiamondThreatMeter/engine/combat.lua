local activeModule = "Engine combat";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local CHECK_TRUSTABLE = 1;
local workTable = {};

local EVENT_VALIDATION_TIME = 0.100; -- That is the time Resist/Parry/Dodge/Miss etc. messages will have to show up before a missable combat event
                                     -- is considered successful.

local IGNORE_ASSOCIATION_ERRORS = 1; -- Comment this out for debug or development builds.

local RECENT_DEATH_THRESHOLD = 2.000; -- The delay during which an unit who has died is considered recently dead.

local REFLECT_MAX_WAIT_TIME = 3.000; -- The max time a reflected spell has to hit before dropping the reflect event.

-- --------------------------------------------------------------------
-- **                     Combat Feedback Handlers                   **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Combat_Event(Result)                                         *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> Result: the table sent by combat parsing system.              *
-- ********************************************************************
-- * Gets called for each stuff occuring in combat.                   *
-- * This function is used as a bridge to use DTM error handler.      *
-- ********************************************************************
function DTM_Combat_Event(Result)
    DTM_ProtectedCall(DTM_Combat_EventSafe, "MAJOR", Result);
end

-- ********************************************************************
-- * DTM_Combat_EventSafe(Result)                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> Result: the table sent by combat parsing system.              *
-- ********************************************************************
-- * Gets called for each stuff occuring in combat.                   *
-- ********************************************************************
function DTM_Combat_EventSafe(Result)
    if not ( DTM_IsEngineRunning() == 1 ) then
        return;
    end

    local outcome = Result.Outcome;
    local actClass = Result.Class;

    -- 0 - Get raid symbols that are active on both actor and target.

    if ( Result.Actor ) and ( Result.Actor.GUID ) and ( Result.Actor.Flags ) then
        DTM_SymbolsBuffer_Grab(Result.Actor.GUID, Result.Actor.Flags);
    end
    if ( Result.Target ) and ( Result.Target.GUID ) and ( Result.Target.Flags ) then
        DTM_SymbolsBuffer_Grab(Result.Target.GUID, Result.Target.Flags);
    end

    -- A - Ignore unuseable outcomes and redirects Effect_*, Death and Miss outcomes.

    if ( strsub(outcome, 1, 6) == "EFFECT" ) then
        DTM_Combat_EffectEvent(Result);
        return;
    end
    if ( outcome == "DEATH" ) or ( outcome == "DESTROYED" ) then
        DTM_Combat_DeathEvent(Result);
        return;
    end
    if ( outcome == "MISS" ) then
        if ( Result.Special == "ABSORB" ) then
            -- Absorbing an attack is equivalent to attacking and doing 0 damage.
            outcome = "DAMAGE";
      else
            DTM_Combat_MissEvent(Result);
            return;
        end
    end
    if ( outcome ~= "DAMAGE" and outcome ~= "LEECH" and outcome ~= "HEAL" ) then
        if ( outcome ~= "CAST_SUCCESS" ) then
            return;
        end
    end
    if ( actClass == "ENVIRONMENT" ) or ( actClass == "DAMAGESPLIT" ) then
        -- Such acts would cause to give threat to actions that affect self or friendly units.
        -- We drop them.
        return;
    end

    -- B - Determinate the ability and its effect.

    local ability;
    local abilityRank;
    local defaultAbility = "DEFAULT";
    if ( outcome == "CAST_SUCCESS" ) then defaultAbility = "DEFAULT_NOAMOUNT"; end
    if ( outcome == "DAMAGE" ) and ( actClass == "MELEE" ) then defaultAbility = "AUTOATTACK"; end
    if ( outcome == "HEAL" ) then defaultAbility = "DEFAULT_HEAL"; end

    local sourceFlags = Result.Actor.Flags;
    local sourceIsPlayer = bit.band( sourceFlags , COMBATLOG_OBJECT_TYPE_PLAYER ) > 0;
    local sourceIsNPC = bit.band( sourceFlags , COMBATLOG_OBJECT_TYPE_NPC ) > 0;
    local sourceIsPet = ( bit.band( sourceFlags , COMBATLOG_OBJECT_TYPE_PET ) > 0 ) or ( bit.band( sourceFlags , COMBATLOG_OBJECT_TYPE_GUARDIAN ) > 0 );
    local npcAbility = nil;

    -- Drop non-player, non-npc, non-pet/guardian sources.
    if not ( sourceIsPlayer or sourceIsNPC or sourceIsPet ) then
        return;
    end

    -- If someone hits someone else in melee with a standard hit, we consider "someone" has aggro on "someone else".
    if ( actClass == "MELEE" ) or ( actClass == "RANGED" ) then   -- We also extend this rule for ranged attacks.
        DTM_UnitHasLandedMeleeHit(Result.Actor.Name, Result.Actor.GUID, Result.Target.Name, Result.Target.GUID);
    end

    if ( actClass == "ABILITY" ) then
        local abilityLocalised = Result.Ability.Name;
        if ( sourceIsPlayer ) or ( sourceIsPet ) then
            ability = DTM_GetInternalBySpellId(Result.Ability.Id);
            ability = ability or DTM_GetInternal("abilities", abilityLocalised, IGNORE_ASSOCIATION_ERRORS);
        end
        if ( sourceIsNPC ) and ( abilityLocalised ) then
            ability = abilityLocalised; -- That is a special case handled a bit below. NPCs abilities have no internal representation.
            npcAbility = 1;
        end

        abilityRank = select(2, GetSpellInfo(Result.Ability.Id));
        abilityRank = DTM_GetRankFromString(abilityRank); -- Need to translate that into a number.

        if ( Result.Actor.Name == UnitName("player") ) then
            DTM_Trace("COMBAT_EVENT_SELF", "Combat related event about you fired !\nAbility: %s, #%d, rank %s", 1, Result.Ability.Name or '', Result.Ability.Id or 0, abilityRank or "none");
      else
            DTM_Trace("COMBAT_EVENT_OTHER", "Combat related event about [%s] fired !\nAbility: %s, #%d, rank %s", 1, Result.Actor.Name, Result.Ability.Name or '', Result.Ability.Id or 0, abilityRank or "none");
        end
    end
    if ( sourceIsPet ) then
        -- Pets use a different ability set.
        -- This is needed to avoid using Druid's growl ability instead of Pet one.
        if ( ability ) then
            ability = "PET_"..ability;
        end
        defaultAbility = "PET_"..defaultAbility;
    end

    if ( npcAbility ) then
        npcData = DTM_GetNPCAbilityData( Result.Actor.Name );
        ability, abilityEffect = DTM_GetNPCAbilityEffect(npcData, ability);
        abilityClass = "NPC";
  else
        abilityClass, abilityEffect = DTM_Abilities_GetData(ability, (outcome == "HEAL"));
    end

    if not ( abilityEffect ) then
        -- If not such an ability is defined in the abilities DB, use the default internal ability.
        abilityClass, abilityEffect = DTM_Abilities_GetData(defaultAbility);
    end

    -- It should be impossible NOT to go past this point, as there is always an internal default ability defined.
    if not ( abilityEffect ) then return; end

    -- This handler only cares for universal detection abilities.
    if ( abilityEffect.detection ) and ( abilityEffect.detection ~= "UNIVERSAL" ) then
        return;
    end

    -- For abilities that have an amount component, we don't care about their preceding "cast success" event.
    if ( abilityEffect.hasAmount ) and ( outcome == "CAST_SUCCESS" ) then
        return;
    end
    
    -- The opposite is true too.
    if not ( abilityEffect.hasAmount ) and not ( outcome == "CAST_SUCCESS" ) then
        return;
    end

    -- C - Prepare the event data.

    local eventData = {
        amount = Result.Amount,
        amountType = "NONE",
        amountTiming = "INSTANT",
        powerType = Result.PowerType,
        special = Result.Special,
        effect = abilityEffect,
        rank = abilityRank,
        sourceName = Result.Actor.Name,
        sourceGUID = Result.Actor.GUID,
        sourceFlags = sourceFlags,
        targetName = Result.Target.Name,
        targetGUID = Result.Target.GUID,
        ability = ability,
        timestamp = Result.Timestamp,

        -- This field is not needed in case of immediate application
        delay = EVENT_VALIDATION_TIME,
    };

    if ( outcome == "HEAL" ) or ( outcome == "DAMAGE" ) or ( outcome == "LEECH" ) then
        eventData.amountType = outcome;
    end
    if ( Result.Periodic ) then
        eventData.amountTiming = "OVERTIME";
    end

    -- For standard resistable taunts, we try to catch the current target of the taunt's target, as it might changes when the taunt is finally validated.
    if ( abilityEffect.type == "TAUNT" ) and ( abilityEffect.relative == "TARGET" ) and ( abilityEffect.checkMiss ) then
        local targetPtr = DTM_GetUnitPointer(Result.Target.GUID);
        if ( targetPtr ) then
            eventData.tauntOffName = UnitName(targetPtr.."target") or nil;
            eventData.tauntOffGUID = UnitGUID(targetPtr.."target") or nil;
        end
    end

    -- D - Redirect the owner of the combat event in case we have registered previously a reflect.

    if ( actClass == "ABILITY" ) then
        local reflecterName, reflecterGUID = DTM_Time_GetReflecterInfo(Result.Target.GUID, Result.Ability.Id, 1);
        if ( reflecterGUID ) then
            eventData.sourceName = reflecterName;
            eventData.sourceGUID = reflecterGUID;
            DTM_Trace("THREAT_EVENT", "[%s] selected as owner of [%s] ability against [%s].", 1, reflecterName or '?', Result.Ability.Name or '?', Result.Target.Name or '?');
        end
    end

    -- E - Submit it.

    -- DTM_Trace("COMBAT", "Universal detection of [%s] ability, fired by [%s] on [%s] !", 1, ability or defaultAbility, Result.Actor.Name or '?', Result.Target.Name or 'N/A');

    if not ( abilityEffect.checkMiss ) then
        -- No check to wait for. Apply it at once.
        DTM_CombatEvents_Apply(eventData);
  else
        DTM_CombatEvents_Add(eventData);
    end
end

-- ********************************************************************
-- * DTM_Combat_EffectEvent(Result)                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> Result: the table sent by combat parsing system.              *
-- ********************************************************************
-- * Gets called for each effect related stuff occuring in combat.    *
-- ********************************************************************
function DTM_Combat_EffectEvent(Result)
    local outcome;
    outcome = Result.Outcome;

    local sourceName = Result.Target.Name; -- We're interested in the person who gained the effect.
    local sourceGUID = Result.Target.GUID;
    local sourcePtr = DTM_GetUnitPointer(sourceGUID);

    -- STEP 0 - Ignore unuseable outcomes.

    if ( outcome == "EFFECT_RESIST" ) then
        return;
    end

    -- STEP 1 - Determinate the effect and its effect.

    local effect;
    local effectRank;

    effect = DTM_GetInternalBySpellId(Result.Ability.Id);
    effect = effect or DTM_GetInternal("effects", Result.Ability.Name, IGNORE_ASSOCIATION_ERRORS);

    effectRank = select(2, GetSpellInfo(Result.Ability.Id));
    effectRank = DTM_GetRankFromString(effectRank); -- Need to translate that into a number.

    local effectClass, effectAlwaysActive, effectEffect = DTM_Effects_GetData(effect);

    if ( sourceName == UnitName("player") ) then
        DTM_Trace("COMBAT_EVENT_SELF", "Effect related event about you fired !\nAbility: %s, #%d, rank %s", 1, Result.Ability.Name or '', Result.Ability.Id or 0, effectRank or "none");
  else
        DTM_Trace("COMBAT_EVENT_OTHER", "Effect related event about [%s] fired !\nAbility: %s, #%d, rank %s", 1, sourceName, Result.Ability.Name or '', Result.Ability.Id or 0, effectRank or "none");
    end

    -- Send a notification to the crowd control monitor.
    if ( effect ) then
        if ( outcome == "EFFECT_GAIN" or outcome == "EFFECT_GAIN_DOSE" ) then
            DTM_CrowdControl_UnitGainedEffect(sourceGUID, sourceName, effect, effectRank);
      else
            DTM_CrowdControl_UnitLostEffect(sourceGUID, sourceName, effect, effectRank);
        end
    end

    -- STEP 2 - Handle data.

    if not ( effectEffect ) then return; end

    local effectType, effectTarget, value, duration, ticks;

    effectType = effectEffect.type;
    effectTarget = effectEffect.target;
    value = effectEffect.value or 0.00;
    duration = effectEffect.duration or 0;
    ticks = effectEffect.ticks or 1;

    -- Value extraction if it is a rank table.
    -- Can also handle very special cases which require a function to compute.
    if ( type(value) == 'table' ) then
        value = value[effectRank or 1] or 0.00;
  elseif ( type(value) == 'function' ) then
        value = value(sourcePtr, effectRank or 1) or 0.00; -- Pretty cool uh.
   else
        -- Pure value. It is ok.
    end

    -- STEP 3 - Apply according to the effect type.

    -- Special handlers

    if ( effectType == "NEW_STANCE" ) and ( outcome == "EFFECT_GAIN" ) then
        -- Oh it's a stance changed effect. Catch it at once.
        DTM_StanceBuffer_StanceChanged(sourceGUID, value);
        DTM_Trace("STANCE", "[%s] changed its stance to '%s' stance (combat event).", 1, sourceName, value);
        return;
    end

    if ( effectType == "DROP" ) and ( outcome == "EFFECT_GAIN" ) then
        -- The guy who gained the effect has to be dropped from all active threat lists.
        DTM_Combat_PickUpThreatListContainingEntityAndDo(sourceGUID, nil, DTM_ThreatList_Modify, sourceName, sourceGUID, "DROP", nil, nil);
        DTM_Trace("THREAT_EVENT", "[%s] has been dropped from all threat lists by '%s' effect.", 1, sourceName, effect);
        return;
    end

    if ( effectType == "DEFENSIVE_TAUNT" ) and ( outcome == "EFFECT_GAIN" ) then
        -- The entity who gained the effect has been taunted, so it has to attack the guy who sent the effect.

        -- We can now do this thanks to DTM_Time_GetDefensiveTauntData function. :)

        local ownerName, ownerGUID, protectedName, protectedGUID = DTM_Time_GetDefensiveTauntData(effect);

        if ( ownerGUID and protectedGUID ) then
            DTM_ThreatList_Modify(sourceName, sourceGUID, ownerName, ownerGUID, "TAUNT", protectedGUID, nil);
        end

        return;
    end

    if ( effectType == "THREAT_REDIRECTION" ) and ( outcome == "EFFECT_GAIN" ) then
        -- The entity who cast the effect will have a certain % of its threat generation redirected to the effect target.
        -- < This section is no longer used. The from who/to whom issue has been resolved with self cast scripting. >
        return;
    end

    -- Handler for periodic threat level modifying effects.

    if ( effectType == "PERIODIC_THREAT_MULTIPLY" or effectType == "PERIODIC_THREAT_ADDITIVE" ) and ( effectTarget == "THREAT_LEVEL" ) then
        if ( outcome == "EFFECT_GAIN" or outcome == "EFFECT_GAIN_DOSE" ) then
            local operation;
            local buildListFunc = function(name, guid, list, value)
                                      list.number = list.number + 1;
                                      list[list.number] = {
                                          name = name,
                                          guid = guid,
                                          value = value,
                                      };
                                  end;
            local list = {
                             number = 0,
                         };

            DTM_Combat_PickUpThreatListContainingEntityAndDo(sourceGUID, nil, buildListFunc, list, value);

            if ( effectType == "PERIODIC_THREAT_MULTIPLY" ) then
                operation = "MULTIPLY_THREAT";
          else
                operation = "ADDITIVE_THREAT";
            end
            DTM_Time_AddEvent(sourceName, sourceGUID, effect, nil, duration, ticks, operation, list);

            DTM_Trace("THREAT_EVENT", "[%s]'s threat level is modified over %d seconds (%d ticks) with '%s' effect.", 1, sourceName, duration, ticks, effect);

            return;
        end        
    end

    -- Handler for temporary threat level modifying effects.

    if ( effectType == "TEMPORARY_MULTIPLY_THREAT" or effectType == "TEMPORARY_ADDITIVE_THREAT" ) and ( effectTarget == "THREAT_LEVEL" ) then
        if ( outcome == "EFFECT_GAIN" or outcome == "EFFECT_GAIN_DOSE" ) then
            -- Apply the initial threat change, building the backfire list at the same time.
            local list = {
                             number = 0,
                         };
            DTM_EntityData_PickUpAndDo( function(name, guid, threatList, sourceName, sourceGUID, list, operation, value)
                                            threatData = DTM_ThreatList_GetEntity(threatList, sourceGUID);
                                            if ( threatData ) then
                                                local currentThreat = threatData.threat or 0;
                                                local endThreat;
                                                local modification = 0;

                                                if ( operation == "TEMPORARY_MULTIPLY_THREAT" ) then
                                                    endThreat = max(0, currentThreat * value);
                                              else
                                                    endThreat = max(0, currentThreat + value);
                                                end

                                                modification = endThreat - currentThreat;

                                                DTM_ThreatList_Modify(name, guid, sourceName, sourceGUID, "VALUE", modification, nil);

                                                list.number = list.number + 1;
                                                list[list.number] = {
                                                    name = name,
                                                    guid = guid,
                                                    value = -modification,
                                                };
                                            end
                                        end , sourceName , sourceGUID , list , effectType , value );

            -- Register the backfire event.

            DTM_Time_AddEvent(sourceName, sourceGUID, effect, 1, duration, 1, "ADDITIVE_THREAT", list);

            DTM_Trace("THREAT_EVENT", "[%s]'s threat level is temporarily modified for %d seconds with '%s' effect.", 1, sourceName, duration, effect);

            return;
        end        
    end

    -- Handler for standard, immediate threat level modification.

    if ( effectType == "MULTIPLY_THREAT" or effectType == "ADDITIVE_THREAT" ) and ( effectTarget == "THREAT_LEVEL" ) and ( outcome == "EFFECT_GAIN" ) then
        local v, c;
        if ( effectType == "MULTIPLY_THREAT" ) then
            c = value; -- We multiply threat level by a (c)oeff.
      else
            v = value; -- We add a fixed (v)alue to the threat level.
        end
        DTM_Combat_PickUpThreatListContainingEntityAndDo(sourceGUID, nil, DTM_ThreatList_Modify, sourceName, sourceGUID, "VALUE", v, c);
        DTM_Trace("THREAT_EVENT", "[%s]'s threat level has been instantly modified by '%s' effect.", 1, sourceName, effect);
        return;
    end

    -- Handler for effects losses/gains.

    if ( outcome == "EFFECT_GAIN" or outcome == "EFFECT_GAIN_DOSE" ) then
        DTM_Time_EffectGain(sourceName, sourceGUID, effect);
  else
        DTM_Time_EffectLost(sourceName, sourceGUID, effect);
    end
end

-- ********************************************************************
-- * DTM_Combat_DeathEvent(Result)                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> Result: the table sent by combat parsing system.              *
-- ********************************************************************
-- * Gets called for each death related stuff occuring in combat.     *
-- ********************************************************************
function DTM_Combat_DeathEvent(Result)
    -- Delete the threat list and associated data of the unit who died.
    -- Time events etc. will be implicitly removed as well.
    DTM_EntityData_DeleteByGUID(Result.Target.GUID);

    -- Add the unit to the death table and specifies when it died.
    DTM_Death[Result.Target.GUID] = GetTime();
end

-- ********************************************************************
-- * DTM_Combat_MissEvent(Result)                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> Result: the table sent by combat parsing system.              *
-- ********************************************************************
-- * Gets called for each miss related stuff occuring in combat.      *
-- ********************************************************************
function DTM_Combat_MissEvent(Result)
    local missType, actClass;
    missType = Result.Special;
    actClass = Result.Class;

    if ( actClass == "ABILITY" ) then
        -- First before going on, remove all self-cast instances of the missed ability that have the "SUCCESS" status.
        if ( Result.Actor.Name == UnitName("player") ) then
            DTM_SelfAbility_DeleteCastByName(Result.Ability.Name, "SUCCESS");
        end
    end

    -- Now, up from there, if we can't do anything else if we haven't got the name of the guy who resisted.
    if not ( Result.Target.GUID ) then return; end

    -- Records Reflect events as a timed event.

    if ( actClass == "ABILITY" ) and ( missType == "REFLECT" ) then
        DTM_Time_AddEvent(Result.Actor.Name, Result.Actor.GUID, Result.Ability.Id, nil, REFLECT_MAX_WAIT_TIME, nil, "REFLECT", nil, Result.Target.Name, Result.Target.GUID);
        DTM_Trace("THREAT_EVENT", "[%s] has reflected [%s] toward [%s].", 1, Result.Target.Name or '?', Result.Ability.Name or '?', Result.Actor.Name or '?');
    end

    -- Now determinates if there are resists on Soulshatter etc. abilities.

    local ability;

    local sourceFlags = Result.Actor.Flags;
    local sourceIsPlayer = bit.band( sourceFlags , COMBATLOG_OBJECT_TYPE_PLAYER ) > 0;
    local sourceIsNPC = bit.band( sourceFlags , COMBATLOG_OBJECT_TYPE_NPC ) > 0;
    local sourceIsPet = ( bit.band( sourceFlags , COMBATLOG_OBJECT_TYPE_PET ) > 0 ) or ( bit.band( sourceFlags , COMBATLOG_OBJECT_TYPE_GUARDIAN ) > 0 );
    local npcAbility = nil;

    if ( actClass == "ABILITY" ) then
        local abilityLocalised = Result.Ability.Name;
        if ( sourceIsPlayer ) or ( sourceIsPet ) then
            ability = DTM_GetInternalBySpellId(Result.Ability.Id);
            ability = ability or DTM_GetInternal("abilities", abilityLocalised, IGNORE_ASSOCIATION_ERRORS);
        end
        if ( sourceIsNPC ) and ( abilityLocalised ) then
            ability = abilityLocalised; -- That is a special case handled a bit below. NPCs abilities have no internal representation.
            npcAbility = 1;
        end
    end
    if ( sourceIsPet ) then
        -- Pets use a different ability set.
        -- This is needed to avoid using Druid's growl ability instead of Pet one.
        if ( ability ) then
            ability = "PET_"..ability;
        end
    end

    -- Retrieve internal name given (arbitrarily) to a NPC ability.
    if ( npcAbility ) then
        npcData = DTM_GetNPCAbilityData( Result.Actor.Name );
        ability, _ = DTM_GetNPCAbilityEffect(npcData, ability);
    end

    -- Aborts if ability that missed hasn't an internal name.
    if not ( ability ) then return; end

    -- Pick up pending ponctual combat events that check for misses.
    DTM_CombatEvents_Remove(ability, Result.Actor.GUID, Result.Target.GUID);

    -- Ok, now pick up events that have "DELAY_internalAbilityName" as linked effect and remove the guy that resisted from their list.
    ability = "DELAY_" .. ability;
    DTM_Time_RemoveFromList(Result.Actor.GUID, ability, Result.Target.GUID);
end

-- --------------------------------------------------------------------
-- **                           Functions                            **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Combat_InjectPresenceList(srcGUID, dstGUID)                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> srcGUID: the GUID of the unit whose presence list will get    *
-- * injected into the destination unit's one.                        *
-- * >> dstGUID: the GUID of the unit whose presence list will get    *
-- * extended by source unit's one.                                   *
-- ********************************************************************
-- * Make sure all entities on <srcGUID> unit presence list are       *
-- * present in <dstGUID> unit presence list. Of course, calling this *
-- * function will keep the concerned threat lists synchronized.      *
-- ********************************************************************
local bufferOp = {};
local bufferName = {};
function DTM_Combat_InjectPresenceList(srcGUID, dstGUID)
    local srcData = DTM_EntityData_Get(srcGUID, nil);
    if ( not srcData ) then return; end

    -- local dstData = DTM_EntityData_Get(dstGUID, nil);
    local dstData = DTM_EntityData_Get(dstGUID, 1); -- writeMode is set in case the threatening unit hadn't a presence list so far.
    -- if ( not dstData ) then return; end

    local srcPresenceList = srcData.presenceList;
    local dstPresenceList = dstData.presenceList;
    if ( not srcPresenceList ) or ( not dstPresenceList ) then return; end

    local k, v, i;
    for k, v in pairs(bufferOp) do
        bufferOp[k] = nil;
    end

    -- List entities that are already in destination unit's presence list.
    for i=1, dstPresenceList.number do
        bufferOp[dstPresenceList[i].guid] = 1;
        bufferName[dstPresenceList[i].guid] = dstPresenceList[i].name;
    end

    -- Add entities that should get added in destination unit's presence list.
    for i=1, srcPresenceList.number do
        if not ( bufferOp[srcPresenceList[i].guid] ) then
            bufferOp[srcPresenceList[i].guid] = 2;
            bufferName[srcPresenceList[i].guid] = srcPresenceList[i].name;
        end
    end

    -- Now complete the presence and threat lists. :)
    for k, v in pairs(bufferOp) do
        if ( v == 2 ) then -- Add this one.
            DTM_ThreatList_Modify(bufferName[k], k, dstData.name, dstGUID, "VALUE", 0);
            -- DTM_Trace("THREAT_EVENT", "[%s] finds [%s] threatening because it has helped [%s].", 1, bufferName[k] or '?', dstData.name or '?', srcData.name or '?');
        end
    end
end

-- ********************************************************************
-- * DTM_Combat_CountThreatListContainingEntity(guid, ignoreIfCC)     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of the unit that must be on one's              *
-- * threat list for one to be eligible for the pickup.               *
-- * >> ignoreIfCC: if set, this function will not count entities     *
-- * that are affected by a crowd control which ignores global threat.*
-- ********************************************************************
-- * Search in all threat lists maintained by DTM the ones which have *
-- * a given GUID on it and count them.                               * 
-- * To do this, now the presence list system has been implemented,   *
-- * we just have to return the presence list size. :p                *
-- ********************************************************************
function DTM_Combat_CountThreatListContainingEntity(guid, ignoreIfCC)
    local total = 0;
    local entityData = DTM_EntityData_Get(guid, nil);
    if ( entityData ) and ( entityData.presenceList ) then
        if ( not ignoreIfCC ) then
            total = entityData.presenceList.number or 0;
      else
            local i;
            for i=1, entityData.presenceList.number do
                if ( not DTM_CrowdControl_IsIgnoringGlobalThreat( entityData.presenceList[i].guid ) ) then
                    total = total + 1;
                end
            end
        end
    end
    return total;
end

-- **********************************************************************
-- * DTM_Combat_PickUpThreatListContainingEntityAndDo(guid, ignoreIfCC, *
-- *                                                  func, ...)        *
-- **********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of the unit that must be on one's              *
-- * threat list for one to be eligible for the pickup.               *
-- * >> ignoreIfCC: if set, this function will not pick up entities   *
-- * that are affected by a crowd control which ignores global threat.*
-- * >> func: the function to call. Name and GUID of one that has     *
-- * the GUID looked for on one's threat list will be passed.         *
-- * >> ... : additionnal arguments that will be passed to func.      *
-- ********************************************************************
-- * Search in all threat lists maintained by DTM the ones which have *
-- * a given GUID on it and perform on them a function.               * 
-- ********************************************************************
function DTM_Combat_PickUpThreatListContainingEntityAndDo(guid, ignoreIfCC, func, ...)
    local entityData = DTM_EntityData_Get(guid, nil);
    if ( entityData ) then
        local presenceList = entityData.presenceList;
        if ( presenceList ) then
            local i;        -- Start from the top of the list. Picked up element could be removed meanwhile because we do not know what "func" will do.
            for i=presenceList.number, 1, -1 do
                if ( not ignoreIfCC ) or ( not DTM_CrowdControl_IsIgnoringGlobalThreat( presenceList[i].guid ) ) then
                    func(presenceList[i].name, presenceList[i].guid, ...);
                end
            end
        end
    end
end

-- ************************************************************************
-- * DTM_Combat_PickUpThreatListContainingEntityAndDoEx(guid, ignoreIfCC, *
-- *                                                    func, ...)        *
-- ************************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of the unit that must be on one's              *
-- * threat list for one to be eligible for the pickup.               *
-- * >> ignoreIfCC: if set, this function will not pick up entities   *
-- * that are affected by a crowd control which ignores global threat.*
-- * >> func: the function to call. Name, GUID and threat of one that *
-- * has the GUID looked for on one's threat list will be passed.     *
-- * >> ... : additionnal arguments that will be passed to func.      *
-- ********************************************************************
-- * Search in all threat lists maintained by DTM the ones which have *
-- * a given GUID on it and perform on them a function. Ex mode.      * 
-- ********************************************************************
function DTM_Combat_PickUpThreatListContainingEntityAndDoEx(guid, ignoreIfCC, func, ...)
    local entityData = DTM_EntityData_Get(guid, nil);
    if ( entityData ) then
        local presenceList = entityData.presenceList;
        if ( presenceList ) then
            local i;
            for i=presenceList.number, 1, -1 do
                if ( not ignoreIfCC ) or ( not DTM_CrowdControl_IsIgnoringGlobalThreat( presenceList[i].guid ) ) then
                    func(presenceList[i].name, presenceList[i].guid, presenceList[i].threat, ...);
                end
            end
        end
    end
end

-- ********************************************************************
-- * DTM_Combat_EvaluateCondition(condition, unit, guid, eventData)   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> condition: the condition of the talent. Nil if none.          *
-- * >> unit: the unit whose talent's condition is evaluated.         *
-- * >> guid: the guid of the unit who is evaluated.                  *
-- * >> eventData: the table containing the event data of what is     *
-- *               evaluated. The combat context in other words.      *
-- ********************************************************************
-- * Checks a given condition is fulfilled, for the activation of a   *
-- * talent, effect, ability, etc.                                    *
-- * You needn't provide all the arguments, only the ones that are    *
-- * necessary for the condition you are checking.                    *
-- ********************************************************************
function DTM_Combat_EvaluateCondition(condition, unit, guid, eventData)
    if not ( condition ) then
        return 1;
    end

    local reverse = nil;
    local result = nil;

    if ( strsub(condition, 1, 2) == "NO" ) then
        reverse = 1;
        condition = strsub(condition, 3, strlen(condition));
    end

    local condition, parameter = strsplit(":", condition, 2);

    if ( condition == "EFFECT" ) and ( unit ) then -- Check an unit has a given effect. We must have unit argument.
        result = DTM_Unit_SearchEffect(unit, parameter);

elseif ( condition == "STANCE" ) and ( unit or guid ) then -- Check given unit is in given stance. It's important to pass unit and GUID arguments.
        result = ( DTM_GetStance(guid, unit) == parameter );

elseif ( condition == "PET" ) and ( unit ) then -- Check given unit has a particular pet type out. Only party/raid UIDs are accepted.
        local petUID = unit.."pet";
        if ( unit == "player" ) then
            petUID = "pet";
        end
        local petFamily = UnitCreatureFamily(petUID);
        if ( petFamily ) then
            petInternal = DTM_GetInternal("pets", petFamily, nil) or "?";
            result = ( petInternal == parameter );
        end
elseif ( condition == "SPECIAL" ) and ( eventData ) then -- Check what's happened in combat event has a particular special flag (Critical, crushing etc.).
        result = ( eventData.special == parameter );

elseif ( condition == "TYPE" ) and ( eventData ) then -- Check if what's happened is a "HEAL", "DAMAGE", "LEECH" or "NONE" of those.
        result = ( eventData.amountType == parameter );

elseif ( condition == "TIMING" ) and ( eventData ) then
        result = ( eventData.amountTiming == parameter );
    end

    if ( reverse ) then
        if ( result ) then
            return nil;
      else
            return 1;
        end
  else
        if ( result ) then
            return 1;
      else
            return nil;
        end
    end
end

-- ********************************************************************
-- * DTM_Combat_SelfCastApply(actorName, actorGUID,                   *
-- *                          targetName, targetGUID,                 *
-- *                          abilityInternal, abilityRank)           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> actorName, actorGUID: identity of the actor.                  *
-- * >> targetName, targetGUID: identity of the ability's target.     *
-- * >> abilityInternal, abilityRank: stuff about the ability used.   *
-- ********************************************************************
-- * Gets called when a hard-to-detect ability is fired by self,      *
-- * party member or raid member.                                     *
-- * This creates a "fake" (or "emulated" if you want) combat event   *
-- * given to the general event handler.                              *
-- ********************************************************************
function DTM_Combat_SelfCastApply(actorName, actorGUID, targetName, targetGUID, abilityInternal, abilityRank)
    -- Converts ability rank to a number or nil.
    if ( abilityRank == "NONE" ) then
        abilityRank = nil;
    end
    if ( abilityRank ) then abilityRank = tonumber(abilityRank); end

    -- Check the ability is defined and is really a LOCAL one.

    local abilityClass, abilityEffect = DTM_Abilities_GetData(abilityInternal);
    if not ( abilityEffect ) then return; end
    local abilityDetection = abilityEffect.detection or "UNIVERSAL";
    if ( abilityDetection ~= "LOCAL" and abilityDetection ~= "FEIGN_DEATH" ) then return; end

    -- OK, create an event data table and sends it to Apply function of CombatEvents module..

    local k, v;
    for k, v in pairs(workTable) do
        workTable[k] = nil;
    end


    workTable.ability = abilityInternal;
    workTable.effect = abilityEffect;
    workTable.rank = abilityRank;
    workTable.sourceName = actorName;
    workTable.sourceGUID = actorGUID;
    workTable.sourceFlags = COMBATLOG_OBJECT_TYPE_PLAYER;
    workTable.targetName = targetName;
    workTable.targetGUID = targetGUID;
    workTable.timestamp = time();   -- Inaccurate, but not needed. Oh well.

    DTM_Trace("COMBAT", "Ability [%s] fired by [%s] on [%s] !", 1, abilityInternal, actorName, targetName);

    DTM_CombatEvents_Apply(workTable);
end

-- ********************************************************************
-- * DTM_Combat_UnitHasDiedRecently(guid)                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: who is examined.                                        *
-- ********************************************************************
-- * Determinates if an unit has died recently (less than 2s ago).    *
-- * These units do not trigger threat events and are ignored by      *
-- * the zone wide algorithm.                                         *
-- ********************************************************************
function DTM_Combat_UnitHasDiedRecently(guid)
    if not ( guid ) then return nil; end

    local deathTime = DTM_Death[guid];
    if not ( deathTime ) then return nil; end

    local elapsed = GetTime() - deathTime;
    if ( elapsed < RECENT_DEATH_THRESHOLD ) then return 1; end

    return nil;
end

-- --------------------------------------------------------------------
-- **                            Handlers                            **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SelfCastPacketReceived()                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> source: the name of the player who issued the packet.         *
-- * >> actorName, actorGUID: identity of the actor. Actor name should*
-- * be the same string as source if secured network is used.         *
-- * >> abilityInternal, abilityRank: stuff about the ability used.   *
-- * >> targetName, targetGUID: identity of the ability's target.     *
-- ********************************************************************
-- * Gets called when a unit in the raid or party does an ability that*
-- * only him can detect and notify.                                  * 
-- ********************************************************************
function DTM_SelfCastPacketReceived(source, actorName, actorGUID, abilityInternal, abilityRank, targetName, targetGUID)
    -- Ignore PCK from self.
    if ( source == UnitName("player") ) then
        return;
    end

    if ( CHECK_TRUSTABLE ) then
        ptr = DTM_GetGroupPointer(source);
        if ( ptr ) then
            if ( UnitGUID(ptr) ~= actorGUID ) or ( UnitName(ptr) ~= actorName ) then
                -- GUID or Name of the sender is not the same the GUID / Name announced in the PCK. Drop it.
                return;
            end
      else
            -- Can't select the sender. Drop PCK.
            return;
        end
    end

    DTM_Combat_SelfCastApply(actorName, actorGUID, targetName, targetGUID, abilityInternal, abilityRank);
end