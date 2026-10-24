local TEX={}

TEX.home_title={
    zh='assets/image/title_zh.png',
    en='assets/image/title_en.png',
}

TEX.bg_star=GC.initCanvas(1600,1000,function()
    local setCL,circ,rand=GC.setColor,GC.circle,math.random
    for _=1,6200 do
        setCL(1,1,1,.2+rand()^2)
        circ('fill',rand(1600)-1,rand(1000)-1,.2+.6*rand())
    end
end)
TEX.bg_star:setWrap('repeat', 'repeat')
TEX.bg_star_quad=GC.newQuad(0,0,1600,1000,TEX.bg_star)
TEX.bg_cloud='assets/image/cloud.jpg'   -- 2880x2000
TEX.bg_galaxy='assets/image/galaxy.jpg' -- 1920x1196

TEX.home_icons='assets/image/home_icons.png'
TEX.home_iconQuad={
    GC.newQuad(2040/6*0,0,2040/6,400,2040,400),
    GC.newQuad(2040/6*1,0,2040/6,400,2040,400),
    GC.newQuad(2040/6*2,0,2040/6,400,2040,400),
    false,
    false,
    false,
    GC.newQuad(2040/6*3,0,2040/6,400,2040,400),
    GC.newQuad(2040/6*4,0,2040/6,400,2040,400),
    GC.newQuad(2040/6*5,0,2040/6,400,2040,400),
}

local img=GC.newImage('assets/image/skin.png')
local sd=GC.newShader[[
    uniform float hsv[3];

    vec3 hsv2rgb(vec3 c) {
        vec3 p = abs(fract(c.xxx + vec3(0.0, 2.0/3.0, 1.0/3.0)) * 6.0 - 3.0);
        return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
    }

    const float SHADOW_GAMMA = 0.62;
    const float SHADOW_LIFT  = 0.04;

    vec4 effect(vec4 color, sampler2D tex, vec2 texCoord, vec2 scrCoord) {
        vec4 samp = texture2D(tex, texCoord);
        float lum = pow(samp.r, SHADOW_GAMMA);
        lum = lum * (1.0 - SHADOW_LIFT) + SHADOW_LIFT;
        vec3 rgb = hsv2rgb(vec3(hsv[0], hsv[1], hsv[2])) * lum;
        return vec4(rgb, samp.a) * color;
    }
]]
local function colorCell(h,s,v)
    return GC.initCanvas(128,128,function()
        sd:send('hsv',h,s,v)
        GC.setShader(sd)
        GC.draw(img)
        GC.setShader()
    end)
end
TEX.skin_std={
    [844]=colorCell(0.0/6, 0.6, 1.00),
    [864]=colorCell(0.5/6, 0.6, 1.00),
    [884]=colorCell(1.0/6, 0.5, 0.95),
    [484]=colorCell(2.0/6, 0.5, 0.90),
    [488]=colorCell(3.0/6, 0.5, 0.95),
    [448]=colorCell(4.0/6, 0.5, 1.00),
    [748]=colorCell(4.8/6, 0.6, 1.00),
}
TEX.skin_dig={
    [777]=colorCell(4.0/6, 0.2, 1.00),
    [844]=colorCell(5.6/6, 0.6, 1.00),
    [864]=colorCell(0.2/6, 0.5, 1.00),
    [884]=colorCell(1.0/6, 0.3, 0.95),
    [484]=colorCell(2.4/6, 0.4, 0.90),
    [488]=colorCell(3.2/6, 0.5, 0.95),
    [448]=colorCell(4.0/6, 0.5, 1.00),
    [748]=colorCell(4.4/6, 0.6, 1.00),
}
TEX.skin_vs={
    [777]=img,
    [844]=colorCell(0.0/6, 0.6*.62, 1.00),
    [864]=colorCell(0.5/6, 0.6*.62, 1.00),
    [884]=colorCell(1.0/6, 0.5*.62, 0.95),
    [484]=colorCell(2.0/6, 0.5*.62, 0.90),
    [488]=colorCell(3.0/6, 0.5*.62, 0.95),
    [448]=colorCell(4.0/6, 0.5*.62, 1.00),
    [748]=colorCell(4.8/6, 0.6*.62, 1.00),
}

