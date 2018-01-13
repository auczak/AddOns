-- X-Perl UnitFrames
-- Author: Zek <Boodhoof-EU>
-- License: GNU GPL v3, 29 June 2007 (see LICENSE.txt)

local XPerl_Player_Events = {}
local isOutOfControl = nil
local playerClass, playerName
local conf, pconf
XPerl_RequestConfig(function(new) conf = new pconf = conf.player if (XPerl_Player) then XPerl_Player.conf = conf.player end end, "$Revision: 176 $")
local perc1F = "%.1f"..PERCENT_SYMBOL
local percD = "%d"..PERCENT_SYMBOL
local libDruidMana = LibStub and LibStub("LibDruidMana-1.0", true)

local format = format
local GetNumRaidMembers = GetNumRaidMembers
local UnitIsDead = UnitIsDead
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsGhost = UnitIsGhost
local UnitIsAFK = UnitIsAFK
local UnitMana = UnitMana
local UnitManaMax = UnitManaMax
local UnitName = UnitName
local UnitPowerType = UnitPowerType

local XPerl_PlayerStatus_OnUpdate
local XPerl_Player_HighlightCallback

----------------------
-- Loading Function --
----------------------
function XPerl_Player_OnLoad(self)
	XPerl_SetChildMembers(self)
	self.partyid = "player"

	XPerl_BlizzFrameDisable(PlayerFrame)

	CombatFeedback_Initialize(self.hitIndicator.text, 30)

	XPerl_SecureUnitButton_OnLoad(self, "player", XPerl_ShowGenericMenu)
	XPerl_SecureUnitButton_OnLoad(self.nameFrame, "player", XPerl_ShowGenericMenu)

	self:RegisterEvent("VARIABLES_LOADED")

	XPerl_UnitEvents(self, XPerl_Player_Events, {"UNIT_SPELLMISS", "UNIT_FACTION", "UNIT_PORTRAIT_UPDATE",
			"UNIT_FLAGS", "PLAYER_FLAGS_CHANGED", "UNIT_SPELLCAST_SUCCEEDED"})
	XPerl_RegisterBasics(self, XPerl_Player_Events)

	self.EnergyLast = 0
	self.tutorialPage = 2
	self:SetScript("OnUpdate", XPerl_Player_OnUpdate)
	self:SetScript("OnEvent", XPerl_Player_OnEvent)
	self:SetScript("OnShow", XPerl_Unit_UpdatePortrait)
	self.time = 0

	XPerl_RegisterHighlight(self.highlight, 3)
	XPerl_RegisterPerlFrames(self, {self.nameFrame, self.statsFrame, self.levelFrame, self.portraitFrame, self.groupFrame})

	if (XPerl_ArcaneBar_RegisterFrame) then
		XPerl_ArcaneBar_RegisterFrame(self.nameFrame, "player")
	end

	self.FlashFrames = {self.portraitFrame, self.nameFrame, self.levelFrame, self.statsFrame}

	XPerl_RegisterOptionChanger(XPerl_Player_Set_Bits, self)
	XPerl_Highlight:Register(XPerl_Player_HighlightCallback, self)
	--self.IgnoreHighlightStates = {AGGRO = true}

	if (XPerlDB) then
		self.conf = XPerlDB.player
	end

	XPerl_Player_OnLoad = nil
end

-- XPerl_Player_HighlightCallback(updateName)
function XPerl_Player_HighlightCallback(self, updateGUID)
	if (updateGUID == UnitGUID("player")) then
		XPerl_Highlight:SetHighlight(self, updateGUID)
	end
end

-------------------------
-- The Update Function --
-------------------------

local function XPerl_Player_CombatFlash(self, elapsed, argNew, argGreen)
	if (XPerl_CombatFlashSet(self, elapsed, argNew, argGreen)) then
		XPerl_CombatFlashSetFrames(self)
	end
end

-- SetupTickerColour
local function SetupTickerColour(self)
	local t = self.statsFrame.energyTicker
	if (t) then
		local p = UnitPowerType(self.partyid)

		if (p ~= t.type) then
			t.type = p
			if (p == 0) then
				t:Hide()
				t:SetStatusBarColor(0.4, 0.7, 1)
				t.spark:SetVertexColor(0.4, 0.7, 1)
				t:SetMinMaxValues(0, 5)
			else
				t:SetStatusBarColor(1, 1, 0.5)
				t.spark:SetVertexColor(1, 1, 0.5)
				t:SetMinMaxValues(0, 2)
			end
		end
	end
end

-- XPerl_Player_UpdateManaType
local function XPerl_Player_UpdateManaType(self)
	XPerl_SetManaBarType(self)

	if (UnitPowerType(self.partyid) == 3) then
		self.EnergyEnabled = true
		if (self.statsFrame.energyTicker) then
			self.statsFrame.energyTicker.fsrEnabled = nil
		end
	else
		self.EnergyEnabled = nil
	end
	SetupTickerColour(self)
	XPerl_Player_TickerShowHide(self)
end

