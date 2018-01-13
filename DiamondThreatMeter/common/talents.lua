local activeModule = "Talents";

-- --------------------------------------------------------------------
-- **                         Talents table                          **
-- --------------------------------------------------------------------

local list = {
    number = 0,
};

local lookupData = {};

--[[
*** Type list:
MULTIPLY_THREAT - The threat is multiplied by a coefficient. Coefficient can vary between ranks.
ADDITIVE_THREAT - A fixed value is added to threat, which can vary between ranks.

*** Target list:
GLOBAL_THREAT - The talent modifies the global threat multiplier of incoming threatening actions.
STANCE_THREAT - The talent modifies the stance threat multiplier of incoming threatening actions performed in the given stance.
ABILITIES - The talent modifies the threat multiplier of some specific abilities.
EFFECTS - The talent modifies the threat multiplier of some specific effects.

*** Stance list:
NORMAL - (Druid) Caster form
AQUATIC - (Druid) Aquatic form
TRAVEL - (Druid) Travel form
BEAR - (Druid) Bear form, Dire bear form
CAT - (Druid) Cat form
MOONKIN - (Druid) Moonkin form
TREE - (Druid) Tree of life form
FLIGHT - (Druid) [Swift] Flight form
COMBAT - (Warrior) Combat stance
DEFENSIVE - (Warrior) Defensive stance
BERSERKER - (Warrior) Berserker stance

*** Conditions:
EFFECT:X - The talent operates only when the owner has the given effect active.
NOEFFECT:X - The talent operates only when the owner DOESN'T have the given effect active.
STANCE:X - The talent operates only when the owner is in the given stance.
NOSTANCE:X - The talent operates only when the owner ISN'T in the given stance.
PET:X - The talent operates only when the given owner's pet is out.
NOPET:X - The talent operates only when the given owner's pet ISN'T out.
]]

-- /!\ Use only internals name in these table, for all fields. /!\
-- See localisation.lua for more details and values.

