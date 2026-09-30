---@type Zenitha.Scene
local scene={}

local rotText={[0]='0','R','2','L'}
local mino ---@type Techmino.KeysetMino
local changed

local function restart()
    ---@class Techmino.KeysetMino
    ---@field charge false | integer
    ---@field dir false | -1 | 1
    mino={
        x=0,
        color=984,
        charge=false,
        dir=false,
        timeRem=0,
        softDropTime=0,
        rotation=0,
    }
end

local function resetKeymap()
    changed=true
    KM.game=KEYMAP.new{
        {act='moveLeft', keys={'left'}},
        {act='moveRight',keys={'right'}},
        {act='rotateCW', keys={'up'}},
        {act='rotateCCW',keys={'down'}},
        {act='rotate180',keys={}},
        {act='softDrop', keys={'x'}},
        {act='hardDrop', keys={'z'}},
        {act='holdPiece',keys={'space'}},
        {act='func1',    keys={'a'}},
        {act='func2',    keys={'s'}},
    }
    KM.sys=KEYMAP.new{
        {act='restart',keys={'r'}},
        {act='back',   keys={'escape'}},
    }
end

local f=false
local buttons={
    {x=-2.25,y=-3,cat='sys', act='restart',  onPress=function() restart() end},
    {x=-2.25,y=-2,cat='sys', act='back',     onPress=function() end},

    {x=-1,   y=-3,cat='game',act='rotateCCW',onPress=function() mino.rotation=(mino.rotation-1)%4 end},
    {x=0,    y=-3,cat='game',act='rotate180',onPress=function() mino.rotation=(mino.rotation+2)%4 end},
    {x=1,    y=-3,cat='game',act='rotateCW', onPress=function() mino.rotation=(mino.rotation+1)%4 end},
    {
        x=-1,
        y=-2,
        cat='game',
        act='moveLeft',
        onPress=function()
            mino.x=MATH.clamp(mino.x-1,-4,4)
            mino.charge=0
            mino.dir=-1
        end,
    },
    {
        x=0,
        y=-2,
        cat='game',
        act='holdPiece',
        onPress=function()
            mino.color=string.gsub(mino.color,'(.)(.)(.)',f and '%2%1%3' or '%1%3%2')+0
            f=not f
        end,
    },
    {
        x=1,
        y=-2,
        cat='game',
        act='moveRight',
        onPress=function()
            mino.x=MATH.clamp(mino.x+1,-4,4)
            mino.charge=0
            mino.dir=1
        end,
    },
    -- {x=-1,y=-1,cat='game',act='func1',   onPress=function() end},
    -- {x=0, y=-1,cat='game',act='func2',   onPress=function() end},
    {x=0,y=-1,cat='game',act='softDrop',onPress=function() mino.softDropTime=love.timer.getTime() end},
    {x=1,y=-1,cat='game',act='hardDrop',onPress=function() end},
}
local a=180
for i=1,#buttons do
    buttons[i].active=false
    buttons[i].x=(buttons[i].x+.5)*a
    buttons[i].y=buttons[i].y*a
    buttons[buttons[i].act]=buttons[i]
end

function scene.load()
    if SCN.stackChange>0 then
        changed=false
        restart()
    elseif SCN.stackChange<0 and SCN.args[1] then
        changed=true
    end
end

function scene.unload()
    if changed then
        FILE.save({
            game=KM.game:export(),
            sys=KM.sys:export(),
        },'conf/keymap','-json')
    end
end

function scene.keyDown(key,isRep)
    if isRep then return true end
    if KM.sys:getAction(key)=='back' then
        SFX.play('button_back')
        SCN.back()
    else
        local act=KM.sys:getAction(key)
        if not act then act=KM.game:getAction(key) end
        local b=buttons[act]
        if b then
            b.active=true
            b.onPress()
        end
    end
    return true
end

function scene.keyUp(key)
    local act=KM.sys:getAction(key)
    if not act then act=KM.game:getAction(key) end
    local b=buttons[act]
    if b then b.active=false end
end

function scene.update(dt)
    mino.timeRem=mino.timeRem+dt*1000
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
            if mino.charge>=SET.asd and (mino.x~=4*mino.dir) then
                if mino.charge>SET.asd then
                    if SET.asp==0 then
                        mino.x=4*mino.dir
                    else
                        if (mino.charge-SET.asd)%SET.asp==0 then
                            mino.x=MATH.clamp(mino.x+mino.dir,-4,4)
                        end
                    end
                else
                    mino.x=MATH.clamp(mino.x+mino.dir,-4,4)
                end
            end
        end
        mino.timeRem=mino.timeRem-1
    end
end

function scene.draw()
    GC.origin()
    GC.setColor(0,0,0,.42)
    GC.rectangle('fill',0,0,SCR.w,SCR.h)
    GC.replaceTransform(SCR.xOy_d)
    GC.setLineWidth(4)
    FONT.set(35)
    for i=1,#buttons do
        local b=buttons[i]
        if b.active then
            GC.setColor(0,0,0,.26)
            GC.mRect('fill',b.x,b.y,160,160)
        end
        GC.setColor(CLR.L)
        GC.mRect('line',b.x,b.y,160,160)
        GC.setColor(1,1,1,.26)
        GC.mDrawQ(TEX.actionIcons.texture,TEX.actionIcons.quads[b.act],b.x,b.y,nil,.8)
        GC.setColor(COLOR.DL)
        local keys=KM[b.cat]:getKeys(b.act)
        for j=1,#keys do
            GC.mStr(keys[j],b.x,b.y-40+30*j-#keys*15)
        end
    end

    -- Demo
    GC.replaceTransform(SCR.xOy_u)
    GC.translate(0,20)
    local w=40
    -- Board
    GC.setColor(COLOR.D)
    GC.rectangle('fill',-5*w-6,0,10*w+12,8*w+26)
    GC.setColor(COLOR.LD)
    GC.rectangle('fill',-5*w,0,10*w,8*w+20)
    -- Grid line
    GC.setLineWidth(2)
    GC.setColor(COLOR.DL)
    for x=-4,4 do GC.line(x*w,8*w+20,x*w,0) end
    for y=1,8 do
        local h=(8-y)*w+20
        GC.line(-5*w,h,5*w,h)
    end
    -- Piece
    GC.setColor(RGB9[mino.color])
    GC.translate(mino.x*w,20+(buttons.hardDrop.active and 7 or buttons.softDrop.active and math.floor((love.timer.getTime()-mino.softDropTime)%.25*4*6+1) or 1)*w)
    GC.rectangle('fill',-w,-w,2*w,2*w)
    FONT.set(30)
    GC.strokePrint('full',3,COLOR.D,COLOR.L,rotText[mino.rotation],0,0,2*w,'center',0,2,2,w/2,20)
end

scene.widgetList={
    WIDGET.new{type='button',pos={1,1},x=-CornerButtonX[2],y=-80,w=140,h=80,text=LANG'keyset_reset',onClick=function() if SureCheck('keyset_reset') then resetKeymap() end end},
    BackButtonBR,
}

for i=1,#buttons do
    local b=buttons[i]
    table.insert(scene.widgetList,WIDGET.new{
        type='hint',
        pos={.5,1},
        x=b.x,y=b.y,w=a-20,h=a-20,
        text="",frameColor='X',
        floatText=LANG('keysetHint_'..b.cat..'_'..b.act),
        labelPos='top',
        onPress=function() SCN.go('keyset_press','none',buttons[i].cat,buttons[i].act) end,
    })
end

return scene
