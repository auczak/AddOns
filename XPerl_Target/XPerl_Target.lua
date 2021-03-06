-- X-Perl UnitFrames
-- Author: Zek <Boodhoof-EU>
-- License: GNU GPL v3, 29 June 2007 (see LICENSE.txt)

local XPerl_Target_Events = {}
local conf, tconf
XPerl_RequestConfig(function(new)
				conf = new
				tconf = conf.target
				if (XPerl_Target) then XPerl_Target.conf = conf.target end
				if (XPerl_Focus) then XPerl_Focus.conf = conf.focus end
				if (XPerl_TargetTarget) then XPerl_TargetTarget.conf = conf.targettarget end
				if (XPerl_FocusTarget) then XPerl_FocusTarget.conf = conf.focustarget end
				if (XPerl_PetTarget) then XPerl_PetTarget.conf = conf.pettarget end
			end, "$Revision: 177 $")

local percD = "%d"..PERCENT_SYMBOL
local format = format
local GetNumRaidMembers = GetNumRaidMembers
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsGhost = UnitIsGhost
local UnitMana = UnitMana
local UnitManaMax = UnitManaMax
local UnitName = UnitName
local UnitPowerType = UnitPowerType
local buffSetup
local playerClass
local lastInspectPending = 0
local mobhealth

----------------------
-- Loading Function --
----------------------
function XPerl_Target_OnLoad(self, partyid)
	XPerl_SetChildMembers(self)

	CombatFeedback_Initialize(self.hitIndicator.text, 30)
	self.hitIndicator.text:SetPoint("CENTER", self.portraitFrame, "CENTER", 0, 0)

	local events = {"UNIT_COMBAT", "PLAYER_FLAGS_CHANGED",
		"PARTY_MEMBER_DISABLE", "PARTY_MEMBER_ENABLE", "RAID_TARGET_UPDATE", "PARTY_MEMBERS_CHANGED",
		"PARTY_LEADER_CHANGED", "PARTY_LOOT_METHOD_CHANGED"}
	for i,event in pairs(events) do
		self:RegisterEvent(event)
	end

	XPerl_Highlight:Register(XPerl_Target_HighlightCallback, self)

	self.partyid = partyid
	if (partyid == "target") then
		XPerl_BlizzFrameDisable(TargetFrame)
		XPerl_BlizzFrameDisable(TargetofTargetFrame)

		self.statsFrame.focusTarget:SetVertexColor(0.7, 1, 1, 0.5)
		self.tutorialPage = 3
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
		self:RegisterEvent("PLAYER_FOCUS_CHANGED")
		self:RegisterEvent("PLAYER_COMBO_POINTS")
		self:RegisterEvent("VARIABLES_LOADED")
		self:RegisterEvent("INSPECT_TALENT_READY")
		self.combatMask = 0x00010000
	else
		self.tutorialPage = 10
		self:RegisterEvent("PLAYER_FOCUS_CHANGED")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		--self:SetScript("OnShow", XPerl_Target_UpdateDisplay)
		self.combatMask = 0x00020000
	end

	self.nameFrame.cpMeter:SetMinMaxValues(0, 5)

	local BuffOnUpdate, DebuffOnUpdate, BuffUpdateTooltip, DebuffUpdateTooltip
	BuffUpdateTooltip = XPerl_Unit_SetBuffTooltip
	DebuffUpdateTooltip = XPerl_Unit_SetDeBuffTooltip

	if (buffSetup) then
		self.buffSetup = buffSetup
	else
		self.buffSetup = {
			buffScripts = {
				OnEnter = XPerl_Unit_SetBuffTooltip,
				OnUpdate = BuffOnUpdate,
				OnLeave = XPerl_PlayerTipHide,
			},
			debuffScripts = {
				OnEnter = XPerl_Unit_SetDeBuffTooltip,
				OnUpdate = DebuffOnUpdate,
				OnLeave = XPerl_PlayerTipHide,
			},
			updateTooltipBuff = BuffUpdateTooltip,
			updateTooltipDebuff = DebuffUpdateTooltip,
			debuffParent = true,
			debuffSizeMod = 0.2,
			debuffAnchor1 = function(self, b) b:SetPoint("TOPLEFT", 0, 0) end,
		}
		self.buffSetup.buffAnchor1 = self.buffSetup.debuffAnchor1
		buffSetup = self.buffSetup
	end

	XPerl_SecureUnitButton_OnLoad(self.nameFrame, partyid, XPerl_ShowGenericMenu)
	XPerl_SecureUnitButton_OnLoad(self, partyid, XPerl_ShowGenericMenu)

	--RegisterUnitWatch(self)

	XPerl_UnitEvents(self, XPerl_Target_Events, {"UNIT_SPELLMISS", "UNIT_FACTION", "UNIT_DYNAMIC_FLAGS", "UNIT_FLAGS",
				"UNIT_CLASSIFICATION_CHANGED", "UNIT_PORTRAIT_UPDATE", "UNIT_AURA", "UNIT_HEALTH"})
	XPerl_RegisterBasics(self, XPerl_Target_Events)

	--self.PlayerFlash = 0
	self.perlBuffs, self.perlDebuffs, self.RangeUpdate = 0, 0, 0

	--XPerl_InitFadeFrame(self)

	if (partyid == "target" and XPerl_Target_AssistFrame) then
		-- Since target module is loaded after raid helper, we have to attach this manually
		-- because the target frame did not exist when this frame was created
		XPerl_Target_AssistFrame:SetParent(self)
		XPerl_Target_AssistFrame:ClearAllPoints()
		XPerl_Target_AssistFrame:SetPoint("TOPLEFT", self.portraitFrame, "TOPRIGHT", -2, -20)
		XPerl_Target_AssistFrame:Raise()
	end

	-- Set here to reduce amount of function calls made
	self:SetScript("OnEvent", XPerl_Target_OnEvent)
	self:SetScript("OnUpdate", XPerl_Target_OnUpdate)
	self:SetScript("OnShow", XPerl_Unit_UpdatePortrait)

	XPerl_RegisterHighlight(self.highlight, 3)
	XPerl_RegisterPerlFrames(self, {self.nameFrame, self.statsFrame, self.levelFrame, self.portraitFrame, self.typeFramePlayer, self.creatureTypeFrame, self.bossFrame, self.cpFrame})

	self.FlashFrames = {self.portraitFrame, self.nameFrame, self.levelFrame, self.statsFrame, self.bossFrame,
				self.typeFramePlayer, self.typeFrame}

	if (XPerl_ArcaneBar_RegisterFrame) then
		XPerl_ArcaneBar_RegisterFrame(self.nameFrame, partyid)
	end

	if (XPerlDB) then
		self.conf = XPerlDB[partyid]
	end

	XPerl_RegisterOptionChanger(XPerl_Target_Set_Bits, self)

	if (XPerl_Target and XPerl_Focus) then
		XPerl_Target_OnLoad = nil
	end
end

-- XPerl_Raid_HighlightCallback
function XPerl_Target_HighlightCallback(self, updateGUID)
	if (UnitGUID(self.partyid) == updateGUID and UnitIsFriend("player", self.partyid)) then
		XPerl_Highlight:SetHighlight(self, updateGUID)
	end
