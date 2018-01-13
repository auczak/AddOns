local activeModule = "NPC abilities";

-- --------------------------------------------------------------------
-- **                        NPC abilities data                      **
-- --------------------------------------------------------------------

local USER_DEFINED_VERSION = 1.059; -- The version that will have all NPCs registered by the user.

local patterns = {};
local lookupData = {};

local DTM_DefaultNPCAbilities = {
    -- Some built-in data for popular bosses. Missing data in NPCAbilities table will be copied each time DTM starts up.

    -- Adding NPC abilities work the same way as adding normal abilities, but there are some changes and special rules between the two :

    -- 1/ .detection field should ALWAYS be *omitted* or set as "UNIVERSAL" for _ALL_ NPC abilities.

    -- 2/ You can set some additionnal special fields that allow you to describe general behavior of the NPC, in the NPC table.
    -- The best way to understand this mechanism is to observe exemples provided below. :)
    -- - You can set the .noThreatList field to inform the GUI the NPC has no threat list at all.
    -- - .warningOveride field can be set to specificaly configure the bossWarning flag for this NPC, regardless of user's setting.
    -- - .aggroDelay field can be set to notify DTM engine it has to wait a bit longer/shorter before assuming this NPC has changed its aggro.
    -- - .aggroDistance field can be set to specify at which distance you CAN pull aggro from the NPC. The default setting used when this field is not provided is
    -- "ANY", but you can set it to "MELEE", "RANGED" or "NONE" (none means you can't pull aggro, melee means you have to be in melee range, ranged means the opposite).

    -- 3/ NPC abilities can be triggered by yelling/emoting a fixed sentence, instead of doing a combat action.
    -- To specify an ability is a yell/emote, and not a standard combat event, set .isYell field in the table of the ability.
    -- Then put the content of the yell/emote in the language fields (i.e <.enUS>, <.frFR> etc.)
    -- If the NPC can yell/emote different sentences that trigger the same effect, you can separate each sentence with a "|" (pipe) caracter and compact
    -- everything in a single ability (See below for concrete exemples).
    -- Partial matches are allowed. Note also that for DTM, an emote is the same thing as a yell.

    -- 4/ For NPC abilities *that get triggered by a yell/emote _ONLY_*, you can set multiple effects tied to this ability.
    -- Instead of providing an "effect" subtable in ability table, provide an "effects" subtable (notice the "s").
    -- See exemples below such as Solarian one to grasp the concept.    

    -- 5/ Provide a version field in each NPC table. If you don't, DTM will assume the NPC table is version 1.00.
    -- Upon each startup, DTM will update each NPC stored in NPCAbilities table with the ones stored in DefaultNPCAbilities table, provided
    -- what's stored in DefaultNPCAbilities is more up to date.

    -- 6/ You can set the .invalidateFlatThreat field to ignore the flat-threat-generated portion of the ability.
    -- This field is essential for any ability that uses the target of the ability as the owner, such as knockbacks.

    -- 7/ The last but not the least, you can provide for NPC abilities *that get triggered by a yell/emote _ONLY_*
    -- a .triggerDelay field that will trigger the effect only after X secondes elapsed since the time ability got triggered.

    -- And the final note: avoid defining abilities that get triggered by a yell/emote for *non-boss* NPCs; if you fight 2 NPCs of same name and
    -- you define a yell/emote ability for them, if one of them triggers it, DTM will have a 50% chance of performing the ability effect on the wrong NPC.

    ["DOOMWALKER"] = {        -- Wipes all threat upon yelling 2 possibles messages.
        enUS = "Doomwalker",
        frFR = "Marche-funeste",
        deDE = "Verdammniswandler",
        number = 1,
        [1] = {
            name = "RESET_THREAT",
            enUS = "Trajectory locked|Engage maximum speed",    -- 2 possible yells
            frFR = "Trajectoire verrouillée|Vitesse maximale enclenchée",
            deDE = "Maximalgeschwindigkeit|festgelegt",
            isYell = 1,
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.00,
                target = "THREAT_LEVEL",
                owner = "ACTOR_LIST",
                relative = "ACTOR",
            },
        },
        version = 1.05,
    },

    -- The Mechanar

    ["SEPETHREA"] = {       -- Has an ability which reduces threat of its target.
        enUS = "Nethermancer Sepethrea",
        frFR = "Néantomancienne Sepethrea",
        deDE = "Nethermantin Sepethrea",
        number = 1,
        [1] = {
            name = "ARCANE_BLAST",
            enUS = "Arcane Blast",
            frFR = "Déflagration des arcanes",
            deDE = "Arkanschlag",
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.50,            -- Dunno the exact value. Probably 50%.
                target = "THREAT_LEVEL",
                hasAmount = 1,
                invalidateFlatThreat = 1,
                owner = "TARGET",
                relative = "ACTOR",
            },
        },
        version = 1.05,
    },

    -- Sethekk Halls

    ["TALON_KING_IKISS"] = {       -- Wipes all (?) threat upon casting Blink.
        enUS = "Talon King Ikiss",
        frFR = "Roi-serre Ikiss",
        deDE = "Klauenk\195\182nig Ikiss",
        number = 1,
        [1] = {
            name = "BLINK",   -- It's instant (so detectable). :)
            enUS = "Blink",
            frFR = "Transfert",
            deDE = "Blinzeln",
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.00,            -- Dunno if it's a full reset. But he often went after our healer after an AE. I assume it's a FULL reset.
                target = "THREAT_LEVEL",
                hasAmount = nil,
                checkMiss = nil,
                owner = "ACTOR_LIST",
                relative = "ACTOR",
            },
        },
        version = 1.05,
    },

    -- Shadow Lab

    ["BLACKHEART"] = {        -- Wipes all threat upon mind controlling the party. Reduces threat by a % upon using war stomp.
        enUS = "Blackheart the Inciter",
        frFR = "Coeur-noir le Séditieux",
        deDE = "Schwarzherz der Hetzer",
        number = 2,
        [1] = {
            name = "WAR_STOMP",
            enUS = "War Stomp",
            frFR = "Choc martial",
            deDE = "Kriegsdonner",
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.50,   -- Is it really 50% ?
                target = "THREAT_LEVEL",
                hasAmount = 1,
                invalidateFlatThreat = 1,
                owner = "TARGET",
                relative = "ACTOR",
            },
        },
        [2] = {
            name = "MIND_CONTROL_RESET",
            enUS = "Time for fun",
            frFR = "Rions un peu",
            deDE = "Spass",
            isYell = 1,
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.00,
                target = "THREAT_LEVEL",
                owner = "ACTOR_LIST",
                relative = "ACTOR",
            },
        },
        version = 1.05,
    },

    ["MURMUR"] = {
        enUS = "Murmur",
        frFR = "Marmon",
        deDE = "Murmur",
        aggroDistance = "MELEE",
        number = 0,
        version = 1.05,
    },

    -- Shattered Halls

    ["WARBRINGER_O'MROGG"] = {         -- Not sure about this one; threat wipe when yelling something ?
        enUS = "Warbringer O'mrogg",
        frFR = "Porteguerre O'mrogg",
        deDE = "Kriegshetzer O'mrogg",
        number = 1,
        [1] = {
            name = "SWITCH_THREAT",
            enUS = "Me go kill someone else|Me not like this one",
            frFR = "un autre|j'aime pas",
            deDE = "???", -- TODO
            isYell = 1,
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.00,
                target = "THREAT_LEVEL",
                owner = "ACTOR_LIST",
                relative = "ACTOR",
            },
        },
        version = 1.05,
    },

    -- Karazhan

    ["ARCANE_ANOMALY"] = {   -- Reset each time they blink, I guess.
        enUS = "Arcane Anomaly",
        frFR = "Anomalie arcanique",
        deDE = "Arkananomalie",
        number = 1,
        [1] = {
            name = "RESET_THREAT",
            enUS = "Blink",         -- Is it really blink?
            frFR = "Transfert",
            deDE = "Blinzeln",
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.00,
                target = "THREAT_LEVEL",
                hasAmount = nil,
                checkMiss = nil,
                owner = "ACTOR_LIST",
                relative = "ACTOR",
            },
        },
        version = 1.05,
    },

    ["MIDNIGHT_AND_ATTUMEN"] = {         -- Attumen wipes all threat upon merging with Midnight.
        enUS = "Attumen the Huntsman",
        frFR = "Attumen le Veneur",
        deDE = "Attumen der J\195\164ger",
        number = 1,
        [1] = {
            name = "PHASE2_START",
            enUS = "Come Midnight",
            frFR = "Dispersons ces", -- Boss yells/emotes can be partial.
            deDE = "Komm Mittnacht",
            isYell = 1,       -- Specify the ability triggers when the boss yells/emotes something.
            effect = {
                type = "THREAT_WIPE", -- Special case, as units merge.
                triggerDelay = 2.0,
            },
        },
        version = 1.05,
    },

    ["DOROTHEE"] = {
        enUS = "Dorothee",
        frFR = "Dorothée",
        deDE = "Dorothee",
        noThreatList = 1,
        number = 0,
        version = 1.05,
    },

    ["SHADE_OF_ARAN"] = {
        enUS = "Shade of Aran",
        frFR = "Ombre d'Aran",
        deDE = "Arans Schemen",
        noThreatList = 1,
        number = 0,
        version = 1.05,
    },

    ["NETHERSPITE"] = {    -- Wipe all threat upon yelling a sentence.
        enUS = "Netherspite",
        frFR = "Dédain-du-Néant",
        deDE = "Nethergroll",
        warningOveride = -1, -- Enforce disabling of aggro-risk warnings.
        number = 1,
        [1] = {
            name = "RESET_THREAT1",
            enUS = "cries out in withdrawal, opening gates",
            frFR = "se retire avec un cri en ouvrant un portail",
            deDE = "Tore zum Nether",
            isYell = 1,
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.00,
                target = "THREAT_LEVEL",
                owner = "ACTOR_LIST",
                relative = "ACTOR",
            },
        },
        version = 1.05,
    },

    ["NIGHTBANE"] = {    -- Wipes all threat upon landing. (2 variations for the yell)
        enUS = "Nightbane",
        frFR = "Plaie-de-nuit",
        deDE = "Schrecken der Nacht",
        number = 1,
        [1] = {
            name = "RESET_THREAT",
            enUS = "Enough!|Insects!",  -- 2 possible yells
            frFR = "Je vais atterrir|Je vais vous montrer",
            deDE = "Genug!|Insekten!",
            isYell = 1,
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.00,
                target = "THREAT_LEVEL",
                owner = "ACTOR_LIST",
                relative = "ACTOR",
            },
        },
        version = 1.05,
    },

    -- Zul'Aman

    ["ZUL'JIN"] = {        -- Wipes all threat upon yelling 4 possibles messages.
        enUS = "Zul'jin",
        frFR = "Zul'jin",
        deDE = "Zul'jin",
        number = 1,
        [1] = {
            name = "PHASE_RESET",
            enUS = "brudda bear|da eagle|fang and claw|da dragonhawk",  -- 4 possible yells
            frFR = "frère ours|L'aigle|griffe et croc|lever les yeux au ciel",
            deDE = "???|???|???|???", -- TODO
            isYell = 1,
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.00,
                target = "THREAT_LEVEL",
                owner = "ACTOR_LIST",
                relative = "ACTOR",
            },
        },
        version = 1.051,
    },

    -- Gruul's Lair

    ["LAIR_BRUTE"] = { -- These lil' guys are really chaotic :) They'll reset threat once in a while, even if they do not charge.
        enUS = "Lair brute",
        frFR = "Brute du repaire",
        deDE = "Schläger des Unterschlupfs",
        number = 1,
        [1] = {
            name = "RESET_THREAT",
            enUS = "Charge",
            frFR = "Charge",
            deDE = "Sturmangriff",
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.00,
                target = "THREAT_LEVEL",
                hasAmount = nil, -- We are interested in the spell cast message, not the damage one, as they reset threat as they charge, regardless
                checkMiss = nil, -- whether it hits or not.
                owner = "ACTOR_LIST",
                relative = "ACTOR",
            },
        },
        version = 1.05,
    },

    ["KIGGLER_THE_CRAZED"] = {       -- Kiggler casts an AoE centered on the guy who has its attention.
        enUS = "Kiggler the Crazed", -- All targets affected will lose threat.
        frFR = "Kiggler le Cinglé",
        deDE = "Kiggler the Crazed", -- Confirm?
        number = 1,
        [1] = {
            name = "ARCANE_EXPLOSION",
            enUS = "Arcane explosion",
            frFR = "Explosion des arcanes",
            deDE = "Arkane Explosion",
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.25,   -- Is it really 50% ?
                target = "THREAT_LEVEL",
                hasAmount = 1,
                invalidateFlatThreat = 1,
                owner = "TARGET",
                relative = "ACTOR",
            },
        },
        version = 1.051,
    },

    ["GRUUL"] = {
        enUS = "Gruul the Dragonkiller",
        frFR = "Gruul le Tue-dragon",
        deDE = "Gruul der Drachenschl\195\164chter",
        number = 0,
        aggroDelay = 1.500,     -- Give more time before considering Gruul has changed its aggro target.
        version = 1.05,
    },

    -- Magtheridon's Lair

    ["HELLFIRE_WARDER"] = {
        enUS = "Hellfire Warder",
        frFR = "Gardien des Flammes infernales",
        deDE = "Höllenfeuerwärter",
        number = 1,
        [1] = {
            name = "SHADOW_BURST",
            enUS = "Shadow Burst",
            frFR = "Explosion d'ombre",
            deDE = "???", -- TODO (SpellID: 34436)
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.00,   -- Removes all threat according to thottbot's spell description.
                target = "THREAT_LEVEL",
                hasAmount = 1,
                invalidateFlatThreat = 1,
                owner = "TARGET",
                relative = "ACTOR",
            },
        },
        version = 1.05,
    },

    -- SSC

    ["GREYHEART_NETHER-MAGE"] = {       -- Wipes threat upon casting Blink.
        enUS = "Greyheart Nether-Mage",
        frFR = "Mage-du-Néant griscoeur",
        deDE = "Nethermagier der Grauherzen",
        number = 1,
        [1] = {
            name = "BLINK",
            enUS = "Blink",
            frFR = "Transfert",
            deDE = "Blinzeln",
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.00,
                target = "THREAT_LEVEL",
                hasAmount = nil,
                checkMiss = nil,
                owner = "ACTOR_LIST",
                relative = "ACTOR",
            },
        },
        version = 1.05,
    },

    ["HYDROSS"] = {        -- Wipes all threat upon changing phases.
        enUS = "Hydross the Unstable",
        frFR = "Hydross l'Instable",
        deDE = "Hydross der Unstete",
        aggroDelay = 1.200,
        number = 1,
        [1] = {
            name = "PHASE_RESET",
            enUS = "the poison|much better",
            frFR = "le poison|Beaucoup mieux",
            deDE = "das Gift|viel besser",
            isYell = 1,
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.00,
                target = "THREAT_LEVEL",
                owner = "ACTOR_LIST",
                relative = "ACTOR",
            },
        },
        version = 1.05,
    },

    ["THE_LURKER_BELOW"] = {
        enUS = "The Lurker Below",
        frFR = "Le Rôdeur d'En bas",
        deDE = "Das Grauen aus der Tiefe",
        aggroDistance = "MELEE",
        number = 0,
        version = 1.05,
    },

    ["LEOTHERAS"] = {        -- Wipes all threat upon starting Whirlwind or changing phase (human/demon/split).
        enUS = "Leotheras the Blind",
        frFR = "Leotheras l'Aveugle",
        deDE = "Leotheras der Blinde",
        number = 3,
        [1] = {
            name = "WHIRLWIND",
            enUS = "Whirlwind",
            frFR = "Tourbillon",
            deDE = "Wirbelwind",
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.00,
                target = "THREAT_LEVEL",
                hasAmount = nil,         -- We're only interested in the cast start event.
                checkMiss = nil,
                owner = "ACTOR_LIST",
                relative = "ACTOR",
            },
        },
        [2] = {
            name = "PHASE_RESET",
            enUS = "Be gone, trifling elf",
            frFR = "elfe insignifiant",
            deDE = "jetzt die Kontrolle",
            isYell = 1,
            effects = {
                [1] = {
                    type = "MULTIPLY_THREAT",
                    value = 0.00,
                    target = "THREAT_LEVEL",
                    owner = "ACTOR_LIST",
                    relative = "ACTOR",
                },
                [2] = {
                    type = "MULTIPLY_THREAT",
                    value = 0.00,
                    target = "THREAT_LEVEL",
                    owner = "ACTOR_LIST",
                    relative = "ACTOR",
                    triggerDelay = 60.0,
                },
            },
        },
        [3] = {
            name = "FORM_SPLIT",
            enUS = "What have you done",
            frFR = "Mais qu'avez-vous fait",
            deDE = "bin der Meister!",
            isYell = 1,
            effect = {
                type = "THREAT_WIPE",
            },
        },
        version = 1.051,
    },

    ["VASHJ"] = {        -- Wipes all threat upon changing phases.
        enUS = "Lady Vashj",
        frFR = "Dame Vashj",
        deDE = "Lady Vashj",
        number = 1,
        [1] = {
            name = "PHASE_RESET",
            enUS = "The time is now|You may want to take cover",
            frFR = "L'heure est venue|Il faudrait peut-être vous mettre à l'abri",
            deDE = "???", -- TODO
            isYell = 1,
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.00,
                target = "THREAT_LEVEL",
                owner = "ACTOR_LIST",
                relative = "ACTOR",
            },
        },
        version = 1.05,
    },

    -- The Eye

    ["AL'AR"] = {
        enUS = "Al'ar",
        frFR = "Al'ar",
        deDE = "Al'ar",
        aggroDistance = "MELEE",
        number = 0,
        version = 1.05,
    },

    ["EMBER_OF_AL'AR"] = {
        enUS = "Ember of Al'ar",
        frFR = "Braise d'Al'ar",
        deDE = "Al'ars Asche",
        warningOveride = 1, -- You seriously don't want to grab aggro of those. >.>
        number = 0,
        version = 1.05,
    },

    ["VOID_REAVER"] = {         -- Multiplies threat by 0.75x (having doubts on this) with its knock away ability.
        enUS = "Void Reaver",
        frFR = "Saccageur du Vide",
        deDE = "Leerh\195\164scher",
        aggroDelay = 1.200,     -- Give more time before considering VR has changed its aggro target.
        number = 1,
        [1] = {
            name = "KNOCK_AWAY",
            enUS = "Knock Away",
            frFR = "Repousser au loin",
            deDE = "Wegschlagen",
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.80,              -- Real big check needed.
                target = "THREAT_LEVEL",
                hasAmount = 1,
                invalidateFlatThreat = 1,
                owner = "TARGET",
                relative = "ACTOR",
            },
        },
        version = 1.052,
    },

    ["SOLARIAN"] = {         -- Reset threat @ 20% (I believe)
        enUS = "High Astromancer Solarian",
        frFR = "Grande astromancienne Solarian",
        deDE = "Hochastromant Solarian",
        -- noThreatList = 1,
        aggroDistance = "MELEE",
        number = 1,
        [1] = {
            name = "PHASE2_RESET",
            enUS = "Enough of this!|with the VOID!",
            frFR = "Assez de|avec le VIDE",
            deDE = "???", -- TODO
            isYell = 1,
            effects = { -- 2 effects. Notice the "s" on "effects".
                [1] = {
                    type = "MULTIPLY_THREAT",
                    value = 0.00,
                    target = "THREAT_LEVEL",
                    owner = "ACTOR_LIST",
                    relative = "ACTOR",
                },
                --[[
                [2] = {
                    type = "CHANGE_FLAG",
                    target = "NO_THREAT_LIST",
                    value = 0,
                },
                ]]
            },
        },
        version = 1.051,
    },

    -- Black Temple

    ["SUPREMUS"] = { -- When switching to phase 2, wipes threat. When switching back to phase 1 after 5 gazes, wipes threat.
         -- Forced aggro when it uses gaze.
        enUS = "Supremus",
        frFR = "Supremus",
        deDE = "Supremus",
        number = 1,
        [1] = {
            name = "PHASE_RESET",
            enUS = "Supremus punches the ground in anger",
            frFR = "De rage, Supremus frappe le sol",
            deDE = "auf den Boden!",
            isYell = 1,
            effects = { -- 2 effects. Notice the "s" on "effects".
                [1] = {
                    type = "MULTIPLY_THREAT",
                    value = 0.00,
                    target = "THREAT_LEVEL",
                    owner = "ACTOR_LIST",
                    relative = "ACTOR",
                },
                [2] = {
                    type = "CHANGE_FLAG",
                    target = "WARNING_OVERIDE",
                    value = -1,
                },
            },
        },
        version = 1.05,
    },

    ["GURTOGG_BLOODBOIL"] = {     -- Has knock away. Use special effects modifying global threat multiplier to 0.00x.
        enUS = "Gurtogg Bloodboil",
        frFR = "Gurtogg Fièvresang",
        deDE = "Gurtogg Siedeblut",
        number = 1,
        [1] = {
            name = "KNOCK_AWAY",
            enUS = "Knock Away",
            frFR = "Repousser au loin",
            deDE = "Wegschlagen",
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.75,
                target = "THREAT_LEVEL",
                hasAmount = 1,
                invalidateFlatThreat = 1,
                owner = "TARGET",
                relative = "ACTOR",
            },
        },
        -- Gurtogg Bloodboil also uses "Insignifiance" and "Fel Rage" debuff effects, which are defined in effects.lua in the NPC section.
        version = 1.05,
    },

    ["ILLIDAN"] = {     -- Shhhh ! It's a surprise...
        enUS = "Illidan Stormrage",
        frFR = "Illidan Hurlorage",
        deDE = "Illidan Sturmgrimm",
        warningOveride = 1,   -- Hey man, it's the final boss of BC ! You gotta be aware when you're about to pull aggro from this dude !
        number = 1,
        [1] = {
            name = "PHASE_RESET",
            enUS = "Behold the power",
            frFR = "Contemplez la puissance",
            deDE = "Erzittert vor der Macht",
            isYell = 1,
            effects = {
                [1] = {
                    type = "MULTIPLY_THREAT",
                    value = 0.00,
                    target = "THREAT_LEVEL",
                    owner = "ACTOR_LIST",
                    relative = "ACTOR",
                },
                [2] = {
                    type = "MULTIPLY_THREAT",
                    value = 0.00,
                    target = "THREAT_LEVEL",
                    owner = "ACTOR_LIST",
                    relative = "ACTOR",
                    triggerDelay = 65.0,    -- Another threat wipe after 65 sec., when he switches back to N.E. form.
                },
            },
        },
        -- Missing: Phase 2->3 detection (threat wipe). Or can I do it another way?
        version = 1.05,
    },

    -- Sunwell Plateau

    ["SACROLASH"] = {     -- Uses Confounding blow, which wipes all threat of the guy who gets hit.
        enUS = "Lady Sacrolash",
        frFR = "Dame Sacrocingle",
        deDE = "Lady Sacrolash",
        number = 1,
        [1] = {
            name = "CONFOUNDING_BLOW",
            enUS = "Confounding Blow",
            frFR = "Coup déconcertant",
            deDE = "???", -- TODO (SpellID: 45256)
            effect = {
                type = "MULTIPLY_THREAT",
                value = 0.00,
                target = "THREAT_LEVEL",
                hasAmount = 1,
                invalidateFlatThreat = 1,
                owner = "TARGET",
                relative = "ACTOR",
            },
        },
        version = 1.05,
    },

    -- Dummy/test NPC here. Removed for normal releases.
};

