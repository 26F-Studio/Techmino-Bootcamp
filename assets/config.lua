local conf={
    _system={ -- We just save values here, do not change them directly.
        -- Audio
        mainVol=1,
        bgmVol=.8,
        sfxVol=1,
        fullscreen=true,
        locale=(os.getenv('LANG') or 'en'):find('^zh') and 'zh' or 'en',
    },
    game_brik={
        asd=120,
        asp=20,
        adp=20,
        ash=20,
    },
}
local settingTriggers={ -- Changing values in CONF.system will trigger these functions (if exist).
    -- Audio
    mainVol=function(v) love.audio.setVolume(v) end,
    bgmVol=function(v) BGM.setVol(v) end,
    sfxVol=function(v) SFX.setVol(v) end,

    -- Video
    fullscreen=function(v)
        love.window.setFullscreen(v); love.resize(GC.getDimensions())
    end,

    -- Other
    locale=function(v) Text=LANG.set(v) end,
}
conf.system=setmetatable({},{
    __index=conf._system,
    __newindex=function(_,k,v)
        if conf._system[k]~=v then
            conf._system[k]=v
            if settingTriggers[k] then
                settingTriggers[k](v)
            end
        end
    end,
    __metatable=true,
})

return conf
