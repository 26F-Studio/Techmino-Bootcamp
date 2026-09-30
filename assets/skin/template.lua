local gc=love.graphics
local gc_push,gc_pop=gc.push,gc.pop
local gc_scale,gc_rotate=gc.scale,gc.rotate
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_draw,gc_line=gc.draw,gc.line
local gc_rectangle=gc.rectangle
local gc_printf=gc.printf

local max,min=math.max,math.min

local COLOR=COLOR

---@type Techmino.Skin
local S={}

local colors={
    fieldBG={.26,.26,.26,.872},
    fieldLine={1,1,1},
    fieldTopline={1,1,1,.26},
    grid={1,1,1,.1},
    nextBG={.26,.26,.26,.942},
    holdBG={.26,.26,.26,.942},
    disabled={.6,.6,.6},
    infoBG={.62,.62,.62,.942},

    ghost={1,1,1,.162},
    handStroke={1,1,1},
}

local R=1
local gridMark=GC.load{w=40,
    {'fRect',0, 0, 40, R},
    {'fRect',0, 40, 40, -R},
    {'fRect',0, R, R, 40-2*R},
    {'fRect',40, R, -R, 40-2*R},
}
local gridBatch=GC.newSpriteBatch(gridMark,2600,'static')
local lastW
function S.drawFieldBackground(fieldW)
    gc_setColor(colors.fieldBG)
    gc_rectangle('fill',0,0,40*fieldW,-80*fieldW)
    gc_draw(TEX.transition,0,-80*fieldW,-math.pi/2,94/128,40*fieldW)
    if fieldW~=lastW then
        lastW=fieldW
        gridBatch:clear()
        for y=1,2*fieldW do for x=1,fieldW do
            gridBatch:add(x*40-40,-y*40)
        end end
    end
    gc_setColor(colors.grid)
    gc_draw(gridBatch)
end

function S.drawFieldBorder()
    gc_setLineWidth(2)
    gc_setColor(colors.fieldLine)
    gc_line(-201,-401,-201,401,201,401,201,-401)
    gc_draw(TEX.transition,-201,-401,-math.pi/2,96/128,2,0,.5)
    gc_draw(TEX.transition,201,-401,-math.pi/2,96/128,2,0,.5)
    gc_setColor(colors.fieldTopline)
    gc_line(-201,-401,201,-401)
end

function S.drawFieldCell(C)
    local r,g,b=unpack(RGB9[C.color])
    local a=C.alpha or 1
    gc_setColor(r,g,b,a)
    gc_rectangle('fill',0,0,40,40)
end

function S.drawFloatHoldCell(C,disabled,_,_,_)
    if disabled then
        gc_setColor(.6,.6,.6,.25)
    else
        local r,g,b=unpack(RGB9[C.color])
        gc_setColor(r,g,b,S.getTime()%150/200)
    end
    gc_rectangle('fill',0,0,40,40)
end

function S.drawFloatHoldMark(n,disabled)
    gc_setColor(disabled and COLOR.DL or COLOR.L)
    FONT.set(50)
    GC.mStr(n,0,5)
end

function S.drawHeightLines(fieldW,maxSpawnH,spawnH,lockoutH,deathH,voidH)
    -- gc_setColor(.0,.4,1.,S.getTime()%600<300 and .3 or .5) gc_rectangle('fill',0,-maxSpawnH-1 ,fieldW,2)
    -- gc_setColor(.0,.4,1.,.8) gc_rectangle('fill',0,-spawnH   -1 ,fieldW,2)
    -- gc_setColor(1.,.5,.0,.6) gc_rectangle('fill',0,-lockoutH -1 ,fieldW,2)
    -- gc_setColor(1.,.0,.0,.6) gc_rectangle('fill',0,-deathH   -1 ,fieldW,2)
    -- gc_setColor(.0,.0,.0,.6) gc_rectangle('fill',0,-voidH    -40,fieldW,40)
end

function S.drawAsdIndicator(dir,charge,asdMax,aspMax,ash)
end

function S.drawDelayIndicator(color,value)
    -- gc_setColor(color)
    -- gc_rectangle('fill',-199,403,398*math.min(value,1),8)

    -- gc_setLineWidth(2)
    -- gc_setColor(1,1,1)
    -- gc_rectangle('line',-201,401,402,12)
end

function S.drawGarbageBuffer(garbageBuffer)
    -- local y=0
    -- for i=1,#garbageBuffer do
    --     local g=garbageBuffer[i]
    --     local h=g.power*40
    --     if y+h>800 then
    --         h=800-y
    --     end
    --     if g._time<g.time then
    --         gc_setColor(COLOR.R)
    --         gc_rectangle('fill',210,400-y-h+3,10,h-6)
    --         gc_setColor(COLOR.L)
    --         local progress=g._time/g.time
    --         gc_rectangle('fill',210,400-y-h+3+(h-6)*(1-progress),10,(h-6)*progress)
    --     else
    --         gc_setColor(S.getTime()%100<50 and COLOR.R or COLOR.L)
    --         gc_rectangle('fill',210,400-y-h+3,10,h-6)
    --     end
    --     y=y+h
    --     if y>=800 then break end
    -- end
