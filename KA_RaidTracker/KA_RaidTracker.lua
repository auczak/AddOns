UIPanelWindows["KA_RaidTrackerFrame"] = { area = "left", pushable = 1, whileDead = 1 };

KA_RaidTracker_Version = "v1.5.3 (Celess)";

-- Globals
KA_RaidTracker_LastWipe = 0;

local KA_RaidTracker_RarityTable = {
	["ff9d9d9d"] = 1,
	["ffffffff"] = 2,
	["ff1eff00"] = 3,
	["ff0070dd"] = 4,
	["ffa335ee"] = 5,
	["ffff8000"] = 6,
	["ffe6cc80"] = 7,
};
local KA_RaidTracker_ClassTable = {
	["WARRIOR"] = 1,
	["ROGUE"] = 2,
	["HUNTER"] = 3,
	["PALADIN"] = 4,
	["SHAMAN"] = 5,
	["DRUID"] = 6,
	["WARLOCK"] = 7,
	["MAGE"] = 8,
	["PRIEST"] = 9,
}
local KA_RaidTracker_RaceTable = {
	["Gnome"] = 1,
	["Human"] = 2,
	["Dwarf"] = 3,
	["NightElf"] = 4,
	["Troll"] = 5,
	["Scourge"] = 6, --Undead
	["Orc"] = 7,
	["Tauren"] = 8,
	["Draenei"] = 9,
	["BloodElf"] = 10,
}
local KA_RaidTracker_Events = { };
local KA_RaidTracker_TimeOffset = 0;
local KA_RaidTracker_QuickLooter = {"disenchanted", "bank"};
local KA_RaidTracker_AutoBossChangedTime = 0;
local PlayerGroupsIndexes = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};


function KA_RaidTracker_SortRaidTable()
	table.sort(
		KARaidTrackerDB.RaidLog,
		function(a1, a2)
			if ( a1 and a2 ) then
				return KARaidTrackerUtility:GetTime(a1.key) > KARaidTrackerUtility:GetTime(a2.key);
			end
		end
	);
end

function KA_RaidTracker_GameTimeFrame_Update()
	KA_RaidTracker_GameTimeFrame_Update_Original();
	local hour, minute = GetGameTime();
	local time = ((hour * 60) + minute) * 60;
	if(not KARaidTrackerDB.Options["TimeOffsetStatus"]) then
		KARaidTrackerDB.Options["TimeOffsetStatus"] = time;
	elseif(KARaidTrackerDB.Options["TimeOffsetStatus"] ~= time) then
		local ltimea = date("*t");
		local ltime = (((ltimea["hour"] * 60) + ltimea["min"]) * 60 + ltimea["sec"]) + (KARaidTrackerDB.Options["Timezone"] * 3600);
		local timediff;
		if(time > ltime) then
			timediff = time - ltime;
			if(timediff >= 43200) then
				KA_RaidTracker_TimeOffset = timediff - 86400;
			else
				KA_RaidTracker_TimeOffset = timediff;
			end
		elseif(time < ltime) then
			timediff = ltime - time;
			if(timediff >= 43200) then
				KA_RaidTracker_TimeOffset = 86400 - timediff;
			else
				KA_RaidTracker_TimeOffset = timediff * -1;
			end
		else
			KA_RaidTracker_TimeOffset = 0;
		end
		KARaidTrackerUtility:Debug("KA_RaidTracker_TimeOffset", KA_RaidTracker_TimeOffset);
		GameTimeFrame_Update = KA_RaidTracker_GameTimeFrame_Update_Original;
		KARaidTrackerDB.Options["TimeOffsetStatus"] = nil;
	end
end

function KA_RaidTracker_GetGameTimeOffset()
	if(KARaidTrackerDB.Options["TimeOffsetStatus"]) then
		return;
	end
	if(not KA_RaidTracker_GameTimeFrame_Update_Original) then
		KA_RaidTracker_GameTimeFrame_Update_Original = GameTimeFrame_Update;
	end
	GameTimeFrame_Update = KA_RaidTracker_GameTimeFrame_Update;
	return;
end

function KA_RaidTracker_GetRaidTitle(id, hideid, showzone, shortdate)
	local RaidTitle = "";
	if ( KARaidTrackerDB.RaidLog[id] and KARaidTrackerDB.RaidLog[id].key ) then
		local _, _, mon, day, year, hr, min, sec = string.find(KARaidTrackerDB.RaidLog[id].key, "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)");
		if ( mon ) then
			local months = {
				"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
			};
			if ( not hideid ) then
				RaidTitle = RaidTitle .. "[" .. (getn(KARaidTrackerDB.RaidLog)-id+1) .. "] ";
			end
			if ( not shortdate ) then
				RaidTitle = RaidTitle .. months[tonumber(mon)] .. " " .. day .. " '" .. year .. ", " .. hr .. ":" .. min;
			else
				RaidTitle = RaidTitle .. mon .. "/" .. day .. " " .. hr .. ":" .. min;
			end
			if ( showzone and KARaidTrackerDB.RaidLog[id].zone) then
				RaidTitle = RaidTitle .. " " .. KARaidTrackerDB.RaidLog[id].zone;
			end
			return RaidTitle;
		else
			return "";
		end
	end
	return "";
end

function KA_RaidTracker_GetLootId(raidid, sPlayer, sItem, sTime)
	KARaidTrackerUtility:Debug("KA_RaidTracker_GetLootId", raidid, sPlayer, sItem, sTime);
	local lootid = nil;
	for key, val in pairs(KARaidTrackerDB.RaidLog[raidid]["Loot"]) do
		if(val["player"] == sPlayer and val["item"]["id"] == sItem and val["time"] == sTime) then
			lootid = key;
			break;
		end
	end
	return lootid;
end

function KA_RaidTracker_Update()
    if(KARaidTrackerDB.Options["CurrentRaid"]) then
      KA_RaidTrackerFrameEndRaidButton:Enable();
      KA_RaidTrackerFrameSnapshotButton:Enable();
    else
        KA_RaidTrackerFrameEndRaidButton:Disable();
        KA_RaidTrackerFrameSnapshotButton:Disable();
    end
    
    if((GetNumRaidMembers() == 0) and (GetNumPartyMembers() == 0)) then
        KA_RaidTrackerFrameNewRaidButton:Disable();
    else
	    if((GetNumRaidMembers() > 0)) then
        KA_RaidTrackerFrameNewRaidButton:Enable();
      else
		    if((GetNumPartyMembers() > 0) and (KARaidTrackerDB.Options["LogGroup"] == 1)) then
	        KA_RaidTrackerFrameNewRaidButton:Enable();
      	else
	        KA_RaidTrackerFrameNewRaidButton:Disable();
      	end;
      end;
    end
    
    --[[
    if ( KA_RaidTrackerFrame.selected ) then
    	KA_RaidTrackerFrameView2Button:Enable();
    else
    	KA_RaidTrackerFrameView2Button:Disable();
    end
    ]]

	if ( getn(KA_RaidTracker_LastPage) > 0 ) then
		KA_RaidTrackerFrameBackButton:Enable();
	else
		KA_RaidTrackerFrameBackButton:Disable();
	end
	if ( getn(KARaidTrackerDB.RaidLog) > 0 ) then
		if ( KA_RaidTrackerFrame.selected ) then
			local selected;
			if ( not KARaidTrackerDB.RaidLog[KA_RaidTrackerFrame.selected] ) then
				while ( not selected ) do
					if ( KA_RaidTrackerFrame.selected < 1 ) then
						selected = 1;
						KA_RaidTrackerFrame.selected = nil;
					else
						KA_RaidTrackerFrame.selected = KA_RaidTrackerFrame.selected - 1;
						if ( KARaidTrackerDB.RaidLog[KA_RaidTrackerFrame.selected] ) then
							selected = 2;
						end
					end
				end
			end
			if ( not selected or selected == 2 ) then
				if ( not KARaidTrackerDB.RaidLog[KA_RaidTrackerFrame.selected] or getn(KARaidTrackerDB.RaidLog[KA_RaidTrackerFrame.selected]["Loot"]) == 0 ) then
					KA_RaidTrackerFrame.type = "raids";
					KA_RaidTrackerFrameViewButton:Disable();
				else
					KA_RaidTrackerFrameViewButton:Enable();
				end
			end
		end

		KA_EmptyRaidTrackerFrame:Hide();
		KA_RaidTrackerFrameDeleteButton:Enable();

		local hasItem;
		for k, v in pairs(KARaidTrackerDB.RaidLog) do
			for key, val in pairs(v["Loot"]) do
				if ( val["player"] == KA_RaidTrackerFrame.player ) then
					hasItem = 1;	
					break;
				end
			end
			if ( hasItem ) then
				break;
			end
		end

		if ( KA_RaidTrackerFrame.type == "raids" or not KA_RaidTrackerFrame.type ) then
			KA_RaidTrackerFrameViewButton:SetText("View Items");
		elseif ( KA_RaidTrackerFrame.type == "items" ) then
			KA_RaidTrackerFrameViewButton:SetText("View Players");
		elseif ( KA_RaidTrackerFrame.type == "player" ) then
			if ( not hasItem ) then
				KA_RaidTrackerFrameViewButton:Disable();
			else
				KA_RaidTrackerFrameViewButton:Enable();
			end
			KA_RaidTrackerFrameViewButton:SetText("View Loot");
			KA_RaidTrackerFrameDeleteButton:Disable();
		elseif ( KA_RaidTrackerFrame.type == "playeritems" ) then
			KA_RaidTrackerFrameViewButton:SetText("View Raids");
			KA_RaidTrackerFrameDeleteButton:Disable();
			if ( not hasItem ) then
				KA_RaidTrackerFrame.type = "player";
				KA_RaidTracker_Update();
				KA_RaidTracker_UpdateView();
			end
		elseif ( KA_RaidTrackerFrame.type == "itemhistory" ) then
			KA_RaidTrackerFrameDeleteButton:Disable();
			KA_RaidTrackerFrameViewButton:Disable();
		elseif ( KA_RaidTrackerFrame.type == "events" ) then
			KA_RaidTrackerFrameDeleteButton:Disable();
			KA_RaidTrackerFrameViewButton:Disable();
		end
	else
		KA_EmptyRaidTrackerFrame:Show();
		KA_RaidTrackerDetailScrollFramePlayers:Hide();
		KA_RaidTrackerDetailScrollFrameItems:Hide();
		KA_RaidTrackerDetailScrollFramePlayer:Hide();
		KA_RaidTrackerDetailScrollFrameEvents:Hide();
		KA_RaidTrackerFrameDeleteButton:Disable();
		KA_RaidTrackerFrameViewButton:Disable();
	end

	local numRaids = getn(KARaidTrackerDB.RaidLog);
	local numEntries = numRaids;

	-- ScrollFrame update
	FauxScrollFrame_Update(KA_RaidTrackerListScrollFrame, numEntries, 6, 16, nil, nil, nil, KA_RaidTrackerHighlightFrame, 293, 316 );
	
	KA_RaidTrackerHighlightFrame:Hide();
	for i=1, 6, 1 do
		local title = getglobal("KA_RaidTrackerTitle" .. i);
		local normaltext = getglobal("KA_RaidTrackerTitle" .. i .. "NormalText");
		local highlighttext = getglobal("KA_RaidTrackerTitle" .. i .. "HighlightText");
		local disabledtext = getglobal("KA_RaidTrackerTitle" .. i .. "DisabledText");
		local highlight = getglobal("KA_RaidTrackerTitle" .. i .. "Highlight");

		local index = i + FauxScrollFrame_GetOffset(KA_RaidTrackerListScrollFrame); 
		if ( index <= numEntries ) then
			local raidTitle = KA_RaidTracker_GetRaidTitle(index, nil, 1, 1);
			local raidTag = KARaidTrackerDB.RaidLog[index]["note"];
			if ( not raidTag ) then
				raidTag = "";
			else
				raidTag = " (" .. raidTag .. ")";
			end
			if ( raidTitle ) then
				title:SetText(raidTitle .. raidTag);
			else
				title:SetText("");
			end
			title:Show();
			-- Place the highlight and lock the highlight state
			if ( KA_RaidTrackerFrame.selected and KA_RaidTrackerFrame.selected == index ) then
				KA_RaidTrackerSkillHighlight:SetVertexColor(1, 1, 0);
				KA_RaidTrackerHighlightFrame:SetPoint("TOPLEFT", "KA_RaidTrackerTitle"..i, "TOPLEFT", 0, 0);
				KA_RaidTrackerHighlightFrame:Show();
				title:LockHighlight();
			else
				title:UnlockHighlight();
			end
			
		else
			title:Hide();
		end

	end
end

function KA_RaidTracker_SelectRaid(id)
	local raidid = id + FauxScrollFrame_GetOffset(KA_RaidTrackerListScrollFrame);
	KA_RaidTracker_GetPage();
	KA_RaidTrackerFrame.selected = raidid;
	--if ( getn(KARaidTrackerDB.RaidLog[raidid]["Loot"]) == 0 or ( KA_RaidTrackerFrame.type and KA_RaidTrackerFrame.type ~= "items" ) ) then
		KA_RaidTrackerFrame.type = "raids";
	--end

	KA_RaidTracker_UpdateView();
	KA_RaidTracker_Update();
end

function KA_RaidTracker_ShowInfo(player)
	KA_RaidTracker_GetPage();

	KA_RaidTrackerFrame.type = "player";
	KA_RaidTrackerFrame.player = player;
	KA_RaidTrackerFrame.selected = nil;
	
	KA_RaidTracker_Update();
	KA_RaidTracker_UpdateView();
end

function KA_RaidTracker_Delete(id, type, typeid)
	KARaidTrackerUtility:Debug("DELETE", type, typeid);
	if ( type == "raid" ) then
		table.remove(KARaidTrackerDB.RaidLog, id);
		if ( id == KARaidTrackerDB.Options["CurrentRaid"] ) then
			KARaidTrackerDB.Options["CurrentRaid"] = nil;
		end
		if ( KA_RaidTrackerFrame.selected == id ) then
			KA_RaidTrackerFrame.selected = KA_RaidTrackerFrame.selected - 1;
			if ( KA_RaidTrackerFrame.selected < 1 ) then
				KA_RaidTrackerFrame.selected = 1;
			end
			KA_RaidTrackerFrame.type = "raids";
		end
	elseif ( type == "item" ) then
		local itemplayer, itemitemid, itemtime;
		itemplayer = this:GetParent().itemplayer;
		itemitemid = this:GetParent().itemitemid;
		itemtime = this:GetParent().itemtime;
		local lootid = KA_RaidTracker_GetLootId(id, itemplayer, itemitemid, itemtime);
		table.remove(KARaidTrackerDB.RaidLog[id]["Loot"], lootid);
	elseif ( type == "player" ) then
		for key, val in pairs(KARaidTrackerDB.RaidLog[id]["Join"]) do
			if ( val["player"] == typeid ) then
				KARaidTrackerUtility:Debug("DELETE", "JOIN", "FOUND PLAYER", key, val["player"]);
				KARaidTrackerDB.RaidLog[id]["Join"][key] = nil;
			end
		end
		for key, val in pairs(KARaidTrackerDB.RaidLog[id]["Leave"]) do
			if ( val["player"] == typeid ) then
				KARaidTrackerUtility:Debug("DELETE", "LEAVE", "FOUND PLAYER", key, val["player"]);
				KARaidTrackerDB.RaidLog[id]["Leave"][key] = nil;
			end
		end
		if(id == KARaidTrackerDB.Options["CurrentRaid"]) then
			KARaidTrackerDB.Online[typeid] = nil;
		end
		if(KARaidTrackerDB.RaidLog[id]["PlayerInfos"]) then
			KARaidTrackerDB.RaidLog[id]["PlayerInfos"][typeid] = nil;
		end
	end
	KA_RaidTracker_Update();
	KA_RaidTracker_UpdateView();
end

function KA_RaidTracker_Sort(tbl, method, way)
	if ( way == "asc" ) then
		table.sort(
			tbl,
			function(a1, a2)
				return a1[method] < a2[method];
			end
		);
	else
		table.sort(
			tbl,
			function(a1, a2)
				return a1[method] > a2[method];
			end
		);
	end
	return tbl;
end

function KA_RaidTracker_SortPlayerRaids(id)
	if ( KA_RaidTrackerFrame.type == "itemhistory" ) then
		local table = { "name", "looter" };

		if ( KARaidTrackerDB.SortOptions["itemhistorymethod"] == table[id] ) then
			if ( KARaidTrackerDB.SortOptions["itemhistoryway"] == "asc" ) then
				KARaidTrackerDB.SortOptions["itemhistoryway"] = "desc";
			else
				KARaidTrackerDB.SortOptions["itemhistoryway"] = "asc";
			end
		else
			KARaidTrackerDB.SortOptions["itemhistoryway"] = "asc";
			KARaidTrackerDB.SortOptions["itemhistorymethod"] = table[id];
		end
	else		
		if ( KARaidTrackerDB.SortOptions["playerraidway"] == "asc" ) then
			KARaidTrackerDB.SortOptions["playerraidway"] = "desc";
		else
			KARaidTrackerDB.SortOptions["playerraidway"] = "asc";
		end
	end
	KA_RaidTracker_UpdateView();
end

function KA_RaidTracker_CompareItems(a1, a2)
	-- This function could probably be better, but I can't think of any better way while still maintaining functionality

	local filter, method, way = KARaidTrackerDB.SortOptions["itemfilter"], KARaidTrackerDB.SortOptions["itemmethod"], KARaidTrackerDB.SortOptions["itemway"];
	if ( KA_RaidTrackerFrame.type == "playeritems" ) then
		filter, method, way = KARaidTrackerDB.SortOptions["playeritemfilter"], KARaidTrackerDB.SortOptions["playeritemmethod"], KARaidTrackerDB.SortOptions["playeritemway"];
	end

	-- Check to see if it matches the rarity requirements
	--KARaidTrackerUtility:Debug(a2["item"]["c"]);
	if ( KA_RaidTracker_RarityTable[a1["item"]["c"]] < filter ) then
		return false;
	elseif ( KA_RaidTracker_RarityTable[a2["item"]["c"]] < filter ) then
		return true;
	end

	if ( method == "name" ) then
		local c1, c2 = a1["item"]["name"], a2["item"]["name"];
		if ( c1 == c2 ) then
			c1, c2 = a1["player"], a2["player"];
		end
		if ( way == "asc" ) then
			return c1 < c2;
		else
			return c1 > c2;
		end
	elseif ( method == "looter" ) then
		local c1, c2 = a1["player"], a2["player"];
		if ( c1 == c2 ) then
			c1, c2 = KA_RaidTracker_RarityTable[a2["item"]["c"]], KA_RaidTracker_RarityTable[a1["item"]["c"]];
			if ( c1 == c2 ) then
				c1, c2 = a1["item"]["name"], a2["item"]["name"];
			end
		end
		if ( way == "asc" ) then
			return c1 < c2;
		else
			return c1 > c2;
		end
	elseif ( method == "looted" ) then
		if ( way == "asc" ) then
			return KARaidTrackerUtility:GetTime(a1["time"]) < KARaidTrackerUtility:GetTime(a2["time"]);
		else
			return KARaidTrackerUtility:GetTime(a1["time"]) > KARaidTrackerUtility:GetTime(a2["time"]);
		end
	else
		local c1, c2 = KA_RaidTracker_RarityTable[a1["item"]["c"]], KA_RaidTracker_RarityTable[a2["item"]["c"]];
		if ( c1 == c2 ) then
			c1, c2 = a1["item"]["name"], a2["item"]["name"];
			if ( c1 == c2 ) then
				c1, c2 = a1["player"], a2["player"];
			else
				return c1 < c2;
			end
		end
		if ( way == "asc" ) then
			return c1 < c2;
		else
			return c1 > c2;
		end
	end
end

function KA_RaidTracker_SortItem(tbl, method, way)
    table.sort(
        tbl,
        KA_RaidTracker_CompareItems
    );
    local newtable = {}
    for key, val in pairs(tbl) do
        newtable[key] = val;
    end
    return newtable;
end

function KA_RaidTracker_SortItemBy(id)
	local table = { "name", "looted", "looter", "rarity" };
	local prefix = "";
	if ( KA_RaidTrackerFrame.type == "playeritems" ) then
		prefix = "player";
	end
	if ( KARaidTrackerDB.SortOptions[prefix.."itemmethod"] == table[id] ) then
		if ( KARaidTrackerDB.SortOptions[prefix.."itemway"] == "asc" ) then
			KARaidTrackerDB.SortOptions[prefix.."itemway"] = "desc";
		else
			KARaidTrackerDB.SortOptions[prefix.."itemway"] = "asc";
		end
	else
		KARaidTrackerDB.SortOptions[prefix.."itemmethod"] = table[id];
		KARaidTrackerDB.SortOptions[prefix.."itemway"] = "asc";
	end
	KA_RaidTracker_UpdateView();
end

