-- **************************************************************************
-- * TitanRepair.lua
-- *
-- * By: Adsertor, Archarodim and the Titan Development Team
-- *     (HonorGoG, jaketodd422, joejanko, Lothayer, Tristanian)
-- **************************************************************************

-- ******************************** Constants *******************************
TITAN_REPAIR_ID = "Repair";
REPAIR_INDEX = 0;
REPAIR_MONEY = 0;
REPAIR_ITEM_STATUS = {};
REPAIR_ITEM_BAG = {};
-- this index (0) will be never set, just accessed to this state, it simplifies code for TitanRepair_GetMostDamagedItem() when Tit_R_EquipedMinIndex == 0
REPAIR_ITEM_STATUS[0] = { val = 0, max = 0, cost = 0, name = INVTYPE_HEAD, slot = "VIRTUAL" };
REPAIR_ITEM_STATUS[1] = { val = 0, max = 0, cost = 0, name = INVTYPE_HEAD, slot = "Head" };
REPAIR_ITEM_STATUS[2] = { val = 0, max = 0, cost = 0, name = INVTYPE_SHOULDER, slot = "Shoulder" };
REPAIR_ITEM_STATUS[3] = { val = 0, max = 0, cost = 0, name = INVTYPE_CHEST, slot = "Chest" };
REPAIR_ITEM_STATUS[4] = { val = 0, max = 0, cost = 0, name = INVTYPE_WAIST, slot = "Waist" };
REPAIR_ITEM_STATUS[5] = { val = 0, max = 0, cost = 0, name = INVTYPE_LEGS, slot = "Legs" };
REPAIR_ITEM_STATUS[6] = { val = 0, max = 0, cost = 0, name = INVTYPE_FEET, slot = "Feet" };
REPAIR_ITEM_STATUS[7] = { val = 0, max = 0, cost = 0, name = INVTYPE_WRIST, slot = "Wrist" };
REPAIR_ITEM_STATUS[8] = { val = 0, max = 0, cost = 0, name = INVTYPE_HAND, slot = "Hands" };
REPAIR_ITEM_STATUS[9] = { val = 0, max = 0, cost = 0, name = INVTYPE_WEAPONMAINHAND, slot = "MainHand" };
REPAIR_ITEM_STATUS[10] = { val = 0, max = 0, cost = 0, name = INVTYPE_WEAPONOFFHAND, slot = "SecondaryHand" };
REPAIR_ITEM_STATUS[11] = { val = 0, max = 0, cost = 0, name = INVTYPE_RANGED, slot = "Ranged" };
REPAIR_ITEM_STATUS[12] = { val = 0, max = 0, cost = 0, name = INVENTORY_TOOLTIP };
INVENTORY_REPAIR_STATUS = {}
INVENTORY_REPAIR_STATUS[0] = { val = 0, max = 0, cost = 0, name = INVENTORY_TOOLTIP };
INVENTORY_REPAIR_STATUS[1] = { val = 0, max = 0, cost = 0, name = INVENTORY_TOOLTIP };
INVENTORY_REPAIR_STATUS[2] = { val = 0, max = 0, cost = 0, name = INVENTORY_TOOLTIP };
INVENTORY_REPAIR_STATUS[3] = { val = 0, max = 0, cost = 0, name = INVENTORY_TOOLTIP };
INVENTORY_REPAIR_STATUS[4] = { val = 0, max = 0, cost = 0, name = INVENTORY_TOOLTIP };

-- ******************************** Variables *******************************
local TitRep_show_debug = false; -- will tell you a lot about what's happening
local Tit_R_WholeScanInProgress = false;
local Tit_R_UpdateCheckDelay = 2; -- 2 seconds must elaps between scans
local Tit_R_UpdateEquipCheck = 30; -- 30 seconds must elaps between Equiped scans
local Tit_R_DelayTimer = 0; -- init the timer
local Tit_R_EquipedMinIndex = 0; -- keep a record of the most damaged equiped item (used when removing the most damaged item placed in the inventory to switch on an equiped index)
local Tit_R_PleaseCheckBag = { };
local Tit_R_CouldRepair = false;
local Tit_R_CheckForUpdate = false; -- tells the TitanPanelRepairButton_OnUpdate() function that it has something to do
local Tit_R_MerchantisOpen = false;
Tit_R_PleaseCheckBag[0]  = 0; -- Tit_R_PleaseCheckBag element values meaning:
Tit_R_PleaseCheckBag[1]  = 0; --  0 means "This bag did not changed, no need to scan it"
Tit_R_PleaseCheckBag[2]  = 0; --  1 means "Please Check This Bag"
Tit_R_PleaseCheckBag[3]  = 0; --  2 means "Yes I'm checking, don't disturb me"
Tit_R_PleaseCheckBag[4]  = 0;
Tit_R_PleaseCheckBag[5]  = 0; -- this will be used for equiped items, not very good but simplify the code...
local InitialLoad = 0; -- Found no use of this

StaticPopupDialogs["REPAIR_CONFIRMATION"] = {
    text = TEXT(REPAIR_LOCALE["confirmation"]),
    button1 = TEXT(YES),
    button2 = TEXT(NO),
    OnAccept = function()
     TitanRepair_RepairItems();
     TitanPanelRepairButton_ScanAllItems();
     Tit_R_CheckForUpdate = true;
     Tit_R_CouldRepair = false;
    end,
    OnShow = function()
     MoneyFrame_Update(this:GetName().."MoneyFrame", REPAIR_MONEY);
    end,     
    hasMoneyFrame = 1,
    timeout = 0,
};

-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelRepairButton_OnLoad()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TitanPanelRepairButton_OnLoad()
	this.registry = { 
		id = TITAN_REPAIR_ID,
     	builtIn = 1,
     	version = TITAN_VERSION,
     	menuText = REPAIR_LOCALE["menu"],
     	buttonTextFunction = "TitanPanelRepairButton_GetButtonText",
     	tooltipTitle = REPAIR_LOCALE["tooltip"],
     	tooltipTextFunction = "TitanPanelRepairButton_GetTooltipText",
     	icon = "Interface\\AddOns\\Titan\\Artwork\\TitanRepair",
     	iconWidth = 16,
     	savedVariables = {
			ShowIcon = 1,
			ShowLabelText = 1,
			ShowItemName = TITAN_NIL,
			ShowUndamaged = TITAN_NIL,
			ShowPopup = TITAN_NIL,
			AutoRepair = TITAN_NIL,
			DiscountFriendly = TITAN_NIL,
			DiscountHonored = TITAN_NIL,
			DiscountRevered = TITAN_NIL,
			DiscountExalted = TITAN_NIL,
			ShowPercentage = TITAN_NIL,
			ShowColoredText = TITAN_NIL,
			ShowInventory = 1 -- this is no longer a problem :-D
		}
	};

    this:RegisterEvent("PLAYER_LEAVING_WORLD");
    this:RegisterEvent("PLAYER_ENTERING_WORLD");
