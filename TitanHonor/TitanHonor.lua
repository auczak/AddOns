-- **************************************************************************
-- * TitanHonor.lua
-- *
-- * By: TitanMod, Dark Imakuni, Adsertor and the Titan Development Team
-- *     (HonorGoG, jaketodd422, joejanko, Lothayer, Tristanian)
-- **************************************************************************

-- ******************************** Constants *******************************
TITAN_HONOR_ID = "Honor";
TITAN_HONOR_CFG = {};
TITAN_HONOR_KILLSTODAY = {};
TITAN_HONOR_VERSION = 1.13;
TITAN_HONOR_USERS = {};

-- ******************************** Variables *******************************
TITAN_HONOR_LASTKILL = "";
TITAN_HONOR_PLAYER = nil;
TITAN_HONOR_VARSLOADED = false;
TITAN_HONOR_PENDINGUPDATE = false;
TITAN_HONOR_LASTWIN_TIMESTAMP = 0;
TITAN_HONOR_BGCONFIRM = 0;             -- auto-joining BG
TITAN_HONOR_BGAUTOJOINTIMER = 15;
TITAN_HONOR_LastEstimated = 0;
TITAN_HONOR_LastBonusEstimated = 0;
TITAN_HONOR_LastKillsEstimated = 0;
TITAN_HONOR_InBattleground = false;
TITAN_HONOR_Map = "";
TITAN_HONOR_EnterTime = 0;
TITAN_HONOR_BAG_ABMarks = 0;
TITAN_HONOR_BAG_AVMarks = 0;
TITAN_HONOR_BAG_WSGMarks = 0;
TITAN_HONOR_BAG_EYEMarks = 0;
local old_StaticPopup_OnHide;          -- Detects when you click 'hide' on BG invite request.

-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelHonorButton_OnLoad()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TitanPanelHonorButton_OnLoad()

     this.registry = {
          id = TITAN_HONOR_ID,
          builtIn = 1,
          version = TITAN_VERSION,
          menuText = "Honor",
          buttonTextFunction = "TitanPanelHonorButton_GetButtonText", 
          tooltipTitle ="Honor Count", 
          tooltipTextFunction = "TitanPanelHonorButton_GetTooltipText",
          savedVariables = {
               ShowLabelText = 1,
               BG_AutoJoin = TITAN_NIL,
               BG_AutoRelease = TITAN_NIL,
               ShowMarks = 1;
               Verbose = 1,
               AlternateView = 0,
          }
     };

     old_StaticPopup_OnHide = StaticPopup_OnHide;
     StaticPopup_OnHide = TitanPanelHonorButton_StaticPopup_OnHide;

     this:RegisterEvent("PLAYER_ENTERING_WORLD"); -- zone chnage
     this:RegisterEvent("VARIABLES_LOADED"); 
     this:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN"); -- honor counter
     
     this:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE"); -- possible counter
     
     this:RegisterEvent("PLAYER_DEAD"); -- auto-release
     this:RegisterEvent("UPDATE_BATTLEFIELD_STATUS"); -- auto-join

     this:RegisterEvent("BAG_UPDATE"); -- marks counter
     this:RegisterEvent("UNIT_INVENTORY_CHANGED"); -- marks counter

     this:RegisterEvent("BANKFRAME_OPENED"); -- marks counter (bank)
     --this:RegisterEvent("BANKFRAME_CLOSED"); -- marks counter (bank)
     this:RegisterEvent("PLAYERBANKSLOTS_CHANGED"); -- marks counter (bank)


     -- slash commands
     SlashCmdList["TITANHONOR"] = TitanPanelHonorButton_CmdLine;
     SLASH_TITANHONOR1 = "/titanhonor";
     SLASH_TITANHONOR2 = "/thonor";

end

function TitanPanelHonorButton_OnShow()
local hasTimer = TitanPanel:HasTimer("TitanPanel"..TITAN_HONOR_ID)
       if hasTimer then
            --do nothing
          else
           TitanPanel:AddRepeatingTimer("TitanPanel"..TITAN_HONOR_ID, 1, TitanPanelPluginHandle_OnUpdate, TITAN_HONOR_ID, TITAN_PANEL_UPDATE_BUTTON)
          end
