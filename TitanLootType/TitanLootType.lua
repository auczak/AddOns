-- **************************************************************************
-- * TitanLootType.lua
-- *
-- * By: TitanMod, Dark Imakuni, Adsertor and the Titan Development Team
-- *     (HonorGoG, jaketodd422, joejanko, Lothayer, Tristanian)
-- **************************************************************************

-- ******************************** Constants *******************************
TITAN_LOOTTYPE_ID = "LootType";
TitanLootMethod = {};
TitanLootMethod["freeforall"] = {text = TITAN_LOOTTYPE_FREE_FOR_ALL};
TitanLootMethod["roundrobin"] = {text = TITAN_LOOTTYPE_ROUND_ROBIN};
TitanLootMethod["master"] = {text = TITAN_LOOTTYPE_MASTER_LOOTER};
TitanLootMethod["group"] = {text = TITAN_LOOTTYPE_GROUP_LOOT};
TitanLootMethod["needbeforegreed"] = {text = TITAN_LOOTTYPE_NEED_BEFORE_GREED};

-- ******************************** Variables *******************************

-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelLootTypeButton_OnLoad()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TitanPanelLootTypeButton_OnLoad()
     this.registry = {
          id = TITAN_LOOTTYPE_ID,
          builtIn = 1,
          version = TITAN_VERSION,
          menuText = TITAN_LOOTTYPE_MENU_TEXT,
          buttonTextFunction = "TitanPanelLootTypeButton_GetButtonText", 
          tooltipTitle = TITAN_LOOTTYPE_TOOLTIP, 
          tooltipTextFunction = "TitanPanelLootTypeButton_GetTooltipText",
          icon = TITAN_ARTWORK_PATH.."TitanLootType",          
          iconWidth = 16,
          savedVariables = {
               ShowIcon = 1,
               ShowLabelText = 1,
               RandomRoll = 100,
          }
     };     

    this:RegisterEvent("PARTY_MEMBERS_CHANGED");
    this:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
end

-- **************************************************************************
-- NAME : TitanPanelLootTypeButton_OnEvent()
-- DESC : Parse events registered to plugin and act on them
-- **************************************************************************
function TitanPanelLootTypeButton_OnEvent()
     TitanPanelButton_UpdateButton(TITAN_LOOTTYPE_ID);     
     TitanPanelButton_UpdateTooltip();
end

-- **************************************************************************
-- NAME : TitanPanelLootTypeButton_GetButtonText(id)
-- DESC : Calculate loottype and then display data on button
-- VARS : id = button ID
-- **************************************************************************
function TitanPanelLootTypeButton_GetButtonText(id)
     local lootTypeText, lootThreshold, color;
     if (GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0) then
          lootTypeText = TitanLootMethod[GetLootMethod()].text;
          lootThreshold = GetLootThreshold();
          color = ITEM_QUALITY_COLORS[lootThreshold];
     else
          lootTypeText = TITAN_NA;
          color = HIGHLIGHT_FONT_COLOR;
     end
     
     return TITAN_LOOTTYPE_BUTTON_LABEL, TitanUtils_GetColoredText(lootTypeText, color);
end

-- **************************************************************************
-- NAME : TitanPanelLootTypeButton_GetTooltipText()
-- DESC : Display tooltip text
-- **************************************************************************
function TitanPanelLootTypeButton_GetTooltipText()
     if (GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0) then
          local lootTypeText = TitanLootMethod[GetLootMethod()].text;
          local lootThreshold = GetLootThreshold();
          local itemQualityDesc = getglobal("ITEM_QUALITY"..lootThreshold.."_DESC");
          local color = ITEM_QUALITY_COLORS[lootThreshold];
          return ""..
               LOOT_METHOD..": \t"..TitanUtils_GetHighlightText(lootTypeText).."\n"..
               LOOT_THRESHOLD..": \t"..TitanUtils_GetColoredText(itemQualityDesc, color).."\n"..
               TitanUtils_GetGreenText(TITAN_LOOTTYPE_TOOLTIP_HINT1).."\n"..
               TitanUtils_GetGreenText(TITAN_LOOTTYPE_TOOLTIP_HINT2);
     else
          return TitanUtils_GetNormalText(ERR_NOT_IN_GROUP).."\n"..
          TitanUtils_GetGreenText(TITAN_LOOTTYPE_TOOLTIP_HINT1).."\n"..
          TitanUtils_GetGreenText(TITAN_LOOTTYPE_TOOLTIP_HINT2);
     end
end

-- **************************************************************************
-- NAME : TitanPanelLootType_Random100()
-- DESC : Define random 100 loottype
-- **************************************************************************
function TitanPanelLootType_Random100()
     TitanSetVar(TITAN_LOOTTYPE_ID, "RandomRoll", 100);
end

-- **************************************************************************
-- NAME : TitanPanelLootType_Random1000()
-- DESC : Define random 1000 loottype
-- **************************************************************************
function TitanPanelLootType_Random1000()
	TitanSetVar(TITAN_LOOTTYPE_ID, "RandomRoll", 1000);
end

-- **************************************************************************
-- NAME : TitanPanelLootType_GetRoll(num)
-- DESC : Confirm loottype is random roll
-- **************************************************************************
function TitanPanelLootType_GetRoll(num)
	local temp;
	temp = TitanGetVar(TITAN_LOOTTYPE_ID, "RandomRoll");
	if temp == num then
		return 1;
	end
	return nil;
end

-- **************************************************************************
-- NAME : TitanPanelRightClickMenu_PrepareLootTypeMenu()
-- DESC : Display rightclick menu options
-- **************************************************************************
function TitanPanelRightClickMenu_PrepareLootTypeMenu()
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
	local info = {};
 
	info.text = "100";
	info.value = 100;
	info.func = TitanPanelLootType_Random100;
	info.checked = TitanPanelLootType_GetRoll(info.value);
	UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL);

	info.text = "1000";
	info.value = 1000;
	info.func = TitanPanelLootType_Random1000;
	info.checked = TitanPanelLootType_GetRoll(info.value);
	UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL);
 
 else
     TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_LOOTTYPE_ID].menuText);
     local info;
	info = {};
	info.text = TITAN_LOOTTYPE_RANDOM_ROLL_LABEL;
     info.hasArrow = 1;
     UIDropDownMenu_AddButton(info);
     TitanPanelRightClickMenu_AddSpacer();
     TitanPanelRightClickMenu_AddToggleIcon(TITAN_LOOTTYPE_ID);
     TitanPanelRightClickMenu_AddToggleLabelText(TITAN_LOOTTYPE_ID);
     
     TitanPanelRightClickMenu_AddSpacer();
     TitanPanelRightClickMenu_AddCommand(TITAN_PANEL_MENU_HIDE, TITAN_LOOTTYPE_ID, TITAN_PANEL_MENU_FUNC_HIDE);
     end
end

-- **************************************************************************
-- NAME : TitanPanelBagButton_OnClick(button)
-- DESC : Generate random roll on leftclick of button
-- **************************************************************************
function TitanPanelLootTypeButton_OnClick()
	if arg1 == "LeftButton" then
		RandomRoll(1, TitanGetVar(TITAN_LOOTTYPE_ID, "RandomRoll"));
	end
end
