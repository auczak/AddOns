local activeModule = "Engine inspect access interface";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local DTM_CODE = "DTM-InspectAccess";

-- This script file provides an interface to DTM modules to query safely
-- talents/gear from an arbitrary unit, without getting in the way of other mods.

local TIMEOUT = 5.000;

local access = {
    status = "READY",
    unitName = nil,
    startTime = 0,
    timeOut = 0,
    onAnswer = nil,
    priority = nil,
};

-- --------------------------------------------------------------------
-- **                               API                              **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Access_Ask(unitId, type, onAnswer, priority)                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * unitId >> the unitId who is to be inspected.                     *
-- * type >> this is what you want to get from the unit: it can be    *
-- * GEAR or TALENT.                                                  *
-- * onAnswer >> the function that will get called once talents or    *
-- * gear been successfully or not grabbed. The following parameters  *
-- * will be passed to the function: state, flag, unitId; where state *
-- * is whether you can now get gear/talents, flag is the parameter to*
-- * add to the talent/gear query API and unitId reminds you who you  *
-- * had queried.                                                     *
-- * priority >> set to non-nil to enforce the launch of the API      *
-- * if the thread that is running has a lower priority.              *
-- ********************************************************************
-- * Ask the system to tell you gear or talents of a given unitId.    *
-- * Return nil if your query couldn't be sent.                       *
-- * Return 1 if the query was sent successfully. Nil if it could not.*
-- * Return 2 if the query was successful and instantaneous. (this    *
-- * case occurs when the player wants to get its own talents or when *
-- * you inspect gear of someone, including yourself)                 *
-- ********************************************************************

function DTM_Access_Ask(unitId, type, onAnswer, priority)
    if ( UnitIsUnit(unitId, "player") ) then
        if ( type == "TALENT" ) then
            onAnswer(1, nil, UnitName("player"));
      else
            onAnswer(1, "player", UnitName("player"));
        end
        return 2;
    end

    local status, callInspect = DTM_Access_CanAsk(unitId, priority);

    if ( status == "OK" ) then
        -- If we were already processing a request, cancel it.
        if ( access.status == "BUSY" ) then
            DTM_Access_SendResult(nil);
        end

        access.unitName = UnitName(unitId);
        access.onAnswer = onAnswer;
        access.priority = priority;
        access.status = "BUSY";

        if ( callInspect ) then
            NotifyInspect(unitId, DTM_CODE);
        end

        if ( type == "GEAR" ) then
            -- GEAR is immediately available upon calling NotifyInspect.
            DTM_Access_SendResult(1, unitId);
            return 2;
        end

        return 1;
    end

    return nil;
end

-- ********************************************************************
-- * DTM_Access_CanAsk(unitId, priority)                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * unitId >> the unitId who is to be inspected.                     *
-- * priority >> the priority level we consider using.                *
-- ********************************************************************
-- * Determinates if you can ask the system to grab talents or gear.  *
-- * Can return "OK", "BUSY", "FOREIGN" or "CANNOT".                  *
-- * "OK" means Ask API will accept your request, "BUSY" means it     *
-- * will not since there is a process already going on.              *
-- * "FOREIGN" means a foreign AddOn or Blizzard inspect frame is     *
-- * currently issuing an inspection. "CANNOT" means you simply cannot*
-- * inspect specified unit.                                          *
-- *                                                                  *
-- * A second value is returned, but it won't probably be of any use  *
-- * to you, as it specifies whether NotifyInspect should be called   *
-- * to grab the data.                                                *
-- ********************************************************************

function DTM_Access_CanAsk(unitId, priority)
    if ( unitId ) then
        -- First, if it is oneself, of course data is available, at once, and without using NotifyInspect.
        if ( UnitIsUnit(unitId, "player") ) then
            return "OK", nil;
        end

        -- Then, if there is an access already running, we don't have to use NotifyInspect if what it is querying is what we want, us, to query.
        if ( access.status ~= "READY" ) and ( UnitName(unitId) == access.unitName ) then
            return "OK", nil;
        end
    end

    -- Now, if these opportunities are not applicable, see if the access is not being used.
    if ( access.status == "BUSY" ) and ( priority <= access.priority ) then return "BUSY", nil; end
    if ( access.status == "FOREIGN" ) then return "FOREIGN", nil; end

    -- If Blizzard inspect frame is opened, prevent inspection while it's open.
    if ( InspectFrame ) then
        if ( InspectFrame:IsShown() ) then return "FOREIGN", nil; end
    end

    -- Is the unit physically inspectable ?
    if ( unitId ) and ( not CanInspect(unitId) ) then return "CANNOT", nil; end

    -- Then we can now access data the standard way.
    return "OK", 1;
