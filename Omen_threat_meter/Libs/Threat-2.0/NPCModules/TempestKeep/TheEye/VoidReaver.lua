local MAJOR_VERSION = "Threat-2.0"
local MINOR_VERSION = tonumber(("$Revision: 70586 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then _G.ThreatLib_MINOR_VERSION = MINOR_VERSION end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()
	local ThreatLib = _G.ThreatLib

	local VOID_REAVER_ID = 19516
	local KNOCK_AWAY_ID = 25778
	ThreatLib:GetModule("NPCCore"):RegisterModule(VOID_REAVER_ID, function(VoidReaver)
		function VoidReaver:Init()
			local func = function(self, mobGUID, targetGUID) self.ModifyThreatOnTargetGUID(mobGUID, targetGUID, 0.75, 0) end
			self:RegisterSpellHandler("SPELL_DAMAGE", func, KNOCK_AWAY_ID)
			self:RegisterCombatant(VOID_REAVER_ID, true)
		end
	end)
end
 