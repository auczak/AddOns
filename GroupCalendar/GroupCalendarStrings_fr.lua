if GetLocale() == "frFR" then
	GroupCalendar_cTitle = "Group Calendar v%s"

	GroupCalendar.cSingleItemFormat = "%s"
	GroupCalendar.cTwoItemFormat = "%s et %s"
	GroupCalendar.cMultiItemFormat = "%s{{, %s}} et %s"
	
	GroupCalendar_cSun = "Dim"
	GroupCalendar_cMon = "Lun"
	GroupCalendar_cTue = "Mar"
	GroupCalendar_cWed = "Mer"
	GroupCalendar_cThu = "Jeu"
	GroupCalendar_cFri = "Ven"
	GroupCalendar_cSat = "Sam"

	GroupCalendar_cSunday = "Dimanche"
	GroupCalendar_cMonday = "Lundi"
	GroupCalendar_cTuesday = "Mardi"
	GroupCalendar_cWednesday = "Mercredi"
	GroupCalendar_cThursday = "Jeudi"
	GroupCalendar_cFriday = "Vendredi"
	GroupCalendar_cSaturday = "Samedi"

	GroupCalendar_cSelfWillAttend = "%s sera présent"
	GroupCalendar_cGuildOnly = "Réservé aux %s"

	GroupCalendar_cMonthNames = {"Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"}
	GroupCalendar_cDayOfWeekNames = {GroupCalendar_cSunday, GroupCalendar_cMonday, GroupCalendar_cTuesday, GroupCalendar_cWednesday, GroupCalendar_cThursday, GroupCalendar_cFriday, GroupCalendar_cSaturday}

	GroupCalendar_cLoadMessage = "GroupCalendar chargé. Taper '/cal show' pour afficher le calendrier"
	GroupCalendar_cInitializingGuilded = "GroupCalendar: Initialisation des paramètres pour les joueurs guildés"
	GroupCalendar_cInitializingUnguilded = "GroupCalendar: Initialisation des paramètres pour les joueurs non guildés"
	GroupCalendar_cLocalTimeNote = "(%s local)"

	GroupCalendar_cOptions = "Configuration..."

	GroupCalendar_cCalendar = "Calendrier"
	GroupCalendar_cSetup = "Configuration"
	GroupCalendar_cBackup = "Backup"
	GroupCalendar_cAbout = "A propos"

	GroupCalendar_cUseServerDateTime = "Utiliser les horaires du serveur"
	GroupCalendar_cUseServerDateTimeDescription = "Activer pour que les événements utilisent l'heure et la date du serveur, désactiver pour utiliser votre date et heure"

	GroupCalendar_cSetupTitle = "Configuration de Calendar"
	GroupCalendar_cConfigModeLabel = "Configuration:"
	GroupCalendar_cAutoChannelConfig = "Automatique"
	GroupCalendar_cManualChannelConfig = "Manuelle"
	GroupCalendar_cAdminChannelConfig = "Administrateur"

	GroupCalendar_cChannelConfigTitle = "Configuration du canal de données"
	GroupCalendar_cChannelConfigDescription = "Le canal de données du calendrier est utilisé pour envoyer et recevoir les événements entre joueurs. Toute personne pouvant joindre le canal pourra voir vos événements s\'ils le veulent. Pour garder votre calendrier privé vous devriez utiliser un mot de passe pour le canal."
	GroupCalendar_cAutoChannelConfig = "Configuration de canal automatique"
	GroupCalendar_cManualChannelConfig = "Configuration du canal manuelle"
	GroupCalendar_cStoreAutoConfig = "Stockage auto. configure les données depuis les notes du joueur"
	GroupCalendar_cAutoConfigPlayer = "Joueur :"

	GroupCalendar_cUseGuildChannel = "Utiliser le canal de données de la guilde"
        GroupCalendar_cUseGuildChannelDescription = "Utilise le canal de votre guilde. Ce canal n\'est pas accessible aux joueurs n'appartenant pas à votre guilde."

	GroupCalendar_cUseSharedChannel = "Utiliser le canal de données du serveur"
        GroupCalendar_cUseSharedChannelDescription = "Utilise un canal publique. Ce canal est accessible à toutes personnes de la même faction sur votre serveur, vous devrez donc utiliser un mot de passe pour restreindre l\'accès."

	GroupCalendar_cApplyChannelChanges = "Appliquer"
	GroupCalendar_cAutoConfigTipTitle = "Configuration canal Automatique"
	GroupCalendar_cAutoConfigTipDescription = "Obtention automatique des configuration de canal depuis votre tableau de guilde. Vous devez obligatoirement être dans une guilde et ce dispositif doit être configuré par un officier de la guilde pour pouvoir l\'utiliser ."
	GroupCalendar_cManualConfigTipDescription = "Vous permet de saisir manuellement les informations de canal et de mot de passe."
	GroupCalendar_cStoreAutoConfigTipDescription = "Permet à un officier de guilde de stocker la configuration du canal dans la note des joueurs sélectionés dans le tableau de guilde."
	GroupCalendar_cAutoConfigPlayerTipDescription = "Le nom du joueur dans le tableau de guilde ayant les données de configuration du canal."
	GroupCalendar_cChannelNameTipTitle = "Nom du canal"
	GroupCalendar_cChannelNameTipDescription = "Le nom du canal de chat qui sera utilisé pour envoyer et recevoir les données des événements des autres joueurs"
	GroupCalendar_cConnectChannel = "Connecter"
	GroupCalendar_cDisconnectChannel = "Déconnecter"
	GroupCalendar_cChannelStatus =
	{
		Starting = {mText = "Statut: Démarrage...", mColor = {r = 1, g = 1, b = 0.3}},
		Synching = {mText = "Statut: Synchronisation avec le réseau %s", mColor = {r = 0.3, g = 1, b = 0.3}},
		Suspended = {mText = "Statut: Suspendu (fermeture de session)", mColor = {r = 1, g = 1, b = 0.3}},
		Connected = {mText = "Statut: Canal de données connecté", mColor = {r = 0.3, g = 1, b = 0.3}},
		Disconnected = {mText = "Statut: Canal de données non connecté", mColor = {r = 1, g = 0.2, b = 0.4}},
		Initializing = {mText = "Statut: Initialisation du canal de données", mColor = {r = 1, g = 1, b = 0.3}},
		Error = {mText = "Erreur: %s", mColor = {r = 1, g = 0.2, b = 0.4}},
	}

	GroupCalendar_cConnected = "Connecté"
	GroupCalendar_cDisconnected = "Deconnecté"
	GroupCalendar_cTooManyChannels = "Vous avez déjà rejoint le nombre maximum de canaux (10)"
	GroupCalendar_cJoinChannelFailed = "N'a pas joint le canal pour une raison inconnue"
	GroupCalendar_cWrongPassword = "Le mot de passe est incorrect"
	GroupCalendar_cAutoConfigNotFound = "Données de configuration non trouvées dans le tableau de guilde"
	GroupCalendar_cErrorAccessingNote = "N'a pas pu retrouver les données de configuration"

	GroupCalendar_cTrustConfigTitle = "Configuration Confiance"
	GroupCalendar_cTrustConfigDescription = "Confiance désigne qui vous autorisez à vous ajouter des événements. Cela ne limite pas qui peut voir les événements de votre calendrier. Utilisez un canal de données avec mot de passe pour restreindre l\'accès à votre calendrier."
	GroupCalendar_cTrustGroupLabel = "Confiance:"
	GroupCalendar_cEvent = "Evénement"
	GroupCalendar_cEdit = "Edit"
	GroupCalendar_cAttendance = "Avancé"

	GroupCalendar_cAboutTitle = "A propos de GroupCalendar"
	GroupCalendar_cTitleVersion = "Group Calendar "..GroupCalendar.VersionString

	GroupCalendar.cAuthor = "Designed and written by John Stephen with contributions by %s"
	GroupCalendar_cTestersTitle = "Testers for 4.0"
	GroupCalendar_cSpecialThanksTitle = "Special thanks to"
	GroupCalendar.cTranslationCredit = "Traduction %s"
	GroupCalendar_cGuildURL = "wobbleworks.com"
	
	GroupCalendar_cRebuildDatabase = "Reconstruire la base de données"
	GroupCalendar_cRebuildDatabaseDescription = "Reconstruit la base de données de votre personnage. Cela devrait résoudre les problèmes pour les personnes qui ne voient pas tous vos événements, mais il y a un léger risque que certaines réponses d\'assistance d\'événement soient perdues."

	GroupCalendar_cTrustGroups =
	{
		"Quiconque ayant accès au canal de données",
		"Les autres membres de votre guilde",
		"Uniquement ceux listés en dessous"
	}

	GroupCalendar_cTrustAnyone = "Confiance envers tous ceux ayant accès au canal"
	GroupCalendar_cTrustGuildies = "Confiance envers les membres de la guilde"
	GroupCalendar_cTrustMinRank = "Rang Minimum:"
	GroupCalendar_cTrustNobody = "Confiance uniquement à ceux listés ci-dessous"
	GroupCalendar_cTrustedPlayers = "Joueurs additionels"
	GroupCalendar_cExcludedPlayers = "Joueurs exclus"
	GroupCalendar_cPlayerName = "Joueur:"
	GroupCalendar_cAddTrusted = "Confiance"
	GroupCalendar_cRemoveTrusted = "Retirer"
	GroupCalendar_cAddExcluded = "Exclure"

	CalendarEventViewer_cTitle = "Voir événement"
	CalendarEventViewer_cDone = "Valider"

	CalendarEventViewer_cLevelRangeFormat = "Niveaux %i à %i"
	CalendarEventViewer_cMinLevelFormat = "Niveaux %i et +"
	CalendarEventViewer_cMaxLevelFormat = "Jusqu\'au niveau %i"
	CalendarEventViewer_cAllLevels = "Tous niveaux"
	CalendarEventViewer_cSingleLevel = "Niveau %i uniquement"

	CalendarEventViewer_cYes = "Oui! Je participe à cet événement"
	CalendarEventViewer_cNo = "Non. je ne participe pas à cet événement"
	CalendarEventViewer_cMaybe = "Peut-être. Me mettre sur la liste d'attente"

	CalendarEventViewer_cResponseMessage =
	{
		"Statut: Aucune réponse envoyée",
		"Statut: Attente de confirmation",
		"Statut: Confirmé - Accepté",
		"Statut: Confirmé - En attente",
		"Statut: Confirmé - Rejeté",
		"Statut: Exclu de l\'event",
		"Statut: Confirmé - Peut-être",
	}

	CalendarEventEditorFrame_cTitle = "Ajouter/Modifier/Effacer un événement"
	CalendarEvent_cDone = "Valider"
	CalendarEvent_cDelete = "Effacer"
	CalendarEvent_cGroupTabTitle = "Groupe"

	CalendarEvent_cConfirmDeleteMsg = "Effacer \"%s\"?"

	-- Event names

	GroupCalendar_cGeneralEventGroup = "Général"
	GroupCalendar_cPersonalEventGroup = "Personnel (non partagé)"
	GroupCalendar_cRaidEventGroup = "Raids"
	GroupCalendar_cDungeonEventGroup = "Donjons"
	GroupCalendar_cOutlandsDungeonEventGroup = "Donjons (Outreterre)"
	GroupCalendar_cOutlandsHeroicDungeonEventGroup = "Héroïque (Outreterre)"
	GroupCalendar_cBattlegroundEventGroup = "Champs de Bataille"
	GroupCalendar_cOutdoorRaidEventGroup = "Raids extérieurs"

	GroupCalendar_cMeetingEventName = "Réunion"
	GroupCalendar_cBirthdayEventName = "Anniversaire"
	GroupCalendar_cRoleplayEventName = "Jeu de rôle"
	GroupCalendar_cHolidayEventName = "Vacances"
	GroupCalendar_cDentistEventName = "Dentiste"
	GroupCalendar_cDoctorEventName = "Docteur"
	GroupCalendar_cVacationEventName = "Vacances"
	GroupCalendar_cOtherEventName = "Autres"

	GroupCalendar_cAQREventName = "Ruines d'Ahn'Qiraj"
	GroupCalendar_cAQTEventName = "Temple d'Ahn'Qiraj"
	GroupCalendar_cBFDEventName = "Profondeurs de Brassenoir"
	GroupCalendar_cBRDEventName = "BRD"
	GroupCalendar_cUBRSEventName = "UBRS"
	GroupCalendar_cLBRSEventName = "LBRS"
	GroupCalendar_cBWLEventName = "Repaire de l'Aile noire"
	GroupCalendar_cDeadminesEventName = "Les Mortemines"
	GroupCalendar_cDMEventName = "Hache Tripe"
	GroupCalendar_cGnomerEventName = "Gnomeregan"
	GroupCalendar_cMaraEventName = "Maraudon"
	GroupCalendar_cMCEventName = "Cœur du Magma"
	GroupCalendar_cOnyxiaEventName = "Repaire d'Onyxia"
	GroupCalendar_cRFCEventName = "Gouffre de Ragefeu"
	GroupCalendar_cRFDEventName = "Souilles de Tranchebauge"
	GroupCalendar_cRFKEventName = "Kraal de Tranchebauge"
	GroupCalendar_cSMEventName = "Monastère Ecarlate"
	GroupCalendar_cScholoEventName = "Scholomance"
	GroupCalendar_cSFKEventName = "Ombreroc"
	GroupCalendar_cStockadesEventName = "La Prison"
	GroupCalendar_cStrathEventName = "Stratholme"
	GroupCalendar_cSTEventName = "Le Temple Englouti"
	GroupCalendar_cUldEventName = "Uldaman"
	GroupCalendar_cWCEventName = "Cavernes de Lamentations"
	GroupCalendar_cZFEventName = "Zul'Farrak"
	GroupCalendar_cZGEventName = "Zul'Gurub"
	GroupCalendar_cNaxxEventName = "Naxxramas"

	GroupCalendar_cTheEyeEventName = "L'Oeil du Cyclone"
	GroupCalendar_cSerpentshrineEventName = "Caverne du Sanctuaire du Serpent"
	GroupCalendar_cMagtheridonEventName = "Le Repaire de Magtheridon"
	GroupCalendar_cHyjalEventName = "Sommet Hyjal"
	GroupCalendar_cKarazhanEventName = "Karazhan"
	GroupCalendar_cZulAmanEventName = "Zul'Aman"
	GroupCalendar_cGruulEventName = "Le Repaire de Gruul"
	GroupCalendar_cBlackTempleEventName = "Le Temple Noir"

	GroupCalendar_cArcatrazEventName = "Tempête: L'Arcatraz"
	GroupCalendar_cBotanicaEventName = "Tempête: La Botanica"
	GroupCalendar_cMechanarEventName = "Tempête: Le Méchanar"

	GroupCalendar_cDurnholdeEventName = "GT: Fort-de-Durn"
	GroupCalendar_cDarkPortalEventName = "GT: Le Noir Marécage"

	GroupCalendar_cAuchenaiCryptsEventName = "Auchindoun: Crypte des Auchenaï"
	GroupCalendar_cSethekkHallsEventName = "Auchindoun: Salles de Sethekk"
	GroupCalendar_cShadowLabyrinthEventName = "Auchindoun: Labyrinthe des Ombres"
	GroupCalendar_cManaTombsEventName = "Auchindoun: Tombes-Mana"

	GroupCalendar_cSteamvaultEventName = "Glissecroc: Caveau de la Vapeur"
	GroupCalendar_cUnderbogEventName = "Glissecroc: Basse Tourbière"
	GroupCalendar_cSlavePensEventName = "Glissecroc: Enclos aux Esclaves"

	GroupCalendar_cShatteredHallsEventName = "CFI: Salles brisées"
	GroupCalendar_cFurnaceEventName = "CFI: Fournaise de sang"
	GroupCalendar_cRampartsEventName = "CFI: Remparts"

	GroupCalendar_cArcatrazHEventName = "Tempête: L'Arcatraz (Héroïque)"
	GroupCalendar_cBotanicaHEventName = "Tempête: La Botanica (Héroïque)"
	GroupCalendar_cMechanarHEventName = "Tempête: Le Méchanar (Héroïque)"

	GroupCalendar_cDurnholdeHEventName = "GT: Fort-de-Durn (Héroïque)"
	GroupCalendar_cDarkPortalHEventName = "GT: Le Noir Marécage (Héroïque)"

	GroupCalendar_cAuchenaiCryptsHEventName = "Auchindoun: Crypte des Auchenaï (Héroïque)"
	GroupCalendar_cSethekkHallsHEventName = "Auchindoun: Salles de Sethekk (Héroïque)"
	GroupCalendar_cShadowLabyrinthHEventName = "Auchindoun: Labyrinthe des Ombres (Héroïque)"
	GroupCalendar_cManaTombsHEventName = "Auchindoun: Tombes-Mana (Héroïque)"

	GroupCalendar_cSteamvaultHEventName = "Glissecroc: Caveau de la Vapeur (Héroïque)"
	GroupCalendar_cUnderbogHEventName = "Glissecroc: Basse Tourbière (Héroïque)"
	GroupCalendar_cSlavePensHEventName = "Glissecroc: Enclos aux Esclaves (Héroïque)"

	GroupCalendar_cShatteredHallsHEventName = "CFI: Salles brisées (Héroïque)"
	GroupCalendar_cFurnaceHEventName = "CFI: Fournaise de sang (Héroïque)"
	GroupCalendar_cRampartsHEventName = "CFI: Remparts (Héroïque)"

	GroupCalendar_cMagistersEventName = "Terrasse des Magistères"
	GroupCalendar_cMagistersHEventName = "Terrasse des Magistères (Héroïque)"
	GroupCalendar_cSunwellEventName = "Plateau du Puits de soleil"
	
	GroupCalendar_cPvPEventName = "PvP Général"
	GroupCalendar_cA2v2EventName = "Arène (2v2)"
	GroupCalendar_cA3v3EventName = "Arène (3v3)"
	GroupCalendar_cA5v5EventName = "Arène (5v5)"
	GroupCalendar_cABEventName = "Bassin d'Arathi"
	GroupCalendar_cAVEventName = "Vallée d'Alterac"
	GroupCalendar_cWSGEventName = "Goulet des Warsong"
	GroupCalendar_cEotSEventName = "L'Oeil de la Tempête"

	GroupCalendar_cDoomWalkerEventName = "Marche-Funeste"
	GroupCalendar_cDoomLordKazzakEventName = "Seigneur Funeste Kazzak"

	GroupCalendar_cZGResetEventName = "Zul'Gurub Resets"
	GroupCalendar_cMCResetEventName = "Cœur du Magma Resets"
	GroupCalendar_cOnyxiaResetEventName = "Onyxia Resets"
	GroupCalendar_cBWLResetEventName = "Repaire de l'Aile Noire Resets"
	GroupCalendar_cAQRResetEventName = "Ruines d'Ahn'Qiraj Resets"
	GroupCalendar_cAQTResetEventName = "Temple d'Ahn'Qiraj Resets"
	GroupCalendar_cNaxxResetEventName = "Naxxramas Resets"
	GroupCalendar_cKarazhanResetEventName = "Karazhan Resets"
	GroupCalendar_cZulAmanResetEventName = "Zul'Aman Resets"
	GroupCalendar_cBlackTempleResetEventName = "Le Temple Noir Resets"
	GroupCalendar_cTheEyeResetEventName = "L'Oeil du Cyclone Resets"
	GroupCalendar_cSerpentshrineResetEventName = "Sanctuaire du Serpent Resets"
	GroupCalendar_cMagtheridonResetEventName = "Magtheridon Resets"
	GroupCalendar_cHyjalResetEventName = "Sommet Hyjal Resets"
	GroupCalendar_cGruulResetEventName = "Gruul Resets"

	GroupCalendar_cTransmuteCooldownEventName = "Transmutation disponible"
	GroupCalendar_cSaltShakerCooldownEventName = "Tamis à sel disponible"
	GroupCalendar_cMoonclothCooldownEventName = "Etoffe lunaire disponible"
	GroupCalendar_cPrimalMoonclothCooldownEventName = "Etoffe lunaire primordiale disponible"
	GroupCalendar_cSpellclothCooldownEventName = "Etoffe ensorcelée disponible"
	GroupCalendar_cShadowclothCooldownEventName = "Etoffe d'ombre disponible"
	GroupCalendar_cSnowmasterCooldownEventName = "SnowMaster 9000 disponible"
	GroupCalendar_cBrilliantGlassCooldownEventName = "Brilliant Glass Available"
	GroupCalendar_cVoidShatterCooldownEventName = "Void Shatter Available"
	GroupCalendar_cVoidSphereCooldownEventName = "Void Sphere Available"

	GroupCalendar_cPersonalEventOwner = "Privé"

	GroupCalendar_cRaidInfoMCName = GroupCalendar_cMCEventName
	GroupCalendar_cRaidInfoOnyxiaName = GroupCalendar_cOnyxiaEventName
	GroupCalendar_cRaidInfoZGName = GroupCalendar_cZGEventName
	GroupCalendar_cRaidInfoBWLName = GroupCalendar_cBWLEventName
	GroupCalendar_cRaidInfoAQRName = GroupCalendar_cAQREventName
	GroupCalendar_cRaidInfoAQTName = GroupCalendar_cAQTEventName
	GroupCalendar_cRaidInfoNaxxName = GroupCalendar_cNaxxEventName
	GroupCalendar_cRaidInfoKarazhanName = GroupCalendar_cKarazhanEventName
	GroupCalendar_cRaidInfoZulAmanName = GroupCalendar_cZulAmanEventName

	-- Race names

	GroupCalendar_cDwarfRaceName = "Nain"
	GroupCalendar_cGnomeRaceName = "Gnome"
	GroupCalendar_cHumanRaceName = "Humain"
	GroupCalendar_cNightElfRaceName = "Elfe de la Nuit"
	GroupCalendar_cOrcRaceName = "Orc"
	GroupCalendar_cTaurenRaceName = "Tauren"
	GroupCalendar_cTrollRaceName = "Troll"
	GroupCalendar_cUndeadRaceName = "Mort-vivant"
	GroupCalendar_cBloodElfRaceName = "Elfe de Sang"
	GroupCalendar_cDraeneiRaceName = "Draenei"

	-- Class names

	GroupCalendar_cFemaleDruidClassName = "Druidesse"
	GroupCalendar_cMaleDruidClassName = "Druide"
	GroupCalendar_cFemaleHunterClassName = "Chasseresse"
	GroupCalendar_cMaleHunterClassName = "Chasseur"
	GroupCalendar_cFemaleMageClassName = "Mage"
	GroupCalendar_cMaleMageClassName = "Mage"
	GroupCalendar_cFemalePaladinClassName = "Paladin"
	GroupCalendar_cMalePaladinClassName = "Paladin"
	GroupCalendar_cFemalePriestClassName = "Prêtresse"
	GroupCalendar_cMalePriestClassName = "Prêtre"
	GroupCalendar_cFemaleRogueClassName = "Voleuse"
	GroupCalendar_cMaleRogueClassName = "Voleur"
	GroupCalendar_cFemaleShamanClassName = "Chamane"
	GroupCalendar_cMaleShamanClassName = "Chaman"
	GroupCalendar_cFemaleWarlockClassName = "Démoniste"
	GroupCalendar_cMaleWarlockClassName = "Démoniste"
	GroupCalendar_cFemaleWarriorClassName = "Guerrière"
	GroupCalendar_cMaleWarriorClassName = "Guerrier"


	-- Plural forms of class names

	GroupCalendar_cDruidsClassName = "Druides"
	GroupCalendar_cHuntersClassName = "Chasseurs"
	GroupCalendar_cMagesClassName = "Mages"
	GroupCalendar_cPaladinsClassName = "Paladins"
	GroupCalendar_cPriestsClassName = "Prêtres"
	GroupCalendar_cRoguesClassName = "Voleurs"
	GroupCalendar_cShamansClassName = "Chamans"
	GroupCalendar_cWarlocksClassName = "Démonistes"
	GroupCalendar_cWarriorsClassName = "Guerriers"

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

	-- Label forms of the class names for the attendance panel. Usually just the plural
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

	GroupCalendar_cTimeLabel = "Temps:"
	GroupCalendar_cDurationLabel = "Durée:"
	GroupCalendar_cEventLabel = "Evénement:"
	GroupCalendar_cTitleLabel = "Titre:"
	GroupCalendar_cLevelsLabel = "Niveaux:"
	GroupCalendar_cLevelRangeSeparator = "à"
	GroupCalendar_cDescriptionLabel = "Description:"
	GroupCalendar_cCommentLabel = "Commentaire:"

	CalendarEditor_cNewEvent = "Nouvel événement"
	CalendarEditor_cEventsTitle = "Evénement"

	CalendarEvent_cNotAttending = "Ne viens pas"
	CalendarEvent_cConfirmed = "Confirmé"
	CalendarEvent_cDeclined = "Decliné"
	CalendarEvent_cStandby = "En attente"
	CalendarEvent_cPending = "En suspens"
	CalendarEvent_cUnknownStatus = "Inconnu %s"

	GroupCalendar_cChannelNameLabel = "Nom de canal:"
	GroupCalendar_cPasswordLabel = "Mot de passe:"

	GroupCalendar_cSingleTimeDateFormat = "%s  %s"
	GroupCalendar_cTimeDateRangeFormat = "%s  %s à %s"

	GroupCalendar_cPluralMinutesFormat = "%d minutes"
	GroupCalendar_cSingularHourFormat = "%d heure"
	GroupCalendar_cPluralHourFormat = "%d heures"
	GroupCalendar_cSingularHourPluralMinutes = "%d heure %d minutes"
	GroupCalendar_cPluralHourPluralMinutes = "%d heures %d minutes"

	GroupCalendar_cLongDateFormat = "$day. $month $year"
	GroupCalendar_cLongDateFormatWithDayOfWeek = "$dow $day. $month $year"

	GroupCalendar_cNotAttendingCategory = "Ne viens pas"
	GroupCalendar_cAttendingCategory = "Viens"
	GroupCalendar_cPendingApprovalCategory = "Attente d\'approbation"
	GroupCalendar_cStandbyCategory = "En attente"
	GroupCalendar_cMaybeCategory = "Peut-être"
	GroupCalendar_cWhispersCategory = "Chuchotements récents"
	GroupCalendar_cBannedCategory = "Enlevé"

	GroupCalendar_cNumAttendeesFormat = "%d participants"
	GroupCalendar_cTotalNumPlayersFormat = "%s joueurs"

	BINDING_HEADER_GROUPCALENDAR_TITLE = "Group Calendar"
	BINDING_NAME_GROUPCALENDAR_TOGGLE = "GroupCalendar [ON/OFF]"

	-- Tradeskill cooldown items

	GroupCalendar_cHerbalismSkillName = "Herboristerie"
	GroupCalendar_cAlchemySkillName = "Alchimie"
	GroupCalendar_cEnchantingSkillName = "Enchantement"
	GroupCalendar_cLeatherworkingSkillName = "Travail du cuir"
	GroupCalendar_cSkinningSkillName = "Dépeçage"
	GroupCalendar_cTailoringSkillName = "Couture"
	GroupCalendar_cMiningSkillName = "Minage"
	GroupCalendar_cBlacksmithingSkillName = "Forge"
	GroupCalendar_cEngineeringSkillName = "Ingénierie"

	GroupCalendar_cTransmuteMithrilToTruesilver = "Transmutation: Mithril en vrai-argent"
	GroupCalendar_cTransmuteIronToGold = "Transmutation: Fer en Or"
	GroupCalendar_cTransmuteLifeToEarth = "Transmutation: Vie en Terre"
	GroupCalendar_cTransmuteWaterToUndeath = "Transmutation: Eau en Non-mort"
	GroupCalendar_cTransmuteWaterToAir = "Transmutation: Eau en Air"
	GroupCalendar_cTransmuteUndeathToWater = "Transmutation: Non-mort en Eau"
	GroupCalendar_cTransmuteFireToEarth = "Transmutation: Feu en Terre"
	GroupCalendar_cTransmuteEarthToLife = "Transmutation: Terre en Vie"
	GroupCalendar_cTransmuteEarthToWater = "Transmutation: Terre en Eau"
	GroupCalendar_cTransmuteAirToFire = "Transmutation: Air en Feu"
	GroupCalendar_cTransmuteArcanite = "Transmutation d'arcanite"
	GroupCalendar_cTransmuteAirToFire = "Transmutation de l'Air en Feu"
	GroupCalendar_cTransmutePrimalAirToFire = "Transmutation primordiale : Air en Feu"
	GroupCalendar_cTransmutePrimalFireToEarth = "Transmutation primordiale : Feu en Terre"
	GroupCalendar_cTransmutePrimalEarthToWater = "Transmutation primordiale : Terre en Eau"
	GroupCalendar_cTransmutePrimalWaterToAir = "Transmutation primordiale : Eau en Air"
	GroupCalendar_cTransmutePrimalEarthToLife = "Transmutation primordiale : Terre en Vie"
	GroupCalendar_cTransmutePrimalLifeToEarth= "Transmutation primordiale : Vie en Terre"
	GroupCalendar_cTransmutePrimalFireToMana = "Transmutation primordiale : Feu en Mana"
	GroupCalendar_cTransmutePrimalManaToFire = "Transmutation primordiale : Mana en Feu"
	GroupCalendar_cTransmutePrimalShadowToWater = "Transmutation primordiale : Ombre en Eau"
	GroupCalendar_cTransmutePrimalWaterToShadow = "Transmutation primordiale : Eau en Ombre"
	GroupCalendar_cTransmutePrimalMight = "Transmutation primordiale : Pouvoir"
	GroupCalendar_cTransmuteEarthstormDiamond = "Transmutation: Diamant tonneterre"
	GroupCalendar_cTransmuteSkyfireDiamond = "Transmutation: Diamant brûleciel"

	GroupCalendar_cMooncloth = "Etoffe lunaire"
	GroupCalendar_cPrimalMooncloth = "Etoffe lunaire primordiale"
	GroupCalendar_cSpellcloth = "Etoffe ensorcelée"
	GroupCalendar_cShadowcloth = "Etoffe d'ombre"

	GroupCalendar_cBrilliantGlass = "Brilliant Glass"
	GroupCalendar_cVoidShatter = "Void Shatter"
	GroupCalendar_cVoidSphere = "Void Sphere"

	GroupCalendar_cCharactersLabel = "Personnage:"

	GroupCalendar_cConfirmed = "Accepté"
	GroupCalendar_cStandby = "En attente"
	GroupCalendar_cMaybe = "Peut-être"
	GroupCalendar_cDeclined = "Refusé"
	GroupCalendar_cRemove = "Enlevé"
	GroupCalendar_cEditPlayer = "Editer le joueur..."
	GroupCalendar_cInviteNow = "Grouper"
	GroupCalendar_cStatus = "Statut"
	GroupCalendar_cAddPlayerEllipses = "Ajoute le joueur..."

	GroupCalendar_cAddPlayer = "Ajoute joueur"
	GroupCalendar_cPlayerLevel = "Niveau:"
	GroupCalendar_cPlayerClassLabel = "Classe:"
	GroupCalendar_cPlayerRaceLabel = "Race:"
	GroupCalendar_cPlayerStatusLabel = "Statut:"
	GroupCalendar_cRankLabel = "Grade dans la guilde:"
	GroupCalendar_cGuildLabel = "Guilde:"
	GroupCalendar_cSave = "Sauvegarde"
	GroupCalendar_cLastWhisper = "Dernier chuchotement:"
	GroupCalendar_cReplyWhisper = "Réponse chuchotement:"

	GroupCalendar_cUnknown = "Inconnu"

	GroupCalendar_cAutoConfirmationTitle = "Confirmations automatiques par classe"
	GroupCalendar_cRoleConfirmationTitle = "Confirmations automatiques par rôle"
	GroupCalendar_cManualConfirmationTitle = "Confirmations manuelles"

	GroupCalendar_cClosedEventTitle = "Evénement clos"
	GroupCalendar_cMinLabel = "min"
	GroupCalendar_cMaxLabel = "max"

	GroupCalendar_cAddPlayerTitle = "Ajouter"
	GroupCalendar_cAutoConfirmButtonTitle = "Paramètre..."

	GroupCalendar_cClassLimitDescription = "Utilisez les champs ci dessous pour définir les minimums et maximums pour chaque classe. Les classes n'ayant pas atteint leur minimum seront remplie en premier, les places suivantes seront remplies par ordre de réponse."

	GroupCalendar_cViewGroupBy = "Grouper par"
	GroupCalendar_cViewByStatus = "Statut"
	GroupCalendar_cViewByClass = "Classe"
	GroupCalendar_cViewByRole = "Rôle"
	GroupCalendar_cViewSortBy = "Trier par"
	GroupCalendar_cViewByDate = "Date"
	GroupCalendar_cViewByRank = "Rang"
	GroupCalendar_cViewByName = "Nom"

	GroupCalendar_cMaxPartySizeLabel = "Taille Maximum du groupe:"
	GroupCalendar_cMinPartySizeLabel = "Taille Minimum du groupe:"
	GroupCalendar_cNoMinimum = "Pas de minimum"
	GroupCalendar_cNoMaximum = "Pas de maximum"
	GroupCalendar_cPartySizeFormat = "%d joueurs"

	GroupCalendar_cInviteButtonTitle = "Inviter sélection"
	GroupCalendar_cAutoSelectButtonTitle = "Joueur sélectionné..."
	GroupCalendar_cAutoSelectWindowTitle = "Joueurs sélectionnés"

	GroupCalendar_cNoSelection = "Pas de joueur sélectionné"
	GroupCalendar_cSingleSelection = "1 joueur sélectionné"
	GroupCalendar_cMultiSelection = "%d joueurs sélectionnés"

	GroupCalendar_cInviteNeedSelectionStatus = "Sélectionnez les joueurs à inviter"
	GroupCalendar_cInviteReadyStatus = "Prêt à inviter"
	GroupCalendar_cInviteInitialInvitesStatus = "Envoyer les invitations initiales"
	GroupCalendar_cInviteAwaitingAcceptanceStatus = "En attente de l'acceptation initiale"
	GroupCalendar_cInviteConvertingToRaidStatus = "Changement en raid"
	GroupCalendar_cInviteInvitingStatus = "Envoi des invitations"
	GroupCalendar_cInviteCompleteStatus = "Invitations terminées"
	GroupCalendar_cInviteReadyToRefillStatus = "Prêt à remplir les places vacantes"
	GroupCalendar_cInviteNoMoreAvailableStatus = "Plus de joueurs disponibles pour remplir les places vacantes"
	GroupCalendar_cRaidFull = "Raid complet"

	GroupCalendar_cInviteWhisperFormat = "[GroupCalendar] Vous êtes invité à l\'événement '%s'. Svp acceptez l\'invitation, si vous souhaitez participer à l'événement."
	GroupCalendar_cAlreadyGroupedWhisper = "[GroupCalendar] Vous êtes déjà dans un groupe. Svp /w de nouveau quand vous avez quitté votre groupe."

	GroupCalendar_cJoinedGroupStatus = "Groupé"
	GropuCalendar_cInvitedGroupStatus = "Invité"
	GropuCalendar_cReadyGroupStatus = "Prêt"
	GroupCalendar_cGroupedGroupStatus = "Dans un autre groupe"
	GroupCalendar_cStandbyGroupStatus = "En attente"
	GroupCalendar_cMaybeGroupStatus = "Peut-être"
	GroupCalendar_cDeclinedGroupStatus = "Refuse l\'invitation"
	GroupCalendar_cOfflineGroupStatus = "Hors ligne"
	GroupCalendar_cLeftGroupStatus = "Quitte le groupe"

	GroupCalendar_cPriorityLabel = "Priorité:"
	GroupCalendar_cPriorityDate = "Date"
	GroupCalendar_cPriorityRank = "Rang"

	GroupCalendar_cConfirmSelfUpdateMsg = "%s"
	GroupCalendar_cConfirmSelfUpdateParamFormat = "Changes have been made to the events for $mUserName from another computer.  If you use multiple computers or you crashed or re-installed the game then you should choose Accept to restore your events.  Choose Delete if you believe changes should not have been made from another computer."
	GroupCalendar_cConfirmSelfRSVPUpdateParamFormat = "Changes have been made to the attendance requests for $mUserName from another computer.  If you use multiple computers or you crashed or re-installed the game then you should choose Accept to restore your attendance requests.  Choose Delete if you believe changes should not have been made from another computer."
	GroupCalendar_cUpdate = "Mise à jour"


	GroupCalendar_cConfirmClearWhispers = "Supprimer les chuchotements récents?"
	GroupCalendar_cClear = "Supprimer"

	CalendarDatabases_cTitle = "Group Calendar Versions"
	CalendarDatabases_cRefresh = "Rafraîchir"
	CalendarDatabases_cRefreshDescription = "Requests online players to send their version numbers. It may take several minutes for version numbers to update. Updates received while this window is closed will still be recorded and can be viewed at a later time."

	GroupCalendar_cVersionFormat = "Group Calendar v%s"
	GroupCalendar_cShortVersionFormat = "v%s"
	GroupCalendar_cVersionUpdatedFormat = "as of %s %s (local time)"
	GroupCalendar_cVersionUpdatedUnknown = "Date version info was last seen is unknown"

	GroupCalendar_cToggleVersionsTitle = "Affiche les versions des joueurs"
	GroupCalendar_cToggleVersionsDescription = "Affiche la version de Group Calendar des autres joueurs connectés"

	GroupCalendar_cChangesDelayedMessage = "Group Calendar: Les changements effectués durant la synchronisation avec le réseau ne seront pas envoyés avant que la synchronisation ne soit complète."

	GroupCalendar_cConfirmKillMsg = "Etes-vous sûr de vouloir forcer les événements de %s sur le réseau?"
	GroupCalendar_cKill = "Forcer"

	GroupCalendar_cNotAnOfficerError = "GroupCalendar: Seulement les officiers sont autorisés à faire ça."
	GroupCalendar_cUserNameExpected = "GroupCalendar: Nom d'utilisateur demandé"
	GroupCalendar_cDatabaseNotFoundError = "GroupCalendar: Base de données pour %s non trouvée."
	GroupCalendar_cCantKillGuildieError = "GroupCalendar: Vous ne pouvez pas supprimer un joueur qui n'est pas dans votre guilde."

	GroupCalendar_cTooltipScheduleItemFormat = "%s (%s)"

	GroupCalendar_cAvailableMinutesFormat = "%s dans %d minutes"
	GroupCalendar_cStartsMinutesFormat = "%s commence dans %d minutes"
	GroupCalendar_cStartingNowFormat = "%s commence maintenant"
	GroupCalendar_cAlreadyStartedFormat = "%s a déjà commencé"
	GroupCalendar_cHappyBirthdayFormat = "Joyeux anniversaire %s!"

	GroupCalendar_cTimeRemainingFormat = "(%d:%02d restant)"

	GroupCalendar_cNone = "Aucun"

	GroupCalendar_cConfirmResetMsg = "Etes-vous certain de vouloir réinitialiser le calendrier pour %S? Tous les événements de ce personnage seront effacés."
	GroupCalendar_cConfirmResetRealmMsg = "Etes-vous certain de vouloir réinitialiser le calendrier de tous vos personnages sur %s? Tous les événements seront effacés pour tous vos personnages sur ce serveur."
	GroupCalendar_cConfirmResetAllMsg = "Etes-vous certain de vouloir réinitialiser le calendrier de tous vos personnages sur tous les royaumes? Tous les événements seront effacés pour tous vos personnages sur tous les serveurs."
	GroupCalendar_cReset = "Réinitialiser"

	GroupCalendar_cAttendanceNote = "You have changed your attendance status for %s.  Please allow one minute before logging off to ensure your request is forwarded to the network.  Your status will show as Pending until the event creator logs on."
	GroupCalendar_cUnknownClockOption = "Option horloge inconnue"
	GroupCalendar_cBadAgeValue = "The maximum event age must be between 1 and 60 days"
	GroupCalendar_cViewMenuFormat = "Afficher par %s/%s"
	GroupCalendar_cDefaultTimeFormat = 12
	GroupCalendar_cDefaultStartDay = "Dimanche"
	GroupCalendar_cForeignRealmFormat = "%s de %s"

	GroupCalendar_cMHRole = "Soigneur"
	GroupCalendar_cOHRole = "Soigneur secondaire"
	GroupCalendar_cMTRole = "Tank"
	GroupCalendar_cOTRole = "Tank secondaire"
	GroupCalendar_cRDRole = "DPS Distant"
	GroupCalendar_cMDRole = "Mêlée"

	GroupCalendar_cMHPluralRole = "Soigneurs"
	GroupCalendar_cOHPluralRole = "Soigneurs secondaires"
	GroupCalendar_cMTPluralRole = "Tanks"
	GroupCalendar_cOTPluralRole = "Tank secondaires"
	GroupCalendar_cRDPluralRole = "DPS Distants"
	GroupCalendar_cMDPluralRole = "Mêlées"

	GroupCalendar_cMHPluralLabel = GroupCalendar_cMHPluralRole..":"
	GroupCalendar_cOHPluralLabel = GroupCalendar_cOHPluralRole..":"
	GroupCalendar_cMTPluralLabel = GroupCalendar_cMTPluralRole..":"
	GroupCalendar_cOTPluralLabel = GroupCalendar_cOTPluralRole..":"
	GroupCalendar_cRDPluralLabel = GroupCalendar_cRDPluralRole..":"
	GroupCalendar_cMDPluralLabel = GroupCalendar_cMDPluralRole..":"

	GroupCalendar_cConfirmDeleteRSVP = "Etes-vous certain de vouloir retirer %s de la liste?"

	GroupCalendar.cAttendanceNoticeYes = "$name sera présent pour $event"
	GroupCalendar.cAttendanceNoticeLimitStandby = "Putting $name on standby for $event: Class or role limit already reached"
	GroupCalendar.cAttendanceNoticeStandby = "$name sera disponible en tant que joueur en attente pour $event"
	GroupCalendar.cAttendanceNoticeNo = "$name ne sera pas présent pour $event"
	GroupCalendar.cAttendanceNoticeBanned = "Discarding request from $name for $event: Player was banned from the event"
	GroupCalendar.cAttendanceNoticeManual = "Putting $name on standby for $event: Event requires you to confirm attendees"
	GroupCalendar.cAttendanceUnknownQualifiedError = "You are not qualified for this event, but the software did not report a reason"
	GroupCalendar.cAttendanceNoticeMaybe = "$name might be attending $event on $date"

	GroupCalendar.cAttendanceClosedEvent = "The event or a closed event -- all players must be manually added by the owner"
	GroupCalendar.cAttendanceUnknownLevel = "L'événement a des restrictions de niveau et votre niveau est inconnu"
	GroupCalendar.cAttendanceLevelTooLow = "Votre niveau est trop bas pour cet événement"
	GroupCalendar.cAttendanceLevelTooHigh = "Votre niveau est trop haut pour cet événement"
	GroupCalendar.cAttendanceGuildMembersOnly = "Cet événement est seulement pour les membres de <%s>"
	GroupCalendar.cAttendanceRankTooLow = "Votre rang de guilde est trop bas pour s'inscrire à cet événement"
	GroupCalendar.cAttendanceNotAllowed = "Vous n'êtes pas autorisé à accéder à ce calendrier"
	GroupCalendar.cAttendanceSynching = "Group Calendar est en train de se synchroniser avec le réseau. Essayez de nouveau dans quelques minutes."

	GroupCalendar.cNewerVersionMessage = "Une nouvelle version est disponible (%s)"

	GroupCalendar.cBackupTitle = "Sauvegarde et restauration"
	GroupCalendar.cNoBackups = "Aucune sauvegarde n'a encore été faite. Une sauvegarde sera faite automatiquement si votre calendrier est modifié sur un autre ordinateur, ou vous pouvez utiliser le bouton 'Sauvegarder'."
	GroupCalendar.cBackupNow = "Sauvegarder"
	GroupCalendar.cBackupNowDescription = "Enregistre une copie des événements du %s."
	GroupCalendar.cConfirmDeleteBackup = "Etes-vous certain de vouloir supprimer la sauvegarde du %s ?"
	GroupCalendar.cConfirmRestoreBackup = "Etes-vous certain de vouloir restaurer la sauvegarde du %s ?"
	GroupCalendar.cRestoreBackup = "Restaurer"
	GroupCalendar.cBackupRestored = "La sauvegarde a été restaurée. Les événements restaurés apparaîtront pour les autres joueurs dans une à deux minutes."

	GroupCalendar.cNetworkSyncComplete = "Network synchronization completed"
end