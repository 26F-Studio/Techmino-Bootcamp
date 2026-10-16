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
    WIDGET.new{type='slider',pos={.5,.5},x=-350,y=-190,w=700,text="ASD",axis={60,160,5},unit=20,disp=TABLE.func_getVal(CONF.game_brik,'asd'),valueShow=sliderShow_time,code=TABLE.func_setVal(CONF.game_brik,'asd')},
    WIDGET.new{type='slider',pos={.5,.5},x=-350,y=-100,w=700,text="ASP",axis={0,15,5},disp=TABLE.func_getVal(CONF.game_brik,'asp'),valueShow=sliderShow_time,
        code=function(v)
            CONF.game_brik.asp=v
            CONF.game_brik.adp=v
        end},

    WIDGET.new{type='hint',pos={.5,.5},x=-470,y=-190,floatText=LANG'settings_hint_asd',text="?"},
    WIDGET.new{type='hint',pos={.5,.5},x=-470,y=-100,floatText=LANG'settings_hint_asp',text="?"},

    WIDGET.new{type='switch',pos={.5,.5},x=-300,y=-10+90,h=40,labelPos='right',text="中文/English",disp=function() return CONF.system.locale=='en' end,code=function()
        CONF.system.locale=CONF.system.locale=='en' and 'zh' or 'en'
        WIDGET._reset()
    end},
    WIDGET.new{type='checkBox',pos={.5,.5},x=300,y=-10,w=40,labelPos='left',text=LANG'settings_force180',disp=TABLE.func_getVal(CONF.system,'force180'),code=TABLE.func_revVal(CONF.system,'force180')},
    WIDGET.new{type='checkBox',pos={.5,.5},x=300,y=-10+90,w=40,labelPos='left',text=LANG'settings_fullscreen',disp=TABLE.func_getVal(CONF.system,'fullscreen'),code=TABLE.func_revVal(CONF.system,'fullscreen')},
    WIDGET.new{type='button',pos={.5,.5},x=0,y=120+90,w=326,h=100,fontSize=50,text=LANG'settings_keyMapping',onClick=WIDGET.c_goScn('keyset')},
    BackButtonBR,
}
return scene
