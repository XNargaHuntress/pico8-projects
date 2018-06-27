pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- template
-- by laerin
debug=false

function _init()
 -- set initial screen here
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

com={
 routines={},
 args={},
 add_cor=function(self,cor,arg)
  local cid=cocreate(cor)
  add(self.routines,cid)
  if (arg != nil) self.args[cid]=arg
  return cid
 end,
 del_cor=function(self,cid)
  del(self.routines,cid)
  if (self.args[cid]!=nil) self.args[cid]=nil
 end,
 update=function(self)
  for cor in all(self.routines) do
   local alive=false
   if (self.args[cor]==nil) then
    alive=coresume(cor)
   else
    alive,self.args[cor]=coresume(cor,self.args[cor])
   end

   if (not alive) del(self.routines,cor)
  end
 end
}

scr_mgr={
 screens={},
 active='none',
 last='none',
 transitioning=false,
 add=function(self,name,scr)
  self.screens[name]=scr
 end,
 update=function(self)
  if (self.active != 'none')
   if (self.active != self.last) self.screens[self.active]:init()

   self.screens[self.active]:update()
  end
  self.last=self.active
 end,
 draw=function(self)
  self.screens[self.active]:draw()
 end
}

fade_mgr={
 val=0,
 tbl={
  {0,0,0,0,0,0,0,0},
  {1,1,1,1,0,0,0,0},
  {2,2,2,2,1,0,0,0},
  {3,3,3,3,1,0,0,0},
  {4,4,2,2,2,1,0,0},
  {5,5,5,1,1,1,0,0},
  {6,6,13,13,5,5,1,0},
  {7,6,6,13,13,5,1,0},
  {8,8,8,2,2,2,0,0},
  {9,9,4,4,4,5,0,0},
  {10,10,9,4,4,5,5,0},
  {11,11,3,3,3,3,0,0},
  {12,12,12,3,1,1,1,0},
  {13,13,5,5,1,1,1,0},
  {14,14,13,4,2,2,1,0},
  {15,15,13,13,5,5,1,0}
 },
 fade=function(self,idx)
  if (idx==nil or idx==0) then
   pal()
   self.val=0
  else
   self.val=idx
   for i=0,15 do
    pal(i,self.tbl[i+1][idx])
   end
  end
 end
}

function fpal(from,to)
 pal(from,fade_mgr.tbl[to+1][fade_mgr.val])
end

function fpal_all(c)
 for i=0,15 do
  fpal(i,c)
 end
end

function trans(scr,t,delay,func,inout)
 func = func or fade_inout
 if (not scr_mgr.transitioning) then
  scr_mgr.transitioning = true
  local arg={}
  arg.t=t
  arg.delay=delay
  arg.tmr=0
  arg.scr=scr
  arg.inout=inout or false

  com:add_cor(func,arg)
 end
end

function fade_inout(arg)
 while (arg.delay > 0) do
  arg.delay -= 1
  yield(arg)
 end

 while (arg.tmr < arg.t) do
  arg.tmr += 1
  local p = arg.tmr/arg.t

  if (not arg.inout) then
   fade_mgr:fade(flr(p*7))
  else
   if (p<0.5) then
    fade_mgr:fade(flr(14*p))
   else
    scr_mgr.active=arg.scr
    fade_mgr:fade(flr(14-14*p))
  end

  yield(arg)
 end
 scr_mgr.active=arg.scr
end

function sign(a)
 if (a > 0) then return 1 end
 if (a < 0) then return -1 end
 if (a == 0) then return 0 end
end

function dist(x1,y1,x2,y2)
 local x=abs(x1-x2)
 local y=abs(y1-y2)
 return sqrt(x*x+y*y)
end
-->8
-- game screen
game={}

function game:init()
 camera_shake = 0
 cam.x = 0
 cam.y = 0
end

function game:update()
 camera_effects()
end

function game:draw()
end

scr_mgr:add('game',game)

plyr={
 x=0,
 y=0,
 hlth=3,
 grnd=false,
 wall=false,
 airtmr=0,
 airpress=false,
 vx=0,
 vy=0
}

function plyr:spawn(x,y)
 self.hlth=3
 self.x=x
 self.y=y
 self.grnd=false
 self.wall=0
 self.airtmr=0
 self.airpress=false
 self.vx=0
 self.vy=0
