local activeModule = "Attributes";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- Notes: Attributes are currently not saved.
-- Maybe they will in a future version, in the savedvariables GUI part.

-- --------------------------------------------------------------------
-- **                         Attributes data                        **
-- --------------------------------------------------------------------

local DTM_KnownAttributes = {
    ["NONE"] = true,
    ["TANK"] = true,
};

local DTM_Attributes = { };

-- --------------------------------------------------------------------
-- **                         Attributes API                         **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SetAttribute(guid, name, attribute)                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid, name: the GUID and name of the entity.                  *
-- * Name is currently optional but recommanded nonetheless.          *
-- * >> attribute: the new attribute of this unit.                    *
-- * Nil or "NONE" means no special attribute.                        *
-- ********************************************************************
-- * Sets a special attribute for the given unit.                     *
-- * Invalid usage of this function will silently fail.               *
-- ********************************************************************

function DTM_SetAttribute(guid, name, attribute)
    if type(guid) ~= "string" or type(name) ~= "string" then return; end
    attribute = attribute or "NONE";

    if DTM_KnownAttributes[attribute] then
        DTM_Attributes[guid] = attribute;
  else
        return;
    end
end

-- ********************************************************************
-- * DTM_GetAttribute(guid)                                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> guid: the GUID of the entity.                                 *
-- ********************************************************************
-- * This function will get the raw data table of a skin.             *
-- ********************************************************************

function DTM_GetAttribute(guid)
    if type(guid) ~= "string" then return "INVALID"; end
    return DTM_Attributes[guid] or "NONE";
end