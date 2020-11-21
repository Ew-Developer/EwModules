--// Init \\--

if not game:GetService("RunService"):IsStudio() then error("Ew Modules can only be installed in studio!") end
if not game:GetService("RunService"):IsEdit() then error("Ew Modules can only be installed in edit mode!") end
if not game:GetService("RunService"):IsServer() then error("Ew Modules can only be installed on server!") end

local HE = game:GetService("HttpService").HttpEnabled or true
pcall(function()
	game:GetService("HttpService").HttpEnabled = true
end)

local VERSION = "0.0.1"
warn("Ew Modules v"..VERSION.."\nUsing '"..tostring(_VERSION).."'\nInstalling...")

--// Varibles \\--

local HttpService = game:GetService("HttpService")

local ScriptTypes = {
	[""] = "ModuleScript";
	["local"] = "LocalScript";
	["module"] = "ModuleScript";
	["mod"] = "ModuleScript";
	["loc"] = "LocalScript";
	["server"] = "Script";
	["client"] = "LocalScript";
}
local DataSources = {}

--// Functions \\--

function GetFirstChild(Parent,Name,Class)
	if Parent then
		local Objects = Parent:GetChildren()
		for Index = 1,#Objects do
			local Object = Objects[Index]
			if Object and Object.Name == Name and Object.ClassName == Class then
				return Object
			end
		end
	end
	
	local Child = Instance.new(Class,Parent)
	Child.Name = Name
	
	return Child,true
end

function UrlDecode(Character)
	return string.char(tonumber(Character, 16))
end

local OpenGetRequests = 0
function GetAsync(...)
	repeat until OpenGetRequests <= 0 or not wait()
	
	local Success,Data = pcall(HttpService.GetAsync,HttpService,...)
	
	if Success then
		return Data
	elseif string.find(Data,"HTTP 429",1,true) or string.find(Data,"Number of requests exceeded limit",1,true) then
		warn("EMI:Too many requests!")
		
		wait(math.random(5))
		
		return GetAsync(...)
	elseif string.find(Data,"Http requests are not enabled",1,true) then
		OpenGetRequests = OpenGetRequests + 1
		
		repeat
			warn("EMI:Http requests are not enabled!")
			Success,Data = pcall(HttpService.GetAsync,HttpService,...)
		until Success and not string.find(Data,"Http requests are not enabled",1,true) or not wait(1)
		
		OpenGetRequests = 0
		
		return GetAsync(...)
	elseif string.find(Data,"HTTP 503",1,true) then
		warn("EMI:"..Data.." "..(...))
		
		return ""
	elseif string.find(Data,"HttpError: SslConnectFail",1,true) then
		local Time = math.random(2,5)
		
		wait("EMI:SslConnectFail error on '".. tostring((...)) .."', trying again in "..Time.." seconds!")
		
		wait(Time)
		
		return GetAsync(...)
	else
		error("EMI:"..Data.." "..(...),0)
	end
end

function SetScriptSourceToLink(Link,Script)
	DataSources[Script] = Link
	Script.Source = GetAsync(Link)
end

