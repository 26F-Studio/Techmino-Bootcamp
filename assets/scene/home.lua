---@type Zenitha.Scene
local scene={}

local noMouseHint=0
local maxX=9
local sel
local function restart()
    sel={
        x=sel and sel.x or (maxX+1)/2,
        charge=false,
        timeRem=0,
        dir=0,
    }
end
local buttons={
    moveLeft={
        onPress=function()
            sel.x=MATH.clamp(sel.x-1,1,maxX)
            sel.charge=0
            sel.dir=-1
        end,
        active=false,
    },
    moveRight={
        onPress=function()
            sel.x=MATH.clamp(sel.x+1,1,maxX)
            sel.charge=0
            sel.dir=1
        end,
        active=false,
    },
    hardDrop={
        onPress=function()
            if sel.x==1 then
                SCN.go('play','fade','std')
            elseif sel.x==2 then
                SCN.go('play','fade','dig')
            elseif sel.x==3 then
                SCN.go('play','fade','vs')
            elseif sel.x==maxX-2 then
                SCN.go('about')
                BG.send('menu',1)
            elseif sel.x==maxX-1 then
                SCN.go('config')
                BG.send('menu',-1)
            elseif sel.x==maxX then
                scene.keyDown('escape')
            end
        end,
        active=false,
    },
}

local helpText=GC.newText(FONT.get(40))
local helpText2=GC.newText(FONT.get(40))

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
    noMouseHint=0
    restart()
    helpText:set(Text.home_help1:repD(
        getHintKey('moveLeft','left'),
        getHintKey('moveRight','right'),
        getHintKey('hardDrop','return')
    ))
    helpText2:set(Text.home_help2)
    BG.set('menu')
    BG.send('menu',0)
end

function scene.unload()
    if SCN.stackChange<0 then
        SaveConf()
    end
end

function scene.mouseMove()
    if noMouseHint<0 then noMouseHint=0 end
end
function scene.mouseDown()
    noMouseHint=1.62
end

function scene.keyDown(key,isRep)
    if isRep then return true end
    noMouseHint=-1e99
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

function scene.update(dt)
    sel.timeRem=sel.timeRem+dt*1000*.8
    while sel.timeRem>=1 do
        if sel.charge then
            local l,r=buttons.moveLeft.active,buttons.moveRight.active
            if not l and not r then
                sel.charge=false
            elseif l~=r then
                if sel.dir==-1~=l then
                    sel.charge=0
                    sel.dir=l and -1 or 1
                end
            end
        end
        if sel.charge then
            sel.charge=sel.charge+1
            local SET=CONF.game_brik
            if sel.charge>=SET.asd and not (sel.dir==-1 and sel.x==1 or sel.dir==1 and sel.x==maxX) then
                if sel.charge>SET.asd then
                    if SET.asp==0 then
                        sel.x=sel.dir==-1 and 1 or maxX
                    else
                        if (sel.charge-SET.asd)%SET.asp==0 then
                            sel.x=MATH.clamp(sel.x+sel.dir,1,maxX)
                        end
                    end
                else
                    sel.x=MATH.clamp(sel.x+sel.dir,1,maxX)
                end
            end
        end
        sel.timeRem=sel.timeRem-1
    end
    if noMouseHint>0 then noMouseHint=noMouseHint-dt end
end

function scene.draw()
    GC.replaceTransform(SCR.xOy_m)

    -- Title
    GC.setColor(1,1,1)
    GC.mDraw(TEX.home_title[CONF.system.locale],0,-260,math.sin(love.timer.getTime())*.026,.5)

    GC.translate(0,126)
    -- Help
    GC_UIframe(true,0,254,1420,160)
    GC.setColor(CLR.dL)
    GC.mDraw(helpText, 0,220)
    GC.mDraw(helpText2, 0,280)

    -- Options
    local wid,height=170,260
    GC.setColor(1,1,1,.16)
    local selX=(sel.x-maxX/2-.5)*wid
    GC.mRect('fill',selX,0,wid,height)
    if Text.home_opt[sel.x] then
        GC.setColor(1,1,1,.42)
        GC.glowCircle(1, selX, -26, wid*.62)
    end

    GC.setLineWidth(2)
    FONT.set(50)
    for i=1,maxX do
        local x=(i-maxX/2-.5)*wid
        GC.setColor(CLR.L)
        GC.mRect('line', x, 0, wid, height)
        if Text.home_opt[i] then
            if sel.x~=i then GC.setShader(SHADER.mono) end
            GC.mDrawQ(TEX.home_icons,TEX.home_iconQuad[i],x,-26,0,.5)
            GC.setShader()
            GC.strokePrint('full',2,CLR.d5,sel.x==i and CLR.l7 or CLR.d2,Text.home_opt[i],x,50,600,'center')
        end
    end

    GC.replaceTransform(SCR.origin)
    GC.translate(love.mouse.getPosition())
    GC.scale(SCR.k)
    GC.setLineWidth(16)
    GC.setColor(1,.42,.42,.06+noMouseHint*.26)
    GC.circle('line',0,0,62)
    local r=36
    GC.line(-r,-r,r,r)
    if noMouseHint>0 then
        GC.replaceTransform(SCR.xOy_m)
        FONT.set(100)
        GC.setColor(1,1,1,noMouseHint)
        GC.mStr(Text.home_no_mouse,0,-126)
    end
end

return scene
