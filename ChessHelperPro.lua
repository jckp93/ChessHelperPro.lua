-- ============================================================================
-- CHESS HELPER PRO - FULL MASTER SCRIPT WITH PERSPECTIVE TOGGLE (ROBLOX CLIENT)
-- ============================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Manajemen Memori & Koneksi
local activeConnections = {}
local activeHighlightParts = {}
local visualExpireTask = nil

local function trackConnection(connection)
    table.insert(activeConnections, connection)
    return connection
end

-- ============================================================================
-- 1. SISTEM GUI UTAMA & TEMA (UI & THEME MANAGER)
-- ============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChessHelperProGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Jendela Utama
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 600)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = MainFrame

local UIStrokeMain = Instance.new("UIStroke")
UIStrokeMain.Thickness = 2
UIStrokeMain.Color = Color3.fromRGB(0, 162, 255)
UIStrokeMain.Transparency = 0.2
UIStrokeMain.Parent = MainFrame

-- Judul (Title Bar)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "Chess Helper Pro"
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local UICornerTitle = Instance.new("UICorner")
UICornerTitle.CornerRadius = UDim.new(0, 8)
UICornerTitle.Parent = Title

-- Tombol Buka Kembali (Open Button)
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 110, 0, 35)
OpenButton.Position = UDim2.new(0.05, 0, 0.05, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Text = "Buka Chess Pro"
OpenButton.TextSize = 11
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local UICornerOpen = Instance.new("UICorner")
UICornerOpen.CornerRadius = UDim.new(0, 6)
UICornerOpen.Parent = OpenButton

-- Tombol Minimalkan
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0, 3)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeButton.Text = "-"
MinimizeButton.TextSize = 16
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = Title

-- Tema Warna
local Themes = {
    Dark = { BgColor = Color3.fromRGB(25, 25, 25), HeaderColor = Color3.fromRGB(40, 40, 40), TextColor = Color3.fromRGB(255, 255, 255), AccentColor = Color3.fromRGB(0, 162, 255), SecondaryBg = Color3.fromRGB(35, 35, 35) },
    NeonGreen = { BgColor = Color3.fromRGB(15, 25, 15), HeaderColor = Color3.fromRGB(25, 45, 25), TextColor = Color3.fromRGB(0, 255, 120), AccentColor = Color3.fromRGB(0, 200, 80), SecondaryBg = Color3.fromRGB(20, 35, 20) },
    CyberBlue = { BgColor = Color3.fromRGB(15, 20, 35), HeaderColor = Color3.fromRGB(25, 35, 55), TextColor = Color3.fromRGB(0, 220, 255), AccentColor = Color3.fromRGB(0, 140, 255), SecondaryBg = Color3.fromRGB(20, 28, 45) }
}
local currentThemeName = "Dark"
local isSoundMuted = false
local currentDepth = 10
local isWhitePerspective = true