function InstallRepository(Link,Directory,Parent,Routines,TypesSpecified)
	local Value = #Routines + 1
	Routines[Value] = false
	
	local MainExists
	
	local ScriptCount = 0
	local Scripts = {}
	
	local FolderCount = 0
	local Folders = {}
	
	local Data = GetAsync(Link)
	local ShouldSkip = false
	
	local _,StatsGraph = string.find(Data,"d-flex repository-lang-stats-graph",1,true)
	
	if StatsGraph then
		ShouldSkip = string.find(string.sub(Data,StatsGraph + 1,(string.find(Data,"</div>",StatsGraph,true) or 0/0) - 1),"%ALua%A") == nil
	end
	
	if not ShouldSkip then
		for Link in string.gmatch(Data,"<span class=\"css%-truncate css%-truncate%-target d%-block width%-fit\"><a class=\"js%-navigation%-open link%-gray%-dark\" title=\"[^\"]+\" %s*href=\"([^\"]+)\".-</span>") do
			if string.find(Link,"/[^/]+/[^/]+/tree") then
				FolderCount = FolderCount + 1
				Folders[FolderCount] = Link
			elseif string.find(Link,"/[^/]+/[^/]+/blob.+%.lua$") then
				local ScriptName,ScriptClass = string.match(Link,"([%w-_%%]+)%.?(%l*)%.lua$")
				local NameLower = string.lower(ScriptName)
				
				if NameLower ~= "install" and NameLower ~= "spec" and ScriptClass ~= "ignore" and ScriptClass ~= "spec" then
					if ScriptClass == "mod" or ScriptClass == "module" then TypesSpecified = true end
					
					ScriptCount = ScriptCount + 1
					if ScriptName == "_" or ScriptName == "main" or NameLower == "init" then
						for Index = ScriptCount,2,-1 do
							Scripts[Index] = Scripts[Index - 1]
						end
						
						Scripts[1] = Link
						MainExists = true
					else
						Scripts[ScriptCount] = Link
					end
				end
			end
		end
	end
	
	if ScriptCount > 0 then
		local ScriptLink = Scripts[1]
		local ScriptName,ScriptClass = string.match(ScriptLink,"([%w-_%%]+)%.?(%l*)%.lua$")
		ScriptName = string.gsub(string.gsub(ScriptName,"Library$","",1),"%%(%x%x)",UrlDecode)
		
		local Sub = string.sub(Link,19)
		local Link = string.gsub(Sub,"^(/[^/]+/[^/]+)/tree/[^/]+","%1",1)
		
		local LastFolder = string.match(Link,"[^/]+$")
		LastFolder = string.match(LastFolder,"^RBX%-(.-)%-Library$") or LastFolder
		
		if MainExists then
			local Directory = string.gsub(LastFolder,"%%(%x%x)",UrlDecode)
			ScriptName,ScriptClass = string.match(Directory,"([%w-_%%]+)%.?(%l*)%.lua$")
			
			if not ScriptName then ScriptName = string.match(Directory,"^RBX%-(.-)%-Library$") or Directory end
			if ScriptClass == "mod" or ScriptClass == "module" then TypesSpecified = true end
		end
		
		if MainExists then Directory = Directory + 2 end
		
		local Count = 0
		local function LocateFolder(FolderName)
			Count = Count + 1
			
			if Count > Directory then
				Directory = Directory + 1
				
				if (Parent and Parent.Name) ~= FolderName and "Modules" ~= FolderName then
					local Generated
					Parent,Generated = GetFirstChild(Parent,FolderName,"Folder")
					if Generated then
						if not Routines[1] then Routines[1] = Parent end
						
						DataSources[Parent] = "https://github.com"..(string.match(Sub,string.rep(("/[^/]+"),Directory > 2 and Directory + 2 or Directory)) or warn("EMI:[1]",Sub,Directory > 1 and Directory + 2 or Directory) or "")
					end
				end
			end
		end
		
		string.gsub(string.gsub(Link,"[^/]+$",""),"[^/]+", LocateFolder)
		
		if MainExists or ScriptCount ~= 1 or ScriptName ~= LastFolder then
			LocateFolder(LastFolder)
		end
		
		local Script = GetFirstChild(Parent,ScriptName,ScriptTypes[ScriptClass or TypesSpecified or "" or "mod"] or "ModuleScript")
		if not Routines[1] then Routines[1] = Script end
		
		coroutine.resume(coroutine.create(SetScriptSourceToLink),"https://raw.githubusercontent.com".. string.gsub(Link,"(/[^/]+/[^/]+/)blob/","%1",1),Script)
		
		if MainExists then Parent = Script end
		
		for Index = 2,ScriptCount do
			local Link = Scripts[Index]
			local ScriptName,ScriptClass = string.match(Link,"([%w-_%%]+)%.?(%l*)%.lua$")
			local Script = GetFirstChild(Parent,string.gsub(string.gsub(ScriptName,"Library$","",1),"%%(%x%x)",UrlDecode),ScriptTypes[ScriptClass or TypesSpecified and "" or "mod"] or "ModuleScript")
			
			coroutine.resume(coroutine.create(SetScriptSourceToLink),"https://raw.githubusercontent.com".. string.gsub(Link,"(/[^/]+/[^/]+/)blob/","%1",1),Script)
		end
	end
	
	for Index = 1,FolderCount do
		local Link = Folders[Index]
		
		coroutine.resume(coroutine.create(InstallRepository),"https://github.com"..Link,Directory,Parent,Routines,TypesSpecified)
	end
	
	Routines[Value] = true
end

