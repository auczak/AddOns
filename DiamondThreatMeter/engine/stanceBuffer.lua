local activeModule = "Engine stance buffer";

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
-- * DTM_GetStance(guid, unit)                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of the entity to get the stance of.            *
-- * >> unit: which unit does the GUID points to ?                    *
-- ********************************************************************
-- * This API tries to determinate current stance of specified GUID,  *
-- * on which a given unit is associated.                             *
-- ********************************************************************
function DTM_GetStance(guid, unit)
    local stanceBuffer = "DEFAULT";

    if ( guid ) then
        stanceBuffer = DTM_Stance[guid] or "DEFAULT";
    end

    if ( unit ) then
        -- We've got an unit. We try to work out current stance.

        local _, class = UnitClass(unit);

        if ( UnitIsUnit(unit, "player") ) then
            if ( class == "DRUID" or class == "WARRIOR" ) then
                activeStance = "DEFAULT";
                for i=1, 16 do
                    local icon, name, active, castable = GetShapeshiftFormInfo(i);
                    if not ( name ) then break; end
                    local internalName = DTM_GetInternal("stances", name, nil);

                    if ( internalName and active ) then
                        activeStance = internalName;
                        break;
                    end
                end

                if ( guid ) then
                    DTM_Stance[guid] = activeStance;
                end
                stanceBuffer = activeStance;
          else
                -- We're not with a class which has a genuine stance system.
                -- So DEFAULT internal stance is used for the purpose of determining global threat multiplier.
            end
      else
            if ( class == "DRUID" ) then
                -- Good it's a druid. :)

                -- Ask effects system to prepare for us the list of all druid effects about stance ! :)
                local internalName, _, alwaysActive, effectEffect;
                DTM_Effects_DoListing("DRUID", "NEW_STANCE", nil, nil);

                for i=1, DTM_Effects_GetListSize() do
                    internalName, _, alwaysActive, effectEffect = DTM_Effects_GetListData(i);
                    if ( alwaysActive ) or ( DTM_Unit_SearchEffect(unit, internalName) ) then
                        if ( guid ) then
                            DTM_Stance[guid] = effectEffect.value;
                        end
                        stanceBuffer = effectEffect.value;
                        break;
                    end
                end
            end

            -- Past this point, only try to determinate stance if we do not know it yet.
            if ( stanceBuffer == "DEFAULT" ) then 
                if ( class == "WARRIOR" ) then
                    -- Damn it's a warrior. Unless it is in our group and we get a stance reminder from him by network,
                    -- or we get a effect notification denoting he changed stance, we can't determinate it !
                    -- So DEFENSIVE internal stance is used by default till we get a more clear network or combat event.
                    stanceBuffer = "DEFENSIVE";

                    -- But! We might know the amounts of points spent in arms/fury trees, so if the total of points spent is at least half the amount of talents points
                    -- available to the warrior, we assume he is in BERSERKER stance.

                    local unitName = UnitName(unit);
                    local availableTalentPoints = max(0, UnitLevel(unit) - 9);
                    local countThreshold = math.floor(availableTalentPoints / 2 + 0.5);
                    local ddTalentCount = DTM_TalentsBuffer_GetTreeTotalPoints(unitName, 1) + DTM_TalentsBuffer_GetTreeTotalPoints(unitName, 2);

                    if ( ddTalentCount >= countThreshold ) then
                        stanceBuffer = "BERSERKER";
                    end
              else
                    -- The other classes should indeed have a DEFAULT stance.
                end
            end
        end
    end

    return stanceBuffer;
end

-- --------------------------------------------------------------------
-- **                             Functions                          **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_StanceBuffer_NotifyStance(stanceInternal)                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> stanceInternal: internal name of the stance you are in.       *
-- ********************************************************************
-- * Sends a network message specifying which stance you are in.      *
-- * Return 1 if packet request was sent to the engine, nil if not.   *
-- ********************************************************************
function DTM_StanceBuffer_NotifyStance(stanceInternal)
    local guid = UnitGUID("player");
    if not ( guid ) then
        return nil;
    end
    local packet = format("STANCE_CHANGE;%s;%s", guid, stanceInternal);
    DTM_Network_SendPacket(packet);
    return 1;
end

-- ********************************************************************
-- * DTM_StanceBuffer_ApplyNotification(source, guid, stanceInternal) *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> source: the name of the player who issued the notification PCK*
-- * >> guid: GUID of the entity whose stance changed.                *
-- * >> stanceInternal: the new stance internal of the entity.        *
-- ********************************************************************
-- * Called when a network PCK(packet) is received specifying a new   *
-- * stance for the given GUID. You can set the local CHECK_TRUSTABLE *
-- * to ignore PCK from ones who tell stance changes from others but  *
-- * oneself.                                                         *
-- ********************************************************************
function DTM_StanceBuffer_ApplyNotification(source, guid, stanceInternal)
    -- Ignore PCK from self.
    if ( source == UnitName("player") ) then
        return;
    end

    if ( CHECK_TRUSTABLE ) then
        ptr = DTM_GetGroupPointer(source);
        if ( ptr ) then
            if ( UnitGUID(ptr) ~= guid ) then
                -- GUID of the sender is not the same the guid announced in the PCK. Drop it.
                return;
            end
      else
            -- Can't select the sender. Drop PCK.
            return;
        end

        DTM_Trace("STANCE", "[%s] changed its stance to '%s' stance (network).", 1, source, stanceInternal);
    end
    DTM_StanceBuffer_StanceChanged(guid, stanceInternal);
end

-- ********************************************************************
-- * DTM_StanceBuffer_StanceChanged(guid, stanceInternal)             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: GUID of the entity whose stance changed.                *
-- * >> stanceInternal: the new stance internal of the entity.        *
-- ********************************************************************
-- * Called when a stance changed notification is caught in the       *
-- * combat log.                                                      *
-- ********************************************************************
function DTM_StanceBuffer_StanceChanged(guid, stanceInternal)
    DTM_Stance[guid] = stanceInternal;
end