end

--------------------
-- Buff Functions --
--------------------

-- XPerl_Targets_BuffPositions
local function XPerl_Targets_BuffPositions(self)
	if (self.partyid and UnitCanAttack("player", self.partyid)) then
		XPerl_Unit_BuffPositions(self, self.buffFrame.debuff, self.buffFrame.buff, self.conf.debuffs.size, self.conf.buffs.size)
	else
		XPerl_Unit_BuffPositions(self, self.buffFrame.buff, self.buffFrame.debuff, self.conf.buffs.size, self.conf.debuffs.size)
	end
end

-- XPerl_Targets_BuffUpdate
function XPerl_Targets_BuffUpdate(self)
	if (UnitExists(self.partyid)) then
		if (not self.conf.buffs.enable and not self.conf.debuffs.enable) then
			self.buffFrame:Hide()
			self.debuffFrame:Hide()
		else
			XPerl_Unit_UpdateBuffs(self, nil, nil, self.conf.buffs.castable, self.conf.debuffs.curable)
			XPerl_Targets_BuffPositions(self)
		end
	end
end

-- GetComboColour
local function GetComboColour(num)
	if (num == 5) then		return 1,   0, 0
	elseif (num == 4) then		return 1, 0.5, 0
	elseif (num == 3) then		return 1,   1, 0
	elseif (num == 2) then		return 0.5, 1, 0
	elseif (num == 1) then		return 0,   1, 0
	end
end

---------------
-- Combo Points
---------------
local function XPerl_Target_UpdateCombo(self)
	if (self == XPerl_Target) then
		local combopoints = GetComboPoints()
		local r, g, b = GetComboColour(combopoints)
		if (tconf.combo.enable) then
			self.cpFrame:Hide()
			self.nameFrame.cpMeter:SetValue(combopoints)
			self.nameFrame.cpMeter:Show()
			if (r) then
				self.nameFrame.cpMeter:SetStatusBarColor(r, g, b, 0.7)
			else
				self.nameFrame.cpMeter:Hide()
			end
		elseif (not tconf.combo.blizzard) then
			self.nameFrame.cpMeter:Hide()
			self.cpFrame:Show()
			self.cpFrame.text:SetText(combopoints)
			if (r) then
				self.cpFrame.text:SetTextColor(r, g, b)
			else
				self.cpFrame:Hide()
			end
		end
	end
end

-- XPerl_UnitDebuffInformation
local function TargetDebuffInformation(debuff)
	for i = 1,40 do
		local name, rank, tex, count = UnitDebuff("target", i)
		if (not name) then
			break
		end
		if (name == debuff) then
			return count
		end
	end
	return 0
end

---------------------
--Debuffs          --
---------------------
local function XPerl_Target_DebuffUpdate(self)
	local partyid = self.partyid
	if (self == XPerl_Target) then
		if (GetComboPoints() == 0) then
			local numDebuffs = 0
			if (playerClass == "WARRIOR") then
				numDebuffs = TargetDebuffInformation(XPERL_SPELL_SUNDER)
			elseif (playerClass == "PRIEST") then
				numDebuffs = TargetDebuffInformation(XPERL_SPELL_SHADOWV)
			elseif (playerClass == "MAGE") then
				numDebuffs = TargetDebuffInformation(XPERL_SPELL_FIREV)
				if (numDebuffs == 0) then
					numDebuffs = TargetDebuffInformation(XPERL_SPELL_WINTERCH)
				end
			end

			local r, g, b = GetComboColour(numDebuffs)
			if (tconf.combo.enable) then
				self.cpFrame:Hide()
				self.nameFrame.cpMeter:SetValue(numDebuffs)
				if (r) then
					self.nameFrame.cpMeter:Show()
					self.nameFrame.cpMeter:SetStatusBarColor(r, g, b, 0.4)
				else
					self.nameFrame.cpMeter:Hide()
				end
			else
				self.nameFrame.cpMeter:Hide()
				self.cpFrame.text:SetText(numDebuffs)
				if (r) then
					self.cpFrame:Show()
					self.cpFrame.text:SetTextColor(r, g, b)
				else
					self.cpFrame:Hide()
				end
			end
		else
			XPerl_Target_UpdateCombo(self)
		end
	end
end

-------------------------
-- The Update Functions--
-------------------------
local function XPerl_Target_UpdatePVP(self)
	local partyid = self.partyid

	if (self.conf.pvpIcon and UnitIsPVP(partyid)) then
		self.nameFrame.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..(UnitFactionGroup(partyid) or "FFA"))
		self.nameFrame.pvpIcon:Show()
	else
		self.nameFrame.pvpIcon:Hide()
	end

	if (self.conf.reactionHighlight) then
		local c = XPerl_ReactionColour(partyid)
		self.nameFrame:SetBackdropColor(c.r, c.g, c.b)

		if (conf.colour.class and UnitPlayerControlled(partyid)) then
			XPerl_SetUnitNameColor(self.nameFrame.text, partyid)
		else
			self.nameFrame.text:SetTextColor(1, 1, 1, conf.transparency.text)
		end
	else
		XPerl_SetUnitNameColor(self.nameFrame.text, partyid)
	end

        if (UnitIsVisible(partyid) and UnitIsCharmed(partyid)) then
		self.nameFrame.warningIcon:Show()
	else
		self.nameFrame.warningIcon:Hide()
	end
end

-- XPerl_Target_UpdateName
local function XPerl_Target_UpdateName(self)
	self.nameFrame.text:SetText(UnitName(self.partyid))
	XPerl_Target_UpdatePVP(self)
end

-- XPerl_Target_UpdateLevel
local function XPerl_Target_UpdateLevel(self)
	local targetlevel = UnitLevel(self.partyid)
	self.levelFrame.text:SetText(targetlevel)
	-- Set Level
	if (self.conf.level) then
		self.levelFrame:Show()
		self.levelFrame.skull:Hide()
		self.levelFrame:SetWidth(27)
		if (targetlevel < 0) then
			if (UnitClassification(partyid) == "normal") then
				self.levelFrame.text:Hide()
				self.levelFrame.skull:Show()
			else
				self.levelFrame:Hide()
			end
		else
			local color = GetDifficultyColor(targetlevel)
			self.levelFrame.text:SetTextColor(color.r, color.g, color.b)
			self.levelFrame.text:Show()
			if (not self.conf.elite and (UnitClassification(self.partyid) == "elite" or UnitClassification(self.partyid) == "worldboss")) then --(UnitIsPlusMob(self.partyid))) then
				self.levelFrame.text:SetFormattedText("%d+", targetlevel)
				self.levelFrame:SetWidth(33)
			end
		end
	end
end

-- XPerl_Target_UpdateClassification
local function XPerl_Target_UpdateClassification(self)
	local partyid = self.partyid
	local targetclassification = UnitClassification(partyid)
	local bossType, eliteGfx

	if (targetclassification == "normal" and UnitPlayerControlled(partyid)) then
		if (not UnitIsPlayer(partyid)) then
			bossType = XPERL_TYPE_PET
			self.bossFrame.text:SetTextColor(1, 1, 1)
			self.typeFramePlayer:Hide()
		end

	elseif (self.conf.level or targetclassification == "rareelite" or targetclassification == "rare" or targetclassification == "elite" or targetclassification == "worldboss") then