-- XPerl_Player_UpdateLeader()
function XPerl_Player_UpdateLeader(self)
	local nf = self.nameFrame

	-- Loot Master
	local method, index
	if (UnitInParty("party1") or UnitInRaid("player")) then
		method, index = GetLootMethod()
	end
	if (method == "master" and index == 0) then
		nf.masterIcon:Show()
	else
		nf.masterIcon:Hide()
	end

	-- Leader
	if (IsPartyLeader()) then
		nf.leaderIcon:Show()
	else
		nf.leaderIcon:Hide()
	end

	if (pconf.partyNumber and GetNumRaidMembers() > 0) then
		for i = 1,GetNumRaidMembers() do
			local name, rank, subgroup = GetRaidRosterInfo(i)
			if (UnitIsUnit("raid"..i, "player")) then
				if (pconf.withName) then
					nf.group:SetFormattedText(XPERL_RAID_GROUPSHORT, subgroup)
					nf.group:Show()
					self.groupFrame:Hide()
					return
				else
					self.groupFrame.text:SetFormattedText(XPERL_RAID_GROUP, subgroup)
					self.groupFrame:Show()
					nf.group:Hide()
					return
				end
			end
		end
	end

	nf.group:Hide()
	self.groupFrame:Hide()
end

-- XPerl_Player_UpdateName()
local function XPerl_Player_UpdateName(self)
	playerName = UnitName(self.partyid)
	self.nameFrame.text:SetText(playerName)
end

-- XPerl_Player_UpdateRep
local function XPerl_Player_UpdateRep(self)
	if (pconf.repBar) then
		local rb = self.statsFrame.repBar
		local name, reaction, min, max, value = GetWatchedFactionInfo()
		local color

		if (name) then
			color = FACTION_BAR_COLORS[reaction]
		else
			name = XPERL_LOC_NONEWATCHED
			max = 1
			min = 0
			value = 0
			color = FACTION_BAR_COLORS[4]
		end

		value = value - min
		max = max - min
		min = 0

		rb:SetMinMaxValues(min, max)
		rb:SetValue(value)

		rb:SetStatusBarColor(color.r, color.g, color.b, 1)
		rb.bg:SetVertexColor(color.r, color.g, color.b, 0.25)

		local perc = (value * 100) / max
		rb.percent:SetFormattedText(perc1F, perc)

		if (max == 1) then
			rb.text:SetText(name)
		else
			rb.text:SetFormattedText("%d/%d", value, max)
		end
		--rb.text:SetText(name)
	end
end

-- XPerl_Player_UpdateXP
local function XPerl_Player_UpdateXP(self)
	if (pconf.xpBar) then
		local xpBar = self.statsFrame.xpBar
		local restBar = self.statsFrame.xpRestBar
		local playerxp = UnitXP("player")
		local playerxpmax = UnitXPMax("player")
		local playerxprest = GetXPExhaustion() or 0
		xpBar:SetMinMaxValues(0, playerxpmax)
		restBar:SetMinMaxValues(0, playerxpmax)
		xpBar:SetValue(playerxp)
		local xptext

		if (playerxpmax > 10000) then
			xptext = format("%dK/%dK", playerxp / 1000, playerxpmax / 1000)
		else
			xptext = format("%d/%d", playerxp, playerxpmax)
		end

		if (playerxprest > 0) then
			if (playerxpmax > 10000) then
				xptext = xptext .. format("(+%dK)", playerxprest / 1000)
			else
				xptext = xptext .. format("(+%d)", playerxprest)
			end

			color = {r = 0.3, g = 0.3, b = 1}
		else
			color = {r = 0.6, g = 0, b = 0.6}
		end

		xpBar:SetStatusBarColor(color.r, color.g, color.b, 1)
		xpBar.bg:SetVertexColor(color.r, color.g, color.b, 0.25)

		restBar:SetValue(playerxp + playerxprest)
		restBar:SetStatusBarColor(color.r, color.g, color.b, 0.5)
		restBar.bg:SetVertexColor(color.r, color.g, color.b, 0.5)

		xpBar.text:SetText(xptext)
		xpBar.percent:SetFormattedText(percD, (playerxp * 100) / playerxpmax)
	end
end

-- XPerl_Player_UpdateCombat
local function XPerl_Player_UpdateCombat(self)
	local nf = self.nameFrame
	if (UnitAffectingCombat(self.partyid)) then
		nf.text:SetTextColor(1,0,0)
		nf.combatIcon:SetTexCoord(0.5, 1.0, 0.0, 0.5)
		nf.combatIcon:Show()
	else
		if (UnitIsPVP("player")) then
			nf.text:SetTextColor(0,1,0)
		else
			XPerl_ColourFriendlyUnit(nf.text, "player")
		end

		if (IsResting()) then
			nf.combatIcon:SetTexCoord(0, 0.5, 0.0, 0.5)
			nf.combatIcon:Show()
		else
			nf.combatIcon:Hide()
		end
	end
end

