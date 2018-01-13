-- **************************************************************************
-- * TitanRider.lua
-- *
-- * By: TitanMod, Dark Imakuni, Adsertor and the Titan Development Team
-- *     (HonorGoG, jaketodd422, joejanko, Lothayer, Tristanian)
-- **************************************************************************

-- ******************************** Constants *******************************
TITAN_PANEL_UPDATE_BUTTON = 1;
TITAN_PANEL_UPDATE_TOOLTIP = 2;
TITAN_PANEL_UPDATE_ALL = 3;
TITAN_PANEL_LABEL_SEPARATOR = "  "
TITAN_PANEL_BUTTON_TYPE_TEXT = 1;
TITAN_PANEL_BUTTON_TYPE_ICON = 2;
TITAN_PANEL_BUTTON_TYPE_COMBO = 3;
TITAN_PANEL_BUTTON_TYPE_CUSTOM = 4;
TITAN_RIDER_ID = "Rider";
TITAN_RIDER_ATTACKBUTTON = 0;
TITAN_RIDER_SWITCH = false;
TITAN_RIDER_IS_MOUNTED = false;
TITAN_DOUBLE_CHECK = false;
TITAN_RIDER_LOCALE = {
     menu = "Rider",
     tooltip = "Rider",
     button = "Rider"
};
TITAN_RIDER_SLOTS = {
          "Head",
          "Neck",
          "Shoulder",
          "Shirt",
          "Chest",
          "Waist",
          "Legs",
          "Feet",
          "Wrist",
          "Hands",
          "Finger0",
          "Finger1",
          "Trinket0",
          "Trinket1",
          "Back",
          "MainHand",
          "SecondaryHand",
          "Ranged",
          "Tabard",
     };
     
-- ******************************** Variables *******************************
CURRENTSTATE = TitanGetVar(TITAN_RIDER_ID,"PlayerState"); 
-- this is a bogus global, it will never get set because Titan Vars wont have time to load
-- to be reviewed further

-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelRiderButton_OnLoad()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TitanPanelRiderButton_OnLoad()
     this.registry = { 
          id = TITAN_RIDER_ID,
          builtIn = 1,
          version = TITAN_VERSION,
          menuText = TITAN_RIDER_LOCALE["menu"],
          buttonTextFunction = "TitanPanelRiderButton_GetButtonText",
          tooltipTitle = TITAN_RIDER_LOCALE["tooltip"],
          tooltipTextFunction = "TitanPanelRiderButton_GetTooltipText",
          icon = "Interface\\AddOns\\Titan\\Artwork\\TitanRider",
          iconWidth = 16,
          savedVariables = {
               ShowIcon = 1,
               ShowLabelText = 1,
               ShowColoredText = TITAN_NIL,
               ShowState = 1,
               DismountDelay = 0,
               PlayerState = 1,
               RiderItems = {"FeetSlot","HandsSlot","Trinket0Slot","Trinket0Slot","Trinket0Slot","Trinket0Slot"},
               RiderEquip = {"Titan Nil","Titan Nil","Titan Nil","Titan Nil","Titan Nil","Titan Nil"}
          }
     };
     this:RegisterEvent("VARIABLES_LOADED")          -- configuration loading
     this:RegisterEvent("PLAYER_REGEN_DISABLED")     -- combat check
     this:RegisterEvent("PLAYER_REGEN_ENABLED")     -- combat check
     this:RegisterEvent("PLAYER_ENTERING_WORLD");
     this:RegisterEvent("PLAYER_UNGHOST");
end

-- **************************************************************************
-- NAME : TitanPanelRiderButton_OnShow()
-- DESC : Create repeating timer when plugin is visible
-- **************************************************************************
function TitanPanelRiderButton_OnShow()
     local hasTimer = TitanPanel:HasTimer("TitanPanel"..TITAN_RIDER_ID)
     if hasTimer then
            --do nothing
     else
          TitanPanel:AddRepeatingTimer("TitanPanel"..TITAN_RIDER_ID, 1, TitanPanelPluginHandle_OnUpdate, TITAN_RIDER_ID, TITAN_PANEL_UPDATE_BUTTON)
     end
end

-- **************************************************************************
-- NAME : TitanPanelRiderButton_OnHide()
-- DESC : Destroy repeating timer when plugin is hidden
-- **************************************************************************
function TitanPanelRiderButton_OnHide()
     local hasTimer = TitanPanel:HasTimer("TitanPanel"..TITAN_RIDER_ID)
     if hasTimer then
          TitanPanel:RemoveTimer("TitanPanel"..TITAN_RIDER_ID)
     end
