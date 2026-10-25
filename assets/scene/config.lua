---@type Zenitha.Scene
local scene={}

local rotText={[0]='0','R','2','L'}
local mino ---@type Techmino.KeysetMino
local changed

local moodList={'shy','angry','nervous'}
local zMood='normal' ---@type 'normal' | 'shy' | 'angry' | 'nervous'
local zPower=0
local zAnim=0

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
    {x=-2,y=0,cat='sys', act='restart',  onPress=function() restart() end},
    {x=-2,y=1,cat='sys', act='back',     onPress=function() end},

    {x=-1,y=0,cat='game',act='rotateCCW',onPress=function() mino.rotation=(mino.rotation-1)%4 end},
    {x=0, y=0,cat='game',act='rotate180',onPress=function() mino.rotation=(mino.rotation+2)%4 end},
    {x=1, y=0,cat='game',act='rotateCW', onPress=function() mino.rotation=(mino.rotation+1)%4 end},
    {
        x=-1,
        y=1,
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
        y=1,
        cat='game',
        act='holdPiece',
        onPress=function()
            mino.color=string.gsub(mino.color,'(.)(.)(.)',f and '%2%1%3' or '%1%3%2')+0
            f=not f
        end,
    },
    {
        x=1,
        y=1,
        cat='game',
        act='moveRight',
        onPress=function()
            mino.x=MATH.clamp(mino.x+1,-4,4)
            mino.charge=0
            mino.dir=1
        end,
    },
    {x=-1,y=2,cat='game',act='func1',   onPress=function() end},
    {x=0, y=2,cat='game',act='softDrop',onPress=function() mino.softDropTime=love.timer.getTime() end},
    {x=1, y=2,cat='game',act='hardDrop',onPress=function() end},
}
local a=180
for i=1,#buttons do
    buttons[i].active=false
    buttons[i].x=(buttons[i].x+.5)*a
    buttons[i].y=buttons[i].y*a
    buttons[buttons[i].act]=buttons[i]
end

function scene.load()
    zMood='normal'
    zPower=0
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
    if SCN.stackChange<0 then
        SaveConf()
    end
end

local function task_zAnim(t) zAnim=1-t end
local function pet()
    zPower=math.min(zPower+1,6.26)
    if zMood=='normal' then
        if zPower>4.2 then
            zMood=TABLE.getRandom(moodList)
        end
    end
    TWEEN.new(task_zAnim):setUnique('zAnim'):setDuration(.62):setEase('OutElastic'):run()
end

function scene.mouseDown(x,y)
    x,y=SCR.xOy_ur:inverseTransformPoint(SCR.xOy:transformPoint(x,y))
    if x>=-456*.5 and y<=420*.5 then
        pet()
    end
end

function scene.keyDown(key,isRep)
    if isRep then return true end
    if key=='z' then
        pet()
    end
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
    zPower=math.max(zPower-dt*1.26,0)
    if zMood~='normal' and zPower<2.6 then
        zMood='normal'
    end
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

