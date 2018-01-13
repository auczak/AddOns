local activeModule = "Engine emulation functions";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

DTM_EmuFunctions = {};

-- ******************************
--      - GUID compression -
--   Borrowed from ThreatLib2.0
-- ******************************

local gsub = string.gsub;

local guid_compress;
do
    local guid_compress_helper = function(x)
        return string.char(tonumber(x,16));
    end

    local function escape(s)
        s = gsub(s, "\254", "\254\252");
        s = gsub(s, "\061", "\254\251");
        s = gsub(s, "\058", "\254\250");
        s = gsub(s, "\255", "\254\253");
        return gsub(s, "%z", "\255");
    end

    guid_compress = setmetatable({}, { __index = function(self, guid)
        local cguid = string.match(guid, "0x(.*)");
        local str  = escape(gsub(cguid, "(%x%x)", guid_compress_helper));
        self[guid] = str;
        return str;
    end })
end

-- ******************************
--       - Serialization -
-- Borrowed from AceSerializer3.0
-- ******************************

local strbyte = string.byte
local strchar = string.char
local tconcat = table.concat
local gsub = string.gsub
local gmatch = string.gmatch
local pcall = pcall
local format = string.format
local type = type
local tostring, tonumber = tostring, tonumber
local select = select

local serNaN = tostring(0/0)
local serInf = tostring(1/0)
local serNegInf = tostring(-1/0)

local function SerializeStringHelper(ch)
    local n = strbyte(ch)
    if n<=32 then
        return "\126"..strchar(n+64)
    elseif n==94 then
        return "\126\125"
    elseif n==126 then
        return "\126\124"
    elseif n==127 then
        return "\126\123"
    end
end

local function SerializeValue(v, res, nres)
    local t=type(v)
    
    if t=="string" then
        res[nres+1] = "^S"
        res[nres+2] = gsub(v,"[%c \94\126\127]", SerializeStringHelper)
        nres=nres+2
    
    elseif t=="number" then
        local str = tostring(v)
        if tonumber(str)==v  or str==serNaN or str==serInf or str==serNegInf then
            -- translates just fine, transmit as-is
            res[nres+1] = "^N"
            res[nres+2] = str
            nres=nres+2
        else
            local m,e = frexp(v)
            res[nres+1] = "^F"
            res[nres+2] = format("%.0f",m*2^53)
            res[nres+3] = "^f"
            res[nres+4] = tostring(e-53)
            nres=nres+4
        end
    
    elseif t=="table" then
        nres=nres+1
        res[nres] = "^T"
        for k,v in pairs(v) do
            nres = SerializeValue(k, res, nres)
            nres = SerializeValue(v, res, nres)
        end
        nres=nres+1
        res[nres] = "^t"
    
    elseif t=="boolean" then
        nres=nres+1
        if v then
            res[nres] = "^B"
        else
            res[nres] = "^b"
        end
    
    elseif t=="nil" then
        nres=nres+1
        res[nres] = "^Z"
    end
    
    return nres
end

local serializeTbl = { "^1" }
function DTM_EmuFunctions:Serialize(...)
    local nres = 1
    for i=1,select("#", ...) do
        local v = select(i, ...)
        nres = SerializeValue(v, serializeTbl, nres)
    end
    serializeTbl[nres+1] = "^^"
    return tconcat(serializeTbl, "", 1, nres+1)
end

local function DeserializeStringHelper(escape)
    if escape<"~\123" then
        return strchar(strbyte(escape,2,2)-64)
    elseif escape=="~\123" then
        return "\127"
    elseif escape=="~\124" then
        return "\126"
    elseif escape=="~\125" then
        return "\94"
    end
end

local function DeserializeNumberHelper(number)
    if number == serNaN then
        return 0/0
    elseif number == serNegInf then
        return -1/0
    elseif number == serInf then
        return 1/0
    else
        return tonumber(number)
    end
end

