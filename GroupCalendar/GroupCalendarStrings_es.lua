if GetLocale() == "esES" then
	GroupCalendar_cTitle = "Group Calendar v%s"

	GroupCalendar.cSingleItemFormat = "%s"
	GroupCalendar.cTwoItemFormat = "%s y %s"
	GroupCalendar.cMultiItemFormat = "%s{{, %s}} y %s"

	GroupCalendar_cSun = "Dom"
	GroupCalendar_cMon = "Lun"
	GroupCalendar_cTue = "Mar"
	GroupCalendar_cWed = "Mie"
	GroupCalendar_cThu = "Jue"
	GroupCalendar_cFri = "Vie"
	GroupCalendar_cSat = "Sab"

	GroupCalendar_cSunday = "Domingo"
	GroupCalendar_cMonday = "Lunes"
	GroupCalendar_cTuesday = "Martes"
	GroupCalendar_cWednesday = "Miercoles"
	GroupCalendar_cThursday = "Jueves"
	GroupCalendar_cFriday = "Viernes"
	GroupCalendar_cSaturday = "Sabado"

	GroupCalendar_cSelfWillAttend = "%s asistirá"
	GroupCalendar_cGuildOnly = "Solo miembros %s"

	GroupCalendar_cMonthNames = {"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"}
	GroupCalendar_cDayOfWeekNames = {GroupCalendar_cSunday, GroupCalendar_cMonday, GroupCalendar_cTuesday, GroupCalendar_cWednesday, GroupCalendar_cThursday, GroupCalendar_cFriday, GroupCalendar_cSaturday}

	GroupCalendar_cLoadMessage = "Group Calendar cargado.  Usa '/cal show' para ver el calendario"
	GroupCalendar_cInitializingGuilded = "Group Calendar: Inicializando configuración para jugador con hermandad"
	GroupCalendar_cInitializingUnguilded = "Group Calendar: Inicializando configuración para jugador sin hermandad"
	GroupCalendar_cLocalTimeNote = "(%s local)"

	GroupCalendar_cOptions = "Configuración..."

	GroupCalendar_cCalendar = "Calendario"
	GroupCalendar_cSetup = "Configuración"
	GroupCalendar_cBackup = "Backup"
	GroupCalendar_cAbout = "Acerca de"

	GroupCalendar_cUseServerDateTime = "Usar fecha y hora del servidor"
	GroupCalendar_cUseServerDateTimeDescription = "Activa para mostrar los eventos usando la fecha y hora del servidor, desactiva para usar tu fecha y hora local"

	GroupCalendar_cSetupTitle = "Configuración Calendario"
	GroupCalendar_cConfigModeLabel = "Configuración:"
	GroupCalendar_cAutoChannelConfig = "Automático"
	GroupCalendar_cManualChannelConfig = "Manual"
	GroupCalendar_cAdminChannelConfig = "Adminsitrador"

	GroupCalendar_cUseGuildChannel = "Usar canal datos de Hermandad"
	GroupCalendar_cUseGuildChannelDescription = "Usa el canal integrado de datos para tu hermandad.  Este canal no es accesible por nadie fuera de tu hermandad."

	GroupCalendar_cUseSharedChannel = "Usar canal datos compartido"
	GroupCalendar_cUseSharedChannelDescription = "Usa un canal de datos público para los datos del calendario.  Este canal es accesible para cualquiera de tu misma facción en tu servidor pero puedes usar una contraseña para restringir el acceso."

	GroupCalendar_cApplyChannelChanges = "Aplicar Cambios"
	GroupCalendar_cManualConfigTipDescription = "Te permite introducir manualmente la información del canal y contraseña."
	GroupCalendar_cStoreAutoConfigTipDescription = "Permite a un oficial de la hermandad almacenar la configuración del canal en la nota de los jugadores elegidos de la lista de la hermandad."
	GroupCalendar_cAutoConfigPlayerTipDescription = "El nombre del jugador de la lista de la hermandad que contiene los datos de la configuración del canal."
	GroupCalendar_cChannelNameTipTitle = "Nombre Canal"
	GroupCalendar_cChannelNameTipDescription = "El nombre del canal de chat usado para enviar y recibir los datos de eventos de otros jugadores"
	GroupCalendar_cConnectChannel = "Conectar"
	GroupCalendar_cDisconnectChannel = "Desconectar"
	GroupCalendar_cChannelStatus =
	{
		Starting = {mText = "Estado: Iniciando...", mColor = {r = 1, g = 1, b = 0.3}},
		Synching = {mText = "Estado: Sincronizando con la red", mColor = {r = 0.3, g = 1, b = 0.3}},
		Suspended = {mText = "Estado: Suspendido (desconectado)", mColor = {r = 1, g = 1, b = 0.3}},
		Connected = {mText = "Estado: Canal de datos conectado", mColor = {r = 0.3, g = 1, b = 0.3}},
		Disconnected = {mText = "Estado: Canal de datos desconectado", mColor = {r = 1, g = 0.5, b = 0.2}},
		Initializing = {mText = "Estado: Inicializando canal de datos", mColor = {r = 1, g = 1, b = 0.3}},
		Error = {mText = "Error: %s", mColor = {r = 1, g = 0.2, b = 0.4}},
	}

	GroupCalendar_cConnected = "Conectado"
	GroupCalendar_cDisconnected = "Desconectado"
	GroupCalendar_cTooManyChannels = "Ya te has unido al número máximo de canales"
	GroupCalendar_cJoinChannelFailed = "Fallo al unirte al canal por causas desconocidas"
	GroupCalendar_cWrongPassword = "Contraseña incorrecta"
	GroupCalendar_cAutoConfigNotFound = "Datos de configuración no encontrados en la lista de la hermandad"
	GroupCalendar_cErrorAccessingNote = "No se puede recuperar los datos de configuración"

	GroupCalendar_cTrustConfigTitle = "Configuración autorización"
	GroupCalendar_cTrustConfigDescription = "Autorización determina a quien permites que te mande eventos.  Esto NO limita quien puede ver eventos en tu calendario.  Usa una contraseña en el canal de datos para restringir quién puede ver tu calendario."
	GroupCalendar_cTrustGroupLabel = "Autorizado:"
	GroupCalendar_cEvent = "Evento"
	GroupCalendar_cEdit = "Edit"
	GroupCalendar_cAttendance = "Asistencia"

	GroupCalendar_cAboutTitle = "Acerca de Group Calendar"
	GroupCalendar_cTitleVersion = "Group Calendar v"..GroupCalendar.VersionString
	
	GroupCalendar_cAuthor = "Diseñado y escrito por John Stephen con contribuciones de %s"
	GroupCalendar_cTestersTitle = "Testeadores de v4.0"
	GroupCalendar_cSpecialThanksTitle = "Gracias especiales por su extraordinario soporte a"
	GroupCalendar_cTranslationCredit = "Traducido por %s"
	GroupCalendar_cGuildURL = "wobbleworks.com"
	
	GroupCalendar_cRebuildDatabase = "Reconstruir base de datos"
	GroupCalendar_cRebuildDatabaseDescription = "Reconstruye la base de datos de eventos de tu personaje.  Esto debe resolver los problemas con gente que no ve todos sus eventos, pero hay un pequeño riesgo de que que algunas respuestas a los asistentes del evento se pierdan."

	GroupCalendar_cTrustGroups =
	{
		"Cualquiera que acceda al canal de datos",
		"Otros miembros de tu hermandad",
		"Solo aquellos explicitamente listados más abajo"
	}

	GroupCalendar_cTrustAnyone = "Autoriza a cualquiera que tenga acceso al canal de datos"
	GroupCalendar_cTrustGuildies = "Autoriza a otros miembros de tu hermandad"
	GroupCalendar_cTrustMinRank = "Rango mínimo para mostrar:";
	GroupCalendar_cTrustNobody = "Autoriza solo a los que esten en la siguiente lista"
	GroupCalendar_cTrustedPlayers = "Jugadores adicionales"
	GroupCalendar_cExcludedPlayers = "Ignorar eventos y peticiones de jugadores"
	GroupCalendar_cPlayerName = "Nombre:"
	GroupCalendar_cRemoveExcluded = "Eliminar"
	GroupCalendar_cAddExcluded = "Agregar"

	CalendarEventViewer_cTitle = "Ver Evento"
	CalendarEventViewer_cDone = "Aceptar"

	CalendarEventViewer_cLevelRangeFormat = "Niveles %i a %i"
	CalendarEventViewer_cMinLevelFormat = "Niveles %i y más"
	CalendarEventViewer_cMaxLevelFormat = "Hasta el nivel %i" --Q Revisar "Up to level" Posible mala traduccion
	CalendarEventViewer_cAllLevels = "Todos los niveles"
	CalendarEventViewer_cSingleLevel = "Solo nivel %i"

	CalendarEventViewer_cYes = "¡Si! Asistiré a este evento"
	CalendarEventViewer_cNo = "No asistiré a este evento"
	CalendarEventViewer_cMaybe = "Quizás. Ponme en la lista de espera"

	CalendarEventViewer_cResponseMessage =
	{
		"Estado: Respuesta no enviada",
		"Estado: Esperando confirmación",
		"Estado: Confirmado - Aceptado",
		"Estado: Confirmado - En reserva",
		"Estado: Confirmado - No asiste",
		"Estado: Expulsado del evento",
		"Estado: Confirmado - Quizás",
	}

	CalendarEventEditorFrame_cTitle = "Agregar/Editar Evento"
	CalendarEvent_cDone = "Aceptar"
	CalendarEvent_cDelete = "Eliminar"
	CalendarEvent_cGroupTabTitle = "Grupo"

	CalendarEvent_cConfirmDeleteMsg = "¿Eliminar \"%s\"?"

	-- Event names

	GroupCalendar_cGeneralEventGroup = "General"
	GroupCalendar_cPersonalEventGroup = "Personal (no se comparte)"
	GroupCalendar_cRaidEventGroup = "Bandas"
	GroupCalendar_cDungeonEventGroup = "Mazmorras (Azeroth)"
	GroupCalendar_cOutlandsDungeonEventGroup = "Mazmorras (Terrallende)"
	GroupCalendar_cOutlandsHeroicDungeonEventGroup = "Heroicas"
	GroupCalendar_cBattlegroundEventGroup = "JcJ"
	GroupCalendar_cOutdoorRaidEventGroup = "Encuentros de Banda"
	
	GroupCalendar_cMeetingEventName = "Cita"
	GroupCalendar_cBirthdayEventName = "Cumpleaños"
	GroupCalendar_cRoleplayEventName = "Roleo"
	GroupCalendar_cHolidayEventName = "Día de fiesta"
	GroupCalendar_cDentistEventName = "Dentista"
	GroupCalendar_cDoctorEventName = "Médico"
	GroupCalendar_cVacationEventName = "Vacaciones"
	GroupCalendar_cOtherEventName = "Otros"

	GroupCalendar_cAQREventName = "Ruinas de Ahn'Qiraj"
	GroupCalendar_cAQTEventName = "Templo de Ahn'Qiraj"
	GroupCalendar_cBFDEventName = "Cavernas de Brazanegra"
	GroupCalendar_cBRDEventName = "Profundidades de Roca Negra"
	GroupCalendar_cUBRSEventName = "Cumbre de Roca Negra (Superior)"
	GroupCalendar_cLBRSEventName = "Cumbre de Roca Negra (Inferior)"
	GroupCalendar_cBWLEventName = "Guarida Alanegra"
	GroupCalendar_cDeadminesEventName = "Las Minas de la Muerte"
	GroupCalendar_cDMEventName = "La Masacre"
	GroupCalendar_cGnomerEventName = "Gnomeregan"
	GroupCalendar_cMaraEventName = "Maraudon"
	GroupCalendar_cMCEventName = "Núcleo de Magma"
	GroupCalendar_cOnyxiaEventName = "Guarida de Onyxia"
	GroupCalendar_cRFCEventName = "Sima ígnea"
	GroupCalendar_cRFDEventName = "Zahúrda Rojocieno"
	GroupCalendar_cRFKEventName = "Horado Rajacieno"
	GroupCalendar_cSMEventName = "Monasterio Escarlata"
	GroupCalendar_cScholoEventName = "Scholomance"
	GroupCalendar_cSFKEventName = "Castillo de Colmillo Oscuro"
	GroupCalendar_cStockadesEventName = "Mazmorras de Ventormenta"
	GroupCalendar_cStrathEventName = "Stratholme"
	GroupCalendar_cSTEventName = "El Templo de Atal'Hakkar"
	GroupCalendar_cUldEventName = "Uldaman"
	GroupCalendar_cWCEventName = "Cuevas de los Lamentos"
	GroupCalendar_cZFEventName = "Zul'Farrak"
	GroupCalendar_cZGEventName = "Zul'Gurub"
	GroupCalendar_cNaxxEventName = "Naxxramas"

	GroupCalendar_cTheEyeEventName = "El Ojo de la Tormenta"
	GroupCalendar_cSerpentshrineEventName = "Caverna del Santuario de la Serpiente"
	GroupCalendar_cMagtheridonEventName = "La Guarida de Magtheridon"
	GroupCalendar_cHyjalEventName = "El Monte Hyjal"
	GroupCalendar_cKarazhanEventName = "Karazhan"
	GroupCalendar_cZulAmanEventName = "Zul'Aman"
	GroupCalendar_cGruulEventName = "Guarida de Gruul"
	GroupCalendar_cBlackTempleEventName = "Templo Oscuro"

	GroupCalendar_cArcatrazEventName = "El Castillo de la Tempestad: Arcatraz"
	GroupCalendar_cBotanicaEventName = "El Castillo de la Tempestad: El Invernáculo"
	GroupCalendar_cMechanarEventName = "El Castillo de la Tempestad: El Mechanar"

	GroupCalendar_cDurnholdeEventName = "CdT: El Castillo de Durnholde"
	GroupCalendar_cDarkPortalEventName = "CdT: El Portal Oscuro"

	GroupCalendar_cAuchenaiCryptsEventName = "Auchindoun: Criptas Auchenai"
	GroupCalendar_cSethekkHallsEventName = "Auchindoun: Salas Sethekk"
	GroupCalendar_cShadowLabyrinthEventName = "Auchindoun: Laberinto de las sombras"
	GroupCalendar_cManaTombsEventName = "Auchindoun: Tumbas de Maná"

	GroupCalendar_cSteamvaultEventName = "Reserva Colmillo Torcido: La Sotiénaga"
	GroupCalendar_cUnderbogEventName = "Reserva Colmillo Torcido: Las Cámaras de Vapor"
	GroupCalendar_cSlavePensEventName = "Reserva Colmillo Torcido: El Campo de Esclavos"

	GroupCalendar_cShatteredHallsEventName = "Ciudadela del Fuego Infernal: Las Salas Arrasadas"
	GroupCalendar_cFurnaceEventName = "Ciudadela del Fuego Infernal: El Horno de la Sangre"
	GroupCalendar_cRampartsEventName = "Ciudadela del Fuego Infernal: Murallas del Fuego Infernal"

	GroupCalendar_cArcatrazHEventName = "El Castillo de la Tempestad: Arcatraz (Heroica)"
	GroupCalendar_cBotanicaHEventName = "El Castillo de la Tempestad: El Invernáculo (Heroica)"
	GroupCalendar_cMechanarHEventName = "El Castillo de la Tempestad: El Mechanar (Heroica)"

	GroupCalendar_cDurnholdeHEventName = "CdT: El Castillo de Durnholde (Heroica)"
	GroupCalendar_cDarkPortalHEventName = "CdT: El Portal Oscuro (Heroica)"

	GroupCalendar_cAuchenaiCryptsHEventName = "Auchindoun: Criptas Auchenai (Heroica)"
	GroupCalendar_cSethekkHallsHEventName = "Auchindoun: Salas Sethekk (Heroica)"
	GroupCalendar_cShadowLabyrinthHEventName = "Auchindoun: Laberinto de las Sombras (Heroica)"
	GroupCalendar_cManaTombsHEventName = "Auchindoun: Tumbas de Maná (Heroica)"

	GroupCalendar_cSteamvaultHEventName = "Reserva Colmillo Torcido: La Sotiénaga (Heroica)"
	GroupCalendar_cUnderbogHEventName = "Reserva Colmillo Torcido: Las Cá1maras de Vapor (Heroica)"
	GroupCalendar_cSlavePensHEventName = "Reserva Colmillo Torcido: El Campo de Esclavos (Heroica)"

	GroupCalendar_cShatteredHallsHEventName = "Ciudadela del Fuego Infernal: Las Salas Arrasadas (Heroica)"
	GroupCalendar_cFurnaceHEventName = "Ciudadela del Fuego Infernal: El Horno de la Sangre (Heroica)"
	GroupCalendar_cRampartsHEventName = "Ciudadela del Fuego Infernal: Murallas del Fuego Infernal (Heroica)"
	
	GroupCalendar_cMagistersEventName = "Bancal del Magister"
	GroupCalendar_cMagistersHEventName = "Bancal del Magister (Heroica)"
	GroupCalendar_cSunwellEventName = "La fuente del Sol"

	GroupCalendar_cPvPEventName = "JcJ en general"
	GroupCalendar_cA2v2EventName = "Arena (2v2)"
	GroupCalendar_cA3v3EventName = "Arena (3v3)"
	GroupCalendar_cA5v5EventName = "Arena (5v5)"
	GroupCalendar_cABEventName = "Cuenca de Arathi"
	GroupCalendar_cAVEventName = "Valle de Alterac"
	GroupCalendar_cWSGEventName = "Garganta Grito de Guerra"
    GroupCalendar_cEotSEventName = "El Ojo de la Tormenta"

	GroupCalendar_cDoomWalkerEventName = "Caminante del Destino"
	GroupCalendar_cDoomLordKazzakEventName = "Señor Apocalíptico Kazzak"
	
	GroupCalendar_cZGResetEventName = "Reinicio de Zul'Gurub"
	GroupCalendar_cMCResetEventName = "Reinicio de Núcleo de Magma"
	GroupCalendar_cOnyxiaResetEventName = "Reinicio de Onyxia"
	GroupCalendar_cBWLResetEventName = "Reinicio de La Guarida Alanegra"
	GroupCalendar_cAQRResetEventName = "Reinicio de Ruinas de Ahn'Qiraj"
	GroupCalendar_cAQTResetEventName = "Reinicio de El Templo de Ahn'Qiraj"
	GroupCalendar_cNaxxResetEventName = "Reinicio de Naxxramas"
	GroupCalendar_cKarazhanResetEventName = "Reinicio de Karazhan"
	GroupCalendar_cZulAmanResetEventName = "Reinicio de Zul'Aman"
	GroupCalendar_cBlackTempleResetEventName = "Reinicio de El Templo Oscuro"
	GroupCalendar_cTheEyeResetEventName = "Reinicio de Ojo de la Tormenta"
	GroupCalendar_cSerpentshrineResetEventName = "Reinicio de Caverna Santuario Serpiente"
	GroupCalendar_cMagtheridonResetEventName = "Reinicio de Guarida de Magtheridon"
	GroupCalendar_cHyjalResetEventName = "Reinicio de El Monte Hyjal"
	GroupCalendar_cGruulResetEventName = "Reinicio de La Guarida de Gruul"
	GroupCalendar_cSunwellResetEventName = "Reinicio La fuente del Sol"
	
	GroupCalendar_cTransmuteCooldownEventName = "Transmutación disponible"
	GroupCalendar_cSaltShakerCooldownEventName = "Salero disponible"
	GroupCalendar_cMoonclothCooldownEventName = "Tela lunar disponible"
	GroupCalendar_cPrimalMoonclothCooldownEventName = "Tela lunar primigenia disponible"
	GroupCalendar_cSpellclothCooldownEventName = "Paño de hechizos disponible"
	GroupCalendar_cShadowclothCooldownEventName = "Paño de las Sombras disponible"
	GroupCalendar_cSnowmasterCooldownEventName = "Señor de las nieves 9000 disponible"
	GroupCalendar_cBrilliantGlassCooldownEventName = "Brilliant Glass Available"
	GroupCalendar_cVoidShatterCooldownEventName = "Void Shatter Available"
	GroupCalendar_cVoidSphereCooldownEventName = "Void Sphere Available"

	GroupCalendar_cPersonalEventOwner = "Privado"

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

	GroupCalendar_cDwarfRaceName = "Enano"
	GroupCalendar_cGnomeRaceName = "Gnomo"
	GroupCalendar_cHumanRaceName = "Humano"
	GroupCalendar_cNightElfRaceName = "Elfos de la Noche"
	GroupCalendar_cOrcRaceName = "Orco"
	GroupCalendar_cTaurenRaceName = "Tauren"
	GroupCalendar_cTrollRaceName = "Trol"
	GroupCalendar_cUndeadRaceName = "No-Muerto"
	GroupCalendar_cBloodElfRaceName = "Elfos de la Sangre"
	GroupCalendar_cDraeneiRaceName = "Draenei"

	-- Class names

	GroupCalendar_cFemaleDruidClassName = "Druida"
	GroupCalendar_cMaleDruidClassName = "Druida"
	GroupCalendar_cFemaleHunterClassName = "Cazadora"
	GroupCalendar_cMaleHunterClassName = "Cazador"
	GroupCalendar_cFemaleMageClassName = "Maga"
	GroupCalendar_cMaleMageClassName = "Mago"
	GroupCalendar_cFemalePaladinClassName = "Paladín"
	GroupCalendar_cMalePaladinClassName = "Paladín"
	GroupCalendar_cFemalePriestClassName = "Sacerdotisa"
	GroupCalendar_cMalePriestClassName = "Sacerdote"
	GroupCalendar_cFemaleRogueClassName = "Pícara"
	GroupCalendar_cMaleRogueClassName = "Pícaro"
	GroupCalendar_cFemaleShamanClassName = "Chamán"
	GroupCalendar_cMaleShamanClassName = "Chamán"
	GroupCalendar_cFemaleWarlockClassName = "Bruja"
	GroupCalendar_cMaleWarlockClassName = "Brujo"
	GroupCalendar_cFemaleWarriorClassName = "Guerrera"
	GroupCalendar_cMaleWarriorClassName = "Guerrero"
	
	-- Plural forms of class names

	GroupCalendar_cDruidsClassName = "Druidas"
	GroupCalendar_cHuntersClassName = "Cazadores"
	GroupCalendar_cMagesClassName = "Magos"
	GroupCalendar_cPaladinsClassName = "Paladines"
	GroupCalendar_cPriestsClassName = "Sacerdotes"
	GroupCalendar_cRoguesClassName = "Pícaros"
	GroupCalendar_cShamansClassName = "Chamanes"
	GroupCalendar_cWarlocksClassName = "Brujos"
	GroupCalendar_cWarriorsClassName = "Guerreros"

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

	GroupCalendar_cTimeLabel = "Hora:"
	GroupCalendar_cDurationLabel = "Duración:"
	GroupCalendar_cEventLabel = "Evento:"
	GroupCalendar_cTitleLabel = "Título:"
	GroupCalendar_cLevelsLabel = "Niveles:"
	GroupCalendar_cLevelRangeSeparator = "a"
	GroupCalendar_cDescriptionLabel = "Descripción:"
	GroupCalendar_cCommentLabel = "Comentario:"

	CalendarEditor_cNewEvent = "Nuevo evento..."
	CalendarEditor_cEventsTitle = "Eventos"

	CalendarEvent_cNotAttending = "No asiste"
	CalendarEvent_cConfirmed = "Confirmado"
	CalendarEvent_cDeclined = "Declinado"
	CalendarEvent_cStandby = "En reserva"
	CalendarEvent_cMaybe = "Quizás asista"
	CalendarEvent_cPending = "Pendiente"
	CalendarEvent_cBanned = "Baneado"
	CalendarEvent_cUnknownStatus = "%s Desconocido"

	GroupCalendar_cChannelNameLabel = "Nombre canal:"
	GroupCalendar_cPasswordLabel = "Contraseña:"

	GroupCalendar_cSingleTimeDateFormat = "%s  %s"
	GroupCalendar_cTimeDateRangeFormat = "%s  %s a %s"

	GroupCalendar_cPluralMinutesFormat = "%d minutos"
	GroupCalendar_cSingularHourFormat = "%d hora"
	GroupCalendar_cPluralHourFormat = "%d horas"
	GroupCalendar_cSingularHourPluralMinutes = "%d hora %d minutos"
	GroupCalendar_cPluralHourPluralMinutes = "%d horas %d minutos"

	if string.sub(GetLocale(), -2) == "US" then
		GroupCalendar_cLongDateFormat = "$month $day, $year"
		GroupCalendar_cShortDateFormat = "$monthNum/$day"
		GroupCalendar_cLongDateFormatWithDayOfWeek = "$dow $month $day, $year"
	else
		GroupCalendar_cLongDateFormat = "$day. $month $year"
		GroupCalendar_cShortDateFormat = "$day.$monthNum"
		GroupCalendar_cLongDateFormatWithDayOfWeek = "$dow $day. $month $year"
	end

	GroupCalendar_cNotAttendingCategory = "No asisten"
	GroupCalendar_cAttendingCategory = "Asisten"
	GroupCalendar_cPendingApprovalCategory = "Pendiente de peticiones y cambios"
	GroupCalendar_cStandbyCategory = "Reserva"
	GroupCalendar_cMaybeCategory = "Quizás"
	GroupCalendar_cWhispersCategory = "Susurros recientes"
	GroupCalendar_cBannedCategory = "Baneado"

	GroupCalendar_cQuestAttendanceNameFormat = "$name ($level $race)"
	GroupCalendar_cMeetingAttendanceNameFormat = "$name ($level $class)"
	GroupCalendar_cGroupAttendanceNameFormat = "$name ($status)"

	GroupCalendar_cNumAttendeesFormat = "%d (+%d)"
	GroupCalendar_cNumPlayersFormat = "%d"

	GroupCalendar_cTotalNumPlayersFormat = "%s jugadores"

	BINDING_HEADER_GROUPCALENDAR_TITLE = "Group Calendar"
	BINDING_NAME_GROUPCALENDAR_TOGGLE = "Mostrar/Ocultar GroupCalendar"

	-- Tradeskill cooldown items

	GroupCalendar_cHerbalismSkillName = "Botánica"
	GroupCalendar_cAlchemySkillName = "Alquimia"
	GroupCalendar_cEnchantingSkillName = "Encantamiento"
	GroupCalendar_cLeatherworkingSkillName = "Peletería"
	GroupCalendar_cSkinningSkillName = "Desollar"
	GroupCalendar_cTailoringSkillName = "Sastrería"
	GroupCalendar_cMiningSkillName = "Minería"
	GroupCalendar_cBlacksmithingSkillName = "Herrería"
	GroupCalendar_cEngineeringSkillName = "Ingeniería"

	GroupCalendar_cTransmuteMithrilToTruesilver = "Transmutar: mitril a veraplata"
	GroupCalendar_cTransmuteIronToGold = "Transmutar: hierro a oro"
	GroupCalendar_cTransmuteLifeToEarth = "Transmutar: vida a tierra"
	GroupCalendar_cTransmuteWaterToUndeath = "Transmutar: agua a inerte";--Q Revisar traducción "Inerte", podria ser "No-muerto"
	GroupCalendar_cTransmuteWaterToAir = "Transmutar: agua a aire"
	GroupCalendar_cTransmuteUndeathToWater = "Transmutar: inerte a agua";--Q Revisar traducción "Inerte", podria ser "No-muerto"
	GroupCalendar_cTransmuteFireToEarth = "Transmutar: fuego a tierra"
	GroupCalendar_cTransmuteEarthToLife = "Transmutar: tierra a vida"
	GroupCalendar_cTransmuteEarthToWater = "Transmutar: tierra a agua"
	GroupCalendar_cTransmuteAirToFire = "Transmutar: aire a fuego"
	GroupCalendar_cTransmuteArcanite = "Transmutar: arcanita"
	GroupCalendar_cTransmutePrimalAirToFire = "Transmutar: aire primigenio en fuego"
	GroupCalendar_cTransmutePrimalFireToEarth = "Transmutar: fuego primigenio a tierra"
	GroupCalendar_cTransmutePrimalEarthToWater = "Transmutar: tierra primigenia a agua"
	GroupCalendar_cTransmutePrimalWaterToAir = "Transmutar: agua primigenia a aire"
	GroupCalendar_cTransmutePrimalEarthToLife = "Transmutar: tierra primigenia a vida"
	GroupCalendar_cTransmutePrimalLifeToEarth= "Transmutar: vida primigenia a tierra"
	GroupCalendar_cTransmutePrimalFireToMana = "Transmutar: fuego primigenio a maná"
	GroupCalendar_cTransmutePrimalManaToFire = "Transmutar: maná primigenio a fuego"
	GroupCalendar_cTransmutePrimalShadowToWater = "Transmutar: sombra primigenia a agua"
	GroupCalendar_cTransmutePrimalWaterToShadow = "Transmutar: agua primigenia a sombra"
	GroupCalendar_cTransmutePrimalMight = "Transmutar: poder primigenio"
	GroupCalendar_cTransmuteEarthstormDiamond = "Transmutar: diamante de tormenta de tierra"
	GroupCalendar_cTransmuteSkyfireDiamond = "Transmutar: diamante de fuego celeste";	
	
	GroupCalendar_cMooncloth = "Tela lunar"
	GroupCalendar_cPrimalMooncloth = "Tela lunar primigenia"
	GroupCalendar_cSpellcloth = "Paño de hechizos"
	GroupCalendar_cShadowcloth = "Paño de las Sombras"

	GroupCalendar_cBrilliantGlass = "Brilliant Glass"
	GroupCalendar_cVoidShatter = "Void Shatter"
	GroupCalendar_cVoidSphere = "Void Sphere"

	GroupCalendar_cCharactersLabel = "Personaje:"

	GroupCalendar_cConfirmed = "Aceptado"
	GroupCalendar_cStandby = "En espera"
	GroupCalendar_cMaybe = "Quizás"
	GroupCalendar_cDeclined = "Rechazado"
	GroupCalendar_cBanned = "Baneado"
	GroupCalendar_cRemove = "Eliminar"
	GroupCalendar_cEditPlayer = "Editar Jugador..."
	GroupCalendar_cInviteNow = "Invitar al grupo"
	GroupCalendar_cStatus = "Estado"
	GroupCalendar_cAddPlayerEllipses = "Agregar jugador..."

	GroupCalendar_cAddPlayer = "Agregar jugador"
	GroupCalendar_cPlayerLevel = "Nivel:"
	GroupCalendar_cPlayerClassLabel = "Clase:"
	GroupCalendar_cPlayerRaceLabel = "Raza:"
	GroupCalendar_cPlayerStatusLabel = "Estado:"
	GroupCalendar_cRankLabel = "Rango en la hermandad:"
	GroupCalendar_cGuildLabel = "Hermandad:"
	GroupCalendar_cRoleLabel = "Papel:"
	GroupCalendar_cSave = "Guardar"
	GroupCalendar_cLastWhisper = "Ultimo susurro:"
	GroupCalendar_cReplyWhisper = "Respuesta susurro:"

	GroupCalendar_cUnknown = "Desconocido"
	GroupCalendar_cAutoConfirmationTitle = "Autoconfirmar clase"
	GroupCalendar_cRoleConfirmationTitle = "Autoconfirmar papel"
	GroupCalendar_cManualConfirmationTitle = "Confirmaciones manuales"
	GroupCalendar_cClosedEventTitle = "Evento Cerrado"
	GroupCalendar_cMinLabel = "mín"
	GroupCalendar_cMaxLabel = "máx"

	GroupCalendar_cAddPlayerTitle = "Agregar..."
	GroupCalendar_cAutoConfirmButtonTitle = "Configuración..."

	GroupCalendar_cClassLimitDescription = "Usa los campos de abajo para definir el mínimo y el máximo número de cada clase.  Las clases que aun no hayan alcanzado el minimo se rellenaraán primero, el resto de huecos se irán completando en orden de respuesta hasta que el máximo se alcance."
	GroupCalendar_cRoleLimitDescription = "Usa los campos de abajo para definir el mínimo y el máximo número de cada papel.  Los papeles (tanque, curandero, etc) que aun no hayan alcanzado el minimo se rellenaraán primero, el resto de huecos se irán completando en orden de respuesta hasta que el máximo se alcance.  Opcionalmente puedes definir el número de cada clase dentro de cada papel (requerido un dps a distancia que sea sacerdote de sombras, por ejemplo)"
	
	GroupCalendar_cViewGroupBy = "Grupo por"
	GroupCalendar_cViewByStatus = "Estado"
	GroupCalendar_cViewByClass = "Clase"
	GroupCalendar_cViewByRole = "Papel"
	GroupCalendar_cViewSortBy = "Ordenar por"
	GroupCalendar_cViewByDate = "Fecha"
	GroupCalendar_cViewByRank = "Rango"
	GroupCalendar_cViewByName = "Nombre"

	GroupCalendar_cMaxPartySizeLabel = "Máx tamaño grupo:"
	GroupCalendar_cMinPartySizeLabel = "Mín tamaño grupo:"
	GroupCalendar_cNoMinimum = "Sin mín"
	GroupCalendar_cNoMaximum = "Sin máx"
	GroupCalendar_cPartySizeFormat = "%d jugadores"

	GroupCalendar_cInviteButtonTitle = "Invitar Seleccionado"
	GroupCalendar_cAutoSelectButtonTitle = "Seleccionar Jugadores..."
	GroupCalendar_cAutoSelectWindowTitle = "Seleccionar Jugadores"

	GroupCalendar_cNoSelection = "No hay jugadores seleccionados"
	GroupCalendar_cSingleSelection = "1 jugador seleccionado"
	GroupCalendar_cMultiSelection = "%d jugadores seleccionados"

	GroupCalendar_cInviteNeedSelectionStatus = "Selecciona jugadores a invitar"
	GroupCalendar_cInviteReadyStatus = "Listo para invitar"
	GroupCalendar_cInviteInitialInvitesStatus = "Enviando invitaciones iniciales"
	GroupCalendar_cInviteAwaitingAcceptanceStatus = "Esperando aceptación inicial"
	GroupCalendar_cInviteConvertingToRaidStatus = "Conviritendo a banda"
	GroupCalendar_cInviteInvitingStatus = "Enviando invitaciones"
	GroupCalendar_cInviteCompleteStatus = "Invitaciones completas"
	GroupCalendar_cInviteReadyToRefillStatus = "Listo para llenar los huecos vacantes"
	GroupCalendar_cInviteNoMoreAvailableStatus = "No hay más personajes disponibles para completar el grupo"
	GroupCalendar_cRaidFull = "Banda completa"

	GroupCalendar_cInviteWhisperFormat = "[Group Calendar] Estas siendo invitado al evento '%s'.  Por favor acepta la invitación si deseas unirte a este evento."
	GroupCalendar_cAlreadyGroupedWhisper = "[Group Calendar] Ya estas en un grupo.  Porfavor vuelve a susurrarme(/su) cuando dejes tu grupo."

	GroupCalendar_cJoinedGroupStatus = "Unido"
	GropuCalendar_cInvitedGroupStatus = "Invitado"
	GropuCalendar_cReadyGroupStatus = "Preparado"
	GroupCalendar_cGroupedGroupStatus = "En otro grupo"
	GroupCalendar_cStandbyGroupStatus = "Reserva"
	GroupCalendar_cMaybeGroupStatus = "Quizás"
	GroupCalendar_cDeclinedGroupStatus = "Invitación Rechazada"
	GroupCalendar_cOfflineGroupStatus = "Desconectado"
	GroupCalendar_cLeftGroupStatus = "Abandono Grupo"

	GroupCalendar_cPriorityLabel = "Prioridad:"
	GroupCalendar_cPriorityDate = "Fecha"
	GroupCalendar_cPriorityRank = "Rango"

	GroupCalendar_cConfirmSelfUpdateMsg = "%s"
	GroupCalendar_cConfirmSelfUpdateParamFormat = "Los cambios en el evento se han realizado por $mUserName desde otro ordenador.  Si utilizas múltiples ordenadores, se te estropea o reinstalas el juego entonces deberías elegir Aceptar para restaurar tus eventos.  Elige Eliminar si crees que los cambios no han sido realizados desde otro ordenador."
	GroupCalendar_cConfirmSelfRSVPUpdateParamFormat = "Los cambios en la asistencia se han realizado por $mUserName desde otro ordenador.  Si utilizas múltiples ordenadores, se te estropea o reinstalas el juego entonces deberías elegir Aceptar para restaurar tus peticiones de asistencia.  Elige Eliminar si crees que los cambios no han sido realizados desde otro ordenador."
	GroupCalendar_cUpdate = "Actualizar"

	GroupCalendar_cConfirmClearWhispers = "¿Limpiar todos los privados recientes?"
	GroupCalendar_cClear = "Limpiar"

	CalendarDatabases_cTitle = "Versiones de Group Calendar"
	CalendarDatabases_cRefresh = "Actualizar"
	CalendarDatabases_cRefreshDescription = "Solicitar a los jugadores en línea su número de versión.  Puede tardar unos cuantos minutos en actualizar las versiones.  Las actualizaciones recibidas mientras esta ventana este cerrada seguiran siendo guardadas y podrán verse más adelante."

	GroupCalendar_cVersionFormat = "Group Calendar v%s"
	GroupCalendar_cShortVersionFormat = "v%s"
	GroupCalendar_cVersionUpdatedFormat = "a fecha %s %s (hora local)"
	GroupCalendar_cVersionUpdatedUnknown = "Fecha de la ultima vez que la información de la versión fue vista es desconocida"

	GroupCalendar_cToggleVersionsTitle = "Mostrar versiones jugadores"
	GroupCalendar_cToggleVersionsDescription = "Muestra que versión de Group Calendar están utilizando otros jugadores"

	GroupCalendar_cChangesDelayedMessage = "Group Calendar: Los cambios hechos mientras se esta sincronizando con la red no se enviarán hasta que la sincronización se haya completado."

	GroupCalendar_cConfirmKillMsg = "¿Esta seguro que deseas forzar los eventos de %s fuera de la red?"
	GroupCalendar_cKill = "Matar"

	GroupCalendar_cNotAnOfficerError = "GroupCalendar: Solo los oficiales de la hermandad pueden hacer esto"
	GroupCalendar_cUserNameExpected = "GroupCalendar: Nombre de usuario requerido"
	GroupCalendar_cDatabaseNotFoundError = "GroupCalendar: Base de datos para %s no encontrada."
	GroupCalendar_cCantKillGuildieError = "GroupCalendar: No se puede purgar a un usuario que esta en tu hermandad"

	GroupCalendar_cTooltipScheduleItemFormat = "%s (%s)"

	GroupCalendar_cAvailableMinutesFormat = "%s en %d minutos"
	GroupCalendar_cAvailableMinuteFormat = "%s en %d minuto"
	GroupCalendar_cStartsMinutesFormat = "%s comienza en %d minutos"
	GroupCalendar_cStartsMinuteFormat = "%s comienza en %d minuto"
	GroupCalendar_cStartingNowFormat = "%s esta comenzando ahora"
	GroupCalendar_cAlreadyStartedFormat = "%s ya ha comenzado"
	GroupCalendar_cHappyBirthdayFormat = "¡Feliz cumpleaños %s!"

	GroupCalendar_cTimeRemainingFormat = "(%d:%02d restante)"
	GroupCalendar_cUnknownEventType = "%s (Nuevo tipo de evento, actualiza GroupCalendar)"

	GroupCalendar_cConfirmResetMsg = "¿Estas seguro de que quieres reiniciar el calendario para %s? Todos los eventos y peticiones de este personaje serán eliminados."
	GroupCalendar_cConfirmResetRealmMsg = "¿Estás seguro de que quieres resetear el calendario para todos tus personajes en %s? Todos los eventos serán eliminados para todos tus personajes en todos los servidores."
	GroupCalendar_cConfirmResetAllMsg = "¿Estás seguro que quieres resetear el calendario para todos tus personajes? Todos los eventos serán eliminados para todos tus personajes en todos los servidores."
	GroupCalendar_cReset = "Reinicia"

	GroupCalendar_cNone = "Ninguno"
	
	GroupCalendar_cAttendanceNote = "Has cambiado tu estado de asistencia para %s. Por favor espera 2 minutos antes de desconectarte para asegurarte de que tu petición es guardada. Tu estado aparecerá como Pendiente hasta que el creador del evento se conecte."
	GroupCalendar_cUnknownClockOption = "GroupCalendar: Opción de reloj desconocida."
	GroupCalendar_cBadAgeValue = "El tiempo máximo para este evento debe ser de 1 a 60 días"
	GroupCalendar_cViewMenuFormat = "Ver por %s/%s"
	GroupCalendar_cDefaultTimeFormat = 12
	GroupCalendar_cDefaultStartDay = "Mon" --Dejar en ingles
	GroupCalendar_cForeignRealmFormat = "%s de %s"

	GroupCalendar_cMHRole = "Curandero"
	GroupCalendar_cOHRole = "Sec-Curan."
	GroupCalendar_cMTRole = "Tanque"
	GroupCalendar_cOTRole = "Sec-Tanque"
	GroupCalendar_cRDRole = "Distancia"
	GroupCalendar_cMDRole = "C. a cuerpo"

	GroupCalendar_cMHPluralRole = "Curanderos"
	GroupCalendar_cOHPluralRole = "Sec-Curans"
	GroupCalendar_cMTPluralRole = "Tanques"
	GroupCalendar_cOTPluralRole = "Sec-Tanques"
	GroupCalendar_cRDPluralRole = "Distancia"
	GroupCalendar_cMDPluralRole = "C a cuerpo"

	GroupCalendar_cMHPluralLabel = GroupCalendar_cMHPluralRole..":"
	GroupCalendar_cOHPluralLabel = GroupCalendar_cOHPluralRole..":"
	GroupCalendar_cMTPluralLabel = GroupCalendar_cMTPluralRole..":"
	GroupCalendar_cOTPluralLabel = GroupCalendar_cOTPluralRole..":"
	GroupCalendar_cRDPluralLabel = GroupCalendar_cRDPluralRole..":"
	GroupCalendar_cMDPluralLabel = GroupCalendar_cMDPluralRole..":"

	GroupCalendar_cClockNotSetWarning = "PELIGRO: Tres o mas copias de tu Group Calendar en esta red, indican que sus relojes tienen una gran diferencia en la hora o fecha. Comprueba las opciones de hora y fecha ya que esto podría causarte problemas a la hora de apuntarte a un evento, especialmente si te logueas desde varios ordenadores."

	GroupCalendar.cWhisperSummaryDateHeader    = "%s"
	GroupCalendar.cWhisperSummaryEvent         = "    $time $event [ID $id]"
	GroupCalendar.cWhisperSummaryEventStatus   = "    $time $event [ID $id] ($status)"
	GroupCalendar.cWhisperSummaryNoEvents      = "No hay eventos próximos"
	GroupCalendar.cWhisperSummaryInvalidOption = "%s no es una opción válida.  Usa '!gc help' para ver la lista de comandos disponibles"

	GroupCalendar.cWhisperHelp =
	{
		"!gc - Lo mismo que !gc summary",
		"!gc summary - Muestra los eventos de los próximos 7 días",
		"!gc yes eventid - Apuntate a un evento como asistente",
		"!gc no eventid - Apuntate a un evento como no asistente",
		"!gc maybe eventid - Apuntate a un evento como en espera",
		"!gc help - Muestra la lista de comandos",
		"El ID de los eventos aparece en el sumario de eventos.  Si el evento fué creado con el mismo personaje con el que estas susurrando, puedes utilizar su número, en otro caso utiliza el formato nombre-número para especificar el evento"
	}

	GroupCalendar.cDatabasesTotalFormat = "%d bases de datos"

	GroupCalendar_cConfirmDeleteRSVP = "¿Estas seguro que quieres eliminar %s de tu lista?"

	GroupCalendar.cCantReloadUI = GroupCalendar_cTitleVersion.." incluye nuevos archivos y World of Warcraft se niega a cargarlos hasta que salgas del juego completamente.  Group Calendar se deshabilitará hasta que reinicies el WoW."

	GroupCalendar.cWhisperAccessDenied = "Se ha denegado el acceso a los eventos para %s"
	GroupCalendar.cWhisperCantProxy = "Debes susurrar a %s o a alguno de sus alts para poder añadirle al evento"
	GroupCalendar.cWhisperDatabaseNotFound = "No se ha encontrado la base de datos de %s"
	GroupCalendar.cWhisperEventNotFound = "No se ha encontrado en la base de datos %s el ID del evento %d"
	GroupCalendar.cWhisperFailed = "La petición ha fallado por una razón desconocida.  ¿Te ha añadido el organizador manualmente?."
	GroupCalendar.cWhisperNotGuildmate = "Todavía no se soporta la opción de añadir jugadores de fuera de la hermandad"
	GroupCalendar.cWhisperEventStatus = "Tu estado para %s en %s el %s es ahora %s"
	GroupCalendar.cWhisperAllDayStatus = "Tu estado para %s en %s es ahora %s"
	GroupCalendar.cWhisperWTFError = "No se puede descibrar el evento ID '%s'"
	GroupCalendar.cWhisperHelpReminder = "Susurra '!gc help' para mas comandos"

	GroupCalendar.cAttendanceNoticeYes = "$name asistirá a $event"
	GroupCalendar.cAttendanceNoticeLimitStandby = "Poniendo a $name en espera para $event: Ya se ha alcanzado el límite de clase o papel"
	GroupCalendar.cAttendanceNoticeStandby = "$name aparecerá disponible como jugador en espera para $event"
	GroupCalendar.cAttendanceNoticeNo = "$name no asistirá a $event"
	GroupCalendar.cAttendanceNoticeBanned = "Descartando peticiones de $name para $event: El jugador ha sido baneado del evento"
	GroupCalendar.cAttendanceNoticeManual = "Poniendo a $name en espera ara $event: Este evento requiere de tu confirmación para asistir"
	GroupCalendar.cAttendanceUnknownQualifiedError = "No estás cualificado para este evento, pero el programa no ha reportado una razón"
	GroupCalendar.cAttendanceNoticeMaybe = "$name might be attending $event on $date"

	GroupCalendar.cAttendanceClosedEvent = "El evento, o un evento cercano -- todos los jugadores deben ser añadidos manualmente por el mismo"
	GroupCalendar.cAttendanceUnknownLevel = "Este evento tiene restricciones de nivel y tu nivel es desconocido"
	GroupCalendar.cAttendanceLevelTooLow = "No tienes suficiente nivel para este evento"
	GroupCalendar.cAttendanceLevelTooHigh = "Tienes demasiado nivel para este evento"
	GroupCalendar.cAttendanceGuildMembersOnly = "Este evento es solo para miembros de <%s>"
	GroupCalendar.cAttendanceRankTooLow = "El rango de tu hermandad es demasiado bajo para poder asistir a este evento"
	GroupCalendar.cAttendanceNotAllowed = "No tienes permiso para acceder al calendario"
	GroupCalendar.cAttendanceSynching = "Group Calendar está sincronizando con la red.  Inténtalo de nuevo dentro de unos minutos."

	GroupCalendar.cNewerVersionMessage = "Hay una nueva versión disponible (%s)"

	GroupCalendar.cBackupTitle = "Backup y Restaurar"
	GroupCalendar.cNoBackups = "No se ha realizado ninguna copia de seguridad todavía.  Se realizará una copia de seguridad automáticamente cuando tu calendario sea modificado desde otro ordenador o haciendo click en el botón 'Backup'."
	GroupCalendar.cBackupNow = "Backup"
	GroupCalendar.cBackupNowDescription = "Guarda una copia de seguridad de tus eventos y peticiones de asistencia para %s."
	GroupCalendar.cConfirmDeleteBackup = "¿Estas seguro de querer eliminar la copia de seguridad de %s?"
	GroupCalendar.cConfirmRestoreBackup = "¿Estas seguro de querer restaurar la copia de seguridad de %s?"
	GroupCalendar.cRestoreBackup = "Restaurar"
	GroupCalendar.cBackupRestored = "La copia de seguridad se ha restaurado.  Los eventos restaurados deberían empezar a aparecer a los demás jugadores en uno o dos minutos."

	GroupCalendar.cNetworkSyncComplete = "Network synchronization completed"

	GroupCalendar.cTimeManagerToggle = "Click-Izdo para mostraar las opciones del reloj."
end
