local activeModule = "GUI Threat list row";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

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

local YELLOW_THRESHOLD = 100.0;
local RED_THRESHOLD = 110.0;

-- Animations duration

local FADE_DURATION = 0.250;

local ANIMATION_LENGTH_WARNING_START = 0.500;
local ANIMATION_LENGTH_WARNING_END = 0.500;

local LIGHTING_ANIMATION_DELAY = 3.000;
local LIGHTING_ANIMATION_DURATION = 0.500;

-- --------------------------------------------------------------------
-- **                            Methods                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * row:Activate(name, guid, threat, class, aggroThreat, ...)        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> row: the threat list row to operate on.                       *
-- * >> ...: the remaining parameters.                                *
-- ********************************************************************
-- * Starts a threat list row display.                                *
-- ********************************************************************
local function Activate(row, name, guid, threat, class, aggroThreat, position, hasAggro, tps)
    if ( row.status == "UNUSED" ) then
        row.status = "OPENING";
        row.positionStatus = "STANDBY";
        row.movementStartX = nil;
        row.movementStartY = nil;
        row.movementStartTimer = nil;
        row.movementTimer = nil;
        row.alpha = 0.00;
        row.warningEnabled = nil;

        row.name = name;
        row.guid = guid;
        row.threat = threat;
        row.displayThreat = threat;
        row.oldThreat = threat;
        row.stepThreat = nil;
        row.class = class;
        row.aggroThreat = aggroThreat;
        row.hasAggro = hasAggro;
        row.hadAggro = hasAggro;
        row.tps = tps;
        row.lightingTimer = 0;

        row.position = position;
        row.targetPosition = position;
        row.stillUsed = 1;

        row.warningStatus = "UNUSED";

        -- Completely revamps the frame levels.
        row.lightingFrame:SetFrameLevel( row.baseLevel + 5 );
        row.sparkFrame:SetFrameLevel( row.baseLevel + 4 );
        row:SetFrameLevel( row.baseLevel + 3 );
        row.dangerYellowBar:SetFrameLevel( row.baseLevel + 2 );
        row.dangerRedBar:SetFrameLevel( row.baseLevel + 1 );
        row.backgroundBar:SetFrameLevel( row.baseLevel );

        row:Show();
        return;
    end
end

-- ********************************************************************
-- * row:Update(name, guid, threat, class, aggroThreat, ...)          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> row: the threat list row to operate on.                       *
-- * >> ...: the remaining parameters.                                *
-- ********************************************************************
-- * Updates a threat list row display.                               *
-- ********************************************************************
local function Update(row, name, guid, threat, class, aggroThreat, targetPosition, hasAggro, tps)
    if ( row.status ~= "UNUSED" ) then
        row.name = name;
        row.guid = guid;
        row.threat = threat;
        row.tps = tps;

        row.class = class;
        row.aggroThreat = aggroThreat;
        row.hasAggro = hasAggro;

        row.targetPosition = targetPosition;
        row.stillUsed = 1;

        if ( row.oldThreat ~= threat ) then
            row.stepThreat = max(10.0, abs( row.displayThreat - threat ) / 1.000 );
            row.oldThreat = threat;
        end

        if ( hasAggro ) and not ( row.hadAggro ) and ( row:GetParent().useAggroLightning == 1 ) then
            row.hadAggro = 1;
            if ( row.lightingTimer <= 0 or row.lightingTimer > LIGHTING_ANIMATION_DURATION ) then row.lightingTimer = LIGHTING_ANIMATION_DURATION; end

    elseif not ( hasAggro ) and ( row.hadAggro ) then
            row.hadAggro = nil;
            if ( row.lightingTimer > LIGHTING_ANIMATION_DURATION ) then row.lightingTimer = 0; end -- Still in delay phase. Cancel the whole anim.
        end

        return;
    end
end

-- ********************************************************************
-- * row:Destroy()                                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> row: the threat list row to operate on.                       *
-- ********************************************************************
-- * Asks a threat list row to disapparear.                           *
-- * It is not instantaneous.                                         *
-- ********************************************************************
local function Destroy(row)
    if ( row.status ~= "UNUSED" ) then
        row.status = "CLOSING";

        return;
    end
end