-- XPerl_Player_UpdatePVP
local function XPerl_Player_UpdatePVP(self)
	-- PVP Status settings
	local nf = self.nameFrame
	if (UnitAffectingCombat(self.partyid)) then
		nf.text:SetTextColor(1,0,0)
	elseif (not conf.colour.class and UnitIsPVP("player")) then
		nf.text:SetTextColor(0,1,0)
	else
		XPerl_ColourFriendlyUnit(nf.text, "player")
	end

	if (pconf.pvpIcon and UnitIsPVP("player")) then
		nf.pvpIcon:Show()
		nf.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..UnitFactionGroup("player"))
	else
		nf.pvpIcon:Hide()
	end
end

-- XPerl_Player_DruidBarUpdate
local function XPerl_Player_DruidBarUpdate(self)
	local manaPct
	local druidBar = self.statsFrame.druidBar

	if (libDruidMana) then
		local maxMana = libDruidMana:GetMaximumMana()
		local currMana = libDruidMana:GetCurrentMana()
		manaPct = floor(currMana / maxMana * 100)

		druidBar:SetMinMaxValues(0, maxMana or 1)
		druidBar:SetValue(currMana or 0)
		druidBar.text:SetFormattedText("%d/%d", ceil(currMana or 0), maxMana or 1)

	elseif (SmartyCat) then
		local maxMana = SmartyCat:GetMaxMana()
		local currMana = SmartyCat:GetCurrMana()
		manaPct = SmartyCat:GetManaPercent()

		druidBar:SetMinMaxValues(0, maxMana or 1)
		druidBar:SetValue(currMana or 0)
		druidBar.text:SetFormattedText("%d/%d", ceil(currMana or 0), maxMana or 1)
 	elseif (SimpleDruidBar) then
		druidBar:SetMinMaxValues(0, SimpleDruidBar.MaxMana or 1)
		druidBar:SetValue(SimpleDruidBar.CurrMana or 0)
		manaPct = ((SimpleDruidBar.CurrMana or 0) * 100.0) / (SimpleDruidBar.MaxMana or 1)
		druidBar.text:SetFormattedText("%d/%d", ceil(SimpleDruidBar.CurrMana or 0), SimpleDruidBar.MaxMana or 1)

		-- Doesn't hide the frame, but makes it not appear on screen. The code in SimpleDruidBar relies on IsShown() to function
		SimpleDruidBar.DISPLAY_BAR:ClearAllPoints()
	else
		druidBar:SetMinMaxValues(0, DruidBarKey.maxmana or 1)
		druidBar:SetValue(DruidBarKey.keepthemana or 0)
		manaPct = ((DruidBarKey.keepthemana or 0) * 100.0) / (DruidBarKey.maxmana or 1)
		druidBar.text:SetFormattedText("%d/%d", DruidBarKey.keepthemana or 0, DruidBarKey.maxmana or 1)
	end

	druidBar.percent:SetFormattedText(percD, manaPct)

	local druidBarExtra
	if (UnitPowerType(self.partyid) > 0) then
		druidBar.text:Show()
		if (pconf.percent) then
			druidBar.percent:Show()
		end
		druidBar:Show()
		druidBar:SetHeight(10)
		druidBarExtra = 1
	else
		druidBar.percent:Hide()
		druidBar.text:Hide()
		druidBar:Hide()
		druidBar:SetHeight(1)
		druidBarExtra = 0
	end

	local h = 40 + ((druidBarExtra + (pconf.repBar or 0) + (pconf.xpBar or 0)) * 10)
	self.statsFrame:SetHeight(h)
	XPerl_StatsFrameSetup(self, {druidBar, self.statsFrame.xpBar, self.statsFrame.repBar})
	if (XPerl_Player_Buffs_Position) then
		XPerl_Player_Buffs_Position(self)
	end
end

-- XPerl_Player_UpdateMana
local function XPerl_Player_UpdateMana(self)
	local mb = self.statsFrame.manaBar
	local playermana = UnitMana(self.partyid)
	local playermanamax = UnitManaMax(self.partyid)
	mb:SetMinMaxValues(0, playermanamax)
	mb:SetValue(playermana)

	mb.text:SetFormattedText("%d/%d", playermana, playermanamax)
	if (UnitPowerType(self.partyid) >= 1) then
		mb.percent:SetText(playermana)
	else
		mb.percent:SetFormattedText(percD, (playermana * 100.0) / playermanamax)
	end

	if (libDruidMana or SmartyCat or DruidBarKey or SimpleDruidBar) then
		if (playerClass == "DRUID") then
			XPerl_Player_DruidBarUpdate(self)
		end
	end
end

