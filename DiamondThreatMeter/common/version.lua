local activeModule = "Version";

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @ Version History                            ( X.Y.ZZ : X > Major ; Y > Minor ; ZZ > Revision )
-- @ -------------------------------------------------------------------------------------------------------------------------------------------------------
-- @
-- @ PRE-RELEASE (0.Y.ZZ)
-- @
-- @ 0.X.0____________________First builds of the DTM project. I worked internally.
-- @
-- @ 0.9.0____________________The first build that I think mature enough to make my guild test it.
-- @
-- @ 0.9.1____________________Fixed some nasty bugs and other dumb things I've forgotten, such as improved blessing of salvation not being recognized.
-- @                          Also, welcome popups will now show a button to open option frame for you.
-- @                          Slash command /DTM options <engine/gui/version> has been added.
-- @                          Some code improvements were done, and the engine is now slightly faster.
-- @
-- @ 0.9.2____________________Functions of CoolLib that are called really often by DTM have undergone nice optimizations, resulting in a real speed boost
-- @                          engine side. Also, the engine now sorts itself the threat lists as they evolve. Threat list API functions will now then submit
-- @                          the new sorted data. Taunts handling could be made much more robust now thanks also to CoolLib functions improvements.
-- @                          Hunters' feign death should be now detectable if the hunter runs DTM.
-- @                          Also, the last change but not the least, PALADINS' taunt is now handled quite reliably !
-- @
-- @ 0.9.3____________________Bars should now sort between one another more nicely. ThreatLib2 is now emulated ! Emulation is now forcefully
-- @                          disabled if you are running what's emulated. Aggro detection has been reworked and extended.
-- @                          Improvements to the NPC abilities module will increase a bit performances of DTM.
-- @                          Non-hunters, non-warlocks will no longer send their attack power stat on the network, only AP of pets will be submitted now.
-- @                          The last fix but not the least, Imp. Righteous Fury of paladins is now correctly taken in account.
-- @
-- @ 0.9.4____________________Entity database management was upgraded, resulting in better performances of the engine.
-- @                          Now the time limit before deleting data of an entity we haven't heard anything about has been reduced to 600 sec.
-- @                          Also, data of entities that have an empty threat list will be deleted after 60 sec.
-- @                          Fixed an error that would occur if one uses LibStub but not ThreatLib2. 
-- @                          An additionnal option panel was added (GUI 2) which allows users to customize even further the GUI.
-- @                          This panel contains currently two sliders, enabling the user to change the scale or the alpha.
-- @
-- @ 0.9.5____________________Introduction of "presence lists" in the engine made it cleaner to compute heals threat and increased the engine performance.
-- @                          New APIs regarding "presence lists" have been added.
-- @                          Now melee hits performed is an additionnal way for the engine to determinate the actor's aggro target.
-- @                          In next versions, thanks to the "presence lists", healers and AoErs will have an "overview" mode
-- @                          which will actually be more useful than plain threat list mode.
-- @
-- @ 0.9.6____________________DTM will now consider that warriors are, when DTM doesn't know, by default in "DEFENSIVE" stance (1.3x threat)
-- @                          instead of "DEFAULT" stance (1.00x threat), which doesn't exist.
-- @                          Symbols will now get displayed in front of entities' names in threat lists. It will have precedence on class display.
-- @
-- @ 0.9.7____________________The first version of overview lists (which use presence list feature) have been implemented !
-- @                          Your overview list can be turned on with a new key binding or in the GUI 2 option panel.
-- @                          It shows all entities that consider you threatening.
-- @                          An unused graphic file has been removed. ^.^