--	elseif ((self.conf.level and self.conf.elite) or targetclassification=="Rare+" or targetclassification=="Rare") then
		if (self.conf.eliteGfx) then
			eliteGfx = true
			self.eliteFrame.tex:SetTexture("Interface\\Addons\\XPerl\\Images\\XPerl_Elite")
			if (targetclassification == "worldboss" or targetclassification == "elite") then
				self.eliteFrame.tex:SetVertexColor(1, 1, 0, 1)

			elseif (targetclassification == "rareelite") then
				self.eliteFrame.tex:SetVertexColor(1, 1, 1, 1)
				--self.eliteFrame.tex:SetVertexColor(1, 1, 0.5, 1)

			elseif (targetclassification == "rare") then
				self.eliteFrame.tex:SetTexture("Interface\\Addons\\XPerl\\Images\\XPerl_Rare")
				self.eliteFrame.tex:SetVertexColor(1, 1, 1, 1)
			else
				eliteGfx = nil
			end
		else
			if (targetclassification == "worldboss") then
				bossType = XPERL_TYPE_BOSS
				self.bossFrame.text:SetTextColor(1, 0.5, 0.5)

			elseif (targetclassification == "rareelite") then
				bossType = XPERL_TYPE_RAREPLUS
				self.bossFrame.text:SetTextColor(0.8, 0.8, 0.8)

			elseif (targetclassification == "elite") then
				bossType = XPERL_TYPE_ELITE
				self.bossFrame.text:SetTextColor(1, 1, 0.5)

			elseif (targetclassification == "rare") then
				bossType = XPERL_TYPE_RARE
				self.bossFrame.text:SetTextColor(0.8, 0.8, 0.8)
			end
		end

		self.typeFramePlayer:Hide()
	end

	if (bossType) then
		self.bossFrame:Show()
		self.bossFrame.text:SetText(bossType)
		self.bossFrame:SetWidth(self.bossFrame.text:GetStringWidth() + 10)
	else
		self.bossFrame:Hide()
	end

	if (eliteGfx) then
		self.eliteFrame:Show()
		if (XPerl_Target_AssistFrame and XPerl_Target_AssistFrame:IsShown()) then
			XPerl_Target_AssistFrame:ClearAllPoints()
			XPerl_Target_AssistFrame:SetPoint("BOTTOMRIGHT", self.portraitFrame, "BOTTOMRIGHT", 0, 0)
			XPerl_Target_AssistFrame:SetFrameLevel(self.portraitFrame:GetFrameLevel() + 2)
			self.eliteFrame.assistOutOfPlace = true
		end
		if (self.conf.level) then
			self.levelFrame:ClearAllPoints()
			self.levelFrame:SetPoint("TOPRIGHT", self.portraitFrame, "TOPRIGHT", 0, 0)
			self.levelFrame:SetFrameLevel(self.portraitFrame:GetFrameLevel() + 2)
			self.levelFrame.outOfPlace = true
		end
		-- this is hidden if the mob is elite regardless of graphics (wihout gfx it says "Elite" for example)
		--if (self.conf.classIcon) then
		--	self.typeFramePlayer:ClearAllPoints()
		--	self.typeFramePlayer:SetPoint("BOTTOMRIGHT", self.portraitFrame, "BOTTOMRIGHT", 0, 0)
		--	self.typeFramePlayer.outOfPlace = true
		--end
	else
		self.eliteFrame:Hide()
		if (self.eliteFrame.assistOutOfPlace) then
			self.eliteFrame.assistOutOfPlace = nil
			XPerl_Target_AssistFrame:ClearAllPoints()
			XPerl_Target_AssistFrame:SetPoint("TOPLEFT", self.portraitFrame, "TOPRIGHT", -2, -20)
			XPerl_Target_AssistFrame:SetFrameLevel(self.portraitFrame:GetFrameLevel())
		end
		if (self.levelFrame.outOfPlace) then
			self.levelFrame.outOfPlace = nil
			self.levelFrame:ClearAllPoints()
			self.levelFrame:SetPoint("TOPLEFT", self.portraitFrame, "TOPRIGHT", -2, 0)
			self.levelFrame:SetFrameLevel(self.portraitFrame:GetFrameLevel())
		end
		--if (self.typeFramePlayer.outOfPlace) then
		--	self.typeFramePlayer.outOfPlace = nil
		--	self.typeFramePlayer:ClearAllPoints()
		--	self.typeFramePlayer:SetPoint("BOTTOMLEFT", self.portraitFrame, "BOTTOMRIGHT", 2, 2)
		--end
	end
end

-- AdjustCreatureTypeFrame
local function AdjustCreatureTypeFrame(self)
	-- If it's too long, we anchor it to left side of portrait instead of right, to avoid it overlapping some buffs
	self.creatureTypeFrame:ClearAllPoints()
	if (self.creatureTypeFrame:GetWidth() > self.portraitFrame:GetWidth()) then
		self.creatureTypeFrame:SetPoint("TOPLEFT", self.portraitFrame, "BOTTOMLEFT", 0, 2)
	else
		self.creatureTypeFrame:SetPoint("TOPRIGHT", self.portraitFrame, "BOTTOMRIGHT", 0, 2)
	end
end

-- XPerl_Target_UpdateTalents
local XPerl_Target_UpdateTalents
if (NotifyInspect) then
	local talentCache = setmetatable({}, {__mode = "kv"})
	local lastInspectName, lastInspectUnit
	local lastInspectTime = 0
	hooksecurefunc("NotifyInspect",
		function(unit)
			if (UnitIsUnit("player", unit) or not (UnitExists(unit) and UnitIsVisible(unit) and UnitIsConnected(unit) and CheckInteractDistance(unit, 4))) then
				return
			end
			lastInspectUnit = unit
			lastInspectPending = lastInspectPending + 1
			if (lastInspectPending > 1) then
				lastInspectInvalid = true
			end
			lastInspectTime = GetTime()
			lastInspectName = UnitName(unit)
		end
	)
	function XPerl_Target_UpdateTalents(self)
		if (not self.creatureTypeFrame:IsShown()) then
			local partyid = self.partyid
			if (self.conf.showTalents and UnitIsVisible(partyid) and UnitExists(partyid) and UnitIsPlayer(partyid) and UnitLevel(partyid) > 10) then
				local name = UnitName(partyid)
				if (not name) then
					return
				else
					local remoteInspectNeeded = not UnitIsUnit("player", partyid) or nil
					local cached = talentCache[name]
					local name1, name2, name3, num1, num2, num3, iconTexture, background
					if (cached) then
						num1, name1, num2, name2, num3, name3 = unpack(cached)
					else
						if (lastInspectName == UnitName(partyid) or not remoteInspectNeeded) then
							name1, iconTexture, num1, background  = GetTalentTabInfo(1, remoteInspectNeeded)
							name2, iconTexture, num2, background  = GetTalentTabInfo(2, remoteInspectNeeded)
							name3, iconTexture, num3, background  = GetTalentTabInfo(3, remoteInspectNeeded)
							newInfo = true
						end
					end

					if (name1 and name2 and name3) then
						if (num1 ~= 0 or num2 ~= 0 or num3 ~= 0) then
							if (not cached) then
								talentCache[name] = {num1, name1, num2, name2, num3, name3}
							end
							if (self.conf.talentsAsText) then
								local title
								if (num1 > num2 and num1 > num3) then
									title = name1
								elseif (num2 > num1 and num2 > num3) then
									title = name2
								elseif (num3 > num1 and num3 > num2) then
									title = name3
								end
								self.creatureTypeFrame.text:SetText(title)
							else
								self.creatureTypeFrame.text:SetFormattedText("%d / %d / %d", num1, num2, num3)
							end
							self.creatureTypeFrame:SetWidth(self.creatureTypeFrame.text:GetStringWidth() + 10)
							self.creatureTypeFrame:Show()

							AdjustCreatureTypeFrame(self)
							XPerl_Targets_BuffPositions(self)
							return
						end
					end

					if (not cached and (lastInspectPending == 0 or GetTime() > lastInspectTime + 15)) then
						if (UnitExists(partyid) and UnitIsVisible(partyid) and CheckInteractDistance(partyid, 4)) then
							if (not UnitIsUnit("player", partyid)) then
								lastInspectInvalid = nil
								lastInspectPending = 0
								NotifyInspect(partyid)
							end
						end
					end
				end
			end
		end
	end
