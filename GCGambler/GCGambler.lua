-- GCGambler by Myrx and Triumvirate of <Gentlemens Club> Korgath US

-- Version 0.2
-- (Myrx) Fixed a bug where minimum roll value was not being checked
-- (Myrx) Fixed a bug where you could start a game of 1-1
-- (Myrx) Added logic to prompt for tiebreakers
-- (TODO) Every player ties

-- Version 0.1
-- Initial release version

local GCGambler = {
		["active"] = 1, 
		["strings"] = { },
		["lowtie"] = { },
		["hightie"] = { }}
local AcceptOnes = "false"
local AcceptRolls = "false"
local totalrolls = 0
local tierolls = 0;
local theMax
local lowname = ""
local highname = ""
local low = 0
local high = 0
local tie = 0
local highbreak = 0;
local lowbreak = 0;
local tiehigh = 0;
local tielow = 0;

function GCGambler_OnLoad()
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00<Gentlemens Club Gambler> loaded /gcg to use");
	if GCGambler.active == nil then
	GCGambler_Reset();
	end
	GCGambler_Frame:Hide();
	GCGambler_Frame:CreateTitleRegion();
	this:RegisterEvent("CHAT_MSG_RAID");
	this:RegisterEvent("CHAT_MSG_RAID_LEADER");
	this:RegisterEvent("CHAT_MSG_SYSTEM");
	this:RegisterForDrag("LeftButton");
	GCGambler_ROLL_Button:Disable();
	GCGambler_AcceptOnes_Button:Enable();		
	GCGambler_LASTCALL_Button:Disable();
end

function GCGambler_OnEvent()
	if ((event == "CHAT_MSG_RAID_LEADER" or event == "CHAT_MSG_RAID")and AcceptOnes=="true") then
		if (tonumber(tostring(arg1),10) == 1) then
			GCGambler_Add(tostring(arg2));
			if (GCGambler_LASTCALL_Button:IsEnabled() == 0 and totalrolls == 1) then
				GCGambler_LASTCALL_Button:Enable();
			end
			if totalrolls == 2 then
				GCGambler_AcceptOnes_Button:Disable();
				GCGambler_AcceptOnes_Button:SetText("Accept Ones");
			end
			--SendChatMessage(format("%s%s%s","[GCG] ", tostring(arg2), " Pressed 1"),"CHANNEL",GetDefaultLanguage("player"),"6");
		end
	end
	AcceptRolls = "true"
	if (event == "CHAT_MSG_SYSTEM" and AcceptRolls=="true") then
		local temp1 = tostring(arg1);

		GCGambler_ParseRoll(temp1);		
	end	
end

function GCGambler_OnClickROLL()
	if (totalrolls >1) then
		if (AcceptRolls == "true") then				
			if table.getn(GCGambler.strings) ~= 0 then
				--if tie == 0 then
					GCGambler_List();
				--end
			end	
			return;
		end
		AcceptOnes = "false";
		AcceptRolls = "true";
		if (tie == 0) then
			SendChatMessage("[GCG] Roll now!","RAID",GetDefaultLanguage("player"));
		end
		if (lowbreak == 1) then
			SendChatMessage(format("%s%d%s", "[GCG] Low end tiebreaker! Roll 1-", theMax, " now!"),"RAID",GetDefaultLanguage("player"));
			GCGambler_List();
		end
		if (highbreak == 1) then
			SendChatMessage(format("%s%d%s", "[GCG] High end tiebreaker! Roll 1-", theMax, " now!"),"RAID",GetDefaultLanguage("player"));
			GCGambler_List();
		end
		GCGambler_EditBox:ClearFocus();
	end
	if (totalrolls <2) then
		SendChatMessage("[GCG] Not enough Players!","RAID",GetDefaultLanguage("player"));
	end
end

function GCGambler_OnClickLASTCALL()
	SendChatMessage("[GCG] Last Call","RAID",GetDefaultLanguage("player"));
	GCGambler_EditBox:ClearFocus();
	GCGambler_LASTCALL_Button:Disable();
	GCGambler_ROLL_Button:Enable();
end

function GCGambler_OnClickACCEPTONES() 
	if GCGambler_EditBox:GetText() ~= "" and GCGambler_EditBox:GetText() ~= "1" then
		GCGambler_Reset();
		GCGambler_ROLL_Button:Disable();
		GCGambler_LASTCALL_Button:Disable();
		AcceptOnes = "true";		
		SendChatMessage(format("%s%s%s", "[GCG] Roll 1-", GCGambler_EditBox:GetText(), " Press 1"),"RAID",GetDefaultLanguage("player"));
		theMax = tonumber(GCGambler_EditBox:GetText()); 
		low = theMax+1;
		tielow = theMax+1;
		GCGambler_EditBox:ClearFocus();
		GCGambler_AcceptOnes_Button:SetText("New Game");
		GCGambler_LASTCALL_Button:Disable();	
	else
		message("Please enter a number to roll from.");
	end
