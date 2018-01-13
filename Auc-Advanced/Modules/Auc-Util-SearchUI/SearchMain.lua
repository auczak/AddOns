--[[
	Auctioneer Advanced - Search UI
	Version: 5.0.0 (BillyGoat)
	Revision: $Id: SearchMain.lua 3534 2008-09-27 00:49:53Z RockSlice $
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds a price level indicator
	to auctions when browsing the Auction House, so that you may readily see
	which items are bargains or overpriced at a glance.

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit licence to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]

local libType, libName = "Util", "SearchUI"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()
local debugPrint = AucAdvanced.Debug.DebugPrint

local Const = AucAdvanced.Const
local gui
private.data = {}
private.sheetData = {}
private.isSearching = false
local coSearch
local SettingCache = {}

private.tleft = {
	"|cff000001|cffe5e5e530m", -- 30m
	"|cff000002|cffe5e5e52h",  --2h
	"|cff000003|cffe5e5e512h", --12h
	"|cff000004|cffe5e5e548h"  --48h
}

-- Our official name:
AucSearchUI = lib

-- lib.CleanTable(temp)
-- used to clean out a table for reuse
-- temp must be a table
function lib.CleanTable(temp)
	for i,j in pairs(temp) do
		temp[i] = nil
	end
end

function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
	if (callbackType == "config") then
		--private.SetupConfigGui(...)
		-- We don't have one of these
	elseif (callbackType == "auctionui") then
		if lib.Searchers.RealTime then
			lib.Searchers.RealTime.HookAH()
		end
		
		--we need to make sure that the GUI is made by the time the AH opens, as RealTime could be trying to add lines to it.
		if not gui then
			lib.MakeGuiConfig()
		end
	elseif (callbackType == "pagefinished") then
		if lib.Searchers.RealTime then
			lib.Searchers.RealTime.FinishedPage(...)
		end
	elseif (callbackType == "tooltip") then
		lib.ProcessTooltip(...)
	end
end

function lib.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, additional)
	if not additional or additional[0] ~= "AuctionPrices" then
		--this isn't an auction, so we're not interested
		return
	end
	if not lib.GetSetting("debug.show") then
		--we're not interested in adding debug
		return
	end
	local button = GetMouseFocus():GetParent() --Note: check that it works without CompactUI
	local id = button.id --CompactUI's layout
	if not id then
		id = button:GetID() + FauxScrollFrame_GetOffset(BrowseScrollFrame) --without CompactUI
	end
	local price = additional[3] --only thing we need from this table, as  minBid and buyout can come from GetAuctionItemInfo
	
	local name, _, count, _, canUse, level, minBid, minInc, buyout, curBid, isHigh, owner = GetAuctionItemInfo("list", id)
	local timeleft = GetAuctionItemTimeLeft("list", id)
	local _, _, _, iLevel, _, iType, iSubType, stack, iEquip = GetItemInfo(hyperlink)
	local _, itemid, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(hyperlink)
	local ItemTable = {}
	-- put the data into a table laid out the same way as the AAdv Scandata, as that's what the searchers need
	ItemTable[Const.LINK]    = hyperlink
	ItemTable[Const.ILEVEL]  = iLevel
	ItemTable[Const.ITYPE]   = iType
	ItemTable[Const.ISUB]    = iSubType
	ItemTable[Const.IEQUIP]  = iEquip
	ItemTable[Const.PRICE]   = price
	ItemTable[Const.TLEFT]   = timeleft
	ItemTable[Const.NAME]    = name
	ItemTable[Const.COUNT]   = count
	ItemTable[Const.QUALITY] = quality
	ItemTable[Const.CANUSE]  = canUse
	ItemTable[Const.ULEVEL]  = level
	ItemTable[Const.MINBID]  = minBid
	ItemTable[Const.MININC]  = minInc
	ItemTable[Const.BUYOUT]  = buyout
	ItemTable[Const.CURBID]  = curBid
	ItemTable[Const.AMHIGH]  = isHigh
	ItemTable[Const.SELLER]  = owner
	ItemTable[Const.ITEMID]  = itemid
	ItemTable[Const.SUFFIX]  = suffix
	ItemTable[Const.FACTOR]  = factor
	ItemTable[Const.ENCHANT]  = enchant
	ItemTable[Const.SEED]  = seed

	EnhTooltip.AddLine("SearchUI:")
	EnhTooltip.LineColor(1,0.7,0.3)
	local active = false
	for name, searcher in pairs(lib.Searchers) do
		if lib.GetSetting("debug."..name) then
			active = true
			local success, returnvalue, value = lib.SearchItem(name, ItemTable, true, true)
			if success then
				if value then
					EnhTooltip.AddLine("  "..name.." profit:"..math.floor(100*returnvalue/value).."%:", returnvalue)
					EnhTooltip.LineColor(1,0.7,0.3)
				elseif returnvalue then
					EnhTooltip.AddLine("  "..name.." profit:", returnvalue)
					EnhTooltip.LineColor(1,0.7,0.3)
				else
					EnhTooltip.AddLine("  "..name.." success")
					EnhTooltip.LineColor(1,0.7,0.3)
				end
			else
				EnhTooltip.AddLine("  "..name..":"..returnvalue)
				EnhTooltip.LineColor(1,0.7,0.3)
			end
		end
	end
	if not active then --if it hasn't changed, we're not enabled for any searcher
		EnhTooltip.AddLine("  No debugging enabled")
		EnhTooltip.LineColor(1,0.7,0.3)
	end
