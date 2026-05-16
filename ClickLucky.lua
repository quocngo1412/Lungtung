-- [PHẦN 1] KHAI BÁO BIẾN ĐẦY ĐỦ
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game.Players.LocalPlayer

local Library = ReplicatedStorage.Library
local Client = ReplicatedStorage.Library.Client

local Network = require(Client.Network)
local Save = require(Client.Save)
local Breakables = workspace['__THINGS'].Breakables

-- [PHẦN 2] MỤC CÁC BREAK
local Farm = {
    ["LuckyBlock"] = true,  
    ["Lucky Block Large"] = true,
    ["Lucky Block Medium"] = true,
    ["Lucky Block Small"] = true
}

-- [PHẦN 3] VÒNG LẶP TỰ ĐỘNG QUÉT VÀ TẤN CÔNG (ĐÃ TỐI ƯU CHỐNG LAG)
task.spawn(function()
    -- Thay vì dùng while true với delay quá ngắn, cấu trúc này giúp giảm tải cho CPU
    while task.wait(0.05) do -- 0.15 giây là tốc độ hoàn hảo để vừa không lag vừa đập nhanh
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            local myPos = hrp.Position
            local breakablesList = Breakables:GetChildren() -- Lưu danh sách vào biến tạm để xử lý nhanh hơn
            
            for i = 1, #breakablesList do
                local v = breakablesList[i]
                local id = v:GetAttribute("BreakableID")
                
                if id and Farm[id] and v:IsA("Model") then
                    -- Tối ưu hóa việc tính khoảng cách (bỏ qua các khối không nằm trong vùng chứa để giảm tính toán)
                    local modelKey = v:GetPivot()
                    if modelKey then
                        local pos = modelKey.Position
                        local dist = (pos - myPos).Magnitude

                        if dist <= 300 then
                            -- Gửi lệnh đập block
                            Network.UnreliableFire("Breakables_PlayerDealDamage", v.Name)
                            -- Thêm một khoảng chờ siêu nhỏ để game không bị nghẽn mạng do gửi quá nhiều lệnh cùng 1 mili giây
                            task.wait(0.01) 
                        end
                    end
                end
            end
        end
    end
end)
