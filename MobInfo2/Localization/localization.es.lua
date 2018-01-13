--
-- Spanish localization for MobInfo
--
-- original version by an anonymous benefactor
-- updates kindly submitted by FILI
-- updates kindly submitted by AlbertQ
--

if ( MI2_Locale == "esES" ) then
--if ( MI2_Locale == "deDE" ) then

MI2_SpellSchools = { Arcana="ar", Fuego="fi", Frost="fr", Sombra="sh", Holy="ho", Naturaleza="na" }

MI_TXT_WELCOME          = "Bienvenido a MobInfo";
MI_DESCRIPTION = "A\195\177ade informaci\195\179n sobre mobs para el tooltip y a\195\177ade la informaci\195\179n salud/man\195\161 al marco del objetivo";
MI_TXT_GENERAL_OPTIONS	= "This Options Page controls the main functions of the MobInfo AddOn. The other options pages allow configuring the details for each feature."

MI_PARSE_SPELL_DMG = "(.+) de (.+) te golpea por (%d+)";
MI_PARSE_BOW_DMG = "(.+) de (.+) te golpea por (%d+)";
MI_PARSE_COMBAT_DMG = "(.+) te golpea por (%d+)";
MI_PARSE_SELF_PET = "(.+) golpea (.+) por (%d+)";
MI_PARSE_SELF_PET_CRIT = "(.+) hace critico (.+) por (%d+)";
MI_PARSE_SELF_PET_SPELL = "(.+) de (.+) golpea a (.+) por (%d+)";
MI_PARSE_SELF_PET_SPELL_CRIT = "(.+) de (.+) hace critico a (.+) por (%d+)";
MI_PARSE_SELF_SPELL_PERIODIC = "(.+) sufre (%d+) (.+) de da\195\177o hacia tu (.+)";

MI_TXT_GOLD   = " Oro";
MI_TXT_SILVER = " Plata";
MI_TXT_COPPER = " Bronce";

MI_TXT_OPEN				= "Abrir";
MI_TXT_COMBINED			= "Combinado: ";
MI_TXT_MOB_DB_SIZE		= "Tama\195\177o BD de MobInfo:  ";
MI_TXT_HEALTH_DB_SIZE	= "Tama\195\177o BD de Salud:  ";
MI_TXT_PLAYER_DB_SIZE	= "Tama\195\177o BD de Salud del Jugador:  ";
MI_TXT_ITEM_DB_SIZE		= "Tama\195\177o BD de objetos:  ";
MI_TXT_CUR_TARGET		= "Objetivo actual:  ";
MI_TXT_MH_DISABLED		= "MobInfo ADVERTENCIA: Encontrado el AddOn MobHealth separado. El MobHealth interno se ha desactivado hasta que se borre el MobHealth separado.";
MI_TXT_MH_DISABLED2		= (MI_TXT_MH_DISABLED.."\n\n No vas a perder tus datos por activar MobHealth.\n\nBeneficios: salud/man\195\161 movibles y adaptados fuente y tama\195\177o");
MI_TXT_CLR_ALL_CONFIRM	= "¿Realmente quieres realizar la siguiente operaci\195\179n de borrado?: ";
MI_TXT_SEARCH_LEVEL		= "Nivel Mob:";
MI_TXT_SEARCH_MOBTYPE	= "Tipo de Mob:";
MI_TXT_SEARCH_LOOTS		= "Saqueo Mob:";
MI_TXT_TRIM_DOWN_CONFIRM = "ADVERTENCIA: esto es un borrado inmediato y permanente. ¿Realmente quieres realizar el borrado?"
MI_TXT_CLAM_MEAT		= "Carne de Almeja"
MI_TXT_SHOWING			= "Muestra lista: "
MI_TXT_DROPPED_BY		= "Saqueado por "
MI_TXT_IMMUNE			= "Inmune:"
MI_TXT_RESIST			= "Resist:"
MI_TXT_DEL_SEARCH_CONFIRM = "\194\191Realmente deseas ELIMINAR los %d Mobs en la lista de resultados de la b\195\186ssqueda de la Base de Datos de MobInfo ?"
MI_TXT_WRONG_LOC		= "ERROR : La localizaci\195\179n de la base de datos de MobInfo no es compatible con tu localizaci\195\179n de cliente de WoW. La Base de Datos no se puede usar hasta que se corija."
MI_TXT_WRONG_DBVER		= "ERROR : Your MobInfo database is too old and not compatible with this version of MobInfo.\n\nMobInfo must delete all your old Mob data."
MI_TXT_PRICE			= "Precio Vendedor por "
MI_TXT_TOOLTIP_MOVE		= "To move the tooltip anchor simply\nclick&drag it to a new location on screen"
MI_TXT_ITEMFILTER		= "Filtrar Objetos"