end

local function getProfileParamName()
	if (not AucAdvancedData.UtilSearchUI) then AucAdvancedData.UtilSearchUI = {} end
	local realmKey = AucAdvanced.GetFaction()
	if not realmKey then
		return
	end
	if (not AucAdvancedData.UtilSearchUI[realmKey]) then AucAdvancedData.UtilSearchUI[realmKey] = {} end
	return AucAdvancedData.UtilSearchUI[realmKey]["lastProfile"] or realmKey
end

local function getProfileParam()
	if (not AucAdvancedData.UtilSearchUI) then AucAdvancedData.UtilSearchUI = {} end
	local realmKey = AucAdvanced.GetFaction()
	if not realmKey then
		return
	end
	if (not AucAdvancedData.UtilSearchUI) then AucAdvancedData.UtilSearchUI = {} end
	local SearchUISettings = AucAdvancedData.UtilSearchUI
	local profileName = getProfileParamName()
	if (not SearchUISettings["profile."..profileName]) then
		if profileName ~= realmKey then
			profileName = realmKey
			SearchUISettings[realmKey]["lastProfile"] = realmKey
		end
		if profileName == realmKey then
			SearchUISettings["profile."..profileName] = {}
		end
	end
	return SearchUISettings["profile."..profileName]
end


local function cleanse( search )
	if (search) then
		search = {}
	end
end

-- Default setting values
local settingDefaults = {
	["searchspeed"] = 100,
	["reserve"] = 1,
	["maxprice"] = 10000000,
}

local function getDefault(setting)
	local a,b,c = strsplit(".", setting)
	local result = settingDefaults[setting];
	return result
end

function lib.GetDefault(setting)
	local val = getDefault(setting);
	return val;
end

function lib.SetDefault(setting, default)
	settingDefaults[setting] = default
end

local function setter(setting, value)
	if (not AucAdvancedData.UtilSearchUI) then AucAdvancedData.UtilSearchUI = {} end
	local realmKey = AucAdvanced.GetFaction()
	if not realmKey then
		return
	end
	if (not AucAdvancedData.UtilSearchUI) then AucAdvancedData.UtilSearchUI = {} end
	local SearchUISettings = AucAdvancedData.UtilSearchUI

	-- turn value into a canonical true or false
	if value == 'on' then
		value = true
	elseif value == 'off' then
		value = false
	end

	-- for defaults, just remove the value and it'll fall through
	if (value == 'default') or (value == getDefault(setting)) then
		-- Don't save default values
		value = nil
	end

	local a,b,c = strsplit(".", setting)
	if (a == "profile") then
		if (setting == "profile.new") then
			value = gui.elements["profile.name"]:GetText()

			-- Create the new profile 
			SearchUISettings["profile."..value] = {}

			-- Set the current profile to the new profile 
			SearchUISettings[realmKey]["lastProfile"] = value
			-- Get the new current profile 
			local newSearch = getProfileParam()

			-- Clean it out and then resave all data
			cleanse(newSearch)

			-- Add the new profile to the profiles list
			local profiles = SearchUISettings["profiles"]
			if (not profiles) then
				profiles = { realmKey }
				SearchUISettings["profiles"] = profiles
			end

			-- Check to see if it already exists
			local found = false
			for pos, name in ipairs(profiles) do
				if (name == value) then found = true end
			end

			-- If not, add it and then sort it
			if (not found) then
				table.insert(profiles, value)
				table.sort(profiles)
			end

		elseif (setting == "profile.copy") then
			value = gui.elements["profile.name"]:GetText()

			-- Create the new profile 
			SearchUISettings["profile."..value] = getProfileParam() or {}

			-- Set the new profile to the current setup 
			SearchUISettings[realmKey]["lastProfile"] = value
			-- Get the new current profile 
			local newSearch = getProfileParam()

			-- Add the new profile to the profiles list
			local profiles = SearchUISettings["profiles"]
			if (not profiles) then
				profiles = { realmKey }
				SearchUISettings["profiles"] = profiles
			end

			-- Check to see if it already exists
			local found = false
			for pos, name in ipairs(profiles) do
				if (name == value) then found = true end
			end

			-- If not, add it and then sort it
			if (not found) then
				table.insert(profiles, value)
				table.sort(profiles)
			end

		elseif (setting == "profile.delete") then
			-- User clicked the Delete button, see what the select box's value is.
			value = gui.elements["profile"].value

			-- If there's a profile name supplied
			if (value) then
				-- Clean it's profile container of values
				cleanse(SearchUISettings["profile."..value])

				-- Delete it's profile container
				SearchUISettings["profile."..value] = nil

				-- Find it's entry in the profiles list
				local profiles = SearchUISettings["profiles"]
				if (profiles) then
					for pos, name in ipairs(profiles) do
						-- If this is it, then extract it
						if (name == value and name ~= realmKey) then
							table.remove(profiles, pos)
						end
					end
				end

				-- If the user was using this one, then move them to Default
				if (getProfileParamName() == value) then
					SearchUISettings[realmKey]["lastProfile"] = realmKey
				end
			end

		elseif (setting == "profile.default") then
			-- User clicked the reset settings button

			-- Get the current profile from the select box
			value = gui.elements["profile"].value

			-- Clean it's profile container of values
			SearchUISettings["profile."..value] = {}
			-- Set the current profile to the default profile 
			SearchUISettings[realmKey]["lastProfile"] = realmKey

		elseif (setting == "profile") then
			-- User selected a different value in the select box, get it
			value = gui.elements["profile"].value

			-- Change the user's current profile to this new one
			SearchUISettings[realmKey]["lastProfile"] = value

		end

		-- Refresh all values to reflect current data
		gui:Refresh()
	else
		-- Set the value for this setting in the current search 
		local db = getProfileParam()
		if db[setting] == value then return end
		db[setting] = value
	end

	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.Processor) then
				engineLib.Processor("configchanged", setting, value)
			end
		end
	end
