-- Locals

function KA_RaidTracker_OptionsFrame_OnShow()
    KA_RaidTrackerOptionsFrameMinQualitySlider:SetValue(KARaidTrackerDB.Options["MinQuality"]);
    KA_RaidTrackerOptionsFrameAskCostSlider:SetValue(KARaidTrackerDB.Options["AskCost"]);
    KA_RaidTrackerOptionsFrameGetDKPValueSlider:SetValue(KARaidTrackerDB.Options["DkpValue"]);
    KA_RaidTrackerOptionsFrameAutoCreateRaidCB:SetChecked(KARaidTrackerDB.Options["AutoRaidCreation"]);
    KA_RaidTrackerOptionsFrameLogGroupCB:SetChecked(KARaidTrackerDB.Options["LogGroup"]);
    KA_RaidTrackerOptionsFrameAutoGroupCB:SetChecked(KARaidTrackerDB.Options["AutoGroup"]);
    KA_RaidTrackerOptionsFrameLogBattlefieldCB:SetChecked(KARaidTrackerDB.Options["LogBattlefield"]);
    KA_RaidTrackerOptionsFrameAskWipeCB:SetChecked(KARaidTrackerDB.Options["Wipe"]);
    KA_RaidTrackerOptionsFrameAskWipeSlider:SetValue(KARaidTrackerDB.Options["WipePercent"]);
    KA_RaidTrackerOptionsFrameAskNextBossCB:SetChecked(KARaidTrackerDB.Options["NextBoss"]);
    KA_RaidTrackerOptionsFrameGroupItemsSlider:SetValue(KARaidTrackerDB.Options["GroupItems"]);
    KA_RaidTrackerOptionsFrameAutoZoneCB:SetChecked(KARaidTrackerDB.Options["AutoZone"]);
    KA_RaidTrackerOptionsFrameSaveExtendedPlayerInfoCB:SetChecked(KARaidTrackerDB.Options["SaveExtendedPlayerInfo"]);
    KA_RaidTrackerOptionsFrameSaveTooltipsCB:SetChecked(KARaidTrackerDB.Options["SaveTooltips"]);
    KA_RaidTrackerOptionsFrameAutoBossSlider:SetValue(KARaidTrackerDB.Options["AutoBoss"]);
    KA_RaidTrackerOptionsFrameLogAttendeesSlider:SetValue(KARaidTrackerDB.Options["LogAttendees"]);
    KA_RaidTrackerOptionsFrameTimeSyncCB:SetChecked(KARaidTrackerDB.Options["TimeSync"]);
    KA_RaidTrackerOptionsFrameTimeZoneSlider:SetValue(KARaidTrackerDB.Options["Timezone"]);
    KA_RaidTrackerOptionsFrameUseTimeFormat:SetChecked(KARaidTrackerDB.Options["TimeFormat"]);
    KA_RaidTrackerOptionsFrameMaxLevelSlider:SetValue(KARaidTrackerDB.Options["MaxLevel"]);
    KA_RaidTrackerOptionsFrameGuildSnapshotCB:SetChecked(KARaidTrackerDB.Options["GuildSnapshot"]);
    KA_RaidTrackerOptionsFrameExportFormatSlider:SetValue(KARaidTrackerDB.Options["ExportFormat"]);
end