else
	function XPerl_Target_UpdateTalents()
	end
end

-- XPerl_Target_UpdateType
local function XPerl_Target_UpdateType(self)
	local partyid = self.partyid
	local targettype = UnitCreatureType(partyid)

	if (targettype == XPERL_TYPE_NOT_SPECIFIED or targettype == "") then
		targettype = nil
	end

	if (self.conf.mobType) then
		self.creatureTypeFrame:Show()
	else
		self.creatureTypeFrame:Hide()
	end

	self.typeFramePlayer:Hide()
	self.creatureTypeFrame.text:SetText(targettype)

	--if (UnitIsPlayer(partyid)) then
		if (self.conf.classIcon and (UnitIsPlayer(partyid) or UnitClassification(partyid) == "normal")) then
			local LocalClass, PlayerClass
			if (UnitClassBase) then			-- WoW 2.4 LocalClass became unit name for NPCs... WHY??
				LocalClass, PlayerClass = UnitClassBase(partyid)
			else
				LocalClass, PlayerClass = UnitClass(partyid)
			end
			if (self.conf.classText) then
				self.bossFrame.text:SetText(LocalClass)
				self.bossFrame.text:SetTextColor(1, 1, 1)
				self.bossFrame:Show()
				self.bossFrame:SetWidth(self.bossFrame.text:GetStringWidth() + 10)
			else
				if (UnitIsPlayer(partyid) or not UnitPlayerControlled(partyid)) then
					local l, r, t, b = XPerl_ClassPos(PlayerClass)
					self.typeFramePlayer.classTexture:SetTexCoord(l, r, t, b)
					self.typeFramePlayer:Show()
				end
			end
		end
		if (UnitIsPlayer(partyid)) then
			self.creatureTypeFrame:Hide()
		end
	--else
		if (targettype) then
			self.creatureTypeFrame.text:SetTextColor(1, 1, 1)
			self.creatureTypeFrame:SetWidth(self.creatureTypeFrame.text:GetStringWidth() + 10)
		else
			self.creatureTypeFrame:Hide()
		end
	--end

	AdjustCreatureTypeFrame(self)

	XPerl_Target_UpdateTalents(self)
end

-- XPerl_Target_SetManaType
function XPerl_Target_SetManaType(self)
	local targetmanamax = UnitManaMax(self.partyid)

	if (targetmanamax == 0 or not self.conf.mana) then
		if (self.statsFrame.manaBar:IsShown()) then
			self.statsFrame.manaBar:Hide()

			if (self == XPerl_Target or self == XPerl_Focus) then
				self.statsFrame:SetHeight(28 + ((conf.bar.fat or 0) * 2))
				XPerl_StatsFrameSetup(self)
			end
		end
		return
	end

	XPerl_SetManaBarType(self)

	if (not self.statsFrame.manaBar:IsShown()) then
		self.statsFrame.manaBar:Show()
		self.statsFrame.manaBar.text:Show()
		if (self == XPerl_Target or self == XPerl_Focus) then
			self.statsFrame:SetHeight(40)
			XPerl_StatsFrameSetup(self)
		end
	end
end

-- XPerl_Target_SetMana
function XPerl_Target_SetMana(self)
	local targetmana, targetmanamax = UnitMana(self.partyid), UnitManaMax(self.partyid)
	local mb = self.statsFrame.manaBar

	if (targetmanamax == 1 and targetmana > targetmanamax) then
		targetmanamax = targetmana
	end

	mb:SetMinMaxValues(0, targetmanamax)
	mb:SetValue(targetmana)

	local p = UnitPowerType(self.partyid)
	if (p == 0) then
		mb.percent:SetFormattedText(percD, 100 * (targetmana / targetmanamax))	--	XPerl_Percent[floor(100 * (targetmana / targetmanamax))])
	else
		mb.percent:SetText(targetmana)
	end

	mb.text:SetFormattedText("%d/%d", targetmana, targetmanamax)
end

-- XPerl_Target_UpdateHealth
local function XPerl_Target_UpdateHealth(self)
	XPerl_Target_SetHealth(self)
end

-- XPerl_Target_GetHealth
function XPerl_Target_GetHealth(self)
	local hp, hpMax = XPerl_Unit_GetHealth(self)
	return hp, hpMax, hpMax == 100
end

-- XPerl_Target_GetHealthMH3
local function XPerl_Target_GetHealthMH3(self)
	local hp, hpMax = XPerl_Unit_GetHealth(self)
	local percent
	if (hpMax == 100) then
		local current, max, found = mobhealth:GetUnitHealth(self.partyid)
		if (current and max and found) then
			if (max ~= 100) then
				hp, hpMax = current, max
			else
				percent = true
			end
		else
			percent = true
		end
	end
	return hp, hpMax, percent
end

-- XPerl_Target_GetHealthMI2
local function XPerl_Target_GetHealthMI2(self)
	local partyid = self.partyid
	local hp, hpMax = XPerl_Unit_GetHealth(self)

	local percent
	if (hpMax == 100) then
		local index, current, max, table
		if (UnitIsPlayer(partyid)) then
			index = UnitName(partyid)
			table = MobHealthPlayerDB or MobHealthDB
		else
			index = UnitName(partyid)..":"..UnitLevel(partyid)
			table = MobHealthDB or MobHealthPlayerDB
		end

		if (table and type(table[index]) == "string") then
			local pts, pct = strmatch(table[index], "^(%d+)/(%d+)$")

			if (pts and pct) then
				pts = pts + 0
				pct = pct + 0
				if( pct ~= 0 ) then
					pointsPerPct = pts / pct
				else
					pointsPerPct = 0
				end

				local currentPct = hp
				if (pointsPerPct > 0) then
					current = (currentPct * pointsPerPct) + 0.5
					max = (100 * pointsPerPct) + 0.5
				end
			end
		end

		if (current) then
			hp, hpMax = current, max
		else
			percent = true
		end
	end

	return hp, hpMax, percent
