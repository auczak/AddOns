local activeModule = "Combat parse (WotLK)";

-- This file contains overides for WotLK Beta DTM version.
-- It will not be run on live clients.

if ( not DTM_OnWotLK() ) then
    return;
end

-- --------------------------------------------------------------------
-- **                       Combat parse data                        **
-- --------------------------------------------------------------------

-- This module provides some combat parse functions.
-- Those are taken from my function library (CoolLib) combat parse API.

-- If an appropriate CoolLib version is run at the same as DTM,
-- DTM will use CoolLib combat parse service instead of this one,
-- to reduce overhead.

local useCoolLibParser = nil;

local registeredCallbacks = 0;
local callback = {};

local resultTable = {};
local extraTable = { [1] = {} , [2] = {} , [3] = {} , [4] = {} };
local gatherArgs = {};

local SCHOOL_MASK_NONE	        = 0x00;
local SCHOOL_MASK_PHYSICAL	= 0x01;
local SCHOOL_MASK_HOLY	        = 0x02;
local SCHOOL_MASK_FIRE	        = 0x04;
local SCHOOL_MASK_NATURE	= 0x08;
local SCHOOL_MASK_FROST	        = 0x10;
local SCHOOL_MASK_SHADOW	= 0x20;
local SCHOOL_MASK_ARCANE	= 0x40;

local schoolMasks = {
    ["PHYSICAL"] = SCHOOL_MASK_PHYSICAL,
    ["HOLY"] = SCHOOL_MASK_HOLY,
    ["FIRE"] = SCHOOL_MASK_FIRE,
    ["NATURE"] = SCHOOL_MASK_NATURE,
    ["FROST"] = SCHOOL_MASK_FROST,
    ["SHADOW"] = SCHOOL_MASK_SHADOW,
    ["ARCANE"] = SCHOOL_MASK_ARCANE,
};

local SPELL_POWER_MANA = 0;
local SPELL_POWER_RAGE = 1;
local SPELL_POWER_FOCUS = 2;
local SPELL_POWER_ENERGY = 3;
local SPELL_POWER_HAPPINESS = 4;
local SPELL_POWER_RUNES = 5;

local powerTypeTable = {
    [SPELL_POWER_MANA] = "MP",
    [SPELL_POWER_RAGE] = "RP",
    [SPELL_POWER_FOCUS] = "Focus",
    [SPELL_POWER_ENERGY] = "EP",
    [SPELL_POWER_HAPPINESS] = "Happiness",
    [SPELL_POWER_RUNES] = "Runes",
};

-- --------------------------------------------------------------------
-- **                        Combat parse API                        **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_RegisterCombatParseCallback(func)                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> func: the function to call whenever a combat event fires.     *
-- ********************************************************************
-- * Register a function to be run when a combat event occurs.        *
-- ********************************************************************
function DTM_RegisterCombatParseCallback(func)
    if ( type(func) ~= "function" ) then return; end

    if ( useCoolLibParser ) and ( combatparse ) and ( combatparse.registerfeedback ) then
        -- Redirect this function call to CoolLib callback register service.
        combatparse.registerfeedback(func);
        return;
    end

    registeredCallbacks = registeredCallbacks + 1;
    callback[ registeredCallbacks ] = func;
end

-- ********************************************************************
-- * DTM_CheckCoolLibCombatParseSupport()                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Check if we should request CoolLib's combat parse service        *
-- * instead of using ours, to reduce overhead. This API should       *
-- * only be called once, after DTM saved variables are loaded.       *
-- *                                                                  *
-- * WARNING - This function should be called BEFORE any call to      *
-- * DTM_RegisterCombatParseCallback is made !                        *
-- ********************************************************************
function DTM_CheckCoolLibCombatParseSupport()
    local requiredCoolLibVer = 2600;
    local coolLibOkay = nil;

    if ( CoolLib ) then
        if ( CoolLib.GetVersion ) then
            if ( CoolLib:GetVersion() >= requiredCoolLibVer ) then
                coolLibOkay = 1;
            end
        end
    end

    if ( coolLibOkay ) then
        useCoolLibParser = 1;
    end

    return coolLibOkay;
end

