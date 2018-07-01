plyr={
 x=0,
 y=0,
 hlth=3,
 grnd=false,
 wall=false,
 airtmr=0,
 airpress=false,
 vx=0,
 vy=0,
 bbox=aabb.new(0, 0, 8, 8)
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
 self.bbox = aabb.new(self.x, self.y, 8, 8)
end

function plyr:draw()
 local c = 7
 if (self.bbox == nil) c = 13
 rectfill(self.x-4,self.y-4,self.x+4,self.y+4,c)

 if (debug) then
  rect(self.bbox.x-self.bbox.hw,self.bbox.y-self.bbox.hh, self.bbox.x+self.bbox.hw,self.bbox.y+self.bbox.hh,8)
 end
end

function plyr:update()
 local h=0
 local j=0

 if (btn(1)) h+=1
 if (btn(0)) h-=1

 local hit=kmove(self,h*6,0)
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