end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_OnHide()
-- DESC : Destroy repeating timer when plugin is visible
-- **************************************************************************
function TitanPanelHonorButton_OnHide()
local hasTimer = TitanPanel:HasTimer("TitanPanel"..TITAN_HONOR_ID)
       if hasTimer then
            TitanPanel:RemoveTimer("TitanPanel"..TITAN_HONOR_ID)
          end
end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_CmdLine(param)
-- DESC : Parser for slash command line
-- VARS : param = parsed command
-- **************************************************************************
function TitanPanelHonorButton_CmdLine(param)
     local arg1, arg2;
     _, _, arg1, arg2 = string.find(param, "(%a+)%s+(.+)");
     if (not arg1) then
          arg1 = param;
     end
     if (arg1 == "reset") then
          TitanPanelHonorButton_ResetToday()
          DEFAULT_CHAT_FRAME:AddMessage("Titan Honor: daily reset forced!", 1, 0, 0);
     else
          DEFAULT_CHAT_FRAME:AddMessage("Titan Honor Console Commands:", 1, 1, 0);
          DEFAULT_CHAT_FRAME:AddMessage("/thonor |c0000ffffreset|r -- Force TitanHonor to reset daily honor.");
     end          
end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_OnEvent()
-- DESC : This section will grab the events registered to the add on and act on them
-- **************************************************************************
function TitanPanelHonorButton_OnEvent()
     if (event == "PLAYER_ENTERING_WORLD") then
          
          if (TITAN_HONOR_VARSLOADED) then
               TitanPanelHonorButton_GetPlayerName();
          else
               TITAN_HONOR_PENDINGUPDATE = true;
          end
    
          -- is player entering or leaving a BG?
          local i, id, map, elapsed, gained;
          for i=1, MAX_BATTLEFIELD_QUEUES do

               _, map, id = GetBattlefieldStatus(i);
               if (id ~= 0) then

                    -- Player entering a BG

                    TITAN_HONOR_InBattleground = true;
                    TITAN_HONOR_Map = map;
                    TITAN_HONOR_LastEstimated = TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].estCP;
                    TITAN_HONOR_LastBonusEstimated = TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].bonusCP;
                    TITAN_HONOR_LastKillsEstimated = TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].killsCP;
                    TITAN_HONOR_EnterTime = time();

                    return
               end
          end

          if (TITAN_HONOR_InBattleground) then

               if (TITAN_HONOR_Map == TITAN_HONOR_TXT_EK) then
                    return
               end

               -- Player just left a BG

               gained = math.floor(TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].estCP - TITAN_HONOR_LastEstimated);
               elapsed = math.floor( (time() - TITAN_HONOR_EnterTime) / 60 );

               if (gained < 0) then
                    gained = "?";
               end

               -- BG Honor History
               if (elapsed > 2 and gained ~= "?" and TITAN_HONOR_Map ~= nil) then
                    if (not TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].BGHonorHistory[TITAN_HONOR_Map]) then
                         TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].BGHonorHistory[TITAN_HONOR_Map] = {};
                    end

                    table.insert(TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].BGHonorHistory[TITAN_HONOR_Map], { honor = gained, time = elapsed } );
                    if (table.getn(TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].BGHonorHistory[TITAN_HONOR_Map]) > 10) then
                         table.remove(TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].BGHonorHistory[TITAN_HONOR_Map], 1);
                    end
               end

               TITAN_HONOR_InBattleground = false;
          end

           THPB_CountBagBgMarks();

     elseif (event == "UPDATE_BATTLEFIELD_STATUS") then
          TitanPanelHonorButton_CheckBGConfirm();

     elseif (event == "PLAYER_DEAD") then
          -- Auto-Release upon death. But not when soulstoned, and only in battlegrounds.
          local status;
          for i=1, MAX_BATTLEFIELD_QUEUES do
               local s, _, _ = GetBattlefieldStatus(i);
               if (s == "active") then
                    status = "active";
                    break;
               end
          end

          if ((status == "active") and (not HasSoulstone()) and (TitanGetVar(TITAN_HONOR_ID, "BG_AutoRelease") == 1)) then
               RepopMe();
          end

     elseif (event == "CHAT_MSG_COMBAT_HONOR_GAIN") or (event == "CHAT_MSG_COMBAT_FACTION_CHANGE") then
          local rank, ecp, est;

          _, _, TITAN_HONOR_LASTKILL, rank, ecp = string.find(arg1, TITAN_HONOR_TXT_HONORKILL_PATTERN);

          if (not TITAN_HONOR_LASTKILL) then

               _, _, TITAN_HONOR_LASTKILL = string.find(arg1, TITAN_HONOR_TXT_HONORBONUS_PATTERN);
               if (TITAN_HONOR_LASTKILL) then
                    TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].estCP = TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].estCP + tonumber(TITAN_HONOR_LASTKILL);
                    TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].bonusCP = TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].bonusCP + tonumber(TITAN_HONOR_LASTKILL);

                    if (TitanGetVar(TITAN_HONOR_ID, "Verbose") == 1) then
                         local txt;
                         txt = format(TITAN_HONOR_CHAT_BONUSPATTERN, math.floor(tonumber(TITAN_HONOR_LASTKILL)));
                         DEFAULT_CHAT_FRAME:AddMessage(txt, 1, 0.7, 0);
                    end

               end

          else

               if (not TITAN_HONOR_KILLSTODAY[TITAN_HONOR_PLAYER][TITAN_HONOR_LASTKILL]) then
                    TITAN_HONOR_KILLSTODAY[TITAN_HONOR_PLAYER][TITAN_HONOR_LASTKILL] = 0;
               end

               TITAN_HONOR_KILLSTODAY[TITAN_HONOR_PLAYER][TITAN_HONOR_LASTKILL] = TITAN_HONOR_KILLSTODAY[TITAN_HONOR_PLAYER][TITAN_HONOR_LASTKILL] + 1;

               if (ecp) then
                    est = TitanPanelHonorButton_EstimateCP(ecp, TITAN_HONOR_KILLSTODAY[TITAN_HONOR_PLAYER][TITAN_HONOR_LASTKILL]);
                    TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].estCP = TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].estCP + est;
                    TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].killsCP = TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].killsCP + est;
               end

               if (TitanGetVar(TITAN_HONOR_ID, "Verbose") == 1) then
                    local txt;
                    txt = format(TITAN_HONOR_CHAT_KILLPATTERN, TITAN_HONOR_LASTKILL, tonumber(TITAN_HONOR_KILLSTODAY[TITAN_HONOR_PLAYER][TITAN_HONOR_LASTKILL]), math.floor(est));
                    DEFAULT_CHAT_FRAME:AddMessage(txt, 1, 0.7, 0);
               end
          end

     elseif (event == "VARIABLES_LOADED") then
          TITAN_HONOR_VARSLOADED = true;
          if (TITAN_HONOR_PENDINGUPDATE) then
               TitanPanelHonorButton_GetPlayerName();
          end

     elseif (event == "BAG_UPDATE") or (event == "UNIT_INVENTORY_CHANGED") then
          THPB_CountBagBgMarks();

     elseif (event == "BANKFRAME_OPENED") or (event == "PLAYERBANKSLOTS_CHANGED") then
          THPB_CountBankBgMarks();
          THPB_CountBagBgMarks();
     end

     TitanPanelButton_UpdateButton(TITAN_HONOR_ID);
     TitanPanelButton_UpdateTooltip();          
