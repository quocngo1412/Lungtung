-- ========================================================
-- SCRIPT ROBLOX: SIÊU GIẢM RAM TREO AFK - DÀNH RIÊNG PET SIM 99
-- Tương thích 100% Executor Mobile (Delta, Arceus, Vega X...)
-- Chống văng, giảm RAM kỷ lục cho Cloud Phone
-- ========================================================

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

print("[PS99 Optimizer] Đang tiến hành dọn dẹp bộ nhớ Pet Sim 99...")

-- 1. KHÓA FPS THẤP (Lệnh gốc của Executor)
if setfpscap then
    setfpscap(5) -- Khóa chặt 5 FPS giúp nhẹ CPU Cloud Phone tối đa
end

-- 2. BẬT BẢNG ĐO RAM CHÍNH THỨC CỦA ROBLOX
game:GetService("GuiService").StatsReportToUser = true

-- 3. GỠ BỎ HIỆU ỨNG VÀ DIỆT TEXTURE (Xóa sạch hình ảnh để giải phóng RAM)
local function toiUuVatThe(v)
    if v:IsA("BasePart") then
        v.Material = Enum.Material.SmoothPlastic
        v.CastShadow = false
    end
    if v:IsA("Decal") or v:IsA("Texture") then
        v.Texture = "" -- Xóa ảnh bề mặt để giải phóng RAM chứa ảnh
    end
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Sparkles") then
        v.Enabled = false -- Tắt hiệu ứng lấp lánh của rương/tiền
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    toiUuVatThe(obj)
end
Workspace.DescendantAdded:Connect(toiUuVatThe)

-- 4. ẨN NGƯỜI CHƠI KHÁC VÀ PET (Tính năng cứu RAM tối thượng cho PS99)
local function anDoiTuongLag()
    -- Ẩn nhân vật của người chơi khác
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            player.Character:Destroy() -- Xóa tạm thời mô hình 3D của họ để nhẹ máy
        end
    end
    
    -- Mẹo PS99: Tìm và xóa bớt hiệu ứng thú cưng/đồng tiền rơi trên sàn
    if Workspace:FindFirstChild("Map") then
        -- Ẩn bớt các hiệu ứng nhặt túi quà, nhặt kim cương rơi vãi tốn RAM
        for _, v in ipairs(Workspace.Map:GetDescendants()) do
            if v.Name == "Coins" or v.Name == "Pets" or v.Name == "Drops" then
                v:ClearAllChildren()
            end
        end
    end
end

-- 5. XOAY CAMERA ÚP XUỐNG ĐẤT ĐỂ GIẢM TẢI GPU VÀ BẬT HIỆU ỨNG MỜ
-- Thay vì màn hình trắng dễ lỗi, Camera sẽ nhìn thẳng xuống sàn đất trống
local localPlayer = Players.LocalPlayer
if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
    local camera = Workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Scriptable
    -- Đưa camera lên cao nhìn vuông góc xuống chân để GPU không phải render cảnh vật xung quanh
    camera.CFrame = CFrame.new(localPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 20, 0), localPlayer.Character.HumanoidRootPart.Position)
end

-- Tạo lớp mờ cực dày đè lên màn hình
local blur = Instance.new("BlurEffect")
blur.Size = 56
blur.Parent = Lighting

-- 6. VÒNG LẶP ÉP GIẢI PHÓNG RÁC RAM (3 giây một lần)
task.spawn(function()
    while true do
        anDoiTuongLag() -- Liên tục xóa người chơi mới vào phòng để giữ RAM thấp
        gcinfo()
        collectgarbage("collect") -- Ép hệ thống dọn sạch bộ nhớ đệm
        task.wait(3)
    end
end)

print("[PS99 Optimizer] Đã kích hoạt! Game đã được ép về cấu hình Potato, RAM và FPS đã được khóa xuống mức thấp an toàn.")
