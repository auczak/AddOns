local L = EPGPGlobalStrings

local mod = EPGP:NewModule("EPGP_Cache", "AceEvent-2.0")

function mod:OnInitialize()
  self.guild_member_count = 0
end

function mod:OnEnable()
  self:RegisterEvent("GUILD_ROSTER_UPDATE")
  self:RegisterEvent("PLAYER_GUILD_UPDATE")
  self:RegisterEvent("CHAT_MSG_ADDON")
  self:GuildRosterNow()
end

function mod:LoadConfig()
  local lines = {string.split("\n", GetGuildInfoText() or "")}
  local in_block = false

  local outsiders = {}
  local dummies = {}

  for _,line in pairs(lines) do
    if line == "-EPGP-" then
      in_block = not in_block
    elseif in_block then
      -- Get options and alts
      -- Format is:
      --   @DECAY_P:<number>    // for decay percent (defaults to 10)
      --   @MIN_EP:<number>     // for min eps until member can need items (defaults to 1000)
      --   @FC                  // for flat credentials (true if specified, false otherwise)

      -- Decay percent
      local dp = line:match("@DECAY_P:(%d+)")
      if dp then
        dp = tonumber(dp)
        if dp and dp >= 0 and dp <= 100 then EPGP.db.profile.decay_percent = dp
        else EPGP:Print(L["Decay Percent should be a number between 0 and 100"]) end
      end

      -- Min EPs
      local mep = tonumber(line:match("@MIN_EP:(%d+)"))
      if mep then
        if mep and mep >= 0 then EPGP.db.profile.min_eps = mep
        else EPGP:Print(L["Min EPs should be a positive number"]) end
      end
      
      -- Base GP
      local bgp = tonumber(line:match("@BASE_GP:(%d+)"))
      if bgp then
        if bgp and bgp >= 0 then EPGP.db.profile.base_gp = bgp
        else EPGP:Print(L["Base GP should be a positive number"]) end
      end
	  
	  -- No consumables penalty
      local ncp = line:match("@NO_CONS_PEN:(%d+)")
      if ncp then
        ncp = tonumber(ncp)
        if ncp and ncp >= 0 then EPGP.db.profile.no_consumables_penalty = -1* ncp
        else EPGP:Print(L["No consumables penalty should be a positive number"]) end
      end
	        
      -- Flat Credentials
      local fc = line:match("@FC")
      if fc then EPGP.db.profile.flat_credentials = true end

      -- Read in Outsiders
      for outsider, dummy in line:gmatch("([^%p%s]+):([^%p%s]+)") do
        outsiders[outsider] = dummy
        dummies[dummy] = outsider
      end
    end
  end
  EPGP.db.profile.outsiders = outsiders
  EPGP.db.profile.dummies = dummies
end

function mod:GetNoConsumablesPenalty()
  return EPGP.db.profile.no_consumables_penalty
end

local function GetMemberData(obj, name)
  if obj:IsOutsider(name) then
    return EPGP.db.profile.data[EPGP.db.profile.outsiders[name]]
  elseif obj:IsAlt(name) then
    return EPGP.db.profile.data[EPGP.db.profile.alts[name]]
  else
    return EPGP.db.profile.data[name]
  end
end

function mod:IsAlt(name)
  return not not EPGP.db.profile.alts[name]
end

function mod:IsOutsider(name)
  return not not EPGP.db.profile.outsiders[name]
end

function mod:IsDummy(name)
  return not not EPGP.db.profile.dummies[name]
end

function mod:GetMemberEPGP(name)
  local t = GetMemberData(self, name)
  if not t then
    return
  else
    return unpack(t)
  end
end

function mod:GetMemberInfo(name)
  local guild_name = name
  if self:IsOutsider(name) then
    guild_name = EPGP.db.profile.outsiders[name]
  end
  local t = EPGP.db.profile.info[guild_name]
  if t then return unpack(t) end
end

function mod:SetMemberEPGP(name, ep, gp)
  assert(type(ep) == "number" and ep >= 0 and ep <= 999999999999999)
  assert(type(gp) == "number" and gp >= 0 and gp <= 999999999999999)
  local t = GetMemberData(self, name)
  t[1] = ep
  t[2] = gp
end

