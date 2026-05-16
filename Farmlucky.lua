-- ==========================================
-- [PHẦN 1] KHAI BÁO BIẾN & THƯ VIỆN HỆ THỐNG
-- ==========================================
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game.Players.LocalPlayer

local Library = ReplicatedStorage.Library
local Client = ReplicatedStorage.Library.Client

local Network = require(Client.Network)
local Breakables = workspace['__THINGS'].Breakables

-- Thư viện Save xử lý dữ liệu túi đồ
local SaveModule = require(Client.Save)
local Save = SaveModule.Get or SaveModule.GetSave

-- Cấu hình danh sách Lucky Block muốn farm trên map
local FarmList = {
    ["LuckyBlock"] = true,  
    ["Lucky Block Large"] = true,
    ["Lucky Block Medium"] = true,
    ["Lucky Block Small"] = true,
    ["Mini Lucky Block"] = true
}

local PinataUid = nil 

-- ==========================================
-- [PHẦN 2] CÁC TÍNH NĂNG TỰ ĐỘNG NHẶT (MỚI THÊM)
-- ==========================================

-- 1. Tự động hút túi quà (Lootbags) ngay khi vừa rơi ra
task.spawn(function()
    local LootbagsFolder = workspace['__THINGS']:FindFirstChild("Lootbags")
    if LootbagsFolder then
        LootbagsFolder.ChildAdded:Connect(function(lootbag)
            task.wait()
            if lootbag then
                Network.Fire("Lootbags_Claim", { lootbag.Name })
            end
        end)
    end
end)

-- 2. Tự động nhặt sạch các hạt Orb (Tiền, Kim cương, EXP) trên map
task.spawn(function()
    Network.Fired("Orbs: Create"):Connect(function(InfoTable)
        local Orbs = {}
        for _, v in ipairs(InfoTable) do
            table.insert(Orbs, v.id)
        end
        Network.Fire("Orbs: Collect", Orbs)
    end)
end)

-- ==========================================
-- [PHẦN 3] HÀM KIỂM TRA MINI LUCKY BLOCK TRONG TÚI
-- ==========================================
local GetPinataUID = function() 
    local currentSave = (type(Save) == "function" and Save()) or Save
    if not currentSave or not currentSave.Inventory or not currentSave.Inventory.Misc then 
        return nil 
    end
    
    local Misc = currentSave.Inventory.Misc 
    if PinataUid then 
        local Entry = Misc[PinataUid] 
        if Entry and Entry.id == "Mini Lucky Block" then 
            return PinataUid 
        end 
        PinataUid = nil 
    end 
    for uid, v in pairs(Misc) do 
        if v.id == "Mini Lucky Block" then 
            PinataUid = uid 
            return uid 
        end 
    end 
    return nil 
end 

-- ==========================================
-- [PHẦN 4] VÒNG LẶP 1: TỰ ĐỘNG ĐẶT MINI LUCKY BLOCK
-- ==========================================
task.spawn(function()
    while true do
        local targetUid = GetPinataUID()
        if targetUid then 
            local a, e = Network.Invoke("MiniLuckyBlock_Consume", targetUid) 
            
            if not a and e ~= "There is already something in this area!" and e ~= "There are too many random events already in the world!" then 
                repeat 
                    local retryUid = GetPinataUID()
                    if not retryUid then break end
                    a, e = Network.Invoke("MiniLuckyBlock_Consume", retryUid) 
                    task.wait(0.2) 
                until a 
            end 
        else 
            print("Không tìm thấy Mini Lucky Block trong túi đồ!") 
            task.wait(5)
        end
        task.wait(1)
    end
end)

-- ==========================================
-- [PHẦN 5] VÒNG LẶP 2: TỰ ĐỘNG QUÉT VÀ TẤN CÔNG
-- ==========================================
task.spawn(function()
    while true do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            for _, v in pairs(Breakables:GetChildren()) do
                local id = v:GetAttribute("BreakableID")
                
                if v:IsA("Model") and id and FarmList[id] then
                    local pos = v:GetPivot().Position
                    local dist = (pos - hrp.Position).Magnitude

                    if dist <= 300 then
                        Network.UnreliableFire("Breakables_PlayerDealDamage", v.Name)
                    end
                end
            end
        end
        
        task.wait(0.15)
    end
end)