MI2_CHAT_MOBRUNS = "intentos de huida"
MI2_TXT_MOBRUNS = "*huida*"

BINDING_HEADER_MI2HEADER	= "MobInfo"
BINDING_NAME_MI2CONFIG	= "Abrir opciones de MobInfo"

MI2_FRAME_TEXTS = {};
MI2_FRAME_TEXTS["MI2_FrmTooltipContent"]	= "Opciones cuadro de texto de Mob";
MI2_FRAME_TEXTS["MI2_FrmHealthOptions"]		= "Opciones de MobHealth";
MI2_FRAME_TEXTS["MI2_FrmDatabaseOptions"]	= "Opciones de Base de Datos";
MI2_FRAME_TEXTS["MI2_FrmHealthValueOptions"]= "Valor de Salud";
MI2_FRAME_TEXTS["MI2_FrmManaValueOptions"]	= "Valor de Man\195\161";
MI2_FRAME_TEXTS["MI2_FrmSearchOptions"]		= "Opciones de b\195\186squeda";
MI2_FRAME_TEXTS["MI2_FrmImportDatabase"]	= "Importa Base de Datos externa de MobInfo"
MI2_FRAME_TEXTS["MI2_FrmItemTooltip"]		= "Opciones Cuadro de Texto de Objeto";
MI2_FRAME_TEXTS["MI2_FrmTooltipLayout"]		= "MobInfo Tooltip Layout"


---------------------------
-- Tooltip Options/Content
---------------------------

