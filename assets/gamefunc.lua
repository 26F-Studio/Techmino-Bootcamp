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

function GC_UIframe(mid,x,y,w,h)
    GC.setColor(.8,.7,.6,.62)
    GC.setLineWidth(4)
    if mid then x,y=x-w/2,y-h/2 end
    GC.rectangle('line',x,y,w,h,20)
    GC.arc('fill','open',x+w-20,y+20,15,0,-1.5708)
    GC.polygon('fill',
        x+w-20-15,y+20-15,
        x+w-20,y+20-15,
        x+w-20+15,y+20,
        x+w-20+15,y+20+15
    )
end