-- XPerl_Player_UpdateHealth
function XPerl_Player_UpdateHealth(self)
	local sf = self.statsFrame
	local hb = sf.healthBar
	local playerhealth, playerhealthmax = XPerl_UnitHealth(self.partyid), UnitHealthMax(self.partyid)

	XPerl_SetHealthBar(self, playerhealth, playerhealthmax)

	local greyMsg
	if (UnitIsDead(self.partyid)) then
		--if (UnitIsFeignDeath("player")) then
		--	greyMsg = XPERL_LOC_FEIGNDEATH
		--else
			greyMsg = XPERL_LOC_DEAD
		--end

	elseif (UnitIsGhost(self.partyid)) then
		greyMsg = XPERL_LOC_GHOST

	elseif (UnitIsAFK("player") and conf.showAFK) then
		greyMsg = CHAT_MSG_AFK
	end

	if (greyMsg) then
		if (pconf.percent) then
			hb.percent:SetText(greyMsg)
			hb.percent:Show()
		else
			hb.text:SetText(greyMsg)
			hb.text:Show()
		end

		sf:SetGrey()
	else
		if (sf.greyMana) then
			if (not pconf.values) then
				hb.text:Hide()
			end

			sf.greyMana = nil
			XPerl_Player_UpdateManaType(self)
		end
	end

	XPerl_PlayerStatus_OnUpdate(self, playerhealth, playerhealthmax)
end

-- XPerl_Player_UpdateLevel
local function XPerl_Player_UpdateLevel(self)
	self.levelFrame.text:SetText(UnitLevel(self.partyid))
end

-- XPerl_PlayerStatus_OnUpdate
function XPerl_PlayerStatus_OnUpdate(self, val, max)
	if (pconf.fullScreen.enable) then
		local testLow = pconf.fullScreen.lowHP / 100
		local testHigh = pconf.fullScreen.highHP / 100

		if (val and max) then
			local test = val / max

			if ( test <= testLow and not XPerl_LowHealthFrame.frameFlash and not UnitIsDeadOrGhost(self.partyid)) then
				XPerl_FrameFlash(XPerl_LowHealthFrame)
			elseif ( (test >= testHigh and XPerl_LowHealthFrame.frameFlash) or UnitIsDeadOrGhost(self.partyid) ) then
				XPerl_FrameFlashStop(XPerl_LowHealthFrame, "out")
			end
		else
			if (isOutOfControl and not XPerl_OutOfControlFrame.frameFlash and not UnitOnTaxi(self.partyid)) then
				XPerl_FrameFlash(XPerl_OutOfControlFrame)
			elseif (not isOutOfControl and XPerl_OutOfControlFrame.frameFlash) then
				XPerl_FrameFlashStop(XPerl_OutOfControlFrame, "out")
			end
		end
	else
		if (XPerl_LowHealthFrame.frameFlash) then
			XPerl_FrameFlashStop(XPerl_LowHealthFrame)
		end
		if (XPerl_OutOfControlFrame.frameFlash) then
			XPerl_FrameFlashStop(XPerl_OutOfControlFrame)
		end
	end
end

-- XPerl_Player_OnUpdate
function XPerl_Player_OnUpdate(self, elapsed)
	CombatFeedback_OnUpdate(elapsed)
	if (self.PlayerFlash) then
		XPerl_Player_CombatFlash(self, elapsed, false)
	end
end

-- XPerl_Player_UpdateBuffs
local function XPerl_Player_UpdateBuffs(self)
	XPerl_CheckDebuffs(self, self.partyid)

	if (playerClass == "DRUID") then
		if (libDruidMana or SmartyCat or DruidBarKey or SimpleDruidBar) then
			-- For DruidBar addon, we update the mana bar on shapeshift
			XPerl_Player_UpdateMana(self)
		end
	end

	if (pconf.fullScreen.enable) then
		if (isOutOfControl and not UnitOnTaxi("player")) then
			XPerl_PlayerStatus_OnUpdate(self)
		end
	end
end

-- XPerl_Player_UpdateDisplay
function XPerl_Player_UpdateDisplay (self)
	XPerl_Player_UpdateXP(self)
	XPerl_Player_UpdateRep(self)
	XPerl_Player_UpdateManaType(self)
	XPerl_Player_UpdateLevel(self)
	XPerl_Player_UpdateName(self)
	XPerl_Player_UpdatePVP(self)
	XPerl_Player_UpdateCombat(self)
	XPerl_Player_UpdateLeader(self)
	XPerl_Player_UpdateMana(self)
	XPerl_Player_UpdateHealth(self)
	XPerl_Player_UpdateBuffs(self)
	XPerl_Unit_UpdatePortrait(self)
end

-- EVENTS AND STUFF

-------------------
-- Event Handler --
-------------------
function XPerl_Player_OnEvent(self, event, arg1, ...)
	XPerl_Player_Events[event](self, arg1, ...)
--	local func = XPerl_Player_Events[event]
--	if (func) then
--		func(self, a, b, c, d)
--	else
--XPerl_ShowMessage("EXTRA EVENT")
--	end
end

-- PLAYER_ENTERING_WORLD
function XPerl_Player_Events:PLAYER_ENTERING_WORLD()
	local _
	_, playerClass = UnitClass("player")
	playerName = UnitName("player")
	XPerl_Player_UpdateDisplay(self)
end

