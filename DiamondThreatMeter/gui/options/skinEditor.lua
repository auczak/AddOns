local activeModule = "Skin editor";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                            Methods                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * me:StartEdit(skinName)                                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> me: the skin editor frame.                                    *
-- * >> skinName: the name of the skin to edit. It must exist.        *
-- ********************************************************************
-- * Ask the skin editor to edit a given skin. Will fail if a skin is *
-- * already being edited by the editor. It will lock the skin        *
-- * manager down.                                                    *
-- ********************************************************************
local function StartEdit(me, skinName)
    if ( me.editedSkin ) and ( me.editedData ) then return; end

    local skinData = DTM_GetSkinData(skinName);

    if type(skinData) == "table" then
        me.editedSkin = skinName;
        me.editedData = skinData;
        me.currentCategory = 1;
        me.testList:Reset();
        me.testList:Display();
        me:Update();
        me:Show();
        PlaySound("UChatScrollButton");

        DTM_SkinManager:Lock();
        InterfaceOptionsFrame:SetAlpha(0.50);
    end
end

-- ********************************************************************
-- * me:FinishEdit()                                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> me: the skin editor frame.                                    *
-- ********************************************************************
-- * Validate the modifications on the edited skin and shut the skin  *
-- * editor frame. Skin manager will then be unlocked.                *
-- ********************************************************************
local function FinishEdit(me)
    if not ( me.editedSkin ) or not ( me.editedData ) then return; end

    me.editedSkin = nil;
    me.editedData = nil;
    me:Hide();
    PlaySound("gsTitleOptionOK");

    DTM_SkinManager:Unlock();
    InterfaceOptionsFrame:SetAlpha(1.00);
    DTM_GUI_OnSkinEvent("SKIN_REFRESH");
end

-- ********************************************************************
-- * me:Update()                                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> me: the skin editor frame.                                    *
-- ********************************************************************
-- * Update the skin editor to reflect the settings of the skin       *
-- * currently edited.                                                *
-- ********************************************************************
local function Update(me)
    if not ( me.editedSkin ) or not ( me.editedData ) then return; end

    -- Update widgets & Hide all unused categories.
    local c;
    for c=1, me.numCategories do
        local category = me.categories[c];
        category:Hide();

        local w;
        for w=1, category.numWidgets do
            local object = category.widgets[w];
            if type(object) == "table" then
                local settingValue = DTM_GetSkinSetting(me.editedData, object.category, object.setting);

                if ( object.family == "CHECKBOX" and object.dataType == "BOOLEAN" ) then
                    if ( settingValue == 1 ) then
                        object:SetChecked(true);
                  else
                        object:SetChecked(false);
                    end
                end

                if ( object.family == "SLIDER" and object.dataType == "NUMBER" ) then
                    settingValue = tonumber(settingValue) or 0;
                    object:SetValue(settingValue);
                end

                if ( object.dataType == "STRING" ) then
                    -- Several ways of producing a string.
                    if ( object.family == "DROPDOWN" ) then
                        if ( object.valueList ) then
                            local i;
                            for i=1, #object.valueList do
                                if ( object.valueList[i] == settingValue ) then
                                    UIDropDownMenu_SetSelectedID(object, i);
                                    getglobal(object:GetName().."Text"):SetText(DTM_Localise(object.stringList[i], true) or settingValue);
                                end
	                    end
                        end
                    end
                    if ( object.family == "EDITBOX" ) then
                        object:SetText(settingValue or '');
                    end
                end

                if ( object.family == "COLUMN" and object.dataType == "COLUMN" ) then
                    if type(settingValue) == "table" then
                       if ( settingValue.enabled == 1 ) then object.enabled:SetChecked(1); else object.enabled:SetChecked(nil); end
                       object.position:SetValue(settingValue.offset);
                       object.justifyLeft:SetChecked(nil);
                       object.justifyCenter:SetChecked(nil);
                       object.justifyRight:SetChecked(nil);
                       if ( settingValue.justification == "LEFT" )   then object.justifyLeft:SetChecked(1); end
                       if ( settingValue.justification == "CENTER" ) then object.justifyCenter:SetChecked(1); end
                       if ( settingValue.justification == "RIGHT" )  then object.justifyRight:SetChecked(1); end
                  else
                        -- Invalid data type
                    end
                end
            end
        end
    end

    -- Position, setup etc. the active category.
    local catFrame = me.categories[me.currentCategory];
    if type(catFrame) == "table" then
        catFrame:SetPoint("BOTTOM", me, "BOTTOM", 0, 40);
        catFrame:Show();
    end

    -- Indicate the current category edited.
    DTM_SkinEditor_CategoryText:SetText(string.format(DTM_Localise("configSkinEditorCategory"), me.currentCategory, me.numCategories));

    -- The cute title.
    DTM_SkinEditor_TitleText:SetText(me.editedSkin);
