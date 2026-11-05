local gc_print,gc_setColor=GC.print,GC.setColor
local setFont=FONT.set

local ATK_TIME=2
local TIMELINE_LEN=6
local ATK_POWER_WEIGHT={3,1,1,4,2}
local ATK_POWER_DIST={1,3,5,7}
local TIMELINE_X,TIMELINE_Y=370,-400
local TIMELINE_CELL_LEN=100
local TIMELINE_WIDTH=10

local statX,statX2=-380,-290
local statY=-262
local statD=48
local ATK_SIZE={.2,.35,.5,.7,.95}
local ATK_CLR={
    {CLR.HEX'00FFE1'},
    {CLR.HEX'00FF77'},
    {CLR.HEX'FFBF00'},
    {CLR.HEX'FF5E00'},
    {CLR.HEX'FF0080'},
}

local function refreshAtkList(P)
    local md=P.modeData
    local list=md.atkList
    while #list<TIMELINE_LEN do
        md.atkGap=md.atkGap-1
        if md.atkGap<=0 then
            list[#list+1]=P:randFreq('vs',ATK_POWER_WEIGHT)
            md.atkGap=P:randFreq('vs',ATK_POWER_DIST)
        else
            list[#list+1]=0
        end
    end
end

local flashClr={1,1,1}
local function flash_event_drawOnPlayer(P)
    local a=MATH.interpolate(0,.8,620,0,P.time-P.modeData.flashTime)
    gc_setColor(flashClr[1],flashClr[2],flashClr[3],a*.62)
    GC.mRect('fill',0,0,400,800)
    return a<=0
end
local function onFault(P)
    P.modeData.flashTime=P.time-260
    flashClr[1],flashClr[2],flashClr[3]=1,.62,.62
    P:addEvent('drawOnPlayer',flash_event_drawOnPlayer)
    if CONF.system.noFault then
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
    {x=statX2,row=1,  font=25,label='game_movSeq',  get=function(P,md) return #md.movSeq<=5 and md.movSeq or "---" end},
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
        BG.set('game_vs')
    end,
    settings={
        brik={
            dropDelay=1e99,
            lockDelay=1e99,
            infHold=true,
            readyDelay=2000,
            skin='vs',
            atkSys='modern',
            event={
                playerInit={
                    function(P)
                        P.modeData.noOspin=true
                        mechLib.brik.saveload.event_playerInit(P,26,onBeforeLoad,onAfterLoad)
                        mechLib.brik.finesse.event_playerInit(P,onFault,CONF.system.force180,CONF.system.noStuck)

                        P.modeData.atkList={}
                        P.modeData.atkLastPiece=-1
                        P.modeData.atkGap=2.6
                        refreshAtkList(P)
                    end,
                },
                afterSpawn={
                    function(P)
                        local md=P.modeData
                        if md.refAns and not md.refAns.fmt then
                            for i=1,#md.refAns do
                                md.refAns[i]=ParseFinesse(md.refAns[i])
                            end
                            md.refAns.fmt=true
                        end
                    end,
                    function(P)
                        local md=P.modeData
                        if md.atkLastPiece==P.stat.piece then return end
                        md.atkLastPiece=P.stat.piece
                        local power=table.remove(md.atkList,1)
                        if power>0 then
                            GAME.send(false,GAME.initAtk{
                                target=GAME.mainID,
                                power=power,
                                mode=1,
                                time=ATK_TIME,
                            })
                        end
                        refreshAtkList(P)
                    end,
                },
                afterLock=function(P)
                    BG.send('game_vs',.026)
                end,
                afterClear=function(P,his)
                    BG.send('game_vs',his.line*.16)
                end,
                drawOnPlayer=function(P)
                    local md=P.modeData

                    gc_setColor(CLR.l9)
                    for i=1,6 do
                        local s=statList[i]
                        setFont(s.font); gc_print(s.get(P,md),s.x,statY+statD*s.row)
                        setFont(15); gc_print(Text[s.label],s.x,statY+(s.font==50 and 55 or 26)+statD*s.row)
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

                    -- Timeline
                    -- gc_setColor(CLR.d4)
                    -- for i=0,TIMELINE_LEN do
                    --     GC.rectangle('fill',TIMELINE_X,TIMELINE_Y+i*TIMELINE_CELL_LEN-1,TIMELINE_WIDTH,2)
                    -- end
                    local cellX=TIMELINE_X+TIMELINE_WIDTH*.5
                    for i=1,TIMELINE_LEN do
                        local power=md.atkList[i]
                        if power>0 then
                            gc_setColor(ATK_CLR[power])
                            GC.mRect('fill',
                                cellX,TIMELINE_Y+(i-.5)*TIMELINE_CELL_LEN,
                                TIMELINE_WIDTH,
                                TIMELINE_CELL_LEN*ATK_SIZE[power],
                                6
                            )
                        end
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

                    -- Limits
                    if md.noStuck then
                        gc_setColor(CLR.l7)
                        GC.mDraw(TEX.icon.noStuck,250,250,0,.16)
                    end
                    if CONF.system.noFault then
                        gc_setColor(CLR.l5Y)
                        GC.mDraw(TEX.icon.noFault,250,310,0,.16)
                    end
                    if md.force180 then
                        gc_setColor(CLR.l7)
                        GC.mDraw(TEX.icon.force180,250,370,0,.16)
                    end
                end,
            },
        },
    },
}
