local activeModule = "GUI Skin manager";

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
-- * skinManager:Lock()                                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> skinManager: the skin manager frame.                          *
-- ********************************************************************
-- * Lock the skin manager's command. This should be used whenever    *
-- * you are starting to edit/create a skin.                          *
-- ********************************************************************
local function Lock(skinManager)
    StaticPopup_Hide("DTM_SKIN_OPERATION_POPUP");
    DTM_SkinManager.locked = true;
    DTM_SkinManager_ExplainText:SetText(DTM_Localise("configSkinManagerExplainLocked"));
    DTM_SkinManager_Update();
end

-- ********************************************************************
-- * skinManager:Unlock()                                             *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> skinManager: the skin manager frame.                          *
-- ********************************************************************
-- * This should be used whenever you shut down the skin editor.      *
-- ********************************************************************
local function Unlock(skinManager)
    DTM_SkinManager.locked = false;
    DTM_SkinManager_ExplainText:SetText(DTM_Localise("configSkinManagerExplain"));
    DTM_SkinManager_Update();
end

-- --------------------------------------------------------------------
-- **                           Functions                            **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SkinManager_SubmitOperationPopup(operation, skinName)        *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> operation: the operation to perform.                          *
-- * It can be either: COPY/DELETE/RENAME/RESTORE                     *
-- * >> skinName: the skin affected by the operation.                 *
-- ********************************************************************
-- * Prepare a localised operation popup and display it.              *
-- ********************************************************************
function DTM_SkinManager_SubmitOperationPopup(operation, skinName)
    -- Hide any previous operation popup
    StaticPopup_Hide("DTM_SKIN_OPERATION_POPUP");

    local dialog = StaticPopupDialogs["DTM_SKIN_OPERATION_POPUP"];
    local hasSkinNameInput = nil;

    if ( operation == "COPY" ) then
        dialog.text = DTM_Localise("configSkinManagerCopyForm");

        dialog.showAlert = nil;
        dialog.OnAccept = function()
                              local editBox = getglobal(this:GetParent():GetName().."EditBox");
                              if DTM_CopySkin(skinName, editBox:GetText()) then DTM_SelectSkin(editBox:GetText()); end
                          end;

        hasSkinNameInput = 1;

elseif ( operation == "RENAME" ) then
        dialog.text = DTM_Localise("configSkinManagerRenameForm");

        dialog.showAlert = nil;
        dialog.OnAccept = function()
                              local editBox = getglobal(this:GetParent():GetName().."EditBox");
                              DTM_RenameSkin(skinName, editBox:GetText());
                          end;

        hasSkinNameInput = 1;

elseif ( operation == "RESTORE" ) then
        dialog.text = DTM_Localise("configSkinManagerRestoreForm");

        dialog.showAlert = nil;
        dialog.OnAccept = function() DTM_RestoreSkin(skinName); end;

elseif ( operation == "DELETE" ) then
        dialog.text = DTM_Localise("configSkinManagerDeleteForm");

        dialog.showAlert = 1;
        dialog.OnAccept = function() DTM_DeleteSkin(skinName); end;
  else
        -- Unknown operation.
    end

    if ( hasSkinNameInput ) then
        dialog.hasEditBox = 1;
        dialog.maxLetters = 24;

        dialog.OnShow = function()
                            getglobal(this:GetName().."EditBox"):SetFocus();
                            getglobal(this:GetName().."EditBox"):SetText("");
                            getglobal(this:GetName().."Button1"):Disable();
                        end;
        dialog.OnHide = function()
                            if ( ChatFrameEditBox:IsVisible() ) then
                                ChatFrameEditBox:SetFocus();
                            end
                            getglobal(this:GetName().."EditBox"):SetText("");
                        end;
        dialog.EditBoxOnTextChanged = function()
                                          local editBox = getglobal(this:GetParent():GetName().."EditBox");
                                          if ( DTM_SkinManager_IsNameFree(editBox:GetText()) ) then
		                              getglobal(this:GetParent():GetName().."Button1"):Enable();
	                                else
		                              getglobal(this:GetParent():GetName().."Button1"):Disable();
		                          end
                                      end;
  else
        dialog.hasEditBox = nil;
        dialog.maxLetters = nil;
        dialog.OnShow = nil;
        dialog.OnHide = nil;
        dialog.EditBoxOnTextChanged = nil;
    end

    StaticPopup_Show("DTM_SKIN_OPERATION_POPUP", skinName);
end

-- ********************************************************************
-- * DTM_SkinManager_IsNameFree(name)                                 *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> name: the name you want to check.                             *
-- ********************************************************************
-- * Checks if a given name is free for copy, rename of a skin.       *
-- ********************************************************************
function DTM_SkinManager_IsNameFree(name)
    if type(name) ~= "string" then return nil; end
    if #name <= 0 then return nil; end
    if name == "version" then return nil; end
    if DTM_GetSkinData(name) then return nil; end
    return 1;
end

-- --------------------------------------------------------------------
-- **                           Handlers                             **
-- --------------------------------------------------------------------

