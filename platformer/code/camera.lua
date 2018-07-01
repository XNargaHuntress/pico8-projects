cam={}
cam.x = 0
cam.y = 0
cam.draw_x = 0
cam.draw_y = 0

function camera_effects()
 screen_shake()
end

camera_shake=0
function screen_shake()
 local fade = 0.625
 local o_x=16-rnd(32)
 local o_y=16-rnd(32)

 o_x *= camera_shake
 o_y *= camera_shake

 cam.draw_x = cam.x + o_x
 cam.draw_y = cam.y + o_y

 camera_shake *= fade
 if (camera_shake <0.05) then
  camera_shake = 0
 end
end
