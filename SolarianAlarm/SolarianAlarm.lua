
local test = false
local vcnt = 0
local tout = 0
local user = {}
local utime = 0

---------------------------------------
--- Helper Functions ------------------
---------------------------------------

local function AddMsg(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end

---------------------------------------

local function SaveAllNames()
	local num,i,name
	user = {}

	num = GetNumRaidMembers()
	if (num>0) then
		for i = 1, num do
			name = UnitName("raid" .. i)
			tinsert(user,name)
		end
		return
	end
	
	num = GetNumPartyMembers()
	if (num>0) then
		name = UnitName("player")
		tinsert(user,name)
		for i = 1, num do
			name = UnitName("party" .. i)
			tinsert(user,name)
		end
		return
	end
end

---------------------------------------

local function RemoveName(name)
	local i
	for i = #user, 1, -1 do
		if (user[i] == name) then
			tremove(user,i)
			return true
		end
	end
	return false
end

---------------------------------------
--- Main Functions --------------------
---------------------------------------

function SolarianAlarm_Init()
	AddMsg(SOLALARM_GREETING)

	SLASH_SOLARIANALARM1 = "/solarianalarm"
	SLASH_SOLARIANALARM2 = "/sa"
	SlashCmdList["SOLARIANALARM"] = SolarianAlarm_SlashHandler
end

---------------------------------------

function SolarianAlarm_SlashHandler(msg)
	if (msg=="") then
		AddMsg(SOLALARM_HELP1)
		AddMsg(SOLALARM_HELP2)
		AddMsg(SOLALARM_HELP3)
		AddMsg(SOLALARM_HELP4)
	end

	if (msg=="test on") then
		test = true
		AddMsg(SOLALARM_TESTON)
	end

	if (msg=="test off") then
		test = false
		AddMsg(SOLALARM_TESTOFF)
	end

	if (msg=="version check") then
		vcnt = 0
		tout = 4
		SaveAllNames()
		AddMsg(SOLALARM_VERCHECK)
		SendAddonMessage("SolarianAlarm","VC","RAID")
	end
end

---------------------------------------

function SolarianAlarm_Msg(msg,sender)
	local prefix  = strsub(msg,1,2)
	local message = strsub(msg,3)
	
	if (prefix=="VC") then
		SendAddonMessage("SolarianAlarm","VB" .. SOLALARM_VER,"RAID")
	end

	if (prefix=="VA" or prefix=="VB") then --VA for version 1.5 and older
		if (tout>0) then
			if (RemoveName(sender)) then
				vcnt = vcnt + 1
				AddMsg(vcnt .. ": " .. sender .. " v" .. message)
			end
		end
	end
end

---------------------------------------

function SolarianAlarm_Update(sec)

	utime = utime + sec
	if (utime<0.15) then
		return
	end

	local a = false

	local i
	for i = 1,8 do
		local name = GetPlayerBuffName(GetPlayerBuff(i,"HARMFUL"))

		if (name~=nil) then
			if (strfind(name,SOLALARM_DEBUFFNAME)~=nil) then
				a = true
			end
			if (test) then
				a = true
			end
		end
	end

	if (a) then
		if not (SolarianAlarmMain:IsVisible()) then
			SolarianAlarmMain:Show()
		end
	else
		if (SolarianAlarmMain:IsVisible()) then
			SolarianAlarmMain:Hide()
		end
	end

	if (tout>0) then
		tout = tout - utime
		if (tout<=0) and (#user>0) then
			AddMsg(SOLALARM_NOSA)
			for i = 1,#user do
				AddMsg(i .. ": " .. user[i])
			end
		end
	end

	utime = 0
end
