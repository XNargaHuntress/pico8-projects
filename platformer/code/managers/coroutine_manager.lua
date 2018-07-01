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
