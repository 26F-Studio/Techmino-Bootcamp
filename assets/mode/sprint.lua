---@type Techmino.Mode
return {
    initialize=function()
        GAME.newPlayer(1,'brik')
        GAME.setMain(1)
    end,
    settings={brik={
        dropDelay=1e99,
        lockDelay=1e99,
        infHold=true,
        readyDelay=2600,
        event={
            playerInit=function(P)
                P.modeData.target.line=40
            end,
            afterClear=mechLib.brik.misc.lineClear_event_afterClear,
            drawOnPlayer=mechLib.brik.misc.lineClear_event_drawOnPlayer,
        },
    }},
}