function KA_RaidTracker_SortBy(id)
	local table = { "name", "join", "leave" };
	if ( KARaidTrackerDB.SortOptions["method"] == table[id] ) then
		if ( KARaidTrackerDB.SortOptions["way"] == "asc" ) then
			KARaidTrackerDB.SortOptions["way"] = "desc";
		else
			KARaidTrackerDB.SortOptions["way"] = "asc";
		end
	else
		KARaidTrackerDB.SortOptions["method"] = table[id];
		if ( table[id] ~= "leave" ) then
			KARaidTrackerDB.SortOptions["way"] = "asc";
		else
			KARaidTrackerDB.SortOptions["way"] = "desc";
		end
	end
	KA_RaidTracker_UpdateView();
end

function KA_RaidTracker_UpdateView()
	if ( KA_EmptyRaidTrackerFrame:IsVisible() ) then
		return;
	end
	local raidid = KA_RaidTrackerFrame.selected;
	
	if (KARaidTrackerDB.RaidLog[raidid] == nil) then
		raidid = nil;
	end;
	
	if(KA_RaidTrackerFrame.type == "events") then
		KA_RaidTrackerFrameView2Button:SetText("View Raid");
  else
  	KA_RaidTrackerFrameView2Button:SetText("View Events");
  	if(not raidid or ((not KARaidTrackerDB.RaidLog[raidid]["BossKills"] or getn(KARaidTrackerDB.RaidLog[raidid]["BossKills"]) == 0) and (not KARaidTrackerDB.RaidLog[raidid]["Events"] or getn(KARaidTrackerDB.RaidLog[raidid]["Events"]) == 0))) then
  		KA_RaidTrackerFrameView2Button:Disable();
  	else
  		KA_RaidTrackerFrameView2Button:Enable();
  	end
  end
	if ( KA_RaidTrackerFrame.type == "raids" or not KA_RaidTrackerFrame.type ) then
		KA_RaidTrackerDetailScrollFramePlayers:Show();
		KA_RaidTrackerDetailScrollFramePlayer:Hide();
		KA_RaidTrackerDetailScrollFrameItems:Hide();
		KA_RaidTrackerDetailScrollFrameEvents:Hide();
		local players = { };
		if ( KARaidTrackerDB.RaidLog[raidid] ) then

			local playerIndexes = { };
			for key, val in pairs(KARaidTrackerDB.RaidLog[raidid]["Join"]) do
				if ( val["player"] ) then
					local id = playerIndexes[val["player"]];
					local time = KARaidTrackerUtility:GetTime(val["time"]);
					if ( not id or time < players[id]["join"] ) then
						
						if ( playerIndexes[val["player"]] ) then
							players[id] = {
								["join"] = time,
								["name"] = val["player"]
							};
						else
							tinsert(players, {
								["join"] = time,
								["name"] = val["player"]
							});
							playerIndexes[val["player"]] = getn(players);
						end
					end
					id = playerIndexes[val["player"]];
					if ( not players[id]["lastjoin"] or players[id]["lastjoin"] < time ) then
						players[id]["lastjoin"] = time;
					end
				end
			end
			for key, val in pairs(KARaidTrackerDB.RaidLog[raidid]["Leave"]) do
				local id = playerIndexes[val["player"]];
				local time = KARaidTrackerUtility:GetTime(val["time"]);
				if ( id ) then
					if ( ( not players[id]["leave"] or time > players[id]["leave"] ) and time >= players[id]["lastjoin"] ) then
						players[id]["leave"] = time;
					end
				end
			end
			for k, v in pairs(players) do
				if ( not v["leave"] ) then
					-- Very ugly hack, I know :(
					players[k]["leave"] = 99999999999;
				end
			end
			players = KA_RaidTracker_Sort(players, KARaidTrackerDB.SortOptions["method"], KARaidTrackerDB.SortOptions["way"]);
			getglobal("KA_RaidTrackerDetailScrollFramePlayers").raidid = raidid;
			getglobal("KA_RaidTrackerDetailScrollFramePlayers").players = players;
			KA_RaidTracker_DetailScrollFramePlayers_Update();
		end
		KA_RaidTrackerParticipantsText:SetText("Participants (" .. getn(players) .. ")");
		KA_RaidTrackerDetailScrollFramePlayers:Show();
	elseif ( KA_RaidTrackerFrame.type == "items" ) then
		KA_RaidTrackerDetailScrollFramePlayers:Hide();
		KA_RaidTrackerDetailScrollFramePlayer:Hide();
		KA_RaidTrackerDetailScrollFrameItems:Show();
		KA_RaidTrackerDetailScrollFrameEvents:Hide();
		local numItems, numHidden = 0, 0;
		if ( KARaidTrackerDB.RaidLog[raidid] ) then
			local keystoremove = {};
			local loot = KA_RaidTracker_SortItem(KARaidTrackerDB.RaidLog[raidid]["Loot"], KARaidTrackerDB.SortOptions["itemmethod"], KARaidTrackerDB.SortOptions["itemway"]);
			for key, val in pairs(loot) do
				val["thisitemid"] = tonumber(key);
				if((not val["item"]["tooltip"] or getn(val["item"]["tooltip"]) == 0) and KARaidTrackerDB.Options["SaveTooltips"] == 1 and GetItemInfo("item:" .. val["item"]["id"])) then
					val["item"]["tooltip"] = KA_RaidTracker_GetItemTooltip(val["item"]["id"]);
					KARaidTrackerUtility:Debug("TooltipGet", val["item"]["name"]);
				end
				if ( KA_RaidTracker_RarityTable[val["item"]["c"]] >= KARaidTrackerDB.SortOptions["itemfilter"] ) then
					numItems = numItems + 1;
				else
					tinsert(keystoremove, key);
					numHidden = numHidden + 1;
				end
			end
			for key, val in pairs(keystoremove) do
				table.remove(loot, val);
			end
			getglobal("KA_RaidTrackerDetailScrollFrameItems").raidid = raidid;
			getglobal("KA_RaidTrackerDetailScrollFrameItems").loot = loot;
			KA_RaidTracker_DetailScrollFrameItems_Update();
			KA_RaidTrackerDetailScrollFrameItems:Show();
		end
		if ( numHidden == 0 ) then
			KA_RaidTrackerItemsText:SetText("Items (" .. numItems .. "):");
		else
			KA_RaidTrackerItemsText:SetText("Items (" .. numItems .. "/" .. numHidden + numItems .. ")");
		end
		UIDropDownMenu_SetSelectedID(KA_RaidTrackerRarityDropDown, KARaidTrackerDB.SortOptions["itemfilter"]);
		local colors = {
			"|c009d9d9dPoor|r",
			"|c00ffffffCommon|r",
			"|c001eff00Uncommon|r",
			"|c000070ddRare|r",
			"|c00a335eeEpic|r",
			"|c00ff8000Legendary|r",
			"|c00e6cc80Artifact",
		};
			
		KA_RaidTrackerRarityDropDownText:SetText(colors[KARaidTrackerDB.SortOptions["itemfilter"]]);
	elseif ( KA_RaidTrackerFrame.type == "player" ) then
		KA_RaidTrackerDetailScrollFramePlayers:Hide();
		KA_RaidTrackerDetailScrollFramePlayer:Show();
		KA_RaidTrackerDetailScrollFrameItems:Hide();
		KA_RaidTrackerDetailScrollFrameEvents:Hide();
		KA_RaidTrackerPlayerRaidTabLooter:Hide();
		KA_RaidTrackerPlayerRaidTab1:SetWidth(300);
		KA_RaidTrackerPlayerRaidTab1Middle:SetWidth(290);
		local name = KA_RaidTrackerFrame.player;

		local raids = { };
		for k, v in pairs(KARaidTrackerDB.RaidLog) do
			local isInRaid;
			for key, val in pairs(v["Join"]) do
				if ( val["player"] == name ) then
					tinsert(raids, { k, v });
					break;
				end
			end
		end
		
		table.sort(
			raids,
			function(a1, a2)
				if ( KARaidTrackerDB.SortOptions["playerraidway"] == "asc" ) then
					return KARaidTrackerUtility:GetTime(a1[2]["key"]) < KARaidTrackerUtility:GetTime(a2[2]["key"]);
				else
					return KARaidTrackerUtility:GetTime(a1[2]["key"]) > KARaidTrackerUtility:GetTime(a2[2]["key"]);
				end
			end
		);
		getglobal("KA_RaidTrackerDetailScrollFramePlayer").data = raids;
		getglobal("KA_RaidTrackerDetailScrollFramePlayer").name = name;
		getglobal("KA_RaidTrackerDetailScrollFramePlayer").maxlines = getn(raids);
		KA_RaidTracker_DetailScrollFramePlayer_Update();
		KA_RaidTrackerDetailScrollFramePlayer:Show();
		
		KA_RaidTrackerPlayerText:SetText(name .. "'s Raids (" .. getn(raids) .. "):");
	elseif ( KA_RaidTrackerFrame.type == "itemhistory" ) then
		KA_RaidTrackerDetailScrollFramePlayers:Hide();
		KA_RaidTrackerDetailScrollFramePlayer:Show();
		KA_RaidTrackerDetailScrollFrameItems:Hide();
		KA_RaidTrackerDetailScrollFrameEvents:Hide();
		KA_RaidTrackerPlayerRaidTabLooter:Show();
		KA_RaidTrackerPlayerRaidTab1:SetWidth(163);
		KA_RaidTrackerPlayerRaidTab1Middle:SetWidth(155);

		local name, totalItems = KA_RaidTrackerFrame.itemname, 0;

		local items = { };
		for k, v in pairs(KARaidTrackerDB.RaidLog) do
			for key, val in pairs(v["Loot"]) do
				if ( val["item"]["name"] == name ) then
					tinsert(items, { k, v, val });
					if ( val["item"]["count"] ) then
						totalItems = totalItems + val["item"]["count"];
					else
						totalItems = totalItems + 1;
					end
				end
			end
		end
		
		table.sort(
			items,
			function(a1, a2)
				if ( KARaidTrackerDB.SortOptions["itemhistorymethod"] == "looter" ) then
					if ( KARaidTrackerDB.SortOptions["itemhistoryway"] == "asc" ) then
						return a1[3]["player"] < a2[3]["player"];
					else
						return a1[3]["player"] > a2[3]["player"];
					end
				else
					if ( KARaidTrackerDB.SortOptions["itemhistoryway"] == "asc" ) then
						return KARaidTrackerUtility:GetTime(a1[2]["key"]) < KARaidTrackerUtility:GetTime(a2[2]["key"]);
					else
						return KARaidTrackerUtility:GetTime(a1[2]["key"]) > KARaidTrackerUtility:GetTime(a2[2]["key"]);
					end
				end
			end
		);

		getglobal("KA_RaidTrackerDetailScrollFramePlayer").data = items;
		getglobal("KA_RaidTrackerDetailScrollFramePlayer").name = name;
		getglobal("KA_RaidTrackerDetailScrollFramePlayer").maxlines = getn(items);
		KA_RaidTracker_DetailScrollFramePlayer_Update();
		KA_RaidTrackerDetailScrollFramePlayer:Show();
		KA_RaidTrackerPlayerText:SetText(name .. " (" .. getn(items) .. "/" .. totalItems .. "):");
	elseif ( KA_RaidTrackerFrame.type == "events" ) then
		KA_RaidTrackerDetailScrollFramePlayers:Hide();
		KA_RaidTrackerDetailScrollFramePlayer:Hide();
		KA_RaidTrackerDetailScrollFrameEvents:Show();
		KA_RaidTrackerDetailScrollFrameItems:Hide();
		KA_RaidTrackerPlayerBossesTabBoss:Show();
		KA_RaidTrackerPlayerBossesTab1:SetWidth(163);
		KA_RaidTrackerPlayerBossesTab1Middle:SetWidth(155);

		local events = {};
		if ( KARaidTrackerDB.RaidLog[raidid] and KARaidTrackerDB.RaidLog[raidid]["BossKills"] ) then
			for key, val in pairs(KARaidTrackerDB.RaidLog[raidid]["BossKills"]) do
				tinsert(events, val);
			end
		end
		getglobal("KA_RaidTrackerDetailScrollFrameEvents").raidid = raidid;
		getglobal("KA_RaidTrackerDetailScrollFrameEvents").events = events;
		
		KA_RaidTrackerEventsText:SetText("Events");
		KA_RaidTracker_DetailScrollFrameBoss_Update();
		KA_RaidTrackerDetailScrollFrameEvents:Show();
	elseif ( KA_RaidTrackerFrame.type == "playeritems" ) then
		KA_RaidTrackerDetailScrollFramePlayers:Hide();
		KA_RaidTrackerDetailScrollFramePlayer:Hide();
		KA_RaidTrackerDetailScrollFrameItems:Show();
		KA_RaidTrackerDetailScrollFrameEvents:Hide();
		local name = KA_RaidTrackerFrame.player;

		local loot = { };
		for k, v in pairs(KARaidTrackerDB.RaidLog) do
			for key, val in pairs(v["Loot"]) do
				if ( val["player"] == name ) then
					tinsert(
						loot,
						{
							["note"] = val["note"],
							["player"] = val["player"],
							["time"] = val["time"],
							["item"] = val["item"],
							["ids"] = { k, key }
						}
					);
				end
			end
		end

		local numItems, numHidden = 0, 0;
		local keystoremove = {};
		loot = KA_RaidTracker_SortItem(loot, KARaidTrackerDB.SortOptions["playeritemmethod"], KARaidTrackerDB.SortOptions["playeritemway"]);
		for key, val in pairs(loot) do
			if ( KA_RaidTracker_RarityTable[val["item"]["c"]] >= KARaidTrackerDB.SortOptions["playeritemfilter"] ) then
				numItems = numItems + 1;
			else
				tinsert(keystoremove, key);
				numHidden = numHidden + 1;
			end
		end
		for key, val in pairs(keystoremove) do
			table.remove(loot, val);
		end
		getglobal("KA_RaidTrackerDetailScrollFrameItems").raidid = raidid;
		getglobal("KA_RaidTrackerDetailScrollFrameItems").loot = loot;
		KA_RaidTracker_DetailScrollFrameItems_Update();
		if ( numHidden == 0 ) then
			KA_RaidTrackerItemsText:SetText(name .. "'s Loot (" .. numItems .. "):");
		else
			KA_RaidTrackerItemsText:SetText(name .. "'s Loot (" .. numItems .. "/" .. numHidden + numItems .. "):");
		end

		UIDropDownMenu_SetSelectedID(KA_RaidTrackerRarityDropDown, KARaidTrackerDB.SortOptions["playeritemfilter"]);
		local colors = {
			"|c009d9d9dPoor|r",
			"|c00ffffffCommon|r",
			"|c001eff00Uncommon|r",
			"|c000070ddRare|r",
			"|c00a335eeEpic|r",
			"|c00ff8000Legendary|r",
			"|c00e6cc80Artifact",
		};
			
		KA_RaidTrackerRarityDropDownText:SetText(colors[KARaidTrackerDB.SortOptions["playeritemfilter"]]);
	end
end

function KA_RaidTracker_DetailScrollFramePlayers_Update()
	local raidid = getglobal("KA_RaidTrackerDetailScrollFramePlayers").raidid;
	local players = getglobal("KA_RaidTrackerDetailScrollFramePlayers").players;
	local maxlines = getn(players);
	local line;
	local lineplusoffset;
	FauxScrollFrame_Update(KA_RaidTrackerDetailScrollFramePlayers, maxlines, 11, 18);
	for line=1, 11 do
		lineplusoffset = line+FauxScrollFrame_GetOffset(KA_RaidTrackerDetailScrollFramePlayers);
		if (lineplusoffset <= maxlines) then
			val = players[lineplusoffset];
			getglobal("KA_RaidTrackerPlayerLine" .. line).raidid = raidid;
			getglobal("KA_RaidTrackerPlayerLine" .. line).raidtitle = KA_RaidTracker_GetRaidTitle(raidid, 1);
			getglobal("KA_RaidTrackerPlayerLine" .. line).playername = val["name"];
			local name = getglobal("KA_RaidTrackerPlayerLine" .. line .. "Name");
			local number = getglobal("KA_RaidTrackerPlayerLine" .. line .. "Number");
			local join = getglobal("KA_RaidTrackerPlayerLine" .. line .. "Join");
			local leave = getglobal("KA_RaidTrackerPlayerLine" .. line .. "Leave");
			if ( name ) then
				name:SetText(val["name"]);
				local iNumber = lineplusoffset;
				if ( iNumber < 10 ) then
					iNumber = "  " .. iNumber;
				end
				number:SetText(iNumber);
				if(KARaidTrackerDB.Options["TimeFormat"] == 1) then
					join:SetText(date("%H:%M", val["join"]));
				else
					join:SetText(date("%I:%M%p", val["join"]));
				end
				if ( val["leave"] == 99999999999 ) then
					leave:SetText("");
				else
					if(KARaidTrackerDB.Options["TimeFormat"] == 1) then
						leave:SetText(date("%H:%M", val["leave"]));
					else
						leave:SetText(date("%I:%M%p", val["leave"]));
					end
				end
				if ( KARaidTrackerDB.RaidLog[raidid]["PlayerInfos"][val["name"]] and KARaidTrackerDB.RaidLog[raidid]["PlayerInfos"][val["name"]]["note"] ) then
					getglobal("KA_RaidTrackerPlayerLine" .. line .. "NoteButtonNormalTexture"):SetVertexColor(1, 1, 1);
				else
					getglobal("KA_RaidTrackerPlayerLine" .. line .. "NoteButtonNormalTexture"):SetVertexColor(0.5, 0.5, 0.5);
				end
				getglobal("KA_RaidTrackerPlayerLine" .. line .. "NoteButton"):Show();
				getglobal("KA_RaidTrackerPlayerLine" .. line .. "DeleteButton"):Show();
				getglobal("KA_RaidTrackerPlayerLine" .. line):Show();
			end
		else
			getglobal("KA_RaidTrackerPlayerLine" .. line):Hide();
		end
	end
	KA_RaidTrackerDetailScrollFramePlayers:Show();
end

function KA_RaidTracker_DetailScrollFrameItems_Update()
	local raidid = getglobal("KA_RaidTrackerDetailScrollFrameItems").raidid;
	local loot = getglobal("KA_RaidTrackerDetailScrollFrameItems").loot;
	local maxlines = getn(loot);
	local line;
	local lineplusoffset;
	FauxScrollFrame_Update(KA_RaidTrackerDetailScrollFrameItems, maxlines, 5, 41);
	for line=1, 5 do
		lineplusoffset = line+FauxScrollFrame_GetOffset(KA_RaidTrackerDetailScrollFrameItems);
		if (lineplusoffset <= maxlines) then
			local val = loot[lineplusoffset];
			if ( KA_RaidTrackerFrame.type == "items" ) then
				getglobal("KA_RaidTrackerItem" .. line).raidid = raidid;
				getglobal("KA_RaidTrackerItem" .. line).itemid = val["thisitemid"];
				getglobal("KA_RaidTrackerItem" .. line).itemname = val["item"]["name"];
				if ( val["item"]["count"] and val["item"]["count"] > 1 ) then
					getglobal("KA_RaidTrackerItem" .. line .. "Count"):Show();
					getglobal("KA_RaidTrackerItem" .. line .. "Count"):SetText(val["item"]["count"]);
				else
					getglobal("KA_RaidTrackerItem" .. line .. "Count"):Hide();
				end
				if ( val["item"]["icon"] ) then
					getglobal("KA_RaidTrackerItem" .. line .. "IconTexture"):SetTexture("Interface\\Icons\\" .. val["item"]["icon"]);
				else
					getglobal("KA_RaidTrackerItem" .. line .. "IconTexture"):SetTexture("Interface\\Icons\\INV_Misc_Gear_08");
				end
				local color = val["item"]["c"];
				if ( color == "ff1eff00" ) then
					color = "ff005D00";
				end
				getglobal("KA_RaidTrackerItem" .. line .. "Description"):SetText("|c" .. color .. val["item"]["name"]);
				getglobal("KA_RaidTrackerItem" .. line .. "Looted"):SetText("Looted by: " .. val["player"]);
	
				if ( val["note"] ) then
					getglobal("KA_RaidTrackerItem" .. line .. "NoteNormalTexture"):SetVertexColor(1, 1, 1);
				else
					getglobal("KA_RaidTrackerItem" .. line .. "NoteNormalTexture"):SetVertexColor(0.5, 0.5, 0.5);
				end
			elseif ( KA_RaidTrackerFrame.type == "playeritems" ) then
				getglobal("KA_RaidTrackerItem" .. line).raidid = val["ids"][1];
				getglobal("KA_RaidTrackerItem" .. line).itemid = val["ids"][2];
				getglobal("KA_RaidTrackerItem" .. line).itemname = val["item"]["name"];

				if ( val["item"]["count"] and val["item"]["count"] > 1 ) then
					getglobal("KA_RaidTrackerItem" .. line .. "Count"):Show();
					getglobal("KA_RaidTrackerItem" .. line .. "Count"):SetText(val["item"]["count"]);
				else
					getglobal("KA_RaidTrackerItem" .. line .. "Count"):Hide();
				end
				if ( val["item"]["icon"] ) then
					getglobal("KA_RaidTrackerItem" .. line .. "IconTexture"):SetTexture("Interface\\Icons\\" .. val["item"]["icon"]);
				else
					getglobal("KA_RaidTrackerItem" .. line .. "IconTexture"):SetTexture("Interface\\Icons\\INV_Misc_Gear_08");
				end
				local color = val["item"]["c"];
				if ( color == "ff1eff00" ) then
					color = "ff005D00";
				end
				getglobal("KA_RaidTrackerItem" .. line .. "Description"):SetText("|c" .. color .. val["item"]["name"]);
				getglobal("KA_RaidTrackerItem" .. line .. "Looted"):SetText("Looted " .. KA_RaidTracker_GetRaidTitle(val["ids"][1], 1));

				if ( val["note"] ) then
					getglobal("KA_RaidTrackerItem" .. line .. "NoteNormalTexture"):SetVertexColor(1, 1, 1);
				else
					getglobal("KA_RaidTrackerItem" .. line .. "NoteNormalTexture"):SetVertexColor(0.5, 0.5, 0.5);
				end	
			end
			getglobal("KA_RaidTrackerItem" .. line):Show();
		else
			getglobal("KA_RaidTrackerItem" .. line):Hide();
		end
	end
	KA_RaidTrackerDetailScrollFrameItems:Show();
end

function KA_RaidTracker_DetailScrollFramePlayer_Update()
	local data = getglobal("KA_RaidTrackerDetailScrollFramePlayer").data;
	local name = getglobal("KA_RaidTrackerDetailScrollFramePlayer").name;
	local maxlines = getglobal("KA_RaidTrackerDetailScrollFramePlayer").maxlines;
	local line;
	local lineplusoffset;
	FauxScrollFrame_Update(KA_RaidTrackerDetailScrollFramePlayer, maxlines, 11, 18);
	for line=1, 11 do
		lineplusoffset = line+FauxScrollFrame_GetOffset(KA_RaidTrackerDetailScrollFramePlayer);
		if (lineplusoffset <= maxlines) then
			val = data[lineplusoffset];
			if ( KA_RaidTrackerFrame.type == "player" ) then
				getglobal("KA_RaidTrackerPlayerRaid" .. line).raidid = val[1];
				getglobal("KA_RaidTrackerPlayerRaid" .. line).playername = name;
				getglobal("KA_RaidTrackerPlayerRaid" .. line).raidtitle = KA_RaidTracker_GetRaidTitle(val[1], 1);
	
				local iNumber = getn(KARaidTrackerDB.RaidLog)-val[1]+1;
				if ( iNumber < 10 ) then
					iNumber = "  " .. iNumber;
				end
	
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "MouseOverLeft"):Hide();
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "MouseOverRight"):Hide();
	
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "HitAreaLeft"):Hide();
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "HitAreaRight"):Hide();
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "HitArea"):Show();
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "Note"):Hide();
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "NoteButton"):Show();
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "DeleteButton"):Show();
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "DeleteText"):Show();
	
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "Number"):SetText(iNumber);
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "Name"):SetWidth(200);
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "Name"):SetText(KA_RaidTracker_GetRaidTitle(val[1], 1));

				if ( val[2]["PlayerInfos"][name] and val[2]["PlayerInfos"][name]["note"] ) then
					getglobal("KA_RaidTrackerPlayerRaid" .. line .. "NoteButtonNormalTexture"):SetVertexColor(1, 1, 1);
				else
					getglobal("KA_RaidTrackerPlayerRaid" .. line .. "NoteButtonNormalTexture"):SetVertexColor(0.5, 0.5, 0.5);
				end
			elseif ( KA_RaidTrackerFrame.type == "itemhistory" ) then
				getglobal("KA_RaidTrackerPlayerRaid" .. line).raidid = val[1];
	
				local iNumber = getn(KARaidTrackerDB.RaidLog)-val[1]+1;
				if ( iNumber < 10 ) then
					iNumber = "  " .. iNumber;
				end
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "MouseOver"):Hide();
	
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "HitAreaLeft"):Show();
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "HitAreaRight"):Show();
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "HitArea"):Hide();
	
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "NoteButton"):Hide();
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "Note"):Show();
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "DeleteButton"):Hide();
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "DeleteText"):Hide();
	
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "Number"):SetText(iNumber);
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "Name"):SetWidth(130);
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "Name"):SetText(KA_RaidTracker_GetRaidTitle(val[1], 1));
				getglobal("KA_RaidTrackerPlayerRaid" .. line .. "Note"):SetText(val[3]["player"]);
			end
			getglobal("KA_RaidTrackerPlayerRaid" .. line):Show();
		else
			getglobal("KA_RaidTrackerPlayerRaid" .. line):Hide();
		end
	end
	KA_RaidTrackerDetailScrollFramePlayer:Show();
