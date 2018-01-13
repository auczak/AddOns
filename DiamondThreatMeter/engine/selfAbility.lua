local activeModule = "Engine self casts";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local PENDING_CAST_TIMEOUT = 15.000;
local CAST_VALIDATION_TIME = 0.250; -- That is the time Resist/Parry/Dodge/Miss etc. messages will have to show up before the cast is considered really
                                    -- successful and a network message is sent to everyone.

-- --------------------------------------------------------------------
-- **                   List management functions                    **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SelfAbility_GetCastData(spellName, statusFilter)             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> spellName: pending spell's name to get infos about.           *
-- * >> statusFilter: if set, this function will only pickup cast data*
-- * instances of <spellName> spell that have the <statusFilter> state*
-- ********************************************************************
-- * Grab data related to a pending local player's spellcast.         *
-- ********************************************************************
function DTM_SelfAbility_GetCastData(spellName, statusFilter)
    local i;
    for i=1, DTM_SelfCast.number do
        if ( DTM_SelfCast[i].name == spellName ) and ( ( not statusFilter ) or ( DTM_SelfCast[i].status == statusFilter ) ) then
            return DTM_SelfCast[i];
        end
    end
    return nil;
end

-- ********************************************************************
-- * DTM_SelfAbility_AddCast(name, rank,                              *
-- *                         targetName, targetGUID, targetFlags)     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the (localised) name of ability pending.                *
-- * >> rank: its rank (a number, not a string !).                    *
-- * >> targetName: the name of the target that will get hit.         *
-- * >> targetGUID: the GUID of the target that will get hit.         *
-- ********************************************************************
-- * Registers a pending self-detectable-only spellcast for local     *
-- * player.                                                          *
-- ********************************************************************
function DTM_SelfAbility_AddCast(name, rank, targetName, targetGUID)
    -- Get the ability internal name, then check the ability's detection field is flagged as LOCAL.
    local ability = DTM_GetInternal("abilities", name, 1);
    if not ( ability ) then return; end
    local abilityClass, abilityEffect = DTM_Abilities_GetData(ability);
    if not ( abilityEffect ) then return; end
    local abilityDetection = abilityEffect.detection or "UNIVERSAL";
    if ( abilityDetection ~= "LOCAL" and abilityDetection ~= "FEIGN_DEATH" ) then return; end

    -- We can't cast 2 instances of the same spell at the same time that have the PENDING status.
    DTM_SelfAbility_DeleteCastByName(name, "PENDING");

    DTM_SelfCast.number = DTM_SelfCast.number + 1;
    DTM_SelfCast[DTM_SelfCast.number] = {
        name = name,
        rank = rank,
        internal = ability,
        targetName = targetName,
        targetGUID = targetGUID,
        status = "PENDING",
        timeOut = PENDING_CAST_TIMEOUT,
        validationTime = CAST_VALIDATION_TIME,
        checkMiss = abilityEffect.checkMiss,
        feignDeathProtocol = (abilityDetection == "FEIGN_DEATH"),
    };
end

-- ********************************************************************
-- * DTM_SelfAbility_DeleteCast(index)                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> index: index of the cast to delete.                           *
-- ********************************************************************
-- * Delete a pending cast in the self ability buffer table by index. *
-- ********************************************************************
function DTM_SelfAbility_DeleteCast(index)
    local i;
    DTM_SelfCast.number = DTM_SelfCast.number - 1;
    for i=index, DTM_SelfCast.number do
        DTM_SelfCast[i] = DTM_SelfCast[i+1];
        DTM_SelfCast[i+1] = nil;
    end
end

