function kmove(obj,xdist,ydist,mx,my)
 mx=mx or 0
 my=my or 0
 local hit=nil
 local x = xdist
 local y = ydist
 if (obj.bbox != nil) then
  hit=col_map(obj.bbox,x,y,mx,my)
  if (hit.flags > 0x00) then
   x += hit.x
   y += hit.y
  end
 end

 obj.x+=x
 obj.y+=y

 if (obj.bbox != nil) then
  obj.bbox.x=obj.x
  obj.bbox.y=obj.y
 end
 return hit
end

-- tests only the corners of the bounding box
-- 0x02 is reserved for solid tiles
function col_map(bbox,dx,dy,mx,my)
 mx=mx or 0
 my=my or 0
 h=h or 8
 w=w or 8

 local cx=bbox:corners_x(dx)
 local cy=bbox:corners_y(dy)

 local x2=flr(cx[2]/8)
 local y2=flr(cy[2]/8)
 local x1=flr(cx[1]/8)
 local y1=flr(cy[1]/8)

 local z={}
 z[1]=fget(mget(x1+mx,y1+my))
 z[2]=fget(mget(x2+mx,y1+my))
 z[3]=fget(mget(x1+mx,y2+my))
 z[4]=fget(mget(x2+mx,y2+my))

 local hit={}
 hit.x=0
 hit.y=0
 hit.flags=0x00

 hit.x=cdist(z,0x02,x1,cx[1],x2,cx[2],1,3,2,4)
 hit.y=cdist(z,0x02,y1,cy[1],y2,cy[2],1,2,3,4)

 for i=1,4 do
  hit.flags = bor(hit.flags,z[i])
 end

 return hit
end

function cdist(f,v,m1,o1,m2,o2,i1,i2,i3,i4)
 return ((m1+1)*8-o1)*(band(bor(f[i1],f[i2]),v)/v)+(m2*8-o2)*(band(bor(f[i3],f[i4]),v)/v)
end

aabb={
 new=function(x,y,w,h)
  local box={}
  box.x=x
  box.y=y
  box.w=w
  box.h=h
  box.hh=h/2
  box.hw=h/2
  function box:corners_x(dx)
   dx=dx or 0
   return {self.x-self.hw+dx, self.x+self.hw+dx}
  end
  function box:corners_y(dy)
   dy=dy or 0
   return {self.y-self.hh+dy, self.y+self.hh+dy}
  end
  return box
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
