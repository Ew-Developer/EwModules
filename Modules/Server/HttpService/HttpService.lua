--[[

Author: Ew-Developer
Usage:
HttpService:GetAsync(...)

]]--

local Module = {}
local HttpService = game:GetService("HttpService")

local OpenGetRequests = 0
function Module:GetAsync(...)
	repeat until OpenGetRequests == 0 or not wait()
	
	local Success,Data = pcall(HttpService.GetAsync,HttpService,...)
	
	if Success then
		return Data
	elseif Data:find("HTTP 429", 1, true) or Data:find("Number of requests exceeded limit", 1, true) then
		wait(math.random(2,5))
		warn("Too many requests")
		return Module:GetAsync(...)
	elseif Data:find("Http requests are not enabled", 1, true) then
		OpenGetRequests = OpenGetRequests + 1
		repeat
			local Success, Data = pcall(HttpService.GetAsync, HttpService, ...)
		until Success and not Data:find("Http requests are not enabled", 1, true) or not wait(1)
		OpenGetRequests = 0
		return Module:GetAsync(...)
	elseif Data:find("HTTP 503", 1, true) then
		warn(Data, (...))
		
		return ""
	elseif Data:find("HttpError: SslConnectFail", 1, true) then
		local t = math.random(2, 5)
		
		warn("HttpError: SslConnectFail error on "..tostring((...)).." trying again in "..t.." seconds.")
		
		wait(t)
		
		return Module:GetAsync(...)
	else
		error(Data..(...), 0)
	end
end

return Module
