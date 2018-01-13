local activeModule = "Powertypes";

-- --------------------------------------------------------------------
-- **                          Powertypes table                      **
-- --------------------------------------------------------------------

local DTM_Powertypes = {
    ["DAMAGE_HP"] = 1.000,
    ["DAMAGE_MP"] = 0.500,
    ["DAMAGE_EP"] = 0.000,
    ["DAMAGE_RP"] = 0.000,

    ["HEAL_HP"] = 0.500,
    ["HEAL_MP"] = 0.500,
    ["HEAL_EP"] = 0.000, -- Having doubts on this one.
    ["HEAL_RP"] = 5.000,

    ["LEECH_MP"] = 0.500,
};

-- --------------------------------------------------------------------
-- **                        Powertypes functions                    **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Powertype_GetThreatRate(outcome, powertype)                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> outcome: the outcome type involved. (DAMAGE/LEECH/HEAL)       *
-- * >> powertype: the powertype to get the threat:powertype ratio.   *
-- ********************************************************************
-- * Gets the threat ratio for a given powertype.                     *
-- ********************************************************************

function DTM_Powertype_GetThreatRate(outcome, powertype)
    if not ( outcome ) or not ( powertype ) then return 0.000; end
    return DTM_Powertypes[outcome.."_"..powertype] or 0.000;
end