end

function KA_RaidTracker_DetailScrollFrameBoss_Update()
	local events = getglobal("KA_RaidTrackerDetailScrollFrameEvents").events;
	local maxlines = getn(events);
	local line;
	local lineplusoffset;
	FauxScrollFrame_Update(KA_RaidTrackerDetailScrollFrameEvents, maxlines, 11, 18);
	for line=1, 11 do
		lineplusoffset = line+FauxScrollFrame_GetOffset(KA_RaidTrackerDetailScrollFrameEvents);
		if (lineplusoffset <= maxlines) then
			val = events[lineplusoffset];
			getglobal("KA_RaidTrackerBosses" .. line .. "MouseOver"):Hide();
			getglobal("KA_RaidTrackerBosses" .. line .. "HitArea"):Show();

			getglobal("KA_RaidTrackerBosses" .. line .. "Boss"):SetText(val["boss"]);
			getglobal("KA_RaidTrackerBosses" .. line .. "Time"):SetText(val["time"]);
			getglobal("KA_RaidTrackerBosses" .. line):Show();
		else
			getglobal("KA_RaidTrackerBosses" .. line):Hide();
		end
	end
	KA_RaidTrackerDetailScrollFrameEvents:Show();
end



function KA_RaidTrackerItem_SetHyperlink()
	local raidid = this.raidid;
	local lootid = this.itemid;
	if ( KARaidTrackerDB.RaidLog[raidid] and KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid] ) then
		local item = KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["item"];
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
		if (GetItemInfo("item:" .. item["id"])) then
			GameTooltip:SetHyperlink("item:" .. item["id"]);
		else
			rl, gl, bl = KARaidTrackerUtility:ColorToRGB(item["c"]);
			GameTooltip:AddLine(item["name"], rl, gl, bl);
			GameTooltip:AddLine("This item is not in your cache, you can try to get the information by rightclicking the item (This may result in a disconnect!)", 1, 1, 1);
		end
		
		GameTooltip:AddLine("Time: "..KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["time"], 1, 1, 0);
		if(KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["zone"]) then
			GameTooltip:AddLine("Zone: "..KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["zone"], 1, 1, 0);
		end
		if(KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["boss"]) then
			GameTooltip:AddLine("Boss: "..KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["boss"], 1, 1, 0);
		end
		if(KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["costs"]) then
			GameTooltip:AddLine("Costs: "..KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["costs"], 1, 1, 0);
		end
		if(KARaidTrackerDB.Options["DebugFlag"]) then
			if(KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["item"]["class"]) then
				GameTooltip:AddLine("Class: "..KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["item"]["class"], 1, 1, 0);
			end
			if(KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["item"]["subclass"]) then
				GameTooltip:AddLine("SubClass: "..KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["item"]["subclass"], 1, 1, 0);
			end
		end

		GameTooltip:Show();
		return;
	end
end

function KA_RaidTrackerItem_GetChatHyperlink()
	local raidid = this.raidid;
	local lootid = this.itemid;
	if ( IsShiftKeyDown() and ( type(WIM_API_InsertText) == "function" ) and KARaidTrackerDB.RaidLog[raidid] and KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid] ) then
		local item = KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["item"];
		WIM_API_InsertText( "|c" .. item.c .. "|Hitem:" .. item.id .. "|h[" .. item.name .. "]|h|r" );
	end	
	if ( IsShiftKeyDown() and ChatFrameEditBox:IsVisible() and KARaidTrackerDB.RaidLog[raidid] and KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid] ) then
		local item = KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["item"];
		ChatFrameEditBox:Insert("|c" .. item.c .. "|Hitem:" .. item.id .. "|h[" .. item.name .. "]|h|r");
	end
end

function KA_RaidTracker_GetItemTooltip(sItem)
	local tTooltip = { };
	KA_RTTooltip:SetOwner(this, "ANCHOR_NONE");
	KA_RTTooltip:ClearLines()
	KA_RTTooltip:SetHyperlink("item:" .. sItem);
	--KA_RTTooltip:Hide();
	KA_RTTooltip.id = sItem;
	for i = 1, KA_RTTooltip:NumLines(), 1 do
		local tl, tr;
		tl = getglobal("KA_RTTooltipTextLeft" .. i):GetText();
		tr = getglobal("KA_RTTooltipTextRight" .. i):GetText();
		tinsert(tTooltip, { ["left"] = tl, ["right"] = tr });
	end
	return tTooltip;
end

		

-- OnFoo functions

function KA_RaidTracker_OnLoad()
	KA_RaidTrackerTitleText:SetText("KA_RaidTracker " .. KA_RaidTracker_Version);
	-- Register events
	this:RegisterEvent("CHAT_MSG_LOOT");
	this:RegisterEvent("CHAT_MSG_SYSTEM");
	this:RegisterEvent("RAID_ROSTER_UPDATE");
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
	this:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH");
	this:RegisterEvent("CHAT_MSG_MONSTER_YELL");
	this:RegisterEvent("CHAT_MSG_MONSTER_EMOTE");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("UPDATE_INSTANCE_INFO");
	
	SlashCmdList["KA_RAIDTRACKER"] = KA_RaidTracker_CommandOptions;
 	SLASH_KA_RAIDTRACKER1 = "/karaidtracker";
 	SLASH_KA_RAIDTRACKER2 = "/kart";
end

function KA_RaidTracker_OnEvent(event)
	--KARaidTrackerUtility:Debug("event fired", event);
	local julianne_died = false;
	if ( KA_RaidTracker_UpdateFrame.time and KA_RaidTracker_UpdateFrame.time <= 2 ) then
		tinsert(KA_RaidTracker_Events, event);
		return;
	end
	
--	if KARaidTrackerDB.Options then
		if ( KARaidTrackerDB.Options["LogBattlefield"] == 0 and ((GetNumBattlefieldScores() > 0) or (IsActiveBattlefieldArena() == 1))) then
			if ( KARaidTrackerDB.Options["CurrentRaid"] ) then
				KA_RaidTracker_Delete( KARaidTrackerDB.Options["CurrentRaid"], "raid", 0 );
				KARaidTrackerUtility:Debug("Battlegroup detected, removing raid entry from list.");
				return;
			else
				KARaidTrackerUtility:Debug("Battlegroup detected, skipped event.");
				return;
			end;
		end;