end

-- **************************************************************************
-- NAME : TitanPanelRepairButton_ScanAllItems()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TitanPanelRepairButton_ScanAllItems()
	if (TitanGetVar(TITAN_REPAIR_ID,"ShowInventory") == 1) then
		Tit_R_PleaseCheckBag[0]  = 1;
		Tit_R_PleaseCheckBag[1]  = 1;
		Tit_R_PleaseCheckBag[2]  = 1;
		Tit_R_PleaseCheckBag[3]  = 1;
		Tit_R_PleaseCheckBag[4]  = 1;
	end
	Tit_R_PleaseCheckBag[5]  = 1;

	Tit_R_WholeScanInProgress = true;
	TitanPanelButton_UpdateButton(TITAN_REPAIR_ID);

end

-- **************************************************************************
-- NAME : TitanPanelRepairButton_OnEvent()
-- DESC : This section will grab the events registered to the add on and act on them
-- **************************************************************************
function TitanPanelRepairButton_OnEvent()

	-- NOTE that events test are done in probability order:
	-- The events that fires the most are tested first

	if (event == "UPDATE_INVENTORY_ALERTS") then
		-- register to check the equiped items on next appropriate OnUpdate call
          if (TitRep_show_debug) then -- this if is not necessary but is here to optimize this part the most possible
					tit_debug_bis("Event " .. event .. " TREATED!");
          end
          Tit_R_PleaseCheckBag[5] = 1;
          Tit_R_CheckForUpdate = true;
          return;

	end
	  
	-- when arg1 is > 4 it means that a bank's bag has been updated
	if ( (event == "BAG_UPDATE") and (arg1 < 5) and (TitanGetVar(TITAN_REPAIR_ID,"ShowInventory") == 1)) then
		-- register to check this bag's items on next appropriate OnUpdate call
          if (TitRep_show_debug) then -- this if is not necessary but is here to optimize this part the most possible
					tit_debug_bis("Event " .. event .. " TREATED!");
          end

          Tit_R_PleaseCheckBag[5] = 1;
          Tit_R_PleaseCheckBag[arg1] = 1;
          Tit_R_CheckForUpdate = true;
          return;
	end

    


	if (event == "MERCHANT_SHOW") then
	  Tit_R_MerchantisOpen = true;
	  local canRepair = CanMerchantRepair();
	   if not canRepair then
	   return;
	   end
		if (TitanGetVar(TITAN_REPAIR_ID,"ShowInventory") == 1) then
			Tit_R_PleaseCheckBag[0]  = 1;
			Tit_R_PleaseCheckBag[1]  = 1;
			Tit_R_PleaseCheckBag[2]  = 1;
			Tit_R_PleaseCheckBag[3]  = 1;
			Tit_R_PleaseCheckBag[4]  = 1;
          end
		Tit_R_PleaseCheckBag[5] = 1;
		Tit_R_CheckForUpdate = true;
          if TitanGetVar(TITAN_REPAIR_ID,"ShowPopup") == 1 then
			local repairCost, canRepair = GetRepairAllCost();
			if (canRepair) then
				Tit_R_CouldRepair = true;
				--local invcost = TitanRepair_GetRepairInvCost();
				if (repairCost > 0) then
					REPAIR_MONEY = repairCost;
					StaticPopup_Show("REPAIR_CONFIRMATION");
				end
			end
          end
          
    -- handle auto-repair     
    if (TitanGetVar(TITAN_REPAIR_ID,"AutoRepair") == 1) then
     local repairCost, canRepair = GetRepairAllCost();
       if (canRepair) then
				Tit_R_CouldRepair = true;
				 if (repairCost > 0) then
				    TitanRepair_RepairItems();
     				TitanPanelRepairButton_ScanAllItems();
     				Tit_R_CheckForUpdate = true;
     				Tit_R_CouldRepair = false;
				 end
			 end
		end	 
		
          return;
	end

	if ( event == "MERCHANT_CLOSED" ) then
		Tit_R_MerchantisOpen = false;
          StaticPopup_Hide("REPAIR_CONFIRMATION");
          -- When an object is repaired in a bag, the BAG_UPDATE event is not sent... :'(
          -- so we rescan all
          if (Tit_R_CouldRepair) then
					TitanPanelRepairButton_ScanAllItems();
					Tit_R_CheckForUpdate = true;
					Tit_R_CouldRepair = false;
					else
					if (TitanGetVar(TITAN_REPAIR_ID,"ShowInventory") == 1) then
					Tit_R_PleaseCheckBag[0]  = 1;
					Tit_R_PleaseCheckBag[1]  = 1;
					Tit_R_PleaseCheckBag[2]  = 1;
					Tit_R_PleaseCheckBag[3]  = 1;
					Tit_R_PleaseCheckBag[4]  = 1;
					end
					Tit_R_PleaseCheckBag[5] = 1;
					Tit_R_CheckForUpdate = true;
          end;
          return;
	end

   

	if (event == "PLAYER_ENTERING_WORLD") then
          this:RegisterEvent("BAG_UPDATE");
          this:RegisterEvent("UPDATE_INVENTORY_ALERTS");
          this:RegisterEvent("MERCHANT_SHOW");
          this:RegisterEvent("MERCHANT_CLOSED");

          -- Check everything on world enter (at init and after zoning)
          -- (NOTE: this will take 6 * Tit_R_UpdateCheckDelay seconds to update)
          TitanPanelRepairButton_ScanAllItems();
          Tit_R_CheckForUpdate = true;
          return;
	end

	if (event == "PLAYER_LEAVING_WORLD") then
          this:UnregisterEvent("BAG_UPDATE");
          this:UnregisterEvent("UPDATE_INVENTORY_ALERTS");
          this:UnregisterEvent("MERCHANT_SHOW");
          this:UnregisterEvent("MERCHANT_CLOSED");
          return;
	end

end

-- **************************************************************************
-- NAME : tit_debug_bis(Message)
-- DESC : Debug function to print message to chat frame
-- VARS : Message = message to print to chat frame
-- **************************************************************************
function tit_debug_bis(Message)
	if (TitRep_show_debug) then
		DEFAULT_CHAT_FRAME:AddMessage("TiT_Rep: " .. Message, 0.5, 0.3, 1);
	end
end


