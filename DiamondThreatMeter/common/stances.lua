local activeModule = "Stances";

-- --------------------------------------------------------------------
-- **                         Stances table                          **
-- --------------------------------------------------------------------

--[[
*** Type list:
MULTIPLY_THREAT - The final stance threat coeff is multiplied by a value.
ADDITIVE_THREAT - The final stance threat coeff is added to a value.

*** Target list:
This field is not used for stances. All threat modifications apply on the stance threat multiplier.
]]

-- /!\ Use only internals name in these table, for all fields. /!\
-- See localisation.lua for more details and values.

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
            value = 1.30,    -- WotLK: 1.45
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