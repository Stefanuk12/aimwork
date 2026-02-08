-- Dependencies
local Trove = require("@pkgs/trove")
local FovObjectTypes = require("@self/FovObject")

--[=[
    @class VisualHandler

    Manages all visual objects.
]=]
local VisualHandler = {}
VisualHandler.__index = VisualHandler

-- Types
export type AdditionalFOVData = {
    update: boolean,
    check: boolean,
}
export type FOVPrimative = FovObjectTypes.FovObject

export type VisualHandlerData = {
    _trove: Trove.Trove,
    objects: { [FOVPrimative]: AdditionalFOVData },
}
export type VisualHandler = setmetatable<VisualHandlerData, typeof(VisualHandler)>

--[=[
    Constructs a new [VisualHandler].

    @tag constructor
]=]
function VisualHandler.new(): VisualHandler
    local self: VisualHandlerData = {
        _trove = Trove.new(),
        objects = {},
    }
    return setmetatable(self, VisualHandler)
end

--[=[
    Add a new object to the tracker.
]=]
function VisualHandler.Add(self: VisualHandler, fovObject: FOVPrimative, data: AdditionalFOVData?)
    if self.objects[fovObject] then
        return false
    end

    self.objects[fovObject] = data or {
        update = true,
        check = true,
    }

    self._trove:Add(fovObject)

    return true
end

--[=[
    Update all of the objects.
]=]
function VisualHandler.Update(self: VisualHandler)
    for fovObject, data in pairs(self.objects) do
        if data.update then
            fovObject:Update()
        end
    end
end

--[=[
    Check all objects.
]=]
function VisualHandler.Check(self: VisualHandler, position: Vector2, fetchAll: boolean)
    local allSuccess = true
    local results = {}

    for fovObject, data in pairs(self.objects) do
        if not data.check then
            continue
        end

        local result = fovObject:InsideFOV(position)
        if not result then
            allSuccess = false

            if not fetchAll then
                return {}, false
            end
        end

        results[fovObject.id] = result
    end

    return results, allSuccess
end

--[=[
    Destroys this object.

    @tag destructor
]=]
function VisualHandler.Destroy(self: VisualHandler)
    self._trove:Destroy()
    setmetatable(self :: any, nil)
end

return VisualHandler
