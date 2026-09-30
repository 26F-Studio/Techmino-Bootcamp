function SureCheck(event,t)
    if TASK.lock('sureCheck_'..event,t or 1) then
        MSG('info',Text.sureText[event],t or 1)
    else
        return true
    end
end

function SaveConf()
    FILE.save({
        system=CONF._system,
        game_brik=CONF.game_brik,
        misc=CONF.misc,
    },'conf/config','-json')
end

IsMouseDown=love.mouse.isDown
IsKeyDown=love.keyboard.isDown
function IsCtrlDown() return IsKeyDown('lctrl','rctrl') end
function IsShiftDown() return IsKeyDown('lshift','rshift') end
function IsAltDown() return IsKeyDown('lalt','ralt') end

local sandBoxEnv={
    math=math,
    string=string,
    table=table,
    coroutine=coroutine,
    assert=assert,
    error=error,
    tonumber=tonumber,
    tostring=tostring,
    select=select,
    next=next,
    ipairs=ipairs,
    pairs=pairs,
    type=type,
    pcall=pcall,
    xpcall=xpcall,
    rawget=rawget,
    rawset=rawset,
    rawlen=rawlen,
    rawequal=rawequal,
    setmetatable=setmetatable,
}
function SetSafeEnv(func)
    sandBoxEnv.mechLib=mechLib -- Update in case it changes during game
    setfenv(func,TABLE.copyAll(sandBoxEnv))
end
