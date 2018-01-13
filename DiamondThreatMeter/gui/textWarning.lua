local activeModule = "GUI Text warning";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local OPEN_POWER = 2;
local CLOSE_POWER = 2;

local OPEN_TIME_RATIO  = 0.15;
local HOLD_TIME_RATIO  = 0.70;
local CLOSE_TIME_RATIO = 0.15;

-- --------------------------------------------------------------------
-- **                             Methods                            **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * self:Display(text)                                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> self: the text warning frame.                                 *
-- * >> text: what is to be displayed.                                *
-- * >> force: if the text warning is already displaying something,   *
-- * setting this parameter will overide the previous warning.        *
-- ********************************************************************
-- * Displays a warning text on-screen, using a scroll effect.        *
-- ********************************************************************
local function Display(self, text, force)
    if ( self.status ~= "READY" and force ) then
        self:Clear();
    end

    if ( self.status == "READY" ) then
        self.fontString:SetText(text);

        self.offscreenFactorClip = self.fontString:GetStringWidth() / (UIParent:GetWidth() * 2);

        self.currentTime = 0;
        self.openTime = OPEN_TIME_RATIO * self.totalTime;
        self.holdTime = HOLD_TIME_RATIO * self.totalTime;
        self.removeTime = CLOSE_TIME_RATIO * self.totalTime;

        self.status = "OPENING";
        self:Show();

        return 1;
    end

    return nil;
end

-- ********************************************************************
-- * self:Clear()                                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> self: the text warning frame.                                 *
-- ********************************************************************
-- * Instantly clears the text warning frame.                         *
-- ********************************************************************
local function Clear(self)
    self:Hide();
    self.status = "READY";
end

-- ********************************************************************
-- * self:ApplySkin()                                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> self: the text warning frame to operate on.                   *
-- ********************************************************************
-- * Apply the currently selected skin to the given textual warning.  *
-- ********************************************************************
local function ApplySkin(self)
    local cfg = DTM_GetCurrentSkinSetting;

    self.yPosition = cfg("Text", "TWPositionY");
    self.totalTime = cfg("Text", "TWHoldTime");
end

-- --------------------------------------------------------------------
-- **                             Handlers                           **
-- --------------------------------------------------------------------

function DTM_TextWarning_OnLoad(self)
    -- Children
    self.fontString = getglobal(self:GetName().."_FontString");
    self.fontString:SetTextHeight(32);

    -- Properties
    self.status = "READY";
    self.yPosition = 0.50;
    self.totalTime = 2.50;

    -- Methods
    self.Display = Display;
    self.Clear = Clear;
    self.ApplySkin = ApplySkin;
end

function DTM_TextWarning_OnUpdate(self, elapsed)
    if ( self.status == "READY" ) then
        self:Hide();
        return;
    end

    -- Status transition

    self.currentTime = self.currentTime + elapsed;

    if ( self.status == "OPENING" ) then
        if ( self.currentTime >= self.openTime ) then
            self.currentTime = 0;
            self.status = "HOLDING";
        end

elseif ( self.status == "HOLDING" ) then
        if ( self.holdTime ) then
            if ( self.currentTime >= self.holdTime ) then
                self.currentTime = 0;
                self.status = "CLOSING";
            end
        end

elseif ( self.status == "CLOSING" ) then
        if ( self.currentTime >= self.removeTime ) then
            self.currentTime = 0;
            self:Clear();
            return;
        end
    end

    -- Now update properties

    local xPosition = 0.500; -- 0.5 <-> Middle screen (on X-axis)

    if ( self.status == "OPENING" ) then
        xPosition = 0.500 + (0.500 + self.offscreenFactorClip) * (1 - self.currentTime / self.openTime) ^ OPEN_POWER;

elseif ( self.status == "CLOSING" ) then
        xPosition = 0.500 - (0.500 + self.offscreenFactorClip) * (self.currentTime / self.removeTime) ^ CLOSE_POWER;
    end

    self.fontString:ClearAllPoints();
    self.fontString:SetPoint("CENTER", self, "BOTTOMLEFT", xPosition * UIParent:GetWidth(), self.yPosition * UIParent:GetHeight());
    self.fontString:Show();
end
