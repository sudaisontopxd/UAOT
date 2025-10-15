

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- Detect queue function
local queue = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)

-- 🌀 Kaitun + Mission Rejoin Logic (stored as one plain string)
local kaitunQueue = [[
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- Wait for Titans to spawn
local ok, TitansFolder = pcall(function()
	return workspace:WaitForChild("Entities"):WaitForChild("Titans", 30)
end)
if ok and TitansFolder then
	repeat task.wait() until #TitansFolder:GetChildren() > 0
	print("🌀 Titans spawned — running kaitun loader...")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/sudaisontopxd/UAOT/refs/heads/main/kaitun"))()
else
	warn("⚠️ Titans didn't spawn in time.")
end

-- Setup mission end detector
local network = ReplicatedStorage:FindFirstChild("Network") or ReplicatedStorage
local gameFinished = network:WaitForChild("GameFinished", 30)

if gameFinished then
	print("✅ Mission End Detector ready...")
	gameFinished.OnClientEvent:Connect(function(result)
		print("🏁 Mission finished:", result)
		task.wait()

		local queue = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
		if queue then
			print("💾 Re-queuing kaitun script for next join...")
			queue(game:HttpGet("https://raw.githubusercontent.com/sudaisontopxd/UAOT/refs/heads/main/autoMissionLoop.lua"))
		else
			warn("⚠️ queue_on_teleport not supported on this executor.")
		end

		print("🔁 Rejoining same place...")
		pcall(function()
			TeleportService:Teleport(game.PlaceId, player)
		end)
	end)
else
	warn("❌ No GameFinished event found.")
end
]]

-- 🧠 Function to create + start mission
local function startMission()
	local network = ReplicatedStorage:WaitForChild("Network")
	local lobbyRemote = network:WaitForChild("LobbyRemote")

	print("🛰️ Creating private mission...")
	lobbyRemote:FireServer(table.unpack({
		[1] = "CreateMission",
		[2] = {
			["Privacy"] = "Private",
			["DifficultyIndex"] = 3,
			["MapName"] = "Outside Walls",
			["Difficulty"] = "Hard",
		},
	}))

	task.wait(5)

	print("🚀 Starting mission...")
	lobbyRemote:FireServer(table.unpack({
		[1] = "Start",
		[2] = { ["Modifiers"] = {} },
	}))

	-- Queue kaitun immediately after mission starts
	if queue then
		print("💾 Queuing kaitun for mission teleport...")
		queue(kaitunQueue)
	else
		warn("⚠️ queue_on_teleport not supported.")
	end
end

-- 🔁 Infinite Mission Loop
while task.wait(3) do
	print("🌌 Starting mission cycle...")
	startMission()
	task.wait(99999) -- wait until teleport resets
end