-- Status & Evaluasi Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 24)
StatusLabel.Position = UDim2.new(0.05, 0, 0.07, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Text = "Status: Siap Memindai"
StatusLabel.TextSize = 10
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

local EvalLabel = Instance.new("TextLabel")
EvalLabel.Size = UDim2.new(0.9, 0, 0, 24)
EvalLabel.Position = UDim2.new(0.05, 0, 0.115, 0)
EvalLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
EvalLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
EvalLabel.Text = "Evaluasi: 0.0"
EvalLabel.TextSize = 10
EvalLabel.Font = Enum.Font.GothamBold
EvalLabel.Parent = MainFrame

-- Indikator Giliran (Turn Indicator)
local TurnIndicatorLabel = Instance.new("TextLabel")
TurnIndicatorLabel.Size = UDim2.new(0.9, 0, 0, 24)
TurnIndicatorLabel.Position = UDim2.new(0.05, 0, 0.16, 0)
TurnIndicatorLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TurnIndicatorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TurnIndicatorLabel.Text = "Giliran: Putih (White)"
TurnIndicatorLabel.TextSize = 10
TurnIndicatorLabel.Font = Enum.Font.GothamBold
TurnIndicatorLabel.Parent = MainFrame

-- Scrolling Frame Riwayat Langkah
local HistoryContainer = Instance.new("ScrollingFrame")
HistoryContainer.Size = UDim2.new(0.9, 0, 0, 75)
HistoryContainer.Position = UDim2.new(0.05, 0, 0.205, 0)
HistoryContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
HistoryContainer.BorderColor3 = Color3.fromRGB(60, 60, 60)
HistoryContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
HistoryContainer.ScrollBarThickness = 4
HistoryContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.Parent = HistoryContainer

local HistoryTextLabel = Instance.new("TextLabel")
HistoryTextLabel.Size = UDim2.new(1, -10, 0, 0)
HistoryTextLabel.Position = UDim2.new(0, 5, 0, 0)
HistoryTextLabel.BackgroundTransparency = 1
HistoryTextLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
HistoryTextLabel.TextSize = 10
HistoryTextLabel.Font = Enum.Font.Code
HistoryTextLabel.TextXAlignment = Enum.TextXAlignment.Left
HistoryTextLabel.TextYAlignment = Enum.TextYAlignment.Top
HistoryTextLabel.TextWrapped = true
HistoryTextLabel.Text = "1. (Belum ada langkah tercatat)"
HistoryTextLabel.Parent = HistoryContainer

-- Tombol-Tombol Kontrol Utama
local AnalyzeButton = Instance.new("TextButton")
AnalyzeButton.Size = UDim2.new(0.9, 0, 0, 28)
AnalyzeButton.Position = UDim2.new(0.05, 0, 0.355, 0)
AnalyzeButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
AnalyzeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AnalyzeButton.Text = "Analisis Papan (Key: F)"
AnalyzeButton.TextSize = 10
AnalyzeButton.Font = Enum.Font.GothamBold
AnalyzeButton.Parent = MainFrame

local CopyFenButton = Instance.new("TextButton")
CopyFenButton.Size = UDim2.new(0.9, 0, 0, 26)
CopyFenButton.Position = UDim2.new(0.05, 0, 0.41, 0)
CopyFenButton.BackgroundColor3 = Color3.fromRGB(100, 50, 180)
CopyFenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyFenButton.Text = "Salin FEN ke Clipboard"
CopyFenButton.TextSize = 10
CopyFenButton.Font = Enum.Font.Gotham
CopyFenButton.Parent = MainFrame

local ExportPgnButton = Instance.new("TextButton")
ExportPgnButton.Size = UDim2.new(0.9, 0, 0, 26)
ExportPgnButton.Position = UDim2.new(0.05, 0, 0.46, 0)
ExportPgnButton.BackgroundColor3 = Color3.fromRGB(50, 120, 180)
ExportPgnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExportPgnButton.Text = "Ekspor Game ke PGN"
ExportPgnButton.TextSize = 10
ExportPgnButton.Font = Enum.Font.Gotham
ExportPgnButton.Parent = MainFrame

local PerspectiveButton = Instance.new("TextButton")
PerspectiveButton.Size = UDim2.new(0.9, 0, 0, 26)
PerspectiveButton.Position = UDim2.new(0.05, 0, 0.51, 0)
PerspectiveButton.BackgroundColor3 = Color3.fromRGB(80, 50, 120)
PerspectiveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PerspectiveButton.Text = "Perspektif: Putih (White)"
PerspectiveButton.TextSize = 10
PerspectiveButton.Font = Enum.Font.GothamBold
PerspectiveButton.Parent = MainFrame

local ThemeButton = Instance.new("TextButton")
ThemeButton.Size = UDim2.new(0.9, 0, 0, 26)
ThemeButton.Position = UDim2.new(0.05, 0, 0.56, 0)
ThemeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ThemeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ThemeButton.Text = "Tema: Gelap (Dark)"
ThemeButton.TextSize = 10
ThemeButton.Font = Enum.Font.Gotham
ThemeButton.Parent = MainFrame

local SoundToggleButton = Instance.new("TextButton")
SoundToggleButton.Size = UDim2.new(0.9, 0, 0, 26)
SoundToggleButton.Position = UDim2.new(0.05, 0, 0.61, 0)
SoundToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 100)
SoundToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SoundToggleButton.Text = "Suara: ON (Unmuted)"
SoundToggleButton.TextSize = 10
SoundToggleButton.Font = Enum.Font.Gotham
SoundToggleButton.Parent = MainFrame

