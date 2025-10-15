--[[ 
♻️ INFINITE AUTO MISSION LOOP (REJOIN + AUTO START)
🧩 Features:
✅ Creates & starts private missions
✅ Queues kaitun and auto mission code before teleport
✅ Waits for mission end (GameFinished)
✅ Rejoins and continues forever
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- Detect queue_on_teleport support
local queue = queue_on_teleport or queueonteleport or syn and syn.queue_on_teleport
if not queue then
	warn("⚠️ Your executor does not support queue_on_teleport.")
end

-- === Code that should run after teleport ===
local kaitunQueue = [[
repeat task.wait() until game:IsLoaded()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for Titans to spawn
local success, TitansFolder = pcall(function()
	return workspace:WaitForChild("Entities"):WaitForChild("Titans", 30)
end)
if success and TitansFolder then
	repeat task.wait() until #TitansFolder:GetChildren() > 0
	loadstring(game:HttpGet("https://raw.githubusercontent.com/sudaisontopxd/UAOT/refs/heads/main/kaitun"))()
else
	warn("⚠️ Titans didn't spawn, retrying later...")
end

-- Wait for 5 seconds after kaitun executes, then restart mission loop
task.wait(5)
loadstring(game:HttpGet("https://raw.githubusercontent.com/sudaisontopxd/UAOT/refs/heads/main/autoMissionLoop.lua"))()
]]

-- === Mission Creation & Start ===
local function startMission()
	local network = ReplicatedStorage:WaitForChild("Network")
	local lobbyRemote = network:WaitForChild("LobbyRemote")

	print("🛰️ Creating Private Mission...")
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
	print("🚀 Starting Mission...")
	lobbyRemote:FireServer(table.unpack({
		[1] = "Start",
		[2] = { ["Modifiers"] = {} },
	}))

	-- Queue kaitun + rejoin loop for after teleport
	if queue then
		print("💾 Queuing kaitun + mission restart for teleport...")
		queue(kaitunQueue)
	else
		warn("❌ queue_on_teleport not supported.")
	end
end

-- === Wait for mission to end ===
local function waitForMissionEnd()
	local network = ReplicatedStorage:WaitForChild("Network")
	local gameFinished = network:WaitForChild("GameFinished", 10)

	if not gameFinished then
		warn("❌ Could not find GameFinished remote.")
		return nil
	end

	print("✅ Listening for GameFinished event...")
	return gameFinished.OnClientEvent
end

-- === Infinite Mission Loop ===
while task.wait(3) do
	print("🌌 Starting new mission cycle...")
	startMission()

	local event = waitForMissionEnd()
	if not event then
		task.wait(10)
		continue
	end

	local ended = false
	local connection
	connection = event:Connect(function(result, leaderboard)
		print("🎯 Mission Ended:", result)
		ended = true
		connection:Disconnect()

		if queue then
			print("💾 Queuing kaitun + restart for rejoin...")
			queue(kaitunQueue)
		end

		print("🔁 Rejoining server...")
		TeleportService:Teleport(game.PlaceId, player)
	end)

	task.wait(600) -- 10-minute safety timeout
	if not ended then
		warn("⏰ Timeout — Forcing rejoin.")
		if queue then queue(kaitunQueue) end
		TeleportService:Teleport(game.PlaceId, player)
	end
end
