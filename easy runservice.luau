local runservice = game:GetService("RunService")
local module = {}
local callbacks = {}
function module.add(callback)
	table.insert(callbacks,callback)
end
function module.wait()
	return runservice.Heartbeat:Wait()
end
runservice.Heartbeat:Connect(function(dt)
	for _,callback in callbacks do
		callback(dt)
	end
end)
return module
