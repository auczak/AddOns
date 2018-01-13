--[[
	Auctioneer Advanced
	Version: 5.0.0 (BillyGoat)
	Revision: $Id: CoreManifest.lua 2530 2007-11-18 22:18:59Z mentalpower $
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

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
]]

if (not AucAdvanced) then AucAdvanced = {} end
local lib = AucAdvanced

lib.revisions = {}
lib.distribution = {--[[<%revisions%>]]} --Currently unused, needs a change in the build script

function lib.RegisterRevision(path, revision)
	if (not path and revision) then
		return
	end

	local file = path:match("%$URL: .*/auctioneer/([^%$]+) %$")
	local rev = revision:match("(%d+)")

	if (not file) then
		return
	end
	rev = tonumber(rev) or 0

	lib.revisions[file] = rev
end

function lib.GetCurrentRevision()
	local revNumber = 0
	local revFile
	for file, revision in pairs(lib.revisions) do
		if (revision > revNumber) then
			revNumber = revision
			revFile = file
		end
	end

	return revNumber, revFile
end

function lib.GetRevisionList()
	return lib.revisions
end

function lib.GetDistributionList()
	return lib.distribution
end

function lib.ValidateInstall()
	return true --NoOp for the moment
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/RC_5.0/Auc-Advanced/CoreManifest.lua $", "$Rev: 2530 $")