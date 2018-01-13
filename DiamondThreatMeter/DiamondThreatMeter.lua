-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          COMMON PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local DTM_EmergencyStop = nil;

local rolePresets = {
    ["TANK"] = {
        translationKey = "RoleTank",
        collisionKey = "RoleTankMatches",
        ["gui:autoDisplayTarget"] = "JOIN_PARTY",
        ["gui:autoDisplayOverview"] = "NEVER",
        ["gui:autoDisplayRegain"] = "JOIN_PARTY",
        ["gui:bossWarning"] = 0,
    },
    ["DAMAGE"] = {
        translationKey = "RoleDamageDealer",
        collisionKey = "RoleDamageDealerMatches",
        ["gui:autoDisplayTarget"] = "JOIN_PARTY",
        ["gui:autoDisplayOverview"] = "NEVER",
        ["gui:autoDisplayRegain"] = "NEVER",
        ["gui:bossWarning"] = 1,
    },
    ["AOE"] = {
        translationKey = "RoleAoEer",
        collisionKey = "RoleAoEerMatches",
        ["gui:autoDisplayTarget"] = "JOIN_PARTY",
        ["gui:autoDisplayOverview"] = "JOIN_PARTY",
        ["gui:autoDisplayRegain"] = "NEVER",
        ["gui:bossWarning"] = 1,
    },
    ["HEALER"] = {
        translationKey = "RoleHealer",
        collisionKey = "RoleHealerMatches",
        ["gui:autoDisplayTarget"] = "NEVER",
        ["gui:autoDisplayOverview"] = "JOIN_PARTY",
        ["gui:autoDisplayRegain"] = "NEVER",
        ["gui:bossWarning"] = 0,
    },
    ["PET"] = {
        translationKey = "RolePet",
        collisionKey = "RolePetMatches",
        ["gui:autoDisplayTarget"] = "ALWAYS",
        ["gui:autoDisplayOverview"] = "NEVER",
        ["gui:autoDisplayRegain"] = "NEVER",
        ["gui:bossWarning"] = 1,
    },
};

-- We don't want people to be bothered with version reminder right after
-- they update DTM, right ?
local INITIAL_VERSION_REMINDER = 86400 * 3; -- 3 days before being reminded for the first time.
local FURTHER_VERSION_REMINDER = 86400 * 7; -- 7 days before being reminded for the other times.

-- --------------------------------------------------------------------
-- **                       DTM Slash commands                       **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SlashInit()                                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Registers all slash commands.                                    *
-- ********************************************************************
function DTM_SlashInit()
    SlashCmdList["DTM"] = DTM_SlashParse;
    SLASH_DTM1 = "/DTM";
end

-- ********************************************************************
-- * DTM_SlashParse(msg)                                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * msg >> the message to interpret.                                 *
-- ********************************************************************
-- * Parse & interpret a slash command sent to DTM.                   *
-- ********************************************************************
function DTM_SlashParse(msg)
    DTM_ProtectedCall(DTM_Console_OnCommand, "MAJOR", msg, 1);
end

-- --------------------------------------------------------------------
-- **                        DTM General API                         **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_DisplayRolePopup()                                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Submits to the player a role selection popup.                    *
-- ********************************************************************
function DTM_DisplayRolePopup()
    StaticPopup_Show("DTM_ROLE_POPUP");
end

-- ********************************************************************
-- * DTM_ApplyRole(role, showPopup)                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> role: the role internal name. See the table above.            *
-- * Should be TANK, DAMAGE, AOE or HEALER (all capitalized).         *
-- * >> showPopup: if set, a confirmation popup will be displayed,    *
-- * telling you the new role has been correctly set.                 *
-- ********************************************************************
-- * Used to quickly configure DTM to suit a given role.              *
-- ********************************************************************
function DTM_ApplyRole(role, showPopup)
    if not ( role ) then return; end

    local rolePreset = rolePresets[role];
    local roleTranslation = DTM_Localise("Unknown");

    if ( rolePreset ) then
        local k, v;
        for k, v in pairs(rolePreset) do
            if ( k ~= "translationKey" and k ~= "collisionKey" ) then
                local part, key = strsplit(":", k, 2);
                if ( part ) and ( key ) then
                    DTM_SetSavedVariable(part, key, v, "active");
                end
          elseif ( k == "translationKey" ) then
                roleTranslation = DTM_Localise(v);
            end
        end
    end

    if ( showPopup ) then
        StaticPopup_Show("DTM_ROLE_CHOSEN_POPUP", roleTranslation);
    end

    -- Also, refresh all configuration panels.
    if ( DTM_RefreshConfigPanels ) then
        DTM_RefreshConfigPanels();
    end

    -- Restart the GUI.
    if ( DTM_IsGUIRunning ) and ( DTM_IsGUIRunning() == 1 ) then
        DTM_HideGUI();
        DTM_ShowGUI();
    end
