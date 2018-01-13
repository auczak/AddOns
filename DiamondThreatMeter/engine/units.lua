local activeModule = "Engine units";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- Adapted functions from CoolLib, my function library.

local lookup = {};
local complex = {};

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Unit_SearchEffect(unit, internalName)                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit that will be affected by the search.           *
-- * >> internalName: the internal name of the effect to find.        *
-- ********************************************************************
-- * Returns 1, rank, count, timeLeft if the specified effect is found*
-- * Elsewise nil, nil, nil, nil is returned.                         *
-- * The effect can be either a buff or debuff, it doesn't matter.    *
-- ********************************************************************
function DTM_Unit_SearchEffect(unit, internalName)
    if not ( unit ) or not ( internalName ) then
        return nil;
    end

    -- If this is a cached effect, check if we have cached data.
    local effectClass, effectAlwaysActive, effectEffect = DTM_Effects_GetData(internalName);
    if ( effectEffect ) then
        if ( effectEffect.cache ) then
            -- It is. Check if it is applied on the unit.
            local timeRemaining = DTM_Time_GetEffectCacheData(UnitGUID(unit), internalName);
            if ( timeRemaining ) then
                return 1, nil, nil, timeRemaining;
            end
            return nil, nil, nil, nil;
        end
    end

    -- It's preferable use the localised name, so unlocalize the internal name.
    local localisedName = DTM_ReverseInternal("effects", internalName);
    if not ( localisedName ) then return nil; end

    local i;
    for i=1, 50 do
        local name, rank, iconTexture, count, duration, timeLeft = UnitBuff(unit, i);
        if not ( name ) then
            break;
      elseif ( name == localisedName ) then
            return 1, rank, count, timeLeft;
        end
    end
    for i=1, 40 do
        local name, rank, texture, count, debuffType, duration, timeLeft = UnitDebuff(unit, i);
        if not ( name ) then
            break;
      elseif ( name == localisedName ) then
            return 1, rank, count, timeLeft;
        end
    end
    return nil, nil, nil, nil;
end

-- ********************************************************************
-- * DTM_CanGetHealth(unit)                                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit to check.                                      *
-- ********************************************************************
-- * Determinate if UnitHealth will return you exact HP of given unit.*
-- ********************************************************************
function DTM_CanGetHealth(unit)
    if not ( unit ) then return; end
    if ( DTM_OnWotLK() ) then return 1; end
    if (UnitHealthMax( unit ) ~= 100) then return 1; end
    return UnitIsUnit("player", unit);
end