end



-- **************************************************************************
-- NAME : THPB_CountBagBgMarks()
-- DESC : <research>
-- **************************************************************************
function THPB_CountBagBgMarks()
     TITAN_HONOR_BAG_WSGMarks = THPB_CountBagItems(TITAN_HONOR_ITEM_WSGMARK);
     TITAN_HONOR_BAG_AVMarks = THPB_CountBagItems(TITAN_HONOR_ITEM_AVMARK);
     TITAN_HONOR_BAG_ABMarks = THPB_CountBagItems(TITAN_HONOR_ITEM_ABMARK);
     TITAN_HONOR_BAG_EYEMarks = THPB_CountBagItems(TITAN_HONOR_ITEM_EOTSMARK);
     
end

-- **************************************************************************
-- NAME : THPB_CountBagBgMarks()
-- DESC : <research>
-- **************************************************************************
function THPB_CountBankBgMarks()
     if (TITAN_HONOR_PLAYER) then
          TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankAVTokens = THPB_CountBankItems(TITAN_HONOR_ITEM_AVMARK);
          TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankABTokens = THPB_CountBankItems(TITAN_HONOR_ITEM_ABMARK);
          TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankWSGTokens = THPB_CountBankItems(TITAN_HONOR_ITEM_WSGMARK);
          TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankEYETokens = THPB_CountBankItems(TITAN_HONOR_ITEM_EOTSMARK);
          -- DEFAULT_CHAT_FRAME:AddMessage(THPB_CountBankItems(TITAN_HONOR_ITEM_AVMARK));
     end