local DepthButton = Instance.new("TextButton")
DepthButton.Size = UDim2.new(0.9, 0, 0, 26)
DepthButton.Position = UDim2.new(0.05, 0, 0.66, 0)
DepthButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
DepthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DepthButton.Text = "Stockfish Depth: 10 (Cepat)"
DepthButton.TextSize = 10
DepthButton.Font = Enum.Font.GothamBold
DepthButton.Parent = MainFrame

local ResetButton = Instance.new("TextButton")
ResetButton.Size = UDim2.new(0.9, 0, 0, 26)
ResetButton.Position = UDim2.new(0.05, 0, 0.71, 0)
ResetButton.BackgroundColor3 = Color3.fromRGB(180, 100, 20)
ResetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetButton.Text = "Reset Game / Hapus Riwayat"
ResetButton.TextSize = 10
ResetButton.Font = Enum.Font.GothamBold
ResetButton.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0.9, 0, 0, 28)
CloseButton.Position = UDim2.new(0.05, 0, 0.89, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "Tutup Skrip Total (Cleanup)"
CloseButton.TextSize = 10
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

-- Terapkan Sudut Melengkung pada Semua Tombol
for _, btn in ipairs(MainFrame:GetChildren()) do
    if btn:IsA("TextButton") then
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn
    end
end
local cTurn = Instance.new("UICorner") cTurn.CornerRadius = UDim.new(0, 6) cTurn.Parent = TurnIndicatorLabel

-- ============================================================================
-- 2. MODUL TEMA & AUTO-SAVE
-- ============================================================================
local settingsFileName = "ChessHelperPro_Settings.json"

local function applyTheme(themeName)
    local theme = Themes[themeName]
    if not theme then return end
    currentThemeName = themeName
    
    MainFrame.BackgroundColor3 = theme.BgColor
    Title.BackgroundColor3 = theme.HeaderColor
    Title.TextColor3 = theme.TextColor
    UIStrokeMain.Color = theme.AccentColor
    StatusLabel.BackgroundColor3 = theme.SecondaryBg
    EvalLabel.BackgroundColor3 = theme.SecondaryBg
    TurnIndicatorLabel.BackgroundColor3 = theme.SecondaryBg
    HistoryContainer.BackgroundColor3 = theme.SecondaryBg
end

local function saveUserSettings()
    local success, encodedData = pcall(function()
        return HttpService:JSONEncode({ Theme = currentThemeName, Muted = isSoundMuted, Depth = currentDepth, WhitePerspective = isWhitePerspective })
    end)
    if success and writefile then
        pcall(function() writefile(settingsFileName, encodedData) end)
    end
end

local function loadUserSettings()
    if readfile and isfile and isfile(settingsFileName) then
        local success, decodedData = pcall(function()
            return HttpService:JSONDecode(readfile(settingsFileName))
        end)
        if success and decodedData then
            if decodedData.Theme and Themes[decodedData.Theme] then
                applyTheme(decodedData.Theme)
                ThemeButton.Text = "Tema: " .. decodedData.Theme
            end
            if type(decodedData.Muted) == "boolean" then
                isSoundMuted = decodedData.Muted
                SoundToggleButton.Text = isSoundMuted and "Suara: OFF (Muted)" or "Suara: ON (Unmuted)"
                SoundToggleButton.BackgroundColor3 = isSoundMuted and Color3.fromRGB(150, 50, 50) or Color3.fromRGB(0, 120, 100)
            end
            if type(decodedData.Depth) == "number" then
                currentDepth = decodedData.Depth
                DepthButton.Text = "Stockfish Depth: " .. tostring(currentDepth)
            end
            if type(decodedData.WhitePerspective) == "boolean" then
                isWhitePerspective = decodedData.WhitePerspective
                PerspectiveButton.Text = isWhitePerspective and "Perspektif: Putih (White)" or "Perspektif: Hitam (Black)"
                PerspectiveButton.BackgroundColor3 = isWhitePerspective and Color3.fromRGB(80, 50, 120) or Color3.fromRGB(120, 80, 50)
            end
        end
    end
end

-- ============================================================================
-- 3. MODUL PEMINDAI FEN DINAMIS & API STOCKFISH
-- ============================================================================
local function getAutomaticCornerA1()
    local a1Part = Workspace:FindFirstChild("A1", true)
    if a1Part then
        return a1Part.PrimaryPart and a1Part.PrimaryPart.Position or a1Part.Position
    end
    return Vector3.new(-14, 0, -14)
end

local function scanBoardDynamic()
    local boardGrid = {}
    for r = 1, 8 do
        boardGrid[r] = {}
        for c = 1, 8 do boardGrid[r][c] = "." end
    end

    local piecesFolder = Workspace:FindFirstChild("ChessPieces") or Workspace
    local cornerA1 = getAutomaticCornerA1()
    local squareSize = 4

    for _, piece in ipairs(piecesFolder:GetChildren()) do
        if piece:IsA("BasePart") or piece:IsA("Model") then
            local pos = piece.PrimaryPart and piece.PrimaryPart.Position or piece.Position
            local col = math.floor((pos.X - cornerA1.X) / squareSize) + 1
            local row = math.floor((pos.Z - cornerA1.Z) / squareSize) + 1
            
            if col >= 1 and col <= 8 and row >= 1 and row <= 8 then
                local finalCol = isWhitePerspective and col or (9 - col)
                local finalRow = isWhitePerspective and row or (9 - row)
                
                local name = piece.Name:lower()
                local isWhitePiece = name:find("white") or name:find("w")
                local char = "p"
                if name:find("rook") or name:find("r_") then char = "r"
                elseif name:find("knight") or name:find("n_") then char = "n"
                elseif name:find("bishop") or name:find("b_") then char = "b"
                elseif name:find("queen") or name:find("q_") then char = "q"
                elseif name:find("king") or name:find("k_") then char = "k"
                end
                if isWhitePiece then char = char:upper() end
                
                boardGrid[9 - finalRow][finalCol] = char
            end
        end
    end

    local fenRows = {}
    for r = 1, 8 do
        local rowStr, empty = "", 0
        for c = 1, 8 do
            local cell = boardGrid[r][c]
            if cell == "." then empty = empty + 1
            else
                if empty > 0 then rowStr = rowStr .. tostring(empty); empty = 0 end
                rowStr = rowStr .. cell
            end
        end
        if empty > 0 then rowStr = rowStr .. tostring(empty) end
        table.insert(fenRows, rowStr)
    end

    local turnChar = isWhitePerspective and "w" or "b"
    return table.concat(fenRows, "/") .. " " .. turnChar .. " KQkq - 0 1"
end

local function getBestMoveFromAPI(fen)
    local encodedFen = fen:gsub(" ", "%%20")
    local url = "https://stockfish.online/api/s/v2.php?fen=" .. encodedFen .. "&depth=" .. tostring(currentDepth)
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        local data = HttpService:JSONDecode(response)
        if data and data.success then
            local bestMoveFull = data.bestmove
            if bestMoveFull then
                local bestMove = bestMoveFull:match("bestmove%s+(%w+)") or bestMoveFull:sub(1, 4)
                return bestMove, data.evaluation or "0"
            end
        end
    end
    return nil, nil
end

-- ============================================================================
-- 4. MODUL VISUAL 3D (ARROW & HIGHLIGHT DENGAN AUTO-DELETE)
-- ============================================================================
local function clearVisualHints()
    if visualExpireTask then
        task.cancel(visualExpireTask)
        visualExpireTask = nil
    end
    for _, part in ipairs(activeHighlightParts) do
        if part and part.Parent then part:Destroy() end
    end
    activeHighlightParts = {}
end

local function getSquarePositionFromName(squareName, cornerA1, squareSize)
    if #squareName < 2 then return nil end
    local col = (squareName:sub(1, 1):lower():byte() - 96)
    local row = tonumber(squareName:sub(2, 2))
    if not col or not row or col < 1 or col > 8 or row < 1 or row > 8 then return nil end
    
    local posX = cornerA1.X + ((col - 0.5) * squareSize)
    local posZ = cornerA1.Z + ((8 - row + 0.5) * squareSize)
    local posY = cornerA1.Y + 0.1
    return Vector3.new(posX, posY, posZ)
end

local function showBestMoveVisual(moveAlgebraic, cornerA1, squareSize, autoClearSeconds)
    clearVisualHints()
    if not moveAlgebraic or #moveAlgebraic < 4 then return end
    
    local fromPos = getSquarePositionFromName(moveAlgebraic:sub(1, 2), cornerA1, squareSize)
    local toPos = getSquarePositionFromName(moveAlgebraic:sub(3, 4), cornerA1, squareSize)
    if not fromPos or not toPos then return end
    
    local fromPart = Instance.new("Part")
    fromPart.Size = Vector3.new(squareSize * 0.9, 0.15, squareSize * 0.9)
    fromPart.Position = fromPos
    fromPart.Anchored = true fromPart.CanCollide = false
    fromPart.Material = Enum.Material.Neon fromPart.BrickColor = BrickColor.new("Deep orange")
    fromPart.Parent = Workspace table.insert(activeHighlightParts, fromPart)
    
    local toPart = Instance.new("Part")
    toPart.Size = Vector3.new(squareSize * 0.9, 0.2, squareSize * 0.9)
    toPart.Position = toPos
    toPart.Anchored = true toPart.CanCollide = false
    toPart.Material = Enum.Material.Neon toPart.BrickColor = BrickColor.new("Lime green")
    toPart.Parent = Workspace table.insert(activeHighlightParts, toPart)
    
    local distance = (toPos - fromPos).Magnitude
    local arrowPart = Instance.new("Part")
    arrowPart.Size = Vector3.new(0.4, 0.2, distance)
    arrowPart.CFrame = CFrame.new(fromPos:Lerp(toPos, 0.5), toPos)
    arrowPart.Anchored = true arrowPart.CanCollide = false
    arrowPart.Material = Enum.Material.Neon arrowPart.BrickColor = BrickColor.new("Cyan")
    arrowPart.Parent = Workspace table.insert(activeHighlightParts, arrowPart)

    autoClearSeconds = autoClearSeconds or 6
    visualExpireTask = task.delay(autoClearSeconds, function()
        clearVisualHints()
    end)
end

-- ============================================================================
-- 5. MODUL AUDIO, PGN & TURN INDICATOR
-- ============================================================================
local gameMoveHistory = {}

local function playSuccessSound()
    if isSoundMuted then return end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://4590657391"
    sound.Volume = 0.8
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

local function updateHistoryDisplay(moveTable)
    if not moveTable or #moveTable == 0 then
        HistoryTextLabel.Text = "1. (Belum ada langkah tercatat)"
        return
    end
    local text = ""
    for i = 1, #moveTable, 2 do
        local turn = math.ceil(i / 2)
        local w = moveTable[i] or ""
        local b = moveTable[i+1] or ""
        text = text .. string.format("%d. %s  %s\n", turn, w, b)
    end
    HistoryTextLabel.Text = text
    task.spawn(function()
        task.wait(0.05)
        HistoryTextLabel.Size = UDim2.new(1, -10, 0, math.max(HistoryTextLabel.TextBounds.Y + 10, 30))
        HistoryContainer.CanvasSize = UDim2.new(0, 0, 0, HistoryTextLabel.Size.Y.Offset + 10)
        HistoryContainer.CanvasPosition = Vector2.new(0, HistoryContainer.CanvasSize.Y.Offset)
    end)
end

local function updateTurnIndicator(moveHistoryTable)
    if #moveHistoryTable % 2 == 0 then
        TurnIndicatorLabel.Text = "Giliran: Putih (White)"
        TurnIndicatorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        TurnIndicatorLabel.Text = "Giliran: Hitam (Black)"
        TurnIndicatorLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    end
end

local function generatePGNString()
    local dateStr = os.date("%Y.%m.%d")
    local pgn = '[Event "Roblox Chess Match"]\n[Site "Roblox Workspace"]\n[Date "'..dateStr..'"]\n[Result "*"]\n\n'
    for i = 1, #gameMoveHistory, 2 do
        local turn = math.ceil(i / 2)
        local w = gameMoveHistory[i] or ""
        local b = gameMoveHistory[i+1] or ""
        pgn = pgn .. string.format("%d. %s %s ", turn, w, b)
    end
    return pgn .. "*"
end

-- ============================================================================
-- 6. ANIMASI TWEEN, DRAGGING & FULL CLEANUP
-- ============================================================================
local function animateOpenWindow()
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Visible = true
    OpenButton.Visible = false
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 300, 0, 600)
    }):Play()
