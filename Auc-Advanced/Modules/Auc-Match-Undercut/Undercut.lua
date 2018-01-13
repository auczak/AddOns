--[[
	Auctioneer Advanced - Price Level Utility module
	Version: 5.0.0 (BillyGoat)
	Revision: $Id: Undercut.lua 3540 2008-10-02 03:41:29Z Nechckn $
	URL: http://auctioneeraddon.com/

	This is an Auctioneer Advanced Matcher module that returns an undercut price 
	based on the current market snapshot

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


local libType, libName = "Match", "Undercut"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		--Called when the tooltip is being drawn.
		private.ProcessTooltip(...)
	elseif (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
	elseif (callbackType == "listupdate") then
		--Called when the AH Browse screen receives an update.
	elseif (callbackType == "configchanged") then
		--Called when your config options (if Configator) have been changed.
	end
end

function lib.GetMatchArray(hyperlink, marketprice)
	if not AucAdvanced.Settings.GetSetting("match.undercut.enable") then
		return
	end
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end

	local overmarket = AucAdvanced.Settings.GetSetting("match.undermarket.overmarket")
	local undermarket = AucAdvanced.Settings.GetSetting("match.undermarket.undermarket")
	local usevalue = AucAdvanced.Settings.GetSetting("match.undercut.usevalue")
	local undercut 
	if usevalue then
		undercut = AucAdvanced.Settings.GetSetting("match.undercut.value")
	else
		undercut = AucAdvanced.Settings.GetSetting("match.undermarket.undercut")
	end	
	local playerName = UnitName("player")
	local marketdiff = 0
	local competing = 0
	local matchprice = 0
	local minprice = 0
	local lowest = true
	if not marketprice then marketprice = 0 end
	if marketprice > 0 then
		matchprice = floor(marketprice*(1+(overmarket/100)))
		minprice = ceil(marketprice*(1+(undermarket/100)))
	end
	
	itemId = tonumber(itemId)
	property = tonumber(property) or 0
	factor = tonumber(factor) or 0
	
	local data = AucAdvanced.API.QueryImage({
		itemId = itemId,
		suffix = property,
		factor = factor,
	})
	competing = #data
	local lowestBidOnly = matchprice
	for i = 1, #data do
		local compet = AucAdvanced.API.UnpackImageItem(data[i])
		local competname = compet.itemName or " "
		local competseller = compet.sellerName or " "
		local competcost = compet.buyoutPrice or 0
		local competstack = compet.stackSize or 0
		if compet.buyoutPrice<1 then
			-- UCUT-8: Don't try to match bid-only auctions
			lowestBidOnly = min(lowestBidOnly, (compet.curBid or compet.minBid)/compet.stackSize)
		else
			compet.buyoutPrice = (compet.buyoutPrice/compet.stackSize)
			if usevalue then
				compet.buyoutPrice = compet.buyoutPrice - undercut
			else		
				compet.buyoutPrice = floor(compet.buyoutPrice*((100-undercut)/100))
			end
			if compet.buyoutPrice <= 0 then
				compet.buyoutPrice = 1
			end
			if (compet.buyoutPrice < matchprice) then
				if (compet.buyoutPrice > minprice) then
					if (not (compet.sellerName == playerName)) then
						matchprice = compet.buyoutPrice
					end
				elseif (compet.buyoutPrice > 0) then
					lowest = false
				end
			end
		end
	end
	if (marketprice > 0) then
		marketdiff = (((matchprice - marketprice)/marketprice)*100)
		if (marketdiff-floor(marketdiff))<0.5 then
			marketdiff = floor(marketdiff)
		else
			marketdiff = ceil(marketdiff)
		end
	else
		marketdiff = 0
	end
	local matchArray = {}
	matchArray.value = matchprice
	if lowest then
		if matchprice<=lowestBidOnly then
			matchArray.returnstring = "Undercut: % change: "..marketdiff.."\nUndercut: Lowest Price"
		else
			matchArray.returnstring = "Undercut: % change: "..marketdiff.."\nUndercut: Lower bid-only auctions"
		end
	else
		matchArray.returnstring = "Undercut: % change: "..marketdiff.."\nUndercut: Can not match lowest price"
	end
	matchArray.competing = competing
	matchArray.diff = marketdiff
	return matchArray
end

local array = {}

function private.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, additional)

end

function lib.OnLoad()
	--This function is called when your variables have been loaded.
	--You should also set your Configator defaults here

	--print("AucAdvanced: {{"..libType..":"..libName.."}} loaded!")
	AucAdvanced.Settings.SetDefault("match.undercut.enable", true)
	AucAdvanced.Settings.SetDefault("match.undermarket.undermarket", -20)
	AucAdvanced.Settings.SetDefault("match.undermarket.overmarket", 10)
	AucAdvanced.Settings.SetDefault("match.undermarket.undercut", 1)
end

--[[ Local functions ]]--

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	local id = gui:AddTab(libName, libType.." Modules")
	--gui:MakeScrollable(id)

	gui:AddHelp(id, "what undercut module",
		"What is this undercut module?",
		"The undercut module allows you to undercut the lowest price of all currently available "..
		"items, based on your settings.\n\n"..
		"It is recommended to have undercut run after any other matcher modules.")

	gui:AddControl(id, "Header",     0,    libName.." options")
	
	gui:AddControl(id, "Subhead",    0,    "Competition Matching")
	
	gui:AddControl(id, "Checkbox",   0, 1, "match.undercut.enable", "Enable Auc-Match-Undercut")
	
	gui:AddControl(id, "WideSlider", 0, 1, "match.undermarket.undermarket", -100, 0, 1, "Max under market price (markdown): %d%%")
	gui:AddTip(id, "This controls how much below the market price you are willing to undercut before giving up.\n"..
		"If AucAdvanced cannot beat the lowest price, it will undercut the lowest price it can.")
	
	gui:AddControl(id, "WideSlider", 0, 1, "match.undermarket.overmarket", 0, 100, 1, "Max over market price (markup): %d%%")
	gui:AddTip(id, "This controls how much above the market price you are willing to mark up.\n"..
		"If there is no competition, or the competition is marked up higher than this value,\n"..
		"AucAdvanced will set the price to this value above market.")
	
	gui:AddControl(id, "Slider",     0, 1, "match.undermarket.undercut", 0, 20, 0.1, "Undercut: %g%%")
	gui:AddTip(id, "This controls the minimum undercut.  AucAdvanced will try to undercut the competition by this amount")
	
	gui:AddControl(id, "Checkbox",   0, 1, "match.undercut.usevalue", "Specify undercut amount by coin value")
	gui:AddTip(id, "Specify the amount to undercut by a specific amount, instead of by a percentage")
	
	gui:AddControl(id, "MoneyFramePinned", 0, 2, "match.undercut.value", 1, 99999999, "Undercut Amount")
	
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/RC_5.0/Auc-Match-Undercut/Undercut.lua $", "$Rev: 3540 $")
