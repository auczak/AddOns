local activeModule = "GUI Common list";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                            Methods                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * listFrame:Destroy()                                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> listFrame: the list frame to operate on.                      *
-- ********************************************************************
-- * Stops displaying a list frame. Note that the frame isn't         *
-- * hidden instantly.                                                *
-- ********************************************************************
local function Destroy(listFrame)
    if ( listFrame:IsShown() ) then
        listFrame.status = "CLOSING";
    end
end

-- ********************************************************************
-- * listFrame:GetStatus()                                            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> listFrame: the list frame to operate on.                      *
-- ********************************************************************
-- * Gets the general status of a list frame, and the unit it         *
-- * is watching.                                                     *
-- * Status can be UNUSED, BOOTING, READY, GRABBING, RUNNING, CLOSING.*
-- ********************************************************************
local function GetStatus(listFrame)
    return listFrame.status, listFrame.unit;
end

-- ********************************************************************
-- * listFrame:ApplyCommonSkin()                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> listFrame: the list frame to operate on.                      *
-- ********************************************************************
-- * Apply the common list skin to the given list frame.              *
-- ********************************************************************
local function ApplyCommonSkin(listFrame)
    local cfg = DTM_GetCurrentSkinSetting;

    listFrame.baseAlpha = cfg("General", "Alpha");
    listFrame.scale = cfg("General", "Scale");
    listFrame.fadeCoeff = cfg("Bars", "FadeCoeff") + 0.001; -- The added 0.001 will prevent divisions by zero.
    listFrame.sortCoeff = cfg("Bars", "SortCoeff") + 0.001;
    listFrame.isLocked = cfg("General", "LockFrames");
    listFrame.useAggroLightning = cfg("Bars", "AggroGraphicEffect");

    -- Prepare the widget if there's one. Adjust the header text in function.
    listFrame.widgetTexture = cfg("Display", "WidgetTexture") or '';
    listFrame.widgetPositionX = cfg("Display", "WidgetPositionX");
    listFrame.widgetPositionY = cfg("Display", "WidgetPositionY");
    listFrame.headerText:ClearAllPoints();
    if ( #listFrame.widgetTexture > 0 ) then
        listFrame.headerTexture:SetTexture(DTM_Resources_GetAbsolutePath("GFX", listFrame.widgetTexture));
        listFrame.headerTexture:Show();
        if ( listFrame.widgetPositionX > 0.5 ) then
            listFrame.headerText:SetPoint("BOTTOMLEFT", listFrame, "TOPLEFT", 0, 0);
      else
            listFrame.headerText:SetPoint("BOTTOMRIGHT", listFrame, "TOPRIGHT", 0, 0);
        end
  else
        listFrame.headerTexture:Hide();
        listFrame.headerText:SetPoint("BOTTOM", listFrame, "TOP", 0, 0);
    end

    -- Handle the backdrop
    local r, g, b, a = 0.2, 0.2, 0.2, 0.5;
    listFrame.edgeTexture = cfg("Display", "EdgeTexture") or '';
    listFrame.tileTexture = cfg("Display", "TileTexture") or '';

    -- Use Blizzard tooltip backdrop in case no texture is specified.
    if ( #listFrame.edgeTexture == 0 ) then
        listFrame.edgeTexture = "Interface\\Tooltips\\UI-Tooltip-Border";
        listFrame.backdrop.edgeSize = 16;
  else
        listFrame.edgeTexture = DTM_Resources_GetAbsolutePath("GFX", listFrame.edgeTexture);
        listFrame.backdrop.edgeSize = 8;
        listFrame:SetBackdropBorderColor(1.0, 1.0, 1.0, 1.0);
    end
    if ( #listFrame.tileTexture == 0 ) then
        listFrame.tileTexture = "Interface\\Tooltips\\UI-Tooltip-Background";
        listFrame.backdrop.tileSize = 16;
  else
        listFrame.tileTexture = DTM_Resources_GetAbsolutePath("GFX", listFrame.tileTexture);
        listFrame.backdrop.tileSize = 8;
        r, g, b, a = 1.0, 1.0, 1.0, 0.5;
    end

    listFrame.backdrop.bgFile = listFrame.tileTexture;
    listFrame.backdrop.edgeFile = listFrame.edgeTexture;
    listFrame.backdrop.insets.left = 3;
    listFrame.backdrop.insets.right = 3;
    listFrame.backdrop.insets.top = 3;
    listFrame.backdrop.insets.bottom = 3;

    if ( cfg("Display", "BackdropUseTile") == 1 ) then
        listFrame.backdrop.tile = true;
  else
        listFrame.backdrop.tile = false;
    end

    listFrame:SetBackdrop(listFrame.backdrop);
    listFrame:SetBackdropBorderColor(1.0, 1.0, 1.0, 1.0);
    listFrame:SetBackdropColor(r, g, b, a);
end

-- ********************************************************************
-- * listFrame:AdjustWidth()                                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> listFrame: the list frame to operate on.                      *
-- ********************************************************************
-- * Adjust the width of a list and its common children according     *
-- * to the value of .barWidth stored in the listFrame data table.    *
-- ********************************************************************
local function AdjustWidth(listFrame)
    listFrame:SetWidth(listFrame.barWidth + 16);
    listFrame.headerText:SetWidth(listFrame.barWidth-16);

    if ( listFrame.standbyFrame ) then
        listFrame.standbyFrame:SetWidth(listFrame.barWidth);
        listFrame.standbyFrame.standbyText:SetWidth(listFrame.barWidth);
    end
    if ( listFrame.headerRow ) then
        listFrame.headerRow:SetWidth(listFrame.barWidth);
        listFrame.headerRow.unitInfo:SetWidth(listFrame.barWidth);
    end

    if ( #listFrame.widgetTexture > 0 ) then
        listFrame.headerTexture:ClearAllPoints();
        listFrame.headerTexture:SetPoint("TOP", listFrame, "TOPLEFT", listFrame.widgetPositionX * listFrame:GetWidth(), listFrame.widgetPositionY);
    end
end

-- ********************************************************************
-- * listFrame:SetVerticalAnchor(anchor)                              *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> listFrame: the list frame to operate on.                      *
-- * >> anchor: the new vertical anchor.                              *
-- * Can be "AUTO", "TOP", "CENTER" or "BOTTOM".                      *
-- ********************************************************************
-- * Change the vertical anchor of the list.                          *
-- * This will eventually cause the list to be repositionned.         *
-- ********************************************************************
local function SetVerticalAnchor(listFrame, anchor)

end

-- These methods are available to any list inherited from commonList.

-- --------------------------------------------------------------------
-- **                           Functions                            **
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                           Handlers                             **
-- --------------------------------------------------------------------

function DTM_CommonListFrame_OnLoad(self)
    -- Sets frames variables.
    self.alpha = 0.00;
    self.height = 48;
    self.status = "UNUSED";

    -- Binds methods to the new frame.
    self.Destroy = Destroy;
    self.GetStatus = GetStatus;
    self.ApplyCommonSkin = ApplyCommonSkin;
    self.AdjustWidth = AdjustWidth;
    self.SetVerticalAnchor = SetVerticalAnchor;

    -- Grab child frames.
    self.standbyFrame = getglobal(self:GetName().."_StandbyFrame");
    self.headerRow = getglobal(self:GetName().."_HeaderRow");

    -- Setup header.
    self.headerText = getglobal(self:GetName().."_HeaderText");
    self.headerText:SetText( format(DTM_Localise("guiHeader"), DTM_GetVersionString()) );
    self.headerTexture = getglobal(self:GetName().."_HeaderTexture");

    -- Make the list clickable, so it can generate OnClick events.
    self:RegisterForClicks("RightButtonDown");
    self:Enable();

    -- Grab and set up the dropdown.
    self.dropDown = getglobal(self:GetName().."_DropDown");
    UIDropDownMenu_Initialize(self.dropDown, DTM_CommonListFrame_InitializeDropDown, "MENU");
    self.commonCommands = {
        --[[
        [1] = {
            type = "SUBMENU",
            name = DTM_Localise("anchorSetting"),
            call = "DTM_CommonListFrame_GetAnchorMenu",
            frame = self,
            tooltipTitle = nil,
            tooltipExplain = DTM_Localise("anchorSettingTooltip"),
        },
        ]]
        [1] = {
            type = "METHOD",
            name = CLOSE,
            call = "Destroy",
            frame = self,
            tooltipTitle = nil,
            tooltipExplain = nil,
        },
        [2] = {
            type = "CANCEL",
            name = CANCEL,
            tooltipTitle = nil,
            tooltipExplain = nil,
        },
    };

    -- Prepare the backdrop table.
    self.backdrop = { insets = {} };

    -- Grab the configId, which is an attribute.
    self.configId = self:GetAttribute("configId");

    -- Ensure it is hidden at its creation.
    self:Hide();
end

function DTM_CommonListFrame_OnUpdate(self, elapsed)
    if ( self.status == "UNUSED" ) then
        self:Hide();
        return;
    end

    -- ***** Handle resizing of the frame *****

    if ( self.targetHeight ) and ( self.height ~= self.targetHeight ) then
        if ( self.height < self.targetHeight ) then
            self.height = min(self.targetHeight, self.height + elapsed * 16 / (0.200 * self.fadeCoeff));
      else
            self.height = max(self.targetHeight, self.height - elapsed * 16 / (0.200 * self.fadeCoeff));
        end
    end

    -- ***** Set new frame properties *****

    self:SetHeight(self.height);
    self:SetAlpha(self.alpha * self.baseAlpha);
    self:SetScale(self.scale);
end

function DTM_CommonListFrame_OnClick(self, button)
    if ( self.status == "UNUSED" or self.status == "CLOSING" ) then
        -- Ignore clicks on shutting or unused frames.
        return;
    end

    if button ~= "RightButton" then return; end

    if type(self.dropDown) == 'table' and not ( self.ignoreDropDown ) then
        HideDropDownMenu(1);
        ToggleDropDownMenu(1, nil, self.dropDown, "cursor");
        PlaySound("igMainMenuOpen");
    end
end

function DTM_CommonListFrame_InitializeDropDown()
    local info;

    local function AddCommandList(commandTable)
        if type(commandTable) ~= "table" then return; end
        local index, data;
        for index, data in ipairs(commandTable) do
            info              = UIDropDownMenu_CreateInfo();
            info.text         = data.name;
            info.notCheckable = 1;
            info.tooltipTitle = data.tooltipTitle or data.name;
            info.tooltipText  = data.tooltipExplain;

            if ( data.type == "METHOD" ) then
                local callValue = data.frame[data.call];
                if type(data.frame) == 'table' and type(callValue) == 'function' then
                    if ( not DTM_OnWotLK() ) then
                        info.func = callValue;
                  else
                        -- Some hack to get rid of the "self" useless argument in WotLK client.
                        info.func = function(self, ...) callValue(...); end;
                    end
                    info.arg1 = data.frame;
                end

        elseif ( data.type == "FUNCTION" ) then
                local callValue = getglobal(data.call);
                if type(callValue) == 'function' then
                    if ( not DTM_OnWotLK() ) then
                        info.func = callValue;
                  else
                        -- Some hack to get rid of the "self" useless argument in WotLK client.
                        info.func = function(self) callValue(); end;
                    end
                end

        elseif ( data.type == "SUBMENU" ) then
                local callValue = getglobal(data.call);
                if type(callValue) == 'function' then
                    info.keepShownOnClick = true;
                    info.hasArrow = true;
                    -- local options = callValue(data.frame);
                    -- local o;
                    -- for _, o in ipairs(options) do
                    --     UIDropDownMenu_AddButton(info, o);
                    -- end
                end

        elseif ( data.type == "CANCEL" ) then
                info.func = function() end;
          else
                error(format("An unknown command type has been encountered (%s).", data.type or 'nil'), 0);
            end

            UIDropDownMenu_AddButton(info);
        end
    end

    local listAffected = getglobal(UIDROPDOWNMENU_INIT_MENU):GetParent();

    -- Add first the specific commands, then the common commands.

    AddCommandList(listAffected.commands);
    AddCommandList(listAffected.commonCommands);
end

local myTable = { };
function DTM_CommonListFrame_GetAnchorMenu(list)
    local k, v;
    for k, v in pairs(myTable) do myTable[k] = nil; end
    myTable[#myTable+1] = {
        text = DTM_Localise("Auto"),
        func = list.SetVerticalAnchor,
        arg1 = list,
        arg2 = "AUTO",
    };
    myTable[#myTable+1] = {
        text = DTM_Localise("Top"),
        func = list.SetVerticalAnchor,
        arg1 = list,
        arg2 = "TOP",
    };
    myTable[#myTable+1] = {
        text = DTM_Localise("Center"),
        func = list.SetVerticalAnchor,
        arg1 = list,
        arg2 = "CENTER",
    };
    myTable[#myTable+1] = {
        text = DTM_Localise("Bottom"),
        func = list.SetVerticalAnchor,
        arg1 = list,
        arg2 = "BOTTOM",
    };
    return myTable;
end