local DTM_Talents = {
    -- Druid talents

    -- WotLK TODO: Remove this talent.
    ["FERAL_INSTINCT"] = {
        class = "DRUID",
        effect = {
            type = "ADDITIVE_THREAT",
            value = {
                [1] = 0.05,
                [2] = 0.10,
                [3] = 0.15,
            },
            target = "STANCE_THREAT",
            stance = "BEAR",
        }
    },
    ["SUBTLETY"] = {
        class = "DRUID",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.96,
                [2] = 0.92,
                [3] = 0.88,
                [4] = 0.84,
                [5] = 0.80,
            },
            target = "ABILITIES",
            abilities = {                       -- WotLK TODO: Remove Balance spells.
                number = 13,
                [1] = "HEALING_TOUCH",
                [2] = "REJUVENATION",
                [3] = "REGROWTH",
                [4] = "LIFEBLOOM",
                [5] = "WRATH",
                [6] = "STARFIRE",
                [7] = "MOONFIRE",
                [8] = "INSECT_SWARM",
                [9] = "HURRICANE",
                [10] = "TRANQUILITY",
                [11] = "ENTANGLING_ROOTS",
                [12] = "CYCLONE",
                [13] = "HIBERNATE",
            },
        }
    },
    ["IMPROVED_TRANQUILITY"] = {
        class = "DRUID",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.50, -- 0.50,          -- Uncomment for WotLK
                [2] = 0.00, -- 0.00,          -- Uncomment for WotLK
            },
            target = "ABILITIES",
            abilities = {
                number = 1,
                [1] = "TRANQUILITY",
            }
        }
    },

    -- WotLK TODO: Uncomment this. x]
    --[[
    ["NATURE_REACH"] = {
        class = "DRUID",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.85,
                [2] = 0.70,
            },
            target = "ABILITIES",
            abilities = {
                number = 10,
                [1] = "WRATH",
                [2] = "STARFIRE",
                [3] = "MOONFIRE",
                [4] = "INSECT_SWARM",
                [5] = "HURRICANE",
                [6] = "STARFALL",
                [7] = "TYPHOON",
                [8] = "ENTANGLING_ROOTS",
                [9] = "CYCLONE",
                [10] = "HIBERNATE",
            }
        }
    },
    ]]

    -- Hunter talents
    -- <None>

    -- Mage talents

    ["ARCANE_SUBTLETY"] = {
        class = "MAGE",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.80,
                [2] = 0.60,
            },
            target = "ABILITIES",
            abilities = {
                number = 5, -- 6,          -- Uncomment for WotLK
                [1] = "ARCANE_EXPLOSION",
                [2] = "ARCANE_MISSILES",
                [3] = "ARCANE_BLAST",
                [4] = "COUNTERSPELL",
                [5] = "POLYMORPH",
                -- [6] = "ARCANE_BARRAGE", -- Uncomment for WotLK
            },
        }
    },
    ["BURNING_SOUL"] = {
        class = "MAGE",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.95,
                [2] = 0.90,
            },
            target = "ABILITIES",
            abilities = {
                number = 9,
                [1] = "FIREBALL",
                [2] = "FIRE_BLAST",
                [3] = "FLAMESTRIKE",
                [4] = "PYROBLAST",
                [5] = "SCORCH",
                [6] = "BLAST_WAVE",
                [7] = "DRAGON_BREATH",
                [8] = "MOLTEN_ARMOR",
                [9] = "IGNITE",
            },
        }
    },
    ["FROST_CHANNELING"] = {
        class = "MAGE",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.96,
                [2] = 0.93,
                [3] = 0.90,
            },
            target = "ABILITIES",
            abilities = {
                number = 5,
                [1] = "FROSTBOLT",
                [2] = "FROST_NOVA",
                [3] = "CONE_OF_COLD",
                [4] = "BLIZZARD",
                [5] = "ICE_LANCE",
            },
        }
    },

    -- Paladin talents

    -- WotLK TODO: Remove this, and apply the threat coeff bonus to the base effect.
    ["IMPROVED_RIGHTEOUS_FURY"] = {
        class = "PALADIN",
        effect = {
            type = "ADDITIVE_THREAT",
            value = {
                [1] = 0.096,
                [2] = 0.198,
                [3] = 0.300,
            },
            target = "EFFECTS",
            effects = {
                number = 1,
                [1] = "RIGHTEOUS_FURY",
            }
        }
    },
    ["FANATICISM"] = {
        class = "PALADIN",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.94,
                [2] = 0.88,
                [3] = 0.82,
                [4] = 0.76,
                [5] = 0.70,
            },
            target = "GLOBAL_THREAT",
            condition = "NOEFFECT:RIGHTEOUS_FURY",
        }
    },

    -- Priest talents

    ["SILENT_RESOLVE"] = {
        class = "PRIEST",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.96,
                [2] = 0.92,
                [3] = 0.88,  -- WotLK: 3 pts instead of 5.
                [4] = 0.84,
                [5] = 0.80,
            },
            target = "ABILITIES",
            abilities = {
                number = 17,
                [1] = "LESSER_HEAL",
                [2] = "SMITE",
                [3] = "RENEW",
                [4] = "HEAL",
                [5] = "FLASH_HEAL",
                [6] = "HOLY_FIRE",
                [7] = "MANA_BURN",
                [8] = "MIND_CONTROL",
                [9] = "PRAYER_OF_HEALING",
                [10] = "GREATER_HEAL",
                [11] = "BINDING_HEAL",
                [12] = "PRAYER_OF_MENDING",
                [13] = "DESPERATE_PRAYER",
                [14] = "STARSHARDS",
                [15] = "CHASTISE",
                [16] = "CIRCLE_OF_HEALING",
                [17] = "POWER_WORD_SHIELD",
            }
        }
    },
    ["SHADOW_AFFINITY"] = {
        class = "PRIEST",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.92,
                [2] = 0.84,
                [3] = 0.75,
            },
            target = "ABILITIES",
            abilities = {
                number = 7,
                [1] = "MIND_FLAY",
                [2] = "MIND_BLAST",
                [3] = "VAMPIRIC_TOUCH",
                [4] = "VAMPIRIC_EMBRACE",
                [5] = "SHADOW_WORD_PAIN",
                [6] = "SHADOW_WORD_DEATH",
                [7] = "DEVOURING_PLAGUE",
            }
        }
    },

    -- Rogue talents

    ["SLEIGHT_OF_HAND"] = {
        class = "ROGUE",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 1.10,
                [2] = 1.20,
            },
            target = "ABILITIES",
            abilities = {
                number = 1,
                [1] = "FEINT",
            }
        }
    },

    -- Shaman talents

    ["ELEMENTAL_PRECISION"] = {
        class = "SHAMAN",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.96, -- WotLK: 0.90
                [2] = 0.93, -- WotLK: 0.80
                [3] = 0.90, -- WotLK: 0.70
            },
            target = "ABILITIES",
            abilities = {
                number = 6,
                [1] = "LIGHTNING_BOLT",
                [2] = "CHAIN_LIGHTNING",
                [3] = "EARTH_SHOCK",
                [4] = "FROST_SHOCK",
                [5] = "FLAME_SHOCK",
                [6] = "LIGHTNING_SHIELD",
            }
        }
    },
    ["SPIRIT_WEAPONS"] = {
        class = "SHAMAN",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.70,
            },
            target = "ABILITIES",
            abilities = {
                number = 4,
                [1] = "AUTOATTACK",
                [2] = "WINDFURY",
                [3] = "STORMSTRIKE",
                [4] = "WINDFURY_WEAPON",
            }
        }
    },
    ["HEALING_GRACE"] = {
        class = "SHAMAN",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.90,
                [2] = 0.80,
                [3] = 0.70,
            },
            target = "ABILITIES",
            abilities = {
                number = 4,
                [1] = "HEALING_WAVE",
                [2] = "LESSER_HEALING_WAVE",
                [3] = "CHAIN_HEAL",
                [4] = "EARTH_SHIELD",
            }
        }
    },
    ["LIGHTNING_OVERLOAD"] = { -- It's not the real way it works, but it's a *statistical equivalence for a very high amount of spellcasts*.
        class = "SHAMAN",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 1/1.02,
                [2] = 1/1.04,
                [3] = 1/1.06,
                [4] = 1/1.08,
                [5] = 1/1.10,
            },
            target = "ABILITIES",
            abilities = {
                number = 2,
                [1] = "LIGHTNING_BOLT",
                [2] = "CHAIN_LIGHTNING",
            }
        }
    },

    -- Warlock talents

    ["IMPROVED_DRAIN_SOUL"] = {
        class = "WARLOCK",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.95,
                [2] = 0.90,
            },
            target = "ABILITIES",
            abilities = {
                number = 17,
                [1] = "CORRUPTION",
                [2] = "CURSE_OF_AGONY",
                [3] = "DRAIN_SOUL",
                [4] = "DRAIN_LIFE",
                [5] = "DRAIN_MANA",
                [6] = "DEATH_COIL",
                [7] = "CURSE_OF_DOOM",
                [8] = "SEED_OF_CORRUPTION",
                [9] = "SIPHON_LIFE",
                [10] = "UNSTABLE_AFFLICTION",
                [11] = "CURSE_OF_SHADOW",
                [12] = "CURSE_OF_ELEMENTS",
                [13] = "CURSE_OF_WEAKNESS",
                [14] = "CURSE_OF_RECKLESSNESS",
                [15] = "CURSE_OF_TONGUES",
                [16] = "FEAR",
                [17] = "HOWL_OF_TERROR",
            }
        }
    },
    ["DESTRUCTIVE_REACH"] = {
        class = "WARLOCK",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.95,
                [2] = 0.90,
            },
            target = "ABILITIES",
            abilities = {
                number = 10,
                [1] = "SHADOW_BOLT",
                [2] = "IMMOLATE",
                [3] = "SEARING_PAIN",
                [4] = "RAIN_OF_FIRE",
                [5] = "HELLFIRE",
                [6] = "SOUL_FIRE",
                [7] = "INCINERATE",
                [8] = "SHADOWBURN",
                [9] = "CONFLAGRATE",
                [10] = "SHADOWFURY",
            }
        }
    },

    -- WotLK TODO: Remove this
    -- <Remove>
    ["MASTER_DEMONOLOGIST"] = {
        class = "WARLOCK",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.96,
                [2] = 0.92,
                [3] = 0.88,
                [4] = 0.84,
                [5] = 0.80,
            },
            target = "GLOBAL_THREAT",
            condition = "PET:IMP",
        }
    },
    -- </Remove>

    -- Warrior talents

    -- WotLK TODO: Remove this, do x1.15 to defensive stance modifier itself.
    -- <Remove>
    ["DEFIANCE"] = {
        class = "WARRIOR",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 1.05,
                [2] = 1.10,
                [3] = 1.15,
            },
            target = "STANCE_THREAT",
            stance = "DEFENSIVE",
        }
    },
    -- </Remove>

    ["IMPROVED_BERSERKER_STANCE"] = {
        class = "WARRIOR",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.98,
                [2] = 0.96,
                [3] = 0.94,
                [4] = 0.92,
                [5] = 0.90,
            },
            target = "STANCE_THREAT",
            stance = "BERSERKER",
        }
    },
    ["TACTICAL_MASTERY"] = {
        class = "WARRIOR",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 1.05,
                [2] = 1.10,     -- I do not recall if those are confirmed or guestimates.
                [3] = 1.15,
            },
            target = "ABILITIES",
            abilities = {
                number = 2,
                [1] = "MORTAL_STRIKE",
                [2] = "BLOODTHIRST",
            },
            condition = "STANCE:DEFENSIVE",
        }
    },

    -- WotLK TODO: Uncomment this. x]
    --[[
    ["FURIOUS_RESOLVE"] = {
        class = "WARRIOR",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 0.96,
                [2] = 0.93,
                [3] = 0.90,
            },
            target = "GLOBAL_THREAT", -- False, only threat caused by attacks.
            condition = "NOSTANCE:DEFENSIVE",
        }
    },
    ]]

    -- Pets-affecting talents

    ["IMPROVED_SUCCUBUS"] = {
        class = "WARLOCK",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 1.10,
                [2] = 1.20,
                [3] = 1.30,
            },
            target = "ABILITIES",
            abilities = {
                number = 1,
                [1] = "PET_SOOTHING_KISS",
            },
        }
    },
    ["IMPROVED_VOIDWALKER"] = {
        class = "WARLOCK",
        effect = {
            type = "MULTIPLY_THREAT",
            value = {
                [1] = 1.10,
                [2] = 1.20,
                [3] = 1.30,
            },
            target = "ABILITIES",
            abilities = {
                number = 2,
                [1] = "PET_TORMENT",
                [2] = "PET_SUFFERING",
            },
        }
    },    
};

