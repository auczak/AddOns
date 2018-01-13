local activeModule = "GUI Regain list row";

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

-- Animations duration

local FADE_DURATION = 0.250;

-- --------------------------------------------------------------------
-- **                            Methods                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * row:Activate(name, guid, threat, class, position, ...)           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> row: the regain list row to operate on.                       *
-- * >> ...: the remaining parameters.                                *
-- ********************************************************************
-- * Starts a regain list row display.                                *
-- ********************************************************************
local function Activate(row, name, guid, threat, class, position, hasAggro, relativeName)
    if ( row.status == "UNUSED" ) then
        row.status = "OPENING";
        row.alpha = 0.00;

        row.name = name;
        row.guid = guid;
        row.threat = threat;
        row.displayThreat = threat;
        row.oldThreat = threat;
        row.stepThreat = nil;
        row.class = class;
        row.hasAggro = hasAggro;
        row.relativeName = relativeName;

        row.position = position;
        row.stillUsed = 1;

        -- Rework the frame levels.
        row:SetFrameLevel( row.baseLevel + 1 );
        row.backgroundBar:SetFrameLevel( row.baseLevel );

        row:Show();
        return;
    end
end

-- ********************************************************************
-- * row:Update(name, guid, threat, class, position, ...)             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> row: the regain list row to operate on.                       *
-- * >> ...: the remaining parameters.                                *
-- ********************************************************************
-- * Updates a regain list row display.                               *
-- ********************************************************************
local function Update(row, name, guid, threat, class, position, hasAggro, relativeName)
    if ( row.status ~= "UNUSED" ) then
        row.name = name;
        row.guid = guid;
        row.threat = threat;
        row.class = class;
        row.hasAggro = hasAggro;
        row.relativeName = relativeName;

        row.position = position;
        row.stillUsed = 1;

        if ( row.oldThreat ~= threat ) then
            row.stepThreat = max(10.0, abs( row.displayThreat - threat ) / 1.000 );
            row.oldThreat = threat;
        end

        return;
    end
end

-- ********************************************************************
-- * row:Destroy()                                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> row: the regain list row to operate on.                       *
-- ********************************************************************
-- * Asks a regain list row to disapparear.                           *
-- * It is not instantaneous.                                         *
-- ********************************************************************
local function Destroy(row)
    if ( row.status ~= "UNUSED" ) then
        row.status = "CLOSING";
        return;
    end
end

-- ********************************************************************
-- * row:ApplySkin()                                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> row: the regain list row to operate on.                       *
-- ********************************************************************
-- * Apply the currently selected skin to the given row.              *
-- ********************************************************************
local function ApplySkin(row)
    local cfg = DTM_GetCurrentSkinSetting;

    row.width = row:GetParent().barWidth;
    row.fadeCoeff = cfg("Bars", "FadeCoeff") + 0.001; -- The added 0.001 will prevent divisions by zero.
    row.isSmooth = cfg("Bars", "Smooth");

    row.backgroundBarTexture:SetTexture( DTM_Resources_GetAbsolutePath("GFX", cfg("Bars", "BackgroundTexture")) );
    row:SetStatusBarTexture( DTM_Resources_GetAbsolutePath("GFX", cfg("Bars", "FillTexture")) );

    -- Resize the bar, then columns.

    row:SetWidth(row.width);

    DTM_ApplyColumnSetting(row.nameText,     row, cfg("RegainColumns", "Name"));
    DTM_ApplyColumnSetting(row.threatText,   row, cfg("RegainColumns", "Threat"));
    DTM_ApplyColumnSetting(row.relativeText, row, cfg("RegainColumns", "Relative"));

    -- Special case of the class icon.

    local classColumnInfo = cfg("RegainColumns", "Class");
    row.showClass = classColumnInfo.enabled;
    DTM_ApplyColumnSetting(row.classTexture, row, classColumnInfo);
end

-- --------------------------------------------------------------------
-- **                           Functions                            **
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                             Handlers                           **
-- --------------------------------------------------------------------

function DTM_RegainListRow_OnLoad(self)
    -- Sets row variables.
    self.alpha = 0.00;
    self.status = "UNUSED";
    self.stillUsed = nil;
    self.position = 0;
    self.offsetX = 0;
    self.hasAggro = nil;
    self.relativeName = nil;

    -- Binds methods to the new row.
    self.Activate = Activate;
    self.Update = Update;
    self.Destroy = Destroy;
    self.ApplySkin = ApplySkin;

    -- Grab child frames.
    self.backgroundBar = getglobal(self:GetName().."_BackgroundBar");
    self.backgroundBarTexture = getglobal(self:GetName().."_BackgroundBarTexture");

    -- Grabs elements of the row.
    self.classTexture = getglobal(self:GetName().."_ClassFrameTexture");
    self.nameText = getglobal(self:GetName().."_Name");
    self.threatText = getglobal(self:GetName().."_Threat");
    self.relativeText = getglobal(self:GetName().."_Relative");

    -- Configures threat% bars.
    self:SetMinMaxValues(0, 1);

    -- Get the frame's level.
    self.baseLevel = self:GetFrameLevel();

    -- Ensure it is hidden at its creation.
    self:Hide();
end

function DTM_RegainListRow_OnUpdate(self, elapsed)
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

    baseX = self:GetParent():GetCenter();
    baseY = self:GetParent():GetTop() - 42 - (self.position-1)*20 - 8;
    baseZ = 1.0;

    finalX = baseX;
    finalY = baseY;
    finalZ = baseZ;

    finalX = finalX + self.offsetX;

    -- ***** Smoothen threat display *****

    if ( self.displayThreat ~= self.threat ) and ( self.isSmooth == 1 ) then
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

    -- ***** Set row content *****

    if ( self.hasAggro ) then
        self:SetValue(1); -- Display the bar in red.
  else
        self:SetValue(0);
    end

    -- Make sure the class column is shown to avoid conflicts.
    if ( self.showClass ) then
        local symbol = DTM_SymbolsBuffer_Get(self.guid);
        if ( symbol > 0 ) then
            -- self unit has a symbol. Display it.
            self.classTexture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
            SetRaidTargetIconTexture(self.classTexture, symbol);
            self.classTexture:Show();
      else
            -- No symbol. Display the class instead.
            iconCoords = CLASS_BUTTONS[self.class];
            if ( iconCoords ) then
                self.classTexture:SetTexture("Interface\\WorldStateFrame\\Icons-Classes");
                self.classTexture:SetTexCoord(unpack(iconCoords));
                self.classTexture:Show();
          else
                self.classTexture:Hide();
            end
        end
    end

    self.nameText:SetText( self.name );
    self.relativeText:SetText( self.relativeName );

    local threatString = DTM_GUI_FormatThreatValue(self.displayThreat);
    if ( self.displayThreat > 0 ) then threatString = "+"..threatString; end
    self.threatText:SetText(threatString);

    -- ***** Set new row properties *****

    self:ClearAllPoints();
    self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", finalX/finalZ, finalY/finalZ);
    self:SetScale(finalZ);
    self:SetAlpha(self.alpha);
end