end

-- ********************************************************************
-- * DTM_GetRoleFromString(input)                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> input: the user role input, in their native language.         *
-- ********************************************************************
-- * Translate a user input into an internal role name.               *
-- ********************************************************************
function DTM_GetRoleFromString(input)
    if not ( input ) then return nil; end
    input = strlower(input);

    local role, data, matches, numMatches, i, match;

    for role, data in pairs(rolePresets) do
        matches = strlower(DTM_Localise(data.collisionKey));
        numMatches = select('#', strsplit("|", matches));
        for i=1, numMatches do
            match = select(i, strsplit("|", matches));
            if ( match == input ) then
                return role;
            end
        end
    end

    return nil;
end

-- ********************************************************************
-- * DTM_TemporaryDisableCondition()                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * This function determinate if we should temporarily shut off the  *
-- * engine and the GUI. Return 1 or nil.                             *
-- ********************************************************************
function DTM_TemporaryDisableCondition()
    if ( DTM_GetSavedVariable("system", "noTemporaryStop", "active") == 1 ) then
        return nil;
    end

    -- 1/ Are we on a taxi ?
    if ( UnitOnTaxi("player") ) then
        return 1;
    end

    -- 2/ Are we in a PvP instance which is not Alterac Valley ?
    local instance, category = IsInInstance();
    if ( instance ) and (category == "arena" or category == "pvp") then
        if ( GetRealZoneText() ~= DTM_Localise("AlteracValley") ) then
            return 1;
        end
    end

    -- Never disable temporarily the engine or GUI in combat state for resting/sanctuary circumstances.
    if ( UnitAffectingCombat("player") ) then
        return nil;
    end

    -- 3/ Are we resting ?
    if ( IsResting() ) then
        return 1;
    end

    -- 4/ Are we in a sanctuary ?
    if ( UnitIsPVPSanctuary("player") ) then
        return 1;
    end

    return nil;
end

-- ********************************************************************
-- * DTM_SetEmergencyStop(op, noFeedback)                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> op: the operation to do with the emergency switch.            *
-- * Can be "ON", "OFF" or "TOGGLE".                                  *
-- * >> noFeedback: if not set, a message specifying the emergency    *
-- * status has been toggled on or off will be displayed.             *
-- ********************************************************************
-- * This function allows you to change the emergency stop status.    *
-- ********************************************************************
function DTM_SetEmergencyStop(op, noFeedback)
    if not ( op ) then op = "TOGGLE"; end

    local oldStatus = DTM_EmergencyStop;

    if ( op == "ON" or ( not oldStatus and op == "TOGGLE" ) ) then
        DTM_EmergencyStop = 1;
elseif ( op == "OFF" or ( oldStatus and op == "TOGGLE" ) ) then
        DTM_EmergencyStop = nil;
    end

    if ( not noFeedback ) then
        if ( oldStatus ) and not ( DTM_EmergencyStop ) then
            DTM_ChatMessage(DTM_Localise("EmergencyStopDisabled"), nil);
    elseif not ( oldStatus ) and ( DTM_EmergencyStop ) then
            DTM_ChatMessage(DTM_Localise("EmergencyStopEnabled"), nil);
        end
    end
end

-- ********************************************************************
-- * DTM_IsEmergencyStopEnabled()                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * This function determinates if the emergency stop is enabled.     *
-- ********************************************************************
function DTM_IsEmergencyStopEnabled()
    if ( DTM_EmergencyStop ) then
        return 1;
    end
    return nil;
