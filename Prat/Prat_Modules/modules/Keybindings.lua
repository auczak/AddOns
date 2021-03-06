﻿---------------------------------------------------------------------------------
--
-- Prat - A framework for World of Warcraft chat mods
--
-- Copyright (C) 2006-2007  Prat Development Team
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to:
--
-- Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor,
-- Boston, MA  02110-1301, USA.
--
--
-------------------------------------------------------------------------------



--[[
Name: PratKeyBindings
Revision: $Revision: 63496 $
Author(s): Curney (asml8ed@gmail.com)
           Krtek (krtek4@gmail.com)
Website: http://www.wowace.com/files/index.php?path=Prat/
Documentation: http://www.wowace.com/wiki/Prat/Integrated_Modules#KeyBindings
SVN: http://svn.wowace.com/wowace/trunk/Prat/
Description: Module for Prat that adds keybindings for modules.
Dependencies: Prat
]]

-- Get Utility Libraries
local util, DBG, CLR = GetPratUtils()


local PRAT_MODULE = Prat:RequestModuleName("PratKeyBindings")

if PRAT_MODULE == nil then
    return
end

-- define localized strings
local L = PRAT_LIBRARY(PRATLIB.LOCALIZATION):new(PRAT_MODULE)

L:RegisterTranslations("enUS", function() return {
    ["Prat ChannelNames"] = true,
    ["Officer Channel"] = true,
	["Guild Channel"] = true,
	["Party Channel"] = true,
	["Raid Channel"] = true,
    ["Raid Warning Channel"] = true,
    ["Battleground Channel"] = true,
    ["Say"] = true,
    ["Yell"] = true,
    ["Whisper"] = true,
    ["Channel %d"] = true,
	["Prat TellTarget"] = true,
    ["TellTarget"] = true,
    ["Prat CopyChat"] = true,
    ["Copy Selected Chat Frame"] = true,
    ["Smart Group Channel"] = true,
} end)

--[[
	Chinese Local : CWDG Translation Team 昏睡墨鱼 (Thomas Mo)
	$Rev: 63496 $
]]

L:RegisterTranslations("zhCN", function() return {
	["Prat ChannelNames"] = "Prat 频道名称",
	["Officer Channel"] = "官员频道",
	["Guild Channel"] = "公会频道",
	["Party Channel"] = "队伍频道",
	["Raid Channel"] = "团队频道",
	["Raid Warning Channel"] = "团队警报频道",
	["Battleground Channel"] = "战场频道",
	["Say"] = "说",
	["Yell"] = "喊",
	["Whisper"] = "密语",
	["Channel %d"] = "频道 %d",
	["Prat TellTarget"] = "Prat 通知目标",
	["TellTarget"] = "通知目标",
    ["Prat CopyChat"] = "Prat 聊天复制",
    ["Copy Selected Chat Frame"] = "复制已选聊天窗口",
    ["Smart Group Channel"] = "智能群频道",
} end)

L:RegisterTranslations("zhTW", function() return {
    ["Prat ChannelNames"] = "Prat 頻道名稱",
    ["Officer Channel"] = "公會理事頻道",
	["Guild Channel"] = "公會頻道",
	["Party Channel"] = "隊伍頻道",
	["Raid Channel"] = "團隊頻道",
    ["Raid Warning Channel"] = "團隊警告頻道",
    ["Battleground Channel"] = "戰場頻道",
    ["Say"] = "說",
    ["Yell"] = "大喊",
    ["Whisper"] = "悄悄話",
    ["Channel %d"] = "頻道%d",
	["Prat TellTarget"] = "Prat 通知目標",
-- no use anymore    ["TellTarget"] = true,
    ["Prat CopyChat"] = "Prat 複製聊天訊息",
    ["Copy Selected Chat Frame"] = "從使用中的聊天視窗複製",
    ["Smart Group Channel"] = "智慧群組頻道",
} end)

L:RegisterTranslations("koKR", function() return {
    ["Prat ChannelNames"] = "Prat 채널명",
    ["Officer Channel"] = "오피서 채널",
    ["Guild Channel"] = "길드 채널",
    ["Party Channel"] = "파티 채널",
    ["Raid Channel"] = "공격대 채널",
    ["Raid Warning Channel"] = "공격대경보 채널",
    ["Battleground Channel"] = "전장 채널",
    ["Say"] = "대화",
    ["Yell"] = "외치기",
    ["Whisper"] = "귓속말",
    ["Channel %d"] = "채널 %d",
    ["Prat TellTarget"] = "Prat 대상대화",
    ["TellTarget"] = "대상대화",
    ["Prat CopyChat"] = "Prat 대화복사",
    ["Copy Selected Chat Frame"] = "선택된 대화창 복사",
    ["Smart Group Channel"] = "스마트 파티 채널",
} end)

