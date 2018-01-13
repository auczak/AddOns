local activeModule = "GUI Regain list";

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
-- * DTM_GUI_GetMaxRegainListRows()                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Returns the max number of rows a regain list can handle          *
-- * at once.                                                         *
-- ********************************************************************
function DTM_GUI_GetMaxRegainListRows()
    return MAX_ROWS;
end

-- --------------------------------------------------------------------
-- **                            Methods                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * regainListFrame:Display()                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> regainListFrame: the regain list frame to operate on.         *
-- ********************************************************************
-- * Starts displaying a regain list frame.                           *
-- ********************************************************************
local function Display(regainListFrame)
    if ( DTM_IsGUIRunning() ~= 1 ) then
        return;
    end
    if not ( regainListFrame:IsShown() ) then
        regainListFrame.alpha = 0.00;
        regainListFrame.height = 48;
        regainListFrame.status = "BOOTING";

        regainListFrame:Show();

        regainListFrame.standbyFrame:Hide();
        regainListFrame.headerRow:Hide();

        -- Reapply the skin used.
        regainListFrame:ApplySkin();
    end
end

-- ********************************************************************
-- * regainListFrame:Reset()                                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> regainListFrame: the regain list frame to operate on.         *
-- ********************************************************************
-- * Instantly hides a regain list frame.                             *
-- ********************************************************************
local function Reset(regainListFrame)
    regainListFrame:Hide();

    regainListFrame.standbyFrame:Hide();
    regainListFrame.headerRow:Hide();
    for i=1, MAX_ROWS do
        regainListFrame.row[i]:Hide();
        regainListFrame.row[i].status = "UNUSED";
    end
end

-- ********************************************************************
-- * regainListFrame:ApplySkin()                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> listFrame: the regain list frame to operate on.               *
-- ********************************************************************
-- * Apply the currently selected skin to the given regain list frame.*
-- ********************************************************************
local function ApplySkin(regainListFrame)
    regainListFrame:ApplyCommonSkin();

    local cfg = DTM_GetCurrentSkinSetting;

    regainListFrame.barWidth = cfg("RegainList", "Length");
    regainListFrame.usedRows = cfg("RegainList", "Rows");

    -- Now we know the width of bars for this list type, apply the width info.
    regainListFrame:AdjustWidth();

    -- Apply the column config on the header row.
    DTM_ApplyColumnSetting(regainListFrame.headerRow.name,     regainListFrame.headerRow, cfg("RegainColumns", "Name"),     1);
    DTM_ApplyColumnSetting(regainListFrame.headerRow.threat,   regainListFrame.headerRow, cfg("RegainColumns", "Threat"),   1);
    DTM_ApplyColumnSetting(regainListFrame.headerRow.relative, regainListFrame.headerRow, cfg("RegainColumns", "Relative"), 1);

    for i=1, MAX_ROWS do
        regainListFrame.row[i]:ApplySkin();
    end
end

-- See commonList.lua for additionnal methods that are common to all lists.

-- --------------------------------------------------------------------
-- **                        Private methods                         **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * regainListFrame:CheckUnitValidity()                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> regainListFrame: the regain list frame checked.               *
-- ********************************************************************
-- * Checks the unit watched by a given regain list frame is valid.   *
-- * Returns flag and a status message.                               *
-- ********************************************************************
local function CheckUnitValidity(regainListFrame)
    local unit = regainListFrame.unit;

    if ( UnitExists(unit) ) then
        return 1, DTM_Localise("regainOpening");
    end

    return nil, DTM_Localise("regainNoUnit");
end

