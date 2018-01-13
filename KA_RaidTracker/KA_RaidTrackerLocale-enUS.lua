local L = AceLibrary("AceLocale-2.2"):new("KA_RaidTracker")

L:RegisterTranslations("enUS", function() return {
    -- MouseOver Fubar Tooltips
    ["Raid Tracker"] = true,
    ["Raid Tracker Options"] = true,
    ["Shows the options dialog"] = true,
    
    ["Ready Check"] = true,
    ["Performs a ready check, asking all CTRA users if they are ready"] = true,
    
    ["Rly Check"] = true,
    ["Performs a rly check, asking all CTRA users if they are rly"] = true,
    
    ["Durability Check"] = true,
    ["Performs a durability check, which shows every CTRA member's durability percent"] = true,
    
    ["\nSaved Instances:"] = true,
    ["List of Instances"] = true,
    
    ["No saved instances found"] = true,
    ["Message when no instances"] = true,
    
    -- Menu text
	["Convert Party to Raid"] = true,
	["Converts the Party to a Raid,"] = true,
    ["Resurection Monitor"] = true,
    ["Shows or hides the Resurrection Monitor"] = true,
    
    ["Show Status Monitor"] = true,
    ["Shows or hides the Satus Monitor"] = true,
    
    ["Current Change Log"] = true,
    ["View the KARaid Change Log"] = true,
	
    ["Help"] = true,
    ["Show KARaid Help window"] = true,
    
        -- Group submenu
    ["Groups"] = true,
    ["Shows or hides the Raid Groups"] = true,
    
    ["Show All"] = true,
    ["Show all groups"] = true,
    
    ["Show Groups"] = true,
    ["Show Raid Groups"] = true,
    
    ["Hide Groups"] = true,
    ["Hide All Groups"] = true,
    
        -- Raid Submenu
    ["Raid Managment"] = true,
    ["Raid Managment Functions"] = true,
    
	["Promote"] = true,
	["Promotes Player to Assistant Status"] = true,
	
	["Demote"] = true,
	["Demotes Player from Assistant Status"] = true,
	
    ["Update Status"] = true,
    ["Update the Raid Status"] = true,
    
    ["Disband Raid"] = true,
    ["Disbands the Raid"] = true,
    
    ["Ask for Votes"] = true,
    ["Performs a vote, asking the raid for their opinion on the question. Results are broadcasted to raid chat after 30 seconds"] = true, 
    ["<Question>"] = true;
    
    ["Raid Messages"] = true,
    ["Open an Inout Box to send a message to all CTRA users in the raid, which appears in the center of the screen"] = true, 
    
    ["Quiet Raid"] = true,
    ["Stop the raid from talking while leaders talk"] = true,
    
            -- Keyword submenu
    ["Autoinvite"] = true,
    ["Automatically invites people whispering you the set keyword"] = true,
    
    ["Change Keyword"] = true,
    ["Set a new Keyword"] = true,
    ["<New Keyword>"] = true,
    
    ["Turn off"] = true,
    ["Disable Autoinvite"] = true,
    
            -- Invites submenu
    ["Guild Invitations"] = true,
    ["Invite Guild Members to Raid"] = true,
    
    ["All Members"]  = true,
    ["Invite All Guild Members"] = true,
    
    ["Members in Zone"] = true,
    ["Invite Guild Members in your own Zone"] = true,
    
    ["Min Level"] = true,
    ["Set the Minimun Level to receive the Invite"] = true,
    
    ["Max Level"] = true,
    ["Set the Maximum Level to receive the Invite"] = true,
    
    ["Send Invitations"] = true,
    ["This will Invite Guild Members according to the choosen parameters"] = true,
    
        -- Check Submenus
    ["Check Functions"] = true,
    ["Status Check Functions"] = true,
    
    ["Reagent Check"] = true,
    ["Performs a reagent check, which shows every CTRA member's reagent count"] = true,

    ["Resistance Check"] = true,
    ["Performs a resistance check, which shows every CTRA member's resistances"] = true,

    ["Item Check"] = true,
    ["Allows to see everyone in raid who has the item listed"] = true,
    ["<ItemName> or <[Item Link]>"] = true, 

    ["Zone Check"] = true,
    ["Performs a zone check, which shows every CTRA member outside of your zone"] = true,

    ["Version Check"] = true,
    ["Performs a version check, which shows every member's CTRA version"] = true,
            
    
	
    [" (requires Leader or Promoted Status)"] = true,
	[" (requires Party Leader Status)"] = true,
} end)