--	end
	if ( event == "" and arg1 == KA_RaidTracker_lang_BossKills_Julianne_BossName) then
		
	end;
	if ( event == "CHAT_MSG_MONSTER_YELL" or event == "CHAT_MSG_MONSTER_EMOTE" ) then -- Sorry, Majordomo needs a little hack
		if(arg1 == KA_RaidTracker_lang_BossKills_Majordomo_Yell) then
			KARaidTrackerUtility:Debug("It's domo!");
			event = "CHAT_MSG_COMBAT_HOSTILE_DEATH";
			arg1 = string.gsub(KA_RaidTracker_ConvertGlobalString(UNITDIESOTHER), "%(%.%+%)", KA_RaidTracker_lang_BossKills_Majordomo_BossName);
		elseif(arg2 == "Karazhan - Chess, Victory Controller") then
			KA_RaidTracker_Print("Plz contact Eris at www.mldkp.net that Chess event logging is working (incl language)");
			event = "CHAT_MSG_COMBAT_HOSTILE_DEATH";
			arg1 = string.gsub(KA_RaidTracker_ConvertGlobalString(UNITDIESOTHER), "%(%.%+%)", KA_RaidTracker_lang_BossKills_Chess_Event_BossName);
		elseif(arg1 == KA_RaidTracker_lang_BossKills_Chess_Event_Yell) then
			KARaidTrackerUtility:Debug("Chess event");
			event = "CHAT_MSG_COMBAT_HOSTILE_DEATH";
			arg1 = string.gsub(KA_RaidTracker_ConvertGlobalString(UNITDIESOTHER), "%(%.%+%)", KA_RaidTracker_lang_BossKills_Chess_Event_BossName);
		elseif(arg1 == KA_RaidTracker_lang_BossKills_Julianne_Die_Yell) then
			KARaidTrackerUtility:Debug("Romulo und Julianne");
			event = "CHAT_MSG_COMBAT_HOSTILE_DEATH";
			arg1 = string.gsub(KA_RaidTracker_ConvertGlobalString(UNITDIESOTHER), "%(%.%+%)", KA_RaidTracker_lang_BossKills_Julianne_BossName);
			julianne_died = true;
		end
	end
	if ( event == "RAID_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD") then 
		if ( GetNumRaidMembers() == 0 and event == "RAID_ROSTER_UPDATE" and KARaidTrackerDB.Options["CurrentRaid"]) then
			local raidendtime = KA_RaidTracker_Date();
			for k, v in pairs(KARaidTrackerDB.Online) do
				KARaidTrackerUtility:Debug("ADDING LEAVE", k, raidendtime);
				tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Leave"],
					{
						["player"] = k,
						["time"] = raidendtime,
					}
				);
			end
			if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["End"]) then
				KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["End"] = raidendtime;
			end
			KARaidTrackerDB.Options["CurrentRaid"] = nil;
			KARaidTrackerUtility:Debug("Left raid.","GetNumRaidMembers() == 0");
			KA_RaidTracker_Offline = { };
			KA_RaidTracker_UpdateView();
			KA_RaidTracker_Update();
		elseif ( not KARaidTrackerDB.Options["CurrentRaid"] and GetNumRaidMembers() > 0 and event == "RAID_ROSTER_UPDATE" and KARaidTrackerDB.Options["AutoRaidCreation"] == 1) then
			KA_RaidTrackerCreateNewRaid();
		end
		if ( not KARaidTrackerDB.Options["CurrentRaid"] ) then
			return;
		end
		local updated;
		for i = 1, GetNumRaidMembers(), 1 do
			local name, online = UnitName("raid" .. i), UnitIsConnected("raid" .. i);
			if ( name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
				local _, race = UnitRace("raid" .. i);
				local _, class = UnitClass("raid" .. i);
				local sex = UnitSex("raid" .. i);
				local level = UnitLevel("raid" .. i);
				local guild = GetGuildInfo("raid" .. i);
				
				if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"]) then
					KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"] = { };
				end
				if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]) then
					KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name] = { };
				end
				if(KARaidTrackerDB.Options["SaveExtendedPlayerInfo"] == 1) then
				    if(race) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["race"] = race; end
				    if(class) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["class"] = class; end
						if(sex) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["sex"] = sex; end
				    if(level > 0) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["level"] = level; end
				    if(guild) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["guild"] = guild; end
				end
				if ( online ~= KARaidTrackerDB.Online[name] ) then
					-- Status isn't updated
					KARaidTrackerUtility:Debug("Status isn't updated", name, online);
					if ( not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]] and KARaidTrackerDB.Options["AutoRaidCreation"] == 1) then
						KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]] = { 
							["Loot"] = { },
							["Join"] = { },
							["Leave"] = { },
							["PlayerInfos"] = { },
							["BossKills"] = { },
						};
					end
					if( KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]] ) then
						if ( not online ) then
							if ( online ~= KARaidTrackerDB.Online[name] ) then
								tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Leave"],
									{
										["player"] = name,
										["time"] = KA_RaidTracker_Date()
									}
								);
								KARaidTrackerUtility:Debug("OFFLINE", name, KA_RaidTracker_Date());
							end
						else
							tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Join"],
								{
									["player"] = name,
									--["race"] = race,
									--["class"] = class,
									--["level"] = level,
									["time"] = KA_RaidTracker_Date()
								}
								);
							KARaidTrackerUtility:Debug("ONLINE", name, KA_RaidTracker_Date());
						end
						updated = 1;
					end
				end
				KARaidTrackerDB.Online[name] = online;
			end
		end
		if ( updated ) then
			KA_RaidTracker_Update();
			KA_RaidTracker_UpdateView();
		end

	-- Party code added thx to Gof
	elseif ( GetNumRaidMembers() == 0 and (event == "PARTY_MEMBERS_CHANGED" or event == "PLAYER_ENTERING_WORLD")) then 
		if ( GetNumPartyMembers() == 0 and event == "PARTY_MEMBERS_CHANGED" and KARaidTrackerDB.Options["CurrentRaid"]) then
			local raidendtime = KA_RaidTracker_Date();
			for k, v in pairs(KARaidTrackerDB.Online) do
		 	KARaidTrackerUtility:Debug("ADDING LEAVE", k, raidendtime);
				tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Leave"],
					{
						["player"] = k,
						["time"] = raidendtime,
					}
				);
			end
			if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["End"]) then
				KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["End"] = raidendtime;
			end
			KARaidTrackerDB.Options["CurrentRaid"] = nil;
			KARaidTrackerUtility:Debug("Left raid.","GetNumPartyMembers() == 0");
			KA_RaidTracker_Offline = { };
			KA_RaidTracker_UpdateView();
			KA_RaidTracker_Update();
		elseif ( not KARaidTrackerDB.Options["CurrentRaid"] and GetNumPartyMembers() > 0 and event == "PARTY_MEMBERS_CHANGED" and KARaidTrackerDB.Options["AutoGroup"] == 1) then
			KA_RaidTrackerCreateNewRaid();
		end
		if ( not KARaidTrackerDB.Options["CurrentRaid"] ) then
			return;
		end
		local updated;
		for i = 1, GetNumPartyMembers(), 1 do
			local name, online = UnitName("party" .. i), UnitIsConnected("party" .. i);
			if ( name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
				local _, race = UnitRace("party" .. i);
				local _, class = UnitClass("party" .. i);
				local level = UnitLevel("party" .. i);
				local guild = GetGuildInfo("party" .. i);
				
				if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"]) then
					KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"] = { };
				end
				if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]) then
					KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name] = { };
				end
				if(KARaidTrackerDB.Options["SaveExtendedPlayerInfo"] == 1) then
				    if(race) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["race"] = race; end
				    if(class) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["class"] = class; end
				    if(level > 0) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["level"] = level; end
				    if(guild) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["guild"] = guild; end
				end
				if ( online ~= KARaidTrackerDB.Online[name] ) then
					-- Status isn't updated
					KARaidTrackerUtility:Debug("Status isn't updated", name, online);
					if ( not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]] and KARaidTrackerDB.Options["AutoRaidCreation"] == 1) then
						KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]] = { 
							["Loot"] = { },
							["Join"] = { },
							["Leave"] = { },
							["PlayerInfos"] = { },
							["BossKills"] = { },
						};
					end
					if( KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]] ) then
						if ( not online ) then
							if ( online ~= KARaidTrackerDB.Online[name] ) then
								tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Leave"],
									{
										["player"] = name,
										["time"] = KA_RaidTracker_Date()
									}
								);
								KARaidTrackerUtility:Debug("OFFLINE", name, KA_RaidTracker_Date());
							end
						else
							tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Join"],
								{
									["player"] = name,
									--["race"] = race,
									--["class"] = class,
									--["level"] = level,
									["time"] = KA_RaidTracker_Date()
								}
								);
							KARaidTrackerUtility:Debug("ONLINE", name, KA_RaidTracker_Date());
						end
						updated = 1;
					end
				end
				KARaidTrackerDB.Online[name] = online;
			end
		end
		
		--Party dosent include player himself, so add him
		
		local name, online = UnitName("player"), UnitIsConnected("player");
		if ( name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
			local _, race = UnitRace("player");
			local _, class = UnitClass("player");
			local level = UnitLevel("player");
			local guild = GetGuildInfo("player");
			
			if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"]) then
				KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"] = { };
			end
			if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]) then
				KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name] = { };
			end
			if(KARaidTrackerDB.Options["SaveExtendedPlayerInfo"] == 1) then
				if(race) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["race"] = race; end
				if(class) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["class"] = class; end
				if(level > 0) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["level"] = level; end
				if(guild) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["guild"] = guild; end
			end
			if ( online ~= KARaidTrackerDB.Online[name] ) then
				-- Status isn't updated
				KARaidTrackerUtility:Debug("Status isn't updated", name, online);
				if ( not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]] and KARaidTrackerDB.Options["AutoRaidCreation"] == 1) then
					KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]] = { 
						["Loot"] = { },
						["Join"] = { },
						["Leave"] = { },
						["PlayerInfos"] = { },
						["BossKills"] = { },
					};
				end
				if( KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]] ) then
					if ( not online ) then
						if ( online ~= KARaidTrackerDB.Online[name] ) then
							tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Leave"],
								{
									["player"] = name,
									["time"] = KA_RaidTracker_Date()
								}
							);
							KARaidTrackerUtility:Debug("OFFLINE", name, KA_RaidTracker_Date());
						end
					else
						tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Join"],
							{
								["player"] = name,
								--["race"] = race,
								--["class"] = class,
								--["level"] = level,
								["time"] = KA_RaidTracker_Date()
							}
							);
						KARaidTrackerUtility:Debug("ONLINE", name, KA_RaidTracker_Date());
					end
					updated = 1;
				end
			end
			KARaidTrackerDB.Online[name] = online;
		end
		if ( updated ) then
			KA_RaidTracker_Update();
			KA_RaidTracker_UpdateView();
		end
	-- Party code end
	elseif ( event == "CHAT_MSG_LOOT" and KARaidTrackerDB.Options["CurrentRaid"] ) then
		if(not testo) then
			testo = {};
		end
		tinsert(testo, arg1);
		local sPlayer, sLink, sPlayerName, sItem, iCount;
		KARaidTrackerUtility:Debug("arg1", arg1);
		if(string.find(arg1, KA_RaidTracker_lang_ReceivesLoot1)) then
			iStart, iEnd, sPlayerName, sItem = string.find(arg1, KA_RaidTracker_lang_ReceivesLoot1);
			iCount = 1;
			KARaidTrackerUtility:Debug("itemdropped1", "format", 1, sPlayerName, sItem, iCount);
		elseif(string.find(arg1, KA_RaidTracker_lang_ReceivesLoot2)) then
			iStart, iEnd, sItem = string.find(arg1, KA_RaidTracker_lang_ReceivesLoot2);
			iCount = 1;
			sPlayerName = YOU;
			KARaidTrackerUtility:Debug("itemdropped2", "format", 2, sPlayerName, sItem, iCount);
		elseif(string.find(arg1, KA_RaidTracker_lang_ReceivesLoot3)) then
			iStart, iEnd, sPlayerName, sItem, iCount = string.find(arg1, KA_RaidTracker_lang_ReceivesLoot3);
			KARaidTrackerUtility:Debug("itemdropped3", "format", 3, sPlayerName, sItem, iCount);
		elseif(string.find(arg1, KA_RaidTracker_lang_ReceivesLoot4)) then
			iStart, iEnd, sItem, iCount = string.find(arg1, KA_RaidTracker_lang_ReceivesLoot4);
			sPlayerName = YOU;
			KARaidTrackerUtility:Debug("itemdropped4", "format", 4, sPlayerName, sItem, iCount);
		end
		
		KARaidTrackerUtility:Debug("itemdropped", "link", sItem);
		if ( sPlayerName ) then
			if(sPlayerName == YOU) then
				KARaidTrackerUtility:Debug("itemdropped", "It's me");
				sPlayer = UnitName("player");
			else
				KARaidTrackerUtility:Debug("itemdropped", "It's sombody else");
				sPlayer = sPlayerName;
			end
			sLink = sItem;
		end
		iCount = tonumber(iCount);
		if(not iCount) then
			iCount = 1;
		end
		KARaidTrackerUtility:Debug("itedroped", sPlayer, sLink, iCount);
		-- Make sure there is a link
		if ( sLink and sPlayer ) then
			local sColor, sItem, sName = KA_RaidTracker_GetItemInfo(sLink);
			local itemoptions;
			for key, val in pairs(KARaidTrackerDB.ItemOptions) do
				if(string.find(sItem, "^"..val["id"]..":%d+:%d+:%d+")) then
					itemoptions = val;
					KARaidTrackerUtility:Debug("ItemOptions", "FoundItem", key);
				end
			end
			local iotrack, iogroup, iocostsgrabbing, ioaskcosts
			if ( (itemoptions and itemoptions["status"] and itemoptions["status"] == 1) or ((sColor and sItem and sName and KA_RaidTracker_RarityTable[sColor] >= KARaidTrackerDB.Options["MinQuality"]) and (not itemoptions or not itemoptions["status"]))) then
				-- Insert into table
				if ( not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]] and KARaidTrackerDB.Options["AutoRaidCreation"] == 1) then
					KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]] = { 
						["Loot"] = { },
						["Join"] = { },
						["Leave"] = { },
						["PlayerInfos"] = { },
						["BossKills"] = { },
					};
				end
				local found = nil;
				if( KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]] ) then
					if( (itemoptions and itemoptions["group"] and itemoptions["group"] == 1) or ((KARaidTrackerDB.Options["GroupItems"] ~= 0 and KA_RaidTracker_RarityTable[sColor] <= KARaidTrackerDB.Options["GroupItems"]) and (not itemoptions or not itemoptions["group"])) ) then
						KARaidTrackerUtility:Debug("Trying to group", sName, sPlayer);
						for k, v in pairs(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Loot"]) do
							if ( v["item"]["name"] == sName and v["player"] == sPlayer ) then
								if ( v["item"]["count"] ) then
									KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Loot"][k]["item"]["count"] = v["item"]["count"]+iCount;
								else
									KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Loot"][k]["item"]["count"] = iCount;
								end
								found = 1;
								KARaidTrackerUtility:Debug("Grouped", sName, sPlayer, KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Loot"][k]["item"]["count"]);
								break;
							end
						end
					end
					if ( not found ) then
						local nameGIF, linkGIF, qualityGIF, iLevelGIF, minLevelGIF, classGIF, subclassGIF, maxStackGIF, invtypeGIV, iconGIF = GetItemInfo("item:"..sItem);
						_, _, iconGIF = string.find(iconGIF, "^.*\\(.*)$");
						local splitted = { [0] = 0, [1] = 0, [2] = 0, [3] = 0 };
						local trimed;
						local i = 0;
						local sNote, sCosts, sBoss;
						
						for item in string.gmatch(string.gsub(sItem, "^%s*(.-)%s*$", "%1") .. ":", "([^:]*):?") do
							trimed = string.gsub(item, "^%s*(.-)%s*$", "%1");
							if(string.len(trimed) >= 1) then
								splitted[i] = trimed;
								i = i + 1;
							end
						end
						if( (itemoptions and itemoptions["costsgrabbing"] and itemoptions["costsgrabbing"] == 1) or ((KARaidTrackerDB.Options["DkpValue"] ~= 0 and KA_RaidTracker_RarityTable[sColor] >= KARaidTrackerDB.Options["DkpValue"]) and (not itemoptions or not itemoptions["costsgrabbing"]))) then
							if(DKPValues and DKPValues[tostring(splitted[0])]) then -- AdvancedItemTooltip
								sCosts = tonumber(DKPValues[tostring(splitted[0])]);
							elseif(HDKP_GetDKP) then -- HoB_DKP
								sCosts = tonumber(HDKP_GetDKP(splitted[0], splitted[1], splitted[2], splitted[3]));
							end
							KARaidTrackerUtility:Debug("Splitted", splitted[0], splitted[1], splitted[2], splitted[3]);
							if(sCosts == 0) then
								sCosts = nil;
							end
						end
						
						if(KARaidTrackerDB.Options["AutoBoss"] >= 1) then
							sBoss = KARaidTrackerDB.Options["AutoBossBoss"];
						end
						
						local tAttendees = { };
						if(KARaidTrackerDB.Options["LogAttendees"] == 2) then
						    if( GetNumRaidMembers() > 0 ) then
								for i = 1, GetNumRaidMembers() do
								    local name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i);
								    local name = UnitName("raid" .. i);
								    if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
									    tinsert(tAttendees, name);
								    end
							    end
							elseif( (GetNumPartyMembers() > 0) and (KARaidTrackerDB.Options["LogGroup"] == 1) ) then
								for i = 1, GetNumPartyMembers() do
								    local online = UnitIsConnected("party" .. i);
								    local name = UnitName("party" .. i);
								    if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
									    tinsert(tAttendees, name);
								    end
							    end
								--Party dosent include player, so add individual
								local online = UnitIsConnected("player");
								local name = UnitName("player");
								if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
									tinsert(tAttendees, name);
								end
							end
						end
						
						local tTooltip = { };
						if(KARaidTrackerDB.Options["SaveTooltips"] == 1) then
							tTooltip = KA_RaidTracker_GetItemTooltip(sItem);
						end
						
						local sTime = KA_RaidTracker_Date();
						local foundValue = "|c" .. sColor .. "|Hitem:" .. sItem .. "|h[" .. sName .. "]|h|r";
						--sNote = "0 DKP";
						--GDKP_Output("foundValue = " .. foundValue,"lokal");
						--if (bidWinnerHistory ~= nil) then
						--	local foundValue;
						--	for i=1,table.getn(bidWinnerHistory) do
						--		foundValue = "|c" .. sColor .. "|Hitem:" .. sItem .. "|h[" .. sName .. "]|h|r";
						--		--GDKP_Output(foundValue,"lokal");
						--		if (bidWinnerHistory[i][3] == foundValue) then
						--			if (bidWinnerHistory[i][1] == sPlayer) then
						--				sNote = bidWinnerHistory[i][2] .. " DKP";
						--				--table.remove(bidWinnerHistory, i);
						--				break;
						--			end
						--		end
						--	end
						--end
						
						tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Loot"], 1,
							{
								["player"] = sPlayer,
								["item"] = {						
									["c"] = sColor,
									["id"] = sItem,
									["tooltip"] = tTooltip,
									["name"] = sName,
									["icon"] = iconGIF,
									["count"] = iCount,
									["class"] = classGIF,
									["subclass"] = subclassGIF,
									["subclass"] = subclassGIF,
								},
								["zone"] = GetRealZoneText(),
								["costs"] = sCosts,
								["boss"] = sBoss,
								["time"] = sTime,
								["note"] = sNote,
								["attendees"] = tAttendees,
							}
						);
						
						if ( (itemoptions and itemoptions["askcosts"] and itemoptions["askcosts"] == 1) or ((KARaidTrackerDB.Options["AskCost"] ~= 0 and KA_RaidTracker_RarityTable[sColor] >= KARaidTrackerDB.Options["AskCost"]) and (not itemoptions or not itemoptions["askcosts"])) ) then -- code and idea from tlund
							KA_RaidTracker_EditCosts(KARaidTrackerDB.Options["CurrentRaid"], 1);
						end
					end
				end
				
				KARaidTrackerUtility:Debug(sPlayer, sColor, sItem, sName);
				KA_RaidTracker_Update();
				KA_RaidTracker_UpdateView();
			end
		end
	
	elseif ( event == "CHAT_MSG_SYSTEM" and UnitName("player") and UnitName("player") ~= UKNOWNBEING and UnitName("player") ~= UNKNOWN and KARaidTrackerDB.Options["CurrentRaid"] ) then
		local sDate = KA_RaidTracker_Date();
		local iStart, iEnd, sPlayer = string.find(arg1, KA_RaidTracker_lang_LeftGroup);
		if ( sPlayer and sPlayer ~= UnitName("player") and sPlayer ~= UKNOWNBEING and sPlayer ~= UNKNOWN and KARaidTrackerDB.Online[sPlayer]) then
			tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Leave"],
				{
					["player"] = sPlayer,
					["time"] = sDate
				}
			);
			KARaidTrackerDB.Online[sPlayer] = nil;
			KARaidTrackerUtility:Debug(sPlayer, "LEFT", sDate);
		end
		
--		local race, lass, level;
--		local iStart, iEnd, sPlayer = string.find(arg1, KA_RaidTracker_lang_JoinedGroup);
--
--      if ( sPlayer and sPlayer ~= UnitName("player") and sPlayer ~= UKNOWNBEING and sPlayer ~= UNKNOWN) then
--			tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"] ]["Join"],
--				{
--					["player"] = sPlayer,
--					["time"] = sDate
--				}
--			);
--			KARaidTrackerUtility:Debug(sPlayer, "JOIN", sDate);
--		end

		KA_RaidTracker_UpdateView();
		KA_RaidTracker_Update();
	
	elseif ( event == "VARIABLES_LOADED" ) then
		KA_RaidTrackerFrame:CreateTitleRegion()
		KA_RaidTrackerFrame:GetTitleRegion():SetAllPoints()
		KARaidTrackerData:OnVariablesLoaded();
		KA_RaidTracker_GetGameTimeOffset();
	elseif ( event == "UPDATE_MOUSEOVER_UNIT" ) then	
		if(KARaidTrackerDB.Options["AutoBoss"] == 1) then
			local autoboss_unitname = UnitName("mouseover");
			local autoboss_newboss;
			if(not UnitIsFriend("mouseover", "player") and not UnitInRaid("mouseover") and not UnitInParty("mouseover")) then
				--KARaidTrackerUtility:Debug("possible mouseover unit update", autoboss_unitname);
				if(KA_RaidTracker_BossUnitTriggers[autoboss_unitname]) then
					if(KA_RaidTracker_BossUnitTriggers[autoboss_unitname] ~= "IGNORE") then
						autoboss_newboss = KA_RaidTracker_BossUnitTriggers[autoboss_unitname];
						KA_RaidTracker_AutoBossChangedTime = GetTime();
					end
				elseif(KA_RaidTracker_BossUnitTriggers["DEFAULTBOSS"] and (KARaidTrackerDB.Options["AutoBossChangeMinTime"] == 0 or (GetTime() > (KA_RaidTracker_AutoBossChangedTime + KARaidTrackerDB.Options["AutoBossChangeMinTime"])))) then
					autoboss_newboss = KA_RaidTracker_BossUnitTriggers["DEFAULTBOSS"];
				else
					autoboss_newboss = nil
				end
				if(autoboss_newboss and KARaidTrackerDB.Options["AutoBossBoss"] ~= autoboss_newboss) then
					KARaidTrackerDB.Options["AutoBossBoss"] = autoboss_newboss;
					KA_RaidTracker_Print("KA_RaidTracker AutoBoss Update: "..autoboss_newboss, 1, 1, 0);
				end
			end
		end
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		if(KARaidTrackerDB.Options["AutoZone"] == 1) then
			KA_RaidTracker_DoZoneCheck();
			KA_RaidTracker_DoRaidIdCheck();
		end
	elseif ( event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" ) then
		local bosskilled, autoboss_newboss;
		local sDate = KA_RaidTracker_Date();
		KARaidTrackerUtility:Debug("CHAT_MSG_COMBAT_HOSTILE_DEATH",arg1);
		for unit in string.gmatch(arg1, KA_RaidTracker_ConvertGlobalString(UNITDIESOTHER)) do
			KARaidTrackerUtility:Debug("CHAT_MSG_COMBAT_HOSTILE_DEATH","unit", unit);
			if(KARaidTrackerDB.Options["AutoBoss"] == 2 and KARaidTrackerDB.Options["CurrentRaid"]) then
				if(not KARaidTrackerDB.Online[unit]) then
					if(KA_RaidTracker_BossUnitTriggers[unit]) then
						if(KA_RaidTracker_BossUnitTriggers[unit] ~= "IGNORE") then
							autoboss_newboss = KA_RaidTracker_BossUnitTriggers[unit];
						end
					elseif(KA_RaidTracker_BossUnitTriggers["DEFAULTBOSS"]) then
						autoboss_newboss = KA_RaidTracker_BossUnitTriggers["DEFAULTBOSS"];
					else
						autoboss_newboss = nil
					end
					if(autoboss_newboss and KARaidTrackerDB.Options["AutoBossBoss"] ~= autoboss_newboss) then
						KARaidTrackerDB.Options["AutoBossBoss"] = autoboss_newboss;
						if (unit == "Hase") then
							unit = "V\195\182lli hat den alten Hoppel Hasen erledigt!"; --Just a Joke
						end
						KA_RaidTracker_Print("KA_RaidTracker AutoBoss Update: "..autoboss_newboss.." ("..unit..")", 1, 1, 0);
					end
				end
			end
			
			if(KARaidTrackerDB.Options["CurrentRaid"] and KA_RaidTracker_BossUnitTriggers[unit] and KA_RaidTracker_BossUnitTriggers[unit] ~= "IGNORE") then	
				local newboss = 1;
				-- Romulo and Julianne Hack
				if (KA_RaidTracker_BossUnitTriggers[unit] == "Romulo and Julianne") then
					if (julianne_died == false) then
						return;
					end;
				end
				-- Romulo and Julianne Hack
				bosskilled = KA_RaidTracker_BossUnitTriggers[unit];
				if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["BossKills"]) then
					KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["BossKills"] = { };
				end
				-- is the boss already killed?
				for key, val in pairs(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["BossKills"]) do
				    if(val["boss"] == bosskilled) then
				        newboss = 0;
				    end
				end
				if (newboss == 1) then
				    local tAttendees = { };
					if( (KARaidTrackerDB.Options["LogAttendees"] == 1) or (KARaidTrackerDB.Options["LogAttendees"] == 3)) then
						if( GetNumRaidMembers() > 0 ) then
							for i = 1, GetNumRaidMembers() do
								local name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i);
								local name = UnitName("raid" .. i);
								if (name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
									if (KARaidTrackerDB.Options["LogAttendees"] == 3)then
										if (zone==GetRealZoneText()) then 
											tinsert(tAttendees, name);
										end;
									else
										tinsert(tAttendees, name);
									end;
								end
							end
						elseif( (GetNumPartyMembers() > 0) and (KARaidTrackerDB.Options["LogGroup"] == 1) ) then
							for i = 1, GetNumPartyMembers() do
								local name = UnitName("party" .. i);
								if (name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
									tinsert(tAttendees, name);
								end
							end
							--Party dosent include player, so add individual
							local name = UnitName("player");
							if (name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
								tinsert(tAttendees, name);
							end
						end
					end
				    tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["BossKills"],
        				{
        					["boss"] = bosskilled,
        					["time"] = sDate,
        					["attendees"] = tAttendees
        				}
			            );
			      KA_RaidTracker_Print("KA_RaidTracker Boss Kills: Set kill time for \""..bosskilled.."\" to "..sDate, 1, 1, 0);
			      if (KARaidTrackerDB.Options["NextBoss"] == 1) then
			      	KA_RaidTrackerNextBossFrame:Show();
			      end;
					if( KARaidTrackerDB.Options["GuildSnapshot"] == 1) then
						KA_RaidTrackerAddGuild();			      
			    end;
			      
				end
				
				--if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["BossKills"][bosskilled]) then
				--	KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["BossKills"][bosskilled] = sDate;
				--	KA_RaidTracker_Print("KA_RaidTracker Boss Kills: Set kill time for \""..bosskilled.."\" to "..sDate, 1, 1, 0);
				--end
			end
		end
	elseif ( event == "UNIT_HEALTH" ) then
		-- check for wipe count
		if (KARaidTrackerDB.Options["Wipe"] == 0) then
			return -- wipecounting is disabled 
		end;
		if (InCombatLockdown()) then
			return -- we are in combat and don't want to ask if this is a wipe if one of this members died and he tried to heal him ;-)
		end;
		if (not KARaidTrackerDB.Options["CurrentRaid"]) then
			return -- no raid tracking
		end;
		if (GetTime() < KA_RaidTracker_LastWipe) then
			return -- wipe cooldown
		end;
		local membercount = 0;
		local unitprefix = 0;
		local memberdead = 0;
		if ( GetNumRaidMembers() > 0) then -- in raid and active
			membercount = GetNumRaidMembers();
			unitprefix = "raid";
		elseif ( GetNumPartyMembers() > 0) then -- in group and active
			membercount = GetNumPartyMembers()+1;
			unitprefix = "party";
			if (UnitIsDeadOrGhost("player")) then
				memberdead = memberdead + 1;
			end;
		else
			return -- not in group
		end;
		for i = 1, membercount, 1 do
			if (UnitIsDeadOrGhost(unitprefix..i)) then
				memberdead = memberdead + 1;
			end;
		end;
		if (memberdead == membercount) then
			KA_RaidTracker_AddWipe();
			KA_RaidTrackerAcceptWipeFrame:Hide();
			return;
		end;
		if ((memberdead / membercount) > KARaidTrackerDB.Options["WipePercent"]) then
			KA_RaidTrackerAcceptWipeFrame:Show();

		end;
	elseif ( event == "UPDATE_INSTANCE_INFO" ) then
		KARaidTrackerUtility:Debug("UPDATE_INSTANCE_INFO");
		KA_RaidTracker_DoRaidIdCheck();
	end
end

function KA_RaidTracker_AddWipe()
	KARaidTrackerUtility:Debug("WIPED");
	KA_RaidTracker_LastWipe = GetTime()+KARaidTrackerDB.Options["WipeCoolDown"]; -- wait for 120 seconds
	if (KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["wipes"] == nil) then
		KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["wipes"] = {};
	end;
	tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["wipes"],time());
	KA_RaidTracker_Print("Wipe has been recorded!", 1, 1, 0);
end;

function KA_RaidTackes_NextBoss(name)
	KARaidTrackerUtility:Debug("NEXTBOSS",name);
	KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["nextboss"] = name;
end;

function KA_RaidTracker_DoZoneCheck()
	if(not KARaidTrackerDB.Options["CurrentRaid"]) then
		return;
	end
	local newzone = GetRealZoneText();
	if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["zone"]) then
		for k, v in pairs(KA_RaidTracker_ZoneTriggers) do
			if(newzone == k) then
				KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["zone"] = v;
				KA_RaidTracker_Update();
				KA_RaidTracker_UpdateView();
				break;
			end
		end
	end
	if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["zone"]) then
		for k, v in pairs(KARaidTrackerDB.CustomZoneTriggers) do
			if(newzone == k) then
				KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["zone"] = v;
				KA_RaidTracker_Update();
				KA_RaidTracker_UpdateView();
				break;
			end
		end
	end
	return true;