TEX.dusk={
    bg='assets/image/bg1/bg.png',      -- 2048 x 1280
    fg='assets/image/bg1/fg.png',      -- 2048 x 1280
    sun='assets/image/bg1/sun.png',    -- 2048 x 1280
    cloud={
        'assets/image/bg1/cloud1.png', -- ~500 x 320
        'assets/image/bg1/cloud2.png', -- ~300 x 320
        'assets/image/bg1/cloud3.png', -- ~800 x 320
        'assets/image/bg1/cloud4.png', -- ~1100 x 320
    },
}
TEX.night={
    bg='assets/image/bg2.jpg', -- 5180 x 3238
}
TEX.vs={
    fan='assets/image/bg3/fan.jpg',       -- 1920 x 1920
    beam='assets/image/bg3/beam.jpg',     -- 1920 x 160
    ring_f='assets/image/bg3/ring_f.png', -- 1000 x 1000
    ring_b='assets/image/bg3/ring_b.png', -- 1000 x 1000
}

TEX.z={
    normal='assets/image/z/normal.png',
    question='assets/image/z/question.png',
    shy='assets/image/z/shy.png',
    angry='assets/image/z/angry.png',
    nervous='assets/image/z/nervous.png',
}

-- Control icons
TEX.actionIcons={
    texture=GC.initCanvas(720,540,function()
        GC.setLineWidth(10)
        for _,svg in next,{
            {90,90,function()
                -- left arrow
                GC.line(32,-50,-32,0,32,50)
            end},
            {270,90,function()
                -- right arrow
                GC.line(-32,-50,32,0,-32,50)
            end},
            {450,90,function()
                -- soft drop
                GC.line(-52,-38,0,26,52,-38)
            end},
            {630,90,function()
                -- hard drop
                GC.line(-52,-52,0,12,52,-52)
                GC.line(-62,46,62,46)
            end},
            {90,270,function()
                -- rotate clockwise
                GC.arc('line','open',0,0,60,-1.071,4.212,72)
                GC.line(-33.594,-20.457,-28.766,-52.655,-61.261,-54.671)
                FONT.set(90); GC.mStr('R',0,-60)
            end},
            {270,270,function()
                -- rotate counter-clockwise
                GC.arc('line','open',0,0,60,-1.071,4.212,72)
                GC.line(61.261,-54.671,28.766,-52.655,33.594,-20.457)
                FONT.set(90); GC.mStr('L',0,-60)
            end},
            {450,270,function()
                -- rotate 180
                GC.arc('line','open',0,0,60,.26,2.8816)
                GC.arc('line','open',0,0,60,3.4016,6.0232)
                GC.line(-27.857,27.768,-57.984,15.424,-67.666,46.509)
                GC.line(27.857,-27.768,57.984,-15.424,67.666,-46.509)
                FONT.set(90); GC.mStr('F',0,-60)
            end},
            {630,270,function()
                -- hold piece
                GC.rectangle('line',-54,-54,108,108,30)
                FONT.set(90); GC.mStr('H',0,-60)
            end},
            {90,450,function()
                -- restart
                GC.rotate(-math.pi/2)
                GC.arc('line','open',0,0,64,-1.271,4.412,72)
                GC.line(50.360,-69.573,18.913,-61.142,30.042,-30.545)
            end},
            {270,450,function()
                -- quit
                GC.line(-46,-46,46,46)
                GC.line(46,-46,-46,46)
            end},
            {450,450,function()
                -- undo
                GC.arc('line','open',26,0,42,-1.57,1.57)
                GC.line(26,-42,-60,-42)
                GC.line(26,42,-60,42)
                GC.line(
                    -60+20,42+20,
                    -60,42,
                    -60+20,42-20
                )
            end},
            {630,450,function()
                -- func2
                FONT.set(90); GC.mStr('F2',0,-60)
            end},
        } do
            GC.push()
            GC.translate(svg[1],svg[2])
            svg[3]()
            GC.pop()
        end
    end),
    quads=(function()
        local t={}
        local w=180
        for i,name in next,{
            'moveLeft','moveRight','softDrop','hardDrop',
            'rotateCW','rotateCCW','rotate180','holdPiece',
            'restart','back','func1','func2',
        } do if #name>0 then t[name]=GC.newQuad((i-1)%4*w,math.floor((i-1)/4)*w,w,w,4*w,3*w) end end
        return t
    end)(),
}

TEX=IMG.init(TEX,true)

return TEX
