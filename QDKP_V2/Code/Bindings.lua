-- Copyright 2008 Riccardo Belloli (belloli@email.it)
-- This file is a part of QDKP_V2 (see about.txt in the Addon's root folder)

--             ## BINDINGS FUCTION ##


BINDING_HEADER_QDKP2 = "Quick DKP V2"


BINDING_NAME_CHARGELASTLOOT = "Charge last item looted"
function QDKP2_BIND_ChargeLastLoot()
  if QDKP2_LootItem and QDKP2_LooterName then
    QDKP2_OpenToolboxForCharge(QDKP2_LooterName, nil,QDKP2_LootItem) 
  end
end

BINDING_NAME_CHARGELASTSEEN = "Charge last item seen in raid chat"
function QDKP2_BIND_ChargeLastSeen()
  if QDKP2_ChatLootItem then
    QDKP2_OpenInputBox("Enter the name of the player who has\n to pay for "..QDKP2_ChatLootItem,QDKP2_BIND_ChargeLastSeen_Do)
  end
end

function QDKP2_BIND_ChargeLastSeen_Do(name)
  local FormattedName = QDKP2_FormatName(name)
  
  if QDKP2_IsInGuild(FormattedName) then
    QDKP2_OpenToolboxForCharge(FormattedName, nil,QDKP2_ChatLootItem) 
  elseif name ~= "" then
    QDKP2_Msg(QDKP2_COLOR_RED..FormattedName.." is not in the guild list")
  end
end

BINDING_NAME_NEWSESSION = "Start a new session"
function QDKP2_BIND_NewSession()
  QDKP2_frame1_DownloadData()
end
BINDING_NAME_SENDCHANGES = "Send all changes"
function QDKP2_BIND_SendChanges()
  QDKP2_UploadAll()
end

BINDING_NAME_TOGGLEMAIN = "Toggle main window"
function QDKP2_BIND_ToggleMain()
  QDKP2_ToggleOffAfter(1)
end
BINDING_NAME_TOGGLELIST = "Toggle list"
function QDKP2_BIND_ToggleList()
  QDKP2_ToggleOffAfter(2)
end
BINDING_NAME_TOGGLELOG = "Toggle log"
function QDKP2_BIND_ToggleLog()
  QDKP2_ToggleOffAfter(5)
end
BINDING_NAME_TOGGLETOOLBOX = "Toggle toolbox"
function QDKP2_BIND_ToggleToolbox()
  QDKP2_ToggleOffAfter(3)
end

