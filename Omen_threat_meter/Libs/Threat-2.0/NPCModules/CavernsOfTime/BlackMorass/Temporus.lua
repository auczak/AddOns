local MAJOR_VERSION = "Threat-2.0"
local MINOR_VERSION = tonumber(("$Revision: 70586 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then _G.ThreatLib_MINOR_VERSION = MINOR_VERSION end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()
	local ThreatLib = _G.ThreatLib
	local TEMPORUS_ID = 17880

	ThreatLib:GetModule("NPCCore"):RegisterModule(TEMPORUS_ID, function(Temporus)
		function Temporus:Init()
			self:RegisterCombatant(TEMPORUS_ID, true)
			
			--[[ self:RegisterSpellHandler(
				"SPELL_DAMAGE",
				function(self, mobGUID, targetGUID) end, 
				-- Register all known wing buffet IDs. We'll pare it down when we have better data, but for now, we'll just use them all.
				18500, 23339, 29905, 37157, 37319, 41572, 32914, 38110, 31475, 38593
			) ]]
		end
	end)
end