function DTM_SkinManager_OnLoad(self)
    -- Sets frames variables.

    -- Binds methods to the new frame.
    self.Lock = Lock;
    self.Unlock = Unlock;

    -- Grab child frames.

    -- Setup some texts that do not change.
    DTM_SkinManager_HeaderText:SetText(DTM_Localise("configSkinManagerHeader"));
    DTM_SkinManager_CopyButton:SetText(DTM_Localise("configSkinManagerCopy"));
    DTM_SkinManager_DeleteButton:SetText(DTM_Localise("configSkinManagerDelete"));
    DTM_SkinManager_ToEditorButton:SetText(DTM_Localise("configSkinManagerToEditor"));

    -- Prepare the basic operation popup
    StaticPopupDialogs["DTM_SKIN_OPERATION_POPUP"] = {
	text = "",
	button1 = OKAY,
	button2 = CANCEL,
        timeout = 0,
        whileDead = 1,
    };

    -- Ensure it is hidden and locked at its creation.
    self:Lock();
    self:Hide();
end

function DTM_SkinManager_Update()
    local skinData = DTM_GetSkinData(DTM_GetActiveSkin());
    local currentIsBase = nil;

    if ( skinData ) then
        currentIsBase = skinData.isBase;
    end

    -- Determinates which buttons are allowed.

    if ( DTM_SkinManager.locked ) then
        DTM_SkinManager_CopyButton:Disable();
        DTM_SkinManager_RenameOrRestoreButton:Disable();
        DTM_SkinManager_ToEditorButton:Disable();
        DTM_SkinManager_DeleteButton:Disable();
  else
        DTM_SkinManager_CopyButton:Enable();
        DTM_SkinManager_RenameOrRestoreButton:Enable();
        DTM_SkinManager_ToEditorButton:Enable();
        if ( currentIsBase ) then
            DTM_SkinManager_DeleteButton:Disable();
            DTM_SkinManager_RenameOrRestoreButton:SetText(DTM_Localise("configSkinManagerRestore"));
      else
            DTM_SkinManager_DeleteButton:Enable();
            DTM_SkinManager_RenameOrRestoreButton:SetText(DTM_Localise("configSkinManagerRename"));
        end
    end

    -- The skin dropdown.
    DTM_SkinManager_UpdateDropDown();
end

function DTM_SkinManager_UpdateDropDown()
    local dropDown = DTM_SkinManager_DropDown;

    local initializeDropDown = function()
                                   local dropDown = getglobal(UIDROPDOWNMENU_INIT_MENU);
                                   local info = UIDropDownMenu_CreateInfo();
                                   for i=1, DTM_GetNumSkins() do
                                       local name, isBase = DTM_GetSkinInfo(i);
                                       info.text = name;
                                       if ( not DTM_OnWotLK() ) then
                                           info.func = function(dropDown, index) DTM_SkinManager_OnSelection(dropDown, index); end;
                                     else
                                           info.func = function(self, dropDown, index) DTM_SkinManager_OnSelection(dropDown, index); end;
                                       end
                                       info.arg1 = dropDown;
                                       info.arg2 = name;
                                       info.checked = nil;
                                       info.tooltipTitle = name;
                                       if ( isBase ) then
                                           info.tooltipTitle = info.tooltipTitle..DTM_Localise("configSkinManagerTagBase");
                                           info.tooltipText = DTM_Localise("configSkinManagerExplainBaseSkin");
                                     else
                                           info.tooltipTitle = info.tooltipTitle..DTM_Localise("configSkinManagerTagUser");
                                           info.tooltipText = DTM_Localise("configSkinManagerExplainUserSkin");
                                       end
                                       info.tooltipText = info.tooltipText..DTM_Localise("configSkinManagerExplainSelectionAppend");
                                       UIDropDownMenu_AddButton(info);
	                           end
                               end;
    UIDropDownMenu_Initialize(dropDown, initializeDropDown);
    if ( DTM_OnWotLK() ) then
        UIDropDownMenu_SetWidth(dropDown, 256);
  else
        UIDropDownMenu_SetWidth(256, dropDown); -- You were bad on this one, Blizz ! Boooh !
    end

    -- Select the right entry
    UIDropDownMenu_SetSelectedName(dropDown, DTM_GetActiveSkin());

    -- Translate the caption
    getglobal(dropDown:GetName().."Caption"):SetText( DTM_Localise("configSkinManagerSelection") );

    -- Apply the "lock" flag.
    if ( DTM_SkinManager.locked ) then
        dropDown:SetAlpha(0.5);
  else
        dropDown:SetAlpha(1.0);
    end
end

function DTM_SkinManager_OnSelection(dropDown, name)
    if ( DTM_SkinManager.locked ) then return; end
    DTM_SelectSkin(name);
end

function DTM_SkinManager_CopyButton_OnClick(self, button)
    if ( DTM_SkinManager.locked ) then return; end
    DTM_SkinManager_SubmitOperationPopup("COPY", DTM_GetActiveSkin());
end

function DTM_SkinManager_RenameOrRestoreButton_OnClick(self, button)
    if ( DTM_SkinManager.locked ) then return; end

    local skinData = DTM_GetSkinData(DTM_GetActiveSkin());
    local currentIsBase = nil;

    if ( skinData ) then
        currentIsBase = skinData.isBase;
    end

    if ( currentIsBase ) then
        DTM_SkinManager_SubmitOperationPopup("RESTORE", DTM_GetActiveSkin());
  else
        DTM_SkinManager_SubmitOperationPopup("RENAME", DTM_GetActiveSkin());
    end
end

function DTM_SkinManager_DeleteButton_OnClick(self, button)
    if ( DTM_SkinManager.locked ) then return; end
    DTM_SkinManager_SubmitOperationPopup("DELETE", DTM_GetActiveSkin());
end

function DTM_SkinManager_ToEditorButton_OnClick(self, button)
    if ( DTM_SkinManager.locked ) then return; end
    DTM_SkinEditor:StartEdit(DTM_GetActiveSkin());
end