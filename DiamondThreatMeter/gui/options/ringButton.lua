local activeModule = "GUI Ring button";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local RESET_DURATION = 0.500;

-- --------------------------------------------------------------------
-- **                            Methods                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * self:UseUnsetPosition()                                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> self: DTM ring button.                                        *
-- ********************************************************************
-- * Reposition the ring button and unset it.                         *
-- ********************************************************************
local function UseUnsetPosition(self)
    if not ( self.unset ) then return; end

    self.resetTimer = nil;

    self:DisplayOver(self.unset.parent);

    self:SetUserPlaced(false);
    self.set = false;

    self:ClearAllPoints();
    self:SetPoint(self.unset.point, self.unset.parent, self.unset.point, self.unset.ofsX, self.unset.ofsY);

    self:Hide();
    self:Show();
end

-- ********************************************************************
-- * self:UseSetPosition()                                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> self: DTM ring button.                                        *
-- ********************************************************************
-- * Reposition the ring button to the saved location.                *
-- * This method ought to be recalled whenever UI scale is changed.   *
-- ********************************************************************
local function UseSetPosition(self)
    local ringButtonX = DTM_GetSavedVariable("gui", "ringButtonX");
    local ringButtonY = DTM_GetSavedVariable("gui", "ringButtonY");
    local ringButtonParent = DTM_GetSavedVariable("gui", "ringButtonParent");

    if ( ringButtonParent == "UNSET" or ringButtonX == "UNSET" or ringButtonY == "UNSET" ) then return; end

    ringButtonParent = getglobal(ringButtonParent);
    self:DisplayOver(ringButtonParent);

    local ofsX, ofsY;
    ofsX = ringButtonX * UIParent:GetWidth();
    ofsY = ringButtonY * UIParent:GetHeight();

    self:SetUserPlaced(false);
    self:ClearAllPoints();
    self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", ofsX, ofsY);
    self.set = true;

    self:Hide();
    self:Show();
end

-- ********************************************************************
-- * self:DisplayOver(frame)                                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> self: DTM ring button.                                        *
-- * >> frame: the frame the ring button should be displayed over.    *
-- ********************************************************************
-- * Change parent, strata and level of the ring button apparear      *
-- * above the given frame.                                           *
-- ********************************************************************
local function DisplayOver(self, frame)
    self:SetParent(frame);
    self:SetFrameStrata(frame:GetFrameStrata());
    self:SetFrameLevel(frame:GetFrameLevel()+1);
end

-- ********************************************************************
-- * self:StartDrag()                                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> self: DTM ring button.                                        *
-- ********************************************************************
-- * Starts dragging the DTM ring button.                             *
-- ********************************************************************
local function StartDrag(self)
    if ( self.set ) then
        return; -- Disallow dragging if the button is set.
    end

    self.moving = true;
    self:StartMoving();
end

-- ********************************************************************
-- * self:StopDrag()                                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> self: DTM ring button.                                        *
-- ********************************************************************
-- * Stops dragging the DTM ring button.                              *
-- ********************************************************************
local function StopDrag(self)
    if not ( self.moving ) then return; end

    self.moving = false;
    self:StopMovingOrSizing();

    local parent = Minimap; -- We assume most users will put the ring button on the minimap.
    self:DisplayOver(parent);

    self.set = true;
    self:SetUserPlaced(false); -- Make sure the ring button is not saved in the layout cache.

    local posX, posY = self:GetCenter();
    
    -- Save settings
    DTM_SetSavedVariable("gui", "ringButtonX", posX / UIParent:GetWidth());
    DTM_SetSavedVariable("gui", "ringButtonY", posY / UIParent:GetHeight());
    DTM_SetSavedVariable("gui", "ringButtonParent", parent:GetName());

    -- Validate position by manually re-anchoring.
    self:UseSetPosition();
end

-- ********************************************************************
-- * self:Reset()                                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> self: DTM ring button.                                        *
-- ********************************************************************
-- * Reposition the ring button in its "box".                         *
-- ********************************************************************
local function Reset(self)
    if ( not self.set ) then return; end
    if ( self.resetTimer ) then return; end

    local parent = self.unset.parent;
    self:DisplayOver(parent);

    self.resetTimer = RESET_DURATION;
    self.startX, self.startY = self:GetCenter();
    self.endX = parent:GetLeft() + self.unset.ofsX + 16;
    self.endY = parent:GetBottom() + self.unset.ofsY + 16;

    -- Erase settings
    DTM_SetSavedVariable("gui", "ringButtonX", "UNSET");
    DTM_SetSavedVariable("gui", "ringButtonY", "UNSET");
    DTM_SetSavedVariable("gui", "ringButtonParent", "UNSET");
end

-- --------------------------------------------------------------------
-- **                             Handlers                           **
-- --------------------------------------------------------------------

function DTM_RingButton_OnLoad(self)
    -- Sets ring button's variables.
    self.resetTimer = nil;
    self.set = false;
    self.moving = false;
    self.previousScale = 0;

    -- Binds methods.
    self.UseUnsetPosition = UseUnsetPosition;
    self.UseSetPosition = UseSetPosition;
    self.DisplayOver = DisplayOver;
    self.StartDrag = StartDrag;
    self.StopDrag = StopDrag;
    self.Reset = Reset;

    -- Drag registration
    self:RegisterForDrag("LeftButton");
end

function DTM_RingButton_OnUpdate(self, elapsed)
    if ( not self.resetTimer ) then
        if ( not self.moving ) and ( self.set ) and ( self.previousScale ~= UIParent:GetEffectiveScale() ) then
            self.previousScale = UIParent:GetEffectiveScale();
            self:UseSetPosition();
        end
        return;
    end

    self.resetTimer = max(0, self.resetTimer - elapsed);
    if ( self.resetTimer == 0 ) or not ( self:IsVisible() ) then
        self:UseUnsetPosition();
  else
        local adjX, adjY, prog;
        prog = 1 - self.resetTimer / RESET_DURATION;
        adjX = self.startX + (self.endX - self.startX) * prog;
        adjY = self.startY + (self.endY - self.startY) * prog;
        self:ClearAllPoints();
        self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", adjX, adjY);
    end
end

function DTM_RingButton_OnClick(self, button)
    if ( self.set ) and ( DTM_ConfigurationFrame_IntroPanel_Open ) and not ( self.moving ) then
        DTM_ConfigurationFrame_IntroPanel_Open();
    end
end