-- UNIT_COMBAT
function XPerl_Player_Events:UNIT_COMBAT()
 	if (arg1 == "player") then
		if (pconf.hitIndicator and pconf.portrait) then
			CombatFeedback_OnCombatEvent(arg2, arg3, arg4, arg5)
		end

		if (arg2 == "HEAL") then
			XPerl_Player_CombatFlash(self, elapsed, true, true)
		elseif (arg4 and arg4 > 0) then
			XPerl_Player_CombatFlash(self, elapsed, true)
		end
	end
end

-- UNIT_SPELLMISS
function XPerl_Player_Events:UNIT_SPELLMISS()
	if (arg1 == "player") then
		if (pconf.hitIndicator and pconf.portrait) then
			CombatFeedback_OnSpellMissEvent(arg2)
		end
	end
end

-- UNIT_PORTRAIT_UPDATE
function XPerl_Player_Events:UNIT_PORTRAIT_UPDATE()
	if (arg1 == "player") then
		XPerl_Unit_UpdatePortrait(self)
	end
end

-- VARIABLES_LOADED
function XPerl_Player_Events:VARIABLES_LOADED()
	self.doubleCheckAFK = 2		-- Check during 2nd UPDATE_FACTION, which are the last guarenteed events to come after logging in
	self:UnregisterEvent(event)

	local events = {"PLAYER_ENTERING_WORLD", "PARTY_MEMBERS_CHANGED", "PARTY_LEADER_CHANGED",
			"PARTY_LOOT_METHOD_CHANGED", "RAID_ROSTER_UPDATE", "PLAYER_UPDATE_RESTING", "PLAYER_REGEN_ENABLED",
			"PLAYER_REGEN_DISABLED", "PLAYER_ENTER_COMBAT", "PLAYER_LEAVE_COMBAT", "PLAYER_DEAD",
			"UPDATE_FACTION", "PLAYER_AURAS_CHANGED", "PLAYER_CONTROL_LOST", "PLAYER_CONTROL_GAINED",
			"UNIT_COMBAT"}

	for i,event in pairs(events) do
		self:RegisterEvent(event)
	end

	XPerl_Player_Events.VARIABLES_LOADED = nil
end

-- PARTY_LOOT_METHOD_CHANGED
function XPerl_Player_Events:PARTY_LOOT_METHOD_CHANGED()
	XPerl_Player_UpdateLeader(self)
end
XPerl_Player_Events.PARTY_MEMBERS_CHANGED	= XPerl_Player_Events.PARTY_LOOT_METHOD_CHANGED
XPerl_Player_Events.PARTY_LEADER_CHANGED	= XPerl_Player_Events.PARTY_LOOT_METHOD_CHANGED
XPerl_Player_Events.RAID_ROSTER_UPDATE		= XPerl_Player_Events.PARTY_LOOT_METHOD_CHANGED

-- UNIT_HEALTH, UNIT_MAXHEALTH
function XPerl_Player_Events:UNIT_HEALTH()
	XPerl_Player_UpdateHealth(self)
end
XPerl_Player_Events.UNIT_MAXHEALTH = XPerl_Player_Events.UNIT_HEALTH
XPerl_Player_Events.PLAYER_DEAD    = XPerl_Player_Events.UNIT_HEALTH

-- UNIT_SPELLCAST_SUCCEEDED
function XPerl_Player_Events:UNIT_SPELLCAST_SUCCEEDED(unit, spell, rank)
	if (pconf.energyTicker and spell and UnitPowerType(self.partyid) == 0) then
		self.waitForManaReduction = true
		self.tickerPrevMana = UnitMana(self.partyid)
		self.tickerCastTime = GetTime()
	end
end

-- UNIT_MANA
function XPerl_Player_Events:UNIT_MANA()
	XPerl_Player_UpdateMana(self)

	if (self.waitForManaReduction) then
		if (UnitMana(self.partyid) < self.tickerPrevMana) then
			local diffTime = GetTime() - self.tickerCastTime

			if (diffTime < 1) then
				self.statsFrame.energyTicker.fsrEnabled = true
				self.statsFrame.energyTicker:SetValue(diffTime)
				self.statsFrame.energyTicker:Show()
			end
		end

		self.waitForManaReduction = nil
		self.tickerPrevMana = nil
		self.tickerCastTime = nil
	end
end

-- UNIT_MAXMANA
function XPerl_Player_Events:UNIT_MAXMANA()
	XPerl_Player_UpdateMana(self)
end

XPerl_Player_Events.UNIT_RAGE		= XPerl_Player_Events.UNIT_MAXMANA
XPerl_Player_Events.UNIT_MAXRAGE	= XPerl_Player_Events.UNIT_MAXMANA

function XPerl_Player_Events:UNIT_ENERGY()
	XPerl_Player_UpdateMana(self)

	local e = UnitMana(self.partyid)
	if (e == self.EnergyLast + 20 and self.statsFrame.energyTicker) then
		self.statsFrame.energyTicker.EnergyTime = GetTime()
	end
	self.EnergyLast = e

	XPerl_Player_TickerShowHide(self)
