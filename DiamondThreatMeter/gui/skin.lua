local activeModule = "Skin";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                            Skin data                           **
-- --------------------------------------------------------------------

local DTM_ActiveSkin = nil;

local DTM_DefaultSkins = {
    ["Diamond"] = {
        ["General"] = {
            ["Alpha"] = 1.00,
            ["Scale"] = 1.00,
            ["LockFrames"] = 0,
        },

        ["Display"] = {
            ["BackdropUseTile"] = 1,
            ["TileTexture"] = "",
            ["EdgeTexture"] = "",
            ["WidgetTexture"] = "Diamond\\Diamond32x32",
            ["WidgetPositionX"] = 0.06,
            ["WidgetPositionY"] = 24,
        },

        ["Bars"] = {
            ["BackgroundTexture"] = "Diamond\\RowBackground",
            ["FillTexture"] = "Diamond\\RowBar",
            ["ShowSpark"] = 1,
            ["Smooth"] = 1,
            ["AggroGraphicEffect"] = 1,
            ["FadeCoeff"] = 1.000,
            ["SortCoeff"] = 0.000,
        },

        ["Columns"] = {
            ["Class"]      = { enabled = 1, offset = 0.03, justification = nil      },
            ["Name"]       = { enabled = 1, offset = 0.12, justification = "LEFT"   },
            ["Threat"]     = { enabled = 1, offset = 0.51, justification = "CENTER" },
            ["TPS"]        = { enabled = 1, offset = 0.71, justification = "CENTER" },
            ["Percentage"] = { enabled = 1, offset = 0.92, justification = "CENTER" },
        },

        ["RegainColumns"] = {
            ["Class"]      = { enabled = 1, offset = 0.03, justification = nil      },
            ["Name"]       = { enabled = 1, offset = 0.10, justification = "LEFT"   },
            ["Threat"]     = { enabled = 1, offset = 0.55, justification = "CENTER" },
            ["Relative"]   = { enabled = 1, offset = 0.96, justification = "RIGHT"  },
        },

        ["Text"] = {
            ["ShortFigures"] = 1,
        },

        ["ThreatList"] = {
            ["OnlyHostile"] = 1,
            ["AlwaysDisplaySelf"] = 1,
            ["DisplayAggroGain"] = 0,
            ["RaiseAggroToTop"] = 1,
            ["DisplayLevel"] = 1,
            ["DisplayHealth"] = 1,
            ["Filter"] = "ALL",
            ["CursorTexture"] = "Crystal",
            ["Rows"] = 5,
            ["Length"] = 290,
        },

        ["OverviewList"] = {
            ["Rows"] = 5,
            ["Length"] = 290,
        },

        ["RegainList"] = {
            ["Rows"] = 5,
            ["Length"] = 290,
        },
    },

    ["Diamond Lite"] = {
        ["General"] = {
            ["Alpha"] = 1.00,
            ["Scale"] = 1.00,
            ["LockFrames"] = 0,
        },

        ["Display"] = {
            ["BackdropUseTile"] = 1,
            ["TileTexture"] = "",
            ["EdgeTexture"] = "",
            ["WidgetTexture"] = "",
            ["WidgetPositionX"] = 0,
            ["WidgetPositionY"] = 0,
        },

        ["Bars"] = {
            ["BackgroundTexture"] = "Diamond\\RowBackground",
            ["FillTexture"] = "Diamond\\RowBar",
            ["ShowSpark"] = 1,
            ["Smooth"] = 1,
            ["AggroGraphicEffect"] = 1,
            ["FadeCoeff"] = 1.000,
            ["SortCoeff"] = 0.000,
        },

        ["Columns"] = {
            ["Class"]      = { enabled = 0, offset = 0.00, justification = nil      },
            ["Name"]       = { enabled = 1, offset = 0.03, justification = "LEFT"   },
            ["Threat"]     = { enabled = 1, offset = 0.55, justification = "CENTER" },
            ["TPS"]        = { enabled = 0, offset = 0.00, justification = "CENTER" },
            ["Percentage"] = { enabled = 1, offset = 0.92, justification = "CENTER" },
        },

        ["RegainColumns"] = {
            ["Class"]      = { enabled = 0, offset = 0.00, justification = nil      },
            ["Name"]       = { enabled = 1, offset = 0.03, justification = "LEFT"   },
            ["Threat"]     = { enabled = 1, offset = 0.55, justification = "CENTER" },
            ["Relative"]   = { enabled = 1, offset = 0.96, justification = "RIGHT"  },
        },

        ["Text"] = {
            ["ShortFigures"] = 1,
        },

        ["ThreatList"] = {
            ["OnlyHostile"] = 1,
            ["AlwaysDisplaySelf"] = 1,
            ["DisplayAggroGain"] = 0,
            ["RaiseAggroToTop"] = 1,
            ["DisplayLevel"] = 0,
            ["DisplayHealth"] = 0,
            ["Filter"] = "PARTY",
            ["CursorTexture"] = "Crystal",
            ["Rows"] = 5,
            ["Length"] = 192,
        },

        ["OverviewList"] = {
            ["Rows"] = 5,
            ["Length"] = 192,
        },

        ["RegainList"] = {
            ["Rows"] = 5,
            ["Length"] = 192,
        },
    },

    ["Final Fantasy"] = {
        ["General"] = {
            ["Alpha"] = 1.00,
            ["Scale"] = 1.00,
            ["LockFrames"] = 0,
        },

        ["Display"] = {
            ["BackdropUseTile"] = 0,
            ["TileTexture"] = "FF\\Tile",
            ["EdgeTexture"] = "FF\\Edge",
            ["WidgetTexture"] = "FF\\Logo64x64",
            ["WidgetPositionX"] = 0.10,
            ["WidgetPositionY"] = 11,
        },

        ["Bars"] = {
            ["BackgroundTexture"] = "FF\\RowBackground",
            ["FillTexture"] = "FF\\RowBar",
            ["ShowSpark"] = 0,
            ["Smooth"] = 0,
            ["AggroGraphicEffect"] = 0,
            ["FadeCoeff"] = 1.000,
            ["SortCoeff"] = 0.000,
        },

        ["Columns"] = {
            ["Class"]      = { enabled = 1, offset = 0.03, justification = nil      },
            ["Name"]       = { enabled = 1, offset = 0.12, justification = "LEFT"   },
            ["Threat"]     = { enabled = 1, offset = 0.51, justification = "CENTER" },
            ["TPS"]        = { enabled = 1, offset = 0.71, justification = "CENTER" },
            ["Percentage"] = { enabled = 1, offset = 0.92, justification = "CENTER" },
        },

        ["RegainColumns"] = {
            ["Class"]      = { enabled = 1, offset = 0.03, justification = nil      },
            ["Name"]       = { enabled = 1, offset = 0.10, justification = "LEFT"   },
            ["Threat"]     = { enabled = 1, offset = 0.55, justification = "CENTER" },
            ["Relative"]   = { enabled = 1, offset = 0.96, justification = "RIGHT"  },
        },

        ["Text"] = {
            ["ShortFigures"] = 0,
        },

        ["ThreatList"] = {
            ["OnlyHostile"] = 1,
            ["AlwaysDisplaySelf"] = 1,
            ["DisplayAggroGain"] = 0,
            ["RaiseAggroToTop"] = 1,
            ["DisplayLevel"] = 1,
            ["DisplayHealth"] = 0,
            ["Filter"] = "PARTY_ONLY_PLAYERS",
            ["CursorTexture"] = "FF\\Hand",
            ["Rows"] = 4,
            ["Length"] = 290,
        },

        ["OverviewList"] = {
            ["Rows"] = 4,
            ["Length"] = 290,
        },

        ["RegainList"] = {
            ["Rows"] = 4,
            ["Length"] = 290,
        },
    },

    version = 1.02, -- Skin system version. If it changes, all previous skins will be deleted and restored to default,
                    -- except if a protocol function is defined to assure backward portability to the new version.
};

