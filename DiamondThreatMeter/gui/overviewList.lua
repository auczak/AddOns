local activeModule = "GUI Overview list";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local MAX_ROWS = 20;

local INOUT_DELAY = 0.500;
local FADE_DELAY = 0.300;

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_GUI_GetMaxOverviewListRows()                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Returns the max number of rows an overview list can handle       *
-- * at once.                                                         *
-- ********************************************************************
function DTM_GUI_GetMaxOverviewListRows()
    return MAX_ROWS;
end

-- --------------------------------------------------------------------
-- **                            Methods                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * overviewListFrame:Display()                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> overviewListFrame: the overview list frame to operate on.     *
-- ********************************************************************
-- * Starts displaying an overview list frame.                        *
-- ********************************************************************
local function Display(overviewListFrame)
    if ( DTM_IsGUIRunning() ~= 1 ) then
        return;
    end
    if not ( overviewListFrame:IsShown() ) then
        overviewListFrame.alpha = 0.00;
        overviewListFrame.height = 48;
        overviewListFrame.status = "BOOTING";

        overviewListFrame:Show();

        overviewListFrame.standbyFrame:Hide();
        overviewListFrame.headerRow:Hide();

        -- Reapply the skin used.
        overviewListFrame:ApplySkin();
    end
end

-- ********************************************************************
-- * overviewListFrame:Reset()                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> overviewListFrame: the overview list frame to operate on.     *
-- ********************************************************************
-- * Instantly hides an overview list frame.                          *
-- ********************************************************************
local function Reset(overviewListFrame)
    overviewListFrame:Hide();

    overviewListFrame.standbyFrame:Hide();
    overviewListFrame.headerRow:Hide();
    for i=1, MAX_ROWS do
        overviewListFrame.row[i]:Hide();
        overviewListFrame.row[i].status = "UNUSED";
    end
end

-- ********************************************************************
-- * overviewListFrame:ApplySkin()                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> overviewListFrame: the overview list frame to operate on.     *
-- ********************************************************************
-- * Apply the currently selected skin to the given overview list.    *
-- ********************************************************************
local function ApplySkin(overviewListFrame)
    overviewListFrame:ApplyCommonSkin();

    local cfg = DTM_GetCurrentSkinSetting;

    overviewListFrame.barWidth = cfg("OverviewList", "Length");
    overviewListFrame.usedRows = cfg("OverviewList", "Rows");

    -- Now we know the width of bars for this list type, apply the width info.
    overviewListFrame:AdjustWidth();

    -- Apply the column config on the header row.
    DTM_ApplyColumnSetting(overviewListFrame.headerRow.name,          overviewListFrame.headerRow, cfg("Columns", "Name"),       1);
    DTM_ApplyColumnSetting(overviewListFrame.headerRow.threat,        overviewListFrame.headerRow, cfg("Columns", "Threat"),     1);
    DTM_ApplyColumnSetting(overviewListFrame.headerRow.tps,           overviewListFrame.headerRow, cfg("Columns", "TPS"),        1);
    DTM_ApplyColumnSetting(overviewListFrame.headerRow.threatPercent, overviewListFrame.headerRow, cfg("Columns", "Percentage"), 1);

    for i=1, MAX_ROWS do
        overviewListFrame.row[i]:ApplySkin();
    end
end

-- See commonList.lua for additionnal methods that are common to all lists.

-- --------------------------------------------------------------------
-- **                        Private methods                         **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * overviewListFrame:CheckUnitValidity()                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> overviewListFrame: the overview list frame checked.           *
-- ********************************************************************
-- * Checks the unit watched by a given overview list frame is valid. *
-- * Returns flag and a status message.                               *
-- ********************************************************************
local function CheckUnitValidity(overviewListFrame)
    local unit = overviewListFrame.unit;

    if ( UnitExists(unit) ) then
        return 1, DTM_Localise("overviewOpening");
    end

    return nil, DTM_Localise("overviewNoUnit");
end

-- --------------------------------------------------------------------
-- **                             Handlers                           **
-- --------------------------------------------------------------------

