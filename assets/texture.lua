local TEX={}

TEX.transition=GC.initCanvas(128, 1, function()
    for x=0,127 do
        GC.setColor(1, 1, 1, 1-x/128)
        GC.rectangle('fill', x, 0, 1, 1)
    end
end)

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
                -- func1
                FONT.set(90); GC.mStr('F1',0,-60)
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