end

-- **************************************************************************
-- NAME : THPB_CountBagItems(ItemName)
-- DESC : <research>
-- VARS : ItemName = <research>
-- **************************************************************************
function THPB_CountBagItems(ItemName)
     local items = 0;
     local bag, slot = 0;
     for bag = 0, NUM_BAG_FRAMES do
          for slot = 1, GetContainerNumSlots(bag) do
          local itemName = GetContainerItemLink(bag, slot);
               if itemName then
                    if string.find(itemName, "%["..ItemName.."%]") then
                         local texture, count = GetContainerItemInfo(bag, slot);
                         items = items + count;
                    end
               end
          end
     end
     return items;
end

-- **************************************************************************
-- NAME : THPB_CountBankItems(ItemName)
-- DESC : <research>
-- VARS : ItemName = <research>
-- **************************************************************************
function THPB_CountBankItems(ItemName)
     local maxContainerItems;
     local containerItemNum;
     local bagNum;
     local link;
     local quantity;
     local icon;

     local iItemCount=0;

     maxContainerItems = GetContainerNumSlots(BANK_CONTAINER);
     if ( maxContainerItems ) then
          for containerItemNum = 1, maxContainerItems do
               link = GetContainerItemLink(BANK_CONTAINER, containerItemNum);
               icon, quantity = GetContainerItemInfo(BANK_CONTAINER, containerItemNum);
               if( link ) then
                    if string.find(link, "%["..ItemName.."%]") then
                         iItemCount = iItemCount + quantity;
                    end
               end
          end
     end


     for bagNum = 5, 11 do
          maxContainerItems = GetContainerNumSlots(bagNum);
          if( maxContainerItems ) then
               local id = BankButtonIDToInvSlotID(bagNum, 1);
               link = GetInventoryItemLink("player", id);
               for containerItemNum = 1, maxContainerItems do
                    link = GetContainerItemLink(bagNum, containerItemNum);
                    icon, quantity = GetContainerItemInfo(bagNum, containerItemNum);
                    if( link ) then
                         if string.find(link, "%["..ItemName.."%]") then
                              iItemCount = iItemCount + quantity;
                         end
                    end
               end
          end
     end
     return iItemCount;
end



-- **************************************************************************
-- NAME : TitanPanelHonorButton_OnClick(button)
-- DESC : Show tooltip when button clicked
-- VARS : button = value of action
-- **************************************************************************
function TitanPanelHonorButton_OnClick(button)
     if (button == "LeftButton") then
          TitanPanelHonorButton_ToggleVar_AlternateView();
          TitanPanelButton_UpdateButton(TITAN_HONOR_ID);
          TitanPanelHonorButton_GetTooltipText()
          TitanPanelButton_UpdateTooltip();
     end
end

-- **************************************************************************
-- NAME : TitanPanelBagButton_GetButtonText(id)
-- DESC : Calculate honor logic then display data on button
-- VARS : id = button ID
-- **************************************************************************
function TitanPanelHonorButton_GetButtonText(id)
     
     if(not TITAN_HONOR_PLAYER) then
          return TITAN_HONOR_BUTTON_LABEL, "Loading";
     end

     TitanPanelHonorButton_CheckBGConfirm();

     local Text, z, cp, kills;

     z = 0;
     for _, kills in pairs(TITAN_HONOR_KILLSTODAY[TITAN_HONOR_PLAYER]) do
          z = z + kills;
     end
     
     
     cp = math.floor(TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].estCP);

     Text = format(TITAN_HONOR_BUTTON_PATTERN, TitanUtils_GetHighlightText(cp), TitanUtils_GetGreenText(z));

     return TITAN_HONOR_BUTTON_LABEL, Text;
end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_GetTooltipText()
-- DESC : Display tooltip text on mouseover
-- **************************************************************************
function TitanPanelHonorButton_GetTooltipText()
     local hc, ac;
     hc = GetHonorCurrency();
     ac = GetArenaCurrency();
     
     local txtret = ""; -- text returned
--     local hk;
     -- lifetime kills
