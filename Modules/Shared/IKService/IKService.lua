local IK = {}

local EwModules = require(game:GetService("ReplicatedStorage"):WaitForChild("EwModules"))
local math = EwModules("Math")

function IK.solve(Origin,Target,Len1,Len2)
	local Localized = Origin:pointToObjectSpace(Target)
	local LocalizedUnit = Localized.Unit
	local Len3 = Localized.Magnitude
	
	local Axis = Vector3.new(0,0,-1):Cross(LocalizedUnit)
	local Angle = math.acos(-LocalizedUnit.Z)
	local Plane = Origin * CFrame.fromAxisAngle(Axis, Angle)
	
	if Len3 < math.max(Len2,Len1) - math.min(Len2,Len1) then
		return Plane * CFrame.new(0,0, math.max(Len2,Len1) - math.min(Len2,Len1) - Len3), -math.pi/2, math.pi
	elseif Len3 > Len1 + Len2 then
		return Plane * CFrame.new(0,0,Len1 + Len2 - Len3),math.pi/2,0
	else
		local Angle1 = -math.acos((-(Len2 * Len2) + (Len1 * Len1) + (Len3 * Len3)) / (2 * Len1 * Len3))
		local Angle2 = math.acos(((Len2  * Len2) - (Len1 * Len1) + (Len3 * Len3)) / (2 * Len2 * Len3))
		
		return Plane,Angle1 + math.pi/2,Angle2 - Angle1
	end
end

return IK