MI_TXT_HEALTH		= "Vida"
MI_HLP_HEALTH		= "Muestra info de la vida del mob (actual/max)"
MI_TXT_MANA			= "Man\195\161"
MI_HLP_MANA			= "Muestra informaci\195\179n de man\195\161/furia/energ\195\173a del Mob (actual/max)"
MI_TXT_KILLS		= "Muertes"
MI_HLP_KILLS		= "Muestra el n\195\186mero de veces que matastaste al Mob\nEl conteo de muertes es calculado y almacenado\nseparadamente por personaje"
MI_TXT_LOOTS		= "Saqueos"
MI_HLP_LOOTS		= "Muestra el n\195\186mero de veces que un Mob ha sido saqueado"
MI_TXT_COINS		= "V-Dinero"
MI_HLP_COINS		= "Muestra la mejor cantidad de monedas arrojada por un Mob\nEl valor total de monedas es acumulado y dividido\npor el contador de saqueos.\n(no se muestra si el valor de moneda es 0)"
MI_TXT_ITEMVAL		= "V-Objeto"
MI_HLP_ITEMVAL		= "Muestra el mayor valor de objeto de Mob\nEl valor total de objetos es acumulable\npor el contador de saqueo.\n(no se muestra con valor 0)"
MI_TXT_MOBVAL		= "Valor"
MI_HLP_MOBVAL		= "Muestra mayor valor total de Mob\nEsta es la suma del dinero y\nel valor de objetos"
MI_TXT_XP			= "Exp"
MI_HLP_XP			= "Muestra el n\195\186mero de puntos de experiencia que obtuviste de este\nEsta es la ultima y actual experiencia que te dio el mob.\n(no se muestran los Mobs que son grises para ti)"
MI_TXT_TO_LEVEL		= "# Nivel"
MI_HLP_TO_LEVEL		= "Muestra el n\195\186mero de muertes necesarias para subir un nivel\nEste te indica cuantas veces tienes que matar al\nmismo Mob recien matado para alcanzar el siguiente nivel\n(no se muestran los Mobs que son grises para ti)"
MI_TXT_EMPTY_LOOTS	= "Vac\195\173os"
MI_HLP_EMPTY_LOOTS	= "Muestra el n\195\186mero de cuerpos vac\195\173os encontrados (n\195\186m/porcentaje)\nEste contador se incrementa cuando abres\n un cuerpo que no tiene nada"
MI_TXT_CLOTH_DROP	= "Telas"
MI_HLP_CLOTH_DROP	= "Muestra cuantas veces has obtenido telas en el saqueo"
MI_TXT_CLASS		= "Clase"
MI_HLP_CLASS		= "Muestra la clase del Mob"
MI_TXT_DAMAGE		= "Da\195\177o"
MI_HLP_DAMAGE		= "Muestra rango de da\195\177o Mob (Min/Max) y DPS (da\195\177o por segundo)\nRango de da\195\177o y DPS es calculado y almacenado separadamente por personaje.\nDPS se actualizan y guardan lentamente despu\195\169s de cada pelea"
MI_TXT_QUALITY		= "Objeto"
MI_HLP_QUALITY		= "Muestra la calidad del saqueo y porcentaje\nEsto cuenta cuantos objetos de las 5 categorias de calidad\nte ha dado un Mob al saquearlo. Categorias con 0 arrojado no\nse muestran. El porcentaje es la posibilidad de conseguir\nun objeto de un monstruo de la rareza especifica como saqueo"
MI_OPT_QUALITY		= "Loot Items Summary"
MI_TXT_LOCATION		= "Loc"
MI_HELP_LOCATION	= "Muestra la localizaci\195\179n de donde esta el Mob\nGuardar datos debe ser ACTIVADO para que funcione"
MI_TXT_LOWHEALTH	= "Runaway Mob Indicator"
MI_HELP_LOWHEALTH	= "Show indicator for Mobs that run when low on health\nThe indicator is a red message line that gets shown\nin the tooltip for the runaway Mobs only"
MI_OPT_RESISTS		= "Resistencias e Inmunidades"
MI_TXT_RESISTS		= "Resist"
MI_TXT_IMMUN		= "Immun"
MI_HELP_RESISTS		= "Muestra las resistencias e inmunidades en el Cuadro de Texto\nDatos almacenados sobre las resistencias \195\179 inmunidades\nde la escuela de magia elemental del enemigo\nson a\195\177adidos al Cuadro de Texto"
MI_TXT_ITEMLIST		= "Detalles del saqueo"
MI_HELP_ITEMLIST	= "Muestra nombre y cantidad de los objetos del saqueo\nGuardar datos de objetos saqueo debe estar ACTIVADO para que funcione"
MI_TXT_CLOTHSKIN	= "Saqueo Tela y Pieles"
MI_HELP_CLOTHSKIN	= "Muestra nombres y cantidad de saqueos de tela y pieles\nGuardar datos de objetos saqueo debe estar ACTIVADO para que funcione"


--------------------
-- General Options
--------------------
MI2_OPTIONS = {};

MI2_OPTIONS["MI2_OptSaveBasicInfo"] = 
{ text = "Record and Store Detailed Information About Mobs";
help = "This option enables or disabled the resording of detailed data\nabout the Mobs that you meet and kill in game. This data can be\nused to show mob details in the tooltip, or to search for Mobs\nusing the MobInfo search tool. The data also allows showing detailed\n'Dropped By' info for items.\n\nDisable this option if you do not want MobInfo to record and store\nMob data in the MobInfo database. Note that (only) the Mob health\ndata will always be calculated and stored, even when disabling this\noptions." }

MI2_OPTIONS["MI2_OptShowMobInfo"] = 
{ text = "Show Mob Information in the MobInfo Tooltip"; 
help = "Activates the showing of Mob information in the MobInfo Tooltip.\nUse the Tooltip options page to choose what information to show.\nDisable this option if you do not want to see Mob information\nor the MobInfo tooltip." }