end

-- **************************************************************************
-- NAME : TitanPanelRiderButton_GetButtonText(id)
-- DESC : Display time on button based on set variables
-- VARS : id = <research>
-- **************************************************************************
function TitanPanelRiderButton_GetButtonText(id)
     local retstr = "";
     local shown =  TitanPanel_IsPluginShown(TITAN_RIDER_ID);

     if shown > 0 then
          if combat_flag == false then
               TitanSetVar(TITAN_RIDER_ID,"PlayerState",TitanRider_PlayerMounted());
               TitanRider_SwitchNeededCheck();
               if CURRENTSTATE ~= TitanGetVar(TITAN_RIDER_ID,"PlayerState") then
                    CURRENTSTATE = TitanGetVar(TITAN_RIDER_ID,"PlayerState");
                    if TITAN_RIDER_SWITCH then
                         TitanRider_SwitchGear();
                    end
               end
          end
     end

     -- supports turning off labels
     if (TitanGetVar(TITAN_RIDER_ID, "ShowLabelText")) then     
          retstr = TITAN_RIDER_LOCALE["button"];
          if TitanGetVar(TITAN_RIDER_ID,"ShowState") then
               retstr = retstr .. ": ";
          end
     end

     if TitanGetVar(TITAN_RIDER_ID,"ShowState") then
          if (TitanGetVar(TITAN_RIDER_ID, "ShowColoredText")) then     
               retstr = retstr .. TitanUtils_GetGreenText(TITAN_RIDER_STATES[TitanGetVar(TITAN_RIDER_ID,"PlayerState")]);
          else
               retstr = retstr .. TitanUtils_GetNormalText(TITAN_RIDER_STATES[TitanGetVar(TITAN_RIDER_ID,"PlayerState")]);
          end
     end

     -- This is a double check to ENSURE all riding equipment is removed as there are cases it will skip or miss the equip swap
     local EquipGear = 0;
     if TITAN_RIDER_IS_MOUNTED == false and combat_flag == false and TITAN_DOUBLE_CHECK == true then
          TitanRider_SwitchGear()
     end

     return retstr;
end

-- **************************************************************************
-- NAME : TitanPanelRiderButton_GetTooltipText()
-- DESC : Display tooltip text
-- **************************************************************************
function TitanPanelRiderButton_GetTooltipText()
     local retstr = "";
     retstr = retstr .. TitanUtils_GetGreenText(TITAN_RIDER_HINT..TITAN_RIDER_STATES[TitanGetVar(TITAN_RIDER_ID,"PlayerState")]);
     return retstr;
end

-- **************************************************************************
-- NAME : TitanPanelRightClickMenu_PrepareRiderMenu()
-- DESC : Display rightclick menu options
-- **************************************************************************
function TitanPanelRightClickMenu_PrepareRiderMenu()

          
     if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) and ( UIDROPDOWNMENU_MENU_VALUE == TITAN_RIDER_OPTIONS_EQUIP ) then
          
          TitanPanelRightClickMenu_AddTitle(TITAN_RIDER_ITEMS_LABEL, UIDROPDOWNMENU_MENU_LEVEL);
          TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL);  
          
          local i;
          for i = 1, table.getn(TITAN_RIDER_ITEM_NAMES) do
               if TITAN_RIDER_ITEM_NAMES[i]~=nil then
                    info = {};
                    info.text = TITAN_RIDER_ITEM_NAMES[i];
                    info.value = TITAN_RIDER_ITEM_NAMES[i];
                    info.checked = TitanGetVarTable(TITAN_RIDER_ID,"RiderEquip",i);
                    info.keepShownOnClick = 1;
                    info.func = TitanRider_SetEquip;
                    UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL);
               end
          end 
    
     else
          
          TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_RIDER_ID].menuText);
     
          TitanPanelRightClickMenu_AddSpacer();

          TitanPanelRightClickMenu_AddToggleIcon(TITAN_RIDER_ID);
          TitanPanelRightClickMenu_AddToggleLabelText(TITAN_RIDER_ID);
          TitanPanelRightClickMenu_AddToggleColoredText(TITAN_RIDER_ID);
     
          info = {};
          info.text = TITAN_RIDER_OPTIONS_SHOWSTATE;
          info.func = TitanRider_StateToggle;
          info.value = TITAN_RIDER_OPTIONS_SHOWSTATE;
          info.checked = TitanGetVar(TITAN_RIDER_ID,"ShowState");
          UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
          
          info = {};
          info.text = TITAN_RIDER_OPTIONS_DISMOUNTDELAY;
          info.func = TitanRider_DismountDelayToggle;
          info.value = TITAN_RIDER_OPTIONS_DISMOUNTDELAY;
          info.checked = TitanGetVar(TITAN_RIDER_ID,"DismountDelay");
          UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

          info = {};
          info.text = TITAN_RIDER_OPTIONS_EQUIP;
          --info.func = TitanRider_EquipToggle;
          info.value = TITAN_RIDER_OPTIONS_EQUIP;
          info.hasArrow = 1;
          --info.checked = TitanGetVar(TITAN_RIDER_ID,"EquipItems");
          UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

          info = {};
          TitanPanelRightClickMenu_AddSpacer();     
          TitanPanelRightClickMenu_AddCommand(TITAN_PANEL_MENU_HIDE, TITAN_RIDER_ID, TITAN_PANEL_MENU_FUNC_HIDE);
     
     end
