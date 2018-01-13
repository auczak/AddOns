local activeModule = "Ignore table";

-- --------------------------------------------------------------------
-- **                         Ignore table                           **
-- --------------------------------------------------------------------

-- Base ignore list and idea was taken from Omen2. Credit goes to Antiarc. :)

-- Mob IDs to completely ignore all threat calculations on, in decimal.
-- This should be things like Crypt Scarabs, which do not have a death message after kamakazing, or
-- other very-low-HP enemies that zerg players and for whom threat data is not important.

-- The reason for this is to prevent getting enemies that despawn (and not die) from getting "stuck"
-- in the threat list for the duration of the fight.

-- Many parts from the original list have been removed to fit DTM inner workings or because the NPC
-- was already explicitly defined as using no threat list in npcAbilities.lua file.

local ignoreTable = {
    -- World
    [19833] = 1,    -- Snake trap snakes
    [19921] = 1,    -- Idem

    -- SSC
    [22250] = 1,    -- Mushrooms >.>
    [21857] = 1,    -- Demons from Leotheras
    [22140] = 1,    -- Toxic spore Bats

    -- Hyjal
    [17967] = 1,    -- Crypt scarabs, used by crypt fiends in Hyjal
    [10577] = 1,    -- More scarabs

    -- Black Temple
    [22841] = 1,    -- Shade of Akama
    [23375] = 1,    -- Shadow demon (Illidan)
    [23254] = 1,    -- Fel geyser (Gurtogg Bloodboil)

    -- Sunwell
    [25214] = 1,    -- Shadow image, Eredar twins
    [25744] = 1,    -- Dark fiend, M'uru encounter

    -- Test
    -- [22095] = 1,
};

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_GetMobID(guid)                                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID to extract the mob ID from.                    *
-- ********************************************************************
-- * Get the mob ID portion of a GUID (returns decimal number).       *
-- ********************************************************************

function DTM_GetMobID(guid)
    if ( not guid ) then return nil; end
    local id = string.sub(guid, -12, -7);
    return tonumber(id, 16) or nil;
end

-- ********************************************************************
-- * DTM_IsMobIgnored(guid)                                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of the mob checked.                            *
-- ********************************************************************
-- * Determinates if a mob is ignored for the threat computations.    *
-- ********************************************************************

function DTM_IsMobIgnored(guid)
    local mobID = DTM_GetMobID(guid);
    if ( not mobID ) then return nil; end
    return ignoreTable[mobID];
end

-- ********************************************************************
-- * DTM_AddMobIgnore(unit)                                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: unit whose threat stuff will be ignored from now on.    *
-- ********************************************************************
-- * Adds temporarily for this game session a mob to the ignore table.*
-- * Good for devs wanting to add on-the-fly mobs in the table.       *
-- * A fake error will be fired to remind the dev calling this API    *
-- * what to add in the permanent ignore table.                       *
-- ********************************************************************

function DTM_AddMobIgnore(unit)
    if not UnitExists(unit) then return; end
    if UnitIsPlayer(unit) then return; end

    local guid = UnitGUID(unit);
    local mobName = UnitName(unit) or '?';
    local mobID = DTM_GetMobID(guid);
    if ( not mobID ) then return; end

    ignoreTable[mobID] = 1;

    -- Remind the dev.
    DTM_ThrowError("MINOR", activeModule, string.format("Dev. reminder:\n\nRemember to add [%s] mob in the ignore table.\n\nIts mobID is: [%s].", mobName, mobID));
end
