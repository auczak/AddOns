local MAJOR_VERSION = "Threat-2.0"
local MINOR_VERSION = tonumber(("$Revision: 70586 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then _G.ThreatLib_MINOR_VERSION = MINOR_VERSION end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

	local ThreatLib = _G.ThreatLib
	local BLOODBOIL_ID = 22948

	ThreatLib:GetModule("NPCCore"):RegisterModule(BLOODBOIL_ID, function(Bloodboil)
		function Bloodboil:Init()
			self:RegisterSpellHandler(
				"SPELL_DAMAGE",
				function(self, mobGUID, targetGUID) self.ModifyThreatOnTargetGUID(mobGUID, targetGUID, 0.75, 0) end,
				40486
			)
			self:RegisterCombatant(BLOODBOIL_ID, true)
		end
	end)
end
