-- ========================================================
-- SCRIPT ROBLOX MOBILE: KHÓA 5 FPS + HẠ ĐỒ HỌA HẾT CỠ + MÀN TRẮNG
-- Thiết kế tối ưu tổng lực cho Pet Simulator 99 trên Cloud Phone
-- Cách dùng: Bấm nút trên cùng màn hình để BẬT / TẮT màn trắng
-- ========================================================

local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local trangThaiAFK = false
local mainGui = nil
local whiteFrame = nil
local afkButton = nil
local loopDonRac = nil

-- ========================================================
-- 1. ÉP CẤU HÌNH ĐỒ HỌA ẨN CỦA ROBLOX VỀ MỨC KHÔNG (POTATO)
-- Lệnh này chạy ngay lập tức và giữ cố định kể cả khi tắt màn trắng
-- ========================================================
local settings = settings()
if settings and settings.Rendering then
    settings.Rendering.QualityLevel = Enum.QualityLevel.Level01 -- Đồ họa mức 1 (Thấp nhất)
    settings.Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.DistanceBased
end

-- Tắt toàn bộ bóng đổ toàn cục và hiệu ứng ánh sáng nặng
Lighting.GlobalShadows = false
Lighting.FogEnd = 999999
for _, obj in ipairs(Lighting:GetChildren()) do
    if obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") then
        obj:Destroy() -- Xóa sạch hiệu ứng tia sáng mặt trời, làm mờ, lấy nét sâu
    end
end

-- ========================================================
-- 2. KHÓA FPS Ở MỨC 5 CỐ ĐỊNH (CỨU CPU KHÔNG BỊ QUÁ TẢI)
-- Vòng lặp cưỡng bức đảm bảo FPS luôn ở mức 5 dù game nặng hay nhẹ
-- ========================================================
if setfpscap then 
    setfpscap(5) 
end

local thoiGianChoFps = 1 / 5
RunService.Heartbeat:Connect(function()
    local batDau = os.clock()
    repeat until (os.clock() - batDau) >= thoiGianChoFps
end)

-- ========================================================
-- 3. TẠO GIAO DIỆN UI NÚT BẤM VÀ MÀN HÌNH TRẮNG
-- ========================================================
if CoreGui:FindFirstChild("MobileAFKRamGui") then
    CoreGui.MobileAFKRamGui:Destroy()
end

mainGui = Instance.new("ScreenGui")
mainGui.Name = "MobileAFKRamGui"
mainGui.DisplayOrder = 9999999
mainGui.IgnoreGuiInset = true
mainGui.Parent = CoreGui

whiteFrame = Instance.new("Frame")
whiteFrame.Size = UDim2.new(1, 0, 1, 0)
whiteFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
whiteFrame.BorderSizePixel = 0
whiteFrame.Visible = false
whiteFrame.ZIndex = 1
whiteFrame.Parent = mainGui

afkButton = Instance.new("TextButton")
afkButton.Size = UDim2.new(0, 180, 0, 45) 
afkButton.Position = UDim2.new(0.5, -90, 0, 12)
afkButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
afkButton.Text = "AFK: OFF\nĐang tính RAM & FPS..."
afkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
afkButton.Font = Enum.Font.SourceSansBold
afkButton.TextSize = 13
afkButton.ZIndex = 2
afkButton.Parent = mainGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = afkButton

-- Cập nhật bảng đo thông số RAM/FPS sau mỗi 1 giây
task.spawn(function()
    while mainGui and afkButton do
        local thongSoRam = Stats:GetTotalMemoryUsageMb()
        local thongSoFps = math.round(1 / RunService.Heartbeat:Wait())
        local chuoiThongTin = string.format("RAM: %d MB | FPS: %d", math.round(thongSoRam), thongSoFps)
        
        if trangThaiAFK then
            afkButton.Text = "⚡ AFK: ON (MÀN TRẮNG)\n" .. chuoiThongTin
        else
            afkButton.Text = "❌ AFK: OFF (ĐỒ HỌA THẤP)\n" .. chuoiThongTin
        end
        task.wait(1)
    end
end)

-- ========================================================
-- 4. HÀM ÉP HẠ VẬT LIỆU MAP ĐỂ CỨU RAM
-- ========================================================
local function quetVaGiamRamMap(v)
    if v:IsA("BasePart") then
        v.Material = Enum.Material.SmoothPlastic
        v.CastShadow = false
    end
    if v:IsA("MeshPart") then
        v.CollisionFidelity = Enum.CollisionFidelity.Box
        v.RenderFidelity = Enum.RenderFidelity.Performance
    end
    if v:IsA("Decal") or v:IsA("Texture") then
        v.Texture = "" -- Xóa sạch ảnh tốn RAM
    end
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Sparkles") then
        v.Enabled = false -- Tắt toàn bộ hiệu ứng lấp lánh của kim cương/tiền xu rơi
    end
end

-- Chạy quét giảm cấu hình vật thể ngay khi load script
for _, obj in ipairs(Workspace:GetDescendants()) do
    quetVaGiamRamMap(obj)
end
Workspace.DescendantAdded:Connect(quetVaGiamRamMap)

-- ========================================================
-- 5. LOGIC KHI BẤM NÚT BẬT / TẮT MÀN TRẮNG
-- ========================================================
local function xuLyKichHoatAFK()
    trangThaiAFK = not trangThaiAFK
    
    if trangThaiAFK then
        -- --- BẬT MÀN HÌNH TRẮNG ---
        RunService:Set3dRenderingEnabled(false) -- GPU nghỉ ngơi hoàn toàn
        
        -- Chạy vòng lặp dọn rác RAM siêu tốc (3 giây/lần)
        gcinfo()
        collectgarbage("collect")
        loopDonRac = task.spawn(function()
            while trangThaiAFK do
                gcinfo()
                collectgarbage("collect")
                task.wait(3)
            end
        end)
        
        whiteFrame.Visible = true
        afkButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50) -- Đổi sang màu xanh lá
    else
        -- --- TẮT MÀN HÌNH TRẮNG ---
        RunService:Set3dRenderingEnabled(true) -- Bật lại hình ảnh 3D cấu hình thấp
        
        if loopDonRac then
            task.cancel(loopDonRac)
            loopDonRac = nil
        end
        
        whiteFrame.Visible = false
        afkButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Đổi về màu đỏ
    end
end

afkButton.MouseButton1Click:Connect(xuLyKichHoatAFK)
print("[AFK Mobile] Đã tối ưu tổng lực! Đồ họa ẩn hạ hết cỡ và FPS đã khóa chặt ở mức 5.")
