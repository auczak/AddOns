local activeModule = "Resources";

-- --------------------------------------------------------------------
-- **                         Resources data                         **
-- --------------------------------------------------------------------

local SFX_BASE_FOLDER = "Interface\\AddOns\\DiamondThreatMeter\\snd\\";
local GFX_BASE_FOLDER = "Interface\\AddOns\\DiamondThreatMeter\\gfx\\";
local BASE_FOLDER = "Interface\\AddOns\\DiamondThreatMeter\\";

local sounds = {
    [1] = {
        name = "BUZZER",
        filename = "Buzzer.wav",
        type = "WARNING",
    },

    [2] = {
        name = "WEIRD",
        filename = "Weird.wav",
        type = "WARNING",
    },

    [3] = {
        name = "PEASANT",
        filename = "Peasant.wav",
        type = "WARNING",
    },

    [4] = {
        name = "ALARM",
        filename = "Alarm.wav",
        type = "WARNING",
    },
};

local graphics = {
    [1] = {
        name = "AGGRO_THRESHOLD",
        filename = "AggroThreshold.tga",
        width = 16,
        height = 16,
    },
    [2] = {
        name = "TANK",
        filename = "Tank.tga",
        width = 16,
        height = 16,
    },
};

-- --------------------------------------------------------------------
-- **                      Resources functions                       **
-- --------------------------------------------------------------------

-- ------------------------ #1: Sound functions -----------------------

-- ********************************************************************
-- * DTM_Resources_GetSoundData(id)                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * id >> id of sound. Internal name can also be passed.             *
-- *                    (and that is preferable)                      *
-- ********************************************************************
-- * Return data about a certain sound:                               *
-- * - Internal name (you ought to work with this, instead of IDs)    *
-- * - Filename (leading to the sound, the root is SFX folder)        *
-- * - Type (the type of the sound, which explains when it is to be   *
-- *         used; if DTM engine searches for this type of sound      *
-- *         and there are more than one, it chooses randomly one.)   *
-- ********************************************************************

function DTM_Resources_GetSoundData(id)
    if ( type(id) == 'string' ) then
        for index, data in pairs( sounds ) do
            if ( data.name == id ) then
                return data.name, SFX_BASE_FOLDER..(data.filename or ''), data.type;
            end
        end
  else
        local data = sounds[id];
        if ( data ) then
            return data.name, SFX_BASE_FOLDER..(data.filename or ''), data.type;
        end
    end
    return nil, nil, nil;
end

-- ********************************************************************
-- * DTM_Resources_GetAllSoundsOfType(type)                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * type >> type of sound we'd like to get a list of.                *
-- ********************************************************************
-- * Return the number of sounds matching the type given, and a table *
-- * indexed from 1 to "number" containing their respective internal  *
-- * names.                                                           *
-- ********************************************************************

function DTM_Resources_GetAllSoundsOfType(type)
    local number = 0;
    local internalNames = {};
    for index, data in pairs( sounds ) do
        if ( data.type == type ) then
            number = number + 1;
            internalNames[number] = data.name;
        end
    end
    return number, internalNames;
end

-- ---------------------- #2: Graphics functions ----------------------

-- ********************************************************************
-- * DTM_Resources_GetGraphicData(id)                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * id >> id of gfx. Internal name can also be passed.               *
-- *                    (and that is preferable)                      *
-- ********************************************************************
-- * Return data about a certain gfx:                                 *
-- * - Internal name (you ought to work with this, instead of IDs)    *
-- * - Filename (leading to the gfx, the root is GFX folder)          *
-- * - Width of the graphic.                                          *
-- * - Height of the graphic.                                         *
-- ********************************************************************

function DTM_Resources_GetGraphicData(id)
    if ( type(id) == 'string' ) then
        for index, data in pairs( graphics ) do
            if ( data.name == id ) then
                return data.name, GFX_BASE_FOLDER..(data.filename or ''), data.width, data.height;
            end
        end
  else
        local data = graphics[id];
        if ( data ) then
            return data.name, GFX_BASE_FOLDER..(data.filename or ''), data.width, data.height;
        end
    end
    return nil, nil, nil, nil;
end

-- ---------------------- #3: General functions -----------------------

-- ********************************************************************
-- * DTM_Resources_GetAbsolutePath(type, filename)                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * > type: the type of file. Can be either SOUND or GFX.            *
-- * > filename: the (subfolder +) filename of the ressource file.    *
-- ********************************************************************
-- * Get the total filename of a texture, sound file, to use with WoW *
-- * texture/play sound APIs.                                         *
-- ********************************************************************

function DTM_Resources_GetAbsolutePath(type, filename)
    if ( type == "SOUND" ) then return SFX_BASE_FOLDER..filename; end
    if ( type == "GFX" ) then return GFX_BASE_FOLDER..filename; end
    return BASE_FOLDER..filename;
end