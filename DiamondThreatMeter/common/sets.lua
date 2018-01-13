local activeModule = "Sets";

-- --------------------------------------------------------------------
-- **                             Sets table                         **
-- --------------------------------------------------------------------

local list = {
    number = 0,
};

local lookupData = {};

local DTM_Sets = {
    -- Druid sets

    ["THUNDERHEART"] = {
        class = "DRUID",  -- Do not specify class if the sets can be worn by anyone.
        numPieces = 5,
        [1] = 31042,
        [2] = 31034,
        [3] = 31039,
        [4] = 31044,
        [5] = 31048,
    },

    -- Hunter sets
    -- <None>

    -- Mage sets

    ["ARCANIST"] = {
        class = "MAGE",
        numPieces = 8,
        [1] = 16795,
        [2] = 16796,
        [3] = 16797,
        [4] = 16798,
        [5] = 16799,
        [6] = 16800,
        [7] = 16801,
        [8] = 16802,
    },
    ["NETHERWIND"] = {
        class = "MAGE",
        numPieces = 8,
        [1] = 16818,
        [2] = 16912,
        [3] = 16913,
        [4] = 16914,
        [5] = 16915,
        [6] = 16916,
        [7] = 16917,
        [8] = 16918,
    },

    -- Paladin sets
    -- <None>

    -- Priest sets
    -- <None>

    -- Rogue sets

    ["BLOODFANG"] = {
        class = "ROGUE",
        numPieces = 8,
        [1] = 16905,
        [2] = 16906,
        [3] = 16907,
        [4] = 16908,
        [5] = 16909,
        [6] = 16910,
        [7] = 16911,
        [8] = 16832,
    },
    ["BONESCYTHE"] = {
        class = "ROGUE",
        numPieces = 9,
        [1] = 22476,
        [2] = 22477,
        [3] = 22478,
        [4] = 22479,
        [5] = 22480,
        [6] = 22481,
        [7] = 22482,
        [8] = 22483,
        [9] = 23060,
    },

    -- Shaman sets
    -- <None>

    -- Warlock sets

    ["NEMESIS"] = {
        class = "WARLOCK",
        numPieces = 8,
        [1] = 16927,
        [2] = 16928,
        [3] = 16929,
        [4] = 16930,
        [5] = 16931,
        [6] = 16932,
        [7] = 16933,
        [8] = 16834,
    },
    ["PLAGUEHEART"] = {
        class = "WARLOCK",
        numPieces = 9,
        [1] = 22504,
        [2] = 22505,
        [3] = 22506,
        [4] = 22507,
        [5] = 22508,
        [6] = 22509,
        [7] = 22510,
        [8] = 22511,
        [9] = 23063,
    },

    -- Warriors sets

    ["MIGHT"] = {
        class = "WARRIOR",
        numPieces = 8,
        [1] = 16866,
        [2] = 16867,
        [3] = 16868,
        [4] = 16862,
        [5] = 16864,
        [6] = 16861,
        [7] = 16865,
        [8] = 16863,
    },

    -- Testing sets (remove for normal builds)

    --[[
    ["DUMMY_SET"] = {
        class = "ALL",
        numPieces = 2,
        [1] = 29359,
        [2] = 28649,
    },
    ]]
};

-- --------------------------------------------------------------------
-- **                         Sets functions                         **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Sets_GetData(setInternal)                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> setInternal: the internal name of the set.                    *
-- ********************************************************************
-- * Get data about a set.                                            *
-- * Returns:                                                         *
-- *   - Internal name of the class which can use the set. 'ALL' is   *
-- * returned if there is no class restriction.                       *
-- *   - The number of pieces that make up the set.                   *
-- *   - The set table itself, with which you can check if the player *
-- * has the pieces making up the set equipped.                       *
-- ********************************************************************

function DTM_Sets_GetData(setInternal)
    local setData = DTM_Sets[setInternal];

    if ( setData ) then
        return setData.class or 'ALL', setData.numPieces or 0, setData;
    end

    return "UNKNOWN", 0, nil;
end

-- ********************************************************************
-- * DTM_Sets_DoListing(class)                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> class: the class filter. 'ALL' or nil will allow all sets.    *
-- ********************************************************************

function DTM_Sets_DoListing(class)
    for k, v in ipairs(list) do
        list[k] = nil;
    end

    -- Lookup feature to increase performance time.
    local lookupKey = class or "?";
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

    for name, data in pairs(DTM_Sets) do
        matching = 1;

        if ( class ) and ( class ~= 'ALL' ) then
            if ( data.class ~= 'ALL' ) and ( data.class ~= class ) then
                matching = nil;
            end
        end

        if ( matching ) then
            matchFound = matchFound + 1;
            list[matchFound] = name;
            lookupData[lookupKey][matchFound] = name;
        end
    end

    list.number = matchFound;
    lookupData[lookupKey].number = matchFound;
end

-- ********************************************************************
-- * DTM_Sets_GetListSize()                                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Get the size of the list created with the set research           *
-- * function DoListing.                                              *
-- ********************************************************************

function DTM_Sets_GetListSize()
    return list.number or 0;
end

-- ********************************************************************
-- * DTM_Sets_GetListData(index)                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> index: ...of the set in the list to get.                      *
-- ********************************************************************
-- * Get effect data from the list.                                   *
-- * Returns:                                                         *
-- *   - Internal name of the set.                                    *
-- *   - Internal name of the class the set effect belongs to.        *
-- *   - The number of pieces that make up the set.                   *
-- *   - The set table, with which items making it up can be checked. *
-- ********************************************************************

function DTM_Sets_GetListData(index)
    local setInternal = list[index] or "UNKNOWN";
    return setInternal, DTM_Sets_GetData(setInternal);
end
