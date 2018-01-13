local activeModule = "Localisation";
local DTM_MISSING_TRANSLATION = "%s"; -- Leave this one in English.

-- Bindings translation

if ( GetLocale() == 'frFR' ) then
    -- French

    BINDING_HEADER_DTM_BINDINGS = "Commandes DiamondThreatMeter";
    BINDING_NAME_DTM_EMERGENCYSTOP = "Arrêt d'urgence";
    BINDING_NAME_DTM_RESETTHREAT = "Réinitialiser listes de menace";
    BINDING_NAME_DTM_TOGGLETARGET = "Basculer liste de menace <cible>";
    BINDING_NAME_DTM_TOGGLEFOCUS = "Basculer liste de menace <focus>";
    BINDING_NAME_DTM_TOGGLEOVERVIEW = "Basculer sa vue d'ensemble";
    BINDING_NAME_DTM_TOGGLEREGAIN = "Basculer sa liste de reprise";

elseif ( GetLocale() == "foo" ) then
    -- Note to translators: just replace "foo" with the language you wish to provide.



elseif ( GetLocale() == "bar" ) then
    -- Note to translators: just replace "bar" with the language you wish to provide.



else
    -- Default

    BINDING_HEADER_DTM_BINDINGS = "DiamondThreatMeter commands";
    BINDING_NAME_DTM_EMERGENCYSTOP = "Emergency stop";
    BINDING_NAME_DTM_RESETTHREAT = "Reset all threat lists";
    BINDING_NAME_DTM_TOGGLETARGET = "Toggle <target> threat list";
    BINDING_NAME_DTM_TOGGLEFOCUS = "Toggle <focus> threat list";
    BINDING_NAME_DTM_TOGGLEOVERVIEW = "Toggle overview list";
    BINDING_NAME_DTM_TOGGLEREGAIN = "Toggle regain list";
end

-- --------------------------------------------------------------------
-- **                     Localisation table                         **
-- --------------------------------------------------------------------

