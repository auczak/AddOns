
-- Local Objects
local L = AceLibrary("AceLocale-2.2"):new("KA_RaidTracker");    -- Localization DB
local Tablet = AceLibrary("Tablet-2.0");                        -- Tooltip-style display
local Dewdrop = AceLibrary("Dewdrop-2.0");                      -- Clean dropdown menu interface

-- Set up big ace object
local KARaidTrackerAce = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceDB-2.0", "FuBarPlugin-2.0");
KARaidTrackerAce.version = GetAddOnMetadata("KA_RaidTracker","Version");
KARaidTrackerAce.title = "RaidTracker";
KARaidTrackerAce.hasIcon = true;
KARaidTrackerAce.clickableTooltip = true;
KARaidTrackerAce.defaultPosition = "RIGHT";
KARaidTrackerAce.printFrame = DEFAULT_CHAT_FRAME;
KARaidTrackerAce.debugFrame = DEFAULT_CHAT_FRAME;

-- Set up the data
KARaidTrackerAce:RegisterDB("KARaidTrackerAceDB")
KARaidTrackerAce:RegisterDefaults("profile", {
    showwindows = {
        res = false,
        status = false,
    },
    showall = false,
    invites = {
        all = false,
        zone = false,
        minlevel = 35,
        maxlevel = 55,
    },
    quiet = false,
    rsinput = {
        show = false,
        xOfs = 0,
        yOfs = 0,
        saved = false,
    },
})

-- Dropdown Menu Creation (thanks FarmerFu)
local MenuOpts = {
    handler = KARaidTrackerAce,
	type = "group",
	args = {
        changelog = {
            -- Latest version changes
		    type = "execute",
            order = 9,
			name = L["Current Change Log"],
            desc = L["View the KARaid Change Log"],
			func = function() ExecuteChatCommand("/ralog") end,
		},
        help = {
            -- Show help window
            type = "execute",
            order = 10,
            name = L["Help"],
            desc = L["Show KARaid Help window"],
			func = function() ExecuteChatCommand("/rahelp") end,
		},
    },
}

function KARaidTrackerAce:OnInitialize()
	KARaidTrackerAce.OnMenuRequest = MenuOpts;
end

-- Actions when Tool is Clicked with Left Button (Fubar Default)
function KARaidTrackerAce:OnClick()
	if(IsShiftKeyDown()) then
		ExecuteChatCommand("/karaidtracker options");
	else
		ExecuteChatCommand("/karaidtracker");
	end
end

-- Mouseover menu
function KARaidTrackerAce:OnTooltipUpdate()
    -- Tooltip
	cat = Tablet:AddCategory(
		"text", "Hint:",
		"columns", 2,
		"child_textR", 0,
		"child_textG", 1,
		"child_textB", 0,
		"child_text2R", r,
		"child_text2G", g,
		"child_text2B", b
	)
	cat:AddLine("text", "Click:", "text2", L["Raid Tracker"])
	cat:AddLine("text", "ShiftClick:", "text2", L["Raid Tracker Options"])
--	cat:AddLine("text", "CtrlClick:", "text2", L["Rly Check"])
--  cat:AddLine("text", "AtlClick:", "text2", L["Durability Check"])
end

-- Execute the /command in Chat
function ExecuteChatCommand(arg)
	if( not DEFAULT_CHAT_FRAME ) then return end
	DEFAULT_CHAT_FRAME.editBox:SetText(arg);
	ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox);
end

