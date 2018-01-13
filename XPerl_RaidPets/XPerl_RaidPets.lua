-- X-Perl UnitFrames
-- Author: Zek <Boodhoof-EU>
-- License: GNU GPL v3, 29 June 2007 (see LICENSE.txt)

local XPerl_RaidPets_Events = {}
local RaidPetFrameArray = {}
local conf, rconf
XPerl_RequestConfig(function(New) conf = New raidconf = New.raid rconf = New.raidpet end, "$Revision: 184 $")

local new, del, copy = XPerl_GetReusableTable, XPerl_FreeTable, XPerl_CopyTable

-- XPerl_RaidPets_OnEvent
local function XPerl_RaidPets_OnEvent(self, event, unit, ...)
	local func = XPerl_RaidPets_Events[event]
	if (func) then
		if (strfind(event, "^UNIT_")) then
			local f = RaidPetFrameArray[unit]
			if (f) then
				func(f, ...)
			end
		else
			func(self, unit, ...)
		end
	else
XPerl_ShowMessage("EXTRA EVENT")
	end
end

-- XPerl_RaidPets_OnUpdate
local function XPerl_RaidPets_OnUpdate(self, elapsed)
	self.time = self.time + elapsed
	if (self.time > 0.3) then
		for unit,frame in pairs(RaidPetFrameArray) do
			if (unit) then
				XPerl_UpdateSpellRange(frame, unit, true)
			end
		end
	end
end

local XPerl_RaidPets_HighlightCallback
do
	local guids
	-- XPerl_RaidPet_UpdateGUIDs
	function XPerl_RaidPet_UpdateGUIDs()
		del(guids)
		guids = new()
		for i = 1,GetNumRaidMembers() do
			local id = "raidpet"..i
			if (UnitExists(id)) then
				guids[UnitGUID(id)] = RaidPetFrameArray[id]
			end
		end
	end

	-- XPerl_Raid_Pet_GetUnitFrameByGUID
	function XPerl_Raid_Pet_GetUnitFrameByGUID(guid)
		return guids and guids[guid]
	end
	
	-- XPerl_RaidPets_HighlightCallback
	function XPerl_RaidPets_HighlightCallback(self, updateGUID)
		local f = guids and guids[guid]
		if (f) then
			XPerl_Highlight:SetHighlight(f, updateGUID)
		end
	end
end

-- XPerl_Raid_Pet_GetUnitFrameByUnit
function XPerl_Raid_Pet_GetUnitFrameByUnit(unitid)
	for k,v in pairs(RaidPetFrameArray) do
		if (v.partyid and UnitIsUnit(v.partyid, unitid)) then
			return v
		end
	end
end

-- XPerl_RaidPets_OnLoad
function XPerl_RaidPets_OnLoad(self)
	self.time = 0
	self.Array = {}

	XPerl_Raid_GrpPets:UnregisterEvent("UNIT_NAME_UPDATE")		-- Fix for WoW 2.1 UNIT_NAME_UPDATE issue

	self:SetScript("OnEvent", XPerl_RaidPets_OnEvent)
	self:SetScript("OnUpdate", XPerl_RaidPets_OnUpdate)

	XPerl_Highlight:Register(XPerl_RaidPets_HighlightCallback, self)

	XPerl_RaidPets_OnLoad = nil
end

-- XPerl_RaidPet_UpdateName
local function XPerl_RaidPet_UpdateName(self)
	local partyid = SecureButton_GetUnit(self)
	local name
	if (partyid) then
		name = UnitName(partyid)
	end
	--local color

	self.lastName = name

	if (not name or name == UNKNOWNOBJECT) then
		name = "no pet"
		--color = conf.ColourTapped
		self:SetAlpha(0.1)
		self.healthBar:SetValue(0)
		XPerl_SetSmoothBarColor(self.healthBar, 0)
	else
		--color = conf.ColourReactionNone
		self:SetAlpha(conf.transparency.frame)
	end

	self.text:SetText(name)

	local partyid = self:GetAttribute("unit")			-- The OWNER unit, not the pet
	if (partyid) then
		local c = XPerl_GetClassColour(select(2, UnitClass(partyid)))
		self.text:SetTextColor(c.r, c.g, c.b)
	else
		self.text:SetTextColor(1, 1, 1)
	end
end

-- XPerl_RaidPet_UpdateHealth
local function XPerl_RaidPet_UpdateHealth(self)
	local partyid = SecureButton_GetUnit(self)
	if (not partyid) then
		self.healthBar:SetValue(0)
		XPerl_SetSmoothBarColor(self.healthBar, 0)
		return
	end

	local health = UnitHealth(partyid)
	local healthmax = UnitHealthMax(partyid)

	if (health > healthmax) then
		-- New glitch with 1.12.1
		if (UnitIsDeadOrGhost(partyid)) then
			health = 0
		else
			health = healthmax
		end
	end

	self.healthBar:SetMinMaxValues(0, healthmax)
	if (conf.bar.inverse) then
		self.healthBar:SetValue(healthmax - health)
	else
		self.healthBar:SetValue(health)
	end
	XPerl_SetSmoothBarColor(self.healthBar, health / healthmax)

	if (UnitIsDead(partyid)) then
		self.healthBar.text:SetText(XPERL_LOC_DEAD)
	else
		if (healthmax == 0) then
			self.healthBar.text:SetText("")
		else
			self.healthBar.text:SetFormattedText("%d%%", health / healthmax * 100)
		end
	end
