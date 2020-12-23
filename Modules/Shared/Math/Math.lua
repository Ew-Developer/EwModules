local Math = {}

function Math.inverse(Num)
  Num = tonumber(Num)
  return Num - (Num * 2)
end

function Math.huge()
  return math.huge
end
function Math.low()
  return -(Math.huge())
end

setmetatable(Math,{
  __index = math
})
return Math
