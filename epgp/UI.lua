local L = EPGPGlobalStrings
local BC = AceLibrary("Babble-Class-2.2")

EPGP_TEXT_BACKUP = L["Backup"]
EPGP_TEXT_RESTORE = L["Restore"]
EPGP_TEXT_STANDINGS = L["Standings"]
EPGP_TEXT_ADD = L["Add"]
EPGP_TEXT_DISTRIBUTE = L["Distribute"]
EPGP_TEXT_RECURRING = L["Recurring"]
EPGP_TEXT_EXPORT_HTML = L["Export to HTML"]
EPGP_TEXT_EXPORT_TEXT = L["Export to text"]
EPGP_TEXT_WARN_CONSUMABLES = L["Warn Cons"]
EPGP_TEXT_PENALTY_CONSUMABLES = L["Penalty Cons"]
EPGP_TEXT_DECAY = L["Decay"]
EPGP_TEXT_REPORT_CHANNEL = L["Report Channel"]
EPGP_TEXT_MASTER_LOOT_QUALITY_THRESHOLD = L["Master Loot Quality Threshold"]

EPGP_UI = EPGP:NewModule("EPGP_UI", "AceEvent-2.0")

local function OnStaticPopupHide()
	if ChatFrameEditBox:IsShown() then
		ChatFrameEditBox:SetFocus()
	end
	getglobal(this:GetName().."EditBox"):SetText("")
end

function EPGP_UI:OnInitialize()
  UIPanelWindows["EPGPFrame"] = { area = "left", pushable = 1, whileDead = 1, }
  StaticPopupDialogs["EPGP_TEXT_EXPORT"] = {
    text = L["The current frame standings in plain text."],
    hasEditBox = 1,
    OnShow = function()
      local editBox = getglobal(this:GetName().."EditBox")
      editBox:SetText(EPGP_UI:Export2Text())
      editBox:HighlightText()
      editBox:SetFocus()
    end,
    OnHide = OnStaticPopupHide,
    EditBoxOnEnterPressed = function()
      this:GetParent():Hide()
      end,
    EditBoxOnEscapePressed = function()
      this:GetParent():Hide();
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
  }
  StaticPopupDialogs["EPGP_HTML_EXPORT"] = {
    text = L["The current frame standings in HTML."],
    hasEditBox = 1,
    OnShow = function()
      local editBox = getglobal(this:GetName().."EditBox")
      editBox:SetText(EPGP_UI:Export2HTML())
      editBox:HighlightText()
      editBox:SetFocus()
    end,
    OnHide = OnStaticPopupHide,
    EditBoxOnEnterPressed = function()
      this:GetParent():Hide()
      end,
    EditBoxOnEscapePressed = function()
      this:GetParent():Hide();
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
  }
  StaticPopupDialogs["EPGP_SET_RECURRING_PERIOD"] = {
    text = L["Enter new recurring EP period in seconds"],
    button1 = ACCEPT,
    button2 = CANCEL,
    timeout = 0,
    OnShow = function()
      local editBox = getglobal(this:GetName().."EditBox")
      editBox:SetFocus()
    end,
    OnHide = OnStaticPopupHide,
    OnAccept = function()
      local editBox = getglobal(this:GetParent():GetName().."EditBox")
      local number = editBox:GetNumber()
      if number > 0 then
        EPGP.db.profile.recurring_ep_period = number
      end
    end,
    EditBoxOnEnterPressed = function()
      local editBox = getglobal(this:GetParent():GetName().."EditBox")
      local number = editBox:GetNumber()
      if number > 0 then
        EPGP.db.profile.recurring_ep_period = number
        this:GetParent():Hide()
      end
    end,
    EditBoxOnTextChanged = function()
      local editBox = getglobal(this:GetParent():GetName().."EditBox")
      local button1 = getglobal(this:GetParent():GetName().."Button1")
      local number = editBox:GetNumber()
      if number > 0 then
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
  }
end

function EPGP_UI:OnEnable()
  self:RegisterEvent("EPGP_CACHE_UPDATE")
  self:RegisterEvent("RAID_ROSTER_UPDATE")
end

function EPGP_UI:SetRestoreButtonStatus(button)
  if EPGP:GetModule("EPGP_Backend"):CanLogRaids() then
    button:Enable()
  else
    button:Disable()
  end
end

function EPGP_UI:SetEPButtonStatus(button)
  button:Enable()
  if not EPGP:GetModule("EPGP_Backend"):CanLogRaids() then
    button:Disable()
    return
  end

  if button:GetParent():GetNumber() == 0 then
    button:Disable()
    return
  end

  if EPGP.db.profile.current_listing == "RAID" and not UnitInRaid("player") then
    button:Disable()
    return
  end
