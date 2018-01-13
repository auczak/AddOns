local activeModule = "Internals";

-- --------------------------------------------------------------------
-- **                        Internals table                         **
-- --------------------------------------------------------------------

local internalTranslationErrors = {};

local DTM_Internals = {
    ["enUS"] = {
        ["classes"] = {
            -- The 9 standard classes

            ["Druid"] = "DRUID",
            ["Hunter"] = "HUNTER",
            ["Mage"] = "MAGE",
            ["Paladin"] = "PALADIN",
            ["Priest"] = "PRIEST",
            ["Rogue"] = "ROGUE",
            ["Shaman"] = "SHAMAN",
            ["Warlock"] = "WARLOCK",
            ["Warrior"] = "WARRIOR",

            -- Hero classes

            ["Death Knight"] = "DEATH_KNIGHT",
        },
        ["stances"] = {
            -- Druid stances

            ["Bear Form"] = "BEAR",
            ["Dire Bear Form"] = "BEAR",
            ["Cat Form"] = "CAT",
            ["Aquatic Form"] = "AQUATIC",
            ["Travel Form"] = "TRAVEL",
            ["Moonkin Form"] = "MOONKIN",
            ["Tree of Life"] = "TREE",
            ["Flight Form"] = "FLIGHT",
            ["Swift Flight Form"] = "FLIGHT",

            -- Warrior stances

            ["Battle Stance"] = "COMBAT",
            ["Defensive Stance"] = "DEFENSIVE",
            ["Berserker Stance"] = "BERSERKER",
        },
        ["talents"] = {
            -- Druid talents

            ["Feral Instinct"] = "FERAL_INSTINCT",
            ["Subtlety"] = "SUBTLETY",
            ["Improved Tranquility"] = "IMPROVED_TRANQUILITY",

            -- Hunter talents
            -- <None>

            -- Mage talents

            ["Arcane Subtlety"] = "ARCANE_SUBTLETY",
            ["Burning Soul"] = "BURNING_SOUL",
            ["Frost Channeling"] = "FROST_CHANNELING",

            -- Paladin talents

            ["Improved Righteous Fury"] = "IMPROVED_RIGHTEOUS_FURY",
            ["Fanaticism"] = "FANATICISM",

            -- Priest talents

            ["Silent Resolve"] = "SILENT_RESOLVE",
            ["Shadow Affinity"] = "SHADOW_AFFINITY",

            -- Rogue talents

            ["Sleight of Hand"] = "SLEIGHT_OF_HAND",

            -- Shaman talents

            ["Elemental Precision"] = "ELEMENTAL_PRECISION",
            ["Spirit Weapons"] = "SPIRIT_WEAPONS",
            ["Healing Grace"] = "HEALING_GRACE",
            ["Lightning Overload"] = "LIGHTNING_OVERLOAD",

            -- Warlock talents

            ["Master Demonologist"] = "MASTER_DEMONOLOGIST",
            ["Improved Drain Soul"] = "IMPROVED_DRAIN_SOUL",
            ["Destructive Reach"] = "DESTRUCTIVE_REACH",

            -- Warrior talents

            ["Defiance"] = "DEFIANCE",
            ["Improved Berserker Stance"] = "IMPROVED_BERSERKER_STANCE",
            ["Tactical Mastery"] = "TACTICAL_MASTERY",

            -- Pets-affecting talents

            ["Improved Succubus"] = "IMPROVED_SUCCUBUS",
            ["Improved Voidwalker"] = "IMPROVED_VOIDWALKER",
        },
        ["abilities"] = {
            -- Druid abilities

            ["Healing Touch"] = "HEALING_TOUCH",
            ["Rejuvenation"] = "REJUVENATION",
            ["Regrowth"] = "REGROWTH",
            ["Tranquility"] = "TRANQUILITY",
            ["Swiftmend"] = "SWIFTMEND",
            ["Lifebloom"] = "LIFEBLOOM",
            ["Wrath"] = "WRATH",
            ["Moonfire"] = "MOONFIRE",
            ["Starfire"] = "STARFIRE",
            ["Entangling Roots"] = "ENTANGLING_ROOTS",
            ["Insect Swarm"] = "INSECT_SWARM",
            ["Hurricane"] = "HURRICANE",
            ["Cower"] = "COWER",                  -- Also hunter pet ability.
            ["Growl"] = "GROWL",                  -- Also hunter pet ability.
            ["Maul"] = "MAUL",
            ["Swipe"] = "SWIPE",
            ["Mangle (Bear)"] = "MANGLE_BEAR",
            ["Lacerate"] = "LACERATE",
            ["Faerie Fire"] = "FAERIE_FIRE",
            ["Faerie Fire (Feral)"] = "FERAL_FAERIE_FIRE",
            ["Improved Leader of the Pack"] = "IMPROVED_LEADER_OF_THE_PACK",
            ["Soothe Animal"] = "SOOTHE_ANIMAL",
            ["Cyclone"] = "CYCLONE",
            ["Demoralizing Roar"] = "DEMORALIZING_ROAR",
            ["Hibernate"] = "HIBERNATE",
            ["Feral Charge"] = "FERAL_CHARGE",
            ["Barkskin"] = "BARKSKIN",

            -- Hunter abilities

            ["Distracting Shot"] = "DISTRACTING_SHOT",
            ["Disengage"] = "DISENGAGE",
            ["Feign Death"] = "FEIGN_DEATH",
            ["Misdirection"] = "MISDIRECTION",
            ["Hunter's Mark"] = "HUNTER_MARK",
            ["Viper Sting"] = "VIPER_STING",

            -- Mage abilities

            ["Arcane Explosion"] = "ARCANE_EXPLOSION",
            ["Arcane Missiles"] = "ARCANE_MISSILES",
            ["Arcane Blast"] = "ARCANE_BLAST",
            ["Fireball"] = "FIREBALL",
            ["Fire Blast"] = "FIRE_BLAST",
            ["Flamestrike"] = "FLAMESTRIKE",
            ["Pyroblast"] = "PYROBLAST",
            ["Scorch"] = "SCORCH",
            ["Blast Wave"] = "BLAST_WAVE",
            ["Dragon's Breath"] = "DRAGON_BREATH",
            ["Molten Armor"] = "MOLTEN_ARMOR",
            ["Ignite"] = "IGNITE",
            ["Frostbolt"] = "FROSTBOLT",
            ["Frost Nova"] = "FROST_NOVA",
            ["Cone of Cold"] = "CONE_OF_COLD",
            ["Blizzard"] = "BLIZZARD",
            ["Ice Lance"] = "ICE_LANCE",
            ["Counterspell"] = "COUNTERSPELL",
            ["Polymorph"] = "POLYMORPH",
            ["Polymorph: Pig"] = "POLYMORPH_PIG",
            ["Polymorph: Turtle"] = "POLYMORPH_TURTLE",

            -- Paladin abilities

            ["Seal of Righteousness"] = "SEAL_OF_RIGHTEOUSNESS",
            ["Holy Light"] = "HOLY_LIGHT",
            ["Lay on Hands"] = "LAY_ON_HANDS",
            ["Retribution Aura"] = "RETRIBUTION_AURA",
            ["Exorcism"] = "EXORCISM",
            ["Flash of Light"] = "FLASH_OF_LIGHT",
            ["Consecration"] = "CONSECRATION",
            ["Hammer of Wrath"] = "HAMMER_OF_WRATH",
            ["Holy Wrath"] = "HOLY_WRATH",
            ["Seal of Blood"] = "SEAL_OF_BLOOD",
            ["Seal of Vengeance"] = "SEAL_OF_VENGEANCE",
            ["Holy Shock"] = "HOLY_SHOCK",
            ["Avenger's Shield"] = "AVENGER_SHIELD",
            ["Seal of Command"] = "SEAL_OF_COMMAND",
            ["Judgement of Righteousness"] = "JUDGEMENT_OF_RIGHTEOUSNESS",
            ["Judgement of Command"] = "JUDGEMENT_OF_COMMAND",
            ["Judgement of Blood"] = "JUDGEMENT_OF_BLOOD",
            ["Judgement of Vengeance"] = "JUDGEMENT_OF_VENGEANCE",
            ["Holy Shield"] = "HOLY_SHIELD",
            ["Hammer of Justice"] = "HAMMER_OF_JUSTICE",
            ["Righteous Defense"] = "RIGHTEOUS_DEFENSE",

            -- Priest abilities

            ["Lesser Heal"] = "LESSER_HEAL",
            ["Smite"] = "SMITE",
            ["Renew"] = "RENEW",
            ["Heal"] = "HEAL",
            ["Flash Heal"] = "FLASH_HEAL",
            ["Holy Fire"] = "HOLY_FIRE",
            ["Mana Burn"] = "MANA_BURN",
            ["Mind Control"] = "MIND_CONTROL",
            ["Prayer of Healing"] = "PRAYER_OF_HEALING",
            ["Greater Heal"] = "GREATER_HEAL",
            ["Binding Heal"] = "BINDING_HEAL",
            ["Prayer of Mending"] = "PRAYER_OF_MENDING",
            ["Desperate Prayer"] = "DESPERATE_PRAYER",
            ["Starshards"] = "STARSHARDS",
            ["Chastise"] = "CHASTISE",
            ["Circle of Healing"] = "CIRCLE_OF_HEALING",
            ["Mind Flay"] = "MIND_FLAY",
            ["Mind Blast"] = "MIND_BLAST",
            ["Vampiric Touch"] = "VAMPIRIC_TOUCH",
            ["Vampiric Embrace"] = "VAMPIRIC_EMBRACE",
            ["Shadow Word: Pain"] = "SHADOW_WORD_PAIN",
            ["Shadow Word: Death"] = "SHADOW_WORD_DEATH",
            ["Devouring Plague"] = "DEVOURING_PLAGUE",
            ["Holy Nova"] = "HOLY_NOVA",
            ["Shadowguard"] = "SHADOWGUARD",
            ["Reflective Shield"] = "REFLECTIVE_SHIELD",
            ["Mind Soothe"] = "MIND_SOOTHE",
            ["Power Word: Shield"] = "POWER_WORD_SHIELD",
            ["Mind Vision"] = "MIND_VISION",

            -- Rogue abilities

            ["Feint"] = "FEINT",
            ["Sap"] = "SAP",
            ["Backstab"] = "BACKSTAB",
            ["Sinister Strike"] = "SINISTER_STRIKE",
            ["Hemorrhage"] = "HEMORRHAGE",
            ["Eviscerate"] = "EVISCERATE",
            ["Blind"] = "BLIND",
            ["Anesthetic Poison"] = "ANESTHETIC_POISON",

            -- Shaman abilities

            ["Lightning Bolt"] = "LIGHTNING_BOLT",
            ["Chain Lightning"] = "CHAIN_LIGHTNING",
            ["Earth Shock"] = "EARTH_SHOCK",
            ["Frost Shock"] = "FROST_SHOCK",
            ["Flame Shock"] = "FLAME_SHOCK",
            ["Lightning Shield"] = "LIGHTNING_SHIELD",
            ["Windfury Attack"] = "WINDFURY",
            ["Windfury Weapon"] = "WINDFURY_WEAPON",
            ["Stormstrike"] = "STORMSTRIKE",
            ["Healing Wave"] = "HEALING_WAVE",
            ["Lesser Healing Wave"] = "LESSER_HEALING_WAVE",
            ["Chain Heal"] = "CHAIN_HEAL",
            ["Earth Shield"] = "EARTH_SHIELD",
            ["Nature's Guardian"] = "NATURE_GUARDIAN",
            ["Purge"] = "PURGE",

            -- Warlock abilities

            ["Corruption"] = "CORRUPTION",
            ["Curse of Agony"] = "CURSE_OF_AGONY",
            ["Drain Soul"] = "DRAIN_SOUL",
            ["Drain Life"] = "DRAIN_LIFE",
            ["Drain Mana"] = "DRAIN_MANA",
            ["Death Coil"] = "DEATH_COIL",
            ["Curse of Doom"] = "CURSE_OF_DOOM",
            ["Seed of Corruption"] = "SEED_OF_CORRUPTION",
            ["Siphon Life"] = "SIPHON_LIFE",
            ["Unstable Affliction"] = "UNSTABLE_AFFLICTION",
            ["Shadow Bolt"] = "SHADOW_BOLT",
            ["Immolate"] = "IMMOLATE",
            ["Searing Pain"] = "SEARING_PAIN",
            ["Rain of Fire"] = "RAIN_OF_FIRE",
            ["Hellfire"] = "HELLFIRE",
            ["Soul Fire"] = "SOUL_FIRE",
            ["Incinerate"] = "INCINERATE",
            ["Shadowburn"] = "SHADOWBURN",
            ["Conflagrate"] = "CONFLAGRATE",
            ["Shadowfury"] = "SHADOWFURY",
            ["Soulshatter"] = "SOULSHATTER",
            ["Curse of Shadow"] = "CURSE_OF_SHADOW",
            ["Curse of Elements"] = "CURSE_OF_ELEMENTS",
            ["Curse of Weakness"] = "CURSE_OF_WEAKNESS",
            ["Curse of Recklessness"] = "CURSE_OF_RECKLESSNESS",
            ["Curse of Tongues"] = "CURSE_OF_TONGUES",
            ["Fear"] = "FEAR",
            ["Howl of Terror"] = "HOWL_OF_TERROR",
            ["Banish"] = "BANISH",
            ["Life Tap"] = "LIFE_TAP",

            -- Warrior abilities

            ["Mortal Strike"] = "MORTAL_STRIKE",
            ["Bloodthirst"] = "BLOODTHIRST",
            ["Cleave"] = "CLEAVE",
            ["Devastate"] = "DEVASTATE",
            ["Disarm"] = "DISARM",
            ["Hamstring"] = "HAMSTRING",
            ["Heroic Strike"] = "HEROIC_STRIKE",
            ["Revenge"] = "REVENGE",
            ["Shield Bash"] = "SHIELD_BASH",
            ["Shield Slam"] = "SHIELD_SLAM",
            ["Sunder Armor"] = "SUNDER_ARMOR",
            ["Thunder Clap"] = "THUNDER_CLAP",
            ["Execute"] = "EXECUTE",
            ["Taunt"] = "TAUNT",
            ["Mocking Blow"] = "MOCKING_BLOW",
            ["Demoralizing Shout"] = "DEMORALIZING_SHOUT",

            -- Pets abilities
            -- (some shares the same name as druid's, cf. druid section)

            ["Anguish"] = "ANGUISH",
            ["Torment"] = "TORMENT",
            ["Suffering"] = "SUFFERING",
            ["Soothing Kiss"] = "SOOTHING_KISS",
        },
        ["effects"] = {
            -- Stance triggers

            ["Bear Form"] = "BEAR_FORM",
            ["Dire Bear Form"] = "DIRE_BEAR_FORM",
            ["Cat Form"] = "CAT_FORM",
            ["Aquatic Form"] = "AQUATIC_FORM",
            ["Travel Form"] = "TRAVEL_FORM",
            ["Moonkin Form"] = "MOONKIN_FORM",
            ["Flight Form"] = "FLIGHT_FORM",
            ["Swift Flight Form"] = "SWIFT_FLIGHT_FORM",
            ["Battle Stance"] = "COMBAT_STANCE",
            ["Defensive Stance"] = "DEFENSIVE_STANCE",
            ["Berserker Stance"] = "BERSERKER_STANCE",

            -- Crowd control effects

            ["Cyclone"] = "CYCLONE",
            ["Hibernate"] = "HIBERNATE",
            ["Freezing Trap Effect"] = "FREEZING_TRAP",
            ["Scare Beast"] = "SCARE_BEAST",
            ["Wyvern Sting"] = "WYVERN_STING",
            ["Polymorph"] = "POLYMORPH",
            ["Polymorph: Pig"] = "POLYMORPH_PIG",
            ["Polymorph: Turtle"] = "POLYMORPH_TURTLE",
            ["Turn Undead"] = "TURN_UNDEAD",
            ["Turn Evil"] = "TURN_EVIL",
            ["Psychic Scream"] = "PSYCHIC_SCREAM",
            ["Sap"] = "SAP",
            ["Banish"] = "BANISH",
            ["Fear"] = "FEAR",
            ["Seduction"] = "SEDUCTION",
            ["Intimidating Shout"] = "INTIMIDATING_SHOUT",
            ["Shackle Undead"] = "SHACKLE_UNDEAD",

            -- Normal effects

            ["Misdirection"] = "MISDIRECTION",
            ["Feign Death"] = "FEIGN_DEATH",
            ["Intimidation"] = "INTIMIDATION",
            ["Invisibility"] = "INVISIBILITY",
            ["Righteous Defense"] = "RIGHTEOUS_DEFENSE",
            ["Righteous Fury"] = "RIGHTEOUS_FURY",
            ["Blessing of Salvation"] = "BLESSING_OF_SALVATION",
            ["Greater Blessing of Salvation"] = "GREATER_BLESSING_OF_SALVATION",
            ["Divine Intervention"] = "DIVINE_INTERVENTION",
            ["Fade"] = "FADE",
            ["Pain Suppression"] = "PAIN_SUPPRESSION",
            ["Vanish"] = "VANISH",
            ["Shadowstep"] = "SHADOWSTEP",
            ["Tranquil Air"] = "TRANQUIL_AIR",
            ["Sunder Armor"] = "SUNDER_ARMOR",

            -- NPC effects

            ["Insignifigance"] = "INSIGNIFIGANCE",
            ["Fel Rage"] = "FEL_RAGE",
            ["Spiteful Fury"] = "SPITEFUL_FURY",
        },
        ["pets"] = {
            ["Imp"] = "IMP",
            ["Succubus"] = "SUCCUBUS",
            ["Voidwalker"] = "VOIDWALKER",
            ["Felhunter"] = "FELHUNTER",
            ["Felguard"] = "FELGUARD",
        },
    },

    ["frFR"] = {
        ["classes"] = {
            -- The 9 standard classes

            ["Druide"] = "DRUID",
            ["Chasseur"] = "HUNTER",
            ["Mage"] = "MAGE",
            ["Paladin"] = "PALADIN",
            ["Prêtre"] = "PRIEST",
            ["Voleur"] = "ROGUE",
            ["Chaman"] = "SHAMAN",
            ["Démoniste"] = "WARLOCK",
            ["Guerrier"] = "WARRIOR",

            -- Hero classes

            ["Chevalier de la mort"] = "DEATH_KNIGHT",
        },
        ["stances"] = {
            -- Druid stances

            ["Forme d'ours"] = "BEAR",
            ["Forme d'ours redoutable"] = "BEAR",
            ["Forme de félin"] = "CAT",
            ["Forme aquatique"] = "AQUATIC",
            ["Forme de voyage"] = "TRAVEL",
            ["Forme de sélénien"] = "MOONKIN",
            ["Arbre de vie"] = "TREE",
            ["Forme de vol"] = "FLIGHT",
            ["Forme de vol rapide"] = "FLIGHT",

            -- Warrior stances

            ["Posture de combat"] = "COMBAT",
            ["Posture défensive"] = "DEFENSIVE",
            ["Posture berserker"] = "BERSERKER",
        },
        ["talents"] = {
            -- Druid talents

            ["Instinct farouche"] = "FERAL_INSTINCT",
            ["Discrétion"] = "SUBTLETY",
            ["Tranquillité améliorée"] = "IMPROVED_TRANQUILITY",

            -- Hunter talents
            -- <None>

            -- Mage talents

            ["Subtilité des arcanes"] = "ARCANE_SUBTLETY",
            ["Ame ardente"] = "BURNING_SOUL",
            ["Canalisation du givre"] = "FROST_CHANNELING",

            -- Paladin talents

            ["Fureur vertueuse améliorée"] = "IMPROVED_RIGHTEOUS_FURY",
            ["Fanatisme"] = "FANATICISM",

            -- Priest talents

            ["Résolution silencieuse"] = "SILENT_RESOLVE",
            ["Affinité avec l'Ombre"] = "SHADOW_AFFINITY",

            -- Rogue talents

            ["Passe-passe"] = "SLEIGHT_OF_HAND",

            -- Shaman talents

            ["Précision élémentaire"] = "ELEMENTAL_PRECISION",
            ["Armes spirituelles"] = "SPIRIT_WEAPONS",
            ["Grâce guérisseuse"] = "HEALING_GRACE",
            ["Surcharge de foudre"] = "LIGHTNING_OVERLOAD",

            -- Warlock talents

            ["Maître démonologue"] = "MASTER_DEMONOLOGIST",
            ["Drain d'âme amélioré"] = "IMPROVED_DRAIN_SOUL",
            ["Allonge de destruction"] = "DESTRUCTIVE_REACH",

            -- Warrior talents

            ["Défi"] = "DEFIANCE",
            ["Posture berserker améliorée"] = "IMPROVED_BERSERKER_STANCE",
            ["Maîtrise tactique"] = "TACTICAL_MASTERY",

            -- Pets-affecting talents

            ["Succube améliorée"] = "IMPROVED_SUCCUBUS",
            ["Marcheur du Vide amélioré"] = "IMPROVED_VOIDWALKER",
        },
        ["abilities"] = {
            -- Druid abilities

            ["Toucher guérisseur"] = "HEALING_TOUCH",
            ["Récupération"] = "REJUVENATION",
            ["Rétablissement"] = "REGROWTH",
            ["Tranquillité"] = "TRANQUILITY",
            ["Prompte guérison"] = "SWIFTMEND",
            ["Fleur de vie"] = "LIFEBLOOM",
            ["Colère"] = "WRATH",
            ["Eclat lunaire"] = "MOONFIRE",
            ["Feu stellaire"] = "STARFIRE",
            ["Sarments"] = "ENTANGLING_ROOTS",
            ["Essaim d'insectes"] = "INSECT_SWARM",
            ["Ouragan"] = "HURRICANE",
            ["Dérobade"] = "COWER",                    -- Also hunter pet ability.
            ["Grondement"] = "GROWL",                  -- Also hunter pet ability.
            ["Mutiler"] = "MAUL",
            ["Balayage"] = "SWIPE",
            ["Mutilation (ours)"] = "MANGLE_BEAR",
            ["Lacérer"] = "LACERATE",
            ["Lucioles"] = "FAERIE_FIRE",
            ["Lucioles (farouche)"] = "FERAL_FAERIE_FIRE",
            ["Chef de la meute amélioré"] = "IMPROVED_LEADER_OF_THE_PACK",
            ["Apaiser les animaux"] = "SOOTHE_ANIMAL",
            ["Cyclone"] = "CYCLONE",
            ["Rugissement démoralisant"] = "DEMORALIZING_ROAR",
            ["Hibernation"] = "HIBERNATE",
            ["Charge farouche"] = "FERAL_CHARGE",
            ["Ecorce"] = "BARKSKIN",

            -- Hunter abilities

            ["Trait provocateur"] = "DISTRACTING_SHOT",
            ["Désengagement"] = "DISENGAGE",
            ["Feindre la mort"] = "FEIGN_DEATH",
            ["Détournement"] = "MISDIRECTION",
            ["Marque du chasseur"] = "HUNTER_MARK",
            ["Morsure de vipère"] = "VIPER_STING",

            -- Mage abilities

            ["Explosion des arcanes"] = "ARCANE_EXPLOSION",
            ["Projectiles des arcanes"] = "ARCANE_MISSILES",
            ["Déflagration des arcanes"] = "ARCANE_BLAST",
            ["Boule de feu"] = "FIREBALL",
            ["Trait de feu"] = "FIRE_BLAST",
            ["Choc de flammes"] = "FLAMESTRIKE",
            ["Explosion pyrotechnique"] = "PYROBLAST",
            ["Brûlure"] = "SCORCH",
            ["Vague explosive"] = "BLAST_WAVE",
            ["Souffle du dragon"] = "DRAGON_BREATH",
            ["Armure de la fournaise"] = "MOLTEN_ARMOR",
            ["Enflammer"] = "IGNITE",
            ["Eclair de givre"] = "FROSTBOLT",
            ["Nova de givre"] = "FROST_NOVA",
            ["Cône de froid"] = "CONE_OF_COLD",
            ["Blizzard"] = "BLIZZARD",
            ["Javelot de glace"] = "ICE_LANCE",
            ["Contresort"] = "COUNTERSPELL",
            ["Métamorphose"] = "POLYMORPH",
            ["Métamorphose : cochon"] = "POLYMORPH_PIG",
            ["Métamorphose : tortue"] = "POLYMORPH_TURTLE",

            -- Paladin abilities

            ["Sceau de piété"] = "SEAL_OF_RIGHTEOUSNESS",
            ["Lumière sacrée"] = "HOLY_LIGHT",
            ["Imposition des mains"] = "LAY_ON_HANDS",
            ["Aura de vindicte"] = "RETRIBUTION_AURA",
            ["Exorcisme"] = "EXORCISM",
            ["Eclair lumineux"] = "FLASH_OF_LIGHT",
            ["Consécration"] = "CONSECRATION",
            ["Marteau de courroux"] = "HAMMER_OF_WRATH",
            ["Colère divine"] = "HOLY_WRATH",
            ["Sceau de sang"] = "SEAL_OF_BLOOD",
            ["Sceau de vengeance"] = "SEAL_OF_VENGEANCE",
            ["Horion sacré"] = "HOLY_SHOCK",
            ["Bouclier du vengeur"] = "AVENGER_SHIELD",
            ["Sceau d'autorité"] = "SEAL_OF_COMMAND",
            ["Jugement de piété"] = "JUDGEMENT_OF_RIGHTEOUSNESS",
            ["Jugement d'autorité"] = "JUDGEMENT_OF_COMMAND",
            ["Jugement de sang"] = "JUDGEMENT_OF_BLOOD",
            ["Jugement de vengeance"] = "JUDGEMENT_OF_VENGEANCE",
            ["Bouclier sacré"] = "HOLY_SHIELD",
            ["Marteau de la justice"] = "HAMMER_OF_JUSTICE",
            ["Défense vertueuse"] = "RIGHTEOUS_DEFENSE",

            -- Priest abilities

            ["Soins inférieurs"] = "LESSER_HEAL",
            ["Châtiment"] = "SMITE",
            ["Rénovation"] = "RENEW",
            ["Soins"] = "HEAL",
            ["Soins rapides"] = "FLASH_HEAL",
            ["Flammes sacrées"] = "HOLY_FIRE",
            ["Brûlure de mana"] = "MANA_BURN",
            ["Contrôle mental"] = "MIND_CONTROL",
            ["Prière de soins"] = "PRAYER_OF_HEALING",
            ["Soins supérieurs"] = "GREATER_HEAL",
            ["Soins de lien"] = "BINDING_HEAL",
            ["Prière de guérison"] = "PRAYER_OF_MENDING",
            ["Prière désespérée"] = "DESPERATE_PRAYER",
            ["Eclats stellaires"] = "STARSHARDS",
            ["Châtier"] = "CHASTISE",
            ["Cercle de soins"] = "CIRCLE_OF_HEALING",
            ["Fouet mental"] = "MIND_FLAY",
            ["Attaque mentale"] = "MIND_BLAST",
            ["Toucher vampirique"] = "VAMPIRIC_TOUCH",
            ["Etreinte vampirique"] = "VAMPIRIC_EMBRACE",
            ["Mot de l'ombre : Douleur"] = "SHADOW_WORD_PAIN",
            ["Mot de l'ombre : Mort"] = "SHADOW_WORD_DEATH",
            ["Peste dévorante"] = "DEVOURING_PLAGUE",
            ["Nova sacrée"] = "HOLY_NOVA",
            ["Garde de l'ombre"] = "SHADOWGUARD",
            ["Bouclier réflecteur"] = "REFLECTIVE_SHIELD",
            ["Apaisement"] = "MIND_SOOTHE",
            ["Mot de pouvoir : Bouclier"] = "POWER_WORD_SHIELD",
            ["Vision télépathique"] = "MIND_VISION",

            -- Rogue abilities

            ["Feinte"] = "FEINT",
            ["Assomer"] = "SAP",
            ["Attaque sournoise"] = "BACKSTAB",
            ["Attaque pernicieuse"] = "SINISTER_STRIKE",
            ["Hémorragie"] = "HEMORRHAGE",
            ["Eviscération"] = "EVISCERATE",
            ["Cécité"] = "BLIND",
            ["Poison anesthésiant"] = "ANESTHETIC_POISON",

            -- Shaman abilities

            ["Eclair"] = "LIGHTNING_BOLT",
            ["Chaîne d'éclairs"] = "CHAIN_LIGHTNING",
            ["Horion de terre"] = "EARTH_SHOCK",
            ["Horion de givre"] = "FROST_SHOCK",
            ["Horion de flammes"] = "FLAME_SHOCK",
            ["Bouclier de foudre"] = "LIGHTNING_SHIELD",
            ["Attaque Furie-des-vents"] = "WINDFURY",
            ["Arme Furie-des-vents"] = "WINDFURY_WEAPON",
            ["Frappe-tempête"] = "STORMSTRIKE",
            ["Vague de soins"] = "HEALING_WAVE",
            ["Vague de soins inférieurs"] = "LESSER_HEALING_WAVE",
            ["Salve de guérison"] = "CHAIN_HEAL",
            ["Bouclier de terre"] = "EARTH_SHIELD",
            ["Gardien de la nature"] = "NATURE_GUARDIAN",
            ["Expiation"] = "PURGE",

            -- Warlock abilities

            ["Corruption"] = "CORRUPTION",
            ["Malédiction d'agonie"] = "CURSE_OF_AGONY",
            ["Drain d'âme"] = "DRAIN_SOUL",
            ["Drain de vie"] = "DRAIN_LIFE",
            ["Drain de mana"] = "DRAIN_MANA",
            ["Voile mortel"] = "DEATH_COIL",
            ["Malédiction funeste"] = "CURSE_OF_DOOM",
            ["Graine de corruption"] = "SEED_OF_CORRUPTION",
            ["Siphon de vie"] = "SIPHON_LIFE",
            ["Affliction instable"] = "UNSTABLE_AFFLICTION",
            ["Trait de l'ombre"] = "SHADOW_BOLT",
            ["Immolation"] = "IMMOLATE",
            ["Douleur brûlante"] = "SEARING_PAIN",
            ["Pluie de feu"] = "RAIN_OF_FIRE",
            ["Flammes infernales"] = "HELLFIRE",
            ["Feu de l'âme"] = "SOUL_FIRE",
            ["Incinérer"] = "INCINERATE",
            ["Brûlure de l'ombre"] = "SHADOWBURN",
            ["Conflagration"] = "CONFLAGRATE",
            ["Furie de l'ombre"] = "SHADOWFURY",
            ["Brise-âme"] = "SOULSHATTER",
            ["Malédiction de l'ombre"] = "CURSE_OF_SHADOW",
            ["Malédiction des éléments"] = "CURSE_OF_ELEMENTS",
            ["Malédiction de faiblesse"] = "CURSE_OF_WEAKNESS",
            ["Malédiction de témérité"] = "CURSE_OF_RECKLESSNESS",
            ["Malédiction des langages"] = "CURSE_OF_TONGUES",
            ["Peur"] = "FEAR",
            ["Hurlement de terreur"] = "HOWL_OF_TERROR",
            ["Bannir"] = "BANISH",
            ["Connexion"] = "LIFE_TAP",

            -- Warrior abilities

            ["Frappe mortelle"] = "MORTAL_STRIKE",
            ["Sanguinaire"] = "BLOODTHIRST",
            ["Enchaînement"] = "CLEAVE",
            ["Dévaster"] = "DEVASTATE",
            ["Désarmement"] = "DISARM",
            ["Brise-genou"] = "HAMSTRING",
            ["Frappe héroïque"] = "HEROIC_STRIKE",
            ["Vengeance"] = "REVENGE",
            ["Coup de bouclier"] = "SHIELD_BASH",
            ["Heurt de bouclier"] = "SHIELD_SLAM",
            ["Fracasser armure"] = "SUNDER_ARMOR",
            ["Coup de tonnerre"] = "THUNDER_CLAP",
            ["Exécution"] = "EXECUTE",
            ["Provocation"] = "TAUNT",
            ["Coup railleur"] = "MOCKING_BLOW",
            ["Cri démoralisant"] = "DEMORALIZING_SHOUT",

            -- Pets abilities
            -- (some shares the same name as druid's, cf. druid section)

            ["Angoisse"] = "ANGUISH",
            ["Tourment"] = "TORMENT",
            ["Souffrance"] = "SUFFERING",
            ["Baiser apaisant"] = "SOOTHING_KISS",
        },
        ["effects"] = {
            -- Stance triggers

            ["Forme d'ours"] = "BEAR_FORM",
            ["Forme d'ours redoutable"] = "DIRE_BEAR_FORM",
            ["Forme de félin"] = "CAT_FORM",
            ["Forme aquatique"] = "AQUATIC_FORM",
            ["Forme de voyage"] = "TRAVEL_FORM",
            ["Forme de sélénien"] = "MOONKIN_FORM",
            ["Forme de vol"] = "FLIGHT_FORM",
            ["Forme de vol rapide"] = "SWIFT_FLIGHT_FORM",
            ["Posture de combat"] = "COMBAT_STANCE",
            ["Posture défensive"] = "DEFENSIVE_STANCE",
            ["Posture berserker"] = "BERSERKER_STANCE",

            -- Crowd control effects

            ["Cyclone"] = "CYCLONE",
            ["Hibernation"] = "HIBERNATE",
            ["Effet Piège givrant"] = "FREEZING_TRAP",
            ["Effrayer une bête"] = "SCARE_BEAST",
            ["Piqûre de wyverne"] = "WYVERN_STING",
            ["Métamorphose"] = "POLYMORPH",
            ["Métamorphose : cochon"] = "POLYMORPH_PIG",
            ["Métamorphose : tortue"] = "POLYMORPH_TURTLE",
            ["Renvoi des morts-vivants"] = "TURN_UNDEAD",
            ["Renvoi du mal"] = "TURN_EVIL",
            ["Cri psychique"] = "PSYCHIC_SCREAM",
            ["Assomer"] = "SAP",
            ["Bannir"] = "BANISH",
            ["Peur"] = "FEAR",
            ["Séduction"] = "SEDUCTION",
            ["Cri d'intimidation"] = "INTIMIDATING_SHOUT",
            ["Entraves des morts-vivants"] = "SHACKLE_UNDEAD",

            -- Normal effects

            ["Détournement"] = "MISDIRECTION",
            ["Feindre la mort"] = "FEIGN_DEATH",
            ["Intimidation"] = "INTIMIDATION",
            ["Invisibilité"] = "INVISIBILITY",
            ["Défense vertueuse"] = "RIGHTEOUS_DEFENSE",
            ["Fureur vertueuse"] = "RIGHTEOUS_FURY",
            ["Bénédiction de salut"] = "BLESSING_OF_SALVATION",
            ["Bénédiction de salut supérieure"] = "GREATER_BLESSING_OF_SALVATION",
            ["Intervention divine"] = "DIVINE_INTERVENTION",
            ["Oubli"] = "FADE",
            ["Suppression de la douleur"] = "PAIN_SUPPRESSION",
            ["Disparition"] = "VANISH",
            ["Pas de l'ombre"] = "SHADOWSTEP",
            ["Tranquilité de l'air"] = "TRANQUIL_AIR",
            ["Fracasser armure"] = "SUNDER_ARMOR",

            -- NPC effects

            ["Insignifiance"] = "INSIGNIFIGANCE",
            ["Gangrerage"] = "FEL_RAGE",
            ["Fureur malveillante"] = "SPITEFUL_FURY",
        },
        ["pets"] = {
            ["Diablotin"] = "IMP",
            ["Succube"] = "SUCCUBUS",
            ["Marcheur du Vide"] = "VOIDWALKER",
            ["Chasseur corrompu"] = "FELHUNTER",
            ["Gangregarde"] = "FELGUARD",
        },
    },

    ["deDE"] = {
        ["classes"] = {
            -- The 9 standard classes

            ["Druide"] = "DRUID",
            ["J\195\164ger"] = "HUNTER",
            ["Magier"] = "MAGE",
            ["Paladin"] = "PALADIN",
            ["Priester"] = "PRIEST",
            ["Schurke"] = "ROGUE",
            ["Schamane"] = "SHAMAN",
            ["Hexenmeister"] = "WARLOCK",
            ["Krieger"] = "WARRIOR",

            -- Hero classes

        },
        ["stances"] = {
            -- Druid stances

            ["B\195\164rengestalt"] = "BEAR",
            ["Terrorb\195\164rengestalt"] = "BEAR",
            ["Katzengestalt"] = "CAT",
            ["Wassergestalt"] = "AQUATIC",
            ["Reisegestalt"] = "TRAVEL",
            ["Moonkingestalt"] = "MOONKIN",
            ["Baum des Lebens"] = "TREE",
            ["Fluggestalt"] = "FLIGHT",
            ["Schnelle Fluggestalt"] = "FLIGHT",

            -- Warrior stances

            ["Kampfhaltung"] = "COMBAT",
            ["Verteidigungshaltung"] = "DEFENSIVE",
            ["Berserkerhaltung"] = "BERSERKER",
        },
        ["talents"] = {
            -- Druid talents

            ["Instinkt der Wildnis"] = "FERAL_INSTINCT",
            ["Feingef\195\188hl"] = "SUBTLETY",
            ["Verbesserte Gelassenheit"] = "IMPROVED_TRANQUILITY",

            -- Hunter talents
            -- <None>

            -- Mage talents

            ["Arkanes Feingef\195\188hl"] = "ARCANE_SUBTLETY",
            ["Brennende Seele"] = "BURNING_SOUL",
            ["Frost-Kanalisierung"] = "FROST_CHANNELING",

            -- Paladin talents

            ["Verbesserter Zorn der Gerechtigkeit"] = "IMPROVED_RIGHTEOUS_FURY",
            ["Fanatismus"] = "FANATICISM",

            -- Priest talents

            ["Schweigsame Entschlossenheit"] = "SILENT_RESOLVE",
            ["Schattenaffinit\195\164t"] = "SHADOW_AFFINITY",

            -- Rogue talents

            ["Kunstgriff"] = "SLEIGHT_OF_HAND",

            -- Shaman talents

            ["Elementare Pr\195\164zision"] = "ELEMENTAL_PRECISION",
            ["Waffen der Geister"] = "SPIRIT_WEAPONS",
            ["Geschick der Heilung"] = "HEALING_GRACE",
            ["Blitzüberladung"] = "LIGHTNING_OVERLOAD",

            -- Warlock talents

            ["Meister der D\195\164monologie"] = "MASTER_DEMONOLOGIST",
            ["Verbesserter Seelendieb"] = "IMPROVED_DRAIN_SOUL",
            ["Zerst\195\182rerische Reichweite"] = "DESTRUCTIVE_REACH",

            -- Warrior talents

            ["Trotz"] = "DEFIANCE",
            ["Verbesserte Berserkerhaltung"] = "IMPROVED_BERSERKER_STANCE",
            ["Taktiker"] = "TACTICAL_MASTERY",

            -- Pets-affecting talents

            ["Verbesserter Sukkubus"] = "IMPROVED_SUCCUBUS",
            ["Verbesserter Leerwandler"] = "IMPROVED_VOIDWALKER",
        },
        ["abilities"] = {
            -- Druid abilities

            ["Heilende Ber\195\188hrung"] = "HEALING_TOUCH",
            ["Verj\195\188ngung"] = "REJUVENATION",
            ["Nachwachsen"] = "REGROWTH",
            ["Gelassenheit"] = "TRANQUILITY",
            ["Rasche Heilung"] = "SWIFTMEND",
            ["Bl\195\188hendes Leben"] = "LIFEBLOOM",
            ["Zorn"] = "WRATH",
            ["Mondfeuer"] = "MOONFIRE",
            ["Sternenfeuer"] = "STARFIRE",
            ["Wucherwurzeln"] = "ENTANGLING_ROOTS",
            ["Insektenschwarm"] = "INSECT_SWARM",
            ["Hurrikan"] = "HURRICANE",
            ["Ducken"] = "COWER",                   -- Also hunter pet ability.
            ["Knurren"] = "GROWL",                  -- Also hunter pet ability.
            ["Zermalmen"] = "MAUL",
            ["Prankenhieb"] = "SWIPE",
            ["Zerfleischen (B\195\164r)"] = "MANGLE_BEAR",
            ["Aufschlitzen"] = "LACERATE",
            ["Feenfeuer"] = "FAERIE_FIRE",
            ["Feenfeuer (Tiergestalt)"] = "FERAL_FAERIE_FIRE",
            ["Verbesserte Rudelf\195\188hrer"] = "IMPROVED_LEADER_OF_THE_PACK",
            ["Tier bes\195\164nftigen"] = "SOOTHE_ANIMAL",
            ["Wirbelsturm"] = "CYCLONE",
            ["Demoralisierendes Gebr\195\188ll"] = "DEMORALIZING_ROAR",
            ["Winterschlaf"] = "HIBERNATE",
            ["Wilde Attacke"] = "FERAL_CHARGE",
            ["Baumrinde"] = "BARKSKIN",

            -- Hunter abilities

            ["Ablenkender Schuss"] = "DISTRACTING_SHOT",
            ["R\195\188ckzug"] = "DISENGAGE",
            ["Totstellen"] = "FEIGN_DEATH",
            ["Irref\195\188hrung"] = "MISDIRECTION",
            ["Mal des J\195\164gers"] = "HUNTER_MARK",
            ["Vipernbiss"] = "VIPER_STING",

            -- Mage abilities

            ["Arkane Explosion"] = "ARCANE_EXPLOSION",
            ["Arkane Geschosse"] = "ARCANE_MISSILES",
            ["Arkanschlag"] = "ARCANE_BLAST",
            ["Feuerball"] = "FIREBALL",
            ["Feuerschlag"] = "FIRE_BLAST",
            ["Flammensto\195\159"] = "FLAMESTRIKE",
            ["Pyroschlag"] = "PYROBLAST",
            ["Versengen"] = "SCORCH",
            ["Druckwelle"] = "BLAST_WAVE",
            ["Drachenodem"] = "DRAGON_BREATH",
            ["Gl\195\188hende R\195\188stung"] = "MOLTEN_ARMOR",
            ["Entz\195\188nden"] = "IGNITE",
            ["Frostblitz"] = "FROSTBOLT",
            ["Frostnova"] = "FROST_NOVA",
            ["K\195\164ltekegel"] = "CONE_OF_COLD",
            ["Blizzard"] = "BLIZZARD",
            ["Eislanze"] = "ICE_LANCE",
            ["Gegenzauber"] = "COUNTERSPELL",
            ["Verwandlung"] = "POLYMORPH",
            ["Verwandlung: Schwein"] = "POLYMORPH_PIG",
            ["Verwandlung: Schildkr\195\182te"] = "POLYMORPH_TURTLE",

            -- Paladin abilities

            ["Siegel der Rechtschaffenheit"] = "SEAL_OF_RIGHTEOUSNESS",
            ["Heiliges Licht"] = "HOLY_LIGHT",
            ["Handauflegung"] = "LAY_ON_HANDS",
            ["Aura der Vergeltung"] = "RETRIBUTION_AURA",
            ["Exorzismus"] = "EXORCISM",
            ["Lichtblitz"] = "FLASH_OF_LIGHT",
            ["Weihe"] = "CONSECRATION",
            ["Hammer des Zorns"] = "HAMMER_OF_WRATH",
            ["Heiliger Zorn"] = "HOLY_WRATH",
            ["Siegel des Blutes"] = "SEAL_OF_BLOOD",
            ["Siegel der Vergeltung"] = "SEAL_OF_VENGEANCE",
            ["Heiliger Schock"] = "HOLY_SHOCK",
            ["Schild des R\195\164chers"] = "AVENGER_SHIELD",
            ["Siegel des Befehls"] = "SEAL_OF_COMMAND",
            ["Richturteil der Rechtschaffenheit"] = "JUDGEMENT_OF_RIGHTEOUSNESS",
            ["Richturteil des Befehls"] = "JUDGEMENT_OF_COMMAND",
            ["Richturteil des Blutes"] = "JUDGEMENT_OF_BLOOD",
            ["Richturteil der Rache"] = "JUDGEMENT_OF_VENGEANCE",
            ["Heiliger Schild"] = "HOLY_SHIELD",
            ["Hammer der Gerechtigkeit"] = "HAMMER_OF_JUSTICE",
            ["Rechtschaffene Verteidigung"] = "RIGHTEOUS_DEFENSE",

            -- Priest abilities

            ["Geringes Heilen"] = "LESSER_HEAL",
            ["G\195\182ttliche Pein"] = "SMITE",
            ["Erneuerung"] = "RENEW",
            ["Heilen"] = "HEAL",
            ["Blitzheilung"] = "FLASH_HEAL",
            ["Heiliges Feuer"] = "HOLY_FIRE",
            ["Manabrand"] = "MANA_BURN",
            ["Gedankenkontrolle"] = "MIND_CONTROL",
            ["Prayer of Healing"] = "PRAYER_OF_HEALING",
            ["Gro\195\159e Heilung"] = "GREATER_HEAL",
            ["Verbindende Heilung"] = "BINDING_HEAL",
            ["Gebet der Besserung"] = "PRAYER_OF_MENDING",
            ["Verzweifeltes Gebet"] = "DESPERATE_PRAYER",
            ["Sternensplitter"] = "STARSHARDS",
            ["Z\195\188chtigung"] = "CHASTISE",
            ["Kreis der Heilung"] = "CIRCLE_OF_HEALING",
            ["Gedankenschinden"] = "MIND_FLAY",
            ["Gedankenschlag"] = "MIND_BLAST",
            ["Vampirber\195\188hrung"] = "VAMPIRIC_TOUCH",
            ["Vampirumarmung"] = "VAMPIRIC_EMBRACE",
            ["Schattenwort: Schmerz"] = "SHADOW_WORD_PAIN",
            ["Schattenwort: Tod"] = "SHADOW_WORD_DEATH",
            ["Verschlingende Seuche"] = "DEVOURING_PLAGUE",
            ["Heilige Nova"] = "HOLY_NOVA",
            ["Schattenschild"] = "SHADOWGUARD",
            ["Reflektierender Schild"] = "REFLECTIVE_SHIELD",
            ["Gedankenbes\195\164nftigung"] = "MIND_SOOTHE",
            ["Machtwort: Schild"] = "POWER_WORD_SHIELD",
            ["Gedankensicht"] = "MIND_VISION",

            -- Rogue abilities

            ["Finte"] = "FEINT",
            ["Kopfnuss"] = "SAP",
            ["Meucheln"] = "BACKSTAB",
            ["Finsterer Sto\195\159"] = "SINISTER_STRIKE",
            ["Blutsturz"] = "HEMORRHAGE",
            ["Ausweiden"] = "EVISCERATE",
            ["Blenden"] = "BLIND",
            ["Beruhigendes Gift"] = "ANESTHETIC_POISON",

            -- Shaman abilities

            ["Blitzschlag"] = "LIGHTNING_BOLT",
            ["Kettenblitzschlag"] = "CHAIN_LIGHTNING",
            ["Erdschock"] = "EARTH_SHOCK",
            ["Frostschock"] = "FROST_SHOCK",
            ["Flammenschock"] = "FLAME_SHOCK",
            ["Blitzschlagschild"] = "LIGHTNING_SHIELD",
            ["Angriff des Windzorns"] = "WINDFURY",
            ["Waffe des Windzorns"] = "WINDFURY_WEAPON",
            ["Sturmschlag"] = "STORMSTRIKE",
            ["Welle der Heilung"] = "HEALING_WAVE",
            ["Geringe Welle der Heilung"] = "LESSER_HEALING_WAVE",
            ["Kettenheilung"] = "CHAIN_HEAL",
            ["Erdschild"] = "EARTH_SHIELD",
            ["Wächter der Natur"] = "NATURE_GUARDIAN",
            ["Reinigen"] = "PURGE",

            -- Warlock abilities

            ["Verderbnis"] = "CORRUPTION",
            ["Fluch der Pein"] = "CURSE_OF_AGONY",
            ["Seelendieb"] = "DRAIN_SOUL",
            ["Blutsauger"] = "DRAIN_LIFE",
            ["Mana entziehen"] = "DRAIN_MANA",
            ["Todesmantel"] = "DEATH_COIL",
            ["Fluch der Verdammnis"] = "CURSE_OF_DOOM",
            ["Saat der Verderbnis"] = "SEED_OF_CORRUPTION",
            ["Lebensentzug"] = "SIPHON_LIFE",
            ["Instabiles Gebrechen"] = "UNSTABLE_AFFLICTION",
            ["Schattenblitz"] = "SHADOW_BOLT",
            ["Feuerbrand"] = "IMMOLATE",
            ["Sengender Schmerz"] = "SEARING_PAIN",
            ["Feuerregen"] = "RAIN_OF_FIRE",
            ["H\195\182llenfeuer"] = "HELLFIRE",
            ["Seelenfeuer"] = "SOUL_FIRE",
            ["Verbrennen"] = "INCINERATE",
            ["Schattenbrand"] = "SHADOWBURN",
            ["Feuersbrunst"] = "CONFLAGRATE",
            ["Schattenfurie"] = "SHADOWFURY",
            ["Seele brechen"] = "SOULSHATTER",
            ["Fluch der Schatten"] = "CURSE_OF_SHADOW",
            ["Fluch der Elemente"] = "CURSE_OF_ELEMENTS",
            ["Fluch der Schw\195\164che"] = "CURSE_OF_WEAKNESS",
            ["Fluch der Tollk\195\188hnheit"] = "CURSE_OF_RECKLESSNESS",
            ["Fluch der Sprachen"] = "CURSE_OF_TONGUES",
            ["Furcht"] = "FEAR",
            ["Schreckgeheul"] = "HOWL_OF_TERROR",
            ["Verbannen"] = "BANISH",
            ["Aderlass"] = "LIFE_TAP",

            -- Warrior abilities

            ["T\195\182dlicher Sto\195\159"] = "MORTAL_STRIKE",
            ["Blutdurst"] = "BLOODTHIRST",
            ["Spalten"] = "CLEAVE",
            ["Verw\195\188sten"] = "DEVASTATE",
            ["Entwaffnen"] = "DISARM",
            ["Kniesehne"] = "HAMSTRING",
            ["Heldenhafter Sto\195\159"] = "HEROIC_STRIKE",
            ["Rache"] = "REVENGE",
            ["Schildhieb"] = "SHIELD_BASH",
            ["Schildschlag"] = "SHIELD_SLAM",
            ["R\195\188stung zerrei\195\159en"] = "SUNDER_ARMOR",
            ["Donnerknall"] = "THUNDER_CLAP",
            ["Hinrichten"] = "EXECUTE",
            ["Spott"] = "TAUNT",
            ["Sp\195\182ttischer Schlag"] = "MOCKING_BLOW",
            ["Demoralisierender Ruf"] = "DEMORALIZING_SHOUT",

            -- Pets abilities
            -- (some shares the same name as druid's, cf. druid section)

            ["Seelenpein"] = "ANGUISH",
            ["Qual"] = "TORMENT",
            ["Leiden"] = "SUFFERING",
            ["Bes\195\164nftigender Kuss"] = "SOOTHING_KISS",
        },
        ["effects"] = {
            -- Stance triggers

            ["B\195\164rengestalt"] = "BEAR_FORM",
            ["Terrorb\195\164rengestalt"] = "DIRE_BEAR_FORM",
            ["Katzengestalt"] = "CAT_FORM",
            ["Wassergestalt"] = "AQUATIC_FORM",
            ["Reisegestalt"] = "TRAVEL_FORM",
            ["Moonkingestalt"] = "MOONKIN_FORM",
            ["Fluggestalt"] = "FLIGHT_FORM",
            ["Schnelle Fluggestalt"] = "SWIFT_FLIGHT_FORM",
            ["Kampfhaltung"] = "COMBAT_STANCE",
            ["Verteidigungshaltung"] = "DEFENSIVE_STANCE",
            ["Berserkerhaltung"] = "BERSERKER_STANCE",

            -- Crowd control effects

            ["Wirbelsturm"] = "CYCLONE",
            ["Winterschlaf"] = "HIBERNATE",
            ["Eisk\195\164ltefalle Effekt"] = "FREEZING_TRAP",
            ["Wildtier \195\164ngstigen"] = "SCARE_BEAST",
            ["Stich des Fl\195\188geldrachen"] = "WYVERN_STING",
            ["Verwandlung"] = "POLYMORPH",
            ["Verwandlung: Schwein"] = "POLYMORPH_PIG",
            ["Verwandlung: Schildkr\195\182te"] = "POLYMORPH_TURTLE",
            ["Untote vertreiben"] = "TURN_UNDEAD",
            ["Böses vertreiben"] = "TURN_EVIL",
            ["Psychischer Schrei"] = "PSYCHIC_SCREAM",
            ["Kopfnuss"] = "SAP",
            ["Verbannen"] = "BANISH",
            ["Furcht"] = "FEAR",
            ["Verf\195\188hrung"] = "SEDUCTION",
            ["Drohruf"] = "INTIMIDATING_SHOUT",
            ["Untote fesseln"] = "SHACKLE_UNDEAD",

            -- Normal effects

            ["Irref\195\188hrung"] = "MISDIRECTION",
            ["Totstellen"] = "FEIGN_DEATH",
            ["Einsch\195\188chterung"] = "INTIMIDATION",
            ["Unsichtbarkeit"] = "INVISIBILITY",
            ["Rechtschaffene Verteidigung"] = "RIGHTEOUS_DEFENSE",
            ["Zorn der Gerechtigkeit"] = "RIGHTEOUS_FURY",
            ["Segen der Rettung"] = "BLESSING_OF_SALVATION",
            ["Gro\195\159er Segen der Rettung"] = "GREATER_BLESSING_OF_SALVATION",
            ["G\195\182ttliches Eingreifen"] = "DIVINE_INTERVENTION",
            ["Verblassen"] = "FADE",
            ["Schmerzunterdr\195\188ckung"] = "PAIN_SUPPRESSION",
            ["Verschwinden"] = "VANISH",
            ["Schattenschritt"] = "SHADOWSTEP",
            ["Beruhigenden Winde"] = "TRANQUIL_AIR",
            ["R\195\188stung zerrei\195\159en"] = "SUNDER_ARMOR",

            -- NPC effects

            ["Bedeutungslosigkeit"] = "INSIGNIFIGANCE",
            ["Teufelswut"] = "FEL_RAGE",
            ["Boshafter Furor"] = "SPITEFUL_FURY",
        },
        ["pets"] = {
            ["Wichtel"] = "IMP",
            ["Sukkubus"] = "SUCCUBUS",
            ["Leerwandler"] = "VOIDWALKER",
            ["Teufelsj\195\164ger"] = "FELHUNTER",
            ["Teufelswache"] = "FELGUARD",
        },
    },
};

local DTM_ReverseInternals = {};

local function DTM_BuildReverseInternals(section)
    if not ( DTM_ReverseInternals[section] ) then DTM_ReverseInternals[section] = {}; end
    local localeTable = DTM_Internals[GetLocale()];
    if ( localeTable ) then
        local sectionTable = localeTable[section];
        if ( sectionTable ) then
            local k, v;
            for k, v in pairs(sectionTable) do
                DTM_ReverseInternals[section][v] = k;
            end
        end
    end
end

-- We only need reverse table for effects.
DTM_BuildReverseInternals("effects");

-- --------------------------------------------------------------------
-- **                     Internals functions                        **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_GetInternal(category, name, noError)                         *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> category: the type of stuff we want to get internal from.     *
-- * Can be "talents", "abilities", "classes", "effects", "stances" or "pets".
-- * >> name: the name of the talent or ability in your locale.       *
-- * >> noError: if set, no error will be fired if the internal is    *
-- * not found.                                                       *
-- ********************************************************************

function DTM_GetInternal(category, name, noError)
    local locale = DTM_Internals[GetLocale()];
    local internal = nil;

    if ( locale ) then
        if ( locale[category] ) then
            internal = locale[category][name];
        end
    end

    if ( not internal ) and not ( noError ) then
        internalTranslationErrors[category..":"..name] = 1;
    end

    return internal;
end

-- ********************************************************************
-- * DTM_ReverseInternal(category, name)                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> category: the type of stuff we want to reverse internal from. *
-- * Can only be "effects" currently.                                 *
-- * >> name: the internal to reverse.                                *
-- ********************************************************************

function DTM_ReverseInternal(category, name)
    local reverse = nil;
    if ( DTM_ReverseInternals[category] ) then
        reverse = DTM_ReverseInternals[category][name];
    end
    return reverse;
end

-- ********************************************************************
-- * DTM_GetNumInternalTranslationErrors()                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Get the number of internals translation errors that occured      *
-- * since the UI was loaded. The local RECORD_INTERNAL_ERRORS has    *
-- * to be set to enable this functionnality.                         *
-- ********************************************************************

function DTM_GetNumInternalTranslationErrors()
    local count = 0;
    for k, v in pairs( internalTranslationErrors ) do
        count = count + 1;
    end
    return count;
end

-- ********************************************************************
-- * DTM_GetInternalTranslationError(index)                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> the index of the error.                                       *
-- ********************************************************************
-- * Get one of the internal translation that failed since startup.   *
-- ********************************************************************

function DTM_GetInternalTranslationError(index)
    local count = 0;
    for k, v in pairs( internalTranslationErrors ) do
        count = count + 1;
        if ( count == index ) then return k; end
    end
    return "";
end