local function DeserializeValue(iter,single,ctl,data)
    if not single then
        ctl,data = iter()
    end

    if not ctl or ctl=="^^" then
        return
    end

    local res
    
    if ctl=="^S" then
        res = gsub(data, "~.", DeserializeStringHelper)
    elseif ctl=="^N" then
        res = DeserializeNumberHelper(data)
        if not res then
            error("Invalid serialized number: '"..tostring(data).."'")
        end
    elseif ctl=="^F" then
        local ctl2,e = iter()
        if ctl2~="^f" then
            error("Invalid serialized floating-point number, expected '^f', not '"..tostring(ctl2).."'")
        end
        local m=tonumber(data)
        e=tonumber(e)
        if not (m and e) then
            error("Invalid serialized floating-point number, expected mantissa and exponent, got '"..tostring(m).."' and '"..tostring(e).."'")
        end
        res = m*(2^e)
    elseif ctl=="^B" then
        res = true
    elseif ctl=="^b" then
        res = false
    elseif ctl=="^Z" then
        res = nil
    elseif ctl=="^T" then
        res = {}
        local k,v
        while true do
            ctl,data = iter()
            if ctl=="^t" then break end
            k = DeserializeValue(iter,true,ctl,data)
            if k==nil then 
                error("Invalid serializer table format (no table end marker)")
            end
            ctl,data = iter()
            v = DeserializeValue(iter,true,ctl,data)
            if v==nil then
                error("Invalid serializer table format (no table end marker)")
            end
            res[k]=v
        end
    else
        error("Invalid serializer control code '"..ctl.."'")
    end
    
    if not single then
        return res,DeserializeValue(iter)
    else
        return res
    end
end

function DTM_EmuFunctions:Deserialize(str)
    str = gsub(str, "[%c ]", "")
    local iter = gmatch(str, "(^.)([^^]*)")
    local ctl,data = iter()
    if not ctl or ctl~="^1" then
        return false, "Supplied data is not serializer (rev 1) data"
    end
    return pcall(DeserializeValue, iter)
end

-- ******************************
--          - Encoding -
--  adapted from KLHThreatMeter.
-- ******************************

local activeGUIDBytes = 6;

local function encodeInt(buffer, value, numbytes)
    local mask, word, byte, x;

    for x = numbytes, 1, -1 do
        mask = bit.lshift(255, (x - 1) * 8);
        word = bit.band(mask, value);
        byte = bit.rshift(word, (x - 1) * 8);

        table.insert(buffer, byte);
    end
end

local function encodeGUID(buffer, guid)
    local miniGUID, hexaGUID;

    miniGUID = string.sub(guid, -2 * activeGUIDBytes, - activeGUIDBytes -1);
    hexaGUID = tonumber(miniGUID, 16);
    encodeInt(buffer, hexaGUID, activeGUIDBytes / 2);

    miniGUID = string.sub(guid, -activeGUIDBytes, -1);
    hexaGUID = tonumber(miniGUID, 16);
    encodeInt(buffer, hexaGUID, activeGUIDBytes / 2);
end

-- ******************************
-- - Emu functions added by DTM -
-- ******************************

-- ********************************************************************
-- * :IsPlayerOfficer(name)                                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name of the player to check.                        *
-- ********************************************************************
-- * Check if a given player is an officer of the raid or party.      *
-- * This function is not needed for DTM itself, but it is for the    *
-- * emulation module.                                                *
-- ********************************************************************
function DTM_EmuFunctions:IsPlayerOfficer(name)
    local ptr = DTM_GetGroupPointer(name);

    if ( ptr ) then
        if ( UnitIsPartyLeader(ptr) ) then
            return 1;
        end
    end

    -- In case of raids, check for assistant flag.

    local i, memberName, memberRank;

    for i=1, GetNumRaidMembers() do
        memberName, memberRank = GetRaidRosterInfo(i);
        if ( memberName == name ) and ( memberRank > 0 ) then
            return 1;
        end
    end

    return nil;
end

-- ********************************************************************
-- * :GetThreatUpdateRate()                                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Determinates the rate at which threat updates should be sent to  *
-- * the emulated AddOns. Slows down updates in a raid environment.   *
-- * This function is not needed for DTM itself, but it is for the    *
-- * emulation module.                                                *
-- ********************************************************************
function DTM_EmuFunctions:GetThreatUpdateRate()
    -- The rate is comprised between 1.5 and 3.0
    -- It's 1.5 when you are all alone, and 3.0 when you are in a 25-man raid or bigger.
    local groupSize = max(0, GetNumRaidMembers(), GetNumPartyMembers());
    return min(3.0, 1.5 + (groupSize / 25) * 1.5);
end

