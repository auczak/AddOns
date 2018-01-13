local activeModule = "Items";

-- --------------------------------------------------------------------
-- **                            Items table                         **
-- --------------------------------------------------------------------

local list = {
    number = 0,
};

local lookupData = {};

-- Please just list items with PASSIVE threat modifying effects.
-- That is, items you can USE to modify your threat level shouldn't be listed there, but in Abilities.lua instead, with "ITEM" as class.

--[[
*** Type list:
MULTIPLY_THREAT - The threat is multiplied by a coefficient. Coefficient can vary between ranks.
ADDITIVE_THREAT - A fixed value is added to threat, which can vary between ranks.
BASE_THREAT - The base threat is modified by a flat value. If initial base threat is > 0 then it won't be able to pass below the 0 threat threshold.
FINAL_THREAT - The final threat (after all multipliers are applied) is modified by a flat value. This type follows same threshold rules as BASE_THREAT.

*** Target list:
GLOBAL_THREAT - The item modifies the global threat multiplier of _INCOMING_ threatening actions.
ABILITIES - The item modifies the threat multiplier of some specific abilities.

*** Conditions:
[NO]SPECIAL:X - X can be CRITICAL, CRUSHING or GLANCING. The effect only operates in case of a special hit [or not].
[NO]TIMING:X - X can be INSTANT or OVERTIME.

]]

-- /!\ Use only item IDs in this table for keys. Use internal name for effect field's content. /!\
-- See localisation.lua for more details and values.

local DTM_Items = {
    [30621] = {
        name = "PRISM_OF_INNER_CALM",
        effect = {
            type = "BASE_THREAT",
            value = -1000,
            target = "GLOBAL_THREAT",
            condition = "SPECIAL:CRITICAL",
        }
    },
    --[[ For melee version... Well how should I implement this ?
    [30621] = {
        name = "PRISM_OF_INNER_CALM_MELEE",
        effect = {
            type = "BASE_THREAT",
            value = -150,
            target = "GLOBAL_THREAT",
            condition = "SPECIAL:CRITICAL",
        }
    },
    ]]

    -- Test entries (remove for normal builds)

    --[[
    [29359] = {
        name = "DUMMY",
        effect = {
            type = "BASE_THREAT",
            value = 2000,
            target = "ABILITIES",
            abilities = {
                number = 1,
                [1] = "MANGLE_BEAR",
            },
            condition = "NOSPECIAL:CRITICAL",
        }
    }
    ]]
};

-- --------------------------------------------------------------------
-- **                         Items functions                        **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Items_GetData(itemId)                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> itemId: the item ID of the item to get infos from.            *
-- ********************************************************************
-- * Get data of an effect.                                           *
-- * Returns:                                                         *
-- *   - Internal name of the item.                                   *
-- *   - .effect field of the item (a table). (See above)             *
-- ********************************************************************

function DTM_Items_GetData(itemId)
    local itemData = DTM_Items[itemId];

    if ( itemData ) then
        return itemData.name, itemData.effect;
    end

    return "UNKNOWN", nil;
end


-- ********************************************************************
-- * DTM_Items_DoListing(effect, target, ability)                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> effect: the effect the item must have to be listed.           *
-- * >> target: what the item must affect to be listed.               *
-- * >> ability: the ability the item must affect to be listed.       *
-- ********************************************************************

function DTM_Items_DoListing(effect, target, ability)
    for k, v in ipairs(list) do
        list[k] = nil;
    end

    -- Lookup feature to increase performance time.
    local lookupKey = (effect or "?")..":"..(target or "?")..":"..(ability or "?");
    local lookupTable = lookupData[lookupKey];
    if ( lookupTable ) then
        list.number = lookupTable.number;
        local i;
        for i=1, list.number do
            list[i] = lookupTable[i];
        end
        return;
    end

    -- Lookup not found, we'll do it this call.
    lookupData[lookupKey] = {};

    local matchFound = 0;
    local matching;

    for id, data in pairs(DTM_Items) do
        local itemEffect = data.effect;

        matching = 1;

        if ( effect ) then
            if ( itemEffect.type ~= effect ) then
                matching = nil;
            end
        end

        if ( target ) then
            if ( itemEffect.target ~= target ) then
                matching = nil;
            end
        end

        local abilityData = itemEffect.abilities;
        if ( ability ) and ( abilityData ) then
            found = nil;
            for i=1, (abilityData.number or 0) do
                if abilityData[i] == ability then
                    found = 1;
                    break;
                end
            end
            if not found then
                matching = nil;
            end
        end
        if ( ability ) and not ( abilityData ) then matching = nil; end

        if ( matching ) then
            matchFound = matchFound + 1;
            list[matchFound] = id;
            lookupData[lookupKey][matchFound] = id;
        end
    end

    list.number = matchFound;
    lookupData[lookupKey].number = matchFound;
end

-- ********************************************************************
-- * DTM_Items_GetListSize()                                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Get the size of the list created with the item research          *
-- * function DoListing.                                              *
-- ********************************************************************

function DTM_Items_GetListSize()
    return list.number or 0;
end

-- ********************************************************************
-- * DTM_Items_GetListData(index)                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> index: ...of the item in the list to get.                     *
-- ********************************************************************
-- * Get effect data from the list.                                   *
-- * Returns:                                                         *
-- *   - Item ID of the item.                                         *
-- *   - Internal name of the item.                                   *
-- *   - .effect field of the item (a table). (See above)             *
-- ********************************************************************

function DTM_Items_GetListData(index)
    local itemId = list[index] or 0;
    return itemId, DTM_Items_GetData(itemId);
end