local GitHub = {}
function GitHub:Install(Link,Parent,RoutineList)
	warn("EMI:Installing repository '"..Link.."'.")
	
	if string.byte(Link,-1) == 47 then
		Link = string.sub(Link,1,-2)
	end
	
	local Organization,Repository,Tree,ScriptName,ScriptClass
	local Website,Directory = string.match(Link,"^(https://[raw%.]*github[usercontent]*%.com/)(.+)")
	Organization,Directory = string.match((Directory or Link),"^/?([%w-_%.]+)/?(.*)")
	Repository,Directory = string.match(Directory,"^([%w-_%.]+)/?(.*)")
	
	if Website == "https://raw.githubusercontent.com/" then
		if Directory then
			Tree,Directory = string.match(Directory,"^([^/]+)/(.+)")
			if Directory then
				ScriptName,ScriptClass = string.match(Directory,"([%w-_%%]+)%.?(%l*)%.lua$")
			end
		end
	elseif Directory then
		local A,B = string.find(Directory,"^[tb][rl][eo][eb]/[^/]+")
		if A and B then
			Tree,Directory = string.sub(Directory,6,B),string.sub(Directory,B + 1)
			if Directory and string.find(Link,"blob",1,true) then
				ScriptName,ScriptClass = string.match(Directory,"([%w-_%%]+)%.?(%l*)%.lua$")
			end
		else
			Directory = nil
		end
	end
	
	if ScriptName then
		local NameLower = string.lower(ScriptName)
		if ScriptName == "_" or NameLower == "main" or NameLower == "init" then
			return GitHub:Install("https://github.com/"..Organization.."/"..Repository.."/tree/"..(Tree or "master").."/".. string.gsub(string.gsub(Directory,"/[^/]+$",""),"^/",""),Parent,RoutineList)
		end
	end
	
	if not Website then Website = "https://github.com/" end
	Directory = Directory and (string.gsub("/"..Directory,"^//","/")) or ""
	
	local Routines = RoutineList or {false}
	local Value = #Routines + 1
	Routines[Value] = false
	
	local Garbage
	
	if ScriptName then
		Link = "https://raw.githubusercontent.com/"..Organization.."/"..Repository.."/"..(Tree or "master")..Directory
		
		local Source = GetAsync(Link)
		
		local Script = GetFirstChild(Parent and not RoutineList and Repository ~= ScriptName and Parent.Name ~= ScriptName and Parent.Name ~= Repository and GetFirstChild(Parent,Repository,"Folder") or Parent,string.gsub(string.gsub(ScriptName,"Library$","",1),"%%(%x%x)",UrlDecode),ScriptTypes[ScriptClass or "mod"] or "ModuleScript")
		DataSources[Script] = Link
		
		if not Routines[1] then Routines[1] = Script end
		
		Script.Source = Source
	elseif Repository then
		Link = Website..Organization.."/"..Repository..((Tree or Directory ~= "") and ("/tree/"..(Tree or "master")..Directory) or "")
		
		if not Parent then Parent,Garbage = Instance.new("Folder"),true end
		
		coroutine.resume(coroutine.create(InstallRepository),Link,1,Parent,Routines)
	elseif Organization then
		Link = Website..Organization
		
		local Data = GetAsync(Link .."?tab=repositories")
		local Object = GetFirstChild(Parent,Organization,"Folder")
		
		if not Routines[1] then Routines[1] = Object end
		
		for Link,Data in string.gmatch(Data,'href="(/'..Organization..'/[^/]+)" itemprop="name codeRepository"(.-)</div>') do
			GitHub:Install(Link,Object,Routines)
		end
	end
	
	Routines[Value] = true
	
	if not RoutineList then
		repeat
			local Done = 0
			local Count = #Routines
			
			for Index = 1,Count do
				if Routines[Index] then
					Done = Done + 1
				end
			end
		until Done >= Count or not wait()
		
		local Object = Routines[1]
		
		if Garbage then
			Object.Parent = nil
			Parent:Destroy()
		end
		
		DataSources[Object] = Link
		
		return Object
	end
end

--// Install \\--

local RepositoriesToInstall = {
	{
		"https://github.com/Quenty/NevermoreEngine/tree/version2/Modules";
		game:GetService("ServerScriptService");
	};
}

local ThreadsDone = table.create(#RepositoriesToInstall,false)
for Index = 1,#RepositoriesToInstall do
	coroutine.resume(coroutine.create(function()
		local Installed = GitHub:Install(
			RepositoriesToInstall[Index][1],
			RepositoriesToInstall[Index][2]
		)
		if RepositoriesToInstall[Index][3] ~= nil then
			RepositoriesToInstall[Index][3](Installed)
		end
		ThreadsDone[Index] = true
		
		local Compleated = 0
		
		for Index = 1,#ThreadsDone do
			if ThreadsDone[Index] then
				Compleated = Compleated + 1
			end
		end
		
		warn("EMI:Installed repository '"..RepositoriesToInstall[Index][1].."'.\nEMI:"..Compleated.."/"..#RepositoriesToInstall.." repositories installed.")
	end))
end

repeat
	wait()
	
	local Finished = true
	
	for Index = 1,#ThreadsDone do
		if ThreadsDone[Index] == false then
			Finished = false
		end
	end
until Finished

--// End \\--

pcall(function()
	game:GetService("HttpService").HttpEnabled = HE
end)

warn("Ew Modules has installed!")