-- ********************************************************************
-- * DTM_SelfAbility_DeleteCastByName(name, statusFilter)             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: name of the spellcast to delete.                        *
-- * >> statusFilter: if set, only instances of <name> spell with     *
-- * status equals to this field will be removed.                     *
-- ********************************************************************
-- * Delete a pending cast in the self ability buffer table by name.  *
-- ********************************************************************
function DTM_SelfAbility_DeleteCastByName(name, statusFilter)
    local i;
    for i=DTM_SelfCast.number, 1, -1 do
        if ( DTM_SelfCast[i].name == name ) and ( ( not statusFilter ) or ( DTM_SelfCast[i].status == statusFilter ) ) then
            DTM_SelfAbility_DeleteCast(i);
        end
    end
end

-- ********************************************************************
-- * DTM_SelfAbility_DeleteFeignDeathCast(statusFilter)               *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> statusFilter: if set, only instances of feign death spells    *
-- * with status equals to this field will be removed.                *
-- ********************************************************************
-- * Delete a pending feign-death type cast. This ability doesn't     *
-- * remove abilities with name "Feign Death" but will instead remove *
-- * abilities that use "FEIGN_DEATH" as their DETECTION protocol.    *
-- ********************************************************************
function DTM_SelfAbility_DeleteFeignDeathCast(statusFilter)
    local i;
    for i=DTM_SelfCast.number, 1, -1 do
        if ( DTM_SelfCast[i].feignDeathProtocol ) and ( ( not statusFilter ) or ( DTM_SelfCast[i].status == statusFilter ) ) then
            DTM_SelfAbility_DeleteCast(i);
        end
    end
end

-- --------------------------------------------------------------------
-- **                     Application functions                      **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SelfAbility_Update(elapsed)                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> elapsed: how much time passed since last call.                *
-- ********************************************************************
-- * Update the spellcast buffer, removing timeouts.                  *
-- ********************************************************************
function DTM_SelfAbility_Update(elapsed)
    local i, castData;

    for i=DTM_SelfCast.number, 1, -1 do
        castData = DTM_SelfCast[i];

        if ( castData.status == "PENDING" ) then
            castData.timeOut = castData.timeOut - elapsed;
            if ( castData.timeOut <= 0.000 ) then
                DTM_SelfAbility_DeleteCast(i);
            end

    elseif ( castData.status == "SUCCESS" ) then
            castData.validationTime = castData.validationTime - elapsed;
            if ( castData.validationTime <= 0.000 ) then
                DTM_SelfCast_Validate(castData);
                DTM_SelfAbility_DeleteCast(i);
            end
      else
            DTM_SelfAbility_DeleteCast(i);
        end
    end
end

-- ********************************************************************
-- * DTM_SelfCast_Register(unit, spellName, spellRank, spellTarget)   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: should be "player" or this function will silently fail. *
-- * >> spellName: the name of the spell that is going to be cast.    *
-- * >> spellRank: its rank.                                          *
-- * >> spellTarget: its target. GUID will be determinated at once.   *
-- ********************************************************************
-- * Fired when client sends a spell cast request to the server.      *
-- ********************************************************************
function DTM_SelfCast_Register(unit, spellName, spellRank, spellTarget)
    if not ( DTM_IsEngineRunning() == 1 ) then
        return;
    end

    if not ( unit ) then unit = arg1; end
    if not ( spellName ) then spellName = arg2; end
    if not ( spellRank ) then spellRank = arg3; end
    if not ( spellTarget ) then spellTarget = arg4; end
    if not ( unit ) or not ( spellName ) or not ( spellTarget ) then return; end
    if ( unit ~= "player") then return; end

    spellRank = DTM_GetRankFromString(spellRank);
    if ( spellTarget == "" ) then spellTarget = UnitName("player"); end

    local ptr = DTM_GetUnitPointer(spellTarget);
    if not ( ptr ) then return; end -- Can't proceed without an unitID.

    local targetGUID = UnitGUID(ptr);
    if not ( targetGUID ) then return; end -- Can't proceed without target's GUID.

    DTM_SelfAbility_AddCast(spellName, spellRank, spellTarget, targetGUID);
end

