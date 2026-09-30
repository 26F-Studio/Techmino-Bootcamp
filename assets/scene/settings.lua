---@type Zenitha.Scene
local scene={}

function scene.unload()
    if SCN.stackChange<0 then
        SaveConf()
    end
end

function scene.keyDown(key,isRep)
    if isRep then return true end
    if KM.sys:getAction(key)=='back' then
        SFX.play('button_back')
        SCN.back()
    end
    return true
end

local function sliderShow_time(S) return S.disp().." ms" end

scene.widgetList={
    WIDGET.new{type='slider',pos={.5,.5},x=-350,y=-270-120,w=700,text=LANG'settings_mainVol',disp=TABLE.func_getVal(CONF.system,'mainVol'),code=TABLE.func_setVal(CONF.system,'mainVol')},
    WIDGET.new{type='slider',pos={.5,.5},x=-350,y=-190-120,w=700,text=LANG'settings_bgm',disp=TABLE.func_getVal(CONF.system,'bgmVol'),code=TABLE.func_setVal(CONF.system,'bgmVol')},
    WIDGET.new{type='slider',pos={.5,.5},x=-350,y=-110-120,w=700,text=LANG'settings_sfx',disp=TABLE.func_getVal(CONF.system,'sfxVol'),code=TABLE.func_setVal(CONF.system,'sfxVol')},

    WIDGET.new{type='slider',pos={.5,.5},x=-350,y=-110,w=700,text="ASD",axis={20,260,5},unit=20,disp=TABLE.func_getVal(CONF.game_brik,'asd'),valueShow=sliderShow_time,code=function(v)
        CONF.game_brik.asd=v; CONF.game_brik.asp=math.min(CONF.game_brik.asp,v); CONF.game_brik.adp=math.min(CONF.game_brik.adp,v)
    end},
    WIDGET.new{type='slider',pos={.5,.5},x=-350,y=-30,w=700,text="ASP",axis={0,120,5},unit=10,disp=TABLE.func_getVal(CONF.game_brik,'asp'),valueShow=sliderShow_time,code=function(v)
        CONF.game_brik.asp=v; CONF.game_brik.asd=math.max(CONF.game_brik.asd,v)
    end},
    WIDGET.new{type='slider',pos={.5,.5},x=-350,y=50,w=700,text="ADP",axis={0,120,5},unit=10,disp=TABLE.func_getVal(CONF.game_brik,'adp'),valueShow=sliderShow_time,code=function(v)
        CONF.game_brik.adp=v; CONF.game_brik.asd=math.max(CONF.game_brik.asd,v)
    end},
    WIDGET.new{type='slider',pos={.5,.5},x=-350,y=130,w=700,text="ASH",axis={0,60,5},unit=10,disp=TABLE.func_getVal(CONF.game_brik,'ash'),valueShow=sliderShow_time,code=function(v)
        CONF.game_brik.ash=v; CONF.game_brik.asd=math.max(CONF.game_brik.asd,v)
    end},

    WIDGET.new{type='hint',pos={.5,.5},x=-470,y=-110,floatText=LANG'settings_hint_asd',text="?"},
    WIDGET.new{type='hint',pos={.5,.5},x=-470,y=-30,floatText=LANG'settings_hint_asp',text="?"},
    WIDGET.new{type='hint',pos={.5,.5},x=-470,y=50,floatText=LANG'settings_hint_adp',text="?"},
    WIDGET.new{type='hint',pos={.5,.5},x=-470,y=130,floatText=LANG'settings_hint_ash',text="?"},

    WIDGET.new{type='switch',pos={.5,.5},x=-300,y=250,h=40,labelPos='right',text="中文/English",disp=function() return CONF.system.locale=='en' end,code=function()
        CONF.system.locale=CONF.system.locale=='en' and 'zh' or 'en'; WIDGET._reset()
    end},
    WIDGET.new{type='checkBox',pos={.5,.5},x=300,y=250,w=40,labelPos='left',text=LANG'settings_fullscreen',disp=TABLE.func_getVal(CONF.system,'fullscreen'),code=TABLE.func_revVal(CONF.system,'fullscreen')},
    WIDGET.new{type='button',pos={.5,.5},x=0,y=380,w=326,h=100,fontSize=50,text=LANG'settings_keyMapping',onClick=WIDGET.c_goScn('keyset')},
    BackButtonBR,
}
return scene
