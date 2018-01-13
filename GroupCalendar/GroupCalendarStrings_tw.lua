-- File containing localized strings
-- Translation : zhTW-阿薩斯:但提勒斯(Displace) (20080419)
if GetLocale() == "zhTW" then
	-- Chinese Traditional localized variables

	GroupCalendar_cTitle = "團隊行事曆 v%s"

	GroupCalendar.cSingleItemFormat = "%s"
	GroupCalendar.cTwoItemFormat = "%s 和 %s"
	GroupCalendar.cMultiItemFormat = "%s{{, %s}} 和 %s"

	GroupCalendar_cSun = "日"
	GroupCalendar_cMon = "一"
	GroupCalendar_cTue = "二"
	GroupCalendar_cWed = "三"
	GroupCalendar_cThu = "四"
	GroupCalendar_cFri = "五"
	GroupCalendar_cSat = "六"

	GroupCalendar_cSunday = "星期日"
	GroupCalendar_cMonday = "星期一"
	GroupCalendar_cTuesday = "星期二"
	GroupCalendar_cWednesday = "星期三"
	GroupCalendar_cThursday = "星期四"
	GroupCalendar_cFriday = "星期五"
	GroupCalendar_cSaturday = "星期六"

	GroupCalendar_cSelfWillAttend = "%s會出席"
	GroupCalendar_cGuildOnly = "只限%s成員"

	GroupCalendar_cMonthNames = {"1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"}
	GroupCalendar_cDayOfWeekNames = {GroupCalendar_cSunday, GroupCalendar_cMonday, GroupCalendar_cTuesday, GroupCalendar_cWednesday, GroupCalendar_cThursday, GroupCalendar_cFriday, GroupCalendar_cSaturday}

	GroupCalendar_cLoadMessage = "團隊行事曆已載入。使用 '/cal show' 來瀏覽行事曆"
	GroupCalendar_cInitializingGuilded = "團隊行事曆: 替已有公會的玩家進行初始化設定"
	GroupCalendar_cInitializingUnguilded = "團隊行事曆: 替沒有公會的玩家進行初始化設定"
	GroupCalendar_cLocalTimeNote = "(%s 本地)"

	GroupCalendar_cOptions = "選項..."

	GroupCalendar_cCalendar = "行事曆"
	GroupCalendar_cSetup = "設定"
	GroupCalendar_cBackup = "備份"
	GroupCalendar_cAbout = "關於"

	GroupCalendar_cUseServerDateTime = "使用伺服器的日期與時間(建議)"
	GroupCalendar_cUseServerDateTimeDescription = "啟動此功能將會以伺服器的日期與時間來顯示活動資訊，若關閉此功能則會以您的電腦日期及時間來顯示。"

	GroupCalendar_cSetupTitle = "行事曆設置"
	GroupCalendar_cConfigModeLabel = "設定模式:"
	GroupCalendar_cAutoChannelConfig = "自動模式"
	GroupCalendar_cManualChannelConfig = "手動模式"
	GroupCalendar_cAdminChannelConfig  = "管理者模式"
		
	GroupCalendar_cUseGuildChannel = "使用公會資訊頻道"
	GroupCalendar_cUseGuildChannelDescription = "使用內建的公會資訊頻道。非公會成員無法檢閱此頻道的資訊。"

	GroupCalendar_cUseSharedChannel = "使用共用資訊頻道"
	GroupCalendar_cUseSharedChannelDescription = "使用公開的資訊頻道來傳輸行事曆資料。在伺服器內的所有人都可以進入此頻道，因此您需要設置密碼來限制檢閱的權限。"

	GroupCalendar_cApplyChannelChanges = "套用"
	GroupCalendar_cManualConfigTipDescription = "允許您手動輸入頻道及密碼資料。"
	GroupCalendar_cStoreAutoConfigTipDescription = "允許公會幹部將頻道設置資訊存到指定成員的玩家資訊中。"
	GroupCalendar_cAutoConfigPlayerTipDescription = "玩家在公會資訊中包含頻道設置資料。"
	GroupCalendar_cChannelNameTipTitle = "頻道名稱"
	GroupCalendar_cChannelNameTipDescription = "頻道名稱用來傳送及接收其他玩家的活動資料。"
	GroupCalendar_cConnectChannel = "連線"
	GroupCalendar_cDisconnectChannel = "中斷連線"
	GroupCalendar_cChannelStatus =
	{
		Starting = {mText = "狀態: 啟動中...", mColor = {r = 1, g = 1, b = 0.3}},
		Synching = {mText = "狀態: 網路同步中 %s", mColor = {r = 0.3, g = 1, b = 0.3}},
		Suspended = {mText = "狀態: 已暫停 (登出中)", mColor = {r = 1, g = 1, b = 0.3}},
		Connected = {mText = "狀態: 資訊頻道已連接", mColor = {r = 0.3, g = 1, b = 0.3}},
		Disconnected = {mText = "狀態: 資料頻道尚未連接", mColor = {r = 1, g = 0.5, b = 0.2}},
		Initializing = {mText = "狀態: 初始化資訊頻道", mColor = {r = 1, g = 1, b = 0.3}},
		Error = {mText = "錯誤: %s", mColor = {r = 1, g = 0.2, b = 0.4}},
	}

	GroupCalendar_cConnected = "已連線"
	GroupCalendar_cDisconnected = "已中斷連線"
	GroupCalendar_cTooManyChannels = "您已經到達頻道的加入上限"
	GroupCalendar_cJoinChannelFailed = "不明原因引致無法加入頻道"
	GroupCalendar_cWrongPassword = "密碼錯誤"
	GroupCalendar_cAutoConfigNotFound = "找不到公會設定資料"
	GroupCalendar_cErrorAccessingNote = "無法接收設置資料"

	GroupCalendar_cTrustConfigTitle = "信任設定"
	GroupCalendar_cTrustConfigDescription = "允許您控制能夠檢視活動的人。行事曆本身並無限制誰能夠檢視活動，設定密碼就能有效限制能夠檢視行事曆的人。"
	GroupCalendar_cTrustGroupLabel = "信任:"
	GroupCalendar_cEvent = "活動"
	GroupCalendar_cEdit = "Edit"
	GroupCalendar_cAttendance = "出席"

	GroupCalendar_cAboutTitle = "關於團隊行事曆"
	GroupCalendar_cTitleVersion = "Group Calendar v"..GroupCalendar.VersionString

	GroupCalendar.cAuthor = "由 John Stephen 設計及編寫，感謝下列人員的支援: %s"
	GroupCalendar_cTestersTitle = "4.0測試人員"
	GroupCalendar_cSpecialThanksTitle = "特別感謝"
	GroupCalendar.cTranslationCredit = "繁體中文翻譯由 zhTW-阿薩斯:但提勒斯(Displace) 提供"
	GroupCalendar_cGuildURL = "wobbleworks.com"

	GroupCalendar_cRebuildDatabase = "重新建立資料庫"
	GroupCalendar_cRebuildDatabaseDescription = "重新建立活動資料庫給您的角色。有助解決無法觀看所有活動的問題，但是此舉動可能會遺失出席回覆的資訊。"

	GroupCalendar_cTrustGroups =
	{
		"所有存取資料頻道的玩家",
		"公會成員",
		"僅限下列名單列出的玩家"
	}

	GroupCalendar_cTrustAnyone = "信任所有存取資料頻道的玩家"
	GroupCalendar_cTrustGuildies = "信任我的公會成員"
	GroupCalendar_cTrustMinRank = "最低階級需求:"
	GroupCalendar_cTrustNobody = "只信任下列名單中列出的玩家"
	GroupCalendar_cTrustedPlayers = "信任的玩家"
	GroupCalendar_cExcludedPlayers = "玩家忽略名單"
	GroupCalendar_cPlayerName = "名稱:"
	GroupCalendar_cRemoveExcluded = "移除"
	GroupCalendar_cAddExcluded = "增加"

	CalendarEventViewer_cTitle = "檢視活動內容"
	CalendarEventViewer_cDone = "完成"

	CalendarEventViewer_cLevelRangeFormat = "等級 %i 至 %i"
	CalendarEventViewer_cMinLevelFormat = "等級 %i 或以上"
	CalendarEventViewer_cMaxLevelFormat = "等級 %i 或以下"
	CalendarEventViewer_cAllLevels = "所有等級"
	CalendarEventViewer_cSingleLevel = "只限等級 %i"

	CalendarEventViewer_cYes = "嗯！我會出席此活動！"
	CalendarEventViewer_cNo = "不，我不會出席此活動！"
	CalendarEventViewer_cMaybe = "可能可以參加，把我放在候補名單！"

	CalendarEventViewer_cResponseMessage =
	{
		"狀態: 沒有回應",
		"狀態: 等候確認",
		"狀態: 已確認 - 已接受",
		"狀態: 已確認 - 等候中",
		"狀態: 已確認 - 不出席",
		"狀態: 被禁止",
		"狀態: 已確認 - Maybe attending",
	}

	CalendarEventEditorFrame_cTitle = "新增/修改活動"
	CalendarEvent_cDone = "完成"
	CalendarEvent_cDelete = "刪除"
	CalendarEvent_cGroupTabTitle = "隊伍"

	CalendarEvent_cConfirmDeleteMsg = "刪除 \"%s\"?"

	-- Event names

	GroupCalendar_cGeneralEventGroup = "綜合"
	GroupCalendar_cPersonalEventGroup = "私人活動 (非共享)"
	GroupCalendar_cRaidEventGroup = "團隊"
	GroupCalendar_cDungeonEventGroup = "副本/地下城 (艾澤拉斯)"
	GroupCalendar_cOutlandsDungeonEventGroup = "副本/地下城 (外域)"
	GroupCalendar_cOutlandsHeroicDungeonEventGroup = "英雄模式副本 (外域)"
	GroupCalendar_cBattlegroundEventGroup = "戰場"
	GroupCalendar_cOutdoorRaidEventGroup = "戶外團隊野戰"

	GroupCalendar_cMeetingEventName = "聚會"
	GroupCalendar_cBirthdayEventName = "生日"
	GroupCalendar_cRoleplayEventName = "角色扮演"
	GroupCalendar_cHolidayEventName = "假期"
	GroupCalendar_cDentistEventName = "牙醫"
	GroupCalendar_cDoctorEventName = "醫生"
	GroupCalendar_cVacationEventName = "假期"
	GroupCalendar_cOtherEventName = "其它"

	GroupCalendar_cAQREventName = "安其拉廢墟(RAQ)"
	GroupCalendar_cAQTEventName = "安其拉神廟(TAQ)"
	GroupCalendar_cBFDEventName = "黑暗深淵(BFD)"
	GroupCalendar_cBRDEventName = "黑石深淵(BRD)"
	GroupCalendar_cUBRSEventName = "黑石塔上層(UBRS)"
	GroupCalendar_cLBRSEventName = "黑石塔(LBRS)"
	GroupCalendar_cBWLEventName = "黑翼之巢(BWL)"
	GroupCalendar_cDeadminesEventName = "死亡礦坑(DeadM)"
	GroupCalendar_cDMEventName = "厄運之槌(DM)"
	GroupCalendar_cGnomerEventName = "諾姆瑞根(Gnom)"
	GroupCalendar_cMaraEventName = "瑪拉頓(Mara)"
	GroupCalendar_cMCEventName = "熔火之心(MC)"
	GroupCalendar_cOnyxiaEventName = "奧克妮希亞的巢穴(ONYX)"
	GroupCalendar_cRFCEventName = "怒焰裂谷(RFC)"
	GroupCalendar_cRFDEventName = "剃刀高地(RFD)"
	GroupCalendar_cRFKEventName = "剃刀沼澤(RFK)"
	GroupCalendar_cSMEventName = "血色修道院(SM)"
	GroupCalendar_cScholoEventName = "通靈學院(Scholo)"
	GroupCalendar_cSFKEventName = "影牙城堡(SFK)"
	GroupCalendar_cStockadesEventName = "暴風城監獄"
	GroupCalendar_cStrathEventName = "斯坦索姆(Stra)"
	GroupCalendar_cSTEventName = "阿塔哈卡神廟(ST)"
	GroupCalendar_cUldEventName = "奧達曼(Uld)"
	GroupCalendar_cWCEventName = "哀嚎洞穴(WC)"
	GroupCalendar_cZFEventName = "祖爾法拉克(ZF)"
	GroupCalendar_cZGEventName = "祖爾格拉布(ZG)"
	GroupCalendar_cNaxxEventName = "納克薩瑪斯(NAXX)"

	GroupCalendar_cTheEyeEventName = "風暴之眼(TE)"
	GroupCalendar_cSerpentshrineEventName = "毒蛇神殿洞穴(SSC)"
	GroupCalendar_cMagtheridonEventName = "地獄火堡壘: 瑪瑟里頓的巢穴(ML)"
	GroupCalendar_cHyjalEventName = "海加爾山(HJ)"
	GroupCalendar_cKarazhanEventName = "卡拉贊(KZ)"
	GroupCalendar_cZulAmanEventName = "祖阿曼(ZA)"
	GroupCalendar_cGruulEventName = "戈魯爾之巢(GL)"
	GroupCalendar_cBlackTempleEventName = "黑暗神廟(BT)"
	GroupCalendar_cArcatrazEventName = "風暴要塞: 亞克崔茲"
	GroupCalendar_cBotanicaEventName = "風暴要塞: 波塔尼卡"
	GroupCalendar_cMechanarEventName = "風暴要塞: 麥克那爾"
				
	GroupCalendar_cDurnholdeEventName = "時光之穴: 希爾斯布萊德丘陵遺址"
	GroupCalendar_cDarkPortalEventName = "時光之穴: 黑暗之門"

	GroupCalendar_cAuchenaiCryptsEventName = "奧齊頓: 奧齊奈地穴"
	GroupCalendar_cSethekkHallsEventName = "奧齊頓: 塞司克大廳"
	GroupCalendar_cShadowLabyrinthEventName = "奧齊頓: 暗影迷宮"
	GroupCalendar_cManaTombsEventName = "奧齊頓: 法力墓地"

	GroupCalendar_cSteamvaultEventName = "盤牙洞穴: 蒸汽洞窟"
	GroupCalendar_cUnderbogEventName = "盤牙洞穴: 毒牙沼澤"
	GroupCalendar_cSlavePensEventName = "盤牙洞穴: 奴隸監獄"
				
	GroupCalendar_cShatteredHallsEventName = "地獄火堡壘: 破碎大廳"
	GroupCalendar_cFurnaceEventName = "地獄火堡壘: 血熔爐"
	GroupCalendar_cRampartsEventName = "地獄火堡壘: 地獄火壁壘"

	GroupCalendar_cArcatrazHEventName = "風暴要塞: 亞克崔茲 (英雄模式)"
	GroupCalendar_cBotanicaHEventName = "風暴要塞: 波塔尼卡 (英雄模式)"
	GroupCalendar_cMechanarHEventName = "風暴要塞: 麥克那爾 (英雄模式)"
					
	GroupCalendar_cDurnholdeHEventName = "時光之穴: 敦霍爾德 (英雄模式)"
	GroupCalendar_cDarkPortalHEventName = "時光之穴: 黑暗之門 (英雄模式)"
		
	GroupCalendar_cAuchenaiCryptsHEventName = "奧齊頓: 奧齊奈地穴 (英雄模式)"
	GroupCalendar_cSethekkHallsHEventName = "奧齊頓: 塞司克大廳 (英雄模式)"
	GroupCalendar_cShadowLabyrinthHEventName = "奧齊頓: 暗影迷宮 (英雄模式)"
	GroupCalendar_cManaTombsHEventName = "奧齊頓: 法力墓地 (英雄模式)"
		
	GroupCalendar_cSteamvaultHEventName = "盤牙洞穴: 蒸汽洞窟 (英雄模式)"
	GroupCalendar_cUnderbogHEventName = "盤牙洞穴: 毒牙沼澤 (英雄模式)"
	GroupCalendar_cSlavePensHEventName = "盤牙洞穴: 奴隸監獄 (英雄模式)"
					
	GroupCalendar_cShatteredHallsHEventName = "地獄火堡壘: 破碎大廳 (英雄模式)"
	GroupCalendar_cFurnaceHEventName = "地獄火堡壘: 血熔爐 (英雄模式)"
	GroupCalendar_cRampartsHEventName = "地獄火堡壘: 地獄火壁壘 (英雄模式)"

	GroupCalendar_cMagistersEventName = "博學者殿堂"
	GroupCalendar_cMagistersHEventName = "博學者殿堂 (英雄模式)"
	GroupCalendar_cSunwellEventName = "太陽井高地(SwP)"

	GroupCalendar_cPvPEventName = "綜合 PvP"
	GroupCalendar_cA2v2EventName = "競技場(2v2)"
	GroupCalendar_cA3v3EventName = "競技場(3v3)"
	GroupCalendar_cA5v5EventName = "競技場(5v5)"
	GroupCalendar_cABEventName = "阿拉希盆地(AB)"
	GroupCalendar_cAVEventName = "奧特蘭克山谷(AV)"
	GroupCalendar_cWSGEventName = "戰歌峽谷(WSG)"
	GroupCalendar_cEotSEventName = "暴風之眼(ES)"

	GroupCalendar_cDoomWalkerEventName = "末日行者(DW)"
	GroupCalendar_cDoomLordKazzakEventName = "毀滅之王卡札克(LKK)"

	GroupCalendar_cZGResetEventName = "祖爾格拉布 重置"
	GroupCalendar_cMCResetEventName = "熔火之心 重置"
	GroupCalendar_cOnyxiaResetEventName = "奧克妮希亞的巢穴 重置"
	GroupCalendar_cBWLResetEventName = "黑翼之巢 重置"
	GroupCalendar_cAQRResetEventName = "安其拉廢墟 重置"
	GroupCalendar_cAQTResetEventName = "安其拉神廟 重置"
	GroupCalendar_cNaxxResetEventName = "納克薩瑪斯 重置"
	GroupCalendar_cKarazhanResetEventName = "卡拉贊 重置"
	GroupCalendar_cZulAmanResetEventName = "祖阿曼 重置"
	GroupCalendar_cBlackTempleResetEventName = "黑暗神廟 重置"
	GroupCalendar_cTheEyeResetEventName = "暴風之眼 重置"
	GroupCalendar_cSerpentshrineResetEventName = "毒蛇神殿 重置"
	GroupCalendar_cMagtheridonResetEventName = "馬瑟里頓 重置"
	GroupCalendar_cHyjalResetEventName = "海加爾山 重置"
	GroupCalendar_cGruulResetEventName = "哥魯爾之巢 重置"
	GroupCalendar_cSunwellResetEventName = "太陽井高地 重置"

	GroupCalendar_cTransmuteCooldownEventName = "轉化 冷卻就緒"
	GroupCalendar_cSaltShakerCooldownEventName = "篩鹽器 冷卻就緒"
	GroupCalendar_cMoonclothCooldownEventName = "月布 冷卻就緒"
	GroupCalendar_cPrimalMoonclothCooldownEventName = "原始月布 冷卻就緒"
	GroupCalendar_cSpellclothCooldownEventName = "符咒布 冷卻就緒"
	GroupCalendar_cShadowclothCooldownEventName = "暗影布 冷卻就緒"
	GroupCalendar_cSnowmasterCooldownEventName = "雪王9000型 冷卻就緒"
	GroupCalendar_cBrilliantGlassCooldownEventName = "明亮的玻璃結晶 冷卻就緒"
	GroupCalendar_cVoidShatterCooldownEventName = "粉碎虛無 冷卻就緒"
	GroupCalendar_cVoidSphereCooldownEventName = "Void Sphere Available"

	GroupCalendar_cPersonalEventOwner = "私人活動"

	GroupCalendar_cRaidInfoMCName = GroupCalendar_cMCEventName
	GroupCalendar_cRaidInfoOnyxiaName = GroupCalendar_cOnyxiaEventName
	GroupCalendar_cRaidInfoZGName = GroupCalendar_cZGEventName
	GroupCalendar_cRaidInfoBWLName = GroupCalendar_cBWLEventName
	GroupCalendar_cRaidInfoAQRName = GroupCalendar_cAQREventName
	GroupCalendar_cRaidInfoAQTName = GroupCalendar_cAQTEventName
	GroupCalendar_cRaidInfoNaxxName = GroupCalendar_cNaxxEventName
	GroupCalendar_cRaidInfoKarazhanName = GroupCalendar_cKarazhanEventName
	GroupCalendar_cRaidInfoZulAmanName = GroupCalendar_cZulAmanEventName
	GroupCalendar_cRaidInfoSunwellName = GroupCalendar_cSunwellEventName

	-- Race names

	GroupCalendar_cDwarfRaceName = "矮人"
	GroupCalendar_cGnomeRaceName = "地精"
	GroupCalendar_cHumanRaceName = "人類"
	GroupCalendar_cNightElfRaceName = "夜精靈"
	GroupCalendar_cOrcRaceName = "獸人"
	GroupCalendar_cTaurenRaceName = "牛頭人"
	GroupCalendar_cTrollRaceName = "食人妖"
	GroupCalendar_cUndeadRaceName = "不死族"
	GroupCalendar_cBloodElfRaceName = "血精靈"
	GroupCalendar_cDraeneiRaceName = "德萊尼"

	-- Class names

	GroupCalendar_cFemaleDruidClassName = "德魯伊"
	GroupCalendar_cMaleDruidClassName = "德魯伊"
	GroupCalendar_cFemaleHunterClassName = "獵人"
	GroupCalendar_cMaleHunterClassName = "獵人"
	GroupCalendar_cFemaleMageClassName = "法師"
	GroupCalendar_cMaleMageClassName = "法師"
	GroupCalendar_cFemalePaladinClassName = "聖騎士"
	GroupCalendar_cMalePaladinClassName = "聖騎士"
	GroupCalendar_cFemalePriestClassName = "牧師"
	GroupCalendar_cMalePriestClassName = "牧師"
	GroupCalendar_cFemaleRogueClassName = "盜賊"
	GroupCalendar_cMaleRogueClassName = "盜賊"
	GroupCalendar_cFemaleShamanClassName = "薩滿"
	GroupCalendar_cMaleShamanClassName = "薩滿"
	GroupCalendar_cFemaleWarlockClassName = "術士"
	GroupCalendar_cMaleWarlockClassName = "術士"
	GroupCalendar_cFemaleWarriorClassName = "戰士"
	GroupCalendar_cMaleWarriorClassName = "戰士"

	-- Plural forms of class names

	GroupCalendar_cDruidsClassName = "德魯伊"
	GroupCalendar_cHuntersClassName = "獵人"
	GroupCalendar_cMagesClassName = "法師"
	GroupCalendar_cPaladinsClassName = "聖騎士"
	GroupCalendar_cPriestsClassName = "牧師"
	GroupCalendar_cRoguesClassName = "盜賊"
	GroupCalendar_cShamansClassName = "薩滿"
	GroupCalendar_cWarlocksClassName = "術士"
	GroupCalendar_cWarriorsClassName = "戰士"

	-- ClassColorNames are the indices for the RAID_CLASS_COLORS array found in FrameXML\Fonts.xml
	-- in the English version of WoW these are simply the class names in caps, I don't know if that's
	-- true of other languages so I'm putting them here in case they need to be localized

	GroupCalendar_cDruidClassColorName = "DRUID"
	GroupCalendar_cHunterClassColorName = "HUNTER"
	GroupCalendar_cMageClassColorName = "MAGE"
	GroupCalendar_cPaladinClassColorName = "PALADIN"
	GroupCalendar_cPriestClassColorName = "PRIEST"
	GroupCalendar_cRogueClassColorName = "ROGUE"
	GroupCalendar_cShamanClassColorName = "SHAMAN"
	GroupCalendar_cWarlockClassColorName = "WARLOCK"
	GroupCalendar_cWarriorClassColorName = "WARRIOR"

	-- Label forms of the class names for the attendance panel.  Usually just the plural
	-- form of the name followed by a colon

	GroupCalendar_cDruidsLabel = GroupCalendar_cDruidsClassName..":"
	GroupCalendar_cHuntersLabel = GroupCalendar_cHuntersClassName..":"
	GroupCalendar_cMagesLabel = GroupCalendar_cMagesClassName..":"
	GroupCalendar_cPaladinsLabel = GroupCalendar_cPaladinsClassName..":"
	GroupCalendar_cPriestsLabel = GroupCalendar_cPriestsClassName..":"
	GroupCalendar_cRoguesLabel = GroupCalendar_cRoguesClassName..":"
	GroupCalendar_cShamansLabel = GroupCalendar_cShamansClassName..":"
	GroupCalendar_cWarlocksLabel = GroupCalendar_cWarlocksClassName..":"
	GroupCalendar_cWarriorsLabel = GroupCalendar_cWarriorsClassName..":"

	GroupCalendar_cTimeLabel = "時間:"
	GroupCalendar_cDurationLabel = "需時:"
	GroupCalendar_cEventLabel = "活動:"
	GroupCalendar_cTitleLabel = "標題:"
	GroupCalendar_cLevelsLabel = "等級:"
	GroupCalendar_cLevelRangeSeparator = "至"
	GroupCalendar_cDescriptionLabel = "內容:"
	GroupCalendar_cCommentLabel = "備註:"

	CalendarEditor_cNewEvent = "新活動..."
	CalendarEditor_cEventsTitle = "活動"

	CalendarEvent_cNotAttending = "不出席"
	CalendarEvent_cConfirmed = "已確定"
	CalendarEvent_cDeclined = "已拒絕"
	CalendarEvent_cStandby = "在等候名單"
	CalendarEvent_cPending = "遲疑不決"
	CalendarEvent_cBanned = "封鎖"
	CalendarEvent_cUnknownStatus = "不明 %s"

	GroupCalendar_cChannelNameLabel = "頻道名稱:"
	GroupCalendar_cPasswordLabel = "密碼:"

	GroupCalendar_cSingleTimeDateFormat = "%s  %s"
	GroupCalendar_cTimeDateRangeFormat = "%s  %s至%s"

	GroupCalendar_cPluralMinutesFormat = "%d分鐘"
	GroupCalendar_cSingularHourFormat = "%d小時"
	GroupCalendar_cPluralHourFormat = "%d小時"
	GroupCalendar_cSingularHourPluralMinutes = "%d小時%d分鐘"
	GroupCalendar_cPluralHourPluralMinutes = "%d小時%d分鐘"

	GroupCalendar_cLongDateFormat = "$year".."年".."$month".."$day".."日"
	GroupCalendar_cShortDateFormat = "$day/$monthNum"
	GroupCalendar_cLongDateFormatWithDayOfWeek = "$dow $year".."年".."$month".."$day".."日"

	GroupCalendar_cNotAttendingCategory = "不出席"
	GroupCalendar_cAttendingCategory = "出席"
	GroupCalendar_cPendingApprovalCategory = "等待審核"
	GroupCalendar_cStandbyCategory = "等候中"
	GroupCalendar_cMaybeCategory = "Maybe"
	GroupCalendar_cWhispersCategory = "最近的密語者"
	GroupCalendar_cBannedCategory = "封鎖"

	GroupCalendar_cQuestAttendanceNameFormat = "$name ($level $race)"
	GroupCalendar_cMeetingAttendanceNameFormat = "$name ($level $class)"
	GroupCalendar_cGroupAttendanceNameFormat = "$name ($status)"

	GroupCalendar_cNumAttendeesFormat = "%d 位出席"
	GroupCalendar_cTotalNumPlayersFormat = "%s 位玩家"

	BINDING_HEADER_GROUPCALENDAR_TITLE = "團隊行事曆"
	BINDING_NAME_GROUPCALENDAR_TOGGLE = "打開/關閉團隊行事曆"

	-- Tradeskill cooldown items

	GroupCalendar_cHerbalismSkillName = "草藥學"
	GroupCalendar_cAlchemySkillName = "鍊金術"
	GroupCalendar_cEnchantingSkillName = "附魔"
	GroupCalendar_cLeatherworkingSkillName = "製皮"
	GroupCalendar_cSkinningSkillName = "剝皮"
	GroupCalendar_cTailoringSkillName = "裁縫"
	GroupCalendar_cMiningSkillName = "採礦"
	GroupCalendar_cBlacksmithingSkillName = "鍛造"
	GroupCalendar_cEngineeringSkillName = "工程學"

	GroupCalendar_cTransmuteMithrilToTruesilver = "轉化真銀"
	GroupCalendar_cTransmuteIronToGold = "轉化:轉鐵成金"
	GroupCalendar_cTransmuteLifeToEarth = "轉化:生命歸土"
	GroupCalendar_cTransmuteWaterToUndeath = "轉化:水轉死靈"
	GroupCalendar_cTransmuteWaterToAir = "轉化:轉水成氣"
	GroupCalendar_cTransmuteUndeathToWater = "轉化:死靈化水"
	GroupCalendar_cTransmuteFireToEarth = "轉化:轉火成土"
	GroupCalendar_cTransmuteEarthToLife = "轉化:土轉生命"
	GroupCalendar_cTransmuteEarthToWater = "轉化:轉土成水"
	GroupCalendar_cTransmuteAirToFire = "轉化:轉氣成火"
	GroupCalendar_cTransmuteArcanite = "轉化:奧金"
	GroupCalendar_cTransmutePrimalAirToFire = "轉化:原始空氣轉原始之火"
	GroupCalendar_cTransmutePrimalFireToEarth = "轉化:原始之火轉原始大地"
	GroupCalendar_cTransmutePrimalEarthToWater = "轉化:原始大地轉原始之水"
	GroupCalendar_cTransmutePrimalWaterToAir = "轉化:原始之水轉原始空氣"
	GroupCalendar_cTransmutePrimalEarthToLife = "轉化:原始大地轉原始生命"
	GroupCalendar_cTransmutePrimalLifeToEarth= "轉化:原始生命轉原始大地"
	GroupCalendar_cTransmutePrimalFireToMana = "轉化:原始之火轉原始法力"
	GroupCalendar_cTransmutePrimalManaToFire = "轉化:原始法力轉原始之火"
	GroupCalendar_cTransmutePrimalShadowToWater = "轉化:原始暗影轉原始之水"
	GroupCalendar_cTransmutePrimalWaterToShadow = "轉化:原始之水轉原始暗影"
	GroupCalendar_cTransmutePrimalMight = "轉化:原始力量"
	GroupCalendar_cTransmuteEarthstormDiamond = "轉化:大地風暴鑽石"
	GroupCalendar_cTransmuteSkyfireDiamond = "轉化:天火鑽石"

	GroupCalendar_cMooncloth = "月布"
	GroupCalendar_cPrimalMooncloth = "原始月布"
	GroupCalendar_cSpellcloth = "魔法布"
	GroupCalendar_cShadowcloth = "暗影布"

	GroupCalendar_cBrilliantGlass = "明亮的玻璃結晶"
	GroupCalendar_cVoidShatter = "粉碎虛無"
	GroupCalendar_cVoidSphere = "Void Sphere"

	GroupCalendar_cCharactersLabel = "角色:"

	GroupCalendar_cConfirmed = "已接受"
	GroupCalendar_cStandby = "等候中"
	GroupCalendar_cMaybe = "Maybe Attending"
	GroupCalendar_cDeclined = "已拒絕"
	GroupCalendar_cRemove = "移除"
	GroupCalendar_cEditPlayer = "修改玩家..."
	GroupCalendar_cInviteNow = "邀請到隊伍"
	GroupCalendar_cStatus = "狀態"
	GroupCalendar_cAddPlayerEllipses = "加入玩家..."

	GroupCalendar_cAddPlayer = "加入玩家"
	GroupCalendar_cPlayerLevel = "等級:"
	GroupCalendar_cPlayerClassLabel = "職業:"
	GroupCalendar_cPlayerRaceLabel = "種族:"
	GroupCalendar_cPlayerStatusLabel = "狀態:"
	GroupCalendar_cRankLabel = "公會階級:"
	GroupCalendar_cGuildLabel = "公會:"
	GroupCalendar_cSave = "儲存"
	GroupCalendar_cLastWhisper = "最近密語者:"
	GroupCalendar_cReplyWhisper = "密語者回覆:"

	GroupCalendar_cUnknown = "未知"
	GroupCalendar_cAutoConfirmationTitle = "自動確認"
	GroupCalendar_cRoleConfirmationTitle = "自動照角色確認"
	GroupCalendar_cManualConfirmationTitle = "手動確認"
	GroupCalendar_cClosedEventTitle = "關閉活動"
	GroupCalendar_cMinLabel = "最低"
	GroupCalendar_cMaxLabel = "最高"

	GroupCalendar_cAddPlayerTitle = "新增..."
	GroupCalendar_cAutoConfirmButtonTitle = "設定..."

	GroupCalendar_cClassLimitDescription = "設定下列每種職業的最低及最高人數。若該職業的人數尚未符合最低要求，您將被自動填補空缺。當人數到達上限時，將會有額外的提示。"
	GroupCalendar_cRoleLimitDescription = "設定下列每種角色的最低及最高人數。若該角色的人數尚未符合最低要求，您將被自動填補空缺。當角色人數到達上限時，將會有額外的提示。您可以手動設定各職業擔任各角色的下限(例如說需要一個暗牧當遠程DPS)"

	GroupCalendar_cViewGroupBy = "分組依照:"
	GroupCalendar_cViewByStatus = "狀況"
	GroupCalendar_cViewByClass = "職業"
	GroupCalendar_cViewByRole = "角色"
	GroupCalendar_cViewSortBy = "排序依照:"
	GroupCalendar_cViewByDate = "時間"
	GroupCalendar_cViewByRank = "公會階級"
	GroupCalendar_cViewByName = "名稱"

	GroupCalendar_cMaxPartySizeLabel = "隊伍人數上限:"
	GroupCalendar_cMinPartySizeLabel = "隊伍人數下限:"
	GroupCalendar_cNoMinimum = "沒有下限"
	GroupCalendar_cNoMaximum = "沒有上限"
	GroupCalendar_cPartySizeFormat = "%d 位玩家"

	GroupCalendar_cInviteButtonTitle = "邀請已選玩家"
	GroupCalendar_cAutoSelectButtonTitle = "選取玩家..."
	GroupCalendar_cAutoSelectWindowTitle = "選取玩家"

	GroupCalendar_cNoSelection = "沒有玩家選取"
	GroupCalendar_cSingleSelection = "選取了 1 位玩家"
	GroupCalendar_cMultiSelection = "選取了 %d 位玩家"

	GroupCalendar_cInviteNeedSelectionStatus = "選擇準備邀請的玩家"
	GroupCalendar_cInviteReadyStatus = "準備邀請"
	GroupCalendar_cInviteInitialInvitesStatus = "傳送首次的邀請"
	GroupCalendar_cInviteAwaitingAcceptanceStatus = "等待首次的邀請回應"
	GroupCalendar_cInviteConvertingToRaidStatus = "轉換至團隊"
	GroupCalendar_cInviteInvitingStatus = "傳送邀請"
	GroupCalendar_cInviteCompleteStatus = "邀請完畢"
	GroupCalendar_cInviteReadyToRefillStatus = "準備填補空缺"
	GroupCalendar_cInviteNoMoreAvailableStatus = "已經沒有玩家可以填補隊伍"
	GroupCalendar_cRaidFull = "團隊已滿"

	GroupCalendar_cInviteWhisperFormat = "[團隊行事曆] 您已經被邀請加入 '%s' 活動。若閣下想加入此活動，請接受此邀請。"
	GroupCalendar_cAlreadyGroupedWhisper = "[團隊行事曆] 您已經加入了一個隊伍。請閣下您在離開您現在的隊伍後，使用 /w 回覆。"

	GroupCalendar_cAlreadyGroupedSysMsg = "(.+) 已經有隊伍"
	GroupCalendar_cInviteDeclinedSysMsg = "(.+) 拒絕您的組隊激請。"
	GroupCalendar_cNoSuchPlayerSysMsg = "現在線上找不到名為 '(.+)' 的玩家。"

	GroupCalendar_cJoinedGroupStatus = "已加入"
	GropuCalendar_cInvitedGroupStatus = "已邀請"
	GropuCalendar_cReadyGroupStatus = "就緒"
	GroupCalendar_cGroupedGroupStatus = "在其他隊伍"
	GroupCalendar_cStandbyGroupStatus = "等候"
	GroupCalendar_cMaybeGroupStatus = "Maybe"
	GroupCalendar_cDeclinedGroupStatus = "拒絕邀請"
	GroupCalendar_cOfflineGroupStatus = "下線"
	GroupCalendar_cLeftGroupStatus = "離開隊伍"

	GroupCalendar_cPriorityLabel = "優先權:"
	GroupCalendar_cPriorityDate = "時間"
	GroupCalendar_cPriorityRank = "階級"

	GroupCalendar_cConfirmSelfUpdateMsg = "%s"
	GroupCalendar_cConfirmSelfUpdateParamFormat = "有一份關於 $mUserName 的活動新版本可以從 $mSender 取得。您想更新您的資料到這個新版本嗎？當您更新任何與您有關的活動，在該活動的邀請及變動過的資訊將會被取消並更新至最新版本"
	GroupCalendar_cConfirmSelfDeleteParamFormat = "您所有的活動已於網路上刪除。若您無意將其他電腦的活動一起刪除的話，請取消此更新來還原您的活動，否則請按更新來刪除本電腦的活動。"
	GroupCalendar_cConfirmSelfRSVPUpdateParamFormat = "有一份關於 %mUserName 的新出席資訊可以從 $mSender 取得。您想更新您的出席邀請到最新版本嗎？若您更新這個資訊，所有未確認的邀請將會被取消並更新至最新版本"
	GroupCalendar_cConfirmSelfRSVPDeleteParamFormat = "所有您的出席邀請資訊已經刪除。若您無意將其他電腦的邀請資訊一起刪除的話，請取消此更新來還原您的活動，否則請按更新來刪除本電腦的邀請資訊。"
	GroupCalendar_cUpdate = "更新"

	GroupCalendar_cConfirmClearWhispers = "清除所有最近的悄悄話？"
	GroupCalendar_cClear = "清除"

	CalendarDatabases_cTitle = "團隊行事曆版本資訊"
	CalendarDatabases_cRefresh = "重新整理"
	CalendarDatabases_cRefreshDescription = "要求線上玩家回報他們使用的版本編號。重新整理版本資訊需時數分鐘。即使您把新視窗關閉，更新程序仍然會繼續進行。"

	GroupCalendar_cVersionFormat = "團隊行事曆 v%s"
	GroupCalendar_cShortVersionFormat = "v%s"
	GroupCalendar_cVersionUpdatedFormat = "資訊於 %s %s 更新 (本地時間)"
	GroupCalendar_cVersionUpdatedUnknown = "無法確認版本時間"

	GroupCalendar_cToggleVersionsTitle = "顯示玩家版本"
	GroupCalendar_cToggleVersionsDescription = "顯示其它玩家正在使用的版本"

	GroupCalendar_cChangesDelayedMessage = "團隊行事曆: 資料將於網路資訊同步化後變更。在資料同步化完成之前，資料不會傳送。"

	GroupCalendar_cConfirmKillMsg = "您確定要將 %s 建立的活動從資訊網路上強制刪除？"; 
	GroupCalendar_cKill = "刪除"

	GroupCalendar_cNotAnOfficerError = "團隊行事曆: 只有公會幹部成員能執行此動作"
	GroupCalendar_cUserNameExpected = "團隊行事曆: 要求使用者名稱"
	GroupCalendar_cDatabaseNotFoundError = "團隊行事曆: 找不到 %s 的資料庫。"
	GroupCalendar_cCantKillGuildieError = "團隊行事曆: 無法刪除一位在您公會內的玩家"

	GroupCalendar_cTooltipScheduleItemFormat = "%s (%s)"

	GroupCalendar_cAvailableMinutesFormat = "%s 尚餘 %d 分鐘"
	GroupCalendar_cAvailableMinuteFormat = "%s 尚餘 %d 分鐘"
	GroupCalendar_cStartsMinutesFormat = "%s 將於 %d 分鐘後開始"
	GroupCalendar_cStartsMinuteFormat = "%s 將於 %d 分鐘內開始"
	GroupCalendar_cStartingNowFormat = "%s 現在開始"
	GroupCalendar_cAlreadyStartedFormat = "%s 已經開始"
	GroupCalendar_cHappyBirthdayFormat = "%s 祝你生日快樂！"

	GroupCalendar_cTimeRemainingFormat = "(下次同步 %d:%02d)"
	GroupCalendar_cUnknownEventType = "%s (新活動種類, 請更新您的團隊行事曆)"

	GroupCalendar_cConfirmResetMsg = "您確定要重置在 %s 的角色行事曆? 您在此角色相關活動將會被刪除。"
	GroupCalendar_cConfirmResetRealmMsg = "您確定要重置所有在 %s 的角色行事曆? 您在此伺服器的所有角色相關活動將會被刪除。"
	GroupCalendar_cConfirmResetAllMsg = "您確定要重置所有伺服器的角色行事曆? 您在所有伺服器的角色相關活動將會被刪除。"
	GroupCalendar_cReset = "重置"

	GroupCalendar_cNone = "無"

	GroupCalendar_cAttendanceNote = "您已經更改了您的 %s 出席狀況。請在5分鐘內盡量不要登出，以便完成您的變更要求。在活動建立者未上線之前，您的狀態將會顯示為懸而未決。"
	GroupCalendar_cUnknownClockOption = "團隊行事曆: 不明時間選頂"
	GroupCalendar_cBadAgeValue = "事件的最大範圍必須在1到60天內"
	GroupCalendar_cViewMenuFormat = "檢視依照 %s/%s"
	GroupCalendar_cDefaultTimeFormat = 12
	GroupCalendar_cDefaultStartDay = "Sun"
	GroupCalendar_cForeignRealmFormat = "%s 與 %s"

	GroupCalendar_cMHRole = "主要補職"
	GroupCalendar_cOHRole = "輔助補職"
	GroupCalendar_cMTRole = "主要坦職"
	GroupCalendar_cOTRole = "輔助坦職"
	GroupCalendar_cRDRole = "遠距傷害職"
	GroupCalendar_cMDRole = "近戰傷害職"

	GroupCalendar_cMHPluralRole = "主要補職"
	GroupCalendar_cOHPluralRole = "輔助補職"
	GroupCalendar_cMTPluralRole = "主要坦克"
	GroupCalendar_cOTPluralRole = "輔助坦克"
	GroupCalendar_cRDPluralRole = "遠距DPS"
	GroupCalendar_cMDPluralRole = "近戰DPS"

	GroupCalendar_cMHPluralLabel = GroupCalendar_cMHPluralRole..":"
	GroupCalendar_cOHPluralLabel = GroupCalendar_cOHPluralRole..":"
	GroupCalendar_cMTPluralLabel = GroupCalendar_cMTPluralRole..":"
	GroupCalendar_cOTPluralLabel = GroupCalendar_cOTPluralRole..":"
	GroupCalendar_cRDPluralLabel = GroupCalendar_cRDPluralRole..":"
	GroupCalendar_cMDPluralLabel = GroupCalendar_cMDPluralRole..":"

	GroupCalendar_cClockNotSetWarning = "警告: %s indicate that their clocks are set to a significantly different time or date than yours.  Check your time and date settings as this may cause problems with posting or signing up for events, especially if you log in from multiple computers."

	GroupCalendar.cWhisperSummaryDateHeader    = "%s"
	GroupCalendar.cWhisperSummaryEvent         = "    $time $event [ID $id]"
	GroupCalendar.cWhisperSummaryEventStatus   = "    $time $event [ID $id] ($status)"
	GroupCalendar.cWhisperSummaryNoEvents      = "沒有新的活動"
	GroupCalendar.cWhisperSummaryInvalidOption = "%s 不是一個正確的指令。用'!gc help'來顯示所有正確的指令"

	GroupCalendar.cWhisperHelp =
	{
		"!gc - 跟!gc summary相同",
		"!gc summary - 顯示接下來七天的活動",
		"!gc yes eventid - 報名參加一個活動",
		"!gc no eventid - 報名不參加一個活動",
		"!gc maybe eventid - 報名候補一個活動",
		"!gc help - 顯示所有指令",
		"Event IDs appear in the summary of events.  If the event was created by the same character that you're whispering you can just use the number, otherwise use the name-number format to specify the event"
	}

	GroupCalendar.cDatabasesTotalFormat = "%d 資料庫"

	GroupCalendar_cConfirmDeleteRSVP = "您確定要將 %s 從清單中移除？"

	GroupCalendar.cCantReloadUI = GroupCalendar_cTitleVersion.." 將新檔案放入插件資料夾並不會讓WOW執行它，團隊行事曆需要您將WOW主程式關閉後重啟才能正常運作"

	GroupCalendar.cWhisperAccessDenied = "您被拒絕參加 %s 活動"
	GroupCalendar.cWhisperCantProxy = "您必須使用 %s 或分身角色來參加這個活動"
	GroupCalendar.cWhisperDatabaseNotFound = "資料庫 %s 未發現"
	GroupCalendar.cWhisperEventNotFound = "活動ID %d 並未在 %s 中被發現"
	GroupCalendar.cWhisperFailed = "不明的原因使您的要求失敗了，需要活動主持者手動加入您"
	GroupCalendar.cWhisperNotGuildmate = "非同公會的人員無法參加活動"
	GroupCalendar.cWhisperEventStatus = "Your status for %s on %s at %s is now %s"
	GroupCalendar.cWhisperAllDayStatus = "Your status for %s on %s is now %s"
	GroupCalendar.cWhisperWTFError = "無法解譯活動ID '%s'"
	GroupCalendar.cWhisperHelpReminder = "使用'!gc help'來查詢更多指令"

	GroupCalendar.cAttendanceNoticeYes = "$name 已經成功報名於 $event 活動"
	GroupCalendar.cAttendanceNoticeLimitStandby = "$name 在 $event 活動的候補名單: 職業或角色已經達到活動設定之需求"
	GroupCalendar.cAttendanceNoticeStandby = "$name 已經成功報名候補於 $event 活動"
	GroupCalendar.cAttendanceNoticeNo = "$name 已經拒絕參加 $event 活動"
	GroupCalendar.cAttendanceNoticeBanned = "$name 報名 $event 活動失敗: 此玩家已被此活動封鎖"
	GroupCalendar.cAttendanceNoticeManual = " $name 在 $event 活動的候補名單: 這個活動需要您手動確認"
	GroupCalendar.cAttendanceUnknownQualifiedError = "您沒有符合參加這個活動的條件，但是團隊行事曆沒有收到未何失敗的理由"
	GroupCalendar.cAttendanceNoticeMaybe = "$name might be attending $event on $date"

	GroupCalendar.cAttendanceClosedEvent = "這是一個封閉的活動 - 所有參與者需要主持者手動加入"
	GroupCalendar.cAttendanceUnknownLevel = "這個活動有等級限制而您的等級未知"
	GroupCalendar.cAttendanceLevelTooLow = "您的等級低於此活動的限制"
	GroupCalendar.cAttendanceLevelTooHigh = "您的等級高於此活動的限制"
	GroupCalendar.cAttendanceGuildMembersOnly = "這個活動只限 <%s> 成員參加"
	GroupCalendar.cAttendanceRankTooLow = "您的公會階級低於此活動的最低限制"
	GroupCalendar.cAttendanceNotAllowed = "您沒有被允許使用團隊行事曆"
	GroupCalendar.cAttendanceSynching = "團隊行事曆已經同步處理完成。如要再次同步請稍後幾分鐘。"

	GroupCalendar.cNewerVersionMessage = "一個新的版本已經可以下載 (%s)"

	GroupCalendar.cBackupTitle = "備份與回復"
	GroupCalendar.cNoBackups = "沒有任何資料被備份。資料會自動備份如果您的行事曆資料被更改過，或是您可以使用'立即備份資料'按鈕即刻備份您的行事曆。"
	GroupCalendar.cBackupNow = "立刻備份資料"
	GroupCalendar.cBackupNowDescription = "建立一份關於 %s 活動的參加人員名單及和活動備份"
	GroupCalendar.cConfirmDeleteBackup = "您確定您要移除 %s 活動的備份?"
	GroupCalendar.cConfirmRestoreBackup = "您確定您要使用之前的備份記錄回復 %s 活動?"
	GroupCalendar.cRestoreBackup = "回復"
	GroupCalendar.cBackupRestored = "已使用之前的備份回復了這個活動。其他的使用者會在幾分鐘內更新此活動。"
	
	GroupCalendar.cNetworkSyncComplete = "Network synchronization completed"
end
