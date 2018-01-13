local activeModule = "Sounds";

-- --------------------------------------------------------------------
-- **                       Sounds variables                         **
-- --------------------------------------------------------------------



-- --------------------------------------------------------------------
-- **                              API                               **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * DTM_PlaySound(internalName)                                      *
-- ********************************************************************
-- * Arguments:                                                       *
-- * internalName >> the internalName of the sound to start.          *
-- * If it is not found or for some reason can't be played, nil is    *
-- * returned. 1 elsewise.                                            *
-- ********************************************************************
-- * Explained above. :)  Note that SFX playback cannot be stopped.   *
-- ********************************************************************
function DTM_PlaySound(internalName)
    local internalName, filename, type = DTM_Resources_GetSoundData(internalName);
    if ( filename ) then
        return PlaySoundFile(filename);
    end
    return nil;
end