DTM_NPCAbilities = {};

-- --------------------------------------------------------------------
-- **                      NPC abilities functions                   **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_CheckNPCAbilitiesVersion()                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Grab all NPCs stored in NPCAbilities table and compare them      *
-- * against their DefaultNPCAbilities version if they exist.         *
-- * Return the number of NPCs that were updated (most of the time 0).*
-- ********************************************************************

function DTM_CheckNPCAbilitiesVersion()
    local updateCounter = 0;
    local savedVersion, providedVersion;

    for k, v in pairs( DTM_DefaultNPCAbilities ) do
        providedVersion = v.version or 1.00;

        if ( DTM_NPCAbilities[k] ) then
            savedVersion = DTM_NPCAbilities[k].version or 1.00;

            if ( providedVersion > savedVersion ) then
                -- Update this saved entry, provided one is more up to date.
                updateCounter = updateCounter + 1;

                DTM_SaveNPCAbilityData( k , v , providedVersion );
            end
        end
    end

    -- OK, we've updated old data, now insert new and missing data.
    DTM_CopyAllNPCAbilityData();

    return updateCounter;
end

-- ********************************************************************
-- * DTM_CopyAllNPCAbilityData()                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Copy default data about NPCs threat-modifying abilities to the   *
-- * saved NPC abilities table. Already existant entries for a given  *
-- * mob will not be overiden.                                        *
-- ********************************************************************

