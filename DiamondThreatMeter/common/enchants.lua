local activeModule = "Enchants";

-- --------------------------------------------------------------------
-- **                       Enchants table                           **
-- --------------------------------------------------------------------

--[[
Enchants always affect the final itemModifier in a multiplicative fashion.
Note that DTM considers gems/sockets and enchants are similar and use the same table and mechanics.
]]

local DTM_Enchants = {
    [2613] = 1.02,  -- +2% Threat Enchant
    [2832] = 0.98,  -- 2% Less Threat Meta-gem
};

-- --------------------------------------------------------------------
-- **                      Enchants functions                        **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Enchants_GetCoefficient(enchantId)                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> enchantId: the enchant ID.                                    *
-- *                                                                  *
-- * Returns threat coefficient of an enchant with given ID.          *
-- ********************************************************************

function DTM_Enchants_GetCoefficient(enchantId)
    return DTM_Enchants[enchantId] or 1.00;
end

-- ********************************************************************
-- * DTM_Enchants_GetItemEnchantCoefficient(itemString)               *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> itemString: the examined itemString.                          *
-- *                                                                  *
-- * Computes the enchantModifier of the given itemString, by getting *
-- * gems and enchants active in the given itemString.                *
-- ********************************************************************

function DTM_Enchants_GetItemEnchantCoefficient(itemString)
    local _, _, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, _, _ = strsplit(":", itemString);
    local enchantCoeff, jewelCoeff1, jewelCoeff2, jowelCoeff3, jewelCoeff4;

    enchantCoeff = DTM_Enchants_GetCoefficient(tonumber(enchantId));
    jewelCoeff1 = DTM_Enchants_GetCoefficient(tonumber(jewelId1));
    jewelCoeff2 = DTM_Enchants_GetCoefficient(tonumber(jewelId2));
    jewelCoeff3 = DTM_Enchants_GetCoefficient(tonumber(jewelId3));
    jewelCoeff4 = DTM_Enchants_GetCoefficient(tonumber(jewelId4));

    return enchantCoeff * jewelCoeff1 * jewelCoeff2 * jewelCoeff3 * jewelCoeff4;
end