local DTM_Locale = {
    ["default"] = {
         ["Unknown"] = "Unknown",
         ["Invalid"] = "Invalid",
         ["Sec"] = "sec",
         ["AlteracValley"] = "Alterac Valley",
         ["RankCapture"] = "Rank (%d+)",
         ["Foo"] = "Foo",
         ["Bar"] = "Bar",
         ["Enabled"] = "Enabled",
         ["Position"] = "Position",
         ["Justification"] = "Justification",
         ["LeftShort"] = "L",
         ["CenterShort"] = "C",
         ["RightShort"] = "R",
         ["Erase"] = "Erase",
         ["Auto"] = "Auto",
         ["Top"] = "Top",
         ["Center"] = "Center",
         ["Bottom"] = "Bottom",

         ["VersionQueryTimeOut"] = "No answer",
         ["VersionQueryDisconnected"] = "Disconnected",

         -- Console localisation

         ["Boot"] = "DiamondThreatMeter loaded and ready. |cff8080ff(v%s)|r\n/DTM to show a list of commands.",
         ["SavedVariablesBadVersion"] = "Configuration parameters are no longer compatible with this version. Default parameters will be used.",
         ["SkinsBadVersion"] = "Skins system is no longer compatible. Default parameters will be used.",
         ["SkinsVersionUpgrade"] = "Skins system has been upgraded to a newer version. Your previous skins could have been adapted successfully.",
         ["ProfileRegistered"] = "The profile of <%s> has been created.",
         ["NPCAbilitiesUpdated"] = "|cffffff00%d|r NPCs were updated in DTM NPC database.",
         ["NPCAbilitiesReset"] = "NPC database has been reset. Predefined NPCs have been restored.",
         ["CheckSavedVariablesReset"] = "Are you sure you want to completely reset DTM configuration?\n\nYour interface will be reloaded.",
         ["CheckNPCDatabaseReset"] = "Are you sure you want to completely reset DTM NPC database?\n\nDefault NPC database will be restored.",
         ["CheckAllReset"] = "Are you sure you want to ERASE ANY DATA saved by DTM, including config and skins? The Addon will behave as if it was run for the first time.\n\nType in |cffff0000ERASE|r to confirm.\n\nYour interface will be reloaded.",
         ["VersionCheckReminder"] = "We recommand you to run a version check and see if there is a newer version of DTM available.\n\nDo you want DTM to do it for you now?",

         ["FirstRunWelcome"] = "This is the first time |cff00ff00DiamondThreatMeter |cff6060ffv%s|r is run on this WoW client.\n\nYou can access the AddOn slash commands with |cff00ff00/DTM|r and modify its settings in |cffffff00WoW interface and bindings menus.|r",
         ["FirstRunWelcomeBeta"] = "This is the first time |cff00ff00DiamondThreatMeter |cff6060ffv%s|r is run on this WoW |cffffff00Beta|r client.\n\nNote that DTM is still under development and that many threat values are currently inaccurate and will be fixed in future versions.",
         ["FunctionalityNotImplementedYet"] = "Sorry! This functionality, |cffffff00%s|r, is not implemented yet! Please wait a future version.",
         ["OpenOptions"] = "Open options",
         ["RoleSelection"] = "Please type in the role you perform currently:\n|cff00ff40Tank | Damage | AoE\nHealer | Solo with pet|r\n\nDTM will be configured automatically to suit this role.",
         ["RoleTank"] = "Tank",
         ["RoleTankMatches"] = "tank|chucknorris|chuck norris",
         ["RoleDamageDealer"] = "Damage dealer",
         ["RoleDamageDealerMatches"] = "damage|dd|dps",
         ["RoleAoEer"] = "AoEer",
         ["RoleAoEerMatches"] = "aoe|pbaoe|zone|zoner",
         ["RoleHealer"] = "Healer",
         ["RoleHealerMatches"] = "healer|heal",
         ["RolePet"] = "Solo with pet",
         ["RolePetMatches"] = "pet|solo with pet",
         ["RoleSelected"] = "You have selected |cff00ff00%s|r.\n\nIf you change your role in the meantime, remember to change DTM configuration to suit your new role better.\n\nBy default, threat lists only apparear when you are grouped.",

         ["EmergencyStopDisabled"] = "|cff40ff40Emergency stop has been deactivated.|r";
         ["EmergencyStopEnabled"] = "|cffff4040Emergency stop has been activated.|r\nEnter /DTM toggle to rearm the AddOn.";

         ["NotifyEngineDisabled"] = "DTM engine is currently disabled. Go to Interface options to re-enable it.",
         ["NotifyGUIDisabled"] = "DTM GUI is currently disabled. Go to Interface options to re-enable it.",

         ["ConsoleBadSyntax"] = "Bad syntax for this slash command. Try:\n",
         ["ConsoleUnknown"] = "You specified an unknown command. Suggestions:\n",
         ["ConsoleBroken"] = "The command could not run, though it should have. Maybe you don't have the full DTM AddOn running.",

         ["TestNoTalent"] = "No talent has been found for %s. Maybe it isn't a PC.",
         ["TestCannotQueryTalents"] = "Can't get active talents of %s. Try getting closer or it isn't a friendly PC.",
         ["TestQueryTalentsFired"] = "Getting %s talents...",
         ["TestQueryTalentsError"] = "Talents request of %s failed. Maybe some AddOn or Blizzard's inspect frame interfered with DTM system.",
         ["TestTalentDB"] = "%d talents have been found in DTM talents database for %s:",
         ["TestTalentDBRow"] = "%d. %s",
         ["TestTalentRank"] = "|cff8080ff%s|r [%s] Rank |cffffff00%d/%d|r",
         ["TestNoPCAbility"] = "%s is a PC. PCs cannot have innate special abilities.",
         ["TestNoNPCAbility"] = "No threat modifying abilities were found on %s NPC.",
         ["TestNPCAbility"] = "%d threat modifying abilities were found on %s NPC:",
         ["TestNPCAbilityRow"] = "%d. |cffffff00%s|r",
         ["TestNoAssociationErrors"] = "No association error was recorded. Maybe the recording feature is turned OFF in the LUA script file.",
         ["TestAssociationErrors"] = "%d association errors have been recorded:",
         ["TestAssociationErrorsRow"] = "%d. |cffffff00%s|r",
         ["TestGearThreatMultiplier"] = "Threat multiplier from items: |cff00ff00x%.3f|r",
         ["TestSets"] = "The following are the armor sets found for %s:",
         ["TestSetsRow"] = "|cffffff00%s|r %d/%d",
         ["TestListNumber"] = "DTM is aware of %d entities:",
         ["TestListRow"] = "%d. %s (%s)",
         ["TestListThreatListNumber"] = "    %s's threat list contains %d entities:",
         ["TestListThreatListRow"] = "    %d. %s (%s) [%d]",
         ["TestVersionSent"] = "Request sent to get DTM versions used by the group...",
         ["TestVersionErrorUnknown"] = "An error occured while sending the version test.",
         ["TestVersionErrorFlood"] = "Please wait a bit before sending a version test.",
         ["TestVersionErrorNotGrouped"] = "You are not in a group, a version test is useless.",
         ["TestVersionResults"] = "Results of version test:",
         ["TestVersionResultsRow"] = "%d. %s %s |cffffff00[%s]|r",
         ["TestTalentsBufferNumber"] = "The talents buffer is aware of %d entities:",
         ["TestTalentsBufferRow"] = "%d. %s (%d talents registered)",
         ["TestItemsBufferNumber"] = "The items buffer is aware of %d entities:",
         ["TestItemsBufferRow"] = "%d. %s (%d items equipped)",

         ["ResetEntityData"] = "All threat data have been reset.",

         ["ErrorInCombat"] = "An error flagged as %s has occured in DTM. The error log will be displayed once you leave combat mode.",
         ["ErrorPosition"] = "Error %d out of %d",
         ["ErrorHeader"] = "Error %d - Type: %s, module: |cff4040ff%s|r\n|cffffffffError message:|r",
         ["ErrorHeaderNoError"] = "No error has been encountered so far.",
         ["ErrorType:MINOR"] = "|cff00ff00Minor|r",
         ["ErrorType:MAJOR"] = "|cffff8000Major|r",
         ["ErrorType:CRITICAL"] = "|cffff0000Critical|r",

         -- Threat, overview, regain lists localisation

         ["guiHeader"] = "DiamondThreatMeter v%s",

         ["Name"] = "Name",
         ["Threat"] = "Threat",
         ["TPS"] = "TPS",
         ["Relative"] = "Who ?",

         ["unitInfo"] = "%s Level %s %s",
         ["unitInfoLight"] = "%s %s",
         ["noThreatList"] = "|cffffa000This NPC does not use a threat list.|r",

         ["aggroRegain"] = "|cffff4040Aggro regain|r",
         ["aggroRegainClose"] = "|cffff8020Aggro (close)|r",

         ["standbyTarget"] = "No NPC selected.",
         ["standbyTargetWrongReaction"] = "This NPC is not hostile.",
         ["standbyTargetDead"] = "Your target is |cffff4040dead|r.",
         ["standbyTargetOpening"] = "Opening threat list...",
         ["standbyFocus"] = "No NPC set as focus.",
         ["standbyFocusWrongReaction"] = "This NPC is not hostile.",
         ["standbyFocusDead"] = "Your focus is |cffff4040dead|r.",
         ["standbyFocusOpening"] = "Opening threat list...",

         ["overviewNoUnit"] = "Unknown unit.",
         ["overviewOpening"] = "Opening presence list...",
         ["overviewUnitInfo"] = "Overview (%s)",

         ["regainNoUnit"] = "Unknown unit.",
         ["regainOpening"] = "Opening regain list...",
         ["regainUnitInfo"] = "Regain (%s)",

         ["test"] = "Test",
         ["testList"] = "This is a test list.",

         ["tankToggle"] = "Is a tank",
         ["tankToggleTooltip"] = "This button allows you to set whether this unit is a tank or not. Tanks show a special icon instead of their class one.",

         ["anchorSetting"] = "Anchor point",
         ["anchorSettingTooltip"] = "You can choose here how you want this list to be anchored. It will expend on the opposite anchor direction.",

         -- Configuration frame localisation

         -- 0. Overall

         ["configEngineCategory"] = "Engine",
         ["configGUICategory"] = "GUI",
         ["configSystemCategory"] = "System",
         ["configWarningCategory"] = "Warnings",
         ["configNameplateCategory"] = "Nameplates",
         ["configVersionCategory"] = "Version",

         -- 1. Intro panel

         ["configIntroTitle"] = "Welcome in DTM configuration panel !",
         ["configIntroSubTitle"] = "From this panel you can access the other configuration panels of DTM.",

         ["configIntroSystemPart"] = "System configuration",
         ["configIntroEnginePart"] = "Engine configuration",
         ["configIntroGUIPart"] = "GUI configuration",
         ["configIntroWarningPart"] = "Warnings configuration",
         ["configIntroNameplatePart"] = "Nameplates configuration",
         ["configIntroVersionPart"] = "Version check",

         ["configIntroRingButtonExplain"] = "Below is the DTM ring button. You can drag it anywhere and then click on it to directly open DTM config menu.",
         ["configIntroRingButtonMoving"] = "You are moving the ring button. Release the mouse button once you have found the appropriate spot for it.",
         ["configIntroRingButtonReset"] = "The ring button is now set. If you made a mistake, click on the button below to set its position again.",

         -- 2. Engine panel

         ["configEngineTitle"] = "Engine settings",
         ["configEngineSubTitle"] = "You can set here how you'd like DTM engine to behave.",

         ["configEngineEnable"] = "Enable engine",
         ["configEngineEnableCaption"] = "|cffff2020The engine is currently switched off.|r\nThreat data is not available.",
         ["configEngineDisable"] = "Disable engine",
         ["configEngineDisableCaption"] = "|cff20ff20The engine is currently switched on.|r\nDisabling it will prevent threat data from being computed.",
         ["configEnginePaused"] = "|cffffff20Temporarily halted.|r\nThe engine will re-enable itself automatically.",
         ["configEngineEmergencyStop"] = "|cffff2020Emergency stop is enabled.|r\nDisable it to reactivate the engine.",

         ["configEngineNotEmulable"] = "DTM cannot emulate it, as the real %s is running.",

         ["configEngineNPCEdit"] = "Edit NPCs",

         ["configAggroDelaySlider"] = "Aggro change delay",
         ["configZoneWideCheckRateSlider"] = "Zone-wide combat check interval",
         ["configTPSUpdateRateSlider"] = "TPS update rate",
         ["configDetectReset"] = "Clean up the database regularly",

         ["configWorkMethod"] = "Work method",
         ["configWorkMethodAnalyze"] = "Analyze",
         ["configWorkMethodHybrid"] = "Hybrid",
         ["configWorkMethodNative"] = "Native",

         ["configEngineEmulation"] = "Emulation settings",
         ["configEmuEnable"] = "Enable emulation",
         ["configEmuSpoof"] = "Spoof version",

         ["configTooltipWorkMethodAnalyze"] = "Determinate threat values by using solely combat log informations. In this setting the threat shown can and will be inaccurate. This was the pre-WotLK way to determinate threat data.",
         ["configTooltipWorkMethodHybrid"] = "Determinate threat values by using both combat log and Blizzard native threat meter. This setting is the most CPU intensive but it yields lots of threat data whose accuracy is quite good. Sudden changes in threat values displayed can occur because native threat meter recalibrates inaccurate results from combat parsing.",
         ["configTooltipWorkMethodNative"] = "Determinate threat values by using solely Blizzard native threat meter. This setting does not give good threat data about units that do not belong to your party or raid, but gives exact threat values and is the fastest.",
         -- ["configTooltipWorkMethodOnlyInBeta"] = "|cffa0a0a0This method can only be used on WotLK Beta test client.|r\n\n",

         ["configTooltipAggroDelayExplain"] = "This slider sets how much time DTM will wait before considering the NPC has changed its real aggro target when it switches between targets.",
         ["configTooltipZoneWideCheckRateExplain"] = "Sets the interval of time there is before DTM checks if nearby raid members have entered zone-wide combat. Lower values decrease overall performances but make sure the raid members are added at once in enemies' threat lists.",
         ["configTooltipTPSUpdateRateExplain"] = "You can adjust here how often you want TPS to be updated. Updates occuring more often might produce slowdowns in heavy fights.",
         ["configTooltipDetectResetExplain"] = "When enabled, this option allows DTM to erase threat lists' content of out-of-combat creatures that are not tagged nor targetting anyone. It also allows DTM to erase data of creatures we haven't heard anything about for 600 sec.",
         ["configTooltipEmulationExplain"] = "DTM is able to emulate partially the engine of other threat meter AddOns. This allows these AddOns to get threat data about you from DTM.",
         ["configTooltipSpoofExplain"] = "In addition to normal emulation feature, DTM can make the other members of your party believe you are running the specified emulated AddOn, by answering version requests.",

         -- 3. GUI panel

         ["configGUITitle"] = "Graphical User Interface settings",
         ["configGUISubTitle"] = "You can set here how DTM should present you threat lists.",

         ["configGUIEnable"] = "Enable GUI",
         ["configGUIEnableCaption"] = "|cffff2020The GUI is currently switched off.|r\nThreat lists' display is disabled.",
         ["configGUIDisable"] = "Disable GUI",
         ["configGUIDisableCaption"] = "|cff20ff20The GUI is currently switched on.|r\nDisabling it will prevent threat lists' display.",
         ["configGUIPaused"] = "|cffffff20Temporarily halted.|r\nThe GUI will re-enable itself automatically.",
         ["configGUIEmergencyStop"] = "|cffff2020Emergency stop is enabled.|r\nDisable it to reactivate the GUI.",

         ["configGUIAutoDisplay"] = "Auto-display condition",
         ["configGUIAutoDisplayTarget"] = "Target threat list",
         ["configGUIAutoDisplayFocus"] = "Focus threat list",
         ["configGUIAutoDisplayOverview"] = "Overview list",
         ["configGUIAutoDisplayRegain"] = "Regain list",
         ["configGUIAutoDisplayAlways"] = "Always",
         ["configGUIAutoDisplayOnChange"] = "On change",
         ["configGUIAutoDisplayOnJoin"] = "On grouping",
         ["configGUIAutoDisplayOnCombat"] = "On combat",
         ["configGUIAutoDisplayNever"] = "Never",

         ["configTooltipAutoDisplayAlways"] = "Allows this threat list to be always displayed by default.",
         ["configTooltipAutoDisplayNever"] = "Prevents this threat list to be displayed by default.",
         ["configTooltipAutoDisplayOnChange"] = "Displays this threat list when you set your focus.",
         ["configTooltipAutoDisplayOnJoin"] = "Displays this threat list when you join a group.",
         ["configTooltipAutoDisplayOnCombat"] = "Displays this threat list when you enter combat.",

         -- 4. System panel

         ["configSystemTitle"] = "System settings",
         ["configSystemSubTitle"] = "You can modify here general DTM options that affect both engine and GUI.",

         ["configSystemEnable"] = "Resume",
         ["configSystemEnableCaption"] = "|cffff2020The emergency stop is currently enabled.|r\nThe engine and the GUI are halted.",
         ["configSystemDisable"] = "STOP",
         ["configSystemDisableCaption"] = "|cff20ff20The emergency stop is currently disabled.|r",

         ["configSystemAlwaysEnabled"] = "Always allows DTM to run",
         ["configSystemQuickConfig"] = "Quick configuration",
         ["configSystemBindings"] = "DTM special bindings",
         ["configSystemErrorLog"] = "Error log",

         ["configSystemManagementHeader"] = "Saved data management",

         ["configSystemModifiedProfile"] = "Profile affected by options modifications:",
         ["configSystemResetSavedVars"] = "Reset DTM configuration",
         ["configSystemResetNPCData"] = "Reset NPC database",
         ["configSystemResetAll"] = "Reset everything",

         ["configTooltipAlwaysEnabledExplain"] = "When ticked, DTM will continue to run even if you're in a battleground or arena, a taxi, an inn, a capital city or a sanctuary.",
         ["configTooltipQuickConfigExplain"] = "This button allows you to quickly configure DTM according to the role you are performing currently.",
         ["configTooltipModifiedProfileExplain"] = "If you select this, character-specific changes made to DTM options will affect |cff20ff20%s (%s)|r profile.\n\n|cffff0000WARNING|r - If you click option panels will be refreshed and unsaved changes will be lost.",
         ["configTooltipResetSavedVarsExplain"] = "Clicking on this button will reset all configuration data. Skins will remain unchanged. Interface will be immediately reloaded.",
         ["configTooltipResetNPCDataExplain"] = "Clicking on this button will reset the NPC database, which contains their special abilities and behaviour. Default data will be restored.",
         ["configTooltipResetAllExplain"] = "Clicking on this button will clear any DTM saved data, including config and skins. This button is the last solution if you experience problems with DTM. Interface will be immediately reloaded.",

         -- 5. Version panel

         ["configVersionTitle"] = "About version",
         ["configVersionSubTitle"] = "You can check here your version number and ask the other party members to send theirs.",

         ["configVersionYours"] = "You are using |cffffffff%s|r version of DiamondThreatMeter.",

         ["configVersionQuery"] = "Request version",
         ["configVersionQueryBusy"] = "|cffffff00The system is currently busy.|r",
         ["configVersionQueryFlood"] = "|cffffff00Please wait a moment.|r",
         ["configVersionQueryNotGrouped"] = "|cffff8000You can only only request version number when you are in a group.|r",
         ["configVersionQueryOK"] = "|cff00ff00Ready to request version number.|r",
         ["configVersionQueryResults"] = "Results of version query:",

         ["configVersionDTMFormat"] = "|cff00ff00DTM|r |cffffffffv%s|r",
         ["configVersionOtherFormat"] = "|cffffa000%s|r |cffffffff%s|r",
         ["configVersionNoneFormat"] = "|cffffffff%s|r",

         -- 6. Warning panel

         ["configWarningTitle"] = "Advanced warnings configuration",
         ["configWarningSubTitle"] = "You can set here when, where and how DTM should warn you when you're about to pull aggro from a dangerous enemy.",

         ["configWarningExplain110"] = "- When going above |cffffff20110%|r of NPC target's threat, you'll regain aggro if you are in melee range.",
         ["configWarningExplain130"] = "- When going above |cffff2020130%|r of NPC target's threat, you'll regain aggro.",
         ["configWarningLimit"] = "Margin before being warned",
         ["configWarningCancelLimit"] = "Margin to cancel",
         ["configWarningPosition"] = "Position setting",
         ["configWarningHorizontal"] = "Horizontal",
         ["configWarningLeft"] = "Left",
         ["configWarningRight"] = "Right",
         ["configWarningVertical"] = "Vertical",
         ["configWarningUp"] = "Up",
         ["configWarningDown"] = "Down",
         ["configWarningEnablePreview"] = "Enable preview",
         ["configWarningDisablePreview"] = "Disable preview",

         ["configWarningToggle"] = "Use warnings",

         ["configWarningThreshold"] = "Warning threshold",
         ["configWarningBossTag"] = "Boss NPC",
         ["configWarningEliteTag"] = "Elite NPC",
         ["configWarningNormalTag"] = "Normal NPC",
         ["configWarningLevelTag"] = "lev.",
         ["configWarningAndMoreTag"] = "and more",
         ["configWarningClassification"] = "Displays warnings against |cffff2020%s|r.",
         ["configWarningClassificationAndLevel"] = "Displays warnings against |cffff2020%s|r that has a level difference with you of |cffff2020%s%s|r and above.",

         ["configWarningSound"] = "Warning sound",
         ["sound:NONE"] = "None",
         ["sound:WEIRD"] = "Weird",
         ["sound:BUZZER"] = "Buzzer",
         ["sound:PEASANT"] = "Peasant (War3)",
         ["sound:ALARM"] = "Alarm",

         ["configTooltipWarningExplain"] = "If enabled, you'll be warned when you're about to pull aggro from a fierce monster (any NPC that matches the warning threshold). Tanks will certainly want to disable this option.\n\nAlso note that there are special rules set in DTM that will force the warning bar to stay hidden or be forcefully shown for some NPCs regardless of your settings.",
         ["configTooltipWarningLimitExplain"] = "This slider allows you to change the margin you have before triggering the warning. For instance, if you set 20% and you are in melee range, this means warning will get triggered above 110 - 20 = 90%.",
         ["configTooltipWarningCancelLimitExplain"] = "This slider allows you to change the margin you have to create before a bar in warning mode stops being in warning mode. For instance, if you set 30% and you are in melee range, this means warning will stop if you get under 110 - 30 = 80%.",
         ["configTooltipPreviewExplain"] = "This button allows you to toggle a special bar which shows where bars in warning mode would go to on your screen. This allows you to precisely position them using sliders above. It also allows you to hear the warning sound you have chosen.",

         -- 7. Nameplates panel

         ["configNameplateTitle"] = "Nameplates configuration",
         ["configNameplateSubTitle"] = "You can set here if you want DTM to also show your threat above enemies' nameplates.",

         ["configNameplateExplain"] = "CAUTION - This functionality is currently experimental and cannot distinguish between enemies holding the same name. If there is an ambiguity, DTM will not display threat data above the nameplate.",
         ["configNameplateToggle"] = "Enable threat display",
         ["configTooltipNameplateExplain"] = "Tick this box in order to display your threat toward nearby enemies above their nameplate.\n\n|cffff0000Please note that when several enemies sharing the same name are engaged in combat, DTM will NOT be able to display their threat above their name.|r",

         -- 8. Skin manager frame

         ["configSkinManagerHeader"] = "Skin Manager",

         ["configSkinManagerTagBase"] = " |cff00ff00(base skin)|r",
         ["configSkinManagerTagUser"] = " |cff2020ff(user-defined skin)|r",

         ["configSkinManagerExplain"] = "Skins are settings that define how DTM should look like. To create your own skin, you must copy an existing skin and modify it.",
         ["configSkinManagerExplainLocked"] = "The manager is currently locked and you have to close the skin editor before you can use it again.",
         ["configSkinManagerExplainBaseSkin"] = "This is a base skin. These skins can be modified, but not deleted or renamed. They can be restored to their original version.",
         ["configSkinManagerExplainUserSkin"] = "This is an user-defined skin. They can be renamed, deleted, modified but not restored.",
         ["configSkinManagerExplainSelectionAppend"] = "\n\nClick to select this skin for the current profile.",

         ["configSkinManagerSelection"] = "Skin selected:",
         ["configSkinManagerRename"] = "Rename",
         ["configSkinManagerRestore"] = "Restore",
         ["configSkinManagerCopy"] = "Copy",
         ["configSkinManagerDelete"] = "Delete",
         ["configSkinManagerToEditor"] = "Send to the skin editor",

         ["configSkinManagerCopyForm"] = "You're about to copy the skin |cff00ff00%s|r.\nWhat name will you give to the copy?",
         ["configSkinManagerRenameForm"] = "You're about to rename the skin |cff00ff00%s|r.\nWhat new name will you give to it?",
         ["configSkinManagerRestoreForm"] = "You're about to restore the base skin |cff00ff00%s|r.\nAre you sure you want to do that?",
         ["configSkinManagerDeleteForm"] = "You're about to delete the skin |cff00ff00%s|r.\nAre you sure you want to do that?",

         -- 9. Skin editor frame

         ["configSkinEditorPreview"] = "Preview",
         ["configSkinEditorFinish"] = "Finish",
         ["configSkinEditorCategory"] = "Category %d / %d",

         -- Skin schema translation

         -- 1. Categories

         ["skinSchema-General"] = "General",
         ["skinSchema-Animation"] = "Animation",
         ["skinSchema-ThreatList"] = "Threat list",
         ["skinSchema-OverviewList"] = "Overview list",
         ["skinSchema-RegainList"] = "Regain list",
         ["skinSchema-Display"] = "Display",
         ["skinSchema-Bars"] = "Bars",
         ["skinSchema-Columns"] = "Columns",
         ["skinSchema-RegainColumns"] = "Columns (regain)",
         ["skinSchema-Text"] = "Text",

         -- 2. Labels

         ["skinSchema-Length"] = "Length",
         ["skinSchema-Alpha"] = "Alpha",
         ["skinSchema-Scale"] = "Scale",
         ["skinSchema-ShortFigures"] = "Shorten figures",
         ["skinSchema-LockFrames"] = "Lock position of lists",

         ["skinSchema-OnlyHostile"] = "Only display hostile NPCs",
         ["skinSchema-AlwaysDisplaySelf"] = "Always show self",
         ["skinSchema-DisplayAggroGain"] = "Add aggro regain tag",
         ["skinSchema-RaiseAggroToTop"] = "Raise to top aggro target",
         ["skinSchema-DisplayLevel"] = "Display level",
         ["skinSchema-DisplayHealth"] = "Display health",
         ["skinSchema-Filter"] = "Filter",
         ["skinSchema-CursorTexture"] = "Cursor texture",
         ["skinSchema-Rows"] = "Max number of rows",

         ["skinSchema-BackdropUseTile"] = "The background uses the tile mode",
         ["skinSchema-TileTexture"] = "Background texture",
         ["skinSchema-EdgeTexture"] = "Edge texture",
         ["skinSchema-WidgetTexture"] = "Widget texture",
         ["skinSchema-WidgetPositionX"] = "Widget X position",
         ["skinSchema-WidgetPositionY"] = "Widget Y offset",

         ["skinSchema-BackgroundTexture"] = "Base texture",
         ["skinSchema-FillTexture"] = "Fill texture",
         ["skinSchema-ShowSpark"] = "Show the spark",
         ["skinSchema-Smooth"] = "Smoothen bars' variations",
         ["skinSchema-FadeCoeff"] = "Fade animation duration coeff",
         ["skinSchema-SortCoeff"] = "Sort animation duration coeff",
         ["skinSchema-AggroGraphicEffect"] = "Graphic effect when one has aggro",

         ["skinSchema-Class"] = "Class",
         ["skinSchema-Name"] = "Name",
         ["skinSchema-Threat"] = "Threat",
         ["skinSchema-TPS"] = "Threat Per Second",
         ["skinSchema-Percentage"] = "Percentage",
         ["skinSchema-Relative"] = "Who ?",

         -- 3. Values

         ["skinSchema-Filter-All"] = "All",
         ["skinSchema-Filter-Party"] = "Party",
         ["skinSchema-Filter-PartyPlayer"] = "Party (players)",

         -- 4. Tooltips

         ["skinSchema-Length-Tooltip"] = "Sets the effective width (in pixels) used by the bars in threat, overview and regain lists. If you use a value that's too short, there won't be enough room for some texts.",
         ["skinSchema-Alpha-Tooltip"] = "This slider allows you to change the display alpha of threat lists.",
         ["skinSchema-Scale-Tooltip"] = "This slider allows you to change the display scale of threat lists.",
         ["skinSchema-ShortFigures-Tooltip"] = "When enabled, this option will shorten threat value figures. 10455 for instance will become 10.5k.",
         ["skinSchema-LockFrames-Tooltip"] = "This options prevents you from moving frames by dragging them with the left mouse button.",

         ["skinSchema-OnlyHostile-Tooltip"] = "If ticked, only threat lists from hostile NPCs will be displayed.",
         ["skinSchema-AlwaysDisplaySelf-Tooltip"] = "This option allows you to be *always* visible on whatever threat list you are involved in, even if you're too far away in the list.",
         ["skinSchema-DisplayAggroGain-Tooltip"] = "When enabled, this option adds one additionnal threshold row in threat lists. Going above this threshold row means you'll probably pull aggro from the concerned NPC.",
         ["skinSchema-RaiseAggroToTop-Tooltip"] = "Allows you to place on the top of the threat list the aggro target of the NPC. It's better to disable this option for NPCs that switch targets a lot.",
         ["skinSchema-DisplayLevel-Tooltip"] = "Allows you to display the NPC's level on threat lists.",
         ["skinSchema-DisplayHealth-Tooltip"] = "Enable this option to display a little health bar below the NPC infos.",
         ["skinSchema-CursorTexture-Tooltip"] = "This field allows you to change the cursor image. The cursor is what shows your position in threat lists.",
         ["skinSchema-Rows-Tooltip"] = "This slider allows you to choose the max number of rows that can be displayed at once in a threat list. High values will undoubtedly lessen your PC's performances.",

         ["skinSchema-BackdropUseTile-Tooltip"] = "Tick this if the background uses a tile system (squares that repeat themselves as much as necessary to fill in the background).",
         ["skinSchema-TileTexture-Tooltip"] = "You can specify here the image file to use for the background of lists.",
         ["skinSchema-EdgeTexture-Tooltip"] = "You can specify here the image file to use for the edges of lists.",
         ["skinSchema-WidgetTexture-Tooltip"] = "You can provide a little image file here (32x32 dots) which will be displayed on the top border of lists.",
         ["skinSchema-WidgetPositionX-Tooltip"] = "You can adjust the X position of the widget with this slider.",
         ["skinSchema-WidgetPositionY-Tooltip"] = "You can adjust the Y offset of the widget with this slider.",

         ["skinSchema-BackgroundTexture-Tooltip"] = "You can specify here the image file to use as the base texture of bars.",
         ["skinSchema-FillTexture-Tooltip"] = "You can specify here the image file to use as the filling texture of bars.",
         ["skinSchema-ShowSpark-Tooltip"] = "When ticked, this option displays a spark on bars.",
         ["skinSchema-Smooth-Tooltip"] = "A purely aesthetic option. If you want a very responsive and clear display, you should disable this option.",
         ["skinSchema-FadeCoeff-Tooltip"] = "This slider allows to change the rate at which fades effects of threat lists perform. x0.5 for instance doubles the speed.",
         ["skinSchema-SortCoeff-Tooltip"] = "This slider allows yo change the rate at which animations of threat lists' rows occur. x0.5 for instance doubles the speed.",
         ["skinSchema-AggroGraphicEffect-Tooltip"] = "This option allows you to add a graphic effect on the bar that has the aggro of an enemy.",

         ["skinSchema-Filter-All-Tooltip"] = "Everything on threat lists will be displayed, including players or NPCs outside your group.",
         ["skinSchema-Filter-Party-Tooltip"] = "Only players or pets that are in your group will be displayed on threat lists.",
         ["skinSchema-Filter-PartyPlayer-Tooltip"] = "Only players (excluding pets) that are in your group will be displayed.",
    },

    ["frFR"] = {
         ["Unknown"] = "Inconnu",
         ["Invalid"] = "Invalide",
         ["Sec"] = "sec",
         ["AlteracValley"] = "Vallée d'Alterac",
         ["RankCapture"] = "Rang (%d+)",
         ["Foo"] = "Machin",
         ["Bar"] = "Truc",
         ["Enabled"] = "Actif",
         ["Position"] = "Position",
         ["Justification"] = "Justification",
         ["LeftShort"] = "G",
         ["CenterShort"] = "C",
         ["RightShort"] = "D",
         ["Erase"] = "Effacer",
         ["Auto"] = "Automatique",
         ["Top"] = "Haut",
         ["Center"] = "Centre",
         ["Bottom"] = "Bas",

         ["VersionQueryTimeOut"] = "Pas de réponse",
         ["VersionQueryDisconnected"] = "Déconnecté(e)",

         -- Console localisation

         ["Boot"] = "DiamondThreatMeter chargé et prêt. |cff8080ff(v%s)|r\n/DTM pour afficher une liste des commandes.",
         ["SavedVariablesBadVersion"] = "Les paramètres de configuration ne sont plus compatibles avec cette version. Les paramètres vont être remis par défaut.",
         ["SkinsBadVersion"] = "Le système de skins n'est plus compatible. Les paramètres vont être remis par défaut.",
         ["SkinsVersionUpgrade"] = "Le système de skins a été amélioré vers une nouvelle version. Vos skins ont pu être adaptés vers cette nouvelle version.",
         ["ProfileRegistered"] = "Le profil de <%s> a été créé.",
         ["NPCAbilitiesUpdated"] = "|cffffff00%d|r PNJ ont été mis à jour dans la base de données de DTM.",
         ["NPCAbilitiesReset"] = "La base de données des PNJ a été réinitialisée. Les PNJ prédéfinis ont été restorés.",
         ["CheckSavedVariablesReset"] = "Êtes-vous sûr(e) de vouloir réinitialiser complétement la configuration de DTM?\n\nVotre interface sera rechargée.",
         ["CheckNPCDatabaseReset"] = "Êtes-vous sûr(e) de vouloir réinitialiser la base de données des PNJ?\n\nLa base de données par défaut sera remise en place.",
         ["CheckAllReset"] = "Êtes-vous sûr(e) de vouloir EFFACER TOUTE DONNEE sauvegardée par DTM, incluant la config et les skins? L'Addon se comportera comme si elle était lancée pour la première fois.\n\nTapez |cffff0000EFFACER|r pour confirmer.\n\nVotre interface sera rechargée.",
         ["VersionCheckReminder"] = "Nous vous recommandons d'effectuer une vérification de version et de regarder si une version plus récente de DTM est disponible.\n\nVoulez-vous que DTM le fasse pour vous maintenant?",

         ["FirstRunWelcome"] = "Ceci est la première fois que |cff00ff00DiamondThreatMeter |cff6060ffv%s|r est lancé sur ce client WoW.\n\nVous pouvez accéder aux commandes slash de l'AddOn avec |cff00ff00/DTM|r et modifier sa configuration dans |cffffff00les menus interface et raccourcis de WoW|r.",
         ["FirstRunWelcomeBeta"] = "Ceci est la première fois que |cff00ff00DiamondThreatMeter |cff6060ffv%s|r est lancé sur ce client WoW |cffffff00Bêta|r.\n\nNotez que DTM est en cours de développement pour l'extension WotLK. Beaucoup de valeurs de menace sont actuellement incorrectes et seront corrigées dans les versions futures.",
         ["FunctionalityNotImplementedYet"] = "Désolé! Cette fonctionnalité, |cffffff00%s|r, n'est pas encore implementée! Veuillez attendre une future version.",
         ["OpenOptions"] = "Ouvrir options",
         ["RoleSelection"] = "Veuillez taper le rôle que vous remplissez actuellement:\n|cff00ff40Tank | Dégâts | Zoneur\nSoigneur | Solo avec familier|r\n\nAprès avoir fait votre choix, les options appropriées seront automatiquement réglées pour vous.",
         ["RoleTank"] = "Tank",
         ["RoleTankMatches"] = "tank|chucknorris|chuck norris",
         ["RoleDamageDealer"] = "Infligeur de dégâts",
         ["RoleDamageDealerMatches"] = "dégâts|degats|dps",
         ["RoleAoEer"] = "Dégâts de zone",
         ["RoleAoEerMatches"] = "zoneur|zone|aoe|pbaoe",
         ["RoleHealer"] = "Soigneur",
         ["RoleHealerMatches"] = "soigneur|soin|heal|healer",
         ["RolePet"] = "Solo avec familier",
         ["RolePetMatches"] = "familier|solo avec familier",
         ["RoleSelected"] = "Vous avez sélectionné |cff00ff00%s|r.\n\nSi vous changez de rôle entre-temps, pensez à changer la configuration de DTM pour l'adapter à votre nouveau rôle.\n\nLes listes de menace n'apparaissent par défaut que lorsque vous êtes groupé.",

         ["EmergencyStopDisabled"] = "|cff40ff40L'arrêt d'urgence a été désactivé.|r";
         ["EmergencyStopEnabled"] = "|cffff4040L'arrêt d'urgence a été activé.|r\nEntrez /DTM basculer pour réenclencher l'AddOn.";

         ["NotifyEngineDisabled"] = "Le moteur de DTM est pour le moment désactivé. Allez dans les options d'interface pour le réactiver.",
         ["NotifyGUIDisabled"] = "L'interface graphique de DTM est pour le moment désactivée. Allez dans les options d'interface pour la réactiver.",

         ["ConsoleBadSyntax"] = "Mauvaise syntaxe pour cette commande slash. Essayez :\n",
         ["ConsoleUnknown"] = "Vous avez entré une commande inconnue. Suggestions:\n",
         ["ConsoleBroken"] = "La commande n'a pas pu être exécutée, alors qu'elle aurait dû. Peut être que vous n'avez pas l'AddOn DTM complète.",

         ["TestNoTalent"] = "Aucun talent n'a été trouvé pour %s. Peut être que ce n'est pas un PJ.",
         ["TestCannotQueryTalents"] = "Impossible d'obtenir les talents actifs de %s. Vérifiez que ce personnage est bien un joueur, attendez un instant ou essayez de vous rapprocher.",
         ["TestQueryTalentsFired"] = "Obtention en cours des talents de %s...",
         ["TestQueryTalentsError"] = "La réquisition des talents de %s a échoué. Peut être qu'un AddOn ou l'écran d'inspection de Blizzard a interféré avec DTM.",
         ["TestTalentDB"] = "%d talents ont été trouvés dans la base de données de DTM pour %s :",
         ["TestTalentDBRow"] = "%d. %s",
         ["TestTalentRank"] = "|cff8080ff%s|r [%s] Rang |cffffff00%d/%d|r",
         ["TestNoPCAbility"] = "%s est un PJ. Les PJ ne peuvent pas avoir de capacités spéciales innées.",
         ["TestNoNPCAbility"] = "Aucune capacité de modification de la menace n'a été trouvée sur le PNJ %s.",
         ["TestNPCAbility"] = "%d capacités de modification de la menace ont été trouvées sur le PNJ %s:",
         ["TestNPCAbilityRow"] = "%d. |cffffff00%s|r",
         ["TestNoAssociationErrors"] = "Pas d'erreurs d'association ont été enregistrées. Peut-être que la fonctionnalité d'enregistrement est désactivée dans le fichier de script LUA.",
         ["TestAssociationErrors"] = "%d erreurs d'association ont été enregistrées :",
         ["TestAssociationErrorsRow"] = "%d. |cffffff00%s|r",
         ["TestGearThreatMultiplier"] = "Multiplicateur de menace des objets: |cff00ff00x%.3f|r",
         ["TestSets"] = "Voici les ensembles d'armures trouvés pour %s :",
         ["TestSetsRow"] = "|cffffff00%s|r %d/%d",
         ["TestListNumber"] = "DTM a des infos concernant %d entités :",
         ["TestListRow"] = "%d. %s (%s)",
         ["TestListThreatListNumber"] = "    La liste de menace de %s contient %d entités :",
         ["TestListThreatListRow"] = "    %d. %s (%s) [%d]",
         ["TestVersionSent"] = "Requête envoyée pour obtention des versions de DTM utilisées...",
         ["TestVersionErrorUnknown"] = "Une erreur s'est produite en voulant envoyer le test de version.",
         ["TestVersionErrorFlood"] = "Veuillez attendre un instant avant d'envoyer un test de version.",
         ["TestVersionErrorNotGrouped"] = "Vous n'êtes pas dans un groupe, le test de version est inutile.",
         ["TestVersionResults"] = "Résultats du test de version:",
         ["TestVersionResultsRow"] = "%d. %s %s |cffffff00[%s]|r",
         ["TestTalentsBufferNumber"] = "La mémoire tampon des talents a enregistré %d entités :",
         ["TestTalentsBufferRow"] = "%d. %s (%d talents enregistrés)",
         ["TestItemsBufferNumber"] = "La mémoire tampon des objets a enregistré %d entités :",
         ["TestItemsBufferRow"] = "%d. %s (%d objets équippés)",

         ["ResetEntityData"] = "Toutes les données concernant la menace ont été réinitialisées.",

         ["ErrorInCombat"] = "Une erreur classifiée comme %s s'est produite au sein de DTM. Le rapport d'erreur apparaîtra lorsque vous aurez quitté le mode combat.",
         ["ErrorPosition"] = "Erreur %d sur %d",
         ["ErrorHeader"] = "Erreur %d - Type: %s, module: |cff4040ff%s|r\n|cffffffffMessage d'erreur:|r",
         ["ErrorHeaderNoError"] = "Aucune erreur n'a été rencontrée pour le moment.",
         ["ErrorType:MINOR"] = "|cff00ff00Mineure|r",
         ["ErrorType:MAJOR"] = "|cffff8000Majeure|r",
         ["ErrorType:CRITICAL"] = "|cffff0000Critique|r",

         -- Threat, overview, regain lists localisation

         ["guiHeader"] = "DiamondThreatMeter v%s",

         ["Name"] = "Nom",
         ["Threat"] = "Menace",
         ["TPS"] = "MPS",
         ["Relative"] = "Qui ?",

         ["unitInfo"] = "%s Niveau %s %s",
         ["unitInfoLight"] = "%s %s",
         ["noThreatList"] = "|cffffa000Ce PNJ n'utilise pas de liste de menace.|r",

         ["aggroRegain"] = "|cffff4040Reprise|r",
         ["aggroRegainClose"] = "|cffff8020Reprise (CàC)|r",

         ["standbyTarget"] = "Pas de PNJ sélectionné.",
         ["standbyTargetWrongReaction"] = "Ce PNJ n'est pas hostile.",
         ["standbyTargetDead"] = "Votre cible est |cffff4040morte|r.",
         ["standbyTargetOpening"] = "Ouverture de la liste de menace...",
         ["standbyFocus"] = "Pas de PNJ défini en focus.",
         ["standbyFocusWrongReaction"] = "Ce PNJ n'est pas hostile.",
         ["standbyFocusDead"] = "Votre focus est |cffff4040mort|r.",
         ["standbyFocusOpening"] = "Ouverture de la liste de menace...",

         ["overviewNoUnit"] = "Unité inconnue.",
         ["overviewOpening"] = "Ouverture de la liste de présence...",
         ["overviewUnitInfo"] = "Vue d'ensemble (%s)",

         ["regainNoUnit"] = "Unité inconnue.",
         ["regainOpening"] = "Ouverture de la liste de reprise...",
         ["regainUnitInfo"] = "Reprise d'attention (%s)",

         ["test"] = "Test",
         ["testList"] = "Ceci est une liste de test.",

         ["tankToggle"] = "Est un tank",
         ["tankToggleTooltip"] = "Ce bouton permet de spécifier si cette unité est un tank ou non. Les tanks sont indiqués avec une icône spéciale au lieu de l'icône de classe.",

         ["anchorSetting"] = "Point d'attache",
         ["anchorSettingTooltip"] = "Vous pouvez préciser ici comment vous souhaitez que la liste soit attachée à l'interface. La liste s'étendra dans la direction opposée du point d'attache.",

         -- Configuration frame localisation

         -- 0. Overall

         ["configEngineCategory"] = "Moteur",
         ["configGUICategory"] = "IUG",
         ["configSystemCategory"] = "Système",
         ["configWarningCategory"] = "Avertissements",
         ["configNameplateCategory"] = "Plaques",
         ["configVersionCategory"] = "Version",

         -- 1. Intro panel

         ["configIntroTitle"] = "Bienvenue dans la configuration de DTM !",
         ["configIntroSubTitle"] = "Depuis ce panneau vous pouvez accéder aux autres panneaux de configuration de DTM.",

         ["configIntroSystemPart"] = "Configuration du système",
         ["configIntroEnginePart"] = "Configuration du moteur",
         ["configIntroGUIPart"] = "Configuration de l'IUG",
         ["configIntroWarningPart"] = "Configuration des alertes",
         ["configIntroNameplatePart"] = "Configuration des plaques",
         ["configIntroVersionPart"] = "Vérification de version",

         ["configIntroRingButtonExplain"] = "Voici le bouton raccourci de DTM. Vous pouvez le déplacer n'importe où et par la suite cliquer dessus pour accéder au menu de DTM.",
         ["configIntroRingButtonMoving"] = "Vous êtes en train de déplacer le bouton raccourci. Relâchez le bouton de la souris une fois que vous avez trouvé l'emplacement approprié.",
         ["configIntroRingButtonReset"] = "Le bouton raccourci est maintenant réglé. Si vous avez commis une erreur, cliquez sur le bouton en-dessous pour recommencer le positionnement.",

         -- 2. Engine panel

         ["configEngineTitle"] = "Paramètres du moteur",
         ["configEngineSubTitle"] = "Vous pouvez régler ici comment vous souhaiteriez que le moteur de DTM se comporte.",

         ["configEngineEnable"] = "Activer moteur",
         ["configEngineEnableCaption"] = "|cffff2020Le moteur est pour l'instant coupé.|r\nLes données de menace ne sont pas disponibles.",
         ["configEngineDisable"] = "Couper moteur",
         ["configEngineDisableCaption"] = "|cff20ff20Le moteur est actif.|r\nLe couper empêchera le calcul des données concernant la menace.",
         ["configEnginePaused"] = "|cffffff20Temporairement arrêté.|r\nLe moteur se réactivera de lui-même automatiquement.", 
         ["configEngineEmergencyStop"] = "|cffff2020L'arrêt d'urgence est enclenché.|r\nDésactivez-le pour réactiver le moteur.",

         ["configEngineNotEmulable"] = "DTM ne peut pas l'émuler, car le véritable %s est en cours d'exécution.",

         ["configEngineNPCEdit"] = "Editer PNJ",

         ["configAggroDelaySlider"] = "Délai de ciblage",
         ["configZoneWideCheckRateSlider"] = "Fréquence de vérif. de combat",
         ["configTPSUpdateRateSlider"] = "Fréquence de recalcul de la MPS",
         ["configDetectReset"] = "Nettoyage régulier de la base de données",

         ["configWorkMethod"] = "Méthode de travail",
         ["configWorkMethodAnalyze"] = "Analyse",
         ["configWorkMethodHybrid"] = "Hybride",
         ["configWorkMethodNative"] = "Native",

         ["configEngineEmulation"] = "Paramètres de l'émulation",
         ["configEmuEnable"] = "Activer émulation",
         ["configEmuSpoof"] = "Leurrer version",

         ["configTooltipWorkMethodAnalyze"] = "Détermine la menace en se basant uniquement sur les informations du journal de combat. Dans cette configuration, la menace affichée sera inévitablement imprécise. Il s'agit de la méthode utilisée avant l'extension WotLK pour calculer la menace.",
         ["configTooltipWorkMethodHybrid"] = "Détermine la menace en se basant à la fois sur le journal de combat et le mètre de menace natif de Blizzard. Cette méthode est la plus gourmande en processeur mais elle offre davantage de données relativement précises. Des changements soudains dans les valeurs de menace affichées peuvent se produire car le mètre natif recalibre les résultats imprécis obtenus par analyse du journal de combat.",
         ["configTooltipWorkMethodNative"] = "Détermine la menace en utilisant uniquement le mètre de menace natif de Blizzard. Cette méthode ne donne pas de bonnes informations concernant les unités extérieures à votre groupe. En revanche, les chiffres donnés pour les membres du groupe ou raid sont exacts et cette méthode est la plus rapide.",
         -- ["configTooltipWorkMethodOnlyInBeta"] = "|cffa0a0a0Cette méthode ne peut être employée que sur le client de jeu Bêta de WotLK.|r\n\n",

         ["configTooltipAggroDelayExplain"] = "Cette option permet de demander à DTM d'attendre un certain délai avant de considérer que la \"vraie\" cible d'un PNJ a changé quand celui-ci change de cible. En effet, les PNJ peuvent utiliser des attaques secondaires ne concernant pas forcément leur \"vraie\" cible.",
         ["configTooltipZoneWideCheckRateExplain"] = "Cette vérification permet de déterminer quand les membres du raid proches ont engagé le combat avec des ennemis. Un délai bas entre chaque vérification diminue les performances mais permet de s'assurer que les membres du raid soient ajoutés immédiatement dans les listes de menace des ennemis.",
         ["configTooltipTPSUpdateRateExplain"] = "Cette glissière vous permet de choisir l'intervalle de temps qui se passe entre chaque mise à jour de la MPS. Des intervalles plus courts peuvent entraîner des ralentissements dans les combats importants.",
         ["configTooltipDetectResetExplain"] = "Quand activée, cette option autorise DTM à effacer le contenu des listes de menaces des créatures hors-combat, n'ayant pas de cible et n'étant pas marquées. Elle permet également à DTM d'effacer les données concernant des créatures pour lesquelles nous n'avons eu aucune information durant 600 secondes.",
         ["configTooltipEmulationExplain"] = "DTM est capable de simuler partiellement le fonctionnement d'un autre AddOn de mesure de la menace. Ceci permet à ces AddOns d'obtenir des infos concernant votre niveau de menace et les utiliser.",
         ["configTooltipSpoofExplain"] = "En plus de la simulation du fonctionnement, DTM peut aussi, si vous le souhaitez, faire croire aux membres de votre groupe que vous avez bel et bien installé l'AddOn émulé, en répondant aux requêtes de version.",

         -- 3. GUI panel

         ["configGUITitle"] = "Options de l'Interface Utilisateur Graphique",
         ["configGUISubTitle"] = "Vous pouvez régler ici comment DTM vous présentera les listes de menace.",

         ["configGUIEnable"] = "Activer l'IUG",
         ["configGUIEnableCaption"] = "|cffff2020L'IUG est pour l'instant coupée.|r\nL'affichage des listes de menace est arrêté.",
         ["configGUIDisable"] = "Couper l'IUG",
         ["configGUIDisableCaption"] = "|cff20ff20L'IUG est pour l'instant active.|r\nLa désactiver coupera l'affichage des listes de menace.",
         ["configGUIPaused"] = "|cffffff20Temporairement arrêtée.|r\nL'IUG se réactivera d'elle-même automatiquement.", 
         ["configGUIEmergencyStop"] = "|cffff2020L'arrêt d'urgence est enclenché.|r\nDésactivez-le pour réactiver l'IUG.",

         ["configGUIAutoDisplay"] = "Condition d'affichage auto",
         ["configGUIAutoDisplayTarget"] = "Liste de menace de la cible",
         ["configGUIAutoDisplayFocus"] = "Liste de menace du focus",
         ["configGUIAutoDisplayOverview"] = "Vue d'ensemble",
         ["configGUIAutoDisplayRegain"] = "Reprise d'attention",
         ["configGUIAutoDisplayAlways"] = "Toujours",
         ["configGUIAutoDisplayOnChange"] = "Sur changement",
         ["configGUIAutoDisplayOnJoin"] = "Sur groupage",
         ["configGUIAutoDisplayOnCombat"] = "Sur combat",
         ["configGUIAutoDisplayNever"] = "Jamais",

         ["configTooltipAutoDisplayAlways"] = "Permet à cette liste de menace d'être toujours affichée par défaut.",
         ["configTooltipAutoDisplayNever"] = "Empêche cette liste de menace d'être affichée par défaut.",
         ["configTooltipAutoDisplayOnChange"] = "Affiche cette liste de menace lorsque vous définissez un focus.",
         ["configTooltipAutoDisplayOnJoin"] = "Affiche cette liste de menace quand vous rejoignez un groupe.",
         ["configTooltipAutoDisplayOnCombat"] = "Affiche cette liste de menace quand vous passez en combat.",

         -- 4. System panel

         ["configSystemTitle"] = "Paramètres du système",
         ["configSystemSubTitle"] = "Vous pouvez modifier ici des options générales qui affectent à la fois le moteur et l'IUG.",

         ["configSystemEnable"] = "Reprendre",
         ["configSystemEnableCaption"] = "|cffff2020L'arrêt d'urgence est pour l'instant activé.|r\nLe moteur et l'IUG sont arrêtés.",
         ["configSystemDisable"] = "STOP",
         ["configSystemDisableCaption"] = "|cff20ff20L'arrêt d'urgence est pour l'instant désactivé.|r",

         ["configSystemAlwaysEnabled"] = "Toujours autoriser le fonctionnement",
         ["configSystemQuickConfig"] = "Configuration rapide",
         ["configSystemBindings"] = "Raccourcis spéciaux de DTM",
         ["configSystemErrorLog"] = "Journal des erreurs",

         ["configSystemManagementHeader"] = "Gestion de la sauvegarde des données",

         ["configSystemModifiedProfile"] = "Profil concerné par les modifications d'options:",
         ["configSystemResetSavedVars"] = "Réinitialiser la config de DTM",
         ["configSystemResetNPCData"] = "Réinitialiser les données des PNJ",
         ["configSystemResetAll"] = "Réinitialiser tout",

         ["configTooltipAlwaysEnabledExplain"] = "Quand coché, DTM continuera de fonctionner même lorsque vous êtes en champ de bataille ou arène, sur un taxi, dans une auberge, une capitale ou un sanctuaire.",
         ["configTooltipQuickConfigExplain"] = "Ce bouton vous permet de configurer rapidement DTM d'après le rôle que vous remplissez actuellement.",
         ["configTooltipModifiedProfileExplain"] = "Si vous selectionnez ceci, les changements faits aux options de DTM n'affectant qu'un personnage s'appliqueront pour le profil de |cff20ff20%s (%s)|r.\n\n|cffff0000ATTENTION|r - Si vous cliquez, les panneaux d'options vont être raffraichis et les changements non sauvegardés seront perdus.",
         ["configTooltipResetSavedVarsExplain"] = "Cliquer sur ce bouton réinitialisera toutes les données de configuration. L'interface sera immédiatement rechargée.",
         ["configTooltipResetNPCDataExplain"] = "Cliquer sur ce bouton réinitialisera toutes les données concernant les particularités et capacités spéciales des PNJ. Les données par défaut seront remises en place.",
         ["configTooltipResetAllExplain"] = "Cliquer sur ce bouton supprimera toute donnée sauvegardée par DTM, incluant la config et les skins. Ce bouton est la dernière solution si vous avez des problèmes pour faire marcher DTM. L'interface sera immédiatement rechargée.",

         -- 5. Version panel

         ["configVersionTitle"] = "A propos de la version",
         ["configVersionSubTitle"] = "Vous pouvez vérifier ici votre numéro de version et demander aux autres membres du groupe d'envoyer le leur.",

         ["configVersionYours"] = "Vous utilisez la version |cffffffff%s|r de DiamondThreatMeter.",

         ["configVersionQuery"] = "Demander",
         ["configVersionQueryBusy"] = "|cffffff00Le système est pour l'instant occupé.|r",
         ["configVersionQueryFlood"] = "|cffffff00Veuillez patienter un moment.|r",
         ["configVersionQueryNotGrouped"] = "|cffff8000Vous ne pouvez demander le numéro de version que lorsque vous vous trouvez dans un groupe.|r",
         ["configVersionQueryOK"] = "|cff00ff00Prêt à demander le numéro de version.|r",
         ["configVersionQueryResults"] = "Résultats de la requête:",

         ["configVersionDTMFormat"] = "|cff00ff00DTM|r |cffffffffv%s|r",
         ["configVersionOtherFormat"] = "|cffffa000%s|r |cffffffff%s|r",
         ["configVersionNoneFormat"] = "|cffffffff%s|r",

         -- 6. Warning panel

         ["configWarningTitle"] = "Configuration avancée des avertissements",
         ["configWarningSubTitle"] = "Vous pouvez configurer ici quand, où et comment DTM vous avertira en cas de risque de reprise d'attention d'un ennemi redoutable.",

         ["configWarningExplain110"] = "- Quand on atteint |cffffff20110%|r de la menace de la cible d'un PNJ, on reprend l'attention de ce PNJ si on se trouve à portée de mêlée.",
         ["configWarningExplain130"] = "- Quand on atteint |cffff2020130%|r de la menace de la cible d'un PNJ, on reprend l'attention de ce PNJ.",
         ["configWarningLimit"] = "Marge avant d'être averti",
         ["configWarningCancelLimit"] = "Marge pour désactiver",
         ["configWarningPosition"] = "Positionnement",
         ["configWarningHorizontal"] = "Horizontal",
         ["configWarningLeft"] = "Gauche",
         ["configWarningRight"] = "Droite",
         ["configWarningVertical"] = "Vertical",
         ["configWarningUp"] = "Haut",
         ["configWarningDown"] = "Bas",
         ["configWarningEnablePreview"] = "Prévisualisation",
         ["configWarningDisablePreview"] = "Stopper",

         ["configWarningToggle"] = "Utiliser avertissements",

         ["configWarningThreshold"] = "Conditions d'avertissement",
         ["configWarningBossTag"] = "PNJ Boss",
         ["configWarningEliteTag"] = "PNJ Elite",
         ["configWarningNormalTag"] = "PNJ Normal",
         ["configWarningLevelTag"] = "niv.",
         ["configWarningAndMoreTag"] = "et plus",
         ["configWarningClassification"] = "Affiche les avertissements contre tout |cffff2020%s|r.",
         ["configWarningClassificationAndLevel"] = "Affiche les avertissements contre tout |cffff2020%s|r qui a une différence de niveau avec vous de |cffff2020%s%s|r et plus.",

         ["configWarningSound"] = "Son d'avertissement",
         ["sound:NONE"] = "Aucun",
         ["sound:WEIRD"] = "Etrange",
         ["sound:BUZZER"] = "Buzzer",
         ["sound:PEASANT"] = "Paysan (War3)",
         ["sound:ALARM"] = "Alarme",

         ["configTooltipWarningExplain"] = "Si activés, vous serez averti lorsque vous serez sur le point d'attirer l'attention d'un monstre redoutable (tout PNJ remplissant les conditions d'avertissement). Les tanks préféreront sans doute désactiver cette option.\n\nNotez que des règles spéciales sont définies dans DTM pour certains PNJ qui forcent la barre d'avertissement à rester cachée ou à apparaître quelle que soit la configuration choisie.",
         ["configTooltipWarningLimitExplain"] = "Cette glissière vous permet de changer la marge que vous vous autorisez avant d'être averti. Par exemple, si vous choisissez 20% et que vous êtes à portée de mêlée, cela signifie que l'avertissement sera enclenché à partir de 110 - 20 = 90%.",
         ["configTooltipWarningCancelLimitExplain"] = "Cette glissière vous permet de changer la marge que vous devez créer pour qu'une barre en mode d'avertissement cesse de l'être. Par exemple, si vous choisissez 30% et que vous êtes à portée de mêlée, cela signifie que l'avertissement cessera lorsque vous descendrez en dessous de 110 - 30 = 80%.",
         ["configTooltipPreviewExplain"] = "Ce bouton vous permet d'activer une barre spéciale vous indiquant où les barres en mode d'avertissement se placeront sur votre écran. Cela vous permet de les positionner avec précision en utilisant les glissières au-dessus. Il vous permet également d'entendre le son d'avertissement que vous avez choisi.",

         -- 7. Nameplates panel

         ["configNameplateTitle"] = "Configuration des plaques de nom",
         ["configNameplateSubTitle"] = "Vous pouvez choisir ici si vous voulez que DTM affiche également votre menace au dessus des plaques de nom des ennemis.",

         ["configNameplateExplain"] = "ATTENTION - Cette fonctionnalité est pour l'instant présente à titre expérimental et ne peut faire la distinction entre des ennemis portant le même nom. Si une ambiguïté se présente, DTM ne prendra pas le risque d'afficher des informations erronées, et donc n'affichera rien.",
         ["configNameplateToggle"] = "Activer l'affichage de la menace",
         ["configTooltipNameplateExplain"] = "Cochez pour que votre menace envers les ennemis proches soit affichée au dessus de leur nom.\n\n|cffff0000Notez que lorsque plusieurs ennemis portant le même nom sont engagés, DTM ne pourra PAS afficher la menace au dessus de leur nom.|r",

         -- 8. Skin manager frame

         ["configSkinManagerHeader"] = "Gestionnaire de skins",

         ["configSkinManagerTagBase"] = " |cff00ff00(skin de base)|r",
         ["configSkinManagerTagUser"] = " |cff2020ff(skin de l'utilisateur)|r",

         ["configSkinManagerExplain"] = "Les skins sont des ensembles de paramètres définissant l'apparence de DTM. Pour créer votre propre skin, vous devez copier une skin existante et la modifier.",
         ["configSkinManagerExplainLocked"] = "Le gestionnaire est pour l'instant verrouillé et vous devez fermer l'éditeur de skin avant de pouvoir le réutiliser.",
         ["configSkinManagerExplainBaseSkin"] = "Ceci est une skin de base. Ces skins peuvent être modifiées mais pas supprimées ou renommées. En outre, elles peuvent être restorées dans leur état original.",
         ["configSkinManagerExplainUserSkin"] = "Ceci est une skin définie par l'utilisateur. Ces skins peuvent être renommées, supprimées, modifiées mais pas restorées.",
         ["configSkinManagerExplainSelectionAppend"] = "\n\nCliquez pour sélectionner cette skin pour le profil actif.",

         ["configSkinManagerSelection"] = "Skin sélectionnée:",
         ["configSkinManagerRename"] = "Renommer",
         ["configSkinManagerRestore"] = "Restorer",
         ["configSkinManagerCopy"] = "Copier",
         ["configSkinManagerDelete"] = "Supprimer",
         ["configSkinManagerToEditor"] = "Envoyer à l'éditeur de skin",

         ["configSkinManagerCopyForm"] = "Vous allez faire une copie du skin |cff00ff00%s|r.\nQuel nom voulez-vous lui donner?",
         ["configSkinManagerRenameForm"] = "Vous allez renommer le skin |cff00ff00%s|r.\nQuel nouveau nom voulez-vous lui donner?",
         ["configSkinManagerRestoreForm"] = "Vous allez restorer le skin de base |cff00ff00%s|r.\nConfirmez-vous cette action?",
         ["configSkinManagerDeleteForm"] = "Vous allez supprimer le skin |cff00ff00%s|r.\nConfirmez-vous cette action?",

         -- 9. Skin editor frame

         ["configSkinEditorPreview"] = "Prévisualisation",
         ["configSkinEditorFinish"] = "Terminer",
         ["configSkinEditorCategory"] = "Catégorie %d / %d",

         -- Skin schema translation

         -- 1. Categories

         ["skinSchema-General"] = "Général",
         ["skinSchema-Animation"] = "Animation",
         ["skinSchema-ThreatList"] = "Liste de menace",
         ["skinSchema-OverviewList"] = "Vue d'ensemble",
         ["skinSchema-RegainList"] = "Liste de reprise",
         ["skinSchema-Display"] = "Affichage",
         ["skinSchema-Bars"] = "Barres",
         ["skinSchema-Columns"] = "Colonnes",
         ["skinSchema-RegainColumns"] = "Colonnes (reprise)",
         ["skinSchema-Text"] = "Texte",

         -- 2. Labels

         ["skinSchema-Length"] = "Longueur",
         ["skinSchema-Alpha"] = "Transparence",
         ["skinSchema-Scale"] = "Echelle",
         ["skinSchema-ShortFigures"] = "Raccourcir les nombres",
         ["skinSchema-LockFrames"] = "Verrouiller la position des listes",

         ["skinSchema-OnlyHostile"] = "Afficher seulement les PNJ hostiles",
         ["skinSchema-AlwaysDisplaySelf"] = "Etre toujours visible soi-même",
         ["skinSchema-DisplayAggroGain"] = "Placer l'indicateur de reprise",
         ["skinSchema-RaiseAggroToTop"] = "Monter en haut de liste la cible du PNJ",
         ["skinSchema-DisplayLevel"] = "Afficher le niveau",
         ["skinSchema-DisplayHealth"] = "Afficher la vie",
         ["skinSchema-Filter"] = "Filtre",
         ["skinSchema-CursorTexture"] = "Texture du curseur",
         ["skinSchema-Rows"] = "Nombre max de lignes",

         ["skinSchema-BackdropUseTile"] = "Le fond utilise le mode mosaïque",
         ["skinSchema-TileTexture"] = "Texture du fond",
         ["skinSchema-EdgeTexture"] = "Texture des bords",
         ["skinSchema-WidgetTexture"] = "Texture du gadget",
         ["skinSchema-WidgetPositionX"] = "Position du gadget X",
         ["skinSchema-WidgetPositionY"] = "Décalage du gadget Y",

         ["skinSchema-BackgroundTexture"] = "Texture de base",
         ["skinSchema-FillTexture"] = "Texture de remplissage",
         ["skinSchema-ShowSpark"] = "Montrer le séparateur",
         ["skinSchema-Smooth"] = "Lisser les variations des barres",
         ["skinSchema-FadeCoeff"] = "Coeff de durée d'animation de fondu",
         ["skinSchema-SortCoeff"] = "Coeff de durée d'animation de tri",
         ["skinSchema-AggroGraphicEffect"] = "Effet graphique quand on a l'attention d'un PNJ",

         ["skinSchema-Class"] = "Classe",
         ["skinSchema-Name"] = "Nom",
         ["skinSchema-Threat"] = "Menace",
         ["skinSchema-TPS"] = "Menace Par Seconde",
         ["skinSchema-Percentage"] = "Pourcentage",
         ["skinSchema-Relative"] = "Qui ?",

         -- 3. Values

         ["skinSchema-Filter-All"] = "Tous",
         ["skinSchema-Filter-Party"] = "Groupe",
         ["skinSchema-Filter-PartyPlayer"] = "Groupe (joueurs)",

         -- 4. Tooltips

         ["skinSchema-Length-Tooltip"] = "Permet de régler la longueur effective utilisée par les barres dans les listes (en pixels). Si vous utilisez une valeur trop faible, il n'y aura pas assez de place pour certains textes.",
         ["skinSchema-Alpha-Tooltip"] = "Cette glissière permet de changer la transparence des listes de menace.",
         ["skinSchema-Scale-Tooltip"] = "Cette glissière permet de changer l'échelle d'affichage des listes de menace.",
         ["skinSchema-ShortFigures-Tooltip"] = "Quand activée, cette option permet de raccourcir les nombres affichés dans la colonne ''Menace''. 10455 par exemple deviendra 10.5k.",
         ["skinSchema-LockFrames-Tooltip"] = "Cette option vous empêche de déplacer les listes en maintenant le bouton gauche de la souris enfoncé et en la bougeant.",

         ["skinSchema-OnlyHostile-Tooltip"] = "Si cochée, cette option ne montrera que le contenu des listes de menace des PNJ hostiles.",
         ["skinSchema-AlwaysDisplaySelf-Tooltip"] = "Cette option vous permet de *toujours* vous voir sur les listes de menace dans lesquelles vous êtes impliqué, même si vous êtes trop bas dans la liste.",
         ["skinSchema-DisplayAggroGain-Tooltip"] = "Quand activée, cette option place un seuil spécial dans les listes de menaces. Dépasser ce seuil implique un très gros risque de reprise d'attention du PNJ concerné.",
         ["skinSchema-RaiseAggroToTop-Tooltip"] = "Vous permet de placer au sommet de la liste de menace la personne qui a l'attention du PNJ. Mieux vaut désactiver cette option pour les PNJ qui changent souvent de cible.",
         ["skinSchema-DisplayLevel-Tooltip"] = "Vous permet d'afficher le niveau du PNJ sur les listes de menace. Néanmoins notez que le texte sera tronqué pour les PNJ ayant un nom trop long.",
         ["skinSchema-DisplayHealth-Tooltip"] = "Activez cette option pour afficher une petite barre de vie sous les infos du PNJ.",
         ["skinSchema-CursorTexture-Tooltip"] = "Vous permet de changer l'apparence du curseur indiquant votre position dans les listes de menace.",
         ["skinSchema-Rows-Tooltip"] = "Cette glissière permet de déterminer le nombre de lignes affichables simultanément dans une liste de menace. Un nombre trop élevé réduirait sans aucun doute les performances de votre PC.",

         ["skinSchema-BackdropUseTile-Tooltip"] = "Cochez cette option si le fond est constitué de carrés qui se répétent autant que nécessaire pour le remplir.",
         ["skinSchema-TileTexture-Tooltip"] = "Vous pouvez spécifier ici le fichier image à utiliser pour le fond des listes.",
         ["skinSchema-EdgeTexture-Tooltip"] = "Vous pouvez spécifier ici le fichier image à utiliser pour les bords des listes.",
         ["skinSchema-WidgetTexture-Tooltip"] = "Vous pouvez spécifier ici un petit fichier image (32x32 pixels) qui sera affiché sur la bordure supérieure des listes.",
         ["skinSchema-WidgetPositionX-Tooltip"] = "Vous pouvez ajuster la position horizontale du gadget avec cette glissière.",
         ["skinSchema-WidgetPositionY-Tooltip"] = "Vous pouvez ajuster le décalage vertical du gadget avec cette glissière.",

         ["skinSchema-BackgroundTexture-Tooltip"] = "Vous pouvez indiquer ici le fichier image à utiliser pour les contours des barres.",
         ["skinSchema-FillTexture-Tooltip"] = "Vous pouvez indiquer ici le fichier image à utiliser pour le contenu des barres.",
         ["skinSchema-ShowSpark-Tooltip"] = "Quand cochée, cette option affiche un séparateur lumineux sur les barres.",
         ["skinSchema-Smooth-Tooltip"] = "Une option d'ordre purement esthétique. Si vous souhaitez un affichage très net et immédiat, mieux vaut désactiver cette option.",
         ["skinSchema-FadeCoeff-Tooltip"] = "Cette glissière permet de faire varier la vitesse de fondu des listes de menace et de leur contenu. x0.5 double par exemple la vitesse.",
         ["skinSchema-SortCoeff-Tooltip"] = "Cette glissière permet de faire varier la vitesse d'animation du contenu des listes de menace. x0.5 double par exemple la vitesse.",
         ["skinSchema-AggroGraphicEffect-Tooltip"] = "Vous permet d'ajouter un effet graphique sur les barres des personnes ayant l'attention d'un PNJ.",

         ["skinSchema-Filter-All-Tooltip"] = "Tout ce qui se trouve dans les listes de menace sera affiché, joueurs et PNJ en dehors de votre groupe inclus.",
         ["skinSchema-Filter-Party-Tooltip"] = "Seuls les joueurs ou familiers au sein de votre groupe seront affichés sur les listes de menace.",
         ["skinSchema-Filter-PartyPlayer-Tooltip"] = "Seuls les joueurs (familiers exclus) au sein de votre groupe seront affichés sur les listes de menace.",
    },
};

