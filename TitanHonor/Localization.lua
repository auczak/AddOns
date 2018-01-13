function TitanHonor_LocalizeEN()

     TITAN_HONOR_TXT_HONORKILL_PATTERN = "^(.+)%s+dies%, honorable kill Rank: (.+) %((%d+) Honor Points%)$";
     TITAN_HONOR_TXT_HONORBONUS_PATTERN = "^You have been awarded (%d+) honor points%.$";

     TITAN_HONOR_TXT_UNKNOWN_ENTITY = "Unknown Entity";

--     TITAN_HONOR_TXT_HONOR_UNKNOWN = "unknown (daily reset possible).";
     TITAN_HONOR_TXT_AUTOJOIN = "Auto-joining Battleground in 15secs...";
     TITAN_HONOR_TXT_NOWJOIN = "Now joining battleground. Good luck!";
     TITAN_HONOR_TXT_CANCELJOIN = "Cancelled joining battleground.";
     TITAN_HONOR_TXT_EK = "Eastern Kingdoms";

     TITAN_HONOR_MENU_AUTOJOIN = "Auto-Join Battleground";
     TITAN_HONOR_MENU_AUTORES = "Auto-Release";
     TITAN_HONOR_MENU_SHOWHONORGAIN = "Show honor gained";

     
     TITAN_HONOR_CHAT_BONUSPATTERN = "You have been awarded %d honor points.";
     TITAN_HONOR_CHAT_KILLPATTERN = "Honor kill: %s (kills today: %d)  Est. Honor: %d";

     TITAN_HONOR_BUTTON_PATTERN = "Points: %s HK: %s";
     TITAN_HONOR_BUTTON_LABEL = "Honor: ";

     TITAN_HONOR_TOOLTIP_STATS = " stats:";
     TITAN_HONOR_TOOLTIP_AVG_HONOR = "Average honor: ";
     TITAN_HONOR_TOOLTIP_HONORPERHOUR = "Average honor/hour (min): ";
     TITAN_HONOR_TOOLTIP_CURRENTBG = "Current battleground: ";
     TITAN_HONOR_TOOLTIP_HONORSOFAR = "Honor gained so far: ";
     TITAN_HONOR_TOOLTIP_CURRENCY = "Currency:";
     TITAN_HONOR_TOOLTIP_HONORCP = "Honor points:";
     TITAN_HONOR_TOOLTIP_ARENACP = "Arena points:";
     TITAN_HONOR_TOOLTIP_TODAY = "Today:";
     TITAN_HONOR_TOOLTIP_HKS = "Honorable Kills:";
     TITAN_HONOR_TOOLTIP_HONORFROMHK = "Honor from Kills:";
     TITAN_HONOR_TOOLTIP_BONUSHONOR = "Bonus honor:";
     TITAN_HONOR_TOOLTIP_HONOREST = "Honor Estimation:"

     -- added in 1.13
     TITAN_HONOR_ITEM_AVMARK = "Alterac Valley Mark of Honor"
     TITAN_HONOR_ITEM_ABMARK = "Arathi Basin Mark of Honor"
     TITAN_HONOR_ITEM_WSGMARK = "Warsong Gulch Mark of Honor"
     TITAN_HONOR_ITEM_EOTSMARK = "Eye of the Storm Mark of Honor"
     TITAN_HONOR_MENU_SHOWMARKS = "Show Battleground Tokens";
     TITAN_HONOR_TOOLTIP_BGTOKENS = "Battleground Tokens:";
     TITAN_HONOR_TOOLTIP_SCHEMA = "Total/Bags/Bank";
     TITAN_HONOR_TOOLTIP_AV = "Alterac Valley:";
     TITAN_HONOR_TOOLTIP_AB = "Arathi Basin:";
     TITAN_HONOR_TOOLTIP_WSG = "Warsong Gulch:";
  TITAN_HONOR_TOOLTIP_EYE = "Eye of The Storm:";

end

function Localize()
     TitanHonor_LocalizeEN();
     
     local locale = GetLocale();
     if ( locale == "deDE" ) then
          TitanHonor_LocalizeDE();
     elseif ( locale == "frFR" ) then
          TitanHonor_LocalizeFR();
     elseif ( locale == "esES" ) then
          TitanHonor_LocalizeES();
     end
end