-- **************************************************************************
-- NAME : TitanPanelRepairButton_OnUpdate(Elapsed)
-- DESC : <research>
-- VARS : elapsed = <research>
-- **************************************************************************
function TitanPanelRepairButton_OnUpdate(Elapsed)
	Tit_R_UpdateEquipCheck = Tit_R_UpdateEquipCheck - Elapsed;
     if (Tit_R_UpdateEquipCheck <= 0 ) then
     if (TitanGetVar(TITAN_REPAIR_ID,"ShowInventory") == 1) and Tit_R_MerchantisOpen then
			Tit_R_PleaseCheckBag[0]  = 1;
			Tit_R_PleaseCheckBag[1]  = 1;
			Tit_R_PleaseCheckBag[2]  = 1;
			Tit_R_PleaseCheckBag[3]  = 1;
			Tit_R_PleaseCheckBag[4]  = 1;
     end
		Tit_R_PleaseCheckBag[5] = 1;
          Tit_R_CheckForUpdate = true;
          Tit_R_UpdateEquipCheck = 30;
     end

	-- Note that Tit_R_CheckForUpdate is a boolean value, boolean values are easier to test for the cpu
	if (not Tit_R_CheckForUpdate) then
          return;
	end
	Tit_R_CheckForUpdate = false; -- this is the first thing we do so another event that fires while we are here can set it to true

	-- test if a "bag" needs to be scanned
	for tocheck = 0, 5 do
     
		-- if there is one
          if (Tit_R_PleaseCheckBag[tocheck] == 1) then

			Tit_R_CheckForUpdate = true; -- so Tit_R_CheckForUpdate will remain false only if there WAS nothing to do :-) (The WAS is important)
                               -- and ONLY if no event fires while we were in this loop... We can't miss anything :-D

			-- increase the delay timer
			Tit_R_DelayTimer = Tit_R_DelayTimer + Elapsed;

			-- if enough time has elapsed
			if (Tit_R_DelayTimer > Tit_R_UpdateCheckDelay) then

				-- we are checking...
                    Tit_R_PleaseCheckBag[tocheck] = 2;
                    -- reset the timer, next update will be made once Tit_R_UpdateCheckDelay seconds have elapsed from now
                    Tit_R_DelayTimer = 0;

                    if (tocheck ~= 5) then  -- call update inventory function (I've put this test first because there is 5 chances on 6 that it returns true)
					tit_debug_bis("Update: Checking bag " .. tocheck .. " as requested");
					TitanRepair_GetInventoryInformation(tocheck);
                    else               -- call update equiped items function
					tit_debug_bis("Update: Checking equiped items as requested");
					TitanRepair_GetEquipedInformation();
                    end

                    -- test if another check was not asked during this update (avoid to miss something... rare but still)
                    if (Tit_R_PleaseCheckBag[tocheck] ~= 1) then
					-- Check completed
					Tit_R_PleaseCheckBag[tocheck] = 0;
                    end

                    -- we break here since we don't have time to scan anything else.
                    break;

			else
                    break;
			end
		end
	end

	--These lines are commented because they're here just for debugging...
	--if (not Tit_R_CheckForUpdate) then
     	--if we get here it means there was nothing to update (we've gone through 0 to 5 without hitting a bag to check that would have set Tit_R_CheckForUpdatep to true)
		--tit_debug_bis("***No more \"Please\" to handle, easy mode on");
	--end

end;

-- **************************************************************************
-- NAME : TitanRepair_GetStatusPercent(val, max)
-- DESC : <research>
-- VARS : val = <research>, max = <research>
-- **************************************************************************
function TitanRepair_GetStatusPercent(val, max)

	if (max > 0) then
		return (val / max);
	end

	return 1.0;

end;

-- **************************************************************************
-- NAME : TitanRepair_GetMostDamagedItem()
-- DESC : <research>
-- **************************************************************************
function TitanRepair_GetMostDamagedItem()
	-- Get repair status for Equiped items and inventory
	--         NOTE: TitanRepair_GetStatusPercent() will return 1.0 if max value <= 0
	local EquipedItemsStatus   = TitanRepair_GetStatusPercent( REPAIR_ITEM_STATUS[Tit_R_EquipedMinIndex].val, REPAIR_ITEM_STATUS[Tit_R_EquipedMinIndex].max );
	local InventoryItemsStatus = TitanRepair_GetStatusPercent( REPAIR_ITEM_STATUS[12].val,                REPAIR_ITEM_STATUS[12].max );

	-- if everything is repaired
	if (EquipedItemsStatus == 1.0 and InventoryItemsStatus == 1.0) then
		tit_debug_bis("Everything is repaired");
		return 0;
	end

	-- If something is more or equaly damaged than the current most damaged equiped item
	--
	--   NOTE: The <= is important because InventoryItemsStatus is updated BEFORE EquipedItemsStatus
	--         The typicale case is when you move the most damaged equiped item to your iventory,
	--         when this function will be called by TitanRepair_GetInventoryInformation(), Tit_R_EquipedMinIndex will point to an empty slot: 
	--         since TitanRepair_GetEquipedInformation() won't have been called yet (bag update events are treated before equiped item event),
	--         EquipedItemsStatus will be egual to InventoryItemsStatus...
	--         So the <= is to avoid that Tit_R_EquipedMinIndex points to nothing (even if it has no concequence right now, it may save hours of debugging some day...)

	if ( (InventoryItemsStatus <= EquipedItemsStatus) and (TitanGetVar(TITAN_REPAIR_ID,"ShowInventory") == 1) ) then
		tit_debug_bis("Inventory is more damaged than equiped items");
		return 12;
	else -- if EquipedItemsStatus < InventoryItemsStatus
		tit_debug_bis("Equiped items are more damaged than inventory");
		return Tit_R_EquipedMinIndex;
	end

	-- Typical 6 possibilities:
	--   - InventoryItemsStatus == 1 and EquipedItemsStatus == 1  ==> returns 0
	--   - InventoryItemsStatus <  1 and EquipedItemsStatus == 1  ==> returns 12
	--   - InventoryItemsStatus == 1 and EquipedItemsStatus <  1  ==> ! (InventoryItemsStatus <= EquipedItemsStatus) ==> returns Tit_R_EquipedMinIndex
	--   - InventoryItemsStatus <  1 and EquipedItemsStatus <  1  :
	--          - InventoryItemsStatus  <=  EquipedItemsStatus       ==> returns 12
	--          - InventoryItemsStatus  >   EquipedItemsStatus       ==> ! (InventoryItemsStatus <= EquipedItemsStatus) ==> returns Tit_R_EquipedMinIndex

end;

-- **************************************************************************
-- NAME : TitanRepair_GetInventoryInformation(bag)
-- DESC : <research>
-- VARS : bag = <research>
-- **************************************************************************
function TitanRepair_GetInventoryInformation(bag)

 -- check to see if a merchant that can repair is open
  if Tit_R_MerchantisOpen then
  local canRepair = CanMerchantRepair();
	   if not canRepair then
	   return;
	   end
	end


	local min_status = 1.0;
	local min_val = 0;
	local min_max = 0;

	TitanRepairTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");

	if (bag > 4) then -- should never get true though, bag > 4 are for the bank's bags
		return;
	end

	-- we re-scan the whole bag so we reset its status
	INVENTORY_REPAIR_STATUS[bag].cost = 0; -- reset this bag globl repair cost
	INVENTORY_REPAIR_STATUS[bag].val  = 0; -- 
	INVENTORY_REPAIR_STATUS[bag].max  = 0; -- 

	for slot = 1, GetContainerNumSlots(bag) do -- find the most damaged item of this bag

		local act_status, act_val, act_max, act_cost = TitanRepair_GetStatus(slot, bag); -- retrieve slot's item repair status

		--if (act_status < min_status) then -- if this item is more damaged than the others
			--min_status = act_status;
			--min_val = act_val;
			--min_max = act_max;

			-- set the global bag repair state to this item state
			--INVENTORY_REPAIR_STATUS[bag].val = act_val;
			--INVENTORY_REPAIR_STATUS[bag].max = act_max;
         
			if act_max ~= 0 then
				INVENTORY_REPAIR_STATUS[bag].val = INVENTORY_REPAIR_STATUS[bag].val + act_val;
				INVENTORY_REPAIR_STATUS[bag].max = INVENTORY_REPAIR_STATUS[bag].max + act_max;
			end         
		--end
		-- add this item cost to this bag global repair cost
		INVENTORY_REPAIR_STATUS[bag].cost = INVENTORY_REPAIR_STATUS[bag].cost + act_cost;
	end

	-- We check all the bags so we reset the global inventory status
	REPAIR_ITEM_STATUS[12].cost = 0;    -- reset global repair cost for inventory
	REPAIR_ITEM_STATUS[12].val     = 0;     -- 
	REPAIR_ITEM_STATUS[12].max     = 0;     -- 
	min_status = 1.0;               -- reset min status to maximum

	-- let's find the bag that contains the most damaged item of the inventory
	for bag = 0, 4 do

		local act_val     = INVENTORY_REPAIR_STATUS[bag].val ;
		local act_max     = INVENTORY_REPAIR_STATUS[bag].max ;
		local act_cost     = INVENTORY_REPAIR_STATUS[bag].cost ;
		local act_status= TitanRepair_GetStatusPercent(act_val, act_max);
     
		-- if the bag contains a damaged item (else act_status == 1, and min_status <= 1 and so this if never get true)
		--if (act_status < min_status) then
			--min_status = act_status;
			--min_val = act_val;
			--min_max = act_max;
               
			--REPAIR_ITEM_STATUS[12].val = act_val;
			--REPAIR_ITEM_STATUS[12].max = act_max;
         
			-- if act_max ~= 0 then
				REPAIR_ITEM_STATUS[12].val = REPAIR_ITEM_STATUS[12].val + act_val;
				REPAIR_ITEM_STATUS[12].max = REPAIR_ITEM_STATUS[12].max + act_max;
			--end
		--end
		-- add each bag global repair cost to inventory global repair cost
		REPAIR_ITEM_STATUS[12].cost = REPAIR_ITEM_STATUS[12].cost + act_cost;
	end

	REPAIR_INDEX = TitanRepair_GetMostDamagedItem();

	tit_debug_bis("(inv) REPAIR_INDEX=" ..REPAIR_INDEX );

	-- Update the button text only if we are not waiting for TitanRepair_GetEquipedInformation()
	--         else an incorrect value may be displayed till TitanRepair_GetEquipedInformation() is called
	--         if a whole scan is in progress we update the button ("Updating..." is displayed in that case, so incorrect values are acceptable)
	if ( (Tit_R_PleaseCheckBag[5] == 0) or Tit_R_WholeScanInProgress ) then
		TitanPanelButton_UpdateButton(TITAN_REPAIR_ID);
	else
		tit_debug_bis("Waiting for updating button text");
	end
	TitanPanelButton_UpdateTooltip();
	TitanRepairTooltip:Hide();
end

-- **************************************************************************
-- NAME : TitanRepair_GetEquipedInformation()
-- DESC : <research>
-- **************************************************************************
function TitanRepair_GetEquipedInformation()

 -- check to see if a merchant that can repair is open
  if Tit_R_MerchantisOpen then
  local canRepair = CanMerchantRepair();
	   if not canRepair then
	   return;
	   end
	end

	local min_status = 1.0;
     local min_val = 0;
     local min_max = 0;
     local min_index = 0;
     Tit_R_EquipedMinIndex = 0;
     
		TitanRepairTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");

     for index, value in pairs(INVENTORY_ALERT_STATUS_SLOTS) do -- index begins from 1

          local act_status, act_val, act_max, act_cost = TitanRepair_GetStatus(index);
          if ( act_status < min_status ) then
			min_status = act_status;
               min_val = act_val;
               min_max = act_max;
               min_index = index;
          end

          REPAIR_ITEM_STATUS[index].val = act_val;
          REPAIR_ITEM_STATUS[index].max = act_max;
          REPAIR_ITEM_STATUS[index].cost = act_cost;
     end
     Tit_R_EquipedMinIndex = min_index;
     

     REPAIR_INDEX = TitanRepair_GetMostDamagedItem();

     -- if a whole update is in progress, and we are here, then we have finished this wole update :)
     -- it has to be here because it changes the text of the button.
     if (Tit_R_WholeScanInProgress) then
		Tit_R_WholeScanInProgress = false;
     end

     tit_debug_bis("(equip) REPAIR_INDEX=" ..REPAIR_INDEX  .. "  min_index=" .. min_index);

     TitanPanelButton_UpdateButton(TITAN_REPAIR_ID);
     TitanPanelButton_UpdateTooltip();
	TitanRepairTooltip:Hide();
end

-- **************************************************************************
-- NAME : TitanRepair_GetStatus(index, bag)
-- DESC : <research>
-- VARS : index = <research>, bag = <research>
-- **************************************************************************
function TitanRepair_GetStatus(index, bag)
	local val = 0;
	local max = 0;
	local cost = 0;
	local hasItem, repairCost

	TitanRepairTooltip:ClearLines();

	if (bag) then
		local _, lRepairCost = TitanRepairTooltip:SetBagItem(bag, index);
		repairCost = lRepairCost;
		hasItem = 1;
	else
		local slotName = REPAIR_ITEM_STATUS[index].slot .. "Slot";

		local id = GetInventorySlotInfo(slotName);
		local lHasItem, _, lRepairCost = TitanRepairTooltip:SetInventoryItem("player", id);
		hasItem = lHasItem;
		repairCost = lRepairCost;
	end

	if (hasItem) then
		if (repairCost) then
			cost = repairCost;
		end

		for i = 1, 30 do
			local field = getglobal("TitanRepairTooltipTextLeft" .. i);
			if (field ~= nil) then
				local text = field:GetText();
				if (text) then
					-- find durability
					local _, _, f_val, f_max = string.find(text, REPAIR_LOCALE["pattern"]);
					if (f_val) then
						val = tonumber(f_val);
						max = tonumber(f_max);
					end
				end               
			end

		end

	end

	return TitanRepair_GetStatusPercent(val, max), val, max, cost;

end

-- **************************************************************************
-- NAME : TitanRepair_GetStatusStr(index, short)
-- DESC : <research>
-- VARS : index = <research>, short = <research>
-- **************************************************************************
local Tit_R_LastKnownText = "";
local Tit_R_LastKnownItemFrac = 1.0;
function TitanRepair_GetStatusStr(index, short)
	-- skip if fully repaired
	if (index == 0) then
		return TitanRepair_AutoHighlight(1.0, "100%");
	end

	local valueText = "";
          
	-- if used for button text
	if (short) then
		valueText = Tit_R_LastKnownText;
	end

	local item_status = REPAIR_ITEM_STATUS[index];
	local item_frac = TitanRepair_GetStatusPercent(item_status.val, item_status.max);

	-- skip if empty slot
	if (item_status.max == 0) then
		if (short) then

			if (not Tit_R_WholeScanInProgress) then
				valueText =  TitanRepair_AutoHighlight(Tit_R_LastKnownItemFrac, valueText .. " (" .. REPAIR_LOCALE["WholeScanInProgress"] .. ")");
			else
				valueText =  TitanRepair_AutoHighlight(Tit_R_LastKnownItemFrac, valueText);
			end

			return valueText;
		else
			return nil;
		end
	end

	-- percent or value
	if (TitanGetVar(TITAN_REPAIR_ID,"ShowPercentage") or short) then
		valueText = string.format("%d%%", item_frac * 100);
	else
		valueText = string.format("%d / %d", item_status.val, item_status.max);     
	end

    
	-- color
	valueText = TitanRepair_AutoHighlight(item_frac, valueText);
    
	-- name
	local SlotID, itemColor, itemRarity;
	local itemName = "";
	local itemLabel = "";

	if (not short or TitanGetVar(TITAN_REPAIR_ID, "ShowItemName")) then
    
		if item_status.slot ~=nil then
     
			SlotID = GetInventorySlotInfo(item_status.slot.."Slot");    
			local itemLink = GetInventoryItemLink("player", SlotID);
    
			if itemLink~=nil then
				itemName, _, itemRarity, _, _, _, _, _,_ , _ = GetItemInfo(itemLink);
				--itemColor, _ = string.find(itemLink, "^|c(%x+)|H(.+)|h%[.+%]");
				_, _, _, itemColor = GetItemQualityColor(itemRarity);
			end
			if itemName==nil or itemName == "" then
				valueText = valueText .. " " .. LIGHTYELLOW_FONT_COLOR_CODE..item_status.name;
				itemLabel = LIGHTYELLOW_FONT_COLOR_CODE..item_status.name;
			else
				valueText = valueText .. " " .. itemColor..itemName;
				itemLabel = itemColor..itemName;
			end
		else
			valueText = valueText .. " " .. LIGHTYELLOW_FONT_COLOR_CODE..item_status.name;
			itemLabel = LIGHTYELLOW_FONT_COLOR_CODE..item_status.name;
		end
	end

	-- add repair cost
	-- local item_cost = TitanRepair_GetCostStr(item_status.cost);
	local item_cost = TitanPanelRepair_GetTextGSC(item_status.cost);
	if TitanGetVar(TITAN_REPAIR_ID, "DiscountFriendly") and (not Tit_R_MerchantisOpen) and (not Tit_R_WholeScanInProgress) then
		item_cost = TitanPanelRepair_GetTextGSC(item_status.cost * 0.95);
	elseif TitanGetVar(TITAN_REPAIR_ID, "DiscountHonored") and (not Tit_R_MerchantisOpen) and (not Tit_R_WholeScanInProgress) then
	  item_cost = TitanPanelRepair_GetTextGSC(item_status.cost * 0.90);
	elseif TitanGetVar(TITAN_REPAIR_ID, "DiscountRevered") and (not Tit_R_MerchantisOpen) and (not Tit_R_WholeScanInProgress) then
	  item_cost = TitanPanelRepair_GetTextGSC(item_status.cost * 0.85);
	elseif TitanGetVar(TITAN_REPAIR_ID, "DiscountExalted") and (not Tit_R_MerchantisOpen) and (not Tit_R_WholeScanInProgress) then
	  item_cost = TitanPanelRepair_GetTextGSC(item_status.cost * 0.80);
	end
    
	if (not short and item_cost) then
		if TitanGetVar(TITAN_REPAIR_ID, "DiscountFriendly") and (not Tit_R_MerchantisOpen) and (not Tit_R_WholeScanInProgress) then
			valueText = valueText .. "\t" .. item_cost..GREEN_FONT_COLOR_CODE.." ("..FACTION_STANDING_LABEL5..")";
		elseif TitanGetVar(TITAN_REPAIR_ID, "DiscountHonored") and (not Tit_R_MerchantisOpen) and (not Tit_R_WholeScanInProgress) then
		  valueText = valueText .. "\t" .. item_cost..GREEN_FONT_COLOR_CODE.." ("..FACTION_STANDING_LABEL6..")";
		elseif TitanGetVar(TITAN_REPAIR_ID, "DiscountRevered") and (not Tit_R_MerchantisOpen) and (not Tit_R_WholeScanInProgress) then
		  valueText = valueText .. "\t" .. item_cost..GREEN_FONT_COLOR_CODE.." ("..FACTION_STANDING_LABEL7..")";
		elseif TitanGetVar(TITAN_REPAIR_ID, "DiscountExalted") and (not Tit_R_MerchantisOpen) and (not Tit_R_WholeScanInProgress) then
		  valueText = valueText .. "\t" .. item_cost..GREEN_FONT_COLOR_CODE.." ("..FACTION_STANDING_LABEL8..")";
		else
			valueText = valueText .. "\t" .. item_cost;
		end
	end

	if (short) then
		local pos;
		pos = string.find(valueText, itemLabel, 1, true);
		if (pos) and itemLabel~= "" then
			valueText = string.sub(valueText,1,pos-1);
		end
		--valueText = string.gsub(valueText, itemLabel, "" );
		Tit_R_LastKnownText = valueText;     
		Tit_R_LastKnownItemFrac = item_frac;
	end
	return valueText, itemLabel;

end

-- **************************************************************************
-- NAME : TitanRepair_AutoHighlight (item_frac, valueText)
-- DESC : <research>
-- VARS : item_frac = <research>, valueText = <research>
-- **************************************************************************
function TitanRepair_AutoHighlight (item_frac, valueText)
	-- I've changed this so when the ratio is 1, the text is green (green means OK for FPS, Latency, etc...)
	-- beneath 0.91 (so it can be true for 0.90) the text is white
	-- and red if the ratio reach 0.20
	-- I didn't check for <= 0.90 or <= 0.20 because fractional eguality test is not acurate...
	if (TitanGetVar(TITAN_REPAIR_ID, "ShowColoredText")) then
		if (item_frac == 0.0) then
			valueText = TitanUtils_GetRedText(valueText);
		elseif (item_frac < 0.21) then
			valueText = TitanUtils_GetNormalText(valueText);
		elseif (item_frac < 0.91) then 
			valueText = TitanUtils_GetHighlightText(valueText);
		else
			valueText = TitanUtils_GetGreenText(valueText);
		end
	else
		valueText = TitanUtils_GetHighlightText(valueText);
	end

	return valueText;
end

function TitanRepair_GetCostStr(cost)
	if (cost > 0) then
		return TitanUtils_GetHighlightText(string.format("%.2fg" , cost / 10000));
	end

	return nil;
end

-- **************************************************************************
-- NAME : TitanPanelRepairButton_GetButtonText(id)
-- DESC : <research>
-- VARS : id = <research>
-- **************************************************************************
function TitanPanelRepairButton_GetButtonText(id)
	local text, itemLabel = TitanRepair_GetStatusStr(REPAIR_INDEX, 1);
	--local _, itemLabel = TitanRepair_GetStatusStr(REPAIR_INDEX, 1);
	local lastItem = "";
     if TitanGetVar(TITAN_REPAIR_ID, "ShowItemName") and itemLabel ~= nil then 
		--safeguard check to ensure that most damaged won't return nil
		lastItem = itemLabel;
     end
	-- supports turning off labels
	if (not Tit_R_WholeScanInProgress) then
    
		local cost = 0;
		local sum = 0;
		local costStr = 0;
		local item_status = {};
		local item_frac = 0;
		local frac_counter = 0;
		local total_frac = 0;
		local inv_frac = 1 ;
		local duraitems = 0;
		local discountlabel = "";
		local canRepair = false;
    
		-- traverse through the durability table and get the damage value, item_frac = 1 (undamaged), item_frac < 1 (damaged)
		for i = 1, table.getn(REPAIR_ITEM_STATUS) do
			item_status = REPAIR_ITEM_STATUS[i];
			item_frac = TitanRepair_GetStatusPercent(item_status.val, item_status.max);
    
			-- set the inventory damage to a seperate variable 
			if item_status.name == INVENTORY_TOOLTIP then
				inv_frac = item_frac;
				item_frac = 0;
			end
    
			if item_status.max ~=0 and item_status.name ~= INVENTORY_TOOLTIP then
				frac_counter = frac_counter + item_frac;
				duraitems = duraitems + 1;
			end
    
			cost = REPAIR_ITEM_STATUS[i].cost;
			sum = sum + cost;
		end
       
     -- check to see if a merchant that can repair is open
  	if Tit_R_MerchantisOpen then
  	   canRepair = CanMerchantRepair();
		end 
       
		if TitanGetVar(TITAN_REPAIR_ID, "DiscountFriendly") and (not Tit_R_MerchantisOpen or (Tit_R_MerchantisOpen and not canRepair)) then
			sum = sum * 0.95;
			discountlabel = FACTION_STANDING_LABEL5;
		elseif TitanGetVar(TITAN_REPAIR_ID, "DiscountHonored") and (not Tit_R_MerchantisOpen or (Tit_R_MerchantisOpen and not canRepair)) then
		  sum = sum * 0.90;
		  discountlabel = FACTION_STANDING_LABEL6;
		elseif TitanGetVar(TITAN_REPAIR_ID, "DiscountRevered") and (not Tit_R_MerchantisOpen or (Tit_R_MerchantisOpen and not canRepair)) then
		  sum = sum * 0.85;
		  discountlabel = FACTION_STANDING_LABEL7;
		elseif TitanGetVar(TITAN_REPAIR_ID, "DiscountExalted") and (not Tit_R_MerchantisOpen or (Tit_R_MerchantisOpen and not canRepair)) then
		  sum = sum * 0.80;
		  discountlabel = FACTION_STANDING_LABEL8;
		end
       
       
		-- failsafe if you have no item with a valid durability value
		if duraitems == 0 then
			duraitems = 1;
			frac_counter = 1;
		end
       
		--total_frac = frac_counter / 11 ;
		total_frac = frac_counter / duraitems ;
       
		if (TitanGetVar(TITAN_REPAIR_ID,"ShowInventory") == 1) then
			total_frac = (total_frac + inv_frac) / 2;
		end
       
		text = string.format("%d%%", total_frac * 100);
		text = TitanRepair_AutoHighlight (total_frac, text);
       
		if (sum > 0) then
			costStr = TitanPanelRepair_GetTextGSC(sum);
			return REPAIR_LOCALE["button"], text .. " (".. costStr ..") "..GREEN_FONT_COLOR_CODE..discountlabel.." "..lastItem;
		else
			return REPAIR_LOCALE["button"], text;
		end
	else
		return REPAIR_LOCALE["button"], text .. " (" .. REPAIR_LOCALE["WholeScanInProgress"] .. ")";
	end
end


-- **************************************************************************
-- NAME : TitanPanelRepairButton_GetTooltipText()
-- DESC : <research>
-- **************************************************************************
function TitanPanelRepairButton_GetTooltipText()

	local out = "";
	local cost = 0;
	local sum = 0;

	for i = 1, table.getn(REPAIR_ITEM_STATUS) do
		local str = TitanRepair_GetStatusStr(i);

		cost = REPAIR_ITEM_STATUS[i].cost;
		sum = sum + cost;

		if ((str) and (TitanGetVar(TITAN_REPAIR_ID,"ShowUndamaged") or (cost > 0))) then
			out = out .. str .. "\n";
		end
	end

	if (sum > 0) then
		--local costStr = TitanRepair_GetCostStr(sum);
		local costStr = TitanPanelRepair_GetTextGSC(sum);
		local costfrStr = TitanPanelRepair_GetTextGSC(sum * 0.95);
		local costhonStr = TitanPanelRepair_GetTextGSC(sum * 0.90);
		local costrevStr = TitanPanelRepair_GetTextGSC(sum * 0.85);
		local costexStr = TitanPanelRepair_GetTextGSC(sum * 0.80);
		if (costStr) then
			if Tit_R_MerchantisOpen then
				out = out .. "\n" .. REPAIR_COST .. " " .. costStr;
				  local canRepair = CanMerchantRepair();
	   				if not canRepair then
	   				  out = out .. "\n".. GREEN_FONT_COLOR_CODE..REPAIR_LOCALE["badmerchant"];
	   				end
			else
				out = out .. "\n" .. REPAIR_LOCALE["normal"] .. "\t" .. costStr;
			end
			if (not Tit_R_MerchantisOpen) and (not Tit_R_WholeScanInProgress) then
			  out = out .. "\n" .. REPAIR_LOCALE["friendly"] .. "\t" .. costfrStr;
				out = out .. "\n" .. REPAIR_LOCALE["honored"] .. "\t" .. costhonStr;
				out = out .. "\n" .. REPAIR_LOCALE["revered"] .. "\t" .. costrevStr;
				out = out .. "\n" .. REPAIR_LOCALE["exalted"] .. "\t" .. costexStr;
			end
		end
	else
		out = out .. "\n" .. REPAIR_LOCALE["nothing"];
	end

	return out;

end

-- **************************************************************************
-- NAME : TitanPanelRepair_GetGSC(money)
-- DESC : <research>
-- VARS : money = <research>
-- **************************************************************************
function TitanPanelRepair_GetGSC(money)
	local neg = false;
     if (money == nil) then money = 0; end
     if (money < 0) then
          neg = true;
		money = money * -1;
     end
     local g = math.floor(money / 10000);
     local s = math.floor((money - (g * 10000)) / 100);
     local c = math.floor(money - (g * 10000) - (s * 100));
     return g, s, c, neg;
end

function TitanPanelRepair_GetTextGSC(money)
	local GSC_GOLD = "ffd100";
	local GSC_SILVER = "e6e6e6";
	local GSC_COPPER = "c8602c";
	local GSC_START = "|cff%s%d|r";
	local GSC_PART = ".|cff%s%02d|r";
	local GSC_NONE = "|cffa0a0a0" .. NONE .. "|r";
     local g, s, c, neg = TitanPanelRepair_GetGSC(money);
     local gsc = "";
     if (g > 0) then
		gsc = format(GSC_START, GSC_GOLD, g);
          gsc = gsc .. format(GSC_PART, GSC_SILVER, s);
          gsc = gsc .. format(GSC_PART, GSC_COPPER, c);
     elseif (s > 0) then
          gsc = format(GSC_START, GSC_SILVER, s);
          gsc = gsc .. format(GSC_PART, GSC_COPPER, c);
     elseif (c > 0) then
          gsc = gsc .. format(GSC_START, GSC_COPPER, c);
     else
          gsc = GSC_NONE;
     end

     if (neg) then gsc = "(" .. gsc .. ")"; end

     return gsc;
end


-- **************************************************************************
-- NAME : TitanPanelRightClickMenu_PrepareRepairMenu()
-- DESC : <research>
-- **************************************************************************
function TitanPanelRightClickMenu_PrepareRepairMenu()
	TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_REPAIR_ID].menuText);

	local info = {};
	info.text = REPAIR_LOCALE["percentage"];
	info.func = TitanRepair_ShowPercentage;
	info.checked = TitanGetVar(TITAN_REPAIR_ID,"ShowPercentage");
	UIDropDownMenu_AddButton(info);

	local info = {};
	info.text = REPAIR_LOCALE["itemname"];
	info.func = TitanRepair_ShowItemName;
	info.checked = TitanGetVar(TITAN_REPAIR_ID,"ShowItemName");
	UIDropDownMenu_AddButton(info);

	local info = {};
	info.text = REPAIR_LOCALE["undamaged"];
	info.func = TitanRepair_ShowUndamaged;
	info.checked = TitanGetVar(TITAN_REPAIR_ID,"ShowUndamaged");
	UIDropDownMenu_AddButton(info);
    
	local info = {};
	info.text = REPAIR_LOCALE["showinventory"];
	info.func = TitanRepair_ShowInventory;
	info.checked = TitanGetVar(TITAN_REPAIR_ID,"ShowInventory");
	UIDropDownMenu_AddButton(info);
	
	TitanPanelRightClickMenu_AddSpacer();
	TitanPanelRightClickMenu_AddTitle(REPAIR_LOCALE["AutoReplabel"]);
   
  local info = {};
  info.text = REPAIR_LOCALE["popup"];
	info.func = TitanRepair_ShowPop;
	info.checked = TitanGetVar(TITAN_REPAIR_ID,"ShowPopup");
	UIDropDownMenu_AddButton(info);	
	
	local info = {};
  info.text = REPAIR_LOCALE["AutoRepitemlabel"];
	info.func = TitanRepair_AutoRep;
	info.checked = TitanGetVar(TITAN_REPAIR_ID,"AutoRepair");
	UIDropDownMenu_AddButton(info);	
	
	TitanPanelRightClickMenu_AddSpacer();
	
	TitanPanelRightClickMenu_AddTitle(REPAIR_LOCALE["discount"]);
  
	info = {};
	info.text = REPAIR_LOCALE["buttonNormal"];
	info.checked = not TitanGetVar(TITAN_REPAIR_ID,"DiscountFriendly") and not TitanGetVar(TITAN_REPAIR_ID,"DiscountHonored") and not TitanGetVar(TITAN_REPAIR_ID,"DiscountRevered") and not TitanGetVar(TITAN_REPAIR_ID,"DiscountExalted");
	info.disabled = Tit_R_MerchantisOpen;
	info.func = function()
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountFriendly", nil)
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountHonored", nil)
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountRevered", nil)
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountExalted", nil)
	  TitanPanelButton_UpdateButton(TITAN_REPAIR_ID)
		end
	UIDropDownMenu_AddButton(info);
	
	
	info = {};
	info.text = REPAIR_LOCALE["buttonFriendly"];
	info.checked = TitanGetVar(TITAN_REPAIR_ID,"DiscountFriendly");
	info.disabled = Tit_R_MerchantisOpen;
	info.func = function()
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountFriendly", 1)
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountHonored", nil)
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountRevered", nil)
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountExalted", nil)
	  TitanPanelButton_UpdateButton(TITAN_REPAIR_ID)
		end
	UIDropDownMenu_AddButton(info);
	
	info = {};
	info.text = REPAIR_LOCALE["buttonHonored"];
	info.checked = TitanGetVar(TITAN_REPAIR_ID,"DiscountHonored");
	info.disabled = Tit_R_MerchantisOpen;
	info.func = function()
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountFriendly", nil)
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountHonored", 1)
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountRevered", nil)
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountExalted", nil)
	  TitanPanelButton_UpdateButton(TITAN_REPAIR_ID)
		end
	UIDropDownMenu_AddButton(info);
	
	
	info = {};
	info.text = REPAIR_LOCALE["buttonRevered"];
	info.checked = TitanGetVar(TITAN_REPAIR_ID,"DiscountRevered");
	info.disabled = Tit_R_MerchantisOpen;
	info.func = function()
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountFriendly", nil)
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountHonored", nil)
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountRevered", 1)
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountExalted", nil)
	  TitanPanelButton_UpdateButton(TITAN_REPAIR_ID)
		end
	UIDropDownMenu_AddButton(info);
	
	info = {};
	info.text = REPAIR_LOCALE["buttonExalted"];
	info.checked = TitanGetVar(TITAN_REPAIR_ID,"DiscountExalted");
	info.disabled = Tit_R_MerchantisOpen;
	info.func = function()
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountFriendly", nil)
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountHonored", nil)
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountRevered", nil)
	  TitanSetVar(TITAN_REPAIR_ID,"DiscountExalted", 1)
	  TitanPanelButton_UpdateButton(TITAN_REPAIR_ID)
		end
	UIDropDownMenu_AddButton(info);
	

	TitanPanelRightClickMenu_AddSpacer();     
	TitanPanelRightClickMenu_AddToggleIcon(TITAN_REPAIR_ID);
	TitanPanelRightClickMenu_AddToggleLabelText(TITAN_REPAIR_ID);
	TitanPanelRightClickMenu_AddToggleColoredText(TITAN_REPAIR_ID);

	TitanPanelRightClickMenu_AddSpacer();     
	TitanPanelRightClickMenu_AddCommand(TITAN_PANEL_MENU_HIDE, TITAN_REPAIR_ID, TITAN_PANEL_MENU_FUNC_HIDE);
