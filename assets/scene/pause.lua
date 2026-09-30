---@type Zenitha.Scene
local scene={}

local animT1 -- Animation timer (0~1, different speed)
local quitHold,quitTimer

function scene.load()
    quitHold=false
    quitTimer=-.2
    if SCN.stackChange<0 then return end
    animT1=0
    TWEEN.new(function(t)
        animT1=t
        scene.widgetList.U.y=-MATH.lerp(100,140,t)
        scene.widgetList.D.y=MATH.lerp(100,140,t)
        scene.widgetList.U:resetPos()
        scene.widgetList.D:resetPos()
    end):setEase('OutQuint'):setDuration(0.26):run()
end
function scene.unload()
    if SCN.stackChange<0 then
        GAME.unload()
    end
end

local function menuAct(action)
    if action=='back' then
        SCN.back()
    elseif action=='continue' then
        SCN.swapTo('play','none')
    elseif action=='restart' then
        if GAME.playing then
            SCN.swapTo('play','none',GAME.mode.name)
        end
    elseif action=='settings' then
        SCN.go('settings')
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
    GC.setColor(.6,.6,.6,.6*animT1)
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