-- ********************************************************************
-- * row:StartWarning()                                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> row: the threat list row to operate on.                       *
-- ********************************************************************
-- * Starts the warning animation of a row.                           *
-- ********************************************************************
local function StartWarning(row)
    if ( row.warningStatus == "UNUSED" ) then
        row.warningStatus = "OPENING";
        row.warningScroll = 0;
        row.warningAlpha = 0.00;
        return;
    end
    if ( row.warningStatus == "CLOSING" ) then
        row.warningStatus = "OPENING";
        return;
    end
end

-- ********************************************************************
-- * row:StopWarning()                                                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> row: the threat list row to operate on.                       *
-- ********************************************************************
-- * Stops the warning animation of a row.                            *
-- ********************************************************************
local function StopWarning(row)
    if ( row.warningStatus ~= "UNUSED" ) then
        row.warningStatus = "CLOSING";
        return;
    end
end

-- ********************************************************************
-- * row:ApplySkin()                                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> row: the threat list row to operate on.                       *
-- ********************************************************************
-- * Apply the currently selected skin to the given row.              *
-- ********************************************************************
local function ApplySkin(row)
    local cfg = DTM_GetCurrentSkinSetting;

    row.width = row:GetParent().barWidth;
    row.fadeCoeff = cfg("Bars", "FadeCoeff") + 0.001; -- The added 0.001 will prevent divisions by zero.
    row.sortCoeff = cfg("Bars", "SortCoeff") + 0.001;
    row.isSmooth = cfg("Bars", "Smooth");
    row.showSpark = cfg("Bars", "ShowSpark");

    row.backgroundBarTexture:SetTexture( DTM_Resources_GetAbsolutePath("GFX", cfg("Bars", "BackgroundTexture")) );
    row:SetStatusBarTexture( DTM_Resources_GetAbsolutePath("GFX", cfg("Bars", "FillTexture")) );
    row.dangerYellowBar:SetStatusBarTexture( DTM_Resources_GetAbsolutePath("GFX", cfg("Bars", "FillTexture")) );
    row.dangerRedBar:SetStatusBarTexture( DTM_Resources_GetAbsolutePath("GFX", cfg("Bars", "FillTexture")) );

    -- Resize the bar, then columns.

    row:SetWidth(row.width);

    DTM_ApplyColumnSetting(row.nameText,          row, cfg("Columns", "Name"));
    DTM_ApplyColumnSetting(row.nameSmallText,     row, cfg("Columns", "Name"));
    DTM_ApplyColumnSetting(row.threatText,        row, cfg("Columns", "Threat"));
    DTM_ApplyColumnSetting(row.tpsText,           row, cfg("Columns", "TPS"));
    DTM_ApplyColumnSetting(row.threatPercentText, row, cfg("Columns", "Percentage"));

    -- Special case of the class icon.

    local classColumnInfo = cfg("Columns", "Class");
    row.showClass = classColumnInfo.enabled;
    DTM_ApplyColumnSetting(row.classTexture, row, classColumnInfo);
end

-- --------------------------------------------------------------------
-- **                           Functions                            **
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                            Handlers                            **
-- --------------------------------------------------------------------

