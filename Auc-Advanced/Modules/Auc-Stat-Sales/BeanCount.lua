--[[
	Auctioneer Advanced - Price Level Utility module
	Version: 5.0.0 (BillyGoat)
	Revision: $Id: BeanCount.lua 3540 2008-10-02 03:41:29Z Nechckn $
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

local libType, libName = "Stat", "Sales"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()

local cache = {}
-- don't recalc time every query, that would be ridiculous
local currenttime = time()
local day3time = currenttime - 3*86400
local day7time = currenttime - 7*86400

function private.onEvent(frame, event, arg, ...)
	if (event == "MAIL_CLOSED") then
        -- Clear cache
		cache = {}
	end
end

local BellCurve = AucAdvanced.API.GenerateBellCurve();
-----------------------------------------------------------------------------------
-- The PDF for standard deviation data, standard bell curve
-----------------------------------------------------------------------------------
function lib.GetItemPDF(hyperlink, faction, realm)
	if not get("stat.sales.enable") then return end
    -- Get the data
	local average, mean, stddev, variance, confidence, bought, sold, boughtqty, soldqty, boughtseen, soldseen, bought3, sold3, boughtqty3, soldqty3, bought7, sold7, boughtqty7, soldqty7 = lib.GetPrice(hyperlink, faction, realm)
   
    -- If the standard deviation is zero, we'll have some issues, so we'll estimate it by saying
    -- the std dev is 100% of the mean divided by square root of number of views
 	if stddev == 0 then stddev = mean / sqrt(soldqty); end

    if not (mean and stddev) or mean == 0 or stddev == 0 then
        return nil;                 -- No data, cannot determine pricing
    end
    
    local lower, upper = mean - 3 * stddev, mean + 3 * stddev;
    
    -- Build the PDF based on standard deviation & mean
    BellCurve:SetParameters(mean, stddev);
    return BellCurve, lower, upper;   -- This has a __call metamethod so it's ok
end

-----------------------------------------------------------------------------------
local ZValues = {.063, .126, .189, .253, .319, .385, .454, .525, .598, .675, .756, .842, .935, 1.037, 1.151, 1.282, 1.441, 1.646, 1.962, 20, 20000}
function private.GetCfromZ(Z)
	--C = 0.05*i
	if (not Z) then
		return .05
	end
	if (Z > 10) then
		return .99
	end
	local i = 1
	while Z > ZValues[i] do
		i = i + 1
	end
	if i == 1 then
		return .05
	else
		i = i - 1 + ((Z - ZValues[i-1]) / (ZValues[i] - ZValues[i-1]))
		return i*0.05
	end
end

function lib.GetSigFromLink(link)
	local sig
	local itype, id, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(link)
	if itype == "item" then
		if enchant ~= 0 then
			sig = ("%d:%d:%d:%d"):format(id, suffix, factor, enchant)
		elseif factor ~= 0 then
			sig = ("%d:%d:%d"):format(id, suffix, factor)
		elseif suffix ~= 0 then
			sig = ("%d:%d"):format(id, suffix)
		else
			sig = tostring(id)
		end
	else
		print("Link is not item")
	end
	return sig
end

local settings = nil
function lib.GetPrice(hyperlink, faction, realm)
	if not get("stat.sales.enable") then return end
    if not (BeanCounter) or not (BeanCounter.API) or not (BeanCounter.API.isLoaded) then return false end
    if not settings then
        -- faction seems to be nil when passed in
        faction = UnitFactionGroup("player"):lower() 
        settings = {["selectbox"] = {"1", faction} , ["bid"] =true, ["auction"] = true, ["exact"] = true}
    end
    local sig = lib.GetSigFromLink(hyperlink)
  	if cache[sig] == false then
		return
	end
	if cache[sig] then
		return unpack(cache[sig])
	end
		local tbl = BeanCounter.API.search(hyperlink, settings, true, 99999)
    local bought, sold, boughtseen, soldseen, boughtqty, soldqty, bought3, sold3, boughtqty3, soldqty3, bought7, sold7, boughtqty7, soldqty7 = 0,0,0,0,0,0,0,0,0,0,0,0,0,0
    local i,v, reason, qty, priceper, thistime
    if tbl then
        for i,v in pairs(tbl) do
            -- local itemLink, reason, bid, buy, net, qty, priceper, seller, deposit, fee, wealth, date = v
            -- true price per = (net+fee-deposit)/Qty
--1 [Void Crystal]
--2 Won on Buyout
--3 1650000
--4 1650000
--5 0
--6 20
--7 82500
--8 Yyzer
--9 0
--10 0
--11 10387318
--12 1198401769
            reason, qty, priceper, thistime = v[2], v[6], v[7], v[12]
            thistime = tonumber(thistime)
            if priceper and qty and priceper>0 and qty>0 then
                if reason == "Won on Buyout" or reason == "Won on Bid" then
                    boughtqty = boughtqty + qty
                    bought = bought + priceper*qty
                    boughtseen = boughtseen + 1
                    if thistime >= day3time then
                        boughtqty3 = boughtqty3 + qty
                        bought3 = bought3 + priceper*qty
                    end
                    if thistime >= day7time then
                        boughtqty7 = boughtqty7 + qty
                        bought7 = bought7 + priceper*qty
                    end
                elseif reason == "Auc Successful" then
                    soldqty = soldqty + qty
                    sold = sold + priceper*qty
                    soldseen = soldseen + 1
                    if thistime >= day3time then
                        soldqty3 = soldqty3 + qty
                        sold3 = sold3 + priceper*qty
                    end
                    if thistime >= day7time then
                        soldqty7 = soldqty7 + qty
                        sold7 = sold7 + priceper*qty
                    end 
                end
            end
        end
        if boughtqty>0 then bought = bought / boughtqty end
        if soldqty>0 then sold = sold / soldqty end
        if boughtqty3>0 then bought3 = bought3 / boughtqty3 end
        if soldqty3>0 then sold3 = sold3 / soldqty3 end
        if boughtqty7>0 then bought7 = bought7 / boughtqty7 end
        if soldqty7>0 then sold7 = sold7 / soldqty7 end
    end
    if (not sold or sold==0) and (not bought or bought==0) then cache[sig]=false; return end
    -- Start StdDev calculations
    local mean = sold
    -- Calculate Variance
    local variance = 0
    local count = 0
    
    for i,v in pairs(tbl) do -- We do multiple passes, but creating a slimmer table would be more memory manipulation and not necessarily faster
    	reason, qty, priceper, thistime = v[2], v[6], v[7], v[12]
        if priceper and qty and priceper>0 and qty>0 and reason == "Auc Successful" then
            variance = variance + ((mean - priceper) ^ 2);
            count = count + 1
        end
	end
	variance = variance / count;
	local stdev = variance ^ 0.5
		
	local deviation = 1.5 * stdev
	
	-- Trim down to those within 1.5 stddev
    local number = 0
    local total = 0
    for i,v in pairs(tbl) do -- We do multiple passes, but creating a slimmer table would be more memory manipulation and not necessarily faster
    	reason, qty, priceper, thistime = v[2], v[6], v[7], v[12]
        if priceper and qty and priceper>0 and qty>0 and reason == "Auc Successful" then
        	if (math.abs(priceper - mean) < deviation) then
			    total = total + priceper * qty
			    number = number + qty
		    end
		end
	end

	local confidence = .01

	local average
	if (number > 0) then
		average = total / number
		confidence = (.15*average)*(number^0.5)/(stdev)
		confidence = private.GetCfromZ(confidence)
	end
    	
    
    cache[sig] = {average, mean, stdev, variance, confidence, bought, sold, boughtqty, soldqty, boughtseen, soldseen, bought3, sold3, boughtqty3, soldqty3, bought7, sold7, boughtqty7, soldqty7}
    return average, mean, stdev, variance, confidence, bought, sold, boughtqty, soldqty, boughtseen, soldseen, bought3, sold3, boughtqty3, soldqty3, bought7, sold7, boughtqty7, soldqty7
end

function lib.GetPriceColumns()
    if not (BeanCounter) or not (BeanCounter.API) or not (BeanCounter.API.isLoaded) then return end
	return "Average", "Mean","Std Deviation", "Variance", "Confidence", "Bought Price", "Sold Price", "Bought Quantity", "Sold Quantity", "Bought Times", "Sold Times", "3day Bought Price", "3day Sold Price", "3day Bought Quantity", "3day Sold Quantity", "7day Bought Price", "7day Sold Price", "7day Bought Quantity", "7day Sold Quantity"
end

local array = {}
function lib.GetPriceArray(hyperlink, faction, realm)
	if not get("stat.sales.enable") then return end
	if not (BeanCounter) or not (BeanCounter.API) or not (BeanCounter.API.isLoaded) then return end
    -- Clean out the old array
	while (#array > 0) do table.remove(array) end

    -- Get our statistics
	local average, mean, stdev, variance, confidence, bought, sold, boughtqty, soldqty, boughtseen, soldseen, bought3, sold3, boughtqty3, soldqty3, bought7, sold7, boughtqty7, soldqty7 = lib.GetPrice(hyperlink, faction, realm)
    if not bought and not sold then return end
   	-- These are the ones that most algorithms will look for
	array.price = average or mean
	array.confidence = confidence
	-- This is additional data
	array.normalized = average
	array.mean = mean
	array.deviation = stdev
	array.variance = variance
	
    array.boughtseen = boughtseen
    array.soldseen = soldseen
    array.bought = bought
	array.sold = sold
    array.boughtqty = boughtqty
    array.soldqty = soldqty
    array.seen = boughtseen
    if soldseen then array.seen = array.seen+soldseen end
    array.bought3 = bought3
	array.sold3 = sold3
    array.boughtqty3 = boughtqty3
    array.soldqty3 = soldqty3
    array.bought7 = bought7
	array.sold7 = sold7
    array.boughtqty7 = boughtqty7
    array.soldqty7 = soldqty7

	return array
end

function lib.ClearItem(hyperlink, faction, realm)
	print(libType.."-"..libName.." does not store data itself. It uses your Beancounter data.")
end

function lib.OnLoad(addon)
	AucAdvanced.Settings.SetDefault("stat.sales.tooltip", false)
    AucAdvanced.Settings.SetDefault("stat.sales.avg", true)
    AucAdvanced.Settings.SetDefault("stat.sales.avg3", false)
    AucAdvanced.Settings.SetDefault("stat.sales.avg7", false)
    AucAdvanced.Settings.SetDefault("stat.sales.normal", true)
    AucAdvanced.Settings.SetDefault("stat.sales.stddev", false)
    AucAdvanced.Settings.SetDefault("stat.sales.confidence", false)
   	AucAdvanced.Settings.SetDefault("stat.sales.enable", true)
end

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		private.ProcessTooltip(...)
	elseif (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
	elseif (callbackType == "load") then
		lib.OnLoad(...)
	end
end

function private.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine whether or what you should
	-- display in the tooltip.
	
	if not AucAdvanced.Settings.GetSetting("stat.sales.tooltip") or not (BeanCounter) or not (BeanCounter.API) or not (BeanCounter.API.isLoaded) then return end --If beancounter disabled itself, boughtseen etc are nil and throw errors
	
	local average, mean, stdev, variance, confidence, bought, sold, boughtqty, soldqty, boughtseen, soldseen, bought3, sold3, boughtqty3, soldqty3, bought7, sold7, boughtqty7, soldqty7 = lib.GetPrice(hyperlink)
	if not bought and not sold then return end
    if (boughtseen+soldseen>0) then
		EnhTooltip.AddLine(libName.." prices:")
		EnhTooltip.LineColor(0.3, 0.9, 0.8)
    
        if AucAdvanced.Settings.GetSetting("stat.sales.avg") then
            if (boughtseen > 0) then
                EnhTooltip.AddLine("  Total Bought |cffddeeff"..(boughtqty).."|r at avg each", bought)
                EnhTooltip.LineColor(0.3, 0.9, 0.8)
            end
            if (soldseen > 0) then
                EnhTooltip.AddLine("  Total Sold |cffddeeff"..(soldqty).."|r at avg each", sold)
                EnhTooltip.LineColor(0.3, 0.9, 0.8)
            end
        end 
        if AucAdvanced.Settings.GetSetting("stat.sales.avg7") then
            if (boughtqty7 > 0) then
                EnhTooltip.AddLine("  7 Days Bought |cffddeeff"..(boughtqty7).."|r at avg each", bought7)
                EnhTooltip.LineColor(0.3, 0.9, 0.8)
            end
            if (soldqty7 > 0) then
                EnhTooltip.AddLine("  7 Days Sold |cffddeeff"..(soldqty7).."|r at avg each", sold7)
                EnhTooltip.LineColor(0.3, 0.9, 0.8)
            end
        end
        if AucAdvanced.Settings.GetSetting("stat.sales.avg3") then
            if (boughtqty3 > 0) then
                EnhTooltip.AddLine("  3 Days Bought |cffddeeff"..(boughtqty3).."|r at avg each", bought3)
                EnhTooltip.LineColor(0.3, 0.9, 0.8)
            end
            if (soldqty3 > 0) then
                EnhTooltip.AddLine("  3 Days Sold |cffddeeff"..(soldqty3).."|r at avg each", sold3)
                EnhTooltip.LineColor(0.3, 0.9, 0.8)
            end
        end
        if (average and average > 0) then
			if AucAdvanced.Settings.GetSetting("stat.sales.normal") then
				EnhTooltip.AddLine("  Normalized (stack)", average*quantity)
				EnhTooltip.LineColor(0.3, 0.9, 0.8)
				if (quantity > 1) then
					EnhTooltip.AddLine("  (or individually)", average)
					EnhTooltip.LineColor(0.3, 0.9, 0.8)
				end
			end
			if AucAdvanced.Settings.GetSetting("stat.sales.stdev") then
				EnhTooltip.AddLine("  Std Deviation", stdev*quantity)
				EnhTooltip.LineColor(0.3, 0.9, 0.8)
                if (quantity > 1) then
                    EnhTooltip.AddLine("  (or individually)", stdev)
                    EnhTooltip.LineColor(0.3, 0.9, 0.8);
                end
                    
			end
			if AucAdvanced.Settings.GetSetting("stat.sales.confid") then
				EnhTooltip.AddLine("  Confidence: "..(floor(confidence*1000))/1000)
				EnhTooltip.LineColor(0.3, 0.9, 0.8)
			end
		end

	end
end

function private.SetupConfigGui(gui)
	local id = gui:AddTab(lib.libName, lib.libType.." Modules")

	gui:AddHelp(id, "what sales stats",
		"What are sales stats?",
		"Sales stats are the numbers that are generated by the sales module from the "..
		"BeanCounter database. It averages all of the prices for items that you have sold")
	
	gui:AddControl(id, "Header",     0,    libName.." options")
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	
	gui:AddControl(id, "Checkbox",   0, 1, "stat.sales.enable", "Enable Sales Stats")
	gui:AddTip(id, "Allow Sales to contribute to Market Price.")
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.sales.tooltip", "Show sales stats in the tooltips?")
	gui:AddTip(id, "Toggle display of stats from the Sales module on or off")
	gui:AddControl(id, "Checkbox",   0, 2, "stat.sales.avg3", "Display Moving 3 Day Mean")
   	gui:AddTip(id, "Toggle display of 3-Day mean from the Sales module on or off")
	gui:AddControl(id, "Checkbox",   0, 2, "stat.sales.avg7", "Display Moving 7 Day Mean")
	gui:AddTip(id, "Toggle display of 7-Day mean from the Sales module on or off")
	gui:AddControl(id, "Checkbox",   0, 2, "stat.sales.avg", "Display Overall Mean")
	gui:AddTip(id, "Toggle display of Permanent mean from the Sales module on or off")
	gui:AddControl(id, "Checkbox",   0, 2, "stat.sales.normal", "Display Normalized")
	gui:AddTip(id, "Toggle display of 'Normalized' calculation in tooltips on or off")
	gui:AddControl(id, "Checkbox",   0, 2, "stat.sales.stdev", "Display Standard Deviation")
	gui:AddTip(id, "Toggle display of 'Standard Deviation' calculation in tooltips on or off")
	gui:AddControl(id, "Checkbox",   0, 2, "stat.sales.confid", "Display Confidence")
	gui:AddTip(id, "Toggle display of 'Confidence' calculation in tooltips on or off")

	end
    
--[[Bootstrap Code]]
private.scriptframe = CreateFrame("Frame")
private.scriptframe:SetScript("OnEvent", private.onEvent)


AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/RC_5.0/Auc-Stat-Sales/BeanCount.lua $", "$Rev: 3540 $")
