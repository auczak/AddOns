--[[
	Persistent Data for RaidTracker, Saved Variables	
]]


--***********************************************************************************
-- Saved Variables

KARaidTrackerData:RegisterDB( "KARaidTrackerDB", {
	Options = {
		AutoRaidCreation = 1,           -- on/off
		AutoBoss = 1,                   -- 0,1,2
		AutoBossBoss = "Trash mob",     -- just the name of the boss
		AutoBossChangeMinTime = 120,    -- how long should trash mob's ignored after a boss kill (seconds)?
		AutoZone = 1,                   -- on/off
		AskCost = 0,                    -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact, asks for cost for items with at least this rarity
		DkpValue = 0,                	-- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact
		DebugFlag = nil,                -- on/off
		GroupItems = 3,                 -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact
		GuildSnapshot = 1,              -- Snapshots the guildroster on bosskill
		LogAttendees = 1,               -- 0:off, 1:for each looted item, 2:for each bosskill
		MaxLevel = 70,                  -- If player lvl is maxlevel it will not be exported to mldkp
		MinQuality = 3,                 -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact
		NextBoss = 0,                   -- ask on boss kill whats the next boss is
		SaveExtendedPlayerInfo = 1,     -- on/off - save race, class and level  
		SaveTooltips = 1,               -- on/off - save tooltips of items
		TimeFormat = 1,                 -- on/off - Use 24h time format
		Timezone = 0,
		TimeSync = 1,
		Wipe = 0,                       -- ask if the group dies if it is a wipe, if all are dead it will not ask
		WipePercent = 0.5,              -- how many prozent of group must be dead to ask
		WipeCoolDown = 150,             -- how long should death be ignored after a wipe count (seconds)
		-- ML_RaidTracker_Custom_Options
		AutoGroup = 1,
		ExportFormat = 2,               -- ExportFormat for the xml string
		GuildSnapshot = 0,
		LogGroup = 1,
		LogBattlefield = 0,
		-- Internal flags
		VersionFix = 8,                 -- Flag to determine current database version for saved variables
		VersionCopy = 0,                -- Flag to determine current database version for saved variables
		TimeOffsetStatus = 0,           -- ???
		ItemOptionsSelected = nil,      -- ???
		CurrentRaid = nil,
	},	
    SortOptions = {
        method = "name",
        way = "asc",
        itemmethod = "looted",
        itemway = "asc",
        itemfilter = 1,
        playerraidway = "desc",
        playeritemfilter = 1,
        playeritemmethod = "name",
        playeritemway = "asc",
        itemhistorymethod = "name",
        itemhistoryway = "asc",
    },
    ItemOptions = { },
    CustomZoneTriggers = { },
    Online = { },
    RaidLog = { },
});