DTM_Skins = {};

-- N.B: "version" name is reserved in the skins table, and all skins API will refuse to operate on it.

local upgradeProtocol = {
    ["1.01"] = function(updatedSkin, name)
                   -- Category changes

                   updatedSkin["Bars"]["Smooth"] = updatedSkin["Animation"]["Smooth"];
                   updatedSkin["Bars"]["AggroGraphicEffect"] = updatedSkin["Animation"]["AggroGraphicEffect"];
                   updatedSkin["Bars"]["FadeCoeff"] = updatedSkin["Animation"]["FadeCoeff"];
                   updatedSkin["Bars"]["SortCoeff"] = updatedSkin["Animation"]["SortCoeff"];

                   updatedSkin["Animation"]["Smooth"] = nil;
                   updatedSkin["Animation"]["AggroGraphicEffect"] = nil;
                   updatedSkin["Animation"]["FadeCoeff"] = nil;
                   updatedSkin["Animation"]["SortCoeff"] = nil;

                   -- Splitting of settings

                   updatedSkin["ThreatList"]["Length"] = updatedSkin["General"]["Length"];
                   updatedSkin["OverviewList"]["Length"] = updatedSkin["General"]["Length"];
                   updatedSkin["RegainList"]["Length"] = updatedSkin["General"]["Length"];

                   updatedSkin["General"]["Length"] = nil;

                   -- New settings

                   if ( name == "Diamond" ) then
                       updatedSkin["ThreatList"]["DisplayHealth"] = 1;
                 else
                       updatedSkin["ThreatList"]["DisplayHealth"] = 0;
                   end
               end,
};