end

function GCGambler_Report()
	local goldowed = high - low
	lowname = lowname:gsub("^%l", string.upper)
	highname = highname:gsub("^%l", string.upper)
	local string3 = strjoin(" ", "[GCG]", lowname, "owes", highname, goldowed,"gold.")
	SendChatMessage(string3,"RAID",GetDefaultLanguage("player"));
	GCGambler_Reset();
	GCGambler_AcceptOnes_Button:SetText("Accept Ones");
end

function GCGambler_Tiebreaker()
	--Everyone has rolled at this point
	tierolls = 0;
	totalrolls = 0;
	tie = 1;
	if table.getn(GCGambler.lowtie) == 1 then
		GCGambler.lowtie = {};
	end
	if table.getn(GCGambler.hightie) == 1 then
		GCGambler.hightie = {};
	end
	totalrolls = table.getn(GCGambler.lowtie) + table.getn(GCGambler.hightie);
	tierolls = totalrolls;
	if (table.getn(GCGambler.hightie) == 0 and table.getn(GCGambler.lowtie) == 0) then
		GCGambler_Report();
	else
		AcceptRolls = "false";
		if table.getn(GCGambler.lowtie) > 0 then
			lowbreak = 1;
			highbreak = 0;
			tielow = theMax+1;
			tiehigh = 0;
			GCGambler.strings = GCGambler.lowtie;
			GCGambler.lowtie = {};
			GCGambler_OnClickROLL();			
		end
		if table.getn(GCGambler.hightie) > 0  and table.getn(GCGambler.strings) == 0 then
			lowbreak = 0;
			highbreak = 1;
			tielow = theMax+1;
			tiehigh = 0;
			GCGambler.strings = GCGambler.hightie;
			GCGambler.hightie = {};
			GCGambler_OnClickROLL();
		end
	end
end

function GCGambler_ParseRoll(temp2)
	local temp1 = strlower(temp2);
	temp3 = temp2
	
	local player1, junk1, roll1, range1 = strsplit(" ", temp3);
	if junk1 == "rolls"
		EPGP:Print("roll registered");
		EPGP:Print(player1);
		local ep, gp = EPGP:GetModule("EPGP_Cache"):GetMemberEPGP(player1)
		EPGP:Print("player: %s, ep: %d, pr: %d, roll: %d", player1, ep, gp,roll1);
	end
	
	local player, junk, roll, range = strsplit(" ", temp1);
	if junk == "rolls" and GCGambler_Check(player)==1 then
		minRoll, maxRoll = strsplit("-",range);
		minRoll = tonumber(strsub(minRoll,2));
		maxRoll = tonumber(strsub(maxRoll,1,-2));
		roll = tonumber(roll);
		
		if (maxRoll == theMax and minRoll == 1) then
			if (tie == 0) then
				if (roll == high) then
					if table.getn(GCGambler.hightie) == 0 then
						GCGambler_AddTie(highname, GCGambler.hightie);
					end
					GCGambler_AddTie(player, GCGambler.hightie);
				end
				if (roll>high) then
					highname = player
					high = roll
					GCGambler.hightie = {};
					--GCGambler_AddTie(player, GCGambler.hightie);				
				end
				if (roll == low) then
					if table.getn(GCGambler.lowtie) == 0 then
						GCGambler_AddTie(lowname, GCGambler.lowtie);
					end
					GCGambler_AddTie(player, GCGambler.lowtie);
				end
				if (roll<low) then 
					lowname = player
					low = roll
					GCGambler.lowtie = {};				
					--GCGambler_AddTie(player, GCGambler.lowtie);				
				end
			else
				if (lowbreak == 1) then
					if (roll == tielow) then
						if table.getn(GCGambler.lowtie) == 0 then
							GCGambler_AddTie(lowname, GCGambler.lowtie);
						end
						GCGambler_AddTie(player, GCGambler.lowtie);
					end
					if (roll<tielow) then 
						lowname = player
						tielow = roll;
						GCGambler.lowtie = {};				
						--GCGambler_AddTie(player, GCGambler.lowtie);				
					end
				end
				if (highbreak == 1) then
					if (roll == tiehigh) then
						if table.getn(GCGambler.hightie) == 0 then
							GCGambler_AddTie(highname, GCGambler.hightie);
						end
						GCGambler_AddTie(player, GCGambler.hightie);
					end
					if (roll>tiehigh) then
						highname = player
						tiehigh = roll;
						GCGambler.hightie = {};
						--GCGambler_AddTie(player, GCGambler.hightie);				
					end
				end
			end
			GCGambler_Remove(tostring(player));
			if table.getn(GCGambler.strings) == 0 then
				if tierolls == 0 then
					GCGambler_Report();
				else
					GCGambler_Tiebreaker();
				end
			end
		end	
	end
end

