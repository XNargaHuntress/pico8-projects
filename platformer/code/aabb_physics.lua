-- function update_plyr()
--  local hx=0
--  local hy=0
--
--  if (plyr.grnd) then
--   hy=max(hy,0)
--  end
--
--  local hit=physics.move(plyr,hx,hy)
--  local hit2=physics.collide_map(plyr.box,0,1)
--
--  plyr.grnd=hit2.dy < 0
--  plyr.wall=sign(hit.dx)
--
-- end

physics={
 aabb_meta={
  setpos=function(self,x,y)
   self.x=x
   self.y=y
   self.x1=x-self.hw
   self.x2=x+self.hw
   self.y1=y-self.hh
   self.y2=y+self.hh
  end,
  collide=function(self,other)
   local hit=collision.hit(0,0,0x00)
   if (self.x1<other.x2 and self.x2>other.x1 and self.y1<other.y2 and self.y2>other.y1) then
    hit.dx=sign(self.x-other.x)*(self.hw+other.hw-abs(self.x-other.x))
    hit.dy=sign(self.y-other.y)*(self.hh+other.hh-abs(self.y-other.y))
   end
   return hit
  end
 }
 hit=function(dx,dy,flags)
  local h={}
  h.dx=dx
  h.dy=dy
  h.flags=flags
  return h
 end
 aabb=function(x,y,h,w)
  local box={}
  box.x=x
  box.y=y
  box.hh=h/2
  box.hw=w/2
  box.x1=x-w/2
  box.x2=x+w/2
  box.y1=y-w/2
  box.y2=y+w/2
  setmetatable(box,collision.aabb_meta)
  return box
 end,
 collide_map=function(box, dx, dy, mx, my)
  local hit=physics.hit(0,0,0x00)

  local x={}
  local y={}
  x[1]=flr((box.x1+dx)/8)
  x[2]=flr((box.x2+dx)/8)
  y[1]=flr((box.y1+dy)/8)
  y[2]=flr((box.y2+dy)/8)

  local f={}
  for i=0,1 do
   for j=0,1 do
    local flag=fget(mget(x[i+1],y[j+1]))
    f[1+(i*2)+j]=flag
    hit.flags = bor(hit.flags,flag)
   end
  end

  if (dy != 0) then
   hit.dy=physics.collide_map_dist(y[1],y[2],box.y1+dy,box.y2+dy,f[1],f[2],f[3],f[4],0x02)
  end

  if (dx != 0) then
   hit.dx=physics.collide_map_dist(x[1],x[2],box.x1+dx,box.x2+dx,f[1],f[3],f[2],f[4],0x02)
  end

  return hit
 end,
 collide_map_dist=function (m1,m2,v1,v2,f1,f2,f3,f4,fv)
  return ((m1+1)*8-v1)*band(bor(f1,f2),fv)/fv+(m2*8-v2)*band(bor(f3,f4),fv)/fv
 end,
 move=function(obj,dx,dy,mx,my)
  mx=mx or 0
  my=my or 0
  local hit=physics.hit(0,0,0x00)
  if (obj.box != nil) then
   hit=physics.collide_map(obj.aabb,dx,dy,mx,my)
   dx+=hit.dx
   dy+=hit.dy
  end

  obj.x+=dx
  obj.y+=dy

  if (obj.aabb != nil) obj.aabb:setpos(obj.x,obj.y)

  return hit
 end
}