MI2_OPTIONS["MI2_OptUseGameTT"] = 
{ text = "Instead of MobInfo-Tooltip use the Game-Tooltip"; 
help = "MobInfo features its very own optimally layouted movable tooltip window,\nwhich is used by default.\nActivating this option uses the Game-Tooltip\ninstead of the MobInfo tooltip window for showing the Mob information.\nThis will disable the MobInfo tooltip window." }

MI2_OPTIONS["MI2_OptShowItemInfo"] = 
{ text = "Show Additional Item Information in the Item Tooltip"; 
help = "Activates the showing of item information in the iem Tooltip.\nUse the Tooltip options page to choose what information to show.\nDisable this option if you do not want MobInfo to add anything\nto the item tooltip."; }

MI2_OPTIONS["MI2_OptShowTargetInfo"] = 
{ text = "Show Mob Info in Target Frame (Health/Mana/etc)"; 
help = "Show info like Health or Mana values in the Mob Target Frame.\n(this works only when not using a so called unit frame AddOn)\nUse the Target options page to configure what to show where.\n\nDisable this option if you do not want MobInfo to show information\nin the mob target frame." }

MI2_OPTIONS["MI2_OptShowMMButton"] = 
{ text = "Show Minimap Button"; 
help = "Show / Hide the MobInfo minimap button" }

MI2_OPTIONS["MI2_OptMMButtonPos"] = 
{ text = "Minimap Button Position"; 
help = "Use the slider to change the position of the MobInfo minimap button" }


--------------------
-- Other Options
--------------------

MI2_OPTIONS["MI2_OptShowIGrey"] = 
{ text = ""; help = "Show grey (poor) loot items in the tooltip" }

MI2_OPTIONS["MI2_OptShowIWhite"] = 
{ text = ""; help = "Show white (common) loot items in the tooltip" }

MI2_OPTIONS["MI2_OptShowIGreen"] = 
{ text = ""; help = "Show green (uncommon) loot items in the tooltip" }

MI2_OPTIONS["MI2_OptShowIBlue"] = 
{ text = ""; help = "Show blue (rare) loot items in the tooltip" }

MI2_OPTIONS["MI2_OptShowIPurple"] = 
{ text = ""; help = "Show purple (epic) loot items in the tooltip" }

MI2_OPTIONS["MI2_OptMouseTooltip"] = 
{ text = "Show Tooltip at Mouse"; help = "MobInfo tooltip shows up at mouse cursor position\nand follows mouse movement while visible." }

MI2_OPTIONS["MI2_OptHideAnchor"] = 
{ text = "Hide Tooltip Anchor"; help = "Hides the little 'MI' anchor for the MobInfo Tooltip.\nThe anchor will become visible when the options dialog\nis open and when the hide anchor option is disabled." }

MI2_OPTIONS["MI2_OptShowCombined"] = 
{ text = "Mostrar Info. Combinada"; help = "Muestra en modo mensaje combinado en el Cuadro de Texto";
info = "Muestra un mensaje en el cuadro de texto indicando que este modo combinado\nesta activo y listando todos los niveles de mob que han sido combinados\n en un solo cuadro de texto." }

MI2_OPTIONS["MI2_OptSmallFont"] = 
{ text = "Use smaller font"; help = "Use a smaller font for the texts in the Mob Tooltip" }

MI2_OPTIONS["MI2_OptTooltipMode"] = 
{ text = "Tooltip Position"; help = "Position of the MobInfo Tooltip information\nrelative to the Tooltip Anchor";
choice1="Top Left"; choice2="Bottom Left"; choice3="Top Right"; choice4="Bottom Right"; choice5="Center Above"; choice6="Center Below" }

MI2_OPTIONS["MI2_OptCompactMode"] =
{ text = "Two Column Tooltip"; help = "Show the Mob infos in a more compact two column layout.\nThe tooltip will be somewhat wider, but considerably shorter.\nThe total width is limited. Infos that are too wide will be\nshown on a separate single line." }

MI2_OPTIONS["MI2_OptOtherTooltip"] =
{ text = "Hide the other Tooltip"; help = "Hides the other tooltip when showing Mob information\nin the MobInfo tooltip." }