end

function lib.SetSetting(...)
	setter(...)
	if (gui) then
		gui:Refresh()
	end
end

local function getter(setting)
	if (not AucAdvancedData.UtilSearchUI) then AucAdvancedData.UtilSearchUI = {} end
	local realmKey = AucAdvanced.GetFaction()
	if not realmKey then
		return
	end
	if (not AucAdvancedData.UtilSearchUI) then AucAdvancedData.UtilSearchUI = {} end
	local SearchUISettings = AucAdvancedData.UtilSearchUI
	if not setting then return end

	local a,b,c = strsplit(".", setting)
	if (a == 'profile') then
		if (b == 'profiles') then
			local pList = SearchUISettings["profiles"]
			if (not pList) then
				pList = { realmKey }
			end
			--Make sure the current realm is included in the list
			local hasRealm = false
			for i,j in pairs(pList) do
				if j == realmKey then
					hasRealm = true
					break
				end
			end
			if not hasRealm then
				table.insert(pList, realmKey)
				table.sort(pList)
			end
			return pList
		end
	end

	if (setting == 'profile') then
		return getProfileParamName()
	end

	local db = getProfileParam()
	if ( db[setting] ~= nil ) then
		return db[setting]
	else
		return getDefault(setting)
	end
end

function lib.GetSetting(setting, default)
	--use settings cache during a search
	if private.isSearching then
		if SettingCache[setting]~=nil then
			return SettingCache[setting]
		end
	end
	local option = getter(setting)
	if ( option ~= nil ) then
		if private.isSearching then
			SettingCache[setting] = option
		end
		return option
	else
		if private.isSearching then
			SettingCache[setting] = default
		end
		return default
	end
end

function lib.Show()
	if not gui then --no need to make the GUI if it already exists
		lib.MakeGuiConfig()
	end
	gui:Show()
end

function lib.Hide()
	if (gui) then
		gui:Hide()
	end
end

function lib.Toggle()
	if (gui and gui:IsShown()) then
		lib.Hide()
	else
		lib.Show()
	end
end

private.callbacks = {}
function lib.AddCallback(name, callback)
	if (gui) then 
		callback(gui)
		return
	end
	private.callbacks[name] = callback
end

local searcherKit = {}
function searcherKit:GetName()
	return self.name
end

lib.Searchers = {}
function lib.NewSearcher(searcherName)
	if not lib.Searchers[searcherName] then
		local searcher = {}
		searcher.name = searcherName
		for k,v in pairs(searcherKit) do
			searcher[k] = v
		end

		lib.Searchers[searcherName] = searcher
		return searcher, lib, {}
	end
end

local filterKit = {}
function filterKit:GetName()
	return self.name
end

lib.Filters = {}
function lib.NewFilter(filterName)
	if not lib.Filters[filterName] then
		local filter = {}
		filter.name = filterName
		for k,v in pairs(filterKit) do
			filter[k] = v
		end
		
		lib.Filters[filterName] = filter
		return filter, lib, {}
	end
end

function lib.GetSearchLocals()
	return lib.GetSetting, lib.SetSetting, lib.SetDefault, Const
end

function private.removeline()
	--print("selected: "..tostring(gui.sheet.selected))
	--DevTools_Dump(private.sheetData)
	table.remove(private.sheetData, gui.sheet.selected)
	--DevTools_Dump(private.sheetData)
	gui.sheet.selected = nil
	gui.frame.remove:Disable()
	gui.sheet:SetData(private.sheetData)
	lib.UpdateControls()
end

function private.removeall()
	lib.CleanTable(private.sheetData)
	gui.sheet.selected = nil
	gui.sheet:SetData(private.sheetData)
	lib.UpdateControls()
end

function private.cropreason(reason)
	if reason then
		reason = string.split(":", reason)
		return reason
	end
end

function private.buyauction()
	AucAdvanced.Buy.QueueBuy(private.data.link, private.data.seller, private.data.stack, private.data.minbid, private.data.buyout, private.data.buyout, private.cropreason(private.data.reason))
	private.removeline()
