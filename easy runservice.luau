local runservice = game:GetService("RunService")
local module = {}
local callbacks = {}

local connection = runservice.RenderStepped:Connect(function(dt)
	for _, callback in callbacks do
		callback(dt)
	end
end)

function module.add(callback)
	table.insert(callbacks, callback)
end

function module.wait()
	return runservice.Heartbeat:Wait()
end

function module.disconnect()
	connection:Disconnect()
	table.clear(callbacks)
end

return module
