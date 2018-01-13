local activeModule = "Engine aggro";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local currentGUIDTarget = {};

-- --------------------------------------------------------------------
-- **                           Functions                            **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Aggro_Set(name, guid, aggroName, aggroGUID)                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name : the name of the unit who changes its aggro.            *
-- * >> guid : the GUID of the unit who changes its aggro.            *
-- * >> aggroName : the name of the unit who has now aggro.           *
-- * >> aggroGUID : the GUID of the unit who has now aggro.           *
-- * aggroX arguments are omittable, but if you do, there will be less*
-- * useable data for the GUI & API. :)                               *
-- ********************************************************************
-- * Gets called when an entity changes its aggro target.             *
-- ********************************************************************
function DTM_Aggro_Set(name, guid, aggroName, aggroGUID)
    if not ( guid ) then return; end

    local entityData = DTM_EntityData_Get(guid, 1);
    entityData.name = name or entityData.name;

    if ( aggroName ) then
        entityData.threatList.aggroName = aggroName;
        DTM_Trace("AGGRO", "[%s] is aggro'd on [%s].", 1, entityData.name or "?", aggroName);
    end
    if ( aggroGUID ) then
        entityData.threatList.aggroGUID = aggroGUID;
        DTM_ThreatList_Modify(name, guid, aggroName, aggroGUID, "VALUE", 0, nil); -- Ensure the guy who is targetted is in threat list.
    end
end

-- --------------------------------------------------------------------
-- **                            Handlers                            **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_CheckTargetOfUnitChange(unitId)                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unitId: the UID who changed its target.                       *
-- ********************************************************************
-- * Gets called when target of target changed, to determinate aggro  *
-- * changes.                                                         *
-- ********************************************************************
function DTM_CheckTargetOfUnitChange(unitId)
    if ( DTM_OnWotLK() ) and not ( DTM_GetSavedVariable("engine", "workMethod", "active") == "PARSE" ) then
        -- Native WotLK threat meter allows us to be no longer bothered by unperfect aggro target determination. :]
        -- Except if we use the ol' combat log parse method.
        return;
    end

    if not ( DTM_IsEngineRunning() == 1 ) then
        return;
    end

    if not ( unitId ) then unitId = arg1; end

    if not ( UnitExists(unitId) ) or not ( DTM_CanHoldThreatList(unitId) ) then
        return;
    end

    local myGUID = UnitGUID(unitId);

    local targetUID = unitId .. "target";
    if ( UnitIsUnit(unitId, "player") ) then targetUID = "target"; end

    myTargetGUID = UnitGUID(targetUID);

    if ( myTargetGUID ~= currentGUIDTarget[myGUID] ) then
        currentGUIDTarget[myGUID] = myTargetGUID;

        -- Remove any aggro pending event affecting the unit.
        DTM_Time_EffectLost(UnitName(unitId), myGUID, "AGGRO_PENDING");

        if ( UnitExists(targetUID) ) and ( UnitCanAttack(unitId, targetUID) ) then
            local _, _, delay = DTM_UnitThreatFlags(unitId);

            if ( delay <= 0 ) then
                -- We set aggro change at once.
                DTM_Aggro_Set(UnitName(unitId), myGUID, UnitName(targetUID), myTargetGUID);
          else
                -- We do not confirm aggro change at once, it might be a quick target swap performed by the mob.
                DTM_Time_AddEvent(UnitName(unitId), myGUID, "AGGRO_PENDING", nil, delay, nil, "CONFIRM_AGGRO", nil, UnitName(targetUID), myTargetGUID);
            end
        end
    end
end

-- ********************************************************************
-- * DTM_UnitHasLandedMeleeHit(actorName, actorGUID,                  *
-- *                           targetName, targetGUID)                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> actorName, actorGUID: infos about the guy who landed the hit. *
-- * >> targetName, targetGUID: infos about the guy who got hit.      *
-- ********************************************************************
-- * Gets called someone lands a normal melee hit (swing) on someone. *
-- * This means we are sure <actor> has <target> as aggro target.     *
-- * (This idea was borrowed from KTM ;) )                            *
-- * This additionnal way of getting aggro increases the chance to    *
-- * have complete threat list and upgrades heal threat accuracy.     *
-- ********************************************************************
function DTM_UnitHasLandedMeleeHit(actorName, actorGUID, targetName, targetGUID)
    currentGUIDTarget[actorGUID] = targetGUID;

    -- Check if the actor can have a threat list. If it can't, there's no point in setting its aggro target.
    local actorPtr = DTM_GetUnitPointer(actorGUID);
    if ( actorPtr ) then
        if ( not DTM_CanHoldThreatList(actorPtr) ) then
            return;
        end
  else
        if ( not DTM_CanHoldThreatListLimited(actorGUID) ) then
            return;
        end
    end

    -- Remove any aggro pending event affecting the unit.
    DTM_Time_EffectLost(actorName, actorGUID, "AGGRO_PENDING");

    -- We set aggro change at once, melee hits do not need some time to be sure it's actual aggro target.
    DTM_Aggro_Set(actorName, actorGUID, targetName, targetGUID);
end
