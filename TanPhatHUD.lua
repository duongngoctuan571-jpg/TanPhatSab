local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local tracers = {}

local function createTracer(player)
    local line = Drawing.new("Line")
    line.Color = Color3.fromRGB(255,0,0)
    line.Thickness = 2
    line.Visible = false

    tracers[player] = line
end

local function removeTracer(player)
    if tracers[player] then
        tracers[player]:Remove()
        tracers[player] = nil
    end
end

-- Tạo tracer cho player hiện có
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createTracer(player)
    end
end

-- Player mới vào
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createTracer(player)
    end
end)

-- Player rời game
Players.PlayerRemoving:Connect(function(player)
    removeTracer(player)
end)

-- Update mỗi frame
RunService.RenderStepped:Connect(function()
    for player, line in pairs(tracers) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, visible = Camera:WorldToViewportPoint(
                player.Character.HumanoidRootPart.Position
            )

            if visible then
                line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                line.To = Vector2.new(pos.X, pos.Y)
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end)

local boxes = {}

local function createBox(player)
    local box = {
        Top = Drawing.new("Line"),
        Bottom = Drawing.new("Line"),
        Left = Drawing.new("Line"),
        Right = Drawing.new("Line")
    }

    for _, line in pairs(box) do
        line.Color = Color3.fromRGB(255,0,0)
        line.Thickness = 2
        line.Visible = false
    end

    boxes[player] = box
end

local function removeBox(player)
    if boxes[player] then
        for _, line in pairs(boxes[player]) do
            line:Remove()
        end
        boxes[player] = nil
    end
end

-- Tạo box cho player hiện có
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createBox(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createBox(player)
    end
end)

Players.PlayerRemoving:Connect(removeBox)

RunService.RenderStepped:Connect(function()
    for player, box in pairs(boxes) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")

            local rootPos, rootVisible = Camera:WorldToViewportPoint(root.Position)
            local headPos, headVisible = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))

            if rootVisible and headVisible then
                local height = math.abs(headPos.Y - rootPos.Y)
                local width = height / 2

                -- Tính góc box
                local topLeft = Vector2.new(rootPos.X - width/2, headPos.Y)
                local topRight = Vector2.new(rootPos.X + width/2, headPos.Y)
                local bottomLeft = Vector2.new(rootPos.X - width/2, rootPos.Y)
                local bottomRight = Vector2.new(rootPos.X + width/2, rootPos.Y)

                -- Gán line
                box.Top.From = topLeft
                box.Top.To = topRight

                box.Bottom.From = bottomLeft
                box.Bottom.To = bottomRight

                box.Left.From = topLeft
                box.Left.To = bottomLeft

                box.Right.From = topRight
                box.Right.To = bottomRight

                for _, line in pairs(box) do
                    line.Visible = true
                end
            else
                for _, line in pairs(box) do
                    line.Visible = false
                end
            end
        else
            for _, line in pairs(box) do
                line.Visible = false
            end
        end
    end
end)




local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

-- Frame chính
local circle = Instance.new("Frame")
circle.Parent = gui
circle.Size = UDim2.new(0, 200, 0, 200)
circle.Position = UDim2.new(0.5, -100, 0.5, -100) -- giữa màn hình
circle.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- nền trong
circle.BackgroundTransparency = 1

-- Bo tròn thành hình tròn
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = circle

-- Tạo viền đỏ
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 0, 0)
stroke.Thickness = 2
stroke.Parent = circle

-- aim
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local DISTANCE = 35

RunService.RenderStepped:Connect(function()
	if not player.Character then return end
	
	local myHRP = player.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end
	
	local closest = nil
	local shortest = DISTANCE
	
	for _, other in pairs(Players:GetPlayers()) do
		if other ~= player
		and other.Character
		and other.Character:FindFirstChild("Head")
		and other.Character:FindFirstChild("HumanoidRootPart") then
			
			local targetHRP = other.Character.HumanoidRootPart
			local distance = (myHRP.Position - targetHRP.Position).Magnitude
			
			if distance < shortest then
				shortest = distance
				closest = other
			end
		end
	end
	
	if closest then
		local head = closest.Character.Head
		local camPos = camera.CFrame.Position
		camera.CFrame = CFrame.new(camPos, head.Position) -- snap ngay lập tức
	end
end)