local iconKey={
    [5]='force180',
    [6]='noFault',
    [7]='noStuck',
}
function scene.draw()
    GC.replaceTransform(SCR.xOy_m)

    -- Keybindings
    GC.translate(-300,0)
    GC_UIframe(true,0,180,730,550)
    FONT.set(35)
    for i=1,#buttons do
        local b=buttons[i]
        if b.active then
            GC.setColor(1,1,1,.26)
            GC.glowCircle(1,b.x,b.y,100)
        end
        GC.setColor(CLR.L)
        GC.mRect('line',b.x,b.y,160,160,10)
        GC.setColor(1,1,1,.26)
        GC.mDrawQ(TEX.actionIcons.texture,TEX.actionIcons.quads[b.act],b.x,b.y,nil,.8)
        GC.setColor(CLR.DL)
        local keys=KM[b.cat]:getKeys(b.act)
        for j=1,#keys do
            GC.mStr(keys[j],b.x,b.y-40+30*j-#keys*15)
        end
    end

    -- Input Test
    do
        GC.translate(0,-460)
        local w=40
        -- Board
        GC_UIframe(false,-5*w-10,-10,10*w+20,8*w+40)
        GC.setColor(.26,.26,.26,.42)
        GC.rectangle('fill',-5*w,0,10*w,8*w+20,6)
        -- Grid line
        GC.setLineWidth(2)
        GC.setColor(CLR.LD)
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
        GC.strokePrint('full',3,CLR.D,CLR.L,rotText[mino.rotation],0,0,2*w,'center',0,2,2,w/2,20)
    end

    -- Zita
    GC.replaceTransform(SCR.xOy_ur)
    GC.setColor(1,1,1)
    local w,h=456,420
    GC.draw(
        TEX.z[(WIDGET.sel==scene.widgetList[3] or WIDGET.sel==scene.widgetList[4]) and 'question' or zMood],
        -w/2*.5,0,3.1416,zAnim*.0626+.5,-zAnim*.0626+.5,w/2,h
    )

    -- Widget Outlines
    GC.replaceTransform(SCR.xOy)
    for i=3,4 do
        local W=scene.widgetList[i]
        GC_UIframe(false,W.x-50,W.y-50,610,100)
    end
    for i=5,7 do
        local W=scene.widgetList[i]
        GC_UIframe(false,W.x-50,W.y-40,470,80)
        GC.setColor(i==6 and CLR.l5Y or CLR.l7)
        if CONF.system[iconKey[i]] then
            GC.mDraw(TEX.icon[iconKey[i]],W.x-50,W.y-40,0,.16)
        end
    end
    for i=8,9 do
        local W=scene.widgetList[i]
        GC_UIframe(false,W.x-50,W.y-40,350,80)
    end
end

local function sliderShow_time(S) return S.disp().." ms" end

scene.widgetList={
    -- Settings
    WIDGET.new{type='slider',x=920,y=140,w=400,text="ASD",axis={60,160,5},unit=10,disp=TABLE.func_getVal(CONF.game_brik,'asd'),valueShow=sliderShow_time,code=TABLE.func_setVal(CONF.game_brik,'asd')},
    WIDGET.new{type='slider',x=920,y=290,w=260,text="ASP",axis={0,15,5},disp=TABLE.func_getVal(CONF.game_brik,'asp'),valueShow=sliderShow_time,
        code=function(v)
            CONF.game_brik.asp=v
            CONF.game_brik.adp=v
        end},
    WIDGET.new{type='hint',x=800,y=140,w=50,fontSize=40,floatText=LANG'config_hint_asd',text="?"},
    WIDGET.new{type='hint',x=800,y=290,w=50,fontSize=40,floatText=LANG'config_hint_asp',text="?"},

    WIDGET.new{type='checkBox',x=940,y=460,w=40,labelPos='right',text=LANG'config_force180',disp=TABLE.func_getVal(CONF.system,'force180'),code=TABLE.func_revVal(CONF.system,'force180')},
    WIDGET.new{type='checkBox',x=940,y=570,w=40,labelPos='right',text=LANG'config_noFault',disp=TABLE.func_getVal(CONF.system,'noFault'),code=TABLE.func_revVal(CONF.system,'noFault')},
    WIDGET.new{type='checkBox',x=940,y=680,w=40,labelPos='right',text=LANG'config_noStuck',disp=TABLE.func_getVal(CONF.system,'noStuck'),code=TABLE.func_revVal(CONF.system,'noStuck')},
    WIDGET.new{type='checkBox',x=940,y=790,w=40,labelPos='right',text=LANG'config_fullscreen',disp=TABLE.func_getVal(CONF.system,'fullscreen'),code=TABLE.func_revVal(CONF.system,'fullscreen')},
    WIDGET.new{type='checkBox',x=940,y=900,w=40,labelPos='right',text=LANG'config_locale',disp=function() return CONF.system.locale=='en' end,code=function()
        CONF.system.locale=CONF.system.locale=='en' and 'zh' or 'en'
        WIDGET._reset()
    end},

    WIDGET.new{type='button',x=230,y=860,w=140,h=80,color='R',text=LANG'keyset_reset',onClick=function() if SureCheck('keyset_reset') then resetKeymap() end end},
    WIDGET.new{type='button',pos={1,1},x=-CornerButtonX[1],y=-80,w=140,h=80,text=LANG'back',onClick=WIDGET.c_backScn()},
}

for i=1,#buttons do
    local b=buttons[i]
    table.insert(scene.widgetList,WIDGET.new{
        type='hint',
        pos={.5,.5},
        x=b.x-300,y=b.y,w=a-20,h=a-20,
        text="",frameColor='X',
        floatText=LANG('keysetHint_'..b.cat..'_'..b.act),
        labelPos='top',
        onPress=function() SCN.go('keyset_press','none',buttons[i].cat,buttons[i].act) end,
    })
end

return scene
