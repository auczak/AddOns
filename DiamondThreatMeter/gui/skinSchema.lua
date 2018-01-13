local activeModule = "Skin schema";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                           Skin schema                          **
-- --------------------------------------------------------------------

local DTM_SkinSchema = {
    ["General"] = {
        position = 1,
        ["Alpha"] = {
            position = 1,
            type = "NUMBER",
            object = "SLIDER",
            minValue = 0.00,
            maxValue = 1.00,
            step = 0.01,
        },
        ["Scale"] = {
            position = 2,
            type = "NUMBER",
            object = "SLIDER",
            minValue = 0.20,
            maxValue = 2.00,
            step = 0.02,
        },
        ["LockFrames"] = {
            position = 3,
            type = "BOOLEAN",
            object = "CHECKBOX",
        },
    },

    ["Display"] = {
        position = 2,
        ["BackdropUseTile"] = {
            position = 1,
            type = "BOOLEAN",
            object = "CHECKBOX",
        },
        ["TileTexture"] = {
            position = 2,
            type = "STRING",
            object = "EDITBOX",
            width = 192,
            maxChars = 64,
        },
        ["EdgeTexture"] = {
            position = 3,
            type = "STRING",
            object = "EDITBOX",
            width = 192,
            maxChars = 64,
        },
        ["WidgetTexture"] = {
            position = 4,
            type = "STRING",
            object = "EDITBOX",
            width = 192,
            maxChars = 64,
        },
        ["WidgetPositionX"] = {
            position = 5,
            type = "NUMBER",
            object = "SLIDER",
            minValue = 0.00,
            maxValue = 1.00,
            step = 0.01,
        },
        ["WidgetPositionY"] = {
            position = 6,
            type = "NUMBER",
            object = "SLIDER",
            minValue = -16.00,
            maxValue = 32.00,
            step = 1,
        },
    },

    ["Bars"] = {
        position = 3,
        ["BackgroundTexture"] = {
            position = 1,
            type = "STRING",
            object = "EDITBOX",
            width = 192,
            maxChars = 64,
        },
        ["FillTexture"] = {
            position = 2,
            type = "STRING",
            object = "EDITBOX",
            width = 192,
            maxChars = 64,
        },
        ["ShowSpark"] = {
            position = 3,
            type = "BOOLEAN",
            object = "CHECKBOX",
        },
        ["Smooth"] = {
            position = 4,
            type = "BOOLEAN",
            object = "CHECKBOX",
        },
        ["AggroGraphicEffect"] = {
            position = 5,
            type = "BOOLEAN",
            object = "CHECKBOX",
        },
        ["FadeCoeff"] = {
            position = 6,
            type = "NUMBER",
            object = "SLIDER",
            minValue = 0.00,
            maxValue = 5.00,
            step = 0.05,
        },
        ["SortCoeff"] = {
            position = 7,
            type = "NUMBER",
            object = "SLIDER",
            minValue = 0.00,
            maxValue = 5.00,
            step = 0.05,
        },
    },

    ["Columns"] = {
        position = 4,
        ["Class"] = {
            position = 1,
            type = "COLUMN",
            object = "COLUMN",
            content = "TEXTURE",
        },
        ["Name"] = {
            position = 2,
            type = "COLUMN",
            object = "COLUMN",
            content = "TEXT",
        },
        ["Threat"] = {
            position = 3,
            type = "COLUMN",
            object = "COLUMN",
            content = "TEXT",
        },
        ["TPS"] = {
            position = 4,
            type = "COLUMN",
            object = "COLUMN",
            content = "TEXT",
        },
        ["Percentage"] = {
            position = 5,
            type = "COLUMN",
            object = "COLUMN",
            content = "TEXT",
        },
    },

    ["RegainColumns"] = {
        position = 5,
        ["Class"] = {
            position = 1,
            type = "COLUMN",
            object = "COLUMN",
            content = "TEXTURE",
        },
        ["Name"] = {
            position = 2,
            type = "COLUMN",
            object = "COLUMN",
            content = "TEXT",
        },
        ["Threat"] = {
            position = 3,
            type = "COLUMN",
            object = "COLUMN",
            content = "TEXT",
        },
        ["Relative"] = {
            position = 4,
            type = "COLUMN",
            object = "COLUMN",
            content = "TEXT",
        },
    },

    ["Text"] = {
        position = 6,
        ["ShortFigures"] = {
            position = 1,
            type = "BOOLEAN",
            object = "CHECKBOX",
        },
    },

    ["ThreatList"] = {
        position = 7,
        ["OnlyHostile"] = {
            position = 1,
            type = "BOOLEAN",
            object = "CHECKBOX",
        },
        ["AlwaysDisplaySelf"] = {
            position = 2,
            type = "BOOLEAN",
            object = "CHECKBOX",
        },
        ["DisplayAggroGain"] = {
            position = 3,
            type = "BOOLEAN",
            object = "CHECKBOX",
        },
        ["RaiseAggroToTop"] = {
            position = 4,
            type = "BOOLEAN",
            object = "CHECKBOX",
        },
        ["DisplayLevel"] = {
            position = 5,
            type = "BOOLEAN",
            object = "CHECKBOX",
            needRefresh = 1,
        },
        ["DisplayHealth"] = {
            position = 6,
            type = "BOOLEAN",
            object = "CHECKBOX",
            needRefresh = 1,
        },
        ["Filter"] = {
            position = 7,
            type = "STRING",
            object = "DROPDOWN",
            width = 128,
            dropDownList = {
                [1] = "ALL",
                [2] = "PARTY",
                [3] = "PARTY_ONLY_PLAYERS",
            },
            dropDownString = {
                [1] = "skinSchema-Filter-All",
                [2] = "skinSchema-Filter-Party",
                [3] = "skinSchema-Filter-PartyPlayer",
            },
            dropDownTooltip = {
                [1] = "skinSchema-Filter-All-Tooltip",
                [2] = "skinSchema-Filter-Party-Tooltip",
                [3] = "skinSchema-Filter-PartyPlayer-Tooltip",
            },
        },
        ["CursorTexture"] = {
            position = 8,
            type = "STRING",
            object = "EDITBOX",
            width = 192,
            maxChars = 64,
        },
        ["Rows"] = {
            position = 9,
            type = "NUMBER",
            object = "SLIDER",
            minValue = 2,
            maxValue = DTM_GUI_GetMaxThreatListRows(),
            step = 1,
        },
        ["Length"] = {
            position = 10,
            type = "NUMBER",
            object = "SLIDER",
            minValue = 128.00,
            maxValue = 384.00,
            step = 1.00,
        },
    },

    ["OverviewList"] = {
        position = 8,
        ["Rows"] = {
            position = 1,
            type = "NUMBER",
            object = "SLIDER",
            minValue = 1,
            maxValue = DTM_GUI_GetMaxOverviewListRows(),
            step = 1,
        },
        ["Length"] = {
            position = 2,
            type = "NUMBER",
            object = "SLIDER",
            minValue = 128.00,
            maxValue = 384.00,
            step = 1.00,
        },
    },

    ["RegainList"] = {
        position = 9,
        ["Rows"] = {
            position = 1,
            type = "NUMBER",
            object = "SLIDER",
            minValue = 1,
            maxValue = DTM_GUI_GetMaxRegainListRows(),
            step = 1,
        },
        ["Length"] = {
            position = 2,
            type = "NUMBER",
            object = "SLIDER",
            minValue = 128.00,
            maxValue = 384.00,
            step = 1.00,
        },
    },
};