end

function private.bidauction()
	local bid = MoneyInputFrame_GetCopper(gui.frame.bidbox)
	AucAdvanced.Buy.QueueBuy(private.data.link, private.data.seller, private.data.stack, private.data.minbid, private.data.buyout, bid, private.cropreason(private.data.reason))
	private.removeline()
end

function private.buyfirst()
	gui.sheet.selected = gui.sheet.sort[1]
	if not gui.sheet.selected then
		return
	end
	lib.UpdateControls()
	if string.match(private.data.reason, ":buy") then
		AucAdvanced.Buy.QueueBuy(private.data.link, private.data.seller, private.data.stack, private.data.minbid, private.data.buyout, private.data.buyout, private.cropreason(private.data.reason))
	elseif string.match(private.data.reason, ":bid") then
		AucAdvanced.Buy.QueueBuy(private.data.link, private.data.seller, private.data.stack, private.data.minbid, private.data.buyout, private.data.bid, private.cropreason(private.data.reason))
	elseif private.data.buyout then
		AucAdvanced.Buy.QueueBuy(private.data.link, private.data.seller, private.data.stack, private.data.minbid, private.data.buyout, private.data.buyout, private.cropreason(private.data.reason))
	else
		AucAdvanced.Buy.QueueBuy(private.data.link, private.data.seller, private.data.stack, private.data.minbid, private.data.buyout, private.data.bid, private.cropreason(private.data.reason))
	end
	private.removeline()
end

function private.ignore()
	local sig = AucAdvanced.API.GetSigFromLink(private.data.link)
	local price
	if string.match(private.data.reason, ":buy") then
		price = private.data.buyout
	elseif string.match(private.data.reason, ":bid") then
		price = private.data.bid
	elseif private.data.buyout then
		price = private.data.buyout
	else
		price = private.data.bid
	end
	local count = private.data.stack or 1
	price = math.floor(price/count)
	AucSearchUI.Filters.ItemPrice.AddIgnore(sig, price)
	print("SearchUI now ignoring "..private.data.link.." at "..EnhTooltip.GetTextGSC(price, true))
	private.removeline()
end

function private.ignoretemp()
	local sig = AucAdvanced.API.GetSigFromLink(private.data.link)
	local price
	if string.match(private.data.reason, ":buy") then
		price = private.data.buyout
	elseif string.match(private.data.reason, ":bid") then
		price = private.data.bid
	elseif private.data.buyout then
		price = private.data.buyout
	else
		price = private.data.bid
	end
	local count = private.data.stack or 1
	price = math.floor(price/count)
	AucSearchUI.Filters.ItemPrice.AddIgnore(sig, price, true)
	print("SearchUI now ignoring "..private.data.link.." at "..EnhTooltip.GetTextGSC(price, true).." for the session")
	private.removeline()
end