end

-- ********************************************************************
-- * DTM_CopyTable(source, destination)                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Copies to the destination table the content of a source table.   *
-- * If the destination table does not exist, a new table will be     *
-- * created and this function will return the new table.             *
-- ********************************************************************
function DTM_CopyTable(source, destination)
    if ( type(source) ~= "table" ) then error("DTM_CopyTable: a table must be passed to source parameter.", 0); return; end
    if not ( destination ) then destination = {}; end
    local k, v;
    for k, v in pairs(source) do
        if( type(v) == "table" ) then
           destination[k] = {}
           DTM_CopyTable(v, destination[k]);
     else
           destination[k] = v;
        end
    end
    return destination;
end

-- ********************************************************************
-- * DTM_OnWotLK()                               - HYBRID/TEMPORARY - *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Returns 1 if we are using a WotLK WoW client.                    *
-- * Returns nil if we are on a vanilla/TBC/Unknown WoW client.       *
-- ********************************************************************
function DTM_OnWotLK()
    local version, build, date, toc = GetBuildInfo();
    if ( toc ) and ( toc >= 30000 and toc <= 40000 ) then
        return 1;
    end
    return nil;
end

-- --------------------------------------------------------------------
-- **                      DTM BIOS handlers                         **
-- --------------------------------------------------------------------

function DTM_BIOS_OnLoad(self)
    self:RegisterEvent("VARIABLES_LOADED");
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED"); -- For the combat parse service.
end