local function ParseNote(note)
  -- Parse old format: ep|tep|gp|tgp
  local ep, tep, gp, tgp = string.match(note, "^(%d+)|(%d+)|(%d+)|(%d+)$")
  if ep then
    return tonumber(ep) + tonumber(tep), tonumber(gp) + tonumber(tgp) + EPGP.db.profile.base_gp
  end

  -- Parse post 2.4.2 old format: ep|tep|gp|tgp
  local ep, tep, gp, tgp = string.match(note, "^(%d+),(%d+),(%d+),(%d+)$")
  if ep then
    return tonumber(ep) + tonumber(tep), tonumber(gp) + tonumber(tgp) + EPGP.db.profile.base_gp
  end

  -- Parse post 2.4.2 new format: ep,gp
  ep, gp = string.match(note, "^(%d+),(%d+)$")
  if ep then
    return tonumber(ep), tonumber(gp) + EPGP.db.profile.base_gp
  end


  -- Nothing works just return 0,BaseGP
  return 0, EPGP.db.profile.base_gp
end

function mod:LoadRoster()
  local data = {}
  local info = {}
  local alts = {}
  for i = 1, GetNumGuildMembers(true) do
    local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i)
    -- This is an alt and officernote stores the main
    if string.match(officernote, "[^%p%s]+") == officernote then
      officernote = officernote:sub(1,1):upper() .. officernote:sub(2):lower()
      alts[name] = officernote
      data[name] = nil
    -- This is a main and officernote stores EPGP
    else
      data[name] = { ParseNote(officernote) }
    end
    info[name] = { rank, rankIndex, level, class, zone, note, officernote, online, status }
  end
  EPGP.db.profile.data = data
  EPGP.db.profile.info = info
  EPGP.db.profile.alts = alts

  local old_count = self.guild_member_count
  self.guild_member_count = GetNumGuildMembers(true)
  EPGP:Debug("old:%d new:%d", old_count, self.guild_member_count)
  return old_count ~= self.guild_member_count
end

local function EncodeNote(ep, gp)
  gp = gp - EPGP.db.profile.base_gp
  if gp < 0 then gp = 0 end
  return string.format("%d,%d", ep, gp)
end

function mod:SaveRoster()
  for i = 1, GetNumGuildMembers(true) do
    local name, _, _, _, _, _, _, officernote, _, _ = GetGuildRosterInfo(i)
    if not self:IsAlt(name) then
      local ep, tep, gp, tgp = self:GetMemberEPGP(name)
      if ep then
        local new_officernote = EncodeNote(ep, tep, gp, tgp)
        if new_officernote ~= officernote then
          GuildRosterSetOfficerNote(i, new_officernote)
        end
      end
    end
  end
  EPGP:Debug("Notes changed - sending update to guild")
  SendAddonMessage("EPGP", "UPDATE", "GUILD")
end

function mod:GuildRosterNow()
  if not IsInGuild() then return end

  GuildRoster()
  self.last_guild_roster_time = GetTime()
end

function mod:GuildRoster()
  if not IsInGuild() then return end

  if not self.last_guild_roster_time then
    self:GuildRosterNow()
  elseif not self:IsEventScheduled("DELAYED_GUILD_ROSTER_UPDATE") then
    local elapsed = GetTime() - self.last_guild_roster_time
    if elapsed > 10 then
      self:GuildRosterNow()
    else
      self:ScheduleEvent("DELAYED_GUILD_ROSTER_UPDATE", mod.GuildRoster, 10 - elapsed, self)
    end
  end
end

function mod:PLAYER_GUILD_UPDATE()
  self:GuildRoster()
end

function mod:GUILD_ROSTER_UPDATE(local_update)
  local guild_name = GetGuildInfo("player")
  if guild_name and guild_name ~= EPGP:GetProfile() then
    EPGP:SetProfile(guild_name)
  end

  if local_update then
    self:GuildRosterNow()
    return
  end
  EPGP:Debug("Reloading roster and config from game")
  self:LoadConfig()
  local member_change = self:LoadRoster()
  self:TriggerEvent("EPGP_CACHE_UPDATE", member_change)
end

function mod:CHAT_MSG_ADDON(prefix, msg, type, sender)
  if prefix == "EPGP" then
    EPGP:Debug("Processing CHAT_MSG_ADDON(%s,%s,%s,%s)", prefix, msg, type, sender)
    if sender == UnitName("player") then return end
    if msg == "UPDATE" then self:GuildRoster() end
  end
end