--     hk = GetPVPLifetimeStats();

     -- Currency
     txtret = txtret..
          TitanUtils_GetHighlightText(TITAN_HONOR_TOOLTIP_CURRENCY).."\n"..
          TITAN_HONOR_TOOLTIP_HONORCP.."\t"..TitanUtils_GetHighlightText(hc).."\n"..
          TITAN_HONOR_TOOLTIP_ARENACP.."\t"..TitanUtils_GetHighlightText(ac).."\n";

     -- alternate view == BG statistics
     -- with too many BGs it getting harder and harder to make it clear and readable
     -- so player can now switch between views
     if (TitanGetVar(TITAN_HONOR_ID, "AlternateView") == 1) then
          local bg, honorArr, avgHonor, avgTime, bgSession, dataPoints, bgstats, honorOK, timeOK;
     
          for bg, honorArr in pairs(TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].BGHonorHistory) do
               avgHonor = 0;
               avgTime = 0;

               dataPoints = table.getn(honorArr);
          
               for _, bgSession in pairs(honorArr) do
                    honorOK = 0;
                    timeOK = 0;

                    -- check honor for bg entry
                    if(tonumber(bgSession.honor) ~= nil) then
                         honorOK = 1;
                    end
               
                    -- check time for bg entry
                    if(tonumber(bgSession.time) ~= nil) then
                         timeOK = 1;
                    end

                    -- only if both, honor and time are valid, numeric values add them to statistics
                    if((honorOK == 1) and (timeOK == 1)) then
                         avgTime = avgTime + bgSession.time;
                         avgHonor = avgHonor + bgSession.honor;
                    else
                         -- this entry wont be counted in statistics
                         dataPoints = dataPoints - 1;
                    end
               end
     
               -- if all values are invalid, we won't get proper value
               if((dataPoints > 0) and (bg ~= TITAN_HONOR_TXT_EK)) then
                    txtret = txtret.."\n"..TitanUtils_GetHighlightText(bg..TITAN_HONOR_TOOLTIP_STATS).."\n"..
                         TITAN_HONOR_TOOLTIP_AVG_HONOR.."\t"..TitanUtils_GetHighlightText(math.floor(avgHonor/dataPoints)).."\n"..
                         TITAN_HONOR_TOOLTIP_HONORPERHOUR.."\t"..TitanUtils_GetHighlightText(math.floor((avgHonor/avgTime)*60)).." ("..TitanUtils_GetHighlightText(math.floor((avgHonor/avgTime)))..")\n";
               end


          end
     else
          
          -- bg marks
          if (TitanGetVar(TITAN_HONOR_ID, "ShowMarks") == 1) then
               txtret = txtret.."\n"..
                    TitanUtils_GetHighlightText(TITAN_HONOR_TOOLTIP_BGTOKENS).."\t"..TITAN_HONOR_TOOLTIP_SCHEMA.."\n"..
                    TITAN_HONOR_TOOLTIP_AV.."\t"..TitanUtils_GetHighlightText(math.floor(TITAN_HONOR_BAG_AVMarks+TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankAVTokens).."/"..TITAN_HONOR_BAG_AVMarks.."/"..TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankAVTokens).."\n"..
                    TITAN_HONOR_TOOLTIP_AB.."\t"..TitanUtils_GetHighlightText(math.floor(TITAN_HONOR_BAG_ABMarks+TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankABTokens).."/"..TITAN_HONOR_BAG_ABMarks.."/"..TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankABTokens).."\n"..
                    TITAN_HONOR_TOOLTIP_WSG.."\t"..TitanUtils_GetHighlightText(math.floor(TITAN_HONOR_BAG_WSGMarks+TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankWSGTokens).."/"..TITAN_HONOR_BAG_WSGMarks.."/"..TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankWSGTokens).."\n"..
                    TITAN_HONOR_TOOLTIP_EYE.."\t"..TitanUtils_GetHighlightText(math.floor(TITAN_HONOR_BAG_EYEMarks+TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankEYETokens).."/"..TITAN_HONOR_BAG_EYEMarks.."/"..TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankEYETokens).."\n";                    
          end

          local z, kills;

          -- today kills
          z = 0;
          for _, kills in pairs(TITAN_HONOR_KILLSTODAY[TITAN_HONOR_PLAYER]) do
               z = z + kills;
          end

          -- estimated honor
          txtret = txtret.."\n"..
               TitanUtils_GetHighlightText(TITAN_HONOR_TOOLTIP_TODAY).."\n"..
               TITAN_HONOR_TOOLTIP_HKS.."\t"..TitanUtils_GetGreenText(z).."\n"..
               TITAN_HONOR_TOOLTIP_HONORFROMHK.."\t"..TitanUtils_GetHighlightText(math.floor(TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].killsCP)).."\n"..
               TITAN_HONOR_TOOLTIP_BONUSHONOR.."\t"..TitanUtils_GetHighlightText(math.floor(TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].bonusCP)).."\n"..
               TITAN_HONOR_TOOLTIP_HONOREST.."\t"..TitanUtils_GetHighlightText(math.floor(TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].estCP)).."\n";


          if (TITAN_HONOR_InBattleground) then
               local gained = 0;
               local bhonor = 0;
               local khonor = 0;
               
               gained = math.floor(TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].estCP - TITAN_HONOR_LastEstimated);
               khonor = math.floor(TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].killsCP - TITAN_HONOR_LastKillsEstimated);
               bhonor = math.floor(TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].bonusCP - TITAN_HONOR_LastBonusEstimated);
               
               txtret = txtret.."\n"..TitanUtils_GetHighlightText(TITAN_HONOR_TOOLTIP_CURRENTBG).."\n"..
                    TITAN_HONOR_TOOLTIP_HONORFROMHK.."\t"..TitanUtils_GetHighlightText(khonor).."\n"..
                    TITAN_HONOR_TOOLTIP_BONUSHONOR.."\t"..TitanUtils_GetHighlightText(bhonor).."\n"..
                    TITAN_HONOR_TOOLTIP_HONORSOFAR.."\t"..TitanUtils_GetHighlightText(gained).."\n";

          end
     end

     return txtret;