end

-- ********************************************************************
-- * DTM_Access_SendResult(status, flag)                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> status: whether the query is successful or not.               *
-- * >> flag: the flag parameter that will get passed to callback. It *
-- * will default to 1 if not provided.                               *
-- ********************************************************************
-- * Gets called when the talent query has finished, whether it is    *
-- * successful or not. The callback is then fired.                   *
-- ********************************************************************

function DTM_Access_SendResult(status, flag)
    if not ( access.status == "BUSY" ) then return; end
    access.status = "READY";

    if ( status ) then
        DTM_Trace("ACCESS", "'%s' inspect query has been successful.", 1, access.unitName);
  else
        DTM_Trace("ACCESS", "'%s' inspect query has failed.", 1, access.unitName);
    end

    if ( access.onAnswer ) then
        access.onAnswer(status, flag or 1, access.unitName);
    end

    access.unitName = nil;
end

-- --------------------------------------------------------------------
-- **                               Hook                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Access_OnInspectRequest(unitId, addOnCode)                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * unitId >> the unitId who is to be inspected.                     *
-- * addOnCode >> a 2nd parameter that is used by DTM to              *
-- * distinguish its inspect requests from other mods'.               *
-- ********************************************************************
-- * Gets called when anything calls NotifyInspect function.          *
-- ********************************************************************

function DTM_Access_OnInspectRequest(unitId, addOnCode)
    if not CanInspect(unitId) then
        return nil;
    end

    if ( addOnCode == DTM_CODE ) then
        DTM_Trace("ACCESS", "DTM is inspecting %s.", 1, UnitName(unitId));
  else
        DTM_Trace("ACCESS", "A foreign system is inspecting %s.", 1, UnitName(unitId));
    end

    access.startTime = GetTime();
    access.timeOut = GetTime() + TIMEOUT;

    name = UnitName(unitId);

    if ( access.status == "BUSY" ) and ( addOnCode ~= DTM_CODE ) and ( name ~= access.unitName ) then
        -- DTM was performing an access, but a foreign AddOn used NotifyInspect API on some other unit. Invalidate current access.
        DTM_Access_SendResult(nil);
    end

    if ( addOnCode ~= DTM_CODE ) and ( name ~= access.unitName ) then
        access.status = "FOREIGN";
    end
end

-- ********************************************************************
-- * DTM_Access_OnTalentsInterrupt()                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Gets called when ClearInspectPlayer API is called.               *
-- ********************************************************************

function DTM_Access_OnTalentsInterrupt()
    if ( access.status == "BUSY" ) then
        -- Darn, we had an access on-going.
        DTM_Access_SendResult(nil);
    end
    access.status = "READY";
end

-- --------------------------------------------------------------------
-- **                              Handlers                          **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Access_OnTalentsReceipt()                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Gets called when the talents queried with NotifyInspect          *
-- * have been received.                                              *
-- ********************************************************************

function DTM_Access_OnTalentsReceipt()
    if ( access.status == "BUSY" ) then
        DTM_Access_SendResult(1);
    end
    access.status = "READY";
end

-- ********************************************************************
-- * DTM_Access_OnUpdate(elapsed)                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> elapsed: time amount that elapsed sine last call.             *
-- ********************************************************************
-- * Gets periodically called, to remove requests above the timeout.  *
-- ********************************************************************

function DTM_Access_OnUpdate(elapsed)
    if ( access.status == "BUSY" or access.status == "FOREIGN" ) then
        if ( GetTime() > access.timeOut ) then
            if ( access.status == "BUSY" ) then
                DTM_Access_SendResult(nil);
            end
            access.status = "READY";
        end
    end
end