end

-- **************************************************************************
-- NAME : TitanRider_SetEquip()
-- DESC : Toggle variables
-- **************************************************************************
function TitanRider_SetEquip()
     local i;
     local RiderItem = this.value;

     for i = 1, table.getn(TITAN_RIDER_ITEM_NAMES) do
          if TITAN_RIDER_ITEM_NAMES[i]~=nil then
               if TITAN_RIDER_ITEM_NAMES[i] == RiderItem then
                    if this.checked then     
                         TitanSetVarTable(TITAN_RIDER_ID,"RiderEquip", i, 1);
                    else
                         TitanSetVarTable(TITAN_RIDER_ID,"RiderEquip", i, nil);
                         TitanSetVarTable(TITAN_RIDER_ID,"RiderItems", i,"-none-");
                    end
               end
          end
     end
end

-- **************************************************************************
-- NAME : TitanPanelRiderButton_OnClick(button)
-- DESC : Execute something on left-click of button.
-- VARS : button = value of action
-- **************************************************************************
function TitanPanelRiderButton_OnClick(button)
     if ( button == "LeftButton" ) then
          --Nothing so far
     end
end

-- **************************************************************************
-- NAME : TitanPanelRiderButton_OnEvent()
-- DESC : Parse events registered to plugin and act on them
-- **************************************************************************
function TitanPanelRiderButton_OnEvent()
     local shown =  TitanPanel_IsPluginShown(TITAN_RIDER_ID);

     if shown == nil then
          shown = 0;
     end

     if(event == "VARIABLES_LOADED") then
          combat_flag = false;
     end

     if event == "PLAYER_REGEN_DISABLED" then
          combat_flag = true
     end
       
     if event == "PLAYER_REGEN_ENABLED" then
          combat_flag = false
     end

     if event == "PLAYER_ENTERING_WORLD" then
          combat_flag = false
     end

     if event == "PLAYER_UNGHOST" then
          combat_flag = false
     end

end

-- **************************************************************************
-- NAME : TitanRider_StateToggle()
-- DESC : <research>
-- **************************************************************************
function TitanRider_StateToggle()
     TitanToggleVar(TITAN_RIDER_ID, "ShowState");
end

-- **************************************************************************
-- NAME : TitanRider_DismountDelayToggle()
-- DESC : <research>
-- **************************************************************************
function TitanRider_DismountDelayToggle()
     TitanToggleVar(TITAN_RIDER_ID, "DismountDelay");
end

-- **************************************************************************
-- NAME : TitanRider_PlayerMounted()
-- DESC : <research>
-- **************************************************************************
function TitanRider_PlayerMounted()
     if IsFlying() then
          TITAN_RIDER_IS_MOUNTED = true;
          TITAN_DOUBLE_CHECK = true;
          return 3;
     elseif UnitOnTaxi("player") then
          TITAN_RIDER_IS_MOUNTED = false;
          TITAN_DOUBLE_CHECK = false;
          return 4;
     elseif IsMounted() then
          TITAN_RIDER_IS_MOUNTED = true;
          TITAN_DOUBLE_CHECK = true;
          return 2;
     elseif IsSwimming() then
          TITAN_RIDER_IS_MOUNTED = false;
          TITAN_DOUBLE_CHECK = false;
          return 5;
     else
          TITAN_RIDER_IS_MOUNTED = false;
          TITAN_DOUBLE_CHECK = false;
          return 1;
     end
