local SCRIPT_URL = "https://raw.githubusercontent.com/sudaisontopxd/UAOT/refs/heads/main/kaitun"
local LOADER_URL = "https://raw.githubusercontent.com/sudaisontopxd/UAOT/refs/heads/main/KaitunLoader.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local Plr = Players.LocalPlayer

-- Prevent rapid re-execution
do
    if getgenv().rz_last_exec and (tick() - getgenv().rz_last_exec) <= 2 then
        return
    end
    getgenv().rz_last_exec = tick()
end

-- Notification utility
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

-- Queue on teleport
do
    local executor = syn or fluxus or {}
    local queueteleport = queue_on_teleport or executor.queue_on_teleport
    if type(queueteleport) == "function" then
        local self_code = ("loadstring(game:HttpGet('%s'))()"):format(LOADER_URL)
        pcall(queueteleport, self_code)
        notify("Auto Rejoin Loaded")
    else
        notify("queue_on_teleport not supported by executor")
    end
end

-- Fetch + load utility
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

-- Flag to prevent repeated rejoin attempts
if getgenv().kaitunAlreadyLoaded == nil then
    getgenv().kaitunAlreadyLoaded = false
end

-- Check for Titans
local function titansExist()
    local entities = Workspace:FindFirstChild("Entities")
    if entities then
        local titans = entities:FindFirstChild("Titans")
        if titans and #titans:GetChildren() > 0 then
            return true
        end
    end
    return false
end

-- Main execution
if titansExist() then
    if not getgenv().kaitunAlreadyLoaded then
        local fn = fetchAndLoad(SCRIPT_URL)
        if fn then
            notify("Running Kaitun")
            local ok, err = pcall(fn)
            if not ok then
                notify("Runtime error: " .. tostring(err))
            else
                getgenv().kaitunAlreadyLoaded = true
            end
        end
    else
        notify("Kaitun already loaded")
    end
else
    if not getgenv().alreadyRejoined then
        notify("No Titans detected. Rejoining...")
        getgenv().alreadyRejoined = true
        TeleportService:Teleport(game.PlaceId, Plr)
    else
        notify("Already attempted rejoin, waiting for next load...")
    end
end