function DTM_ThreatListRow_OnLoad(self)
    -- Sets row variables.
    self.alpha = 0.00;
    self.status = "UNUSED";
    self.positionStatus = "STANDBY";
    self.movementStartX = nil;
    self.movementStartY = nil;
    self.movementStartTimer = nil;
    self.movementTimer = nil;
    self.stillUsed = nil;
    self.position = 0;
    self.targetPosition = 0;
    self.offsetX = 0;
    self.warningEnabled = nil;
    self.hasAggro = nil;
    self.hadAggro = nil;

    -- Binds methods to the new row.
    self.Activate = Activate;
    self.Update = Update;
    self.Destroy = Destroy;
    self.StartWarning = StartWarning;
    self.StopWarning = StopWarning;
    self.ApplySkin = ApplySkin;

    -- Grab child frames.
    self.dangerYellowBar = getglobal(self:GetName().."_DangerYellowBar");
    self.dangerRedBar = getglobal(self:GetName().."_DangerRedBar");
    self.backgroundBar = getglobal(self:GetName().."_BackgroundBar");
    self.backgroundBarTexture = getglobal(self:GetName().."_BackgroundBarTexture");
    self.clickFrame = getglobal(self:GetName().."_ClickFrame");

    -- Grabs elements of the row.
    self.classTexture = getglobal(self:GetName().."_ClassFrameTexture");
    self.nameText = getglobal(self:GetName().."_Name");
    self.nameSmallText = getglobal(self:GetName().."_NameSmall");
    self.threatText = getglobal(self:GetName().."_Threat");
    self.tpsText = getglobal(self:GetName().."_TPS");
    self.threatPercentText = getglobal(self:GetName().."_ThreatPercent");
    self.sparkFrame = getglobal(self:GetName().."_Spark");
    self.lightingFrame = getglobal(self:GetName().."_Lighting");
    self.lightingTexture = getglobal(self:GetName().."_LightingTexture");

    -- Creates 4 scrolling warning frames.
    self.warningStatus = "UNUSED";
    self.warningScroll = 0;
    self.warningAlpha = 0.00;
    self.warningFrame = {};
    for i=1, 4 do
        self.warningFrame[i] = CreateFrame("Frame", self:GetName().."_WarningFrame"..i, self, "DTM_ThreatListRow_WarningTemplate");
    end

    -- Clear the lightning feature.
    self.lightingTimer = 0.000;

    -- Configures threat% bars.
    self:SetMinMaxValues(0, 130);
    self.dangerYellowBar:SetMinMaxValues(0, 130);
    self.dangerRedBar:SetMinMaxValues(0, 130);

    -- Completely revamps the frame levels.
    self.baseLevel = self:GetFrameLevel();

    -- Setup the click frame
    self.clickFrame:RegisterForClicks("RightButtonDown");
    self.clickFrame:Enable();

    -- Grab and set up the dropdown.
    self.dropDown = getglobal(self:GetName().."_DropDown");
    UIDropDownMenu_Initialize(self.dropDown, DTM_ThreatListRow_InitializeDropDown, "MENU");

    -- Ensure it is hidden at its creation.
    self:Hide();
end

function DTM_ThreatListRow_OnUpdate(self, elapsed)
    if ( self.status == "UNUSED" ) then
        self:Hide();
        return;
    end

    -- ***** Handle global status *****

    if ( self.status == "OPENING" ) then
        self.alpha = min(1.00, self.alpha + elapsed / (FADE_DURATION * self.fadeCoeff));
        self.offsetX = (self.width / 4) * (1 - self.alpha);

        if ( self.alpha == 1.00 ) then
            self.status = "RUNNING";
        end
    end

    if ( self.status == "RUNNING" ) then
        self.offsetX = 0;

        -- Interface with position status section.
        -- (Moved in the threat list itself)
    end

    if ( self.status == "CLOSING" ) then
        self.alpha = max(0.00, self.alpha - elapsed / (FADE_DURATION * self.fadeCoeff));
        self.offsetX = self.offsetX - (self.width / self.fadeCoeff) * elapsed;

        if ( self.alpha == 0.00 ) then
            self.status = "UNUSED";
        end
    end

    -- ***** Handle position status *****

    local baseX, baseY, baseZ;      -- Z is considered the "scale" axis.
    local finalX, finalY, finalZ;

    if ( self.positionStatus == "STARTWARNING" or self.positionStatus == "WARNING" ) then
        local warningPosition = self:GetParent().warningPosition;
        local xFactor = DTM_GetSavedVariable("gui", "warningPosX", "active");
        local yFactor = DTM_GetSavedVariable("gui", "warningPosY", "active");
        baseX = UIParent:GetWidth() * xFactor;
        baseY = UIParent:GetHeight() * yFactor + (warningPosition-1) * 40;
        baseX = baseX / self:GetParent():GetScale();
        baseY = baseY / self:GetParent():GetScale(); -- We don't want the threat row to scale with threat list's scale while in warning position, right?
        baseZ = 2.0 / self:GetParent():GetScale();
  else
        baseX = self:GetParent():GetCenter();
        baseY = self:GetParent():GetTop() - 42 - (self.position-1)*20 - 8;
        baseZ = 1.0;
    end

    finalZ = baseZ; -- By default.

    if ( self.positionStatus == "MOVEUP" ) then
        self.movementTimer = max(0.0, self.movementTimer - elapsed);
        if ( self.movementTimer <= 0.000 ) then
            self.positionStatus = "STANDBY";
        end

        local progression = 1.0 - self.movementTimer / self.movementStartTimer;

        finalX = self.movementStartX + (baseX - self.movementStartX) * progression;
        finalY = self.movementStartY + (baseY - self.movementStartY) * progression;

