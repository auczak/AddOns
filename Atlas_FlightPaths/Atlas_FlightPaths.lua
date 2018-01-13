--[[

	Atlas, a World of Warcraft instance map browser
	Copyright 2005 - 2008 Dan Gilbert
	Email me at loglow@gmail.com

	This file is part of Atlas.

	Atlas is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	Atlas is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Atlas; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

--]]

local BLUE = "|cff6666ff";
local GREY = "|cff999999";
local GREN = "|cff66cc33";
local _RED = "|cffcc6666";
local ORNG = "|cffcc9933";
local PURP = "|cff9900ff";
local INDENT = "      ";

local ZONE = 1;
local NPC = 2;
local ITEM = 3;
local OBJECT = 4;
local FACTION = 5;
local QUEST = 6;

--Now with GUIDs!

local myCategory = AtlasFPLocale["Flight Path Maps"];

local myData = {
	FPAllianceEast = {
		ZoneName = { AtlasFPLocale["Alliance"].." ("..AtlasFPLocale["Eastern Kingdoms"]..")" };
		Location = { AtlasFPLocale["Eastern Kingdoms"] };
		{ GREY.."1) "..AtlasFPLocale["Sun's Reach"]..", ".._RED..AtlasFPLocale["Isle of Quel'Danas"], ZONE, 4080 };
		{ GREY.."2) "..AtlasFPLocale["Hatchet Hills"]..", ".._RED..AtlasFPLocale["Ghostlands"], ZONE, 3433 };
		{ GREY.."3) "..AtlasFPLocale["Light's Hope Chapel"]..", ".._RED..AtlasFPLocale["Eastern Plaguelands"], ZONE, 139 };
		{ GREY.."4) "..AtlasFPLocale["Chillwind Point"]..", ".._RED..AtlasFPLocale["Western Plaguelands"], ZONE, 28 };
		{ GREY.."5) "..AtlasFPLocale["Aerie Peak"]..", ".._RED..AtlasFPLocale["The Hinterlands"], ZONE, 47 };
		{ GREY.."6) "..AtlasFPLocale["Southshore"]..", ".._RED..AtlasFPLocale["Hillsbrad Foothills"], ZONE, 267 };
		{ GREY.."7) "..AtlasFPLocale["Refuge Pointe"]..", ".._RED..AtlasFPLocale["Arathi Highlands"], ZONE, 45 };
		{ GREY.."8) "..AtlasFPLocale["Menethil Harbor"]..", ".._RED..AtlasFPLocale["Wetlands"], ZONE, 11 };
		{ GREY.."9) "..AtlasFPLocale["Ironforge"]..", ".._RED..AtlasFPLocale["Dun Morogh"], ZONE, 1 };
		{ GREY.."10) "..AtlasFPLocale["Thelsamar"]..", ".._RED..AtlasFPLocale["Loch Modan"], ZONE, 38 };
		{ GREY.."11) "..AtlasFPLocale["Thorium Point"]..", ".._RED..AtlasFPLocale["Searing Gorge"], ZONE, 51 };
		{ GREY.."12) "..AtlasFPLocale["Morgan's Vigil"]..", ".._RED..AtlasFPLocale["Burning Steppes"], ZONE, 46 };
		{ GREY.."13) "..AtlasFPLocale["Stormwind City"]..", ".._RED..AtlasFPLocale["Elwynn Forest"], ZONE, 12 };
		{ GREY.."14) "..AtlasFPLocale["Lakeshire"]..", ".._RED..AtlasFPLocale["Redridge Mountains"], ZONE, 44 };
		{ GREY.."15) "..AtlasFPLocale["Sentinel Hill"]..", ".._RED..AtlasFPLocale["Westfall"], ZONE, 40 };
		{ GREY.."16) "..AtlasFPLocale["Darkshire"]..", ".._RED..AtlasFPLocale["Duskwood"], ZONE, 10 };
		{ GREY.."17) "..AtlasFPLocale["Nethergarde Keep"]..", ".._RED..AtlasFPLocale["Blasted Lands"], ZONE, 4 };
		{ GREY.."18) "..AtlasFPLocale["Rebel Camp"]..", ".._RED..AtlasFPLocale["Stranglethorn Vale"], ZONE, 33 };
		{ GREY.."19) "..AtlasFPLocale["Booty Bay"]..", ".._RED..AtlasFPLocale["Stranglethorn Vale"], ZONE, 33 };
	};
	FPAllianceWest = {
		ZoneName = { AtlasFPLocale["Alliance"].." ("..AtlasFPLocale["Kalimdor"]..")" };
		Location = { AtlasFPLocale["Kalimdor"] };
		{ GREY.."1) "..AtlasFPLocale["Rut'Theran Village"]..", ".._RED..AtlasFPLocale["Teldrassil"], ZONE, 141 };
		{ GREY.."2) "..GREN..AtlasFPLocale["Nighthaven"]..GREY..", ".._RED..AtlasFPLocale["Moonglade"]..GREN.." ("..AtlasFPLocale["Druid-only"]..")", ZONE, 493 };
		{ GREY.."3) "..AtlasFPLocale["South of the path along Lake Elune'ara"]..", ".._RED..AtlasFPLocale["Moonglade"], ZONE, 493 };
		{ GREY.."4) "..AtlasFPLocale["Everlook"]..", ".._RED..AtlasFPLocale["Winterspring"], ZONE, 618 };
		{ GREY.."5) "..AtlasFPLocale["Auberdine"]..", ".._RED..AtlasFPLocale["Darkshore"], ZONE, 148 };
		{ GREY.."6) "..AtlasFPLocale["Talonbranch Glade"]..", ".._RED..AtlasFPLocale["Felwood"], ZONE, 361 };
		{ GREY.."7) "..AtlasFPLocale["Emerald Sanctuary"]..", ".._RED..AtlasFPLocale["Felwood"], ZONE, 361 };
		{ GREY.."8) "..AtlasFPLocale["Stonetalon Peak"]..", ".._RED..AtlasFPLocale["Stonetalon Mountains"], ZONE, 406 };
		{ GREY.."9) "..AtlasFPLocale["Astranaar"]..", ".._RED..AtlasFPLocale["Ashenvale"], ZONE, 331 };
		{ GREY.."10) "..AtlasFPLocale["Forest Song"]..", ".._RED..AtlasFPLocale["Ashenvale"], ZONE, 331 };
		{ GREY.."11) "..AtlasFPLocale["Talrendis Point"]..", ".._RED..AtlasFPLocale["Azshara"], ZONE, 16 };
		{ GREY.."12) "..AtlasFPLocale["Nijel's Point"]..", ".._RED..AtlasFPLocale["Desolace"], ZONE, 405 };
		{ GREY.."13) "..AtlasFPLocale["Ratchet"]..", ".._RED..AtlasFPLocale["The Barrens"], ZONE, 17 };
		{ GREY.."14) "..AtlasFPLocale["Theramore Isle"]..", ".._RED..AtlasFPLocale["Dustwallow Marsh"], ZONE, 15 };
		{ GREY.."15) "..AtlasFPLocale["Mudsprocket"]..", ".._RED..AtlasFPLocale["Dustwallow Marsh"], ZONE, 15 };
		{ GREY.."16) "..AtlasFPLocale["Feathermoon Stronghold"]..", ".._RED..AtlasFPLocale["Feralas"], ZONE, 357 };
		{ GREY.."17) "..AtlasFPLocale["Thalanaar"]..", ".._RED..AtlasFPLocale["Feralas"], ZONE, 357 };
		{ GREY.."18) "..AtlasFPLocale["Marshal's Refuge"]..", ".._RED..AtlasFPLocale["Un'Goro Crater"], ZONE, 490 };
		{ GREY.."19) "..AtlasFPLocale["Cenarion Hold"]..", ".._RED..AtlasFPLocale["Silithus"], ZONE, 1377 };
		{ GREY.."20) "..AtlasFPLocale["Gadgetzan"]..", ".._RED..AtlasFPLocale["Tanaris"], ZONE, 440 };
		{ GREY.."21) "..AtlasFPLocale["Blood Watch"]..", ".._RED..AtlasFPLocale["Bloodmyst Isle"], ZONE, 3525 };
		{ GREY.."22) "..AtlasFPLocale["The Exodar"]..", ".._RED..AtlasFPLocale["Azuremyst Isle"], ZONE, 3524 };
	};
	FPHordeEast = {
		ZoneName = { AtlasFPLocale["Horde"].." ("..AtlasFPLocale["Eastern Kingdoms"]..")" };
		Location = { AtlasFPLocale["Eastern Kingdoms"] };
		{ GREY.."1) "..AtlasFPLocale["Sun's Reach"]..", ".._RED..AtlasFPLocale["Isle of Quel'Danas"], ZONE, 4080 };
		{ GREY.."2) "..AtlasFPLocale["Silvermoon"]..", ".._RED..AtlasFPLocale["Eversong Woods"], ZONE, 3430 };
		{ GREY.."3) "..AtlasFPLocale["Tranquillien"]..", ".._RED..AtlasFPLocale["Ghostlands"], ZONE, 3433 };
		{ GREY.."4) "..AtlasFPLocale["Hatchet Hills"]..", ".._RED..AtlasFPLocale["Ghostlands"], ZONE, 3433 };
		{ GREY.."5) "..AtlasFPLocale["Light's Hope Chapel"]..", ".._RED..AtlasFPLocale["Eastern Plaguelands"], ZONE, 139 };
		{ GREY.."6) "..AtlasFPLocale["Undercity"]..", ".._RED..AtlasFPLocale["Tirisfal Glades"], ZONE, 85 };
		{ GREY.."7) "..AtlasFPLocale["The Sepulcher"]..", ".._RED..AtlasFPLocale["Silverpine Forest"], ZONE, 130 };
		{ GREY.."8) "..AtlasFPLocale["Tarren Mill"]..", ".._RED..AtlasFPLocale["Hillsbrad Foothills"], ZONE, 267 };
		{ GREY.."9) "..AtlasFPLocale["Revantusk Village"]..", ".._RED..AtlasFPLocale["The Hinterlands"], ZONE, 47 };
		{ GREY.."10) "..AtlasFPLocale["Hammerfall"]..", ".._RED..AtlasFPLocale["Arathi Highlands"], ZONE, 45 };
		{ GREY.."11) "..AtlasFPLocale["Thorium Point"]..", ".._RED..AtlasFPLocale["Searing Gorge"], ZONE, 51 };
		{ GREY.."12) "..AtlasFPLocale["Kargath"]..", ".._RED..AtlasFPLocale["Badlands"], ZONE, 3 };
		{ GREY.."13) "..AtlasFPLocale["Flame Crest"]..", ".._RED..AtlasFPLocale["Burning Steppes"], ZONE, 46 };
		{ GREY.."14) "..AtlasFPLocale["Stonard"]..", ".._RED..AtlasFPLocale["Swamp of Sorrows"], ZONE, 8 };
		{ GREY.."15) "..AtlasFPLocale["Grom'Gol Base Camp"]..", ".._RED..AtlasFPLocale["Stranglethorn Vale"], ZONE, 33 };
		{ GREY.."16) "..AtlasFPLocale["Booty Bay"]..", ".._RED..AtlasFPLocale["Stranglethorn Vale"], ZONE, 33 };
	};
	FPHordeWest = {
		ZoneName = { AtlasFPLocale["Horde"].." ("..AtlasFPLocale["Kalimdor"]..")" };
		Location = { AtlasFPLocale["Kalimdor"] };
		{ GREY.."1) "..GREN..AtlasFPLocale["Nighthaven"]..GREY..", ".._RED..AtlasFPLocale["Moonglade"]..GREN.." ("..AtlasFPLocale["Druid-only"]..")", ZONE, 493 };
		{ GREY.."2) "..AtlasFPLocale["West of the path to Timbermaw Hold"]..", ".._RED..AtlasFPLocale["Moonglade"], ZONE, 493 };
		{ GREY.."3) "..AtlasFPLocale["Everlook"]..", ".._RED..AtlasFPLocale["Winterspring"], ZONE, 618 };
		{ GREY.."4) "..AtlasFPLocale["Bloodvenom Post"]..", ".._RED..AtlasFPLocale["Felwood"], ZONE, 361 };
		{ GREY.."5) "..AtlasFPLocale["Emerald Sanctuary"]..", ".._RED..AtlasFPLocale["Felwood"], ZONE, 361 };
		{ GREY.."6) "..AtlasFPLocale["Zoram'gar Outpost"]..", ".._RED..AtlasFPLocale["Ashenvale"], ZONE, 331 };
		{ GREY.."7) "..AtlasFPLocale["Valormok"]..", ".._RED..AtlasFPLocale["Azshara"], ZONE, 16 };
		{ GREY.."8) "..AtlasFPLocale["Splintertree Post"]..", ".._RED..AtlasFPLocale["Ashenvale"], ZONE, 331 };
		{ GREY.."9) "..AtlasFPLocale["Orgrimmar"]..", ".._RED..AtlasFPLocale["Durotar"], ZONE, 14 };
		{ GREY.."10) "..AtlasFPLocale["Sun Rock Retreat"]..", ".._RED..AtlasFPLocale["Stonetalon Mountains"], ZONE, 406 };
		{ GREY.."11) "..AtlasFPLocale["Crossroads"]..", ".._RED..AtlasFPLocale["The Barrens"], ZONE, 17 };
		{ GREY.."12) "..AtlasFPLocale["Ratchet"]..", ".._RED..AtlasFPLocale["The Barrens"], ZONE, 17 };
		{ GREY.."13) "..AtlasFPLocale["Shadowprey Village"]..", ".._RED..AtlasFPLocale["Desolace"], ZONE, 405 };
		{ GREY.."14) "..AtlasFPLocale["Thunder Bluff"]..", ".._RED..AtlasFPLocale["Mulgore"], ZONE, 215 };
		{ GREY.."15) "..AtlasFPLocale["Camp Taurajo"]..", ".._RED..AtlasFPLocale["The Barrens"], ZONE, 17 };
		{ GREY.."16) "..AtlasFPLocale["Brackenwall Village"]..", ".._RED..AtlasFPLocale["Dustwallow Marsh"], ZONE, 15 };
		{ GREY.."17) "..AtlasFPLocale["Mudsprocket"]..", ".._RED..AtlasFPLocale["Dustwallow Marsh"], ZONE, 15 };
		{ GREY.."18) "..AtlasFPLocale["Camp Mojache"]..", ".._RED..AtlasFPLocale["Feralas"], ZONE, 357 };
		{ GREY.."19) "..AtlasFPLocale["Freewind Post"]..", ".._RED..AtlasFPLocale["Thousand Needles"], ZONE, 400 };
		{ GREY.."20) "..AtlasFPLocale["Marshal's Refuge"]..", ".._RED..AtlasFPLocale["Un'Goro Crater"], ZONE, 490 };
		{ GREY.."21) "..AtlasFPLocale["Cenarion Hold"]..", ".._RED..AtlasFPLocale["Silithus"], ZONE, 1377 };
		{ GREY.."22) "..AtlasFPLocale["Gadgetzan"]..", ".._RED..AtlasFPLocale["Tanaris"], ZONE, 440 };
	};
	FPHordeOutland = {
		ZoneName = { AtlasFPLocale["Horde"].." ("..AtlasFPLocale["Outland"]..")" };
		Location = { AtlasFPLocale["Outland"] };
		{ GREY.."1) "..AtlasFPLocale["The Dark Portal"]..", ".._RED..AtlasFPLocale["Hellfire Peninsula"], ZONE, 3483 };
		{ GREY.."2) "..AtlasFPLocale["Thrallmar"]..", ".._RED..AtlasFPLocale["Hellfire Peninsula"], ZONE, 3483 };
		{ GREY.."3) "..AtlasFPLocale["Spinebreaker Post"]..", ".._RED..AtlasFPLocale["Hellfire Peninsula"], ZONE, 3483 };
		{ GREY.."4) "..AtlasFPLocale["Falcon Watch"]..", ".._RED..AtlasFPLocale["Hellfire Peninsula"], ZONE, 3483 };
		{ GREY.."5) "..AtlasFPLocale["Swamprat Post"]..", ".._RED..AtlasFPLocale["Zangarmarsh"], ZONE, 3521 };
		{ GREY.."6) "..AtlasFPLocale["Zabra'jin"]..", ".._RED..AtlasFPLocale["Zangarmarsh"], ZONE, 3521 };
		{ GREY.."7) "..AtlasFPLocale["Garadar"]..", ".._RED..AtlasFPLocale["Nagrand"], ZONE, 3518 };
		{ GREY.."8) "..AtlasFPLocale["Shattrath City"]..", ".._RED..AtlasFPLocale["Terokkar Forest"], ZONE, 3519 };
		{ GREY.."9) "..AtlasFPLocale["Stonebreaker Hold"]..", ".._RED..AtlasFPLocale["Terokkar Forest"], ZONE, 3519 };
		{ GREY.."10) "..AtlasFPLocale["Shadowmoon Village"]..", ".._RED..AtlasFPLocale["Shadowmoon Valley"], ZONE, 3520 };
		{ GREY.."11) "..AtlasFPLocale["Altar of Sha'tar"]..", ".._RED..AtlasFPLocale["Shadowmoon Valley"]..BLUE.." ("..AtlasFPLocale["The Aldor"]..")", ZONE, 3520 , FACTION, 932 };
		{ GREY.."12) "..AtlasFPLocale["Sanctum of the Stars"]..", ".._RED..AtlasFPLocale["Shadowmoon Valley"]..BLUE.." ("..AtlasFPLocale["The Scryers"]..")", ZONE, 3520 , FACTION, 934 };
		{ GREY.."13) "..AtlasFPLocale["Thunderlord Stronghold"]..", ".._RED..AtlasFPLocale["Blade's Edge Mountains"], ZONE, 3522 };
		{ GREY.."14) "..AtlasFPLocale["Evergrove"]..", ".._RED..AtlasFPLocale["Blade's Edge Mountains"], ZONE, 3522 };
		{ GREY.."15) "..AtlasFPLocale["Mok'Nathal Village"]..", ".._RED..AtlasFPLocale["Blade's Edge Mountains"], ZONE, 3522 };
		{ GREY.."16) "..AtlasFPLocale["Area 52"]..", ".._RED..AtlasFPLocale["Netherstorm"], ZONE, 3523 };
		{ GREY.."17) "..AtlasFPLocale["The Stormspire"]..", ".._RED..AtlasFPLocale["Netherstorm"], ZONE, 3523 };
		{ GREY.."18) "..AtlasFPLocale["Cosmowrench"]..", ".._RED..AtlasFPLocale["Netherstorm"], ZONE, 3523 };
		{ GREN.."1') "..AtlasFPLocale["Blackwind Landing"]..", ".._RED..AtlasFPLocale["Terokkar Forest"], ZONE, 3519 };
		{ GREN.."2') "..AtlasFPLocale["Skyguard Outpost"]..", ".._RED..AtlasFPLocale["Blade's Edge Mountains"], ZONE, 3522 };
		{ GREN..INDENT.."("..AtlasFPLocale["Requires honored faction with Sha'tari Skyguard"]..")", FACTION, 1031 };
	};
	FPAllianceOutland = {
		ZoneName = { AtlasFPLocale["Alliance"].." ("..AtlasFPLocale["Outland"]..")" };
		Location = { AtlasFPLocale["Outland"] };
		{ GREY.."1) "..AtlasFPLocale["The Dark Portal"]..", ".._RED..AtlasFPLocale["Hellfire Peninsula"], ZONE, 3483 };
		{ GREY.."2) "..AtlasFPLocale["Shatter Point"]..", ".._RED..AtlasFPLocale["Hellfire Peninsula"], ZONE, 3483 };
		{ GREY.."3) "..AtlasFPLocale["Honor Hold"]..", ".._RED..AtlasFPLocale["Hellfire Peninsula"], ZONE, 3483 };
		{ GREY.."4) "..AtlasFPLocale["Temple of Telhamat"]..", ".._RED..AtlasFPLocale["Hellfire Peninsula"], ZONE, 3483 };
		{ GREY.."5) "..AtlasFPLocale["Telredor"]..", ".._RED..AtlasFPLocale["Zangarmarsh"], ZONE, 3521 };
		{ GREY.."6) "..AtlasFPLocale["Orebor Harborage"]..", ".._RED..AtlasFPLocale["Zangarmarsh"], ZONE, 3521 };
		{ GREY.."7) "..AtlasFPLocale["Telaar"]..", ".._RED..AtlasFPLocale["Nagrand"], ZONE, 3518 };
		{ GREY.."8) "..AtlasFPLocale["Shattrath City"]..", ".._RED..AtlasFPLocale["Terokkar Forest"], ZONE, 3519 };
		{ GREY.."9) "..AtlasFPLocale["Allerian Stronghold"]..", ".._RED..AtlasFPLocale["Terokkar Forest"], ZONE, 3519 };
		{ GREY.."10) "..AtlasFPLocale["Wildhammer Stronghold"]..", ".._RED..AtlasFPLocale["Shadowmoon Valley"], ZONE, 3520 };
		{ GREY.."11) "..AtlasFPLocale["Altar of Sha'tar"]..", ".._RED..AtlasFPLocale["Shadowmoon Valley"]..BLUE.." ("..AtlasFPLocale["The Aldor"]..")", ZONE, 3520 , FACTION, 932 };
		{ GREY.."12) "..AtlasFPLocale["Sanctum of the Stars"]..", ".._RED..AtlasFPLocale["Shadowmoon Valley"]..BLUE.." ("..AtlasFPLocale["The Scryers"]..")", ZONE, 3520 , FACTION, 934 };
		{ GREY.."13) "..AtlasFPLocale["Sylvanaar"]..", ".._RED..AtlasFPLocale["Blade's Edge Mountains"], ZONE, 3522 };
		{ GREY.."14) "..AtlasFPLocale["Evergrove"]..", ".._RED..AtlasFPLocale["Blade's Edge Mountains"], ZONE, 3522 };
		{ GREY.."15) "..AtlasFPLocale["Toshley's Station"]..", ".._RED..AtlasFPLocale["Blade's Edge Mountains"], ZONE, 3522 };
		{ GREY.."16) "..AtlasFPLocale["Area 52"]..", ".._RED..AtlasFPLocale["Netherstorm"], ZONE, 3523 };
		{ GREY.."17) "..AtlasFPLocale["The Stormspire"]..", ".._RED..AtlasFPLocale["Netherstorm"], ZONE, 3523 };
		{ GREY.."18) "..AtlasFPLocale["Cosmowrench"]..", ".._RED..AtlasFPLocale["Netherstorm"], ZONE, 3523 };
		{ GREN.."1') "..AtlasFPLocale["Blackwind Landing"]..", ".._RED..AtlasFPLocale["Terokkar Forest"], ZONE, 3519 };
		{ GREN.."2') "..AtlasFPLocale["Skyguard Outpost"]..", ".._RED..AtlasFPLocale["Blade's Edge Mountains"], ZONE, 3522 };
		{ GREN..INDENT.."("..AtlasFPLocale["Requires honored faction with Sha'tari Skyguard"]..")", FACTION, 1031 };
	};
};

Atlas_RegisterPlugin("Atlas_FlightPaths", myCategory, myData);