end

function KA_RaidTracker_DoRaidIdCheck()
	if(not KARaidTrackerDB.Options["CurrentRaid"]) then
		return;
	end
	local savedInstances = GetNumSavedInstances();
	local instanceName, instanceID, instanceReset;
	if ( savedInstances > 0 ) then
		for i=1, MAX_RAID_INFOS do
			if ( i <=  savedInstances) then
				instanceName, instanceID, instanceReset = GetSavedInstanceInfo(i);
				if (KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["zone"] == instanceName) then
					KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["instanceid"] = instanceID;
					--KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["instancereset"] = instanceReset;
				end;
			end
			
		end
	end
end;


-- Item functions
function KA_RaidTracker_GetItemInfo(sItem)
	local sStart, sEnde, sColor, sItemName, sName = string.find(sItem, "|c(%x+)|Hitem:([-%d:]+)|h%[(.-)%]|h|r");
	KARaidTrackerUtility:Debug("sColor:", sColor,"sItemName:", sItemName,"sName:", sName);
	return sColor, sItemName, sName, sStart, sEnde;
end

function KA_RaidTracker_CommandOptions(msg)
	local _, _, command, args = string.find(msg, "(%w+)%s?(.*)");
	if(command) then
		command = strlower(command);
	end
	
	if(command == "debug") then
		if(args == "1") then
			KARaidTrackerDB.Options["DebugFlag"] = 1;
			KA_RaidTracker_Print("Enabled Debug Output", 1, 1, 0);
		elseif(args == "0") then
			KARaidTrackerDB.Options["DebugFlag"] = nil;
			KA_RaidTracker_Print("Disabled Debug Output", 1, 1, 0);
		else
			if(KARaidTrackerDB.Options["DebugFlag"] == 1) then
				KA_RaidTracker_Print("Debug Output: Enabled", 1, 1, 0);
			else
				KA_RaidTracker_Print("Debug Output: Disabled", 1, 1, 0);
			end
		end
	elseif(command == "addwipe") then
		KA_RaidTracker_AddWipe();
	elseif(command == "deleteall") then
		KA_RaidTracker_Print("Deleted "..getn(KARaidTrackerDB.RaidLog).." Raids", 1, 1, 0);
		KARaidTrackerDB.RaidLog = { };
		KARaidTrackerDB.Options["CurrentRaid"] = nil;
		KA_RaidTracker_UpdateView();
		KA_RaidTracker_Update();
	elseif(command == "additem") then
		if(args and args ~= "") then
			local sColor, sItem, sName, sStart, sEnde = KA_RaidTracker_GetItemInfo(args);
			if(sItem and sItem) then
				if (string.len(args) > sEnde+2) then
					sLooter = string.sub(args,sEnde+2);
					KARaidTrackerUtility:Debug("Looter",sLooter);
				else
					KARaidTrackerUtility:Debug("Kein Looter",sLooter);
					sLooter = "";
				end;
				if(KA_RaidTrackerFrame.selected) then
					local nameGIF, linkGIF, qualityGIF, iLevelGIF, minLevelGIF, classGIF, subclassGIF, maxStackGIF, invtypeGIV, iconGIF = GetItemInfo("item:"..sItem);
					if(iconGIF) then 
						_, _, iconGIF = string.find(iconGIF, "^.*\\(.*)$");
					end
					
					local tAttendees = { };
					if(KARaidTrackerDB.Options["LogAttendees"] == 2) then
						if( GetNumRaidMembers() > 0 ) then
							for i = 1, GetNumRaidMembers() do
								local name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i);
								local name = UnitName("raid" .. i);
								if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
									tinsert(tAttendees, name);
								end
							end
						elseif( (GetNumPartyMembers() > 0) and (KARaidTrackerDB.Options["LogGroup"] == 1) ) then
							for i = 1, GetNumPartyMembers() do
								local online = UnitIsConnected("party" .. i);
								local name = UnitName("party" .. i);
								if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
									tinsert(tAttendees, name);
								end
							end
							--Party dosent include player, so add individual
							local online = UnitIsConnected("player");
							local name = UnitName("player");
							if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
								tinsert(tAttendees, name);
							end
						end
					end
					
					local tTooltip = { };
					if(KARaidTrackerDB.Options["SaveTooltips"] == 1) then
						tTooltip = KA_RaidTracker_GetItemTooltip(sItem);
					end
					
					local sTime = KA_RaidTracker_Date();
					tinsert(KARaidTrackerDB.RaidLog[KA_RaidTrackerFrame.selected]["Loot"], 1,
						{
							["player"] = sLooter,
							["item"] = {						
								["c"] = sColor,
								["id"] = sItem,
								["tooltip"] = tTooltip,
								["name"] = sName,
								["icon"] = iconGIF,
								["count"] = 1,
								["class"] = classGIF,
								["subclass"] = subclassGIF,
							},
							["zone"] = GetRealZoneText(),
							["time"] = sTime,
							["attendees"] = tAttendees,
						}
					);
					KA_RaidTracker_Print("Add item: Added "..sName, 1, 1, 0);
					KA_RaidTracker_UpdateView();
					KA_RaidTracker_Update();
				else
					KA_RaidTracker_Print("Add item: There is no raid selected", 1, 1, 0);
				end
			else
				KA_RaidTracker_Print("Add item: Invalid Item Link given", 1, 1, 0);
			end
		else
			KA_RaidTracker_Print("Add item: No Item Link given", 1, 1, 0);
		end
	elseif(command == "io") then
		local idfound;
		for idtoadd in string.gmatch(args, "item:(%d+):") do
			idfound = nil;
			idtoadd = tonumber(idtoadd);
			for key, val in pairs(KARaidTrackerDB.ItemOptions) do
				if(val["id"] == idtoadd) then
					idfound = true;
					break;
				end
			end
			if(idfound) then
				KA_RaidTracker_Print(idtoadd.." is already in the Item Options list", 1, 1, 0);
			else
				tinsert(KARaidTrackerDB.ItemOptions, {["id"] = idtoadd});
				KA_RaidTracker_Print("Added "..idtoadd.." to the Item Options list", 1, 1, 0);
				idfound = true;
			end
		end
		if(not idfound) then
			for idtoadd in string.gmatch(args, "(%d+)%s?") do
				idfound = nil;
				idtoadd = tonumber(idtoadd);
				KARaidTrackerUtility:Debug("idtoadd", idtoadd);
				for key, val in pairs(KARaidTrackerDB.ItemOptions) do
					if(val["id"] == idtoadd) then
						idfound = true;
						break;
					end
				end
				if(idfound) then
					KA_RaidTracker_Print(idtoadd.." is already in the Item Options list", 1, 1, 0);
				else
					tinsert(KARaidTrackerDB.ItemOptions, {["id"] = idtoadd});
					KA_RaidTracker_Print("Added "..idtoadd.." to the Item Options list", 1, 1, 0);
				end
			end
		end
		KA_RaidTracker_ItemOptions_ScrollBar_Update();
		KA_RaidTrackerItemOptionsFrame:Show();
		
    elseif(command == "options") then
	    KA_RaidTrackerOptionsFrame:Show();
	elseif(command == "o") then
		KA_RaidTrackerOptionsFrame:Show();
	elseif(command == "join") then
		if(KA_RaidTrackerFrame.selected) then
			if(args and strlen(args) > 0) then
				KA_RaidTrackerJoinLeaveFrameNameEB:SetText(args);
			end
			KA_RaidTrackerJoinLeaveFrameTitle = "Join";
			KA_RaidTrackerJoinLeaveFrame.type = "Join";
			KA_RaidTrackerJoinLeaveFrame.raidid = KA_RaidTrackerFrame.selected;
			KA_RaidTrackerJoinLeaveFrame:Show();
		else
			KA_RaidTracker_Print("Join: There is no raid selected", 1, 1, 0);
		end
	elseif(command == "leave") then
		if(KA_RaidTrackerFrame.selected) then
			if(args and strlen(args) > 0) then
				KA_RaidTrackerJoinLeaveFrameNameEB:SetText(args);
			end
			KA_RaidTrackerJoinLeaveFrameTitle = "Leave";
			KA_RaidTrackerJoinLeaveFrame.type = "Leave";
			KA_RaidTrackerJoinLeaveFrame.raidid = KA_RaidTrackerFrame.selected;
			KA_RaidTrackerJoinLeaveFrame:Show();
		else
			KA_RaidTracker_Print("Join: There is no raid selected", 1, 1, 0);
		end
	elseif(command) then
		KA_RaidTracker_Print("/rt - Shows the Control Panel", 1, 1, 0);
		KA_RaidTracker_Print("/rt options/o - Options", 1, 1, 0);
		KA_RaidTracker_Print("/rt io - Shows the Item Options Panel", 1, 1, 0);
		KA_RaidTracker_Print("/rt io [ITEMLINK(S)/ITEMID(S)] - This will add the given item(s) to the Item Options list", 1, 1, 0);
		KA_RaidTracker_Print("/rt additem [ITEMLINK] [Looter]- This will add the given item to the loot of your selected raid", 1, 1, 0);
		KA_RaidTracker_Print("/rt join [PLAYER] - Manual player join", 1, 1, 0);
		KA_RaidTracker_Print("/rt leave [PLAYER] - Manual player leave", 1, 1, 0);
		KA_RaidTracker_Print("/rt deleteall - Deletes all raids", 1, 1, 0);
		KA_RaidTracker_Print("/rt debug 0/1 - Enables/Disables debug output", 1, 1, 0);
		KA_RaidTracker_Print("/rt addwipe - Adds a Wipe with the current timestamp", 1, 1, 0);
	else
		ShowUIPanel(KA_RaidTrackerFrame);	
	end
end


function KA_RaidTracker_Print(msg, r, g, b)
	if ( KA_Print ) then
		KA_Print(msg, r, g, b);
	else
		DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b);
	end
end

function KA_RaidTracker_RarityDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, KA_RaidTracker_RarityDropDown_Initialize);
	--UIDropDownMenu_SetWidth(130);
	UIDropDownMenu_SetSelectedID(KA_RaidTrackerRarityDropDown, 1);
end

-- Grey = 9d9d9d
-- White = ffffff
-- Green = 1eff00
-- Blue = 0070dd
-- Purple = a335ee
-- Orange = ff8000
-- Red e6cc80

function KA_RaidTracker_RarityDropDown_Initialize()
	local info = {};
	info.text = "|c009d9d9dPoor|r";
	info.func = KA_RaidTracker_RarityDropDown_OnClick;
	UIDropDownMenu_AddButton(info);
	
	local info = {};
	info.text = "|c00ffffffCommon|r";
	info.func = KA_RaidTracker_RarityDropDown_OnClick;
	UIDropDownMenu_AddButton(info);

	local info = {};
	info.text = "|c001eff00Uncommon|r";
	info.func = KA_RaidTracker_RarityDropDown_OnClick;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = "|c000070ddRare|r";
	info.func = KA_RaidTracker_RarityDropDown_OnClick;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = "|c00a335eeEpic|r";
	info.func = KA_RaidTracker_RarityDropDown_OnClick;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = "|c00ff8000Legendary|r";
	info.func = KA_RaidTracker_RarityDropDown_OnClick;
	UIDropDownMenu_AddButton(info);
	
	info = {};
	info.text = "|c00e6cc80Artifact|r";
	info.func = KA_RaidTracker_RarityDropDown_OnClick;
	UIDropDownMenu_AddButton(info);
end


function KA_RaidTracker_RarityDropDown_OnClick()
	UIDropDownMenu_SetSelectedID(KA_RaidTrackerRarityDropDown, this:GetID());
	if ( KA_RaidTrackerFrame.type == "items" ) then
		KARaidTrackerDB.SortOptions["itemfilter"] = this:GetID();
	else
		KARaidTrackerDB.SortOptions["playeritemfilter"] = this:GetID();
	end
	KA_RaidTracker_UpdateView();
end

function KA_RaidTracker_SelectItem(name)
	KA_RaidTracker_GetPage();
	KA_RaidTrackerFrame.type = "itemhistory";
	KA_RaidTrackerFrame.itemname = name;
	KA_RaidTrackerFrame.selected = nil;
	KA_RaidTracker_Update();
	KA_RaidTracker_UpdateView();
end

function KA_RaidTracker_GetPage()
	if ( KA_RaidTrackerFrame.type or KA_RaidTrackerFrame.itemname or KA_RaidTrackerFrame.selected or KA_RaidTrackerFrame.player ) then

		tinsert(KA_RaidTracker_LastPage,
			{
				["type"] = KA_RaidTrackerFrame.type,
				["itemname"] = KA_RaidTrackerFrame.itemname,
				["selected"] = KA_RaidTrackerFrame.selected,
				["player"] = KA_RaidTrackerFrame.player
			}
		);
	end

	if ( getn(KA_RaidTracker_LastPage) > 0 ) then
		KA_RaidTrackerFrameBackButton:Enable();
	else
		KA_RaidTrackerFrameBackButton:Disable();
	end
end

function KA_RaidTracker_GoBack()
	local t = table.remove(KA_RaidTracker_LastPage);

	if ( t ) then
		KA_RaidTrackerFrame.type = t["type"];
		KA_RaidTrackerFrame.itemname = t["itemname"];
		KA_RaidTrackerFrame.selected = t["selected"];
		KA_RaidTrackerFrame.player = t["player"];
		KA_RaidTracker_Update();
		KA_RaidTracker_UpdateView();
	end
	if ( getn(KA_RaidTracker_LastPage) > 0 ) then
		KA_RaidTrackerFrameBackButton:Enable();
	else
		KA_RaidTrackerFrameBackButton:Disable();
	end
end

if ( KA_RegisterMod ) then
	KA_RaidTracker_DisplayWindow = function()
		ShowUIPanel(KA_RaidTrackerFrame);
	end
	KA_RegisterMod("Raid Tracker", "Display window", 5, "Interface\\Icons\\INV_Chest_Chain_05", "Displays the Raid Tracker window, which tracks raid loot & attendance.", "switch", "", KA_RaidTracker_DisplayWindow);
else
	--KA_RaidTracker_Print("<CTMod> KA_RaidTracker loaded. Type /rt to show the RaidTracker window.", 1, 1, 0);
end


function KA_RaidTracker_Date()
	local timestamp;
	if(KARaidTrackerDB.Options["TimeSync"] == 1) then
		timestamp = time()+KA_RaidTracker_TimeOffset+(KARaidTrackerDB.Options["Timezone"]*3600);
	else
		timestamp = time()+(KARaidTrackerDB.Options["Timezone"]*3600);
	end
	local t = date("*t", timestamp);
	return KARaidTrackerUtility:FixZero(t.month) .. "/" .. KARaidTrackerUtility:FixZero(t.day) .. "/" .. strsub(t.year, 3) .. " " .. KARaidTrackerUtility:FixZero(t.hour) .. ":" .. KARaidTrackerUtility:FixZero(t.min) .. ":" .. KARaidTrackerUtility:FixZero(t.sec);
end

function KA_RaidTrackerUpdateFrame_OnUpdate(elapsed)
	if ( this.time ) then
		this.time = this.time + elapsed;
		if ( this.time > 2 ) then
			this.time = nil;
			for k, v in pairs(KA_RaidTracker_Events) do
				KA_RaidTracker_OnEvent(v);
			end
		end
	end
end

function KA_RaidTrackerCreateNewRaid()
	KA_RaidTracker_GetGameTimeOffset();
	local sDate = KA_RaidTracker_Date();
	if(KARaidTrackerDB.Options["CurrentRaid"]) then
		for k, v in pairs(KARaidTrackerDB.Online) do
			KARaidTrackerUtility:Debug("ADDING LEAVE", k, sDate);
			tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Leave"],
				{
					["player"] = k,
					["time"] = sDate,
				}
			);
		end
		if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["End"]) then
			KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["End"] = sDate;
		end
	end
	KARaidTrackerDB.Online = { };
	KA_RaidTracker_Offline = { };
	tinsert(KARaidTrackerDB.RaidLog, 1, { 
		["Loot"] = { },
		["Join"] = { },
		["Leave"] = { },
		["PlayerInfos"] = { },
		["BossKills"] = { },
		["key"] = sDate
	});
	KA_RaidTracker_SortRaidTable();
	KARaidTrackerDB.Options["CurrentRaid"] = 1;
	if( GetNumRaidMembers() > 0 ) then
		for i = 1, GetNumRaidMembers(), 1 do
			local sPlayer = UnitName("raid" .. i);
			local _, race = UnitRace("raid" .. i);
			local sex = UnitSex("raid" .. i);
			local guild = GetGuildInfo("raid" .. i);
			local name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i);
			if(sPlayer ~= UKNOWNBEING and name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
				if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]) then
					KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name] = { };
				end
				if(KARaidTrackerDB.Options["SaveExtendedPlayerInfo"] == 1) then
				    if(race) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["race"] = race; end
				    if(fileName) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["class"] = fileName; end
						if(sex) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["sex"] = sex; end
				    if(level > 0) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["level"] = level; end
				    if(guild) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["guild"] = guild; end
				end
				tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Join"],
					{
						["player"] = sPlayer,
						["time"] = sDate
					}
				);
				if ( not online ) then
					tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Leave"],
						{
							["player"] = UnitName("raid" .. i),
							["time"] = sDate
						}
					);
				end
				KARaidTrackerDB.Online[name] = online;
			end
		end
	elseif( (GetNumPartyMembers()  > 0) and (KARaidTrackerDB.Options["LogGroup"] == 1) ) then
		for i = 1, GetNumPartyMembers(), 1 do
			local sPlayer = UnitName("party" .. i);
			local _, race = UnitRace("party" .. i);
			local sex = UnitSex("party" .. i);
			local guild = GetGuildInfo("party" .. i);
			local name = UnitName("party" .. i);
			local rank = UnitPVPRank("party" .. i);
			local level = UnitLevel("party" .. i);
			local _, class = UnitClass("party" .. i);
			local online = UnitIsConnected("party" .. i);
			if (class) then
				local fileName = string.upper(class);
			end;
			if(sPlayer ~= UKNOWNBEING and name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
				if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]) then
					KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name] = { };
				end
				if(KARaidTrackerDB.Options["SaveExtendedPlayerInfo"] == 1) then
				    if(race) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["race"] = race; end
				    if(fileName) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["class"] = fileName; end
						if(sex) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["sex"] = sex; end
				    if(level > 0) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["level"] = level; end
				    if(guild) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["guild"] = guild; end
				end
				tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Join"],
					{
						["player"] = sPlayer,
						["time"] = sDate
					}
				);
				if ( not online ) then
					tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Leave"],
						{
							["player"] = name,
							["time"] = sDate
						}
					);
				end
				KARaidTrackerDB.Online[name] = online;
			end
		end
		
		--Player isnt in party so add individual
		
		local sPlayer = UnitName("player");
		local _, race = UnitRace("player");
		local sex = UnitSex("player");
		local guild = GetGuildInfo("player");
		local name = UnitName("player");
		local rank = UnitPVPRank("player");
		local level = UnitLevel("player");
		local _, class = UnitClass("player");
		local online = UnitIsConnected("player");
		local fileName = string.upper(class);
		if(sPlayer ~= UKNOWNBEING and name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
			if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]) then
				KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name] = { };
			end
			if(KARaidTrackerDB.Options["SaveExtendedPlayerInfo"] == 1) then
			    if(race) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["race"] = race; end
			    if(fileName) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["class"] = fileName; end
					if(sex) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["sex"] = sex; end
			    if(level > 0) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["level"] = level; end
			    if(guild) then KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["PlayerInfos"][name]["guild"] = guild; end
			end
			tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Join"],
				{
					["player"] = sPlayer,
					["time"] = sDate
				}
			);
			if ( not online ) then
				tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Leave"],
					{
						["player"] = name,
						["time"] = sDate
					}
				);
			end
			KARaidTrackerDB.Online[name] = online;
		end
	end
	if(KARaidTrackerDB.Options["AutoZone"] == 1) then
		KA_RaidTracker_DoZoneCheck()
	end
	KARaidTrackerUtility:Debug("Joined new raid at " .. sDate);
	KA_RaidTracker_Update();
	KA_RaidTracker_UpdateView();
end

function KA_RaidTrackerEndRaid()
    local raidendtime = KA_RaidTracker_Date();
    if(KARaidTrackerDB.Options["CurrentRaid"]) then
        KA_RaidTracker_Print("Ending current raid at "..raidendtime, 1, 1, 0);
    	for k, v in pairs(KARaidTrackerDB.Online) do
    		KARaidTrackerUtility:Debug("ADDING LEAVE", k, raidendtime);
    		tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Leave"],
    			{
    				["player"] = k,
    				["time"] = raidendtime,
    			}
    		);
    	end
    	if(not KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["End"]) then
    		KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["End"] = raidendtime;
    	end
    	KARaidTrackerDB.Options["CurrentRaid"] = nil;
    	KARaidTrackerUtility:Debug("Left raid.","KA_RaidTrackerEndRaid");
    	KARaidTrackerDB.Online = { };
    	KA_RaidTracker_UpdateView();
    	KA_RaidTracker_Update();
    end
