local activeModule = "GUI Threat list";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local MAX_ROWS = 40;

local CRYSTAL_ANIMATION_INTERVAL = 0.067;

local INOUT_DELAY = 0.500;
local FADE_DELAY = 0.300;

-- Animations duration

local ANIMATION_LENGTH_MOVEUP = 0.400;
local ANIMATION_LENGTH_SWAP = 0.400;

local HEALTHBAR_HOLDTIME = 1.500;
local HEALTHBAR_PROGRESSIONSPEED = 0.350; -- per second.

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_GUI_GetMaxThreatListRows()                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Returns the max number of rows a threat list can handle at once. *
-- ********************************************************************
function DTM_GUI_GetMaxThreatListRows()
    return MAX_ROWS;
end

-- --------------------------------------------------------------------
-- **                            Methods                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * threatListFrame:Display()                                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> threatListFrame: the threat list frame to operate on.         *
-- ********************************************************************
-- * Starts displaying a threat list frame.                           *
-- ********************************************************************
local function Display(threatListFrame)
    if ( DTM_IsGUIRunning() ~= 1 and threatListFrame.unit ~= "test" ) then
        return;
    end
    if not ( threatListFrame:IsShown() ) then
        threatListFrame.alpha = 0.00;
        threatListFrame.height = 48;
        threatListFrame.status = "BOOTING";

        threatListFrame:Show();

        threatListFrame.standbyFrame:Hide();
        threatListFrame.headerRow:Hide();

        threatListFrame.crystalAlpha = 0.00;
        threatListFrame.crystalParent = nil;

        -- Reapply the skin used.
        threatListFrame:ApplySkin();
    end
end

-- ********************************************************************
-- * threatListFrame:Reset()                                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> threatListFrame: the threat list frame to operate on.         *
-- ********************************************************************
-- * Instantly hides a threat list frame.                             *
-- ********************************************************************
local function Reset(threatListFrame)
    threatListFrame:Hide();

    threatListFrame.standbyFrame:Hide();
    threatListFrame.headerRow:Hide();
    for i=1, MAX_ROWS do
        threatListFrame.row[i]:Hide();
        threatListFrame.row[i].status = "UNUSED";
    end
end

