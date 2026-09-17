## linear velocity.luau
```lua
local Velocity = loadstring(game:HttpGet("https://raw.githubusercontent.com/GST-Studios/GST-Studios/refs/heads/main/LinearVelocity.luau"))()

local player = game:GetService("Players").LocalPlayer
local root = player.Character:FindFirstChild("HumanoidRootPart")

local part = workspace.someshit -- hat or something idfk this is meant for just a baseplate

local mover = Velocity.new(part, {
	PositionSpeed = 120,
	RotationSpeed = 60,
	MaxForce = 200
})

mover.SetTarget(root.CFrame * CFrame.new(0, 0, 3))

-- functions
-- mover.SetTarget(CFrame)
-- mover.SetTargetPosition(Vector3)
-- mover.Enable()
-- mover.Disable()
-- mover.Destroy()
-- mover.IsEnabled()
-- mover.GetTarget()
```
