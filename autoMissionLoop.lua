repeat task.wait() until game:IsLoaded()

-- ⚙️ Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- 🌐 Queue itself for next teleport
local function queueSelf()
	local code = game:HttpGet("https://raw.githubusercontent.com/sudaisontopxd/UAOT/refs/heads/main/autoMissionLoop.lua")
	if queue_on_teleport then
		queue_on_teleport(code)
	elseif queueteleport then
		queueteleport(code)
	elseif queue then
		queue(code)
	else
		warn("⚠️ No teleport queue function found.")
	end
end

-- 🔁 Always queue itself
queueSelf()

-- 🌀 Wait for Titans and run kaitun
local success, TitansFolder = pcall(function()
	return workspace:WaitForChild("Entities"):WaitForChild("Titans", 30)
end)

if success and TitansFolder then
	repeat task.wait() until #TitansFolder:GetChildren() > 0
	print("🌀 Titans spawned — running kaitun loader...")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/sudaisontopxd/UAOT/refs/heads/main/kaitun"))()
else
	warn("⚠️ Titans didn’t spawn in time.")
end

-- 🧭 Mission End Detector
task.wait()
local network = ReplicatedStorage:FindFirstChild("Network") or ReplicatedStorage
local gameFinished = network:FindFirstChild("GameFinished")

if gameFinished then
	print("✅ Mission End Detector ready...")

	gameFinished.OnClientEvent:Connect(function(result)
		print("🏁 Mission finished:", result)

		task.wait()
		print("🔁 Rejoining same place...")
		local ok, err = pcall(function()
			TeleportService:Teleport(game.PlaceId, player)
		end)
		if not ok then
			warn("⚠️ Teleport failed:", err)
		end
	end)
else
	warn("❌ No GameFinished event found.")
end