-- --------------------------------------------------------------------
-- **                         Talents functions                      **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Talents_GetData(internalName)                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> internalName: internal name of the talent to get data about.  *
-- ********************************************************************
-- * Get data of a talent.                                            *
-- * Returns:                                                         *
-- *   - Class it belongs to (internal name)                          *
-- *   - .effect field of the talent (a table). (See above)           *
-- ********************************************************************

function DTM_Talents_GetData(internalName)
    local talentData = DTM_Talents[internalName];

    if ( talentData ) then
        return talentData.class or "UNKNOWN", talentData.effect or nil;
    end

    return "UNKOWN", nil;
end

-- ********************************************************************
-- * DTM_Talents_DoListing(class, stance, effect, target, ability,    *
-- *                       effectAffected)
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> class: the class we are currently interested in...            *
-- * >> stance: the stance the talent must affect to be listed.       *
-- * >> effect: the effect the talent must have to be listed.         *
-- * >> target: what the talent must affect to be listed.             *
-- * >> ability: the ability the talent must affect to be listed.     *
-- * >> effectAffected: the effect the talent must alter to be listed.*
-- *                                                                  *
-- * /!\ Effect is a magic word, while effectAffected is a buff or    *
-- * debuff internal name, beware the confusion !                     *
-- ********************************************************************