end

-- --------------------------------------------------------------------
-- **                           Functions                            **
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                           Handlers                             **
-- --------------------------------------------------------------------

-- ***** Skin editor frame and elements *****

function DTM_SkinEditor_OnLoad(self)
    -- Set frame vars.
    self.editedSkin = nil;
    self.editedData = nil;

    -- Bind methods.
    self.StartEdit = StartEdit;
    self.FinishEdit = FinishEdit;
    self.Update = Update;

    -- Setup the test list.
    self.testList = DTM_SkinEditor_TestList;
    self.testList.ignoreDrag = true;
    self.testList.ignoreDropDown = true;
    self.testList.unit = "test";
    self.testList.altUnit = nil;
    self.testList.warningPosition = 1;
    self.testList.standbyBaseKey = "Invalid";
    self.testList:SetParent(self);
    self.testList:ClearAllPoints();
    self.testList:SetPoint("TOP", self, "TOP", 0, -40);
    self.testList:SetFrameStrata("DIALOG");

    -- Translation of elements that do not change.
    DTM_SkinEditor_PreviewButton:SetText(DTM_Localise("configSkinEditorPreview"));
    DTM_SkinEditor_FinishButton:SetText(DTM_Localise("configSkinEditorFinish"));

    -- Build each category frame
    self.currentCategory = 0;
    self.numCategories = DTM_SkinSchema_GetNumCategories();
    self.categories = {};
    local c;
    for c=1, self.numCategories do
        local name, position, numWidgets = DTM_SkinSchema_GetCategoryInfo(c);
        self.categories[position] = CreateFrame("Frame", self:GetName().."_"..name, self, "DTM_SkinEditor_CategoryFrameTemplate");
        DTM_SkinEditor_SetupCategory(self.categories[position], name, numWidgets);
    end

    self:Hide();
end