-- ********************************************************************
-- * threatListFrame:ApplySkin()                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> listFrame: the threat list frame to operate on.               *
-- ********************************************************************
-- * Apply the currently selected skin to the given threat list frame.*
-- ********************************************************************
local function ApplySkin(threatListFrame)
    threatListFrame:ApplyCommonSkin();

    local cfg = DTM_GetCurrentSkinSetting;

    threatListFrame.barWidth = cfg("ThreatList", "Length");
    threatListFrame.usedRows = cfg("ThreatList", "Rows");
    threatListFrame.isSmooth = cfg("Bars", "Smooth");
    threatListFrame.alwaysDisplaySelf = cfg("ThreatList", "AlwaysDisplaySelf");
    threatListFrame.filter = cfg("ThreatList", "Filter");
    threatListFrame.displayAggroGain = cfg("ThreatList", "DisplayAggroGain");
    threatListFrame.onlyHostile = cfg("ThreatList", "OnlyHostile");
    threatListFrame.raiseAggroToTop = cfg("ThreatList", "RaiseAggroToTop");
    threatListFrame.displayLevel = cfg("ThreatList", "DisplayLevel");
    threatListFrame.displayHealth = cfg("ThreatList", "DisplayHealth");

    -- Handle the cursor (the crystal in the original skin).
    threatListFrame.cursorTexture = cfg("ThreatList", "CursorTexture");
    if ( #threatListFrame.cursorTexture > 0 ) and ( string.lower(threatListFrame.cursorTexture) ~= "crystal" ) then
        threatListFrame.crystalTexture:SetTexture(DTM_Resources_GetAbsolutePath("GFX", threatListFrame.cursorTexture));
        threatListFrame.crystalTexture:SetTexCoord(0, 1, 0, 1);
        threatListFrame.crystalFrameWidget:SetWidth(16);
        threatListFrame.crystalFrameWidget:SetHeight(16);
        threatListFrame.crystalAnimate = false;
  else
        threatListFrame.crystalTexture:SetTexture("Interface\\AddOns\\DiamondThreatMeter\\gfx\\Crystal");
        threatListFrame.crystalTexture:SetTexCoord(0, 1, 0, 8/64);
        threatListFrame.crystalFrameWidget:SetWidth(16);
        threatListFrame.crystalFrameWidget:SetHeight(8);
        threatListFrame.crystalAnimate = true;
    end

    -- Now we know the width of bars for this list type, apply the width info.
    threatListFrame:AdjustWidth();

    -- Apply the column config on the header row.
    DTM_ApplyColumnSetting(threatListFrame.headerRow.name,          threatListFrame.headerRow, cfg("Columns", "Name"),       1);
    DTM_ApplyColumnSetting(threatListFrame.headerRow.threat,        threatListFrame.headerRow, cfg("Columns", "Threat"),     1);
    DTM_ApplyColumnSetting(threatListFrame.headerRow.tps,           threatListFrame.headerRow, cfg("Columns", "TPS"),        1);
    DTM_ApplyColumnSetting(threatListFrame.headerRow.threatPercent, threatListFrame.headerRow, cfg("Columns", "Percentage"), 1);

    for i=1, MAX_ROWS do
        threatListFrame.row[i]:ApplySkin();
    end
end

-- See commonList.lua for additionnal methods that are common to all lists.

-- --------------------------------------------------------------------
-- **                        Private methods                         **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * threatListFrame:CheckUnitValidity(unit)                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> threatListFrame: the threat list frame checked.               *
-- * >> unit: the UID checked.                                        *
-- ********************************************************************
-- * Check if a given unit is valid to be displayed in the given      *
-- * threat list frame. Returns flag and a status message.            *
-- ********************************************************************
local function CheckUnitValidity(threatListFrame, unit)
    if ( unit == "test" ) then
        -- Special case, "test" bound lists are always valid.
        return 1, DTM_Localise("testList");
    end

    local standbyTextBaseKey = threatListFrame.standbyBaseKey or "standbyTarget";

    if ( UnitExists(unit) ) and not ( UnitIsPlayer(unit) ) then
        local matchReaction = 1;
        if ( threatListFrame.onlyHostile == 1 ) and not ( UnitCanAttack(unit, "player") ) then matchReaction = nil; end

        if ( matchReaction ) then
            if not ( UnitIsDeadOrGhost(unit) ) then
                return 1, DTM_Localise( standbyTextBaseKey.."Opening" );
           else
                return nil, DTM_Localise( standbyTextBaseKey.."Dead" );
            end
       else
            return nil, DTM_Localise( standbyTextBaseKey.."WrongReaction" );
        end
    end

    return nil, DTM_Localise( standbyTextBaseKey );
end

-- ********************************************************************
-- * threatListFrame:SortThreatData(data, cutoff, alwaysShowGUID)     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> threatListFrame: the list frame whose threat list is sorted.  *
-- * >> data: the table containing a threat list.                     *
-- * >> cutoff: the limit of entities in threat list.                 *
-- * >> alwaysShowGUID: if provided, the GUID of an entity you'd like *
-- * to be always shown on the list, whatever its position is.        *
-- ********************************************************************
-- * Sorts a threat list in DTM's fashion. =D                         *
-- ********************************************************************
local function SortThreatData(threatListFrame, data, cutoff, alwaysShowGUID)
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

        selfName = data["name"..i] or "???";
        selfGUID = data["guid"..i] or "???";
        selfThreat = data["threat"..i] or 0;
        selfClass = data["class"..i] or nil;
        selfFlag = data["flag"..i] or nil;
        selfTPS = data["tps"..i] or 0;

        selfHasAggro = ( selfGUID == data.aggroGUID );

        for ii = i+1, data.number do
            local exchange = false;
            if ( selfThreat < (data["threat"..ii] or 0) ) then
                exchange = true;
            end
            if ( threatListFrame.raiseAggroToTop == 1 ) then
                if ( data["guid"..ii] == data.aggroGUID ) then
                    exchange = true;
                end
                if ( selfHasAggro ) then
                    exchange = false;
                end
            end
            if ( exchange ) then
                data["name"..i] = data["name"..ii];
                data["guid"..i] = data["guid"..ii];
                data["threat"..i] = data["threat"..ii];
                data["class"..i] = data["class"..ii];
                data["flag"..i] = data["flag"..ii];
                data["tps"..i] = data["tps"..ii];

                data["name"..ii] = selfName;
                data["guid"..ii] = selfGUID;
                data["threat"..ii] = selfThreat;
                data["class"..ii] = selfClass;
                data["flag"..ii] = selfFlag;
                data["tps"..ii] = selfTPS;

                redo = 1;
                break;
            end
        end
    until ( i >= data.number ) or ( count > 100 ); -- count>100 is here to prevent freezing :o)

    data.number = min(cutoff, data.number);

    -- Is there an entity to always display on the list that is below the visible part of the list ?

    if ( alwaysShowGUID ) and ( data.number >= 2 ) then
        local e;
        for e=data.number+1, i do
            if ( data["guid"..e] == alwaysShowGUID ) then
                -- Got it.
                while ( e > data.number ) do
                    -- Move it upward till it becomes visible, swapping with everything on its way.

                    selfName = data["name"..e] or "???";
                    selfGUID = data["guid"..e] or "???";
                    selfThreat = data["threat"..e] or 0;
                    selfClass = data["class"..e] or nil;
                    selfFlag = data["flag"..e] or nil;
                    selfTPS = data["tps"..e] or 0;

                    e = e - 1;

                    data["name"..(e+1)] = data["name"..e];
                    data["guid"..(e+1)] = data["guid"..e];
                    data["threat"..(e+1)] = data["threat"..e];
                    data["class"..(e+1)] = data["class"..e];
                    data["flag"..(e+1)] = data["flag"..e];
                    data["tps"..(e+1)] = data["tps"..e];

                    data["name"..e] = selfName;
                    data["guid"..e] = selfGUID;
                    data["threat"..e] =  selfThreat;
                    data["class"..e] = selfClass;
                    data["flag"..e] = selfFlag;
                    data["tps"..e] = selfTPS;
                end

                break;
            end
        end
    end
