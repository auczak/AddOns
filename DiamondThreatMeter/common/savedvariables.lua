local activeModule = "Saved variables";

-- --------------------------------------------------------------------
-- **                    Saved variables data                        **
-- --------------------------------------------------------------------

local modifiedProfile = "none";

local DTM_DefaultSavedVariables = {
    ["system"] = {
        ["noTemporaryStop"] = 0,
        ["versionCheckReminder"] = 0,

        ["notFirstRun:1.6.0"] = 0,
        ["roleChosenOnce"] = 0,
    },

    ["engine"] = {
        ["run"] = 1,

        -- Can be either "HYBRID", "NATIVE" or "PARSE".
        ["workMethod"] = "HYBRID",

        ["selfGearUpdateInterval"] = 10.000,
        ["selfTalentsUpdateInterval"] = 60.000,
        ["stanceNotifyInterval"] = 10.000,
        ["statsUpdateInterval"] = 5.000,
        ["talentsNotifyInterval"] = 60.000,
        ["gearUpdateInterval"] = 15.000, -- We'll refresh gear of nearby party/raid members every 15 sec.
        ["talentsOutdatedThreshold"] = 900.00, -- We'll refresh one's talents only 900 sec. after getting them for the first time.

        ["detectUnitReset"] = 1,
        ["checkOutdatedInterval"] = 5.000,
        ["outdatedThreshold"] = 600.00,      -- Time before wiping data of an entity we haven't heard anything about for X sec.
        ["outdatedThresholdEmpty"] = 60.00,  -- Same thing as outdatedThreshold, except this value is used instead when entity's threat list is empty.

        ["aggroValidationDelay"] = 0.000, -- It can be specifically set on NPCs. In such cases, this variable is ignored.
        ["checkZoneWideCombat"] = 5.000, -- The amount of time (after the end of the last check) to wait before performing a zonewide combat check while in a raid/party. 0=OFF.
        ["tpsUpdateRate"] = 2.000, -- Time amount between each global recomputation of TPS data. 0=OFF.

        ["unitListUpdateInterval"] = 3.000, -- The interval between forcefully updating the unit list, checking for combat state change in the same time.

        ["emulation:ThreatLib2"] = 1,
        ["spoof:ThreatLib2"] = 0,
        ["emulation:KTM"] = 0,
        ["spoof:KTM"] = 0,
    },

    ["gui"] = {
        ["run"] = 1,

        -- This config var determinates when to auto-show the target threat list frame. Can be ALWAYS, JOIN_PARTY, ENTER_COMBAT or NEVER.
        ["autoDisplayTarget"] = "ALWAYS",
        -- This config var determinates when to auto-show the focus threat list frame. Can be ALWAYS, ON_CHANGE or NEVER.
        ["autoDisplayFocus"] = "ON_CHANGE",
        -- This config var determinates when to auto-show the overview list frame. Can be ALWAYS, JOIN_PARTY, ENTER_COMBAT or NEVER.
        ["autoDisplayOverview"] = "NEVER",
        -- This config var determinates when to auto-show the regain list frame. Can be ALWAYS, JOIN_PARTY, ENTER_COMBAT or NEVER.
        ["autoDisplayRegain"] = "NEVER",

        ["bossWarning"] = 1,

        -- This key specifies when warnings should be enabled. The syntax is as follow:
        -- <BOSS/ELITE/NORMAL>_<Number>, where number can be <-A> or <A>, where A is the result of (NPCLevel - MyLevel).
        ["warningThreshold"] = "ELITE_2",

        ["warningPosX"] = 0.500,
        ["warningPosY"] = 0.300,
        ["warningSound"] = "WEIRD",
        ["warningLimit"] = 20,
        ["warningCancelLimit"] = 30,

        ["skinUsed"] = "Diamond",

        ["ringButtonX"] = "UNSET",
        ["ringButtonY"] = "UNSET",
        ["ringButtonParent"] = "UNSET",

        ["nameplatesBarDisplay"] = 0,
    },

    ["profiles"] = {},

    ["version"] = 1.3,
};

-- WotLK: Quick hack till 3.0.1 release to prevent TBC clients from choosing HYBRID setting as default.
if ( not DTM_OnWotLK() ) then
    DTM_DefaultSavedVariables["engine"]["workMethod"] = "PARSE";
end

DTM_SavedVariables = {};

-- --------------------------------------------------------------------
-- **                   SavedVariables functions                     **
-- --------------------------------------------------------------------

-- *** Saved vars basic operations and management ***