-- ********************************************************************
-- * DTM_SelfCast_Success(unit, spellName)                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: should be "player" or this function will silently fail. *
-- * >> spellName: the name of the spell which succeeded.             *
-- ********************************************************************
-- * Fired when the local player's pending spellcast is a success.    *
-- * Note that this doesn't mean it wasn't resisted, so we have to    *
-- * wait a bit longer before telling.                                *
-- ********************************************************************
function DTM_SelfCast_Success(unit, spellName)
    if not ( DTM_IsEngineRunning() == 1 ) then
        return;
    end

    if not ( unit ) then unit = arg1; end
    if not ( spellName ) then spellName = arg2; end
    if not ( unit ) or not ( spellName ) then return; end
    if ( unit ~= "player") then return; end

    local castData = DTM_SelfAbility_GetCastData(spellName, "PENDING");
    if ( castData ) then
        castData.status = "SUCCESS";

        if not ( castData.checkMiss or castData.feignDeathProtocol ) then
            -- If there's no miss chance, sends at once validation.
            DTM_SelfCast_Validate(castData);
            DTM_SelfAbility_DeleteCastByName(spellName, "SUCCESS");
        end
    end
end

-- ********************************************************************
-- * DTM_SelfCast_Validate(castData)                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> castData: the data of the cast that was validated.            *
-- ********************************************************************
-- * Validates a successful cast (that is, we consider there was no   *
-- * resist/parry/dodge/miss etc.) and send a network event.          *
-- ********************************************************************
function DTM_SelfCast_Validate(castData)
    if not ( castData ) then return; end

    local ability = castData.internal;

    local selfName = UnitName("player");
    local selfGUID = UnitGUID("player");

    if not ( selfName ) or not ( selfGUID ) then return; end

    local packet = format("SELF_CAST;%s;%s;%s;%s;%s;%s", selfName, selfGUID, ability, (castData.rank or "NONE"), castData.targetName, castData.targetGUID);
    DTM_Network_SendPacket(packet);

    DTM_Combat_SelfCastApply(selfName, selfGUID, castData.targetName, castData.targetGUID, ability, (castData.rank or "NONE"));
end

-- ********************************************************************
-- * DTM_SelfCast_Interrupt(unit, spellName)                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: should be "player" or this function will silently fail. *
-- * >> spellName: the name of the spell which failed/was interrupted.*
-- ********************************************************************
-- * Fired when the local player's sent spellcast was cancelled or    *
-- * interrupted midcast. This allows to do maintenance on SelfCast   *
-- * buffer table, in addition to casts timeouts.                     *
-- ********************************************************************
function DTM_SelfCast_Interrupt(unit, spellName)
    if not ( DTM_IsEngineRunning() == 1 ) then
        return;
    end

    if not ( unit ) then unit = arg1; end
    if not ( spellName ) then spellName = arg2; end
    if not ( unit ) or not ( spellName ) then return; end
    if ( unit ~= "player") then return; end

    DTM_SelfAbility_DeleteCastByName(spellName, "PENDING");
end

-- --------------------------------------------------------------------
-- **                        Special handler                         **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SelfCast_OnErrorMessage(message)                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> message: the error message we've received.                    *
-- ********************************************************************
-- * Fired when we encounter an error message (red messages on the    *
-- * top of the screen). This handler allows us to call self casts of *
-- * feign death-like abilities.                                      *
-- ********************************************************************
function DTM_SelfCast_OnErrorMessage(message)
    if not ( DTM_IsEngineRunning() == 1 ) then
        return;
    end
    if not ( message ) then message = arg1; end

    if ( message == ERR_FEIGN_DEATH_RESISTED ) then
        DTM_Trace("THREAT_EVENT", "Local player's feign death has been resisted.");
        DTM_SelfAbility_DeleteFeignDeathCast(); -- Do not take risks with the filter. According to Omen2, the UI error message apparears before the cast
    end                                         -- successful event is fired.
end