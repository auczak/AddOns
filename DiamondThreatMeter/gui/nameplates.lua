local activeModule = "GUI Nameplates";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local NAMEPLATES_READY = 0;

local NUM_NAMEPLATES = 25; -- Up to 25 threat nameplate bars displayed at a time.

DTM_NameplateBar = { };

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_InitialiseNameplates()                                       *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Set up the special nameplate threat bar display.                 *
-- ********************************************************************

function DTM_InitialiseNameplates()
    if ( NAMEPLATES_READY == 1 ) then return; end

    local i;
    for i=1, NUM_NAMEPLATES do
        DTM_NameplateBar[i] = CreateFrame("StatusBar", "DTM_NameplateBar"..i, nil, "DTM_NameplateBarTemplate");
    end

    NAMEPLATES_READY = 1;
end

-- ********************************************************************
-- * DTM_UpdateNameplates()                                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Callback called periodically by NameplateLib that update threat  *
-- * nameplate bars.                                                  *
-- ********************************************************************

function DTM_UpdateNameplates()
    if ( NAMEPLATES_READY ~= 1 ) then return; end

    local i, nameplate, myName, nameplateInstances, myGUID, threatInstances;
    local aggroName, aggroGUID, aggroThreat;
    local localPlayerGUID, localPlayerThreat, percentage;
    local nameplateBar;

    -- Release all current DTM nameplates.
    for i=1, NUM_NAMEPLATES do
        DTM_NameplateBar[i]:Remove();
    end

    if ( DTM_IsGUIRunning() ~= 1 ) or not ( DTM_GetSavedVariable("gui", "nameplatesBarDisplay", "active") == 1 ) then
        return;
    end

    localPlayerGUID = UnitGUID("player");

    -- Get all current on-screen nameplates.
    for i=1, NameplateLib:GetNum() do
        nameplate = NameplateLib:GetByID(i);
        myName = NameplateLib:GetName(nameplate);
        nameplateInstances = select(2, NameplateLib:GetByName(myName));

        if ( nameplateInstances == 1 ) then
            -- Only 1 nameplate instance. Proceed.
            myGUID, threatInstances = DTM_FindGUIDFromName(myName);

            if ( threatInstances == 1 ) then
                -- Only 1 threat data instance. Proceed.

                aggroName, aggroGUID = DTM_UnitThreatGetAggro(myGUID);
                if ( aggroGUID ) then
                    -- This NPC has an aggro target, displaying the relative threat info is relevant.

                    localPlayerThreat = DTM_UnitThreat(myGUID, localPlayerGUID);
                    aggroThreat = DTM_UnitThreat(myGUID, aggroGUID);

                    if ( localPlayerThreat and localPlayerThreat > 0 and aggroThreat and aggroThreat > 0 ) then
                        -- All needed infos are gathered.

                        percentage = localPlayerThreat * 100 / aggroThreat;
                        nameplateBar = DTM_GetFreeNameplate();

                        if ( nameplateBar ) then
                            nameplateBar:Display(nameplate, localPlayerThreat, percentage, aggroGUID == localPlayerGUID);
                        end
                    end
                end
            end
        end
    end
end

-- ********************************************************************
-- * DTM_GetFreeNameplate()                                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Returns a free nameplate bar object. Nil if can't be found.      *
-- ********************************************************************

function DTM_GetFreeNameplate()
    if ( NAMEPLATES_READY ~= 1 ) then return nil; end
    local i;
    for i=1, NUM_NAMEPLATES do
        if ( DTM_NameplateBar[i].status == "UNUSED" ) then return DTM_NameplateBar[i]; end
    end
    return nil;
end

-- --------------------------------------------------------------------
-- **                            Methods                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * self:Display(nameplate, threat, percentage, hasAggro)            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> self: the nameplate bar.                                      *
-- * >> nameplate: the nameplate to attach the bar to.                *
-- * >> threat: the local player's threat value.                      *
-- * >> percentage: the local player's threat percentage.             *
-- * >> hasAggro: whether the local player has aggro.                 *
-- ********************************************************************
-- * Set up a nameplate bar on a visible nameplate.                   *
-- ********************************************************************
local function Display(self, nameplate, threat, percentage, hasAggro)
    if ( not nameplate or not percentage ) then return; end

    self.status = "RUNNING";

    if ( hasAggro ) then
        self:SetStatusBarColor(1.0, 0.0, 0.0, 1.0);
        self:SetMinMaxValues(0, 100);
  else
        self:SetStatusBarColor(0.0, 0.0, 1.0, 1.0);
        self:SetMinMaxValues(0, 130);
    end
    self:SetValue(percentage);

    self.threatText:SetText(DTM_GUI_FormatThreatValue(threat));
    self.percentText:SetText(string.format("%d%%", math.floor(percentage+0.5)));

    self:SetParent(nameplate);
    self:SetPoint("CENTER", nameplate, "BOTTOM", 0, 36);
    self:Show();
end

-- ********************************************************************
-- * self:Remove()                                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> self: the nameplate bar.                                      *
-- ********************************************************************
-- * Releases a nameplate. This is instant.                           *
-- ********************************************************************
local function Remove(self)
    self.status = "UNUSED";
    self:Hide();
end

-- --------------------------------------------------------------------
-- **                           Functions                            **
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                           Handlers                             **
-- --------------------------------------------------------------------

function DTM_NameplateBar_OnLoad(self)
    -- Sets frames variables.
    self.status = "UNUSED";

    -- Binds methods to the new frame.
    self.Display = Display;
    self.Remove = Remove;

    -- Grab child frames.
    self.threatText = getglobal(self:GetName().."_Threat");
    self.percentText = getglobal(self:GetName().."_ThreatPercent");

    -- Text resizing
    self.threatText:SetTextHeight(12);
    self.percentText:SetTextHeight(12);

    -- Ensure it is hidden at its creation.
    self:Hide();
end

function DTM_NameplateBar_OnUpdate(self, elapsed)
    if ( self.status == "UNUSED" ) then
        self:Hide();
        return;
    end

    -- ***** Set new frame properties *****
end