-- Services
local Workspace = game:GetService("Workspace")

--[=[
    Returns the `CurrentCamera`

    @function getCurrentCamera
    @within Functions
    @return Camera
]=]
local function getCurrentCamera()
    return Workspace.CurrentCamera
end
return getCurrentCamera