MI2_OPTIONS["MI2_OptSearchMinLevel"] = 
{ text = "Min"; help = "nivel m\195\173nimo del mob para opciones de b\195\186squeda"; }

MI2_OPTIONS["MI2_OptSearchMaxLevel"] = 
{ text = "Max"; help = "nivel m\195\161ximo del mob para opciones de b\195\186squeda (debe ser < 66)"; }

MI2_OPTIONS["MI2_OptSearchNormal"] = 
{ text = "Normal"; help = "incluye mobs de tipo normal en los resultados de la b\195\186squeda"; }

MI2_OPTIONS["MI2_OptSearchElite"] = 
{ text = "Elite"; help = "incluye mobs de tipo elite en los resultados de la b\195\186squeda"; }

MI2_OPTIONS["MI2_OptSearchBoss"] = 
{ text = "Jefe"; help = "incluye mobs jefe en los resultados de la b\195\186squeda"; }

MI2_OPTIONS["MI2_OptSearchMinLoots"] = 
{ text = "Min"; help = "n\195\186mero m\195\173nimo de veces que se ha saqueado un mob"; }

MI2_OPTIONS["MI2_OptSearchMaxLoots"] = 
{ text = "Max"; help = "n\195\186mero m\195\161ximo de veces que se ha saqueado un mob"; }

MI2_OPTIONS["MI2_OptSearchMobName"] = 
{ text = "Nombre Mob"; help = "nombre completo o parcial para buscar";
info = 'Dejalo vac\195\173o para no restringir la b\195\186squeda a objetos espec\195\173ficos\nIntroduciendo "*" selecciona todos los objetos.'; }

MI2_OPTIONS["MI2_OptSearchItemName"] = 
{ text = "Objeto"; help = "nombre completo o parcial del objeto a buscar";
info = 'dejalo vac\195\173o para buscar todos los nombres de objetos'; }

MI2_OPTIONS["MI2_OptSortByValue"] = 
{ text = "Por recompensa"; help = "Clasifica los resultados de b\195\186squeda por recompensa";
info = 'Clasifica los Mobs por el provecho que puedes sacar de ellos mat\195\161ndolos.'; }

MI2_OPTIONS["MI2_OptSortByItem"] = 
{ text = "Por objetos"; help = "Clasifica los resultados de b\195\186squeda por n\195\186mero de veces que se cuenta el objeto";
info = 'Clasifica los Mobs por cuantas veces ha dado el objeto(s) especificado(s).'; }

MI2_OPTIONS["MI2_OptItemTooltip"] = 
{ text = "Mostrar mobs en cuadro de texto"; help = "Muestra los nombres de los que arrojan un objeto en cuadro de texto del objeto";
info = "Muestra el nombre de todos los Mobs que han arrojado multitud de objetos\nen el cuadro di\195\161logo del objeto. Por cada objeto lista la cantidad\narrojada por el Mob con porcentajes." }

MI2_OPTIONS["MI2_OptShowItemPrice"] =
{ text = "Mostrar Precio del Objeto"; help = "Muestra el precio de venta a un vendedor de un objeto en el cuadro de texto" }

MI2_OPTIONS["MI2_OptCombinedMode"] = 
{ text = "Combinar mobs iguales"; help = "Combina datos para Mob con el mismo nombre";
info = "Combina de modo que acumulara los datos para Mobs\ncon el mismo nombre pero de diferente nivel. Cuando esta activo un\nindicador se muestra en Cuadro de Texto" }

MI2_OPTIONS["MI2_OptKeypressMode"] = 
{ text = "Presionar ALT para MobInfo"; help = "Solo se muestra MobInfo en Cuadro de Texto cuando pulsas la tecla ALT"; }

MI2_OPTIONS["MI2_OptItemFilter"] = 
{ text = ""; help = "Establece filtrado de expresi\195\179n para objetos saqueados en Cuadros de Textos";
info = "Sirve para hacer un filtro. Por ejemplo si pones 'monkey' solo se monstraran objetos en que sale esa palabra. Para mostrar todos dejar vacio." }

