local activeModule = "Engine yells and alerts";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                           Functions                            **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_CreatureMessage_ApplyEffect(npcName, effect, ability, text)  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> npcName: the locale NPC name who fired the effect.            *
-- * >> effect: the effect field of the "ability" (kinda) triggered.  *
-- * >> ability: the internal name of the NPC ability.                *
-- * >> text: the thing the NPC said/emoted.                          *
-- ********************************************************************
-- * Applies an "ability" effect triggered by a yell/emote from a NPC.*
-- * (It's considered as an ability by the engine, although it's not  *
-- * technically one.)                                                *
-- ********************************************************************
function DTM_CreatureMessage_ApplyEffect(npcName, effect, ability, text)
    if not ( npcName ) then return; end
    if not ( effect ) then return; end
    -- Ability can be omitted, but it's preferable and more clean for feedback feature to provide it.
    -- Text is not necessary in 90% of cases.

    -- OK, first goal is to find the GUID of the NPC.
    -- This shouldn't be the case in most "reasonable" situations, but it is possible
    -- that if there are multiple instances of the same NPC a bad GUID is to be returned.
    -- Though indeed, most (if not all) boss NPCs only exist in 1 instance at a time :)

    local npcGUID = DTM_FindGUIDFromName(npcName);
    if not ( npcGUID ) then return; end -- Well there's no current threat data for the NPC. We have nothing to work with.

    local triggerDelay = effect.triggerDelay or 0;

    -- Prepare the equivalent combat event (yes, some more memory garbage hmmmmmm... But it's not called often =P).

    local eventData = {
        amount = nil,
        amountType = "NONE",
        amountTiming = "INSTANT",
        powerType = nil,
        special = nil,
        effect = effect,
        rank = nil,
        sourceName = npcName,
        sourceGUID = npcGUID,
        sourceFlags = COMBATLOG_OBJECT_TYPE_NPC,
        targetName = nil,
        targetGUID = nil,
        ability = ability or "UNKNOWN_NPC_ABILITY",

        delay = triggerDelay,
    };

    -- If the ability has a delay, we will make the combat event fire after <triggerDelay> sec. Elsewise, fire the combat event at once.
    if ( triggerDelay > 0 ) then
        DTM_Trace("BOSS", "[%s] boss delayed '%s' ability: %d ms.", 1, npcName, ability or "<?>", floor(triggerDelay*1000));
        DTM_CombatEvents_Add(eventData);
  else
        DTM_CombatEvents_Apply(eventData);
    end
end

-- --------------------------------------------------------------------
-- **                            Handlers                            **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_OnCreatureMessageDoReplace(text, npcName)                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> text: the thing the NPC said/emoted.                          *
-- * >> npcName: the locale NPC name who/which yells/emotes something.*
-- ********************************************************************
-- * Replaces the first '%s' tag with the NPC name before sending     *
-- * the yell/emote to OnCreatureMessage function.                    *
-- * This preprocessing is needed for standard NPC emotes.            *
-- ********************************************************************
function DTM_OnCreatureMessageDoReplace(text, npcName)
    if not ( text ) then text = arg1; end
    if not ( npcName ) then npcName = arg2; end

    DTM_OnCreatureMessage(format(text, npcName), npcName);
end

-- ********************************************************************
-- * DTM_OnCreatureMessage(text, npcName)                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> text: the thing the NPC said/emoted.                          *
-- * >> npcName: the locale NPC name who/which yells/emotes something.*
-- ********************************************************************
-- * Gets called when a NPC yells/warns something.                    *
-- ********************************************************************
function DTM_OnCreatureMessage(text, npcName)
    if not ( DTM_IsEngineRunning() == 1 ) then
        return;
    end

    if not ( text ) then text = arg1; end
    if not ( npcName ) then npcName = arg2; end

    -- DTM_Trace("BOSS", "We have received from [%s] the emote/yell: '%s'", 1, npcName, text);

    local npcData = DTM_GetNPCAbilityData(npcName);
    if ( npcData ) then
        local name, num, effects = DTM_GetNPCYellEffect(npcData, text);

        if ( num > 0 ) then
            DTM_Trace("BOSS", "[%s] boss fired '%s' ability with an emote or a yell.", 1, npcName, name or "<?>");

            if ( num == 1 ) then
                -- One effect only. "effects" points directly to the single effect.
                DTM_CreatureMessage_ApplyEffect(npcName, effects, name, text);
          else
                -- Multiple effects.
                local e;
                for e=1, num do
                    DTM_CreatureMessage_ApplyEffect(npcName, effects[e], name, text);
                end
            end
        end
    end
end
