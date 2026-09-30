---@type Zenitha.Scene
local scene={}

local mode,act
local keyLangStr
local escTimer
local bgAlpha

function scene.load()
    bgAlpha=0
    TWEEN.new(function(t)
        bgAlpha=t*.7
    end):setDuration(.12):setUnique('keyset_bgAnim'):run()
    mode=SCN.args[1]
    act=SCN.args[2]
    keyLangStr='keysetHint_'..mode..'_'..act
    escTimer=false
end

function scene.keyDown(key,isRep)
    if isRep then return true end
    if key=='escape' and not escTimer then
        escTimer=1
    elseif key=='backspace' then
        local L=KM[mode]:getKeys(act)
        if L then TABLE.clear(L) end
        SCN.back('none',true)
    else
        escTimer=false
        if act==KM[mode]:getAction(key) then
            if not KM[mode]:remKey(key) then
                KM[mode]:addKey(act,key)
            end
        else
            KM[mode]:remKey(key)
            KM[mode]:addKey(act,key)
        end
        SCN.back('none',true)
    end
    return true
end

function scene.update(dt)
    if escTimer then
        escTimer=escTimer-dt*1.626
        if escTimer<=0 then
            SCN.back('none')
        end
    end
end

function scene.draw()
    SCN.scenes.keyset.draw()

    GC.origin()
    GC.setColor(.42,.42,.42,escTimer and escTimer*.7 or bgAlpha)
    GC.rectangle('fill',0,0,SCR.w,SCR.h)

    if escTimer then
        GC.setColor(0,0,0,.1)
        local r=escTimer*SCR.w/2
        GC.rectangle('fill',SCR.w/2-r,SCR.h*.45,r*2,SCR.h*.1,5)
    end

    GC.replaceTransform(SCR.xOy_m)
    FONT.set(100) GC.strokePrint('full',4,COLOR.D,COLOR.L,Text[keyLangStr],0,-200,nil,'center')
    FONT.set(60)  GC.strokePrint('full',2,COLOR.D,COLOR.L,Text.keyset_pressKey,0,-40,nil,'center')
    FONT.set(35)  GC.strokePrint('full',2,COLOR.D,COLOR.L,Text.keyset_info,0,80,nil,'center')
end

scene.widgetList={
    {type='button',pos={1,1},x=-CornerButtonX[1],y=-80,w=140,h=80,fillColor='I',sound_release='button_back',text=LANG'back',onClick=WIDGET.c_backScn('none')},
}

return scene