function GCGambler_Check(player)
	for i=1, table.getn(GCGambler.strings) do
		if strlower(GCGambler.strings[i]) == tostring(player) then
			return 1
		end
	end
	return 0
end

function GCGambler_List()
	for i=1, table.getn(GCGambler.strings) do
	  	local string3 = strjoin(" ", "[GCG]", tostring(GCGambler.strings[i]):gsub("^%l", string.upper),"still needs to roll.")
		SendChatMessage(string3,"RAID",GetDefaultLanguage("player"));
	end
end

function GCGambler_Add(name)
	if (name ~= nil or name ~= "") then
		local found = 0;
		for i=1, table.getn(GCGambler.strings) do
		  	if GCGambler.strings[i] == name then
			found = 1;
			--local string3 = strjoin(" ", "[GCG]", tostring(name),"was already found in the database.")
			--SendChatMessage(string3,"CHANNEL",GetDefaultLanguage("player"),"6");
			end
        	end
		if found == 0 then
		      	table.insert(GCGambler.strings, name)
			totalrolls = totalrolls+1
			--local string3 = strjoin(" ", "[GCG]", GCGambler.strings[table.getn(GCGambler.strings)],"has been added to the database.")
			--SendChatMessage(string3,"CHANNEL",GetDefaultLanguage("player"),"6");
		end
	end
end

function GCGambler_AddTie(name, tietable)
	if (name ~= nil or name ~= "") then
		local found = 0;
		for i=1, table.getn(tietable) do
		  	if tietable[i] == name then
			found = 1;
			--local string3 = strjoin(" ", "[GCG]", tostring(name),"was already found in the database.")
			--SendChatMessage(string3,"CHANNEL",GetDefaultLanguage("player"),"6");
			end
        	end
		if found == 0 then
		    table.insert(tietable, name)
			tierolls = tierolls+1	
			totalrolls = totalrolls+1		
			--local string3 = strjoin(" ", "[GCG]", tostring(name),"was already found in the database.")
			--SendChatMessage(string3,"CHANNEL",GetDefaultLanguage("player"),"6");
		end
	end
end

function GCGambler_Remove(name)
	for i=1, table.getn(GCGambler.strings) do
		if GCGambler.strings[i] ~= nil then
		  	if strlower(GCGambler.strings[i]) == name then
				table.remove(GCGambler.strings, i)
				--local string3 = strjoin(" ", "[GCG]", tostring(name),"has been removed from database.")
				--SendChatMessage(string3,"CHANNEL",GetDefaultLanguage("player"),"6");
			end
		end
      end
end

function GCGambler_RemoveTie(name, tietable)
	for i=1, table.getn(tietable) do
		if tietable[i] ~= nil then
		  	if strlower(tietable[i]) == name then
				table.remove(tietable, i)
				--local string3 = strjoin(" ", "[GCG]", tostring(name),"has been removed from database.")
				--SendChatMessage(string3,"CHANNEL",GetDefaultLanguage("player"),"6");
			end
		end
      end
end

function GCGambler_Reset()
	  	GCGambler = {
		["active"] = 1, 
		["strings"] = { },
		["lowtie"] = { },
		["hightie"] = { }}
		AcceptOnes = "false"
		AcceptRolls = "false"
		totalrolls = 0
		theMax = 0
		tierolls = 0;
		lowname = ""
		highname = ""
		low = theMax
		high = 0
		tie = 0
		highbreak = 0;
		lowbreak = 0;
		tiehigh = 0;
		tielow = 0;
		GCGambler_ROLL_Button:Disable();
		GCGambler_AcceptOnes_Button:Enable();		
		GCGambler_LASTCALL_Button:Disable();
end

function GCGambler_EditBox_OnLoad()
	GCGambler_EditBox:SetNumeric("true");
	GCGambler_EditBox:SetAutoFocus("false");
	GCGambler_EditBox:SetText("100");
end

function GCGambler_SlashCmd(msg)
	local msg = msg:lower()
	local msgPrint = 0;
	if (msg == "" or msg == nil) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Following commands for /gcg:");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00show - Shows the frame");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00hide - Hides the frame");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00reset - Resets the AddOn");
		msgPrint = 1;
	end
	if (msg == "hide") then
		GCGambler_Frame:Hide();
		msgPrint = 1;
	end
	if (msg == "show") then
		GCGambler_Frame:Show();
		msgPrint = 1;
	end
	if (msg == "reset") then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00GCG has now been reset");
		GCGambler_Reset();
		GCGambler_AcceptOnes_Button:SetText("Accept Ones");
		msgPrint = 1;		
	end
	if (msgPrint == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Invalid argument for command /gcg");
	end
end

SLASH_GCGAMBLER1 = "/gambler";
SLASH_GCGAMBLER2 = "/gcg";
SLASH_GCGAMBLER3 = "/rollgame";
SLASH_GCGAMBLER4 = "/GCGambler";
SlashCmdList["GCGAMBLER"] = GCGambler_SlashCmd