function KARaidTrackerData:RunVersionFix( )
    local util = KARaidTrackerUtility
	local db = self._store.db;

    local debugflagpre = db.Options.DebugFlag;
    --self.db.Options.DebugFlag = 1;  
    
    if(db.Options.VersionCopy == 0) then
    	DEFAULT_CHAT_FRAME:AddMessage("RaidTracker: Importing CT database start.", 1, 0.5, 0)
         
    	self:ImportToDB( "Options", _G, "CT_RaidTracker_", false, { 
			"VersionFix",CurrentRaid="GetCurrentRaid","MinQuality","AutoRaidCreation","GroupItems",DkpValue="GetDkpValue","OldFormat",
			"AutoBoss","AutoBossBoss","AutoZone","AskCosts","Timezone","TimeSync","DebugFlag" } );    	        
    	self:ImportToDB( nil, _G, "CT_RaidTracker_", true, {"Options","ItemOptions","SortOptions"} );
    	self:ImportToDB( nil, _G, "CT_RaidTracker_", false, {"RaidLog","CustomZoneTriggers","Online"} );

    	DEFAULT_CHAT_FRAME:AddMessage("RaidTracker: Importing CT database end.", 1, 0.5, 0)
	    db.Options.VersionCopy = 1;
    end
	    
	local opts = db.Options;
    local raidLog = db.RaidLog;
    
    if(opts.VersionFix == 0) then
        util:Debug("VersionFix", 1);
        for k, v in pairs(raidLog) do
            if(not raidLog[k]["PlayerInfos"]) then
                raidLog[k]["PlayerInfos"] = { };
            end
            if ( v["Notes"] ) then
                for notesk, notesv in pairs(v["Notes"]) do
                    if(not raidLog[k]["PlayerInfos"][notesk]) then
                        raidLog[k]["PlayerInfos"][notesk] = { };
                    end
                    raidLog[k]["PlayerInfos"][notesk]["note"] = notesv;
                    util:Debug("VersionFix", 1, "note", k, notesk, notesv);
                end
                raidLog[k]["Notes"] = nil;
            end
        end
        opts.VersionFix = 1;
    end
    if(opts.VersionFix == 1) then
        util:Debug("VersionFix", 2);
        opts.VersionFix = 2; -- Do not remove tooltips any longer
    end
    if(opts.VersionFix == 2) then
        util:Debug("VersionFix", 3);        
        for k, v in pairs(raidLog) do
            if(raidLog[k]["BossKills"] and getn(raidLog[k]["BossKills"]) >= 1 and not raidLog[k]["BossKills"][1]) then
                local tempbosskills = {};
                for k2, v2 in pairs(raidLog[k]["BossKills"]) do
                    tempbosskills[k2] = v2;
                end
                raidLog[k]["BossKills"] = {};
                for k2, v2 in pairs(tempbosskills) do
                    tinsert(raidLog[k]["BossKills"],
                        {
                            ["boss"] = k2,
                            ["time"] = v2,
                            ["attendees"] = {}
                        }
                    );
                    util:Debug("VersionFix", 3, "BossKills", k, k2);
                end
            end
        end
        opts.VersionFix = 3;
    end
    if(opts.VersionFix == 3) then
        util:Debug("VersionFix", 4);
        for k, v in pairs(raidLog) do
            if(raidLog[k]["BossKills"]) then
                for k2, v2 in pairs(raidLog[k]["BossKills"]) do
                    if(type(v2["time"]) == "table") then
                        util:Debug("VersionFix", 4, "BossKills Fix", k, k2, v2["time"]["boss"], v2["time"]["time"]);
                        raidLog[k]["BossKills"][k2]["boss"] = v2["time"]["boss"];
                        raidLog[k]["BossKills"][k2]["attendees"] = v2["time"]["attendees"];
                        raidLog[k]["BossKills"][k2]["time"] = v2["time"]["time"];
                    end
                end
            end
        end
        opts.VersionFix = 4;
    end
    if(opts.VersionFix == 4) then
        opts.Wipe = 1;                     -- ask if the group dies if it is a wipe, if all are dead it will not ask
        opts.WipePercent = 0.5;            -- how many prozent of group must be dead to ask
        opts.NextBoss = 1;                 -- ask on boss kill whats the next boss is
        
        opts.VersionFix = 5;
    end
    if (opts.VersionFix == 5) then
        opts.MLdkp = 1;                     -- Export für mldkp
        
        opts.VersionFix = 6;
    end;
    if (opts.VersionFix == 6) then
        if (opts.MLdkp and opts.MLdkp == 1) then
            opts.ExportFormat = 2;
        else
            if (opts.OldFormat and opts.OldFormat == 1) then
                opts.ExportFormat = 0;
            else
                opts.ExportFormat = 1;
            end;
        end;
        opts.MLdkp = nil;
        opts.OldFormat = nil;

        opts.VersionFix = 7;
    end;
--	Post CT RaidTracker fixes 
    if (opts.VersionFix == 7) then    	
    	if (opts["24hFormat"]) then	opts.TimeFormat = opts["24hFormat"]; opts["24hFormat"] = nil; end
		if (opts["GetCurrentRaid"]) then opts.CurrentRaid = opts["GetCurrentRaid"]; opts["GetCurrentRaid"] = nil; end
		if (opts["GetDkpValue"]) then opts.DkpValue = opts["GetDkpValue"]; opts["GetDkpValue"] = nil; end
		
        opts.VersionFix = 8;
--		KA_RaidTrackerOptionsFrame:Show();
    end;
    
    opts.DebugFlag = debugflagpre;
 end