-- The upgrade protocol defines how to go from a previous version to the current version without using the evil reformat way.

-- --------------------------------------------------------------------
-- **                      Skin Initialisation API                   **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_InitialiseSkinSystem()                                       *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Start up the skin system. This should be called when the GUI is  *
-- * set up. It will check the saved skins version, etc.              *
-- ********************************************************************

function DTM_InitialiseSkinSystem()
    local currentVersion = DTM_DefaultSkins.version or 0.00;
    local savedVersion = DTM_Skins.version;
    local skinSettingsReset = nil;

    -- Check version is OK.
    if not ( savedVersion ) then
        -- Skins table has been formatted. This should occur the first time DTM is run.
        DTM_Skins = {
            version = currentVersion,
        };
  else
        if ( savedVersion ~= currentVersion ) then
            -- Version has changed. Do we have a procedure to upgrade to this version without having to reformat?
            local updateFunction = upgradeProtocol[tostring(savedVersion)];

            if type(updateFunction) == "function" then
                local k, v;
                for k, v in pairs( DTM_Skins ) do
                   if ( k ~= "version" ) then
                        updateFunction(v, k);
                    end
                end

                DTM_Skins.version = currentVersion;
                skinSettingsReset = 2;
          else
                -- Reformats skins table, coz' version has changed and no upgrade protocol is defined.
                DTM_Skins = {
                    version = currentVersion,
                };
                skinSettingsReset = 1;
            end
        end
    end

    -- Check skins table is populated with default skins. Flag them as being "base" skins.
    local k, v;
    for k, v in pairs( DTM_DefaultSkins ) do
        if not ( DTM_Skins[k] ) then
            -- This entry doesn't exist in skins table. Insert it.
            DTM_SaveSkinData(k, v, 1);
        end
    end

    -- Choose the initial skin to use.
    DTM_SelectSkin(DTM_GetSavedVariable("gui", "skinUsed", "active"));
    DTM_GUI_OnSkinEvent("SKIN_UPDATED");

    return skinSettingsReset;
end

