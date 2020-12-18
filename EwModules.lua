--[[

Author: Ew-Developer
Usage:
EwModules(Service)

]]--

local RunService = game:GetService("RunService")

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function GetService(ServiceName,Location)
	if ServiceName and Location then
		if RunService:IsServer() then
			local Server = Location:FindFirstChild("Server")
			local Shared = Location:FindFirstChild("Shared")
			
			if Server then
				if Server:FindFirstChild(ServiceName) then
					return require(Server:FindFirstChild(ServiceName)) or nil
				end
			end
			if Shared then
				if Shared:FindFirstChild(ServiceName) then
					return require(Shared:FindFirstChild(ServiceName)) or nil
				end
			end
		elseif RunService:IsClient() then
			local Client = Location:FindFirstChild("Client")
			local Shared = Location:FindFirstChild("Shared")

			if Client then
				if Client:FindFirstChild(ServiceName) then
					return require(Client:FindFirstChild(ServiceName)) or nil
				end
			end
			if Shared then
				if Shared:FindFirstChild(ServiceName) then
					return require(Shared:FindFirstChild(ServiceName)) or nil
				end
			end
		else
			return error("Unknown state.")
		end
	end
	
	return nil
end

return function(ServiceName)
	if RunService:IsServer() then
		local EwModules = ServerScriptService:FindFirstChild("EwModules")
		return GetService(ServiceName,EwModules)
	elseif RunService:IsClient() then
		if not game:IsLoaded() then repeat wait() until game:IsLoaded() end
		
		local EwModules = ReplicatedStorage:FindFirstChild("EwModules_REPLICATED")
		return GetService(ServiceName,EwModules)
	else
		return error("Unknown state.")
	end
end