end

-- XPerl_RaidPets_UpdateDisplay
local function XPerl_RaidPets_UpdateDisplay(self)
	XPerl_RaidPet_UpdateName(self)
	XPerl_RaidPet_UpdateHealth(self)
	local unit = SecureButton_GetUnit(self)
	if (unit) then
		XPerl_Highlight:SetHighlight(self, UnitGUID(unit))
	end
end

-- VARIABLES_LOADED
function XPerl_RaidPets_Events:VARIABLES_LOADED()
	self:UnregisterEvent("VARIABLES_LOADED")

	XPerl_Raid_TitlePets:SetScale((conf.raid and conf.raid.scale) or 0.8)

	XPerl_RaidPets_ChangeAttributes()

	XPerl_RaidPets_Events.VARIABLES_LOADED = nil
end

-- PLAYER_ENTERING_WORLD
function XPerl_RaidPets_Events:PLAYER_ENTERING_WORLD()
	XPerl_RaidPet_UpdateGUIDs()
	XPerl_RaidPets_Titles()
end

-- UNIT_PET
function XPerl_RaidPets_Events:UNIT_PET()
	XPerl_RaidPet_UpdateGUIDs()
end

-- RAID_ROSTER_UPDATE
function XPerl_RaidPets_Events:RAID_ROSTER_UPDATE()
	XPerl_RaidPets_Titles()
end

-- UNIT_HEALTH
function XPerl_RaidPets_Events:UNIT_HEALTH()
	XPerl_RaidPet_UpdateHealth(self)
end

-- UNIT_HEALTHMAX
XPerl_RaidPets_Events.UNIT_MAXHEALTH = XPerl_RaidPets_Events.UNIT_HEALTH

-- UNIT_NAME_UPDATE
function XPerl_RaidPets_Events:UNIT_NAME_UPDATE()
	XPerl_RaidPet_UpdateGUIDs()
	XPerl_RaidPet_UpdateName(self)
end

function XPerl_RaidPets_Events:UNIT_AURA()
	XPerl_CheckDebuffs(self, SecureButton_GetUnit(self))
end

-- SetFrameArray
local function SetFrameArray(self, value)
	for k,v in pairs(RaidPetFrameArray) do
		if (v == self) then
			RaidPetFrameArray[k] = nil
		end
	end

	self.partyid = value

	if (value) then
		RaidPetFrameArray[value] = self
	end
end

-- onAttrChanged
local function onAttrChanged(self, name, value)
	if (name == "unit") then
		if (value) then
			SetFrameArray(self, "raidpet"..strmatch(value, "^raid(%d+)"))
			self.ownerid = value

			if (self.lastName ~= UnitName(self.partyid)) then
				XPerl_RaidPets_UpdateDisplay(self)
			end
		else
			SetFrameArray(self)
			self.lastID = nil
			self.lastName = nil
		end
	end
end

-- XPerl_RaidPet_Single_OnLoad
function XPerl_RaidPet_Single_OnLoad(self)
	XPerl_SetChildMembers(self)
	XPerl_RegisterPerlFrames(self)
	self:SetScript("OnAttributeChanged", onAttrChanged)
	XPerl_RegisterClickCastFrame(self)
	XPerl_RegisterHighlight(self.highlight, 2)

	self.FlashFrames = {self}

	self:SetScript("OnShow", XPerl_RaidPets_UpdateDisplay)
end

-- SetMainHeaderAttributes
local function SetMainHeaderAttributes(self)

	self:Hide()

	local classes = {}
	if (rconf.hunter) then
		tinsert(classes, "HUNTER")
	end
	if (rconf.warlock) then
		tinsert(classes, "WARLOCK")
	end

	self:SetAttribute("groupFilter", table.concat(classes, ","))

	self:SetAttribute("unitsPerColumn", 5)			-- Don't grow taller than a standard raid group
	self:SetAttribute("columnAnchorPoint", "LEFT")

	self:SetAttribute("point", conf.raid.anchor)
	self:SetAttribute("minWidth", 80)
	self:SetAttribute("minHeight", 10)
	local titleFrame = self:GetParent()
	self:ClearAllPoints()
	if (conf.raid.anchor == "TOP") then
		self:SetPoint("TOP", titleFrame, "BOTTOM", 0, 0)
		self:SetAttribute("xOffset", 0)
		self:SetAttribute("yOffset", 2 + -conf.raid.spacing)
	elseif (conf.raid.anchor == "LEFT") then
		self:SetPoint("TOPLEFT", titleFrame, "BOTTOMLEFT", 0, 0)
		self:SetAttribute("xOffset", -2 + conf.raid.spacing)
		self:SetAttribute("yOffset", 0)
	elseif (conf.raid.anchor == "BOTTOM") then
		self:SetPoint("BOTTOM", titleFrame, "TOP", 0, 0)
		self:SetAttribute("xOffset", 0)
		self:SetAttribute("yOffset", -2 + conf.raid.spacing)
	elseif (conf.raid.anchor == "RIGHT") then
		self:SetPoint("TOPRIGHT", titleFrame, "BOTTOMRIGHT", 0, 0)
		self:SetAttribute("xOffset", 2 + -conf.raid.spacing)
		self:SetAttribute("yOffset", 0)
	end
	self:SetAttribute("template", "XPerl_RaidPet_FrameTemplate")
	self:SetAttribute("templateType", "Button")

	self.initialConfigFunction = function(self)
		-- This is the only place we're allowed to set attributes whilst in combat
		self:SetAttribute("unitsuffix", "pet")
		self:SetAttribute("*type1", "target")
		self:SetAttribute("initial-height", 35)
		XPerl_RaidPets_UpdateDisplay(self)
	end