end

local function animateCloseWindow()
    local tw = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    tw:Play()
    tw.Completed:Connect(function()
        MainFrame.Visible = false
        OpenButton.Visible = true
    end)
end

local function makeDraggable(guiObject, dragTarget)
    local dragging, dragInput, mousePos, framePos
    trackConnection(dragTarget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true mousePos = input.Position framePos = guiObject.Position
        end
    end))
    trackConnection(UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - mousePos
            guiObject.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end))
    trackConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end
makeDraggable(MainFrame, Title)

local function fullCleanupAndDestroy()
    clearVisualHints()
    for _, conn in ipairs(activeConnections) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    activeConnections = {}
    if ScreenGui then ScreenGui:Destroy() end
    print("Chess Helper Pro berhasil dibersihkan total!")
end

-- ============================================================================
-- 7. EVENT & INTERAKSI TOMBOL
-- ============================================================================
trackConnection(AnalyzeButton.MouseButton1Click:Connect(function()
    StatusLabel.Text = "Status: Memindai & Menganalisis..."
    task.spawn(function()
        local fen = scanBoardDynamic()
        local bestMove, eval = getBestMoveFromAPI(fen)
        if bestMove then
            playSuccessSound()
            local cleanMove = string.lower(bestMove)
            StatusLabel.Text = "Saran: " .. string.upper(cleanMove)
            EvalLabel.Text = "Evaluasi: " .. tostring(eval)
            
            showBestMoveVisual(cleanMove, getAutomaticCornerA1(), 4, 6)
            
            table.insert(gameMoveHistory, cleanMove)
            updateHistoryDisplay(gameMoveHistory)
            updateTurnIndicator(gameMoveHistory)
        else
            StatusLabel.Text = "Status: Gagal Mendapatkan Langkah"
        end
    end)
end))

