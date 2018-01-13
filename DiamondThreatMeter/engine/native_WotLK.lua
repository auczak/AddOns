local activeModule = "Engine native Blizzard meter (WotLK)";

-- This file contains functions that can only work on WotLK Beta DTM version.
-- It will not be run on live clients.

if ( not DTM_OnWotLK() ) then
    return;
end

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local DISABLED = 0;

-- Uncomment this to rely only on DTM combat events parsing for threat calculations.
-- Also useful to determinate threat values of abilities by comparing it to WoW native threat meter.
-- DISABLED = 1;

-- In case native threat meter does not use the same scaling as the conventionnal one all threat-guessers have used so far, input it here.
local SCALING = 1.000;

SCALING = 535 / 57485; -- Did 535 damage causing 57485 threat in the Blizzard threat scale which on our scale should be 535 coz' it was with a 1x global multiplier.

-- --------------------------------------------------------------------
-- **                               API                              **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Native_PullDataFromUnit(unit)                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit to get native threat data of.                  *
-- ********************************************************************
-- * Grabs relevant threat data info about an unit through Blizzard   *
-- * native threat functions.                                         *
-- ********************************************************************

function DTM_Native_PullDataFromUnit(unit)
    local relativeName, relativeGUID, relativeUID = select(1, UnitName(unit)), UnitGUID(unit), unit;
    local ownerName, ownerGUID, ownerUID;
    local ownerList = DTM_Native_GetUnitChecklist();
    local i, num;
    local isTanking, state, scaledPercent, rawPercent, threatValue;

    num = select('#', strsplit(",", ownerList));
    for i=1, num do
        ownerUID = select(i, strsplit(",", ownerList));
        if UnitExists(ownerUID) and not UnitIsUnit(relativeUID, ownerUID) then
            ownerName, ownerGUID = select(1, UnitName(ownerUID)), UnitGUID(ownerUID);

            isTanking, state, scaledPercent, rawPercent, threatValue = UnitDetailedThreatSituation(ownerUID, relativeUID);

            if ( isTanking ) then
                -- This one has aggro !
                DTM_Aggro_Set(relativeName, relativeGUID, ownerName, ownerGUID);
            end

            if ( threatValue ) then
                -- Value is available => Unit has this owner on its threat list.
                -- Update it in DTM internal threat list.
                DTM_ThreatList_Modify(relativeName, relativeGUID, ownerName, ownerGUID, "SET", threatValue * SCALING);
          else
                -- Value is not available => Unit has not this owner on its threat list.
                -- Remove it eventually from DTM internal threat list.
                DTM_ThreatList_Modify(relativeName, relativeGUID, ownerName, ownerGUID, "DROP");
            end
        end
    end
end

-- --------------------------------------------------------------------
-- **                            Functions                           **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Native_GetUnitChecklist()                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Get a comma separated list of units IDs that should be checked   *
-- * against when a threat list of an unit is updated.                *
-- * It's very possible the same unit apparears several times on the  *
-- * list, though with a different unit Id.                           *
-- ********************************************************************

function DTM_Native_GetUnitChecklist()
    local list = "player,pet,pettarget,target,targettarget,mouseover,mouseovertarget";

    --[[
    local AddToList = function(unit)
                          if UnitExists(unit) then
                              list = list..","..unit;
                          end
                      end;

    AddToList("target");
    AddToList("targettarget");
    AddToList("mouseover");
    AddToList("mouseovertarget");
    AddToList("pet");
    AddToList("pettarget");
    ]]

    local i;

    if ( GetNumRaidMembers() > 0 ) then
        for i=1, GetNumRaidMembers() do
            list = list..",raid"..i..",raid"..i.."target,raidpet"..i..",raidpet"..i.."target";
        end

elseif ( GetNumPartyMembers() > 0 ) then
        for i=1, GetNumPartyMembers() do
            list = list..",party"..i..",party"..i.."target,partypet"..i..",partypet"..i.."target";
        end
    end

    return list;
end

-- --------------------------------------------------------------------
-- **                             Handlers                           **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Native_OnThreatListUpdate(unit)                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit whose threat list is updated.                  *
-- ********************************************************************
-- * Gets fired when the native threat list of an unit is updated.    *
-- ********************************************************************

function DTM_Native_OnThreatListUpdate(unit)
    if ( DISABLED == 1 ) then return; end
    local workMethod = DTM_GetSavedVariable("engine", "workMethod", "active");
    if not ( workMethod == "NATIVE" or workMethod == "HYBRID" ) then
        return;
    end

    if not ( unit ) then unit = arg1; end

    if not DTM_CanHoldThreatList(unit) then
        return;
    end

    DTM_Native_PullDataFromUnit(unit);
end