require'Zenitha'
CLR.installNumLiteral('RGB9')
RGB9=CLR.installNumLiteral('RGB9',true)
RGBA9=CLR.installNumLiteral('RGBA9',true)

UTIL.time("Load Zenitha",true)
--------------------------------------------------------------

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
for _,v in next,love.filesystem.getDirectoryItems('assets/shader') do
    if FILE.isSafe('assets/shader/'..v) then
        local name=v:sub(1,-6)
        local suc,res=pcall(love.graphics.newShader,'assets/shader/'..name..'.hlsl')
        SHADER[name]=suc and res or error("Err in compiling Shader '"..name.."': "..tostring(res))
    end
end

for _,v in next,love.filesystem.getDirectoryItems('assets/background') do
    if FILE.isSafe('assets/background/'..v) and v:sub(-3)=='lua' then
        local name=v:sub(1,-5)
        BG.add(name,FILE.load('assets/background/'..v,'-lua'))
    end
end
BG.setDefault('matrix')
BG.set()

for _,v in next,love.filesystem.getDirectoryItems('assets/scene') do
    if FILE.isSafe('assets/scene/'..v) then
        local sceneName=v:sub(1,-5)
        SCN.add(sceneName,FILE.load('assets/scene/'..v,'-lua'))
    end
end

SKIN.add('brik_template',FILE.load('assets/skin/template.lua','-lua'))
GAME.addMode('test','assets/mode/test.lua')
GAME.addMode('sprint','assets/mode/sprint.lua')
GAME.addMode('death','assets/mode/death.lua')

UTIL.time("Load Data",true)

UTIL.showTimeLog()

-- require("Zenitha.compile")()
