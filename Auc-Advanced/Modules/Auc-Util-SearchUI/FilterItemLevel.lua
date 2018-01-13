--[[
	Auctioneer Advanced - Search UI - Filter IgnoreItemQuality
	Version: 5.0.0 (BillyGoat)
	Revision: $Id: FilterItemLevel.lua 3277 2008-07-28 12:04:47Z Norganna $
	URL: http://auctioneeraddon.com/

	This is a plugin module for the SearchUI that assists in searching by refined paramaters

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
-- Create a new instance of our lib with our parent
local lib, parent, private = AucSearchUI.NewFilter("ItemLevel")
if not lib then return end
local print,decode,_,_,replicate,empty,_,_,_,debugPrint,fill = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "ItemLevel"
-- Set our defaults
default("ignoreitemlevel.enable", false)

local typename = {
	[1] = "Armor",
	[2] = "Consumable",
	[3] = "Container",
	[4] = "Gem",
	[5] = "Key",
	[6] = "Miscellaneous",
	[7] = "Reagent",
	[8] = "Recipe",
	[9] = "Projectile",
	[10] = "Quest",
	[11] = "Quiver",
	[12] = "Trade Goods",
	[13] = "Weapon",
}

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Filters")
	gui:MakeScrollable(id)

	gui:AddControl(id, "Header",     0,      "ItemLevel Filter Criteria")
	
	gui:AddControl(id, "Checkbox",    0, 1,  "ignoreitemlevel.enable", "Enable ItemLevel filtering")
	gui:AddControl(id, "Subhead",     0, "Filter for:")
	for name, searcher in pairs(AucSearchUI.Searchers) do
		if searcher and searcher.Search then
			gui:AddControl(id, "Checkbox", 0, 1, "ignoreitemlevel.filter."..name, name)
			gui:AddTip(id, "Filter Time-left when searching with "..name)
			default("ignoreitemlevel.filter."..name, false)
		end
	end

	gui:AddControl(id, "Subhead",     0,  "Minimum itemLevels by Type")
	for i = 1, 13 do
		gui:AddControl(id, "WideSlider",   0, 1, "ignoreitemlevel.minlevel."..typename[i], 1, 140, 1, "Min iLevel for "..typename[i]..": %s")
		default("ignoreitemlevel.minlevel."..typename[i], 61)
	end
end

--lib.Filter(item, searcher)
--This function will return true if the item is to be filtered
--Item is the itemtable, and searcher is the name of the searcher being called. If searcher is not given, it will assume you want it active.
function lib.Filter(item, searcher)
	if (not get("ignoreitemlevel.enable"))
			or (searcher and (not get("ignoreitemlevel.filter."..searcher))) then
		return
	end
	
	local itype = item[Const.ITYPE]
	local ilevel = item[Const.ILEVEL]

	if ilevel < get("ignoreitemlevel.minlevel."..itype) then
		return true, "ItemLevel too low"
	end
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/RC_5.0/Auc-Util-SearchUI/FilterItemLevel.lua $", "$Rev: 3277 $")
