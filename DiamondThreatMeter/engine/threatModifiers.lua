local activeModule = "Engine threat modifiers";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                     Threat modifiers API                       **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_ThreatModifiers_GetAbilityModifier(ability, sourcePtr,       *
-- *                                        eventData, sourceIsPet)   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> ability: the ability internal name.                           *
-- * >> sourcePtr: the unit whose ability modifier is computed.       *
-- * >> eventData: the data about the action that occured at the time *
-- * this function is called. Pass nil if called out of a context.    *
-- * >> sourceIsPet: pass 1 if the source is a pet. This is necessary *
-- * because it's the owner of the pet who provides its talents.      *
-- ********************************************************************
-- * Gets the threat multiplier of a given ability for asked player   *
-- * unit (often 1.00x), and the flat threat modifiers to apply on    *
-- * the base threat and final threat (both often 0).                 *
-- ********************************************************************
function DTM_ThreatModifiers_GetAbilityModifier(ability, sourcePtr, eventData, sourceIsPet)
    if not ( ability ) then return 1.00, 0, 0; end
    if not ( sourcePtr ) then return 1.00, 0, 0; end
    if not ( UnitIsPlayer(sourcePtr) ) and not ( sourceIsPet ) then return 1.00, 0, 0; end

    local talentPtr = sourcePtr;
    -- Redirects the unit pointer if it's a pet that acts.
    if ( sourceIsPet ) then
        talentPtr = DTM_GetPetMasterPointer( sourcePtr );
    end
    if not ( talentPtr ) then return 1.00, 0, 0; end

    local sourceName = UnitName(talentPtr);
    local sourceGUID = UnitGUID(sourcePtr);
    local _, sourceClass = UnitClass(talentPtr);

    local abilityMultiplier, baseThreatChange, finalThreatChange = 1.00, 0, 0;

    -- First get talents that directly affect this ability's threat.

    DTM_Talents_DoListing(sourceClass, nil, nil, "ABILITIES", ability, nil);
    for i=1, DTM_Talents_GetListSize() do
        talentInternal, talentClass, talentEffect = DTM_Talents_GetListData(i);
        talentRank = DTM_TalentsBuffer_GetTalentRank(sourceName, talentInternal);

        if ( talentRank > 0 ) and ( DTM_Combat_EvaluateCondition(talentEffect.condition, sourcePtr, sourceGUID, eventData) ) then
            if ( talentEffect.type == "MULTIPLY_THREAT" ) then
                abilityMultiplier = abilityMultiplier * talentEffect.value[talentRank];
        elseif ( talentEffect.type == "ADDITIVE_THREAT" ) then
                abilityMultiplier = abilityMultiplier + talentEffect.value[talentRank];
            end
        end
    end

    -- Then get effects that affect this ability's threat.

    DTM_Effects_DoListing(nil, nil, "ABILITIES", ability);
    for i=1, DTM_Effects_GetListSize() do
        effectInternal, effectClass, effectAlwaysActive, effectEffect = DTM_Effects_GetListData(i);

        if ( effectAlwaysActive and (sourceClass == effectClass) ) or ( DTM_Unit_SearchEffect(sourcePtr, effectInternal) ) then
            -- The effect is operational. Just check an eventual condition.

            if ( DTM_Combat_EvaluateCondition(effectEffect.condition, sourcePtr, sourceGUID, eventData) ) then
                local effectValue = effectEffect.value;

                -- Get talents that affect the effect's threat modifier.

                DTM_Talents_DoListing(sourceClass, nil, nil, "EFFECTS", nil, effectInternal);
                for ii=1, DTM_Talents_GetListSize() do
                    talentInternal, talentClass, talentEffect = DTM_Talents_GetListData(ii);
                    talentRank = DTM_TalentsBuffer_GetTalentRank(sourceName, talentInternal);

                    if ( talentRank > 0 ) and ( DTM_Combat_EvaluateCondition(talentEffect.condition, sourcePtr, sourceGUID, eventData) ) then
                        if ( talentEffect.type == "MULTIPLY_THREAT" ) then
                            effectValue = effectValue * talentEffect.value[talentRank];
                    elseif ( talentEffect.type == "ADDITIVE_THREAT" ) then
                            effectValue = effectValue + talentEffect.value[talentRank];
                        end
                    end
                end

                if ( effectEffect.type == "MULTIPLY_THREAT" ) then
                    abilityMultiplier = abilityMultiplier * effectValue;
            elseif ( effectEffect.type == "ADDITIVE_THREAT" ) then
                    abilityMultiplier = abilityMultiplier + effectValue;
                end
            end
        end
    end

    -- Then get items that affect this ability's threat.

    DTM_Items_DoListing(nil, "ABILITIES", ability);
    for i=1, DTM_Items_GetListSize() do
        itemId, itemInternal, itemEffect = DTM_Items_GetListData(i);
        equipedItemString = DTM_ItemsBuffer_GetItemEquipedAttributes(sourceName, itemId);

        if ( equipedItemString ) and ( itemEffect ) and ( DTM_Combat_EvaluateCondition(itemEffect.condition, sourcePtr, sourceGUID, eventData) ) then
            if ( itemEffect.type == "MULTIPLY_THREAT" ) then
                abilityMultiplier = abilityMultiplier * itemEffect.value;
        elseif ( itemEffect.type == "ADDITIVE_THREAT" ) then
                abilityMultiplier = abilityMultiplier + itemEffect.value;
        elseif ( itemEffect.type == "BASE_THREAT" ) then
                baseThreatChange = baseThreatChange + itemEffect.value;
        elseif ( itemEffect.type == "FINAL_THREAT" ) then
                finalThreatChange = finalThreatChange + itemEffect.value;
            end
        end
    end

    -- Get sets that affect this ability's threat.

    DTM_SetsEffects_DoListing(nil, "ABILITIES", ability);
    for i=1, DTM_SetsEffects_GetListSize() do
        setEffectInternal, setInternal, reqPieces, setEffect = DTM_SetsEffects_GetListData(i);

        if ( setEffect ) and ( DTM_SetsBuffer_GetSetEquipedPieceNumber(sourceName, setInternal) >= reqPieces ) then
            -- The effect is working.
            if ( DTM_Combat_EvaluateCondition(setEffect.condition, sourcePtr, sourceGUID, eventData) ) then
                if ( setEffect.type == "MULTIPLY_THREAT" ) then
                    abilityMultiplier = abilityMultiplier * setEffect.value;
            elseif ( setEffect.type == "ADDITIVE_THREAT" ) then
                    abilityMultiplier = abilityMultiplier + setEffect.value;
            elseif ( setEffect.type == "BASE_THREAT" ) then
                    baseThreatChange = baseThreatChange + setEffect.value;
            elseif ( setEffect.type == "FINAL_THREAT" ) then
                    finalThreatChange = finalThreatChange + setEffect.value;
                end
            end
        end
    end

    return abilityMultiplier, baseThreatChange, finalThreatChange;
