-- NameplateLib v1.00

-- An embeddable WoW-Lib by MrCool.

-- Implements methods for distinguishing and querying nameplates frames, as well as getting
-- informations from them and easing their customisation.

-- Developped originally for DiamondThreatMeter, by MrCool.

-- STILL MISSING:
-- > Health querying (including max)
-- > Level querying

-- **************************************************************************************************
-- Check prerequisites
-- **************************************************************************************************

-- **************************************************************************************************
-- Version & setup stuff
-- **************************************************************************************************

local NAMEPLATE_LIB_VERSION = 1;
local NameplateLib = _G.NameplateLib;

if ( type(NameplateLib) == "table" ) and ( type(NameplateLib.version) == "number" ) and ( NameplateLib.version >= NAMEPLATE_LIB_VERSION ) then
    return; -- Newer version of the lib already loaded.
elseif ( type(NameplateLib) ~= "nil" and type(NameplateLib) ~= "table" ) then
    error("NameplateLib could not be loaded. <NameplateLib> global namespace was already used by something else.", 0);
    return; -- Something used the NameplateLib namespace.
end

_G.NameplateLib = { };
local NameplateLib = _G.NameplateLib;
NameplateLib.version = NAMEPLATE_LIB_VERSION;

-- **************************************************************************************************
-- The lib itself
-- **************************************************************************************************

local UPDATE_RATE = 0.100;
local callbacks = { };

-- Data stuff

local NAMEPLATES_TYPE = "Frame";
local NAMEPLATES_LEVEL = 1;
local NAMEPLATES_STRATA = "UNKNOWN";

-- Internal methods

function NameplateLib.OnUpdate(frame, elapsed)
    if ( ( GetTime() - NameplateLib.lastUpdate ) >= UPDATE_RATE ) then
       NameplateLib:Update();
       NameplateLib.lastUpdate = GetTime();
   end
end

function NameplateLib:Update()
    local k, i, me;

    for k in pairs(NameplateLib.nameplates) do NameplateLib.nameplates[k] = nil; end
    for k in pairs(NameplateLib.nameToFrame) do NameplateLib.nameToFrame[k] = nil; end

    for i=1, WorldFrame:GetNumChildren() do
        me = select(i, WorldFrame:GetChildren());
        if ( me:GetFrameType() == NAMEPLATES_TYPE and me:GetFrameStrata() == NAMEPLATES_STRATA and me:GetFrameLevel() == NAMEPLATES_LEVEL ) then
            if me:IsShown() and not me:GetName() then -- Nameplates do not have a name. It's an additionnal check to distinguish them.
                NameplateLib.nameplates[#NameplateLib.nameplates+1] = me;

                NameplateLib:ExtractData(me);
                local name = me.nName or nil;

                -- Name -> Nameplate frame association. It will fail if there are 2 nameplates for a given name and instead return the number of conflicts.
                if ( name ) then
                    if ( NameplateLib.nameToFrame[name] ) then
                        if type(NameplateLib.nameToFrame[name]) == "number" then
                            NameplateLib.nameToFrame[name] = NameplateLib.nameToFrame[name] + 1; -- Another conflict.
                      else
                            NameplateLib.nameToFrame[name] = 2; -- First conflict.
                        end
                  else
                        NameplateLib.nameToFrame[name] = me; -- No conflict.
                    end
                end
            end
        end
    end

    -- Fire callbacks

    local k, callback;
    for k, callback in pairs(callbacks) do
        if type(callback) == "function" then
            callback();
        end
    end
end

function NameplateLib:ExtractData(nameplate)
    if type(nameplate) ~= "table" then return; end

    -- Erase old data
    nameplate.nName = nil;
    nameplate.nLevel = nil;
    nameplate.nHealth = nil;
    nameplate.nHealthMax = nil;

    if not nameplate:IsShown() then return; end

    local regions = nameplate:GetNumRegions() or 0;
    local i, me;

    for i=1, regions do
        me = select(i, nameplate:GetRegions());

        if ( me:GetObjectType() == "FontString" ) then
            -- It's either the Level or the Name text.

            local point, relativeTo, relativePoint = me:GetPoint(1);

            if ( point == "BOTTOM" and relativeTo == nameplate and relativePoint == "CENTER" ) then
                -- Got the nameplate's name.

                nameplate.nName = me:GetText() or nil;
                if type(nameplate.nName) == "string" and #nameplate.nName == 0 then nameplate.nName = nil; end -- In case we get an empty string, use nil instead.

        elseif ( point == "CENTER" and relativeTo == nameplate and relativePoint == "BOTTOMRIGHT" ) then
                -- Got the nameplate's level.

                nameplate.nLevel = tonumber(me:GetText() or -1) or -1; -- -1 means skull or ?? level.
            end
        end
    end
end

-- Setup methods

function NameplateLib:Initialize()
    if ( NameplateLib.frame ) then return; end
    NameplateLib.frame = CreateFrame("Frame");
    NameplateLib.frame:SetScript("OnUpdate", NameplateLib.OnUpdate);
    NameplateLib.frame:Show();
    NameplateLib.lastUpdate = 0;
    NameplateLib.nameplates = { };
    NameplateLib.nameToFrame = { };
end

-- API

function NameplateLib:GetNum()
    return #NameplateLib.nameplates;
end

function NameplateLib:GetByID(index)
    return NameplateLib.nameplates[index] or nil;
end

function NameplateLib:GetByName(name)
    if type(NameplateLib.nameToFrame[name]) == "number" then
        return nil, NameplateLib.nameToFrame[name];
  else
        return NameplateLib.nameToFrame[name], 1;
    end
end

-- No return value is guaranteed. It depends on circumstances.

function NameplateLib:GetName(nameplate)
    return nameplate.nName or nil;
end

function NameplateLib:GetLevel(nameplate)
    return nameplate.nLevel or nil;
end

function NameplateLib:GetHealth(nameplate)
    return nameplate.nHealth or nil;
end

function NameplateLib:GetHealthMax(nameplate)
    return nameplate.nHealthMax or nil;
end

function NameplateLib:RegisterCallback(callback)
    if type(callback) ~= "function" then error("Usage: NameplateLib:RegisterCallback(function)", 1); end
    local funcName = tostring(callback);
    if not funcName then return; end
    callbacks[funcName] = callback;
end

-- **************************************************************************************************
-- Run it !
-- **************************************************************************************************

do
    NameplateLib:Initialize();
end