function lib.MakeGuiConfig()
	if gui then return end

	local Configator = LibStub("Configator")
	local ScrollSheet = LibStub("ScrollSheet")
	local id, last, cont
	local selected

	gui = Configator:Create(setter,getter, 900, 500, 0, 300)

	private.gui = gui
	gui.frame = CreateFrame("Frame", nil, gui)
	gui.frame:SetPoint("BOTTOMRIGHT", gui.Done, "TOPRIGHT", 0,25) 
	gui.frame:SetPoint("LEFT", gui:GetButton(1), "RIGHT", 5,0) 
	gui.frame:SetHeight(275)
	gui.frame:SetBackdrop({
		bgFile = "Interface/Tooltips/ChatBubble-Background",
		edgeFile = "Interface/Tooltips/ChatBubble-BackDrop",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 32, right = 32, top = 32, bottom = 32 }
	})
	gui.frame:SetBackdropColor(0, 0, 0, 1)
	
	function lib.UpdateControls()
		if gui.sheet.selected then
			gui.frame.remove:Enable()
			gui.frame.ignore:Enable()
			gui.frame.notnow:Enable()
		else
			gui.frame.remove:Disable()
			gui.frame.ignore:Disable()
			gui.frame.notnow:Disable()
		end
		if selected ~= gui.sheet.selected then
			selected = gui.sheet.selected
			local data = gui.sheet:GetSelection()
			if not data then
				lib.CleanTable(private.data)
			else
				private.data.link = data[1]
				private.data.seller = data[8]
				private.data.stack = data[4]
				private.data.bid = data[6]
				private.data.minbid = data[12]
				private.data.curbid = data[13]
				private.data.buyout = data[5]
				private.data.reason = data[7]
			end
			if private.data.buyout and (private.data.buyout > 0) then
				gui.frame.buyout:Enable()
				gui.frame.buyoutbox:SetText(EnhTooltip.GetTextGSC(private.data.buyout, true))
			else
				gui.frame.buyout:Disable()
				gui.frame.buyoutbox:SetText(EnhTooltip.GetTextGSC(0, true))
			end
		
			if private.data.bid then
				MoneyInputFrame_SetCopper(gui.frame.bidbox, private.data.bid)
				gui.frame.bid:Enable()
			else
				MoneyInputFrame_SetCopper(gui.frame.bidbox, 0)
				gui.frame.bid:Disable()
			end
		elseif private.data.curbid then--bid price was changed, so make sure that it's allowable 
			if MoneyInputFrame_GetCopper(gui.frame.bidbox) < math.ceil(private.data.curbid*1.05) then
				MoneyInputFrame_SetCopper(gui.frame.bidbox, math.ceil(private.data.curbid*1.05))
			end
			gui.frame.bid:Enable()
		end
		--if bid >= buyout, it's going to be a buyout anyway, so disable bid button to indicate that
		if private.data.buyout and (private.data.buyout > 0) and (MoneyInputFrame_GetCopper(gui.frame.bidbox) >= private.data.buyout) then
			MoneyInputFrame_SetCopper(gui.frame.bidbox, private.data.buyout)
			gui.frame.bid:Disable()
		end
	end

	function lib.OnEnterSheet(button, row, index)
		if gui.sheet.rows[row][index]:IsShown()then --Hide tooltip for hidden cells
			local link, name
			link = gui.sheet.rows[row][index]:GetText() 
			if not link then
				return
			end
			name = GetItemInfo(link)
			if link and name then
				GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
				GameTooltip:SetHyperlink(link)
				EnhTooltip.TooltipCall(GameTooltip, name, link, -1, 1) 
			end		
		end
	end

	function lib.OnLeaveSheet(button, row, index)
		GameTooltip:Hide()
	end

	function lib.OnClickSheet(button, row, index)
	--	lib.DoSomethingWithLinkFunctionHere(link)
	end	

	gui.sheet = ScrollSheet:Create(gui.frame, {
		{ "Item",   "TOOLTIP", 120 },
		{ "Pct",    "TEXT", 30  },
		{ "Profit", "COIN", 85, { DESCENDING=true } },
		{ "Stk",    "INT",  30  },
		{ "Buyout", "COIN", 85, { DESCENDING=true } },
		{ "Bid",    "COIN", 85, { DESCENDING=true } },
		{ "Reason", "TEXT", 85  },
		{ "Seller", "TEXT", 75  },
		{ "Left",   "TEXT", 40  },
		{ "Buy/ea", "COIN", 85, { DESCENDING=true, DEFAULT=true } },
		{ "Bid/ea", "COIN", 85, { DESCENDING=true, DEFAULT=true } },
		{ "MinBid", "COIN", 85, { DESCENDING=true } },
		{ "CurBid", "COIN", 85, { DESCENDING=true } },
		{ "Min/ea", "COIN", 85, { DESCENDING=true } },
		{ "Cur/ea", "COIN", 85, { DESCENDING=true } },
	}, lib.OnEnterSheet, lib.OnLeaveSheet, lib.OnClickSheet, nil, lib.UpdateControls) 
	

	gui.sheet:EnableSelect(true)
	gui.Search = CreateFrame("Button", "AucSearchUISearchButton", gui, "OptionsButtonTemplate")
	gui.Search:SetPoint("BOTTOMRIGHT", gui, "BOTTOMRIGHT", -10, 35)
	gui.Search:SetText("Search")
	gui.Search:SetScript("OnClick", lib.PerformSearch)
	gui.Search:SetFrameLevel(11)
	
	gui:AddCat("Searches")
	gui:AddCat("Filters")
	id = gui:AddTab("General parameters", "Searches") -- Merely a place holder

	id = gui:AddTab("Saved Profiles", "Options")
	gui:AddControl(id, "Header",     0,    "Setup, configure and edit profiles")
	last = gui:GetLast(id)
	gui:AddControl(id, "Subhead",    0,    "Select a saved profile")
	gui:AddControl(id, "Selectbox",  0, 1, "profile.profiles", "profile", "Switch to given profile")
	gui:AddControl(id, "Button",     0, 1, "profile.delete", "Delete")
	cont = gui:GetLast(id)
	gui:SetLast(id, last)
	gui:AddControl(id, "Subhead",    0.5,    "Create or replace a profile")
	gui:AddControl(id, "Text",       0.5, 1, "profile.name", "New profile name:")
	last = gui:GetLast(id)
	gui:AddControl(id, "Button",     0.5, 1, "profile.new", "Create new")
	gui:SetLast(id, last)
	gui:AddControl(id, "Button",     0.7, 1, "profile.copy", "Create copy")
	
	gui:AddCat("Options")
	id = gui:AddTab("General Options", "Options")
	gui:MakeScrollable(id)
	gui:AddControl(id, "Header",           0,    "Setup general options")
	gui:AddControl(id, "WideSlider",       0, 1, "searchspeed", 10, 500, 10, "Search process priority: %s")
	gui:AddControl(id, "Subhead",          0,    "Purchase Settings")
	gui:AddControl(id, "MoneyFramePinned", 0, 1, "reserve", 1, 99999999, "Reserve Amount")
	gui:AddTip(id, "Sets the amount that you don't want your cash-on-hand to fall below")
	gui:AddControl(id, "MoneyFramePinned", 0, 1, "maxprice", 1, 99999999, "Maximum Price")
	
	gui:AddControl(id, "Subhead",          0,    "Tooltip")
	gui:AddControl(id, "Checkbox",         0, 1, "debug.show", "Show debug line in tooltip for auctions")
	for name, searcher in pairs(lib.Searchers) do
		if searcher and searcher.Search then
			gui:AddControl(id, "Checkbox",  0, 2, "debug."..name, "Show debug for "..name)
			gui:AddTip(id, "Show a debug line in the tooltip over auctions for searcher: "..name)
		end
	end
	
	gui:SetScript("OnKeyDown", lib.UpdateControls)
	
	gui.frame.buyout = CreateFrame("Button", nil, gui.frame, "OptionsButtonTemplate")
	gui.frame.buyout:SetPoint("BOTTOMRIGHT", gui.Done, "BOTTOMLEFT", -30, 25)
	gui.frame.buyout:SetText("Buyout")
	gui.frame.buyout:SetScript("OnClick", private.buyauction)
	gui.frame.buyout:Disable()
	
	gui.frame.buyoutbox = gui.frame.buyout:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	gui.frame.buyoutbox:SetPoint("BOTTOMRIGHT", gui.frame.buyout, "BOTTOMLEFT", -4, 4)
	gui.frame.buyoutbox:SetWidth(100)

	gui.frame.bid = CreateFrame("Button", nil, gui.frame, "OptionsButtonTemplate")
	gui.frame.bid:SetPoint("BOTTOMRIGHT", gui.frame.buyoutbox, "BOTTOMLEFT", -10, -4)
	gui.frame.bid:SetText("Bid")
	gui.frame.bid:SetScript("OnClick", private.bidauction)
	gui.frame.bid:Disable()
	
	gui.frame.bidbox = CreateFrame("Frame", "AucAdvSearchUIBidBox", gui.frame, "MoneyInputFrameTemplate")
	gui.frame.bidbox:SetPoint("BOTTOMRIGHT", gui.frame.bid, "BOTTOMLEFT", -4, 4)
	MoneyInputFrame_SetOnvalueChangedFunc(gui.frame.bidbox, lib.UpdateControls)
	
	gui.frame.buyfirst = CreateFrame("Button", nil, gui.frame, "OptionsButtonTemplate")
	gui.frame.buyfirst:SetPoint("BOTTOMRIGHT", gui.frame.bidbox, "BOTTOMLEFT", -30, -4)
	gui.frame.buyfirst:SetText("Buy First")
	gui.frame.buyfirst:SetScript("OnClick", private.buyfirst)
	gui.frame.buyfirst:Enable()
	
	gui.frame.clear = CreateFrame("Button", nil, gui.frame, "OptionsButtonTemplate")
	gui.frame.clear:SetPoint("TOPLEFT", gui.frame.buyfirst, "BOTTOMLEFT", 10, -5)
	gui.frame.clear:SetText("Clear")
	gui.frame.clear:SetScript("OnClick", private.removeall)
	gui.frame.clear:Enable()
	
	gui.frame.remove = CreateFrame("Button", nil, gui.frame, "OptionsButtonTemplate")
	gui.frame.remove:SetPoint("BOTTOMLEFT", gui.frame.clear, "BOTTOMRIGHT", 30, 0)
	gui.frame.remove:SetText("Remove")
	gui.frame.remove:SetScript("OnClick", private.removeline)
	gui.frame.remove:Disable()
	
	gui.frame.ignore = CreateFrame("Button", nil, gui.frame, "OptionsButtonTemplate")
	gui.frame.ignore:SetPoint("BOTTOMLEFT", gui.frame.remove, "BOTTOMRIGHT", 120, 0)
	gui.frame.ignore:SetText("Ignore")
	gui.frame.ignore:SetScript("OnClick", private.ignore)
	gui.frame.ignore:Disable()
	
	gui.frame.notnow = CreateFrame("Button", nil, gui.frame, "OptionsButtonTemplate")
	gui.frame.notnow:SetPoint("BOTTOMLEFT", gui.frame.ignore, "BOTTOMRIGHT", 30, 0)
	gui.frame.notnow:SetText("Not Now")
	gui.frame.notnow:SetScript("OnClick", private.ignoretemp)
	gui.frame.notnow:Disable()
	
	gui.frame.progressbar = CreateFrame("STATUSBAR", nil, gui.frame, "TextStatusBar")
	gui.frame.progressbar:SetWidth(400)
	gui.frame.progressbar:SetHeight(30)
	gui.frame.progressbar:SetPoint("BOTTOM", gui.frame, "BOTTOM", 0, 100)
	gui.frame.progressbar:SetBackdrop({
	  bgFile="Interface\\Tooltips\\UI-Tooltip-Background", 
	  edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
	  tile=1, tileSize=10, edgeSize=10, 
	  insets={left=3, right=3, top=3, bottom=3}
	})
	gui.frame.progressbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	gui.frame.progressbar:SetStatusBarColor(0.6, 0, 0, 0.4)
	gui.frame.progressbar:SetMinMaxValues(0, 1000)
	gui.frame.progressbar:SetValue(0)
	gui.frame.progressbar:SetFrameLevel(10)
	gui.frame.progressbar:Hide()
	
	gui.frame.progressbar.text = gui.frame.progressbar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	gui.frame.progressbar.text:SetPoint("CENTER", gui.frame.progressbar, "CENTER")
	gui.frame.progressbar.text:SetText("AucAdv SearchUI: Searching")
	gui.frame.progressbar.text:SetTextColor(1,1,1)
	
	gui.frame.progressbar.cancel = CreateFrame("Button", nil, gui.frame.progressbar, "OptionsButtonTemplate")
	gui.frame.progressbar.cancel:SetPoint("BOTTOMRIGHT", gui.frame.progressbar, "BOTTOMRIGHT", -5, 5)
	gui.frame.progressbar.cancel:SetPoint("TOPLEFT", gui.frame.progressbar, "TOPRIGHT", -25, -5)
	gui.frame.progressbar.cancel:SetText("X")
	gui.frame.progressbar.cancel:SetScript("OnClick", private.cancelSearch)
	
	-- Alert our searchers?
	for name, searcher in pairs(lib.Searchers) do
		if searcher.MakeGuiConfig then
			searcher:MakeGuiConfig(gui)
		end
	end
	--Alert our Filters
	for name, filter in pairs(lib.Filters) do
		if filter.MakeGuiConfig then
			filter:MakeGuiConfig(gui)
		end
	end
	-- Any callbacks?
	for name, callback in pairs(private.callbacks) do
		callback(gui)
	end
