local activeModule = "Engine sets buffer";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                               API                              **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SetsBuffer_Get(name)                                         *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the player whose sets are queried.          *
-- ********************************************************************
-- * Grab the set data of a player by its name.                       *
-- * If no set data is found, nil is returned.                        *
-- * You can read directly in the buffer and so use this function as  *
-- * an API, but it is "more beautiful" to use the other APIs.        *
-- ********************************************************************
function DTM_SetsBuffer_Get(name)
    if ( name == "number" ) then return nil; end -- Illegal.
    return DTM_Sets[name];
end

-- ********************************************************************
-- * DTM_SetsBuffer_GetSetEquipedPieceNumber(name, setInternal)       *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the player whose sets are queried.          *
-- * >> setInternal: the internal name of the set to query.           *
-- ********************************************************************
-- * Grab the equip piece attributes of an item equiped by a player   *
-- * by its name. (an itemString)                                     *
-- ********************************************************************
function DTM_SetsBuffer_GetSetEquipedPieceNumber(name, setInternal)
    local setsData = DTM_SetsBuffer_Get(name);
    if ( setsData ) then
        return setsData[setInternal] or 0;
    end
    return 0;
end

-- ********************************************************************
-- * DTM_SetsBuffer_Grab(name, class)                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the guy whose set data is grabbed.                      *
-- * >> class: the class internal name of the guy.                    *
-- ********************************************************************
-- * Grab the set data of an unit and store it in the buffer.         *
-- * Repeated calls of this function will refresh appropriately the   *
-- * current data stored in the buffer.                               *
-- * This function should be called after updating this unit's item   *
-- * buffer, as it needs it to make the update.                       *
-- ********************************************************************
function DTM_SetsBuffer_Grab(name, class)
    if ( name == "number" ) then return nil; end -- Illegal.

    local setsData = DTM_SetsBuffer_Get(name);
    if not ( setsData ) then
        DTM_Sets.number = DTM_Sets.number + 1;
        DTM_Sets[name] = {};
        setsData = DTM_Sets[name];
    end

    setsData.class = class;

    local i, p, equipedPieces;
    local set, _, numPieces, pieces;

    DTM_Sets_DoListing(class);
    for i=1, DTM_Sets_GetListSize() do
        set, _, numPieces, pieces = DTM_Sets_GetListData(i);
        equipedPieces = 0;

        for p=1, numPieces do
            if ( DTM_ItemsBuffer_GetItemEquipedAttributes(name, pieces[p]) ) then
                equipedPieces = equipedPieces + 1;
            end
        end

        setsData[set] = equipedPieces;
    end
end

-- --------------------------------------------------------------------
-- **                             Functions                          **
-- --------------------------------------------------------------------
