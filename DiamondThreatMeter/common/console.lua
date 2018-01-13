local activeModule = "Console";

-- --------------------------------------------------------------------
-- **                          Console table                         **
-- --------------------------------------------------------------------

local inputPortions = {};

-- /!\ Do not set "call" fields to directly a function. Sets it to a function name instead, as when this code will be executed,
-- functions themselves won't be defined yet. /!\

-- Note to translators: basically you can cut-paste, change the locale ID and translate the following fields:
-- >> unknownHelp
-- >> invalidHelp
-- >> input

local console = {
    ["default"] = {
        unknownHelp = "/DTM <command>\nCommands: options | test | reset | toggle\n<Options> allows you to access various DTM options panels.\n<Test> will bring you various test commands.\n<Reset> allows you reset all threat lists.\n<Toggle> allows you to toggle the emergency stop.",

        [1] = {
            type = "COMMAND",
            input = "reset",
            call = "DTM_EntityData_Reset",
            arguments = {
                number = 0,
            },
            invalidHelp = "/DTM reset |cffffff00<no parameter>|r",
        },

        [2] = {
            type = "COMMAND",
            input = "toggle",
            call = "DTM_SetEmergencyStop",
            arguments = {
                number = 0,
            },
            invalidHelp = "/DTM toggle |cffffff00<no parameter>|r",
        },

        [3] = {
            type = "CATEGORY",
            input = "test",
            unknownHelp = "/DTM test <command>\nCommands: talent | npc | internals | gear | list | set | version | buffer",

            [1] = {
                type = "COMMAND",
                input = "talent",
                call = "DTM_Engine_Test_CheckTalents",
                arguments = {
                    number = 1,
                    [1] = "string",
                },
                invalidHelp = "/DTM test talent <player/target/party1/raid3 etc.>",
            },

            [2] = {
                type = "COMMAND",
                input = "npc",
                call = "DTM_Engine_Test_CheckNPCAbilities",
                arguments = {
                    number = 1,
                    [1] = "string",
                },
                invalidHelp = "/DTM test npc <target/mouseover/focus etc.>",
            },

            [3] = {
                type = "COMMAND",
                input = "internals",
                call = "DTM_Engine_Test_PrintAssociationErrors",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM test internals |cffffff00<no parameter>|r",
            },

            [4] = {
                type = "COMMAND",
                input = "gear",
                call = "DTM_Engine_Test_CheckGear",
                arguments = {
                    number = 1,
                    [1] = "string",
                },
                invalidHelp = "/DTM test gear <player/target/party1/raid3 etc.>",
            },

            [5] = {
                type = "COMMAND",
                input = "list",
                call = "DTM_Engine_Test_PrintLists",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM test list |cffffff00<no parameter>|r",
            },

            [6] = {
                type = "COMMAND",
                input = "set",
                call = "DTM_Engine_Test_CheckSets",
                arguments = {
                    number = 1,
                    [1] = "string",
                },
                invalidHelp = "/DTM test set <player/target/party1/raid3 etc.>",
            },

            [7] = {
                type = "COMMAND",
                input = "version",
                call = "DTM_Engine_Test_CheckVersion",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM test version |cffffff00<no parameter>|r",
            },

            [8] = {
                type = "CATEGORY",
                input = "buffer",
                unknownHelp = "/DTM test buffer <command>\nCommands: talent | gear",

                [1] = {
                    type = "COMMAND",
                    input = "talent",
                    call = "DTM_Engine_Test_CheckTalentsBuffer",
                    arguments = {
                        number = 0,
                    },
                    invalidHelp = "/DTM test buffer talent |cffffff00<no parameter>|r",
                },

                [2] = {
                    type = "COMMAND",
                    input = "gear",
                    call = "DTM_Engine_Test_CheckItemsBuffer",
                    arguments = {
                        number = 0,
                    },
                    invalidHelp = "/DTM test buffer gear |cffffff00<no parameter>|r",
                },
            },
        },

        [4] = {
            type = "CATEGORY",
            input = "options",
            unknownHelp = "/DTM options <command>\nCommands: system | engine | gui | warning | nameplate | version | role\n<Role> allows you to change quickly your configuration, based on your role.",

            [1] = {
                type = "COMMAND",
                input = "engine",
                call = "DTM_ConfigurationFrame_EnginePanel_Open",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM options engine |cffffff00<no parameter>|r",
            },

            [2] = {
                type = "COMMAND",
                input = "gui",
                call = "DTM_ConfigurationFrame_GUIPanel_Open",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM options gui |cffffff00<no parameter>|r",
            },

            [3] = {
                type = "COMMAND",
                input = "version",
                call = "DTM_ConfigurationFrame_VersionPanel_Open",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM options version |cffffff00<no parameter>|r",
            },

            [4] = {
                type = "COMMAND",
                input = "role",
                call = "DTM_DisplayRolePopup",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM options role |cffffff00<no parameter>|r",
            },

            [5] = {
                type = "COMMAND",
                input = "system",
                call = "DTM_ConfigurationFrame_SystemPanel_Open",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM options system |cffffff00<no parameter>|r",
            },

            [6] = {
                type = "COMMAND",
                input = "warning",
                call = "DTM_ConfigurationFrame_WarningPanel_Open",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM options warning |cffffff00<no parameter>|r",
            },

            [7] = {
                type = "COMMAND",
                input = "nameplate",
                call = "DTM_ConfigurationFrame_NameplatePanel_Open",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM options nameplate |cffffff00<no parameter>|r",
            },
        },
    },

    ["frFR"] = {
        unknownHelp = "/DTM <commande>\nCommandes : basculer | options | test | raz\n<Basculer> permet de basculer l'arrêt d'urgence.\n<Options> permet d'accéder aux divers panneaux de configuration de DTM.\n<Test> permet d'effectuer des commandes de test.\n<RaZ> vous permet de réinitialiser toutes les listes de menace.",

        [1] = {
            type = "COMMAND",
            input = "raz",
            call = "DTM_EntityData_Reset",
            arguments = {
                number = 0,
            },
            invalidHelp = "/DTM raz |cffffff00<pas de paramètre>|r",
        },

        [2] = {
            type = "COMMAND",
            input = "basculer",
            call = "DTM_SetEmergencyStop",
            arguments = {
                number = 0,
            },
            invalidHelp = "/DTM basculer |cffffff00<pas de paramètre>|r",
        },

        [3] = {
            type = "CATEGORY",
            input = "test",
            unknownHelp = "/DTM test <commande>\nCommandes : talent | pnj | internes | equipement | liste | ensemble | version | tampon",

            [1] = {
                type = "COMMAND",
                input = "talent",
                call = "DTM_Engine_Test_CheckTalents",
                arguments = {
                    number = 1,
                    [1] = "string",
                },
                invalidHelp = "/DTM test talent <player/target/party1/raid3 etc.>",
            },

            [2] = {
                type = "COMMAND",
                input = "pnj",
                call = "DTM_Engine_Test_CheckNPCAbilities",
                arguments = {
                    number = 1,
                    [1] = "string",
                },
                invalidHelp = "/DTM test pnj <target/mouseover/focus etc.>",
            },

            [3] = {
                type = "COMMAND",
                input = "internes",
                call = "DTM_Engine_Test_PrintAssociationErrors",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM test internes |cffffff00<pas de paramètre>|r",
            },

            [4] = {
                type = "COMMAND",
                input = "equipement",
                call = "DTM_Engine_Test_CheckGear",
                arguments = {
                    number = 1,
                    [1] = "string",
                },
                invalidHelp = "/DTM test equipement <player/target/party1/raid3 etc.>",
            },

            [5] = {
                type = "COMMAND",
                input = "liste",
                call = "DTM_Engine_Test_PrintLists",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM test liste |cffffff00<pas de paramètre>|r",
            },

            [6] = {
                type = "COMMAND",
                input = "ensemble",
                call = "DTM_Engine_Test_CheckSets",
                arguments = {
                    number = 1,
                    [1] = "string",
                },
                invalidHelp = "/DTM test ensemble <player/target/party1/raid3 etc.>",
            },

            [7] = {
                type = "COMMAND",
                input = "version",
                call = "DTM_Engine_Test_CheckVersion",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM test version |cffffff00<pas de paramètre>|r",
            },

            [8] = {
                type = "CATEGORY",
                input = "tampon",
                unknownHelp = "/DTM test tampon <commande>\nCommandes: talent | equipement",

                [1] = {
                    type = "COMMAND",
                    input = "talent",
                    call = "DTM_Engine_Test_CheckTalentsBuffer",
                    arguments = {
                        number = 0,
                    },
                    invalidHelp = "/DTM test tampon talent |cffffff00<pas de paramètre>|r",
                },

                [2] = {
                    type = "COMMAND",
                    input = "equipement",
                    call = "DTM_Engine_Test_CheckItemsBuffer",
                    arguments = {
                        number = 0,
                    },
                    invalidHelp = "/DTM test tampon equipement |cffffff00<pas de paramètre>|r",
                },
            },
        },

        [4] = {
            type = "CATEGORY",
            input = "options",
            unknownHelp = "/DTM options <commande>\nCommandes: systeme | moteur | iug | avertissement | plaque | version | role\n<Role> vous permet de changer rapidement la configuration, en fonction de votre rôle.",

            [1] = {
                type = "COMMAND",
                input = "moteur",
                call = "DTM_ConfigurationFrame_EnginePanel_Open",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM options moteur |cffffff00<pas de paramètre>|r",
            },

            [2] = {
                type = "COMMAND",
                input = "iug",
                call = "DTM_ConfigurationFrame_GUIPanel_Open",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM options iug |cffffff00<pas de paramètre>|r",
            },

            [3] = {
                type = "COMMAND",
                input = "version",
                call = "DTM_ConfigurationFrame_VersionPanel_Open",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM options version |cffffff00<pas de paramètre>|r",
            },

            [4] = {
                type = "COMMAND",
                input = "role",
                call = "DTM_DisplayRolePopup",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM options role |cffffff00<pas de paramètre>|r",
            },

            [5] = {
                type = "COMMAND",
                input = "systeme",
                call = "DTM_ConfigurationFrame_SystemPanel_Open",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM options systeme |cffffff00<pas de paramètre>|r",
            },

            [6] = {
                type = "COMMAND",
                input = "avertissement",
                call = "DTM_ConfigurationFrame_WarningPanel_Open",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM options avertissement |cffffff00<pas de paramètre>|r",
            },

            [7] = {
                type = "COMMAND",
                input = "plaque",
                call = "DTM_ConfigurationFrame_NameplatePanel_Open",
                arguments = {
                    number = 0,
                },
                invalidHelp = "/DTM options plaque |cffffff00<pas de paramètre>|r",
            },
        },
    },

    -- Provide here new translations. :)


};

