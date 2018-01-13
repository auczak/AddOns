local activeModule = "Engine test";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local TEST_TALENTS_ACCESS_PRIORITY = 2;
local TEST_GEAR_ACCESS_PRIORITY = 2;

-- --------------------------------------------------------------------
-- **                          Test functions                        **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Engine_Test_CheckTalents(unit)                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- * unit >> the unit to check talents upon.                          *
-- ********************************************************************
-- * Determinates the talents the unit may benefit from.              *
-- ********************************************************************
function DTM_Engine_Test_CheckTalents(unit)
    if not UnitExists(unit) then return; end

    local _, class = UnitClass(unit);

    DTM_Talents_DoListing(class, nil, nil, nil, nil, nil);
    local num = DTM_Talents_GetListSize();
    if not ( UnitIsPlayer(unit) ) then num = 0; end

    if num <= 0 then
        DTM_ChatMessage(format(DTM_Localise("TestNoTalent"), UnitName(unit)), 1);
  else
        DTM_ChatMessage(format(DTM_Localise("TestTalentDB"), num, UnitName(unit)), 1);
        for i=1, num do
            local internalName, internalClass, effect = DTM_Talents_GetListData(i);
            DTM_ChatMessage(format(DTM_Localise("TestTalentDBRow"), i, internalName), 1); 
        end

        local resultCode = DTM_Access_Ask(unit, "TALENT", DTM_Engine_Test_TalentsResult, TEST_TALENTS_ACCESS_PRIORITY);

        if not ( resultCode ) then
            DTM_ChatMessage(format(DTM_Localise("TestCannotQueryTalents"), UnitName(unit)), 1);

      elseif ( resultCode == 1 ) then
            DTM_ChatMessage(format(DTM_Localise("TestQueryTalentsFired"), UnitName(unit)), 1);

      elseif ( resultCode == 2 ) then
             -- Got instantly. Do not print additionnal message.
        end
    end
end

-- ********************************************************************
-- * DTM_Engine_Test_TalentsResult(state, flag, unitName)             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * state >> whether the query succeeded or not.                     *
-- * flag >> what to pass as 2nd or 3rd argument to Blizz functions.  *
-- * unitName >> the unit who was queried.                            *
-- ********************************************************************
-- * Fired when talents query finished, regardless of success or fail.*
-- ********************************************************************
function DTM_Engine_Test_TalentsResult(state, flag, unitName)
    if not ( state ) then
        -- Something got on our way meantime.
        DTM_ChatMessage(format(DTM_Localise("TestQueryTalentsError"), unitName), 1);
  else
        for i=1, GetNumTalentTabs(flag) do
            for ii=1, GetNumTalents(i, flag) do
                name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(i, ii, flag);

                internalName = DTM_GetInternal("talents", name, 1);
                if internalName then
                    DTM_ChatMessage(format(DTM_Localise("TestTalentRank"), name, internalName, rank, maxRank), 1);   
                end
            end
        end
    end
end

-- ********************************************************************
-- * DTM_Engine_Test_CheckNPCAbilities(unit)                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * unit >> the unit to check abilities upon.                        *
-- ********************************************************************
-- * Determinates the threat modifying abilities of the given NPC unit*
-- ********************************************************************
function DTM_Engine_Test_CheckNPCAbilities(unit)
    if not UnitExists(unit) then return; end

    local name = UnitName(unit);

    if UnitIsPlayer(unit) then
        DTM_ChatMessage(format(DTM_Localise("TestNoPCAbility"), name), 1);
        return nil;
    end

    local data = DTM_GetNPCAbilityData(name);
    local num = 0;
    if ( data ) then num = data.number; end

    if num <= 0 then
        DTM_ChatMessage(format(DTM_Localise("TestNoNPCAbility"), name), 1);
  else
        DTM_ChatMessage(format(DTM_Localise("TestNPCAbility"), num, name), 1);
        for i=1, num do
            local internalName = data[i].name;
            DTM_ChatMessage(format(DTM_Localise("TestNPCAbilityRow"), i, internalName), 1); 
        end
    end
end

-- ********************************************************************
-- * DTM_Engine_Test_PrintAssociationErrors()                         *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Prints all associations between locale and internals that failed.*
-- ********************************************************************
function DTM_Engine_Test_PrintAssociationErrors()
    local num = DTM_GetNumInternalTranslationErrors();
    if num <= 0 then
        DTM_ChatMessage(DTM_Localise("TestNoAssociationErrors"), 1);
  else
        DTM_ChatMessage(format(DTM_Localise("TestAssociationErrors"), num), 1);
        for i=1, num do
            local errorData = DTM_GetInternalTranslationError(i);
            DTM_ChatMessage(format(DTM_Localise("TestAssociationErrorsRow"), i, errorData), 1); 
        end
    end