-- @                          
-- @ 0.9.8____________________ThreatLib2 emulation has been slightly optimized thanks to the presence list feature.
-- @                          Fixed some issues with lookup system for entity database.
-- @                          Holy shock should no longer benefit from passive threat reduction when used offensively.
-- @                          A role selection popup has been added, a related command has been added to /DTM options.
-- @                          Fixed a nasty bug about NPC abilities.
-- @                          Bars animation are disabled by default. Many people reported it was dazzling. x)
-- @                          The "safety" delay before the aggro is considered as gained has been finally removed.
-- @                          Special polymorph spells (turtle/pig) are now handled the same way as the standard polymorph.
-- @                          GUI configuration panels have been slightly reorganized.
-- @
-- @ 0.9.9____________________Party members that are possessed or doing damage to one another should not longer add themselves
-- @                          to one another's threat list.
-- @                          Improved significantly talents, items and sets buffers access speed.
-- @                          So, the overall engine speed is nicely upgraded in large raids.
-- @                          Talents affecting Warlock pets threat have been provided.
-- @                          Heals that do not generate threat, such as Imp. Leader of the Pack, is flagged as a "NULL" ability
-- @                          instead of a 0.00x threat ability, to improve performances of the engine.
-- @                          Role popup now accepts alternate inputs. For instance, "damage dealer" now accepts "dd" or "dps".
-- @                          Name display in threat rows have been improved. Now long names should no longer be cut in most cases.
-- @                          It's now possible to set the warning threshold in the GUI panel.
-- @
-- @ 0.9.10___________________Fixed a stupid carelessness that prevented most optimizations performed on previous versions from working...
-- @                          Added The Lightning Capacitor threat effect.
-- @                          Added Shrouding potion threat effect.
-- @                          Threat lists should no longer be on top of most other frames.
-- @                          Improved significantly buff/debuff access speed.
-- @                          Kalecgos's Wild Magic debuff should now be detectable thanks to an extension of the engine and buff detection.
-- @
-- @ 0.9.11___________________Fixed a bug that prevented till now talents from being taken in account ! >.<*
-- @                          Engine and GUI will now be temporarily halted whenever you enter in rest state,
-- @                          in a city, in a PvP instance (beside Alterac Valley) or on a taxi.
-- @                          CoolLib has removed its old combat parsing service, keeping only the new one,
-- @                          resulting in a significant speed boost in large scale battles.
-- @
-- @ 0.9.12___________________Now aggro regain bars have been merged into only 1 bar, which is 110% of aggro target's threat
-- @                          if you are close to the mob, 130% otherwise.
-- @                          Version query will now work even if the engine is disabled or temporarily halted.
-- @                          Fixed an issue with text on threat lists using small font too soon.
-- @                          Fixed a bug which caused "Use warning" option to have no effect whatsoever.
-- @                          CoolLib is no longer needed by DTM to work.
-- @
-- @ 0.9.13___________________Added Lifetap.
-- @                          KTM emulation provided.
-- @                          Emergency stop commands and bindings have been added.
-- @                          DTM can now distinguish between the healing and damaging portion of dual-spells such as Drain life.
-- @                          Consequently, threat of warlocks should be more accurate, as the healing portion of those spells do not generate threat.
-- @                          Drain mana is now flagged as generating no threat.
-- @                          Mouseover units will now be used for aggro and reset determination.
-- @                          Some code upgrades. Maybe this will help in getting not disconnected in case of massive AoE situations with MANY mobs.
-- @                          Reworked feign death detection mechanic.
-- @                          Fixed a typo for Insignifigance (enUS clients only).
-- @                          Fixed a bug introduced in 0.9.6 which prevented the message "This NPC has no threat list" to apparear on relevant NPCs.
-- @                          Entity lists management has been reworked. Once again, it could help in getting not disconnected.
-- @
-- @ 0.9.14___________________Disconnects issues for those that have experienced them should no longer occur because
-- @                          DTM uses now ChatThrottleLib and it should send threat data updates to TL2 and KTM at a more adapted pace.
-- @                          Targetting/focusing a friendly unit which has selected an hostile unit will trigger the
-- @                          display of the threat list of this hostile unit.
-- @                          DTM should no longer gets activated in combat in a PvP or Arena instance.
-- @                          Viper sting has been flagged as causing no threat.
-- @                          Healing threat mechanic has been revised.
-- @                          Fixed Nightbane threat reset for French clients (typo).
-- @                          Fixed Void reaver threat reset for French clients (bad cap).
-- @                          Fixed Blessing of Salvation bug, introduced while optimizing buff searches code.
-- @                          Fixed Tranquil Air totem buff.
-- @                          Added most German internals. DTM will be able soon to work fine with German clients,
-- @                          though the AddOn will be in English for them.
-- @
-- @ 0.9.15___________________All internals are now localised for German client. DTM will work fine with German clients,
-- @                          though the AddOn will be in English for them.
-- @                          /!\ The saved variables system has been changed. This means settings from previous versions will be reset.
-- @                          A profile system has been implemented, which allows most options of the AddOn to be character-specific.
-- @                          Options panels have been redone: version panel is no longer the main panel and
-- @                          an intro panel and a system config panel have been added. Check out the new options and features!
-- @                          Options panels have been reordered in a more logical way.
-- @                          Improved taunt handling in case the mob has no target because it is CCed.
-- @                          Devastate should now grant less threat when the target has less than 5 sunder armor debuff stacked.
-- @                          [Fetish of the Sand Reaver] and [The Eye of Diminution] will now be taken in account properly.
-- @                          Added Fungal Bloom and Seethe debuff effects.
-- @                          Rewritten aggro regain threshold option tooltip.
-- @                          Updated various NPCs in the NPC database.
-- @                          Fixed Life Tap for English clients.
-- @                          Corrected encoding format of internals.lua which was ANSI instead of UTF-8 since 0.9.14, resulting in bad
-- @                          detection of French abilities with accents in their name.
-- @
-- @ 0.9.16___________________GUI 2 panel got renamed Display.
-- @                          Added an option panel which allows the player to extensively configure warnings.
-- @                          Warnings should now be less spammy, as there are now separate thresholds for enabling AND disabling them.
-- @                          Added the lock frames option.
-- @                          "Overheal" for Mana, Rage etc. gains are now discarded whenever possible in threat calculations.
-- @                          Fixed Devastate which couldn't work properly due to a missing internal.
-- @                          Fixed Solarian phase 3 trigger for the French language.
-- @                          The filter introduced in 0.9.9 whose purpose was to prevent party members from adding into one another
-- @                          threat list (for various reasons, such as boss "bombs") has been redone and should no longer ignore some events
-- @                          that should not.
-- @
-- @ RELEASE (1.Y.ZZ)
-- @
-- @ 1.0.0____________________The first "official" release, which contains all the things I originally planed to implement.
-- @                          Standard settings are once again reverted to default ones.
-- @                          The guy who has aggro of an NPC should see his threat bar performing a special lighting effect.
-- @                          Fixed Hydross second phase trigger for the French client.
-- @                          Added aenesthetic poison.
-- @                          Nethermancer Sepethrea boss has been added.
-- @                          "Absorb"s are now considered as abilities that hit successfully for 0 damage and no longer abilities that missed.
-- @                          Fixed a nasty enhance Shaman talent typo (Spirit Weapon instead of Spirit Weapons) that caused serious miscalculations of their threat.
-- @                          Fixed Power Word: Shield, SW:P and SW:D for the French client (weird space chars).
-- @
-- @ 1.0.1____________________You should be now removed correctly of threat lists (and so your overview list should be cleared) when you exit an instance while being in combat.
-- @                          A special procedure that is periodically executed while in a PvE instance should ensure that you are added to the threat list of mobs your
-- @                          party or raid is engaged in combat against. It should be sufficient to allow an accurate determination of the healing threat divider.
-- @                          There is now a new auto-display condition for target and overview lists: On combat.
-- @                          A new preset has been added, for hunters and warlocks and their pets for solo play.
-- @                          "Play sound" option has been replaced by a sound selection dropdown, so you can now choose between different sounds.
-- @                          The preview warning button will now play the warning sound selected.
-- @                          When the emulation of a foreign AddOn is enabled, the emulation module will now be able to request versions, and its results will be
-- @                          displayed in DTM standard version result panel.
-- @
-- @ 1.0.2____________________Fixed a spammy error introduced in 1.0.1.
-- @                          GUI folder of DTM is now completely optionnal. Deleting it will not cause DTM errors, though you won't have a GUI of course.
-- @                          Lifebloom's instant heal portion is now flagged as generating 0 threat. Many people (me included) believed so far that lifebloom's instant portion
-- @                          was generating threat for the heal recipient.
-- @                          The slash command version check will now display the system used, much like the GUI version check.
-- @                          You'll answer version requests even if the engine is turned off.
-- @                          Reduced slightly CPU usage while in combat (Useless gear/talent inspect authorization checks got removed).
-- @                          Optimized talents, gear and sets buffers access speed (=> slightly better processor performances).
-- @                          Greyheart Nether-Mage NPC has been added.
-- @                          Now DTM will no longer ever try to inspect anyone (to get talents and gear) if you have opened the Blizzard Inspect frame.
-- @                          The tooltip of the "Preview" warning button will now state clicking it will allow you to listen to the warning sound
-- @                          you have selected in the sound dropdown.
-- @                          In some rare cases the player who has aggro would fail to be determined. This should be fixed.
-- @                          Combat leave checks have been strengthened.
-- @                          Players will no longer undergo "reset" checks, they should only be used for mobs. This will ensure misdirection effects cast by hunters
-- @                          on other raid members will not be "forgotten" by DTM prior the pull.
-- @
-- @ 1.1.0____________________Skin system is under construction (but still not implemented/functionnal), do not worry about it yet.
-- @                          A third display mode has been added: the Regain list, which now replaces Overview list in the Tank preset.
-- @                          It allows tanks to see, unlike overview list, when they are about to lose aggro.
-- @                          Threat API defined by DTM now accepts GUIDs as input, not only UIDs.
-- @                          Fixed the bug which caused status text in threat lists to be above other frames though it shouldn't.
-- @                          DTM now take in account the fact that you can only pull aggro on some bosses from melee range.
-- @                          UnitThreatFlags(unit) API has been updated to reflect this possibility.
-- @                          The Lurker Below has been added (Its particularity is that ranged DPSers will no longer get warnings).
-- @                          Al'ar description has been changed (now melee DPSers will get warnings, previously ALL warnings were disabled on him).
-- @                          Murmur has been added (Its particularity is that ranged DPSers will no longer get warnings).
-- @                          When mind controls or friendly fire occur, the zone wide aggro mechanism introduced in 1.0.1
-- @                          should no longer add the whole raid in one another's threat list.
-- @                          Leotheras the Blind should now reset threat upon leaving Demon form.
-- @
-- @ 1.2.0____________________When something dies or is destroyed, it will now be flagged for 2 seconds as "recently dead" and anything related to this entity will be ignored.
-- @                          This should make overview/regain lists a bit cleaner and will prevent in some cases dead mobs from coming back in these lists.
-- @                          You can now right-click on a threat/overview/regain list to make a dropdown apparear. It currently has the Close command which simply causes
-- @                          the list to stop being visible. Why don't you submit suggestions to fill up this lil' menu ? :)
-- @                          In case DTM can't know the exact stance a warrior is in currently, DTM will now count the amount of talent points spent in arms/fury trees to
-- @                          guess the stance the warrior *should* be in.
-- @                          UnitThreatListSize, UnitThreatList and UnitThreatGetAggro API now accept "test" as unit parameter, if you do they'll provide testing data.
-- @                          The skin manager is now implemented.
-- @                          The skin editor is now ready !
-- @                          Display option panel has been removed, it's no longer needed.
-- @                          Most options of GUI panel have been removed, they are now implemented in the skin editor.
-- @                          The GUI panel now contain the skin manager.
-- @                          "Transferee" column has been renamed "Who ?" in the regain list.
-- @                          A <Final Fantasy> skin has been made available. :)
-- @
-- @ 1.2.1____________________Void Reaver has been fixed for English language.
-- @                          Warbringer O'mrogg boss has been added.
-- @                          Healing threat calculation has been further improved: mobs that are crowd-controlled no longer get hate from healers while they are.
-- @                          -53% threat reduction on lifebloom HoT portion is now assumed, after doing some testing. Bloom portion still remains at -100% threat.
-- @
-- @ 1.3.0____________________/!\ Due to changes in the skin system, base skins will be restored and user skins deleted.
-- @                          Columns in all types of list are now customizable ! You can hide whichever you want, change their position and justification.
-- @                          A new skin has been added to illustrate these new possibilities: the Diamond Lite skin, which is kinda the Diamond skin small brother. :)
-- @                          Yellow and red portions of bars have been changed to match the color scheme of the explanation bar found in the warning config panel.
-- @                          Error handling has been improved a lot. Errors handlers have been placed at key points, especially on functions that are run on a time basis.
-- @                          A nice and smart (won't bother you in combat) error console will show you errors instead of the ugly Blizzard error box. :)
-- @                          These changes however doesn't mean ALL errors will be handled in the new way, some errors will still be shown in the Blizzard error box.
-- @                          A version check reminder has been put in place.
-- @                          Reflected damaging spells will now grant threat for the character who caused the reflect.
-- @                          Solarian's threat list will no longer be hidden above 20% of her health, and you'll get warnings if you are in melee range.
-- @                          You can now choose to display or not the level of NPCs in threat list frames in the skin editor.
-- @                          You can now choose not to raise the bar of the character who has aggro to the top of the threat list, still in the skin editor; this
-- @                          feature was enforced in all previous versions, it's no longer the case.
-- @                          Swapping anims for bars are once again disabled by default.
-- @
-- @ 1.4.0____________________TPS data is now calculated by the engine.
-- @                          UnitThreatList, UnitPresenceList APIs now return the TPS data calculated by the engine.
-- @                          TPS column is now available !
-- @                          Now upgrades from the skin system should in most cases adapt existing skins to the new skin system without having to delete existing skins.
-- @                          You can specify length of bars for each type of list instead of a global setting that affects all lists.
-- @                          Animation category in the skin editor has been merged with Bars category.
-- @                          You can now display a tiny mob health bar in the threat list category of the skin editor.
-- @                          DTM will no longer compute threat lists of players as it's basically pointless. >.>
-- @                          This will also cause DTM to ignore mind-controlled players (though they act like mobs most of the time) and will prevent pollution of the
-- @                          overview list by the zone-wide combat detection mechanism introduced in the 1.0.1.
-- @                          These changes increase the overall speed of the engine, though the new TPS calculations counterbalance them.
-- @                          Soulshatter should now correctly halve current threat on all engaged mobs that do not resist.
-- @                          A ring button now allow you to open DTM options by clicking on it. You may place it anywhere though it should be next to the minimap cluster. :)
-- @
-- @ 1.4.1____________________/!\ The version of saved variables system has changed. This means settings from previous versions will be reset.
-- @                          Your skins will not be affected, though. Diamond skin will just be selected as the active skin by default on all of your characters.
-- @                          Some old settings of the Engine section are no longer changeable. They have been replaced by more general settings
-- @                          which could help you improve the performances and speed of DTM.
-- @                          Some SSC mobs whose threat data is not relevant (such as totems) will no longer be computed.
-- @
-- @ 1.5.0____________________Threat can now be displayed on nameplates. Check out the new options! There are unfortunately some restrictions on this new system. :/
-- @                          This option can be turned on in a new config panel: "Nameplate".
-- @                          New API: DTM_FindGUIDFromName(name).
-- @                          Various files in docs folder have been updated.
-- @                          The bars of threat list are now right-clickable to make an option dropdown apparear.
-- @                          Currently, this option dropdown allows you to specify whether the unit the bar belongs to is a tank or not.
-- @                          This will cause a tank icon to be displayed in front of the unit. This feature will evolve in further version. :)
-- @                          For the moment, DTM will not remember between game sessions who is and who isn't a tank. It will come in a next version.
-- @                          A "Reset everything" button has been added, it's now the last resort button in case DTM suffers from errors,
-- @                          especially when changing versions.
-- @                          Fixed a bug causing healers not to apparear on threat lists when healing someone engaged against a mob if this healer
-- @                          did not do anything harmful toward any mob engaged in combat (Finally, I got it ! :)).
-- @                          Fixed a bug causing header columns labels to show up despite being disabled in the skin editor.
-- @                          Fixed incorrect positionning of the ring button occuring when using an UI scale different from 1.
-- @
-- @ 1.6.0____________________This build is an hybrid build, which means it can be used on both WoW TBC and WoW WotLK Beta test.
-- @ - HYBRID -               I'm leveling my char in Northrend while figuring out how to implement the threat data given by the new Blizzard APIs, so new features
-- @                          will come at a slower pace.
-- @                          Beta-only changes:
-- @                              * DTM will pull data from Blizzard native threat functions whenever possible.
-- @                              * DTM should however continue to use combat events for threat determination between each value update of Blizzard's threat functions.
-- @                              * Beta players can now find in the Engine panel a dropdown to change the threat calculation method. This reflects what's said above.
-- @                          Fixed some miscellaneous bugs in both Engine and GUI.
-- @                          A few tooltips have been rewritten/corrected.
-- @                          CAUTION: UnitThreat and other DTM threat info APIs are now prefixed with "DTM_" (e.g: DTM_UnitThreat), to avoid conflict if Blizzard adds
-- @                          its own APIs during the Beta phase. Any external mod that could use these functions would have to be modified.
-- @
-- @
-- @
-- @
-- @ Version Convention
-- @ -------------------------------------------------------------------------------------------------------------------------------------------------------
-- @ Major:
-- @   When a complete revamp of DTM system is performed, the major increases by 1 and minor/revision are reset to 0.
-- @   A test version of DTM should always have a major of 0.
-- @   The original DiamondThreatMeter should have a major of 1.
-- @   Systems with different majors are immediately incompatible.
-- @
-- @ Minor:
-- @   Increases when a new functionality is added in DTM. This causes revisions to reset back to 0.
-- @   Systems with different minors are sometimes incompatible.
-- @
-- @ Revision:
-- @   When minor changes/bugfixes to DTM are performed, the revision number should increase by 1, until we have to increase the minor or major by 1,
-- @   in which case the revision number resets back to 0.
-- @   Generally, revision number has no effect on compatibility.
-- @
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local DTM_Version_String = "1.6.0";
local DTM_Version_Major = 1;
local DTM_Version_Minor = 6;
local DTM_Version_Revision = 0;