-- "COLUMN" is a special type.
-- It's a table containing several config info about a threat list's column.
-- Namely:
-- .enabled (boolean)
-- .offset (range: 0~1)
-- .justification (possible values: "LEFT", "RIGHT", "CENTER"), for text columns only (all but "class" one).

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_GetSkinSetting(skinData, category, name)                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> skinData: the skin data to browse.                            *
-- * >> category: the category of the skin setting.                   *
-- * >> name: the name of the skin setting.                           *
-- ********************************************************************
-- * Get the value of a current skin setting.                         *
-- ********************************************************************
function DTM_GetSkinSetting(skinData, category, name)
    if type(skinData) ~= "table" then return nil; end
    if type(category) ~= "string" or type(name) ~= "string" then return nil; end

    local categoryData = DTM_SkinSchema[category];
    if ( categoryData ) and ( skinData[category] ) then
        local settingData = categoryData[name];
        if ( settingData ) then
            return skinData[category][name];
        end
    end
end

-- ********************************************************************
-- * DTM_GetCurrentSkinSetting(category, name)                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> category: the category of the skin setting.                   *
-- * >> name: the name of the skin setting.                           *
-- ********************************************************************
-- * Get the value of a current skin setting.                         *
-- ********************************************************************
function DTM_GetCurrentSkinSetting(category, name)
    local skinData = DTM_GetSkinData(DTM_GetActiveSkin());
    if ( skinData ) then return DTM_GetSkinSetting(skinData, category, name); end
    return nil;
