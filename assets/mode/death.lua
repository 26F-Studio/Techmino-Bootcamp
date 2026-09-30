---@type Techmino.Mode
return {
    initialize=function()
        GAME.newPlayer(1,'brik')
        GAME.setMain(1)
    end,
    settings={brik={
        dropDelay=0,
        lockDelay=1e99,
        spawnDelay=260,
        readyDelay=2600,
        event={
            playerInit=function(P)
                P.modeData.storedASD=P.settings.asd
                P.modeData.storedASP=P.settings.asp
                P.settings.asd=math.max(P.modeData.storedASD,200)
                P.settings.asp=math.max(P.modeData.storedASP,40)
                P.settings.dropDelay=0
                P.settings.lockDelay=1e99
                P.settings.spawnDelay=260
                mechLib.brik.marathon.hypersonic_high_event_playerInit(P)
            end,
        },
    }},
}
