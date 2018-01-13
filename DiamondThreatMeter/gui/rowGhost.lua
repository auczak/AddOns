local activeModule = "GUI ghost row";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local FADE_DURATION = 0.250;
local ANIMATION_INTERVAL = 0.050;

-- --------------------------------------------------------------------
-- **                            Methods                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * row:Activate()                                                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> row: the ghost row to operate on.                             *
-- ********************************************************************
-- * Starts a ghost row display. You should position it with other    *
-- * methods just after activating it.                                *
-- ********************************************************************
local function Activate(row)
    if ( row.status == "UNUSED" ) then
        row.status = "WORKING";
        row.alpha = 0.00;
        row.frameDisplayed = 0;
        row.frameTimer = 0.000;
        row:ApplySkin();
        row:Show();
        return;
    end
    if ( row.status == "CLOSING" ) then
        row.status = "WORKING";
        row:Show();
        return;
    end
end

-- ********************************************************************
-- * row:SetPosition(x, y, scale)                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> row: the ghost row to operate on.                             *
-- * >> x, y, scale: positionning info. These parameters must be      *
-- * comprised between 0 and 1, scale can be greater than 1.          *
-- ********************************************************************
-- * Set position of the ghost row on the screen.                     *
-- ********************************************************************
local function SetPosition(row, x, y, scale)
    if ( row.status ~= "UNUSED" ) then
        row.x = x;
        row.y = y;
        row.scale = scale;
    end
end

-- ********************************************************************
-- * row:Destroy()                                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> row: the ghost row to operate on.                             *
-- ********************************************************************
-- * Asks a ghost row to disapparear. It is not instantaneous.        *
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
-- * >> row: the ghost row to operate on.                             *
-- ********************************************************************
-- * Apply the currently selected skin to the given row.              *
-- ********************************************************************
local function ApplySkin(row)
    local cfg = DTM_GetCurrentSkinSetting;

    row:SetWidth(cfg("ThreatList", "Length"));
end

-- --------------------------------------------------------------------
-- **                      DTM ghost row handlers                    **
-- --------------------------------------------------------------------

function DTM_GhostRow_OnLoad(self)
    -- Sets row variables.
    self.alpha = 0.00;
    self.status = "UNUSED";
    self.x = 0.00; -- Comprised between 0 and 1.
    self.y = 0.00; -- Comprised between 0 and 1.
    self.scale = 1.00;
    self.frameDisplayed = 0;
    self.frameTimer = 0.000;
    self.frameTexture = getglobal(self:GetName().."Texture");

    -- Binds methods.
    self.Activate = Activate;
    self.SetPosition = SetPosition;
    self.Destroy = Destroy;
    self.ApplySkin = ApplySkin;

    -- Ensure it is hidden at its creation.
    self:Hide();
end

function DTM_GhostRow_OnUpdate(self, elapsed)
    if ( self.status == "UNUSED" ) then
        self:Hide();
        return;
    end

    -- ***** Handle global status *****

    if ( self.status == "WORKING" ) then
        self.alpha = min(1.00, self.alpha + elapsed / FADE_DURATION);
    end

    if ( self.status == "CLOSING" ) then
        self.alpha = max(0.00, self.alpha - elapsed / FADE_DURATION);
        if ( self.alpha == 0.00 ) then
            self.status = "UNUSED";
        end
    end

    -- ***** Handle animation *****

    self.frameTimer = self.frameTimer - elapsed;
    while ( self.frameTimer <= 0.00 ) do
        self.frameTimer = self.frameTimer + ANIMATION_INTERVAL;
        self.frameDisplayed = math.fmod(self.frameDisplayed + 1, 4);
        self.frameTexture:SetTexCoord(0.00, 1.00, 16/64 * self.frameDisplayed, 16/64 * (self.frameDisplayed+0.99));
    end

    -- ***** Handle position status *****

    local X, Y, Z;
    Z = self.scale;
    X = self.x / Z;
    Y = self.y / Z;

    -- ***** Set new row properties *****

    self:ClearAllPoints();
    self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", X, Y);
    self:SetScale(Z);
    self:SetAlpha(self.alpha);
end
