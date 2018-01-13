local activeModule = "GUI configuration panel templates";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                            GUI PART                            --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **               DTM configuration widgets functions              **
-- --------------------------------------------------------------------

-----------------------------------------------------------------------------
-- DTM_ConfigurationFramePanel_SetSlider(slider, min, max, step,
--                                       valText, minText, maxText,
--                                       captionText, tooltipText)
--
-- Called when a configuration panel wishes to configure easily a slider.
-----------------------------------------------------------------------------

function DTM_ConfigurationFramePanel_SetSlider(slider, min, max, step, valText, minText, maxText, captionText, tooltipText)
    slider.valueTextTemplate = valText;
    getglobal(slider:GetName().."Text"):SetText(captionText);
    getglobal(slider:GetName().."High"):SetText(maxText);
    getglobal(slider:GetName().."Low"):SetText(minText);
    slider:SetMinMaxValues(min, max);
    slider:SetValueStep(step);

    if ( captionText and #captionText > 0 ) and ( tooltipText ) then
        slider.tooltipText = "|cffffffff"..captionText.."|r";
        slider.tooltipRequirement = tooltipText;
  else
        slider.tooltipText = nil;
        slider.tooltipRequirement = nil;
    end
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFramePanel_SetDropDown(dropDown, width, valueList, tooltipList, disableList)
--
-- Called when a configuration panel wishes to configure easily a drop down.
-----------------------------------------------------------------------------

function DTM_ConfigurationFramePanel_SetDropDown(dropDown, width, valueList, tooltipList, disableList)
    dropDown.valueList = valueList;
    dropDown.tooltipList = tooltipList;
    dropDown.disableList = disableList;

    local initializeDropDown = function()
                                   local dropDown = getglobal(UIDROPDOWNMENU_INIT_MENU);
                                   if not ( dropDown.valueList ) then return; end
                                   local info = UIDropDownMenu_CreateInfo();
                                   for i=1, #dropDown.valueList do
                                       info.text = dropDown.valueList[i];
                                       if ( not DTM_OnWotLK() ) then
                                           info.func = function(dropDown, index) UIDropDownMenu_SetSelectedID(dropDown, index, 1); end;
                                     else
                                           info.func = function(self, dropDown, index) UIDropDownMenu_SetSelectedID(dropDown, index, 1); end;
                                       end
                                       if ( dropDown.disableList ) and ( dropDown.disableList[i] ) then
                                           info.disabled = 1;
                                     else
                                           info.disabled = nil;
                                       end
                                       info.arg1 = dropDown;
                                       info.arg2 = i;
                                       info.checked = nil;
                                       info.tooltipTitle = info.text;
                                       if ( dropDown.tooltipList ) then
                                           info.tooltipText = dropDown.tooltipList[i] or nil;
                                     else
                                           info.tooltipText = nil;
                                       end
                                       UIDropDownMenu_AddButton(info);
	                           end
                               end;
    UIDropDownMenu_Initialize(dropDown, initializeDropDown);
    if ( DTM_OnWotLK() ) then
        UIDropDownMenu_SetWidth(dropDown, width);
  else
        UIDropDownMenu_SetWidth(width, dropDown); -- You were bad on this one, Blizz ! Boooh !
    end
    UIDropDownMenu_SetSelectedID(dropDown, 1);
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFramePanel_SetTextAndTooltip(frame, textKey, tooltipExplainKey)
--
-- Called when a simple frame needs to have its :Text method invoked and its
-- tooltip fields set to a localised message.
-----------------------------------------------------------------------------

function DTM_ConfigurationFramePanel_SetTextAndTooltip(frame, textKey, tooltipExplainKey)
    local title = DTM_Localise(textKey);

    if ( frame:GetFrameType() == "CheckButton" ) then
        getglobal(frame:GetName().."Text"):SetText(title);
  else
        frame:SetText(title);
    end

    if ( title and #title > 0 ) and ( tooltipExplainKey ) then
        frame.tooltipText = "|cffffffff"..title.."|r";
        frame.tooltipRequirement = DTM_Localise(tooltipExplainKey);
  else
        frame.tooltipText = nil;
        frame.tooltipRequirement = nil;
    end
end

-- --------------------------------------------------------------------
-- **               DTM configuration widgets handlers               **
-- --------------------------------------------------------------------

-----------------------------------------------------------------------------
-- DTM_ConfigurationFramePanel_Slider_OnValueChanged(slider)
--
-- Called when a configuration slider has its value changed.
-----------------------------------------------------------------------------

function DTM_ConfigurationFramePanel_Slider_OnValueChanged(slider)
    local newValueText = slider.valueTextTemplate;
    if type(newValueText) == "function" then
        newValueText = newValueText(slider:GetValue());
  else
        newValueText = format(newValueText, slider:GetValue());
    end
    getglobal(slider:GetName().."Value"):SetText(newValueText);
end

-- --------------------------------------------------------------------
-- **                DTM configuration panels functions              **
-- --------------------------------------------------------------------

-----------------------------------------------------------------------------
-- DTM_ConfigurationFramePanel_Save(self, saveSchema)
--
-- Called when a configuration panel has to save its settings.
-----------------------------------------------------------------------------

function DTM_ConfigurationFramePanel_Save(self, saveSchema)
    if type(saveSchema) ~= "table" then return; end

    local k, v;
    local part, key, method, value;
    local effectiveValue;
    local selectedIndex;

    for k, v in ipairs(saveSchema) do
        part, key, method, value = v.part, v.key, v.method, v.value;
        if ( part and key and method and value ) then
            effectiveValue = nil;

            if ( methode ~= "FUNCTION" and method ~= "VALUE" ) then
                value = getglobal(value); -- The value is pointing to a widget.
            end

            if ( method == "NUMERIC_CONTROL" ) and ( type(value) == "table" ) then
                effectiveValue = value:GetValue();
            end
            if ( method == "BOOLEAN_CONTROL" ) and ( type(value) == "table" ) then
                effectiveValue = value:GetChecked();
                if ( effectiveValue ) then
                    effectiveValue = 1;
              else
                    effectiveValue = 0;
                end
            end
            if ( method == "DROPLIST_CONTROL" ) and ( type(value) == "table" ) then
                selectedIndex = UIDropDownMenu_GetSelectedID(value);

                if ( v.list ) and ( v.list[selectedIndex] ) then
                    effectiveValue = v.list[selectedIndex];
                end
            end
            if ( method == "FUNCTION" ) and ( type(value) == "function" ) then
                effectiveValue = value();
            end
            if ( method == "VALUE" ) and ( type(value) == "number" or type(value) == "string" ) then
                effectiveValue = value;
            end

            if ( effectiveValue ) then
                DTM_SetSavedVariable(part, key, effectiveValue, "modified");
          else
                DTM_ThrowError("MINOR", activeModule, "Was unable to find a valid save method for "..part..":"..key.." saved variable.");
            end
        end
    end
end

-----------------------------------------------------------------------------
-- DTM_ConfigurationFramePanel_Default(self, defaultSchema)
--
-- Called when a configuration panel has to use its defaults.
-----------------------------------------------------------------------------

function DTM_ConfigurationFramePanel_Default(self, defaultSchema)
    if type(defaultSchema) ~= "table" then return; end

    local k, v;
    local part, key;

    for k, v in ipairs(defaultSchema) do
        part, key = v.part, v.key;
        if ( part and key ) then
            DTM_SetSavedVariable(part, key, DTM_GetDefaultSavedVariable(part, key), "modified");
        end
    end
end


-----------------------------------------------------------------------------
-- DTM_ConfigurationFramePanel_Update(self, updateSchema)
--
-- Called when a configuration panel has to reset its controls
-- to current settings.
-----------------------------------------------------------------------------

function DTM_ConfigurationFramePanel_Update(self, updateSchema)
    -- Set title/sub-title if correct attributes are specified.

    local titleKey = self:GetAttribute("titleKey");
    if ( titleKey ) then
        getglobal(self:GetName().."Title"):SetText(DTM_Localise(titleKey));
    end
    local subTitleKey = self:GetAttribute("subTitleKey");
    if ( subTitleKey ) then
        getglobal(self:GetName().."SubText"):SetText(DTM_Localise(subTitleKey));
    end

    -- Exploit the update schema

    if type(updateSchema) ~= "table" then return; end

    local k, v;
    local part, key, method, value;
    local effectiveValue;
    local selectedIndex, listIndex, listValue;

    for k, v in ipairs(updateSchema) do
        part, key, method, value = v.part, v.key, v.method, v.value;
        if ( part and key and method and value ) then
            effectiveValue = DTM_GetSavedVariable(part, key, "modified");

            value = getglobal(value); -- The value is pointing to a widget.

            if ( method == "NUMERIC_CONTROL" ) and ( type(value) == "table" ) then
                value:SetValue(effectiveValue);
            end
            if ( method == "BOOLEAN_CONTROL" ) and ( type(value) == "table" ) then
                if ( effectiveValue == 1 ) then
                    value:SetChecked(1);
              else
                    value:SetChecked(nil);
                end
            end
            if ( method == "DROPLIST_CONTROL" ) and ( type(value) == "table" ) then
                selectedIndex = nil;

                if ( v.list ) then
                    for listIndex, listValue in ipairs(v.list) do
                        if ( listValue == effectiveValue ) then
                            selectedIndex = listIndex;
                            break;
                        end
                    end
                    if ( selectedIndex ) then
                        UIDropDownMenu_SetSelectedID(value, selectedIndex, 1);
                        getglobal(value:GetName().."Text"):SetText(value.valueList[selectedIndex] or '?');
                    end
                end
            end
        end
    end
end