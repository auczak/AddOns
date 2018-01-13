local activeModule = "Engine crowd control";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                              Data                              **
-- --------------------------------------------------------------------

-- Currently, listing CCs that do not cause global threat to be ignored is pointless for DTM usage.
-- .ignoreGlobalThreat means that when an unit is crowd-controlled with a CC which has this flag
-- set will cause this unit to not be "angered" by actions that cause global threat (like healing).
-- .notSpammable tells DTM if it's possible or not to refresh the CC duration while it is running or if we have
-- to wait the end of the CC first.

local crowdControls = {
    -- Druid's crowd controls

    ["CYCLONE"] = {
        ignoreGlobalThreat = 1,
        notSpammable = 1,
        duration = 6,
    },
    ["HIBERNATE"] = {
        ignoreGlobalThreat = 1,
        notSpammable = nil,
        duration = {
            [1] = 20,
            [2] = 30,
            [3] = 40,
        },
    },

    -- Hunter's crowd controls

    ["FREEZING_TRAP"] = {
        ignoreGlobalThreat = 1,
        notSpammable = nil, -- Hardly/unlikely but still technically possible to refresh it.
        duration = {
            [1] = 10,
            [2] = 15,
            [3] = 20,
        },
    },
    ["SCARE_BEAST"] = {
        ignoreGlobalThreat = 1,
        notSpammable = nil, -- Hardly/unlikely but still technically possible to refresh it.
        duration = {
            [1] = 10,
            [2] = 15,
            [3] = 20,
        },
    },
    ["WYVERN_STING"] = {
        ignoreGlobalThreat = 1,
        notSpammable = nil, -- Hardly/unlikely but still technically possible to refresh it.
        duration = 12,
    },

    -- Mage's crowd controls

    ["POLYMORPH"] = {
        ignoreGlobalThreat = 1,
        notSpammable = nil,
        duration = {
            [1] = 20,
            [2] = 30,
            [3] = 40,
            [4] = 50,
        },
    },
    ["POLYMORPH_PIG"] = {
        ignoreGlobalThreat = 1,
        notSpammable = nil,
        duration = 50,
    },
    ["POLYMORPH_TURTLE"] = {
        ignoreGlobalThreat = 1,
        notSpammable = nil,
        duration = 50,
    },

    -- Paladin's crowd controls

    ["TURN_UNDEAD"] = {
        ignoreGlobalThreat = 1,
        notSpammable = nil, -- Hardly/unlikely but still technically possible to refresh it.
        duration = {
            [1] = 10,
            [2] = 15,
        },
    },
    ["TURN_EVIL"] = {
        ignoreGlobalThreat = 1,
        notSpammable = nil, -- Hardly/unlikely but still technically possible to refresh it.
        duration = {
            [1] = 20,
        },
    },

    -- Priest's crowd controls

    ["PSYCHIC_SCREAM"] = {
        ignoreGlobalThreat = 1,
        notSpammable = nil, -- Hardly/unlikely but still technically possible to refresh it.
        duration = 8,
    },
    ["SHACKLE_UNDEAD"] = {
        ignoreGlobalThreat = 1,
        notSpammable = nil,
        duration = {
            [1] = 30,
            [2] = 40,
            [3] = 50,
        },
    },

    -- Rogue's crowd controls

    ["SAP"] = {
        ignoreGlobalThreat = 1,
        notSpammable = nil,
        duration = {
            [1] = 25,
            [2] = 35,
            [3] = 45,
        },
    },

    -- Shaman's crowd controls

    -- Warlock's crowd controls

    ["BANISH"] = {
        ignoreGlobalThreat = 1,
        notSpammable = 1,
        duration = {
            [1] = 20,
            [2] = 30,
        },
    },
    ["FEAR"] = {
        ignoreGlobalThreat = 1,
        notSpammable = nil,
        duration = {
            [1] = 10,
            [2] = 15,
            [3] = 20,
        },
    },
    ["SEDUCTION"] = {
        ignoreGlobalThreat = 1,
        notSpammable = nil,
        duration = 15,
    },

    -- Warrior's crowd controls

    ["INTIMIDATING_SHOUT"] = {
        ignoreGlobalThreat = 1,
        notSpammable = nil,
        duration = 8,
    },
};

-- --------------------------------------------------------------------
-- **                               API                              **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_CrowdControl_GetControlData(name, rank)                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the internal name of the crowd control to get data of.  *
-- * >> rank: the rank of the effect to query.                        *
-- ********************************************************************
-- * Gets info about a crowd control effect.                          *
-- * Returns:                                                         *
-- *    1. Flag "ignore global threat" (see above).                   *
-- *    2. Flag "not spammable" (see above).                          *
-- *    3. Expected duration (seconds, vary with rank given).         *
-- ********************************************************************
function DTM_CrowdControl_GetControlData(name, rank)
    local data = crowdControls[name];
    if ( data ) then
        local durationData = data.duration;
        if ( type(durationData) == "table" ) then
            rank = tonumber(rank) or 1;
            durationData = durationData[rank];
      else
            -- Leave it as it is.
        end
        return data.ignoreGlobalThreat, data.notSpammable, durationData;
    end
    return nil, nil, 0;
