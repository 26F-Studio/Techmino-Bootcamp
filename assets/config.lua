local conf={
    _system={ -- We just save values here, do not change them directly.
        fullscreen=true,
        locale=(os.getenv('LANG') or 'en'):find('^zh') and 'zh' or 'en',
    },
    game_brik={
        asd=120,
        asp=20,
    },
}
local settingTriggers={ -- Changing values in CONF.system will trigger these functions (if exist).
    fullscreen=function(v)
        love.window.setFullscreen(v); love.resize(GC.getDimensions())
    end,
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
