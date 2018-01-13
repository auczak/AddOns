local activeModule = "Feedback";

-- --------------------------------------------------------------------
-- **                         Feedback data                          **
-- --------------------------------------------------------------------

local TRACE_ENABLED = nil;

local TRACE_CATEGORY_FILTER = {
    ["ACCESS"] = nil, -- 1 to display this category debug traces. Use nil to prevent display.
    ["AGGRO"] = nil,
    ["BOSS"] = 1,
    ["BUFFER"] = nil,
    ["COMBAT"] = nil,
    ["COMBAT_EVENT_SELF"] = nil,
    ["COMBAT_EVENT_OTHER"] = nil,
    ["EMULATION"] = 1,
    ["MAINTENANCE"] = nil,
    ["THREAT_EVENT"] = 1,
    ["THREAT_ERROR"] = nil,
    ["STANCE"] = nil,
    ["NETWORK"] = nil,
    ["CROWD_CONTROL"] = nil,
    ["MISC"] = 1,
};

-- --------------------------------------------------------------------
-- **                       Feedback functions                       **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_ChatMessage(text, short)                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> text: what to display.                                        *
-- * >> short: displays DTM instead of the full mod name.             *
-- ********************************************************************
-- * Sends a plain text message to the default chat frame.            *
-- ********************************************************************

function DTM_ChatMessage(text, short)
    -- Note: it's a core & critical function whose potential errors have to be handled the standard way with error() API.
    if type(text) ~= "string" then
        error("Usage: DTM_ChatMessage(\"text\"[, short])", 0);
    end
    if type(DEFAULT_CHAT_FRAME) ~= "table" then
        error("(Critical) DTM_ChatMessage: No default chat frame is set in DEFAULT_CHAT_FRAME global variable !");
    end
    if ( short ) then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DTM|r - " .. text);
  else
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DiamondThreatMeter|r - " .. text);
    end
end

-- ********************************************************************
-- * DTM_Trace(category, text, flag, ...)                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> category: category of the debug message. This is used by the  *
-- *              filter. See above.                                  *
-- * >> text: what to display. Can be unformatted string.             *
-- * >> flag: set this argument if the text has unformatted tokens.   *
-- * >> ...: the arguments passed to format() function if flag is set.*
-- ********************************************************************
-- * Prints out a cute debug message on the default chat frame.       *
-- ********************************************************************

function DTM_Trace(category, text, flag, ...)
    if not ( TRACE_ENABLED ) then return; end
    if not ( TRACE_CATEGORY_FILTER[category] ) then return; end
    local textToDisplay = '';
    if ( flag ) then
        textToDisplay = format(text, ...);
  else
        textToDisplay = text;
    end
    DTM_ChatMessage(textToDisplay, 1);
end