local Main = {}
Main.Functions = {}
Main.__index = Main.Functions

local CharacterHandler = require(script.CharacterHandler)
local RuntimeHandler = require(script.RuntimeHandler)

Main.CharacterHandler = CharacterHandler
Main.CreateCharacterObject = CharacterHandler.CreateCharacterObject
Main.Functions.AddToRuntime = RuntimeHandler.AddToRuntime

function Main:LoadAnimation(CharacterObject:"Return of Main:CreateCharacterObject()", KeyframeSequence:KeyframeSequence)
	local Animation = setmetatable({}, Main)

	Animation.CharacterObject = CharacterObject
	Animation.KeyframeSequence = KeyframeSequence

	Animation.Priority = KeyframeSequence.Priority
	Animation.Loop = KeyframeSequence.Loop

	Animation.PlaybackSpeed = 1
	Animation.Playing = false

	Animation.BlendTime = 0.15
	Animation.RuntimePrivate = {}

	local KeyframeSequenceInOrder = KeyframeSequence:GetChildren()

	table.sort(KeyframeSequenceInOrder, function(a, b)
		return a.Time < b.Time
	end)

	Animation.Keyframes = KeyframeSequenceInOrder
	Animation.Time = KeyframeSequenceInOrder[#KeyframeSequenceInOrder].Time

	local KeyframeFormat = {}

	for _, Keyframe in ipairs(KeyframeSequenceInOrder) do
		for _, LimbFrame in ipairs(Keyframe:GetDescendants()) do

			if LimbFrame.Name ~= "Null"
				and LimbFrame.Name ~= "HumanoidRootPart"
				and LimbFrame:FindFirstChild("Null") == nil then

				KeyframeFormat[LimbFrame.Name] = KeyframeFormat[LimbFrame.Name] or {}

				table.insert(KeyframeFormat[LimbFrame.Name], {
					Time = Keyframe.Time,
					Keyframe = LimbFrame
				})
			end
		end
	end

	Animation.KeyframeTable = KeyframeFormat

	return Animation
end

function Main.Functions:Play()
	if self.Playing then
		return
	end

	self.Playing = true

	for LimbName, Limb in pairs(self.KeyframeTable) do

		local LimbMotor = self.CharacterObject.Motors[LimbName]

		if not LimbMotor then
			continue
		end

		local Previous = Limb[1]
		local Slot = 1

		local default = self.CharacterObject.DefaultC0[LimbName]
		local truedefault = default

		local KeyframeAmount = #Limb
		local Repeats = 0

		local Max = Limb[#Limb]

		-- This gets set by SwitchAnimation.
		-- If nil, the animation starts normally.
		local BlendFrom = self.BlendFrom and self.BlendFrom[LimbName]
		local BlendElapsed = 0

		self:AddToRuntime(LimbName, function(Runtime, RepeatsDetect, DeltaTime)

			if Runtime > Max.Time then
				LimbMotor.C0 = default * Max.Keyframe.CFrame
				return
			end

			if Repeats ~= RepeatsDetect then
				Repeats = RepeatsDetect
				default = truedefault
				Slot = 1
				Previous = Limb[1]
			end

			while true do
				if Runtime > Previous.Time and Slot ~= KeyframeAmount then
					Slot += 1
					Previous = Limb[Slot]
				else
					break
				end
			end

			local CalculatedTime

			if Slot == 1 then
				CalculatedTime = {
					Time = 0,
					Keyframe = {
						CFrame = CFrame.new(0, 0, 0)
					}
				}
			else
				CalculatedTime = Limb[Slot - 1]
			end

			local Calculation = 1

			if Slot ~= 1 then
				Calculation =
					(Runtime - CalculatedTime.Time)
					/ (Previous.Time - CalculatedTime.Time)
			end

			local CalculatedCFrame =
				CalculatedTime.Keyframe.CFrame:Lerp(
					Previous.Keyframe.CFrame,
					math.clamp(Calculation, 0, 1)
				)

			local TargetCFrame = default * CalculatedCFrame

			if BlendFrom and BlendElapsed < self.BlendTime then

				BlendElapsed += DeltaTime

				local Alpha = math.clamp(
					BlendElapsed / self.BlendTime,
					0,
					1
				)

				-- Smoothstep
				Alpha = Alpha * Alpha * (3 - 2 * Alpha)

				LimbMotor.C0 = BlendFrom:Lerp(TargetCFrame, Alpha)

			else
				LimbMotor.C0 = TargetCFrame
			end
		end)
	end

	-- Only needed for the initial switch.
	self.BlendFrom = nil
end

function Main.Functions:SwitchAnimation(NewAnimation)
	if NewAnimation == self then
		return
	end

	-- Capture the exact pose currently visible on every motor.
	local BlendFrom = {}

	for LimbName, Motor in pairs(self.CharacterObject.Motors) do
		BlendFrom[LimbName] = Motor.C0
	end

	-- Give the new animation the captured pose.
	NewAnimation.BlendFrom = BlendFrom

	-- Start the new animation FIRST.
	--
	-- This is important because if the old animation is stopped first,
	-- Stop() can reset the motors to their default C0.
	NewAnimation:Play()

	-- Now remove the old animation.
	self:Stop()

	return NewAnimation
end

function Main.Functions:Stop()
	local Priority = (self.Priority.Name == "Core" and -1) or self.Priority.Value

	self.Playing = false

	for LimbName, Thread in pairs(self.RuntimePrivate) do

		local Runtime = self.CharacterObject.Runtime[LimbName][Priority]

		if Runtime then
			local Index = table.find(Runtime, Thread)

			if Index then
				table.remove(Runtime, Index)
			end
		end

		local Times = 0

		for _, Items in pairs(self.CharacterObject.Runtime[LimbName]) do
			Times += #Items
		end

		if Times == 0 then
			self.CharacterObject.Motors[LimbName].C0 =
				self.CharacterObject.DefaultC0[LimbName]
		end
	end

	self.RuntimePrivate = {}
end

return Main