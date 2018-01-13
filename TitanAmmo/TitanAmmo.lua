-- **************************************************************************
-- * TitanAmmo.lua
-- *
-- * By: TitanMod, Dark Imakuni, Adsertor and the Titan Development Team
-- *     (HonorGoG, jaketodd422, joejanko, Lothayer, Tristanian)
-- **************************************************************************

-- ******************************** Constants *******************************
TITAN_AMMO_ID = "Ammo";
TITAN_AMMO_THRESHOLD_TABLE = {
     Values = { 150, 400 },
     Colors = { RED_FONT_COLOR, NORMAL_FONT_COLOR, GREEN_FONT_COLOR },
}

-- ******************************** Variables *******************************
local UpdateAmmoNow = 0;
local AmmoUpdateCounter = 1; --Ammo will update every second when in combat, change this from here

-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelAmmoButton_OnLoad()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TitanPanelAmmoButton_OnLoad()
     this.registry = {
          id = TITAN_AMMO_ID,
          builtIn = 1,
          version = TITAN_VERSION,
          menuText = TITAN_AMMO_MENU_TEXT,
          buttonTextFunction = "TitanPanelAmmoButton_GetButtonText", 
          tooltipTitle = TITAN_AMMO_TOOLTIP, 
          icon = TITAN_ARTWORK_PATH.."TitanThrown",     
          iconWidth = 16,
          savedVariables = {
               ShowIcon = 1,
               ShowLabelText = 1,
               ShowColoredText = 1,
          }
     };     

	this:RegisterEvent("PLAYER_LEAVING_WORLD");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
end

-- **************************************************************************
-- NAME : TitanPanelAmmoButton_OnEvent()
-- DESC : Parse events registered to plugin and act on them
-- **************************************************************************
function TitanPanelAmmoButton_OnEvent()
     if (event == "PLAYER_LEAVING_WORLD") then
    --this:UnregisterEvent("BAG_UPDATE");
      this:UnregisterEvent("ITEM_LOCK_CHANGED");
      this:UnregisterEvent("UNIT_INVENTORY_CHANGED");
      this:UnregisterEvent("PLAYER_REGEN_ENABLED");
		  this:UnregisterEvent("PLAYER_REGEN_DISABLED");
		  this:UnregisterEvent("UPDATE_INVENTORY_ALERTS");
     end

     if (event == "PLAYER_ENTERING_WORLD") then
		--this:RegisterEvent("BAG_UPDATE");
      this:RegisterEvent("ITEM_LOCK_CHANGED");
      this:RegisterEvent("UNIT_INVENTORY_CHANGED");
      this:RegisterEvent("PLAYER_REGEN_ENABLED");
		  this:RegisterEvent("PLAYER_REGEN_DISABLED");
		  this:RegisterEvent("UPDATE_INVENTORY_ALERTS");
     end
     
     if (event == "ITEM_LOCK_CHANGED" or event == "UPDATE_INVENTORY_ALERTS" or (event == "UNIT_INVENTORY_CHANGED" and arg1 == "player")) then
      if TitanPanelAmmoButton:IsVisible() then
        TitanPanelButton_UpdateButton(TITAN_AMMO_ID);
      end
     end
     
     if (event == "PLAYER_REGEN_DISABLED") then
     	UpdateAmmoNow = 1;
     end
     
     if (event == "PLAYER_REGEN_ENABLED") then
     	UpdateAmmoNow = 0;
     	if TitanPanelAmmoButton:IsVisible() then
     			TitanPanelButton_UpdateButton(TITAN_AMMO_ID);
     	end
     end
end

-- **************************************************************************
-- NAME : TitanPanelAmmoButton_OnUpdate(elapsed)
-- DESC : Update button data
-- VARS : elapsed = <research>
-- **************************************************************************
function TitanPanelAmmoButton_OnUpdate(elapsed)
     if (UpdateAmmoNow == 1) then
          AmmoUpdateCounter = AmmoUpdateCounter - elapsed;
          if (AmmoUpdateCounter <=0)  then
               AmmoUpdateCounter = 1;
               if TitanPanelAmmoButton:IsVisible() then
               		TitanPanelButton_UpdateButton(TITAN_AMMO_ID);
               end
          end
     end
