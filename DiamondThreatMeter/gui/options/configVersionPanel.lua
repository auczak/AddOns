local activeModule = "GUI configuration version panel";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local MAX_RESULT_ROWS = 13;

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_VersionPanel_OnLoad()
--
-- Called when the version panel is loaded.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_VersionPanel_OnLoad(self)
    -- Registers itself as a custom tab of Blizzard Interface options.

    self.name = DTM_Localise("configVersionCategory");
    self.parent = "DiamondThreatMeter";

    self.okay = function(self) end;
    self.cancel = function(self) end;
    self.default = function(self) end;

    InterfaceOptions_AddCategory(self);

    -- Do the translation of stuff we have to only do once.

    DTM_ConfigurationFrame_VersionPanel_YourVersion:SetText(format(DTM_Localise("configVersionYours"), DTM_GetVersionString()));
    DTM_ConfigurationFrame_VersionPanel_RequestButton:SetText(DTM_Localise("configVersionQuery"));
    DTM_ConfigurationFrame_VersionPanel_RequestResults:SetText(DTM_Localise("configVersionQueryResults"));

    -- Build the result rows, and resize the result frame to the maximum result rows at once.

    self.resultRow = { };

    for i=1, MAX_RESULT_ROWS do
        self.resultRow[i] = CreateFrame("Frame", self:GetName().."_ResultRow"..i, DTM_ConfigurationFrame_VersionPanel_ResultPanel, "DTM_ConfigurationFrame_ResultRowTemplate");
        self.resultRow[i].text1 = getglobal(self.resultRow[i]:GetName().."Text1");
        self.resultRow[i].text2 = getglobal(self.resultRow[i]:GetName().."Text2");
        self.resultRow[i]:SetPoint("TOPLEFT", DTM_ConfigurationFrame_VersionPanel_ResultPanel, "TOPLEFT", 8, -8-(i-1)*16);
        self.resultRow[i]:Show();
    end

    DTM_ConfigurationFrame_VersionPanel_ResultPanel:SetHeight( 16 + 16 * MAX_RESULT_ROWS );

    -- Refresh as it has just loaded up.

    DTM_ConfigurationFrame_VersionPanel_Refresh(self);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_VersionPanel_Refresh(self)
--
-- Called when version panel has to refresh its controls.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_VersionPanel_Refresh(self)
    DTM_ConfigurationFramePanel_Update(self);

    -- Display version results in the appropriate frame.

    local numResults = DTM_Version_GetNumResults();
    local currentResult = 0;
    local i;

    for i=1, MAX_RESULT_ROWS do
        currentResult = currentResult + 1;
        if ( currentResult <= numResults ) then
            verString = DTM_ConfigurationFrame_VersionPanel_GetVersionString(currentResult);
            self.resultRow[i].text1:SetText(verString);
  
    else
            self.resultRow[i].text1:SetText('');
        end

        currentResult = currentResult + 1;
        if ( currentResult <= numResults ) then
            verString = DTM_ConfigurationFrame_VersionPanel_GetVersionString(currentResult);
            self.resultRow[i].text2:SetText(verString);
  
    else
            self.resultRow[i].text2:SetText('');
        end
    end

    DTM_ConfigurationFrame_VersionPanel_OnUpdate(self, 0);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_VersionPanel_OnUpdate(self, elapsed)
--
-- Called when the version config panel is updated.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_VersionPanel_OnUpdate(self, elapsed)
    -- Update here infos etc. that can vary through time.

    -- We update the request button text and caption.

    local statusKey = "configVersionQueryOK";
    local status = DTM_Version_CanAsk();

    if ( status == "BUSY" ) then statusKey = "configVersionQueryBusy"; end;
    if ( status == "FLOOD" ) then statusKey = "configVersionQueryFlood"; end;
    if ( status == "NOT_GROUPED" ) then statusKey = "configVersionQueryNotGrouped"; end;

    DTM_ConfigurationFrame_VersionPanel_RequestButtonCaption:SetText(DTM_Localise(statusKey));

    if ( status ~= "OK" ) then
        DTM_ConfigurationFrame_VersionPanel_RequestButton:Disable();
  else
        DTM_ConfigurationFrame_VersionPanel_RequestButton:Enable();
    end
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_VersionPanel_OnVersionRequestDone()
--
-- Called when the engine's version API has finished performing its work.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_VersionPanel_OnVersionRequestDone()
    DTM_ConfigurationFrame_VersionPanel_Refresh(DTM_ConfigurationFrame_VersionPanel);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_VersionPanel_GetVersionString(resultIndex)
--
-- Formats a version query result obtained with engine's version API.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_VersionPanel_GetVersionString(resultIndex)
    local name, vString, system, major, minor, revision = DTM_Version_GetResultInfo(resultIndex);
    local formatString = "?";

    if ( system == "N/A" ) then
        formatString = format(DTM_Localise("configVersionNoneFormat"), vString);
  elseif ( system == "DTM" ) then
        formatString = format(DTM_Localise("configVersionDTMFormat"), vString);
  else
        formatString = format(DTM_Localise("configVersionOtherFormat"), system, vString);
    end

    return name.."|cffffffff - |r"..formatString;
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFrame_VersionPanel_Open()
--
-- This function allows you to open the version panel from an external way.
-----------------------------------------------------------------------------

function DTM_ConfigurationFrame_VersionPanel_Open()
    InterfaceOptionsFrame_OpenToFrame(DTM_ConfigurationFrame_VersionPanel);
end