end

function plyr:update()
 local h=0
 local j=0

 if (btn(0)) h+=1
 if (btn(1)) h-=1

 local hit=kmove(self,h*8,0)
 if (not hit) then
  self.grnd=false
  self.wall=0
 else
  self.grnd=hit.y<0
  self.wall=sign(hit.x)
 end
end

function plyr:destroy()
end

function kmove(obj,xdist,ydist,mx,my)
 mx=mx or 0
 my=my or 0
 local hit=nil
 if (obj.bbox) then
  hit=col_map(obj.bbox.x-obj.bbox.hw,obj.bbox.y-obj.bbox.hh,obj.bbox.h,obj.bbox.w,mx,my)
  if (hit.flags > 0x00) then
   distx += hit.x
   disty += hit.y
  end
 end

 obj.x+=xdist
 obj.y+=ydist
 return hit
end

-- tests only the corners of the bounding box
-- 0x02 is reserved for solid tiles
function col_map(x,y,h,w,mx,my)
 mx=mx or 0
 my=my or 0
 h=h or 8
 w=w or 8

 local x2=flr((x+w)/8)
 local y2=flr((y+h)/8)
 local x1=flr(x/8)
 local y1=flr(y/8)

 local h={}
 h[1]=fget(mget(x+mx,y+my))
 h[2]=fget(mget(x2+mx,y+my))
 h[3]=fget(mget(x+mx,y2+my))
 h[4]=fget(mget(x2+mx,y2+my))

 local hit={}
 hit.x=0
 hit.y=0
 hit.flags=0x00

 for i=1,4 do
  if (band(h[i],0xFF) > 0x00) then
   if (band(h[i],0x02)==0x02) then
    local i2=flr((i-1)/2)
    hit.x += ((i%2)*(x-x1*8)) + ((i%2-1)*(x2*8-x-w))
    hit.y += (i2-1)*(y1*8-y) + i2*(y2*8-y-h)
   end
   hit.flags |= h[i]
  end
 end
end

bbox={
 new=function(x,y,w,h)
  local box={}
  box.cx=x
  box.cy=y
  box.w=w
  box.h=h
  box.hh=h/2
  box.hw=h/2
 end
}

function col_box(b1,b2)
 local hit={}
 hit.x=0
 hit.y=0
 hit.hit=false
 if (abs(b1.x-b2.x) < (b1.hw+b2.hw)) then
  if (abs(b1.y-b2.y) < (b1.hh+b2.hh)) then
   hit.hit=true
   local xd=sign(b1.x-b2.x)
   local yd=sign(b1.y-b2.y)
   hit.x=(b1.x-xd*b1.hw)-(b2.x+xd*b2.hw)
   hit.y=(b1.y-yd*b1.hh)-(b2.y+yd*b2.hh)
  end
 end

 return hit
end