end

-- **************************************************************************
-- NAME : TitanPanelAmmoButton_GetButtonText(id)
-- DESC : Calculate ammo/thrown logic then display data on button
-- VARS : id = button ID
-- **************************************************************************
function TitanPanelAmmoButton_GetButtonText(id)
     TitanAmmoTooltip:SetOwner(UIParent, "ANCHOR_NONE");
     TitanAmmoTooltip:ClearLines();
     local ammoSlotID = GetInventorySlotInfo("AmmoSlot");
     local rangedSlotID = GetInventorySlotInfo("RangedSlot");
     
     local isThrown, isAmmo;
     local itemLink = GetInventoryItemLink("player", rangedSlotID);
     if (itemLink~=nil) then
     _, _, _, _, _, _, itemSubType, _, _, _ = GetItemInfo(itemLink);
     end
     if (itemSubType == nil) then
      itemSubType = "";
     end
     
     if (GetInventoryItemQuality("player", rangedSlotID)~=nil and string.find(itemSubType, TITAN_AMMO_THROWN_KEYWORD)) then
          isThrown = 1;
     end
     if (not isThrown and GetInventoryItemQuality("player", ammoSlotID)~=nil) then
          isAmmo = 1;
     end
     
     local labelText, ammoText, ammoRichText, color;
     local count = 0;
     if (isThrown) then
		local HasItem = TitanAmmoTooltip:SetInventoryItem("player", rangedSlotID);
		if HasItem ~= nil then
		for i = 1, 30 do
			local field = getglobal("TitanAmmoTooltipTextLeft" .. i);
			if (field ~= nil) then
				local text = field:GetText();
				if (text) then
				-- find durability
					local _, _, f_val, f_max = string.find(text, REPAIR_LOCALE["pattern"]);
					if (f_val) then
						count = tonumber(f_val);
					end
				end               
			end

    end
    end     
          --count = GetInventoryItemCount("player", rangedSlotID);
          labelText = TITAN_AMMO_BUTTON_LABEL_THROWN;
          ammoText = format(TITAN_AMMO_FORMAT, count);
     elseif (isAmmo) then
          count = GetInventoryItemCount("player", ammoSlotID);
          labelText = TITAN_AMMO_BUTTON_LABEL_AMMO;
          ammoText = format(TITAN_AMMO_FORMAT, count);
     else
          count = 0;
          labelText = TITAN_AMMO_BUTTON_LABEL_AMMO_THROWN;
          ammoText = format(TITAN_AMMO_FORMAT, count);
     end
     
     if (TitanGetVar(TITAN_AMMO_ID, "ShowColoredText")) then     
          color = TitanUtils_GetThresholdColor(TITAN_AMMO_THRESHOLD_TABLE, count);
          ammoRichText = TitanUtils_GetColoredText(ammoText, color);
     else
          ammoRichText = TitanUtils_GetHighlightText(ammoText);
     end

     return labelText, ammoRichText;
end

-- **************************************************************************
-- NAME : TitanPanelRightClickMenu_PrepareAmmoMenu()
-- DESC : Display rightclick menu options
-- **************************************************************************
function TitanPanelRightClickMenu_PrepareAmmoMenu()
     TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_AMMO_ID].menuText);
     TitanPanelRightClickMenu_AddToggleIcon(TITAN_AMMO_ID);
     TitanPanelRightClickMenu_AddToggleLabelText(TITAN_AMMO_ID);
     TitanPanelRightClickMenu_AddToggleColoredText(TITAN_AMMO_ID);
     TitanPanelRightClickMenu_AddSpacer();
     TitanPanelRightClickMenu_AddCommand(TITAN_PANEL_MENU_HIDE, TITAN_AMMO_ID, TITAN_PANEL_MENU_FUNC_HIDE);
end