MI2_OPTIONS["MI2_OptSavePlayerHp"] = 
{ text = "Guardar base de datos de Salud de pjs permanentemente"; help = "Guarda permanentemente salud de jugador en batallas PvP.";
info = "Normalmente los datos de salud de jugador de batallas PvP son descartadas despues de \nuna sesi\195\179n. Ajustando esta opcion te permite guardar los datos." }

MI2_OPTIONS["MI2_OptAllOn"] = 
{ text = "Todo ON"; help = "Activa todas las opciones MobInfo"; }

MI2_OPTIONS["MI2_OptAllOff"] = 
{ text = "Todo OFF"; help = "Desactiva todas las opciones de MobInfo"; }

MI2_OPTIONS["MI2_OptDefault"] = 
{ text = "Por defecto"; help = "Establece las opciones por defecto"; }

MI2_OPTIONS["MI2_OptBtnDone"] = 
{ text = "Hecho"; help = "Cierra MobInfo"; }

MI2_OPTIONS["MI2_OptTargetHealth"] = 
{ text = "Mostrar valor de Vida"; help = "Muestra el valor de la vida en el marco del objetivo"; }

MI2_OPTIONS["MI2_OptTargetMana"] = 
{ text = "Mostrar valor de Man\195\161"; help = "Muestra el valor de man\195\161 en el marco del objetivo"; }

MI2_OPTIONS["MI2_OptHealthPercent"] = 
{ text = "Mostrar porcentaje"; help = "Agrega un porcentaje de la vida en el marco del objetivo"; }

MI2_OPTIONS["MI2_OptManaPercent"] = 
{ text = "Mostrar porcentaje"; help = "Agrega un porcentaje de man\195\161 en el marco del objetivo"; }

MI2_OPTIONS["MI2_OptHealthPosX"] = 
{ text = "Posici\195\179n Horizontal"; help = "Ajusta la posici\195\179n horizontal de la vida en el marco del objetivo"; }

MI2_OPTIONS["MI2_OptHealthPosY"] = 
{ text = "Posici\195\179n Vertical"; help = "Ajusta la posici\195\179n vertical de la vida en el marco del objetivo"; }

MI2_OPTIONS["MI2_OptManaPosX"] = 
{ text = "Posici\195\179n Horizontal"; help = "Ajusta la posici\195\179n horizontal del man\195\161 en el marco del objetivo"; }

MI2_OPTIONS["MI2_OptManaPosY"] = 
{ text = "Posici\195\179n Vertical"; help = "Ajusta la posici\195\179n horizontal del man\195\161 en el marco del objetivo"; }

MI2_OPTIONS["MI2_OptTargetFont"] = 
{ text = "Fuente"; help = "Establece la letra de los valores vida/man\195\161";
choice1= "Fuente N\195\186meros"; choice2="Fuente Juego"; choice3="Fuente Texto" }

MI2_OPTIONS["MI2_OptTargetFontSize"] = 
{ text = "Tama\195\177o de Fuente"; help = "Fija el tama\195\177o de la letra en los valores vida/man\195\161"; }

MI2_OPTIONS["MI2_OptClearTarget"] = 
{ text = "Borrar datos de Objetivo"; help = "Borra los datos del objetivo actual de la Base de Datos."; }

MI2_OPTIONS["MI2_OptClearMobDb"] = 
{ text = "Purgar base de datos"; help = "Borra los datos completos de mobs de la Base de Datos."; }

MI2_OPTIONS["MI2_OptClearHealthDb"] = 
{ text = "Purgar base de datos"; help = "Borra los datos de la vida de la Base de Datos."; }

MI2_OPTIONS["MI2_OptClearPlayerDb"] = 
{ text = "Purgar base de datos"; help = "Borrar datos de la vida de los jugadores."; }

MI2_OPTIONS["MI2_OptSaveItems"] = 
{ text = "Guardar calidad de objetos del Mob:"; help = "Habilita esto para guardar detalles de objetos de saqueo de Mobs.";
info = "Puedes elegir el nivel de la calidad de objetos para guardar"; }

