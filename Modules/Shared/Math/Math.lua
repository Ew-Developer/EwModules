local Module = {}

function Module.inverse(Num)
  Num = tonumber(Num)
  return Num - (Num * 2)
end

setmetatable(Module,{
  __index = math
})
return Module