-- ********************************************************************
-- * DTM_RebuildUnitList(callback)                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * > callback: a custom function call for each unit accessed.       *
-- ********************************************************************
-- * Calling this API will ask a complete reconstruction of           *
-- * accessable units by either their name or GUID.                   *
-- * This is now necessary for DTM_GetUnitPointer/GetGroupPointer     *
-- * APIs. RebuildUnitList should be called whenever any UID changes. *
-- * If you are unsure about that, you can just periodically call     *
-- * this API.                                                        *
-- ********************************************************************
function DTM_RebuildUnitList(callback)
    local k, v, i;
    for k, v in ipairs(complex) do
        complex[k] = nil;
    end
    for k, v in pairs(lookup) do
        lookup[k] = nil;
    end

    local function addToList(UID)
        if not ( UnitExists(UID) ) then return nil; end
        local name = UnitName(UID);
        local guid = UnitGUID(UID);
        if not ( lookup[name] ) then lookup[name] = UID; end
        if not ( lookup[guid] ) then lookup[guid] = UID; end
        if type(callback) == "function" then callback(UID); end
        return 1;
    end

    -- Simple unitIDs

    addToList("player");
    if ( addToList("pet") ) then complex[#complex+1] = "pet"; end
    if ( addToList("target") ) then complex[#complex+1] = "target"; end
    if ( addToList("focus") ) then complex[#complex+1] = "focus"; end
    if ( addToList("mouseover") ) then complex[#complex+1] = "mouseover"; end

    -- Dynamic unitIDs

    local unitId;
    local petUnitId;

    if ( GetNumRaidMembers() > 0 ) then
        for i=1, GetNumRaidMembers(), 1 do
            unitId = "raid"..i;
            if ( addToList(unitId) ) then
                complex[#complex+1] = unitId;
                petUnitId = "raidpet"..i;
                if ( addToList(petUnitId) ) then complex[#complex+1] = petUnitId; end
            end
        end
  else
        for i=1, GetNumPartyMembers(), 1 do
            unitId = "party"..i;
            if ( addToList(unitId) ) then
                complex[#complex+1] = unitId;
                petUnitId = "partypet"..i;
                if ( addToList(petUnitId) ) then complex[#complex+1] = petUnitId; end
            end
        end
    end

    -- Complex unitIDs

    local base;
    local firstNest;
    local secondNest;
    local thirdNest;

    for i=1, #complex, 1 do
        base = complex[i];
        firstNest = base .. "target";
        secondNest = base .. "targettarget";
        thirdNest = base .. "targettargettarget";

        if ( addToList(firstNest) ) then
            if ( addToList(secondNest) ) then
                addToList(thirdNest);
            end
        end
    end
end

-- ********************************************************************
-- * DTM_GetUnitPointer(value)                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> value: the name *OR* GUID to search an UID for.               *
-- ********************************************************************
-- * This function tries to find an unitId which points to the unit   *
-- * name or GUID you specified.                                      *
-- * Be aware that this function will fail most of the time,          *
-- * except if the unit you want to get info from is your current,    *
-- * target/focus your pet, yourself or a party/raid member.          *
-- * Return an UID (like 'player', 'targettargettarget') or nil.      *
-- ********************************************************************
function DTM_GetUnitPointer(value)
    if not ( value ) then return nil; end

    return lookup[value]; -- Couldn't be simpler. x)
end

-- ********************************************************************
-- * DTM_GetGroupPointer(value)                                       *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> value: the name *OR* GUID to search an UID for.               *
-- ********************************************************************
-- * This function tries to find an unitId which points to the unit   *
-- * name or GUID you specified that is in your party or raid.        *
-- * Return a self/party/raid UID (like 'player', 'party3') or nil.   *
-- ********************************************************************
function DTM_GetGroupPointer(value)
    if not ( value ) then return nil; end

    local uid = lookup[value];

    if ( uid ) then
        if ( UnitInParty(uid) or UnitInRaid(uid) ) then
            return uid;
        end
    end

    return nil;
end

-- ********************************************************************
-- * DTM_GetPetMasterPointer(petUnitId)                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> petUnitId: the UID of the pet to get the master's UID from.   *
-- ********************************************************************
-- * This function tries to find the UID of the master of the given   *
-- * pet UID in the raid or party (including yourself).               *
-- ********************************************************************
function DTM_GetPetMasterPointer(petUnitId)
    if not ( petUnitId ) then return nil; end

    local i;

    -- Self pet ID

    if ( UnitIsUnit('pet', petUnitId) ) then return 'player'; end

    -- Raid/party pet ID

    if ( GetNumRaidMembers() > 0 ) then
        for i=1, GetNumRaidMembers(), 1 do
            if ( UnitIsUnit('raidpet'..i, petUnitId) ) then return 'raid'..i; end
        end
  else
        if ( GetNumPartyMembers() > 0 ) and not ( ignoreParty ) then
            for i=1, GetNumPartyMembers(), 1 do
                if ( UnitIsUnit('partypet'..i, petUnitId) ) then return 'party'..i; end
            end
        end 
    end

    -- Sorry, couldn't resolve :/
    return nil;
end

-- ********************************************************************
-- * DTM_GetUnitTypeFromGUID(guid)                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of who is checked.                             *
-- ********************************************************************
-- * Determinates the unit type of the unit a GUID belongs to.        *
-- * Will either return "npc", "player" or "pet".                     *
-- * "unknown" may be returned in case of erroneous data.             *
-- ********************************************************************
function DTM_GetUnitTypeFromGUID(guid)
    if ( not guid ) then return "unknown"; end
    local typeCreature = tonumber(string.sub(guid, 5, 5), 16);
    local isPlayer = bit.band(typeCreature, 0x00f) == 0;
    local isNPC = bit.band(typeCreature, 0x00f) == 3;
    local isPet = bit.band(typeCreature, 0x00f) == 4;
    if ( isPlayer ) then return "player"; end
    if ( isNPC ) then return "npc"; end
    if ( isPet ) then return "pet"; end
    return "unknown";
end

-- ********************************************************************
-- * DTM_CanHoldThreatList(unit)                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unitId: the unit ID to check.                                 *
-- ********************************************************************
-- * Determinates if an unit can hold a threat list.                  *
-- * Will return nil for any player-controlled entity.                *
-- * Will return nil for ignored/no-threat-list-flagged NPCs.         *
-- * Will return 1 for the rest.                                      *
-- ********************************************************************
function DTM_CanHoldThreatList(unit)
    if ( not unit ) then return nil; end
    if ( not UnitExists(unit) ) then return nil; end
    if ( UnitPlayerControlled(unit) ) then return nil; end

    local noThreatList = DTM_UnitThreatFlags(unit);
    if ( noThreatList == 1 ) then return nil; end

    local guid = UnitGUID(unit);
    if ( DTM_IsMobIgnored(guid) ) then return nil; end

    return 1;
end

-- ********************************************************************
-- * DTM_CanHoldThreatListLimited(guid)                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of who is checked.                             *
-- ********************************************************************
-- * Determinates if an unit can hold a threat list by knowing only   *
-- * its GUID. This function is well suited for combat events parsing *
-- * as it does not involve UIDs that could be not useable.           *
-- ********************************************************************
function DTM_CanHoldThreatListLimited(guid)
    if ( DTM_GetUnitTypeFromGUID(guid) == "player" ) then return nil; end
    if ( DTM_IsMobIgnored(guid) ) then return nil; end
    return 1;
end

-- --------------------------------------------------------------------
-- **                            Handlers                            **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_UnitFlagsChanged(unit)                                       *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit whose flags are changed.                       *
-- ********************************************************************
-- * Gets called when an unit's flags are changed, such as combat     *
-- * state. It's a good occasion to check an unit has changed its     *
-- * combat state.                                                    *
-- ********************************************************************
function DTM_UnitFlagsChanged(unit)
    if not ( unit ) then unit = arg1; end
    if not ( unit ) then return; end

    DTM_UnitCheckCombatChange(unit);
    DTM_CheckUnitReset(unit);
    DTM_SymbolsBuffer_RaidTargetUpdated(unit);
end

-- ********************************************************************
-- * DTM_UnitCheckCombatChange(unit)                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit whose flags are changed.                       *
-- ********************************************************************
-- * Gets called when an unit's flags are changed, such as combat     *
-- * state. It's a good occasion to check an unit has changed its     *
-- * combat state.                                                    *
-- ********************************************************************
function DTM_UnitCheckCombatChange(unit)
    if not ( unit ) then return; end

    DTM_Trace("MAINTENANCE", "Checking [%s] has changed its combat state.", 1, UnitName(unit) or '<?>');

    local guid, combat, previousCombat;

    guid = UnitGUID(unit);
    combat = UnitAffectingCombat(unit);
    previousCombat = DTM_Combat[guid] or nil;

    if ( combat ) and not ( previousCombat ) then
        DTM_UnitBeginCombat(unit);
elseif not ( combat ) and ( previousCombat ) then
        DTM_UnitLeaveCombat(unit);
    end

    DTM_Combat[guid] = combat;
end

-- ********************************************************************
-- * DTM_UnitBeginCombat(unit)                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit who entered combat mode.                       *
-- ********************************************************************
-- * Gets called when a supported unit enters combat mode.            *
-- * Supported units: partyX, raidX, partypetX, raidpetX, player, pet * 
-- ********************************************************************
function DTM_UnitBeginCombat(unit)
    -- Nothing special to do.
end

-- ********************************************************************
-- * DTM_UnitLeaveCombat(unit)                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit who left combat mode.                          *
-- ********************************************************************
-- * Gets called when a supported unit leaves combat mode.            *
-- * Supported units: partyX, raidX, partypetX, raidpetX, player, pet * 
-- ********************************************************************
function DTM_UnitLeaveCombat(unit)
    local leaverGUID = UnitGUID(unit);

    if ( leaverGUID ) then
        -- Delete the data of the unit and everything linked to it.
        -- Time events etc. will be implicitly removed as well.
        DTM_EntityData_DeleteByGUID(leaverGUID);
    end
end

-- ********************************************************************
-- * DTM_PlayerTargetChanged()                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Gets called when local player's target has changed.              *
-- ********************************************************************
function DTM_PlayerTargetChanged()
    DTM_CheckTargetOfUnitChange("player");
    DTM_CheckUnitReset("target");
    DTM_SymbolsBuffer_RaidTargetUpdated("target");
    DTM_RebuildUnitList();
end

-- ********************************************************************
-- * DTM_PlayerFocusChanged()                                         *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Gets called when local player's focus has changed.               *
-- ********************************************************************
function DTM_PlayerFocusChanged()
    DTM_CheckTargetOfUnitChange("focus");
    DTM_CheckUnitReset("focus");
    DTM_SymbolsBuffer_RaidTargetUpdated("focus");
    DTM_RebuildUnitList();
end

-- ********************************************************************
-- * DTM_PlayerMouseoverChanged()                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Gets called when local player's mouseover has changed.           *
-- ********************************************************************
function DTM_PlayerMouseoverChanged()
    DTM_CheckTargetOfUnitChange("mouseover");
    DTM_CheckUnitReset("mouseover");
    DTM_SymbolsBuffer_RaidTargetUpdated("mouseover");
    DTM_RebuildUnitList();
end

-- ********************************************************************
-- * DTM_UnitTargetChanged(unitId)                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unitId: the unit who has changed its target.                  *
-- ********************************************************************
-- * Gets called when an unit's target has changed.                   *
-- ********************************************************************
function DTM_UnitTargetChanged(unitId)
    if not ( unitId ) then unitId = arg1; end

    DTM_CheckTargetOfUnitChange(unitId);
    DTM_CheckTargetOfUnitChange(unitId.."target");
    DTM_SymbolsBuffer_RaidTargetUpdated(unitId.."target");
    DTM_RebuildUnitList();
end