-- --------------------------------------------------------------------
-- **                         Skin General API                       **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SaveSkinData(name, data, isBase)                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the skin.                                   *
-- * >> data: reference to the table containing the skin data.        *
-- * >> isBase: a flag whether this skin is a base one or not.        *
-- * NOTE: isBase should only be used by the skin system boot up func.*
-- ********************************************************************
-- * Saves new data about a skin. If the active skin is modified,     *
-- * the GUI will be acknowledged of the change through an event.     *
-- ********************************************************************

function DTM_SaveSkinData(name, data, isBase)
    if type(name) ~= "string" or type(data) ~= "table" then return; end
    if ( name == "version" ) then return nil; end -- Illegal.

    DTM_Skins[name] = DTM_CopyTable(data);
    DTM_Skins[name].isBase = isBase or nil;

    if ( name == DTM_GetActiveSkin() ) then DTM_GUI_OnSkinEvent("SKIN_REFRESH"); end
end

-- ********************************************************************
-- * DTM_GetSkinData(name)                                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the skin.                                   *
-- ********************************************************************
-- * This function will get the raw data table of a skin.             *
-- ********************************************************************

function DTM_GetSkinData(name)
    if type(name) ~= "string" then return nil; end
    if ( name == "version" ) then return nil; end -- Illegal.

    if ( DTM_Skins[name] ) then
        return DTM_Skins[name];
    end

    return nil;
end

-- --------------------------------------------------------------------
-- **                        Skin Management API                     **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_DeleteSkin(name)                                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the skin.                                   *
-- ********************************************************************
-- * Delete a skin. This function will silently fail if you try to    *
-- * remove a base skin.                                              *
-- * Returns 1 if operation successful, nil if not.                   *
-- ********************************************************************

function DTM_DeleteSkin(name)
    if type(name) ~= "string" then return nil; end
    if ( name == "version" ) then return nil; end -- Illegal.

    local result = nil;

    if ( DTM_Skins[name] ) then
        if not ( DTM_Skins[name].isBase ) then
            -- Okay. Delete it.
            DTM_Skins[name] = nil;
            DTM_GUI_OnSkinEvent("SKIN_UPDATED");
            result = 1;
        end
    end

    -- Make sure active skin is still valid.
    DTM_SelectSkin(DTM_GetActiveSkin());

    return result;
end

-- ********************************************************************
-- * DTM_RestoreSkin(name)                                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the skin.                                   *
-- ********************************************************************
-- * Will restore a skin to its defaults. This function will silently *
-- * fail if you do not target a base skin.                           *
-- * Returns 1 if operation successful, nil if not.                   *
-- ********************************************************************

function DTM_RestoreSkin(name)
    if type(name) ~= "string" then return nil; end
    if ( name == "version" ) then return nil; end -- Illegal.

    if ( DTM_Skins[name] and DTM_DefaultSkins[name] ) then
        DTM_SaveSkinData(name, DTM_DefaultSkins[name], 1);
        DTM_GUI_OnSkinEvent("SKIN_UPDATED");
        return 1;
    end

    return nil;
end

-- ********************************************************************
-- * DTM_RenameSkin(name, newName)                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the skin.                                   *
-- * >> newName: the new name to give to the skin.                    *
-- ********************************************************************
-- * This function will rename a skin. Will not work on base skins.   *
-- * Returns 1 if operation successful, nil if not.                   *
-- ********************************************************************

function DTM_RenameSkin(name, newName)
    if type(name) ~= "string" or type(newName) ~= "string" then return nil; end
    if ( name == "version" or newName == "version" ) then return nil; end -- Illegal.

    if ( DTM_Skins[name] ) then
        local redirectActiveSkin = nil;
        if ( DTM_GetActiveSkin() == name ) then redirectActiveSkin = 1; end

        DTM_Skins[newName] = DTM_Skins[name];
        DTM_Skins[name] = nil;

        if ( redirectActiveSkin ) then
            DTM_SelectSkin(newName);
        end

        DTM_GUI_OnSkinEvent("SKIN_UPDATED");
        return 1;
    end

    return nil;