-- --------------------------------------------------------------------
-- **                    Localisation functions                      **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Localise(key, noError)                                       *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> key: what to localise. If not found on the correct locale,    *
-- * will use default value. If there is no default value, this       *
-- * function will return formatted DTM_MISSING_TRANSLATION.          *
-- * >> noError: if set and the localisation is not available, this   *
-- * function will return nil instead of missing translation.         *
-- ********************************************************************

function DTM_Localise(key, noError)
    local locale = DTM_Locale[GetLocale()];
    local defaultlocale = DTM_Locale["default"];

    if ( locale ) and ( locale[key] ) then
        return locale[key];
  else
        if ( defaultlocale ) and ( defaultlocale[key] ) then
            return defaultlocale[key];
        end
    end

    if ( noError ) then return nil; end

    DTM_ThrowError("MINOR", activeModule, string.format('Translation for "%s" is missing (%s language).', key, GetLocale()));
    return string.format(DTM_MISSING_TRANSLATION, key);
end

-- ********************************************************************
-- * DTM_Unlocalise(translation)                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> translation: translation thing to unlocalise.                 *
-- * If there is an error, <translation> value will be returned.      *
-- ********************************************************************

function DTM_Unlocalise(translation)
    local locale = DTM_Locale[GetLocale()];
    local defaultlocale = DTM_Locale["default"];
    local k, t;

    if ( locale ) then
        for k, t in pairs(locale) do
            if ( t == translation ) then
                return k;
            end
        end
    end

    if ( defaultlocale ) then
        for k, t in pairs(defaultlocale) do
            if ( t == translation ) then
                return k;
            end
        end
    end

    DTM_ThrowError("MINOR", activeModule, string.format('Couldn\'t unlocalise "%s" translation (%s language).', translation, GetLocale()));
    return translation;
end