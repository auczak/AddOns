--[[
	Auctioneer Advanced - Price Level Utility module
	Version: 5.0.0 (BillyGoat)
	Revision: $Id: WOWEcon.lua 3540 2008-10-02 03:41:29Z Nechckn $
	URL: http://auctioneeraddon.com/

	This is an Auctioneer Advanced module that does something nifty.

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

local libType, libName = "Stat", "WOWEcon"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()

function private.Sanitize(hyperlink)
	local lType, id, suffix, factor, enchant, seed = decode(hyperlink)
	if lType == "item" then
		local newbit, newlink
		if AucAdvanced.Settings.GetSetting("stat.wowecon.sanitize") then
			-- If the settings say to sanitize this item, them remove all the
			-- specificness from the hyperlink before sending it in.
			newbit = ("|Hitem:%d:%d:%d:%d:%d:%d:%d:%d|h"):format(id,0,0,0,0,0,suffix,factor)
			newlink = hyperlink:gsub("|Hitem:[%d%p:]+|h", newbit)
		else
			-- Only remove the random seed component from the link, leave the factor
			newlink = hyperlink:gsub("(|Hitem:[%d%p:]+):[%p%d]+|h", "%1:"..factor.."|h")
		end
		assert(newlink, "Link sanitization failed")
		return newlink
	end
	return hyperlink
end

function lib.GetPrice(hyperlink, faction, realm)
	if not AucAdvanced.Settings.GetSetting("stat.wowecon.enable") then return end
	if not (Wowecon and Wowecon.API) then return end
	hyperlink = private.Sanitize(hyperlink)

	local price,seen,specific = Wowecon.API.GetAuctionPrice_ByLink(hyperlink)
	if specific and AucAdvanced.Settings.GetSetting("stat.wowecon.useglobal") then
		price,seen = Wowecon.API.GetAuctionPrice_ByLink(hyperlink, Wowecon.API.GLOBAL_PRICE)
	end
	return price, false, seen, specific
end

function lib.GetPriceColumns()
	if not (Wowecon and Wowecon.API) then return end
	return "WOWEcon Price", false, "WOWEcon Seen"
end

local array = {}
function lib.GetPriceArray(hyperlink, faction, realm)
	if not AucAdvanced.Settings.GetSetting("stat.wowecon.enable") then return end
	if not (Wowecon and Wowecon.API) then return end

	array.hyperlink = hyperlink
	hyperlink = private.Sanitize(hyperlink)
	array.sanitized = hyperlink

	-- Get our statistics
	local price,seen,specific = Wowecon.API.GetAuctionPrice_ByLink(hyperlink)
	array.price = price
	array.seen = seen or 0
	array.specific = specific

	if (specific) then
		array.s_price = price
		array.s_seen = seen
		price,seen = Wowecon.API.GetAuctionPrice_ByLink(hyperlink, Wowecon.API.GLOBAL_PRICE)
	else
		array.s_price = nil
		array.s_seen = 0
	end
	array.g_price = price
	array.g_seen = seen or 0
	
	if AucAdvanced.Settings.GetSetting("stat.wowecon.useglobal") then
		array.price = array.g_price
		array.seen = array.g_seen
		array.specific = false
	end
	
	return array
end

function lib.IsValidAlgorithm()
	if not (Wowecon and Wowecon.API) then return false end
	return true
end

function lib.CanSupplyMarket()
	if not (Wowecon and Wowecon.API) then return false end
	return true
end

function lib.Processor(callbackType, ...)
	if (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
	elseif (callbackType == "load") then
		lib.OnLoad(...)
	elseif (callbackType == "tooltip") then
		lib.ProcessTooltip(...)
	end
end

function private.SetupConfigGui(gui)
	local id = gui:AddTab(lib.libName, lib.libType.." Modules")

	gui:AddHelp(id, "what global price",
		"What are global prices?",
		"Wowecon provides two different types of prices: a global price, averaged across "..
		"all servers, and a server specific price, for just your server and faction.")

	gui:AddHelp(id, "why use global",
		"Why should I use global prices?",
		"Server specific prices can be useful if your server has prices which are far "..
		"removed from the average, but often these prices are based on many "..
		"fewer data points, causing your server specific price to "..
		"possibly get out of whack for some items.  This option lets you force the "..
		"Wowecon stat to always use global prices, if you'd prefer.")
	
	gui:AddHelp(id, "prices dont match",
		"The Wowecon price used by Appraiser doesn't match the Wowecon tooltip.  What gives?",
		"Wowecon gives you the option to hide server specific prices if seen "..
		"fewer than a given number of times.  Even though these prices are "..
		"hidden from the tooltip, they are still reported to Appraiser.  "..
		"If you are not using the global price option here, you should "..
		"check to make sure there isn't a hidden server specific price for your server, "..
		"with just a small number of seen times.")

	gui:AddHelp(id, "sanitize link",
		"What does the sanitize link option do?",
		"Sanitizing the link can improve the price data you receive from WOWEcon by "..
		"removing the parts of the link that are very specific (such as enchants, "..
		"item factors, and gem informatio) to just get the price information for the "..
		"common base item. This will generally only affect items that are slightly "..
		"different from the normal base item, and have no, or very little price data "..
		"due to their uniqueness.")

	gui:AddHelp(id, "show price tooltip",
		"Why would I want to show the WOWEcon price in the tooltip?",
		"The pricing data that Appraiser uses for the items may be different to the "..
		"price data that WOWEcon displays by default, since WOWEcon can get very "..
		"specific with the data that it returns. Enabling this option will let you "..
		"see the exact price that this module is reporting for the current item.")
	
	gui:AddControl(id, "Header",     0,    libName.." options")
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.wowecon.enable", "Enable WOWEcon Stats")
	gui:AddTip(id, "Allow WOWEcon to gather and return price data")
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.wowecon.useglobal", "Always use global price, not server price")
	gui:AddTip(id, "Toggle use of server specific Wowecon price stats, if they exist")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.wowecon.sanitize", "Sanitize links before sending to WOWEcon API")
	gui:AddTip(id, "Removes ultra-specific item data from links before issuing the price request")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.wowecon.tooltip", "Show WOWEcon value in tooltip (see note)")
	gui:AddTip(id, "Note: WOWEcon already shows this by default, this may produce redundant information in your tooltip")
end

function lib.OnLoad(addon)
	AucAdvanced.Settings.SetDefault("stat.wowecon.useglobal", true)
	AucAdvanced.Settings.SetDefault("stat.wowecon.enable", false)
	AucAdvanced.Settings.SetDefault("stat.wowecon.sanitize", true)
	AucAdvanced.Settings.SetDefault("stat.wowecon.tooltip", false)
end

function lib.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, ...)
	if not AucAdvanced.Settings.GetSetting("stat.wowecon.tooltip") then return end
	lib.GetPriceArray(hyperlink)

	if array.seen > 0 then
		EnhTooltip.AddLine(libName.." prices (seen "..array.seen..")")
		EnhTooltip.LineColor(0.3, 0.9, 0.8)

		if array.specific then
			EnhTooltip.AddLine("  Server price:", array.price * quantity)
		else
			EnhTooltip.AddLine("  Global price:", array.price * quantity)
		end
		EnhTooltip.LineColor(0.3, 0.9, 0.8)
		if (quantity > 1) then
			EnhTooltip.AddLine("    (or individually)", array.price)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end

		if IsModifierKeyDown() then
			if array.specific then
				EnhTooltip.AddLine("  Global (seen "..array.g_seen.."):", array.g_price * quantity)
			elseif array.s_seen > 0 then
				EnhTooltip.AddLine("  Server (seen "..array.s_seen.."):", array.s_price * quantity)
			else
				EnhTooltip.AddLine("  Never seen for server")
			end
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end

	end
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/RC_5.0/Auc-Stat-WOWEcon/WOWEcon.lua $", "$Rev: 3540 $")
