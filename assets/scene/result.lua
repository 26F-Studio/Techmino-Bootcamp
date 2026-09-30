---@type Zenitha.Scene
local scene={}

local time

function scene.load()
    time=0
end
function scene.unload()
    if SCN.stackChange<0 then
        GAME.unload()
    end
end

function scene.keyDown(key,isRep)
    if isRep then return true end
    local action=KM.sys:getAction(key)
    if action=='restart' then
        SCN.swapTo('play','none',GAME.mode.name)
    elseif action=='back' then
        SFX.play('button_back')
        SCN.back()
    end
    return true
end

function scene.update(dt)
    GAME.update(dt*.26)
    time=time+dt
end

function scene.draw()
    SCN.scenes['play'].draw()

    GC.setCanvas(ZENITHA.bigCanvas.result)
    GC.clear(0,0,0,0)
    GC.replaceTransform(SCR.xOy)
    GAME.mode.resultPage(time)
    GC.setCanvas()

    GC.origin()
    GC.setColor(.06,.06,.06,math.min(time,.626))
    GC.rectangle('fill',0,0,SCR.w,SCR.h)

    GC.setColor(1,1,1)
    GC.draw(ZENITHA.bigCanvas.result)
end

scene.widgetList={
    BackButtonBR
}
return scene
