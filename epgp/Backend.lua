local L = EPGPGlobalStrings

local mod = EPGP:NewModule("EPGP_Backend", "AceEvent-2.0")

local function OnStaticPopupHide()
	if ChatFrameEditBox:IsShown() then
		ChatFrameEditBox:SetFocus()
	end
	getglobal(this:GetName().."EditBox"):SetText("")
end

local function GuildIterator(obj, i)
  local name = GetGuildRosterInfo(i)
  -- Handle dummies
  if obj.cache:IsDummy(name) then
    name = EPGP.db.profile.dummies[name]
  end
  if not name then return end
  return i+1, name
end

local function RaidIterator(obj, i)
  if not UnitInRaid("player") then return end
  local name = GetRaidRosterInfo(i)
  if not name then return end
  return i+1, name
end

local function GuildOnlineIterator(obj, i)
  local name, online
  repeat
    name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
    i = i + 1
  until not name or online
  -- Handle dummies
  if obj.cache:IsDummy(name) then
    name = EPGP.db.profile.dummies[name]
  end

  if not name then return end
  return i, name
end

local ITERATORS = {
  ["GUILD"] = GuildIterator,
  ["RAID"] = RaidIterator,
  ["GUILD_ONLINE_LABEL"] = GuildOnlineIterator,
}

local LISTING_IDS = {
  "GUILD",
  "RAID",
  "GUILD_ONLINE_LABEL",
}

function mod:GetListingIDs()
  return LISTING_IDS
end

function mod:OnInitialize()
  self.cache = EPGP:GetModule("EPGP_Cache")
  StaticPopupDialogs["EPGP_RESET_EPGP"] = {
    text = L["Reset all EP and GP to 0 and make officer notes readable by all?"],
    button1 = ACCEPT,
    button2 = CANCEL,
    timeout = 0,
    OnAccept = function()
      mod:ResetEPGP()
    end,
    hideOnEscape = 1,
    whileDead = 1,
  }
  StaticPopupDialogs["EPGP_DECAY_EPGP"] = {
    text = L["Decay EP and GP by %d%%?"],
    button1 = ACCEPT,
    button2 = CANCEL,
    timeout = 0,
    OnAccept = function()
      mod:DecayEPGP()
    end,
    hideOnEscape = 1,
    whileDead = 1,
  }
  StaticPopupDialogs["EPGP_RESTORE_NOTES"] = {
    text = L["Restore public and officer notes from the last backup?"],
    button1 = ACCEPT,
    button2 = CANCEL,
    timeout = 0,
    OnAccept = function()
      mod:RestoreNotes()
    end,
    hideOnEscape = 1,
    whileDead = 1,
  }
  self.popup_modify_epgp_data = {}
  StaticPopupDialogs["EPGP_MODIFY_EPGP"] = {
    text = "%s",
    button1 = ACCEPT,
    button2 = CANCEL,
    timeout = 0,
    OnShow = function()
      local editBox = getglobal(this:GetName().."EditBox")
      editBox:SetFocus()
    end,
    OnHide = OnStaticPopupHide,
    OnAccept = function()
      local data = self.popup_modify_epgp_data
      local editBox = getglobal(this:GetParent():GetName().."EditBox")
      local number = editBox:GetNumber()
      if not data.valid_func or data.valid_func(number) then
        data.func(mod, data.member, number)
      end
    end,
    EditBoxOnEnterPressed = function()
      local data = self.popup_modify_epgp_data
      local editBox = getglobal(this:GetParent():GetName().."EditBox")
      local number = editBox:GetNumber()
      if not data.valid_func or data.valid_func(number) then
        data.func(mod, data.member, number)
        this:GetParent():Hide()
      end
    end,
    EditBoxOnTextChanged = function()
      local data = self.popup_modify_epgp_data
      local editBox = getglobal(this:GetParent():GetName().."EditBox")
      local button1 = getglobal(this:GetParent():GetName().."Button1")
      local number = editBox:GetNumber()
      if not data.valid_func or data.valid_func(number) then
        button1:Enable()
      else
        button1:Disable()
      end
    end,
    EditBoxOnEscapePressed = function()
      this:GetParent():Hide()
    end,
    hideOnEscape = 1,
    hasEditBox = 1,
    whileDead = 1,
  }
  self.popup_unzoned_members_data = {}
  StaticPopupDialogs["EPGP_UNZONED_MEMBERS_POPUP"] = {
    text = L["Do you want to include members not in %s in the award? (%s)"],
    button1 = YES,
    button2 = NO,
    timeout = 0,
    OnAccept = function()
      local data = self.popup_unzoned_members_data
      data.func(mod, data.list_name, data.points, {})
    end,
    OnCancel = function()
      local data = self.popup_unzoned_members_data
      data.func(mod, data.list_name, data.points, data.exclude_map)
    end,
    whileDead = 1,
  }