end

-- XPerl_Target_SetHealth
function XPerl_Target_SetHealth(self)
	local partyid = self.partyid

	local hb = self.statsFrame.healthBar
	local hbt = self.statsFrame.healthBar.text
	local hp, hpMax, percent = XPerl_Target_GetHealth(self)

	if (self.targethp == 100) then
		-- Try to work around the occasion WoW targettarget bug of a zero hp tank who is not at zero hp
		if (not UnitIsDeadOrGhost(partyid)) then
			if (UnitInRaid(partyid)) then
				for i = 1,GetNumRaidMembers() do
					local id = "raid"..i
					if (UnitIsUnit(id, partyid)) then
						hp, hpMax, percent = UnitHealth(id), UnitHealthMax(id), false
						break
					end
				end
			end
		end
	end
	
	XPerl_SetHealthBar(self, hp, hpMax)

	if (percent) then
		hbt:SetFormattedText(percD, 100 * hp / hpMax)
	end

	local color
	if (self.conf.percent) then
		if (UnitIsGhost(partyid)) then
			self.statsFrame.manaBar.percent:Hide()
			hb.percent:SetText(XPERL_LOC_GHOST)

		elseif (UnitIsDead(partyid) or (self.feigning and conf.showFD)) then
			self.statsFrame.manaBar.percent:Hide()
			hb.percent:SetText(XPERL_LOC_DEAD)
			if (conf.showFD and UnitIsFeignDeath(partyid)) then
				hbt:SetText(XPERL_LOC_FEIGNDEATH)
			end

		elseif (UnitExists(partyid) and not UnitIsConnected(partyid)) then
			self.statsFrame.manaBar.percent:Hide()
			hb.percent:SetText(XPERL_LOC_OFFLINE)

		elseif (UnitIsAFK(partyid) and conf.showAFK and (self == XPerl_Target or self == XPerl_Focus)) then
			hb.percent:SetText(CHAT_MSG_AFK)

		else
			self.statsFrame.manaBar.percent:Show()
			color = true
		end
	else
		if (UnitIsGhost(partyid)) then
			hbt:SetText(XPERL_LOC_GHOST)

		elseif (UnitIsDead(partyid) or (self.feigning and conf.showFD)) then
			if (self.feigning or UnitIsFeignDeath(partyid)) then
				hbt:SetText(XPERL_LOC_FEIGNDEATH)
			else
				hbt:SetText(XPERL_LOC_DEAD)
			end

		elseif (UnitExists(partyid) and not UnitIsConnected(partyid)) then
			hbt:SetText(XPERL_LOC_OFFLINE)

		elseif (UnitIsAFK(partyid) and conf.showAFK) then
			hbt:SetText(CHAT_MSG_AFK)

		else
			color = true
		end
	end

	if (color) then
		XPerl_ColourHealthBar(self, hp / hpMax)

		if (self.statsFrame.greyMana) then
			self.statsFrame.greyMana = nil
			XPerl_Target_SetManaType(self)
		end
	else
		self.statsFrame:SetGrey()
	end
end

-- XPerl_Target_Update_Combat
function XPerl_Target_Update_Combat(self)
	if (UnitAffectingCombat(self.partyid)) then
		self.nameFrame.combatIcon:Show()
	else
		self.nameFrame.combatIcon:Hide()
	end
end

-- XPerl_Target_CombatFlash
local function XPerl_Target_CombatFlash(self, elapsed, argNew, argGreen)
	if (XPerl_CombatFlashSet (self, elapsed, argNew, argGreen)) then
		XPerl_CombatFlashSetFrames(self)
	end
end

-- XPerl_Target_Update_Range
function XPerl_Target_Update_Range(self)
	if (not self.conf.range30yard or CheckInteractDistance(self.partyid, 1) or not UnitIsConnected(self.partyid)) then
		self.nameFrame.rangeIcon:Hide()
	else
		self.nameFrame.rangeIcon:Show()
		self.nameFrame.rangeIcon:SetAlpha(1)
	end
end

-- XPerl_Target_UpdateLeader
local function XPerl_Target_UpdateLeader(self)
	local leader
	local partyid = self.partyid
	if (UnitIsUnit(partyid, "player")) then
		leader = IsPartyLeader()

	elseif (UnitInRaid(partyid)) then
		local find = UnitName(partyid)
		for i = 1,GetNumRaidMembers() do
			local name, rank = GetRaidRosterInfo(i)
			if (name == find) then
				leader = (rank == 2)
				break
			end
		end

	elseif (UnitInParty(partyid)) then
		local index = GetPartyLeaderIndex()
		if (index > 0) then
			leader = UnitIsUnit(partyid, "party"..index)
		end
	end

	if (leader) then
		self.nameFrame.leaderIcon:Show()
	else
		self.nameFrame.leaderIcon:Hide()
	end

	-- We can't determine who is master looter in raid if not in current party... :(
	local ml
	if (UnitInParty("party1") or UnitInRaid("player")) then
		local method, index = GetLootMethod()

		if (method == "master" and index) then
			if (index == 0 and UnitIsUnit("player", partyid)) then
				ml = true
			elseif (index >= 1 and index <= 4) then
				ml = UnitIsUnit(partyid, "party"..index)
			end
		end
	end

	if (ml) then
		self.nameFrame.masterIcon:Show()
	else
		self.nameFrame.masterIcon:Hide()
	end
end

-- RaidTargetUpdate
local function RaidTargetUpdate(self)
	local raidIcon = self.nameFrame.raidIcon

	XPerl_Update_RaidIcon(raidIcon, self.partyid)
	XPerl_Update_RaidIcon(self.eliteFrame.raidIcon, self.partyid)

	raidIcon:ClearAllPoints()
	if (self.conf.raidIconAlternate) then
		raidIcon:SetHeight(16)
		raidIcon:SetWidth(16)
		raidIcon:SetPoint("CENTER", self.nameFrame, "TOPRIGHT", -5, -4)
	else
		raidIcon:SetHeight(32)
		raidIcon:SetWidth(32)
		raidIcon:SetPoint("CENTER", self.nameFrame, "CENTER", 0, 0)
		self.eliteFrame.raidIcon:Hide()
	end
end

-- XPerl_Target_CheckDebuffs
local function XPerl_Target_CheckDebuffs(self)
	if (self.conf.highlightDebuffs.enable) then
       		if (self.conf.highlightDebuffs.who == 1 or
       			(self.conf.highlightDebuffs.who == 2 and UnitCanAssist("player", self.partyid)) or
       			(self.conf.highlightDebuffs.who == 3 and not UnitCanAssist("player", self.partyid))) then

       			XPerl_CheckDebuffs(self, self.partyid)
       		else
       			XPerl_CheckDebuffs(self, self.partyid, true)
       		end

		if (self.conf.reactionHighlight) then
			XPerl_Target_UpdatePVP(self)
		end
	end
end

