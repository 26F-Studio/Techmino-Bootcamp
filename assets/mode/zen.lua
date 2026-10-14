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
            readyDelay=1000,
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
                afterLock=mechLib.brik.misc.invincible_event_afterLock,
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

                    local x,x2=-380,-290
                    local y=-262
                    local d=48

                    FONT.set(25)
                    GC.print(P.stat.piece,x,y+d*0)
                    GC.print(P.stat.key,x2,y+d*0)
                    GC.print(P.stat.spawn,x,y+d*1)
                    GC.print(#md.movHis,x2,y+d*1)
                    FONT.set(50)
                    GC.print(md.kpp,x,y+d*2)
                    GC.print(P.stat.line,x,y+d*3.5)
                    FONT.set(25)
                    GC.print(md.fault,x,y+d*6.5)
                    GC.print(md.overCnt,x2,y+d*6.5)
                    GC.print(md.neatPiece,x,y+d*7.5)
                    GC.print(md.movCnt,x2,y+d*7.5)
                    FONT.set(50)
                    GC.print(md.mpp,x,y+d*8.5)
                    GC.print(md.dropRate,x,y+d*10)

                    FONT.set(15)
                    GC.print(Text.zen_piece,x,y+26+d*0)
                    GC.print(Text.zen_key,x2,y+26+d*0)
                    GC.print(Text.zen_spawn,x,y+26+d*1)
                    GC.print(Text.zen_curCnt,x2,y+26+d*1)
                    GC.print(Text.zen_kpp,x,y+55+d*2)
                    GC.print(Text.zen_line,x,y+55+d*3.5)
                    for i=1,#md.timeSplit do GC.print(md.timeSplit[i],x,y+55+d*(3.9+(i-1)*.4)) end
                    GC.print(Text.zen_fault,x,y+26+d*6.5)
                    GC.print(Text.zen_overCnt,x2,y+26+d*6.5)
                    GC.print(Text.zen_neat,x,y+26+d*7.5)
                    GC.print(Text.zen_movCnt,x2,y+26+d*7.5)
                    GC.print(Text.zen_mpp,x,y+55+d*8.5)
                    GC.print(Text.zen_dropRate,x,y+55+d*10)
                end,
            },
        },
    },
}
