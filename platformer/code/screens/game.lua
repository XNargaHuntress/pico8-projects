game={}

function game:init()
 camera_shake = 0
 cam.x = 0
 cam.y = 0
 plyr:spawn(64,64)
end

function game:update()
 camera_effects()
 plyr:update()
end

function game:draw()
 cls()
 map(0,0,0,0,16,16)
 plyr:draw()
end

scr_mgr:add('game',game)