function DTM_OverviewListFrame_OnLoad(self)
    self.listType = "OVERVIEWLIST";

    -- Sets frames variables.
    self.presenceData = {};

    -- Binds methods to the new frame.
    self.Display = Display;
    self.Reset = Reset;
    self.ApplySkin = ApplySkin;
    -- + Destroy inherited from common list.
    -- + GetStatus inherited from common list.
    -- + AdjustWidth inherited from common list.

    -- Private methods
    self.CheckUnitValidity = CheckUnitValidity;

    -- Create threat rows.
    self.row = {};
    for i=1, MAX_ROWS do
        -- Presence list's rows behave the same way as threat list row. <3 code reuse.
        self.row[i] = CreateFrame("StatusBar", self:GetName().."_Row"..i, self, "DTM_ThreatListFrame_RowTemplate");
        self.row[i].id = i;
    end

    -- Also set properties common to all lists.
    DTM_CommonListFrame_OnLoad(self);
end

function DTM_OverviewListFrame_OnUpdate(self, elapsed)
    if ( self.status == "UNUSED" ) then
        self:Hide();
        return;
    end

    -- Default height
    self.targetHeight = 48;

    -- ***** Manage the frame status & main properties *****

    local unit = self.unit;
 
    local valid, statusText = self:CheckUnitValidity();

    if ( self.status == "BOOTING" ) then
        self.alpha = min(1.00, self.alpha + elapsed / (INOUT_DELAY * self.fadeCoeff));

        if ( self.alpha >= 1.00 ) then
            self.status = "READY";

            self.standbyFrame:Show();
            UIFrameFadeIn(self.standbyFrame, FADE_DELAY * self.fadeCoeff, 0.00, 1.00);
        end
    end

    if ( self.status == "READY" ) then
        -- If the unit ID tied to the overview list becomes valid (that is, existant), start monitoring its presence list.

        if ( self.standbyFrame:GetAlpha() >= 1.00 ) and ( valid ) then
            self.unitGUID = UnitGUID(unit);
            self.unitName = UnitName(unit);
            self.status = "GRABBING";
            UIFrameFadeOut(self.standbyFrame, FADE_DELAY * self.fadeCoeff, 1.00, 0.00);
        end

        self.standbyFrame.standbyText:SetText( statusText );
    end

    if ( self.status == "GRABBING" ) then
        -- We wait till end of the standbyFrame fade out.

        if ( self.standbyFrame:GetAlpha() <= 0.00 ) then
            if not ( valid ) then
                -- Unit became invalid in between.
                self.status = "READY";

                self.standbyFrame:Show();
                UIFrameFadeIn(self.standbyFrame, FADE_DELAY * self.fadeCoeff, 0.00, 1.00);
          else
                -- OK, we can start displaying threat list.
                self.status = "RUNNING";

                self.headerRow:Show();

                UIFrameFadeIn(self.headerRow, FADE_DELAY * self.fadeCoeff, 0.00, 1.00);

                -- Prepare the unit info text.
                self.unitInfoString = format(DTM_Localise("overviewUnitInfo"), self.unitName);
                self.headerRow.unitInfo:SetText( self.unitInfoString );

                self.headerRow.unitInfo:ClearAllPoints();
                self.headerRow.unitInfo:SetPoint("TOP", self.headerRow, "TOP", 0, -8);
                self.headerRow.unitInfo:SetHeight(16);
                self.headerRow.name:Show();
                self.headerRow.threat:Show();
                self.headerRow.threatPercent:Show();
            end
        end
    end

    -- By default makes all bars going to disapparear, unless we flag them below they're still used.
    for r=1, MAX_ROWS do
        self.row[r].stillUsed = nil;
    end

    if ( self.status == "RUNNING" ) then
        -- Overview list working.

        if ( self.headerRow:GetAlpha() >= 1.00 ) then
            if not ( valid ) or ( UnitName(unit) ~= self.unitName ) or ( UnitGUID(unit) ~= self.unitGUID ) then
                -- Unit became invalid in between.
                self.status = "CLEARING";

                UIFrameFadeOut(self.headerRow, FADE_DELAY * self.fadeCoeff, 1.00, 0.00);
          else
                -- Build presence list from API.

                for k, v in pairs(self.presenceData) do
                    self.presenceData[k] = nil;
                end

                local name, guid, threat, ratio, hasAggro, tps;

                size = min(DTM_UnitPresenceListSize(unit), self.usedRows, MAX_ROWS);
                index = 0;
                for i=1, size do
                    name, guid, threat, ratio, hasAggro, tps = DTM_UnitPresenceList(unit, i);

                    index = index + 1;

                    self.presenceData["name"..index] = name;
                    self.presenceData["guid"..index] = guid;
                    self.presenceData["threat"..index] = threat;
                    self.presenceData["ratio"..index] = ratio;
                    self.presenceData["aggro"..index] = hasAggro;
                    self.presenceData["tps"..index] = tps;
                end

                self.presenceData.number = index;

                -- We needn't sort the presence list, because the engine has already done that for us.

                local i, r;

                -- OK, let's update the rows appropriately.
                -- If a given entity in the list is not displayed, allocate a new row.

                self.targetHeight = 48 + 20 * self.presenceData.number;

                local found;

                local aggroThreat;

                for i=1, self.presenceData.number do
                    found = nil;

                    name = self.presenceData["name"..i];
                    guid = self.presenceData["guid"..i];
                    threat = self.presenceData["threat"..i];
                    ratio = self.presenceData["ratio"..i];
                    hasAggro = self.presenceData["aggro"..i];
                    tps = self.presenceData["tps"..i];

                    if ( ratio ) then
                        aggroThreat = threat / ratio;
                  else
                        aggroThreat = 0;
                    end

                    -- Checks if a row is already displaying the current browsed entity threat.
                    for r=1, MAX_ROWS do
                        if ( self.row[r].status ~= "UNUSED" ) and ( self.row[r].guid == guid ) then
                            self.row[r]:Update(name, guid, threat, nil, aggroThreat, i, hasAggro, tps);
                            self.row[r].position = i;
                            found = 1;
                            break;
                        end
                    end

                    if not ( found ) then
                        -- No row does. Allocates a new row.
                        for r=1, MAX_ROWS do
                            -- Finds an unused row that will display the threat info.
                            if ( self.row[r].status == "UNUSED" ) then
                                -- Empty slot is O.K, but is the frame tall enough ?
                                if ( (self.height-48) >= (20*i) ) then
                                    -- Slot found.
                                    self.row[r]:Activate(name, guid, threat, nil, aggroThreat, i, hasAggro, tps);
                                    self.row[r].position = i;
                                    break;
                                end
                            end
                        end
                    end
                end
            end

            -- Update the symbol. Remove it if the presence list is shutting down.
            local symbol, symbolString = 0, '';
            symbol = DTM_SymbolsBuffer_Get(self.unitGUID);
            if ( symbol > 0 ) and ( self.status == "RUNNING" ) then
                symbolString = format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d.blp:0|t ", symbol);
            end   
            self.headerRow.unitInfo:SetText( symbolString .. self.unitInfoString );
        end
    end

    -- Grab rows that do not have the stillUsed field set and ask for their deletion.

    for r=1, MAX_ROWS do
        if ( self.row[r].status ~= "UNUSED" ) and not ( self.row[r].stillUsed ) then
            self.row[r]:Destroy();
        end
    end

    if ( self.status == "CLEARING" ) then
        -- We wait till end of the headerRow frame.

        if ( self.headerRow:GetAlpha() <= 0.00 ) then
            self.status = "READY";

            self.standbyFrame:Show();
            UIFrameFadeIn(self.standbyFrame, FADE_DELAY * self.fadeCoeff, 0.00, 1.00);
        end
    end

    if ( self.status == "CLOSING" ) then
        self.alpha = max(0.00, self.alpha - elapsed / (INOUT_DELAY * self.fadeCoeff));

        if ( self.alpha <= 0.00 ) then
            self.status = "UNUSED";
        end
    end

    -- ***** Common properties *****

    DTM_CommonListFrame_OnUpdate(self, elapsed);
end