-- // Dependencies
local FOVObjectTypes = require("./fov_object")

-- // Types
export type AdditionalFOVData = {
    UpdateEnabled: boolean,
    CheckEnabled: boolean,
}
export type FOVPrimative = FOVObjectTypes.FOVObject
export type VisualHandlerData = {
    Objects: { [FOVPrimative]: AdditionalFOVData },
}

--[=[
]=]
local VisualHandler = {}
VisualHandler.__index = VisualHandler
export type VisualHandler = typeof(setmetatable({} :: VisualHandlerData, VisualHandler))
do
    --[=[
        Constructs a new [VisualHandler].

        @tag constructor
    ]=]
    function VisualHandler.new()
        -- // Create the object
        local self = setmetatable({}, VisualHandler)

        -- // Initialise properties
        self.Objects = {}

        -- // Return the object
        return self
    end

    --[=[
        Add a new object to the tracker.
    ]=]
    function VisualHandler.Add(self: VisualHandler, Object: FOVPrimative, Data: AdditionalFOVData?)
        if self.Objects[Object] then
            return false
        end

        self.Objects[Object] = Data or {
            UpdateEnabled = true,
            CheckEnabled = true,
        }

        return true
    end

    --[=[
        Update all of the objects.
    ]=]
    function VisualHandler.Update(self: VisualHandler)
        for i, v in pairs(self.Objects) do
            if v.UpdateEnabled then
                i:Update()
            end
        end
    end

    --[=[
        Check all objects.
    ]=]
    function VisualHandler.Check(
        self: VisualHandler,
        Position: Vector2,
        FetchAll: boolean
    ): { [string]: number? } | boolean
        local Results = {}

        for i, v in pairs(self.Objects) do
            if not v.CheckEnabled then
                continue
            end

            local Result = i:InsideFOV(Position)
            if not FetchAll and not Result then
                return false
            end

            Results[i.Id] = Result
        end

        return Results
    end

    --[=[
        Destroys this object.

        @tag destructor
    ]=]
    function VisualHandler.Destroy(self: VisualHandler)
        setmetatable(self :: any, nil)
    end
end

-- //
return VisualHandler
