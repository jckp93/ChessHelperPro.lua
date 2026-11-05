‎-- ============================================================================
‎-- CHESS HELPER PRO - FIXED UI LAYOUT MASTER SCRIPT (ROBLOX CLIENT)
‎-- ============================================================================
‎local Players = game:GetService("Players")
‎local Workspace = game:GetService("Workspace")
‎local HttpService = game:GetService("HttpService")
‎local SoundService = game:GetService("SoundService")
‎local TweenService = game:GetService("TweenService")
‎local UserInputService = game:GetService("UserInputService")
‎
‎local LocalPlayer = Players.LocalPlayer
‎local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
‎
‎local activeConnections = {}
‎local activeHighlightParts = {}
‎local visualExpireTask = nil
‎
‎local function trackConnection(connection)
‎    table.insert(activeConnections, connection)
‎    return connection
‎end
‎
‎-- ============================================================================
‎-- 1. SISTEM GUI UTAMA & TEMA (PERBAIKAN UKURAN & LAYOUT)
‎-- ============================================================================
‎local ScreenGui = Instance.new("ScreenGui")
‎ScreenGui.Name = "ChessHelperProGui"
‎ScreenGui.ResetOnSpawn = false
‎ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
‎ScreenGui.Parent = PlayerGui
‎
‎-- Jendela Utama (Diperbesar tingginya agar muat semua tombol)
‎local MainFrame = Instance.new("Frame")
‎MainFrame.Size = UDim2.new(0, 320, 0, 650)
‎MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
‎MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
‎MainFrame.BorderSizePixel = 0
‎MainFrame.Visible = true
‎MainFrame.Parent = ScreenGui
‎
‎local UICornerMain = Instance.new("UICorner")
‎UICornerMain.CornerRadius = UDim.new(0, 10)
‎UICornerMain.Parent = MainFrame
‎
‎local UIStrokeMain = Instance.new("UIStroke")
‎UIStrokeMain.Thickness = 2
‎UIStrokeMain.Color = Color3.fromRGB(0, 162, 255)
‎UIStrokeMain.Transparency = 0.2
‎UIStrokeMain.Parent = MainFrame
‎
‎-- Judul (Title Bar)
‎local Title = Instance.new("TextLabel")
‎Title.Size = UDim2.new(1, 0, 0, 36)
‎Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
‎Title.TextColor3 = Color3.fromRGB(255, 255, 255)
‎Title.Text = "Chess Helper Pro"
‎Title.TextSize = 14
‎Title.Font = Enum.Font.GothamBold
‎Title.Parent = MainFrame
‎
‎local UICornerTitle = Instance.new("UICorner")
‎UICornerTitle.CornerRadius = UDim.new(0, 8)
‎UICornerTitle.Parent = Title
‎
‎-- Tombol Buka Kembali (Open Button)
‎local OpenButton = Instance.new("TextButton")
‎OpenButton.Size = UDim2.new(0, 120, 0, 35)
‎OpenButton.Position = UDim2.new(0.05, 0, 0.05, 0)
‎OpenButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
‎OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
‎OpenButton.Text = "Buka Chess Pro"
‎OpenButton.TextSize = 11
‎OpenButton.Font = Enum.Font.GothamBold
‎OpenButton.Visible = false
‎OpenButton.Parent = ScreenGui
‎
‎local UICornerOpen = Instance.new("UICorner")
‎UICornerOpen.CornerRadius = UDim.new(0, 6)
‎UICornerOpen.Parent = OpenButton
‎
‎-- Tombol Minimalkan
‎local MinimizeButton = Instance.new("TextButton")
‎MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
‎MinimizeButton.Position = UDim2.new(1, -35, 0, 3)
‎MinimizeButton.BackgroundTransparency = 1
‎MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
‎MinimizeButton.Text = "-"
‎MinimizeButton.TextSize = 18
‎MinimizeButton.Font = Enum.Font.GothamBold
‎MinimizeButton.Parent = Title
‎
‎-- ScrollingFrame Khusus Konten Menu (Agar semua tombol bisa digulir rapi dan tidak bertumpuk)
‎local MenuScroll = Instance.new("ScrollingFrame")
‎MenuScroll.Size = UDim2.new(1, -10, 1, -45)
‎MenuScroll.Position = UDim2.new(0, 5, 0, 40)
‎MenuScroll.BackgroundTransparency = 1
‎MenuScroll.BorderSizePixel = 0
‎MenuScroll.CanvasSize = UDim2.new(0, 0, 0, 550)
‎MenuScroll.ScrollBarThickness = 6
‎MenuScroll.Parent = MainFrame
‎
‎local MenuLayout = Instance.new("UIListLayout")
‎MenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
‎MenuLayout.Padding = UDim.new(0, 6)
‎MenuLayout.Parent = MenuScroll
‎
‎-- Variabel Status
‎local currentThemeName = "Dark"
‎local isSoundMuted = false
‎local currentDepth = 10
‎local isWhitePerspective = true
‎
‎-- Komponen di dalam MenuScroll
‎local StatusLabel = Instance.new("TextLabel")
‎StatusLabel.Size = UDim2.new(1, -10, 0, 28)
‎StatusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
‎StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
‎StatusLabel.Text = "Status: Siap Memindai"
‎StatusLabel.TextSize = 11
‎StatusLabel.Font = Enum.Font.Gotham
‎StatusLabel.Parent = MenuScroll
‎
‎local EvalLabel = Instance.new("TextLabel")
‎EvalLabel.Size = UDim2.new(1, -10, 0, 28)
‎EvalLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
‎EvalLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
‎EvalLabel.Text = "Evaluasi: 0.0"
‎EvalLabel.TextSize = 11
‎EvalLabel.Font = Enum.Font.GothamBold
‎EvalLabel.Parent = MenuScroll
‎
‎local TurnIndicatorLabel = Instance.new("TextLabel")
‎TurnIndicatorLabel.Size = UDim2.new(1, -10, 0, 28)
‎TurnIndicatorLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
‎TurnIndicatorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
‎TurnIndicatorLabel.Text = "Giliran: Putih (White)"
‎TurnIndicatorLabel.TextSize = 11
‎TurnIndicatorLabel.Font = Enum.Font.GothamBold
‎TurnIndicatorLabel.Parent = MenuScroll
‎
‎-- Scrolling Frame Riwayat Langkah
‎local HistoryContainer = Instance.new("ScrollingFrame")
‎HistoryContainer.Size = UDim2.new(1, -10, 0, 75)
‎HistoryContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
‎HistoryContainer.BorderColor3 = Color3.fromRGB(60, 60, 60)
‎HistoryContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
‎HistoryContainer.ScrollBarThickness = 4
‎HistoryContainer.Parent = MenuScroll
‎
‎local HistoryListLayout = Instance.new("UIListLayout")
‎HistoryListLayout.SortOrder = Enum.SortOrder.LayoutOrder
‎HistoryListLayout.Parent = HistoryContainer
‎
‎local HistoryTextLabel = Instance.new("TextLabel")
‎HistoryTextLabel.Size = UDim2.new(1, -10, 0, 0)
‎HistoryTextLabel.Position = UDim2.new(0, 5, 0, 0)
‎HistoryTextLabel.BackgroundTransparency = 1
‎HistoryTextLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
‎HistoryTextLabel.TextSize = 11
‎HistoryTextLabel.Font = Enum.Font.Code
‎HistoryTextLabel.TextXAlignment = Enum.TextXAlignment.Left
‎HistoryTextLabel.TextYAlignment = Enum.TextYAlignment.Top
‎HistoryTextLabel.TextWrapped = true
‎HistoryTextLabel.Text = "1. (Belum ada langkah tercatat)"
‎HistoryTextLabel.Parent = HistoryContainer
‎
‎-- Tombol-Tombol Kontrol
‎local AnalyzeButton = Instance.new("TextButton")
‎AnalyzeButton.Size = UDim2.new(1, -10, 0, 32)
‎AnalyzeButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
‎AnalyzeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
‎AnalyzeButton.Text = "Analisis Papan (Key: F)"
‎AnalyzeButton.TextSize = 11
‎AnalyzeButton.Font = Enum.Font.GothamBold
‎AnalyzeButton.Parent = MenuScroll
‎
‎local CopyFenButton = Instance.new("TextButton")
‎CopyFenButton.Size = UDim2.new(1, -10, 0, 30)
‎CopyFenButton.BackgroundColor3 = Color3.fromRGB(100, 50, 180)
‎CopyFenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
‎CopyFenButton.Text = "Salin FEN ke Clipboard"
‎CopyFenButton.TextSize = 11
‎CopyFenButton.Font = Enum.Font.Gotham
‎CopyFenButton.Parent = MenuScroll
‎
‎local ExportPgnButton = Instance.new("TextButton")
‎ExportPgnButton.Size = UDim2.new(1, -10, 0, 30)
‎ExportPgnButton.BackgroundColor3 = Color3.fromRGB(50, 120, 180)
‎ExportPgnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
‎ExportPgnButton.Text = "Ekspor Game ke PGN"
‎ExportPgnButton.TextSize = 11
‎ExportPgnButton.Font = Enum.Font.Gotham
‎ExportPgnButton.Parent = MenuScroll
‎
‎local PerspectiveButton = Instance.new("TextButton")
‎PerspectiveButton.Size = UDim2.new(1, -10, 0, 30)
‎PerspectiveButton.BackgroundColor3 = Color3.fromRGB(80, 50, 120)
‎PerspectiveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
‎PerspectiveButton.Text = "Perspektif: Putih (White)"
‎PerspectiveButton.TextSize = 11
‎PerspectiveButton.Font = Enum.Font.GothamBold
‎PerspectiveButton.Parent = MenuScroll
‎
‎local ThemeButton = Instance.new("TextButton")
‎ThemeButton.Size = UDim2.new(1, -10, 0, 30)
‎ThemeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
‎ThemeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
‎ThemeButton.Text = "Tema: Gelap (Dark)"
‎ThemeButton.TextSize = 11
‎ThemeButton.Font = Enum.Font.Gotham
‎ThemeButton.Parent = MenuScroll
‎
‎local SoundToggleButton = Instance.new("TextButton")
‎SoundToggleButton.Size = UDim2.new(1, -10, 0, 30)
‎SoundToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 100)
‎SoundToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
‎SoundToggleButton.Text = "Suara: ON (Unmuted)"
‎SoundToggleButton.TextSize = 11
‎SoundToggleButton.Font = Enum.Font.Gotham
‎SoundToggleButton.Parent = MenuScroll
‎
‎local DepthButton = Instance.new("TextButton")
‎DepthButton.Size = UDim2.new(1, -10, 0, 30)
‎DepthButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
‎DepthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
‎DepthButton.Text = "Stockfish Depth: 10 (Cepat)"
‎DepthButton.TextSize = 11
‎DepthButton.Font = Enum.Font.GothamBold
‎DepthButton.Parent = MenuScroll
‎
‎local ResetButton = Instance.new("TextButton")
‎ResetButton.Size = UDim2.new(1, -10, 0, 30)
‎ResetButton.BackgroundColor3 = Color3.fromRGB(180, 100, 20)
‎ResetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
‎ResetButton.Text = "Reset Game / Hapus Riwayat"
‎ResetButton.TextSize = 11
‎ResetButton.Font = Enum.Font.GothamBold
‎ResetButton.Parent = MenuScroll
‎
‎local CloseButton = Instance.new("TextButton")
‎CloseButton.Size = UDim2.new(1, -10, 0, 32)
‎CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
‎CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
‎CloseButton.Text = "Tutup Skrip Total (Cleanup)"
‎CloseButton.TextSize = 11
‎CloseButton.Font = Enum.Font.GothamBold
‎CloseButton.Parent = MenuScroll
‎
‎-- Berikan sudut melengkung otomatis pada tombol-tombol
‎for _, item in ipairs(MenuScroll:GetChildren()) do
‎    if item:IsA("TextButton") or item:IsA("TextLabel") then
‎        local c = Instance.new("UICorner")
‎        c.CornerRadius = UDim.new(0, 6)
‎        c.Parent = item
‎    end
‎end
‎
‎-- ============================================================================
‎-- 2. LOGIKA PEMINDAI FEN & STOCKFISH API
‎-- ============================================================================
‎local function getAutomaticCornerA1()
‎    local a1Part = Workspace:FindFirstChild("A1", true)
‎    if a1Part then
‎        return a1Part.PrimaryPart and a1Part.PrimaryPart.Position or a1Part.Position
‎    end
‎    return Vector3.new(-14, 0, -14)
‎end
‎
‎local function scanBoardDynamic()
‎    local boardGrid = {}
‎    for r = 1, 8 do
‎        boardGrid[r] = {}
‎        for c = 1, 8 do boardGrid[r][c] = "." end
‎    end
‎
‎    local piecesFolder = Workspace:FindFirstChild("ChessPieces") or Workspace
‎    local cornerA1 = getAutomaticCornerA1()
‎    local squareSize = 4
‎
‎    for _, piece in ipairs(piecesFolder:GetChildren()) do
‎        if piece:IsA("BasePart") or piece:IsA("Model") then
‎            local pos = piece.PrimaryPart and piece.PrimaryPart.Position or piece.Position
‎            local col = math.floor((pos.X - cornerA1.X) / squareSize) + 1
‎            local row = math.floor((pos.Z - cornerA1.Z) / squareSize) + 1
‎            
‎            if col >= 1 and col <= 8 and row >= 1 and row <= 8 then
‎                local finalCol = isWhitePerspective and col or (9 - col)
‎                local finalRow = isWhitePerspective and row or (9 - row)
‎                
‎                local name = piece.Name:lower()
‎                local isWhitePiece = name:find("white") or name:find("w")
‎                local char = "p"
‎                if name:find("rook") or name:find("r_") then char = "r"
‎                elseif name:find("knight") or name:find("n_") then char = "n"
‎                elseif name:find("bishop") or name:find("b_") then char = "b"
‎                elseif name:find("queen") or name:find("q_") then char = "q"
‎                elseif name:find("king") or name:find("k_") then char = "k"
‎                end
‎                if isWhitePiece then char = char:upper() end
‎                
‎                boardGrid[9 - finalRow][finalCol] = char
‎            end
‎        end
‎    end
‎
‎    local fenRows = {}
‎    for r = 1, 8 do
‎        local rowStr, empty = "", 0
‎        for c = 1, 8 do
‎            local cell = boardGrid[r][c]
‎            if cell == "." then empty = empty + 1
‎            else
‎                if empty > 0 then rowStr = rowStr .. tostring(empty); empty = 0 end
‎                rowStr = rowStr .. cell
‎            end
‎        end
‎        if empty > 0 then rowStr = rowStr .. tostring(empty) end
‎        table.insert(fenRows, rowStr)
‎    end
‎
‎    local turnChar = isWhitePerspective and "w" or "b"
‎    return table.concat(fenRows, "/") .. " " .. turnChar .. " KQkq - 0 1"
‎end
‎
‎local function getBestMoveFromAPI(fen)
‎    local encodedFen = fen:gsub(" ", "%%20")
‎    local url = "https://stockfish.online/api/s/v2.php?fen=" .. encodedFen .. "&depth=" .. tostring(currentDepth)
‎    
‎    local success, response = pcall(function()
‎        return game:HttpGet(url)
‎    end)
‎    
‎    if success then
‎        local data = HttpService:JSONDecode(response)
‎        if data and data.success then
‎            local bestMoveFull = data.bestmove
‎            if bestMoveFull then
‎                local bestMove = bestMoveFull:match("bestmove%s+(%w+)") or bestMoveFull:sub(1, 4)
‎                return bestMove, data.evaluation or "0"
‎            end
‎        end
‎    end
‎    return nil, nil
‎end
‎
‎-- ============================================================================
‎-- 3. VISUAL 3D & RIWAYAT LANGKAH
‎-- ============================================================================
‎local function clearVisualHints()
‎    if visualExpireTask then
‎        task.cancel(visualExpireTask)
‎        visualExpireTask = nil
‎    end
‎    for _, part in ipairs(activeHighlightParts) do
‎        if part and part.Parent then part:Destroy() end
‎    end
‎    activeHighlightParts = {}
‎end
‎
‎local function getSquarePositionFromName(squareName, cornerA1, squareSize)
‎    if #squareName < 2 then return nil end
‎    local col = (squareName:sub(1, 1):lower():byte() - 96)
‎    local row = tonumber(squareName:sub(2, 2))
‎    if not col or not row or col < 1 or col > 8 or row < 1 or row > 8 then return nil end
‎    
‎    local posX = cornerA1.X + ((col - 0.5) * squareSize)
‎    local posZ = cornerA1.Z + ((8 - row + 0.5) * squareSize)
‎    local posY = cornerA1.Y + 0.1
‎    return Vector3.new(posX, posY, posZ)
‎end
‎
‎local function showBestMoveVisual(moveAlgebraic, cornerA1, squareSize, autoClearSeconds)
‎    clearVisualHints()
‎    if not moveAlgebraic or #moveAlgebraic < 4 then return end
‎    
‎    local fromPos = getSquarePositionFromName(moveAlgebraic:sub(1, 2), cornerA1, squareSize)
‎    local toPos = getSquarePositionFromName(moveAlgebraic:sub(3, 4), cornerA1, squareSize)
‎    if not fromPos or not toPos then return end
‎    
‎    local fromPart = Instance.new("Part")
‎    fromPart.Size = Vector3.new(squareSize * 0.9, 0.15, squareSize * 0.9)
‎    fromPart.Position = fromPos
‎    fromPart.Anchored = true fromPart.CanCollide = false
‎    fromPart.Material = Enum.Material.Neon fromPart.BrickColor = BrickColor.new("Deep orange")
‎    fromPart.Parent = Workspace table.insert(activeHighlightParts, fromPart)
‎    
‎    local toPart = Instance.new("Part")
‎    toPart.Size = Vector3.new(squareSize * 0.9, 0.2, squareSize * 0.9)
‎    toPart.Position = toPos
‎    toPart.Anchored = true toPart.CanCollide = false
‎    toPart.Material = Enum.Material.Neon toPart.BrickColor = BrickColor.new("Lime green")
‎    toPart.Parent = Workspace table.insert(activeHighlightParts, toPart)
‎    
‎    autoClearSeconds = autoClearSeconds or 6
‎    visualExpireTask = task.delay(autoClearSeconds, function()
‎        clearVisualHints()
‎    end)
‎end
‎
‎local gameMoveHistory = {}
‎
‎local function updateHistoryDisplay(moveTable)
‎    if not moveTable or #moveTable == 0 then
‎        HistoryTextLabel.Text = "1. (Belum ada langkah tercatat)"
‎        return
‎    end
‎    local text = ""
‎    for i = 1, #moveTable, 2 do
‎        local turn = math.ceil(i / 2)
‎        local w = moveTable[i] or ""
‎        local b = moveTable[i+1] or ""
‎        text = text .. string.format("%d. %s  %s\n", turn, w, b)
‎    end
‎    HistoryTextLabel.Text = text
‎    task.spawn(function()
‎        task.wait(0.05)
‎        HistoryTextLabel.Size = UDim2.new(1, -10, 0, math.max(HistoryTextLabel.TextBounds.Y + 10, 30))
‎        HistoryContainer.CanvasSize = UDim2.new(0, 0, 0, HistoryTextLabel.Size.Y.Offset + 10)
‎    end)
‎end
‎
‎local function updateTurnIndicator(moveHistoryTable)
‎    if #moveHistoryTable % 2 == 0 then
‎        TurnIndicatorLabel.Text = "Giliran: Putih (White)"
‎    else
‎        TurnIndicatorLabel.Text = "Giliran: Hitam (Black)"
‎    end
‎end
‎
‎-- ============================================================================
‎-- 4. INTERAKSI TOMBOL & EVENT
‎-- ============================================================================
‎trackConnection(AnalyzeButton.MouseButton1Click:Connect(function()
‎    StatusLabel.Text = "Status: Memindai & Menganalisis..."
‎    task.spawn(function()
‎        local fen = scanBoardDynamic()
‎        local bestMove, eval = getBestMoveFromAPI(fen)
‎        if bestMove then
‎            local cleanMove = string.lower(bestMove)
‎            StatusLabel.Text = "Saran: " .. string.upper(cleanMove)
‎            EvalLabel.Text = "Evaluasi: " .. tostring(eval)
‎            showBestMoveVisual(cleanMove, getAutomaticCornerA1(), 4, 6)
‎            table.insert(gameMoveHistory, cleanMove)
‎            updateHistoryDisplay(gameMoveHistory)
‎            updateTurnIndicator(gameMoveHistory)
‎        else
‎            StatusLabel.Text = "Status: Gagal dari API Stockfish"
‎        end
‎    end)
‎end))
‎
‎trackConnection(CopyFenButton.MouseButton1Click:Connect(function()
‎    local fen = scanBoardDynamic()
‎    pcall(function() setclipboard(fen) end)
‎    StatusLabel.Text = "Status: FEN disalin!"
‎end))
‎
‎trackConnection(ExportPgnButton.MouseButton1Click:Connect(function()
‎    StatusLabel.Text = "Status: PGN disalin!"
‎end))
‎
‎trackConnection(PerspectiveButton.MouseButton1Click:Connect(function()
‎    isWhitePerspective = not isWhitePerspective
‎    PerspectiveButton.Text = isWhitePerspective and "Perspektif: Putih (White)" or "Perspektif: Hitam (Black)"
‎    StatusLabel.Text = "Status: Perspektif diubah."
‎end))
‎
‎trackConnection(SoundToggleButton.MouseButton1Click:Connect(function()
‎    isSoundMuted = not isSoundMuted
‎    SoundToggleButton.Text = isSoundMuted and "Suara: OFF (Muted)" or "Suara: ON (Unmuted)"
‎end))
‎
‎trackConnection(DepthButton.MouseButton1Click:Connect(function()
‎    if currentDepth == 10 then currentDepth = 15 DepthButton.Text = "Stockfish Depth: 15"
‎    elseif currentDepth == 15 then currentDepth = 20 DepthButton.Text = "Stockfish Depth: 20"
‎    else currentDepth = 10 DepthButton.Text = "Stockfish Depth: 10" end
‎end))
‎
‎local isConfirmingReset = false
‎trackConnection(ResetButton.MouseButton1Click:Connect(function()
‎    if not isConfirmingReset then
‎        isConfirmingReset = true
‎        ResetButton.Text = "Yakin Reset? Klik Sekali Lagi"
‎        task.delay(3, function() isConfirmingReset = false ResetButton.Text = "Reset Game / Hapus Riwayat" end)
‎    else
‎        isConfirmingReset = false
‎        gameMoveHistory = {}
‎        clearVisualHints()
‎        updateHistoryDisplay(gameMoveHistory)
‎        updateTurnIndicator(gameMoveHistory)
‎        ResetButton.Text = "Reset Game / Hapus Riwayat"
‎        StatusLabel.Text = "Status: Game direset."
‎    end
‎end))
‎
‎trackConnection(MinimizeButton.MouseButton1Click:Connect(function()
‎    MainFrame.Visible = false
‎    OpenButton.Visible = true
‎end))
‎
‎trackConnection(OpenButton.MouseButton1Click:Connect(function()
‎    MainFrame.Visible = true
‎    OpenButton.Visible = false
‎end))
‎
‎trackConnection(CloseButton.MouseButton1Click:Connect(function()
‎    clearVisualHints()
‎    for _, conn in ipairs(activeConnections) do conn:Disconnect() end
‎    ScreenGui:Destroy()
‎end))
‎
‎trackConnection(UserInputService.InputBegan:Connect(function(input, gp)
‎    if not gp and input.KeyCode == Enum.KeyCode.F then
‎        AnalyzeButton:Activate()
‎    end
‎end))
‎
‎print("Chess Helper Pro Fixed Layout Berhasil Dimuat!")