end

local sideIcon
local SlideBar = LibStub:GetLibrary("SlideBar", true)
if SlideBar then
	--Need to figure out if we're embedded first
	local embedded = false
	for _, module in ipairs(AucAdvanced.EmbeddedModules) do 
		if module == "Auc-Util-SearchUI"  then 
			embedded = true 
		end 
	end 
	if embedded then
		sideIcon = SlideBar.AddButton("Auc-Util-SearchUI", "Interface\\AddOns\\Auc-Advanced\\Modules\\Auc-Util-SearchUI\\Textures\\SearchUIIcon", 300)
	else
		sideIcon = SlideBar.AddButton("Auc-Util-SearchUI", "Interface\\AddOns\\Auc-Util-SearchUI\\Textures\\SearchUIIcon", 300)
	end
	sideIcon:RegisterForClicks("LeftButtonUp","RightButtonUp")
	sideIcon:SetScript("OnClick", lib.Toggle)
	sideIcon.tip = {
		"Auction SearchUI",
		"Allows you to perform searches on the AuctioneerAdvanced auction cache, even when away from the Auction House",
		"{{Click}} to open the Search UI.",
	}
end

function private.FindSearcher(item)
	if not gui.config.selectedTab then
		return
	end
	for name, searcher in pairs(lib.Searchers) do
		if searcher and searcher.tabname and searcher.tabname == gui.config.selectedTab and searcher.Search then
			return searcher, name
		end
	end