function DTM_CopyAllNPCAbilityData()
    for k, v in pairs( DTM_DefaultNPCAbilities ) do
        if not ( DTM_NPCAbilities[k] ) then
            -- This entry doesn't exist in NPCAbilities table. Insert it.
            DTM_SaveNPCAbilityData( k , v , v.version or 1.00 );
        end
    end
end

-- ********************************************************************
-- * DTM_SaveNPCAbilityData(internalName, data, version)              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> internalName: internal name (arbitrarily) chosen for the NPC. *
-- * >> data: reference to the table containing NPC data.             *
-- * >> version: the version of the NPC data.                         *
-- * NOTE: Leave version argument to nil if it's a NPC defined by the *
-- * user. Version will be set appropriately.                         *
-- ********************************************************************
-- * Saves in NPC abilities table data about a given NPC.             *
-- ********************************************************************

function DTM_SaveNPCAbilityData(internalName, data, version)
    if not ( internalName ) or not ( type(data) == "table" ) then return; end
    DTM_NPCAbilities[internalName] = DTM_CopyTable(data);
    DTM_NPCAbilities[internalName].version = version or USER_DEFINED_VERSION;
end

-- ********************************************************************
-- * DTM_GetNPCAbilityData(localeName)                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> localeName: name of the NPC as displayed by local player's    *
-- * client.                                                          *
-- ********************************************************************
-- * Get data about a NPC, if it's saved in NPCAbilities table.       *
-- ********************************************************************

