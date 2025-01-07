-- // Services
local Workspace = game:GetService("Workspace")

--[=[
    Returns the `CurrentCamera`

    @function GetCurrentCamera
    @within Functions
    @return Camera
]=]
return function()
    return Workspace.CurrentCamera
end
