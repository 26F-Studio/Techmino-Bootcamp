local gc=love.graphics
local gc_push,gc_pop=gc.push,gc.pop
local gc_scale,gc_rotate=gc.scale,gc.rotate
local gc_setColor=gc.setColor
local gc_draw=gc.draw
local gc_rectangle=gc.rectangle
local gc_printf=gc.printf
local gc_rectBeam=GC.rectBeam

local max,min=math.max,math.min

local CLR=CLR

---@type Techmino.Skin
local S={}

local colors={
    fieldBG={.1,.1,.1,.62},
    grid={1,1,1,.62},
    disabled={.6,.6,.6},
    infoBG={.62,.62,.62,.942},

    ghost={1,1,1,.162},
    handStroke={1,1,1},
}

local R=2
local gridMark=GC.load{w=40,
    {'setLW',1},
    {'dCirc',0, 0, R},
    {'dCirc',0, 40,R},
    {'dCirc',40,0, R},
    {'dCirc',40,40,R},
}
local gridBatch=GC.newSpriteBatch(gridMark,2600,'static')
local lastW
function S.drawFieldBackground(fieldW)
    gc_setColor(colors.fieldBG)
    gc_rectangle('fill',0,0,40*fieldW,-80*fieldW)
    gc_rectBeam(1,40*fieldW/2,-80*fieldW,-1.5708,40*fieldW,94)
    if fieldW~=lastW then
        lastW=fieldW
        gridBatch:clear()
        for y=1,2*fieldW do
            for x=1,fieldW do
                gridBatch:add(x*40-40,-y*40)
            end
        end
    end
    gc_setColor(colors.grid)
    gc_draw(gridBatch)
end

function S.drawFieldBorder()
    -- ABSTRACT
end

function S.drawFieldCell(C)
end

function S.drawFloatHoldCell(C,disabled,_,_,_)
    if disabled then
        gc_setColor(.6,.6,.6,.25)
    else
        local r,g,b=unpack(RGB9[C.color])
        gc_setColor(r,g,b,S.time%150/200)
    end
    gc_rectangle('fill',0,0,40,40)
end

function S.drawFloatHoldMark(n,disabled)
    gc_setColor(disabled and CLR.l5 or CLR.l9)
    GC.setFont(50)
    GC.mStr(n,0,5)
end

function S.drawHeightLines(fieldW,maxSpawnH,spawnH,lockoutH,deathH,voidH)
end

function S.drawAsdIndicator(dir,charge,asdMax,aspMax,ash)
end

function S.drawDelayIndicator(color,value)
end

function S.drawLockDelayIndicator(freshCondition,freshChance,timeRem)
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
end

function S.drawNextBorder(slot)
    -- ABSTRACT
end

function S.drawNextCell(C,disabled,_,_,_)
end

function S.drawHoldBorder(mode,slot)
    -- ABSTRACT
end

function S.drawHoldCell(C,disabled,_,_,_)
end

function S.drawTime(time)
    gc_setColor(CLR.l7)
    GC.setFont(30,'number')
    gc_printf(("%.1f"):format(time/1000),-220-260,370,260,'right')
end

function S.drawInfoPanel(x,y,w,h)
    gc_setColor(colors.infoBG)
    gc_rectangle('fill',x,y,w,h)
    gc_setColor(CLR.l7)
    gc_rectangle('line',x,y,w,h)
end

function S.drawStartingCounter(readyDelay)
    gc_push('transform')
    local num=math.ceil((readyDelay-S.time)/1000)
    local r,g,b
    local d=(readyDelay-S.time)%1000/1000 -- from .999 to 0

    if num==1 then
        r,g,b=1.00,0.70,0.70
        if d>.75 then gc_scale(1,1+(d/.25-3)^2) end
    elseif num==2 then
        r,g,b=0.98,0.85,0.75
        if d>.75 then gc_scale(1+(d/.25-3)^2,1) end
    elseif num==3 then
        r,g,b=0.70,0.80,0.98
        if d>.75 then gc_rotate((d-.75)^3*40) end
    elseif num==4 then
        r,g,b=0.95,0.93,0.50
    elseif num==5 then
        r,g,b=0.70,0.95,0.70
    else
        r,g,b=max(1.26-num/10,0),max(1.26-num/10,0),max(1.26-num/10,0)
    end

    GC.setFont(100)

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