end

-- --------------------------------------------------------------------
-- **                             Handlers                           **
-- --------------------------------------------------------------------

function DTM_ThreatListFrame_OnLoad(self)
    self.listType = "THREATLIST";

    -- Sets frames variables.
    self.threatData = {};
    self.positionUsed = {};

    -- Binds methods to the new frame.
    self.Display = Display;
    self.Reset = Reset;
    self.ApplySkin = ApplySkin;
    -- + Destroy inherited from common list.
    -- + GetStatus inherited from common list.
    -- + AdjustWidth inherited from common list.

    -- Private methods
    self.CheckUnitValidity = CheckUnitValidity;
    self.SortThreatData = SortThreatData;

    -- Grab child frames.
    self.standbyFrame = getglobal(self:GetName().."_StandbyFrame");
    self.headerRow = getglobal(self:GetName().."_HeaderRow");
    self.healthBar = getglobal(self:GetName().."_HeaderRow_HealthBar");
    self.healthVar = getglobal(self:GetName().."_HeaderRow_HealthBarVariation");

    -- Create threat rows.
    self.row = {};
    for i=1, MAX_ROWS do
        self.row[i] = CreateFrame("StatusBar", self:GetName().."_Row"..i, self, "DTM_ThreatListFrame_RowTemplate");
        self.row[i].id = i;
    end

    -- Setup crystal.
    self.crystalFrameWidget = getglobal(self:GetName().."_CrystalFrame");
    self.crystalTexture = getglobal(self:GetName().."_CrystalFrame_Texture");
    self.crystalFrame = 0;
    self.crystalTimer = 0.000;
    self.crystalAnimate = false;
    self.crystalAlpha = 0.00;
    self.crystalParent = nil;

    -- Setup health bar
    self.healthBar:ClearAllPoints();
    self.healthBar:SetPoint("TOP", self.headerRow.unitInfo, "BOTTOM", 0, 0);
    self.healthBar:SetMinMaxValues(0, 1);
    self.healthBar:SetValue(1);
    self.healthVar:SetMinMaxValues(0, 1);
    self.healthVar:SetValue(0);

    -- Also set properties common to all lists.
    DTM_CommonListFrame_OnLoad(self);