end

function KA_RaidTrackerSnapshotRaid()
    local sDate = KA_RaidTracker_Date();
    local newraid = {};
    if(KARaidTrackerDB.Options["CurrentRaid"]) then
        KA_RaidTracker_Print("Snapshotting current raid", 1, 1, 0);
        tinsert(KARaidTrackerDB.RaidLog, 2, { 
    		["Loot"] = { },
    		["Join"] = { },
    		["Leave"] = { },
    		["PlayerInfos"] = { },
    		["BossKills"] = { },
    		["key"] = sDate,
    		["End"] = sDate,
	        });
	    if(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Zone"]) then
	        KARaidTrackerDB.RaidLog[2]["Zone"] = KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Zone"];
	    end
	    
	    for k, v in pairs(KARaidTrackerDB.Online) do
            KARaidTrackerDB.RaidLog[2]["PlayerInfos"][k] = {};
            tinsert(KARaidTrackerDB.RaidLog[2]["Join"], {
                ["player"] = k,
                ["time"] = sDate 
                });
            tinsert(KARaidTrackerDB.RaidLog[2]["Leave"], {
                ["player"] = k,
                ["time"] = sDate 
                });
	    end
	    KA_RaidTracker_UpdateView();
    	KA_RaidTracker_Update();
    end
end
	
function KA_RaidTrackerAddGuild()
	if(KARaidTrackerDB.Options["CurrentRaid"]) then
		SetGuildRosterShowOffline(false);
     for i = 1, GetNumGuildMembers() do
        local name, rank, rankIndex, level, class, zone, group, note, officernote, online = GetGuildRosterInfo(i);
       -- KARaidTrackerUtility:Debug("GUILD", name, online);
        if( online ~= KARaidTrackerDB.Online[name] ) then
          if( online ) then
            tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Join"],
            {
               ["player"] = name,
               ["time"] = KA_RaidTracker_Date()
            }
            );
            KARaidTrackerDB.Online[name] = online;
            KARaidTrackerUtility:Debug("GUILD-ONLINE", name);
          elseif ( not online and KARaidTrackerDB.Online[name]) then
						tinsert(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["Leave"],
							{
								["player"] = name,
								["time"] = KA_RaidTracker_Date()
							}
						);
						KARaidTrackerDB.Online[name] = online;
						KARaidTrackerUtility:Debug("GUILD-OFFLINE", name);
         	end
       	end
     end
  end
	KA_RaidTracker_Update();
	KA_RaidTracker_UpdateView();
end


function KA_RaidTracker_GetPlayerIndexes(raidid)
	local PlayerIndexes = { };
	local PlayerFound = nil;
	if(KARaidTrackerDB.RaidLog[raidid]) then
		for k, v in pairs(KARaidTrackerDB.RaidLog[raidid]["Join"]) do
			if ( v["player"] ) then
				PlayerFound = false;
				for k2, v2 in pairs(PlayerIndexes) do
					if(v2 == v["player"]) then
						PlayerFound = true;
						break;
					end
				end
				if(not PlayerFound) then
					tinsert(PlayerIndexes, v["player"]);
				end
			end
		end
	end
	table.sort(PlayerIndexes);
	return PlayerIndexes;
end

function KA_RaidTracker_GetPlayerGroups(raidid)
	local PlayerIndexes = KA_RaidTracker_GetPlayerIndexes(raidid);
	local PlayerGroups = { };
	local PlayerGroup;
	for k, v in pairs(PlayerIndexes) do
		PlayerGroup = KA_RaidTracker_PlayerGroupIndex(strupper(strsub(KA_RaidTracker_StripSpecialChars(v), 1, 1)));
		if(not PlayerGroups[PlayerGroup]) then
			PlayerGroups[PlayerGroup] = { };
		end
		tinsert(PlayerGroups[PlayerGroup], v);
	end
	return PlayerGroups;
end

function KA_RaidTracker_PlayerGroupIndex(letter)
	letter = strupper(letter);
	for k, v in pairs(PlayerGroupsIndexes) do
		if(v == letter) then
			return k;
		end
	end
	return;
end

function KA_RaidTracker_StripSpecialChars(sstring)
	
	sstring = string.gsub(sstring, "\194\161", "!");
	sstring = string.gsub(sstring, "\194\170", "a");
	sstring = string.gsub(sstring, "\194\186", "o");
	sstring = string.gsub(sstring, "\194\191", "?");
	sstring = string.gsub(sstring, "\195\128", "A");
	sstring = string.gsub(sstring, "\195\129", "A");
	sstring = string.gsub(sstring, "\195\130", "A");
	sstring = string.gsub(sstring, "\195\131", "A");
	sstring = string.gsub(sstring, "\195\133", "A");
	sstring = string.gsub(sstring, "\195\135", "C");
	sstring = string.gsub(sstring, "\195\136", "E");
	sstring = string.gsub(sstring, "\195\137", "E");
	sstring = string.gsub(sstring, "\195\138", "E");
	sstring = string.gsub(sstring, "\195\139", "E");
	sstring = string.gsub(sstring, "\195\140", "I");
	sstring = string.gsub(sstring, "\195\141", "I");
	sstring = string.gsub(sstring, "\195\142", "I");
	sstring = string.gsub(sstring, "\195\143", "I");
	sstring = string.gsub(sstring, "\195\144", "D");
	sstring = string.gsub(sstring, "\195\145", "N");
	sstring = string.gsub(sstring, "\195\146", "O");
	sstring = string.gsub(sstring, "\195\147", "O");
	sstring = string.gsub(sstring, "\195\148", "O");
	sstring = string.gsub(sstring, "\195\149", "O");
	sstring = string.gsub(sstring, "\195\152", "O");
	sstring = string.gsub(sstring, "\195\153", "U");
	sstring = string.gsub(sstring, "\195\154", "U");
	sstring = string.gsub(sstring, "\195\155", "U");
	sstring = string.gsub(sstring, "\195\157", "Y");
	sstring = string.gsub(sstring, "\195\160", "a");
	sstring = string.gsub(sstring, "\195\161", "a");
	sstring = string.gsub(sstring, "\195\162", "a");
	sstring = string.gsub(sstring, "\195\163", "a");
	sstring = string.gsub(sstring, "\195\165", "a");
	sstring = string.gsub(sstring, "\195\167", "c");
	sstring = string.gsub(sstring, "\195\168", "e");
	sstring = string.gsub(sstring, "\195\169", "e");
	sstring = string.gsub(sstring, "\195\170", "e");
	sstring = string.gsub(sstring, "\195\171", "e");
	sstring = string.gsub(sstring, "\195\172", "i");
	sstring = string.gsub(sstring, "\195\173", "i");
	sstring = string.gsub(sstring, "\195\174", "i");
	sstring = string.gsub(sstring, "\195\175", "i");
	sstring = string.gsub(sstring, "\195\176", "d");
	sstring = string.gsub(sstring, "\195\177", "n");
	sstring = string.gsub(sstring, "\195\178", "o");
	sstring = string.gsub(sstring, "\195\179", "o");
	sstring = string.gsub(sstring, "\195\180", "o");
	sstring = string.gsub(sstring, "\195\181", "o");
	sstring = string.gsub(sstring, "\195\184", "o");
	sstring = string.gsub(sstring, "\195\185", "u");
	sstring = string.gsub(sstring, "\195\186", "u");
	sstring = string.gsub(sstring, "\195\187", "u");
	sstring = string.gsub(sstring, "\195\189", "y");
	sstring = string.gsub(sstring, "\195\191", "y");
	sstring = string.gsub(sstring, "\195\132", "Ae");
	sstring = string.gsub(sstring, "\195\134", "AE");
	sstring = string.gsub(sstring, "\195\150", "Oe");
	sstring = string.gsub(sstring, "\195\156", "Ue");
	sstring = string.gsub(sstring, "\195\158", "TH");
	sstring = string.gsub(sstring, "\195\159", "ss");
	sstring = string.gsub(sstring, "\195\164", "ae");
	sstring = string.gsub(sstring, "\195\166", "ae");
	sstring = string.gsub(sstring, "\195\182", "oe");
	sstring = string.gsub(sstring, "\195\188", "ue");
	sstring = string.gsub(sstring, "\195\190", "th");
	return sstring;
end

function KA_RaidTrackerShowDkpLink(link)
	URLFrameEditBox:SetText(link);
	URLFrameEditBox:HighlightText();
	URLFrame:Show();
end

function KA_RaidTrackerGenerateMLdkpXML(id)
	local race, class, level, sex;
	
	if (not KARaidTrackerDB.RaidLog[id]["End"]) then
		KA_RaidTracker_Print("You have to end the raid before you exporting it");
		return;
	end;
	
	local xml ='<?xml version="1.0"?>';
	xml = xml..'<!DOCTYPE ML_Raidtracker PUBLIC "-//MLdkp//DTD ML_Raidtracker V 1.5//EN" "http://www.mldkp.net/dtds/1.0/ML_Raidtracker.dtd">';
	
	xml = xml.."<raidinfo>";
	xml = xml.."<version>1.5</version>";
	
	xml = xml.."<start>"..KARaidTrackerUtility:GetTime(KARaidTrackerDB.RaidLog[id]["key"]).."</start>";
	xml = xml.."<end>"..KARaidTrackerUtility:GetTime(KARaidTrackerDB.RaidLog[id]["End"]).."</end>";

	if(KARaidTrackerDB.RaidLog[id]["zone"]) then
		xml = xml.."<zone>"..KARaidTrackerDB.RaidLog[id]["zone"].."</zone>";
	end
	if(KARaidTrackerDB.RaidLog[id]["instanceid"]) then
		xml = xml.."<instanceid>"..KARaidTrackerDB.RaidLog[id]["instanceid"].."</instanceid>";
	end
	xml = xml.."<exporter>"..UnitName("Player").."</exporter>";
	
	if(KARaidTrackerDB.RaidLog[id]["PlayerInfos"]) then
		xml = xml.."<playerinfos>";
		for key, val in pairs(KARaidTrackerDB.RaidLog[id]["PlayerInfos"]) do
			xml = xml.."<player>";
			xml = xml.."<name>"..key.."</name>";
			for key2, val2 in pairs(KARaidTrackerDB.RaidLog[id]["PlayerInfos"][key]) do
				if(key2 == "note") then
					xml = xml.."<"..key2.."><![CDATA["..val2.."]]></"..key2..">";
				elseif (key2 == "class") then
					xml = xml.."<"..key2..">"..KA_RaidTracker_ClassTable[val2].."</"..key2..">";
				elseif (key2 == "race") then
					xml = xml.."<"..key2..">"..KA_RaidTracker_RaceTable[val2].."</"..key2..">";
				elseif (key2 == "level") then
					if (KARaidTrackerDB.Options["MaxLevel"] ~= val2) then
						xml = xml.."<"..key2..">"..val2.."</"..key2..">";
					end;
				else
					xml = xml.."<"..key2..">"..val2.."</"..key2..">";
				end
			end
			xml = xml.."</player>";
		end
		xml = xml.."</playerinfos>";
	end
	if(KARaidTrackerDB.RaidLog[id]["BossKills"]) then
		local bosskillsindex = 1;
		xml = xml.."<bosskills>";
		for key, val in pairs(KARaidTrackerDB.RaidLog[id]["BossKills"]) do
			xml = xml.."<bosskill>";
			xml = xml.."<name>"..val["boss"].."</name>";
			xml = xml.."<time>"..KARaidTrackerUtility:GetTime(val["time"]).."</time>";
			xml = xml.."</bosskill>";
		end
		xml = xml.."</bosskills>";
	end
	if(KARaidTrackerDB.RaidLog[id]["wipes"]) then
		xml = xml.."<wipes>";
		for key, val in pairs(KARaidTrackerDB.RaidLog[id]["wipes"]) do
			xml = xml.."<wipe><time>"..val.."</time></wipe>";
		end
		xml = xml.."</wipes>";
	end
	if(KARaidTrackerDB.RaidLog[id]["nextboss"]) then
		xml = xml.."<nextboss>"..KARaidTrackerDB.RaidLog[id]["nextboss"].."</nextboss>";
	end

	if(KARaidTrackerDB.RaidLog[id]["note"]) then 
		xml = xml.."<note><![CDATA["..KARaidTrackerDB.RaidLog[id]["note"].."]]></note>"; 
	end

	xml = xml.."<joins>";
	for key, val in pairs(KARaidTrackerDB.RaidLog[id]["Join"]) do
		xml = xml.."<join>";
		xml = xml.."<player>"..val["player"].."</player>";
		xml = xml.."<time>"..KARaidTrackerUtility:GetTime(val["time"]).."</time>";
		xml = xml.."</join>";
	end
	xml = xml.."</joins>";
	xml = xml.."<leaves>";
	for key, val in pairs(KARaidTrackerDB.RaidLog[id]["Leave"]) do
		xml = xml.."<leave>";
		xml = xml.."<player>"..val["player"].."</player>";
		xml = xml.."<time>"..KARaidTrackerUtility:GetTime(val["time"]).."</time>";
		xml = xml.."</leave>";
	end
	xml = xml.."</leaves>";
	xml = xml.."<loots>";
	for key, val in pairs(KARaidTrackerDB.RaidLog[id]["Loot"]) do
		xml = xml.."<loot>";
		xml = xml.."<itemname>"..val["item"]["name"].."</itemname>";
		xml = xml.."<itemid>"..val["item"]["id"].."</itemid>";
		xml = xml.."<count>"..val["item"]["count"].."</count>";
		xml = xml.."<player>"..val["player"].."</player>";
		if(val["costs"]) then
			xml = xml.."<costs>"..val["costs"].."</costs>";
		end
		xml = xml.."<time>"..KARaidTrackerUtility:GetTime(val["time"]).."</time>";
		if(val["zone"]) then 
			xml = xml.."<zone>"..val["zone"].."</zone>";
		end
		if(val["boss"]) then 
			xml = xml.."<boss>"..val["boss"].."</boss>";
		end
		if(val["note"]) then 
			xml = xml.."<note><![CDATA["..val["note"].."]]></note>";
		end
		xml = xml.."</loot>";
	end
	xml = xml.."</loots>";
	xml = xml.."</raidinfo>";
	KA_RaidTrackerShowDkpLink(xml);
end

function KA_RaidTrackerGenerateDkpLink(id)
	local race, class, level, sex;
	if (KARaidTrackerDB.Options["ExportFormat"]==2) then
		KA_RaidTrackerGenerateMLdkpXML(id);
		return;
	end;
	local link = "<RaidInfo>";
	if(KARaidTrackerDB.Options["ExportFormat"] == 0) then
		local link = link.."<Version>1.4</Version>";
	end
	
	if(KARaidTrackerDB.Options["ExportFormat"] == 0) then
		link = link.."<key>"..KARaidTrackerDB.RaidLog[id]["key"].."</key>";
	end
	if(KARaidTrackerDB.Options["ExportFormat"] == 1) then
		link = link.."<start>"..KARaidTrackerUtility:GetTime(KARaidTrackerDB.RaidLog[id]["key"]).."</start>";
	else
		link = link.."<start>"..KARaidTrackerDB.RaidLog[id]["key"].."</start>";
	end
	
	if(KARaidTrackerDB.RaidLog[id]["End"]) then
		if(KARaidTrackerDB.Options["ExportFormat"] == 1) then
			link = link.."<end>"..KARaidTrackerUtility:GetTime(KARaidTrackerDB.RaidLog[id]["End"]).."</end>";
		else
			link = link.."<end>"..KARaidTrackerDB.RaidLog[id]["End"].."</end>";
		end
	end
	if(KARaidTrackerDB.RaidLog[id]["zone"]) then
		link = link.."<zone>"..KARaidTrackerDB.RaidLog[id]["zone"].."</zone>";
	end
	if(KARaidTrackerDB.RaidLog[id]["PlayerInfos"]) then
		link = link.."<PlayerInfos>";
		local playerinfosindex = 1;
		for key, val in pairs(KARaidTrackerDB.RaidLog[id]["PlayerInfos"]) do
			link = link.."<key"..playerinfosindex..">";
			link = link.."<name>"..key.."</name>";
			for key2, val2 in pairs(KARaidTrackerDB.RaidLog[id]["PlayerInfos"][key]) do
				if(key2 == "note") then
					link = link.."<"..key2.."><![CDATA["..val2.."]]></"..key2..">";
				
				else
					link = link.."<"..key2..">"..val2.."</"..key2..">";
				end
			end
			link = link.."</key"..playerinfosindex..">";
			playerinfosindex = playerinfosindex + 1;
		end
		link = link.."</PlayerInfos>";
	end
	if(KARaidTrackerDB.RaidLog[id]["BossKills"]) then
		local bosskillsindex = 1;
		link = link.."<BossKills>";
		for key, val in pairs(KARaidTrackerDB.RaidLog[id]["BossKills"]) do
			link = link.."<key"..bosskillsindex..">";
			link = link.."<name>"..val["boss"].."</name>";
			if(KARaidTrackerDB.Options["ExportFormat"] == 1) then
				link = link.."<time>"..KARaidTrackerUtility:GetTime(val["time"]).."</time>";
			else
				link = link.."<time>"..val["time"].."</time>";
				if( KARaidTrackerDB.RaidLog[id]["BossKills"][key]["attendees"]) then
					link = link.."<attendees>";
					for key2, val2 in pairs(KARaidTrackerDB.RaidLog[id]["BossKills"][key]["attendees"]) do
						link = link.."<key"..key2..">";
						link = link.."<name>"..val2.."</name>";
						link = link.."</key"..key2..">";
					end
					link = link.."</attendees>";
				end
			end
			link = link.."</key"..bosskillsindex..">";
			bosskillsindex = bosskillsindex + 1;
		end
		link = link.."</BossKills>";
	end
	-- new exports
	if(KARaidTrackerDB.RaidLog[id]["wipes"]) then
		link = link.."<Wipes>";
		for key, val in pairs(KARaidTrackerDB.RaidLog[id]["wipes"]) do
			link = link.."<Wipe>"..val.."</Wipe>";
		end
		link = link.."</Wipes>";
	end
	if(KARaidTrackerDB.RaidLog[id]["nextboss"]) then
		link = link.."<NextBoss>"..KARaidTrackerDB.RaidLog[id]["nextboss"].."</NextBoss>";
	end
	--	
	if(KARaidTrackerDB.Options["ExportFormat"] == 0) then
			local sNote = "<note><![CDATA[";
			if(KARaidTrackerDB.RaidLog[id]["note"]) then sNote = sNote..KARaidTrackerDB.RaidLog[id]["note"]; end
			if(KARaidTrackerDB.RaidLog[id]["zone"]) then sNote = sNote.." - Zone: "..KARaidTrackerDB.RaidLog[id]["zone"]; end
			sNote = sNote.."]]></note>";
			link = link..sNote;
		else
			if(KARaidTrackerDB.RaidLog[id]["note"]) then link = link.."<note><![CDATA["..KARaidTrackerDB.RaidLog[id]["note"].."]]></note>"; end
		end
	link = link.."<Join>";
	for key, val in pairs(KARaidTrackerDB.RaidLog[id]["Join"]) do
		link = link.."<key"..key..">";
		link = link.."<player>"..val["player"].."</player>";
		if(KARaidTrackerDB.Options["ExportFormat"] == 0) then
			if(val["race"]) then
				race = val["race"]; 
			elseif(KARaidTrackerDB.RaidLog[id]["PlayerInfos"] and KARaidTrackerDB.RaidLog[id]["PlayerInfos"][val["player"]] and KARaidTrackerDB.RaidLog[id]["PlayerInfos"][val["player"]]["race"]) then
				race = KARaidTrackerDB.RaidLog[id]["PlayerInfos"][val["player"]]["race"]; 
			else
				race = nil;
			end
			if(val["class"]) then
				class = val["class"]; 
			elseif(KARaidTrackerDB.RaidLog[id]["PlayerInfos"] and KARaidTrackerDB.RaidLog[id]["PlayerInfos"][val["player"]] and KARaidTrackerDB.RaidLog[id]["PlayerInfos"][val["player"]]["class"]) then
				class = KARaidTrackerDB.RaidLog[id]["PlayerInfos"][val["player"]]["class"]; 
			else
				class = nil;
			end
			if(val["sex"]) then
				sex = val["sex"]; 
			elseif(KARaidTrackerDB.RaidLog[id]["PlayerInfos"] and KARaidTrackerDB.RaidLog[id]["PlayerInfos"][val["player"]] and KARaidTrackerDB.RaidLog[id]["PlayerInfos"][val["player"]]["sex"]) then
				sex = KARaidTrackerDB.RaidLog[id]["PlayerInfos"][val["player"]]["sex"]; 
			else
				sex = nil;
			end
			if(val["level"]) then
				level = val["level"]; 
			elseif(KARaidTrackerDB.RaidLog[id]["PlayerInfos"] and KARaidTrackerDB.RaidLog[id]["PlayerInfos"][val["player"]] and KARaidTrackerDB.RaidLog[id]["PlayerInfos"][val["player"]]["level"]) then
				level = KARaidTrackerDB.RaidLog[id]["PlayerInfos"][val["player"]]["level"]; 
			else
				level = nil;
			end
			if(race) then link = link.."<race>"..race.."</race>"; end
			if(class) then link = link.."<class>"..class.."</class>"; end
			if(sex) then link = link.."<sex>"..sex.."</sex>"; end
			if(level) then link = link.."<level>"..level.."</level>"; end
		end
		if(KARaidTrackerDB.Options["ExportFormat"] == 0 and KARaidTrackerDB.RaidLog[id]["PlayerInfos"][val["player"]] and KARaidTrackerDB.RaidLog[id]["PlayerInfos"][val["player"]]["note"]) then link = link.."<note>"..KARaidTrackerDB.RaidLog[id]["PlayerInfos"][val["player"]]["note"].."</note>"; end
		if(KARaidTrackerDB.Options["ExportFormat"] == 1) then
			link = link.."<time>"..KARaidTrackerUtility:GetTime(val["time"]).."</time>";
		else
			link = link.."<time>"..val["time"].."</time>";
		end
		link = link.."</key"..key..">";
	end
	link = link.."</Join>";
	link = link.."<Leave>";
	for key, val in pairs(KARaidTrackerDB.RaidLog[id]["Leave"]) do
		link = link.."<key"..key..">";
		link = link.."<player>"..val["player"].."</player>";
		if(KARaidTrackerDB.Options["ExportFormat"] == 1) then
			link = link.."<time>"..KARaidTrackerUtility:GetTime(val["time"]).."</time>";
		else
			link = link.."<time>"..val["time"].."</time>";
		end
		link = link.."</key"..key..">";
	end
	link = link.."</Leave>";
	link = link.."<Loot>";
	for key, val in pairs(KARaidTrackerDB.RaidLog[id]["Loot"]) do
		link = link.."<key"..key..">";
		link = link.."<ItemName>"..val["item"]["name"].."</ItemName>";
		link = link.."<ItemID>"..val["item"]["id"].."</ItemID>";
		if(val["item"]["icon"]) then link = link.."<Icon>"..val["item"]["icon"].."</Icon>"; end
		if(val["item"]["class"]) then link = link.."<Class>"..val["item"]["class"].."</Class>"; end
		if(val["item"]["subclass"]) then link = link.."<SubClass>"..val["item"]["subclass"].."</SubClass>"; end
		link = link.."<Color>"..val["item"]["c"].."</Color>";
		link = link.."<Count>"..val["item"]["count"].."</Count>";
		link = link.."<Player>"..val["player"].."</Player>";
		if(val["costs"]) then
			link = link.."<Costs>"..val["costs"].."</Costs>";
		end
		if(KARaidTrackerDB.Options["ExportFormat"] == 1) then
			link = link.."<Time>"..KARaidTrackerUtility:GetTime(val["time"]).."</Time>";
		else
			link = link.."<Time>"..val["time"].."</Time>";
		end
		if(val["zone"]) then link = link.."<Zone>"..val["zone"].."</Zone>"; end
		if(val["boss"]) then link = link.."<Boss>"..val["boss"].."</Boss>"; end
		if(KARaidTrackerDB.Options["ExportFormat"] == 0) then
			local sNote = "<Note><![CDATA[";
			if(val["note"]) then sNote = sNote..val["note"]; end
			if(val["zone"]) then sNote = sNote.." - Zone: "..val["zone"]; end
			if(val["boss"]) then sNote = sNote.." - Boss: "..val["boss"]; end
			if(val["costs"]) then sNote = sNote.." - "..val["costs"].." DKP"; end
			sNote = sNote.."]]></Note>";
			link = link..sNote;
		else
			if(val["note"]) then link = link.."<Note><![CDATA["..val["note"].."]]></Note>"; end
		end
		link = link.."</key"..key..">";
	end
	link = link.."</Loot>";
	link = link.."</RaidInfo>";
	KA_RaidTrackerShowDkpLink(link);
