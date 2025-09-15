-- Kaitun Auto Loader - Auto Rejoin Loop
local SCRIPT_URL = "https://raw.githubusercontent.com/sudaisontopxd/UAOT/refs/heads/main/kaitun"
local LOADER_URL = "https://raw.githubusercontent.com/sudaisontopxd/UAOT/refs/heads/main/KaitunLoader.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local Plr = Players.LocalPlayer

-- Notification function
local function notify(msg)
    print("[Loader] " .. tostring(msg))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Kaitun Loader",
            Text = msg,
            Duration = 5
        })
    end)
end

-- Fetch and load script
local function fetchAndLoad(url)
    local ok, res = pcall(game.HttpGet, game, url)
    if not ok or not res or res == "" then
        notify("Failed to fetch: " .. tostring(url))
        return nil
    end
    local fn, err = loadstring(res)
    if not fn then
        notify("Syntax error in script: " .. tostring(err))
        return nil
    end
    return fn
end

-- Queue on teleport (auto-rejoin)
do
    local executor = syn or fluxus or {}
    local queueteleport = queue_on_teleport or executor.queue_on_teleport
    if type(queueteleport) == "function" then
        local self_code = ("loadstring(game:HttpGet('%s'))()"):format(LOADER_URL)
        pcall(queueteleport, self_code)
        notify("Auto Rejoin Enabled")
    else
        notify("queue_on_teleport not supported by executor, use Synapse or Fluxus")
    end
end

-- Infinite Loader Loop
spawn(function()
    while true do
        -- Execute Kaitun
        notify("Executing Kaitun...")
        local fn = fetchAndLoad(SCRIPT_URL)
        if fn then
            local ok, err = pcall(fn)
            if not ok then
                notify("Runtime error: " .. tostring(err))
            end
        end

        -- Wait until Titans are 0
        notify("Waiting for Titans to be defeated...")
        repeat
            local titansFolder = Workspace:WaitForChild("Entities"):WaitForChild("Titans")
            task.wait(2)
        until #titansFolder:GetChildren() == 0

        -- Titans are gone, rejoin
        notify("All Titans defeated! Rejoining...")
        task.wait(2)
        TeleportService:Teleport(game.PlaceId, Plr)

        -- Wait 20–40 seconds for the game to properly load
        local waitTime = math.random(20, 40)
        notify("Waiting " .. waitTime .. " seconds for game to load...")
        task.wait(waitTime)
    end
end)