end

-- ********************************************************************
-- * DTM_SkinSchema_GetNumCategories()                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Get the number of categories in the skin schema.                 *
-- ********************************************************************
function DTM_SkinSchema_GetNumCategories()
    local count, k, v = 0, nil, nil;
    for k, v in pairs(DTM_SkinSchema) do
        count = count + 1;
    end
    return count;
end

-- ********************************************************************
-- * DTM_SkinSchema_GetCategoryInfo(index)                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> index: the index of the category.                             *
-- ********************************************************************
-- * Get the name, position and the number of settings inside- of a   *
-- * given category of the skin schema.                               *
-- ********************************************************************
function DTM_SkinSchema_GetCategoryInfo(index)
    local count, k, v = 0, nil, nil;
    for k, v in pairs(DTM_SkinSchema) do
        count = count + 1;
        if ( count == index ) then
            return k, v.position, DTM_SkinSchema_GetNumSettings(k);
        end
    end
    return nil, 0, 0;
end

-- ********************************************************************
-- * DTM_SkinSchema_GetNumSettings(category)                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> category: the category to examine settings of.                *
-- ********************************************************************
-- * Get the number of settings inside of a given category            *
-- * of the skin schema.                                              *
-- ********************************************************************
function DTM_SkinSchema_GetNumSettings(category)
    if type( DTM_SkinSchema[category] ) ~= "table" then return 0; end
    local count, k, v = 0, nil, nil;
    for k, v in pairs(DTM_SkinSchema[category]) do
    if ( k ~= "position" ) then
        count = count + 1;
    end
    end
    return count;
end

-- ********************************************************************
-- * DTM_SkinSchema_GetSettingInfo(category, index)                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> category: the category to examine settings of.                *
-- * >> index: the index of the setting.                              *
-- ********************************************************************
-- * Get data about a given setting in the skin schema.               *
-- *   Returns:                                                       *
-- * 1. The name of the setting.                                      *
-- * 2. Its position in the category.                                 *
-- * 3. The type of data it carries, either NUMBER, BOOLEAN or STRING.*
-- * 4. The setting table itself, in case you need more data from it. *
-- ********************************************************************
function DTM_SkinSchema_GetSettingInfo(category, index)
    if type( DTM_SkinSchema[category] ) ~= "table" then return 0; end
    local count, k, v = 0, nil, nil;
    for k, v in pairs(DTM_SkinSchema[category]) do
    if ( k ~= "position" ) then
        count = count + 1;
        if ( count == index ) then
            return k, v.position, v.type, v;
        end
    end
    end
    return nil, 0, nil, nil;
end

-- --------------------------------------------------------------------
-- **                           Functions                            **
-- --------------------------------------------------------------------