trackConnection(CopyFenButton.MouseButton1Click:Connect(function()
    local fen = scanBoardDynamic()
    pcall(function() setclipboard(fen) end)
    StatusLabel.Text = "Status: FEN disalin!"
end))

trackConnection(ExportPgnButton.MouseButton1Click:Connect(function()
    local pgn = generatePGNString()
    pcall(function() setclipboard(pgn) end)
    StatusLabel.Text = "Status: PGN disalin!"
end))

trackConnection(PerspectiveButton.MouseButton1Click:Connect(function()
    isWhitePerspective = not isWhitePerspective
    if isWhitePerspective then
        PerspectiveButton.Text = "Perspektif: Putih (White)"
        PerspectiveButton.BackgroundColor3 = Color3.fromRGB(80, 50, 120)
    else
        PerspectiveButton.Text = "Perspektif: Hitam (Black)"
        PerspectiveButton.BackgroundColor3 = Color3.fromRGB(120, 80, 50)
    end
    saveUserSettings()
    StatusLabel.Text = "Status: Perspektif diubah."
end))

trackConnection(ThemeButton.MouseButton1Click:Connect(function()
    if currentThemeName == "Dark" then
        applyTheme("NeonGreen") ThemeButton.Text = "Tema: Hijau Neon"
    elseif currentThemeName == "NeonGreen" then
        applyTheme("CyberBlue") ThemeButton.Text = "Tema: Biru Cyber"
    else
        applyTheme("Dark") ThemeButton.Text = "Tema: Gelap (Dark)"
    end
    saveUserSettings()
end))

