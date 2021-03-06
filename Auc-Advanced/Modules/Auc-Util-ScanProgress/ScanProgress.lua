--[[
	Auctioneer Advanced - Price Level Utility module
	Version: 5.0.0 (BillyGoat)
	Revision: $Id: ScanProgress.lua 3470 2008-09-08 00:10:16Z anaral $
	URL: http://auctioneeraddon.com/

	This is an Auctioneer Advanced module that adds a textual scan progress
	indicator to the Auction House UI.

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

local libType, libName = "Util", "ScanProgress"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()

function lib.Processor(callbackType, ...)
	if (callbackType == "scanprogress") then
		private.UpdateScanProgress(...)
	elseif (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif (callbackType == "configchanged") then
		private.ConfigChanged(...)
	end
end

function lib.OnLoad()
	--print("AucAdvanced: {{"..libType..":"..libName.."}} loaded!")
	AucAdvanced.Settings.SetDefault("util.scanprogress.activated", true)
	AucAdvanced.Settings.SetDefault("util.scanprogress.leaveshown", true)
end

----  Functions to manage the progress indicator ----
private.scanStartTime = time()
private.scanProgressFormat = "Auctioneer Advanced: %s\nScanning page %d of %d\n\nAuctions per second: %.2f\nAuctions scanned thus far: %d\n\nEstimated time left: %s\nElapsed scan time: %s"

function private.UpdateScanProgress(state, totalAuctions, scannedAuctions, elapsedTime)
	--Check that we're enabled before passing on the callback
	if not AucAdvanced.Settings.GetSetting("util.scanprogress.activated")

	--Check to see if browseoverride has been set, if so gracefully allow it to continue as is
	or AucAdvanced.Settings.GetSetting("util.browseoverride.activated") then
		state = false
	end

	--Change the state if we have not scanned any auctions yet.
	--This is done so that we don't start the timer too soon and thus get skewed numbers
	if (state == nil and (
		not scannedAuctions or
		scannedAuctions == 0 or
		not AucAdvanced.API.IsBlocked() or
		BrowseButton1:IsVisible()
	)) then
		state = true
	end

	--Distribute the callback according to the value of the state variable
	if (state == false) then
		if AucAdvanced.API.IsBlocked() then
			private.HideScanProgressUI()
		end
		return
	elseif (state == true) then
		private.ShowScanProgressUI(totalAuctions)
	end
	if scannedAuctions and scannedAuctions > 0 then
		private.UpdateScanProgressUI(totalAuctions, scannedAuctions, elapsedTime)
	end
end

function private.ShowScanProgressUI(totalAuctions)
	for i=1, NUM_BROWSE_TO_DISPLAY do
		_G["BrowseButton"..i]:Hide()
	end
	BrowseNoResultsText:Show()
	private.scanStartTime = time()
	if totalAuctions and totalAuctions > 0 then
		BrowseNoResultsText:SetText(("Scanning %d items..."):format(totalAuctions))
	else
		BrowseNoResultsText:SetText("Scanning...")
	end
	AucAdvanced.API.BlockUpdate(true, true)
end

function private.HideScanProgressUI()
	if (AucAdvanced.Settings.GetSetting("util.scanprogress.leaveshown")) then
		AucAdvanced.API.BlockUpdate(false, false)
	else
		BrowseNoResultsText:Hide()
		BrowseNoResultsText:SetText(SEARCHING_FOR_ITEMS)

		local numBatchAuctions, totalAuctions = GetNumAuctionItems("list")
		local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
		for i=1, NUM_BROWSE_TO_DISPLAY do
			index = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)
			if ( index > (numBatchAuctions + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)) ) then
				_G["BrowseButton"..i]:Hide()
			else
				_G["BrowseButton"..i]:Show()
			end
		end
		AucAdvanced.API.BlockUpdate(false, true)
	end
end

function private.UpdateScanProgressUI(totalAuctions, scannedAuctions, elapsedTime)
	local numAuctionsPerPage = NUM_AUCTION_ITEMS_PER_PAGE

	-- Prefer the elapsed time which is provided by core and excludes paused time.
	local secondsElapsed = elapsedTime or (time() - private.scanStartTime)

	local auctionsToScan = totalAuctions - scannedAuctions

	local currentPage = math.floor(scannedAuctions / numAuctionsPerPage)
	
	local totalPages = totalAuctions / numAuctionsPerPage
	if (totalPages - math.floor(totalPages) > 0) then
		totalPages = math.ceil(totalPages)
	else
		totalPages = math.floor(totalPages)
	end

	local auctionsScannedPerSecond = scannedAuctions / secondsElapsed
	local secondsToScanCompletion = auctionsToScan / auctionsScannedPerSecond

	BrowseNoResultsText:SetText(
		private.scanProgressFormat:format(
			"Scanning auctions.",
			currentPage + 1,
			totalPages,
			auctionsScannedPerSecond,
			scannedAuctions,
			SecondsToTime(secondsToScanCompletion),
			SecondsToTime(secondsElapsed)
		)
	)
end

--Config UI functions
function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	local id = gui:AddTab(libName, libType.." Modules")
	gui:AddControl(id, "Header",     0,    libName.." options")

	gui:AddHelp(id, "what scanprogress",
		"What is the Scan Progress indicator?",
		"The Scan Progress indicator is the text that appears while scanning the Auction House. It displays:  the speed of the scan, current auctions and total number of auctions scanned, aswell as the current number of pages and total pages scanned.")

--	Old answer, incase the new one is too short and/or vague.
--		"The Scan Progress indicator is the text that appears while scanning the Auction House, indicating "..
--		"how fast you are scanning, how many auctions you have scanned so far, how many total auctions there are, "..
--		"how many pages you have scanned so far, and how many total pages there are.")

	gui:AddControl(id, "Checkbox",   0, 1, "util.scanprogress.activated", "Show a textual progress indicator when scanning.")
	gui:AddTip(id, "If enabled, will show the scan progress indicator")
	gui:AddControl(id, "Checkbox",   0, 1, "util.scanprogress.leaveshown", "Leave the scan progress text shown after scan completion.")
	gui:AddTip(id, "If enabled, will leave the scan progress indicator on the screen after scan has completed.\n\nIf disabled will show the last scanned page.")
end

function private.ConfigChanged()
	if (not AucAdvanced.Settings.GetSetting("util.scanprogress.activated")) then
		private.UpdateScanProgress(false)
	elseif (AucAdvanced.Scan.IsScanning()) then
		private.UpdateScanProgress(true)
	end
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/RC_5.0/Auc-Util-ScanProgress/ScanProgress.lua $", "$Rev: 3470 $")
