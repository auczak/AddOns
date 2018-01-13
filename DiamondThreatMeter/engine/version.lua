local activeModule = "Engine version";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local VERSION_QUERY_TIMEOUT = 4.000;
local FLOOD_DELAY_WAIT = 5.000;

-- After doing a version check, we'll remind them to check version X days later.
local VERSION_REMINDER_DELAY = 86400 * 7; -- 7 days
local VERSION_REMINDER_MINSIZE = 7; -- The number of members there has to be in the raid before trying to remind. A low-sized raid wouldn't be interesting for version-checking.

local queryData = {
    status = "READY",
    timeStarted = 0,
    timeOut = 0,
    lastQuery = 0,
};

local queryResults = {
    number = 0,
};

local lastVersionQuery = 0;

-- Foreign ThreatMeters do not use the same notation convention for versions.
-- AddOns whose version check is emulated by DTM are listed here.
local foreignSystemPatterns = {
    ["KTM"] = "%m.%r",
    ["ThreatLib2"] = "r%r",
};

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Version_Ask(callback)                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> callback: function to call once all results have been         *
-- * determinated. It is necessary or the API will silently fail;     *
-- * it doesn't like to work for nothing =P                           *
-- ********************************************************************
-- * Asks the members of the party/raid to tell us our version.       *
-- * Callback will be fired when query is done & results are available*
-- * This API will do nothing and return nil if a query is already    *
-- * going on. It will instead return 1 if query was sent succesfully.*
-- ********************************************************************

function DTM_Version_Ask(callback)
    if not callback or type(callback) ~= "function" then return nil; end
    if not ( DTM_Version_CanAsk() == "OK" ) then return nil; end

    queryData.status = "BUSY";
    queryData.timeStarted = GetTime();
    queryData.timeOut = GetTime() + VERSION_QUERY_TIMEOUT;
    queryData.callback = callback;
    queryData.lastQuery = GetTime();

    local i, numAnswersExpected;
    numAnswersExpected = 0;

    if ( GetNumRaidMembers() > 0 ) then
        for i=1, GetNumRaidMembers() do
            name = GetRaidRosterInfo(i);
            if ( name ) and ( name ~= UnitName("player") ) then
                numAnswersExpected = numAnswersExpected + 1;
                queryData["name"..numAnswersExpected] = name;
                queryData["status"..numAnswersExpected] = "PENDING";
                queryData["major"..numAnswersExpected] = 0;
                queryData["minor"..numAnswersExpected] = 0;
                queryData["revision"..numAnswersExpected] = 0;
                queryData["system"..numAnswersExpected] = "N/A";
            end
        end
  else
        if ( GetNumPartyMembers() > 0 ) then
            for i=1, GetNumPartyMembers() do
                name = UnitName("party"..i);
                if ( name ) and ( name ~= UnitName("player") ) then
                    numAnswersExpected = numAnswersExpected + 1;
                    queryData["name"..numAnswersExpected] = name;
                    queryData["status"..numAnswersExpected] = "PENDING";
                    queryData["major"..numAnswersExpected] = 0;
                    queryData["minor"..numAnswersExpected] = 0;
                    queryData["revision"..numAnswersExpected] = 0;
                    queryData["system"..numAnswersExpected] = "N/A";
                end
            end
        end
    end

    queryData.number = numAnswersExpected;

    DTM_Network_SendPacket("YOURVERSION");

    -- Also sends a request to each active emulation module.
    DTM_Emulation_QueryVersion();

    -- We won't bother the user with version reminding since it has just asked for a version check.
    DTM_Version_SetReminder(VERSION_REMINDER_DELAY);

    return 1;
end

-- ********************************************************************
-- * DTM_Version_CanAsk()                                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Determinates if DTM_Version_Ask API is ready to forward your     *
-- * wishes :p                                                        *
-- ********************************************************************

function DTM_Version_CanAsk()
    if ( queryData.status ~= "READY" ) then
        return "BUSY";
    end

    -- Nah we don't flood.
    if ( queryData.lastQuery > 0 ) then
        local timeElapsed = GetTime() - queryData.lastQuery;
        if ( timeElapsed < FLOOD_DELAY_WAIT ) then
            return "FLOOD";
        end
    end

    -- Useless outside of a party/raid.
    if ( (GetNumRaidMembers() or 0) + (GetNumPartyMembers() or 0) == 0 ) then
        return "NOT_GROUPED";
    end

    return "OK";
end

-- ********************************************************************
-- * DTM_Version_GetNumResults()                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Get the number of results available for the last successful      *
-- * version query.                                                   *
-- ********************************************************************

function DTM_Version_GetNumResults()
    return queryResults.number or 0;
end