end

function private.cancelSearch()
	private.SearchCancel = true
end

--lib.SearchItem(searcherName, item, nodupes)
--purpose: handles sending the item to the specified searcher, and if necessary, adds it to the SearchUI results
--nodupes is boolean flag.  If true, no duplicate checking is done.  This flag is true for searching from the cache, but false for realtime.
--debugonly is boolean flag, If true, nothing gets added to the results list
--returns true, value, profit when successful
--returns false, reason when not
function lib.SearchItem(searcherName, item, nodupes, debugonly)
	if not searcherName or not item or #item == 0 then
		return
	end
	local searcher = lib.Searchers[searcherName]
	if not searcher then
		return
	end
	local debugstring
	
	--next, pass the item through the filters
	local isfiltered = false
	for filtername, filter in pairs(lib.Filters) do
		if filter.Filter then
			local dofilter, filterreturn = filter.Filter(item, searcherName)
			if dofilter then
				return false, "Filter:"..filtername..": "..tostring(filterreturn)
			end
		end
	end
	
	--buyorbid must be either "bid", "buy", true, false, or nil
	--if string is returned for buyorbid, value must be number or nil (in which case value will be Marketprice)
	local buyorbid, value, pct, reason
	buyorbid, value, pct, reason = searcher.Search(item)
	if buyorbid then
		--give the filters a second chance to filter out, based on bid/buy differences
		for filtername, filter in pairs(lib.Filters) do
			if filter.PostFilter then
				local dofilter, filterreturn = filter.PostFilter(item, searcherName, buyorbid)
				if dofilter then
					return false, "Filtered by "..filtername..": "..filterreturn
				end
			end
		end

		local cost = 0
		if type(buyorbid) == "string" then
			item["reason"] = searcher.tabname..":"..buyorbid
			if reason then
				item["reason"] = item["reason"]..":"..reason
			end
			if buyorbid == "bid" then
				--don't show result if we're already the highest bidder
				if item[Const.AMHIGH] then
					return false, "Bid blocked: Already high bidder"
				end
				cost = item[Const.PRICE]
			else
				cost = item[Const.BUYOUT]
			end
			if not value then
				value = AucAdvanced.API.GetMarketValue(item[Const.LINK])
			end
			if not value then
				value = 0
			end
			item["profit"] = value - cost
		else
			item["reason"] = searcher.tabname
		end
		local maxprice = lib.GetSetting("maxprice") or 10000000
		local reserve = lib.GetSetting("reserve") or 1
		local balance = GetMoney()
		
		if (cost <= maxprice) and ((balance-cost) > reserve) then
			--Check to see whether the item already exists in the results table
			local isdupe = false
			if not nodupes then
				if not private.sheetData then
					private.sheetData = {}
				end
				for j,k in pairs(private.sheetData) do
					if (k[1] == item[Const.LINK]) and (k[7] == item["reason"]) then
						isdupe = true
					end
				end
			end
			if nodupes or (not isdupe) then
				if not debugonly then
					local level, _, r, g, b
					local pctstring = ""
					if not pct and AucAdvanced.Modules.Util.PriceLevel then
						local valueper
						if value then
							valueper = value/item[Const.COUNT]
						end
						if buyorbid == "bid" then
							level, _, r, g, b = AucAdvanced.Modules.Util.PriceLevel.CalcLevel(item[Const.LINK], item[Const.COUNT], item[Const.PRICE], item[Const.PRICE], valueper)
						else
							level, _, r, g, b = AucAdvanced.Modules.Util.PriceLevel.CalcLevel(item[Const.LINK], item[Const.COUNT], item[Const.PRICE], item[Const.BUYOUT], valueper)
						end
						if level then
							r = r*255
							g = g*255
							b = b*255
							--first color code here is for sorting purposes
							pctstring = string.format("|cff%06d|cff%02x%02x%02x"..math.floor(level), 100*level, r, g, b)
							pct = pctstring
						end
					end
					item["pct"] = pct
					item["cost"] = cost
					local count = item[Const.COUNT] or 1
					local min = item[Const.MINBID] or 0
					local cur = item[Const.CURBID] or 0
					local buy = item[Const.BUYOUT] or 0
					local price = item[Const.PRICE] or 0
					table.insert(private.sheetData, {
						item[Const.LINK],
						item["pct"],
						item["profit"],
						count,
						buy,
						price,
						item["reason"],
						item[Const.SELLER],
						private.tleft[item[Const.TLEFT]],
						buy/count,
						price/count,
						min,
						cur,
						min/count,
						cur/count
					})
					gui.sheet:SetData(private.sheetData)
				end
				return true, item["profit"], value
			end
		elseif cost > maxprice then
			return false, "Price higher than maxprice"
		else
			return false, "Balance lower than reserve"
		end
	end
	return false, value