MI2_OPTIONS["MI2_OptSaveCharData"] = 
{ text = "Guardar datos de un pj espec\195\173fico"; help = "Guarda todos los datos de Mob que son espec\195\173ficos para cada personaje.";
info = "Con esto activas o desactivas el guardado de los siguientes datos:\nnñumero de muertes, daño m\195\173n/m\195\161x, DPS (daño por seg.)\n\nEstos datos son salvados separadamente para cada personaje. Salvar solo puede\nactivarse/desactivarse para cada grupo completo de 4 valores"; }

MI2_OPTIONS["MI2_OptSaveResist"] = 
{ text = "Guarda datos Resistencias e Inmunidades"; help = "Guarda datos sobre las resistencias e inmunidades de los Enemigos a las escuelas de magia.";
info = "MobInfo guarda para las escuelas de magia cuantos hechizos por escuela\nhan impactado con \195\169xito contra cuantos han sido resistidos."; }

MI2_OPTIONS["MI2_OptItemsQuality"] = 
{ text = "Guardar calidad"; help = "Guarda detalles de calidad del objeto con la calidad seleccionada o mejor.";
choice1 = "Gris y mejor"; choice2="Blanco y mejor"; choice3="Verde y mejor" }

MI2_OPTIONS["MI2_OptTrimDownMobData"] = 
{ text = "Reducir tama\195\177o de base de datos"; help = "Reduce el tama\195\177o de la Base de Datos de Mobs borrando datos sin importancia";
info = "Datos sin importancia son todos los datos\nque no marcas para guardarse."; }

MI2_OPTIONS["MI2_OptImportMobData"] = 
{ text = "Comienza la Importaci\195\179n"; help = "Importa una Base de Datos de Mobs externa en tu Base de Datos";
info = "IMPORTANTE: ¡ por favor lee las instrucciones de importaci\195\179n !\n¡ SIEMPRE haz una copia de seguridad de Base de Datos ANTES de importar !"; }

MI2_OPTIONS["MI2_OptDeleteSearch"] = 
{ text = "BORRAR"; help = "Borra todos los Mobs en la lista resultado de la b\195\186squeda de la Base de Datos de MobInfo.";
info = "ADVERTENCIA: esta operaci\195\179n no se puede deshacer.\n¡ Por favor usa con cuidado !\nPuedes querer hacer una copia de seguridad de base de datos de MobInfo antes de borrar los Mobs."; }

MI2_OPTIONS["MI2_OptImportOnlyNew"] = 
{ text = "Importa solo Mobs Desconocidos"; help = "Importa solo los Mobs que no existen en tu base de datos";
info = "Activando esta opci\195\179n previene que la informaci\195\179n de los Mobs existentes\nsea modificada. Solo Mobs desconocidos (ej. nuevo) seran importados. Esto\npermite importar sobreponiendo parcialmente la base de datos\nsin causar problemas de consitencia."; }

MI2_OPTIONS["MI2_SearchResultFrameTab1"] = 
{ text = "Lista Mobs"; help = "Muestra la lista de Mobs"; }

MI2_OPTIONS["MI2_SearchResultFrameTab2"] = 
{ text = "Lista Objetos"; help = "Muestra la lista de objetos"; }

MI2_OPTIONS["MI2_OptionsTabFrameTab1"] = 
{ text = "Tooltips"; help = "Fija las opciones para mostrar MobInfo en el Cuadro de Texto"; }

MI2_OPTIONS["MI2_OptionsTabFrameTab2"] = 
{ text = "Salud/Man\195\161"; help = "Fija opciones para mostrar vida/man\195\161 en el marco objetivo"; }

MI2_OPTIONS["MI2_OptionsTabFrameTab3"] = 
{ text = "Base de Datos"; help = "Opciones de Base de Datos"; }

MI2_OPTIONS["MI2_OptionsTabFrameTab4"] = 
{ text = "Buscar"; help = "Busca en la base de datos"; }

MI2_OPTIONS["MI2_OptionsTabFrameTab5"] = 
{ text = "General"; help = "General options for the MobInfo AddOn"; }

end