end

-- ********************************************************************
-- * DTM_ThreatModifiers_GetStanceModifier(sourcePtr, eventData)      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> sourcePtr: the unit whose stance modifier is computed.        *
-- * >> eventData: the data about the action that occured at the time *
-- * this function is called. Pass nil if called out of a context.    *
-- ********************************************************************
-- * Gets the threat multiplier of the stance the asked player is in. *
-- ********************************************************************
function DTM_ThreatModifiers_GetStanceModifier(sourcePtr, eventData)
    if not ( sourcePtr ) then return 1.00; end

    local sourceName = UnitName(sourcePtr);
    local sourceGUID = UnitGUID(sourcePtr);

    local stanceMultiplier = 1.00;

    local stanceInternal = DTM_GetStance(sourceGUID , sourcePtr);
    local stanceClass, stanceEffect = DTM_Stances_GetData(stanceInternal);

    local stanceValue = stanceEffect.value;

    -- Additionally, if the unit is a player, compute his/her talents.
    if ( UnitIsPlayer(sourcePtr) ) then
        DTM_Talents_DoListing(sourceClass, stanceInternal, nil, "STANCE_THREAT", nil, nil);
        for i=1, DTM_Talents_GetListSize() do
            talentInternal, talentClass, talentEffect = DTM_Talents_GetListData(i);
            talentRank = DTM_TalentsBuffer_GetTalentRank(sourceName, talentInternal);

            if ( talentRank > 0 ) and ( DTM_Combat_EvaluateCondition(talentEffect.condition, sourcePtr, sourceGUID, eventData) ) then
                if ( talentEffect.type == "MULTIPLY_THREAT" ) then
                    stanceValue = stanceValue * talentEffect.value[talentRank];
            elseif ( talentEffect.type == "ADDITIVE_THREAT" ) then
                    stanceValue = stanceValue + talentEffect.value[talentRank];
                end
            end
        end
    end

    if ( stanceEffect.type == "ADDITIVE_THREAT" ) then
        stanceMultiplier = stanceMultiplier + stanceValue;
    end
    if ( stanceEffect.type == "MULTIPLY_THREAT" ) then
        stanceMultiplier = stanceMultiplier * stanceValue;
    end

    return stanceMultiplier;
end