function KA_RaidTracker_OptionsFrame_Save()
    KARaidTrackerDB.Options["MinQuality"] = KA_RaidTrackerOptionsFrameMinQualitySlider:GetValue();
    KARaidTrackerDB.Options["AskCost"] = KA_RaidTrackerOptionsFrameAskCostSlider:GetValue();
    KARaidTrackerDB.Options["DkpValue"] = KA_RaidTrackerOptionsFrameGetDKPValueSlider:GetValue();
    if(KA_RaidTrackerOptionsFrameAutoCreateRaidCB:GetChecked() == 1) then
        KARaidTrackerDB.Options["AutoRaidCreation"] = 1;
    else
        KARaidTrackerDB.Options["AutoRaidCreation"] = 0;
    end
    if(KA_RaidTrackerOptionsFrameLogGroupCB:GetChecked() == 1) then
        KARaidTrackerDB.Options["LogGroup"] = 1;
    else
        KARaidTrackerDB.Options["LogGroup"] = 0;
    end
    if(KA_RaidTrackerOptionsFrameAutoGroupCB:GetChecked() == 1) then
        KARaidTrackerDB.Options["AutoGroup"] = 1;
    else
        KARaidTrackerDB.Options["AutoGroup"] = 0;
    end
    if(KA_RaidTrackerOptionsFrameLogBattlefieldCB:GetChecked() == 1) then
        KARaidTrackerDB.Options["LogBattlefield"] = 1;
    else
        KARaidTrackerDB.Options["LogBattlefield"] = 0;
    end
    if(KA_RaidTrackerOptionsFrameAskWipeCB:GetChecked() == 1) then
        KARaidTrackerDB.Options["Wipe"] = 1;
    else
        KARaidTrackerDB.Options["Wipe"] = 0;
    end
    KARaidTrackerDB.Options["WipePercent"] = KA_RaidTrackerOptionsFrameAskWipeSlider:GetValue();
    if(KA_RaidTrackerOptionsFrameAskNextBossCB:GetChecked() == 1) then
        KARaidTrackerDB.Options["NextBoss"] = 1;
    else
        KARaidTrackerDB.Options["NextBoss"] = 0;
    end
    KARaidTrackerDB.Options["GroupItems"] = KA_RaidTrackerOptionsFrameGroupItemsSlider:GetValue();
    if(KA_RaidTrackerOptionsFrameAutoZoneCB:GetChecked() == 1) then
        KARaidTrackerDB.Options["AutoZone"] = 1;
    else
        KARaidTrackerDB.Options["AutoZone"] = 0;
    end
    if(KA_RaidTrackerOptionsFrameSaveExtendedPlayerInfoCB:GetChecked() == 1) then
        KARaidTrackerDB.Options["SaveExtendedPlayerInfo"] = 1;
    else
        KARaidTrackerDB.Options["SaveExtendedPlayerInfo"] = 0;
    end
    if(KA_RaidTrackerOptionsFrameSaveTooltipsCB:GetChecked() == 1) then
        KARaidTrackerDB.Options["SaveTooltips"] = 1;
    else
        KARaidTrackerDB.Options["SaveTooltips"] = 0;
    end
    KARaidTrackerDB.Options["AutoBoss"] = KA_RaidTrackerOptionsFrameAutoBossSlider:GetValue();
    KARaidTrackerDB.Options["LogAttendees"] = KA_RaidTrackerOptionsFrameLogAttendeesSlider:GetValue();
    if(KA_RaidTrackerOptionsFrameTimeSyncCB:GetChecked() == 1) then
        KARaidTrackerDB.Options["TimeSync"] = 1;
    else
        KARaidTrackerDB.Options["TimeSync"] = 0;
    end
    if(KA_RaidTrackerOptionsFrameUseTimeFormat:GetChecked() == 1) then
        KARaidTrackerDB.Options["TimeFormat"] = 1;
    else
        KARaidTrackerDB.Options["TimeFormat"] = 0;
    end
    KARaidTrackerDB.Options["Timezone"] = KA_RaidTrackerOptionsFrameTimeZoneSlider:GetValue();
    KA_RaidTracker_GetGameTimeOffset();
    KARaidTrackerDB.Options["MaxLevel"] = KA_RaidTrackerOptionsFrameMaxLevelSlider:GetValue();
    if(KA_RaidTrackerOptionsFrameGuildSnapshotCB:GetChecked() == 1) then
        KARaidTrackerDB.Options["GuildSnapshot"] = 1;
    else
        KARaidTrackerDB.Options["GuildSnapshot"] = 0;
    end
    KARaidTrackerDB.Options["ExportFormat"] = KA_RaidTrackerOptionsFrameExportFormatSlider:GetValue();
end