end

-- Editing
function KA_RaidTracker_EditPlayerNote(raidid, playerid)
    KA_RaidTrackerEditNoteFrame.type = "playernote";
    KA_RaidTrackerEditNoteFrame.raidid = raidid;
    KA_RaidTrackerEditNoteFrame.playerid = playerid;
    KA_RaidTrackerEditNoteFrame:Show();
end

function KA_RaidTracker_EditRaidNote(raidid)
	KA_RaidTrackerEditNoteFrame:Hide();
	KA_RaidTrackerEditNoteFrame.type = "raidnote";
	KA_RaidTrackerEditNoteFrame.raidid = raidid;
	KA_RaidTrackerEditNoteFrame:Show();
end

function KA_RaidTracker_EditItemNote(raidid, itemid)
    KA_RaidTrackerEditNoteFrame.type = "itemnote";
    KA_RaidTrackerEditNoteFrame.raidid = raidid;
    KA_RaidTrackerEditNoteFrame.itemid = itemid;
    KA_RaidTrackerEditNoteFrame:Show();
end

function KA_RaidTracker_EditItemCount(raidid, itemid)
    KA_RaidTrackerEditNoteFrame.type = "itemcount";
    KA_RaidTrackerEditNoteFrame.raidid = raidid;
    KA_RaidTrackerEditNoteFrame.itemid = itemid;
    KA_RaidTrackerEditNoteFrame:Show();
end

function KA_RaidTracker_EditCosts(raidid, itemid)
    KA_RaidTrackerEditCostFrame.type = "itemcost";
    KA_RaidTrackerEditCostFrame.raidid = raidid;
    KA_RaidTrackerEditCostFrame.itemid = itemid;
    KA_RaidTrackerEditCostFrame:Show();
end

function KA_RaidTracker_EditLooter(raidid, itemid)
	KARaidTrackerUtility:Debug("KA_RaidTracker_EditLooter", raidid, itemid);
	KA_RaidTrackerEditNoteFrame.type = "looter";
    KA_RaidTrackerEditNoteFrame.raidid = raidid;
    KA_RaidTrackerEditNoteFrame.itemid = itemid;
    KA_RaidTrackerEditNoteFrame:Show();
end

function KA_RaidTracker_EditTime(raidid, what)
	-- what: raidend/raidstart
 	KA_RaidTrackerEditNoteFrame.type = "time";
 	KA_RaidTrackerEditNoteFrame.what = what;
	KA_RaidTrackerEditNoteFrame.raidid = raidid;
	KA_RaidTrackerEditNoteFrame:Show();
end

function KA_RaidTracker_EditItemTime(raidid, itemid)
 	KA_RaidTrackerEditNoteFrame.type = "time";
 	KA_RaidTrackerEditNoteFrame.what = "item";
	KA_RaidTrackerEditNoteFrame.raidid = raidid;
	KA_RaidTrackerEditNoteFrame.itemid = itemid;
	KA_RaidTrackerEditNoteFrame:Show();
end

function KA_RaidTracker_EditZone(raidid)
	KA_RaidTrackerEditNoteFrame.type = "zone";
	KA_RaidTrackerEditNoteFrame.raidid = raidid;
	KA_RaidTrackerEditNoteFrame:Show();
end



function KA_RaidTracker_EditNote_OnShow()
	local text;
	
	if ( this.itemid ) then
		KA_RaidTrackerEditNoteFrame.itemitemid = KARaidTrackerDB.RaidLog[this.raidid]["Loot"][this.itemid]["item"]["id"];
		KA_RaidTrackerEditNoteFrame.itemtime = KARaidTrackerDB.RaidLog[this.raidid]["Loot"][this.itemid]["time"];
		KA_RaidTrackerEditNoteFrame.itemplayer = KARaidTrackerDB.RaidLog[this.raidid]["Loot"][this.itemid]["player"];
	end
	
	if ( this.type == "raidnote" ) then
	    local raidkey = KARaidTrackerDB.RaidLog[this.raidid]["key"];
	    getglobal(this:GetName() .. "Title"):SetText("Edit Note");
	    getglobal(this:GetName() .. "Editing"):SetText("Editing note for \"|c" .. "0000ff00" .. "" .. raidkey .. "|r\"");
			text = KARaidTrackerDB.RaidLog[this.raidid]["note"];
	
	elseif ( this.type == "itemnote" ) then
	    local itemname = KARaidTrackerDB.RaidLog[this.raidid]["Loot"][this.itemid]["item"]["name"];
	    local itemcolor = KARaidTrackerDB.RaidLog[this.raidid]["Loot"][this.itemid]["item"]["c"];
	    getglobal(this:GetName() .. "Title"):SetText("Edit Note");
	    getglobal(this:GetName() .. "Editing"):SetText("Editing note for \"|c" .. itemcolor .. "" .. itemname .. "|r\"");
			text = KARaidTrackerDB.RaidLog[this.raidid]["Loot"][this.itemid]["note"];
	
	elseif ( this.type == "itemcount" ) then
	    local itemname = KARaidTrackerDB.RaidLog[this.raidid]["Loot"][this.itemid]["item"]["name"];
	    local itemcolor = KARaidTrackerDB.RaidLog[this.raidid]["Loot"][this.itemid]["item"]["c"];
	    getglobal(this:GetName() .. "Title"):SetText("Edit Count");
	    getglobal(this:GetName() .. "Editing"):SetText("Editing count for \"|c" .. itemcolor .. "" .. itemname .. "|r\"");
			text = KARaidTrackerDB.RaidLog[this.raidid]["Loot"][this.itemid]["item"]["count"];
	
	elseif ( this.type == "playernote") then
	    getglobal(this:GetName() .. "Title"):SetText("Edit Note");
	    getglobal(this:GetName() .. "Editing"):SetText("Editing note for player \"" .. this.playerid .. "\"");
	    if( KARaidTrackerDB.RaidLog[this.raidid]["PlayerInfos"][this.playerid] and KARaidTrackerDB.RaidLog[this.raidid]["PlayerInfos"][this.playerid]["note"] ) then
		    text = KARaidTrackerDB.RaidLog[this.raidid]["PlayerInfos"][this.playerid]["note"];
			end
	
	elseif(this.type == "looter") then
	    local itemname = KARaidTrackerDB.RaidLog[this.raidid]["Loot"][this.itemid]["item"]["name"];
	    local itemcolor = KARaidTrackerDB.RaidLog[this.raidid]["Loot"][this.itemid]["item"]["c"];
	    local looter = KARaidTrackerDB.RaidLog[this.raidid]["Loot"][this.itemid]["player"];
	    getglobal(this:GetName() .. "Title"):SetText("Edit Looter");
	    getglobal(this:GetName() .. "Editing"):SetText("Editing looter for \"|c" .. itemcolor .. "" .. itemname .. "|r\"");
	    text = KARaidTrackerDB.RaidLog[this.raidid]["Loot"][this.itemid]["player"];
	
	elseif(this.type == "time") then
	    getglobal(this:GetName() .. "Title"):SetText("Edit Time");
	    if(this.what == "raidend") then
	        getglobal(this:GetName() .. "Editing"):SetText("Editing End Time");
		    text = KARaidTrackerDB.RaidLog[this.raidid]["End"];
	    elseif(this.what == "raidstart") then
	      getglobal(this:GetName() .. "Editing"):SetText("Editing Start Time");
		    text = KARaidTrackerDB.RaidLog[this.raidid]["key"];
		  elseif(this.what == "item") then
	      getglobal(this:GetName() .. "Editing"):SetText("Editing Item Time");
		    text = KARaidTrackerDB.RaidLog[this.raidid]["Loot"][this.itemid]["time"];
	    end
	    
	elseif(this.type == "zone") then
	    local raidkey = KARaidTrackerDB.RaidLog[this.raidid]["key"];
	    text = KARaidTrackerDB.RaidLog[this.raidid]["zone"];
	    getglobal(this:GetName() .. "Title"):SetText("Edit Zone");
	    getglobal(this:GetName() .. "Editing"):SetText("Editing zone for \"|c" .. "0000ff00" .. "" .. raidkey .. "|r\"");
	end
	
	if ( text ) then
		getglobal(this:GetName() .. "NoteEB"):SetText(text);
		getglobal(this:GetName() .. "NoteEB"):HighlightText();
	else
		getglobal(this:GetName() .. "NoteEB"):SetText("");
	end
end

function KA_RaidTracker_SaveCost(option)
	local text = KA_RaidTrackerEditCostFrameNoteEB:GetText();
	local raidid = KA_RaidTrackerEditCostFrame.raidid;
	local lootid;

	if(KA_RaidTrackerEditCostFrame.itemplayer and KA_RaidTrackerEditCostFrame.itemitemid and KA_RaidTrackerEditCostFrame.itemtime) then
		lootid = KA_RaidTracker_GetLootId(raidid, KA_RaidTrackerEditCostFrame.itemplayer, KA_RaidTrackerEditCostFrame.itemitemid, KA_RaidTrackerEditCostFrame.itemtime)
	end

	if ( strlen(text) == 0 ) then
		text = nil;
	end
	
	
  if(text and not string.find(text, "^(%d+%.?%d*)$") ) then
    KA_RaidTracker_Print("KA_RaidTracker Edit Costs: Invalid value", 1, 1, 0);
  else
  	KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["costs"] = text;
  	if ( type(dkpp_ctra_sub) == "function") then
  		dkpp_ctra_sub(raidid,lootid);
  	end;
  end
	if (option == "bank") then
		KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["player"] = "bank";
	end;
	if (option == "disenchanted") then
		KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["player"] = "disenchanted";
	end;
	
	KA_RaidTracker_Update();
	KA_RaidTracker_UpdateView();	
end;

function KA_RaidTracker_SaveNote()
	local text = KA_RaidTrackerEditNoteFrameNoteEB:GetText();
	local raidid = KA_RaidTrackerEditNoteFrame.raidid;
	local typeof = type;
	local type = KA_RaidTrackerEditNoteFrame.type;
	local lootid;
	if(KA_RaidTrackerEditNoteFrame.itemplayer and KA_RaidTrackerEditNoteFrame.itemitemid and KA_RaidTrackerEditNoteFrame.itemtime) then
		lootid = KA_RaidTracker_GetLootId(raidid, KA_RaidTrackerEditNoteFrame.itemplayer, KA_RaidTrackerEditNoteFrame.itemitemid, KA_RaidTrackerEditNoteFrame.itemtime)
	end
	
	KARaidTrackerUtility:Debug("KA_RaidTracker_SaveNote", raidid, type, lootid);
	
	if ( strlen(text) == 0 ) then
		text = nil;
	end
	
	if (type == "itemnote") then
		KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["note"] = text;
		
	elseif (type == "itemcount") then
		if(not text or not string.find(text, "^(%d+)$") ) then
			KA_RaidTracker_Print("KA_RaidTracker Edit Count: Invalid value", 1, 1, 0);
		else
			KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["item"]["count"] = tonumber(text);
		end
	
	elseif (type == "raidnote" ) then
		KARaidTrackerDB.RaidLog[raidid]["note"] = text;
	
	elseif(type == "playernote") then
	    local playerid = KA_RaidTrackerEditNoteFrame.playerid;
		if ( not KARaidTrackerDB.RaidLog[raidid]["PlayerInfos"][playerid] ) then
			KARaidTrackerDB.RaidLog[raidid]["PlayerInfos"][playerid] = {};
		end
		KARaidTrackerDB.RaidLog[raidid]["PlayerInfos"][playerid]["note"] = text;
	
	elseif(type == "looter") then
	    if(text and strlen(text) > 0) then
	        KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["player"] = text;
	    end
	
	elseif(type == "time") then
	    local what = KA_RaidTrackerEditNoteFrame.what;
	    if(text and not string.find(text, "^(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)$")) then
		    KA_RaidTracker_Print("KA_RaidTracker Edit Time: Invalid Time format", 1, 1, 0);
		  else
		  	if(what == "raidend") then
			    KARaidTrackerDB.RaidLog[raidid]["End"] = text;
		    elseif(what == "raidstart") then
			    KARaidTrackerDB.RaidLog[raidid]["key"] = text;
			  elseif(what == "item") then
			  	KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["time"] = text;
		    end
	    end
	    
	elseif(type == "zone") then
	    KA_RaidTracker_SaveZone(raidid, text);
	end
	
	KA_RaidTrackerEditNoteFrame.type = nil;
	KA_RaidTrackerEditNoteFrame.raidid = nil;
	KA_RaidTrackerEditNoteFrame.playerid = nil;
	KA_RaidTrackerEditNoteFrame.what = nil;
	KA_RaidTrackerEditNoteFrame.itemid = nil;
	KA_RaidTrackerEditNoteFrame.itemplayer = nil;
	KA_RaidTrackerEditNoteFrame.itemitemid = nil;
	KA_RaidTrackerEditNoteFrame.itemtime = nil;
	
	KA_RaidTracker_Update();
	KA_RaidTracker_UpdateView();
end

function KA_RaidTracker_SaveZone(raidid, text)
	local zone, zonetrigger, zonefound;
	if (text == nil or strlen(text) == 0 ) then
		text = nil;
		zone = nil;
		zonetrigger = nil;
	elseif( string.find(text, "^(.+)%-(.+)$") ) then
		_, _, zone, zonetrigger = string.find(text, "^(.+)%-(.+)$");
	else
		zone = text;
		zonetrigger = text;
	end
	if(zone and zonetrigger) then
		if(not KARaidTrackerDB.RaidLog[raidid]["zone"] or KARaidTrackerDB.RaidLog[raidid]["zone"] ~= zone) then
			for k, v in pairs(KA_RaidTracker_ZoneTriggers) do
				if(zonetrigger == k) then
					zonefound = 1;
					break;
				end
			end
			if(not zonefound) then
				for k, v in pairs(KARaidTrackerDB.CustomZoneTriggers) do
					if(zonetrigger == k) then
						zonefound = 1;
						break;
					end
				end
			end
			if(not zonefound) then
				KA_RaidTracker_Print("KA_RaidTracker Custom Zones: Added \""..zone.."\" (Trigger: \""..zonetrigger.."\")", 1, 1, 0);
				KARaidTrackerDB.CustomZoneTriggers[zonetrigger] = zone;
			end
		end
	elseif(not zone and not zonetrigger and KARaidTrackerDB.RaidLog[raidid]["zone"]) then
		for k, v in pairs(KARaidTrackerDB.CustomZoneTriggers) do
			if(v == KARaidTrackerDB.RaidLog[raidid]["zone"]) then
				KARaidTrackerDB.CustomZoneTriggers[k] = nil;
				KA_RaidTracker_Print("KA_RaidTracker Custom Zones: Removed \""..v.."\" (Trigger: \""..k.."\")", 1, 1, 0);
			end
		end
	end
	
	KARaidTrackerDB.RaidLog[raidid]["zone"] = zone;
end

function KA_RaidTracker_LootSetBoss(raidid, itemitemid, itemtime, itemplayer, boss)

	local lootid = KA_RaidTracker_GetLootId(raidid, itemplayer, itemitemid, itemtime);
	KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["boss"] = boss;
	KA_RaidTracker_Update();
	KA_RaidTracker_UpdateView();
end

function KA_RaidTracker_LootSetLooter(raidid, itemitemid, itemtime, itemplayer, player)
	local lootid = KA_RaidTracker_GetLootId(raidid, itemplayer, itemitemid, itemtime);
	KARaidTrackerDB.RaidLog[raidid]["Loot"][lootid]["player"] = player;
	KA_RaidTracker_Update();
	KA_RaidTracker_UpdateView();
end

function KA_RaidTracker_RaidSetZone(raidid, zone)
	KARaidTrackerDB.RaidLog[raidid]["zone"] = zone;
	KA_RaidTracker_Update();
	KA_RaidTracker_UpdateView();
end