elseif ( self.positionStatus == "SWAP" ) then
        self.movementTimer = max(0.0, self.movementTimer - elapsed);
        if ( self.movementTimer <= 0.000 ) then
            self.positionStatus = "STANDBY";
        end

        local progression = 1.0 - self.movementTimer / self.movementStartTimer;

        local moveY  = (baseY - self.movementStartY)/2;
        local centerY = (self.movementStartY + baseY)/2;
                 
        finalX = self.movementStartX + (baseX - self.movementStartX) * progression;
        if ( moveY < 0 ) then
            finalX = finalX + math.abs(96) * cos(90+progression*180);
            finalY = centerY + moveY * cos(180+progression*180);
      else
            finalX = finalX - math.abs(96) * cos(90+progression*180);
            finalY = centerY + moveY * cos(180+progression*180);
        end

elseif ( self.positionStatus == "STARTWARNING" ) then
        self.movementTimer = max(0.0, self.movementTimer - elapsed);
        if ( self.movementTimer <= 0.000 ) then
            self.positionStatus = "WARNING";
        end

        local progression = 1.0 - self.movementTimer / self.movementStartTimer;

        finalX = self.movementStartX + (baseX - self.movementStartX) * progression;
        finalY = self.movementStartY + (baseY - self.movementStartY) * progression;
        finalZ = self.movementStartZ + (baseZ - self.movementStartZ) * progression;

elseif ( self.positionStatus == "ENDWARNING" ) then
        self.movementTimer = max(0.0, self.movementTimer - elapsed);
        if ( self.movementTimer <= 0.000 ) then
            self.positionStatus = "STANDBY";
        end

        local progression = 1.0 - self.movementTimer / self.movementStartTimer;

        finalX = self.movementStartX + (baseX - self.movementStartX) * progression;
        finalY = self.movementStartY + (baseY - self.movementStartY) * progression;
        finalZ = self.movementStartZ + (baseZ - self.movementStartZ) * progression;

  else
        -- Normal position status.
        finalX = baseX;
        finalY = baseY;
    end

    finalX = finalX + self.offsetX;

    -- ***** Handle warning scrolling *****

    if ( self.warningStatus == "UNUSED" ) then
        self.warningAlpha = 0.00;

elseif ( self.warningStatus == "OPENING" ) then
        self.warningAlpha = min(1.00, self.warningAlpha + elapsed / 1.00);
        if ( self.warningAlpha == 1.00 ) then self.warningStatus = "RUNNING"; end

elseif ( self.warningStatus == "RUNNING" ) then
        self.warningScroll = self.warningScroll + 64 * elapsed;