function DTM_SkinEditor_SetupCategory(frame, name)
    frame.name = name;

    frame.numWidgets = DTM_SkinSchema_GetNumSettings(name);
    frame.widgets = {};
    local w;

    -- Step 1: Create
    for w=1, frame.numWidgets do
        local objName, position, dataType, dataTable = DTM_SkinSchema_GetSettingInfo(name, w);
        local displayName = DTM_Localise("skinSchema-"..objName, true) or objName;
        local object = nil;

        if ( dataTable.object == "CHECKBOX" ) then
            frame.widgets[position] = CreateFrame("CheckButton", frame:GetName().."_"..objName, frame, "DTM_SkinEditor_CheckButtonTemplate");
            object = frame.widgets[position];

            getglobal(object:GetName().."Text"):SetText(displayName);
            object:SetHitRectInsets(0, -getglobal(object:GetName().."Text"):GetStringWidth(), 0, 0);
        end

        if ( dataTable.object == "SLIDER" ) then
            frame.widgets[position] = CreateFrame("Slider", frame:GetName().."_"..objName, frame, "DTM_SkinEditor_SliderTemplate");
            object = frame.widgets[position];

            local lowBound, highBound, valueTemplate, step = "%d", "%d", "%d", dataTable.step;
            if ( step < 0.1 ) then
                lowBound, highBound, valueTemplate = "%.2f", "%.2f", "%.2f";
        elseif ( step < 1 ) then
                lowBound, highBound, valueTemplate = "%.1f", "%.1f", "%.1f";
            end
            lowBound = string.format(lowBound, dataTable.minValue);
            highBound = string.format(highBound, dataTable.maxValue);

            object:SetMinMaxValues(dataTable.minValue, dataTable.maxValue);
            object:SetValueStep(step);

            object.valueTextTemplate = valueTemplate;
            getglobal(object:GetName().."Text"):SetText(displayName);
            getglobal(object:GetName().."Low"):SetText(lowBound);
            getglobal(object:GetName().."High"):SetText(highBound);
        end

        if ( dataTable.object == "DROPDOWN" ) then
            frame.widgets[position] = CreateFrame("Frame", frame:GetName().."_"..objName, frame, "DTM_SkinEditor_DropDownTemplate");
            object = frame.widgets[position];

            object.width = dataTable.width or 128;
            object.valueList = dataTable.dropDownList;
            object.stringList = dataTable.dropDownString;
            object.tooltipList = dataTable.dropDownTooltip;

            local initializeDropDown = function()
                                   local dropDown = getglobal(UIDROPDOWNMENU_INIT_MENU);
                                   if not ( dropDown.valueList ) or not ( dropDown.stringList ) then return; end
                                   local info = UIDropDownMenu_CreateInfo();
                                   for i=1, #dropDown.valueList do
                                       info.text = DTM_Localise(dropDown.stringList[i], true) or dropDown.valueList[i];
                                       if ( not DTM_OnWotLK() ) then
                                           info.func = function(dropDown, index) DTM_SkinEditor_DropDown_OnSelection(dropDown, index); end;
                                     else
                                           info.func = function(self, dropDown, index) DTM_SkinEditor_DropDown_OnSelection(dropDown, index); end;
                                       end
                                       info.arg1 = dropDown;
                                       info.arg2 = i;
                                       info.checked = nil;
                                       info.tooltipTitle = info.text;
                                       if ( dropDown.tooltipList ) then
                                           info.tooltipText = DTM_Localise(dropDown.tooltipList[i], true);
                                     else
                                           info.tooltipText = nil;
                                       end
                                       UIDropDownMenu_AddButton(info);
	                           end
                               end;
            UIDropDownMenu_Initialize(object, initializeDropDown);
            if ( DTM_OnWotLK() ) then
                UIDropDownMenu_SetWidth(object, object.width);
          else
                UIDropDownMenu_SetWidth(object.width, object); -- You were bad on this one, Blizz ! Boooh !
            end
            UIDropDownMenu_SetSelectedID(object, 1);
            getglobal(object:GetName().."Caption"):SetText(displayName);
        end

        if ( dataTable.object == "EDITBOX" ) then
            frame.widgets[position] = CreateFrame("EditBox", frame:GetName().."_"..objName, frame, "DTM_SkinEditor_EditBoxTemplate");
            object = frame.widgets[position];

            object.width = dataTable.width or 128;
            object.maxChars = dataTable.maxChars or 64;

            object:SetWidth(object.width);
            object:SetMaxLetters(object.maxChars);

            getglobal(object:GetName().."Text"):SetText(displayName);
        end

        if ( dataTable.object == "COLUMN" ) then
            frame.widgets[position] = CreateFrame("Frame", frame:GetName().."_"..objName, frame, "DTM_SkinEditor_ColumnEditorTemplate");
            object = frame.widgets[position];

            if ( dataTable.content == "TEXT" ) then
                -- Justification is relevant.
                object.hasJustification = 1;
                object.justifyText:Show();
                object.justifyLeft:Show();
                object.justifyCenter:Show();
                object.justifyRight:Show();
          else
                -- Remove the justification checkbuttons
                object.hasJustification = nil;
                object.justifyText:Hide();
                object.justifyLeft:Hide();
                object.justifyCenter:Hide();
                object.justifyRight:Hide();
            end

            getglobal(object:GetName().."Title"):SetText(displayName);
        end

        -- Binds common properties.
        if type(object) == "table" then
            object.family = dataTable.object;
            object.category = name;
            object.setting = objName;
            object.dataType = dataType;
            object.tooltipText = "|cffffffff"..displayName.."|r";
            object.tooltipRequirement = DTM_Localise("skinSchema-"..objName.."-Tooltip", true);
            object.needRefresh = dataTable.needRefresh;
        end
    end

    local maxX = 256;
    local curY = -32;

    -- Step 2: Position
    for w=1, frame.numWidgets do
        local object = frame.widgets[w];

        if type(object) == "table" then
            if ( object.family == "CHECKBOX" ) then
                object:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, curY);
                curY = curY - 24;
                maxX = max(maxX, getglobal(object:GetName().."Text"):GetStringWidth() + 64); -- Ensure we've got enough room on X-axis.
            end

            if ( object.family == "SLIDER" ) then
                object:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, curY);
                curY = curY - 28;
                maxX = max(maxX, getglobal(object:GetName().."Text"):GetStringWidth() + 192);
            end

            if ( object.family == "DROPDOWN" ) then
                object:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, curY);
                curY = curY - 32;
                maxX = max(maxX, getglobal(object:GetName().."Caption"):GetStringWidth() + object.width + 64);
            end

            if ( object.family == "EDITBOX" ) then
                object:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, curY-6);
                curY = curY - 32;
                maxX = max(maxX, getglobal(object:GetName().."Text"):GetStringWidth() + object.width + 52);
            end

            if ( object.family == "COLUMN" ) then
                object:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, curY);
                curY = curY - 48;
                maxX = max(maxX, 16*2+384);
            end

            object:Show();
        end
    end
    curY = curY - 12;

    -- Set the category title
    frame.titleText = getglobal(frame:GetName().."_TitleText");
    frame.titleTexture = getglobal(frame:GetName().."_TitleTexture");
    frame.titleText:SetText(DTM_Localise("skinSchema-"..name, true) or name);
    local headerWidth = max(256, frame.titleText:GetStringWidth()+32);
    frame.titleTexture:SetWidth(headerWidth);

    frame:SetWidth(maxX);
    frame:SetHeight(-curY);
    frame:Hide();