function DTM_GetNPCAbilityData(localeName)
    if not ( localeName ) then return nil; end

    local key = lookupData[localeName];
    if ( key ) then
        return DTM_NPCAbilities[key];
    end

    return nil;
end

-- ********************************************************************
-- * DTM_GetNPCAbilityEffect(npcData, abilityName)                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> npcData: the NPC abilities data, got with GetNPCAbilityData   *
-- * >> abilityName: name of the ability as displayed by local        *
-- * player's client.                                                 *
-- ********************************************************************
-- * Get internal name and effect about a given NPC ability,          *
-- * if present in NPCAbilities table.                                *
-- * Note that NPC abilities internal names are chosen by the user    *
-- * and not built-in.                                                *
-- ********************************************************************

function DTM_GetNPCAbilityEffect(npcData, abilityName)
    if not ( npcData ) or not ( abilityName ) then return nil; end
    abilityName = strlower(abilityName);
    local locale = GetLocale();
    local i;
    for i=1, npcData.number do
        local abilityData = npcData[i];
        if ( abilityData[locale] ) then
            if not ( abilityData.isYell ) and ( strlower(abilityData[locale]) == abilityName ) then
                return abilityData.name, abilityData.effect;
            end
        end
    end
    return nil;
end

-- ********************************************************************
-- * DTM_GetNPCYellEffect(npcData, yellMessage)                       *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> npcData: the NPC abilities data, got with GetNPCAbilityData   *
-- * >> yellMessage: what the NPC yells, in local player's client     *
-- * language.                                                        *
-- ********************************************************************
-- * Get internal name, number of effects and effects about a         *
-- * given NPC yell trigger, if any are defined.                      *
-- * Note that NPC abilities internal name are chosen by the user     *
-- * and not built-in.                                                *
-- ********************************************************************

