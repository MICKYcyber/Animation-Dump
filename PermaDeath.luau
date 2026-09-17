local players = game:GetService("Players")
local startergui = game:GetService("StarterGui")
local workspace = game:GetService("Workspace")

local lp = players.LocalPlayer
local camera = workspace.CurrentCamera
local loadtime = players.RespawnTime + 0.5

local function respawnrequest()
  local char = lp.Character
  local camCF = camera.CFrame
  lp.Character = nil
  lp.Character = char

  local con
  con = camera.Changed:Connect(function(prop)
    if prop == "CFrame" or prop == "Parent" then
      camera.CFrame = camCF
      con:Disconnect()
    end
  end)
end

local function lockdeath(char)
  respawnrequest()

  local hum = char:FindFirstChildOfClass("Humanoid")
  if hum then
    hum:ChangeState(Enum.HumanoidStateType.Physics)
  end

  task.delay(loadtime, function()
    char:BreakJoints()
    local h = char:FindFirstChildOfClass("Humanoid")
    if h then
      h.Health = 0
    end
  end)

  local rb = Instance.new("BindableEvent")

  rb.Event:Connect(function()
    rb:Destroy()

    pcall(function()
      startergui:SetCore("ResetButtonCallback", true)
    end)

    char:BreakJoints()
    local h = char:FindFirstChildOfClass("Humanoid")
    if h then
      h.Health = 0
    end

    respawnrequest()
  end)

  pcall(function()
    startergui:SetCore("ResetButtonCallback", rb)
  end)
end

lockdeath(lp.Character)
