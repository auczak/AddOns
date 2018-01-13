local activeModule = "GUI Error Console";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- This frame is a stand-alone frame which runs separate from DTM mod,
-- as such it is unaffected by DTM runtime errors.
-- It asks the errors handler module to send the errors reports to it.
--
-- The error console goal is also to give comfort to DTM user, by
-- preventing the error console from popping up while in combat, and
-- triggering the emergency stop for CRITICAL errors.
--
-- All DTM functions called from this module must be either functions whose
-- errors are handled the standard way with error() API or functions
-- that are run in noError mode.

-- --------------------------------------------------------------------
-- **                             Locals                             **
-- --------------------------------------------------------------------

local self = nil;

local OPEN_TIME = 1.000;
local CLOSE_TIME = 0.500;

-- --------------------------------------------------------------------
-- **                             Methods                            **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * errorConsole:Open(force)                                         *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> errorConsole: the error console frame.                        *
-- * >> force: if set, will force the opening even in combat.         *
-- ********************************************************************
-- * Asks the error console frame to pop up.                          *
-- * You can force the request even if in combat.                     *
-- ********************************************************************
local function Open(errorConsole, force)
    if type(errorConsole) ~= "table" then return; end
    if ( errorConsole.status ~= "STANDBY" and errorConsole.status ~= "CLOSING" ) then return; end

    -- Delay the opening.
    if ( not force ) and UnitAffectingCombat("player") then
         errorConsole.openRequest = 1;
         return;
     end

    errorConsole.status = "OPENING";
    errorConsole.timer = OPEN_TIME;
    errorConsole:Show();
end

-- ********************************************************************
-- * errorConsole:Close()                                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> errorConsole: the error console frame.                        *
-- ********************************************************************
-- * Asks the error console frame to shut off.                        *
-- ********************************************************************
local function Close(errorConsole)
    if type(errorConsole) ~= "table" then return; end
    if ( errorConsole.status ~= "OPENING" and errorConsole.status ~= "RUNNING" ) then return; end

    errorConsole.status = "CLOSING";
    errorConsole.timer = CLOSE_TIME;

    errorConsole.errorText:SetText("");
end

-- ********************************************************************
-- * errorConsole:SelectError(index)                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> errorConsole: the error console frame.                        *
-- * >> index: the index of error to display.                         *
-- ********************************************************************
-- * Changes the current error browsed in the error console.          *
-- * This method works even if the console is not displayed.          *
-- ********************************************************************
local function SelectError(errorConsole, index)
    if type(errorConsole) ~= "table" then return; end
    if type(index) ~= "number" then return; end

    local numErrors = DTM_GetNumErrors();

    if ( index >= numErrors ) then
        index = numErrors;
        errorConsole.nextButton:Disable();
  else
        errorConsole.nextButton:Enable();
    end
    if ( index <= 1 ) then
        errorConsole.prevButton:Disable();
  else
        errorConsole.prevButton:Enable();
    end
    if ( index < 1 ) and ( numErrors > 0 ) then index = 1; end

    errorConsole.currentError = index;

    if ( index > 0 ) then
        local errorType, module, info = DTM_GetErrorInfo(index);
        errorConsole.headerText:SetText(string.format(DTM_Localise("ErrorHeader", 1), index, DTM_Localise("ErrorType:"..errorType, 1), module));
        errorConsole.errorInfo = info;
  else
        errorConsole.headerText:SetText(DTM_Localise("ErrorHeaderNoError", 1));
        errorConsole.errorInfo = "";
    end

    if ( errorConsole.status ~= "RUNNING" ) then
        errorConsole.errorText:SetText(""); -- Error text box is left empty for the duration of the zoom.
  else
        errorConsole.errorText:SetText(errorConsole.errorInfo);
    end

    errorConsole.positionText:SetText(string.format(DTM_Localise("ErrorPosition", 1), index, numErrors));
end

-- ********************************************************************
-- * errorConsole:MoveError(value)                                    *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> errorConsole: the error console frame.                        *
-- * >> value: the change on the currently displayed error index.     *
-- ********************************************************************
-- * Steps forward or backward from a given value in the error        *
-- * console. 1 moves to the next error, -1 goes to the previous.     *
-- ********************************************************************
local function MoveError(errorConsole, value)
    if type(errorConsole) ~= "table" then return; end
    if type(value) ~= "number" then return; end

    errorConsole:SelectError(errorConsole.currentError + value);
end

-- --------------------------------------------------------------------
-- **                             Handlers                           **
-- --------------------------------------------------------------------

function DTM_ErrorConsole_OnLoad(errorConsole)
    self = errorConsole;

    -- Children
    self.prevButton = getglobal(self:GetName().."_PrevButton");
    self.nextButton = getglobal(self:GetName().."_NextButton");
    self.positionText = getglobal(self:GetName().."_Position");
    self.headerText = getglobal(self:GetName().."_Header");
    self.errorText = getglobal(self:GetName().."_ErrorText");

    -- Properties
    self.status = "STANDBY";
    self.timer = 0.000;
    self.currentError = 0;
    self.openRequest = nil;
    self.errorInfo = "";

    -- Methods
    self.Open = Open;
    self.Close = Close;
    self.SelectError = SelectError;
    self.MoveError = MoveError;

    -- Errors registration
    DTM_RegisterForErrors(DTM_ErrorConsole_OnError, "MINOR");

    -- Displays no error stuff
    self:SelectError(0);
end

function DTM_ErrorConsole_OnUpdate(elapsed)
    if type(self) ~= "table" then return; end

    if ( not UnitAffectingCombat("player") ) and ( self.openRequest ) then
        self.openRequest = nil;
        self:Open(1);
    end

    if ( self.status == "STANDBY" ) then
        self:Hide();
        return;
    end

    local scale = 1.0;

    if ( self.status == "OPENING" ) then
        self.timer = max(0, self.timer - elapsed);
        if ( self.timer == 0 ) then
            self.status = "RUNNING";
            self.errorText:SetText(self.errorInfo); -- Only show content in error text box after the zoom.
        end
        scale = 1 - self.timer / OPEN_TIME;
    end
    if ( self.status == "CLOSING" ) then
        self.timer = max(0, self.timer - elapsed);
        if ( self.timer == 0 ) then self.status = "STANDBY" end
        scale = self.timer / CLOSE_TIME;
    end

    self:SetScale(max(0.01, scale));
    self:SetAlpha(scale);
end

function DTM_ErrorConsole_OnError(errorType, module, info)
    if type(self) ~= "table" then return; end

    self:SelectError(DTM_GetNumErrors()); -- When an error occur, it's always the last entry in GetErrorInfo() API that holds its data.
    self:Open();

    if UnitAffectingCombat("player") then
        DTM_ChatMessage(string.format(DTM_Localise("ErrorInCombat", 1), DTM_Localise("ErrorType:"..errorType, 1)), 1);
    end

    -- Additionnal measure: emergency stop trigger when the error type is critical.
    -- We use protected call in case the API is not available for some reason, to not further trigger pointless errors.
    if ( errorType == "CRITICAL" ) then
        pcall(DTM_SetEmergencyStop, "ON", nil);
    end
end