-- ********************************************************************
-- * DTM_GetSavedVariable(part, key, profileMode, noError)            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> part: which side of DTM the data to fetch is stored into.     *
-- * Can be "engine", "gui" or "system".                              *
-- * >> key: what data to retrieve. If it is not found on SavedVars   *
-- * table, DTM will search into DefaultSavedVars. If still not       *
-- * found, nil will be returned.                                     *
-- * >> profileMode: whether this data can be character specific or   *
-- * not. You can provide nil, "none", "active" or "modified". If     *
-- * "active" is provided, the data will be read for the currently    *
-- * logged-in character. If "modified" is provided, the data will be *
-- * read for the currently edited character profile.                 *
-- * >> noError: if set, the case of a "nil" value will be deemed O.K *
-- * by the system and will not fire an error.                        *
-- ********************************************************************
-- * Returns a saved variable value (a variable which is "remembered" *
-- * between each game session).                                      *
-- ********************************************************************

function DTM_GetSavedVariable(part, key, profileMode, noError)
    local partdata = DTM_SavedVariables[part];
    local defaultpartdata = DTM_DefaultSavedVariables[part];

    if ( partdata ) then
        if ( profileMode == "active" or profileMode == "modified" ) then
            local name, server, prefix;
            if ( profileMode == "active" ) then
                name, server, prefix = DTM_GetActiveProfile();
          else
                name, server, prefix = DTM_GetModifiedProfile();
            end
            if ( partdata[prefix..key] ) then
                return partdata[prefix..key];
            end
        end
        if ( partdata[key] ) then
            return partdata[key];
        end
    end

    if ( defaultpartdata ) and ( defaultpartdata[key] ) then
        return defaultpartdata[key];
    end

    if ( not noError ) then
        DTM_ThrowError("MAJOR", activeModule, string.format('Could not read "%s" saved variable in "%s" part (%s profile mode).', key, part, tostring(profileMode)));
    end
    return nil;
end

-- ********************************************************************
-- * DTM_SetSavedVariable(part, key, value, profileMode)              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> part: which side of DTM data will be stored into.             *
-- * (either "engine", "gui" or "system")                             *
-- * >> key: where to store data.                                     *
-- * >> value: self-explanatory.                                      *
-- * >> profileMode: whether the modified data is character specific  *
-- * or not. You can provide nil, "none", "active" or "modified". If  *
-- * "active" is provided, the data will be set for the currently     *
-- * logged-in character. If "modified" is provided, the data will be *
-- * set for the currently edited character profile.                  *
-- ********************************************************************
-- * Changes a saved variable value.                                  *
-- ********************************************************************

function DTM_SetSavedVariable(part, key, value, profileMode)
    if not ( DTM_SavedVariables[part] ) then DTM_SavedVariables[part] = {}; end
    if ( profileMode == "active" or profileMode == "modified" ) then
        local name, server, prefix;
        if ( profileMode == "active" ) then
            name, server, prefix = DTM_GetActiveProfile();
      else
            name, server, prefix = DTM_GetModifiedProfile();
        end
        DTM_SavedVariables[part][prefix..key] = value;
  else
        DTM_SavedVariables[part][key] = value;
    end
    return 1;
end

-- ********************************************************************
-- * DTM_GetSavedVariablesDirectAccess(part)                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> part: which side of DTM data to get direct access of.         *
-- ********************************************************************
-- * Directly access saved variables' table of a given part of DTM.   *
-- ********************************************************************

function DTM_GetSavedVariablesDirectAccess(part)
    if not ( DTM_SavedVariables[part] ) then DTM_SavedVariables[part] = {}; end
    return DTM_SavedVariables[part];
end

-- ********************************************************************
-- * DTM_GetDefaultSavedVariable(part, key)                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> part: which side of DTM data is stored into. (either          *
-- * "engine", "gui" or "system")                                     *
-- * >> key: what data to retrieve.                                   *
-- ********************************************************************
-- * Returns the default value of a saved variable.                   *
-- ********************************************************************

function DTM_GetDefaultSavedVariable(part, key)
    local defaultpartdata = DTM_DefaultSavedVariables[part];

    if ( defaultpartdata ) and ( defaultpartdata[key] ) then
        return defaultpartdata[key];
    end

    DTM_ThrowError("MAJOR", activeModule, string.format('Could not read default value of "%s" saved variable in "%s" part.', key, part));
    return nil;
end

-- ********************************************************************
-- * DTM_CheckSavedVariablesVersion()                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * None                                                             *
-- ********************************************************************
-- * Compares saved variables defaults' version with saved variables' *
-- * version. If there is a difference, clear saved variables and     *
-- * return 1.                                                        *
-- ********************************************************************

function DTM_CheckSavedVariablesVersion()
    local currentVersion = DTM_DefaultSavedVariables.version;
    local savedVersion = DTM_SavedVariables.version;

    if not ( currentVersion ) then
        DTM_ThrowError("CRITICAL", activeModule, "No version field was found in DTM_DefaultSavedVariables table!");
        return nil;
    end

    if not ( savedVersion ) then
        -- Saved variables table has been formatted. This should occur the first time DTM is run.
        DTM_SavedVariables = {
            version = currentVersion,
            ["engine"] = {},
            ["gui"] = {},
            ["system"] = {},
        };
        return nil;
  else
        if ( savedVersion ~= currentVersion ) then
            -- Reformats saved variables table, coz' version has changed.
            DTM_SavedVariables = {
                version = currentVersion,
                ["engine"] = {},
                ["gui"] = {},
                ["system"] = {},
            };
            -- And also informs the caller.
            return 1;
        end
    end

    return nil;
