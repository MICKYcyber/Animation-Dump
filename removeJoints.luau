local removeJoints = {}
function removeJoints.removeJoints(part)
	for _, obj in ipairs(part:GetChildren()) do
		if obj:IsA("Weld")
			or obj:IsA("WeldConstraint")
			or obj:IsA("Motor6D")
			or obj:IsA("Snap")
			or obj:IsA("TouchTransmitter") then
			obj:Destroy()
		end
	end
	for _, joint in ipairs(part:GetJoints()) do
		joint:Destroy()
	end
end
return removeJoints
