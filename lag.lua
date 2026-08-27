-- ========================================================
-- SCRIPT ROBLOX: MÀN HÌNH TRẮNG + ĐO RAM & FPS CHO MOBILE
-- Vị trí: Chạy bằng Executor (Delta, Arceus X, Vega X,...)
-- Nút bấm tự động cập nhật số RAM và FPS thực tế sau mỗi 1 giây
-- ========================================================

local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local trangThaiAFK = false
local mainGui = nil
local whiteFrame = nil
local afkButton = nil

-- 1. Xóa giao diện cũ tránh trùng lặp
if CoreGui:FindFirstChild("MobileAFKGui") then
    CoreGui.MobileAFKGui:Destroy()
end

-- 2. Tạo Giao diện
mainGui = Instance.new("ScreenGui")
mainGui.Name = "MobileAFKGui"
mainGui.DisplayOrder = 9999999
mainGui.IgnoreGuiInset = true
mainGui.Parent = CoreGui

-- 3. Tạo khung nền trắng
whiteFrame = Instance.new("Frame")
whiteFrame.Size = UDim2.new(1, 0, 1, 0)
whiteFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
whiteFrame.BorderSizePixel = 0
whiteFrame.Visible = false
whiteFrame.ZIndex = 1
whiteFrame.Parent = mainGui

-- 4. Tạo nút bấm thông minh hiển thị RAM/FPS (Kích thước to hơn một chút để chứa chữ)
afkButton = Instance.new("TextButton")
afkButton.Size = UDim2.new(0, 160, 0, 45) 
afkButton.Position = UDim2.new(0.5, -80, 0, 10) -- Nằm giữa cạnh trên màn hình
afkButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Màu đỏ ban đầu
afkButton.Text = "AFK: OFF\nTính RAM..."
afkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
afkButton.Font = Enum.Font.SourceSansBold
afkButton.TextSize = 13
afkButton.ZIndex = 2
afkButton.Parent = mainGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = afkButton

-- 5. Hàm cập nhật RAM và FPS liên tục sau mỗi 1 giây
task.spawn(function()
    while task.wait(1) do
        if mainGui and afkButton then
            -- Lấy chỉ số RAM thực tế mà game đang ngốn (đơn vị MB)
            local thongSoRam = Stats:GetTotalMemoryUsageMb()
            -- Tính toán FPS hiện tại
            local thongSoFps = math.round(1 / RunService.Heartbeat:Wait())
            
            -- Định dạng hiển thị số làm tròn cho đẹp
            local chuoiRamFps = string.format("RAM: %d MB | FPS: %d", math.round(thongSoRam), thongSoFps)
            
            -- Cập nhật chữ lên nút bấm tùy theo trạng thái bật tắt
            if trangThaiAFK then
                afkButton.Text = "AFK: ON\n" .. chuoiRamFps
            else
                afkButton.Text = "AFK: OFF\n" .. chuoiRamFps
            end
        else
            break
        end
    end
end)

-- 6. Hàm xử lý khi chạm vào nút bấm
local function kichHoatAFK()
    trangThaiAFK = not trangThaiAFK
    
    if trangThaiAFK then
        if setfpscap then setfpscap(5) end -- Khóa 5 FPS
        RunService:Set3dRenderingEnabled(false) -- Tắt đồ họa 3D
        
        whiteFrame.Visible = true
        afkButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50) -- Đổi sang màu xanh
    else
        if setfpscap then setfpscap(60) end -- Mở khóa 60 FPS
        RunService:Set3dRenderingEnabled(true) -- Bật lại đồ họa 3D
        
        whiteFrame.Visible = false
        afkButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Đổi về màu đỏ
    end
end

afkButton.MouseButton1Click:Connect(kichHoatAFK)
print("[AFK Mobile] Đã kích hoạt hệ thống đo RAM và FPS tự động!")
