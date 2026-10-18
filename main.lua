require'Zenitha'
CLR.installNumLiteral('RGB9')
RGB9=CLR.installNumLiteral('RGB9',true)
RGBA9=CLR.installNumLiteral('RGBA9',true)

UTIL.time("Load Zenitha",true)
--------------------------------------------------------------

love.audio.setVolume(0)
ZENITHA.setAppInfo("Techmino-Bootcamp",require'version'.appVer)
ZENITHA.setFirstScene('home')
ZENITHA.setMainLoopSpeed(120)
ZENITHA.setUpdateRate(100)
ZENITHA.setRenderRate(75)
ZENITHA.setCleanCanvas(false)
STRING.install()

love.keyboard.setTextInput(false)

SCR.setSize(1600,1000)

BGM.setMaxSources(6)
BGM.load{}
SFX.load{}
FONT.load('norm','assets/RHDisplayGalaxy-Medium.otf')
FONT.setDefaultFont('norm')

Text=nil ---@type Techmino.I18N
LANG.add{
    en='assets/language/lang_en.lua',
    zh='assets/language/lang_zh.lua',
}
LANG.setDefault('en')

local _keyDown_orig=ZENITHA.globalEvent.keyDown
local _setDebugMode_orig=ZENITHA.setDebugMode
function ZENITHA.setDebugMode(m) if m==false or m==1 then _setDebugMode_orig(m) end end
function ZENITHA.globalEvent.keyDown(key,isRep)
    if _keyDown_orig(key,isRep) then return true end
    if not isRep then
        if key=='f11' then
            CONF.system.fullscreen=not CONF.system.fullscreen
            SaveConf()
            return true
        end
    end
end

ZENITHA.globalEvent.drawCursor=NULL
ZENITHA.globalEvent.clickFX=NULL

UTIL.time("Config Zenitha",true)
--------------------------------------------------------------
TEX=require'assets.texture'
KEYMAP=require'assets.keymap'
CONF=require'assets.config'
require'assets.gamefunc'
GAME=require'ZTC'
SKIN=require'assets.skin'

---@type Map<Techmino.keymapAction[]>
KM={}
KM.game=KEYMAP.new{
    {act='moveLeft', keys={'left'}},
    {act='moveRight',keys={'right'}},
    {act='rotateCW', keys={'up'}},
    {act='rotateCCW',keys={'down'}},
    {act='rotate180',keys={}},
    {act='softDrop', keys={'x'}},
    {act='hardDrop', keys={'z'}},
    {act='holdPiece',keys={'space'}},
    {act='func1',    keys={'a'}},
    {act='func2',    keys={'s'}},
}
KM.sys=KEYMAP.new{
    {act='restart',keys={'r'}},
    {act='back',   keys={'escape'}},
}

KeyAlias=setmetatable({
    space='Space',
    backspace='BS',
    escape='Esc',
    scrolllock='ScrLk',
    capslock='CapLk',
    numlock='NumLk',
},{__index=function(_,k) return tostring(k):upper() end})

UTIL.time("Load modules",true)
--------------------------------------------------------------

CornerButtonX={120,320,520,720,920}
BackButtonBR=WIDGET.new{type='button',pos={1,1},x=-CornerButtonX[1],y=-80,w=140,h=80,text=LANG'back',onClick=WIDGET.c_backScn()}
WIDGET.setDefaultOption{
    button={
        fontSize=40,
    },
}

UTIL.time("Init widget",true)
--------------------------------------------------------------

FILE.createDirectory('conf')

do
    -- Load setting file
    local setFile=FILE.safeLoad('conf/config','-json') or {}
    setFile._system,setFile.system=setFile.system,nil
    TABLE.update(CONF,setFile)

    -- Trigger all setting-triggers
    for k,v in next,CONF._system do
        CONF._system[k]=nil
        CONF.system[k]=v
    end
end

-- Load keymap
local keys=FILE.safeLoad('conf/keymap','-json')
if keys then
    KM.game:import(keys['game'])
    KM.sys:import(keys['sys'])
end

---@type table<string, love.Shader>
SHADER={}
SHADER.mono=GC.newShader[[
    vec4 effect(vec4 color, sampler2D tex, vec2 texCoord, vec2 scrCoord) {
        vec4 samp = texture2D(tex, texCoord);
        float t = (samp.r + samp.g + samp.b) / 3.0;
        return vec4(t, t, t, samp.a * color.a);
    }
]]

do
    ---@type Zenitha.Background
    local bg={}

    local pos,pos1=0,0
    function bg.init()
    end

    function bg.event(page)
        pos=
            page=='about' and 1 or
            page=='home' and 0 or
            page=='config' and -1 or
            0
    end

    function bg.update(dt)
        pos1=MATH.expApproach(pos1,pos,dt*1.626)
    end

    local colorU=TABLE.transpose{
        {CLR.HEX('03184C')},
        {CLR.HEX('040319')},
        {CLR.HEX('000311')},
    }
    local colorD=TABLE.transpose{
        {CLR.HEX('4C483B')},
        {CLR.HEX('31193F')},
        {CLR.HEX('020A11')},
    }
    function bg.draw()
        GC.clear(
            MATH.lLerp(colorD[1],(pos1+1)/2),
            MATH.lLerp(colorD[2],(pos1+1)/2),
            MATH.lLerp(colorD[3],(pos1+1)/2)
        )
        GC.setColor(
            MATH.lLerp(colorU[1],(pos1+1)/2),
            MATH.lLerp(colorU[2],(pos1+1)/2),
            MATH.lLerp(colorU[3],(pos1+1)/2)
        )
        GC.draw(TEX.transition,0,0,1.5708,SCR.h/128,SCR.w,0,1)

        GC.translate(SCR.w/2,SCR.h/2)
        GC.scale(SCR.w/SCR.w0)

        -- 1600 x 1000
        GC.setBlendMode('add')
        do
            -- Star
            GC.setColor(1,1,1)
            local t=love.timer.getTime()/26
            TEX.bg_star_quad:setViewport(26*math.sin(t*2.6),12*math.cos(t)-pos1*62,1600,1000,1600,1000)
            GC.mDrawQ(TEX.bg_star,TEX.bg_star_quad)
            -- Cloud
            GC.setColor(.62,.62,.62,MATH.clampInterpolate(-.26,.62,.62,0,pos1))
            GC.mDraw(TEX.bg_cloud,0,500+900*pos1,0,1600/2880)
            -- Galaxy
            if pos1>.026 then
                GC.setColor(.62,.62,.62,pos1)
                GC.mDraw(TEX.bg_galaxy,0,260*(pos1-.62),0,1600/1920*1.26)
            end
        end
        GC.setBlendMode('alpha')
    end

    BG.add('menu',bg)
end

for _,v in next,love.filesystem.getDirectoryItems('assets/scene') do
    if FILE.isSafe('assets/scene/'..v) then
        local sceneName=v:sub(1,-5)
        SCN.add(sceneName,FILE.load('assets/scene/'..v,'-lua'))
    end
end
SCN.setDefaultSwap('none')

SKIN.add('brik_template',FILE.load('assets/skin/template.lua','-lua'))
GAME.addMode('std','assets/mode/std.lua')
GAME.addMode('dig','assets/mode/dig.lua')

UTIL.time("Load Data",true)

UTIL.showTimeLog()

-- require("Zenitha.compile")()