end




-- **************************************************************************
-- NAME : TitanPanelRightClickMenu_PrepareHonorMenu()
-- DESC : Display rightclick menu options
-- **************************************************************************
function TitanPanelRightClickMenu_PrepareHonorMenu()
     TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_HONOR_ID].menuText);
     TitanPanelRightClickMenu_AddSpacer();


     -- Add toggle for batleground auto-joining
     info = {};
     info.text = TITAN_HONOR_MENU_AUTOJOIN;
     info.func = TitanPanelHonorButton_ToggleVar_BG_AutoJoin;
     info.checked = TitanGetVar(TITAN_HONOR_ID, "BG_AutoJoin");
     info.keepShownOnClick = 1;
     UIDropDownMenu_AddButton(info);

     -- Add toggle for auto-release in bgs
     info = {};
     info.text = TITAN_HONOR_MENU_AUTORES;
     info.func = TitanPanelHonorButton_ToggleVar_BG_AutoRelease;
     info.checked = TitanGetVar(TITAN_HONOR_ID, "BG_AutoRelease");
     info.keepShownOnClick = 1;
     UIDropDownMenu_AddButton(info);

     TitanPanelRightClickMenu_AddSpacer();     

     -- Add toggle for showing bg marks
     info = {};
     info.text = TITAN_HONOR_MENU_SHOWMARKS;
     info.func = TitanPanelHonorButton_ToggleVar_ShowMarks;
     info.checked = TitanGetVar(TITAN_HONOR_ID, "ShowMarks");
     info.keepShownOnClick = 1;
     UIDropDownMenu_AddButton(info);

     -- Add toggle for verbose mode
     info = {};
     info.text = TITAN_HONOR_MENU_SHOWHONORGAIN;
     info.func = TitanPanelHonorButton_ToggleVar_Verbose;
     info.checked = TitanGetVar(TITAN_HONOR_ID, "Verbose");
     info.keepShownOnClick = 1;
     UIDropDownMenu_AddButton(info);

     TitanPanelRightClickMenu_AddSpacer();     
     TitanPanelRightClickMenu_AddToggleLabelText(TITAN_HONOR_ID);
     
     TitanPanelRightClickMenu_AddSpacer();     
     TitanPanelRightClickMenu_AddCommand(TITAN_PANEL_MENU_HIDE, TITAN_HONOR_ID, TITAN_PANEL_MENU_FUNC_HIDE);
end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_GetPlayerName()
-- DESC : Get player name and login
-- **************************************************************************
function TitanPanelHonorButton_GetPlayerName()
     local pname;

     pname = UnitName("player");
     if (pname and pname ~= UNKNOWNOBJECT and pname ~= UKNOWNBEING and pname ~= TITAN_HONOR_TXT_UNKNOWN_ENTITY) then
          TitanPanelHonorButton_Login();
     end