end

-- ********************************************************************
-- * DTM_Engine_Test_CheckGear(unit)                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * unit >> the unit to check gear of.                               *
-- ********************************************************************
-- * Displays threat info about the gear one is currently wearing.    *
-- ********************************************************************
function DTM_Engine_Test_CheckGear(unit)
    if not UnitExists(unit) then return; end
    if not ( UnitIsPlayer(unit) ) then return; end

    DTM_ItemsBuffer_Grab(unit, DTM_Engine_Test_GearResult, TEST_GEAR_ACCESS_PRIORITY);
end

-- ********************************************************************
-- * DTM_Engine_Test_GearResult(state, unit)                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> state: whether the gear could be queried successfully.        *
-- * >> unit: the unit who has had its gear queried.                  *
-- ********************************************************************
-- * Displays threat info about the gear one is currently wearing.    *
-- ********************************************************************
function DTM_Engine_Test_GearResult(state, unit)
    if not ( state ) then
        return;
    end

    local name = UnitName(unit);
    local itemMultiplier = 1.000;
    local itemId, itemInternal, itemEffect, itemString, equipedItemString;

    DTM_Items_DoListing(nil, "GLOBAL_THREAT", nil);
    for i=1, DTM_Items_GetListSize() do
        itemId, itemInternal, itemEffect = DTM_Items_GetListData(i);
        equipedItemString = DTM_ItemsBuffer_GetItemEquipedAttributes(name, itemId);

        if ( equipedItemString ) and ( itemEffect ) then
            if ( itemEffect.type == "MULTIPLY_THREAT" ) then
                itemMultiplier = itemMultiplier * itemEffect.value;
        elseif ( itemEffect.type == "ADDITIVE_THREAT" ) then
                itemMultiplier = itemMultiplier + itemEffect.value;
            end
        end
    end

    -- Read into unit's equipment table directly and apply enchants/gems that modify threat on itemMultiplier.
    local equipmentData = DTM_ItemsBuffer_Get(name);
    if ( equipmentData ) then
        for itemId, itemString in pairs(equipmentData) do
        if itemId ~= "class" then
            DTM_ChatMessage(itemString.." |cffffff00("..GetItemInfo(itemString)..")|r", 1);
            itemMultiplier = itemMultiplier * DTM_Enchants_GetItemEnchantCoefficient(itemString);
        end
        end
    end

    DTM_ChatMessage(format(DTM_Localise("TestGearThreatMultiplier"), itemMultiplier), 1); 
end

-- ********************************************************************
-- * DTM_Engine_Test_PrintLists()                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Prints internal threat lists of DTM. (not using API)             *
-- ********************************************************************
function DTM_Engine_Test_PrintLists()
    local i = 0;
    local ii;
    DTM_ChatMessage(format(DTM_Localise("TestListNumber"), DTM_Entity.number), 1);

    DTM_EntityData_PickUpAndDo( function(name, guid, threatList, presenceList)
                                    i = i + 1;
                                    DTM_ChatMessage(format(DTM_Localise("TestListRow"), i, name or '<?>', guid), 1);
                                    DTM_ChatMessage(format(DTM_Localise("TestListThreatListNumber"), name, threatList.number), 1);
                                    for ii=1, threatList.number do
                                        DTM_ChatMessage(format(DTM_Localise("TestListThreatListRow"), ii, threatList[ii].name or '<?>', threatList[ii].guid, threatList[ii].threat), 1);
                                    end
                                end );
end

-- ********************************************************************
-- * DTM_Engine_Test_CheckSets(unit)                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * unit >> the unit to check sets of.                               *
-- ********************************************************************
-- * Displays threat-modifying sets one is currently wearing.         *
-- ********************************************************************
function DTM_Engine_Test_CheckSets(unit)
    if not UnitExists(unit) then return; end
    if not ( UnitIsPlayer(unit) ) then return; end

    -- We need to update the items buffer; it'll then automatically update the sets buffer.
    DTM_ItemsBuffer_Grab(unit, DTM_Engine_Test_SetsResult, TEST_GEAR_ACCESS_PRIORITY);
