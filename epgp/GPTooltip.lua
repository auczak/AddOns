local L = EPGPGlobalStrings

local mod = EPGP:NewModule("EPGP_GPTooltip", "AceHook-2.1")

local EQUIPSLOT_VALUE = {
  ["INVTYPE_HEAD"] = 1,
  ["INVTYPE_NECK"] = 0.55,
  ["INVTYPE_SHOULDER"] = 0.777,
  ["INVTYPE_CHEST"] = 1,
  ["INVTYPE_ROBE"] = 1,
  ["INVTYPE_WAIST"] = 0.777,
  ["INVTYPE_LEGS"] = 1,
  ["INVTYPE_FEET"] = 0.777,
  ["INVTYPE_WRIST"] = 0.55,
  ["INVTYPE_HAND"] = 0.777,
  ["INVTYPE_FINGER"] = 0.55,
  ["INVTYPE_TRINKET"] = 0.7,
  ["INVTYPE_CLOAK"] = 0.55,
  ["INVTYPE_WEAPON"] = 0.42,
  ["INVTYPE_SHIELD"] = 0.55,
  ["INVTYPE_2HWEAPON"] = 1,
  ["INVTYPE_WEAPONMAINHAND"] = 0.42,
  ["INVTYPE_WEAPONOFFHAND"] = 0.42,
  ["INVTYPE_HOLDABLE"] = 0.55,
  ["INVTYPE_RANGED"] = 0.42,
  ["INVTYPE_RANGEDRIGHT"] = 0.42,
  ["INVTYPE_THROWN"] = 0.42,
  ["INVTYPE_RELIC"] = 0.42
}

local ILVL_TO_IVALUE = {
  [2] = function(ilvl) return (ilvl - 4) / 2 end,         -- Green
  [3] = function(ilvl) return (ilvl - 1.84) / 1.6 end,   -- Blue
  [4] = function(ilvl) return (ilvl - 1.3) / 1.3 end,     -- Purple
}