function DTM_Talents_DoListing(class, stance, effect, target, ability, effectAffected)
    for k, v in ipairs(list) do
        list[k] = nil;
    end

    -- Lookup feature to increase performance time.
    local lookupKey = (class or "?")..":"..(stance or "?")..":"..(effect or "?")..":"..(target or "?")..":"..(ability or "?")..":"..(effectAffected or "?");
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

    for internal, data in pairs(DTM_Talents) do
        local talentEffect = data.effect;

        matching = 1;

        if ( class ) then
            if ( data.class ~= class ) then
                matching = nil;
            end
        end

        if ( stance ) then
            if ( talentEffect.stance ~= stance ) then
                matching = nil;
            end
        end

        if ( effect ) then
            if ( talentEffect.type ~= effect ) then
                matching = nil;
            end
        end

        if ( target ) then
            if ( talentEffect.target ~= target ) then
                matching = nil;
            end
        end

        local abilityData = talentEffect.abilities;
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

        local effectData = talentEffect.effects;
        if ( effectAffected ) and ( effectData ) then
            found = nil;
            for i=1, (effectData.number or 0) do
                if effectData[i] == effectAffected then
                    found = 1;
                    break;
                end
            end
            if not found then
                matching = nil;
            end
        end
        if ( effectAffected ) and not ( effectData ) then matching = nil; end

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
-- * DTM_Talents_GetListSize()                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Get the size of the list created with the talent research        *
-- * function DoListing.                                              *
-- ********************************************************************

function DTM_Talents_GetListSize()
    return list.number or 0;
end

-- ********************************************************************
-- * DTM_Talents_GetListData(index)                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> index: ...of the talent in the list to get.                   *
-- ********************************************************************
-- * Get talent data from the list.                                   *
-- * Returns:                                                         *
-- *   - Internal name of the talent.                                 *
-- *   - Class it belongs to (internal name)                          *
-- *   - .effect field of the talent (a table). (See above)           *
-- ********************************************************************

function DTM_Talents_GetListData(index)
    local talentInternalName = list[index] or "UNKNOWN";
    local talentData = DTM_Talents[talentInternalName];
    local classInternalName = "UNKNOWN";
    local talentEffectData = nil;

    if ( talentData ) then
        classInternalName = talentData.class or classInternalName;
        talentEffectData = talentData.effect;
    end

    return talentInternalName, classInternalName, talentEffectData;
end