-- ********************************************************************
-- * regainListFrame:SortRegainData(data, cutoff)                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> regainListFrame: the list frame whose regain list is sorted.  *
-- * >> data: the regain list to treat.                               *
-- * >> cutoff: the limit of entities in the regain list.             *
-- ********************************************************************
-- * Sorts a regain list in decreasing order.                         *
-- ********************************************************************
local function SortRegainData(regainListFrame, data, cutoff)
    local i, ii, redo, count;
    i = 0;
    redo = nil;
    count = 0;
    data.number = data.number or 0;

    repeat
        count = count + 1;
        if not ( redo ) then
            i = i + 1;
        end
        redo = nil;

        selfName = data["name"..i];
        selfGUID = data["guid"..i];
        selfThreat = data["threat"..i] or 0;
        selfAggro = data["aggro"..i];
        selfRelative = data["relative"..i];

        for ii = i+1, data.number do
            if ( selfThreat < (data["threat"..ii] or 0) ) then
                data["name"..i] = data["name"..ii];
                data["guid"..i] = data["guid"..ii];
                data["threat"..i] = data["threat"..ii];
                data["aggro"..i] = data["aggro"..ii];
                data["relative"..i] = data["relative"..ii];

                data["name"..ii] = selfName;
                data["guid"..ii] = selfGUID;
                data["threat"..ii] = selfThreat;
                data["aggro"..ii] = selfAggro;
                data["relative"..ii] = selfRelative;

                redo = 1;
                break;
            end
        end
    until ( i >= data.number ) or ( count > 100 ); -- count>100 is here to prevent freezing :o)

    data.number = min(cutoff, data.number);
end

-- --------------------------------------------------------------------
-- **                             Handlers                           **
-- --------------------------------------------------------------------

function DTM_RegainListFrame_OnLoad(self)
    self.listType = "REGAINLIST";

    -- Sets frames variables.
    self.regainData = {};

    -- Binds methods to the new frame.
    self.Display = Display;
    self.Reset = Reset;
    self.ApplySkin = ApplySkin;
    -- + Destroy inherited from common list.
    -- + GetStatus inherited from common list.
    -- + AdjustWidth inherited from common list.

    -- Private methods
    self.CheckUnitValidity = CheckUnitValidity;
    self.SortRegainData = SortRegainData;

    -- Create regain rows. They do not behave the same way as threat rows.
    self.row = {};
    for i=1, MAX_ROWS do
        self.row[i] = CreateFrame("StatusBar", self:GetName().."_Row"..i, self, "DTM_RegainListFrame_RowTemplate");
        self.row[i].id = i;
    end

    -- Also set properties common to all lists.
    DTM_CommonListFrame_OnLoad(self);
end