end
XPerl_Player_Events.UNIT_MAXENERGY       = XPerl_Player_Events.UNIT_ENERGY

-- UNIT_DISPLAYPOWER
function XPerl_Player_Events:UNIT_DISPLAYPOWER()
	XPerl_Player_UpdateManaType(self)
	XPerl_Player_UpdateMana(self)
	XPerl_Player_TickerShowHide(self)
end

-- UNIT_NAME_UPDATE
function XPerl_Player_Events:UNIT_NAME_UPDATE()
	XPerl_Player_UpdateName(self)
end

-- UNIT_LEVEL
function XPerl_Player_Events:UNIT_LEVEL()
	XPerl_Player_UpdateLevel(self)
	XPerl_Player_UpdateXP(self)
end
XPerl_Player_Events.PLAYER_LEVEL_UP = XPerl_Player_Events.UNIT_LEVEL

-- PLAYER_XP_UPDATE
function XPerl_Player_Events:PLAYER_XP_UPDATE()
	XPerl_Player_UpdateXP(self)
end

-- UPDATE_STEALTH
function XPerl_Player_Events:UPDATE_STEALTH()
	XPerl_Player_TickerShowHide(self)
end

-- UPDATE_FACTION
function XPerl_Player_Events:UPDATE_FACTION()
	XPerl_Player_UpdateRep(self)

	if (self.doubleCheckAFK) then
		self.doubleCheckAFK = self.doubleCheckAFK - 1
		if (self.doubleCheckAFK <= 0) then
			XPerl_Player_UpdateHealth(self)
			self.doubleCheckAFK = nil
		end
	end
end

-- UNIT_FACTION
function XPerl_Player_Events:UNIT_FACTION()
	XPerl_Player_UpdatePVP(self)
end
XPerl_Player_Events.UNIT_FLAGS = XPerl_Player_Events.UNIT_FACTION

function XPerl_Player_Events:PLAYER_FLAGS_CHANGED(unit)
	XPerl_Player_UpdateHealth(self)
end

-- PLAYER_ENTER_COMBAT, PLAYER_LEAVE_COMBAT
function XPerl_Player_Events:PLAYER_ENTER_COMBAT()
	XPerl_Player_UpdateCombat(self)
end
XPerl_Player_Events.PLAYER_LEAVE_COMBAT = XPerl_Player_Events.PLAYER_ENTER_COMBAT

-- PLAYER_REGEN_ENABLED, PLAYER_REGEN_DISABLED
function XPerl_Player_Events:PLAYER_REGEN_ENABLED()
	XPerl_Player_UpdateCombat(self)
end
XPerl_Player_Events.PLAYER_REGEN_DISABLED = XPerl_Player_Events.PLAYER_REGEN_ENABLED
XPerl_Player_Events.PLAYER_UPDATE_RESTING = XPerl_Player_Events.PLAYER_REGEN_ENABLED

function XPerl_Player_Events:PLAYER_AURAS_CHANGED()
	XPerl_Player_UpdateBuffs(self)
end

-- PLAYER_CONTROL_LOST
function XPerl_Player_Events:PLAYER_CONTROL_LOST()
	if (pconf.fullScreen.enable and not UnitOnTaxi("player")) then
		isOutOfControl = 1
	end
end

-- PLAYER_CONTROL_GAINED
function XPerl_Player_Events:PLAYER_CONTROL_GAINED()
	isOutOfControl = nil
	if (pconf.fullScreen.enable) then
		XPerl_PlayerStatus_OnUpdate(self)
	end
end

-- XPerl_Player_Energy_TickWatch
function XPerl_Player_Energy_OnUpdate(self, elapsed)
	local sparkPosition
	if (self.fsrEnabled) then
		local val = self:GetValue() + elapsed
		if (val > 5) then
			self:Hide()
			self.fsrEnabled = false
		else
			self:SetValue(val)
			sparkPosition = self:GetWidth() * (val / 5)
		end
	else
		local remainder = (GetTime() - self.EnergyTime) % 2
		self:SetValue(remainder)
		sparkPosition = self:GetWidth() * (remainder / 2)
	end

	self.spark:SetPoint("CENTER", self, "LEFT", sparkPosition, 0)
end

-- XPerl_Player_TickerShowHide
function XPerl_Player_TickerShowHide(self)
	local f = self.statsFrame.energyTicker
	if (f) then
		local t = UnitPowerType(self.partyid)
		local show

		if (pconf.energyTicker and self.EnergyEnabled and not UnitIsDeadOrGhost(self.partyid)) then
			if (t == 3) then
				local e, m = UnitMana(self.partyid), UnitManaMax(self.partyid)
				show = (e < m or UnitAffectingCombat(self.partyid) or IsStealthed()) and not UnitIsDeadOrGhost(self.partyid)
			end
		end

		if (show) then
			if (t == 0) then
				f:SetStatusBarColor(0.4, 0.7, 1)
			else
				f:SetStatusBarColor(1, 1, 0.5)
			end
			f:Show()
		else
			f:Hide()
		end
	end
