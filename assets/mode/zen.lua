local ins=table.insert

local sprintMark={40,100,260} -- 里程碑行数

local finesseData={
    Z={
        [0]={1,2,1,0,1,-2,2,1},
        [1]={2,2,2,1,1,2,3,2,2},
        [2]={1,2,1,0,1,-2,2,1},  -- copy
        [3]={2,2,2,1,1,2,3,2,2}, -- copy
    },
    J={
        [0]={1,2,1,0,1,-2,2,1},
        [1]={2,2,3,2,1,2,3,3,2},
        [2]={3,4,3,2,3,-4,4,3},
        [3]={2,3,2,1,2,3,3,2,2},
    },
    O={
        [0]={1,2,-2,1,0,1,-2,2,1},
        [1]={1,2,-2,1,0,1,-2,2,1}, -- copy
        [2]={1,2,-2,1,0,1,-2,2,1}, -- copy
        [3]={1,2,-2,1,0,1,-2,2,1}, -- copy
    },
    I={
        [0]={1,2,1,0,1,2,1},
        [1]={2,2,2,-2,1,1,-2,2,2,2},
        [2]={1,2,1,0,1,2,1},         -- copy
        [3]={2,2,2,-2,1,1,-2,2,2,2}, -- copy
    },
}
finesseData.S=finesseData.Z
finesseData.L=finesseData.J
finesseData.T=finesseData.J

local _r1=require'ZTC/mechanicLib/brik/actions'.rotateCW.press
local _r2=require'ZTC/mechanicLib/brik/actions'.rotateCCW.press
local _r3=require'ZTC/mechanicLib/brik/actions'.rotate180.press
local r1=function(P)
    ins(P.modeData.movHis,'r')
    _r1(P)
end
local r2=function(P)
    ins(P.modeData.movHis,'l')
    _r2(P)
end
local r3=function(P)
    ins(P.modeData.movHis,'f')
    _r3(P)
end
GAME.regFunc(r1,'zen.r1')
GAME.regFunc(r2,'zen.r2')
GAME.regFunc(r3,'zen.r3')

local function winFlash_event_always(P)
    P.modeData.winFlash=P.modeData.winFlash-.0026
    return P.modeData.winFlash<=0
end
local function winFlash_event_drawOnPlayer(P)
    GC.setColor(.62,1,.62,P.modeData.winFlash*.62)
    GC.mRect('fill',0,0,400,800)
    return P.modeData.winFlash<=0
end
GAME.regFunc(winFlash_event_always,'zen.winFlash')
GAME.regFunc(winFlash_event_drawOnPlayer,'zen.winFlashDraw')

local gc_print,gc_setColor=GC.print,GC.setColor
local setFont=FONT.set

local statX,statX2=-380,-290
local statY=-262
local statD=48
local statColor=COLOR.L
local statLabelColor=COLOR.L