end

-- ********************************************************************
-- * DTM_CopySkin(name, newName)                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the skin to copy.                           *
-- * >> newName: the name to give to the new skin.                    *
-- ********************************************************************
-- * This function will copy a skin. In case a base skin is copied,   *
-- * its base flag will not carry over to the new skin.               *
-- * Returns 1 if operation successful, nil if not.                   *
-- ********************************************************************

function DTM_CopySkin(name, newName)
    if type(name) ~= "string" or type(newName) ~= "string" then return nil; end
    if ( name == "version" or newName == "version" ) then return nil; end -- Illegal.

    if ( DTM_Skins[newName] ) then
        return nil; -- May not erase an existing skin.
    end

    if ( DTM_Skins[name] ) then
        DTM_SaveSkinData(newName, DTM_Skins[name], nil);

        DTM_GUI_OnSkinEvent("SKIN_UPDATED");
        return 1;
    end


    return nil;
end

-- --------------------------------------------------------------------
-- **                          Skin Listing API                      **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_GetNumSkins()                                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Get the number of defined skins.                                 *
-- ********************************************************************

function DTM_GetNumSkins()
    local count, name, data;
    count = 0;
    for name, data in pairs(DTM_Skins) do
        if ( name ~= "version" and type(data) == "table" ) then
            count = count + 1;
        end
    end
    return count;
end

-- ********************************************************************
-- * DTM_GetSkinInfo(index)                                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> index: index of the skin in the list.                         *
-- ********************************************************************
-- * Get basic infos about a skin.                                    *
-- * Returns name, isBase.                                            *
-- ********************************************************************

function DTM_GetSkinInfo(index)
    local count, name, data;
    count = 0;
    for name, data in pairs(DTM_Skins) do
        if ( name ~= "version" and type(data) == "table" ) then
            count = count + 1;
            if ( count == index ) then
                return name, data.isBase;
            end
        end
    end
    return nil, nil;
end

-- --------------------------------------------------------------------
-- **                         Skin Selection API                     **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SelectSkin(name)                                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the skin to use.                            *
-- ********************************************************************
-- * Select the skin to use. If name is invalid, the first base skin  *
-- * encountered will be used instead.                                *
-- * An event will be fired to acknowledge the GUI of the change.     *
-- ********************************************************************

function DTM_SelectSkin(name)
    if ( type(name) ~= "nil" and type(name) ~= "string" ) then return; end
    if ( name == "version" ) then return; end -- Illegal.

    local oldActiveSkin = DTM_ActiveSkin;

    -- Check the enabled skin for the active profile is valid. If not, choose a default skin.

    if ( name ) then
        if ( DTM_Skins[name] ) then
            DTM_ActiveSkin = name;
            DTM_SetSavedVariable("gui", "skinUsed", DTM_ActiveSkin, "active");

            if ( oldActiveSkin ~= DTM_ActiveSkin ) then
                DTM_GUI_OnSkinEvent("SKIN_REFRESH");
            end

            return;
        end
    end

    -- Ok we have to choose a base skin then. Use the first one encountered.

    local name, data;
    for name, data in pairs(DTM_Skins) do
        if ( name ~= "version" and type(data) == "table" ) then
            if ( data.isBase ) then
                DTM_ActiveSkin = name;
                DTM_SetSavedVariable("gui", "skinUsed", DTM_ActiveSkin, "active");

                if ( oldActiveSkin ~= DTM_ActiveSkin ) then
                    DTM_GUI_OnSkinEvent("SKIN_REFRESH");
                end

                return;
            end
        end
    end
end

-- ********************************************************************
-- * DTM_GetActiveSkin()                                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Return the name of the skin that is currently being used.        *
-- ********************************************************************

function DTM_GetActiveSkin()
    return DTM_ActiveSkin;
end