-- --------------------------------------------------------------------
-- **                       Version functions                        **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_GetVersion()                                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- *  <none>                                                          *
-- ********************************************************************
-- * Returns the major, minor & revision data relevant to our version.*
-- ********************************************************************

function DTM_GetVersion()
    return DTM_Version_Major, DTM_Version_Minor, DTM_Version_Revision;
end

-- ********************************************************************
-- * DTM_GetVersionString()                                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- *  <none>                                                          *
-- ********************************************************************
-- * Returns the version DTM is made for.                             *
-- ********************************************************************

function DTM_GetVersionString()
    return DTM_Version_String;
end

-- The following APIs were taken from one of my other projects, but it's probably unnecessary for DTM itself.

-- ********************************************************************
-- * DTM_IsCompatible(major, minor, revision)                         *
-- ********************************************************************
-- * Arguments:                                                       *
-- * major, minor, revision >> the version of the remote DTM system.  *
-- ********************************************************************
-- * Returns nil if we can't cooperate with remote DTM system.        *
-- * Returns 1 if we can.                                             *
-- ********************************************************************

function DTM_IsCompatible(major, minor, revision)
    local oMajor, oMinor, oRevision = DTM_GetVersion();
    if ( major ~= oMajor ) then return nil; end
    if ( minor ~= oMinor ) then return nil; end
    return 1;
end

-- ********************************************************************
-- * DTM_CompareRemoteVersion(major, minor, revision)                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * major, minor, revision >> the version of the remote DTM system.  *
-- ********************************************************************
-- * Returns 0 if the remote system version is older than ours.       *
-- * Returns 1 if remote system version = ours.                       *
-- * Returns 2 if the remove system version is newer than ours.       *
-- ********************************************************************

function DTM_CompareRemoteVersion(major, minor, revision)
    local oMajor, oMinor, oRevision = DTM_GetVersion();
    if ( major < oMajor ) then return 0; end
    if ( major > oMajor ) then return 2; end
    if ( minor < oMinor ) then return 0; end
    if ( minor > oMinor ) then return 2; end
    if ( revision < oRevision ) then return 0; end
    if ( revision > oRevision ) then return 2; end
    return 1;
end
