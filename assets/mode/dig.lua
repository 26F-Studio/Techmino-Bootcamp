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
            readyDelay=0,
            event={
                playerInit={
                    mechLib.brik.misc.SL_event_playerInit,
                    function(P)
                        P.modeData.digMode='neat'
                        P.modeData.lineStay=12
                        P.modeData.target.lineDig=1e99
                        mechLib.brik.dig.event_playerInit(P)
                    end
                },
                afterClear=mechLib.brik.dig.event_afterClear,
            },
        },
    },
}
