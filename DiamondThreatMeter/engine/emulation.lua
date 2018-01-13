local activeModule = "Engine emulation";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

local DTM_Emulation_Vars = {};
local F = DTM_EmuFunctions; -- We need some additionnal functions to ease addOns emulation.

local emulationSupport = {
    ["ThreatLib2"] = {
        description = {
            ["default"] = "Sends your threat data to your group members running this library (Omen2 uses it).",
            ["frFR"] = "Informe les utilisateurs de cette librairie de votre niveau de menace (Omen2 l'utilise).",
        },

        canSpoofVersion = 1, -- Puts an additionnal checkbox that, if checked, allows the emulation module to answer the version request net messages.

        CheckInstalled = function()
                             if ( LibStub ) and ( LibStub.libs ) and ( LibStub.libs["Threat-2.0"] ) then
                                 return 1;
                           else
                                 return nil;
                             end
                         end,

        OnLoad = function(useVersionSpoof)
                     DTM_Emulation_Vars["TL2"] = {};
                     local vars = DTM_Emulation_Vars["TL2"];

                     vars.lastUpdate = 0;
                     vars.updateInterval = -1; -- Will be set to an appropriate value on the first update.

                     if ( useVersionSpoof == 1 ) then
                         vars.agent = "Threat-2.0";
                         vars.minor = 74642;
                   else
                         -- Display ourselves as DTM.
                         vars.agent = "DTM";
                         local major, minor, revision = DTM_GetVersion();
                         vars.minor = major * 10000 + minor * 100 + revision;
                     end
                 end,
        OnUpdate = function(elapsed)
                       local vars = DTM_Emulation_Vars["TL2"];
                       if ( vars ) then
                           if ( ( GetTime() - vars.lastUpdate ) > vars.updateInterval ) then
                               vars.updateInterval = F:GetThreatUpdateRate();
                               vars.lastUpdate = GetTime();
                               
                               -- Does a TL2 threat level update.

                               local playerMsg = F:GetTL2ThreatString("player");
                               local petMsg = F:GetTL2ThreatString("pet");
                               local packet;

                               if ( playerMsg ) then
                                   packet = "TU"..playerMsg;
                                   if ( #packet <= 250 ) then
                                       DTM_Network_SendPacket(packet, "TL2");
                                   end
                                   -- DTM_Trace("EMULATION", "ThreatLib2 Emu sends [%s] threat data to the group:\n%s", 1, UnitName("player"), packet);
                               end
                               if ( petMsg ) then
                                   packet = "TU"..petMsg;
                                   if ( #packet <= 250 ) then
                                       DTM_Network_SendPacket(packet, "TL2");
                                   end
                               end
                           end
                       end
                   end,
        OnNet = function(author, distribution, prefix, body)
                    if ( author == UnitName("player") ) then return; end

                    local vars = DTM_Emulation_Vars["TL2"];
                    if not ( string.match(body, "^%^") ) then return; end -- Not serialized data.

                    local _, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p = F:Deserialize(body);
                    if ( vars ) and ( prefix == "TL2" ) and ( a ) then
                        -- DTM_Trace("EMULATION", "ThreatLib2 packet: %s/%s/%s/%s", 1, a or '?', b or '?', c or '?', d or '?');
                        if ( a == "RI" ) and ( distribution == "PARTY" or distribution == "RAID" ) and ( vars.agent ) and ( vars.minor ) then
		            -- Send the spoofed version.
                            DTM_Network_SendPacket(F:Serialize("CI", vars.minor, vars.agent), "TL2");
                            DTM_Trace("EMULATION", "ThreatLib2 Emu answers [%s] version request.", 1, author);
                        end
                        if ( a == "CI" ) then
		            -- We have received version data from a ThreatLib2 system.
                            DTM_Version_OnAnswer(author, 0, 0, b or "?", "ThreatLib2");
                            DTM_Trace("EMULATION", "ThreatLib2 Emu receives [%s] version info.", 1, author);
                        end
                    end
                end,
        OnQuery = function()
             local vars = DTM_Emulation_Vars["TL2"];
             DTM_Network_SendPacket(F:Serialize("RI", vars.minor or 0, vars.agent or nil), "TL2");
             DTM_Trace("EMULATION", "ThreatLib2 Emu requests version info to the party/raid.");
        end,
    },

    ["KTM"] = {
        description = {
            ["default"] = "Sends your threat data to your group members running KLHThreatMeter (KTM).",
            ["frFR"] = "Informe les utilisateurs de KLHThreatMeter (KTM) de votre niveau de menace.",
        },

        canSpoofVersion = 1, -- Puts an additionnal checkbox that, if checked, allows the emulation module to answer the version request net messages.

        CheckInstalled = function()
                             if ( klhtm ) then
                                 return 1;
                           else
                                 return nil;
                             end
                         end,

        OnLoad = function(useVersionSpoof)
                     DTM_Emulation_Vars["KTM"] = {};
                     local vars = DTM_Emulation_Vars["KTM"];

                     vars.lastUpdate = 0;
                     vars.updateInterval = -1; -- Will be set to an appropriate value on the first update.
                     vars.selfInCombat = nil;

                     if ( useVersionSpoof == 1 ) then
                         vars.release = 21;
                         vars.revision = 12;
                   else
                         vars.release = nil;
                         vars.revision = nil;
                     end
                 end,
        OnUpdate = function(elapsed)
                       local vars = DTM_Emulation_Vars["KTM"];
                       if ( vars ) then
                           -- "I have left combat" net messages.

                           if ( UnitAffectingCombat("player") and not vars.selfInCombat ) then
                               -- Just entered combat.
                               vars.selfInCombat = 1;

                         elseif ( not UnitAffectingCombat("player") and vars.selfInCombat ) then
                               -- We've left combat. Warns KTM.
                               vars.selfInCombat = nil;
                               DTM_Network_SendPacket("endcombat", "KLHTM");
                               -- DTM_Trace("EMULATION", "KTM Emu notifies the group we have left combat mode.");
                           end

                           -- Periodic threat updates

                           if ( ( GetTime() - vars.lastUpdate ) > vars.updateInterval ) then
                               vars.updateInterval = F:GetThreatUpdateRate();
                               vars.lastUpdate = GetTime();
                               
                               -- Does a KTM threat level update.

                               local packet = F:GetKTMThreatString();
                               if ( packet ) and ( #packet <= 240 ) then
                                   DTM_Network_SendPacket(packet, "KLHTM");
                                   -- DTM_Trace("EMULATION", "KTM Emu sends our threat data to the group:\n%s", 1, packet);
                               end
                           end
                       end
                   end,
        OnNet = function(author, distribution, prefix, body)
                    if ( author == UnitName("player") ) then return; end
                    local vars = DTM_Emulation_Vars["KTM"];
                    if ( vars ) and ( prefix == "KLHTM" ) and ( distribution == "PARTY" or distribution == "RAID" ) then
                        local _, _, command, data = string.find(body, "^(%w+) ?(.*)");

                        if ( command == "versionquery" ) and ( vars.release and vars.revision ) then
		            -- Check the author has permission.
                            if not F:IsPlayerOfficer(author) then return; end

		            -- Send the spoofed version.
                            DTM_Network_SendPacket(format("versionresponse %s.%s", vars.release, vars.revision), "KLHTM");
                            DTM_Trace("EMULATION", "KTM Emu answers [%s] version request.", 1, author);
                        end
                        if ( command == "versionresponse" ) then
		            -- We have received version data from a KTM system.
                            local _, _, release, revision = string.find(data, "(%d+)%.(%d+)");
                            DTM_Version_OnAnswer(author, 0, release or "?", revision or "?", "KTM");
                            DTM_Trace("EMULATION", "KTM Emu receives [%s] version info.", 1, author);
                        end
                    end
                end,
        OnQuery = function()
             if not F:IsPlayerOfficer(UnitName("player")) then
                 DTM_Trace("EMULATION", "KTM Emu cannot do a version request (permission).");
                 return;
             end

             DTM_Network_SendPacket("versionquery", "KLHTM");
             DTM_Trace("EMULATION", "KTM Emu requests version info to the party/raid.");
        end,
    },
};

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_SetEmulationState(addOnName, state, spoofVersion)            *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> addOnName: the ThreatMeter AddOn to emulate. See table above. *
-- * >> state: whether or not emulate the threat COMM.                *
-- * Only 1 will be interpreted as "emulate", other values are inter- *
-- * preted as "do not emulate", including nil.                       *
-- * >> spoofVersion: if set to a non-nil value, this gives the       *
-- * authorization to answer version request net messages.            *
-- ********************************************************************
-- * Allows the user to send threat data to addon-message dependant   *
-- * threatMeters, such as KTM, so the user of these AddOns can see   *
-- * what your threat is. It is important if you are the tank; it is  *
-- * good to see, but it is also good to be seen. ;)                  *
-- ********************************************************************
function DTM_SetEmulationState(addOnName, state, spoofVersion)
    if not ( F ) then F = DTM_EmuFunctions; end

    local emulationData = emulationSupport[addOnName];
    if not ( emulationData ) then
        return;
    end

    if ( state == 1 ) then
        -- Do not allow emulation if the AddOn that is emulated is running.
        if ( emulationData.CheckInstalled ) and ( emulationData.CheckInstalled() ) then
            return;
        end

        DTM_Emulation[addOnName] = 1;

        local onLoadFunc = emulationSupport[addOnName].OnLoad;
        if ( onLoadFunc ) then onLoadFunc(spoofVersion); end
  else
        DTM_Emulation[addOnName] = 0;
    end
end

-- ********************************************************************
-- * DTM_Emulation_GetNumberOfEmulableAddOns()                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Determinate the number of AddOns DTM supports emulation for.     *
-- * This info can be used by the GUI to create a selection frame.    *
-- ********************************************************************
function DTM_Emulation_GetNumberOfEmulableAddOns()
    local count = 0;
    for k, v in pairs(emulationSupport) do
        count = count + 1;
    end
    return count;
end

-- ********************************************************************
-- * DTM_Emulation_GetEmulableAddOnData(index)                        *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Get emulable AddOn data:                                         *
-- *    - The AddOn name (for instance KTM).                          *
-- *    - A localised AddOn quick description.                        *
-- *    - A flag indicating if you can spoof version request packets. *
-- *    - Can be emulated now flag (yes if AddOn is not running).     *
-- ********************************************************************
function DTM_Emulation_GetEmulableAddOnData(index)
    local count = 0;
    for k, v in pairs(emulationSupport) do
        count = count + 1;
        if ( count == index ) then
            local descriptionTable = v.description;
            local description = nil;
            if ( descriptionTable ) then
                description = descriptionTable[GetLocale()] or descriptionTable["default"];
            end
            local canEmulate = 1;
            if ( v.CheckInstalled ) and ( v.CheckInstalled() ) then
                canEmulate = nil;
            end
            return k, description, v.canSpoofVersion, canEmulate;
        end
    end
    return nil;
end

-- ********************************************************************
-- * DTM_Emulation_QueryVersion()                                     *
-- ********************************************************************
-- * Arguments:                                                       *
-- *   <none>                                                         *
-- ********************************************************************
-- * Called by the version engine to ask each active emulation module *
-- * to perform a version request for the system they emulate.        *
-- ********************************************************************
function DTM_Emulation_QueryVersion()
    for k, v in pairs(emulationSupport) do
        if ( DTM_Emulation[k] == 1 ) then
            local onQueryFunc = v.OnQuery;
            if ( onQueryFunc ) then onQueryFunc(); end
        end
    end
end

-- --------------------------------------------------------------------
-- **                            Handler                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Emulation_OnUpdate(elapsed)                                  *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> elapsed: how much time passed.                                *
-- ********************************************************************
-- * Periodic update function, used for some emulations to send       *
-- * current threat level.                                            *
-- ********************************************************************

function DTM_Emulation_OnUpdate(elapsed)
    for k, v in pairs(emulationSupport) do
        if ( DTM_Emulation[k] == 1 ) then
            local onUpdateFunc = emulationSupport[k].OnUpdate;
            if ( onUpdateFunc ) then onUpdateFunc(elapsed); end
        end
    end
end

-- ********************************************************************
-- * DTM_Emulation_OnNetMessage(sender, distrib, prefix, message)     *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> ...: the arguments to pass to the OnNet function of the emu.  *
-- ********************************************************************
-- * Gets called upon receiving a net message.                        *
-- ********************************************************************

function DTM_Emulation_OnNetMessage(sender, distribution, prefix, message)
    for k, v in pairs(emulationSupport) do
        if ( DTM_Emulation[k] == 1 ) then
            local onNetFunc = emulationSupport[k].OnNet;
            if ( onNetFunc ) then onNetFunc(sender, distribution, prefix, message); end
        end
    end
end