end


-- ********************************************************************
-- * DTM_Engine_Test_SetsResult(state, unit)                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> state: whether the sets could be queried successfully.        *
-- * >> unit: the unit who has had its sets queried.                  *
-- ********************************************************************
-- * Displays threat-modifying sets one is currently wearing.         *
-- ********************************************************************
function DTM_Engine_Test_SetsResult(state, unit)
    if not ( state ) then
        return;
    end

    local name = UnitName(unit);
    local setsData = DTM_SetsBuffer_Get(name);
    local setInternal, setCount, numPieces;

    DTM_ChatMessage(format(DTM_Localise("TestSets"), name), 1);

    if ( setsData ) then
        for setInternal, setCount in pairs(setsData) do
        if setInternal ~= "class" then
            _, numPieces, _ = DTM_Sets_GetData(setInternal);
            DTM_ChatMessage(format(DTM_Localise("TestSetsRow"), setInternal, setCount, numPieces), 1);
        end
        end
    end
end

-- ********************************************************************
-- * DTM_Engine_Test_CheckVersion()                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Sends a request to the version service to get DTM version of the *
-- * party/raid members.                                              *
-- ********************************************************************
function DTM_Engine_Test_CheckVersion()
    local serviceStatus = DTM_Version_CanAsk();

    if ( serviceStatus == "OK" ) then
        if ( DTM_Version_Ask( DTM_Engine_Test_PrintVersion ) ) then
            DTM_ChatMessage(DTM_Localise("TestVersionSent"), 1);
      else
            DTM_ChatMessage(DTM_Localise("TestVersionErrorUnknown"), 1);
        end
  else
        if ( serviceStatus == "FLOOD" ) then
            DTM_ChatMessage(DTM_Localise("TestVersionErrorFlood"), 1);
    elseif ( serviceStatus == "NOT_GROUPED" ) then
            DTM_ChatMessage(DTM_Localise("TestVersionErrorNotGrouped"), 1);
      else
            DTM_ChatMessage(DTM_Localise("TestVersionErrorUnknown"), 1);
        end
    end
end

-- ********************************************************************
-- * DTM_Engine_Test_PrintVersion()                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Fired when the version service has finished to compute versions. *
-- ********************************************************************
function DTM_Engine_Test_PrintVersion()
    DTM_ChatMessage(DTM_Localise("TestVersionResults"), 1);

    local i;
    local name, version, system, major, minor, revision;

    for i=1, DTM_Version_GetNumResults() do
        name, version, system, major, minor, revision = DTM_Version_GetResultInfo(i);
        DTM_ChatMessage(format(DTM_Localise("TestVersionResultsRow"), i, name, system, version), 1);
    end
end

-- ********************************************************************
-- * DTM_Engine_Test_CheckTalentsBuffer()                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Prints the whole content of the talents buffer.                  *
-- ********************************************************************
function DTM_Engine_Test_CheckTalentsBuffer()
    DTM_ChatMessage(format(DTM_Localise("TestTalentsBufferNumber"), DTM_Talents.number), 1);

    local i, k, v;
    local name, data, numTalents;
    i = 0;
    for name, data in pairs(DTM_Talents) do
    if ( name ~= "number" ) then -- Fortunately it's impossible to name a character "number". :)
        i = i + 1;
        numTalents = 0;

        for k, v in pairs(data) do
        if ( k ~= "class" and k ~= "lastUpdate" and k ~= "count" ) then
            numTalents = numTalents + 1;
        end
        end

        DTM_ChatMessage(format(DTM_Localise("TestTalentsBufferRow"), i, name, numTalents), 1);
    end
    end
end

-- ********************************************************************
-- * DTM_Engine_Test_CheckItemsBuffer()                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Prints the whole content of the items buffer.                    *
-- ********************************************************************
function DTM_Engine_Test_CheckItemsBuffer()
    DTM_ChatMessage(format(DTM_Localise("TestItemsBufferNumber"), DTM_Items.number), 1);

    local i, k, v;
    local name, data, numItems;
    i = 0;
    for name, data in pairs(DTM_Items) do
    if ( name ~= "number" ) then
        i = i + 1;
        numItems = 0;

        for k, v in pairs(data) do
        if ( k ~= "class" and k ~= "lastUpdate" ) then
            numItems = numItems + 1;
        end
        end

        DTM_ChatMessage(format(DTM_Localise("TestItemsBufferRow"), i, name, numItems), 1);
    end
    end
end