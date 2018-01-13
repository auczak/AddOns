local activeModule = "Stances (WotLK)";

-- This file contains overides for WotLK Beta DTM version.
-- It will not be run on live clients.

if ( not DTM_OnWotLK() ) then
    return;
end

-- --------------------------------------------------------------------
-- **                         Stances table                          **
-- --------------------------------------------------------------------

local DTM_Stances = {
    -- Druid stances

    ["BEAR"] = {
        class = "DRUID",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 1.30,
        }
    },
    ["CAT"] = {
        class = "DRUID",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 0.71,
        }
    },
    ["MOONKIN"] = {
        class = "DRUID",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 1.00,
        }
    },
    ["TRAVEL"] = {
        class = "DRUID",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 1.00,
        }
    },
    ["AQUATIC"] = {
        class = "DRUID",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 1.00,
        }
    },
    ["FLIGHT"] = {
        class = "DRUID",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 1.00,
        }
    },
    ["TREE"] = {
        class = "DRUID",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 1.00,
        }
    },

    -- Warrior stances

    ["COMBAT"] = {
        class = "WARRIOR",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 0.80,
        }
    },
    ["DEFENSIVE"] = {
        class = "WARRIOR",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 1.45,
        }
    },
    ["BERSERKER"] = {
        class = "WARRIOR",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 0.80,
        }
    },

    -- Internal

    ["DEFAULT"] = {
        class = "INTERNAL",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 1.00,
        }
    },
};

-- --------------------------------------------------------------------
-- **                         Stances functions                      **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Stances_GetData(internalName)                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> internalName: the internal name of the stance.                *
-- ********************************************************************
-- * Get stance data.                                                 *
-- * Returns:                                                         *
-- *   - Class it belongs to (internal name).                         *
-- *   - .effect field of the stance (a table). (See above)           *
-- ********************************************************************

function DTM_Stances_GetData(internalName)
    if ( DTM_Stances[internalName] ) then
        return DTM_Stances[internalName].class, DTM_Stances[internalName].effect;
  else
        return "UNKNOWN", nil;
    end
end