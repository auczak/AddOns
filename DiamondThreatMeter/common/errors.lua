local activeModule = "Errors handling";

-- --------------------------------------------------------------------
-- **                              Data                              **
-- --------------------------------------------------------------------

local errorsData = { };
local countTable = { };
local errorCallback = { };

local errorLevels = {
    MINOR = 1,
    MAJOR = 2,
    CRITICAL = 3,
};

-- --------------------------------------------------------------------
-- **                               API                              **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_RegisterForErrors(callback, typeThreshold)                   *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> callback: the callback function to call upon receiving an     *
-- * error that has a gravity equal or higher than the threshold.     *
-- * Can be: CRITICAL, MAJOR or MINOR.                                *
-- * >> typeThreshold: the gravity the error must have at least to    *
-- * be sent through the callback.                                    *
-- ********************************************************************
-- * This API allows the mod to register a custom error notification  *
-- * function that will be called whenever an error matching its      *
-- * gravity threshold occurs.                                        *
-- ********************************************************************

function DTM_RegisterForErrors(callback, typeThreshold)
    local invalidType = type(typeThreshold) ~= "string" or type(errorLevels[typeThreshold]) ~= "number";
    if type(callback) ~= "function" or invalidType then error("Usage: DTM_RegisterForErrors(callback, \"CRITICAL|MAJOR|MINOR\")", 0); end

    local callbackID = tostring(callback);
    if type(callbackID) ~= "string" then
        error("Could not get callback's ID. Error callback registration aborted.", 0);
    end

    if ( errorCallback[callbackID] ) then
        -- Silent fail. The callback was already registered.
        return;
    end

    errorCallback[callbackID] = {callback=callback, threshold=errorLevels[typeThreshold]};
end

-- ********************************************************************
-- * DTM_ThrowError(errorType, module, info)                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> errorType: the gravity of the error.                          *
-- * Can be: CRITICAL, MAJOR or MINOR.                                *
-- * >> module: the name of the addOn module in which it occured.     *
-- * >> info: detailed errors informations.                           *
-- ********************************************************************
-- * Notifies DTM a handled error occured, and where/why.             *
-- ********************************************************************

function DTM_ThrowError(errorType, module, info)
    local invalidType = type(errorType) ~= "string" or type(errorLevels[errorType]) ~= "number";
    if type(module) ~= "string" or type(info) ~= "string" or invalidType then error("Usage: DTM_ThrowError(\"CRITICAL|MAJOR|MINOR\", \"module\", \"info\")", 0); end

    -- Complete the raw info with context stuff
    info = info..(DTM_GetErrorContext(1, 1, 1) or '');

    -- Log the error.
    errorsData[#errorsData+1] = {
        errorType = errorType,
        module = module,
        info = info,
    };

    -- Dispatch the error in appropriate registered callbacks.
    local id, info;
    for id, info in pairs(errorCallback) do
        if type(info) == "table" and type(info.callback) == "function" and type(info.threshold) == "number" then
            if ( errorLevels[errorType] >= info.threshold ) then
                info.callback(errorType, module, info);
            end
        end
    end
end

-- ********************************************************************
-- * DTM_ProtectedCall(func, type, ...)                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> func: the func to issue the protected call to.                *
-- * >> callType: the type of call it is. Same possibilities as       *
-- *              error levels: can be CRITICAL, MAJOR, MINOR.        *
-- * >> ...: arguments to pass to func.                               *
-- ********************************************************************
-- * Issues a protected function call, with error handling support.   *
-- * This function does not return any value. It's to be used to      *
-- * prevent recurrent routines from breaking up the whole mod.       *
-- ********************************************************************

function DTM_ProtectedCall(func, callType, ...)
    local invalidType = type(callType) ~= "string" or type(errorLevels[callType]) ~= "number";
    if type(func) ~= "function" or invalidType then error("Usage: DTM_ProtectedCall(func, \"CRITICAL|MAJOR|MINOR\"[, ...])", 0); end

    local funcID = tostring(func);
    if type(funcID) ~= "string" then
        error("Could not get function's ID. Function hasn't been run.", 0);
    end

    local errorCount = countTable[funcID] or 0;

    if ( errorCount >= 3 ) then
        -- This function's call failed by 3 times now. This func starts to be fucked up, we block further calls...
        -- We do not log the block event, as the function might be set on a OnUpdate handler and it'd start to flood the error log...
        return;
  else
        local result, errMessage = pcall(func, ...);

        if ( not result ) then
            errMessage = "A runtime error has occured.\n\n"..errMessage;
            if ( errorCount == 0 ) then errMessage = errMessage.."\n\nFirst failure of the function."; end
            if ( errorCount == 1 ) then errMessage = errMessage.."\n\nSecond failure of the function."; end
            if ( errorCount == 2 ) then errMessage = errMessage.."\n\nThird failure of the function: further calls will be blocked."; end

            DTM_ThrowError(callType, activeModule, errMessage);
            countTable[funcID] = errorCount + 1;
      else
            -- Okay, function ran fine, phew !
        end
    end
end

-- ********************************************************************
-- * DTM_GetNumErrors()                                               *
-- ********************************************************************
-- * Arguments:                                                       *
-- *    <none>                                                        *
-- ********************************************************************
-- * Returns the number of declared errors or handled runtime errors  *
-- * so far. No distinction is made among these two error types.      *
-- ********************************************************************

function DTM_GetNumErrors()
    return #errorsData or 0;
end

-- ********************************************************************
-- * DTM_GetErrorInfo(index)                                          *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> index: of the error. Must be in bounds of course.             *
-- ********************************************************************
-- * Gives info about a given error.                                  *
-- * Returns errorType, module, info.                                 *
-- ********************************************************************

function DTM_GetErrorInfo(index)
    if type(errorsData[index]) ~= "table" then return "INVALID", "INVALID", "DTM_GetErrorInfo: error index is out of bounds."; end
    return errorsData[index].errorType or "INVALID", errorsData[index].module or "Unknown", errorsData[index].info or "None";
end

-- --------------------------------------------------------------------
-- **                            Functions                           **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_GetErrorContext(incBuild, incChar, incAddOns)                *
-- ********************************************************************
-- * Arguments:                                                       *
-- * >> incBuild: display the WoW build in the error context.         *
-- * >> incChar: display the name/realm of the character.             *
-- * >> incAddOns: display list of enabled AddOns.                    *
-- ********************************************************************
-- * Return a string explaining the current context.                  *
-- ********************************************************************

function DTM_GetErrorContext(incBuild, incChar, incAddOns)
    local info = string.format("\n\nDTM v%s (%s)\nDate (day first): %s", DTM_GetVersionString(), GetLocale(), date("%d/%m/%y %H:%M:%S"));

    if ( incBuild ) then
        local version, build, date, toc = GetBuildInfo();
        info = info..string.format("\nWoW version: %s (%s), %s", version, build, date);
    end

    if ( incChar ) then
        local name = UnitName("player");
        info = info..string.format("\nCharacter: %s, server: %s", name, GetRealmName());
    end

    if ( incAddOns ) then
        local totalCount = GetNumAddOns();
        local usedCount = 0;
        local listString = "";
        local i, name, title, notes, enabled, loadable, reason, security;

        for i=1, totalCount do
            name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i);
            if ( enabled ) then
                if ( usedCount == 0 ) then
                    listString = listString..name;
              else
                    listString = listString..", "..name;
                end
                usedCount = usedCount + 1;
            end
        end

        info = info..string.format("\n\nAddOns (%d): %s", usedCount, listString);
    end

    return info;
end

