local activeModule = "Engine talents buffer";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local TALENTS_ACCESS_PRIORITY = 1;

local talentsBuffer_Callback = nil;

-- --------------------------------------------------------------------
-- **                               API                              **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_TalentsBuffer_Get(name)                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the player whose talents are queried.       *
-- ********************************************************************
-- * Grab the talents data of an entity based on its name.            *
-- * If no talent data is found, nil is returned.                     *
-- * You can read directly in the buffer and so use this function as  *
-- * an API, but it is "more beautiful" to use GetTalentRank API.     *
-- ********************************************************************
function DTM_TalentsBuffer_Get(name)
    if ( name == "number" ) then return nil; end -- Illegal.
    return DTM_Talents[name];
end

-- ********************************************************************
-- * DTM_TalentsBuffer_GetTalentRank(name, talentInternal)            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the player whose talents are queried.       *
-- * >> talentInternal: the internal name of the talent to get.       *
-- ********************************************************************
-- * Get the number of points spent on the given talent by the player *
-- * named "name". If no data is available for a given player, 0 rank *
-- * will be returned.                                                *
-- ********************************************************************
function DTM_TalentsBuffer_GetTalentRank(name, talentInternal)
    local talents = DTM_TalentsBuffer_Get(name);
    if ( talents ) then
        return talents[talentInternal] or 0;
    end
    return 0;
end

-- ********************************************************************
-- * DTM_TalentsBuffer_GetTreeTotalPoints(name, treeIndex)            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the player whose talents are queried.       *
-- * >> treeIndex: the talent tree index of the player, generally it  *
-- * is either 1, 2 or 3, from left to right in the talents frame.    *
-- * See each class talents for more information.                     *
-- ********************************************************************
-- * Get the number of points spent on the given talent tree by the   *
-- * player named "name". If no data is available for a given player, *
-- * 0 will be returned.                                              *
-- ********************************************************************
function DTM_TalentsBuffer_GetTreeTotalPoints(name, treeIndex)
    local talents = DTM_TalentsBuffer_Get(name);
    if ( talents ) and ( type(treeIndex) == "number" ) then
        return talents.count[treeIndex] or 0;
    end
    return 0;
end

-- ********************************************************************
-- * DTM_TalentsBuffer_Grab(unit, callback, priorityOveride)          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit whose talent data is grabbed.                  *
-- * >> callback: a function you wish to call once talents have been  *
-- * grabbed, successfully or not.                                    *
-- * >> priorityOveride: sets a new priority for the talents access.  *
-- ********************************************************************
-- * Grab the talents data of an unit and store it in the buffer.     *
-- * Repeated calls of this function will refresh appropriately the   *
-- * current data stored in the buffer.                               *
-- *                                                                  *
-- * Return 1 if talents grab request was issued successfully.        *
-- * Return nil if not.                                               *
-- ********************************************************************
function DTM_TalentsBuffer_Grab(unit, callback, priorityOveride)
    if not UnitExists(unit) then return nil; end
    if not UnitIsPlayer(unit) then return nil; end
    if ( UnitAffectingCombat("player") ) then return nil; end

    local truePriority = priorityOveride or TALENTS_ACCESS_PRIORITY;
    local auth = DTM_Access_CanAsk(unit, truePriority);

    if ( auth == "OK" ) then
        talentsBuffer_Callback = callback;
        DTM_Access_Ask(unit, "TALENT", DTM_TalentsBuffer_OnResult, truePriority);
        return 1;
  else
        -- Cannot do the grabbing now. If there is a callback, we tell it we failed.
        if ( callback ) then
            callback(nil, unit);
        end
        return nil;
    end
end

-- --------------------------------------------------------------------
-- **                             Functions                          **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_TalentsBuffer_OnResult(state, flag, unitName)                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> state: whether it succeeded or not.                           *
-- * >> flag: what to pass to talents API functions.                  *
-- * >> unitName: the unit whose talent data is received.             *
-- ********************************************************************
-- * Called when talent data of an unit is now available.             *
-- ********************************************************************
function DTM_TalentsBuffer_OnResult(state, flag, unitName)
    local unit = DTM_GetUnitPointer(unitName);
    if not ( unit ) then return; end

    if not ( UnitIsUnit(unit, "player") ) then
        DTM_Trace("BUFFER", "[%s] talents have been stored in the buffer.", 1, unitName);
    end

    local talents = DTM_TalentsBuffer_Get(unitName);
    if not ( talents ) then
        DTM_Talents.number = DTM_Talents.number + 1;
        DTM_Talents[unitName] = {
            count = {}, -- The counter for points spent in each talent tree.
        };
        talents = DTM_Talents[unitName];
    end

    _, class = UnitClass(unit);
    talents.class = class;
    talents.lastUpdate = GetTime();

    if ( state ) then
        local thisTreeCount = 0;
        for i=1, GetNumTalentTabs(flag) do
            thisTreeCount = 0;
            for ii=1, GetNumTalents(i, flag) do
                name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(i, ii, flag);
                thisTreeCount = thisTreeCount + rank;

                internalName = DTM_GetInternal("talents", name, 1);
                if internalName then
                    talents[internalName] = rank;  
                end
            end
            talents.count[i] = thisTreeCount;
        end
    end

    -- Tell the callback if there is one if we succeeded or failed.
    if ( talentsBuffer_Callback ) then
        talentsBuffer_Callback(state, unit);
    end