function KA_RaidTracker_ItemsRightClickMenu_Initialize(level)
	if(not level) then
		return;
	end
	local raidid, itemid = 0, 0;
	local dropdown, info;
	if ( UIDROPDOWNMENU_OPEN_MENU ) then
		dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU);
	else
		dropdown = this;
	end
	
	if (level == 1) then
		raidid = this:GetParent().raidid;
		itemid = this:GetParent().itemid;
		local itemitemid = KARaidTrackerDB.RaidLog[raidid]["Loot"][itemid]["item"]["id"];
		local itemtime = KARaidTrackerDB.RaidLog[raidid]["Loot"][itemid]["time"];
		local itemplayer = KARaidTrackerDB.RaidLog[raidid]["Loot"][itemid]["player"];
		
		info = {};
		info.text = "Edit Looter";
		info.hasArrow = 1;
		info.value = { ["opt"] = "quick_looter", ["raidid"] = raidid, ["itemid"] = itemid, ["itemitemid"] = itemitemid, ["itemtime"] = itemtime, ["itemplayer"] = itemplayer, ["cplayer"] = KARaidTrackerDB.RaidLog[raidid]["Loot"][itemid]["player"] };
		info.func = function()
			HideDropDownMenu(1);
			local lootid = KA_RaidTracker_GetLootId(this.value["raidid"], this.value["itemplayer"], this.value["itemitemid"], this.value["itemtime"]);
			KA_RaidTracker_EditLooter(this.value["raidid"], lootid);
		end;
		UIDropDownMenu_AddButton(info, level);
		
		info = {};
		if(KARaidTrackerDB.RaidLog[raidid]["Loot"][itemid]["costs"]) then
			info.text = "Edit Costs ("..KARaidTrackerDB.RaidLog[raidid]["Loot"][itemid]["costs"]..")";
		else
			info.text = "Edit Costs";
		end
		info.value = { ["raidid"] = raidid, ["itemid"] = itemid, ["itemitemid"] = itemitemid, ["itemtime"] = itemtime, ["itemplayer"] = itemplayer };
		info.func = function()
			HideDropDownMenu(1);
			local lootid = KA_RaidTracker_GetLootId(this.value["raidid"], this.value["itemplayer"], this.value["itemitemid"], this.value["itemtime"]);
			KA_RaidTracker_EditCosts(this.value.raidid, lootid);
		end;
		UIDropDownMenu_AddButton(info, level);
		
		info = {};
		if(KARaidTrackerDB.RaidLog[raidid]["Loot"][itemid]["item"]["count"]) then
			info.text = "Edit Count ("..KARaidTrackerDB.RaidLog[raidid]["Loot"][itemid]["item"]["count"]..")";
		else
			info.text = "Edit Count";
		end
		info.value = { ["raidid"] = raidid, ["itemid"] = itemid, ["itemitemid"] = itemitemid, ["itemtime"] = itemtime, ["itemplayer"] = itemplayer };
		info.func = function()
			HideDropDownMenu(1);
			local lootid = KA_RaidTracker_GetLootId(this.value["raidid"], this.value["itemplayer"], this.value["itemitemid"], this.value["itemtime"]);
			KA_RaidTracker_EditItemCount(this.value.raidid, lootid);
		end;
		UIDropDownMenu_AddButton(info, level);
		
		info = {};
		info.text = "Edit Time";
		info.value = { ["raidid"] = raidid, ["itemid"] = itemid, ["itemitemid"] = itemitemid, ["itemtime"] = itemtime, ["itemplayer"] = itemplayer };
		info.func = function()
			HideDropDownMenu(1);
			local lootid = KA_RaidTracker_GetLootId(this.value["raidid"], this.value["itemplayer"], this.value["itemitemid"], this.value["itemtime"]);
			KA_RaidTracker_EditItemTime(this.value.raidid, lootid);
		end;
		UIDropDownMenu_AddButton(info, level);
		
		info = {};
		info.text = "Dropped from:";
		info.hasArrow = 1;
		info.value = { ["opt"] = "dropped_from_zones", ["raidid"] = raidid, ["itemid"] = itemid, ["itemitemid"] = itemitemid, ["itemtime"] = itemtime, ["itemplayer"] = itemplayer };
		if(KARaidTrackerDB.RaidLog[raidid]["Loot"][itemid]["boss"]) then
			info.text = "Dropped from: "..KARaidTrackerDB.RaidLog[raidid]["Loot"][itemid]["boss"];
			info.value["cboss"] = KARaidTrackerDB.RaidLog[raidid]["Loot"][itemid]["boss"];
			info.checked = 1;
		else
			info.text = "Dropped from: none";
		end
		UIDropDownMenu_AddButton(info, level);
		
	elseif (level == 2) then
		if(this.value) then
			if(this.value["opt"] == "dropped_from_zones") then
				for k, v in pairs(KA_RaidTracker_Bosses) do
					info = {};
					if(v == 1) then
						info.text = k;
						info.value = { ["raidid"] = this.value["raidid"], ["itemid"] = this.value["itemid"], ["zone"] = this.value["zone"], ["boss"] = k, ["itemitemid"] = this.value["itemitemid"], ["itemtime"] = this.value["itemtime"], ["itemplayer"] = this.value["itemplayer"] };
						info.func = function()
							HideDropDownMenu(1);
							KA_RaidTracker_LootSetBoss(this.value["raidid"], this.value["itemitemid"], this.value["itemtime"], this.value["itemplayer"], this.value["boss"])
						end;
						if(this.value["cboss"] == k) then
							info.checked = 1;
						end
					else
						info.text = k;
						info.hasArrow = 1;
						info.value = { ["opt"] = "dropped_from_bosses", ["raidid"] = this.value["raidid"], ["itemid"] = this.value["itemid"], ["zone"] = k, ["cboss"] = this.value["cboss"], ["itemitemid"] = this.value["itemitemid"], ["itemtime"] = this.value["itemtime"], ["itemplayer"] = this.value["itemplayer"] };
						if(this.value["cboss"]) then
							for k2, v2 in pairs(KA_RaidTracker_Bosses[k]) do
								if(this.value["cboss"] == v2) then
									info.checked = 1;
									break;
								end
							end
						end
					end
					UIDropDownMenu_AddButton(info, level);
				end
				
				info = {};
				info.text = "None";
				info.value = this.value;
				info.func = function()
					HideDropDownMenu(1);
					KA_RaidTracker_LootSetBoss(this.value["raidid"], this.value["itemitemid"], this.value["itemtime"], this.value["itemplayer"], nil)
				end;
				UIDropDownMenu_AddButton(info, level);
			elseif(this.value["opt"] == "quick_looter") then
				if(KA_RaidTracker_QuickLooter and getn(KA_RaidTracker_QuickLooter) >= 1) then
					for k, v in pairs(KA_RaidTracker_QuickLooter) do
						info = {};
						info.text = v;
						info.value = { ["raidid"] = this.value["raidid"], ["itemid"] = this.value["itemid"], ["itemitemid"] = this.value["itemitemid"], ["itemtime"] = this.value["itemtime"], ["itemplayer"] = this.value["itemplayer"], ["player"] = v, ["cplayer"] = this.value["cplayer"] };
						info.func = function()
							HideDropDownMenu(1);
							KA_RaidTracker_LootSetLooter(this.value["raidid"], this.value["itemitemid"], this.value["itemtime"], this.value["itemplayer"], this.value["player"]);
						end;
						if(this.value["cplayer"] == v) then
							info.checked = 1;
						end
						UIDropDownMenu_AddButton(info, level);
					end
					info = {};
					info.disabled = 1;
					UIDropDownMenu_AddButton(info, level);
				end
				
				PlayerGroups = KA_RaidTracker_GetPlayerGroups(this.value["raidid"]);
				for k, v in pairs(PlayerGroups) do
					info = {};
					info.text = PlayerGroupsIndexes[k];
					info.hasArrow = 1;
					info.value = { ["opt"] = "quick_looter_subplayers", ["raidid"] = this.value["raidid"], ["itemid"] = this.value["itemid"], ["playergroupsindex"] = k, ["itemitemid"] = this.value["itemitemid"], ["itemtime"] = this.value["itemtime"], ["itemplayer"] = this.value["itemplayer"], ["players"] = v, ["cplayer"] = this.value["cplayer"] };
					for k2, v2 in pairs(v) do
						if(this.value["cplayer"] == v2) then
							info.checked = 1;
							break;
						end
					end
					UIDropDownMenu_AddButton(info, level);
				end
			end
		end
	elseif (level == 3) then
		if(this.value) then
			if(this.value["opt"] == "dropped_from_bosses") then
				for k, v in pairs(KA_RaidTracker_Bosses[this.value["zone"]]) do
					if (type(v) == "table") then
						for k2, v2 in pairs(v) do
							info = {};
							info.text = k..' - '..v2;
							info.value = { ["raidid"] = this.value["raidid"], ["itemid"] = this.value["itemid"], ["zone"] = this.value["zone"], ["itemitemid"] = this.value["itemitemid"], ["itemtime"] = this.value["itemtime"], ["itemplayer"] = this.value["itemplayer"], ["boss"] = v2 };
							info.func = function()
								HideDropDownMenu(1);
								KA_RaidTracker_LootSetBoss(this.value["raidid"], this.value["itemitemid"], this.value["itemtime"], this.value["itemplayer"], this.value["boss"])
							end;
							if(this.value["cboss"] == v) then
								info.checked = 1;
							end
							UIDropDownMenu_AddButton(info, level);
						end;
					else
						info = {};
						info.text = v;
						info.value = { ["raidid"] = this.value["raidid"], ["itemid"] = this.value["itemid"], ["zone"] = this.value["zone"], ["itemitemid"] = this.value["itemitemid"], ["itemtime"] = this.value["itemtime"], ["itemplayer"] = this.value["itemplayer"], ["boss"] = v };
						info.func = function()
							HideDropDownMenu(1);
							KA_RaidTracker_LootSetBoss(this.value["raidid"], this.value["itemitemid"], this.value["itemtime"], this.value["itemplayer"], this.value["boss"])
						end;
						if(this.value["cboss"] == v) then
							info.checked = 1;
						end
						UIDropDownMenu_AddButton(info, level);
					end;
				end
			elseif(this.value["opt"] == "quick_looter_subplayers") then
				for k, v in pairs(this.value["players"]) do
					info = {};
					info.text = v;
					info.value = { ["raidid"] = this.value["raidid"], ["itemid"] = this.value["itemid"], ["itemitemid"] = this.value["itemitemid"], ["itemtime"] = this.value["itemtime"], ["itemplayer"] = this.value["itemplayer"], ["player"] = v };
					info.func = function()
						HideDropDownMenu(1);
						KA_RaidTracker_LootSetLooter(this.value["raidid"], this.value["itemitemid"], this.value["itemtime"], this.value["itemplayer"], this.value["player"]);
					end;
					if(KARaidTrackerDB.RaidLog[this.value["raidid"]]["Loot"][this.value["itemid"]]["player"] == v) then
						info.checked = 1;
					end
					UIDropDownMenu_AddButton(info, level);
				end
			end
		end
	end
end

function KA_RaidTracker_ItemsRightClickMenu_Toggle()
	local menu = getglobal(this:GetParent():GetName().."RightClickMenu");
	menu.point = "TOPLEFT";
	menu.relativePoint = "BOTTOMLEFT";
	ToggleDropDownMenu(1, nil, menu, "cursor", 0, 0);
end

function KA_RaidTracker_RaidsRightClickMenu_Initialize(level)
	if(not level) then
		return;
	end
	local raidid, itemid = 0, 0;
	local dropdown, info;
	if ( UIDROPDOWNMENU_OPEN_MENU ) then
		dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU);
	else
		dropdown = this;
	end
	
	if (level == 1) then
		raidid = this:GetID() + FauxScrollFrame_GetOffset(KA_RaidTrackerListScrollFrame);
		
		info = {};
		if ( KARaidTrackerDB.RaidLog[raidid]["key"] ) then
			info.text = "Edit Start ("..KARaidTrackerDB.RaidLog[raidid]["key"]..")";
		else
			info.text = "Edit Start";
		end
		info.value = { ["raidid"] = raidid, ["what"] = "raidstart"};
		info.func = function()
			HideDropDownMenu(1);
			KA_RaidTracker_EditTime(this.value["raidid"], this.value["what"]);
		end;
		UIDropDownMenu_AddButton(info, level);
		
		info = {};
		if ( KARaidTrackerDB.RaidLog[raidid]["End"] ) then
			info.text = "Edit End ("..KARaidTrackerDB.RaidLog[raidid]["End"]..")";
		else
			info.text = "Edit End";
		end
		info.value = { ["raidid"] = raidid, ["what"] = "raidend"};
		info.func = function()
			HideDropDownMenu(1);
			KA_RaidTracker_EditTime(this.value["raidid"], this.value["what"]);
		end;
		UIDropDownMenu_AddButton(info, level);
		
		info = {};
		if ( KARaidTrackerDB.RaidLog[raidid]["zone"] ) then
			info.text = "Edit Zone ("..KARaidTrackerDB.RaidLog[raidid]["zone"]..")";
		else
			info.text = "Edit Zone";
		end
		info.hasArrow = 1;
		info.value = { ["opt"] = "raid_zones", ["raidid"] = raidid};
		info.func = function()
			HideDropDownMenu(1);
			KA_RaidTracker_EditZone(this.value["raidid"]);
		end;
		if ( KARaidTrackerDB.RaidLog[raidid]["zone"] ) then
			for k, v in pairs(KA_RaidTracker_Zones) do
				if(KARaidTrackerDB.RaidLog[raidid]["zone"] and KARaidTrackerDB.RaidLog[raidid]["zone"] == v) then
					info.checked = 1;
					break;
				end
			end
		end
		UIDropDownMenu_AddButton(info, level);
		
		info = {};
		if ( KARaidTrackerDB.RaidLog[raidid]["note"] ) then
			info.text = "Edit Note ("..KARaidTrackerDB.RaidLog[raidid]["note"]..")";
		else
			info.text = "Edit Note";
		end
		info.value = { ["raidid"] = raidid};
		info.func = function()
			HideDropDownMenu(1);
			--KA_RaidTracker_EditNote(this.value["raidid"], "raidnote")
			KA_RaidTracker_EditRaidNote(this.value["raidid"]);
		end;
		UIDropDownMenu_AddButton(info, level);
		
		info = {};
		info.text = "Show DKP String";
		info.value = { ["raidid"] = raidid};
		info.func = function()
			HideDropDownMenu(1);
			KA_RaidTrackerGenerateDkpLink(this.value["raidid"]);
		end;
		UIDropDownMenu_AddButton(info, level);
	elseif (level == 2) then
		if(this.value) then
			if(this.value["opt"] == "raid_zones") then
				for k, v in pairs(KA_RaidTracker_Zones) do
					info = {};
					info.text = v;
					info.value = { ["raidid"] = this.value["raidid"], ["zone"] = v};
					info.func = function()
						HideDropDownMenu(1);
						KA_RaidTracker_RaidSetZone(this.value["raidid"], this.value["zone"]);
					end;
					if(KARaidTrackerDB.RaidLog[this.value["raidid"]]["zone"] == v) then
						info.checked = 1;
					end
					UIDropDownMenu_AddButton(info, level);
				end
				
				info = {};
				info.text = "None";
				info.value = { ["raidid"] = this.value["raidid"]};
				info.func = function()
					HideDropDownMenu(1);
					KA_RaidTracker_RaidSetZone(this.value["raidid"], nil);
				end;
				UIDropDownMenu_AddButton(info, level);
				
				local KA_RaidTracker_CustomZoneTriggersSpacer = false;
					
				for k, v in pairs(KARaidTrackerDB.CustomZoneTriggers) do
					if(not KA_RaidTracker_CustomZoneTriggersSpacer) then
						info = {};
						info.disabled = 1;
						UIDropDownMenu_AddButton(info, level);
						KA_RaidTracker_CustomZoneTriggersSpacer = true;
					end
					info = {};
					info.text = v;
					info.value = { ["raidid"] = this.value["raidid"], ["zone"] = v};
					info.func = function()
						HideDropDownMenu(1);
						KA_RaidTracker_RaidSetZone(this.value["raidid"], this.value["zone"]);
					end;
					if(KARaidTrackerDB.RaidLog[this.value["raidid"]]["zone"] == v) then
						info.checked = 1;
					end
					UIDropDownMenu_AddButton(info, level);
				end
			end
		end
	end
end

function KA_RaidTracker_RaidsRightClickMenu_Toggle()
	local menu = getglobal(this:GetName().."RightClickMenu");
	menu.point = "TOPLEFT";
	menu.relativePoint = "BOTTOMLEFT";
	ToggleDropDownMenu(1, nil, menu, "cursor", 0, 0);
end

function KA_RaidTracker_ConvertGlobalString(globalString)
	-- Stolen from nurfed (and fixed for german clients)
	globalString = string.gsub(globalString, "%%%d%$", "%%"); 
	globalString = string.gsub(globalString, "%%s", "(.+)");
	globalString = string.gsub(globalString, "%%d", "(%%d+)");
	return globalString;
end

function KA_RaidTracker_JoinLeaveSave()
    local player_name = KA_RaidTrackerJoinLeaveFrameNameEB:GetText();
	local player_note = KA_RaidTrackerJoinLeaveFrameNoteEB:GetText();
	local player_time = KA_RaidTrackerJoinLeaveFrameTimeEB:GetText();
	
	if(player_name == nil or strlen(player_name) == 0) then
	    KA_RaidTracker_Print("KA_RaidTracker Join/Leave: No player", 1, 1, 0);
	    return nil;
	end
	if(not string.find(player_time, "^(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)$")) then
	    KA_RaidTracker_Print("KA_RaidTracker Join/Leave: Invalid Time format", 1, 1, 0);
	    return nil;
    end
	
    if((strlen(player_name) > 0)) then
        local sDate = KA_RaidTracker_Date();
        KARaidTrackerUtility:Debug("KA_RaidTracker_JoinLeave", player_name, player_note);
        if (KA_RaidTrackerJoinLeaveFrame.type == "Join") then 
            tinsert(KARaidTrackerDB.RaidLog[KA_RaidTrackerJoinLeaveFrame.raidid]["Join"],
            {
               ["player"] = player_name,
               ["time"] = player_time
            }
            );
            KARaidTrackerDB.Online[player_name] = 1;
            KA_RaidTracker_Print(player_name.." manually joined at "..player_time, 1, 1, 0);
        elseif (KA_RaidTrackerJoinLeaveFrame.type == "Leave") then
            tinsert(KARaidTrackerDB.RaidLog[KA_RaidTrackerJoinLeaveFrame.raidid]["Leave"],
            {
               ["player"] = player_name,
               ["time"] = player_time
            }
            );
            KARaidTrackerDB.Online[player_name] = nil;
            KA_RaidTracker_Print(player_name.." manually left at "..player_time, 1, 1, 0);
        end
        if(strlen(player_note) > 0) then
            if( not KARaidTrackerDB.RaidLog[KA_RaidTrackerJoinLeaveFrame.raidid]["PlayerInfos"][player_name]) then
	            KARaidTrackerDB.RaidLog[KA_RaidTrackerJoinLeaveFrame.raidid]["PlayerInfos"][player_name] = {};
            end
            KARaidTrackerDB.RaidLog[KA_RaidTrackerJoinLeaveFrame.raidid]["PlayerInfos"][player_name]["note"] = player_note;
        end
        KA_RaidTracker_Update();
        KA_RaidTracker_UpdateView();
    end
end


-- Next Boss selection handling

function KA_RaidTracker_Boss_InitWindow()
	UIDropDownMenu_Initialize(KA_RaidTrackerNextBossFrameBossDropdown, KA_RaidTracker_Boss_Init);
end;

function KA_RaidTracker_Boss_Init()
	local i = 0;
	local ii = 0;
	if (KARaidTrackerDB.Options["CurrentRaid"] == nil) then
		return;
	end;

	i = KA_RaidTracker_Boss_Add_Button(KA_RaidTracker_BossUnitTriggers["DEFAULTBOSS"],i);
	ii = ii + 1;
	if (KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["zone"] == nil) then
		for k,v in pairs(KA_RaidTracker_Bosses) do
				KARaidTrackerUtility:Debug(k,v);
			if (v == 1) then
				ii = ii + 1;
				for k2,v2 in pairs(KA_RaidTracker_BossUnitTriggers) do
					if (v2 == v) then
						i = KA_RaidTracker_Boss_Add_Button(k2,i);
					end;
				end;
			end;
		end
	else
		for k,v in pairs(KA_RaidTracker_Bosses[KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["zone"]]) do
			local addit = true;
			for k2,v2 in pairs(KARaidTrackerDB.RaidLog[KARaidTrackerDB.Options["CurrentRaid"]]["BossKills"]) do
				if (v2["boss"] == v) then
					addit = false;
				end;
			end;
			if (addit == true) then
				if (type(v) == "table") then
					for k2,v2 in pairs(v) do
						ii = ii + 1;
						for k3,v3 in pairs(KA_RaidTracker_BossUnitTriggers) do
							if (v3 == v2) then
								i = KA_RaidTracker_Boss_Add_Button(k..' - '..k3,i);
							end;
						end;
					end;
				else
					ii = ii + 1;
					for k2,v2 in pairs(KA_RaidTracker_BossUnitTriggers) do
						if (v2 == v) then
							i = KA_RaidTracker_Boss_Add_Button(k2,i);
						end;
					end;
				end;
			end;
		end
	end;
	if (ii == 2) then
		UIDropDownMenu_SetSelectedID(KA_RaidTrackerNextBossFrameBossDropdown, ii);
	end;
end;

function KA_RaidTracker_Boss_Add_Button(k,i)
	local info = {
		text = k;
		func = KA_RaidTracker_Boss_Update;
	};
	UIDropDownMenu_AddButton(info);
	if (i == cur_class_id) then
		UIDropDownMenu_SetSelectedID(KA_RaidTrackerNextBossFrameBossDropdown, i+1);
		UIDropDownMenu_SetText(info.text, KA_RaidTrackerNextBossFrameBossDropdown);
	end
	return i
end;

function KA_RaidTracker_Boss_Update()
	i = this:GetID();
	UIDropDownMenu_SetSelectedID(KA_RaidTrackerNextBossFrameBossDropdown, i);
end;