end

-- ********************************************************************
-- * DTM_ClearSavedVariables()                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * None                                                             *
-- ********************************************************************
-- * Clear all saved variables and formats a new saved vars table.    *
-- ********************************************************************

function DTM_ClearSavedVariables()
    DTM_SavedVariables = { };
    DTM_CheckSavedVariablesVersion();
end

-- *** Profile management ***

-- ********************************************************************
-- * DTM_GetActiveProfile()                                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Get the profile which will be used for the profile mode "active" *
-- * in saved vars read/write accesses.                               *
-- * Returns name, server and prefix.                                 *
-- ********************************************************************

function DTM_GetActiveProfile()
    local name = UnitName("player");
    local server = GetRealmName();
    local prefix = name.."/"..server.."|";
    return name, server, prefix;
end

-- ********************************************************************
-- * DTM_GetModifiedProfile()                                         *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Get the profile which will be used for the profile mode          *
-- * "modified" in saved vars read/write accesses.                    *
-- * Returns name, server and prefix. It will be the active profile   *
-- * if not specifically changed since the login on the game server.  *
-- ********************************************************************

function DTM_GetModifiedProfile()
    if ( type(modifiedProfile) == "number" ) then
        modifiedProfile = math.floor(modifiedProfile);
        if ( modifiedProfile > 0 and modifiedProfile <= DTM_GetNumProfiles() ) then
            return DTM_GetProfileInfo(modifiedProfile);
        end
    end

    if ( type(modifiedProfile) == "string" ) and ( modifiedProfile ~= "none" ) then
        local _, _, name, server = string.find(modifiedProfile, "(.+)%/(.+)");
        if ( name and server ) then
            return name, server, name.."/"..server.."|";
        end
    end

    return DTM_GetActiveProfile();
end

-- ********************************************************************
-- * DTM_SetModifiedProfile(index)                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> index: the index in the profile list. You can also provide    *
-- * a string of the format "NNNNN/SSSSS" where NNNNN is the name of  *
-- * the character and SSSSS its realm.                               *
-- ********************************************************************
-- * Set the profile which will be used for savedvars write accesses. *
-- * Returns 1 if the modified profile has been successfully changed. *
-- ********************************************************************

function DTM_SetModifiedProfile(index)
    if ( type(index) == "string" ) then
        local _, _, name, server = string.find(index, "(.+)%/(.+)");
        if ( name and server ) then
            modifiedProfile = name.."/"..server;
            return 1;
        end
    end

    if ( type(index) == "number" ) then
        index = math.floor(index);
        if ( index > 0 and index <= DTM_GetNumProfiles() ) then
            modifiedProfile = index;
            return 1;
        end
    end

    return nil;
end

-- ********************************************************************
-- * DTM_GetNumProfiles()                                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Get the number of profiles known by DTM.                         *
-- ********************************************************************

function DTM_GetNumProfiles()
    if not ( DTM_SavedVariables["profiles"] ) then DTM_SavedVariables["profiles"] = {}; end
    return #DTM_SavedVariables["profiles"];
end

-- ********************************************************************
-- * DTM_GetProfileInfo(index)                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> index: the index in the profile list.                         *
-- ********************************************************************
-- * Get the number of profiles known by DTM.                         *
-- ********************************************************************

function DTM_GetProfileInfo(index)
    if ( type(index) == "number" ) then
        index = math.floor(index);
        if ( index > 0 and index <= DTM_GetNumProfiles() ) then
            local profileString = DTM_SavedVariables["profiles"][index];
            local _, _, name, server = string.find(profileString, "(.+)%/(.+)");
            if ( name and server ) then
                return name, server, name.."/"..server.."|";
            end
        end
    end

    return "INVALID", "INVALID", "?/?|";
end

-- ********************************************************************
-- * DTM_UpdateProfile()                                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Ensure active character is in the profile list. This API should  *
-- * be called once at startup of any game session.                   *
-- * Returns 1 if the active character profile has been created.      *
-- * In this case, the second return is the name of the character     *
-- * whose profile just got created.                                  *
-- ********************************************************************

function DTM_UpdateProfile()
    local name, server, _ = DTM_GetActiveProfile();
    local p, pName, pServer;
    for p=1, DTM_GetNumProfiles() do
        pName, pServer, _ = DTM_GetProfileInfo(p);
        if ( pName == name and pServer == server ) then
            return nil;
        end
    end
    DTM_SavedVariables["profiles"][#DTM_SavedVariables["profiles"] + 1] = name.."/"..server;
    return 1, string.format("%s (%s)", name, server);
end