end

-- XPerl_Player_SetWidth
function XPerl_Player_SetWidth(self)

	pconf.size.width = max(0, pconf.size.width or 0)
	if (pconf.percent) then
		self.nameFrame:SetWidth(160 + pconf.size.width)
		self.statsFrame:SetWidth(160 + pconf.size.width)
		self.statsFrame.healthBar.percent:Show()
		self.statsFrame.manaBar.percent:Show()

		if (self.statsFrame.xpBar) then
			self.statsFrame.xpBar.percent:Show()
		end
		if (self.statsFrame.repBar) then
			self.statsFrame.repBar.percent:Show()
		end
	else
		self.nameFrame:SetWidth(128 + pconf.size.width)
		self.statsFrame:SetWidth(128 + pconf.size.width)
		self.statsFrame.healthBar.percent:Hide()
		self.statsFrame.manaBar.percent:Hide()
		if (self.statsFrame.xpBar) then
			self.statsFrame.xpBar.percent:Hide()
		end
		if (self.statsFrame.repBar) then
			self.statsFrame.repBar.percent:Hide()
		end
	end

	local h = 40 + ((((self.statsFrame.druidBar and self.statsFrame.druidBar:IsShown()) or 0) + (pconf.repBar or 0) + (pconf.xpBar or 0)) * 10)
	self.statsFrame:SetHeight(h)

	self:SetWidth((pconf.portrait or 0) * 62 + (pconf.percent or 0) * 32 + 124 + pconf.size.width)
	self:SetScale(pconf.scale)

	XPerl_StatsFrameSetup(self, {self.statsFrame.druidBar, self.statsFrame.xpBar, self.statsFrame.repBar})
	if (XPerl_Player_Buffs_Position) then
		XPerl_Player_Buffs_Position(self)
	end

	XPerl_SavePosition(self, true)
end

-- CreateBar(self, name)
local function CreateBar(self, name)
	local f = CreateFrame("StatusBar", self.statsFrame:GetName()..name, self.statsFrame, "XPerlStatusBar")
	f:SetPoint("TOPLEFT", self.statsFrame.manaBar, "BOTTOMLEFT", 0, 0)
	f:SetHeight(10)
	self.statsFrame[name] = f
	f:SetWidth(112)
	return f
end

-- MakeEnergyTicker
local function MakeEnergyTicker(self)
	local f = CreateFrame("StatusBar", self.statsFrame:GetName().."energyTicker", self.statsFrame.manaBar)
	self.statsFrame.energyTicker = f
	f:SetPoint("TOPLEFT", self.statsFrame.manaBar, "BOTTOMLEFT", 0, 0)
	f:SetPoint("BOTTOMRIGHT", self.statsFrame.manaBar, "BOTTOMRIGHT", 0, -2)
	f:SetStatusBarTexture("Interface\\Addons\\XPerl\\Images\\XPerl_FrameBack")
	f:SetHeight(2)
	--f:SetFrameLevel(self.statsFrame.manaBar:GetFrameLevel() + 1)
	f:Hide()

	f.spark = f:CreateTexture(nil, "OVERLAY")
	f.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	f.spark:SetBlendMode("ADD")
	f.spark:SetWidth(12)
	f.spark:SetHeight(12)
	f.spark:SetPoint("CENTER", 0, 0)

	SetupTickerColour(self)

	f.EnergyTime = 0
	f:SetScript("OnUpdate", XPerl_Player_Energy_OnUpdate)

	MakeEnergyTicker = nil
end

-- MakeDruidBar()
local function MakeDruidBar(self)
	local f = CreateBar(self, "druidBar")
	local c = conf.colour.bar.mana
	f:SetStatusBarColor(c.r, c.g, c.b)
	f.bg:SetVertexColor(c.r, c.g, c.b, 0.25)
	MakeDruidBar = nil
end

-- MakeXPBars
local function MakeXPBars(self)
	local f = CreateBar(self, "xpBar")
	local f2 = CreateBar(self, "xpRestBar")

	f2:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
	f2:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)

	--f:SetStatusBarColor(0, 0.8, 0)
	--f2:SetStatusBarColor(0, 0.8, 0)

	MakeXPBars = nil
end

-- XPerl_Player_SetTotems
function XPerl_Player_SetTotems(self)
	if (pconf.totems.enable) then
		TotemFrame:SetParent(self)
		TotemFrame:ClearAllPoints()
		TotemFrame:SetPoint("TOP", self, "BOTTOM", pconf.totems.offsetX, pconf.totems.offsetY)
	else
		TotemFrame:SetParent(PlayerFrame)
		TotemFrame:ClearAllPoints()
		TotemFrame:SetPoint("TOPLEFT", PlayerFrame, "BOTTOMLEFT", 99, 38)
	end
	TotemFrame_Update()
end