trackConnection(SoundToggleButton.MouseButton1Click:Connect(function()
    isSoundMuted = not isSoundMuted
    SoundToggleButton.Text = isSoundMuted and "Suara: OFF (Muted)" or "Suara: ON (Unmuted)"
    SoundToggleButton.BackgroundColor3 = isSoundMuted and Color3.fromRGB(150, 50, 50) or Color3.fromRGB(0, 120, 100)
    saveUserSettings()
end))

trackConnection(DepthButton.MouseButton1Click:Connect(function()
    if currentDepth == 10 then
        currentDepth = 15 DepthButton.Text = "Stockfish Depth: 15 (Standar)"
    elseif currentDepth == 15 then
        currentDepth = 20 DepthButton.Text = "Stockfish Depth: 20 (Akurat)"
    else
        currentDepth = 10 DepthButton.Text = "Stockfish Depth: 10 (Cepat)"
    end
    saveUserSettings()
end))

-- Logika Reset Game dengan Two-Step Confirmation
local isConfirmingReset = false
local resetTimeoutTask = nil

local function resetChessGame()
    gameMoveHistory = {}
    clearVisualHints()
    updateHistoryDisplay(gameMoveHistory)
    updateTurnIndicator(gameMoveHistory)
    StatusLabel.Text = "Status: Game direset."
    EvalLabel.Text = "Evaluasi: 0.0"
