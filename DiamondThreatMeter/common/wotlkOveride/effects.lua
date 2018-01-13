local activeModule = "Effects (WotLK)";

-- This file contains overides for WotLK Beta DTM version.
-- It will not be run on live clients.

if ( not DTM_OnWotLK() ) then
    return;
end

-- --------------------------------------------------------------------
-- **                         Effects table                          **
-- --------------------------------------------------------------------

local list = {
    number = 0,
};

local lookupData = {};

local DTM_Effects = {
    -- Druid effects

    ["BEAR_FORM"] = {
        class = "DRUID",
        effect = {
            type = "NEW_STANCE",
            value = "BEAR",
        }
    },
    ["DIRE_BEAR_FORM"] = {
        class = "DRUID",
        effect = {
            type = "NEW_STANCE",
            value = "BEAR",
        }
    },
    ["CAT_FORM"] = {
        class = "DRUID",
        effect = {
            type = "NEW_STANCE",
            value = "CAT",
        }
    },
    ["AQUATIC_FORM"] = {
        class = "DRUID",
        effect = {
            type = "NEW_STANCE",
            value = "AQUATIC",
        }
    },
    ["TRAVEL_FORM"] = {
        class = "DRUID",
        effect = {
            type = "NEW_STANCE",
            value = "TRAVEL",
        }
    },
    ["MOONKIN_FORM"] = {
        class = "DRUID",
        effect = {
            type = "NEW_STANCE",
            value = "MOONKIN",
        }
    },
    ["FLIGHT_FORM"] = {
        class = "DRUID",
        effect = {
            type = "NEW_STANCE",
            value = "FLIGHT",
        }
    },
    ["SWIFT_FLIGHT_FORM"] = {
        class = "DRUID",
        effect = {
            type = "NEW_STANCE",
            value = "FLIGHT",
        }
    },
    -- ToL form is not handled here because unfortunatley, the buff shares the same name as the aura. Thanks goodness, it has no particularity regarding threat level.

    -- Hunter effects

    ["MISDIRECTION"] = {
        class = "HUNTER",
        effect = {
            type = "THREAT_REDIRECTION",
            value = 1.00,
            duration = 30,
        }
    },
    ["INTIMIDATION"] = {
        class = "HUNTER",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 1.50,
            target = "GLOBAL_THREAT",
        }
    },

    -- Mage effects

    ["INVISIBILITY"] = {      -- There are 2 separate buffs but they share the same name.
        class = "MAGE",       -- One could use the spellId instead to get the distinction between them.
        effect = {
            type = "PERIODIC_THREAT_MULTIPLY",
            value = 0.00,
            ticks = 3,     -- 2/1 sec. if prismatic cloak 1/2.
            duration = 3,  -- 2/1 sec. if prismatic cloak 1/2.
            target = "THREAT_LEVEL",
        }
    },
    ["INVISIBILITY_APPLY"] = {
        class = "MAGE",
        effect = {
            type = "DROP",
        }
    },

    -- Paladin effects

    ["RIGHTEOUS_DEFENSE"] = {
        class = "PALADIN",
        effect = {
            type = "DEFENSIVE_TAUNT",
        },
    },
    ["RIGHTEOUS_FURY"] = {
        class = "PALADIN",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 1.90,
            target = "ABILITIES",
            abilities = {
                number = 20,
                [1] = "SEAL_OF_RIGHTEOUSNESS",
                [2] = "HOLY_LIGHT",
                [3] = "LAY_ON_HANDS",
                [4] = "RETRIBUTION_AURA",
                [5] = "EXORCISM",
                [6] = "FLASH_OF_LIGHT",
                [7] = "CONSECRATION",
                [8] = "HAMMER_OF_WRATH",
                [9] = "HOLY_WRATH",
                [10] = "SEAL_OF_BLOOD",
                [11] = "SEAL_OF_VENGEANCE",
                [12] = "HOLY_SHOCK",
                [13] = "AVENGER_SHIELD",
                [14] = "SEAL_OF_COMMAND",
                [15] = "JUDGEMENT_OF_RIGHTEOUSNESS",
                [16] = "JUDGEMENT_OF_COMMAND",
                [17] = "JUDGEMENT_OF_BLOOD",
                [18] = "JUDGEMENT_OF_VENGEANCE",
                [19] = "HOLY_SHIELD",
                [20] = "HAMMER_OF_JUSTICE",
            }
        }
    },
    ["BLESSING_OF_SALVATION"] = {
        class = "PALADIN",
        effect = {
            type = "PERIODIC_THREAT_MULTIPLY",
            value = 0.80,
            ticks = 10,
            duration = 10,
            target = "THREAT_LEVEL",
        }
    },
    ["DIVINE_INTERVENTION"] = {
        class = "PALADIN",
        effect = {
            type = "DROP",
        }
    },
    ["PALADIN_PASSIVE_REDUCTION"] = {
        class = "PALADIN",
        alwaysActive = 1,
        effect = {
            type = "MULTIPLY_THREAT",
            value = 0.50,
            target = "ABILITIES",
            abilities = {
                number = 4,
                [1] = "HOLY_LIGHT",
                [2] = "FLASH_OF_LIGHT",
                [3] = "HOLY_SHOCK",
                [4] = "LAY_ON_HANDS",
            },
            condition = "TYPE:HEAL", -- This ensures offensive holy shock won't get affected.
        }
    },

    -- Priest effects

    ["FADE"] = {
        class = "PRIEST",
        effect = {
            type = "TEMPORARY_ADDITIVE_THREAT",
            value = {         -- We record each mob that have the priest on their threat list, and we memorize the amount
                [1] = -55,    -- of threat that will be given back to each mob upon buff ends, on a per-case basis.
                [2] = -155,
                [3] = -285,
                [4] = -440,
                [5] = -620,
                [6] = -820,
                [7] = -1500,
            },
            duration = 10,
            target = "THREAT_LEVEL",
        }
    },
    ["PAIN_SUPPRESSION"] = {
        class = "PRIEST",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 0.95,
            target = "THREAT_LEVEL",
        }
    },
    ["SHADOW_FORM"] = {
        class = "PRIEST",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 0.70,
            target = "GLOBAL_THREAT",
        }
    },

    -- Rogue effects

    ["VANISH"] = {
        class = "ROGUE",
        effect = {
            type = "DROP",
        }
    },
    ["SHADOWSTEP"] = { -- Since 2.3
        class = "ROGUE",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 0.50,
            target = "GLOBAL_THREAT",
        }
    },
    ["ROGUE_PASSIVE_REDUCTION"] = {
        class = "ROGUE",
        alwaysActive = 1,
        effect = {
            type = "MULTIPLY_THREAT",
            value = 0.71,
            target = "GLOBAL_THREAT",
        }
    },

    -- Shaman effects

    ["TRANQUIL_AIR"] = {
        class = "SHAMAN",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 0.80,
            target = "GLOBAL_THREAT",
        }
    },

    -- Warlock effects
    -- <None>
    -- Note: Master demonologist is handled in DTM as a conditionnal talent.

    -- Warrior effects

    ["COMBAT_STANCE"] = {
        class = "WARRIOR",
        effect = {
            type = "NEW_STANCE",
            value = "COMBAT",
        }
    },
    ["DEFENSIVE_STANCE"] = {
        class = "WARRIOR",
        effect = {
            type = "NEW_STANCE",
            value = "DEFENSIVE",
        }
    },
    ["BERSERKER_STANCE"] = {
        class = "WARRIOR",
        effect = {
            type = "NEW_STANCE",
            value = "BERSERKER",
        }
    },

    -- Pets effects
    -- <None>

    -- Item effects.

    ["STEALTHBLADE"] = {
        class = "ITEM",
        effect = {
            type = "TEMPORARY_ADDITIVE_THREAT",
            value = -55,
            duration = 10,
            target = "THREAT_LEVEL",
        }
    },
    ["EYE_OF_DIMINUTION"] = {
        class = "ITEM",
        effect = {
            type = "MULTIPLY_THREAT",
            value = function(sourcePtr, effectRank)
                        if not ( sourcePtr ) then return 0.75; end -- If we don't have the pointer, it's probably a LV 70 char nonetheless.
                        local pLevel = UnitLevel(sourcePtr) or 0;
                        if ( pLevel > 60 ) then
                            return 0.65 + (pLevel - 60) * 0.01;
                        end
                        return 0.65;
                    end,
            target = "GLOBAL_THREAT",
            duration = 20.0,
            cache = 1, -- Do not know the localised name for this effect. Use the cache in conjunction with spellID.
        }
    },
    ["FETISH_OF_THE_SAND_REAVER"] = {
        class = "ITEM",
        effect = {
            type = "MULTIPLY_THREAT",
            value = function(sourcePtr, effectRank)
                        if not ( sourcePtr ) then return 0.50; end -- If we don't have the pointer, it's probably a LV 70 char nonetheless.
                        local pLevel = UnitLevel(sourcePtr) or 0;
                        if ( pLevel > 60 ) then
                            return 0.30 + (pLevel - 60) * 0.02;
                        end
                        return 0.30;
                    end,
            target = "GLOBAL_THREAT",
            duration = 20.0,
            cache = 1, -- Do not know the localised name for this effect. Use the cache in conjunction with spellID.
        }
    },

    -- Special (boss/NPC) effects.

    ["FUNGAL_BLOOM"] = { -- Actions cause no threat. Applied by Loatheb in Naxxramas.
        class = "NPC",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 0.00,
            target = "GLOBAL_THREAT",
            duration = 90.0,
            cache = 1, -- Do not know the localised name for this effect. Use the cache in conjunction with spellID.
        }
    },
    ["SEETHE"] = { -- Increases threat generated by all actions of 200%. Unknown source.
        class = "NPC",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 3.00,
            target = "GLOBAL_THREAT",
            duration = 10.0,
            cache = 1, -- Do not know the localised name for this effect. Use the cache in conjunction with spellID.
        }
    },
    ["INSIGNIFIGANCE"] = { -- Reduces threat generated by all actions of 100% (I know it is applied by Terokk[?] and Gurtogg Bloodboil).
        class = "NPC",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 0.00,
            target = "GLOBAL_THREAT",
        }
    },
    ["FEL_RAGE"] = { -- Implicit - Reduces threat generated by all actions of 100%. Applied by Gurtogg Bloodboil.
        class = "NPC",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 0.00,
            target = "GLOBAL_THREAT",
        }
    },
    ["WILD_MAGIC"] = { -- Increases threat generated by all actions of 100%. Applied by Kalecgos (SWP).
        class = "NPC",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 2.00,
            target = "GLOBAL_THREAT",
            duration = 20.0,
            cache = 1, -- There are other instances of this debuff that have the same name but not this threat effect. We need the effect caching feature.
        }
    },
    ["SPITEFUL_FURY"] = { -- Increases threat generated by all actions of 500%. Applied by Spiteful Temptresses in the Arcatraz.
        class = "NPC",
        effect = {
            type = "MULTIPLY_THREAT",
            value = 6.00,
            target = "GLOBAL_THREAT",
        }
    },
};