-- ********************************************************************
-- * :GetTL2ThreatString(unit)                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit to publish threat of.                          *
-- ********************************************************************
-- * Create a decent-sized string (less than 250 chars) to submit to  *
-- * ThreatLib2, which will fit in 1 network packet.                  *
-- * This packet will tell the threat of the top 8 targets.           *
-- * This function is not needed for DTM itself, but it is for the    *
-- * emulation module.                                                *
-- ********************************************************************
function DTM_EmuFunctions:GetTL2ThreatString(unit)
    --[[ ThreatLib2's way
	local t = {}
	local function getThreatString(unit, module, force)
		local mod = ThreatLib:GetModule(module, true)
		if not mod or not mod:IsEnabled() then return nil, false end
		local nl = 1
		local uid = UnitGUID(unit) or mod.unitGUID
		if not uid then return nil, false end
		t[1] = guid_compress[uid]  .. ":"
		local changed = false
		for k, v in pairs(mod.targetThreat) do
			if type(k) ~= "string" then
				error(format("Assertion failed! Expected %s, got %s", "string", tostring(type(k))))
			end
			if lastPublishedThreat[unit][k] ~= v or force then
				local fv = math_floor(v)
				nl = nl + 1
				t[nl] = format("%s=%d,", guid_compress[k], fv)
				lastPublishedThreat[unit][k] = v
				changed = true
			end
		end
		
		if changed then
			return tconcat(t, "", 1, nl), true
		else
			return nil, false
		end
	end
    ]]

    if not ( UnitExists(unit) ) or not ( UnitAffectingCombat(unit) ) then
        return nil;
    end

    -- We simply show the first elements of the unit's presence list, sorted in decreasing order.

    local i, listSize;
    listSize = DTM_UnitPresenceListSize(unit);

    if ( listSize == 0 ) then
        return nil;
    end

    local maxLength = 250;
    local str = guid_compress[UnitGUID(unit)]..":";
    local addingStr;
    local _, guid, threat;

    for i=1, min(listSize, 8) do
        _, guid, threat, _, _ = DTM_UnitPresenceList(unit, i);
        addingStr = format("%s=%d,", guid_compress[guid], math.floor(threat));
        if ( (#str + #addingStr) <= maxLength ) then
            str = str..addingStr;
      else
            break; -- Cannot add more data.
        end
    end

    return str;
end

-- ********************************************************************
-- * :GetKTMThreatString()                                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> unit: the unit to publish threat of.                          *
-- ********************************************************************
-- * Create a decent-sized string to submit to KTM, which will fit in *
-- * 1 network packet and will tell our threat on the top 10 targets. *
-- * (With KTM protocol I send more data, because it's simply more    *
-- * efficient than ThreatLib2 one :P)                                *
-- * This function is not needed for DTM itself, but it is for the    *
-- * emulation module.                                                *
-- ********************************************************************

local buffer = {};

local gsubencode = 
{
    ["\254"] = "\254\252",
    ["\255"] = "\254\253",
}

function DTM_EmuFunctions:GetKTMThreatString()
    --[[ KTM's way
	local buffer = mod.garbage.gettable() -- { }
	local mobdata, threat
	
	for x = 1, maxindex do
		
		mobdata = data[x]
		
		me.encodeguid(buffer, mobdata.mob)
		
		-- sanitise threat value
		threat = math.floor(mobdata.threat)
		
		if threat < 0 then
			threat = 0
		elseif threat > 16777215 then	-- 0xFFFFFF
			threat = 16777215
		end
		
		me.encodeint(buffer, threat, 3)
		
	end

	local message = string.char(unpack(buffer))

	-- undo invalid values
	message = message:gsub(".", me.gsubencode)
	message = message:gsub("%z", "\255")
		
	-- SEND
	mod.net.sendmessage("t2 " .. message)
    ]]

    if not ( UnitExists("player") ) or not ( UnitAffectingCombat("player") ) then
        return nil;
    end

    -- We simply show the first elements of player's presence list, sorted in decreasing order.

    local i, k, v, listSize;
    listSize = DTM_UnitPresenceListSize("player");

    if ( listSize == 0 ) then
        return nil;
    end

    for k, v in pairs(buffer) do
        buffer[k] = nil;
    end

    local _, guid, threat;

    for i=1, min(listSize, 10) do
        _, guid, threat, _, _ = DTM_UnitPresenceList("player", i);

        threat = math.floor(threat);
        threat = min(threat, 16777215);
        threat = max(threat, 0);

        encodeGUID(buffer, guid);
        encodeInt(buffer, threat, 3);
    end

    local message = string.char(unpack(buffer));
    message = message:gsub(".", gsubencode);
    message = message:gsub("%z", "\255");
    return "t2 "..message;
end