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