-- --------------------------------------------------------------------
-- **                      Combat parse functions                    **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_DoCombatParse(...)                                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> ...: the args of the combat event to parse.                   *
-- ********************************************************************
-- * Parses a combat event and returns an information table.
-- * This function has been lightened for DTM, and some events have been removed, as DTM doesn't need them.
-- * This function does not include XP gain, reputation gain, honor gain etc. messages.
-- *
-- * A table is returned, with the following properties (some may be non-applicable and thus nil) :
-- *
-- * 1/ .Timestamp = X                    Allows to determinate precisely when the combat event occured. Counts in seconds since Epoch. (1st January 1970)
-- *
-- * 2/ .Actor = {
-- *                 Name = "Foo",        The "pure" name of the actor. Nothing new about it since the previous system.
-- *                 GUID = Something,    The unique ID attributed to the actor.
-- *                 Flags = X,           Special flags allowing you to determinate affiliation of the unit and its relation with raid targets etc.
-- *             }
-- * 3/ .Target = {
-- *                  Name = "Bar",
-- *                  GUID = Something,
-- *                  Flags = X,
-- *              }
-- *
-- * 4/ .Outcome - of action
-- *
-- * See this table :
-- * 
-- * DAMAGE - One has been hurt by a physical attack, a magical attack, a spell, an environment damage etc. See other properties to get more details.
-- * LEECH - One has leeched another unit's powertype. See .PowerType, .Amount and .ExtraAmount properties to get more info.
-- * MISS - One's attack has missed. Refers to additionnal fields to determinate the type of "Miss".
-- * HEAL - One has been healed by a spell, a proc, an item etc. See other properties to get more details.
-- *
-- * EFFECT_GAIN - One has gained an effect. See other fields to check whether it is a "Buff" or "Debuff".
-- * EFFECT_GAIN_DOSE - One has gained some applications of an effect, which is now stacked X times. (refer to .Amount to get X)
-- * EFFECT_FADE - One's effect has disappareared.
-- * EFFECT_FADE_DOSE - One has lost some applications of an effect, which is now stacked X times. (refer to .Amount to get X)
-- * EFFECT_DISPEL - Called when an effect gets dispelled or was broken due to some game mechanic.
-- * EFFECT_STOLEN - Called when one's effect gets stolen.
-- *
-- * CAST_START - One's starting to cast a non-channeled spell.
-- * CAST_SUCCESS - One has finished to cast a non-damaging and non-healing ability.
-- *
-- * DEATH - One has died, you included.
-- * DESTRUCTION - Something was destroyed. This generally apparears for totems and similar objects. This event is here to reduce pollution in DEATH event.
-- *
-- * 5/ .Class - of action
-- *
-- * See this table :
-- *
-- * MELEE - The action was an auto-melee attack.
-- * RANGED - The action was an auto-shoot attack.
-- * WAND - The action was an auto-wand attack.
-- * ABILITY - The action was a special ability. This includes spells and rogues, warriors, hunters', druids', death knights combat techs.
-- * DAMAGESHIELD - The wound was triggered by a or several damageshield buff.
-- * ENVIRONMENT - The action was triggered by World itself. This includes fall damage, lava damage etc.
-- *
-- * Of course "Class" is nil for some outcomes.
-- *
-- * 6/ .Amount
-- * This property only apparears for DAMAGE, LEECH, HEAL and some other special cases. In other cases it is nil.
-- *
-- * 7/ .ExtraAmount
-- * This property only apparears for LEECH. It represents the amount recovered by the actor.
-- *
-- * 8/ .PowerType
-- * This property only apparears for DAMAGE, LEECH and HEAL. It can be "HP", "MP", "EP", "RP", "Runes", "Focus", "Happiness" or nil.
-- * This is what you use to determinate what kind of healing/damaging it was, as you can heal HP, recover MP, be hurt and lose HP or drain MP etc.
-- *
-- * 9/ .Special
-- * This property only apparears for DAMAGE, HEAL, MISS and EFFECT_* outcomes.
-- * For DAMAGE and HEAL: can be "CRITICAL", "CRUSHING", "GLANCING" or nil.
-- * For MISS: can be "MISS", "DODGE", "PARRY", "BLOCK", "DEFLECT", "REFLECT", "EVADE", "IMMUNE" or "ABSORB".
-- * For EFFECT_*: Can be "BUFF" or "DEBUFF".
-- *
-- * 10/ .Ability = {                      Table that apparears when an ability is involved, that is for RANGED, WAND, ABILITY, DAMAGESHIELD and DAMAGESPLIT classes.
-- *                    Id = 0,            The id of the spell. Useable for spell links and tooltip reading.
-- *                    Name = "Foo",      The "pure" name of the spell. This is the replacement of the .Name field of the previous system.
-- *                    School = 0,        Bit table indicating the school the spell belongs to.
-- *                }
-- *
-- * 11/ .Mean = {                        Table that apparears when a second ability is involved in DISPEL and STOLEN outcomes.
-- *                 Id = 0,
-- *                 Name = "Bar",
-- *                 School = 0,
-- *             }
-- *
-- * 12/ .Element
-- * This property only apparears for DAMAGE and HEAL. It is a bit table indicating the schools involved with the damage or the heal.
-- *
-- * 13/ .Periodic
-- * This property is set for periodic DAMAGE, LEECH, MISS and HEAL outcomes.
-- *
-- * 14/ .Overheal
-- * The amount of overheal. Only for HEAL outcomes.
-- ********************************************************************
function DTM_DoCombatParse(...)
    if ( useCoolLibParser ) then return nil; end -- Invalidate this function if CoolLib offers us its combat parse service.

    timestamp, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags = select(1, ...);

    local Result = resultTable;

    -- Tables cleanup
    local k, v, t;
    for k, v in pairs( Result ) do
        Result[k] = nil;
    end
    for t=1, 4 do
        for k, v in pairs( extraTable[t] ) do
            extraTable[t][k] = nil;
        end
    end

    Result.Timestamp = timestamp;
    extraTable[1].Name = srcName;
    extraTable[1].GUID = srcGUID;
    extraTable[1].Flags = srcFlags;
    Result.Actor = extraTable[1];

    extraTable[2].Name = dstName;
    extraTable[2].GUID = dstGUID;
    extraTable[2].Flags = dstFlags;
    Result.Target = extraTable[2];

    -- [environmentalDamageType]
    -- [spellName, spellRank, spellSchool]
    -- [damage, school, [resisted, blocked, absorbed, crit, glancing, crushing]]

    -- Spell standard order
    local spellId, spellName, spellSchool;
    local extraSpellId, extraSpellName, extraSpellSchool;

    -- Damage standard order
    local amount, school, resisted, blocked, absorbed, critical, glancing, crushing, overhealing;
    -- Miss argument order
    -- {MISS, ABSORB, BLOCK, DEFLECT, REFLECT, DODGE, EVADE, IMMUNE, PARRY, RESIST}
    local missType, amountMissed;
    -- Aura arguments
    local auraType; -- BUFF or DEBUFF

    -- Special Spell values
    local extraAmount; -- Used for Drains and Leeches
    local powerType; -- Used for energizes, drains and leeches

    -- Periodic flag
    local isPeriodic = nil;

    -- Swings
    if ( event == "SWING_DAMAGE" ) then 
    	-- Damage standard
        amount, school, resisted, blocked, absorbed, critical, glancing, crushing = select(9, ...);

        powerType = "HP";
        Result.Outcome = "DAMAGE";
        Result.Class = "MELEE";
        Result.Amount = amount;

    elseif ( event == "SWING_MISSED" ) then
        missType, amountMissed = select(9, ...);

        Result.Outcome = "MISS";
        Result.Special = missType;
        Result.Class = "MELEE";
        Result.Amount = amountMissed;
    end

    -- Shots
    if ( event == "RANGE_DAMAGE" ) then 
        -- Damage standard
        spellId, spellName, spellSchool = select(9, ...);
        amount, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, ...);

        powerType = "HP";
        Result.Outcome = "DAMAGE";
        Result.Class = "RANGED";
        Result.Amount = amount;

 elseif ( event == "RANGE_MISSED" ) then 
        -- Damage standard
        spellId, spellName, spellSchool = select(9, ...);
        missType, amountMissed = select(12, ...);

        Result.Outcome = "MISS";
        Result.Special = missType;
        Result.Class = "RANGED";
        Result.Amount = amountMissed;
    end

    -- Spells
    if ( strsub(event, 1, 6) == "SPELL_" ) then
        spellId, spellName, spellSchool = select(9, ...);

        if ( event == "SPELL_DAMAGE" or event == "SPELL_BUILDING_DAMAGE" ) then
            -- Damage standard
            amount, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, ...);

            powerType = "HP";
            Result.Outcome = "DAMAGE";
            Result.Class = "ABILITY";
            Result.Amount = amount;

    elseif ( event == "SPELL_MISSED" ) then 
            -- Miss type
            missType, amountMissed = select(12, ...);

            Result.Outcome = "MISS";
            Result.Special = missType;
            Result.Class = "ABILITY";
            Result.Amount = amountMissed;

    elseif ( event == "SPELL_HEAL" or event == "SPELL_BUILDING_HEAL" ) then 
            -- Did the heal crit?
            amount, overhealing, critical = select(12, ...);
            school = spellSchool;

            powerType = "HP";
            Result.Outcome = "HEAL";
            Result.Class = "ABILITY";
            Result.Amount = amount;

    elseif ( event == "SPELL_ENERGIZE" ) then 
            -- Gain of MP, EP etc.
            amount, powerType = select(12, ...);
            school = spellSchool;

            Result.Outcome = "HEAL";
            Result.Class = "ABILITY";
            Result.Amount = amount;

    elseif ( strsub(event, 1, 14) == "SPELL_PERIODIC" ) then
            isPeriodic = true;

            if ( event == "SPELL_PERIODIC_MISSED" ) then
                -- Miss type
                missType, amountMissed = select(12, ...);

                Result.Outcome = "MISS";
                Result.Special = missType;
                Result.Class = "ABILITY";
                Result.Amount = amountMissed;

        elseif ( event == "SPELL_PERIODIC_DAMAGE" ) then
                -- Damage standard
                amount, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, ...);

                powerType = "HP";
                Result.Outcome = "DAMAGE";
                Result.Class = "ABILITY";
                Result.Amount = amount;

        elseif ( event == "SPELL_PERIODIC_HEAL" ) then
                -- Did the heal crit?
                amount, overhealing, critical = select(12, ...);
                school = spellSchool;

                powerType = "HP";
                Result.Outcome = "HEAL";
                Result.Class = "ABILITY";
                Result.Amount = amount;

	elseif ( event == "SPELL_PERIODIC_DRAIN" ) then
		-- Special attacks
		amount, powerType, extraAmount = select(12, ...);

                Result.Outcome = "DAMAGE";
                Result.Class = "ABILITY";
                Result.Amount = amount;
                Result.ExtraAmount = extraAmount;

	elseif ( event == "SPELL_PERIODIC_LEECH" ) then
		-- Special attacks
		amount, powerType, extraAmount = select(12, ...);

                Result.Outcome = "LEECH";
                Result.Class = "ABILITY";
                Result.Amount = amount;
                Result.ExtraAmount = extraAmount;

	elseif ( event == "SPELL_PERIODIC_ENERGIZE" ) then 
		-- Did the heal crit?
		amount, powerType = select(12, ...);

                Result.Outcome = "HEAL";
                Result.Class = "ABILITY";
                Result.Amount = amount;
	    end

    elseif ( event == "SPELL_DRAIN" ) then
            -- Special attacks
            amount, powerType, extraAmount = select(12, ...);

            Result.Outcome = "DAMAGE";
            Result.Class = "ABILITY";
            Result.Amount = amount;
            Result.ExtraAmount = extraAmount;

    elseif ( event == "SPELL_LEECH" ) then
            -- Special attacks
            amount, powerType, extraAmount = select(12, ...);

            Result.Outcome = "LEECH";
            Result.Class = "ABILITY";
            Result.Amount = amount;
            Result.ExtraAmount = extraAmount;

    elseif ( event == "SPELL_AURA_DISPELLED" ) then
            -- Do swap.
            spellId, spellName, spellSchool, auraType = select(12, ...);
            extraSpellId, extraSpellName, extraSpellSchool = select(9, ...);

            Result.Outcome = "EFFECT_DISPEL";
            Result.Class = "ABILITY";

    elseif ( event == "SPELL_AURA_STOLEN" ) then
            -- Do swap.
            spellId, spellName, spellSchool, auraType = select(12, ...);
            extraSpellId, extraSpellName, extraSpellSchool = select(9, ...);

            Result.Outcome = "EFFECT_STOLEN";
            Result.Class = "ABILITY";

    elseif ( event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED" ) then
            -- Aura standard
            auraType = select(12, ...);

            if ( event == "SPELL_AURA_REMOVED" ) then
                Result.Outcome = "EFFECT_FADE";
          else
                Result.Outcome = "EFFECT_GAIN";
            end

            Result.Actor = Result.Target;

    elseif ( event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" ) then
            -- Aura standard
            auraType, amount = select(12, ...);

            if ( event == "SPELL_AURA_REMOVED_DOSE" ) then
                Result.Outcome = "EFFECT_FADE_DOSE";
          else
                Result.Outcome = "EFFECT_GAIN_DOSE";
            end

            Result.Amount = amount;
            Result.Actor = Result.Target;

    elseif ( event == "SPELL_CAST_START" ) then
            Result.Outcome = "CAST_START";
            Result.Class = "ABILITY";

    elseif ( event == "SPELL_CAST_SUCCESS" ) then
            Result.Outcome = "CAST_SUCCESS";
            Result.Class = "ABILITY";
        end
    end

    -- Damage Shields
    if ( event == "DAMAGE_SHIELD" ) then
        -- Spell standard
        spellId, spellName, spellSchool = select(9, ...);

        -- Damage standard
        amount, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, ...);

        powerType = "HP";
        Result.Outcome = "DAMAGE";
        Result.Class = "DAMAGESHIELD";
        Result.Amount = amount;

 elseif ( event == "DAMAGE_SHIELD_MISSED" ) then 
        -- Spell standard
        spellId, spellName, spellSchool = select(9, ...);

        -- Miss type
        missType, amountMissed = select(12, ...);

        Result.Outcome = "MISS";
        Result.Special = missType;
        Result.Class = "DAMAGESHIELD";
        Result.Amount = amountMissed;
    end

    -- Unique events
   if ( event == "UNIT_DIED" or event == "UNIT_DESTROYED" ) then
        Result.Actor = Result.Target;

        if ( event == "UNIT_DIED" ) then
            Result.Outcome = "DEATH";
      else
            Result.Outcome = "DESTRUCTION";
        end

elseif ( event == "ENVIRONMENTAL_DAMAGE" ) then
	-- Damage standard
        amount, school, resisted, blocked, absorbed, critical, glancing, crushing = select(10, ...);

        powerType = "HP";
        Result.Outcome = "DAMAGE";
        Result.Class = "ENVIRONMENT";
        Result.Amount = amount;

        Result.Actor = Result.Target;
    end

    if not ( Result.Outcome ) then
        return nil;
    end

    -- Handling of PowerTypes:
    if ( powerType ) then
        Result.PowerType = powerTypeTable[powerType] or powerType;
    end

    -- Handling of Special flag:
    if ( critical ) then
        Result.Special = "CRITICAL";
elseif ( crushing ) then
        Result.Special = "CRUSHING";
elseif ( glancing ) then
        Result.Special = "GLANCING";
    end

    -- Handling of damage Element:
    if ( school ) then
        -- The bit table is kept as-it.
        Result.Element = school;
    end

    -- Periodic flag
    Result.Periodic = isPeriodic;

    -- Handling of Ability:
    if ( spellId ) and ( spellName ) then
        extraTable[3].Id = spellId;
        extraTable[3].Name = spellName;
        extraTable[3].School = spellSchool;
        Result.Ability = extraTable[3];
    end

    -- Handling of Mean:
    if ( extraSpellId ) and ( extraSpellName ) then
        extraTable[4].Id = extraSpellId;
        extraTable[4].Name = extraSpellName;
        extraTable[4].School = extraSpellSchool;
        Result.Mean = extraTable[4];
    end

    -- Handling of auraType:
    if ( auraType ) then
        Result.Special = auraType;
    end

    -- Handling of overhealing:
    if ( overhealing ) then
        Result.Overheal = overhealing;
    end

    return Result;
end

-- ********************************************************************
-- * DTM_HasElement(schoolBitTable, element)                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> schoolBitTable: the school bit table to examine.              *
-- * >> element: the element name, in capitalized English.            *
-- ********************************************************************
-- * Checks if an element is set in the given school bit table.       *
-- * Element can be "HOLY", "ARCANE", "FIRE", "NATURE", "FROST",      *
-- * "SHADOW" or "PHYSICAL".                                          *
-- ********************************************************************
function DTM_HasElement(schoolBitTable, element)
    if not ( schoolBitTable ) then return nil; end
    local bitMask = schoolMasks[element] or nil;
    if not ( bitMask ) then
        return nil;
  else
        return ( bit.band(schoolBitTable, bitMask) ) > 0;
    end
end

-- --------------------------------------------------------------------
-- **                      Combat parse handlers                     **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_OnCombatEvent()                                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Fires whenever a combat event is received.                       *
-- ********************************************************************
function DTM_OnCombatEvent()
    if ( useCoolLibParser ) then return nil; end -- Invalidate this function if CoolLib offers us its combat parse service.

    local Result = DTM_DoCombatParse(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19);
    if not ( Result ) then
        return nil;
    end

    local i, f;
    for i=1, registeredCallbacks, 1 do
        f = callback[i];
        if ( f ) then f( Result ); end
    end
end