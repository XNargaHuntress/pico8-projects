scr_mgr={
 screens={},
 active='none',
 last='none',
 transitioning=false,
 add=function(self,name,scr)
  self.screens[name]=scr
 end,
 update=function(self)
  if (self.active != 'none') then
   if (self.active != self.last) self.screens[self.active]:init()

   self.screens[self.active]:update()
  end
  self.last=self.active
 end,
 draw=function(self)
  if (self.active != 'none') self.screens[self.active]:draw()
 end
}

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
  end

  yield(arg)
 end
 scr_mgr.active=arg.scr
end
