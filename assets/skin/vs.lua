local gc=love.graphics
local gc_setColor=gc.setColor
local gc_draw=gc.draw
local gc_rectangle=gc.rectangle
local gc_rectBeam=GC.rectBeam

---@type Techmino.Skin
local S={}

S.base='brik_template'

local colors={
    fieldBG={0,0,0,.9},
    grid={1,1,1,.62},
    fieldBorderU=CLR.d2,
    fieldBorderD=CLR.d4,
    nextBG={.1,.1,.1,.62},
    holdBG={.1,.1,.1,.62},
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

local lw=10
function S.drawFieldBorder()
    gc_setColor(colors.fieldBorderU)
    gc_rectangle('fill',-200,-400,-lw,800)
    gc_rectangle('fill',200,-400,lw,800)
    gc_rectBeam(1,-200-lw/2,-400,-1.5708,lw,96)
    gc_rectBeam(1,200+lw/2,-400,-1.5708,lw,96)
    gc_setColor(colors.fieldBorderD)
    gc_rectBeam(1,-200-lw/2,400,-1.5708,lw,800)
    gc_rectBeam(1,200+lw/2,400,-1.5708,lw,800)
    gc_rectangle('fill',-200-lw,400,400+2*lw,lw)
end

local function drawOuterBorder(x,y,w,h)
    gc_setColor(colors.fieldBorderU)
    gc_rectangle('fill',x-lw,y,lw,h)
    gc_rectangle('fill',x+w,y,lw,h)
    gc_rectangle('fill',x-lw,y-lw,w+2*lw,lw)
    gc_setColor(colors.fieldBorderD)
    gc_rectBeam(1,x-lw/2,y+h,-1.5708,lw,h)
    gc_rectBeam(1,x+w+lw/2,y+h,-1.5708,lw,h)
    gc_rectangle('fill',x-lw,y+h,w+2*lw,lw)
end

function S.drawNextBorder(slot)
    gc_setColor(colors.nextBG)
    gc_rectangle('fill',30,0,140,100*slot)
    drawOuterBorder(30,0,140,100*slot)
end

function S.drawHoldBorder()
    gc_setColor(colors.holdBG)
    gc_rectangle('fill',-30,0,-140,100)
    gc_setColor(colors.fieldBorderU)
    gc_rectangle('fill',-30+lw,0,-140-2*lw,-lw)
    gc_rectangle('fill',-30,0,lw,100)
    gc_rectangle('fill',-170,0,-lw,100)
    gc_rectangle('fill',-30+lw,100,-140-2*lw,lw)
end

function S.drawFieldCell(C)
    gc_setColor(1,1,1)
    gc_draw(TEX.skin_vs[C.color],nil,nil,nil,40/128)
end
S.drawHandCell=S.drawFieldCell

function S.drawNextCell(C,disabled,_,_,_)
    gc_setColor(1,1,1)
    gc_draw(TEX.skin_vs[disabled and 666 or C.color],nil,nil,nil,40/128)
end
S.drawHoldCell=S.drawNextCell

return S
