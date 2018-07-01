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
