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

function scene.draw()
    GC.setColor(1,1,1)
    FONT.set(40)
    GC.print(Text.about_title,120,90,0,2.6)
    for i=1,#Text.about_text do
        GC.print(Text.about_text[i],120,230+60*i)
    end

    GC_UIframe(false,80,260,1600-80*2,540)
end

scene.widgetList={
    BackButtonBR,
}
return scene
