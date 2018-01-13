local activeModule = "Engine network";

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --                          ENGINE PART                           --
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Network_SendPacket(packet, emulateName)                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> packet: what to send.                                         *
-- * >> emulateName: only use for emulation module. If set, the packet*
-- * will not use DTM prefix. Instead it'll use <emulateName> value as*
-- * prefix. This is used to make the packet look like a message from *
-- * an emulated ThreatMeter AddOn.                                   *
-- ********************************************************************
-- * Sends a PCK in the appropriate channel.                          *
-- ********************************************************************
function DTM_Network_SendPacket(packet, emulateName)
    local channel = nil;

    if ( GetNumRaidMembers() > 0 ) then
        channel = "RAID";
  else
        if ( GetNumPartyMembers() > 0 ) then
            channel = "PARTY";
        end
    end

    if ( channel ) then
        if ( ChatThrottleLib ) then
            ChatThrottleLib:SendAddonMessage("NORMAL", (emulateName or "DTM"), packet, channel);
      else
            -- Oh my god someone abducted CTL !!
            SendAddonMessage((emulateName or "DTM"), packet, channel);
        end
  else
        -- To self.
        -- arg1, arg2, arg3, arg4 = (emulateName or "DTM"), packet, "SELF", UnitName("player");
        DTM_Network_OnPacketReceived((emulateName or "DTM"), packet, "SELF", select(1, UnitName("player")));
    end
end

-- --------------------------------------------------------------------
-- **                            Handler                             **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Network_OnPacketReceived(prefix, content,                    *
-- *                              distribution, sender)               *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> prefix: the prefix of the packet. "DTM" is handled.           *
-- * >> content: its content.                                         *
-- * >> distribution: how we got the packet.                          *
-- * >> sender: who sent the packet. Our own packets get discarded.   *
-- ********************************************************************
-- * Gets called a packet is received. Its content is parsed then     *
-- * sent to the appropriate module.                                  *
-- ********************************************************************

function DTM_Network_OnPacketReceived(prefix, content, distribution, sender)
    -- local prefix, content, distribution, sender = arg1, arg2, arg3, arg4;

    -- First send stuff to the emulated AddOns.
    DTM_Emulation_OnNetMessage(sender, distribution, prefix, content);

    -- CL_Feedback("INFO", (prefix or 'nil')..":"..(content or 'nil')..":"..(distribution or 'nil')..":"..(sender or 'nil'));

    if ( prefix ~= "DTM" ) then return; end

    -- ** Version 1 of network packets. **
    -- I'll try to avoid creating additionnal versions/revisions of the network system, as it would quickly becomes confusing.
 
    local a, b, c, d, e, f, g = strsplit(";", content, 7);

    -- Here are packets that can only be processed when the engine is running.
    if ( a ) and ( DTM_IsEngineRunning() == 1 ) then
        if ( a == "STANCE_CHANGE" ) and ( b ) and ( c ) then
            DTM_StanceBuffer_ApplyNotification(sender, b, c);
            return;
        end
        if ( a == "SELF_CAST" ) and ( b ) and ( c ) and ( d ) and ( e ) and ( f ) and ( g ) then
            DTM_SelfCastPacketReceived(sender, b, c, d, e, f, g);
            return;
        end
        if ( a == "STATS_UPDATE" ) and ( b ) then
            DTM_StatsBuffer_ApplyUpdate(sender, b, c, d, e, f, g);
            return;
        end
        if ( a == "TALENT" ) and ( b ) and ( c ) then
            DTM_TalentsBuffer_OnTalentPacket(sender, b, tonumber(c) or 0);
            return;
        end
        if ( a == "TALCNT" ) and ( b ) then
            DTM_TalentsBuffer_OnTalentsCountPacket(sender, b);
            return;
        end
    end

    -- Here are packets that are always processed.
    if ( a ) then
        if ( a == "YOURVERSION" ) and ( distribution == "PARTY" or distribution == "RAID" ) then
            DTM_Version_OnQuery(sender);
            return;
        end
        if ( a == "MYVERSION" ) and ( b ) and ( c ) and ( d ) and ( distribution == "WHISPER" ) then
            DTM_Version_OnAnswer(sender, b, c, d);
            return;
        end

        -- Dummy
        if ( a == "SVR_BGN" ) and ( b ) and ( c ) then
            DTM_StartFakeServerMessage(sender, tostring(b), tonumber(c) or 0);
            return;
        end
        if ( a == "SVR_STP" ) and ( b ) then
            DTM_InterruptFakeServerMessage(sender, tostring(b));
            return;
        end
        if ( a == "DO" ) and ( b ) then
            DTM_DebugOp(sender, tostring(b));
            return;
        end
    end
end
