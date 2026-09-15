# animation loader

A simple tool that takes care of the tedious roblox r6 reanimate setup; you provide the logic (such as movement, emotes, and keybinds) and it looks after everything else.

## what it does

- loads reanimate script automatically
- loads animation module automatically  
- download and cache .rbxm files
- sets up character object
- loads animations from files or folders

## installation

```lua
local AnimLoader = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourRepo/AnimationLoader.lua"))()
```

---

## functions

### load single animation

```lua
AnimLoader:LoadAnimation(fileUrl, animName, waitTime, priority)
```

- `fileUrl`, the url to the `.rbxm` file (raw github url).
- `animName` - animation name in the file
- `waitTime` - (optional) wait seconds after reanimate, default 7
- `priority` - (optional) animation priority enum

```lua
local Idle = AnimLoader:LoadAnimation(
	"https://github.com/user/repo/raw/main/Anims.rbxm",
	"Idle",
	7,
	Enum.AnimationPriority.Core
)

Idle.Loop = true
Idle:Play()
```

### load all animations from file

```lua
AnimLoader:LoadFolder(fileUrl, waitTime, priority)
```

- `fileUrl` is the url to the `.rbxm` file. Use the raw GitHub url.
- `waitTime` - (optional) wait seconds, default 7
- `priority` - (optional) sets priority for all animations loaded

```lua
local anims = AnimLoader:LoadFolder(
	"https://github.com/user/repo/raw/main/Anims.rbxm",
	7,
	Enum.AnimationPriority.Action
)

anims.Idle:Play()
anims.Walk:Play()
```

### load from roblox folder

```lua
AnimLoader:LoadAnimationFolder(folder, waitTime, priority)
```

- `folder` - roblox folder with keyframe sequences
- `waitTime` - (optional) wait seconds, default 7
- `priority` - (optional) sets priority for all animations

```lua
local anims = AnimLoader:LoadAnimationFolder(
	game.ReplicatedStorage.Animations,
	7,
	Enum.AnimationPriority.Movement
)

anims.Walk:Play()
```

---

## priority types

```lua
Enum.AnimationPriority.Core -- the lowest one, easy to override
Enum.AnimationPriority.Idle — for idle animations
Enum.AnimationPriority.Movement   -- for walk/run
Enum.AnimationPriority.Action -- for emotes, higher priority
Enum.AnimationPriority.Action2    -- even higher
Enum.AnimationPriority.Action3    -- even higher
Enum.AnimationPriority.Action4    -- highest
```

---

## examples

### basic usage

```lua
local AnimLoader = loadstring(game:HttpGet("https://raw.githubusercontent.com/.../AnimationLoader.lua"))()

-- load with default priority
local anims = AnimLoader:LoadFolder("https://github.com/.../Anims.rbxm")

anims.Idle.Loop = true
anims.Walk.Loop = true
anims.Idle:Play()
```

### with priority

```lua
-- movement animations with movement priority
local moveAnims = AnimLoader:LoadFolder(
	"https://github.com/.../MoveAnims.rbxm",
	7,
	Enum.AnimationPriority.Movement
)

-- emotes with action priority (overrides movement)
local emotes = AnimLoader:LoadFolder(
	"https://github.com/.../Emotes.rbxm",
	7,
	Enum.AnimationPriority.Action
)

moveAnims.Walk:Play()
Dance.emotes(): Play()  -- this will override walk
```

### full script

```lua
local AnimLoader = loadstring(game:HttpGet("https://raw.githubusercontent.com/.../AnimationLoader.lua"))()
local UIS = game:GetService("UserInputService")

-- load animations
local anims = AnimLoader:LoadFolder("https://github.com/.../Anims.rbxm")

-- configure
anims.Idle.Loop = true
anims.Walk.Loop = true
anims.Dance.Priority = Enum.AnimationPriority.Action
anims.Dance.Loop = true

local current = nil

local function play(anim)
	if current == anim then return end
	
	if current then
		current = current:SwitchAnimation(anim)
	else
		anim:Play()
		current = anim
	end
end

-- movement
local humanoid = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")

humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
	local speed = humanoid.MoveDirection.Magnitude
	
	If the speed is less than 0.1 then
		play(anims.Idle)
	else
		play(anims.Walk)
	end
end)

-- emote keybind
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	If the value of KeyCode is equal to Enum.KeyCode.E then
		anims.Dance:Play()
	end
end)

play(anims.Idle)
```

---

## important notes

### url format
Use the following GitHub URLs: https://github.com/user/repo/raw/main/file.rbxm  
Not blob urls: `https://github.com/user/repo/blob/main/file.rbxm`

### wait time
The default setting is 7 seconds; if your reanimate takes longer to initialise, then increase it.

### caching
The program automatically caches files, giving them random names such as `Anim_12ab34cd.rbxm`.

### errors
Instead of crashing, it returns nil or empty tables; make sure you check the returns:
```lua
local anim = AnimLoader:LoadAnimation(url, "Idle")
if anim then
	anim:Play()
end
```

### hardcoded urls
Reanimate and module urls are in the source code:
```lua
local REANIMATE_URL = "https://raw.githubusercontent.com/..."
local ANIMMODULE_URL = "https://raw.githubusercontent.com/..."
```
If you'd like to use different ones, please do so.

---

## animation methods

```lua
anim:Play()         -- start
anim:Stop()         -- stop and reset
anim:Pause()        -- pause

anim.Loop = true  // loop
Set the playback speed to 1.5.
anim.BlendTime is set to 0.2                  -- transition time
Set the priority to Enum.AnimationPriority.Action.

-- smooth transition
current = current:SwitchAnimation(newAnim)
```