end

-- ********************************************************************
-- * DTM_CrowdControl_IsIgnoringGlobalThreat(guid)                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of the PC/NPC whose crowd control status       *
-- * is queried.                                                      *
-- ********************************************************************
-- * Determinates if a given unit ignores the global threat.          *
-- * because it is crowd-controlled.                                  *
-- ********************************************************************
function DTM_CrowdControl_IsIgnoringGlobalThreat(guid)
    local entityData = DTM_EntityData_Get(guid, nil);
    if ( entityData ) then
        local ccData = entityData.crowdControl;
        local name, amount, ignoreGlobalThreat;
        for name, amount in pairs(ccData) do
            ignoreGlobalThreat, _, _ = DTM_CrowdControl_GetControlData(name, nil);
            if ( ignoreGlobalThreat ) then
                return 1; -- One CC enabled is enough.
            end            
        end
    end
    return nil;
end

-- --------------------------------------------------------------------
-- **                             Handlers                           **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_CrowdControl_UnitGainedEffect(guid, name,                    *
-- *                                   effectName, effectRank)        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of the PC/NPC who gained the effect.           *
-- * >> name: the name of the PC/NPC who gained the effect.           *
-- * >> effectName: the *internal* name of the effect gained.         *
-- * >> effectRank: the rank of the effect gained.                    *
-- ********************************************************************
-- * Gets called when an unit gains a buff/debuff, to check if it     *
-- * has become flagged as crowd controlled by DTM.                   * 
-- ********************************************************************
function DTM_CrowdControl_UnitGainedEffect(guid, name, effectName, effectRank)
    if not ( guid ) or not ( effectName ) then return; end

    local entityData = DTM_EntityData_Get(guid, 1);
    entityData.name = entityData.name or name;
    local ccData = entityData.crowdControl;

    local ignoreGlobalThreat, notSpammable, duration = DTM_CrowdControl_GetControlData(effectName, effectRank);

    if ( duration > 0 ) then -- Is the effect gained a valid CC ?
        ccData[effectName] = duration;

        DTM_Trace("CROWD_CONTROL", "[%s] has been affected by [%s] CC for %d sec.", 1, name or '<?>', effectName, duration);
    end
end

-- ********************************************************************
-- * DTM_CrowdControl_UnitLostEffect(guid, name,                      *
-- *                                 effectName, effectRank)          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of the PC/NPC who lost the effect.             *
-- * >> name: the name of the PC/NPC who lost the effect.             *
-- * >> effectName: the *internal* name of the effect gained.         *
-- * >> effectRank: the rank of the effect gained.                    *
-- ********************************************************************
-- * Gets called when an unit loses a buff/debuff, to check if it     *
-- * is no longer flagged as crowd controlled by DTM.                 * 
-- ********************************************************************
function DTM_CrowdControl_UnitLostEffect(guid, name, effectName, effectRank)
    if not ( guid ) or not ( effectName ) then return; end

    local entityData = DTM_EntityData_Get(guid, 1);
    entityData.name = entityData.name or name;
    local ccData = entityData.crowdControl;

    local ignoreGlobalThreat, notSpammable, duration = DTM_CrowdControl_GetControlData(effectName, effectRank);

    if ( duration > 0 ) then -- Is the effect lost a valid CC ?
        ccData[effectName] = nil;

        DTM_Trace("CROWD_CONTROL", "[%s] has been released from [%s] CC.", 1, name or '<?>', effectName);
    end
end

-- ********************************************************************
-- * DTM_CrowdControl_OnUpdate(elapsed)                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> elapsed: the time that elapsed since the last call.           *
-- ********************************************************************
-- * Gets called periodically to time-out crowd controls that are     *
-- * active on the various entities.                                  * 
-- ********************************************************************
function DTM_CrowdControl_OnUpdate(elapsed)
    DTM_EntityData_PickUpTableAndDo(DTM_CrowdControl_OnUpdatePickup, elapsed);
end
function DTM_CrowdControl_OnUpdatePickup(entityData, elapsed)
    local ccData = entityData.crowdControl;
    local name, duration, notSpammable;
    for name, duration in pairs(ccData) do
        ccData[name] = max(0, duration - elapsed);
        _, notSpammable, _ = DTM_CrowdControl_GetControlData(name, nil);
        if ( notSpammable ) and ( ccData[name] == 0 ) then
            ccData[name] = nil;
            DTM_Trace("CROWD_CONTROL", "We are sure that [%s] expired on [%s].", 1, name, entityData.name or '<?>');
        end
    end
end