-- ********************************************************************
-- * DTM_Version_GetResultInfo(index)                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> index: the index of the result to query.                      *
-- ********************************************************************
-- * Returns info about a version query at given index :              *
-- * - Name of the guy                                                *
-- * - Version string of the guy (can be a localised sentence stating *
-- *                              its answer couldn't be got)         *
-- * - System used by the guy. Special case: "N/A".                   *
-- * - Major (0 if couldn't be got)                                   *
-- * - Minor (0 if couldn't be got)                                   *
-- * - Revision (0 if couldn't be got)                                *
-- ********************************************************************

function DTM_Version_GetResultInfo(index)
    local info = queryResults;
    return info["n"..index] or "UNKNOWN", info["str"..index] or "UNKNOWN", info["sys"..index] or "N/A", info["maj"..index] or 0, info["min"..index] or 0, info["rev"..index] or 0;
end

-- ********************************************************************
-- * DTM_Version_CheckReminder()                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Check if we should display a popup inviting the user to check    *
-- * the version of the raid.                                         *
-- ********************************************************************

function DTM_Version_CheckReminder()
    local remindTime = DTM_GetSavedVariable("system", "versionCheckReminder") or 0;
    if ( time() < remindTime ) then return; end
    if DTM_Version_CanAsk() ~= "OK" then return; end
    if UnitAffectingCombat("player") then return; end -- Never ever bother someone with this while in combat.
    if ( GetNumRaidMembers() < VERSION_REMINDER_MINSIZE ) then return; end
    StaticPopup_Show("DTM_VERSION_REMINDER");
end

-- ********************************************************************
-- * DTM_Version_SetReminder(waitTime)                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> timestamp: the time amount (in sec) before DTM will try when  *
-- * possible to remind the user to perform a version check.          *
-- ********************************************************************
-- * Check if we should display a popup inviting the user to check    *
-- * the version of the raid.                                         *
-- ********************************************************************

function DTM_Version_SetReminder(waitTime)
    local oldTime = DTM_GetSavedVariable("system", "versionCheckReminder") or 0;
    local remindTime = time() + waitTime;
    DTM_SetSavedVariable("system", "versionCheckReminder", max(oldTime, remindTime));
end

-- --------------------------------------------------------------------
-- **                            Handler                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Version_OnQuery(sender)                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> sender: the guy who wants to know our version.                *
-- ********************************************************************
-- * Gets called when a YOURVERSION request is received.              *
-- ********************************************************************

function DTM_Version_OnQuery(sender)
    -- Ignore self
    if sender == UnitName("player") then
        return;
    end

    -- Ignore version query flood
    if ( lastVersionQuery > 0 ) then
        local timeElapsed = GetTime() - lastVersionQuery;
        if ( timeElapsed < FLOOD_DELAY_WAIT ) then
            return;
        end
    end

    -- Send a special one-target AddOn message.
    SendAddonMessage("DTM", format("MYVERSION;%d;%d;%d", DTM_GetVersion()), "WHISPER", sender);

    lastVersionQuery = GetTime();
end

-- ********************************************************************
-- * DTM_Version_OnAnswer(sender, b, c, d, system)                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> sender: the guy who answered a version query.                 *
-- * >> b, c, d: major, minor and revision of the system used.        *
-- * >> system: the system the guy uses, if different from DTM.       *
-- ********************************************************************
-- * Gets called after one has sent a MYVERSION, as answer to YOUR... *
-- * This function can also be called as an API by the emu module.    *
-- ********************************************************************

function DTM_Version_OnAnswer(sender, b, c, d, system)
    -- Ignore self
    if sender == UnitName("player") then
        return;
    end

    if ( queryData.status ~= "BUSY" ) then
        return;
    end

    system = system or "DTM";

    local i;
    for i=1, queryData.number do
        if ( queryData["name"..i] == sender ) and ( queryData["status"..i] == "PENDING" or queryData["status"..i] == "E-OK" ) then
            if ( system == "DTM" ) then
                queryData["status"..i] = "OK";
          else
                queryData["status"..i] = "E-OK";
            end
            queryData["major"..i] = tonumber(b) or 0;
            queryData["minor"..i] = tonumber(c) or 0;
            queryData["revision"..i] = tonumber(d) or 0;
            queryData["system"..i] = system;
            break;
        end
    end
end

-- ********************************************************************
-- * DTM_Version_OnUpdate(elapsed)                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> elapsed: the time that elapsed since last call.               *
-- ********************************************************************
-- * Gets called periodically to check for end of processing.         *
-- ********************************************************************

function DTM_Version_OnUpdate(elapsed)
    if ( queryData.status == "BUSY" ) then
        if ( GetTime() > queryData.timeOut ) then
            -- OK finished, send results.

            -- First clean up previous results.
            for k, v in pairs(queryResults) do
                queryResults[k] = nil;
            end
            queryResults.number = 0;

            -- Populates the results.
            local name, status, system, major, minor, revision;
            local verString;
            for i=1, queryData.number do
                name, status, system, major, minor, revision = queryData["name"..i], queryData["status"..i], queryData["system"..i], queryData["major"..i], queryData["minor"..i], queryData["revision"..i];

                if ( status == "PENDING" ) then
                    local ptr = DTM_GetGroupPointer(name);
                    if ( ptr ) and not ( UnitIsConnected(ptr) ) then
                        verString = DTM_Localise("VersionQueryDisconnected");
                  else
                        verString = DTM_Localise("VersionQueryTimeOut");
                    end
            elseif ( status == "OK" or status == "E-OK" ) then
                    if ( system == "DTM" ) then
                        verString = format("%d.%d.%d", major, minor, revision);
                  else
                        local pattern = foreignSystemPatterns[system];
                        if ( pattern ) then
                            pattern = string.gsub(pattern, "%%M", major);
                            pattern = string.gsub(pattern, "%%m", minor);
                            pattern = string.gsub(pattern, "%%r", revision);
                            verString = pattern;
                      else
                            verString = "";
                        end
                    end
              else
                    verString = "?";
                end

                queryResults.number = queryResults.number + 1;
                queryResults["n"..queryResults.number] = name;
                queryResults["maj"..queryResults.number] = major;
                queryResults["min"..queryResults.number] = minor;
                queryResults["rev"..queryResults.number] = revision;
                queryResults["str"..queryResults.number] = verString;
                queryResults["sys"..queryResults.number] = system;
            end

            -- Calls the callback.
            queryData.callback();

            -- Resets the service to standby status.
            queryData.status = "READY";
            queryData.callback = nil;
        end
    end
end