end

function S.drawLockDelayIndicator(freshCondition,freshChance,timeRem)
    -- if timeRem>0 then
    --     gc_setColor(COLOR.HSV(timeRem/2.6,.4,.9,.62))
    --     gc_rectangle('fill',-200,415,400*timeRem,14)
    -- end
    -- if freshChance>0 then
    --     freshChance=min(freshChance,15)
    --     gc_setColor(
    --         freshCondition=='any' and COLOR.dL or
    --         freshCondition=='fall' and COLOR.R or
    --         freshCondition=='none' and COLOR.D or
    --         COLOR.rainbow(4)
    --     )
    --     stc_reset()
    --     stc_rect(-200,415,400*timeRem,14)
    --     for i=1,freshChance do gc_rectangle('fill',-218+26*i-1,420-1,20+2,5+2) end
    --     gc_setColor(COLOR.HSV(freshChance/(14*2.6),.4,.9))
    --     for i=1,freshChance do gc_rectangle('fill',-218+26*i,420,20,5) end
    --     stc_stop()
    --     gc_setColor(COLOR.HSV(freshChance/(14*2.6),.4,.9,.62))
    --     for i=1,freshChance do gc_rectangle('fill',-218+26*i,420,20,5) end
    -- end
end

function S.drawGhostCell()
    gc_setColor(colors.ghost)
    gc_rectangle('fill',0,0,40,40)
end

local strokeR=4
function S.drawHandCellStroke()
    gc_setColor(colors.handStroke)
    gc_rectangle('fill',-strokeR,-strokeR,40+2*strokeR,40+2*strokeR)
end

function S.drawHandCell(C)
    gc_setColor(RGB9[C.color])
    gc_rectangle('fill',0,0,40,40)
end

function S.drawNextBorder(slot)
    if slot<=0 then return end
    gc_setColor(colors.nextBG)
    gc_rectangle('fill',30,0,140,100*slot)
    gc_setLineWidth(2)
    gc_setColor(COLOR.L)
    gc_rectangle('line',30,0,140,100*slot)
end

function S.drawNextCell(C,disabled,_,_,_)
    gc_setColor(disabled and colors.disabled or RGB9[C.color])
    gc_rectangle('fill',0,0,40,40)
end

function S.drawHoldBorder(mode,slot)
    if slot<=0 then return end
    gc_setLineWidth(2)
    if mode=='hold' then
        gc_setColor(colors.holdBG)
        gc_rectangle('fill',-170,0,140,100*slot)
        gc_setColor(COLOR.L)
        gc_rectangle('line',-170,0,140,100*slot)
    elseif mode=='swap' then
        gc_setColor(colors.holdBG)
        gc_rectangle('fill',430,0,140,100*slot)
        gc_setColor(COLOR.L)
        gc_rectangle('line',430,0,140,100*slot)
    end
end

function S.drawHoldCell(C,disabled,_,_,_)
    gc_setColor(disabled and colors.disabled or RGB9[C.color])
    gc_rectangle('fill',0,0,40,40)
end

function S.drawTime(time)
    gc_setColor(COLOR.dL)
    FONT.set(30,'number')
    gc_printf(("%.1f"):format(time/1000),-220-260,370,260,'right')
end

function S.drawInfoPanel(x,y,w,h)
    gc_setColor(colors.infoBG)
    gc_rectangle('fill',x,y,w,h)
    gc_setColor(COLOR.dL)
    gc_rectangle('line',x,y,w,h)
end

function S.drawStartingCounter(readyDelay)
    gc_push('transform')
    local num=math.ceil((readyDelay-S.getTime())/1000)
    local r,g,b
    local d=(readyDelay-S.getTime())%1000/1000 -- from .999 to 0

    if     num==1 then r,g,b=1.00,0.70,0.70 if d>.75 then gc_scale(1,1+(d/.25-3)^2) end
    elseif num==2 then r,g,b=0.98,0.85,0.75 if d>.75 then gc_scale(1+(d/.25-3)^2,1) end
    elseif num==3 then r,g,b=0.70,0.80,0.98 if d>.75 then gc_rotate((d-.75)^3*40) end
    elseif num==4 then r,g,b=0.95,0.93,0.50
    elseif num==5 then r,g,b=0.70,0.95,0.70
    else   r,g,b=max(1.26-num/10,0),max(1.26-num/10,0),max(1.26-num/10,0)
    end

    FONT.set(100)

    -- Warping number
    gc_push('transform')
        gc_scale((1.5-d*.6)^1.5)
        gc_setColor(r,g,b,d/(.5+num/3))
        GC.mStr(num,0,-70)
        gc_setColor(1,1,1,(1.5*d-0.5)/(.5+num/3))
        GC.mStr(num,0,-70)
    gc_pop()

    -- Scaling + Fading number
    gc_scale(min(d/.333,1)^.4)
    gc_setColor(r,g,b)
    GC.mStr(num,0,-70)
    gc_setColor(1,1,1,1.5*d-0.5)
    GC.mStr(num,0,-70)
    gc_pop()
end

return S
