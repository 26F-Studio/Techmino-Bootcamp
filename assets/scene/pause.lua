---@type Zenitha.Scene
local scene={}

local quitHold,quitTimer

function scene.load()
    quitHold=false
    quitTimer=-.2
    if SCN.stackChange<0 then return end
end
function scene.unload()
    if SCN.stackChange<0 then
        GAME.unload()
    end
end

local function menuAct(action)
    if action=='back' then
        SCN.back('fade')
    elseif action=='continue' then
        SCN.swapTo('play','none')
    elseif action=='restart' then
        SCN.swapTo('play','none',GAME.mode.name)
    elseif action=='settings' then
        SCN.go('config')
    end
end
function scene.keyDown(key,isRep)
    if isRep then return true end
    if KM.sys:getAction(key)=='back' then
        quitHold=true
    elseif KM.sys:getAction(key)=='restart' then
        menuAct('restart')
    elseif key=='s' then
        menuAct('settings')
    end
    return true
end

function scene.keyUp(key)
    if quitHold and KM.sys:getAction(key)=='back' then
        quitHold=false
        if quitTimer<0 then
            menuAct('continue')
        end
    end
end

function scene.update(dt)
    if quitHold then
        quitTimer=math.min(quitTimer+dt*2.26,1)
        if quitTimer>=1 then
            quitHold=false
            menuAct('back')
        end
    elseif not SCN.swapping then
        quitTimer=math.max(quitTimer-dt*2.6,-.26)
    end
end

function scene.draw()
    GAME.render()

    GC.origin()
    GC.setColor(.2,.2,.2,.6)
    GC.rectangle('fill',0,0,SCR.w,SCR.h)

    GC.replaceTransform(SCR.xOy_m)

    if quitTimer>0 then
        GC.setColor(1,1,1,quitTimer^.5*.42)
        GC.arc('fill','pie',0,0,260,-1.57,-1.57+quitTimer*6.2832)
    end
end

scene.widgetList={
    WIDGET.new{type='button',name='B',pos={0,0},x=120,y=80,w=160,h=80,text=LANG'pause_leave',sound_release=false,onClick=function() menuAct('back') end},
    WIDGET.new{type='button',name='U',pos={.5,.5},x=0,y=-140,w=180,h=90,text=LANG'pause_retry',sound_release=false,onClick=function() menuAct('restart') end},
    WIDGET.new{type='button',name='M',pos={.5,.5},x=0,y=0,w=180,h=90,text=LANG'pause_resume',sound_release=false,onClick=function() menuAct('continue') end},
    WIDGET.new{type='button',name='D',pos={.5,.5},x=0,y=140,w=180,h=90,text=LANG'pause_settings',sound_release=false,onClick=function() menuAct('settings') end},
}
return scene
