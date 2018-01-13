--Feel free to edit this file to add support for your language.
--Also look at the TOC file. Please send the changes to me so
--I can incorporate them into the official version. Thanks!
--Cheers, Lenja

SOLALARM_VER = "1.6"

---------------------------------------

SOLALARM_GREETING   = "SolarianAlarm v" .. SOLALARM_VER .. " loaded! (/sa)"
SOLALARM_HELP1      = "SolarianAlarm v" .. SOLALARM_VER .. " Commands:"
SOLALARM_HELP2      = "  /sa test on - SA will warn on ANY debuff."
SOLALARM_HELP3      = "  /sa test off - SA will only warn on Solarian's debuff."
SOLALARM_HELP4      = "  /sa version check - Shows you what SA versions your raid members are using."
SOLALARM_TESTON     = "Test mode enabled. SA will warn on ANY debuff."
SOLALARM_TESTOFF    = "Test mode disabled. SA will warn on Solarian's debuff."
SOLALARM_VERCHECK   = "Version check:"
SOLALARM_NOSA       = "No SA detected:"
SOLALARM_DEBUFFNAME = "Astro"

---------------------------------------

if (GetLocale() == "deDE") then
	SOLALARM_GREETING   = "SolarianAlarm v" .. SOLALARM_VER .. " geladen! (/sa)"
	SOLALARM_HELP1      = "SolarianAlarm v" .. SOLALARM_VER .. " Kommandos:"
	SOLALARM_HELP2      = "  /sa test on - SA warnt bei JEDEM Debuff."
	SOLALARM_HELP3      = "  /sa test off - SA warnt nur bei Solarians Debuff."
	SOLALARM_HELP4      = "  /sa version check - Zeigt Dir, welche SA Versionen Deine Raidmitglieder benutzen."
	SOLALARM_TESTON     = "Testmodus eingeschaltet. SA warnt bei JEDEM Debuff."
	SOLALARM_TESTOFF    = "Testmodus ausgeschaltet. SA warnt bei Solarians Debuff."
	SOLALARM_VERCHECK   = "Versionsliste:"
	SOLALARM_NOSA       = "Kein SA gefunden:"
	SOLALARM_DEBUFFNAME = "Astro"
end

---------------------------------------

if (GetLocale() == "frFR") then -- Translation by Heeroyuy
	SOLALARM_GREETING   = "SolarianAlarm v" .. SOLALARM_VER .. " charg\195\169! (/sa)"
	SOLALARM_HELP1      = "SolarianAlarm v" .. SOLALARM_VER .. " Commands:"
	SOLALARM_HELP2      = "  /sa test on - SA s'activera pour tout debuff sur vous."
	SOLALARM_HELP3      = "  /sa test off - SA s'activera pour tout debuff de Solarian sur vous."
	SOLALARM_HELP4      = "  /sa version check - Montre quelle version possedent les membres de votre raid."
	SOLALARM_TESTON     = "Test mode enabled. SA s'activera pour tout debuff sur vous."
	SOLALARM_TESTOFF    = "Test mode disabled. SA s'activera pour tout debuff de Solarian sur vous."
	SOLALARM_VERCHECK   = "Version check:"
	SOLALARM_NOSA       = "No SA detected:"
	SOLALARM_DEBUFFNAME = "Courroux"
end

---------------------------------------

if (GetLocale() == "esES") then
end

---------------------------------------

if (GetLocale() == "ruRU") then
end

---------------------------------------

if (GetLocale() == "koKR") then
end

---------------------------------------

if (GetLocale() == "zhCN") then
end

---------------------------------------

if (GetLocale() == "zhTW") then
end