-- XPerl_Target_UpdateDisplay
function XPerl_Target_UpdateDisplay(self)
	if (UnitExists(self.partyid)) then
		XPerl_NoFadeBars(true)

		XPerl_Target_UpdateName(self)
		XPerl_Target_UpdateClassification(self)
		XPerl_Target_UpdateLevel(self)
		XPerl_Target_UpdateType(self)
		XPerl_Target_SetManaType(self)
		XPerl_Target_SetMana(self)
		XPerl_Target_UpdateHealth(self)
		XPerl_Target_Update_Combat(self)

		RaidTargetUpdate(self)

		if (self.conf.defer) then
			self.portraitFrame.portrait:Hide()
			self.portraitFrame.portrait3D:Hide()
			self.nameFrame.leaderIcon:Hide()
			self.nameFrame.masterIcon:Hide()
			self.cpFrame:Hide()
			self.nameFrame.cpMeter:Hide()
			self.deferring = true
			self.RangeUpdate = -0.3
		else
			XPerl_Target_UpdateLeader(self)
			XPerl_Target_UpdateCombo(self)
			XPerl_Unit_UpdatePortrait(self)
		end

		XPerl_Highlight:SetHighlight(self, UnitGUID(self.partyid))
		XPerl_UpdateSpellRange(self, self.partyid)

		XPerl_NoFadeBars()

		-- Some optimizing here to limit the amount of work done on a target change
--[[
		local buffOptionString = tostring(self.statsFrame.manaBar:IsVisible() or 0)..tostring(self.bossFrame:IsVisible() or 0)..tostring(self.creatureTypeFrame:IsVisible() or 0)..tostring(self.statsFrame:GetWidth())
		if (self.buffOptionString ~= buffOptionString) then
			self.buffOptionString = buffOptionString
			-- Work out where all our buffs can fit, we only do this for a fresh target
			XPerl_Targets_BuffPositions(self)
		end
]]

		XPerl_Targets_BuffUpdate(self)
		XPerl_Target_DebuffUpdate(self)
		XPerl_Target_CheckDebuffs(self)

		XPerl_Target_UpdatePVP(self)
	end
end

-- XPerl_Target_OnUpdate
function XPerl_Target_OnUpdate(self, elapsed)
	CombatFeedback_OnUpdate(elapsed)

	self.RangeUpdate = self.RangeUpdate + elapsed
	if (self.RangeUpdate > 0.2) then
		self.RangeUpdate = 0
		XPerl_Target_Update_Range(self)
		XPerl_UpdateSpellRange(self)

		if (self.deferring) then
			self.deferring = nil
			XPerl_Target_UpdateLeader(self)
                	XPerl_Target_Update_Combat(self)
			XPerl_Target_UpdateCombo(self)
			XPerl_Unit_UpdatePortrait(self)
			RaidTargetUpdate(self)
		end
	end
	if (self.PlayerFlash) then
		XPerl_Target_CombatFlash(self, elapsed, false)
	end
end

-------------------
-- Event Handler --
-------------------
function XPerl_Target_OnEvent(self, event, ...)
	local func = XPerl_Target_Events[event]
	if (func) then
		func(self, ...)
	else
XPerl_ShowMessage("EXTRA EVENT")
	end
end

-- VARIABLES_LOADED
function XPerl_Target_Events:VARIABLES_LOADED()
	if (XPerl_Target_GetHealthMH3) then
		local mh4 = AceLibrary and AceLibrary:HasInstance("LibMobHealth-4.0") and AceLibrary("LibMobHealth-4.0")

		if (mh4) then
			mobhealth = mh4
			XPerl_Target_GetHealth = XPerl_Target_GetHealthMH3
		elseif (MobHealth3) then
			mobhealth = MobHealth3
			XPerl_Target_GetHealth = XPerl_Target_GetHealthMH3
		elseif (MobHealthDB) then
			XPerl_Target_GetHealth = XPerl_Target_GetHealthMI2
		end

		XPerl_Target_GetHealthMH3 = nil
		XPerl_Target_GetHealthMI2 = nil

		XPerl_Target_Events.VARIABLES_LOADED = nil
	end
end

-- PLAYER_ENTERING_WORLD
function XPerl_Target_Events:PLAYER_ENTERING_WORLD()
	if (UnitExists("focus")) then
		self.feigning = nil
		self.PlayerFlash = 0
		XPerl_CombatFlashSetFrames(self)
		XPerl_Target_UpdateDisplay(self)
	end
end

local bit_band = bit.band

local amountIndex = {
	SWING_DAMAGE = 1,
	RANGE_DAMAGE = 4,
	SPELL_DAMAGE = 4,
	DAMAGE_SHIELD = 4,
	ENVIRONMENTAL_DAMAGE = 2,
}
local missIndex = {
	SWING_MISSED = 1,
	RANGE_MISSED = 4,
	SPELL_MISSED = 4,
	SPELL_PERIODIC_MISSED = 4,
}

