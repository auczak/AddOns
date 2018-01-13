
KARaidTrackerUtility = { };

function KARaidTrackerUtility:ToStr(val)
	if not val then val = "[nil]" end
	if type(val)=="table" then val = "[table]" end
	return val
end

function KARaidTrackerUtility:Debug(...)
    --local a = ...;
    if ( KARaidTrackerDB.Options.DebugFlag ) then
        local sDebug = "#";
        for i = 1, select("#", ...) , 1 do
            if ( select(i, ...) ) then
                sDebug = sDebug .. tostring(select(i, ...) ) .. "#";
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage(sDebug, 1, 0.5, 0);
    end
end

function KARaidTrackerUtility:SysMsg(...)
	local msg = ""
	for i=1, select("#", ...), 1 do
		msg = msg .. tostring( self:ToStr(select(i, ...)) );
  	end
    DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 0.5, 0);
end


function KARaidTrackerUtility:GetTime(dDate)
    if ( not dDate ) then
        return nil;
    end
    local _, _, mon, day, year, hr, min, sec = string.find(dDate, "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)");
    local table = date("*t", time());
    local timestamp;
    table["month"] = tonumber(mon);
    table["year"] = tonumber("20" .. year);
    table["day"] = tonumber(day);
    table["hour"] = tonumber(hr);
    table["min"] = tonumber(min);
    table["sec"] = tonumber(sec);
    timestamp = time(table);
    return timestamp;
end

function KARaidTrackerUtility:ColorToRGB(str)
    str = strlower(strsub(str, 3));
    local tbl = { };
    tbl[1], tbl[2], tbl[3], tbl[4], tbl[5], tbl[6] = strsub(str, 1, 1), strsub(str, 2, 2), strsub(str, 3, 3), strsub(str, 4, 4), strsub(str, 5, 5), strsub(str, 6, 6);
    
    local highvals = { ["a"] = 10, ["b"] = 11, ["c"] = 12, ["d"] = 13, ["e"] = 14, ["f"] = 15 };
    for k, v in pairs(tbl) do
        if ( highvals[v] ) then
            tbl[k] = highvals[v];
        elseif ( tonumber(v) ) then
            tbl[k] = tonumber(v);
        end
    end
    local r, g, b = (tbl[1]*16+tbl[2])/255, (tbl[3]*16+tbl[4])/255, (tbl[5]*16+tbl[6])/255;
    if ( not r or r > 1 or r < 0 ) then
        r = 1;
    end
    if ( not g or g > 1 or g < 0 ) then
        g = 1;
    end
    if ( not b or b > 1 or b < 0 ) then
        b = 1;
    end
    return r, g, b;
end

function KARaidTrackerUtility:FixZero(num)
    if ( num < 10 ) then
        return "0" .. num;
    else
        return num;
    end
end

function KARaidTrackerUtility:CopyDeep(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end  -- if
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end  -- for
        return setmetatable(new_table, getmetatable(object))
    end  -- function _copy
    return _copy(object)
end  -- function deepcopy

-- this assumes the objects have the same basic structure,
-- but wont let a null clobber a table reference
function KARaidTrackerUtility:MergeDeep(dst, src)

	-- copy clobber check
 	local function _canCopy(dst, src)
 		if not dst then	return true	end
 	 	if not src then	return false end 	
 	 	if type(dst) == "table" and type(src) ~= "table" then
 			return false 
 		end
 	 	if type(dst) ~= "table" and type(src) == "table" then
 			return false 
 		end
	 	return true
	end
	-- recursive copy
	local function _copy(dst, src)
		for i, v in pairs(src) do
			if _canCopy(dst[i], v) then
				if type(v) ~= "table" then 
--					KARaidTrackerData:PrintValue("Options",i,v);
					if dst[i] ~= v then dst[i] = v end
--					KARaidTrackerData:PrintValue("Options",i,v);
				else
					self:SysMsg("      t:"..i.."="..v)		
					if not dst[i] then dst[i] = { } end
					_copy(i, dst[i], v) 
				end
			end 	
		end  -- for
		return dst
	end

	if _canCopy(dst, src) then 
		if type(src) ~= "table" then return src end
		if not dst then dst = { } end 	
	 	_copy(dst, src)
	end
 	
	return dst 
end  -- function deepcopy