end


-- **************************************************************************
-- NAME : TitanRepair_ShowPercentage()
-- DESC : <research>
-- **************************************************************************
function TitanRepair_ShowPercentage()
	TitanToggleVar(TITAN_REPAIR_ID, "ShowPercentage");
	TitanPanelButton_UpdateButton(TITAN_REPAIR_ID);
end


-- **************************************************************************
-- NAME : TitanRepair_ShowItemName()
-- DESC : <research>
-- **************************************************************************
function TitanRepair_ShowItemName()
	TitanToggleVar(TITAN_REPAIR_ID, "ShowItemName");
	TitanPanelButton_UpdateButton(TITAN_REPAIR_ID);
end


-- **************************************************************************
-- NAME : TitanRepair_ShowUndamaged()
-- DESC : <research>
-- **************************************************************************
function TitanRepair_ShowUndamaged()
	TitanToggleVar(TITAN_REPAIR_ID, "ShowUndamaged");
end

-- **************************************************************************
-- NAME : TitanRepair_ShowPop()
-- DESC : <research>
-- **************************************************************************
function TitanRepair_ShowPop()
	TitanToggleVar(TITAN_REPAIR_ID, "ShowPopup");
	if TitanGetVar(TITAN_REPAIR_ID,"ShowPopup") and TitanGetVar(TITAN_REPAIR_ID,"AutoRepair") then
	  TitanSetVar(TITAN_REPAIR_ID,"AutoRepair",nil);
	end
