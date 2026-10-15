---@type Zenitha.Scene
local scene={}

local maxX=9
local mino
local function restart()
    mino={
        x=(maxX+1)/2,
        charge=false,
        timeRem=0,
        dir=0,
    }
end
local buttons={
    moveLeft={
        onPress=function()
            mino.x=MATH.clamp(mino.x-1,1,maxX)
            mino.charge=0
            mino.dir=-1
        end,
        active=false,
    },
    moveRight={
        onPress=function()
            mino.x=MATH.clamp(mino.x+1,1,maxX)
            mino.charge=0
            mino.dir=1
        end,
        active=false,
    },
    hardDrop={
        onPress=function()
            if mino.x==1 then
                SCN.go('play',nil,'std')
            elseif mino.x==2 then
                SCN.go('play',nil,'dig')
            elseif mino.x==3 then
                MSG('info',"Coming soon!")
                -- SCN.go('play',nil,'vs')
            elseif mino.x==maxX-2 then
                SCN.go('about')
            elseif mino.x==maxX-1 then
                SCN.go('settings')
            elseif mino.x==maxX then
                scene.keyDown('escape')
            end
        end,
        active=false,
    },
}

local helpText=GC.newText(FONT.get(40))

local overrideAct={left='moveLeft',right='moveRight',['return']='hardDrop'}
local function getHintKey(action,fallback)
    local keys=KM.game:getKeys(action)
    if keys then
        for _,k in next,keys do
            if not overrideAct[k] or overrideAct[k]==action then
                return KeyAlias[k]
            end
        end
    end
    return KeyAlias[fallback]
end

function scene.load()
    restart()
    helpText:set(Text.home_help1:repD(
        getHintKey('moveLeft','left'),
        getHintKey('moveRight','right'),
        getHintKey('hardDrop','return')
    ))
end

function scene.unload()
    if SCN.stackChange<0 then
        SaveConf()
    end
end

function scene.update(dt)
    mino.timeRem=mino.timeRem+dt*1000*.8
    while mino.timeRem>=1 do
        if mino.charge then
            local l,r=buttons.moveLeft.active,buttons.moveRight.active
            if not l and not r then
                mino.charge=false
            elseif l~=r then
                if mino.dir==-1~=l then
                    mino.charge=0
                    mino.dir=l and -1 or 1
                end
            end
        end
        if mino.charge then
            mino.charge=mino.charge+1
            local SET=CONF.game_brik
            if mino.charge>=SET.asd and not (mino.dir==-1 and mino.x==1 or mino.dir==1 and mino.x==maxX) then
                if mino.charge>SET.asd then
                    if SET.asp==0 then
                        mino.x=mino.dir==-1 and 1 or maxX
                    else
                        if (mino.charge-SET.asd)%SET.asp==0 then
                            mino.x=MATH.clamp(mino.x+mino.dir,1,maxX)
                        end
                    end
                else
                    mino.x=MATH.clamp(mino.x+mino.dir,1,maxX)
                end
            end
        end
        mino.timeRem=mino.timeRem-1
    end
end

function scene.keyDown(key,isRep)
    if isRep then return true end
    if KM.sys:getAction(key)=='back' then
        if SureCheck('quit') then SCN.back('slowFade') end
    else
        local act=overrideAct[key] or KM.game:getAction(key)
        local b=buttons[act]
        if b then
            b.active=true
            b.onPress()
        end
    end
    return true
end
function scene.keyUp(key)
    local act=overrideAct[key]
    if not act then
        act=KM.sys:getAction(key)
        if not act then act=KM.game:getAction(key) end
    end
    local b=buttons[act]
    if b then b.active=false end
end

function scene.draw()
    GC.replaceTransform(SCR.xOy_m)
    GC.setColor(1,1,1)

    -- Title
    GC.setColor(1,1,1)
    GC.mDraw(TEX.home_title[CONF.system.locale],0,-300,math.sin(love.timer.getTime())*.026)

    -- Help
    GC.mDraw(helpText, 0,260)
    FONT.set(40)
    GC.mStr(Text.home_help2, 0,290)

    -- Options
    GC.setLineWidth(2)
    local wid,height=170,260
    FONT.set(50)
    for i=1,maxX do
        local x=(i-maxX/2-.5)*wid
        GC.mRect('line', x, 0, wid, height)
        if Text.home_opt[i] then
            GC.mDraw(TEX.home_icons[i],x,-40)
            GC.mStr(Text.home_opt[i],x,50)
        end
    end
    GC.setColor(1,1,1,.26)
    local selX=(mino.x-maxX/2-.5)*wid
    GC.mRect('fill',selX,0,wid,height)
end

return scene