end

local PerformSearch = function()
	gui:ClearFocus()
	--Perform the search.  We're not using API.QueryImage() because we need it to be a coroutine
	local scandata = replicate((AucAdvanced.Scan.GetScanData()))
	local speed = lib.GetSetting("searchspeed")
	if not speed then speed = 1000 end
	local searcher, searcherName = private.FindSearcher()
	if not searcher then
		print("No valid Searches selected")
		return
	end
	gui.frame.progressbar.text:SetText("AucAdv SearchUI: Searching |cffffcc19"..gui.config.selectedTab)
	gui.frame.progressbar:Show()
	
	--clear the results table
	lib.CleanTable(private.sheetData)
	gui.sheet:SetData(private.sheetData)
	
	private.isSearching = true
	for i, data in ipairs(scandata.image) do
		if (i % speed) == 0 then
			gui.frame.progressbar:SetValue((i/#scandata.image)*1000)
			coroutine.yield()
			if private.SearchCancel then
				private.SearchCancel = nil
				break
			end
		end
		lib.SearchItem(searcher.name, data, true)
	end
	private.isSearching = false
	empty(SettingCache)
	gui.frame.progressbar:Hide()
end

function lib.IsSearching()
	return private.isSearching
end

function lib.PerformSearch(searcher)
	if (not coSearch) or (coroutine.status(coSearch) == "dead") then
		coSearch = coroutine.create(PerformSearch)
		local status, result = coroutine.resume(coSearch, searcher)
		if not status and result then
            error("Error in search coroutine: "..result.."\n\n{{{Coroutine Stack:}}}\n"..debugstack(coSearch));
		end
	else
		print("coroutine already running: "..coroutine.status(coSearch))
	end
end

local flip = false
function private.OnUpdate()
	if coSearch and coroutine.status(coSearch) ~= "dead" then
		flip = not flip
		if flip then
			local status, result = coroutine.resume(coSearch)
			if not status and result then
				error("Error in search coroutine: "..result.."\n\n{{{Coroutine Stack:}}}\n"..debugstack(coSearch));
			end
		end
	end
	if gui and gui:IsShown() then 
		if gui.config.selectedCat == "Searches" then
			if not gui.Search:IsShown() then
				gui.Search:Show()
			end
		else
			if gui.Search:IsShown() then
				gui.Search:Hide()
			end
		end
	end
end

private.updater = CreateFrame("Frame", nil, UIParent)
private.updater:SetScript("OnUpdate", private.OnUpdate)

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/RC_5.0/Auc-Util-SearchUI/SearchMain.lua $", "$Rev: 3534 $")
