local activeModule = "Engine combat events";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local DISABLED = nil;

-- Uncomment this to rely only on Blizzard native threat meter for threat determination.
-- Also useful to determinate threat values of abilities by comparing it to WoW native threat meter.
-- DISABLED = 1;

-- --------------------------------------------------------------------
-- **                        Combat events API                       **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_CombatEvents_Add(eventData)                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> eventData: the data of the combat event to add in queue.      *
-- ********************************************************************
-- * Gets called by general handler of Combat.lua to add non-damaging *
-- * abilities that could potentially miss in the meantime.           *
-- ********************************************************************
function DTM_CombatEvents_Add(eventData)
    if not ( eventData ) or not ( eventData.delay ) or not ( eventData.ability ) then
        return;
    end
    DTM_Events.number = DTM_Events.number + 1;
    DTM_Events[DTM_Events.number] = eventData;
end

-- ********************************************************************
-- * DTM_CombatEvents_Remove(ability, actorGUID, targetGUID)          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> ability: the internal ability name that missed.               *
-- * >> actorGUID: the GUID of the guy whose ability was missed.      *
-- * >> targetGUID: the GUID of the guy who was targetted.            *
-- ********************************************************************
-- * Gets called by miss handler of Combat.lua file to remove pending *
-- * abilities that could miss - and indeed missed.                   *
-- ********************************************************************
function DTM_CombatEvents_Remove(ability, actorGUID, targetGUID)
    local i, ii, eventData, deleteThis;

    for i=DTM_Events.number, 1, -1 do
        eventData = DTM_Events[i];
        deleteThis = 1;

        if ( ability ) and ( eventData.ability ~= ability ) then
            deleteThis = nil;
        end
        if ( actorGUID ) and ( eventData.sourceGUID ~= actorGUID ) then
            deleteThis = nil;
        end
        if ( targetGUID ) and ( eventData.targetGUID ~= targetGUID ) then
            deleteThis = nil;
        end

        if ( deleteThis ) then
            DTM_Events.number = DTM_Events.number - 1;
            for ii=i, DTM_Events.number do
                DTM_Events[ii] = DTM_Events[ii+1];
                DTM_Events[ii+1] = nil;
            end
        end
    end
end

-- ********************************************************************
-- * DTM_CombatEvents_Update(elapsed)                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> elapsed: time that passed since last call.                    *
-- ********************************************************************
-- * Update pending events, and eventually time-out them, and so      *
-- * validate them.                                                   *
-- ********************************************************************
function DTM_CombatEvents_Update(elapsed)
    local i, eventData;

    for i=DTM_Events.number, 1, -1 do
        eventData = DTM_Events[i];

        eventData.delay = max(0.0, eventData.delay - elapsed);
        if ( eventData.delay <= 0.000 ) then
            DTM_Trace("COMBAT", "[%s]'s [%s] pending ability has been considered successful.", 1, eventData.sourceName or '?', eventData.ability);

            DTM_CombatEvents_Apply(eventData);
            DTM_CombatEvents_Remove(eventData.ability, eventData.sourceGUID, eventData.targetGUID);
        end
    end
end

