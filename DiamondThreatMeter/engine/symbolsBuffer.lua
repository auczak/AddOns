local activeModule = "Engine symbols buffer";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local COMBATLOG_OBJECT_RAIDTARGET1 = COMBATLOG_OBJECT_RAIDTARGET1 or 0x00100000;
local COMBATLOG_OBJECT_RAIDTARGET2 = COMBATLOG_OBJECT_RAIDTARGET2 or 0x00200000;
local COMBATLOG_OBJECT_RAIDTARGET3 = COMBATLOG_OBJECT_RAIDTARGET3 or 0x00400000;
local COMBATLOG_OBJECT_RAIDTARGET4 = COMBATLOG_OBJECT_RAIDTARGET4 or 0x00800000;
local COMBATLOG_OBJECT_RAIDTARGET5 = COMBATLOG_OBJECT_RAIDTARGET5 or 0x01000000;
local COMBATLOG_OBJECT_RAIDTARGET6 = COMBATLOG_OBJECT_RAIDTARGET6 or 0x02000000;
local COMBATLOG_OBJECT_RAIDTARGET7 = COMBATLOG_OBJECT_RAIDTARGET7 or 0x04000000;
local COMBATLOG_OBJECT_RAIDTARGET8 = COMBATLOG_OBJECT_RAIDTARGET8 or 0x08000000;
local COMBATLOG_OBJECT_SPECIAL_MASK = COMBATLOG_OBJECT_SPECIAL_MASK or 0xFFFF0000;

-- --------------------------------------------------------------------
-- **                               API                              **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SymbolsBuffer_Get(guid)                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the guid of the PC/NPC whose active symbol is queried.  *
-- ********************************************************************
-- * Grab the symbol data of a PC/NPC by its GUID.                    *
-- * 0 if we think the entity has not a symbol active on it.          *
-- ********************************************************************
function DTM_SymbolsBuffer_Get(guid)
    return DTM_Symbols[guid] or 0;
end

-- ********************************************************************
-- * DTM_SymbolsBuffer_GrabUnit(unit)                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit whose symbol is grabbed.                       *
-- ********************************************************************
-- * Grab the symbol currently active on the given unit.              *
-- * Repeated calls of this function will refresh appropriately the   *
-- * current data stored in the buffer.                               *
-- ********************************************************************
function DTM_SymbolsBuffer_GrabUnit(unit)
    if not ( unit ) then return; end
    if not ( UnitExists(unit) ) then return; end
    local symbol = GetRaidTargetIndex(unit);
    local guid = UnitGUID(unit);
    if ( guid ) then
        DTM_Symbols[guid] = symbol;
    end
end

-- ********************************************************************
-- * DTM_SymbolsBuffer_Grab(guid, flags)                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> GUID: the GUID of the guy whose symbol is grabbed.            *
-- * >> flags: the bit table indicating the symbol that's active on   *
-- * this guy. This API should only be used when getting a            *
-- * combat event.                                                    *
-- ********************************************************************
-- * Grab the symbol currently active on someone that's reported in   *
-- * the combat log.                                                  *
-- * Repeated calls of this function will refresh appropriately the   *
-- * current data stored in the buffer.                               *
-- ********************************************************************
function DTM_SymbolsBuffer_Grab(guid, flags)
    if not ( guid ) or not ( flags ) then return; end
    local specialBits = bit.band(flags, COMBATLOG_OBJECT_SPECIAL_MASK);
    local symbol = 0;
    if ( bit.band(specialBits, COMBATLOG_OBJECT_RAIDTARGET1) > 0 ) then symbol = 1; end
    if ( bit.band(specialBits, COMBATLOG_OBJECT_RAIDTARGET2) > 0 ) then symbol = 2; end
    if ( bit.band(specialBits, COMBATLOG_OBJECT_RAIDTARGET3) > 0 ) then symbol = 3; end
    if ( bit.band(specialBits, COMBATLOG_OBJECT_RAIDTARGET4) > 0 ) then symbol = 4; end
    if ( bit.band(specialBits, COMBATLOG_OBJECT_RAIDTARGET5) > 0 ) then symbol = 5; end
    if ( bit.band(specialBits, COMBATLOG_OBJECT_RAIDTARGET6) > 0 ) then symbol = 6; end
    if ( bit.band(specialBits, COMBATLOG_OBJECT_RAIDTARGET7) > 0 ) then symbol = 7; end
    if ( bit.band(specialBits, COMBATLOG_OBJECT_RAIDTARGET8) > 0 ) then symbol = 8; end
    DTM_Symbols[guid] = symbol;
end

-- --------------------------------------------------------------------
-- **                             Functions                          **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SymbolsBuffer_RaidTargetUpdated(unit)                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit who had its raid symbol updated.               *
-- ********************************************************************
-- * Gets called when a supported unit enters combat mode.            *
-- * Supported units: partyX, raidX, partypetX, raidpetX, player, pet * 
-- ********************************************************************
function DTM_SymbolsBuffer_RaidTargetUpdated(unit)
    if not ( unit ) then
        -- No unit passed as argument. Update "standards" units.

        DTM_SymbolsBuffer_GrabUnit("player");
        DTM_SymbolsBuffer_GrabUnit("pet");
        DTM_SymbolsBuffer_GrabUnit("target");
        DTM_SymbolsBuffer_GrabUnit("targettarget");
        DTM_SymbolsBuffer_GrabUnit("focus");
        DTM_SymbolsBuffer_GrabUnit("mouseover");

        local totalIndex = 0;
        local baseUID = nil;
        local i, id;

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
            DTM_SymbolsBuffer_GrabUnit(baseUID..i);
            DTM_SymbolsBuffer_GrabUnit(baseUID.."pet"..i);
            DTM_SymbolsBuffer_GrabUnit(baseUID..i.."target");
        end

        return;
    end
    DTM_SymbolsBuffer_GrabUnit(unit);
end