DTM_Effects["GREATER_BLESSING_OF_SALVATION"] = DTM_Effects["BLESSING_OF_SALVATION"];

-- --------------------------------------------------------------------
-- **                         Effects functions                      **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Effects_GetData(internalName)                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> internalName: internal name of the effect to get data about.  *
-- ********************************************************************
-- * Get data of an effect.                                           *
-- * Returns:                                                         *
-- *   - Class it belongs to (internal name)                          *
-- *   - Flag whether the effect is or not ALWAYS considered as active*
-- *   - .effect field of the effect (a table). (See above)           *
-- ********************************************************************

function DTM_Effects_GetData(internalName)
    local effectData = DTM_Effects[internalName];
    local classInternalName = "UNKNOWN";
    local effectEffectData = nil;
    local effectAlwaysActive = nil;

    if ( effectData ) then
        classInternalName = effectData.class or classInternalName;
        effectEffectData = effectData.effect;
        effectAlwaysActive = effectData.alwaysActive;
    end

    return classInternalName, effectAlwaysActive, effectEffectData;
end

-- ********************************************************************
-- * DTM_Effects_DoListing(class, effect, target, ability)            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> class: the class we are currently interested in...            *
-- * >> effect: the effect the effect must have to be listed.         *
-- * >> target: what the effect must affect to be listed.             *
-- * >> ability: the ability the effect must affect to be listed.     *
-- ********************************************************************

