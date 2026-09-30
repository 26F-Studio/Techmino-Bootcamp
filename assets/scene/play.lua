---@type Zenitha.Scene
local scene={}

function scene.load()
    if SCN.args[1] then
        GAME.unload()
        GAME.load(SCN.args[1])
    end
    WIDGET._reset()
end
function scene.unload()
    if SCN.stackChange<0 then
        GAME.unload()
    end
end

local function sysAction(action)
    if action=='restart' then
        if GAME.playing then
            local id=GAME.mode.name
            GAME.unload()
            GAME.load(id)
        end
    elseif action=='back' then
        SCN.swapTo('pause','none')
    end
end
function scene.keyDown(key,isRep)
    if isRep then return true end

    local action

    local p=GAME.mainPlayer
    if p then
        action=KM.game:getAction(key)
        if action then
            GAME.press(action)
            return true
        end
    end

    sysAction(KM.sys:getAction(key))
    return true
end
function scene.keyUp(key)
    local action

    local p=GAME.mainPlayer
    if p then
        action=KM.game:getAction(key)
        if action then
            GAME.release(action)
            return
        end
    end
end

function scene.update(dt)
    GAME.update(dt)
end

function scene.draw()
    GAME.render()
end

scene.widgetList={
    BackButtonBR,
}
return scene
