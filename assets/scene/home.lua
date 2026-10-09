---@type Zenitha.Scene
local scene={}

function scene.load()
end

function scene.unload()
    if SCN.stackChange<0 then
        SaveConf()
    end
end

function scene.update(dt)
end

function scene.keyDown(key,isRep)
    if isRep then return true end
    if KM.sys:getAction(key)=='back' then
        if SureCheck('quit') then SCN.back('slowFade') end
    end
    return true
end

function scene.draw()
end

scene.widgetList={
    WIDGET.new{type='button',pos={.5,.5},w=300,x=-260,fontSize=60,text=LANG'home_zen',onClick=function() SCN.go('play',nil,'zen') end},
    WIDGET.new{type='button',pos={.5,.5},w=300,x=260,fontSize=60,text=LANG'home_dig',onClick=function() SCN.go('play',nil,'dig') end},

    WIDGET.new{type='button',pos={1,1},name='settings',y=-80,x=-CornerButtonX[2],w=160,h=80,text=LANG'home_settings',onClick=WIDGET.c_goScn('settings')},
    WIDGET.new{type='button',pos={1,1},name='quit',y=-80,sound_release=false,x=-CornerButtonX[1],w=160,h=80,text=LANG'home_quit',onClick=WIDGET.c_backScn()},
}
return scene