-- ********************************************************************
-- * DTM_ThreatModifiers_GetEffectModifier(sourcePtr, eventData)      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> sourcePtr: the unit whose effect modifier is computed.        *
-- * >> eventData: the data about the action that occured at the time *
-- * this function is called. Pass nil if called out of a context.    *
-- ********************************************************************
-- * Gets the threat multiplier provided with active or passive       *
-- * special class effects on the given unit.                         *
-- ********************************************************************
function DTM_ThreatModifiers_GetEffectModifier(sourcePtr, eventData)
    if not ( sourcePtr ) then return 1.00; end

    local sourceGUID = UnitGUID(sourcePtr);
    local sourceIsPlayer = UnitIsPlayer(sourcePtr);
    local _, sourceClass = UnitClass(sourcePtr);

    local effectMultiplier = 1.000;

    DTM_Effects_DoListing(nil, nil, "GLOBAL_THREAT", nil);
    for i=1, DTM_Effects_GetListSize() do
        effectInternal, effectClass, effectAlwaysActive, effectEffect = DTM_Effects_GetListData(i);

        if ( effectAlwaysActive and sourceIsPlayer and (sourceClass == effectClass) ) or ( DTM_Unit_SearchEffect(sourcePtr, effectInternal) ) then
            -- The effect is operational. Just check an eventual condition.

            if ( DTM_Combat_EvaluateCondition(effectEffect.condition, sourcePtr, sourceGUID, eventData) ) then
                if ( effectEffect.type == "MULTIPLY_THREAT" ) then
                    effectMultiplier = effectMultiplier * effectEffect.value;
            elseif ( effectEffect.type == "ADDITIVE_THREAT" ) then
                    effectMultiplier = effectMultiplier + effectEffect.value;
                end
            end
        end
    end

    return effectMultiplier;
end

-- ********************************************************************
-- * DTM_ThreatModifiers_GetItemModifier(sourcePtr, eventData)        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> sourcePtr: the unit whose item modifier is computed.          *
-- * >> eventData: the data about the action that occured at the time *
-- * this function is called. Pass nil if called out of a context.    *
-- ********************************************************************
-- * Gets the threat multiplier provided with active or passive       *
-- * special class effects on the given unit, along with the flat     *
-- * threat modifiers to apply on the base threat and final threat.   *
-- ********************************************************************
function DTM_ThreatModifiers_GetItemModifier(sourcePtr, eventData)
    if not ( sourcePtr ) then return 1.00, 0, 0; end
    if not ( UnitIsPlayer(sourcePtr) ) then return 1.00, 0, 0; end

    local sourceGUID = UnitGUID(sourcePtr);
    local sourceName = UnitName(sourcePtr);

    local itemMultiplier, baseThreatChange, finalThreatChange = 1.00, 0, 0;

    -- Finds items that have a passive threat coefficient and checks if we have them.
    DTM_Items_DoListing(nil, "GLOBAL_THREAT", nil);
    for i=1, DTM_Items_GetListSize() do
        itemId, itemInternal, itemEffect = DTM_Items_GetListData(i);
        equipedItemString = DTM_ItemsBuffer_GetItemEquipedAttributes(sourceName, itemId);

        if ( equipedItemString ) and ( itemEffect ) and ( DTM_Combat_EvaluateCondition(itemEffect.condition, sourcePtr, sourceGUID, eventData) ) then
            if ( itemEffect.type == "MULTIPLY_THREAT" ) then
                itemMultiplier = itemMultiplier * itemEffect.value;
        elseif ( itemEffect.type == "ADDITIVE_THREAT" ) then
                itemMultiplier = itemMultiplier + itemEffect.value;
        elseif ( itemEffect.type == "BASE_THREAT" ) then
                baseThreatChange = baseThreatChange + itemEffect.value;
        elseif ( itemEffect.type == "FINAL_THREAT" ) then
                finalThreatChange = finalThreatChange + itemEffect.value;
            end
        end
    end

    -- Read into unit's equipment table directly and apply enchants/gems that modify threat on itemMultiplier.
    local equipmentData = DTM_ItemsBuffer_Get(sourceName);
    if ( equipmentData ) then
        for itemId, itemString in pairs(equipmentData) do
        if ( itemId ~= "name" and itemId ~= "class" ) then
            itemMultiplier = itemMultiplier * DTM_Enchants_GetItemEnchantCoefficient(itemString);
        end
        end
    end

    return itemMultiplier, baseThreatChange, finalThreatChange;
end