end

function DTM_ThreatListFrame_OnUpdate(self, elapsed)
    if ( self.status == "UNUSED" ) then
        self:Hide();
        return;
    end

    -- Default height
    self.targetHeight = 48;

    -- ***** Manage the frame status & main properties *****

    local unit = self.unit;
    local valid, statusText = self:CheckUnitValidity(unit);
    if not ( valid ) and ( self.altUnit ) and ( UnitIsFriend("player", unit) ) then
        local altValid, altStatusText = self:CheckUnitValidity(self.altUnit);
        if ( altValid ) then
            -- Redirect to the alternate unit.
            valid = 1;
            unit = self.altUnit;
            statusText = altStatusText;
        end
    end

    if ( self.status == "BOOTING" ) then
        self.alpha = min(1.00, self.alpha + elapsed / (INOUT_DELAY * self.fadeCoeff));

        if ( self.alpha >= 1.00 ) then
            self.needReset = nil;
            self.status = "READY";

            self.standbyFrame:Show();
            UIFrameFadeIn(self.standbyFrame, FADE_DELAY * self.fadeCoeff, 0.00, 1.00);
        end
    end

    if ( self.status == "READY" ) then
        -- If the unit ID tied to the threat list becomes valid (that is, existant and a NPC), start monitoring the threat list.

        if ( self.standbyFrame:GetAlpha() >= 1.00 ) and ( valid ) then
            if ( unit == "test" ) then
                -- Test lists behaviour.
                self.activeUnit = unit;
                self.unitGUID = -1;
                self.unitName = DTM_Localise("test");
                self.unitIsBoss = 1;
                self.unitLevel = -1;
                self.noThreatList = nil;
                self.useWarning = nil;
                self.aggroDistance = "NONE";
          else
                -- Normal unit behaviour.
                self.activeUnit = unit;
                self.unitGUID = UnitGUID(unit);
                self.unitName = UnitName(unit);
                self.unitIsBoss = ( UnitClassification(unit) == "worldboss" );
                self.unitLevel = UnitLevel(unit);
                self.useWarning = DTM_GUI_IsWarningApplicable(UnitClassification(unit), self.unitLevel);
                self.noThreatList = nil;

                -- Check if the NPC has special threat list flags.
                local noThreatList, warningOveride, aggroDelay, aggroDistance = DTM_UnitThreatFlags(unit);
                self.aggroDistance = aggroDistance;
                if ( noThreatList == 1 ) then self.noThreatList = 1; end
                if ( warningOveride == -1 ) then self.useWarning = nil; end
                if ( warningOveride == 1 ) then self.useWarning = 1; end
            end

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
                self.activeUnit = nil;
                self.status = "READY";

                self.standbyFrame:Show();
                UIFrameFadeIn(self.standbyFrame, FADE_DELAY * self.fadeCoeff, 0.00, 1.00);
          else
                -- OK, we can start displaying threat list.
                self.status = "RUNNING";

                self.headerRow:Show();

                UIFrameFadeIn(self.headerRow, FADE_DELAY * self.fadeCoeff, 0.00, 1.00);

                -- Prepare the unit info text.
                local levelString = "??";
                local flagString = "";
                if ( self.unitLevel ) and ( self.unitLevel >= 0 ) then levelString = tostring(self.unitLevel); end
                if ( self.unitIsBoss ) then flagString = "("..BOSS..")"; end
                if ( self.displayLevel == 1 ) then
                    self.unitInfoString = format( DTM_Localise("unitInfo") , self.unitName , levelString , flagString );
              else
                    self.unitInfoString = format( DTM_Localise("unitInfoLight") , self.unitName , flagString );
                end

                -- Checks if the NPC uses the no threat list flag.

                if ( self.noThreatList ) then
                    -- Append no threat list notification.
                    self.unitInfoString = self.unitInfoString.."\n"..DTM_Localise("noThreatList");
                    self.headerRow.unitInfo:ClearAllPoints();
                    self.headerRow.unitInfo:SetPoint("CENTER", self.headerRow, "CENTER", 0, 0);
                    self.headerRow.unitInfo:SetHeight(32);
                    self.headerRow.name:Hide();
                    self.headerRow.threat:Hide();
                    self.headerRow.tps:Hide();
                    self.headerRow.threatPercent:Hide();
              else
                    self.headerRow.unitInfo:ClearAllPoints();
                    self.headerRow.unitInfo:SetPoint("TOP", self.headerRow, "TOP", 0, -8);
                    self.headerRow.unitInfo:SetHeight(16);
                    self.headerRow.name:Show();
                    self.headerRow.threat:Show();
                    self.headerRow.tps:Show();
                    self.headerRow.threatPercent:Show();
                end

                self.headerRow.unitInfo:SetText( self.unitInfoString );

                if ( self.displayHealth == 1 ) then
                    -- Initialize the health bar
                    self.healthBar:Show();
                    self.healthVar.currentHealth = nil;
                    self.healthVar.oldHealth = nil;
                    self.healthVar.position = nil;
                    self.healthVar.holdTime = 0;
              else
                    self.healthBar:Hide();
                end
            end
        end
    end

    -- By default makes all bars going to disapparear, unless we flag them below they're still used.
    for r=1, MAX_ROWS do
        self.row[r].stillUsed = nil;
    end

    if ( self.status == "RUNNING" ) then
        -- Threat list working.

        if ( self.headerRow:GetAlpha() >= 1.00 ) then
            local mismatchingUnit = ( UnitName(unit) ~= self.unitName ) or ( UnitGUID(unit) ~= self.unitGUID );

            if not ( valid ) or ( mismatchingUnit and unit ~= "test" ) or ( self.needReset ) then
                -- Unit became invalid in between.
                self.activeUnit = nil;
                self.status = "CLEARING";

                -- Clear the reset flag so as not to loop the reset request.
                self.needReset = nil;

                UIFrameFadeOut(self.headerRow, FADE_DELAY * self.fadeCoeff, 1.00, 0.00);

        elseif not ( self.noThreatList ) then
                -- Mob uses a threat list, as usual.

                -- Build threat list from API.

                for k, v in pairs(self.threatData) do
                    self.threatData[k] = nil;
                end

                local matchFilter;
                local name, guid, threat, class, flag, tps;
                local alwaysDisplayedGUID = nil;

                if ( self.alwaysDisplaySelf == 1 ) then
                    alwaysDisplayedGUID = UnitGUID("player");
                end

                size = DTM_UnitThreatListSize(unit);
                index = 0;
                for i=1, size do
                    name, guid, threat, class, flag, tps = DTM_UnitThreatList(unit, i);

                    matchFilter = 1;
                    if ( ( self.filter == "PARTY_ONLY_PLAYERS" ) or ( self.filter == "PARTY" ) ) and not ( flag ) then
                        matchFilter = nil;
                    end
                    if ( self.filter == "PARTY_ONLY_PLAYERS" ) and not ( class ) then
                        matchFilter = nil;
                    end

                    if ( matchFilter ) then
                        index = index + 1;

                        self.threatData["name"..index] = name;
                        self.threatData["guid"..index] = guid;
                        self.threatData["threat"..index] = threat;
                        self.threatData["class"..index] = class;
                        self.threatData["flag"..index] = flag;
                        self.threatData["tps"..index] = tps;
                    end
                end

                -- Get the aggro threat if there is one.
                self.threatData.aggroName, self.threatData.aggroGUID = DTM_UnitThreatGetAggro(unit);
                self.threatData.aggroThreat = nil;
                if ( self.threatData.aggroGUID ) then
                    for i=1, size do
                        name, guid, threat = DTM_UnitThreatList(unit, i);
                        if ( guid == self.threatData.aggroGUID ) then
                            self.threatData.aggroThreat = threat;
                            break;
                        end
                    end
                end

                -- In case of smooth bar display, do not use the harsh current aggro threat value, but instead find the row that is flagged as
                -- having aggro and get the current displayed threat of that bar as aggroThreat.

                if ( self.isSmooth == 1 ) then
                    for r=1, MAX_ROWS do
                        if ( self.row[r].status ~= "UNUSED" ) and ( self.row[r].guid == self.threatData.aggroGUID ) then
                            self.threatData.aggroThreat = self.row[r].displayThreat;
                            break;
                        end
                    end
                end

                -- Do we also show aggro regain threshold ?
                if ( self.threatData.aggroThreat and self.threatData.aggroGUID ) and ( self.displayAggroGain == 1 ) then
                    if ( self.threatData.aggroGUID ~= UnitGUID("player") ) then
                        index = index + 1;
                        self.threatData["name"..index] = DTM_Localise("aggroRegain");
                        self.threatData["guid"..index] = -1;
                        self.threatData["threat"..index] = self.threatData.aggroThreat * DTM_Self_GetAggroGainThreshold(unit);
                        self.threatData["class"..index] = "AGGRO_THRESHOLD";
                        self.threatData["tps"..index] = "-";
                    end
                end

                self.threatData.number = index;

                self:SortThreatData(self.threatData, min(MAX_ROWS, self.usedRows), alwaysDisplayedGUID);

                -- Get the row positions that are empty.

                local i, r, p;

                for r=1, MAX_ROWS do
                    self.positionUsed[r] = nil;
                end
                for r=1, MAX_ROWS do
                    if ( self.row[r].status ~= "UNUSED" ) then
                        self.positionUsed[self.row[r].position] = self.row[r];
                    end
                end

                -- Let's determinate now the rows that should get before/after the others.

                local row;
                local positionUsageTable = self.positionUsed;

                for r=1, MAX_ROWS do
                    row = positionUsageTable[r]; -- self.row[r];

                    if ( row ) and ( row.status == "RUNNING" ) and ( row.position ) and ( row.targetPosition ) then
                        -- Interface with position status section.

                        if ( row.position > 1 ) and ( row.positionStatus == "STANDBY" ) then
                            if ( row.position ~= row.targetPosition ) then
                                local swapFrame = positionUsageTable[row.targetPosition];
                                if ( swapFrame ) then
                                    -- Something in the way. Do we swap with it ?
                                    if ( swapFrame.positionStatus == "STANDBY" ) then -- and ( swapFrame.displayThreat < self.displayThreat ) then
                                        swapFrame.position = row.position;
                                        positionUsageTable[row.position] = swapFrame;

                                        row.position = row.targetPosition;
                                        positionUsageTable[row.targetPosition] = row;

                                        row.positionStatus = "SWAP";
                                        row.movementStartX, row.movementStartY = row:GetCenter();
                                        row.movementStartTimer = ANIMATION_LENGTH_SWAP * self.sortCoeff;
                                        row.movementTimer = row.movementStartTimer;

                                        swapFrame.positionStatus = "SWAP";
                                        swapFrame.movementStartX, swapFrame.movementStartY = swapFrame:GetCenter();
                                        swapFrame.movementStartTimer = ANIMATION_LENGTH_SWAP * self.sortCoeff;
                                        swapFrame.movementTimer = swapFrame.movementStartTimer;
                                    end
                               else
                                    -- Do we scroll or do a swap anim ?
                                    if ( math.abs( row.targetPosition - row.position ) == 1 ) then
                                        row.positionStatus = "MOVEUP";
                                        row.movementStartX, row.movementStartY = row:GetCenter();
                                        row.movementStartTimer = ANIMATION_LENGTH_MOVEUP * self.sortCoeff;
                                        row.movementTimer = row.movementStartTimer;
                                  else
                                        row.positionStatus = "SWAP";
                                        row.movementStartX, row.movementStartY = row:GetCenter();
                                        row.movementStartTimer = ANIMATION_LENGTH_SWAP * self.sortCoeff;
                                        row.movementTimer = row.movementStartTimer;
                                    end

                                    positionUsageTable[row.position] = nil;
                                    row.position = row.targetPosition;
                                    positionUsageTable[row.position] = self;
                                end
                            end
                        end
                    end
                end

                -- OK, let's update the rows appropriately.
                -- If a given entity in the list is not displayed, allocate a new row.

                self.targetHeight = 48 + 20 * self.threatData.number;

                local found;

                for i=1, self.threatData.number do
                    found = nil;

                    name = self.threatData["name"..i];
                    guid = self.threatData["guid"..i];
                    threat = self.threatData["threat"..i];
                    class = self.threatData["class"..i];
                    tps = self.threatData["tps"..i];

                    -- Checks if a row is already displaying the current browsed entity threat.
                    for r=1, MAX_ROWS do
                        if ( self.row[r].status ~= "UNUSED" ) and ( self.row[r].guid == guid ) then
                            self.row[r]:Update(name, guid, threat, class, self.threatData.aggroThreat, i, (self.threatData.aggroGUID==guid), tps);
                            found = 1;
                            break;
                        end
                    end

                    if not ( found ) then
                        -- No row does. Allocates a new row.
                        for r=1, MAX_ROWS do
                            -- Finds an unused row that will display the threat info.
                            if ( self.row[r].status == "UNUSED" ) then
                                -- Find an empty slot to start introducing the row.
                                for p=1, MAX_ROWS do
                                    -- Empty slot is O.K, but is the frame tall enough ?
                                    if not ( self.positionUsed[p] ) and ( (self.height-48) >= (20*p) ) then
                                        -- Slot found.
                                        self.row[r]:Activate(name, guid, threat, class, self.threatData.aggroThreat, p, (self.threatData.aggroGUID==guid), tps);
                                        self.positionUsed[p] = self.row[r];
                                        found = 1;
                                        break;
                                    end
                                end
                            end
                            if ( found ) then break; end
                        end
                    end
                end
          else
                -- Unit uses no threat list whatsoever.
                self.targetHeight = 48;
            end
        end

        -- Update the symbol. Remove it if the threat list is shutting down.
        local symbol, symbolString = 0, '';
        symbol = DTM_SymbolsBuffer_Get(self.unitGUID);
        if ( symbol > 0 ) and ( self.status == "RUNNING" ) then
            symbolString = format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d.blp:0|t ", symbol);
        end   
        self.headerRow.unitInfo:SetText( symbolString .. self.unitInfoString );

        -- Update the health bar nicely.
        if ( valid and unit and self.healthBar:IsShown() and self.status == "RUNNING" ) then
            -- Resize regularly
            self.healthBar:SetWidth(self.headerRow.unitInfo:GetStringWidth());
            self.healthBar:SetHeight(2);

            -- Health recalculation
            local currentHealth = min(1, max(0, UnitHealth(unit) / UnitHealthMax(unit)));
            if ( unit == "test" ) then currentHealth = 0.60; end
            self.healthBar:SetValue(currentHealth);

            -- Update of the variation bar
            local varBar = self.healthVar;

            if ( varBar.oldHealth ~= currentHealth ) then
                if ( varBar.position == varBar.currentHealth ) or ( not varBar.position ) then
                    varBar.holdTime = HEALTHBAR_HOLDTIME;
                end
                varBar.currentHealth = currentHealth;
                if ( not varBar.position ) then
                    varBar.position = varBar.currentHealth;
                end
            end
            varBar.oldHealth = currentHealth;

            if ( varBar.position and varBar.currentHealth and varBar.position ~= varBar.currentHealth ) then
                if ( varBar.holdTime > 0 ) then
                    varBar.holdTime = max(0, varBar.holdTime - elapsed);
              else
                    if ( varBar.position > varBar.currentHealth ) then
                        varBar.position = max(varBar.currentHealth, varBar.position - HEALTHBAR_PROGRESSIONSPEED * elapsed);
                  else
                        varBar.position = min(varBar.currentHealth, varBar.position + HEALTHBAR_PROGRESSIONSPEED * elapsed);
                    end
                end

                local delta = varBar.currentHealth - varBar.position;
                if ( delta < 0 ) then
                    varBar:ClearAllPoints();
                    varBar:SetPoint("LEFT", self.healthBar, "LEFT", varBar.currentHealth * self.healthBar:GetWidth(), 0);
                    varBar:SetWidth(-delta * self.healthBar:GetWidth());
                    varBar:SetHeight(2);
                    varBar:SetValue(1);
                    varBar:SetStatusBarColor(1, 0, 0);
              elseif ( delta > 0 ) then
                    varBar:ClearAllPoints();
                    varBar:SetPoint("RIGHT", self.healthBar, "LEFT", varBar.currentHealth * self.healthBar:GetWidth(), 0);
                    varBar:SetWidth(delta * self.healthBar:GetWidth());
                    varBar:SetHeight(2);
                    varBar:SetValue(1);
                    varBar:SetStatusBarColor(1, 1, 0);
               else
                    varBar:SetValue(0);
                end
          else
                varBar:SetValue(0);
            end
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

    -- ***** Handle crystal *****

    if ( self.crystalParent ) then
        if not ( self.crystalParent.status ) or ( self.crystalParent.status ~= "RUNNING" ) then
            self.crystalParent = nil;
        end
    end

    if ( self.crystalAnimate ) then
        self.crystalTimer = self.crystalTimer - elapsed;
        while ( self.crystalTimer <= 0.00 ) do
            self.crystalTimer = self.crystalTimer + CRYSTAL_ANIMATION_INTERVAL;
            self.crystalFrame = math.fmod(self.crystalFrame + 1, 8);

            self.crystalTexture:SetTexCoord(0.00, 1.00, 8/64 * self.crystalFrame, 8/64 * (self.crystalFrame+0.99));
        end
    end

    local offset = cos( GetTime() * 540 ) * 4;
    if not ( self.crystalParent ) then
        self.crystalAlpha = max(0.00, self.crystalAlpha - elapsed / 0.50);
  else
        self.crystalAlpha = min(1.00, self.crystalAlpha + elapsed / 0.50);
        self.crystalFrameWidget:ClearAllPoints();
        self.crystalFrameWidget:SetPoint("RIGHT", self.crystalParent, "LEFT", 6 + offset, 0);
        self.crystalFrameWidget:SetScale( self.crystalParent:GetScale() );
        self.crystalFrameWidget:SetFrameLevel( self.crystalParent:GetFrameLevel() + 1 );
    end
    self.crystalFrameWidget:SetAlpha(self.crystalAlpha);
    self.crystalFrameWidget:Show();

    -- ***** Common properties *****

    DTM_CommonListFrame_OnUpdate(self, elapsed);
end