end

-- ********************************************************************
-- * DTM_TalentsBuffer_OnTalentPacket(source, talentInternal, talRank)*
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> source: the name of the guy who notifies us of his talent.    *
-- * >> talentInternal: the talent's internal name he's talking about.*
-- * >> talentRank: the points spent in this talent.                  *
-- ********************************************************************
-- * Called when someone sends us a packet notifying us of one of his *
-- * talents.                                                         *
-- ********************************************************************
function DTM_TalentsBuffer_OnTalentPacket(source, talentInternal, talentRank)
    -- Ignore PCK from self.
    if ( source == UnitName("player") ) then
        return;
    end

    local unit = DTM_GetGroupPointer(source);
    -- If we can't select the sender, there's no point continuing.
    if not ( unit ) then return; end

    DTM_Trace("NETWORK", "[%s] has sent a talent packet for [%s] talent (%d).", 1, source, talentInternal, talentRank);

    local talents = DTM_TalentsBuffer_Get(source);
    if not ( talents ) then
        DTM_Talents.number = DTM_Talents.number + 1;
        DTM_Talents[source] = {
            count = {}, -- The counter for points spent in each talent tree.
        };
        talents = DTM_Talents[source];
    end

    _, class = UnitClass(unit);
    talents.class = class;
    talents.lastUpdate = GetTime();

    -- Check this guy is talkin' about an existing talent of our own talents database and it belongs to his class.
    local talentClass, talentEffect = DTM_Talents_GetData(talentInternal);

    if ( talentClass == class ) and ( talentEffect ) then
        -- The rank this guy is telling us he has must be defined in the talent's effect table.
        if ( type( talentEffect.value ) == "table" ) and ( talentEffect.value[talentRank] ) then
            talents[talentInternal] = talentRank;
        end
    end
end

-- ********************************************************************
-- * DTM_TalentsBuffer_OnTalentsCountPacket(source, packet)           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> source: the name of the guy who tells us his talents count.   *
-- * >> packet: the coded packet.                                     *
-- ********************************************************************
-- * Called when someone sends us a packet notifying us of the points *
-- * amount spent in each talent tree.                                *
-- ********************************************************************
function DTM_TalentsBuffer_OnTalentsCountPacket(source, packet)
    -- Ignore PCK from self.
    if ( source == UnitName("player") ) then
        return;
    end

    local unit = DTM_GetGroupPointer(source);
    -- If we can't select the sender, there's no point continuing.
    if not ( unit ) then return; end

    DTM_Trace("NETWORK", "[%s] has sent a talent count packet (%s).", 1, source, packet);

    local talents = DTM_TalentsBuffer_Get(source);
    if not ( talents ) then
        DTM_Talents.number = DTM_Talents.number + 1;
        DTM_Talents[source] = {
            count = {}, -- The counter for points spent in each talent tree.
        };
        talents = DTM_Talents[source];
    end

    _, class = UnitClass(unit);
    talents.class = class;
    talents.lastUpdate = GetTime();

    -- Okay, decode the packet. We only currently accept packets with 3 entries.

    local numTrees, i, treeCount;

    numTrees = select('#', strsplit("-", packet));
    if numTrees ~= 3 then return; end -- Illegal.

    for i=1, numTrees do
        treeCount = select(i, strsplit("-", packet));
        treeCount = tonumber(treeCount) or 0;
        talents.count[i] = treeCount;
        DTM_Trace("NETWORK", "[%s] has spent %d talent points on his talent tree #%d.", 1, source, treeCount, i);
    end
end

-- ********************************************************************
-- * DTM_TalentsBuffer_NotifyTalents()                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Tells your group the talents you have chosen.                    *
-- ********************************************************************
function DTM_TalentsBuffer_NotifyTalents()
    if ( UnitAffectingCombat("player") ) then return nil; end

    local talents = DTM_TalentsBuffer_Get(UnitName("player"));
    if not ( talents ) then return; end

    local k, v;
    local packet;

    for k, v in pairs(talents) do
    if ( k ~= "class" and k ~= "lastUpdate" and k ~= "count" ) then
        packet = format("TALENT;%s;%d", k, v or 0);
        DTM_Network_SendPacket(packet);
    end
    end

    -- Now also send a packet telling how many points have been spent in each tree.

    local numTrees, i, ii, thisTreeCount;
    local talentCountString = '';

    numTrees = GetNumTalentTabs();
    for i=1, numTrees do
        thisTreeCount = 0;
        for ii=1, GetNumTalents(i) do
            name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(i, ii);
            thisTreeCount = thisTreeCount + rank;
        end
        talentCountString = talentCountString..thisTreeCount;
        if ( i < numTrees ) then
            talentCountString = talentCountString.."-";
        end
    end

    packet = format("TALCNT;%s", talentCountString);
    DTM_Network_SendPacket(packet);
end