-- ********************************************************************
-- * DTM_ThreatModifiers_GetTalentsModifier(sourcePtr, eventData,     *
-- *                                        sourceIsPet)              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> sourcePtr: the unit whose talents modifier is computed.       *
-- * >> eventData: the data about the action that occured at the time *
-- * this function is called. Pass nil if called out of a context.    *
-- * >> sourceIsPet: pass 1 if the source is a pet. This is necessary *
-- * because it's the owner of the pet who provides its talents.      *
-- ********************************************************************
-- * Gets the threat multiplier provided with talents affecting       *
-- * global threat generated.                                         *
-- ********************************************************************
function DTM_ThreatModifiers_GetTalentsModifier(sourcePtr, eventData, sourceIsPet)
    if not ( sourcePtr ) then return 1.00; end
    if not ( UnitIsPlayer(sourcePtr) ) and not ( sourceIsPet ) then return 1.00; end

    local talentPtr = sourcePtr;
    -- Redirects the unit pointer if it's a pet that acts.
    if ( sourceIsPet ) then
        talentPtr = DTM_GetPetMasterPointer( sourcePtr );
    end
    if not ( talentPtr ) then return 1.00; end

    local sourceName = UnitName(talentPtr);
    local sourceGUID = UnitGUID(sourcePtr);
    local _, sourceClass = UnitClass(talentPtr);

    local talentsMultiplier = 1.00;

    DTM_Talents_DoListing(sourceClass, nil, nil, "GLOBAL_THREAT", nil, nil);
    for i=1, DTM_Talents_GetListSize() do
        talentInternal, talentClass, talentEffect = DTM_Talents_GetListData(i);
        talentRank = DTM_TalentsBuffer_GetTalentRank(sourceName, talentInternal);

        if ( talentRank > 0 ) and ( DTM_Combat_EvaluateCondition(talentEffect.condition, sourcePtr, sourceGUID, eventData) ) then
            if ( talentEffect.type == "MULTIPLY_THREAT" ) then
                talentsMultiplier = talentsMultiplier * talentEffect.value[talentRank];
        elseif ( talentEffect.type == "ADDITIVE_THREAT" ) then
                talentsMultiplier = talentsMultiplier + talentEffect.value[talentRank];
            end
        end
    end

    return talentsMultiplier;
end

-- ********************************************************************
-- * DTM_ThreatModifiers_GetSetsModifier(sourcePtr, eventData)        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> sourcePtr: the unit whose sets modifier is computed.          *
-- * >> eventData: the data about the action that occured at the time *
-- * this function is called. Pass nil if called out of a context.    *
-- ********************************************************************
-- * Gets the threat multiplier provided with sets affecting          *
-- * global threat generated, along with the flat                     *
-- * threat modifiers to apply on the base threat and final threat.   *
-- ********************************************************************
function DTM_ThreatModifiers_GetSetsModifier(sourcePtr, eventData)
    if not ( sourcePtr ) then return 1.00, 0, 0; end
    if not ( UnitIsPlayer(sourcePtr) ) then return 1.00, 0, 0; end

    local sourceGUID = UnitGUID(sourcePtr);
    local sourceName = UnitName(sourcePtr);

    local setsMultiplier, baseThreatChange, finalThreatChange = 1.00, 0, 0;

    DTM_SetsEffects_DoListing(nil, "GLOBAL_THREAT", nil);
    for i=1, DTM_SetsEffects_GetListSize() do
        setEffectInternal, setInternal, reqPieces, setEffect = DTM_SetsEffects_GetListData(i);

        if ( setEffect ) and ( DTM_SetsBuffer_GetSetEquipedPieceNumber(sourceName, setInternal) >= reqPieces ) then
            -- The effect is working.
            if ( DTM_Combat_EvaluateCondition(setEffect.condition, sourcePtr, sourceGUID, eventData) ) then
                if ( setEffect.type == "MULTIPLY_THREAT" ) then
                    setsMultiplier = setsMultiplier * setEffect.value;
            elseif ( setEffect.type == "ADDITIVE_THREAT" ) then
                    setsMultiplier = setsMultiplier + setEffect.value;
            elseif ( setEffect.type == "BASE_THREAT" ) then
                    baseThreatChange = baseThreatChange + setEffect.value;
            elseif ( setEffect.type == "FINAL_THREAT" ) then
                    finalThreatChange = finalThreatChange + setEffect.value;
                end
            end
        end
    end

    return setsMultiplier, baseThreatChange, finalThreatChange;
end

-- ********************************************************************
-- * DTM_ThreatModifiers_ApplyModifier(threatValue, modifier)         *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> sourcePtr: the unit whose sets modifier is computed.          *
-- * >> eventData: the data about the action that occured at the time *
-- * this function is called, needed by some sets trigger             *
-- * condition. Pass nil if called out of a context.                  *
-- ********************************************************************
-- * Applies safely a modifier on a threat value, preventing the new  *
-- * threat value to be positive if it was at first negative, and the *
-- * opposite: preventing the new threat value to be negative if it   *
-- * was at first positive.                                           *
-- ********************************************************************
function DTM_ThreatModifiers_ApplyModifier(threatValue, modifier)
    if not ( threatValue ) or not ( modifier ) then return 0; end

    -- A modifier to the threat value may not change the threat value's sign.
    if ( threatValue < 0 ) then
        threatValue = min(0, threatValue + modifier);
  else
        threatValue = max(0, threatValue + modifier);
    end

    return threatValue;
end