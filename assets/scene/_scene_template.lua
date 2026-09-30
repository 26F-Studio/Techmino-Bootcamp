---@type Zenitha.Scene
local scene={}

---@type fun(fromScene:string | false, ...)  Called when scene loaded (false when loading first scene)
function scene.load() end

---@type fun(fromScene:string | false, ...) Called when scene swapping finished (false when entering first scene)
function scene.enter() end

---@type fun(toScene:string, ...)   Called when scene swapping started
function scene.leave() end

---@type fun(toScene:string, ...)  Called when scene unloaded
function scene.unload() end

---@type fun(x:number, y:number, k:number, presses:number): boolean? Able to interrupt cursor & widget control
function scene.mouseDown() end

---@type fun(x:number, y:number, dx:number, dy:number)
function scene.mouseMove() end

---@type fun(x:number, y:number, k:number, presses:number)
function scene.mouseUp() end

---@type fun(x:number, y:number, k:number, dist:number, presses:number)
function scene.mouseClick() end

---@type fun(dx:number, dy:number): boolean? Able to interrupt WIDGET._scroll
function scene.wheelMove() end

---@type fun(x:number, y:number, id:userdata, pressure?:number)
function scene.touchDown() end

---@type fun(x:number, y:number, id:userdata, pressure?:number)
function scene.touchUp() end

---@type fun(x:number, y:number, dx:number, dy:number, id:userdata, pressure?:number)
function scene.touchMove() end

---@type fun(x:number, y:number, id:userdata, dist:number)
function scene.touchClick() end

---@type fun(key:love.KeyConstant, isRep:boolean, scancode:love.Scancode): boolean? Able to interrupt cursor & widget control
function scene.keyDown() end

---@type fun(key:love.KeyConstant, scancode:love.Scancode)
function scene.keyUp() end

---@type fun(texts:string): boolean? Able to interrupt widget control
function scene.textInput() end

---@type fun(texts:string): boolean? Able to interrupt widget control
function scene.imeChange() end

---@type fun(key:love.GamepadButton)
function scene.gamepadDown() end

---@type fun(key:love.GamepadButton)
function scene.gamepadUp() end

---@type fun(file:love.DroppedFile)
function scene.fileDrop() end

---@type fun(path:string)
function scene.folderDrop() end

function scene.lowMemory() end

---@type fun(width:number, height:number)
function scene.resize() end

---@type fun(focus:boolean)
function scene.focus() end

---@type fun(dt:number)
function scene.update() end

function scene.draw() end

function scene.overDraw() end

scene.widgetList={
    BackButtonBR,
}
return scene
