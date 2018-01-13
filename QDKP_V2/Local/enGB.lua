-- Copyright 2008 Riccardo Belloli (belloli@email.it)
-- This file is a part of QDKP_V2 (see about.txt in the Addon's root folder)

--        ## ENGLISH-GREAT BRITAIN (enGB) LOCALIZATION ##

--General
QDKP2_LOC_Player="player"
QDKP2_LOC_Net="Net"
QDKP2_LOC_Spent="Spent"
QDKP2_LOC_Total="Total"
QDKP2_LOC_Hours="Hours"
QDKP2_LOC_WinTrigger={"win","wins","won","winner","winning","sold","dkp","points","goes"} --this list is used to detect bids. translate in your language each of the words, plus more if needed

--Warnings
QDKP2_LOC_NotIntoARaid="You are not into a Raid"
QDKP2_LOC_BetaWarning="You are running a beta version of QDKP2.\nShould you find a bug, please report it on\nthe addon's page at CurseGaming.com\nThanks!"
QDKP2_LOC_OldOptFile="The options file of Quick DKP is outdated.\nPlease replace it with the one provided\nin the current version's package."
QDKP2_LOC_BecomedNegative="$NAME's net DKP amount has becomed negative."
QDKP2_LOC_Negative="$NAME's net DKP amount is negative."
QDKP2_LOC_ClearDB="Local database has been cleared"
QDKP2_LOC_Loaded=QDKP2_COLOR_RED.."$VERSION $BETA"..QDKP2_COLOR_WHITE.." Loaded"

--Auto Boss Award
--QDKP2 will use this filter to obtain the name of the killed mob. Adjust it to match
--the message in your client's language (you can read it in the combat log)
QDKP2_LOC_ChatKilledTrig="(.+) dies." 

QDKP2_LOC_Killed="$MOB has been killed!"
QDKP2_LOC_Kill=" kill" --used in the reason of DKP awarding (like 'gains 10 dkp for Onyxia _kill_)

--Loot
--QDKP2 will use these filters to detect the loots. Please adjust it to match
--the message in your client's language
QDKP2_LOC_ChatLootTrig="([^%s]+) receives loot: (.+)%."
QDKP2_LOC_ChatMeLootTrig="You receive loot: (.+)%."

QDKP2_LOC_Loots="Loots $ITEM"
QDKP2_LOC_WinDetect_Q="Do you want to turn on\nthe Winner Detect System?"
QDKP2_LOC_NoRarityInfo="Cannot find rarity info for $ITEM"

--Raid Manager
QDKP2_LOC_IsInRaid="Is in the raid just joined"
QDKP2_LOC_JoinsRaid="Joins the Raid"
QDKP2_LOC_GoesOnline="Returns Online"
QDKP2_LOC_GoesOffline="Goes Offline"
QDKP2_LOC_IsOffline="Is Offline"
QDKP2_LOC_NoInGuild="$NAMES don't seem to be in guild. Skipped"
QDKP2_LOC_LeavedRaid="Leaves the Raid"
QDKP2_LOC_ExtJoins="$NAME has joined the active raid. Removed from standby list."

--IRONMAN BONUS
QDKP2_LOC_Start="Start"
QDKP2_LOC_Finish="Finish"
QDKP2_LOC_FinishWithRaid="The IronMan Bonus has not been closed yet.\nDo you want to close it now?"
QDKP2_LOC_StartButOffline="IronMan bonus started but player is offline"
QDKP2_LOC_IronmanMarkPlaced="IronMan mark placed"
QDKP2_LOC_DataWiped="IronMan Data has been Wiped"

--DKP Modify
QDKP2_LOC_Gains="Gains $GAIN DKP"
QDKP2_LOC_GainsSpends="Gains $GAIN and Spends $SPEND DKP"
QDKP2_LOC_GainsEarns="Gains $GAIN DKP and Earns $HOUR hours"
QDKP2_LOC_GainsSpendsEarns=" Gains $GAIN and Spends $SPEND DKP, Earns $HOUR hours"
QDKP2_LOC_Spends="Spends $SPEND DKP"
QDKP2_LOC_SpendsEarns="Spends $SPEND DKP and Earns $HOUR hours"
QDKP2_LOC_Earns="Earns $HOUR hours"
QDKP2_LOC_ReceivedReas="Online Raid members received $AMOUNT DKP for $REASON"
QDKP2_LOC_Received="Online Raid members received $AMOUNT DKP"
QDKP2_LOC_ZSRecReas="$NAME gives $AMOUNT DKP to the Raid for $REASON"
QDKP2_LOC_ZSRec="$NAME gives $AMOUNT DKP to the Raid"
QDKP2_LOC_RaidAw="[Raid Award] $AWARDSPENDTEXT"
QDKP2_LOC_RaidAwReas="[Raid Award] $AWARDSPENDTEXT for $REASON"
QDKP2_LOC_RaidAwMain="Raid $AWARDSPENDTEXT"
QDKP2_LOC_RaidAwMainReas="Raid $AWARDSPENDTEXT for $REASON"
QDKP2_LOC_ZeroSumSp="Gives $SPENT DKP to the Raid"
QDKP2_LOC_ZeroSumSpReas="Gives $SPENT DKP to the Raid for $REASON"
QDKP2_LOC_ZeroSumAw="Gets $AMOUNT DKP from $GIVER"
QDKP2_LOC_ZeroSumAwReas="Gets $AMOUNT DKP from $GIVER for $REASON"
QDKP2_LOC_ExtMod="$AWARDSPENDTEXT for external editing"
QDKP2_LOC_Generic="$AWARDSPENDTEXT" --those are used in the general case. (eg. manual editing to DKP)
QDKP2_LOC_GenericReas="$AWARDSPENDTEXT for $REASON" 
QDKP2_LOC_NoPlayerInChance="You are trying to modify a player that doesn't exist in local cache."
QDKP2_LOC_MaxNetLimit="$NAME's DKP gain has been limitated because he reached the Maximum Net DKP Cap ($MAXIMUMNET)"
QDKP2_LOC_MaxNetLimitLog="Reaches the Maximum Net DKP Cap"
QDKP2_LOC_MinNetLimit="$NAME's DKP loss has been limitated because he reached the Minimum Net DKP Cap ($MINIMUMNET)"
QDKP2_LOC_MinNetLimitLog="Reaches the Minimum Net DKP Cap"

--lost awards
QDKP2_LOC_Offline="Offline"
QDKP2_LOC_NoRank="UnDKP-able Rank"
QDKP2_LOC_NoZone="Out of Zone"
QDKP2_LOC_ManualRem="Manually excluded"
QDKP2_LOC_LowAtt="Low Presence"
QDKP2_LOC_NetLimit="Net DKP Limit"
QDKP2_LOC_NoDKPRaid="$WHYNOT. Loses award of $AMOUNT DKP"
QDKP2_LOC_NoDKPRaidReas="$WHYNOT. Loses Raid award of $AMOUNT DKP for $REASON"
QDKP2_LOC_NoDKPZS="$WHYNOT. Loses ZeroSum share of $AMOUNT DKP from $GIVER"
QDKP2_LOC_NoDKPZSReas="$WHYNOT. Loses ZeroSum share of $AMOUNT DKP for $REASON"
QDKP2_LOC_NoTick="$WHYNOT. Loses Timer Tick"

--timer
QDKP2_LOC_TimerTick="Timer Tick"
QDKP2_LOC_IntegerTime="Hourly Bonus"
QDKP2_LOC_RaidTimerLog="Timer Tick. Online Raid members award $TIME hours"
QDKP2_LOC_HoursUpdted="Timer Tick"
QDKP2_LOC_TimerStop="Timer stopped"
QDKP2_LOC_TimerResumed="Timer resumed"
QDKP2_LOC_TimerStarted="Timer started"

--upload
QDKP2_LOC_NoMod="No DKP modification have been done since last download/upload"
QDKP2_LOC_SucLocal="Upload Report: $UPLOADED external entries stored in RAM."
QDKP2_LOC_Successful="Upload report: $UPLOADED notes sent. Wait for check..."
QDKP2_LOC_Failed="Upload report: $FAILED haven't been successfull uploaded. Try again in few seconds"
QDKP2_LOC_IndexNoFound="$NAME's guild index cannot be found, skipped. Will try again in a minute"
QDKP2_LOC_IndexNoFoundLog="Has a broken guild cache index (Upload Failed)"

--Externals's DKP Posting
QDKP2_LOC_ExtPost="<QDKP2> External's DKP Amounts"
QDKP2_LOC_ExtLine="$NAME: Net=$NET, Total=$TOTAL, Hours=$HOURS"

--Log
QDKP2_LOC_NewSess="New Session: $SESSIONNAME"
QDKP2_LOC_NoSessName="<noname>"

--download
QDKP2_LOC_NewSessionQ="Enter the name of the New Session"
QDKP2_LOC_NewSession="New Session Started: $SESSIONNAME"
QDKP2_LOC_DifferentTot="$NAME's net+spent is different from the total. Please check"
QDKP2_LOC_NewGuildMember="$NAME added to the Guild Roster as new Member."

--mob kill detection
--put here the die phrase that the given boss says in your client's language
QDKP2_LOC_Romulo="This day's black fate on more days doth depend. This but begins the woe. Others must end."
QDKP2_LOC_Julianne="Where is my Lord? Where is my Romulo? Ohh, happy dagger! This is thy sheath! There rust, and let me die!"
