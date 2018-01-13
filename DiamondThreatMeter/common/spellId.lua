local activeModule = "Spell ID";

-- --------------------------------------------------------------------
-- **                       Spell ID table                           **
-- --------------------------------------------------------------------

local DTM_SpellIdInternals = {
    [0] = "DEFAULT",

    -- Invisibility effects
    [66] = "INVISIBILITY",
    [32612] = "INVISIBILITY_APPLY",

    -- Threat level modifying items "On use" or "On hit"
    [12685] = "STEALTHBLADE",
    [23604] = "BLACK_AMNESTY",
    [25892] = "GRACE_OF_EARTH",
    [32599] = "HYPNOTIST_WATCH",
    [32641] = "MUCK_COVERED_DRAPE",
    [33486] = "JEWEL_OF_CHARISMATIC_MYSTIQUE",
    [35352] = "TIMELAPSE_SHARD",
    [28548] = "SHROUDING_POTION",

    -- Items effects
    [28862] = "EYE_OF_DIMINUTION",
    [26400] = "FETISH_OF_THE_SAND_REAVER",

    -- Lightning bolt from The Lightning Capacitor
    [37661] = "LIGHTNING_CAPACITOR",

    -- NPC effects
    [29232] = "FUNGAL_BLOOM",
    [41520] = "SEETHE",
    [45006] = "WILD_MAGIC",
};

-- --------------------------------------------------------------------
-- **                      Spell ID functions                        **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_GetInternalBySpellId(id)                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> id: the spell/buff ID.                                        *
-- *                                                                  *
-- * Spell IDs are the last way of accurately distinguishing between  *
-- * two spells or effects sharing the same name, such as             *
-- * Invisibility.                                                    *
-- *                                                                  *
-- * IDs are defined for only a few ambigous spells, such as indeed   *
-- * invisibility; do not be surprised if this function returns nil   *
-- * a lot.                                                           *
-- ********************************************************************

function DTM_GetInternalBySpellId(id)
    return DTM_SpellIdInternals[id] or nil;
end