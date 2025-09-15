-- Kaitun Auto Loader with Auto Rejoin Loop (Waits for Titans)
local SCRIPT_URL = "https://raw.githubusercontent.com/sudaisontopxd/UAOT/refs/heads/main/kaitun"
local LOADER_URL = "https://raw.githubusercontent.com/sudaisontopxd/UAOT/refs/heads/main/KaitunLoader.lua"

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local Plr = Players.LocalPlayer

-- Prevent rapid re-execution
do
    if getgenv().rz_last_exec and (tick() - getgenv().rz_last_exec) <= 2 then
        return
    end
    getgenv().rz_last_exec = tick()
end

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

-- Fetch and load script
local function fetchAndLoad(url)
    local ok, res = pcall(game.HttpGet, game, url)
    if not ok or not res or res == "" then
        notify("Failed to fetch: " .. tostring(url))
        return nil
    end
    local fn, err = loadstring(res)
    if not fn then
        notify("Syntax error in: " .. tostring(url) .. "\n" .. tostring(err))
        return nil
    end
    return fn
end

-- Flag to prevent reloading Kaitun multiple times
getgenv().kaitunLoaded = getgenv().kaitunLoaded or false

-- Infinite loader loop
spawn(function()
    while true do
        local titansFolder = Workspace:FindFirstChild("Entities") and Workspace.Entities:FindFirstChild("Titans")

        if titansFolder then
            local titans = titansFolder:GetChildren()
            if #titans > 0 then
                -- Wait until all Titans are fully spawned
                local fullySpawned = true
                for _, titan in ipairs(titans) do
                    if not titan:FindFirstChild("Humanoid") or not titan.PrimaryPart then
                        fullySpawned = false
                        break
                    end
                end

                if fullySpawned then
                    if not getgenv().kaitunLoaded then
                        notify("All Titans spawned! Executing Kaitun...")
                        local fn = fetchAndLoad(SCRIPT_URL)
                        if fn then
                            local ok, err = pcall(fn)
                            if not ok then
                                notify("Runtime error: " .. tostring(err))
                            else
                                getgenv().kaitunLoaded = true
                            end
                        end
                    else
                        notify("Kaitun already loaded, skipping...")
                    end
                else
                    notify("Waiting for Titans to fully spawn...")
                end
            else
                notify("No Titans detected. Rejoining...")
                getgenv().kaitunLoaded = false
                task.wait(2)
                TeleportService:Teleport(game.PlaceId, Plr)
                task.wait(10)
            end
        else
            notify("No Titans folder found. Rejoining...")
            getgenv().kaitunLoaded = false
            task.wait(2)
            TeleportService:Teleport(game.PlaceId, Plr)
            task.wait(10)
        end

        task.wait(5)
    end
end)
