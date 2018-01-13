--[[

ARL-RuneForge.lua

Runeforging data for all of AckisRecipeList

$Date: 2008-08-09 18:05:16 -0400 (Sat, 09 Aug 2008) $
$Rev: 80048 $

]]--

local L			= LibStub("AceLocale-3.0"):GetLocale("Ackis Recipe List")

local addon = AckisRecipeList

function addon:InitRuneforging()
	self:addTradeSkillSpell(53323, 1, L["Trainer"],1)
	self:addTradeSkillSpell(53331, 1, L["Trainer"],1)
	self:addTradeSkillSpell(53341, 1, L["Trainer"],1)
	self:addTradeSkillSpell(53342, 1, L["Trainer"],1)
	self:addTradeSkillSpell(53343, 1, L["Trainer"],1)
	self:addTradeSkillSpell(53344, 1, L["Trainer"],1)
	self:addTradeSkillSpell(54446, 1, L["Trainer"],1)
	self:addTradeSkillSpell(54447, 1, L["Trainer"],1)
end
