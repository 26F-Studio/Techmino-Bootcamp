local milestones={40,100,260} -- 里程碑行数

local gc_print,gc_setColor=GC.print,GC.setColor
local setFont=FONT.set

local statX,statX2=-380,-290
local statY=-262
local statD=48

local function winFlash_event_always(P)
    P.modeData.winFlash=P.modeData.winFlash-.0026
    return P.modeData.winFlash<=0
end

local function winFlash_event_drawOnPlayer(P)
    GC.setColor(.62,1,.62,P.modeData.winFlash*.62)
    GC.mRect('fill',0,0,400,800)
    return P.modeData.winFlash<=0
end

local statList={
    {x=statX, row=0,  font=25,label='std_piece',   get=function(P,md) return P.stat.piece end},
    {x=statX2,row=0,  font=25,label='std_key',     get=function(P,md) return P.stat.key end},
    {x=statX, row=1,  font=25,label='std_spawn',   get=function(P,md) return P.stat.spawn end},
    {x=statX2,row=1,  font=25,label='std_curCnt',  get=function(P,md) return #md.movHis end},
    {x=statX, row=6.5,font=25,label='std_fault',   get=function(P,md) return md.fault end},
    {x=statX2,row=6.5,font=25,label='std_overCnt', get=function(P,md) return md.overCnt end},
    {x=statX, row=7.5,font=25,label='std_neat',    get=function(P,md) return md.neatPiece end},
    {x=statX2,row=7.5,font=25,label='std_movCnt',  get=function(P,md) return md.movCnt end},
    {x=statX, row=2,  font=50,label='std_kpp',     get=function(P,md) return md.kpp end},
    {x=statX, row=3.5,font=50,label='std_line',    get=function(P,md) return P.stat.line end},
    {x=statX, row=8.5,font=50,label='std_mpp',     get=function(P,md) return md.mpp end},
    {x=statX, row=10, font=50,label='std_dropRate',get=function(P,md) return md.dropRate end},
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
                    mechLib.brik.misc.SL_event_playerInit,
                    mechLib.brik.finesse.event_playerInit,
                    function(P)
                        P.modeData.noOspin=true
                        P.modeData.undoDepthLimit=26
                        P.modeData.force180=CONF.system.force180

                        P.modeData.lineGoal=milestones[1] -- 当前目标行数
                        P.modeData.timeSplit={}           -- 各里程碑用时
                        P.modeData.lineAnim=0
                        P.modeData.winFlash=0
                    end,
                },
                afterClear=function(P)
                    local md=P.modeData
                    if P.stat.line>=md.lineGoal then
                        table.insert(md.timeSplit, "["..md.lineGoal.."L]  "..(P.gameTime/1000).."s")
                        md.winFlash=1
                        P:addEvent('always',winFlash_event_always)
                        P:addEvent('drawOnPlayer',winFlash_event_drawOnPlayer)
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
                    local lastC

                    for i=1,#statList do
                        local s=statList[i]
                        local v=s.get(P,md)
                        setFont(s.font)

                        local c=s.color or COLOR.L
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
                    gc_setColor(COLOR.L)
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