end

function EPGP_UI:EPGP_CACHE_UPDATE()
  EPGP_UI.UpdateListing()
  self:UpdateCheckButtons()
end

function EPGP_UI:RAID_ROSTER_UPDATE()
  if self.player_in_raid ~= UnitInRaid("player") then
    if UnitInRaid("player") then
      EPGP.db.profile.current_listing = "RAID"
    else
      EPGP.db.profile.current_listing = "GUILD"
    end
    EPGPFramePage1ListDropDown:Hide()
    EPGPFramePage1ListDropDown:Show()
    EPGP_UI.UpdateListing()
    EPGP_UI:UpdateCheckButtons()
  end
  self.player_in_raid = UnitInRaid("player")
end

function EPGP_UI.UpdateListing()
  if not EPGPFrame:IsShown() then return end

  local frame = getglobal("EPGPScrollFrame")
  local backend = EPGP:GetModule("EPGP_Backend")
  local t = EPGP_UI:GetListingForListingFrame()

  local scrollbar_shown = FauxScrollFrame_Update(EPGPScrollFrame, #t, 15, 16)--, "EPGPListingEntry", 298, 330)
  if (scrollbar_shown) then
    EPGPListingNameColumnHeader:SetWidth(111)
  else
    EPGPListingNameColumnHeader:SetWidth(131)
  end

  for i=1,15 do
    local j = i + FauxScrollFrame_GetOffset(EPGPScrollFrame)
    local row = getglobal("EPGPListingEntry"..i)
    if j <= #t then
      local name, class, EP, GP, PR = unpack(t[j])
      row.member_name = name
      getglobal(row:GetName().."Name"):SetText(name)
      getglobal(row:GetName().."Name"):SetTextColor(BC:GetColor(class))
      if scrollbar_shown then
        getglobal(row:GetName().."Name"):SetWidth(92)
      else
        getglobal(row:GetName().."Name"):SetWidth(112)
      end
      getglobal(row:GetName().."EP"):SetText(tostring(EP))
      getglobal(row:GetName().."EP"):SetAlpha(backend:IsBelowThreshold(EP) and 0.5 or 1.0)
      getglobal(row:GetName().."GP"):SetText(tostring(GP))
      getglobal(row:GetName().."GP"):SetAlpha(backend:IsBelowThreshold(EP) and 0.5 or 1.0)
      getglobal(row:GetName().."PR"):SetText(string.format("%.4g", PR))
      getglobal(row:GetName().."PR"):SetAlpha(backend:IsBelowThreshold(EP) and 0.5 or 1.0)
      row:Show()
    else
      row:Hide()
    end
  end
end

function EPGP_UI:UpdateCheckButtons()
  local show_alts_button = getglobal("EPGPFrameShowAltsCheckButton")
  if not EPGPFrame:IsShown() then return end

  show_alts_button:SetChecked(EPGP.db.profile[EPGP.db.profile.current_listing].show_alts)
end

function EPGP_UI:GetListingForListingFrame()
  local backend = EPGP:GetModule("EPGP_Backend")
  local t = backend:GetListing(EPGP.db.profile.current_listing,
                               EPGP.db.profile.comparator_name,
                               EPGP.db.profile[EPGP.db.profile.current_listing].show_alts,
                               getglobal("EPGPListingSearchBox"):GetText())
  return t
end

function EPGP_UI:Export2HTML()
  local t = self:GetListingForListingFrame()

  local text = "<table id=\"epgp-standings\">"..
  "<caption>EPGP Standings</caption>"..
  "<tr><th>Name</th><th>Class</th><th>EP</th><th>GP</th><th>PR</th></tr>"
  for i,rowdata in pairs(t) do
    local name, class, EP, GP, PR = unpack(rowdata)
    text = text..string.format(
      "<tr class=\"%s\">"..
      "<td>%s</td><td>%s</td><td>%d</td><td>%d</td><td>%.4g</td>"..
      "</tr>",
      class, name, class, EP, GP, PR)
  end
  text = text.."</table>"
  return text
end

function EPGP_UI:Export2Text()
  local t = self:GetListingForListingFrame()

  local text =
  "+----------------+-------EPGP Standings----+----------+----------+\n"..
  "|      Name      |     Class    |    EP    |    GP    |    PR    |\n"..
  "+----------------+--------------+----------+----------+----------+\n"
  local fmt_str_row = "| %-15s| %-13s|%9d |%9d |%9.2f |\n"
  for i,rowdata in pairs(t) do
    local name, class, EP, GP, PR = unpack(rowdata)
    text = text..string.format(fmt_str_row, name, class, EP, GP, PR);
  end
  text = text..
  "+----------------+--------------+----------+----------+----------+\n"
  return text
end

function EPGP_UI:AddEP2List(points)
  assert(type(points) == "number")
  EPGP:GetModule("EPGP_Backend"):AddEP2List(EPGP.db.profile.current_listing, points)
end

function EPGP_UI:DistributeEP2List(points)
  assert(type(points) == "number")
  EPGP:GetModule("EPGP_Backend"):DistributeEP2List(EPGP.db.profile.current_listing, points)
end

function EPGP_UI:RecurringEP2List(points)
  assert(type(points) == "number")
  EPGP:GetModule("EPGP_Backend"):RecurringEP2List(EPGP.db.profile.current_listing, points)
end

function EPGP_UI.ReportChannelList_Initialize()
  local info = UIDropDownMenu_CreateInfo()
  info.func = function()
    EPGP.db.profile.report_channel = this.value
    UIDropDownMenu_SetSelectedValue(getglobal(UIDROPDOWNMENU_OPEN_MENU), EPGP.db.profile.report_channel)
  end

  local options = {
    ["NONE"] = NONE,
    ["GUILD"] = CHAT_MSG_GUILD,
    ["OFFICER"] = CHAT_MSG_OFFICER,
    ["RAID"] = CHAT_MSG_RAID,
    ["PARTY"] = CHAT_MSG_PARTY,
  }
  for k,v in pairs(options) do
    info.text = v
    info.value = k
    info.checked = nil
    UIDropDownMenu_AddButton(info)
  end
end

function EPGP_UI.ListingList_Initialize()
  local info = UIDropDownMenu_CreateInfo()
  info.func = function()
    EPGP.db.profile.current_listing = this.value
    UIDropDownMenu_SetSelectedValue(getglobal(UIDROPDOWNMENU_OPEN_MENU), EPGP.db.profile.current_listing)
    EPGP_UI.UpdateListing()
    EPGP_UI:UpdateCheckButtons()
  end

  local options = EPGP:GetModule("EPGP_Backend"):GetListingIDs()
  for i,v in pairs(options) do
    info.text = getglobal(v)
    info.value = strupper(v)
    info.checked = nil
    UIDropDownMenu_AddButton(info)
  end
end

function EPGP_UI.ListingDropDown_Initialize()
  local info = UIDropDownMenu_CreateInfo()

  info.text = ListingDropDown.member_name
  info.isTitle = 1
  UIDropDownMenu_AddButton(info)

  info = UIDropDownMenu_CreateInfo()
  info.func = function()
    EPGP:GetModule("EPGP_Backend"):AddEP2Member(ListingDropDown.member_name)
  end
  info.text = L["Award EP"]
  info.checked = nil
  UIDropDownMenu_AddButton(info)

  info = UIDropDownMenu_CreateInfo()
  info.func = function()
    EPGP:GetModule("EPGP_Backend"):AddGP2Member(ListingDropDown.member_name)
  end
  info.text = L["Credit GP"]
  info.checked = nil
  UIDropDownMenu_AddButton(info)

  info = UIDropDownMenu_CreateInfo()
  info.func = function()
    EPGP:GetModule("EPGP_Backend"):SetEPMember(ListingDropDown.member_name)
  end
  info.text = L["Set EP"]
  info.checked = nil
  UIDropDownMenu_AddButton(info)

  info = UIDropDownMenu_CreateInfo()
  info.func = function()
    EPGP:GetModule("EPGP_Backend"):SetGPMember(ListingDropDown.member_name)
  end
  info.text = L["Set GP"]
  info.checked = nil
  UIDropDownMenu_AddButton(info)
end

function EPGP_UI.MasterLootQualityThreshold_Initialize()
  local info = UIDropDownMenu_CreateInfo()
  info.func = function()
    EPGP.db.profile.master_loot_popup_quality_threshold = this.value
    UIDropDownMenu_SetSelectedValue(getglobal(UIDROPDOWNMENU_OPEN_MENU), EPGP.db.profile.master_loot_popup_quality_threshold)
  end
  
  for i=2,#ITEM_QUALITY_COLORS do
    info.text = getglobal("ITEM_QUALITY"..i.."_DESC")
    info.value = i
    info.checked = nil
    UIDropDownMenu_AddButton(info)
  end
end

function EPGP_UI.ListingDropDown(name)
  HideDropDownMenu(1)
  UIDropDownMenu_Initialize(ListingDropDown, EPGP_UI.ListingDropDown_Initialize, "MENU")
  ListingDropDown.member_name = name
  ToggleDropDownMenu(1, nil, ListingDropDown, "cursor");
end