L:RegisterTranslations("esES", function() return {
    ["Prat ChannelNames"] = "Nombres de Canal de Prat",
    ["Officer Channel"] = "Canal de Oficial",
	["Guild Channel"] = "Canal de Hermandad",
	["Party Channel"] = "Canal de Grupo",
	["Raid Channel"] = "Canal de Banda",
    ["Raid Warning Channel"] = "Canal de Aviso de Banda",
    ["Battleground Channel"] = "Canal de Campo de Batalla",
    ["Say"] = "Decir",
    ["Yell"] = "Gritar",
    ["Whisper"] = "Susurrar",
    ["Channel %d"] = "Canal %d",
	["Prat TellTarget"] = "Susurrar a Objetivo de Prat",
    ["TellTarget"] = "Susurrar a Objetivo",
} end)

L:RegisterTranslations("deDE", function() return {
    ["Prat ChannelNames"] = "Prat Kanal Namen",
    ["Officer Channel"] = "Offizier's Kanal",
	["Guild Channel"] = "Gilden Kanal",
	["Party Channel"] = "Gruppen Kanal",
	["Raid Channel"] = "Schlachtgruppen Kanal",
    ["Raid Warning Channel"] = "Schlachtgruppenwarnung Kanal",
    ["Battleground Channel"] = "Schlachtfeld Kanal",
    ["Say"] = "Sagen",
    ["Yell"] = "Schreien",
    ["Whisper"] = "Fl\195\188stern",
    ["Channel %d"] = "Kanal %d",
	["Prat TellTarget"] = "Prat Ziel Fl\195\188stern",
    ["TellTarget"] = "Ziel Fl\195\188stern",
    ["Prat CopyChat"] = "Prat Chat Kopieren",
    ["Copy Selected Chat Frame"] = "Kopiere das ausgewälte Chat Fenster.",
} end)

L:RegisterTranslations("frFR", function() return {
    ["Prat ChannelNames"] = "Prat - Noms de canaux",
    ["Officer Channel"] = "Canal officiers",
	["Guild Channel"] = "Canal de guilde",
	["Party Channel"] = "Canal de groupe",
	["Raid Channel"] = "Canal de raid",
    ["Raid Warning Channel"] = "Canal d'avertissement de raid",
    ["Battleground Channel"] = "Canal de champs de bataille",
    ["Say"] = "Dire",
    ["Yell"] = "Crier",
    ["Whisper"] = "Chuchoter",
    ["Channel %d"] = "Canal %d",
	["Prat TellTarget"] = "Prat Dire \195\160 la cible",
    ["TellTarget"] = "Dire \195\160 la cible",
    ["Prat CopyChat"] = "Prat Copier un chat",
    ["Copy Selected Chat Frame"] = "Copier le texte de la fen\195\170tre s\195\169lectionn\195\169e",
} end)

Prat_Keybindings = Prat:NewModule(PRAT_MODULE)
Prat_Keybindings.moduleHidden = true

Prat_Keybindings.revision = tonumber(string.sub("$Revision: 63496 $", 12, -3))

-- Prat categories relevant to this module. list at: http://groups.google.com/group/wow-prat/web/prat-categories
local cat = Prat.Categories
Prat_Keybindings.Categories	= { cat.DEV, cat.BEHAVIOR, cat.ACTION }	-- eg { cat.TEXT, cat.INFO }

function Prat_Keybindings:OnModuleInit()
	BINDING_HEADER_Prat_ChannelNames = L["Prat ChannelNames"]
	BINDING_NAME_officer = L["Officer Channel"]
	BINDING_NAME_guild = L["Guild Channel"]
	BINDING_NAME_party = L["Party Channel"]
	BINDING_NAME_raid = L["Raid Channel"]
	BINDING_NAME_raidwarn = L["Raid Warning Channel"]
	BINDING_NAME_battleground = L["Battleground Channel"]
	BINDING_NAME_say = L["Say"]
	BINDING_NAME_yell = L["Yell"]
	BINDING_NAME_whisper = L["Whisper"]
	BINDING_NAME_one = string.format(L["Channel %d"], 1)
	BINDING_NAME_two = string.format(L["Channel %d"], 2)
	BINDING_NAME_three = string.format(L["Channel %d"], 3)
	BINDING_NAME_four = string.format(L["Channel %d"], 4)
	BINDING_NAME_five = string.format(L["Channel %d"], 5)
	BINDING_NAME_six = string.format(L["Channel %d"], 6)
	BINDING_NAME_seven = string.format(L["Channel %d"], 7)
	BINDING_NAME_eight = string.format(L["Channel %d"], 8)
	BINDING_NAME_nine = string.format(L["Channel %d"], 9)
	BINDING_NAME_ten = string.format(L["Channel %d"], 10)
	BINDING_NAME_SmartGroup = L["Smart Group Channel"]
    BINDING_HEADER_Prat_TellTarget = L["Prat TellTarget"]
    BINDING_HEADER_Prat_CopyChat = L["Prat CopyChat"]
    BINDING_NAME_CopySelected = L["Copy Selected Chat Frame"]
end