-->8
-- camera
cam={}
cam.x = 0
cam.y = 0
cam.draw_x = 0
cam.draw_Y = 0

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
__gfx__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000c00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000c00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000559000c000c00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000595555555595777000ccc0c0cccc0c00c0c0cc0c0cc000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000595555959595577060c000c0c00c0c00c0c0000c00c077776000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000599000c000c0c00c0c00c0c0c00c0cc000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000005555500060c000c0c00c0c0c00c0000c00c077760000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000c0cccc0c0000c0cc0c000c00000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000c00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000c00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000559000c000c00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000595555555595777000ccc0c0cccc0c00c0c0cc0c0cc000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000595555959595577060c000c0c00c0c00c0c0000c00c077776000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000599000c000c0c00c0c00c0c0c00c0cc000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000005555500060c000c0c00c0c0c00c0000c00c077760000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000c0cccc0c0000c0cc0c000c00000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000c00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000559000c000c00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000595555555595777000ccc0c0cccc0c00c0c0cc0c0cc000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000595555959595577060c000c0c00c0c00c0c0000c00c077776000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000599000c000c0c00c0c00c0c0c00c0cc000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000005555500060c000c0c00c0c0c00c0000c00c077760000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000c0cccc0c0000c0cc0c000c00000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000c00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000c00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000559000c000c00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000595555555595777000ccc0c0cccc0c00c0c0cc0c0cc000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000595555959595577060c000c0c00c0c00c0c0000c00c077776000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000599000c000c0c00c0c00c0c0c00c0cc000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000005555500060c000c0c00c0c0c00c0000c00c077760000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000c0cccc0c0000c0cc0c000c00000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000c00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000c00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000559000c000c00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000595555555595777000ccc0c0cccc0c00c0c0cc0c0cc000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000595555959595577060c000c0c00c0c00c0c0000c00c077776000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000599000c000c0c00c0c00c0c0c00c0cc000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000005555500060c000c0c00c0c0c00c0000c00c077760000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000c0cccc0c0000c0cc0c000c00000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999999000000000000000900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900000000
00000000000000000000000000000000000000000000000000000000000000000000000099999999999999000000000000000900000000000000000900000000
00000000000000000000000000000000000000000000000000000000000000000000000077777777777777990000000000000909999090090999909909000000
00000000000000000000000000000000000000000000000000000000000000000000000077777777777777990000006770000909009090090900000900060000
00000000000000000000000000000000000000000000000000000000000000000000000099999999999999000000000000900909009090090990900900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067770900909009090090000900900060000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000999909999099090999900999000000
0000000000000000000000000000000000000000000000000000000000000000000000000cc00000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000cccc0000cc000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000cccccc00cccc0000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000ccccccc0ccccccc0ccccccc00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000cccccc00cccc0000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000cccc0000cc000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000cc00000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000c000c00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000c000c00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000c000c00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000ccc0c0cccc0c00c0c0cc0c0cc000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000060c000c0c00c0c00c0c0000c00c077776000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000c000c0c00c0c00c0c0c00c0cc000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000060c000c0c00c0c0c00c0000c00c077760000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000c000c0cccc0c0000c0cc0c000c00000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000055999999999999999999999999999999999999999999999990000000000000000000000000000000000
00000000000000000000000000000000059555555559577777777777777777777777777777777777777777777777779900000000000000000000000000000000
00000000000000000000000000000000059555595959557777777777777777777777777777777777777777777777779900000000000000000000000000000000
00000000000000000000000000000000000000000000059999999999999999999999999999999999999999999999990000000000000000000000000000000000
00000000000000000000000000000000000000000555550000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000099999990000000000000009000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000009000000000000000009000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000009099990900909999099090000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000067700009090090900909000009000600000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000009009090090900909909009000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000677709009090090900900009009000600000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000009999099990990909999009990000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000666066606660066006600000066666000000666006600000066066606660666066600000000000000000000000000000
00000000000000000000000000000000606060606000600060000000660006600000060060600000600006006060606006000000000000000000000000000000
00000000000000000000000000000000666066006600666066600000660606600000060060600000666006006660660006000000000000000000000000000000
00000000000000000000000000000000600060606000006000600000660006600000060060600000006006006060606006000000000000000000000000000000
00000000000000000000000000000000600060606660660066000000066666000000060066000000660006006060606006000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0002020202000202000000000000000000000000020200080000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004b4c4d4e4f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000494a59595959595a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005b5c5d5e5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000103000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
150000000000000000000000000000000000000000000000000000000000000000000000000001030000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
150000000000161700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15000000000102030000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000008080000080b0000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000b0b09000008080000000000080908000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15000000000000000000000000000102030000000000000000000102030000000000000000000000000000000000000000000809000808090900080800090900000b0b09000008080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080b0008080909000808000b080000080809000809080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080008080008080909000a0b000808000008080000080b090024250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080008080008080b09000b0800080808000a0b08000808090034350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000808000b09080900080800080808000a080a000808090034350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000808000809080900080800080808000a080a000808090034350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080008080008090a0800080800080808000a0808000808090034350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000010203000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000000000000000000161700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000102030000000000000000000000000000000000000000000000010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000102030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500010203000000000000000000000000000000000000000000000000000000000000000000000103000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0430303030300607070430303030300604303030303006070704303030303006043030303030060707043030303030060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010900000c5510c5510c5530e0000e5510e5510e553161000f5510f5510f5530510011551115511155300000135511355113553000000f5510f5510f553000001355113551135520000000000000000000000000
