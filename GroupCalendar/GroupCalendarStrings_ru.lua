-- Translation by Eritnull (StingerSoft aka Шептун)
if GetLocale() == "ruRU" then
	GroupCalendar_cTitle = "Организатор v%s"

	GroupCalendar.cSingleItemFormat = "%s"
	GroupCalendar.cTwoItemFormat = "%s и %s"
	GroupCalendar.cMultiItemFormat = "%s{{, %s}} и %s"

	GroupCalendar_cSun = "Вос"
	GroupCalendar_cMon = "Пон"
	GroupCalendar_cTue = "Вт"
	GroupCalendar_cWed = "Сред"
	GroupCalendar_cThu = "Чет"
	GroupCalendar_cFri = "Пят"
	GroupCalendar_cSat = "Суб"

	GroupCalendar_cSunday = "Восресенье"
	GroupCalendar_cMonday = "Понедельник"
	GroupCalendar_cTuesday = "Вторник"
	GroupCalendar_cWednesday = "Среда"
	GroupCalendar_cThursday = "Четверг"
	GroupCalendar_cFriday = "Пятница"
	GroupCalendar_cSaturday = "Суббота"

	GroupCalendar_cSelfWillAttend = "%s будет присутствовать"
	GroupCalendar_cGuildOnly = "Только <%s> представителям"

	GroupCalendar_cMonthNames = {"Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"}
	GroupCalendar_cDayOfWeekNames = {GroupCalendar_cSunday, GroupCalendar_cMonday, GroupCalendar_cTuesday, GroupCalendar_cWednesday, GroupCalendar_cThursday, GroupCalendar_cFriday, GroupCalendar_cSaturday}

	GroupCalendar_cLoadMessage = "Организатор загружен. Для просмотра событий используйте календарь /cal show. Или посетите http://wobbleworks.com/groupcalendar/manual"
	GroupCalendar_cInitializingGuilded = "Организатор: Инициализация настроек для игрока состоящего в гильдии"
	GroupCalendar_cInitializingUnguilded = "Организатор: Инициализация настроек для игрока не состоящего в гильдии"
	GroupCalendar_cLocalTimeNote = "(%s местное)"

	GroupCalendar_cOptions = "Установки..."

	GroupCalendar_cCalendar = "Календарь"
	GroupCalendar_cSetup = "Установки"
	GroupCalendar_cBackup = "Резерв"
	GroupCalendar_cAbout = "О Аддоне"

	GroupCalendar_cUseServerDateTime = "Дата и Время сервера"
	GroupCalendar_cUseServerDateTimeDescription = "Включите чтобы использовалось серверное время и дату для событий, или выключите чтобы использовалось локальное время и дату"

	GroupCalendar_cSetupTitle = "Установки Организатора"
	GroupCalendar_cConfigModeLabel = "Конфигурация:"
	GroupCalendar_cAutoChannelConfig = "Автоматическая"
	GroupCalendar_cManualChannelConfig = "Ручная"
	GroupCalendar_cAdminChannelConfig = "Администратор"

	GroupCalendar_cUseGuildChannel = "Использовать канал гильдии"
	GroupCalendar_cUseGuildChannelDescription = "Использовать встроенный канал гильдии.  Канал доступен только для членов гильдии."

	GroupCalendar_cUseSharedChannel = "Использовать общий канал"
	GroupCalendar_cUseSharedChannelDescription = "Использовать общий канал для передачи данных Организатора. Этот канал доступен для всех на вашем сервере. Вы можете использовать пароль, чтобы ограничить доступ."

	GroupCalendar_cApplyChannelChanges = "Применить"
	GroupCalendar_cManualConfigTipDescription = "Позволяет вам вручную ввести название канала и пароль."
	GroupCalendar_cStoreAutoConfigTipDescription = "Позволяет офицерам гильдии хранитьa информацию конфигурации канала в заметке выбранного игрока в списке гильдии."
	GroupCalendar_cAutoConfigPlayerTipDescription = "Имя игрока из списка гильдии содержащего информацию настроек канала."
	GroupCalendar_cChannelNameTipTitle = "Название канала"
	GroupCalendar_cChannelNameTipDescription = "Название канала, который будет использоваться, для отсылки и приёма данных о событиях между другими игроками"
	GroupCalendar_cConnectChannel = "Соединить"
	GroupCalendar_cDisconnectChannel = "Разъединить"
	GroupCalendar_cChannelStatus =
	{
		Starting = {mText = "Статус: Запуск...", mColor = {r = 1, g = 1, b = 0.3}},
		Synching = {mText = "Статус: Синхронизация с сетью %s", mColor = {r = 0.3, g = 1, b = 0.3}},
		Suspended = {mText = "Статус: Приостановлен (выходит)", mColor = {r = 1, g = 1, b = 0.3}},
		Connected = {mText = "Статус: Канал данных подключен", mColor = {r = 0.3, g = 1, b = 0.3}},
		Disconnected = {mText = "Статус: Канал данных не подключен", mColor = {r = 1, g = 0.5, b = 0.2}},
		Initializing = {mText = "Статус: Инициализация канала данных", mColor = {r = 1, g = 1, b = 0.3}},
		Error = {mText = "Ошибка: %s", mColor = {r = 1, g = 0.2, b = 0.4}},
	}

	GroupCalendar_cConnected = "Подключен"
	GroupCalendar_cDisconnected = "Разъединён"
	GroupCalendar_cTooManyChannels = "Вы уже присоединились к максимальному числу каналов"
	GroupCalendar_cJoinChannelFailed = "По неизвестным причинам не-удалось подключиться к каналу"
	GroupCalendar_cWrongPassword = "Неверный пароль"
	GroupCalendar_cAutoConfigNotFound = "Данные настроек не найдены в списке гильдии"
	GroupCalendar_cErrorAccessingNote = "Невозможна восстановить конфигурацию"

	GroupCalendar_cTrustConfigTitle = "Установки доверия"
	GroupCalendar_cTrustConfigDescription = "Определяет кому Вы разрешаете предоставлять вам планированные события.Это не ограничивает тех кто может видеть события в вашем календаре. Используйте пароль на канале, чтобы ограничить доступ к виду вашего календаря."
	GroupCalendar_cTrustGroupLabel = "Доверить:"
	GroupCalendar_cEvent = "Событие"
	GroupCalendar_cAttendance = "Состав"

	GroupCalendar_cAboutTitle = "О Организаторе"
	GroupCalendar_cTitleVersion = "Организатор v"..GroupCalendar.VersionString

	GroupCalendar.cAuthor = "Разработал и написал аддон John Stephen в содействие с %s"
	GroupCalendar_cTestersTitle = "Тестировщики 4.0"
	GroupCalendar_cSpecialThanksTitle = "Особенные благодарности"
	GroupCalendar.cTranslationCredit = "Переводы %s"
	GroupCalendar_cGuildURL = ""

	GroupCalendar_cRebuildDatabase = "Перестроить БД"
	GroupCalendar_cRebuildDatabaseDescription = "Перестроить базу данных событий для вашего героя.  Это может решить проблемы у людей, не видящих ваши события, но есть не большой риск что некоторые ответы событий могут быть утеряны."

	GroupCalendar_cTrustGroups =
	{
	"Любой, кто имеет доступ к каналу",
	"Другие игроки гильдии",
	"Только упомянутые ниже"
	}

	GroupCalendar_cTrustAnyone = "Доверять любому у кого есть доступ к каналу данных"
	GroupCalendar_cTrustGuildies = "Доверять другим игрокам гильдии"
	GroupCalendar_cTrustMinRank = "Минимум ранг для записи:"
	GroupCalendar_cTrustNobody = "Доверять только упомянутым ниже"
	GroupCalendar_cTrustedPlayers = "Дополнительные игроки"
	GroupCalendar_cExcludedPlayers = "Игнорировать события и запросы от игроков"
	GroupCalendar_cPlayerName = "Имя:"
	GroupCalendar_cRemoveExcluded = "Удалить"
	GroupCalendar_cAddExcluded = "Добавить"

	CalendarEventViewer_cTitle = "Смотреть события"
	CalendarEventViewer_cDone = "Готово"

	CalendarEventViewer_cLevelRangeFormat = "С уровня %i до %i"
	CalendarEventViewer_cMinLevelFormat = "С уровня %i и выше"
	CalendarEventViewer_cMaxLevelFormat = "До уровня %i"
	CalendarEventViewer_cAllLevels = "Все уровни"
	CalendarEventViewer_cSingleLevel = "Только %i уровня"

	CalendarEventViewer_cYes = "Да! Я буду на этом событии"
	CalendarEventViewer_cNo = "Нет! Я не буду на этом событии"
	CalendarEventViewer_cMaybe = "Возможно. Запишите в список резерва"

	CalendarEventViewer_cResponseMessage =
	{
		"Статус: Запрос не послан",
		"Статус: Ожидание подтверждения",
		"Статус: Подтверждён - взят",
		"Статус: подтверждён - в ожидании",
		"Статус: подтверждён - Не присутствует",
		"Статус: Исключён из события",
	}

	CalendarEventEditorFrame_cTitle = "Добавить/Править событие"
	CalendarEventEditor_cDone = "Готово"
	CalendarEventEditor_cDelete = "Удалить"
	CalendarEventEditor_cGroupTabTitle = "Группа"

	CalendarEventEditor_cConfirmDeleteMsg = "Удалить \"%s\"?"

