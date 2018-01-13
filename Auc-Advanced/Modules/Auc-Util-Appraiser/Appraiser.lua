--[[
	Auctioneer Advanced - Appraisals and Auction Posting
	Version: 5.0.0 (BillyGoat)
	Revision: $Id: Appraiser.lua 3520 2008-09-23 05:58:19Z GhostfromTexas $
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds an appriasals dialog for
	easy posting of your auctionables when you are at the auction-house.

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

local libType, libName = "Util", "Appraiser"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()

local data, _
local ownResults = {}
local ownCounts = {}

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		lib.ProcessTooltip(...)
	elseif (callbackType == "auctionui") then
        private.CreateFrames(...)
        lib.GetOwnAuctionDetails()
	elseif (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif (callbackType == "configchanged") then
		if private.frame then
			private.frame.salebox.config = true
			private.frame.SetPriceFromModel()
			private.frame.UpdateControls()
			private.frame.salebox.config = nil
		end
	elseif (callbackType == "inventory") then
		if private.frame and private.frame:IsVisible() then
			private.frame.GenerateList()
		end
	elseif (callbackType == "scanstats") then
		if private.frame then
			private.frame.cache = {}
			private.frame.GenerateList()
			private.frame.UpdateImage()
			private.frame.SetPriceFromModel()
		end
	elseif (callbackType == "postresult") then
		private.frame.Reselect(select(3, ...))
	end
end

-- For backwards compatibility, leave these here. This is now a capability of the core API
lib.GetSigFromLink = AucAdvanced.API.GetSigFromLink;
lib.GetLinkFromSig = AucAdvanced.API.GetLinkFromSig;


function lib.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, additional)
	if not AucAdvanced.Settings.GetSetting("util.appraiser.enable") then return end
	if not AucAdvanced.Settings.GetSetting("util.appraiser.model") then return end

	local sig = lib.GetSigFromLink(hyperlink)
	if sig then
		local curModel = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..sig..".model") or "default"
		if curModel == "default" then
			curModel = AucAdvanced.Settings.GetSetting("util.appraiser.model") or "market"
		end

		local value
		if curModel == "fixed" then
			value = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".fixed.buy")
			if not value then
				value = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".fixed.bid")
			end
		elseif curModel == "market" then
			value = AucAdvanced.API.GetMarketValue(hyperlink)
		else
			value = AucAdvanced.API.GetAlgorithmValue(curModel, hyperlink)
		end

		if value then
			EnhTooltip.AddLine("Appraiser |cffddeeff("..curModel..")|r x|cffddeeff"..quantity.."|r", value * quantity)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
	end
    if AucAdvanced.Settings.GetSetting("util.appraiser.ownauctions") then
        -- Just to make sure it has the data seeing it likes to not load when you first load the auction house currently
        local numBatchAuctions, totalAuctions = GetNumAuctionItems("owner");
        if numBatchAuctions > 0 and totalAuctions > 0 and not lib.ownResults then
            lib.GetOwnAuctionDetails()
        end
        if not lib.ownResults then return end
    
        local itemName = name
        
        local colored = (AucAdvanced.Settings.GetSetting('util.appraiser.manifest.color') and AucAdvanced.Modules.Util.PriceLevel)
		
		local results = lib.ownResults[itemName]
		local counts = lib.ownCounts[itemName]
		
		if counts and #counts>0 then
            local sumBid, sumBO = 0, 0
            local countBid, countBO = 0, 0
			for _,count in ipairs(counts) do
				local res = results[count]
				sumBid = sumBid + res.sumBid --*res.stackCount
                sumBO = sumBO + res.sumBO --*res.stackCount
                countBid = countBid + res.countBid --*res.stackCount
                countBO = countBO + res.countBO --*res.stackCount
			end
            local avgBid =  countBid>0 and (sumBid / countBid) or nil
            local avgBO =  countBO>0 and (sumBO / countBO) or nil
            local r,g,b,_
			if colored then
				_, _, r,g,b = AucAdvanced.Modules.Util.PriceLevel.CalcLevel(hyperlink, 1, avgBid, avgBO)
			end
			r,g,b = r or 1,g or 1, b or 1
			
            EnhTooltip.AddLine(format("  Posted %2d at avg/ea", countBO or countBid)..
				(avgBO and "" or " (bid)"), avgBO or avgBid)
            EnhTooltip.LineColor(r,g,b)    
		end
    end
end

function lib.OnLoad()
	AucAdvanced.Settings.SetDefault("util.appraiser.model", "market")
end

function lib.CanSupplyMarket()
	return false
end

