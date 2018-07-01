debug=true

function _init()
 -- set initial screen here
 scr_mgr.active='game'
end

function _update()
 com:update()
 scr_mgr:update()
end

function _draw()
 scr_mgr:draw()
 if (debug) then
  print('cpu:'..stat(1),80,1,8)
  print('mem:'..stat(0),80,7,8)
  print('fps:'..stat(7),80,13,8)
 end
end
