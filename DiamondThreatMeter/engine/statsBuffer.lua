local activeModule = "Engine stats buffer";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local CHECK_TRUSTABLE = 1;

-- --------------------------------------------------------------------
-- **                               API                              **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_GetStat(guid, unit, statInternal)                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of the entity to get the stat of.              *
-- * >> unit: which unit does the GUID points to ?                    *
-- * >> statInternal: the stat to get's internal name. (e.g: 'AP')    *
-- ********************************************************************
-- * This API tries to determinate a stat of specified GUID,          *
-- * on which a given unit is associated.                             *
-- * Currently, only 2 stats are buffered (some more could come if    *
-- * they are relevant to threat determination) :                     *
-- * > Attack power - 'AP'                                            *
-- * > Level - 'LV' (not necessary, but still done for conveniance)   *
-- ********************************************************************
function DTM_GetStat(guid, unit, statInternal)
    local statsBuffer = nil;

    if ( unit ) then
        -- We've got an unit. We try to directly access stats value.

        if ( statInternal == "LV" ) then
            return UnitLevel(unit);
        end

        if ( unit == "player" ) or ( unit == "pet" ) then
            -- OK, we can get all stats for "player" or "pet" units.

            local base, posBuff, negBuff;
            local effectiveValue = nil;

            if ( statInternal == "AP" ) then
                base, posBuff, negBuff = UnitAttackPower(unit);
                effectiveValue = max(0, base+posBuff+negBuff);
            end

            return effectiveValue;
        end
    end

    if ( guid ) then
        statsBuffer = DTM_Stats[guid] or nil;

        if ( statsBuffer ) then
            return statsBuffer[statInternal] or nil;
        end
    end

    return nil;
end

-- ********************************************************************
-- * DTM_StatsBuffer_Grab(unit)                                       *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit to grab and inform stats of.                   *
-- ********************************************************************
-- * Get stats data of a given unit. Only "player" and "pet" unitIds  *
-- * are allowed to be passed to this function.                       *
-- ********************************************************************
function DTM_StatsBuffer_Grab(unit)
    if ( unit ~= "player" ) and ( unit ~= "pet" ) then return; end
    if not ( UnitExists(unit) ) then return; end

    local guid = UnitGUID(unit);
    if not ( guid ) then
        return nil;
    end

    if not ( DTM_Stats[guid] ) then DTM_Stats[guid] = {}; end

    local statsBuffer = DTM_Stats[guid];
    local base, posBuff, negBuff;
    local effectiveValue;

    -- Grab LV.

    statsBuffer["LV"] = UnitLevel(unit);

    -- Grab AP.

    base, posBuff, negBuff = UnitAttackPower(unit);
    statsBuffer["AP"] = max(0, base+posBuff+negBuff);

    -- Send an update packet.

    local packet = format("STATS_UPDATE;%s;%d;%d", guid, statsBuffer["LV"], statsBuffer["AP"]);
    DTM_Network_SendPacket(packet);
end

-- --------------------------------------------------------------------
-- **                             Functions                          **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_StatsBuffer_ApplyUpdate(source, guid, ...)                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> source: the name of the player who issued the notification PCK*
-- * >> guid: GUID of the entity whose stats changed.                 *
-- * >> ...: the list of updated stats.                               *
-- ********************************************************************
-- * Called when a network PCK is received giving stats update of an  *
-- * entity. You can set the local CHECK_TRUSTABLE to ignore PCK from *
-- * ones who tell stats changes from others but oneself or one's pet.*
-- ********************************************************************
function DTM_StatsBuffer_ApplyUpdate(source, guid, ...)
    -- Ignore PCK from self.
    if ( source == UnitName("player") ) then
        return;
    end

    if ( CHECK_TRUSTABLE ) then
        ptr = DTM_GetGroupPointer(source);
        if ( ptr ) then
            if ( UnitGUID(ptr) ~= guid ) and ( UnitGUID(ptr.."pet") ~= guid ) then
                -- GUID of the sender is not the same the guid announced or his/her pet's GUID. Drop it.
                return;
            end
      else
            -- Can't select the sender. Drop PCK.
            return;
        end
    end

    -- Apply the packet data.

    if not ( DTM_Stats[guid] ) then DTM_Stats[guid] = {}; end

    DTM_Trace("NETWORK", "[%s] has submitted its new stats values (LV: %s, AP: %s)", 1, source, ...);

    local statsBuffer = DTM_Stats[guid];
    local level, ap = select(1, ...);

    statsBuffer["LV"] = tonumber(level) or nil;
    statsBuffer["AP"] = tonumber(ap) or nil;
end