end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_Login()
-- DESC : Get player login
-- **************************************************************************
function TitanPanelHonorButton_Login()

     TITAN_HONOR_PLAYER = UnitName("player").." "..GetCVar("realmName");

     -- today's kills
     if(not TITAN_HONOR_KILLSTODAY[TITAN_HONOR_PLAYER]) then
          TITAN_HONOR_KILLSTODAY[TITAN_HONOR_PLAYER] = {};
     end

     -- basic data
     if(not TITAN_HONOR_CFG[TITAN_HONOR_PLAYER]) then
          TITAN_HONOR_CFG[TITAN_HONOR_PLAYER] = { yesterdayHK = 0, yesterdayCP = 0 }
     end

     -- keep users and they last script version
     if(not TITAN_HONOR_USERS[TITAN_HONOR_PLAYER]) then
          TITAN_HONOR_USERS[TITAN_HONOR_PLAYER] = { version = TITAN_HONOR_VERSION }
     end
     
     -- estimated cp for today
     if (not TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].estCP) then
          TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].estCP = 0;
     end

     -- estimated cp from kills
     if (not TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].killsCP) then
          TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].killsCP = 0;
     end

     -- estimated cp from bonuses
     if (not TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].bonusCP) then
          TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].bonusCP = 0;
     end

     -- bg statistics
     if (not TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].BGHonorHistory) then
          TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].BGHonorHistory = {};
     end

     -- bg (av) tokens in bank
     if (not TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankABTokens) then
          TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankABTokens = 0;
     end

     -- bg (ab) tokens in bank
     if (not TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankAVTokens) then
          TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankAVTokens = 0;
     end

     -- bg (wsg) tokens in bank
     if (not TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankWSGTokens) then
          TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankWSGTokens = 0;
     end
   
   -- bg (eye) tokens in bank
  if (not TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankEYETokens) then
          TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].BankEYETokens = 0;
     end

     TitanPanelHonorButton_CheckVersion();

     -- check for new day, reset if it is
     TitanPanelHonorButton_ResetToday();

end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_CheckVersion()
-- DESC : Check versioning
-- **************************************************************************
function TitanPanelHonorButton_CheckVersion()
     
     if(TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].version ~= TITAN_HONOR_VERSION) then
          if(TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].version > TITAN_HONOR_VERSION) then
               -- wtf is this user doing?
               -- to be implemented
               -- dont forget 
               DEFAULT_CHAT_FRAME:AddMessage("Current TitanHonor version ("..TITAN_HONOR_VERSION..") is older then the one your have ran last time ("..TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].version..")! Prior to this expect errors, expect chaos and expect warlocks to rule the world!",1,0,0);
          end
          if(TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].version < TITAN_HONOR_VERSION) then
               TITAN_HONOR_USERS[TITAN_HONOR_PLAYER].version = TITAN_HONOR_VERSION;
               -- nothing here yet
               -- space saved for future updates
          end
     end

end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_ResetToday()
-- DESC : Reset daily kills
-- **************************************************************************
function TitanPanelHonorButton_ResetToday()
     local hk, contribution;

     -- Yesterday's values
     hk, contribution = GetPVPYesterdayStats();

     -- if yesterday's values differ from when last logged in, wipe kills for today
     if (     TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].yesterdayHK ~= hk or
          TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].yesterdayCP ~= contribution
     ) then
          -- new day
          TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].yesterdayHK = hk;
          TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].yesterdayCP = contribution;

          -- wipe honor kills from last day
          TITAN_HONOR_KILLSTODAY[TITAN_HONOR_PLAYER] = {};

          -- wipe estinated CP for today
          TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].estCP = 0;
          TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].killsCP = 0;
          TITAN_HONOR_CFG[TITAN_HONOR_PLAYER].bonusCP = 0;
          
     end
end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_Login()
-- DESC : Calculate estimated honor
-- VARS : ecp = <research>, kills = <research>
-- **************************************************************************
function TitanPanelHonorButton_EstimateCP(ecp, kills)
-- Tristanian : Obsolete stuff
     --return ecp
--     if (TITAN_HONOR_KILLSTODAY[TITAN_HONOR_PLAYER][TITAN_HONOR_LASTKILL] > 10) then
--          return 0
--     elseif (TITAN_HONOR_KILLSTODAY[TITAN_HONOR_PLAYER][TITAN_HONOR_LASTKILL] == 1) then
--          return ecp
--     else
--          return ecp - ( (TITAN_HONOR_KILLSTODAY[TITAN_HONOR_PLAYER][TITAN_HONOR_LASTKILL] - 1) / 10 * ecp );
--     end

