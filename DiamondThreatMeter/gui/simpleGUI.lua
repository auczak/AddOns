local activeModule = "GUI Simple GUI";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- Uncomment to enable the simple GUI.
-- local USE_SIMPLE_GUI = 1;

local MAX_ROWS = 10;
local DTM_SimpleGUI_Running = nil;
local eventHandlers = {};

local UPDATE_RATE = 0.250;

local CLASS_BUTTONS = {
	["WARRIOR"]	= {0, 0.25, 0, 0.25},
	["MAGE"]		= {0.25, 0.49609375, 0, 0.25},
	["ROGUE"]		= {0.49609375, 0.7421875, 0, 0.25},
	["DRUID"]		= {0.7421875, 0.98828125, 0, 0.25},
	["HUNTER"]		= {0, 0.25, 0.25, 0.5},
	["SHAMAN"]	 	= {0.25, 0.49609375, 0.25, 0.5},
	["PRIEST"]		= {0.49609375, 0.7421875, 0.25, 0.5},
	["WARLOCK"]	= {0.7421875, 0.98828125, 0.25, 0.5},
	["PALADIN"]		= {0, 0.25, 0.5, 0.75},
	["DEATHKNIGHT"]	= {0.25, 0.49609375, 0.5, 0.75},
};

local CLASS_COLORS = {
    ["DRUID"] = { r=1.0, g=0.5, b=0 },
    ["HUNTER"] = { r=0.2, g=0.8, b=0.2 },
    ["MAGE"] = { r=0.4, g=0.4, b=1.0 },
    ["PALADIN"] = { r=1.0, g=0.2, b=0.7 },
    ["PRIEST"] = { r=0.8, g=0.8, b=0.8 },
    ["ROGUE"] = { r=0.8, g=0.8, b=0.3 },
    ["SHAMAN"] = { r=0.2, g=0.2, b=0.8 },
    ["WARLOCK"] = { r=0.3, g=0.5, b=0.9 },
    ["WARRIOR"] = { r=0.9, g=0.6, b=0.6 },

    ["DEATH_KNIGHT"] = { r=0.2, g=0.2, b=0.2 },

    ["UNKNOWN"] = { r=0.4, g=0.4, b=0.4 },
};

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_StartSimpleGUI()                                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Start the simple GUI part of DTM.                                *
-- ********************************************************************
function DTM_StartSimpleGUI()
    if not USE_SIMPLE_GUI then return; end -- Advanced version should no longer use simple GUI.
    DTM_SimpleGUI_Running = 1;
    DTM_SimpleGUI_Frame:Show();
end

-- ********************************************************************
-- * DTM_StopSimpleGUI()                                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Stop the simple GUI part of DTM.                                 *
-- ********************************************************************
function DTM_StopSimpleGUI()
    if not USE_SIMPLE_GUI then return; end -- Advanced version should no longer use simple GUI.
    DTM_SimpleGUI_Running = nil;
    DTM_SimpleGUI_Frame:Hide();
end

-- ********************************************************************
-- * DTM_IsSimpleGUIRunning()                                         *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Determinates if DTM simple GUI is currently running.             *
-- ********************************************************************
function DTM_IsSimpleGUIRunning()
    return DTM_SimpleGUI_Running;
end

-- --------------------------------------------------------------------
-- **                           Functions                            **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SimpleGUI_RegisterEvent(event, handler)                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> event: the event to be notified of.                           *
-- * >> handler: the function which will get fired.                   *
-- ********************************************************************
-- * Start the engine part of DTM.                                    *
-- ********************************************************************
function DTM_SimpleGUI_RegisterEvent(event, handler)
    eventHandlers[event] = handler;
    DTM_SimpleGUI_Frame:RegisterEvent(event);
end

-- ********************************************************************
-- * DTM_SimpleGUI_SortThreatData(data)                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> data: the table containing a threat list.                     *
-- ********************************************************************
-- * Sorts a threat list in increasing order.                         *
-- ********************************************************************
function DTM_SimpleGUI_SortThreatData(data)
    local numEntity = data.number or 0;
    local i, ii, redo, tmp, count;
    i = 0;
    count = 0;
    redo = nil;

    repeat
        count = count + 1;
        if not ( redo ) then
            i = i + 1;
        end
        redo = nil;

        selfName = data["name"..i] or "???";
        selfThreat = data["threat"..i] or 0;
        selfClass = data["class"..i] or nil;
        selfFlag = data["flag"..i] or nil;

        selfHasAggro = ( selfName == data.aggro );

        for ii = i+1, numEntity do
            if ( ( selfThreat < (data["threat"..ii] or 0) ) or ( data["name"..ii] == data.aggro ) ) and not ( selfHasAggro ) then
                data["name"..i] = data["name"..ii];
                data["threat"..i] = data["threat"..ii];
                data["class"..i] = data["class"..ii];
                data["flag"..i] = data["flag"..ii];

                data["name"..ii] = selfName;
                data["threat"..ii] = selfThreat;
                data["class"..ii] = selfClass;
                data["flag"..ii] = selfFlag;

                redo = 1;
                break;
            end
        end
    until ( i >= numEntity ) or ( count > 100 ); -- count>100 is here to prevent freezing :o)

    if ( count > 100 ) then message("DTM_SimpleGUI_SortThreatData: Stack Overflow"); end