function DTM_GetNPCYellEffect(npcData, yellMessage)
    if not ( npcData ) or not ( yellMessage ) then return nil; end
    yellMessage = strlower(yellMessage);
    local locale = GetLocale();
    local i;
    for i=1, npcData.number do
        local abilityData = npcData[i];
        if ( abilityData[locale] ) then
            local pattern = strlower(abilityData[locale]);
            if ( abilityData.isYell ) and ( DTM_GetPartialMatch(yellMessage, pattern) == 1 ) then
                if not ( abilityData.effects ) then
                    return abilityData.name, 1, abilityData.effect;
              else
                    return abilityData.name, #abilityData.effects, abilityData.effects;
                end
            end
        end
    end
    return nil, 0, nil;
end

-- ********************************************************************
-- * DTM_GetPartialMatch(msg, pattern)                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> msg: the message in which we'll search for the pattern(s).    *
-- * >> pattern: the partial pattern to look for. Several pattern can *
-- * be specified by separating them with a pipe (|) caracter.        *
-- ********************************************************************
-- * Returns 1 if pattern is found in msg.                            *
-- ********************************************************************

function DTM_GetPartialMatch(msg, pattern)
    if not ( msg ) or not ( pattern ) then return nil; end

    local result = nil;
    local patterns = { strsplit("|", pattern) };
    local index, p, k, v;

    for index, p in ipairs(patterns) do
        if ( string.find(msg, p) ) then
            result = 1;
            break;
        end
    end

    for k, v in pairs(patterns) do
        patterns[k] = nil;
    end

    return result;
end

-- ********************************************************************
-- * DTM_RebuildNPCLookupData()                                       *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Rebuild lookup data, that is used to find quickly NPC info for   *
-- * your client language. It HAS to be called once at startup, and   *
-- * then preferably recalled whenever you perform changes on the     *
-- * npcAbilities table through SaveNPCAbilityData API.               *
-- ********************************************************************

function DTM_RebuildNPCLookupData()
    local k, v;
    for k, v in pairs(lookupData) do
        lookupData[k] = nil;
    end

    local locale = GetLocale();
    for k, v in pairs( DTM_NPCAbilities ) do
        if ( v[locale] ) then
            lookupData[v[locale]] = k;
        end
    end
end

-- ********************************************************************
-- * DTM_ClearAllNPCData()                                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Destroys the complete NPC abilities table.                       *
-- * You should rebuild it immediately after with default DB          *
-- * and then rebuild the lookup table.                               *
-- ********************************************************************

function DTM_ClearAllNPCData()
    local k, v;
    for k, v in pairs(DTM_NPCAbilities) do
        DTM_NPCAbilities[k] = nil;
    end
end