elseif ( self.warningStatus == "CLOSING" ) then
        self.warningAlpha = max(0.00, self.warningAlpha - elapsed / 1.00);
        if ( self.warningAlpha == 0.00 ) then self.warningStatus = "UNUSED"; end
    end

    local i;
    local leftPosition;
    local leftCoord, rightCoord;
    local neededTextures = 1 + math.floor(self.width/128);

    for i=1, 4 do
        if ( i > neededTextures ) then
            self.warningFrame[i]:Hide();
      else
            local leftPosition = math.fmod(i * 128 + self.warningScroll, self.width+128) - 128;
            local leftCoord, rightCoord = 0, 128;

            if ( leftPosition < 0 ) then
                -- Clip the Danger message upon reaching the left edge.
                leftCoord = -leftPosition;
                leftPosition = 0;
        elseif ( leftPosition > (self.width-128) ) then
                -- Clip the Danger message upon reaching the right edge.
                rightCoord = self.width - leftPosition;
            end

            self.warningFrame[i].texture:SetTexCoord(leftCoord/128, rightCoord/128, 0, 1);
            self.warningFrame[i]:ClearAllPoints();
            self.warningFrame[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", leftPosition, -16 + self.warningAlpha * 16);

            if ( (rightCoord - leftCoord) <= 0 ) or ( self.warningAlpha == 0.00 ) then
                self.warningFrame[i]:Hide();
          else
                self.warningFrame[i]:SetWidth(rightCoord - leftCoord);
                self.warningFrame[i]:SetAlpha(self.warningAlpha);
                self.warningFrame[i]:Show();
            end
        end
    end

    -- ***** Smoothen threat display *****

    if ( self.displayThreat ~= self.threat ) then
    if not ( self.class == "AGGRO_THRESHOLD" ) and ( self.isSmooth == 1 ) then
        local modifier = self.stepThreat * elapsed;
        if ( abs( self.displayThreat - self.threat ) <= modifier ) then
            self.displayThreat = self.threat;
            self.stepThreat = nil;
      else
            if ( self.displayThreat < self.threat ) then
                self.displayThreat = self.displayThreat + modifier;
          else
                self.displayThreat = self.displayThreat - modifier;
            end
        end
  else
        self.displayThreat = self.threat;
    end
    end

    -- ***** Set row content *****

    local percent = nil;
    local barPercent = nil;
    local percentText = "-";
    if ( self.hasAggro ) then percent = 100; barPercent = 100; percentText = "100"; end -- Always 100% full bar in case current bar has the aggro.
    if ( self.aggroThreat ) and ( self.aggroThreat > 0 ) and not ( self.hasAggro ) then
        percent = self.displayThreat / self.aggroThreat * 100;
        barPercent = min(130, percent);
        percentText = floor(percent + .5);
    end
    if ( barPercent ) then
        if ( self.showSpark == 1 ) then
            self.sparkFrame:ClearAllPoints();
            self.sparkFrame:SetPoint("CENTER", self, "LEFT", barPercent / 130 * self.width, 0);
            self.sparkFrame:Show();

            -- Reduce brightness of the spark on the borders of the bar.
            if ( barPercent < 5 ) then
                self.sparkFrame:SetAlpha(barPercent / 5);
        elseif ( barPercent > 125 ) then
                self.sparkFrame:SetAlpha(1.0 - (barPercent - 125) / 5);
          else
                self.sparkFrame:SetAlpha(1.0);
            end
      else
            self.sparkFrame:Hide();
        end

        if ( self.hasAggro ) then
            self:SetValue(0);
            self.dangerYellowBar:SetValue(0);
            self.dangerRedBar:SetValue(barPercent);

    elseif ( barPercent >= RED_THRESHOLD ) then
            self:SetValue( YELLOW_THRESHOLD );
            self.dangerYellowBar:SetValue( RED_THRESHOLD );
            self.dangerRedBar:SetValue(barPercent);

    elseif ( barPercent >= YELLOW_THRESHOLD ) then
            self:SetValue( YELLOW_THRESHOLD );
            self.dangerYellowBar:SetValue(barPercent);
            self.dangerRedBar:SetValue(0);
      else
            self:SetValue(barPercent);
            self.dangerYellowBar:SetValue(0);
            self.dangerRedBar:SetValue(0);
        end
  else
        self:SetValue(0);
        self.dangerYellowBar:SetValue(0);
        self.dangerRedBar:SetValue(0);
        self.sparkFrame:Hide();
    end
    self.threatPercentText:SetText( percentText );

    -- Make sure the class column is shown to avoid conflicts.
    if ( self.showClass == 1 ) then
        if not ( self.class == "AGGRO_THRESHOLD" ) then
            local symbol = DTM_SymbolsBuffer_Get(self.guid);
            if ( symbol > 0 ) then
                -- self unit has a symbol. Display it.
                self.classTexture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
                SetRaidTargetIconTexture(self.classTexture, symbol);
                self.classTexture:Show();
                self.classTexture:SetAlpha(1.0);
          else
                -- No symbol. Check if the unit has a special attribute icon.
                local attribute = DTM_GetAttribute(self.guid);
                local internal, filename, w, h = DTM_Resources_GetGraphicData(attribute);
                if ( attribute ~= "NONE" ) and ( filename ) then
                    self.classTexture:Show();
                    self.classTexture:SetTexture(filename);
                    self.classTexture:SetTexCoord(0, 1, 0, 1);
                    self.classTexture:SetAlpha(1.0);
              else
                    -- Display the class instead.
                    iconCoords = CLASS_BUTTONS[self.class];
                    if ( iconCoords ) then
                        self.classTexture:SetTexture("Interface\\WorldStateFrame\\Icons-Classes");
                        self.classTexture:SetTexCoord(unpack(iconCoords));
                        self.classTexture:Show();
                        self.classTexture:SetAlpha(1.0);
                  else
                        self.classTexture:Hide();
                    end
                end
            end
      else
            -- Shows a cute flashing danger sign.
            local internal, filename, w, h = DTM_Resources_GetGraphicData("AGGRO_THRESHOLD");
            self.classTexture:Show();
            self.classTexture:SetTexture(filename);
            self.classTexture:SetTexCoord(0, 1, 0, 1);
            self.classTexture:SetAlpha(0.7 + 0.3 * cos(GetTime()*360));
        end
    end

    -- The name. If it's too long, use the small text widget instead.
    local smallTextThreshold = self.width * 0.25;

    self.nameText:SetText( self.name );
    if ( (self.nameText:GetStringWidth() / self:GetEffectiveScale()) > smallTextThreshold ) then
        self.nameSmallText:SetText( self.name );
        self.nameText:SetText('');
  else
        self.nameSmallText:SetText('');
    end
    self.threatText:SetText( DTM_GUI_FormatThreatValue(self.displayThreat) );
    if type(self.tps) == "number" then
        self.tpsText:SetText( DTM_GUI_FormatThreatValue(self.tps) );
  else
        self.tpsText:SetText( self.tps or '' );
    end

    -- ***** Okay, play the beautiful lighting effect if it is running. x)

    if ( self.hasAggro ) and ( self.lightingTimer <= 0 ) and ( self:GetParent().useAggroLightning == 1 ) then
        self.lightingTimer = LIGHTING_ANIMATION_DURATION + LIGHTING_ANIMATION_DELAY;
    end

    if ( self.lightingTimer > 0 ) then
        self.lightingTimer = max(0, self.lightingTimer - elapsed);

        if ( self.lightingTimer <= LIGHTING_ANIMATION_DURATION ) then
            local leftPosition = -128 + (self.lightingTimer / LIGHTING_ANIMATION_DURATION) * (self.width+128);
            local leftCoord, rightCoord = 0, 128;

            if ( leftPosition < 0 ) then
                -- Clip the lighting texture upon reaching the left edge.
                leftCoord = -leftPosition;
                leftPosition = 0;
        elseif ( leftPosition > (self.width-128) ) then
                -- Clip the lighting texture upon reaching the right edge.
                rightCoord = self.width - leftPosition;
            end

            self.lightingTexture:SetTexCoord(leftCoord/128, rightCoord/128, 0, 1);
            self.lightingFrame:ClearAllPoints();
            self.lightingFrame:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", leftPosition, 0);

            if ( (rightCoord - leftCoord) <= 0 ) then
                self.lightingFrame:Hide();
          else
                self.lightingFrame:SetWidth(rightCoord - leftCoord);
                self.lightingFrame:SetHeight(self:GetHeight());
                self.lightingFrame:SetAlpha(0.5);
                self.lightingFrame:Show();
            end
      else
            self.lightingFrame:Hide();
        end
  else
        self.lightingFrame:Hide();
    end

    -- ***** Set new row properties *****

    self:ClearAllPoints();
    self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", finalX/finalZ, finalY/finalZ);
    self:SetScale(finalZ);
    self:SetAlpha(self.alpha);

    -- ***** Binds the crystal if row is local player *****

    local inWarningStatus = nil;

    local playerGUID = UnitGUID("player");
    if ( playerGUID ) and ( playerGUID == self.guid ) then
        self:GetParent().crystalParent = self;

        -- Further computations to determinate if the frame should be zoomed to warn local player, in
        -- case it is going to get the aggro.

        local activeUnit = self:GetParent().activeUnit;
        local warnable = ( self:GetParent().useWarning ) and ( self.aggroThreat ) and ( self.aggroThreat > 0 ) and not ( self.hasAggro );

        if ( activeUnit ) and ( warnable ) and ( DTM_GUI_CheckWarningDistance(activeUnit, self:GetParent().aggroDistance) ) then
            local margin = 0.2;
            if not ( self.warningEnabled ) then
                margin = DTM_GetSavedVariable("gui", "warningLimit", "active") / 100;
          else
                margin = DTM_GetSavedVariable("gui", "warningCancelLimit", "active") / 100;
            end

            local ratio = self.threat / self.aggroThreat;
            local dangerRatio = DTM_Self_GetAggroGainThreshold( activeUnit ) - margin;

            if ( ratio > dangerRatio ) then
                inWarningStatus = 1;
            end
        end
    end


    -- ***** Warning state change handler *****

    if ( inWarningStatus ) and not ( self.warningEnabled ) then
        self.warningEnabled = 1;
        self:StartWarning();

        self.positionStatus = "STARTWARNING";
        self.movementStartX, self.movementStartY = self:GetCenter();
        self.movementStartX = self.movementStartX * self:GetScale();
        self.movementStartY = self.movementStartY * self:GetScale();
        self.movementStartZ = self:GetScale();
        self.movementStartTimer = ANIMATION_LENGTH_WARNING_START * self.sortCoeff;
        self.movementTimer = self.movementStartTimer;

        -- Play a warning sound.
        local warningSound = DTM_GetSavedVariable("gui", "warningSound", "active");
        if ( warningSound ~= "NONE" ) then
            DTM_PlaySound(warningSound);
        end
    end
    if not ( inWarningStatus ) and ( self.warningEnabled ) then
        if ( self.positionStatus == "STARTWARNING" ) or ( self.positionStatus == "WARNING" ) then
            self.warningEnabled = nil;
            self:StopWarning();

            self.positionStatus = "ENDWARNING";
            self.movementStartX, self.movementStartY = self:GetCenter();
            self.movementStartX = self.movementStartX * self:GetScale();
            self.movementStartY = self.movementStartY * self:GetScale();
            self.movementStartZ = self:GetScale();
            self.movementStartTimer = ANIMATION_LENGTH_WARNING_END * self.sortCoeff;
            self.movementTimer = self.movementStartTimer;
        end
    end