end

-- --------------------------------------------------------------------
-- **                      DTM Simple GUI handlers                   **
-- --------------------------------------------------------------------

function DTM_SimpleGUI_OnLoad(self)
    self.updateTimer = 0.000;
    self.threatData = {};

    DTM_SimpleGUI_RegisterEvent("PLAYER_TARGET_CHANGED", DTM_SimpleGUI_TargetChanged);

    self.row = {};
    for i=1, MAX_ROWS do
        self.row[i] = CreateFrame("StatusBar", self:GetName().."_Row"..i, self, "DTM_SimpleGUI_RowTemplate");
    end

    DTM_SimpleGUI_HeaderRow:Show();
    DTM_SimpleGUI_HeaderRow:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -8);
    DTM_SimpleGUI_HeaderRow:SetMinMaxValues(0.0, 1.0);
    DTM_SimpleGUI_HeaderRow:SetValue(0.0);
end

function DTM_SimpleGUI_OnEvent(self, event, ...)
    if not ( event ) then return 0; end

    if ( eventHandlers[event] ) then
        eventHandlers[event](...);
        return 1;
    end

    return 2;
end

function DTM_SimpleGUI_OnUpdate(self, elapsed)
    if not ( DTM_SimpleGUI_Running ) then
        self:Hide();
        return;
    end

    self.updateTimer = self.updateTimer - (elapsed or 0);
    if ( self.updateTimer <= 0.000 ) then
        self.updateTimer = UPDATE_RATE;

        for k, v in pairs(self.threatData) do
             self.threatData[k] = nil;
        end

        size = DTM_UnitThreatListSize("target");
        self.threatData.number = size;
        for i=1, size do
            name, guid, threat, class, flag = UnitThreatList("target", i);
            self.threatData["name"..i] = name;
            self.threatData["threat"..i] = threat;
            self.threatData["class"..i] = class;
            self.threatData["flag"..i] = flag;
        end
        self.threatData.aggro = DTM_UnitThreatGetAggro("target");
        DTM_SimpleGUI_SortThreatData(self.threatData);

        -- Get the aggro threat if there is one.
        aggroThreat = nil;
        aggroName = self.threatData.aggro;
        if ( aggroName ) then
            for i=1, size do
                name, guid, threat = DTM_UnitThreatList("target", i);
                if ( name == aggroName ) then
                    aggroThreat = threat;
                    break;
                end
            end
        end

        -- Now builds the display.

        for i=1, MAX_ROWS do
            row = self.row[i];
            if ( i <= self.threatData.number ) then
                local threatPercent = 0;
                local threatPercentText = "-";
                if ( aggroName ) and ( aggroThreat ) then
                    if ( aggroThreat > 0 ) then
                        threatPercent = self.threatData["threat"..i] / aggroThreat * 100;
                        threatPercentText = floor(threatPercent) .. "%"
                    end
                end

                row.name:SetText(self.threatData["name"..i]);
                row.threat:SetText(floor(self.threatData["threat"..i]+0.5));
                row.threatPercent:SetText(threatPercentText);

                class = self.threatData["class"..i] or "UNKNOWN";
                colorScheme = CLASS_COLORS[class];
                iconCoords = CLASS_BUTTONS[class];
                r, g, b = colorScheme.r, colorScheme.g, colorScheme.b;
                if ( iconCoords ) then
                    row.class:SetTexCoord(unpack(iconCoords));
                    row.class:Show();
              else
                    row.class:Hide();
                end

                row:SetStatusBarColor(r, g, b);
                row:SetMinMaxValues(0.0, 130.0);
                row:SetValue(threatPercent);
                row:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -24 - (i-1) * 16);
                row:Show();
          else
                row:Hide();
            end
        end

        effectiveSize = min(MAX_ROWS, self.threatData.number);
        self:SetHeight(32 + effectiveSize * 16);
    end
end

-- --------------------------------------------------------------------
-- **                      DTM Simple GUI events                     **
-- --------------------------------------------------------------------

function DTM_SimpleGUI_TargetChanged()
    DTM_SimpleGUI_Frame.updateTimer = 0.000;
end