-- XPerl_Player_Set_Bits()
function XPerl_Player_Set_Bits(self)
	if (pconf.portrait) then
		self.portraitFrame:Show()
		self.portraitFrame:SetWidth(60)
	else
		self.portraitFrame:Hide()
		self.portraitFrame:SetWidth(3)
	end

	if (pconf.level) then
		self.levelFrame:Show()
		self:RegisterEvent("PLAYER_LEVEL_UP")
	else
		self.levelFrame:Hide()
	end

	local _
	_, playerClass = UnitClass("player")
	playerName = UnitName("player")
	local l, r, t, b = XPerl_ClassPos(playerClass)
	self.classFrame.tex:SetTexCoord(l, r, t, b)

	if (pconf.classIcon) then
		self.classFrame:Show()
	else
		self.classFrame:Hide()
	end

	if (pconf.repBar) then
		if (not self.statsFrame.repBar) then
			CreateBar(self, "repBar")
		end

		self.statsFrame.repBar:Show()
	else
		if (self.statsFrame.repBar) then
			self.statsFrame.repBar:Hide()
		end
	end

	if (playerClass ~= "WARRIOR") then
		if (pconf.energyTicker) then
			if (not self.statsFrame.energyTicker) then
				MakeEnergyTicker(self)
			end

			if (playerClass == "ROGUE" or playerClass == "DRUID") then
				self:RegisterEvent("UPDATE_STEALTH")
			end
		else
			self:UnregisterEvent("UPDATE_STEALTH")
		end
	else
		MakeEnergyTicker = nil
	end

	if (playerClass == "DRUID" and not self.statsFrame.druidBar and (libDruidMana or SmartyCat or DruidBarKey or SimpleDruidBar)) then
		MakeDruidBar(self)
	else
		MakeDruidBar = nil
	end

	if (pconf.xpBar) then
		if (not self.statsFrame.xpBar) then
			MakeXPBars(self)
		end

		self.statsFrame.xpBar:Show()
		self.statsFrame.xpRestBar:Show()

		self:RegisterEvent("PLAYER_XP_UPDATE")
	else
		if (self.statsFrame.xpBar) then
			self.statsFrame.xpBar:Hide()
			self.statsFrame.xpRestBar:Hide()
		end

		self:UnregisterEvent("PLAYER_XP_UPDATE")
	end

	if (pconf.values) then
		self.statsFrame.healthBar.text:Show()
		self.statsFrame.manaBar.text:Show()
		if (self.statsFrame.xpBar) then
			self.statsFrame.xpBar.text:Show()
		end
		if (self.statsFrame.repBar) then
			self.statsFrame.repBar.text:Show()
		end
	else
		self.statsFrame.healthBar.text:Hide()
		self.statsFrame.manaBar.text:Hide()
		if (self.statsFrame.xpBar) then
			self.statsFrame.xpBar.text:Hide()
		end
		if (self.statsFrame.repBar) then
			self.statsFrame.repBar.text:Hide()
		end
	end

	XPerl_Player_SetWidth(self)

	local h1 = self.nameFrame:GetHeight() + self.statsFrame:GetHeight() - 2
	local h2 = self.portraitFrame:GetHeight()
	XPerl_SwitchAnchor(self, "TOPLEFT")
	self:SetHeight(max(h1, h2))

	self.highlight:ClearAllPoints()
	if (pconf.extendPortrait) then
		self.portraitFrame:SetHeight(62 + (((pconf.xpBar or 0) + (pconf.repBar or 0)) * 10))
		--self.highlight:SetPoint("TOPLEFT", self.levelFrame, "TOPLEFT", 0, 0)
		--self.highlight:SetPoint("BOTTOMRIGHT", self.statsFrame, "BOTTOMRIGHT", 0, 0)
	else
		self.portraitFrame:SetHeight(62)
		--self.highlight:SetPoint("BOTTOMLEFT", self.classFrame, "BOTTOMLEFT", -2, -2)
		--self.highlight:SetPoint("TOPRIGHT", self.nameFrame, "TOPRIGHT", 0, 0)
	end

	self.highlight:ClearAllPoints()
	if (not pconf.level and not pconf.classIcon and (not XPerlConfigHelper or XPerlConfigHelper.ShowTargetCounters == 0)) then
		self.highlight:SetPoint("TOPLEFT", self.portraitFrame, "TOPLEFT", 0, 0)
	else
		self.highlight:SetPoint("TOPLEFT", self.levelFrame, "TOPLEFT", 0, 0)
	end
	self.highlight:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)

	if (playerClass == "SHAMAN") then
		if (not pconf.totems) then
			pconf.totems = {
				enable = true,
				offsetX = 0,
				offsetY = 0
			}
		end
		XPerl_Player_SetTotems(self)
	end
	
	self:SetAlpha(conf.transparency.frame)

	self.buffOptMix = nil
	XPerl_Player_UpdateDisplay(self)

	if (XPerl_Player_BuffSetup) then
		if (self.buffFrame) then
			self.buffOptMix = nil
			XPerl_Player_BuffSetup(XPerl_Player)
		end
	end

	if (XPerl_Voice) then
		XPerl_Voice:Register(self)
	end
end