end

function DTM_ThreatListRow_OnClick(self, button)
    if ( self.status == "UNUSED" or self.status == "CLOSING" ) then
        -- Ignore clicks on shutting or unused frames.
        return;
    end

    if button ~= "RightButton" then return; end
    if self:GetParent().ignoreDropDown then return; end

    -- The dropdown does not provide useful functions to the lists that display NPCs.
    if self:GetParent().listType ~= "THREATLIST" then return; end

    if type(self.dropDown) == 'table' then
        HideDropDownMenu(1);
        ToggleDropDownMenu(1, nil, self.dropDown, "cursor");
        PlaySound("igMainMenuOpen");
    end
end

function DTM_ThreatListRow_InitializeDropDown()
    local row = getglobal(UIDROPDOWNMENU_INIT_MENU):GetParent();
    local info;
    local name, guid = row.name, row.guid;
    local attribute = DTM_GetAttribute(guid);

    -- Add the commands.

    info              = UIDropDownMenu_CreateInfo();
    info.text         = DTM_Localise("tankToggle");
    info.checked      = (attribute == "TANK");
    info.tooltipTitle = info.text;
    info.tooltipText  = DTM_Localise("tankToggleTooltip");
    if ( not DTM_OnWotLK() ) then
        info.func = DTM_ThreatListRow_DropDown_TankToggle;
 else
        -- Another WotLK hack to get rid of pesky "self" argument.
        info.func = function(self, ...) DTM_ThreatListRow_DropDown_TankToggle(...); end;
    end
    info.arg1 = guid;
    info.arg2 = name;
    UIDropDownMenu_AddButton(info);

    info              = UIDropDownMenu_CreateInfo();
    info.text         = CANCEL;
    info.notCheckable = 1;
    info.tooltipTitle = info.text;
    info.tooltipText  = nil;
    info.func = function() end;
    UIDropDownMenu_AddButton(info);
end

function DTM_ThreatListRow_DropDown_TankToggle(guid, name)
    local attribute = DTM_GetAttribute(guid);
    if ( attribute == "TANK" ) then
        DTM_SetAttribute(guid, name, "NONE");
  else
        DTM_SetAttribute(guid, name, "TANK");
    end
end