end

-- **************************************************************************
-- NAME : TitanRider_SwitchNeededCheck()
-- DESC : <research>
-- **************************************************************************
function TitanRider_SwitchNeededCheck()
     if (CURRENTSTATE == 2 or CURRENTSTATE == 3) and (TitanGetVar(TITAN_RIDER_ID,"PlayerState") == 2 or TitanGetVar(TITAN_RIDER_ID,"PlayerState") == 3) then
          TITAN_RIDER_SWITCH = false;
     elseif (CURRENTSTATE ~= 2 or CURRENTSTATE ~= 3) and (TitanGetVar(TITAN_RIDER_ID,"PlayerState") == 2 or TitanGetVar(TITAN_RIDER_ID,"PlayerState") == 3) then
          TITAN_RIDER_SWITCH = true;
     elseif (CURRENTSTATE == 2 or CURRENTSTATE == 3) and (TitanGetVar(TITAN_RIDER_ID,"PlayerState") ~= 2 or TitanGetVar(TITAN_RIDER_ID,"PlayerState") ~= 3) then
          TITAN_RIDER_SWITCH = true;
     else     
          TITAN_RIDER_SWITCH = false;
     end
end

-- **************************************************************************
-- NAME : TitanRider_SwitchGear()
-- DESC : <research>
-- **************************************************************************
function TitanRider_SwitchGear()
     if (TITAN_RIDER_IS_MOUNTED) then
          TitanRider_EquipRidingGear();
     else
          if (UnitHealth ("player") > 1) then
               if TitanGetVar(TITAN_RIDER_ID,"DismountDelay") then
                    TitanPanel:AddTimer("TitanPanel"..TITAN_RIDER_ID.."Delay", 10, TitanRider_RemoveRidingGear)
               else
                    TitanRider_RemoveRidingGear()
               end
          end
     end               
end

-- **************************************************************************
-- NAME : TitanRider_EquipRidingGear()
-- DESC : <research>
-- **************************************************************************
function TitanRider_EquipRidingGear()
     local i;
     local EquipGear = 0;
     for EquipGear = 1, TITAN_RIDER_ITEMS do
          local EquipItem = true;
          --if (TitanGetVarTable(TITAN_RIDER_ID,"RiderItems",EquipGear) == TITAN_RIDER_ITEM_SLOTS[EquipGear] or TitanGetVarTable(TITAN_RIDER_ID,"RiderItems",EquipGear) == "-none-") then
               if TitanGetVarTable(TITAN_RIDER_ID,"RiderEquip",EquipGear) == 1 then -- yes to equip
                    local bagNum, itemInBagNum = TitanUtils_FindInventoryItemWithTextAndSlot(TITAN_RIDER_ITEM_NAMES[EquipGear], TITAN_RIDER_ITEM_DESCS[EquipGear], EquipGear);
                              
                    for i=1,GetNumShapeshiftForms(),1 do
                         local _, formname, isFormActive = GetShapeshiftFormInfo(i);
                         if (formname == TITAN_RIDER_DRUID_FLIGHT_FORM or formname == TITAN_RIDER_DRUID_SWIFTFLIGHT_FORM) and isFormActive and EquipGear~= 6 then
                              EquipItem = false;
                         end
                    end
                                                            
                    if (bagNum ~= nil) and EquipItem then
               
                         if EquipGear == 6 and IsMounted() and not IsFlying() then
                              TitanSetVarTable(TITAN_RIDER_ID,"RiderItems",EquipGear,"-none-");
                              break;                               
                         end
               
                         local newItemLink = GetContainerItemLink(bagNum, itemInBagNum);
                         local normalItemLink = GetInventoryItemLink("player", GetInventorySlotInfo(TITAN_RIDER_ITEM_SLOTS[EquipGear]));
     
                         if (normalItemLink ~= nil) then
                              local gearBagNum, gearItemInBagNum, tempstr;
                              _, _, tempstr = string.find (normalItemLink, "%[(.+)%]");
                              if tempstr~= nil then
                                   TitanSetVarTable(TITAN_RIDER_ID,"RiderItems", EquipGear, tempstr);
                              else
                                   TitanSetVarTable(TITAN_RIDER_ID,"RiderItems", EquipGear, "-none-");
                              end
                         else
                              TitanSetVarTable(TITAN_RIDER_ID,"RiderItems", EquipGear, "-none-");
                         end
                         
                         if (CursorHasItem()) then PickupSpell(1, "spell"); end
                         PickupContainerItem (bagNum, itemInBagNum);
                         AutoEquipCursorItem();
                    else
                         -- new routine to check inventory as well
                         local i, f, slotname, slotid, hasItem, itemName, itemLink;
                         local foundonchar = false;
               
                         TitanRiderTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
               
                         for i, slotname in pairs(TITAN_RIDER_SLOTS) do
                              slotid, _ = GetInventorySlotInfo(slotname.. "Slot");
                              TitanRiderTooltip:ClearLines();
                              hasItem = TitanRiderTooltip:SetInventoryItem("player", slotid);
          
                              if hasItem~=nil then
                                   itemName, itemLink = TitanRiderTooltip:GetItem();
                                   if itemLink ~= nil then
                                        -- check name
                                        if itemName == TITAN_RIDER_ITEM_NAMES[EquipGear] then
                                             foundonchar = true;
                                        else                     
                                             -- if not name check description
                                             for f = 1, 30 do
                                                  local field = getglobal("TitanRiderTooltipTextLeft" .. i);
                                                  if (field ~= nil) then
                                                       local text = field:GetText();
                                                       if text ~=nil then
                                                            if (string.find(text,TITAN_RIDER_ITEM_DESCS[EquipGear])) then
                                                                 foundonchar = true;
                                                            end
                                                       end
                                                  end
                                             end
                                        end
                                   end
                              end 
                         end
               
                         -- if a valid item name exists in the rider table dont delete it
                         if foundonchar and TitanGetVarTable(TITAN_RIDER_ID,"RiderItems",EquipGear) ~= "-none-" then
                              -- do nothing
                         else
                              TitanSetVarTable(TITAN_RIDER_ID,"RiderItems",EquipGear,"-none-");
                         end
                    end
                end -- yes to equip
          --end
     end
