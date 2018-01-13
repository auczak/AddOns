local L = EPGPGlobalStrings

local mod = EPGP:NewModule("EPGP_OfficerNoteWarning", "AceHook-2.1")

function mod:OnInitialize()
  StaticPopupDialogs["EPGP_OFFICER_NOTE_WARNING"] = {
    text = L["EPGP is using Officer Notes for data storage. Do you really want to edit the Officer Note by hand?"],
    button1 = YES,
    button2 = NO,
    timeout = 0,
    OnAccept = function()
      self.hooks[GuildMemberOfficerNoteBackground]["OnMouseUp"]()
    end,
    whileDead = 1,
    hideOnEscape = 1,
  }
end

function mod:OnMouseUp()
  StaticPopup_Show("EPGP_OFFICER_NOTE_WARNING")
end

function mod:OnEnable()
  if GuildMemberOfficerNoteBackground and GuildMemberOfficerNoteBackground:HasScript("OnMouseUp") then
    self:HookScript(GuildMemberOfficerNoteBackground, "OnMouseUp")
  end
end