--Used to display GP values directly on tier tokens
local CUSTOM_ITEM_DATA = {
  -- Tier 4
  ["29753"] = { 4, 120, "INVTYPE_CHEST" },
  ["29754"] = { 4, 120, "INVTYPE_CHEST" },
  ["29755"] = { 4, 120, "INVTYPE_CHEST" },
  ["29756"] = { 4, 120, "INVTYPE_HAND" },
  ["29757"] = { 4, 120, "INVTYPE_HAND" },
  ["29758"] = { 4, 120, "INVTYPE_HAND" },
  ["29759"] = { 4, 120, "INVTYPE_HEAD" },
  ["29760"] = { 4, 120, "INVTYPE_HEAD" },
  ["29761"] = { 4, 120, "INVTYPE_HEAD" },
  ["29762"] = { 4, 120, "INVTYPE_SHOULDER" },
  ["29763"] = { 4, 120, "INVTYPE_SHOULDER" },
  ["29764"] = { 4, 120, "INVTYPE_SHOULDER" },
  ["29765"] = { 4, 120, "INVTYPE_LEGS" },
  ["29766"] = { 4, 120, "INVTYPE_LEGS" },
  ["29767"] = { 4, 120, "INVTYPE_LEGS" },

  -- Tier 5
  ["30236"] = { 4, 133, "INVTYPE_CHEST" },
  ["30237"] = { 4, 133, "INVTYPE_CHEST" },
  ["30238"] = { 4, 133, "INVTYPE_CHEST" },
  ["30239"] = { 4, 133, "INVTYPE_HAND" },
  ["30240"] = { 4, 133, "INVTYPE_HAND" },
  ["30241"] = { 4, 133, "INVTYPE_HAND" },
  ["30242"] = { 4, 133, "INVTYPE_HEAD" },
  ["30243"] = { 4, 133, "INVTYPE_HEAD" },
  ["30244"] = { 4, 133, "INVTYPE_HEAD" },
  ["30245"] = { 4, 133, "INVTYPE_LEGS" },
  ["30246"] = { 4, 133, "INVTYPE_LEGS" },
  ["30247"] = { 4, 133, "INVTYPE_LEGS" },
  ["30248"] = { 4, 133, "INVTYPE_SHOULDER" },
  ["30249"] = { 4, 133, "INVTYPE_SHOULDER" },
  ["30250"] = { 4, 133, "INVTYPE_SHOULDER" },
  
  -- Tier 5 - BoE recipes - BoP crafts
  ["30282"] = { 4, 128, "INVTYPE_BOOTS" },
  ["30283"] = { 4, 128, "INVTYPE_BOOTS" },
  ["30305"] = { 4, 128, "INVTYPE_BOOTS" },
  ["30306"] = { 4, 128, "INVTYPE_BOOTS" },
  ["30307"] = { 4, 128, "INVTYPE_BOOTS" },
  ["30308"] = { 4, 128, "INVTYPE_BOOTS" },
  ["30323"] = { 4, 128, "INVTYPE_BOOTS" },
  ["30324"] = { 4, 128, "INVTYPE_BOOTS" },

  -- Tier 6
  ["31089"] = { 4, 146, "INVTYPE_CHEST" },
  ["31090"] = { 4, 146, "INVTYPE_CHEST" },
  ["31091"] = { 4, 146, "INVTYPE_CHEST" },
  ["31092"] = { 4, 146, "INVTYPE_HAND" },
  ["31093"] = { 4, 146, "INVTYPE_HAND" },
  ["31094"] = { 4, 146, "INVTYPE_HAND" },
  ["31095"] = { 4, 146, "INVTYPE_HEAD" },
  ["31096"] = { 4, 146, "INVTYPE_HEAD" },
  ["31097"] = { 4, 146, "INVTYPE_HEAD" },
  ["31098"] = { 4, 146, "INVTYPE_LEGS" },
  ["31099"] = { 4, 146, "INVTYPE_LEGS" },
  ["31000"] = { 4, 146, "INVTYPE_LEGS" },
  ["31001"] = { 4, 146, "INVTYPE_SHOULDER" },
  ["31102"] = { 4, 146, "INVTYPE_SHOULDER" },
  ["31003"] = { 4, 146, "INVTYPE_SHOULDER" },
  ["34848"] = { 4, 154, "INVTYPE_WRIST" },
  ["34851"] = { 4, 154, "INVTYPE_WRIST" },
  ["34852"] = { 4, 154, "INVTYPE_WRIST" },
  ["34853"] = { 4, 154, "INVTYPE_WAIST" },
  ["34854"] = { 4, 154, "INVTYPE_WAIST" },
  ["34855"] = { 4, 154, "INVTYPE_WAIST" },
  ["34856"] = { 4, 154, "INVTYPE_FEET" },
  ["34857"] = { 4, 154, "INVTYPE_FEET" },
  ["34858"] = { 4, 154, "INVTYPE_FEET" },
  
  -- Tier 6 - BoE recipes - BoP crafts
  ["32737"] = { 4, 141, "INVTYPE_SHOULDER" },
  ["32739"] = { 4, 141, "INVTYPE_SHOULDER" },
  ["32745"] = { 4, 141, "INVTYPE_SHOULDER" },
  ["32747"] = { 4, 141, "INVTYPE_SHOULDER" },
  ["32749"] = { 4, 141, "INVTYPE_SHOULDER" },
  ["32751"] = { 4, 141, "INVTYPE_SHOULDER" },
  ["32753"] = { 4, 141, "INVTYPE_SHOULDER" },
  ["32755"] = { 4, 141, "INVTYPE_SHOULDER" },

  -- Magtheridon's Head
  ["32385"] = { 4, 125, "INVTYPE_FINGER" },
  ["32386"] = { 4, 125, "INVTYPE_FINGER" },

  -- Kael'thas' Sphere
  ["32405"] = { 4, 138, "INVTYPE_NECK" },
}

function mod:GetGPValue(itemLink)
  if not itemLink then return end
  local _, _, rarity, level, _, _, _, _, equipLoc = GetItemInfo(itemLink)

  -- Get the item ID to check against known token IDs
  local _, _, itemID = string.find(itemLink, "^|c%x+|Hitem:([^:]+):.+|h%[.+%]")
  -- Check to see if there is custom data for this item ID
  if CUSTOM_ITEM_DATA[itemID] then
    rarity, level, equipLoc = unpack(CUSTOM_ITEM_DATA[itemID])
  end
  local islot_mod = EQUIPSLOT_VALUE[equipLoc]
  if not islot_mod then return end
  local ilvl2ivalue = ILVL_TO_IVALUE[rarity]
  if ilvl2ivalue then
    local ivalue = ilvl2ivalue(level)
    return math.floor(ivalue^2 * 0.04 * islot_mod), level, ivalue
  end
end

function mod:OnTooltipSetItem(tooltip, ...)
  local _, itemlink = tooltip:GetItem()
  self.hooks[tooltip]["OnTooltipSetItem"](tooltip, ...)
  if EPGP.db.profile.gp_in_tooltips then
    local gp, ilvl, ivalue = self:GetGPValue(itemlink)
    if gp and gp > 0 then
      tooltip:AddLine(string.format(L["GP: %d [ItemLevel=%d ItemValue=%d]"], gp, ilvl, ivalue),
        NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    end
  end
end

function mod:OnEnable()
  local obj = EnumerateFrames()
  while obj do
    if obj:IsObjectType("GameTooltip") then
      assert(obj:HasScript("OnTooltipSetItem"))
      self:HookScript(obj, "OnTooltipSetItem")
    end
    obj = EnumerateFrames(obj)
  end
end
