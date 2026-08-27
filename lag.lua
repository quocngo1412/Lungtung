-- ========================================================
-- SCRIPT ROBLOX MOBILE: KHÓA FPS + MÀN TRẮNG + THEO DÕI RAM
-- Tối ưu hóa 100% cho Pet Simulator 99 trên Cloud Phone
-- Cách dùng: Bấm nút trên cùng màn hình để BẬT / TẮT AFK
-- ========================================================

local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")

local trangThaiAFK = false
local mainGui = nil
local whiteFrame = nil
local afkButton = nil
local loopDonRac = nil

-- 1. Xóa giao diện cũ tránh lỗi trùng lặp khi chạy lại script
if CoreGui:FindFirstChild("MobileAFKRamGui") then
    CoreGui.MobileAFKRamGui:Destroy()
end

-- 2. Tạo Giao diện UI thông minh
mainGui = Instance.new("ScreenGui")
mainGui.Name = "MobileAFKRamGui"
mainGui.DisplayOrder = 9999999 -- Độ ưu tiên cao nhất để đè lên mọi thứ
mainGui.IgnoreGuiInset = true
mainGui.Parent = CoreGui

-- Khung nền trắng xóa hoàn toàn khi bật AFK
whiteFrame = Instance.new("Frame")
whiteFrame.Size = UDim2.new(1, 0, 1, 0)
whiteFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
whiteFrame.BorderSizePixel = 0
whiteFrame.Visible = false
whiteFrame.ZIndex = 1
whiteFrame.Parent = mainGui

-- Nút bấm đa năng hiển thị trạng thái, RAM và FPS
afkButton = Instance.new("TextButton")
afkButton.Size = UDim2.new(0, 180, 0, 45) 
afkButton.Position = UDim2.new(0.5, -90, 0, 12) -- Nằm chính giữa mép trên màn hình
afkButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Màu đỏ mặc định (Đang tắt)
afkButton.Text = "AFK: OFF\nĐang tính RAM & FPS..."
afkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
afkButton.Font = Enum.Font.SourceSansBold
afkButton.TextSize = 13
afkButton.ZIndex = 2 -- Luôn nằm ĐÈ trên màn hình trắng để bấm được
afkButton.Parent = mainGui

-- Bo góc nút bấm cho đẹp mắt
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = afkButton

-- 3. Vòng lặp cập nhật thông số RAM & FPS thực tế lên nút bấm (1 giây/lần)
task.spawn(function()
    while mainGui and afkButton do
        -- Lấy dung lượng RAM hệ thống Roblox đang nạp (MB)
        local thongSoRam = Stats:GetTotalMemoryUsageMb()
        -- Tính toán FPS thực tế của game
        local thongSoFps = math.round(1 / RunService.Heartbeat:Wait())
        
        local chuoiThongTin = string.format("RAM: %d MB | FPS: %d", math.round(thongSoRam), thongSoFps)
        
        -- Cập nhật chữ hiển thị dựa theo trạng thái
        if trangThaiAFK then
            afkButton.Text = "⚡ AFK: ON (MÀN TRẮNG)\n" .. chuoiThongTin
        else
            afkButton.Text = "❌ AFK: OFF (BÌNH THƯỜNG)\n" .. chuoiThongTin
        end
        task.wait(1)
    end
end)

-- 4. Hàm bổ trợ gỡ Texture của bản đồ để ép RAM xuống thêm khi treo máy
local function quetVaGiamRamMap(v)
    if v:IsA("BasePart") then
        v.Material = Enum.Material.SmoothPlastic
        v.CastShadow = false
    end
    if v:IsA("Decal") or v:IsA("Texture") then
        v.Texture = "" -- Giải phóng RAM lưu trữ hình ảnh
    end
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Sparkles") then
        v.Enabled = false -- Tắt hiệu ứng rơi tiền/kim cương trong Pet 99
    end
end

-- 5. Hàm xử lý logic khi bấm nút Bật/Tắt AFK
local function xuLyKichHoatAFK()
    trangThaiAFK = not trangThaiAFK
    
    if trangThaiAFK then
        -- ======= [ BẬT CHẾ ĐỘ AFK MÀN TRẮNG ] =======
        if setfpscap then setfpscap(5) end -- Ép game về 5 FPS để Cloud Phone siêu nhẹ
        RunService:Set3dRenderingEnabled(false) -- Tắt render 3D hoàn toàn (GPU nghỉ 100%)
        
        -- Tiến hành quét map gỡ ảnh để ép RAM giảm xuống sâu nhất
        for _, obj in ipairs(Workspace:GetDescendants()) do
            quetVaGiamRamMap(obj)
        end
        
        -- Khởi động vòng lặp dọn rác bộ đệm RAM liên tục mỗi 3 giây
        gcinfo()
        collectgarbage("collect")
        loopDonRac = task.spawn(function()
            while trangThaiAFK do
                gcinfo()
                collectgarbage("collect")
                task.wait(3)
            end
        end)
        
        whiteFrame.Visible = true -- Hiện màn hình trắng xóa
        afkButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50) -- Đổi nút sang màu xanh lá
        print("[AFK] Đã bật màn hình trắng và khóa 5 FPS.")
    else
        -- ======= [ TẮT CHẾ ĐỘ AFK - QUAY LẠI CHƠI BÌNH THƯỜNG ] =======
        if setfpscap then setfpscap(60) end -- Trả lại 60 FPS mượt mà
        RunService:Set3dRenderingEnabled(true) -- Bật lại đồ họa 3D để nhìn thấy game
        
        -- Tắt vòng lặp dọn rác ngầm
        if loopDonRac then
            task.cancel(loopDonRac)
            loopDonRac = nil
        end
        
        whiteFrame.Visible = false -- Ẩn màn hình trắng
        afkButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Trả nút về màu đỏ
        print("[AFK] Đã tắt màn hình trắng. Game quay lại bình thường.")
    end
end

-- Kết nối sự kiện nhấp chuột/chạm tay vào nút bấm
afkButton.MouseButton1Click:Connect(xuLyKichHoatAFK)

print("[AFK Mobile] Kích hoạt thành công! Hãy nhấn nút phía trên màn hình để bật màn trắng.")