end

function mod:OnEnable()
  self:RegisterEvent("RAID_ROSTER_UPDATE")
  self:RegisterEvent("EPGP_CACHE_UPDATE")
  self:RegisterEvent("EPGP_STOP_RECURRING_EP_AWARDS")
end

function mod:RAID_ROSTER_UPDATE()
  if not UnitInRaid("player") then
    self:TriggerEvent("EPGP_STOP_RECURRING_EP_AWARDS")
  end
end

function mod:EPGP_CACHE_UPDATE()
  local guild_name = GetGuildInfo("player")
  if guild_name ~= EPGP:GetProfile() then EPGP:SetProfile(guild_name) end
end

function mod:CanLogRaids()
  return CanEditOfficerNote()
end

function mod:CanChangeRules()
  return IsGuildLeader() or (self:CanLogRaids() and EPGP.db.profile.flat_credentials)
end

function mod:Report(fmt, ...)
  if EPGP.db.profile.report_channel ~= "NONE" then
    local msg = string.format(fmt, ...)
    local str = "EPGP:"
    for _,s in pairs({strsplit(" ", msg)}) do
      if #str + #s >= 250 then
	      SendChatMessage(str, EPGP.db.profile.report_channel)
	      str = "EPGP:"
      end
      str = str .. " " .. s
    end
    SendChatMessage(str, EPGP.db.profile.report_channel)
  end
end

function mod:ResetEPGP()
  -- First delete all officer notes
  for i = 1, GetNumGuildMembers(true) do
    GuildRosterSetOfficerNote(i, "")
  end
  -- Now set zero values
  for i = 1, GetNumGuildMembers(true) do
    local name = GetGuildRosterInfo(i)
    self.cache:SetMemberEPGP(name, 0, 0)
  end
  self.cache:SaveRoster()
  -- Make officer notes readable by all ranks
  for i = 1,GuildControlGetNumRanks() do
    GuildControlSetRank(i)
    GuildControlSetRankFlag(11, true)
    GuildControlSaveRank(GuildControlGetRankName(i))
  end
  self:Report(L["All EP/GP are reset and officer notes are made readable by all."])
end

function mod:DecayEPGP()
  local factor = 1 - EPGP.db.profile.decay_percent*0.01
  for i = 1, GetNumGuildMembers(true) do
    local name = GetGuildRosterInfo(i)
    if not self.cache:IsAlt(name) then
      local ep, gp = self.cache:GetMemberEPGP(name)
      if ep then
        ep = math.floor(ep * factor)
        gp = math.floor(gp * factor)
        self.cache:SetMemberEPGP(name, ep, gp)
      end
    end
  end
  self.cache:SaveRoster()
  self:Report(L["Applied a decay of %d%% to EP and GP."], EPGP.db.profile.decay_percent)
end

function mod:AddEP2Member(name, points)
  assert(type(name) == "string")
  if type(points) == "number" then
    local ep, gp = self.cache:GetMemberEPGP(name)
    self.cache:SetMemberEPGP(name, ep+points, gp)
    self.cache:SaveRoster()
    self:Report(L["Awarded %d EPs to %s."], points, name)
  else
    self.popup_modify_epgp_data.func = mod.AddEP2Member
    self.popup_modify_epgp_data.member = name
    self.popup_modify_epgp_data.valid_func = function(n) return n > -10000 and n < 10000 and n ~= 0 end    
    StaticPopup_Show("EPGP_MODIFY_EPGP", string.format(L["Award EP to %s"], name), popup_modify_epgp_data)
  end
end

