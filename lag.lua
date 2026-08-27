-- ========================================================
-- SCRIPT ROBLOX MOBILE: KHÓA 5 FPS + BẦU TRỜI ĐEN + XÓA CHI TIẾT
-- Thiết kế tối ưu tổng lực không leak RAM cho Pet Simulator 99
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

-- ========================================================
-- 1. BIẾN BẦU TRỜI THÀNH MÀU ĐEN TUYỀN (BLACK SKYBOX)
-- ========================================================
Lighting.GlobalShadows = false
Lighting.FogEnd = 999999
Lighting.ClockTime = 0 -- Ép thời gian về nửa đêm
Lighting.Brightness = 0 -- Tắt hoàn toàn độ sáng môi trường
Lighting.Ambient = Color3.fromRGB(0, 0, 0) -- Biến ánh sáng xung quanh thành màu đen
Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)

-- Xóa sạch các đám mây, hiệu ứng ánh sáng và Skybox cũ để giải phóng RAM chứa ảnh trời
for _, obj in ipairs(Lighting:GetChildren()) do
    if obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("Sky") or obj:IsA("Clouds") then
        obj:Destroy()
    end
end

-- Tạo một Skybox đen trơn hoàn toàn mới
local blackSky = Instance.new("Sky")
blackSky.SkyboxBk = "rbxassetid://0"
blackSky.SkyboxDn = "rbxassetid://0"
blackSky.SkyboxFt = "rbxassetid://0"
blackSky.SkyboxLf = "rbxassetid://0"
blackSky.SkyboxRt = "rbxassetid://0"
blackSky.SkyboxUp = "rbxassetid://0"
blackSky.CelestialBodiesShown = false -- Tắt hiển thị mặt trời, mặt trăng, ngôi sao
blackSky.Parent = Lighting

-- ========================================================
-- 2. KHÓA CHẶT 5 FPS CỐ ĐỊNH (CỨU CPU ĐÁM MÂY)
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
-- 3. HÀM XÓA SẠCH CHI TIẾT CỦA CÁC KHỐI GẠCH (CHẠY 1 LẦN)
-- ========================================================
local function xoaDoHoaVaChiTiet()
    local allObjects = Workspace:GetDescendants()
    for i = 1, #allObjects do
        local v = allObjects[i]
        
        -- Biến tất cả các khối thành nhựa trơn phẳng lì (SmoothPlastic) không đổ bóng
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.CastShadow = false
        end
        
        -- Ép các vật thể Mesh phức tạp về dạng hộp rỗng đơn giản nhất để cứu RAM tính toán
        if v:IsA("MeshPart") then
            v.CollisionFidelity = Enum.CollisionFidelity.Box
            v.RenderFidelity = Enum.RenderFidelity.Performance
        end
        
        -- Xóa sạch các ảnh dán, hình vẽ chi tiết đè lên khối gạch
        if v:IsA("Decal") or v:IsA("Texture") then
            v.Texture = "" 
        end
        
        -- Tắt hiệu ứng hạt làm nghẽn bộ đệm
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
    
    -- Giải phóng bộ nhớ đệm ngay lập tức
    gcinfo()
    collectgarbage("collect")
end

-- Kích hoạt xóa chi tiết map ngay khi vừa nạp script
xoaDoHoaVaChiTiet()

-- ========================================================
-- 4. TẠO GIAO DIỆN NÚT BẤM VÀ MÀN HÌNH TRẮNG
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

-- Cập nhật bảng đo thông số RAM/FPS thực tế mỗi giây
task.spawn(function()
    while mainGui and afkButton do
        local thongSoRam = Stats:GetTotalMemoryUsageMb()
        local thongSoFps = math.round(1 / RunService.Heartbeat:Wait())
        
        if trangThaiAFK then
            afkButton.Text = "⚡ AFK: ON (MÀN TRẮNG)\nRAM: " .. math.round(thongSoRam) .. " MB | FPS: " .. thongSoFps
        else
            afkButton.Text = "❌ AFK: OFF (BẦU TRỜI ĐEN)\nRAM: " .. math.round(thongSoRam) .. " MB | FPS: " .. thongSoFps
        end
        task.wait(1)
    end
end)

-- ========================================================
-- 5. LOGIC KHI BẤM NÚT BẬT / TẮT MÀN TRẮNG
-- ========================================================
local function xuLyKichHoatAFK()
    trangThaiAFK = not trangThaiAFK
    
    if trangThaiAFK then
        -- --- BẬT MÀN HÌNH TRẮNG ---
        RunService:Set3dRenderingEnabled(false) -- Ép GPU ngừng hoạt động
        
        gcinfo()
        collectgarbage("collect")
        
        whiteFrame.Visible = true
        afkButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        -- --- TẮT MÀN HÌNH TRẮNG ---
        RunService:Set3dRenderingEnabled(true) -- Hiện lại thế giới Potato bầu trời đen
        
        whiteFrame.Visible = false
        afkButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end

afkButton.MouseButton1Click:Connect(xuLyKichHoatAFK)
print("[AFK Mobile] Đã chuyển đổi bầu trời đen và gỡ chi tiết khối gạch thành công!")