-- ********************************************************************
-- * DTM_CombatEvents_Apply(eventData)                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> eventData: the data of the combat event that was validated.   *
-- ********************************************************************
-- * Gets called for each ponctual event that is considered successful*
-- ********************************************************************
function DTM_CombatEvents_Apply(eventData)
    if ( DISABLED == 1 ) then return; end
    local workMethod = DTM_GetSavedVariable("engine", "workMethod", "active");
    if not ( workMethod == "PARSE" or workMethod == "HYBRID" ) then
        return;
    end

    -- STEP 1 - Grab data

    local ability = eventData.ability;
    local amount = eventData.amount or 0;
    local amountType = eventData.amountType or "NONE";
    local amountTiming = eventData.amountTiming or "INSTANT";
    local powerType = eventData.powerType;
    local abilityEffect = eventData.effect;
    local abilityRank = eventData.rank;
    local sourceName = eventData.sourceName;
    local sourceGUID = eventData.sourceGUID;
    local sourceFlags = eventData.sourceFlags;
    local targetName = eventData.targetName;
    local targetGUID = eventData.targetGUID;
    local eventTime = eventData.timestamp;

    if not ( abilityEffect ) then return; end

    local threatValue = 0;
    local threatValueCoeff = nil;
    local threatOperation = nil;
    local globalThreatMultiplier = 1.000;
    local baseMod, finalMod = 0, 0;

    local owner = abilityEffect.owner;
    local relative = abilityEffect.relative;
    local delay = abilityEffect.delay;
    local sourceIsPet = ( bit.band( sourceFlags , COMBATLOG_OBJECT_TYPE_PET ) > 0 ) or ( bit.band( sourceFlags , COMBATLOG_OBJECT_TYPE_GUARDIAN ) > 0 );

    local effectType = abilityEffect.type;
    local target = abilityEffect.target;
    local value = abilityEffect.value or 0.00;
    local instantCoeff = abilityEffect.instantCoeff or 1.00;
    local overTimeCoeff = abilityEffect.overTimeCoeff or 1.00;
    local detection = abilityEffect.detection or "UNIVERSAL";
    local scaling = abilityEffect.scaling;
    local invalidateFlatThreat = abilityEffect.invalidateFlatThreat or nil;

    local sourcePtr = DTM_GetUnitPointer(sourceGUID);
    local targetPtr = DTM_GetUnitPointer(targetGUID);

    local talentInternal, talentClass, talentEffect;
    local talentRank;
    local itemId, itemInternal, itemEffect;
    local equipedItemString;
    local setEffectInternal, setInternal, reqPieces, setEffect;

    -- Value extraction if it is a rank table.
    -- Can also handle very special cases which require a function to compute.
    if ( type(value) == 'table' ) then
        value = value[abilityRank or 1] or 0.00;
  elseif ( type(value) == 'function' ) then
        value = value(sourcePtr, targetPtr, abilityRank or 1) or 0.00; -- Pretty cool uh.
   else
        -- Pure value. It is ok.
    end

    -- If source is dead then we admit that there's no point applying the action.
    if ( sourcePtr ) and ( UnitIsDeadOrGhost(sourcePtr) ) then
        return;
    end

    -- If there is a target and it is dead, we'll admit that there's no point applying the action.
    if ( targetPtr ) and ( UnitIsDeadOrGhost(targetPtr) ) then
        return;
    end

    -- If either unit has been recently reported as dead, drop at once the event too.
    if ( DTM_Combat_UnitHasDiedRecently(sourceGUID) or DTM_Combat_UnitHasDiedRecently(targetGUID) ) then
        return;
    end

    -- STEP 2 - Determinate threat operation

    if ( effectType == "NULL" ) then
        return;
    end
    if ( effectType == "CHANGE_FLAG" ) then
        -- Warns the engine handler.
        DTM_EntityData_HandleFlagChange(sourceName, sourceGUID, target, value);
        -- Skip the remainder.
        return;
    end
    if ( effectType == "THREAT_WIPE" ) then
        DTM_EntityData_Reset(1);
        -- Skip the remainder.
        return;
    end
    if ( effectType ~= "DROP" and effectType ~= "TAUNT" and effectType ~= "THREAT_REDIRECTION" and effectType ~= "DEFENSIVE_TAUNT" ) then
        threatOperation = "VALUE";
  else
        threatOperation = effectType;
    end

    if not ( threatOperation ) then return; end

    -- Before doing further CPU intensive computations, for traditionnal targetting skills (Actor as owner, Target as relative) that do plain threat modification,
    -- drop it if we "threaten" an invalid (assistable) unit.
    -- This code should prevent for instance, that you get added in your mates' threat list in Gruul's encounter or in Blackheart boss fight.
    -- This also checks that the Relative (that is, the guy who gets his threat list updated) can INDEED hold a threat list.

    if ( owner == "ACTOR" and relative == "TARGET" ) and ( threatOperation == "VALUE" ) then
        if ( targetPtr ) then
            if ( not DTM_CanHoldThreatList(targetPtr) ) then
                DTM_Trace("THREAT_ERROR", "Dropping invalid event: [%s] may not hold a threat list.", 1, targetName);
                return;
            end
      else
            if ( not DTM_CanHoldThreatListLimited(targetGUID) ) then
                DTM_Trace("THREAT_ERROR", "Dropping invalid event: [%s] may not hold a threat list.", 1, targetName);
                return;
            end
        end

        if ( sourcePtr and targetPtr ) and ( UnitCanAssist(sourcePtr, targetPtr) ) then
            DTM_Trace("THREAT_ERROR", "Dropping invalid event: [%s] threatens [%s] (%d)", 1, sourceName, targetName, threatValue);
            return;
        end
    end

    -- STEP 3 - Remaining operations are only valid for VALUE operation.

    if ( threatOperation == "VALUE" ) then
        -- 3A - Determinate the base threat value.

        local powerTypeMultiplier = DTM_Powertype_GetThreatRate(amountType, powerType);
        local effectiveAmount = 0;

        -- Ignore overheal for HP heals.
        if ( amountType == "HEAL" ) and ( powerType == "HP" ) then
            if not ( targetPtr ) then
                effectiveAmount = 0;
          else
                local healableValue = 0;
                if ( DTM_CanGetHealth(targetPtr) ) then
                    healableValue = UnitHealthMax(targetPtr) - UnitHealth(targetPtr);
                end
                effectiveAmount = min(amount, healableValue);
            end

         -- We also ignore overheal for other powertypes if we have a pointer to this unit.
    elseif ( amountType == "HEAL" ) and not ( powerType == "HP" ) then
            if not ( targetPtr ) then
                effectiveAmount = amount;
          else
                effectiveAmount = min(amount, UnitManaMax(targetPtr) - UnitMana(targetPtr));
            end

         -- There's no such thing as overdamage for damage or leech.
    elseif ( amountType == "DAMAGE" ) or ( amountType == "LEECH" ) then
            effectiveAmount = amount;
        end

        local baseThreat = effectiveAmount * powerTypeMultiplier;
        if ( amountTiming == "OVERTIME" ) then
            baseThreat = baseThreat * overTimeCoeff;
      else
            baseThreat = baseThreat * instantCoeff;
        end

        threatValue = baseThreat;

        -- Has the ability a bonus threat component ?
        if ( target == "THREAT_LEVEL" ) and ( effectType == "ADDITIVE_THREAT" ) and not ( amountTiming == "OVERTIME" ) then
            -- If there is valid scaling data and we know actor's AP and Level then compute it out...

            if ( scaling ) then
                local actorLevel = DTM_GetStat(sourceGUID, sourcePtr, "LV");
                local actorAP = DTM_GetStat(sourceGUID, sourcePtr, "AP");

                -- Courtesy adapted from KTM.
                if ( actorLevel ) and ( actorAP ) then
                    if ( actorLevel > 59 ) then
                        local minAP = scaling.minAPConstant + actorLevel * scaling.minAPGradient;
		
                        if ( actorAP > minAP ) then
                            value = value + (actorAP - minAP) * scaling.threatPerAP;

                            DTM_Trace("THREAT_EVENT", "[%s] has used a scaling ability (%d bonus, %d total).", 1, eventData.sourceName or '?', (actorAP - minAP) * scaling.threatPerAP, value);
                        end
                    end
                end
            end

            threatValue = threatValue + value;
        end

        -- 3B - Grab all multipliers/modifiers related to talents, stances, sets, items...

        local abilityMultiplier, baseThreatChange, finalThreatChange = DTM_ThreatModifiers_GetAbilityModifier(ability, sourcePtr, eventData, sourceIsPet);
        baseMod = baseMod + baseThreatChange;
        finalMod = finalMod + finalThreatChange;

        local stanceMultiplier = DTM_ThreatModifiers_GetStanceModifier(sourcePtr, eventData);

        local effectMultiplier = DTM_ThreatModifiers_GetEffectModifier(sourcePtr, eventData);

        local itemMultiplier, baseThreatChange, finalThreatChange = DTM_ThreatModifiers_GetItemModifier(sourcePtr, eventData);
        baseMod = baseMod + baseThreatChange;
        finalMod = finalMod + finalThreatChange;

        local talentsMultiplier = DTM_ThreatModifiers_GetTalentsModifier(sourcePtr, eventData, sourceIsPet);

        local setsMultiplier, baseThreatChange, finalThreatChange = DTM_ThreatModifiers_GetSetsModifier(sourcePtr, eventData);
        baseMod = baseMod + baseThreatChange;
        finalMod = finalMod + finalThreatChange;

        -- Also apply the ability on the abilityMultiplier if it's a global threat multiplier modifying one.

        if ( target == "GLOBAL_THREAT" ) then
            if ( effectType == "ADDITIVE_THREAT" ) then
                abilityMultiplier = abilityMultiplier + value;
            end
            if ( effectType == "MULTIPLY_THREAT" ) then
                abilityMultiplier = abilityMultiplier * value;
            end
        end

        -- 3C - Apply them all on the global threat multiplier.

        globalThreatMultiplier = globalThreatMultiplier * abilityMultiplier * effectMultiplier * stanceMultiplier;
        globalThreatMultiplier = globalThreatMultiplier * setsMultiplier * talentsMultiplier * itemMultiplier;

        -- 3D - Determinate the final threat value & coeff the total threat will be multiplied with.

        threatValue = DTM_ThreatModifiers_ApplyModifier(threatValue, baseMod);
        threatValue = threatValue * globalThreatMultiplier;
        threatValue = DTM_ThreatModifiers_ApplyModifier(threatValue, finalMod);

        -- Is the amount directly modifying threat level by a % ? Note this % will not scale, regardless of global threat multiplier.
        if ( target == "THREAT_LEVEL" ) and ( effectType == "MULTIPLY_THREAT" ) and not ( amountTiming == "OVERTIME" ) then
            threatValueCoeff = value;
        end

        -- Do we invalidate the flat threat generated ?
        if ( invalidateFlatThreat ) then
            threatValue = 0.00;
        end
    end

    -- STEP 4 - Special case ! If the ability has a threat redirection effect, create an event and drop the remainder of this function.

    if ( threatOperation == "THREAT_REDIRECTION" ) then
        local effectInternal = value;
        local effectClass, effectAlwaysActive, effectEffect = DTM_Effects_GetData(effectInternal);

        if ( effectEffect ) then
            local redirectCoeff = effectEffect.value or 1.00;
            local redirectDuration = effectEffect.duration;

            if ( redirectDuration ) and ( effectEffect.type == "THREAT_REDIRECTION" ) then
                -- Effect is compatible, we can now register the redirection event.
                local list = {
                                 number = 1,
                                 [1] = {
                                     name = targetName,
                                     guid = targetGUID,
                                     value = redirectCoeff,
                                 },
                             };
                DTM_Time_AddEvent(sourceName, sourceGUID, effectInternal, nil, redirectDuration, 1, "REDIRECTION", list);

                DTM_Trace("THREAT_EVENT", "[%s] is redirecting its damage-threat to [%s] for %d seconds with '%s' effect.", 1, sourceName, targetName, redirectDuration, effectInternal);
            end
        end

        return;
    end

    -- STEP 5 - Special cases !

    -- A / If the ability is a taunt effect, check if we have the tauntOffGUID field in the event data table.
    -- If we don't have it for some reason, try getting tauntOffName instead.
    -- This should be only the case for resistible taunts.
    if ( threatOperation == "TAUNT" ) then
        threatValue = eventData.tauntOffGUID or eventData.tauntOffName;
    end

    -- B / If the ability is a defensive taunt effect, create a special event that will allow us to catch
    -- the bad guys who get taunted off the friendly unit the actor cast the defensive taunt upon, then drop the remainder of this function.
    if ( threatOperation == "DEFENSIVE_TAUNT" ) then
        DTM_Time_AddEvent(sourceName, sourceGUID, value, nil, delay or 1.500, nil, "DEFENSIVE_TAUNT", nil, targetName, targetGUID);
        return;
    end

    -- STEP 6 - Apply the threat modification on the correct owner and relative.

    if ( owner ) and ( relative ) then
        -- Time to change the threat list !

        -- Special case! Delayed abilities with .owner as "ACTOR" and .relative as "ACTOR_GLOBAL". If so, skips the remainder of the function.
        -- Exemples of abilities which work that way: feign death, soulshatter.

        if ( owner == "ACTOR" ) and ( relative == "ACTOR_GLOBAL" ) and ( delay ) and ( sourceGUID ) then
            -- Build the "ACTOR_GLOBAL" list.
            local list = {
                             number = 0,
                         };
            DTM_Combat_PickUpThreatListContainingEntityAndDoEx(sourceGUID, nil,
                                        function(name, guid, threat, list, operation, value)
                                            local modification = nil;

                                            if ( operation == "MULTIPLY_THREAT" or operation == "ADDITIVE_THREAT" ) then
                                                local currentThreat = threat or 0;
                                                local endThreat;
                                                modification = 0;

                                                if ( operation == "MULTIPLY_THREAT" ) then
                                                    endThreat = max(0, currentThreat * value);
                                              else
                                                    endThreat = max(0, currentThreat + value);
                                                end

                                                modification = endThreat - currentThreat;
                                            end

                                            list.number = list.number + 1;
                                            list[list.number] = {
                                                name = name,
                                                guid = guid,
                                                value = modification,
                                            };
                                        end , list , effectType , value );

            -- Register the delayed threat modification.

            DTM_Trace("THREAT_EVENT", "[%s] is going to perform a global %s threat operation in %d ms with '%s' ability.", 1, sourceName, effectType, delay*1000, ability);

            -- Convert multiply-based adjustments to additive adjustment.
            if ( effectType == "MULTIPLY_THREAT" ) then effectType = "ADDITIVE_THREAT"; end
            DTM_Time_AddEvent(sourceName, sourceGUID, "DELAY_"..ability, nil, delay, 1, effectType, list);

            return;
        end

        -- General case. That is, immediate changes.

        local ownerFunc = function(ownerName, ownerGUID, relative, threatOperation, threatValue, threatValueCoeff)
                              threatValue = threatValue or 0;
                              if ( relative == "ACTOR" ) then
                                  DTM_ThreatList_Modify(sourceName, sourceGUID, ownerName, ownerGUID, threatOperation, threatValue, threatValueCoeff);
                              end
                              if ( relative == "TARGET" ) then
                                  DTM_ThreatList_Modify(targetName, targetGUID, ownerName, ownerGUID, threatOperation, threatValue, threatValueCoeff);
                              end
                              if ( relative == "ACTOR_GLOBAL" ) or ( relative == "ACTOR_GLOBAL_SPLIT" ) then
                                  if ( threatOperation == "VALUE" ) then
                                      local divider = 1;
                                      if ( relative == "ACTOR_GLOBAL_SPLIT" ) then
                                          divider = max(1, DTM_Combat_CountThreatListContainingEntity(sourceGUID, 1));
                                      end
                                      DTM_Combat_PickUpThreatListContainingEntityAndDo(sourceGUID, 1, DTM_ThreatList_Modify, ownerName, ownerGUID, threatOperation, threatValue/divider, threatValueCoeff);
                                else
                                      DTM_Combat_PickUpThreatListContainingEntityAndDo(sourceGUID, nil, DTM_ThreatList_Modify, ownerName, ownerGUID, threatOperation, threatValue, threatValueCoeff);
                                  end
                              end
                              if ( relative == "TARGET_GLOBAL" ) or ( relative == "TARGET_GLOBAL_SPLIT" ) then
                                  if (targetGUID ~= sourceGUID) then
                                      -- The entities that hate the target will also hate the source.
                                      DTM_Combat_InjectPresenceList(targetGUID, sourceGUID);
                                  end

                                  if ( threatOperation == "VALUE" ) then
                                      local divider = 1;
                                      if ( relative == "TARGET_GLOBAL_SPLIT" ) then
                                          divider = max(1, DTM_Combat_CountThreatListContainingEntity(sourceGUID, 1));
                                      end
                                      DTM_Combat_PickUpThreatListContainingEntityAndDo(sourceGUID, 1, DTM_ThreatList_Modify, ownerName, ownerGUID, threatOperation, threatValue/divider, threatValueCoeff);
                                else
                                      DTM_Combat_PickUpThreatListContainingEntityAndDo(sourceGUID, nil, DTM_ThreatList_Modify, ownerName, ownerGUID, threatOperation, threatValue, threatValueCoeff);
                                  end
                              end
                          end;

        -- Determinate the people on whom we'll apply the function.

        if ( owner == "ACTOR" ) and ( sourceGUID ) then
            -- For "VALUE" operation with positive threat values, we check for a redirect event enabled for ACTOR owner against TARGET relative.
            -- Otherwise said, redirects all hostile damaging attacks performed by ACTOR against TARGET.

            if ( threatOperation == "VALUE" ) and ( threatValue ) and not ( threatValueCoeff ) and ( relative == "TARGET" ) then
                local redirectionEffect, redirectionTargets = DTM_Time_GetRedirectionData(sourceGUID);
                if ( threatValue > 0 ) and ( redirectionEffect ) and ( redirectionTargets ) then
                    -- OK ! We redirect threat !
                    local redirectedThreat;
                    local totalRedirection = 0;

                    for i=1, redirectionTargets.number do
                        redirectedThreat = threatValue * redirectionTargets[i].value;
                        DTM_ThreatList_Modify(targetName, targetGUID, redirectionTargets[i].name, redirectionTargets[i].guid, "VALUE", redirectedThreat, nil);
                        totalRedirection = totalRedirection + redirectedThreat;
                    end

                    threatValue = max(0, threatValue - totalRedirection);
                end
            end

            ownerFunc(sourceName, sourceGUID, relative, threatOperation, threatValue, threatValueCoeff);
        end
        if ( owner == "TARGET" ) and ( targetGUID ) then
            ownerFunc(targetName, targetGUID, relative, threatOperation, threatValue, threatValueCoeff);
        end
        if ( owner == "ACTOR_LIST" ) and ( sourceGUID ) then
            -- This case allows limited functionnality; only accept ACTOR as relative.

            local actorData = DTM_EntityData_Get(sourceGUID, 1);
            local threatList = actorData.threatList;

            if ( threatOperation == "VALUE" ) and ( relative == "ACTOR" ) then
                DTM_ThreatList_PickUpAndDo(threatList, function(name, guid, threat, sourceName, sourceGUID, threatOperation, threatValue, threatValueCoeff)
                                                           DTM_ThreatList_Modify(sourceName, sourceGUID, name, guid, threatOperation, threatValue, threatValueCoeff);
                                                       end, sourceName, sourceGUID, threatOperation, threatValue, threatValueCoeff);
            end
        end
    end
end