function mod:SetEPMember(name, points)
  assert(type(name) == "string")
  if type(points) == "number" then
    local ep, gp = self.cache:GetMemberEPGP(name)
    self.cache:SetMemberEPGP(name, points, gp)
    self.cache:SaveRoster()
    self:Report(L["Set EPs for %s to %d."], name, points)
  else
    self.popup_modify_epgp_data.func = mod.SetEPMember
    self.popup_modify_epgp_data.member = name
    self.popup_modify_epgp_data.valid_func = function(n) return n > 0 and n < 10000000 end    
    StaticPopup_Show("EPGP_MODIFY_EPGP", string.format(L["Set EP for %s"], name), popup_modify_epgp_data)
  end
end

function mod:CheckUnzonedInRaid(func, list_name, points)
  assert(UnitInRaid("Player"))
  local t = {}
  for i = 1, GetNumRaidMembers() do
    local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
    if zone ~= GetRealZoneText() then
      table.insert(t, name)
    end
  end

  if #t > 0 then
    -- initialize the exclude map
    local exclude_map = {}
    for i,name in pairs(t) do
      exclude_map[name] = true
    end

    self.popup_unzoned_members_data.func = func
    self.popup_unzoned_members_data.points = points
    self.popup_unzoned_members_data.list_name = list_name
    self.popup_unzoned_members_data.exclude_map = exclude_map

    StaticPopup_Show("EPGP_UNZONED_MEMBERS_POPUP", GetRealZoneText(), table.concat(t, ", "))
  else
    func(mod, list_name, points, t) -- t is empty here
  end
end

function mod:AddEP2List(list_name, points, exclude_map)
  assert(type(list_name) == "string" and ITERATORS[list_name])
  assert(type(points) == "number")

  if list_name == "RAID" and not exclude_map then
    mod:CheckUnzonedInRaid(mod.AddEP2List, list_name, points)
    return
  end

  local members = {}
  for i,name in ITERATORS[list_name],self,1 do
    if not exclude_map or not exclude_map[name] then
      table.insert(members, name)
      local ep, gp = self.cache:GetMemberEPGP(name)
      if ep and gp then -- If the member is not in the guild we get nil
        -- Don't add EP to alts if they are not shown in the UI
        if EPGP.db.profile[list_name].show_alts or not self.cache:IsAlt(name) then
          self.cache:SetMemberEPGP(name, ep+points, gp)
        end
      end
    end
  end
  self.cache:SaveRoster()
  self:Report("Awarded %d EPs to %s.", points, table.concat(members, ", "))
end

function mod:RecurringEP2List(list_name, points)
  -- TODO: Need different event for each list
  assert(type(points) == "number")
  if points == 0 then
    self:TriggerEvent("EPGP_STOP_RECURRING_EP_AWARDS")
  else
    self:ScheduleRepeatingEvent("RECURRING_EP", mod.AddEP2List, EPGP.db.profile.recurring_ep_period, self, list_name, points, {})
    local fmt, val = SecondsToTimeAbbrev(EPGP.db.profile.recurring_ep_period)
    self:Report(L["Awarding %d EPs/%s to %s."], points, fmt:format(val), getglobal(list_name))
  end
end

function mod:DistributeEP2List(list_name, total_points, exclude_map)
  assert(type(total_points) == "number")

  if list_name == "RAID" and not exclude_map then
    mod:CheckUnzonedInRaid(mod.DistributeEP2List, list_name, total_points)
    return
  end

  local count = 0
  for i,name in ITERATORS[list_name],self,1 do
    if not exclude_map or not exclude_map[name] then
      count = count + 1
    end
  end
  local points = math.floor(total_points / count)
  self:AddEP2List(list_name, points, exclude_map)
end

function mod:EPGP_STOP_RECURRING_EP_AWARDS()
  if self:IsEventScheduled("RECURRING_EP") then
    self:CancelScheduledEvent("RECURRING_EP")
    self:Report(L["Recurring EP awards stopped."])
  end
end