end

-- XPerl_RaidPets_ChangeAttributes
function XPerl_RaidPets_ChangeAttributes()
	XPerl_ProtectedCall(SetMainHeaderAttributes, XPerl_Raid_GrpPets)
end

-- XPerl_RaidPets_HideShow
function XPerl_RaidPets_HideShow()
	local singleGroup
	if (XPerl_Party_SingleGroup) then
		if (conf.party.smallRaid) then
			singleGroup = XPerl_Party_SingleGroup()
		end
	end

	local on = (GetNumRaidMembers() > 0 and rconf.enable)

	local events = {"UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_NAME_UPDATE", "UNIT_AURA"}
	for i,event in pairs(events) do
		if (on) then
			XPerl_RaidPets_Frame:RegisterEvent(event)
		else
			XPerl_RaidPets_Frame:UnregisterEvent(event)
		end
	end

	if (rconf.enable and GetNumRaidMembers() > 0 and not singleGroup) then
		XPerl_RaidPets_Frame:Show()
		XPerl_Raid_TitlePets:Show()
		XPerl_Raid_GrpPets:Show()
	else
		XPerl_RaidPets_Frame:Hide()
		XPerl_Raid_TitlePets:Hide()
		XPerl_Raid_GrpPets:Hide()
	end
end

-- XPerl_RaidPets_Align()
function XPerl_RaidPets_Align()
	if (rconf.alignToRaid) then
		local counts = XPerl_RaidGroupCounts()
		local lastUsed = 0
		if (counts) then
			for i = 1,9 do
				if (counts[i] > 0) then
					lastUsed = i
				end
			end
		end

		if (lastUsed > 0) then
			local relative = getglobal("XPerl_Raid_Title"..lastUsed)
			if (relative) then
				XPerl_Raid_TitlePets:SetPoint("TOPLEFT", relative, "TOPRIGHT", raidconf.spacing - 2, 2)
				XPerl_Raid_TitlePets:SetUserPlaced(true)
			end
		end

		XPerl_Raid_TitlePets:EnableMouse(false)
	else
		XPerl_Raid_TitlePets:EnableMouse(true)
	end
end

-- XPerl_RaidPets_Titles
function XPerl_RaidPets_Titles()
	if (rconf.hunter) then
		if (rconf.warlock) then
			XPerl_Raid_TitlePets.text:SetText(XPERL_LOC_CLASS_PETS)
		else
			XPerl_Raid_TitlePets.text:SetText(XPERL_LOC_CLASS_PETSHUNTER)
		end
	elseif (rconf.warlock) then
		XPerl_Raid_TitlePets.text:SetText(XPERL_LOC_CLASS_PETSWARLOCK)
	end

	local show
	for i = 1,GetNumRaidMembers() do
		local unitName, rank, group, level, _, unitClass = GetRaidRosterInfo(i)
		if (unitClass == "HUNTER" or unitClass == "WARLOCK") then
			show = true
			break
		end
	end

	if (XPerlLocked == 0 or (rconf.enable and show and conf.raid.titles)) then
		XPerl_Raid_TitlePets.text:Show()
	else
		XPerl_Raid_TitlePets.text:Hide()
	end

	XPerl_ProtectedCall(XPerl_RaidPets_HideShow)
end

-- XPerl_RaidPets_OptionActions
function XPerl_RaidPets_OptionActions()
	SetMainHeaderAttributes(XPerl_Raid_GrpPets)

	local events = {"PLAYER_ENTERING_WORLD", "VARIABLES_LOADED", "RAID_ROSTER_UPDATE", "UNIT_PET"}
	for i,event in pairs(events) do
		if (rconf.enable) then
			XPerl_RaidPets_Frame:RegisterEvent(event)
		else
			XPerl_RaidPets_Frame:UnregisterEvent(event)
		end
	end

	XPerl_RaidPets_Titles()
	XPerl_Raid_TitlePets:SetScale((conf.raid and conf.raid.scale) or 0.8)

	if (rconf.enable) then
		XPerl_Raid_TitlePets:Show()
	else
		XPerl_Raid_TitlePets:Hide()
	end
end

XPerl_RegisterOptionChanger(XPerl_RaidPets_OptionActions, "RaidPets")