-- DoEvent
local function DoEvent(self, timestamp, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
	local feedbackText = self.feedbackText
	local fontHeight = self.feedbackFontHeight
	local text
	local r = 1
	local g = 1
	local b = 1

	if (event == "SWING_DAMAGE" or event == "RANGE_DAMAGE" or event == "SPELL_DAMAGE" or event == "DAMAGE_SHIELD" or event == "ENVIRONMENTAL_DAMAGE") then
		local amount, school, resisted, blocked, absorbed, critical, glancing, crushing = select(amountIndex[event], ...)
		if (amount and amount ~= 0) then
			if (critical or crushing) then
				fontHeight = fontHeight * 1.5
			elseif (glancing) then
				fontHeight = fontHeight * 0.75;
			end
			if (event ~= "SWING_DAMAGE" and event ~= "RANGE_DAMAGE") then
				b = 0
			end
			text = amount
		end

	elseif (event == "SWING_MISSED" or event == "RANGE_MISSED" or event == "SPELL_MISSED" or event == "SPELL_PERIODIC_MISSED") then
		local missType = select(missIndex[event], ...)
		if (missType) then
			text = CombatFeedbackText[missType]
		end

	elseif (event == "SPELL_HEAL" or event == "SPELL_PERIODIC_HEAL") then
		local amount, critical = select(4, ...)
		if (amount and amount ~= 0) then
			if (critical) then
				fontHeight = fontHeight * 1.5
			end
			r = 0
			g = 1
			b = 0
			text = amount
		end
	end

	if (text) then
		self.feedbackStartTime = GetTime()

		feedbackText:SetTextHeight(fontHeight)
		feedbackText:SetText(text)
		feedbackText:SetTextColor(r, g, b)
		feedbackText:SetAlpha(0)
		feedbackText:Show()
	end
end

-- COMBAT_LOG_EVENT_UNFILTERED
function XPerl_Target_Events:COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
	if (self.conf.hitIndicator and self.conf.portrait) then
		if (bit_band(dstFlags, self.combatMask) ~= 0 and bit_band(srcFlags, 0x00000001) ~= 0) then
			DoEvent(self, timestamp, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		end
	end
end

-- UNIT_COMBAT
function XPerl_Target_Events:UNIT_COMBAT()
	if (arg1 == self.partyid) then
		XPerl_Target_Update_Combat(self)

		if (not self.conf.ownDamageOnly) then
			if (self.conf.hitIndicator and self.conf.portrait) then
				CombatFeedback_OnCombatEvent(arg2, arg3, arg4, arg5)
			end
		end

		if (arg2 == "HEAL") then
			XPerl_Target_CombatFlash(self, 0, true, true)
		elseif (arg4 and arg4 > 0) then
			XPerl_Target_CombatFlash(self, 0, true)
		end
	end
end

-- UNIT_SPELLMISS
function XPerl_Target_Events:UNIT_SPELLMISS()
	if (self.conf.hitIndicator and self.conf.portrait) then
		CombatFeedback_OnSpellMissEvent(arg2)
	end
end

-- PLAYER_TARGET_CHANGED
function XPerl_Target_Events:PLAYER_TARGET_CHANGED()
	if (self == XPerl_Target) then
		if (self.conf.sound and UnitExists("target")) then
			if (UnitIsEnemy("target", "player")) then
				PlaySound("igCreatureAggroSelect")
			elseif (UnitIsFriend("player", "target")) then
				PlaySound("igCharacterNPCSelect")
			else
				PlaySound("igCreatureNeutralSelect")
			end
		end

		if (UnitIsUnit("target", "focus")) then
			XPerl_Target.statsFrame.focusTarget:Show()
		else
			XPerl_Target.statsFrame.focusTarget:Hide()
		end
	end

	self.feigning = nil
	self.PlayerFlash = 0
	XPerl_CombatFlashSetFrames(self)
	XPerl_Target_UpdateDisplay(self)
end

XPerl_Target_Events.PLAYER_FOCUS_CHANGED = XPerl_Target_Events.PLAYER_TARGET_CHANGED

-- UNIT_HEALTH, UNIT_MAXHEALTH
function XPerl_Target_Events:UNIT_HEALTH()
	XPerl_Target_UpdateHealth(self)
end
XPerl_Target_Events.UNIT_MAXHEALTH = XPerl_Target_Events.UNIT_HEALTH

-- UNIT_DYNAMIC_FLAGS
function XPerl_Target_Events:UNIT_DYNAMIC_FLAGS()
	XPerl_Target_UpdateName(self)
	XPerl_Target_UpdatePVP(self)
	XPerl_Target_Update_Combat(self)
end

XPerl_Target_Events.UNIT_FLAGS = XPerl_Target_Events.UNIT_DYNAMIC_FLAGS

-- RAID_TARGET_UPDATE
function XPerl_Target_Events:RAID_TARGET_UPDATE()
	RaidTargetUpdate(XPerl_Target)
	RaidTargetUpdate(XPerl_Focus)
end

-- UNIT_MANA, UNIT_MAXMANA, UNIT_RAGE, UNIT_MAXRAGE, UNIT_ENERGY
-- UNIT_MAXENERGY, UNIT_FOCUS, UNIT_MAXFOCUS
function XPerl_Target_Events:UNIT_MANA()
	XPerl_Target_SetMana(self)
end
XPerl_Target_Events.UNIT_MAXMANA	= XPerl_Target_Events.UNIT_MANA
XPerl_Target_Events.UNIT_RAGE		= XPerl_Target_Events.UNIT_MANA
XPerl_Target_Events.UNIT_MAXRAGE	= XPerl_Target_Events.UNIT_MANA
XPerl_Target_Events.UNIT_ENERGY		= XPerl_Target_Events.UNIT_MANA
XPerl_Target_Events.UNIT_MAXENERGY	= XPerl_Target_Events.UNIT_MANA
XPerl_Target_Events.UNIT_FOCUS		= XPerl_Target_Events.UNIT_MANA
XPerl_Target_Events.UNIT_MAXFOCUS	= XPerl_Target_Events.UNIT_MANA

-- UNIT_DISPLAYPOWER
function XPerl_Target_Events:UNIT_DISPLAYPOWER()
	XPerl_Target_SetManaType(self)
	XPerl_Target_SetMana(self)
end

-- UNIT_PORTRAIT_UPDATE
function XPerl_Target_Events:UNIT_PORTRAIT_UPDATE()
	XPerl_Unit_UpdatePortrait(self)
end

-- UNIT_NAME_UPDATE
function XPerl_Target_Events:UNIT_NAME_UPDATE()
	XPerl_Target_UpdateName(self)
	XPerl_Target_UpdateHealth(self)
	XPerl_Target_UpdateClassification(self)
end

-- UNIT_LEVEL
function XPerl_Target_Events:UNIT_LEVEL()
	XPerl_Target_UpdateLevel(self)
	XPerl_Target_UpdateClassification(self)
end

-- UNIT_CLASSIFICATION_CHANGED
function XPerl_Target_Events:UNIT_CLASSIFICATION_CHANGED()
	XPerl_Target_UpdateClassification(self)
end

-- PLAYER_COMBO_POINTS
function XPerl_Target_Events:PLAYER_COMBO_POINTS()
	XPerl_Target_UpdateCombo(self)
end

-- UNIT_AURA
function XPerl_Target_Events:UNIT_AURA()
	XPerl_Target_CheckDebuffs(self, self.partyid)

	--if (not self.perlBuffs or XPerl_UnitBuff(self.partyid, self.perlBuffs + 1, self.conf.buffs.castable)) then
	--	XPerl_Targets_BuffPositions(self)
	--elseif (XPerl_UnitDebuff(self.partyid, self.perlDebuffs + 1, self.conf.debuffs.curable)) then
	--	XPerl_Targets_BuffPositions(self)
	--end

	XPerl_Targets_BuffUpdate(self)
	XPerl_Target_DebuffUpdate(self)

	if (select(2, UnitClass(self.partyid)) == "HUNTER") then
		local f = UnitIsFeignDeath(self.partyid)
		if (f ~= self.feigning) then
			self.feigning = f
			XPerl_Target_UpdateHealth(self)
		end
	end
end

-- UNIT_FACTION
function XPerl_Target_Events:UNIT_FACTION()
	XPerl_Target_UpdatePVP(self)
	XPerl_Targets_BuffPositions(self)
end

-- PLAYER_FLAGS_CHANGED
function XPerl_Target_Events:PLAYER_FLAGS_CHANGED()
	XPerl_Target_Update_Combat(self)
	XPerl_Target_UpdatePVP(self)
	XPerl_Target_UpdateHealth(self)
end

-- PARTY_MEMBER_ENABLE
function XPerl_Target_Events:PARTY_MEMBER_ENABLE()
	if (UnitInParty(self.partyid)) then
		XPerl_Target_Update_Combat(self)
		XPerl_Target_UpdatePVP(self)
		XPerl_Target_UpdateHealth(self)
	end
end

XPerl_Target_Events.PARTY_MEMBER_DISABLE = XPerl_Target_Events.PARTY_MEMBER_ENABLE

-- PARTY_LOOT_METHOD_CHANGED
function XPerl_Target_Events:PARTY_LOOT_METHOD_CHANGED()
	XPerl_Target_UpdateLeader(self)
end
XPerl_Target_Events.PARTY_MEMBERS_CHANGED = XPerl_Target_Events.PARTY_LOOT_METHOD_CHANGED
XPerl_Target_Events.PARTY_LEADER_CHANGED  = XPerl_Target_Events.PARTY_LOOT_METHOD_CHANGED

-- INSPECT_TALENT_READY
function XPerl_Target_Events:INSPECT_TALENT_READY()
	lastInspectPending = lastInspectPending - 1
	if (lastInspectPending == 0) then
		if (not lastInspectInvalid) then
			XPerl_Target_UpdateTalents(self)
		end
		lastInspectInvalid = nil
	end
end

-- XPerl_Target_SetWidth
function XPerl_Target_SetWidth(self)

	self.conf.size.width = max(0, self.conf.size.width or 0)
	local w = 128 + ((self.conf.portrait or 0) * 60) + ((self.conf.percent or 0) * 32) + self.conf.size.width

	self:SetWidth(w)

	if (self.conf.percent) then
		self.nameFrame:SetWidth(160 + self.conf.size.width)
		self.statsFrame:SetWidth(160 + self.conf.size.width)
		self.statsFrame.healthBar.percent:Show()
		self.statsFrame.manaBar.percent:Show()
	else
		self.nameFrame:SetWidth(128 + self.conf.size.width)
		self.statsFrame:SetWidth(128 + self.conf.size.width)
		self.statsFrame.healthBar.percent:Hide()
		self.statsFrame.manaBar.percent:Hide()
	end

	self.conf.scale = self.conf.scale or 0.8
	self:SetScale(self.conf.scale)

	XPerl_SavePosition(self, true)
end

-- XPerl_Target_Set_Bits
function XPerl_Target_Set_Bits(self)
	local _
	_, playerClass = UnitClass("player")

	self.buffOptionString = nil

	if (self.conf.portrait) then
		self.portraitFrame:Show()
		self.portraitFrame:SetWidth(60)
	else
		self.portraitFrame:Hide()
		self.portraitFrame:SetWidth(2)
	end

	if (self.conf.values) then
		self.statsFrame.healthBar.text:Show()
		self.statsFrame.manaBar.text:Show()
	else
		self.statsFrame.healthBar.text:Hide()
		self.statsFrame.manaBar.text:Hide()
	end

	self.eliteFrame:SetFrameLevel(self.portraitFrame:GetFrameLevel() + 3)

	if (self.conf.level) then
		self.levelFrame:Show()
	else
		self.levelFrame:Hide()
	end

	if (self.conf.classIcon) then
		self.typeFramePlayer.classTexture:Show()
	else
		self.typeFramePlayer.classTexture:Hide()
	end

	self.highlight:SetPoint("BOTTOMRIGHT", self.portraitFrame, "BOTTOMRIGHT", 26, -1)

	self.conf.buffs.size = tonumber(self.conf.buffs.size) or 20
	XPerl_SetBuffSize(self)

	XPerl_Target_SetWidth(self)

	if (self.conf.enable) then
		RegisterUnitWatch(self)
	else
		self:Hide()
		UnregisterUnitWatch(self)
	end

	if (self == XPerl_Target) then
		XPerl_Target_Set_BlizzCPFrame(self)
	end

	XPerl_StatsFrameSetup(self)

	if (self.conf.ownDamageOnly and (self.conf.hitIndicator and self.conf.portrait)) then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end

	self.buffFrame:ClearAllPoints()
	if (self.conf.buffs.above) then
		self.buffFrame:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 2, 0)
	else
		self.buffFrame:SetPoint("TOPLEFT", self.statsFrame, "BOTTOMLEFT", 2, 0)
	end
	self.buffOptMix = nil

	if (self:IsShown()) then
		XPerl_Target_UpdateDisplay(self)
	end
end

-- Using the Blizzard Combo Point frame, but we move the buttons around a little
function XPerl_Target_Set_BlizzCPFrame(self)
	ComboFrame:ClearAllPoints()
	ComboPoint1:ClearAllPoints()
	ComboPoint2:ClearAllPoints()
	ComboPoint3:ClearAllPoints()
	ComboPoint4:ClearAllPoints()
	ComboPoint5:ClearAllPoints()

	if (tconf.combo.blizzard) then
		-- This setup will put the buttons along the top of the portrait frame

		ComboFrame:SetScale(self.conf.scale)

		if (tconf.combo.pos == "top") then
			ComboFrame:SetPoint("TOPLEFT", self.portraitFrame, "TOPLEFT", -1, 4)
			ComboPoint1:SetPoint("TOPLEFT", 0, 0)
			ComboPoint2:SetPoint("LEFT", ComboPoint1, "RIGHT", 0, 1)
			ComboPoint3:SetPoint("LEFT", ComboPoint2, "RIGHT", 0, 1)
			ComboPoint4:SetPoint("LEFT", ComboPoint3, "RIGHT", 0, -1)
			ComboPoint5:SetPoint("LEFT", ComboPoint4, "RIGHT", 0, -4)

		elseif (tconf.combo.pos == "bottom") then
			ComboFrame:SetPoint("BOTTOMLEFT", self.portraitFrame, "BOTTOMLEFT", -1, -4)
			ComboPoint1:SetPoint("BOTTOMLEFT", 0, 0)
			ComboPoint2:SetPoint("LEFT", ComboPoint1, "RIGHT", 0, -1)
			ComboPoint3:SetPoint("LEFT", ComboPoint2, "RIGHT", 0, -1)
			ComboPoint4:SetPoint("LEFT", ComboPoint3, "RIGHT", 0, 1)
			ComboPoint5:SetPoint("LEFT", ComboPoint4, "RIGHT", 0, -1)

		elseif (tconf.combo.pos == "left") then
			ComboFrame:SetPoint("BOTTOMLEFT", self.portraitFrame, "BOTTOMLEFT", -1, 0)
			ComboPoint1:SetPoint("BOTTOMLEFT", 0, 0)
			ComboPoint2:SetPoint("BOTTOM", ComboPoint1, "TOP", -1, 0)
			ComboPoint3:SetPoint("BOTTOM", ComboPoint2, "TOP", -1, 0)
			ComboPoint4:SetPoint("BOTTOM", ComboPoint3, "TOP", 1, 0)
			ComboPoint5:SetPoint("BOTTOM", ComboPoint4, "TOP", 3, -5)

		elseif (tconf.combo.pos == "right") then
			ComboFrame:SetPoint("BOTTOMRIGHT", self.portraitFrame, "BOTTOMRIGHT", 2, 0)
			ComboPoint1:SetPoint("BOTTOMRIGHT", 0, 0)
			ComboPoint2:SetPoint("BOTTOM", ComboPoint1, "TOP", 1, 0)
			ComboPoint3:SetPoint("BOTTOM", ComboPoint2, "TOP", 1, 0)
			ComboPoint4:SetPoint("BOTTOM", ComboPoint3, "TOP", -1, 0)
			ComboPoint5:SetPoint("BOTTOM", ComboPoint4, "TOP", 0, -5)

		end

		ComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
		ComboFrame:RegisterEvent("PLAYER_COMBO_POINTS")
	else
		ComboFrame:Hide()
		ComboFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
		ComboFrame:UnregisterEvent("PLAYER_COMBO_POINTS")
	end
end