end

function DTM_SkinEditor_PreviewButton_OnClick(self, button)
    DTM_SkinEditor_TestList:Reset();
    DTM_SkinEditor_TestList:Display();
end

function DTM_SkinEditor_Move(value)
    local me = DTM_SkinEditor;
    me.currentCategory = max(1, me.currentCategory + value);
    me.currentCategory = min(me.numCategories, me.currentCategory);
    me:Update();
end

-- ***** Complex controls handlers *****

function DTM_SkinEditor_ColumnEditor_OnLoad(self)
    self.enabled  = getglobal(self:GetName().."_EnabledCheckButton");
    self.position = getglobal(self:GetName().."_PositionSlider");
    self.justifyText   = getglobal(self:GetName().."Justification");
    self.justifyLeft   = getglobal(self:GetName().."_JustifyLeft");
    self.justifyCenter = getglobal(self:GetName().."_JustifyCenter");
    self.justifyRight  = getglobal(self:GetName().."_JustifyRight");

    getglobal(self:GetName().."Enabled"):SetText(DTM_Localise("Enabled"));
    getglobal(self:GetName().."Position"):SetText(DTM_Localise("Position"));
    self.justifyText:SetText(DTM_Localise("Justification"));
end

-- ***** Skin editor dynamic widgets *****

function DTM_SkinEditor_CheckButton_OnClick(self, button)
    local me = DTM_SkinEditor;
    if not ( me.editedSkin ) or not ( me.editedData ) then return; end

    if ( self:GetChecked() ) then
        me.editedData[self.category][self.setting] = 1;
  else
        me.editedData[self.category][self.setting] = 0;
    end

    if ( self.needRefresh ) then
        DTM_GUI_OnSkinEvent("SKIN_RESET_NEEDED");
    end

    DTM_GUI_OnSkinEvent("SKIN_REFRESH");
end

function DTM_SkinEditor_Slider_OnValueChanged(self)
    -- Set the current value text of the slider.
    local newValueText = string.format(self.valueTextTemplate or "%d", self:GetValue());
    getglobal(self:GetName().."Value"):SetText(newValueText);

    local me = DTM_SkinEditor;
    if not ( me.editedSkin ) or not ( me.editedData ) then return; end

    me.editedData[self.category][self.setting] = self:GetValue();

    if ( self.needRefresh ) then
        DTM_GUI_OnSkinEvent("SKIN_RESET_NEEDED");
    end
    DTM_GUI_OnSkinEvent("SKIN_REFRESH");
end

function DTM_SkinEditor_DropDown_OnSelection(dropDown, index)
    UIDropDownMenu_SetSelectedID(dropDown, index);

    local me = DTM_SkinEditor;
    if not ( me.editedSkin ) or not ( me.editedData ) then return; end

    me.editedData[dropDown.category][dropDown.setting] = dropDown.valueList[index];

    if ( dropDown.needRefresh ) then
        DTM_GUI_OnSkinEvent("SKIN_RESET_NEEDED");
    end
    DTM_GUI_OnSkinEvent("SKIN_REFRESH");
end

function DTM_SkinEditor_EditBox_ValidateValue(self)
    local me = DTM_SkinEditor;
    if not ( me.editedSkin ) or not ( me.editedData ) then return; end

    me.editedData[self.category][self.setting] = self:GetText() or '';

    if ( self.needRefresh ) then
        DTM_GUI_OnSkinEvent("SKIN_RESET_NEEDED");
    end
    DTM_GUI_OnSkinEvent("SKIN_REFRESH");
end

function DTM_SkinEditor_ColumnEditor_OnPropertyChange(self, propertyController)
    local me = DTM_SkinEditor;
    if not ( me.editedSkin ) or not ( me.editedData ) then return; end

    local newValue = 0;

    if ( propertyController.type == "BOOLEAN" ) then
        if ( propertyController:GetChecked() ) then newValue = 1; end

elseif ( propertyController.type == "NUMBER" ) then
        newValue = propertyController:GetValue();

elseif ( propertyController.type == "GENERAL" ) then
        newValue = propertyController.value;
    end
 
    me.editedData[self.category][self.setting][propertyController.property] = newValue;

    -- We need an advanced update for the justification checkbuttons
    if ( propertyController.type == "GENERAL" ) then
        me:Update();
    end

    if ( self.needRefresh ) then
        DTM_GUI_OnSkinEvent("SKIN_RESET_NEEDED");
    end
    DTM_GUI_OnSkinEvent("SKIN_REFRESH");
end