function mod:AddGP2Member(name, points)
  if type(points) == "number" then
    assert(type(name) == "string")
    local ep, gp = self.cache:GetMemberEPGP(name)
    self.cache:SetMemberEPGP(name, ep, gp+points)
    self.cache:SaveRoster()
    self:Report(L["Credited %d GPs to %s."], points, name)
  else
    self.popup_modify_epgp_data.func = mod.AddGP2Member
    self.popup_modify_epgp_data.member = name
    self.popup_modify_epgp_data.valid_func = function(n) return n > -10000 and n < 10000 and n ~= 0 end    
    StaticPopup_Show("EPGP_MODIFY_EPGP", string.format(L["Credit GP to %s"], name))
  end
end

function mod:SetGPMember(name, points)
  assert(type(name) == "string")
  if type(points) == "number" then
    local ep, gp = self.cache:GetMemberEPGP(name)
    self.cache:SetMemberEPGP(name, ep, points)
    self.cache:SaveRoster()
    self:Report(L["Set GPs for %s to %d."], name, points)
  else
    self.popup_modify_epgp_data.func = mod.SetGPMember
    self.popup_modify_epgp_data.member = name
    self.popup_modify_epgp_data.valid_func = function(n) return n > 0 and n < 10000000 end    
    StaticPopup_Show("EPGP_MODIFY_EPGP", string.format(L["Set GP for %s"], name), popup_modify_epgp_data)
  end
end

function mod:BackupNotes()
  for i = 1, GetNumGuildMembers(true) do
    local name, _, _, _, _, _, note, officernote, _, _ = GetGuildRosterInfo(i)
    EPGP.db.profile.backup_notes[name] = { note, officernote }
  end
  EPGP:Print(L["Backed up Officer and Public notes."])
end

function mod:RestoreNotes()
  if not EPGP.db.profile.backup_notes then return end
  for i = 1, GetNumGuildMembers(true) do
    local name = GetGuildRosterInfo(i)
    local t = EPGP.db.profile.backup_notes[name]
    if t then
      GuildRosterSetPublicNote(i, t[1])
      upgraded_note = t[2]:gsub('|', ',')
      GuildRosterSetOfficerNote(i, upgraded_note)
    end
  end
  EPGP:Print(L["Restored Officer and Public notes."])
end

-------------------------------------------------------------------------------
-- Listings
-------------------------------------------------------------------------------
function mod:IsBelowThreshold(ep)
  return EPGP.db.profile.min_eps > ep
end

local function AreSameTier(n1, n2)
  return (mod:IsBelowThreshold(n1) and mod:IsBelowThreshold(n2)) or
         (not mod:IsBelowThreshold(n1) and not mod:IsBelowThreshold(n2))
end

local COMPARATORS = {
  ["NAME"] = function(a,b) return a[1] < b[1] end,
  ["EP"] = function(a,b) return a[3] > b[3] end,
  ["GP"] = function(a,b) return a[4] > b[4] end,
  ["PR"] = function(a,b) if AreSameTier(a[3], b[3]) then return a[5] > b[5] else return mod:IsBelowThreshold(b[3]) end end,
}

-- list_names: GUILD, RAID, ZONE
-- sort_on: NAME, EP, GP, PR
-- show_alts: boolean
-- search_str: string
--
-- returns table of listings with each row: { name:string, class:string, ep:number, gp:number, pr:number }
function mod:GetListing(list_name, sort_on, show_alts, search_str)
  local t = {}
  local iterator = ITERATORS[list_name]
  search_str = strlower(search_str)
  if not iterator then return t end
  if not self.cache then return t end
  for i,name in iterator,self,1 do
    if show_alts or not self.cache:IsAlt(name) then
      local rank, rankIndex, level, class, zone, note, officernote, online, status = self.cache:GetMemberInfo(name)
      if not search_str or
         search_str == "search" or
         (class and search_str == strlower(class)) or
         string.find(strlower(name), search_str, 1, true) then
        local ep, gp = self.cache:GetMemberEPGP(name)
        local rank, rankIndex, level, class, zone, note, officernote, online, status = self.cache:GetMemberInfo(name)
        if ep and gp then
          local pr = gp == 0 and ep or ep/gp
          table.insert(t, { name, class, ep, gp, pr })
        end
      end
    end
  end
  local comparator = COMPARATORS[sort_on]
  if not comparator then comparator = COMPARATORS.PR end
  table.sort(t, comparator)
  return t
end