end

trackConnection(ResetButton.MouseButton1Click:Connect(function()
    if not isConfirmingReset then
        isConfirmingReset = true
        ResetButton.Text = "Yakin Reset? Klik Sekali Lagi"
        ResetButton.BackgroundColor3 = Color3.fromRGB(220, 80, 20)
        if resetTimeoutTask then task.cancel(resetTimeoutTask) end
        resetTimeoutTask = task.delay(3, function()
            if isConfirmingReset then
                isConfirmingReset = false
                ResetButton.Text = "Reset Game / Hapus Riwayat"
                ResetButton.BackgroundColor3 = Color3.fromRGB(180, 100, 20)
            end
        end)
    else
        isConfirmingReset = false
        if resetTimeoutTask then task.cancel(resetTimeoutTask) end
        ResetButton.Text = "Reset Game / Hapus Riwayat"
        ResetButton.BackgroundColor3 = Color3.fromRGB(180, 100, 20)
        resetChessGame()
    end
end))

trackConnection(MinimizeButton.MouseButton1Click:Connect(animateCloseWindow))
trackConnection(OpenButton.MouseButton1Click:Connect(animateOpenWindow))
trackConnection(CloseButton.MouseButton1Click:Connect(fullCleanupAndDestroy))

-- Keybind Keyboard (Tombol F untuk Analisis Cepat)
trackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        AnalyzeButton:Activate()
    end
end))

-- Inisialisasi Pengaturan Tersimpan
loadUserSettings()
print("Chess Helper Pro Complete Master Script Berhasil Dimuat!")