-- Event names

	GroupCalendar_cGeneralEventGroup = "Общий"
	GroupCalendar_cPersonalEventGroup = "Личные (не общий)"
	GroupCalendar_cRaidEventGroup = "Рейды"
	GroupCalendar_cDungeonEventGroup = "Подземелья (Azeroth)"
	GroupCalendar_cOutlandsDungeonEventGroup = "Подземелья (Outlands)"
	GroupCalendar_cOutlandsHeroicDungeonEventGroup = "Героики (Outlands)"
	GroupCalendar_cBattlegroundEventGroup = "ПвП"
	GroupCalendar_cOutdoorRaidEventGroup = "Внешние Рейды"

	GroupCalendar_cMeetingEventName = "Собрание"
	GroupCalendar_cBirthdayEventName = "День рождения"
	GroupCalendar_cRoleplayEventName = "Ролевая игра"
	GroupCalendar_cHolidayEventName = "Развлечения"
	GroupCalendar_cDentistEventName = "Дантист"
	GroupCalendar_cDoctorEventName = "Доктор"
	GroupCalendar_cVacationEventName = "Дуэли, тренинг ПвП"
	GroupCalendar_cOtherEventName = "Другое"

	GroupCalendar_cAQREventName = "Руины Ан'Киража"
	GroupCalendar_cAQTEventName = "Храм Ан'Киража"
	GroupCalendar_cBFDEventName = "Непроглядная Пучина"
	GroupCalendar_cBRDEventName = "Глубины Черной Горы"
	GroupCalendar_cUBRSEventName = "Верхний Ярус Черной горы"
	GroupCalendar_cLBRSEventName = "Нижний Ярус Черной горы"
	GroupCalendar_cBWLEventName = "Логово Крыла Тьмы"
	GroupCalendar_cDeadminesEventName = "Мертвые копи"
	GroupCalendar_cDMEventName = "Забытый Город"
	GroupCalendar_cGnomerEventName = "Гномреган"
	GroupCalendar_cMaraEventName = "Мародон"
	GroupCalendar_cMCEventName = "Огненные Недра"
	GroupCalendar_cOnyxiaEventName = "Логово Ониксии"
	GroupCalendar_cRFCEventName = "Огненная пропасть"
	GroupCalendar_cRFDEventName = "Курганы Иглошкурых"
	GroupCalendar_cRFKEventName = "Лабиринты Иглошкурых"
	GroupCalendar_cSMEventName = "Монастырь Алого Ордена"
	GroupCalendar_cScholoEventName = "Некроситет"
	GroupCalendar_cSFKEventName = "Крепость Темного Клыка"
	GroupCalendar_cStockadesEventName = "Тюрьма"
	GroupCalendar_cStrathEventName = "Стратхольм"
	GroupCalendar_cSTEventName = "Затонувший храм"
	GroupCalendar_cUldEventName = "Ульдаман"
	GroupCalendar_cWCEventName = "Пещеры Стенаний"
	GroupCalendar_cZFEventName = "Зул'Фаррак"
	GroupCalendar_cZGEventName = "Зул'Гуруб"
	GroupCalendar_cNaxxEventName = "Наксрамас"

	GroupCalendar_cTheEyeEventName = "Око"
	GroupCalendar_cSerpentshrineEventName = "Змеиное святилище"
	GroupCalendar_cMagtheridonEventName = "Логово Магтеридона"
	GroupCalendar_cHyjalEventName = "Хиджал"
	GroupCalendar_cKarazhanEventName = "Каражан"
	GroupCalendar_cZulAmanEventName = "Зул'Аман"
	GroupCalendar_cGruulEventName = "Логово Груула"
	GroupCalendar_cBlackTempleEventName = "Черный храм"
				
	GroupCalendar_cArcatrazEventName = "Механар"
	GroupCalendar_cBotanicaEventName = "Ботаника"
	GroupCalendar_cMechanarEventName = "Аркатрац"
				
	GroupCalendar_cDurnholdeEventName = "ПВ: Крепость Дарнхольд"
	GroupCalendar_cDarkPortalEventName = "ПВ: Черные топи (Темный портал)"

	GroupCalendar_cAuchenaiCryptsEventName = "Аукенайские Гробницы"
	GroupCalendar_cSethekkHallsEventName = "Сетеккские Залы"
	GroupCalendar_cShadowLabyrinthEventName = "Темный Лабиринт"
	GroupCalendar_cManaTombsEventName = "Гробницы Маны"

	GroupCalendar_cSteamvaultEventName = "Паровое Подземелье"
	GroupCalendar_cUnderbogEventName = "Нижетопь"
	GroupCalendar_cSlavePensEventName = "Узилище"
				
	GroupCalendar_cShatteredHallsEventName = "Разрушенные залы"
	GroupCalendar_cFurnaceEventName = "Кузня Крови"
	GroupCalendar_cRampartsEventName = "Бастионы Адского Пламени"

	GroupCalendar_cArcatrazHEventName = "Аркатрац (Героик)"
	GroupCalendar_cBotanicaHEventName = "Ботаника (Героик)"
	GroupCalendar_cMechanarHEventName = "Механар (Героик)"
				
	GroupCalendar_cDurnholdeHEventName = "ПВ: Крепость Дарнхольд (Героик)"
	GroupCalendar_cDarkPortalHEventName = "ПВ: Черные топи (Героик)"

	GroupCalendar_cAuchenaiCryptsHEventName = "Аукенайские Гробницы (Героик)"
	GroupCalendar_cSethekkHallsHEventName = "Сетеккские Залы (Героик)"
	GroupCalendar_cShadowLabyrinthHEventName = "Темный Лабиринт (Героик)"
	GroupCalendar_cManaTombsHEventName = "Гробницы Маны (Героик)"

	GroupCalendar_cSteamvaultHEventName = "Паровое Подземелье (Героик)"
	GroupCalendar_cUnderbogHEventName = "Нижетопь (Героик)"
	GroupCalendar_cSlavePensHEventName = "Узилище (Героик)"
				
	GroupCalendar_cShatteredHallsHEventName = "Разрушенные залы (Героик)"
	GroupCalendar_cFurnaceHEventName = "Кузня Крови (Героик)"
	GroupCalendar_cRampartsHEventName = "Бастионы Адского Пламени (Героик)"
	
	GroupCalendar_cMagistersEventName = "Терраса Магистров"
	GroupCalendar_cMagistersHEventName = "Терраса Магистров (Героик)"
	GroupCalendar_cSunwellEventName = "Плато Солнечного Колодца"

	GroupCalendar_cPvPEventName = "Общее PvP"
	GroupCalendar_cA2v2EventName = "Арена (2v2)"
	GroupCalendar_cA3v3EventName = "Арена (3v3)"
	GroupCalendar_cA5v5EventName = "Арена (5v5)"
	GroupCalendar_cABEventName = "Низина Арати (НА)"
	GroupCalendar_cAVEventName = "Альтеракская долина (АД)"
	GroupCalendar_cWSGEventName = "Ущелье Песни Войны (УПВ)"
	GroupCalendar_cEotSEventName = "Око Бури (Глаз)"

	GroupCalendar_cDoomWalkerEventName = "Doomwalker"
	GroupCalendar_cDoomLordKazzakEventName = "Doom Lord Kazzak"

	GroupCalendar_cZGResetEventName = "Сброс Зул'Гуруба"
	GroupCalendar_cMCResetEventName = "Сброс Огненных Недр"
	GroupCalendar_cOnyxiaResetEventName = "Сброс Логово Ониксии"
	GroupCalendar_cBWLResetEventName = "Сброс Логово Крыла Тьмы"
	GroupCalendar_cAQRResetEventName = "Сброс Руин Ан'Киража"
	GroupCalendar_cAQTResetEventName = "Сброс Храма Ан'Киража"
	GroupCalendar_cNaxxResetEventName = "Сброс Наксрамаса"
	GroupCalendar_cKarazhanResetEventName = "Сброс Каражана"
	GroupCalendar_cZulAmanResetEventName = "Сброс Зул'Амана"
	GroupCalendar_cBlackTempleResetEventName = "Сброс Черного Храма"
	GroupCalendar_cTheEyeResetEventName = "Сброс Ока"
	GroupCalendar_cSerpentshrineResetEventName = "Сброс Змеиного Святилищя"
	GroupCalendar_cMagtheridonResetEventName = "Сброс Логово Магтеридона"
	GroupCalendar_cHyjalResetEventName = "Сброс Хиджала"
	GroupCalendar_cGruulResetEventName = "Сброс Логово Груула"
	GroupCalendar_cSunwellResetEventName = "Сброс Плато Солнечного Колодца"

	GroupCalendar_cTransmuteCooldownEventName = "Трансмутация - Доступна"
	GroupCalendar_cSaltShakerCooldownEventName = "Солонка - Доступна"
	GroupCalendar_cMoonclothCooldownEventName = "Лунная ткань - Доступна"
	GroupCalendar_cPrimalMoonclothCooldownEventName = "Изначальная лунная ткань - Доступна"
	GroupCalendar_cSpellclothCooldownEventName = "Чароткань - Доступна"
	GroupCalendar_cShadowclothCooldownEventName = " Ткань Тьмы - Доступна"
	GroupCalendar_cSnowmasterCooldownEventName = "SnowMaster 9000 - Доступен"
	GroupCalendar_cBrilliantGlassCooldownEventName = " Сверкающий сосуд - Доступен"
	GroupCalendar_cVoidShatterCooldownEventName = "Дробление пустоты - Доступно"
	GroupCalendar_cVoidSphereCooldownEventName = " Пустая сфера - Доступна"

	GroupCalendar_cPersonalEventOwner = "Личный"

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

	GroupCalendar_cDwarfRaceName = "Dwarf"
	GroupCalendar_cGnomeRaceName = "Gnome"
	GroupCalendar_cHumanRaceName = "Human"
	GroupCalendar_cNightElfRaceName = "Night Elf"
	GroupCalendar_cOrcRaceName = "Orc"
	GroupCalendar_cTaurenRaceName = "Tauren"
	GroupCalendar_cTrollRaceName = "Troll"
	GroupCalendar_cUndeadRaceName = "Undead"
	GroupCalendar_cBloodElfRaceName = "Blood Elf"
	GroupCalendar_cDraeneiRaceName = "Draenei"

	-- Class names

	GroupCalendar_cFemaleDruidClassName = "Druid"
	GroupCalendar_cMaleDruidClassName = "Druid"
	GroupCalendar_cFemaleHunterClassName = "Hunter"
	GroupCalendar_cMaleHunterClassName = "Hunter"
	GroupCalendar_cFemaleMageClassName = "Mage"
	GroupCalendar_cMaleMageClassName = "Mage"
	GroupCalendar_cFemalePaladinClassName = "Paladin"
	GroupCalendar_cMalePaladinClassName = "Paladin"
	GroupCalendar_cFemalePriestClassName = "Priest"
	GroupCalendar_cMalePriestClassName = "Priest"
	GroupCalendar_cFemaleRogueClassName = "Rogue"
	GroupCalendar_cMaleRogueClassName = "Rogue"
	GroupCalendar_cFemaleShamanClassName = "Shaman"
	GroupCalendar_cMaleShamanClassName = "Shaman"
	GroupCalendar_cFemaleWarlockClassName = "Warlock"
	GroupCalendar_cMaleWarlockClassName = "Warlock"
	GroupCalendar_cFemaleWarriorClassName = "Warrior"
	GroupCalendar_cMaleWarriorClassName = "Warrior"

	-- Plural forms of class names

	GroupCalendar_cDruidsClassName = "Druids"
	GroupCalendar_cHuntersClassName = "Hunters"
	GroupCalendar_cMagesClassName = "Mages"
	GroupCalendar_cPaladinsClassName = "Paladins"
	GroupCalendar_cPriestsClassName = "Priests"
	GroupCalendar_cRoguesClassName = "Rogues"
	GroupCalendar_cShamansClassName = "Shamans"
	GroupCalendar_cWarlocksClassName = "Warlocks"
	GroupCalendar_cWarriorsClassName = "Warriors"

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

	GroupCalendar_cTimeLabel = "Время:"
	GroupCalendar_cDurationLabel = "Длина:"
	GroupCalendar_cEventLabel = "Событие:"
	GroupCalendar_cTitleLabel = "Название:"
	GroupCalendar_cLevelsLabel = "Уровни:"
	GroupCalendar_cLevelRangeSeparator = "до"
	GroupCalendar_cDescriptionLabel = "Описание:"
	GroupCalendar_cCommentLabel = "Заметка:"

	CalendarEditor_cNewEvent = "Новое Событие..."
	CalendarEditor_cEventsTitle = "События"

	CalendarEventEditor_cNotAttending = "Не присутствует"
	CalendarEventEditor_cConfirmed = "Подтверждён"
	CalendarEventEditor_cDeclined = "Отклонён"
	CalendarEventEditor_cStandby = "С списке резерва"
	CalendarEventEditor_cPending = "В ожидании"
	CalendarEventEditor_cBanned = "Заблокирован"
	CalendarEventEditor_cUnknownStatus = "Неизвестно %s"

	GroupCalendar_cChannelNameLabel = "Канал:"
	GroupCalendar_cPasswordLabel = "Пароль:"

	GroupCalendar_cSingleTimeDateFormat = "%s %s"
	GroupCalendar_cTimeDateRangeFormat = "%s с %s до %s"

	GroupCalendar_cPluralMinutesFormat = "%d минут"
	GroupCalendar_cSingularHourFormat = "%d час"
	GroupCalendar_cPluralHourFormat = "%d часа"
	GroupCalendar_cSingularHourPluralMinutes = "%d час %d минут"
	GroupCalendar_cPluralHourPluralMinutes = "%d часа %d минут"

	if string.sub(GetLocale(), -2) == "RU" then
		GroupCalendar_cLongDateFormat = "$month $day, $year"
		GroupCalendar_cShortDateFormat = "$monthNum/$day"
		GroupCalendar_cLongDateFormatWithDayOfWeek = "$dow $month $day, $year"
	else
		GroupCalendar_cLongDateFormat = "$day. $month $year"
		GroupCalendar_cShortDateFormat = "$day.$monthNum"
		GroupCalendar_cLongDateFormatWithDayOfWeek = "$dow $day. $month $year"
	end

	GroupCalendar_cNotAttendingCategory = "Не присутствует"
	GroupCalendar_cAttendingCategory = "Присутствует"
	GroupCalendar_cPendingApprovalCategory = "Ожидается запрос и изменения"
	GroupCalendar_cStandbyCategory = "Резерв"
	GroupCalendar_cQueuedCategory = "Обрабатывается"
	GroupCalendar_cWhispersCategory = "Последние ЛС"
	GroupCalendar_cBannedCategory = "Заблокированные"

	GroupCalendar_cQuestAttendanceNameFormat = "$name ($level $race)"
	GroupCalendar_cMeetingAttendanceNameFormat = "$name ($level $class)"
	GroupCalendar_cGroupAttendanceNameFormat = "$name ($status)"

	GroupCalendar_cNumPlayersPlusStandbyFormat = "%d (+%d)"
	GroupCalendar_cNumPlayersFormat = "%d"

	GroupCalendar_cTotalNumPlayersFormat = "%s игроков"

	BINDING_HEADER_GROUPCALENDAR_TITLE = "Организатор"
	BINDING_NAME_GROUPCALENDAR_TOGGLE = "Переключатель"

	-- Tradeskill cooldown items

	GroupCalendar_cHerbalismSkillName = "Herbalism"
	GroupCalendar_cAlchemySkillName = "Alchemy"
	GroupCalendar_cEnchantingSkillName = "Enchanting"
	GroupCalendar_cLeatherworkingSkillName = "Leatherworking"
	GroupCalendar_cSkinningSkillName = "Skinning"
	GroupCalendar_cTailoringSkillName = "Tailoring"
	GroupCalendar_cMiningSkillName = "Mining"
	GroupCalendar_cBlacksmithingSkillName = "Blacksmithing"
	GroupCalendar_cEngineeringSkillName = "Engineering"
	GroupCalendar_cJewelcraftSkillName = "Jewelcrafting"

	GroupCalendar_cTransmuteMithrilToTruesilver = "Transmute: Mithril to Truesilver"
	GroupCalendar_cTransmuteIronToGold = "Transmute: Iron to Gold"
	GroupCalendar_cTransmuteLifeToEarth = "Transmute: Life to Earth"
	GroupCalendar_cTransmuteWaterToUndeath = "Transmute: Water to Undeath"
	GroupCalendar_cTransmuteWaterToAir = "Transmute: Water to Air"
	GroupCalendar_cTransmuteUndeathToWater = "Transmute: Undeath to Water"
	GroupCalendar_cTransmuteFireToEarth = "Transmute: Fire to Earth"
	GroupCalendar_cTransmuteEarthToLife = "Transmute: Earth to Life"
	GroupCalendar_cTransmuteEarthToWater = "Transmute: Earth to Water"
	GroupCalendar_cTransmuteAirToFire = "Transmute: Air to Fire"
	GroupCalendar_cTransmuteArcanite = "Transmute: Arcanite"
	GroupCalendar_cTransmutePrimalAirToFire = "Transmute: Primal Air to Fire"
	GroupCalendar_cTransmutePrimalFireToEarth = "Transmute: Primal Fire to Earth"
	GroupCalendar_cTransmutePrimalEarthToWater = "Transmute: Primal Earth to Water"
	GroupCalendar_cTransmutePrimalWaterToAir = "Transmute: Primal Water to Air"
	GroupCalendar_cTransmutePrimalEarthToLife = "Transmute: Primal Earth to Life"
	GroupCalendar_cTransmutePrimalLifeToEarth= "Transmute: Primal Life To Earth"
	GroupCalendar_cTransmutePrimalFireToMana = "Transmute: Primal Fire to Mana"
	GroupCalendar_cTransmutePrimalManaToFire = "Transmute: Primal Mana to Fire"
	GroupCalendar_cTransmutePrimalShadowToWater = "Transmute: Primal Shadow to Water"
	GroupCalendar_cTransmutePrimalWaterToShadow = "Transmute: Primal Water to Shadow"
	GroupCalendar_cTransmutePrimalMight = "Transmute: Primal Might"
	GroupCalendar_cTransmuteEarthstormDiamond = "Transmute: Earthstorm Diamond"
	GroupCalendar_cTransmuteSkyfireDiamond = "Transmute: Skyfire Diamond"

	GroupCalendar_cMooncloth = "Mooncloth"
	GroupCalendar_cPrimalMooncloth = "Primal Mooncloth"
	GroupCalendar_cSpellcloth = "Spellcloth"
	GroupCalendar_cShadowcloth = "Shadowcloth"

	GroupCalendar_cBrilliantGlass = "Brilliant Glass"
	GroupCalendar_cVoidShatter = "Void Shatter"
	GroupCalendar_cVoidSphere = "Void Sphere"

	GroupCalendar_cCharactersLabel = "Характер:"

	GroupCalendar_cConfirmed = "Принят"
	GroupCalendar_cStandby = "В ожидании"
	GroupCalendar_cDeclined = "Отклонён"
	GroupCalendar_cBanned = "Заблокирован"
	GroupCalendar_cRemove = "Удалить"
	GroupCalendar_cEditPlayer = "Править Игрока..."
	GroupCalendar_cInviteNow = "Пригласить в группу"
	GroupCalendar_cStatus = "Статус"
	GroupCalendar_cAddPlayerEllipses = "Добавить игрока..."

	GroupCalendar_cAddPlayer = "Добавить игрока"
	GroupCalendar_cPlayerLevel = "Уровень:"
	GroupCalendar_cPlayerClassLabel = "Класс:"
	GroupCalendar_cPlayerRaceLabel = "Раса:"
	GroupCalendar_cPlayerStatusLabel = "Статус:"
	GroupCalendar_cRankLabel = "Звание:"
	GroupCalendar_cGuildLabel = "Гильдия:"
	GroupCalendar_cRoleLabel = "Роль:"
	GroupCalendar_cSave = "Сохранить"
	GroupCalendar_cLastWhisper = "Последнее ЛС:"
	GroupCalendar_cReplyWhisper = "Ответ на ЛС:"

	GroupCalendar_cUnknown = "Неизвестно"
	GroupCalendar_cAutoConfirmationTitle = "Авто подтвердить по классу"
	GroupCalendar_cRoleConfirmationTitle = "Авто подтвердить по роли"
	GroupCalendar_cManualConfirmationTitle = "Ручное подтверждение"
	GroupCalendar_cClosedEventTitle = "Закрытое событие"
	GroupCalendar_cMinLabel = "мин"
	GroupCalendar_cMaxLabel = "макс"

	GroupCalendar_cAddPlayerTitle = "Добавить..."
	GroupCalendar_cAutoConfirmButtonTitle = "Настройки..."

	GroupCalendar_cClassLimitDescription = "В области ниже, установите минимальное и максимальное количество каждого класса. Игроки не попавшие в лимит автоматически попадают в резерв. Дополнительные места будут заполнены в порядке ответа до достижения максимума."
	GroupCalendar_cRoleLimitDescription = "В области ниже, установите минимальное и максимальное количество каждой роли.  Игроки не попавшие в лимит автоматически попадают в резерв. Дополнительные места будут заполнены в порядке ответа до достижения максимума..  Вы можете по выбору установить число минимума классов по роли (запрашивая одного удалённого дамагера шадов приста для примера)"

	GroupCalendar_cViewGroupBy = "Группы по"
	GroupCalendar_cViewByStatus = "Статусу"
	GroupCalendar_cViewByClass = "Классу"
	GroupCalendar_cViewByRole = "Роли"
	GroupCalendar_cViewSortBy = "Сортировать"
	GroupCalendar_cViewByDate = "По дате"
	GroupCalendar_cViewByRank = "По рангу"
	GroupCalendar_cViewByName = "По Имени"

	GroupCalendar_cMaxPartySizeLabel = "Макс размер группы:"
	GroupCalendar_cMinPartySizeLabel = "Мин размер группы:"
	GroupCalendar_cNoMinimum = "Нет минимума"
	GroupCalendar_cNoMaximum = "Не ограничено"
	GroupCalendar_cPartySizeFormat = "%d игроков"

	GroupCalendar_cInviteButtonTitle = "Пригласить"
	GroupCalendar_cAutoSelectButtonTitle = "Выбрать игроков..."
	GroupCalendar_cAutoSelectWindowTitle = "Выбрать игроков"

	GroupCalendar_cNoSelection = "Нет выбранных игроков"
	GroupCalendar_cSingleSelection = "1 игрок выбран"
	GroupCalendar_cMultiSelection = "%d игрока выбраны"

	GroupCalendar_cInviteNeedSelectionStatus = "Выбрать для приглашения"
	GroupCalendar_cInviteReadyStatus = "Готовы для приглашения"
	GroupCalendar_cInviteInitialInvitesStatus = "Отправить приглашение"
	GroupCalendar_cInviteAwaitingAcceptanceStatus = "Ожидание приёма"
	GroupCalendar_cInviteConvertingToRaidStatus = "Конвертировать в рейд"
	GroupCalendar_cInviteInvitingStatus = "Рассылка приглашений"
	GroupCalendar_cInviteCompleteStatus = "Приглашение закончено"
	GroupCalendar_cInviteReadyToRefillStatus = "Заполнения свободных мест готово"
	GroupCalendar_cInviteNoMoreAvailableStatus = "Нет больше игроков чтобы вступить в группу"
	GroupCalendar_cRaidFull = "Рейд полон"

	GroupCalendar_cInviteWhisperFormat = "[Организатор] Привет!!! Вас приглашают участвовать в событии '%s'.  Обязательно примите участие в этом событии если у вас есть время."
	GroupCalendar_cAlreadyGroupedWhisper = "[Организатор] Вы уже в группе :(.  Пожалуйста /w отпишитесь когда вы покинете группу."

	GroupCalendar_cJoinedGroupStatus = "Присоединён"
	GropuCalendar_cInvitedGroupStatus = "Приглашён"
	GropuCalendar_cReadyGroupStatus = "Готов"
	GroupCalendar_cGroupedGroupStatus = "В другой группе"
	GroupCalendar_cStandbyGroupStatus = "Резерв"
	GroupCalendar_cDeclinedGroupStatus = "Отклонил приглашение"
	GroupCalendar_cOfflineGroupStatus = "Не в сети"
	GroupCalendar_cLeftGroupStatus = "Покинул группу"

	GroupCalendar_cPriorityLabel = "Приоритет:"
	GroupCalendar_cPriorityDate = "Дата"
	GroupCalendar_cPriorityRank = "Ранг"

	GroupCalendar_cConfirmSelfUpdateMsg = "%s"
	GroupCalendar_cConfirmSelfUpdateParamFormat = "Были сделаны изменения в событиях $mUserName'ом с другого компьютера.  Если вы используете многопользовательский компьютер, или вы пере-установили игру, выберите Принять чтобы восстановить ваши события.  Выберите Удалить если вы не верите что изменения не могли быть сделаны с другого компьютера."
	GroupCalendar_cConfirmSelfRSVPUpdateParamFormat = "Были сделаны изменения в составах $mUserName'ом с другого компьютера.  Если вы используете многопользовательский компьютер, или вы пере-установили игру, выберите Принять чтобы восстановить ваших запросов.  Выберите Удалить если вы не верите что изменения не могли быть сделаны с другого компьютера."
	GroupCalendar_cUpdate = "Обновить"

	GroupCalendar_cConfirmClearWhispers = "Очистить последние сообщения?"
	GroupCalendar_cClear = "Очистить"

	CalendarDatabases_cTitle = "Версии Организатора"
	CalendarDatabases_cRefresh = "Обновить"
	CalendarDatabases_cRefreshDescription = "Требует что бы игрок был в сети. Просматривает у кого установлен календарь и узнает какая у них версия,это займёт некоторое время. Обновляться может при закрытом окне, результат можно посмотреть позже."

	GroupCalendar_cVersionFormat = "Организатор v%s"
	GroupCalendar_cShortVersionFormat = "v%s"
	GroupCalendar_cVersionUpdatedFormat = "%s %s (локальное время)"
	GroupCalendar_cVersionUpdatedUnknown = "Информация о последней версии неизвестна"

	GroupCalendar_cToggleVersionsTitle = "Показать версию игроков"
	GroupCalendar_cToggleVersionsDescription = "Показать какая версия Организатора запущена у других игроков"

	GroupCalendar_cChangesDelayedMessage = "Организатор: Изменения в расписании синхронизируются с другими игроками."

	GroupCalendar_cConfirmKillMsg = "Вы уверены, что Вы хотите вмешаться в событие %s из сети?" 
	GroupCalendar_cKill = "Убить"

	GroupCalendar_cNotAnOfficerError = "Только офицерам гильдии дозволенно сделать это"
	GroupCalendar_cUserNameExpected = "Ожидаемое имя пользователя"
	GroupCalendar_cDatabaseNotFoundError = "База данных для %s не найдена."
	GroupCalendar_cCantKillGuildieError = "Нельзя удалить пользователя из вашей гильдии"

	GroupCalendar_cTooltipScheduleItemFormat = "%s (%s)"

	GroupCalendar_cAvailableMinutesFormat = "%s через %d минуты"
	GroupCalendar_cAvailableMinuteFormat = "%s через %d минут"
	GroupCalendar_cStartsMinutesFormat = "%s старт через %d минут"
	GroupCalendar_cStartsMinuteFormat = "%s старт через %d минуты"
	GroupCalendar_cStartingNowFormat = "%s уже начинается"
	GroupCalendar_cAlreadyStartedFormat = "%s уже начался"
	GroupCalendar_cHappyBirthdayFormat = "С днем рождения %s!"

	GroupCalendar_cTimeRemainingFormat = "(%d:%02d осталось)"
	GroupCalendar_cUnknownEventType = "%s (Новый тип записи, обновите Организатор)"

	GroupCalendar_cConfirmResetMsg = "Вы уверены, что Вы хотите сбросить календари для всех ваших характеров на %s? Все события будут удалены для всех ваших характеров."
	GroupCalendar_cConfirmResetRealmMsg = "Вы уверены, что Вы хотите сбросить календари для всех ваших характеров на %s? Все события будут удалены для всех ваших характеров на этом сервере."
	GroupCalendar_cConfirmResetAllMsg = "Вы уверены, что Вы хотите сбросит календари для всех ваших характеров на всех реалмах? Все события будут удалены для всех ваших характеров на всех серверах."
	GroupCalendar_cReset = "Сброс"

	GroupCalendar_cNone = "Нету"

	GroupCalendar_cAttendanceNote = "Вы обновили информацию в %s.  Пожалуйста подождите 5 минут, не выходите из игры, для того чтобы обработать ваш запрос,синхронизировать с другими игроками."
	GroupCalendar_cUnknownClockOption = "Время неизвестно"
	GroupCalendar_cBadAgeValue = "Максимальный срок давности событий от 1 до 60 дней"
	GroupCalendar_cViewMenuFormat = "Показ по %s/%s"
	GroupCalendar_cDefaultTimeFormat = 24
	GroupCalendar_cDefaultStartDay = "Mon"
	GroupCalendar_cForeignRealmFormat = "%s из %s"

	GroupCalendar_cMHRole = "Хил"
	GroupCalendar_cOHRole = "Оф-Хил"
	GroupCalendar_cMTRole = "Танк"
	GroupCalendar_cOTRole = "Оф-Танк"
	GroupCalendar_cRDRole = "Рендж"
	GroupCalendar_cMDRole = "Мили"

	GroupCalendar_cMHPluralRole = "Хил"
	GroupCalendar_cOHPluralRole = "Оф-Хил"
	GroupCalendar_cMTPluralRole = "Танк"
	GroupCalendar_cOTPluralRole = "Оф-Танк"
	GroupCalendar_cRDPluralRole = "Рендж"
	GroupCalendar_cMDPluralRole = "Мили"

	GroupCalendar_cMHPluralLabel = GroupCalendar_cMHPluralRole..":"
	GroupCalendar_cOHPluralLabel = GroupCalendar_cOHPluralRole..":"
	GroupCalendar_cMTPluralLabel = GroupCalendar_cMTPluralRole..":"
	GroupCalendar_cOTPluralLabel = GroupCalendar_cOTPluralRole..":"
	GroupCalendar_cRDPluralLabel = GroupCalendar_cRDPluralRole..":"
	GroupCalendar_cMDPluralLabel = GroupCalendar_cMDPluralRole..":"

	GroupCalendar_cClockNotSetWarning = "ПРЕДУПРЕЖДЕНИЕ: Три или больше копий Организатора в вашей сети указывают на то что на их часах установлено значительно другое время и дата нежели у вас.  Проверьте настройки даты/времени, это может вызвать некоторые проблемы при назначение или записи в события, особенно если мы подключаетесь из многопользовательских компьютеров."

	GroupCalendar.cWhisperSummaryDateHeader    = "%s"
	GroupCalendar.cWhisperSummaryEvent         = "    $time $event [ID $id]"
	GroupCalendar.cWhisperSummaryEventStatus   = "    $time $event [ID $id] ($status)"
	GroupCalendar.cWhisperSummaryNoEvents      = "Нет предстоящих событий"
	GroupCalendar.cWhisperSummaryInvalidOption = "%s не действительная команда.  Используйте '!gc help' для получения списка доступных команд"

	GroupCalendar.cWhisperHelp =
	{
		"!gc - Тоже что и !gc summary",
		"!gc summary - Список событий следующие 7 дней",
		"!gc yes eventid - Записаться в событие что будите присутствовать",
		"!gc no eventid - Записаться в событие что не будите присутствовать",
		"!gc standby eventid - Записаться в событие в резерв",
		"!gc help - Показать список команд",
		"ID событий показывает сводку событий.  Если событие создано одним и тем-же игроком с которым вы переписываетесь то вы можете использовать номер, в противном случае используйте название-номер определённого события"
	}

	GroupCalendar.cDatabasesTotalFormat = "%d баз данных"

	GroupCalendar_cConfrimDeleteRSVP = "Вы уверены что вы хотите удалить %s из списка?"

	GroupCalendar.cCantReloadUI = GroupCalendar_cTitleVersion.." содержатся новые файлы и World of Warcraft отказываться загружать их пока вы находитесь в игре. Организатор будет отключён пока вы не перезапустите WoW."

	GroupCalendar.cWhisperAccessDenied = "доступ к событию для %s отклонён"
	GroupCalendar.cWhisperCantProxy = "Вы должны написать %s или одному из них чинов для участия в этом событии"
	GroupCalendar.cWhisperDatabaseNotFound = "БД для %s не найдена"
	GroupCalendar.cWhisperEventNotFound = "ID события %d не найдено в БД для %s"
	GroupCalendar.cWhisperFailed = "Неудачный запрос по неизвестной причине.  Пускай организатор добавит вас в ручную."
	GroupCalendar.cWhisperNotGuildmate = "Записывание в событию игроков вне гильдии теперь не поддерживается"
	GroupCalendar.cWhisperEventStatus = "Ваш статус для %s на %s at %s теперь %s"
	GroupCalendar.cWhisperAllDayStatus = "Ваш статус для %s на %s теперь %s"
	GroupCalendar.cWhisperWTFError = "невозможно декодировать ID события '%s'"
	GroupCalendar.cWhisperHelpReminder = "Напишите '!gc help' для большего списка команд"

	GroupCalendar.cAttendanceNoticeYes = "$name будет присутствовать $event"
	GroupCalendar.cAttendanceNoticeLimitStandby = "Поместить $name в резерв для $event: Лимит Класса или Роли уже достигнут"
	GroupCalendar.cAttendanceNoticeStandby = "$name доступен в резерве для $event"
	GroupCalendar.cAttendanceNoticeNo = "$name не будет присутствовать на $event"
	GroupCalendar.cAttendanceNoticeBanned = "Отказ запроса $name для $event: Игрок забанен для этого события"
	GroupCalendar.cAttendanceNoticeManual = "Поместить $name в резерв для $event: Требуется ваше подтверждение для участия в событии"
	GroupCalendar.cAttendanceUnknownQualifiedError = "Вы не пригодный для этого события, но программы не сообщает о причине"

	GroupCalendar.cAttendanceClosedEvent = "Закрытое событие -- все участники должны быть добавлены в ручную создателем события"
	GroupCalendar.cAttendanceUnknownLevel = "Это событие ограничено по уровню и ваш уровень неизвестен"
	GroupCalendar.cAttendanceLevelTooLow = "Ваш уровень за низкий для этого события"
	GroupCalendar.cAttendanceLevelTooHigh = "Ваш уровень за высокий для этого события"
	GroupCalendar.cAttendanceGuildMembersOnly = "Это событие только для членов <%s> "
	GroupCalendar.cAttendanceRankTooLow = "Ваше звание за низкое для участия в этом событии"
	GroupCalendar.cAttendanceNotAllowed = "У вас нет доступа к просмотру этого календаря"
	GroupCalendar.cAttendanceSynching = "Организатор синхронизируется с сетью.  Попробуйте ещё раз через несколько минут."

	GroupCalendar.cNewerVersionMessage = "Доступна новая версия (%s)"

	GroupCalendar.cBackupTitle = "Резервная копия и восстановление"
	GroupCalendar.cNoBackups = "Нет резервных копий.  Резервное копирование будет сделано автоматически если вы с другого компьютера измените данные в календаре, или вы можете использовать кнопку 'Создать Ре-копию'."
	GroupCalendar.cBackupNow = "Создать Ре-копию"
	GroupCalendar.cBackupNowDescription = "Сохранить копию событий и запросы состава для %s."
	GroupCalendar.cConfirmDeleteBackup = "Вы уверены что хотите удалить резервную копию %s?"
	GroupCalendar.cConfirmRestoreBackup = "Вы уверены что хотите восстановить резервную копию %s?"
	GroupCalendar.cRestoreBackup = "Восстановление"
	GroupCalendar.cBackupRestored = "Резервная копия восстановлена. Восстановленные события появятся у других игроков в течении нескольких минут."
	
	GroupCalendar.cNetworkSyncComplete = "Синхронизация с сетью завершена"
end