end

-- **************************************************************************
-- NAME : TitanRider_RemoveRidingGear()
-- DESC : <research>
-- **************************************************************************
function TitanRider_RemoveRidingGear()
     -- Remove timer
     local hasTimer = TitanPanel:HasTimer("TitanPanel"..TITAN_RIDER_ID.."Delay")
     if hasTimer then
          TitanPanel:RemoveTimer("TitanPanel"..TITAN_RIDER_ID.."Delay")
     end
     if ( TitanGetVar(TITAN_RIDER_ID,"DismountDelay") and combat_flag ) then
          --DEFAULT_CHAT_FRAME:AddMessage("Combat_Flag: TRUE");
          TITAN_RIDER_IS_MOUNTED = false;
          TitanRider_SwitchGear()
          -- do nothing
     else
          --DEFAULT_CHAT_FRAME:AddMessage("Combat_Flag: FALSE");
          local EquipGear = 0;
          for EquipGear = 1, TITAN_RIDER_ITEMS do
               if (TitanGetVarTable(TITAN_RIDER_ID,"RiderItems",EquipGear) ~= TITAN_RIDER_ITEM_SLOTS[EquipGear]) then
                    local bagNum, itemInBagNum = TitanUtils_FindInventoryItemWithText(TitanGetVarTable(TITAN_RIDER_ID,"RiderItems",EquipGear));

                    if (bagNum ~= nil) and TitanGetVarTable(TITAN_RIDER_ID,"RiderItems",EquipGear) ~= nil and TitanGetVarTable(TITAN_RIDER_ID,"RiderItems",EquipGear) ~= "-none-" then
                         local normalItemLink = GetContainerItemLink(bagNum, itemInBagNum);
                         if (CursorHasItem()) then PickupSpell(1, "spell"); end
                         PickupContainerItem (bagNum, itemInBagNum);
                         AutoEquipCursorItem();
                    end
                    local newItemLink = GetInventoryItemLink("player", GetInventorySlotInfo(TITAN_RIDER_ITEM_SLOTS[EquipGear]));
                    if newItemLink == normalItemLink then
                         TitanSetVarTable(TITAN_RIDER_ID,"RiderItems",EquipGear,TITAN_RIDER_ITEM_SLOTS[EquipGear]);
                         TITAN_DOUBLE_CHECK = false;
                    end
               end
          end
     end
end