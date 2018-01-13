local activeModule = "Engine TPS calculation";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- How long ago we come back from now on to determinate TPS.
local COVERED_PERIOD = 5.000;

-- Time before an entry in the threat history gets deleted.
local OUTDATED_THRESHOLD = 10.000;

-- An entity which had no update at all for a shorter time than this will not have its TPS data redone for its threat list's content.
local IGNORE_THRESHOLD = 10.000;

-- The history must describe events fitting in at least this amount of time before we start computing non-zero TPS.
local MINIMUM_TIME_WINDOW = 0.500;

-- --------------------------------------------------------------------
-- **                               API                              **
-- --------------------------------------------------------------------

-- History API

-- ********************************************************************
-- * DTM_TPS_AddToHistory(historyTable, threat)                       *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> historyTable: the history table to work with.                 *
-- * >> threat: the threat value inserted in the history.             *
-- ********************************************************************
-- * Add an entry to the history.                                     *
-- * Will also drop outdated entries.                                 *
-- ********************************************************************

function DTM_TPS_AddToHistory(historyTable, threat)
    historyTable[#historyTable+1] = tostring(GetTime()).."|"..tostring(threat);
    DTM_TPS_CleanHistory(historyTable);
end

-- ********************************************************************
-- * DTM_TPS_GetHistoryData(historyTable, index)                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> historyTable: the history table to work with.                 *
-- * >> index: the index to get data of.                              *
-- ********************************************************************
-- * Get data from an entry in an history table.                      *
-- * Returns: timestamp, threat.                                      *
-- ********************************************************************

function DTM_TPS_GetHistoryData(historyTable, index)
    local stringInfo = historyTable[index];
    if type(stringInfo) == "string" then
        local timeString, threatString = strsplit("|", stringInfo, 2);
        return tonumber(timeString) or 0, tonumber(threatString) or 0;
    end
    return 0, 0;
end

-- ********************************************************************
-- * DTM_TPS_CleanHistory(historyTable)                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> historyTable: the history table to work with.                 *
-- ********************************************************************
-- * Remove outdated entries from a given history table.              *
-- ********************************************************************

function DTM_TPS_CleanHistory(historyTable)
    local timeNow = GetTime();
    local time, threat;
    local elapsed, i, ii;

    for i=#historyTable, 1, -1 do
        time, threat = DTM_TPS_GetHistoryData(historyTable, i);
        elapsed = timeNow - time;
        if ( elapsed > OUTDATED_THRESHOLD ) then
            for ii=i, #historyTable-1 do
                historyTable[ii] = historyTable[ii+1];
            end
            historyTable[#historyTable] = nil;
        end
    end
end

-- TPS API

-- ********************************************************************
-- * DTM_TPS_CalculateTPS(historyTable, timeNow)                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> historyTable: the history table to work with.                 *
-- * >> timeNow: the time we consider it is now.                      *
-- ********************************************************************
-- * Calculate the TPS based on the current TPS config.               *
-- ********************************************************************

function DTM_TPS_CalculateTPS(historyTable, timeNow)
    local tps = 0;
    local historySize = #historyTable;
    local i;
    local change, time = nil, nil;
    local elapsed;
    local beginThreat, beginTime, endThreat, endTime;
    local time, threat;

    if historySize <= 1 then -- Can't do anything with only 1 or 0 history entry.
        return 0;
    end

    -- Last entry automatically becomes the end threat.
    time, threat = DTM_TPS_GetHistoryData(historyTable, historySize);
    endThreat = threat;
    endTime = timeNow;

    -- Now find the start threat, using the oldest entry in the history possible that also matches our TPS calculation settings.
    for i=1, historySize do
        time, threat = DTM_TPS_GetHistoryData(historyTable, i);
        elapsed = timeNow - time;
        if ( COVERED_PERIOD > elapsed ) then
            beginThreat = threat;
            beginTime = time;
            break;
        end
    end

    -- Check if we have valid data to calculate TPS.
    if ( beginThreat and endThreat ) then
        change = endThreat - beginThreat;
        time = endTime - beginTime;

        if ( time >= MINIMUM_TIME_WINDOW ) then
            tps = change / time; -- That's the definition of TPS yeah?
        end
    end

    return tps;
end

-- ********************************************************************
-- * DTM_TPS_SubmitNewTPS(ownerGUID, relativeGUID, newTPS)            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> ownerGUID: the GUID of the threatening guy.                   *
-- * >> relativeGUID: the GUID of the guy threatened.                 *
-- * >> newTPS: the new TPS of the threatening guy.                   *
-- ********************************************************************
-- * Update the TPS of an owner vs. relative.                         *
-- ********************************************************************

function DTM_TPS_SubmitNewTPS(ownerGUID, relativeGUID, newTPS)
    -- First update the threat list of the relative.

    local relativeData = DTM_EntityData_Get(relativeGUID, nil);
    if not ( relativeData ) then return; end

    local threatList = relativeData.threatList;

    local ownerData = DTM_ThreatList_GetEntity(threatList, ownerGUID);
    if not ( ownerData ) then return; end

    ownerData.tps = newTPS;
    -- ownerData.tpsUpdate = GetTime();

    -- Now update the presence list of the owner.

    local ownerEntityData = DTM_EntityData_Get(ownerGUID, nil);
    if not ( ownerEntityData ) then return; end

    local presenceList = ownerEntityData.presenceList;

    local relativePresenceData = DTM_ThreatList_GetEntity(presenceList, relativeGUID);
    if not ( relativePresenceData ) then return; end

    relativePresenceData.tps = newTPS;
end

-- --------------------------------------------------------------------
-- **                            Functions                           **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_TPS_CheckForTPSUpdate(entityData, timeNow)                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> entityData: the entity data table.                            *
-- * >> timeNow: the time we consider it is now.                      *
-- ********************************************************************
-- * Update the TPS for the entities in a given entity's threat list. *
-- * The entity will be ignored if it hasn't been updated for a while.*
-- ********************************************************************

function DTM_TPS_CheckForTPSUpdate(entityData, timeNow)
    local elapsed = timeNow - entityData.lastUpdate;
    if ( elapsed > IGNORE_THRESHOLD ) then return; end

    local threatList = entityData.threatList;
    local data, i;

    for i=1, threatList.number do
        data = threatList[i];
        -- A TPS update is needed now for this threat list entry.
        local newTPS = DTM_TPS_CalculateTPS(data.history, timeNow);
        DTM_TPS_SubmitNewTPS(data.guid, entityData.guid, newTPS);
    end
end

-- --------------------------------------------------------------------
-- **                             Handlers                           **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_TPS_Update(elapsed)                                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> elapsed: how much time passed since last call.                *
-- ********************************************************************
-- * Update the TPS.                                                  *
-- ********************************************************************

function DTM_TPS_Update(elapsed)
    local updateTimer = DTM_Update["TPS_UPDATE"] or 0;
    local rate = DTM_GetSavedVariable("engine", "tpsUpdateRate", "active");

    if ( rate > 0 ) and ( GetTime() > updateTimer ) then
        DTM_EntityData_PickUpTableAndDo(DTM_TPS_CheckForTPSUpdate, GetTime());
        DTM_Update["TPS_UPDATE"] = GetTime() + rate;
    end
end


