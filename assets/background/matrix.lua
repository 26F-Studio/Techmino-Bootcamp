---@type Zenitha.Background
local back={}

local gc=love.graphics
local gc_clear,gc_translate,gc_scale=gc.clear,gc.translate,gc.scale
local gc_setColor=gc.setColor
local gc_rectangle=gc.rectangle

local sin=math.sin

local t=-26000
local matrixT={}
local W,H=26,12
for y=1,H do
    matrixT[y]={}
    for x=1,W do matrixT[y][x]=love.math.noise(y,x)+2 end
end

function back.update(dt)
    t=t+dt
end

function back.draw()
    gc_clear(.1,.1,.1)
    gc_translate(SCR.w/2,SCR.h/2)
    gc_scale(math.max(SCR.w/W,SCR.h/H)*1.026)
    for y=1,H do
        for x=1,W do
            gc_setColor(1,1,1,sin(matrixT[y][x]*t)*.03+.03)
            gc_rectangle('fill',x-W/2,y-H/2,-1,-1)
        end
    end
end

return back
