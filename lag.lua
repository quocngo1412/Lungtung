-- ========================================================
-- SCRIPT ROBLOX: SIÊU ÉP GIẢM RAM + MÀN TRẮNG + KHÓA FPS THẤP
-- Vị trí: Chạy bằng Executor (Delta, Arceus X, Vega X,...)
-- Hỗ trợ treo máy AFK mát máy, chống tràn RAM văng game tuyệt đối
-- ========================================================

local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")

local trangThaiAFK = false
local mainGui = nil
local whiteFrame = nil
local afkButton = nil
local dọnRácVòngLặp = nil

-- 1. Xóa giao diện cũ nếu có để tránh lỗi trùng lặp
if CoreGui:FindFirstChild("SieuToiUuRamGui") then
    CoreGui.SieuToiUuRamGui:Destroy()
end

-- 2. Tạo giao diện UI mới
mainGui = Instance.new("ScreenGui")
mainGui.Name = "SieuToiUuRamGui"
mainGui.DisplayOrder = 9999999
mainGui.IgnoreGuiInset = true
mainGui.Parent = CoreGui

-- Màn hình trắng xóa phủ kín (Mặc định ẩn)
whiteFrame = Instance.new("Frame")
whiteFrame.Size = UDim2.new(1, 0, 1, 0)
whiteFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
whiteFrame.BorderSizePixel = 0
whiteFrame.Visible = false
whiteFrame.ZIndex = 1
whiteFrame.Parent = mainGui

-- Nút bấm thông minh cập nhật RAM & FPS thực tế
afkButton = Instance.new("TextButton")
afkButton.Size = UDim2.new(0, 170, 0, 45) 
afkButton.Position = UDim2.new(0.5, -85, 0, 10) -- Nằm chính giữa trên cùng màn hình
afkButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Màu đỏ (Đang tắt)
afkButton.Text = "AFK: OFF\nĐang tính thông số..."
afkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
afkButton.Font = Enum.Font.SourceSansBold
afkButton.TextSize = 13
afkButton.ZIndex = 2 -- Luôn nằm đè lên màn hình trắng
afkButton.Parent = mainGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = afkButton

-- 3. Vòng lặp cập nhật thông số RAM và FPS lên nút bấm sau mỗi 1 giây
task.spawn(function()
    while mainGui and afkButton do
        local dungLuongRam = Stats:GetTotalMemoryUsageMb()
        local soFPS = math.round(1 / RunService.Heartbeat:Wait())
        local chuoiThongTin = string.format("RAM: %d MB | FPS: %d", math.round(dungLuongRam), soFPS)
        
        if trangThaiAFK then
            afkButton.Text = "AFK: ON (SỬ ĐỒNG)\n" .. chuoiThongTin
        else
            afkButton.Text = "AFK: OFF (BÌNH THƯỜNG)\n" .. chuoiThongTin
        end
        task.wait(1)
    end
end)

-- 4. Hàm quét bản đồ để gỡ sạch hình ảnh tốn RAM
local function quetVaGiamRamVatThe(v)
    -- Ép mọi khối gạch về nhựa trơn phẳng không đổ bóng
    if v:IsA("BasePart") then
        v.Material = Enum.Material.SmoothPlastic
        v.CastShadow = false
    end
    -- Gỡ bỏ hoàn toàn dữ liệu hình ảnh (Texture/Decal) đè lên khối gạch để giải phóng RAM chứa ảnh
    if v:IsA("Decal") or v:IsA("Texture") then
        v.Texture = ""
    end
    -- Tắt các hiệu ứng hạt tốn bộ nhớ đệm
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Sparkles") then
        v.Enabled = false
    end
end

-- 5. Hàm xử lý khi bấm nút chuyển đổi Bật/Tắt AFK
local function kichHoatAFK()
    trangThaiAFK = not trangThaiAFK
    
    if trangThaiAFK then
        -- ====== [ BẬT CHẾ ĐỘ TIẾT KIỆM RAM TỐI ĐA ] ======
        if setfpscap then setfpscap(5) end -- Khóa chặt ở 5 FPS để CPU mát nhất
        RunService:Set3dRenderingEnabled(false) -- Tắt render hình ảnh 3D để giải phóng GPU
        
        -- Tiến hành gỡ sạch hình ảnh trên toàn bộ map để ép RAM giảm xuống sâu nhất
        for _, obj in ipairs(Workspace:GetDescendants()) do
            quetVaGiamRamVatThe(obj)
        end
        
        -- Ép hệ thống Lua chạy dọn rác RAM ngay lập tức
        gcinfo()
        collectgarbage("collect")
        
        -- Kích hoạt vòng lặp dọn rác RAM liên tục mỗi 3 giây
        dọnRácVòngLặp = task.spawn(function()
            while trangThaiAFK do
                gcinfo()
                collectgarbage("collect")
                task.wait(3)
            end
        end)
        
        whiteFrame.Visible = true -- Bật màn hình trắng xóa
        afkButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50) -- Đổi nút sang màu xanh lá
        print("[AFK] Đã BẬT siêu tối ưu RAM và màn hình trắng.")
    else
        -- ====== [ TẮT CHẾ ĐỘ AFK - QUAY LẠI BÌNH THƯỜNG ] ======
        if setfpscap then setfpscap(60) end -- Trả lại 60 FPS để chơi mượt
        RunService:Set3dRenderingEnabled(true) -- Bật lại đồ họa 3D để nhìn thấy game
        
        -- Hủy vòng lặp dọn rác RAM liên tục
        if dọnRácVòngLặp then
            task.cancel(dọnRácVòngLặp)
            dọnRácVòngLặp = nil
        end
        
        whiteFrame.Visible = false -- Ẩn màn hình trắng
        afkButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Đổi nút về màu đỏ
        print("[AFK] Đã TẮT màn hình trắng. Game quay lại hoạt động bình thường.")
    end
end

-- Kết nối sự kiện nhấn vào nút bấm
afkButton.MouseButton1Click:Connect(kichHoatAFK)
print("[AFK Mobile] Script tối ưu RAM đỉnh cao đã sẵn sàng! Nhấn nút trên màn hình để bật.")