function DTM_BIOS_OnEvent(self, event, ...)
    if not ( event ) then return 0; end

    if ( event == "VARIABLES_LOADED" ) then
        DTM_ProtectedCall(DTM_Startup, "CRITICAL");
        return 1;
    end

    if ( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then -- The combat parse service.
        DTM_ProtectedCall(DTM_OnCombatEvent, "MAJOR", ...);
        return 1;
    end

    return 2;
end

-- --------------------------------------------------------------------
-- **                        DTM BIOS events                         **
-- --------------------------------------------------------------------

-----------------------------------------------------------------------------
-- DTM_Startup()
--
-- Called after variables are loaded.
-----------------------------------------------------------------------------
function DTM_Startup()
    -- Display a message.
    DTM_ChatMessage(format(DTM_Localise("Boot"), DTM_GetVersionString()));

    -- Determinate if we can use CoolLib combat parse service instead.
    if ( DTM_CheckCoolLibCombatParseSupport() ) then
        DTM_Trace("EMULATION", "We'll use CoolLib's combat parse service.");
  else
        DTM_Trace("EMULATION", "We'll use DTM combat parse service.");
    end

    -- Handle slash commands.
    DTM_SlashInit();

    -- Check version for saved variables.
    local erased = DTM_CheckSavedVariablesVersion();
    if ( erased ) then
        DTM_ChatMessage(DTM_Localise("SavedVariablesBadVersion"));
    end

    -- Check active profile is registered.
    local gotRegistered, name = DTM_UpdateProfile();
    if ( gotRegistered ) then
        DTM_ChatMessage(format(DTM_Localise("ProfileRegistered"), name));
    end

    -- Check version for each NPC table.
    local changes = DTM_CheckNPCAbilitiesVersion();
    if ( changes > 0 ) then
        DTM_ChatMessage(format(DTM_Localise("NPCAbilitiesUpdated"), changes));
    end
    DTM_RebuildNPCLookupData();

    -- And start the engine.
    if ( DTM_SetupEngine ) then
        DTM_SetupEngine();
        if ( DTM_GetSavedVariable("engine", "run") == 1 ) then
            DTM_StartEngine();
      else
            DTM_ChatMessage(DTM_Localise("NotifyEngineDisabled"));
        end
    end

    -- Simple GUI for development versions.
    if ( DTM_StartSimpleGUI ) then
        DTM_StartSimpleGUI();
    end

    -- GUI for normal versions.
    if ( DTM_SetupGUI ) then
        DTM_SetupGUI();
        if ( DTM_GetSavedVariable("gui", "run") == 1 ) then
            DTM_StartGUI();
      else
            DTM_ChatMessage(DTM_Localise("NotifyGUIDisabled"));
        end
    end

    -- As variables have been loaded, refresh the config panels.
    if ( DTM_RefreshConfigPanels ) then
        DTM_RefreshConfigPanels();
    end

    -- Create the "this functionality is not implemented yet" popup.

    StaticPopupDialogs["DTM_FUNCTIONALITY_NOT_IMPLEMENTED"] = {
	    text = DTM_Localise("FunctionalityNotImplementedYet"),
	    button1 = OKAY.." :(",
            timeout = 0,
            showAlert = 1,
            whileDead = 1,
    };

    -- Create the role selection popups.

    StaticPopupDialogs["DTM_ROLE_POPUP"] = {
	    text = DTM_Localise("RoleSelection"),
	    button1 = OKAY,
            button2 = CANCEL,
            timeout = 0,
            whileDead = 1,
            hasEditBox = 1,
            maxLetters = 24,

            OnAccept = function(self)
                self = self or this:GetParent(); -- Compat with TBC.
                local editBox = getglobal(self:GetName().."EditBox");
                local text = editBox:GetText() or '';
                local role = DTM_GetRoleFromString(text);
                DTM_SetSavedVariable("system", "roleChosenOnce", 1, "active");
                DTM_ApplyRole(role, 1);
            end,
            OnCancel = function(self) DTM_SetSavedVariable("system", "roleChosenOnce", 1, "active"); end,
            OnShow = function(self)
                self = self or this; -- Compat with TBC.
                getglobal(self:GetName().."EditBox"):SetFocus();
                getglobal(self:GetName().."EditBox"):SetText("");
                getglobal(self:GetName().."Button1"):Disable();
            end,
            OnHide = function(self)
                self = self or this; -- Compat with TBC.
                if ( ChatFrameEditBox:IsVisible() ) then
                    ChatFrameEditBox:SetFocus();
                end
                getglobal(self:GetName().."EditBox"):SetText("");
            end,
            EditBoxOnTextChanged = function(self)
                self = self or this; -- Compat with TBC.
                local editBox = self;
                local text = editBox:GetText() or '';

                if ( DTM_GetRoleFromString(text) ) then
		    getglobal(self:GetParent():GetName().."Button1"):Enable();
	        else
		    getglobal(self:GetParent():GetName().."Button1"):Disable();
		end
            end,
    };

    StaticPopupDialogs["DTM_ROLE_CHOSEN_POPUP"] = {
	    text = DTM_Localise("RoleSelected"),
	    button1 = OKAY,
            timeout = 0,
            whileDead = 1,
    };

    -- Confirmation to reset saved vars / NPC database popups

    StaticPopupDialogs["DTM_RESET_SAVEDVARS"] = {
		text = DTM_Localise("CheckSavedVariablesReset"),
		button1 = YES,
		button2 = NO,
		timeout = 0,
		showAlert = 1,
		whileDead = 1,
		OnAccept = function(self) DTM_ResetSavedVars(); end,
    };

    StaticPopupDialogs["DTM_RESET_NPCDATABASE"] = {
		text = DTM_Localise("CheckNPCDatabaseReset"),
		button1 = YES,
		button2 = NO,
		timeout = 0,
		showAlert = 1,
		whileDead = 1,
		OnAccept = function(self) DTM_ResetNPCData(); end,
    };

    StaticPopupDialogs["DTM_RESET_ALL"] = {
		text = DTM_Localise("CheckAllReset"),
		button1 = DTM_Localise("Erase"),
		button2 = CANCEL,
		timeout = 0,
		showAlert = 1,
		whileDead = 1,
  		hasEditBox = 1,
   		maxLetters = 16,

		OnAccept = function(self) DTM_HardReset(); end,
		OnShow = function(self)
                    self = self or this; -- Compat with TBC.
		    getglobal(self:GetName().."EditBox"):SetFocus();
		    getglobal(self:GetName().."EditBox"):SetText("");
		    getglobal(self:GetName().."Button1"):Disable();
		end,
		OnHide = function(self)
                    self = self or this; -- Compat with TBC.
		    if ( ChatFrameEditBox:IsVisible() ) then
		        ChatFrameEditBox:SetFocus();
		    end
                    getglobal(self:GetName().."EditBox"):SetText("");
		end,
		EditBoxOnTextChanged = function(self)
                    self = self or this; -- Compat with TBC.
		    local editBox = self;
                    local erase = string.upper(DTM_Localise("Erase"));
                    if ( erase == editBox:GetText() ) then
		        getglobal(self:GetParent():GetName().."Button1"):Enable();
		   else
		        getglobal(self:GetParent():GetName().."Button1"):Disable();
		    end
		end,
    };

    -- Version reminder popup

    StaticPopupDialogs["DTM_VERSION_REMINDER"] = {
		text = DTM_Localise("VersionCheckReminder"),
		button1 = YES,
		button2 = NO,
		timeout = 0,
		whileDead = 1,
		OnAccept = function(self)
                               -- Check if the GUI way of checking version is available.
                               if type(DTM_ConfigurationFrame_VersionPanel_Open) == "function" then
                                   DTM_ConfigurationFrame_VersionPanel_Open();
                                   DTM_Version_Ask(DTM_ConfigurationFrame_VersionPanel_OnVersionRequestDone);
                             else
                                   DTM_Engine_Test_CheckVersion();
                               end
                           end,
                OnShow = function(self)
                             -- Even if the user does not do the version check, do not bother him with it for some time.
                             DTM_Version_SetReminder(FURTHER_VERSION_REMINDER);
                         end,
    };

    -- Welcome message for first-time runs.

    StaticPopupDialogs["DTM_WELCOME_POPUP"] = {
	    text = format(DTM_Localise("FirstRunWelcome"), DTM_GetVersionString()),
	    button1 = OKAY,
            button2 = DTM_Localise("OpenOptions"),
            timeout = 0,
            whileDead = 1,
            OnAccept = function(self) DTM_DisplayRolePopup(); end,
            OnCancel = function(self) DTM_ConfigurationFrame_IntroPanel_Open(); DTM_DisplayRolePopup(); end,
    };
    if ( DTM_OnWotLK() ) then -- Hack to use Beta variant instead.
        StaticPopupDialogs["DTM_WELCOME_POPUP"].text = format(DTM_Localise("FirstRunWelcomeBeta"), DTM_GetVersionString());
    end

    local key = "notFirstRun:"..DTM_GetVersionString();
    local displayWelcome = not ( DTM_GetSavedVariable("system", key, nil, 1) == 1 ); -- Global saved variable.
    if ( displayWelcome ) then
        DTM_SetSavedVariable("system", key, 1);
        StaticPopup_Show("DTM_WELCOME_POPUP");

        -- DTM is updated or new to this user, prevent version reminding for some time.
        DTM_Version_SetReminder(INITIAL_VERSION_REMINDER);
  else
        -- Check role has been chosen at least once (or cancelled) for active profile.
        if not ( DTM_GetSavedVariable("system", "roleChosenOnce", "active") == 1 ) then
            DTM_DisplayRolePopup();
        end
    end
end

-----------------------------------------------------------------------------
-- DTM_ResetSavedVars()
--
-- Gets called when reset saved vars popup accept button is clicked.
-----------------------------------------------------------------------------

function DTM_ResetSavedVars()
    DTM_ClearSavedVariables();
    ReloadUI();
end

-----------------------------------------------------------------------------
-- DTM_ResetNPCData()
--
-- Gets called when reset NPC data popup accept button is clicked.
-----------------------------------------------------------------------------

function DTM_ResetNPCData()
    DTM_ClearAllNPCData();
    DTM_CopyAllNPCAbilityData();
    DTM_RebuildNPCLookupData();
    DTM_ChatMessage(DTM_Localise("NPCAbilitiesReset"), 1);
end

-----------------------------------------------------------------------------
-- DTM_HardReset()
--
-- Gets called if you wish to revert completely DTM variables to their
-- default values. DTM will act as if ran for the first time.
-- Use with care this API.
-----------------------------------------------------------------------------

function DTM_HardReset()
    DTM_SavedVariables = nil;
    DTM_NPCAbilities = nil;
    DTM_Skins = nil;
    ReloadUI();
end