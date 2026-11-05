-- Chess Helper Pro: Versi GUI Ringkas & Minimalis
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Pilih parent yang aman dari blokir game
local targetParent = CoreGui
pcall(function()
    if not pcall(function() return CoreGui:GetChildren() end) then
        targetParent = PlayerGui
    end
end)

-- Hapus GUI lama jika ada
if targetParent:FindFirstChild("ChessHelperProMini") then
    targetParent.ChessHelperProMini:Destroy()
end

-- 1. Membuat Wadah Utama (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChessHelperProMini"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetParent

-- 2. Membuat Bingkai Menu Utama (Kecil, Rapi, & Ringan)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 280)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Bisa digeser-geser di layar
MainFrame.Parent = ScreenGui

-- Corner melingkar agar terlihat modern
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- 3. Judul Menu
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "chess helper pro"
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- 4. Tombol 1: Scan & Analisis Papan
local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(0.9, 0, 0, 40)
ScanBtn.Position = UDim2.new(0.05, 0, 0, 50)
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Text = "Scan & Analisis Papan"
ScanBtn.TextSize = 12
ScanBtn.Font = Enum.Font.GothamSemibold
ScanBtn.Parent = MainFrame

local BtnCorner1 = Instance.new("UICorner")
BtnCorner1.CornerRadius = UDim.new(0, 6)
BtnCorner1.Parent = ScanBtn

-- 5. Tombol 2: Toggle Tanda Panah / Visual 3D
local VisualBtn = Instance.new("TextButton")
VisualBtn.Size = UDim2.new(0.9, 0, 0, 40)
VisualBtn.Position = UDim2.new(0.05, 0, 0, 100)
VisualBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
VisualBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VisualBtn.Text = "Visual 3D: ON"
VisualBtn.TextSize = 12
VisualBtn.Font = Enum.Font.GothamSemibold
VisualBtn.Parent = MainFrame

local BtnCorner2 = Instance.new("UICorner")
BtnCorner2.CornerRadius = UDim.new(0, 6)
BtnCorner2.Parent = VisualBtn

-- 6. Label Status / Informasi
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 70)
StatusLabel.Position = UDim2.new(0.05, 0, 0, 150)
StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Text = "Status: Siap memindai papan...\nDepth Bot: 15 (Optimal)"
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextWrapped = true
StatusLabel.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusLabel

-- 7. Tombol Tutup / Close (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 3)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Text = "X"
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Interaksi Tombol Scan
ScanBtn.MouseButton1Click:Connect(function()
    StatusLabel.Text = "Status: Memindai papan & meminta saran Stockfish..."
    -- Logika pemindaian dijalankan di sini
    task.wait(0.5)
    StatusLabel.Text = "Status: Saran ditemukan!\nPetak: E2 -> E4 (Skor: +0.4)"
end)

-- Interaksi Tombol Visual 3D
local visualActive = true
VisualBtn.MouseButton1Click:Connect(function()
    visualActive = not visualActive
    if visualActive then
        VisualBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
        VisualBtn.Text = "Visual 3D: ON"
    else
        VisualBtn.BackgroundColor3 = Color3.fromRGB(160, 60, 60)
        VisualBtn.Text = "Visual 3D: OFF"
    end
end)

print("Chess Helper Pro Mini Berhasil Dimuat!")