function DTM_Effects_DoListing(class, effect, target, ability)
    for k, v in ipairs(list) do
        list[k] = nil;
    end

    -- Lookup feature to increase performance time.
    local lookupKey = (class or "?")..":"..(effect or "?")..":"..(target or "?")..":"..(ability or "?");
    local lookupTable = lookupData[lookupKey];
    if ( lookupTable ) then
        list.number = lookupTable.number;
        local i;
        for i=1, list.number do
            list[i] = lookupTable[i];
        end
        return;
    end

    -- Lookup not found, we'll do it this call.
    lookupData[lookupKey] = {};

    local matchFound = 0;
    local matching;

    for internal, data in pairs(DTM_Effects) do
        local effectEffect = data.effect;

        matching = 1;

        if ( class ) then
            if ( data.class ~= class ) then
                matching = nil;
            end
        end

        if ( effect ) then
            if ( effectEffect.type ~= effect ) then
                matching = nil;
            end
        end

        if ( target ) then
            if ( effectEffect.target ~= target ) then
                matching = nil;
            end
        end

        local abilityData = effectEffect.abilities;
        if ( ability ) and ( abilityData ) then
            found = nil;
            for i=1, (abilityData.number or 0) do
                if abilityData[i] == ability then
                    found = 1;
                    break;
                end
            end
            if not found then
                matching = nil;
            end
        end
        if ( ability ) and not ( abilityData ) then matching = nil; end

        if ( matching ) then
            matchFound = matchFound + 1;
            list[matchFound] = internal;
            lookupData[lookupKey][matchFound] = internal;
        end
    end

    list.number = matchFound;
    lookupData[lookupKey].number = matchFound;