end

function TitanRepair_AutoRep()
	TitanToggleVar(TITAN_REPAIR_ID, "AutoRepair");
	if TitanGetVar(TITAN_REPAIR_ID,"AutoRepair") and TitanGetVar(TITAN_REPAIR_ID,"ShowPopup") then
	  TitanSetVar(TITAN_REPAIR_ID,"ShowPopup",nil);
	end
end

-- **************************************************************************
-- NAME : TitanRepair_ShowInventory()
-- DESC : <research>
-- **************************************************************************
function TitanRepair_ShowInventory()

	if (Tit_R_WholeScanInProgress) then
		return;
	end

	tit_debug_bis("TitanRepair_ShowInventory has been called !!");
	TitanToggleVar(TITAN_REPAIR_ID, "ShowInventory");

	if TitanGetVar(TITAN_REPAIR_ID,"ShowInventory") ~= 1 then
		REPAIR_ITEM_STATUS[12].cost = 0;
		REPAIR_ITEM_STATUS[12].val = 0;
		REPAIR_ITEM_STATUS[12].max = 0;
	end
	TitanPanelRepairButton_ScanAllItems();
	Tit_R_CheckForUpdate = true;
end

-- **************************************************************************
-- NAME : TitanRepair_RepairItems()
-- DESC : <research>
-- **************************************************************************
function TitanRepair_RepairItems()
	RepairAllItems();

	ShowRepairCursor();
	local bag, slot
	for bag = 0, 4 do     
		for slot = 1, GetContainerNumSlots(bag) do
			local _, repairCost = TitanRepairTooltip:SetBagItem(bag, slot);
			if (repairCost and (repairCost > 0)) then
				UseContainerItem(bag,slot);
				Tit_R_PleaseCheckBag[bag] = 1; -- this bag will be updated
				Tit_R_CheckForUpdate = true;
			end
		end
	end
	HideRepairCursor();
    
	-- disable repair all icon in merchant    
	SetDesaturation(MerchantRepairAllIcon, 1);
	MerchantRepairAllButton:Disable();
	-- disable guild bank repair all icon in merchant
	SetDesaturation(MerchantGuildBankRepairButtonIcon, 1);
	MerchantGuildBankRepairButton:Disable();    
       
end

-- **************************************************************************
-- NAME : TitanRepair_GetRepairInvCost()
-- DESC : <research>
-- **************************************************************************
function TitanRepair_GetRepairInvCost()
	local result = 0;
	local bag;
	TitanRepairTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");

	for bag = 0, 4 do     
		for slot = 1, GetContainerNumSlots(bag) do
			local _, repairCost = TitanRepairTooltip:SetBagItem(bag, slot);
			if (repairCost and (repairCost > 0)) then
				result = result + repairCost;
			end
		end
	end
	TitanRepairTooltip:Hide();

	return result;
end



