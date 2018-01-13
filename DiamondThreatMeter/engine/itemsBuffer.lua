local activeModule = "Engine items buffer";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local MAX_SCAN_SLOT_ID = 19;

local GEAR_ACCESS_PRIORITY = 0;

local itemsBuffer_Callback = nil;

-- --------------------------------------------------------------------
-- **                               API                              **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_ItemsBuffer_Get(name)                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the player whose items are queried.         *
-- ********************************************************************
-- * Grab the equip data of a player by its name.                     *
-- * If no equip data is found, nil is returned.                      *
-- * You can read directly in the buffer and so use this function as  *
-- * an API, but it is "more beautiful" to use the other APIs.        *
-- ********************************************************************
function DTM_ItemsBuffer_Get(name)
    if ( name == "number" ) then return nil; end -- Illegal.
    return DTM_Items[name];
end

-- ********************************************************************
-- * DTM_ItemsBuffer_GetItemEquipedAttributes(name, itemId)           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the player whose items are queried.         *
-- * >> itemId: the item Id to get attributes from.                   *
-- ********************************************************************
-- * Grab the equip piece attributes of an item equiped by a player   *
-- * by its name. (an itemString)                                     *
-- ********************************************************************
function DTM_ItemsBuffer_GetItemEquipedAttributes(name, itemId)
    local equipData = DTM_ItemsBuffer_Get(name);
    if ( equipData ) then
        return equipData[itemId];
    end
    return nil;
end

-- ********************************************************************
-- * DTM_ItemsBuffer_Grab(unit, callback, priorityOveride)            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit whose equip data is grabbed.                   *
-- * >> callback: a function you wish to call once items have been    *
-- * grabbed, successfully or not.                                    *
-- * >> priorityOveride: sets a new priority for the gear access.     *                                                
-- ********************************************************************
-- * Grab the equip data of an unit and store it in the buffer.       *
-- * Repeated calls of this function will refresh appropriately the   *
-- * current data stored in the buffer.                               *
-- *                                                                  *
-- * Return 1 if item grab request was issued successfully.           *
-- * Return nil if not.                                               *
-- ********************************************************************
function DTM_ItemsBuffer_Grab(unit, callback, priorityOveride)
    if not UnitExists(unit) then return nil; end
    if not UnitIsPlayer(unit) then return nil; end
    if ( UnitAffectingCombat("player") ) then return nil; end

    local truePriority = priorityOveride or GEAR_ACCESS_PRIORITY;
    local auth = DTM_Access_CanAsk(unit, truePriority);

    if ( auth == "OK" ) then
        itemsBuffer_Callback = callback;
        DTM_Access_Ask(unit, "GEAR", DTM_ItemsBuffer_OnResult, truePriority);
        return 1;
  else
        -- Cannot do the grabbing now. If there is a callback, we tell it we failed.
        if ( callback ) then
            callback(nil, unit);
        end
        return nil;
    end
end

-- --------------------------------------------------------------------
-- **                             Functions                          **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_ItemsBuffer_OnResult(state, flag, unitName)                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> state: whether it succeeded or not.                           *
-- * >> flag: what to pass to GetInventoryItemLink function.          *
-- * >> unitName: the unit whose equip data is received.              *
-- ********************************************************************
-- * Called when equipment data of an unit is now available.          *
-- ********************************************************************
function DTM_ItemsBuffer_OnResult(state, flag, unitName)
    local equipment = DTM_ItemsBuffer_Get(unitName);
    if not ( equipment ) then
        DTM_Items.number = DTM_Items.number + 1;
        DTM_Items[unitName] = {};
        equipment = DTM_Items[unitName];
    end

    if not ( UnitIsUnit(flag, "player") ) then
        DTM_Trace("BUFFER", "[%s] items have been stored in the buffer.", 1, unitName);
    end

    -- Erase old inventory.
    for k, v in pairs(equipment) do
        equipment[k] = nil;
    end

    local _, class = UnitClass(flag);
    equipment.class = class;

    if ( state ) then
        local slotId;
        local itemLink, itemString;

        for slotId=0, MAX_SCAN_SLOT_ID do  -- It's not clean, but oh well. It's much easier x]
            itemLink = GetInventoryItemLink(flag, slotId);

            if ( itemLink ) and ( strlen(itemLink) > 0 ) then
                _, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.+%]");
                if ( itemString ) then
                    local _, itemId = strsplit(":", itemString);
                    equipment[tonumber(itemId)] = itemString;
                end
            end
        end
    end

    -- Update at the same time set data for this unit.
    DTM_SetsBuffer_Grab(unitName, class);

    -- Tell the callback if there is one if we succeeded or failed.
    if ( itemsBuffer_Callback ) then
        itemsBuffer_Callback(state, flag);
    end
end