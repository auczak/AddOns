local L = EPGPGlobalStrings

local mod = EPGP:NewModule("EPGP_MLPopup", "AceHook-2.1")

local function OnStaticPopupHide()
	if ChatFrameEditBox:IsShown() then
		ChatFrameEditBox:SetFocus()
	end
	getglobal(this:GetName().."EditBox"):SetText("")
end

function mod:OnInitialize()
  local backend = EPGP:GetModule("EPGP_Backend")
  local gptooltip = EPGP:GetModule("EPGP_GPTooltip")
  
  StaticPopupDialogs["EPGP_GP_ASSIGN_FOR_LOOT"] = {
    text = L["Credit GP to %s for %s"],
    button1 = ACCEPT,
    button2 = CANCEL,
    timeout = 0,
    OnShow = function()
      local gp = gptooltip:GetGPValue(mod.itemLink) or ""
      local editBox = getglobal(this:GetName().."EditBox")
      editBox:SetNumeric(true)
      editBox:SetText(gp)
      editBox:HighlightText()
      editBox:SetFocus()
    end,
    OnHide = OnStaticPopupHide,
    OnAccept = function()
      local editBox = getglobal(this:GetParent():GetName().."EditBox")
      local gp = editBox:GetNumber()
      if gp > 0 and gp < 10000 then
        backend:AddGP2Member(mod.member, gp)
      end
    end,
    EditBoxOnEnterPressed = function()
      local editBox = getglobal(this:GetParent():GetName().."EditBox")
      local gp = editBox:GetNumber()
      editBox:SetText("")
      if gp > 0 and gp < 10000 then
        backend:AddGP2Member(mod.member, gp)
        this:GetParent():Hide()
      end
    end,
    EditBoxOnTextChanged = function()
      local editBox = getglobal(this:GetParent():GetName().."EditBox")
      local button1 = getglobal(this:GetParent():GetName().."Button1")
      local gp = editBox:GetNumber()
      if gp > 0 and gp < 10000 then
        button1:Enable()
      else
        button1:Disable()
      end
    end,
    EditBoxOnEscapePressed = function()
      this:GetParent():Hide()
    end,
    hideOnEscape = 1,
    whileDead = 1,
    hasEditBox = 1,
  }
end

function mod:OnEnable()
  self:SecureHook("GiveMasterLoot")
end

function mod:GiveMasterLoot(slot, index)
  mod.member = GetMasterLootCandidate(index)
  mod.itemLink = GetLootSlotLink(slot)
  local name, link, rarity, level, minlevel, type, subtype, count, equipLoc = GetItemInfo(mod.itemLink)
  if EPGP.db.profile.master_loot_popup and rarity >= EPGP.db.profile.master_loot_popup_quality_threshold then
    mod.member = GetMasterLootCandidate(index)
    mod.itemLink = GetLootSlotLink(slot)
    StaticPopup_Show("EPGP_GP_ASSIGN_FOR_LOOT", mod.member, mod.itemLink)
  end
end