function lib.GetPrice(link, serverKey, match)
	local sig = lib.GetSigFromLink(link)
	local curModel, curModelText
	
	if not sig then
       	return 0, 0, false, 0, "Unknown", "", 0, 0, 0
	end
	
	curModel = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".model") or "default"
	curModelText = curModel
	local duration = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".duration") or AucAdvanced.Settings.GetSetting("util.appraiser.duration")
	
	if match then
		match = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".match")
		if match == nil then
			match = AucAdvanced.Settings.GetSetting("util.appraiser.match")
		end
	end
	
	local newBuy, newBid, seen, _, DiffFromModel, MatchString
	if curModel == "default" then
		curModel = AucAdvanced.Settings.GetSetting("util.appraiser.model") or "market"
		if curModel == "market" then
			newBuy, seen = AucAdvanced.API.GetMarketValue(link, serverKey)
		else
			newBuy, seen = AucAdvanced.API.GetAlgorithmValue(curModel, link, serverKey)
		end
		if (not newBuy) or (newBuy == 0) then
			curModel = AucAdvanced.Settings.GetSetting("util.appraiser.altModel")
			if curModel == "market" then
				newBuy, seen = AucAdvanced.API.GetMarketValue(link, serverKey)
			else
				newBuy, seen = AucAdvanced.API.GetAlgorithmValue(curModel, link, serverKey)
			end
		end
		curModelText = curModelText.."("..curModel..")"
	elseif curModel == "fixed" then
		newBuy = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".fixed.buy")
		newBid = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".fixed.bid")
		seen = 99
	elseif curModel == "market" then
		newBuy, seen = AucAdvanced.API.GetMarketValue(link, serverKey)
	else
		newBuy, seen = AucAdvanced.API.GetAlgorithmValue(curModel, link, serverKey)
	end
	if match then
		local biddown
		if curModel == "fixed" then
			if newBuy and newBuy > 0 then
				biddown = newBid/newBuy
				newBuy, _, _, DiffFromModel, MatchString = AucAdvanced.API.GetBestMatch(link, newBuy, serverKey)
				newBid = newBuy * biddown
			end
		else
			newBuy, _, _, DiffFromModel, MatchString = AucAdvanced.API.GetBestMatch(link, newBuy, serverKey)
		end
	end
	if curModel ~= "fixed" then
		if newBuy and not newBid then
			local markdown = math.floor(AucAdvanced.Settings.GetSetting("util.appraiser.bid.markdown") or 0)/100
			local subtract = AucAdvanced.Settings.GetSetting("util.appraiser.bid.subtract") or 0
			local deposit = AucAdvanced.Settings.GetSetting("util.appraiser.bid.deposit") or false
			if deposit then
				local rate = AucAdvanced.depositRate or 0.05
				local newfaction
				if rate == .25 then newfaction = "neutral" end
				deposit = GetDepositCost(link, 12, newfaction)
			end
			if (not deposit) then deposit = 0 end
			
			--scale up for duration > 12 hours
			if deposit > 0 then
				deposit = deposit * duration/720
			end
			
			markdown = newBuy * markdown
			newBid = math.max(newBuy - markdown - subtract - deposit, 1)
		end
		
		if not newBid then
			newBid = 0
		end
		if GetSellValue and AucAdvanced.Settings.GetSetting("util.appraiser.bid.vendor") then
			local vendor = (GetSellValue(link) or 0)
			if vendor and vendor>0 then
				vendor = math.ceil(vendor / (1 - (AucAdvanced.cutRate or 0.05)))
				if newBid < vendor then
					newBid = vendor
				end
			end
		end

		
		if newBid and (not newBuy or newBid > newBuy) then
			newBuy = newBid
		end
	end

	local stack = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".stack") or AucAdvanced.Settings.GetSetting("util.appraiser.stack")
	local number = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".number") or AucAdvanced.Settings.GetSetting("util.appraiser.number")
		
	if stack == "max" then
		_, _, _, _, _, _, _, stack = GetItemInfo(link)
	end
	if number == "maxplus" then
		number = -1
	elseif number == "maxfull" then
		number = -2
	end
	stack = tonumber(stack)
	number = tonumber(number)
--	if (type(stack) ~= "number") or (type(number) ~= "number") then
--		print("Stack: "..stack.."  Number: "..number)
--		print("Stack: "..type(stack).."  Number: "..type(number))
--	end
	if not newBuy then
		newBuy = 0
	end
	newBid = math.floor((newBid or 0) + 0.5)
	newBuy = math.floor((newBuy or 0) + 0.5)
	return newBuy, newBid, false, seen, curModelText, MatchString, stack, number, duration
end

function lib.GetPriceColumns()
	return "Buyout", "Bid", false, "seen", "curModelText", "MatchString", "Stack", "Number", "Duration"
end

local array = {}
--returns pricing and posting settings
function lib.GetPriceArray(link, _, match)
	while (#array > 0) do table.remove(array) end
	
	local newBuy, newBid, _, seen, curModelText, MatchString, stack, number, duration = lib.GetPrice(link, _, match)
	
	array.price = newBuy
	array.seen = seen
	
	array.stack = stack
	array.number = number
	array.duration = duration
	
	return array
end

function lib.GetOwnAuctionDetails()
    local results = {}
    local counts = {}		
    local numBatchAuctions, totalAuctions = GetNumAuctionItems("owner");
    if totalAuctions >0 then
	for i=1, totalAuctions do
		local name, _, count, _, _, _, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner  = GetAuctionItemInfo("owner", i)
		if name then
        if not results[name] then
            results[name] = {}
            counts[name] = {}
		end
		local r = results[name][count] 
		if not r then
			r = { stackCount=0, countBid=0, sumBid=0, countBO=0, sumBO=0 }
			results[name][count] = r
			tinsert(counts[name], count)
		end
		if (minBid or 0)>0 then
			r.countBid = r.countBid + count
            r.sumBid = r.sumBid + bidAmount
        end
        if (buyoutPrice or 0)>0 then
            r.countBO = r.countBO + count
            r.sumBO = r.sumBO + buyoutPrice
        end
        r.stackCount = r.stackCount + 1
        end
    end
    end
    lib.ownResults = results
    lib.ownCounts = counts
end



AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/RC_5.0/Auc-Util-Appraiser/Appraiser.lua $", "$Rev: 3520 $")