-- Add all commands/category from default command set to all localised command sets.

--[[     ABORTED FOR NOW - The implementation I tried was only partial; it didn't implement fully the default command set. I'll maybe fix it later.

local function copyTable(new, fill)
    if not ( new ) or not ( fill ) then return; end
    for key, copy in pairs(fill) do
        if ( type(copy) == "table" ) then
            new[key] = {};
            completeNest(new[key], copy);
      else
            new[key] = copy;
        end
    end
end

local function completeLocalisedSet(data, defaultData)
    if not ( data ) or not ( defaultData ) then return; end
    local k, v;
    local position;
    local key, copy;
    for k, v in ipairs(defaultData) do
        position = #data+1;

        data[position] = {};
        copyTable(data[position], v);
    end
end

-- Add here a similar line for your language code if you want the default commands to be useable too in your language.
completeLocalisedSet(console["frFR"], console["default"]);

]]

-- --------------------------------------------------------------------
-- **                        Console functions                       **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_Console_OnCommand(input, feedback)                           *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> input: what we asked the console to do.                       *
-- * >> feedback: if set, the console will print feedback in case of  *
-- * unknown commands, bad syntaxes etc. instead of silently fail.    *
-- ********************************************************************

function DTM_Console_OnCommand(input, feedback)
    -- STEP 1 - Decomposes each word of the input.

    local k, v;
    local portions = 0;

    for k, v in ipairs(inputPortions) do
        inputPortions[k] = nil;
    end

    for w in string.gmatch(input, "[%a%d]+") do
        portions = portions + 1;
        inputPortions[portions] = strlower(w);
    end

    -- STEP 2 - Grab the appropriate console table.

    if not ( console ) then
        -- Uh ? Console table has been deleted from the cosmos !
        DTM_ThrowError("CRITICAL", activeModule, "No console table exists.");
        return;
    end

    local data = console[GetLocale()];
    if not ( data ) then
        data = console["default"];
    end
    if not ( data ) then
        -- Uh ? No console table at all !
        DTM_ThrowError("CRITICAL", activeModule, "No entry for '"..GetLocale().."' nor 'default' locales have been found in console table !");
        return;
    end

    -- STEP 3 - Enter the loop ! Oh yeah baby enter the loop =))

    local unknownHelp;
    local invalidHelp;
    local level = 0;
    local levelData;

    local continue = 1;
    local isValid = 1; -- 1 if the command exists. If isValid is nil and feedback set, a message saying you entered an unknown command will fire.
    local hasSyntaxError = nil; -- 1 if the command was a real command and the user passed missing/invalid arguments to it.
    local functionMissing = nil; -- 1 if command was provided good arguments, but the function itself to call did not exist !

    while ( continue ) do
        unknownHelp = nil;
        invalidHelp = nil;

        if ( level == 0 ) then
            -- Root level dude.
            unknownHelp = data.unknownHelp;
            levelData = data;
      else
            -- We're somewhere deep in the tree.
            unknownHelp = levelData.unknownHelp;
        end

        isValid = nil;
        continue = nil;

        for k, nodeData in ipairs(levelData) do
            if ( nodeData.input and inputPortions[level+1] ) and ( strlower(nodeData.input) == inputPortions[level+1] ) then
                -- This command matches.
                isValid = 1;

                if ( nodeData.type == "COMMAND" ) then
                    local a;
                    local providedArgument = nil;
                    local awaiting = nil;

                    continue = nil;

                    -- It has initially a good syntax..
                    hasSyntaxError = nil;
                    invalidHelp = nodeData.invalidHelp;

                    for a=1, nodeData.arguments.number do
                        awaiting = nodeData.arguments[a];
                        providedArgument = inputPortions[level+1+a];
                        
                        if ( awaiting == "number" ) and not ( tonumber(providedArgument) ) then
                            hasSyntaxError = 1;
                        end
                        if ( awaiting == "string" ) then
                            providedArgument = providedArgument or '';
                            if ( strlen( providedArgument ) <= 0 ) then
                                hasSyntaxError = 1;
                            end
                        end
                    end

                    -- The console system is strict; you can't pass more arguments than the function expects.
                    if ( (portions-level-1) > nodeData.arguments.number ) then
                        hasSyntaxError = 1;
                    end

                    -- Ok, seems like it's safe to pass arguments to the func without making the system crashes :P
                    if not ( hasSyntaxError ) then
                        local funcToCall = nodeData.call;
                        if ( type(funcToCall) == "string" ) then
                            funcToCall = getglobal(funcToCall);
                            if ( type(funcToCall) == "function" ) then
                                -- Ok, prepare the arguments and deliver them to the function.
                                -- Up to 5 arguments. It's enough for 99% of cases I guess ^_^'..
                                funcToCall(inputPortions[level+2], inputPortions[level+3],inputPortions[level+4],inputPortions[level+5], inputPortions[level+6]);
                          else
                                functionMissing = 1;
                            end
                      else
                            functionMissing = 1;
                        end
                    end

            elseif ( nodeData.type == "CATEGORY" ) then
                    continue = 1;
                    levelData = levelData[k];  -- Progress in the tree.
                    level = level + 1;
              else
                    -- Unknown type. Ignore & exit loop.
                    continue = nil;
                end

                break;
            end
        end

        if not ( isValid ) then
            continue = nil;
        end
    end

    -- STEP 4 - If enabled, tells the user anything that could have gone wrong.

    if ( feedback ) then
        local errorMessage = nil;

        if not ( isValid ) and ( unknownHelp ) then
            errorMessage = DTM_Localise("ConsoleUnknown") .. unknownHelp;

    elseif ( hasSyntaxError ) and ( invalidHelp ) then
            errorMessage = DTM_Localise("ConsoleBadSyntax") .. invalidHelp;

    elseif ( functionMissing ) then
            errorMessage = DTM_Localise("ConsoleBroken");
        end

        if ( errorMessage ) then
            DTM_ChatMessage(errorMessage, 1);
        end
    end
end