local statList={
    {x=statX, row=0,  font=25,label='zen_piece',   get=function(P,md) return P.stat.piece end},
    {x=statX2,row=0,  font=25,label='zen_key',     get=function(P,md) return P.stat.key end},
    {x=statX, row=1,  font=25,label='zen_spawn',   get=function(P,md) return P.stat.spawn end},
    {x=statX2,row=1,  font=25,label='zen_curCnt',  get=function(P,md) return #md.movHis end},
    {x=statX, row=6.5,font=25,label='zen_fault',   get=function(P,md) return md.fault end},
    {x=statX2,row=6.5,font=25,label='zen_overCnt', get=function(P,md) return md.overCnt end},
    {x=statX, row=7.5,font=25,label='zen_neat',    get=function(P,md) return md.neatPiece end},
    {x=statX2,row=7.5,font=25,label='zen_movCnt',  get=function(P,md) return md.movCnt end},
    {x=statX, row=2,  font=50,label='zen_kpp',     get=function(P,md) return md.kpp end},
    {x=statX, row=3.5,font=50,label='zen_line',    get=function(P,md) return P.stat.line end},
    {x=statX, row=8.5,font=50,label='zen_mpp',     get=function(P,md) return md.mpp end},
    {x=statX, row=10, font=50,label='zen_dropRate',get=function(P,md) return md.dropRate end},
}

---@type Techmino.Mode
return {
    initialize=function()
        GAME.newPlayer(1,'brik')
        GAME.setMain(1)
    end,
    settings={
        brik={
            dropDelay=1e99,
            lockDelay=1e99,
            infHold=true,
            readyDelay=2000,
            event={
                playerInit={
                    mechLib.brik.misc.SL_event_playerInit,
                    function(P)
                        P.modeData.undoDepthLimit=26
                        P.modeData.lineGoal=sprintMark[1] -- 当前目标行数
                        P.modeData.timeSplit={}           -- 各里程碑用时
                        P.modeData.lineAnim=0
                        P.modeData.winFlash=0

                        -- P.stat.key              -- 总按键数
                        -- P.stat.piece            -- 总落块数
                        P.modeData.kpp=0           -- 每块按键（传统KPP）

                        P.modeData.fault=0         -- 失误数
                        P.modeData.overCnt=0       -- 多余操作数

                        P.modeData.movHis={}       -- 当前块动作历史（数量）
                        P.modeData.movCnt=0        -- 移动/旋转总数
                        -- P.stat.spawn            -- 总出块数
                        P.modeData.neatPiece=0     -- 无需软降的块数
                        P.modeData.mpp=0           -- 每块操作（仅考虑良定义的露天选点，计暂存不计硬降，衡量选点质量）
                        P.modeData.dropRate='100%' -- 硬降率

                        P:setAction('rotateCW',r1)
                        P:setAction('rotateCCW',r2)
                        P:setAction('rotate180',r3)
                    end,
                },
                afterResetPos=function(P)
                    TABLE.clear(P.modeData.movHis)
                    if P.keyState.moveLeft~=P.keyState.moveRight then
                        ins(P.modeData.movHis,P.keyState.moveLeft and '<' or '>') -- pre-charged
                    end
                end,
                beforePress=function(P,act)
                    if act=='moveLeft' or act=='moveRight' then
                        ins(P.modeData.movHis,act=='moveLeft' and '[' or ']')
                    end
                end,
                afterDrop=function(P)
                    -- Overhang check
                    local fine=true
                    for y=P.handY,P.field:getHeight() do
                        if P:ifoverlap(P.hand.matrix,P.handX,y) then
                            fine=false
                            break
                        end
                    end

                    local md=P.modeData
                    if fine then
                        local piece=P.hand.name
                        local x=P.handX
                        local dir=P.hand.direction
                        local move=#md.movHis
                        local par=finesseData[piece][dir][x]
                        if par<0 then
                            par=-par
                            if md.movHis[1]=='<' or md.movHis[1]=='>' then
                                move=move-1
                            end
                        end
                        -- print(piece,dir,x,move,par) -- TODO: debug
                        if move>par then
                            md.fault=md.fault+1
                            md.overCnt=md.overCnt+(move-par)
                            -- MSG('warn'," ")
                        else
                            -- MSG('check'," ")
                        end

                        md.neatPiece=md.neatPiece+1
                        if #md.movHis>0 then
                            md.movCnt=md.movCnt+#md.movHis
                            TABLE.clear(md.movHis)
                        end
                    end
                end,
                afterClear=function(P)
                    local md=P.modeData
                    if P.stat.line>=md.lineGoal then
                        table.insert(md.timeSplit, "["..md.lineGoal.."L]  "..(P.gameTime/1000)..'s')
                        md.winFlash=1
                        P:addEvent('always',winFlash_event_always)
                        P:addEvent('drawOnPlayer',winFlash_event_drawOnPlayer)
                        md.lineGoal=TABLE.next(sprintMark,md.lineGoal)
                        if not md.lineGoal then return true end
                    end
                end,
                beforeDiscard=function(P)
                    local md=P.modeData
                    -- Update statistics
                    md.kpp=MATH.roundUnit(P.stat.key/P.stat.piece,.01)
                    md.mpp=MATH.roundUnit((md.movCnt+md.neatPiece)/md.neatPiece,.01)
                    md.dropRate=MATH.roundUnit(md.neatPiece/P.stat.piece*100,.1).."%"
                end,
                always=function(P)
                    local md=P.modeData
                    if md.lineGoal then
                        md.lineAnim=MATH.linearApproach(md.lineAnim,math.min(P.stat.line,md.lineGoal),.042)
                    elseif md.lineAnim then
                        md.lineAnim=false
                    end
                end,
                drawInField=function(P)
                    if not P.modeData.lineAnim then return true end
                    local remain=P.modeData.lineGoal-P.modeData.lineAnim
                    if remain>=25 then
                        return
                    elseif remain>=14 then
                        GC.setColor(1,1,1,MATH.clampInterpolate(25,0,14,.8,remain))
                    elseif remain>=10 then
                        GC.setColor(1,1,1,.8)
                    else
                        GC.setColor(1,-P.gameTime/120%1,0,.8)
                    end
                    GC.rectangle('fill',0,-3-remain*40,400,6)
                end,
                drawOnPlayer=function(P)
                    local md=P.modeData
                    local lastC

                    for i=1,#statList do
                        local s=statList[i]
                        local v=s.get(P,md)
                        setFont(s.font)

                        local c=s.color or statColor
                        if type(c)=='table' then
                            if c~=lastC then
                                gc_setColor(c)
                                lastC=c
                            end
                        else
                            gc_setColor(c(P,md,v))
                            lastC=nil
                        end

                        gc_print(v,s.x,statY+statD*s.row)
                    end

                    setFont(15)
                    gc_setColor(statLabelColor)
                    for i=1,#statList do
                        local s=statList[i]
                        gc_print(Text[s.label],s.x,statY+(s.font==50 and 55 or 26)+statD*s.row)
                    end
                    for i=1,#md.timeSplit do
                        gc_print(md.timeSplit[i],statX,statY+55+statD*(3.9+(i-1)*.4))
                    end
                end,
            },
        },
    },
}
