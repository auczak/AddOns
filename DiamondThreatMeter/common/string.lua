local activeModule = "String";

-- --------------------------------------------------------------------
-- **                           String data                          **
-- --------------------------------------------------------------------

-- This module provides some string functions.
-- Those are taken from my function library (CoolLib) string API.

-- --------------------------------------------------------------------
-- **                           String API                           **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_GetRankFromString(rankString)                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Extracts a rank number from given string.                        *
-- * If rank cannot be found, nil is returned.                        *
-- ********************************************************************
function DTM_GetRankFromString(rankString)
    if not ( rankString ) then return nil; end
    local _, _, stringFound = string.find( rankString , DTM_Localise("RankCapture") );
    if ( stringFound ) then
        return tonumber( stringFound );
    end
    return nil;
end

-- ********************************************************************
-- * DTM_FormatCountdownString(time, formatPattern,                   *
-- *                           hrsNoPad, minNoPad, secNoPad)          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * > time: the time value to use in the format (in sec).            *
-- * > formatPattern: how to format the string. You can use %H, %M,   *
-- * %S and %C tags. They'll get replaced by their equivalent value.  *
-- * > xNoPad: if set, it will prevent the format function from       *
-- * adding a "0" if value of x is below 10.                          *
-- ********************************************************************
-- * Creates a countdown string with a given format pattern.          *
-- * If rank cannot be found, nil is returned.                        *
-- ********************************************************************
function DTM_FormatCountdownString(time, formatPattern, hrsNoPad, minNoPad, secNoPad)
    if type(time) ~= "number" or type(formatPattern) ~= "string" then return "INVALID"; end
    
    local hrs, min, sec, cen;

    -- Extract each component

    hrs = math.floor( math.floor(time) / 3600 );
    min = math.floor( math.fmod( math.floor(time) / 60 , 60 ) );
    sec = math.floor( math.fmod( math.floor(time) , 60 ) );
    cen = math.floor( math.fmod( math.floor(time * 100) , 100 ) );

    -- Pads a "0" if below 10 to look pretty (0:4 is dumb for instance, 00:04 is nice),
    -- given there is not a noPad parameter set to prevent us doing this.

    if ( hrs < 10 and not hrsNoPad ) then hrs = "0"..tostring(hrs); else hrs = tostring(hrs); end
    if ( min < 10 and not minNoPad ) then min = "0"..tostring(min); else min = tostring(min); end
    if ( sec < 10 and not secNoPad ) then sec = "0"..tostring(sec); else sec = tostring(sec); end
    if ( cen < 10 ) then cen = "0"..tostring(cen); else cen = tostring(cen); end

    -- Build the result string

    local text = formatPattern;
    text = string.gsub(text, "%%H", hrs);
    text = string.gsub(text, "%%M", min);
    text = string.gsub(text, "%%S", sec);
    text = string.gsub(text, "%%C", cen);
    return text;
end