-- Tristanian : New stuff (experimental)

local factor
          factor = (11 - kills) / 10
          if factor < 0 then
               factor = 0
          end
          local est = ceil(ecp * factor)
       return est;
end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_ToggleVar_BG_AutoRelease()
-- DESC : Toggle BG Autorelease
-- **************************************************************************
function TitanPanelHonorButton_ToggleVar_BG_AutoRelease()
     TitanToggleVar(TITAN_HONOR_ID, "BG_AutoRelease");
     TitanPanelButton_UpdateButton(TITAN_HONOR_ID);
end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_ToggleVar_BG_AutoJoin()
-- DESC : Toggle BG AutoJoin
-- **************************************************************************
function TitanPanelHonorButton_ToggleVar_BG_AutoJoin()
     TitanToggleVar(TITAN_HONOR_ID, "BG_AutoJoin");
     TitanPanelButton_UpdateButton(TITAN_HONOR_ID);
end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_ToggleVar_BG_ShowMarks()
-- DESC : Toggle BG ShowMarks
-- **************************************************************************
function TitanPanelHonorButton_ToggleVar_ShowMarks()
     TitanToggleVar(TITAN_HONOR_ID, "ShowMarks");
     TitanPanelButton_UpdateButton(TITAN_HONOR_ID);
end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_ToggleVar_Verbose()
-- DESC : Toggle Verbose mode
-- **************************************************************************
function TitanPanelHonorButton_ToggleVar_Verbose()
     TitanToggleVar(TITAN_HONOR_ID, "Verbose");
     TitanPanelButton_UpdateButton(TITAN_HONOR_ID);
end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_ToggleVar_AlternateView()
-- DESC : Toggle AlternateView
-- **************************************************************************
function TitanPanelHonorButton_ToggleVar_AlternateView()
     TitanToggleVar(TITAN_HONOR_ID, "AlternateView");
     TitanPanelButton_UpdateButton(TITAN_HONOR_ID);
end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_CheckBGConfirm()
-- DESC : Auto-join battlegrounds
-- **************************************************************************
function TitanPanelHonorButton_CheckBGConfirm()
     local status, index;

     for i=1,MAX_BATTLEFIELD_QUEUES do
          status,_,_ = GetBattlefieldStatus(i);
          if(status == "confirm") then
               index = i;
               break
          end
     end

     if ((status == "confirm") and (TitanGetVar(TITAN_HONOR_ID, "BG_AutoJoin") == 1)) then
          if (StaticPopup_Visible("CONFIRM_BATTLEFIELD_ENTRY")) then
               if (TITAN_HONOR_BGCONFIRM == 0) then
                    DEFAULT_CHAT_FRAME:AddMessage(TITAN_HONOR_TXT_AUTOJOIN, 1, 1, 0);
                    TITAN_HONOR_BGCONFIRM = GetTime() + TITAN_HONOR_BGAUTOJOINTIMER;
               elseif (GetTime() > TITAN_HONOR_BGCONFIRM) then
                    TITAN_HONOR_BGCONFIRM = 0;
                    DEFAULT_CHAT_FRAME:AddMessage(TITAN_HONOR_TXT_NOWJOIN, 1, 1, 0);
                    AcceptBattlefieldPort(index,1)
                    StaticPopup_Hide("CONFIRM_BATTLEFIELD_ENTRY");
               end
          end
     end
end

-- **************************************************************************
-- NAME : TitanPanelHonorButton_StaticPopup_OnHide()
-- DESC : Create popup to confirm battlefield entry
-- NOTE : If the "Hide" button is clicked when ready to enter BG, it means
--        the user doesn't want to join, so we diable auto-join.
-- **************************************************************************
function TitanPanelHonorButton_StaticPopup_OnHide()
     old_StaticPopup_OnHide();
     if (this.which == "CONFIRM_BATTLEFIELD_ENTRY") and (TITAN_HONOR_BGCONFIRM ~= 0) then
          TITAN_HONOR_BGCONFIRM = 0;
          DEFAULT_CHAT_FRAME:AddMessage(TITAN_HONOR_TXT_CANCELJOIN, 1, 1, 0);
     end
end