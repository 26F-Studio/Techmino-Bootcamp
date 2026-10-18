local milestones={40,100,260} -- 里程碑行数

local gc_print,gc_setColor=GC.print,GC.setColor
local setFont=FONT.set

local statX,statX2=-380,-290
local statY=-262
local statD=48

local flashClr={1,1,1}
local function flash_event_drawOnPlayer(P)
    local a=MATH.clampInterpolate(0,.8,620,0,P.time-P.modeData.flashTime)
    GC.setColor(flashClr[1],flashClr[2],flashClr[3],a*.62)
    GC.mRect('fill',0,0,400,800)
    return a<=0
end
local function onFault(P)
    P.modeData.flashTime=P.time+260
    flashClr[1],flashClr[2],flashClr[3]=1,.62,.62
    P:addEvent('drawOnPlayer',flash_event_drawOnPlayer)
    if CONF.system.forcePerfect then
        P:restoreBrikState()
        table.insert(P.nextQueue,1,P.hand)
        P.hand=nil
    end
end
local function onBeforeLoad(P)
    return P.modeData.refAns
end
local function onAfterLoad(P,refAns)
    P.modeData.flashTime=-1e99
    P.modeData.refAns=refAns
end
GAME.regFunc(flash_event_drawOnPlayer,'std.winFlashDraw')
GAME.regFunc(onFault,'std.onFault')
GAME.regFunc(onBeforeLoad,'std.onBeforeLoad')
GAME.regFunc(onAfterLoad,'std.onAfterLoad')

local statList={
    {x=statX, row=0,  font=25,label='game_piece',   get=function(P,md) return P.stat.piece end},
    {x=statX2,row=0,  font=25,label='game_spawn',   get=function(P,md) return P.stat.spawn end},
    {x=statX, row=1,  font=25,label='game_key',     get=function(P,md) return P.stat.key end},
    {x=statX2,row=1,  font=25,label='game_movSeq',  get=function(P,md) return md.movSeq end},
    {x=statX, row=2,  font=50,label='game_kpp',     get=function(P,md) return md.kpp end},
    {x=statX, row=3.5,font=50,label='game_line',    get=function(P,md) return P.stat.line end},
    {x=statX, row=6.5,font=25,label='game_fault',   get=function(P,md) return md.fault end},
    {x=statX2,row=6.5,font=25,label='game_overCnt', get=function(P,md) return md.overCnt end},
    {x=statX, row=7.5,font=25,label='game_movCnt',  get=function(P,md) return md.movCnt end},
    {x=statX2,row=7.5,font=25,label='game_neat',    get=function(P,md) return md.neatPiece end},
    {x=statX, row=8.5,font=50,label='game_mpp',     get=function(P,md) return md.mpp end},
    {x=statX, row=10, font=50,label='game_dropRate',get=function(P,md) return md.dropRate end},
}

---@type Techmino.ModeInput
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
                    mechLib.brik.saveload.event_playerInit,
                    mechLib.brik.finesse.event_playerInit,
                    function(P)
                        P.modeData.noOspin=true
                        P.modeData.undoDepthLimit=26
                        P.modeData.force180=CONF.system.force180
                        P.modeData.onFinesseFault=onFault
                        P.modeData.onAfterLoad=onAfterLoad

                        P.modeData.lineGoal=milestones[1] -- 当前目标行数
                        P.modeData.split={}               -- 各里程碑用时
                        P.modeData.lineAnim=0
                    end,
                },
                afterSpawn=function(P)
                    local md=P.modeData
                    if md.refAns and not md.refAns.fmt then
                        for i=1,#md.refAns do
                            md.refAns[i]=ParseFinesse(md.refAns[i])
                        end
                        md.refAns.fmt=true
                    end
                end,
                afterClear=function(P)
                    local md=P.modeData
                    if P.stat.line>=md.lineGoal then
                        table.insert(md.split, "["..md.lineGoal.."L]  "..(P.gameTime/1000).."s")
                        md.flashTime=P.time
                        flashClr[1],flashClr[2],flashClr[3]=.62,1,.62
                        P:addEvent('drawOnPlayer',flash_event_drawOnPlayer)
                        md.lineGoal=TABLE.next(milestones,md.lineGoal)
                        if not md.lineGoal then return true end
                    end
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

                    gc_setColor(CLR.L)
                    for i=1,6 do
                        local s=statList[i]
                        setFont(s.font); gc_print(s.get(P,md),s.x,statY+statD*s.row)
                        setFont(15); gc_print(Text[s.label],s.x,statY+(s.font==50 and 55 or 26)+statD*s.row)
                    end
                    for i=1,#md.split do
                        gc_print(md.split[i],statX,statY+55+statD*(3.9+(i-1)*.4))
                    end

                    if md.fault==0 then
                        gc_setColor(1,.95,.7)
                    else
                        local l=MATH.clampInterpolate(.026,1,.062,.42,md.fault/P.stat.piece)
                        gc_setColor(1,l,l)
                    end
                    for i=md.fault==0 and 9 or 7,#statList do
                        local s=statList[i]
                        setFont(s.font); gc_print(s.get(P,md),s.x,statY+statD*s.row)
                        setFont(15); gc_print(Text[s.label],s.x,statY+(s.font==50 and 55 or 26)+statD*s.row)
                    end

                    -- Hint
                    if md.refAns then
                        setFont(40)
                        gc_setColor(1,1,1)
                        GC.mStr(md.refAns[1],0,-330)
                        if md.refAns[2] then
                            GC.mStr(md.refAns[2],0,-240)
                            setFont(30)
                            GC.mStr(Text.game_hint['OR'],0,-280)
                        end
                    end
                end,
            },
        },
    },
}