end

-- ********************************************************************
-- * DTM_Effects_GetListSize()                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Get the size of the list created with the effect research        *
-- * function DoListing.                                              *
-- ********************************************************************

function DTM_Effects_GetListSize()
    return list.number or 0;
end

-- ********************************************************************
-- * DTM_Effects_GetListData(index)                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> index: ...of the effect in the list to get.                   *
-- ********************************************************************
-- * Get effect data from the list.                                   *
-- * Returns:                                                         *
-- *   - Internal name of the effect.                                 *
-- *   - Class it belongs to (internal name)                          *
-- *   - Flag whether the effect is or not ALWAYS considered as active*
-- *   - .effect field of the effect (a table). (See above)           *
-- *                                                                  *
-- * Note that always active effects only operate on the class that   *
-- * has them. For instance, only paladins have a healing passive     *
-- * threat reduction.                                                *
-- ********************************************************************

function DTM_Effects_GetListData(index)
    local effectInternalName = list[index] or "UNKNOWN";
    local effectData = DTM_Effects[effectInternalName];
    local classInternalName = "UNKNOWN";
    local effectEffectData = nil;
    local effectAlwaysActive = nil;

    if ( effectData ) then
        classInternalName = effectData.class or classInternalName;
        effectEffectData = effectData.effect;
        effectAlwaysActive = effectData.alwaysActive;
    end

    return effectInternalName, classInternalName, effectAlwaysActive, effectEffectData;
end