function DTM_RegainListFrame_OnUpdate(self, elapsed)
    if ( self.status == "UNUSED" ) then
        self:Hide();
        return;
    end

    -- Default height
    self.targetHeight = 48;

    -- ***** Manage the frame status & main properties *****

    local unit = self.unit;
    local valid, statusText = self:CheckUnitValidity();
    local r, i, ii, k, v;

    if ( self.status == "BOOTING" ) then
        self.alpha = min(1.00, self.alpha + elapsed / (INOUT_DELAY * self.fadeCoeff));

        if ( self.alpha >= 1.00 ) then
            self.status = "READY";

            self.standbyFrame:Show();
            UIFrameFadeIn(self.standbyFrame, FADE_DELAY * self.fadeCoeff, 0.00, 1.00);
        end
    end

    if ( self.status == "READY" ) then
        -- If the unit ID tied to the overview list becomes valid (that is, existant), start monitoring its regain list.

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
                self.unitInfoString = format(DTM_Localise("regainUnitInfo"), self.unitName);
                self.headerRow.unitInfo:SetText( self.unitInfoString );

                self.headerRow.unitInfo:ClearAllPoints();
                self.headerRow.unitInfo:SetPoint("TOP", self.headerRow, "TOP", 0, -8);
                self.headerRow.unitInfo:SetHeight(16);
                self.headerRow.name:Show();
                self.headerRow.threat:Show();
                self.headerRow.relative:Show();
            end
        end
    end

    -- By default makes all bars going to disapparear, unless we flag them below they're still used.
    for r=1, MAX_ROWS do
        self.row[r].stillUsed = nil;
    end

    if ( self.status == "RUNNING" ) then
        -- Regain list working.

        if ( self.headerRow:GetAlpha() >= 1.00 ) then
            if not ( valid ) or ( UnitName(unit) ~= self.unitName ) or ( UnitGUID(unit) ~= self.unitGUID ) then
                -- Unit became invalid in between.
                self.status = "CLEARING";

                UIFrameFadeOut(self.headerRow, FADE_DELAY * self.fadeCoeff, 1.00, 0.00);
          else
                -- Build regain list from API.

                for k, v in pairs(self.regainData) do
                    self.regainData[k] = nil;
                end

                local size, index;
                local enemyName, enemyGUID, myThreat, haveAggro;
                local aggroName, aggroGUID, aggroThreat;
                local found;

                size = DTM_UnitPresenceListSize(unit);
                index = 0;
                for i=1, size do
                    enemyName, enemyGUID, myThreat, _, haveAggro = DTM_UnitPresenceList(unit, i);
                    aggroName, aggroGUID = DTM_UnitThreatGetAggro(enemyGUID);

                    index = index + 1;

                    self.regainData["name"..index] = enemyName;
                    self.regainData["guid"..index] = enemyGUID;
                    self.regainData["aggro"..index] = haveAggro;

                    if ( haveAggro ) then
                        -- 1st case: we are holding the mob attention. We display "+X" on the threat column which shows the advance we have over
                        -- the second highest threat target.

                        local enemyListSize = DTM_UnitThreatListSize(enemyGUID);
                        local name, guid, threat;
                        local secName, secGUID, secThreat = '-', '-', 0;
                        for ii=1, enemyListSize do
                            name, guid, threat = DTM_UnitThreatList(enemyGUID, ii);
                            if ( guid ~= aggroGUID ) and ( threat > secThreat ) then
                                secName = name;
                                secGUID = guid;
                                secThreat = threat;
                            end
                        end

                        local regainFactor = 1.3;
                        if ( UnitIsUnit(unit, "player") ) then
                            -- Get the distance from the tank to the potential apply that could pull aggro. It should be quite the same as the distance between mob<~>apply.
                            regainFactor = DTM_Self_GetAggroGainThreshold(DTM_GetUnitPointer(secGUID));
                        end
                        local regainThreat = myThreat * regainFactor;

                        self.regainData["threat"..index] = max(0, regainThreat - secThreat);
                        self.regainData["relative"..index] = secName;
                  else
                        -- 2nd case: we are NOT holding the mob attention. We display "-X" on the threat column which shows the threat we have to build
                        -- before grabbing aggro.

                        local aggroThreat = 0;
                        if ( aggroGUID ) then
                            aggroThreat = DTM_UnitThreat(enemyGUID, aggroGUID);
                        end

                        local regainFactor = 1.3;
                        if ( UnitIsUnit(unit, "player") ) then
                            regainFactor = DTM_Self_GetAggroGainThreshold(DTM_GetUnitPointer(enemyGUID));
                        end
                        local regainThreat = aggroThreat * regainFactor;

                        self.regainData["threat"..index] = min(0, myThreat - regainThreat);
                        self.regainData["relative"..index] = self.unitName;
                    end
                end

                self.regainData.number = index; -- should be equal to size.

                -- Re-order the regain list :)
                self:SortRegainData(self.regainData, min(size, self.usedRows, MAX_ROWS));

                -- OK, let's update the rows appropriately.
                -- If a given entity in the list is not displayed, allocate a new row.

                self.targetHeight = 48 + 20 * self.regainData.number;

                for i=1, self.regainData.number do
                    found = nil;

                    name = self.regainData["name"..i];
                    guid = self.regainData["guid"..i];
                    threat = self.regainData["threat"..i];
                    hasAggro = self.regainData["aggro"..i];
                    relative = self.regainData["relative"..i];

                    -- Checks if a row is already displaying the current browsed entity threat.
                    for r=1, MAX_ROWS do
                        if ( self.row[r].status ~= "UNUSED" ) and ( self.row[r].guid == guid ) then
                            self.row[r]:Update(name, guid, threat, nil, i, hasAggro, relative);
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
                                    self.row[r]:Activate(name, guid, threat, nil, i, hasAggro, relative);
                                    break;
                                end
                            end
                        end
                    end
                end
            end

            -- Update the symbol. Remove it if the regain list is shutting down.
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