-- // Dependencies
local MergeTables = require("@functions/merge_tables")

-- // Services
local UserInputService = game:GetService("UserInputService")

-- // Checks if the `Point` is inside of a rectangle.
local function IsPointInsideRect(Point: Vector2, Centre: Vector2, Size: Vector2): number?
    local TopLeft = Centre - Size / 2
    local BottomRight = Centre + Size / 2
    if Point.X >= TopLeft.X and Point.X <= BottomRight.X and Point.Y >= TopLeft.Y and Point.Y <= BottomRight.Y then
        return (Centre - Point).Magnitude
    end
    return
end

-- //
--[=[
    @class FOVObject

    Handles updating and rendering the FOV while providing methods to check if a [Vector2] point is inside.
]=]
--[=[
    @prop Drawing DrawingEnumWithData
    @within FOVObject
    Holds the Drawing object and its related data.
]=]
local FOVObject = {}
FOVObject.__index = FOVObject
export type FOVObjectData = {
    Id: string,
    Drawing: DrawingEnumWithData,
}
export type FOVObject = typeof(setmetatable({} :: FOVObjectData, FOVObject))
do
    local FOVDefaults = {
        Line = {
            Visible = false,
            ZIndex = 1,
            Transparency = 0,
            Color = Color3.new(),

            Thickness = 1,
            From = Vector2.zero,
            To = Vector2.zero,
        } :: DrawingLineData,
        Text = {
            Visible = false,
            ZIndex = 1,
            Transparency = 0,
            Color = Color3.new(),

            Text = "",
            Size = 12,
            Center = true,
            Outline = false,
            OutlineColor = Color3.new(),
            Position = Vector2.zero,
            TextBounds = Vector2.zero,
        } :: DrawingTextData,
        Image = {
            Visible = false,
            ZIndex = 1,
            Transparency = 0,
            Color = Color3.new(),

            Data = "",
            Size = Vector2.zero,
            Position = Vector2.zero,
            Rounding = 0,
        } :: DrawingImageData,
        Circle = {
            Visible = false,
            ZIndex = 1,
            Transparency = 0,
            Color = Color3.new(),

            Thickness = 1,
            NumSides = 100,
            Radius = 0,
            Filled = false,
            Position = Vector2.zero,
        } :: DrawingCircleData,
        Square = {
            Visible = false,
            ZIndex = 1,
            Transparency = 0,
            Color = Color3.new(),

            Thickness = 1,
            Size = Vector2.zero,
            Position = Vector2.zero,
            Filled = false,
        } :: DrawingSquareData,
        Quad = {
            Visible = false,
            ZIndex = 1,
            Transparency = 0,
            Color = Color3.new(),

            Thickness = 1,
            PointA = Vector2.zero,
            PointB = Vector2.zero,
            PointC = Vector2.zero,
            PointD = Vector2.zero,
            Filled = false,
        } :: DrawingQuadData,
        Triangle = {
            Visible = false,
            ZIndex = 1,
            Transparency = 0,
            Color = Color3.new(),

            Thickness = 1,
            PointA = Vector2.zero,
            PointB = Vector2.zero,
            PointC = Vector2.zero,
            Filled = false,
        } :: DrawingTriangleData,
    }

    --[=[
        Constructs a new [FOVObject].

        @tag constructor
    ]=]
    function FOVObject.new(Id: string, DrawingData: DrawingOptionalDataEnum): FOVObject
        -- // Create the object
        local self = setmetatable({}, FOVObject)

        -- // Initialise properties
        local Defaults = FOVDefaults[DrawingData.Kind]
        assert(Defaults, "could not find drawing defaults")
        Defaults = table.clone(Defaults)
        self.Id = Id
        self.Drawing = {
            Kind = DrawingData.Kind,
            Data = MergeTables(Defaults, DrawingData.Value),
            Value = nil,
        } :: any

        -- // Create the drawing
        self:CreateDrawing()

        -- // Return the object
        return self
    end

    --[=[
        Used during [FOVObject.new] to create the [Drawing] object, if the library is available.
    ]=]
    function FOVObject.CreateDrawing(self: FOVObject)
        if not Drawing then
            return
        end

        local Object = Drawing.new(self.Drawing.Kind :: any) :: any;
        (self.Drawing :: any).Value = Object
        self:SetDrawingData()
    end

    --[=[
        Applies all of the settings stored internally in `self.Drawing.Value` to the actual Drawing object, if it exists.
    ]=]
    function FOVObject.SetDrawingData(self: FOVObject)
        local Object = self.Drawing.Value :: any?
        if not Object then
            return
        end

        for i, v in pairs(self.Drawing.Data) do
            Object[i] = v
        end
    end

    --[=[
        Updates the internal data and attempts to update the internal Drawing object with the new data.
    ]=]
    function FOVObject.Update(self: FOVObject)
        local DrawingData = self.Drawing
        if DrawingData.Kind == "Circle" then
            DrawingData.Data.Position = UserInputService:GetMouseLocation()
        elseif DrawingData.Kind == "Text" then
            if DrawingData.Value then
                DrawingData.Data.TextBounds = DrawingData.Value.TextBounds
            end
        end

        self:SetDrawingData()
    end

    --[=[
        Checks if a [Vector2] point is inside of the FOV.

        @return number? -- The distance from the centre of the FOV
    ]=]
    function FOVObject.InsideFOV(self: FOVObject, Position: Vector2): number?
        local DrawingData = self.Drawing
        if DrawingData.Kind == "Line" then
            local DrawingObject = DrawingData.Data
            local LineVector = DrawingObject.To - DrawingObject.From
            local PointVector = Position - DrawingObject.From
            local Projection = PointVector:Dot(LineVector.Unit)
            if Projection >= 0 and Projection <= LineVector.Magnitude then
                local ClosestPoint = DrawingObject.From + LineVector.Unit * Projection
                local Distance = (ClosestPoint - Position).Magnitude
                if Distance <= DrawingObject.Thickness / 2 then
                    return Distance
                end
            end
        elseif DrawingData.Kind == "Text" then
            local DrawingObject = DrawingData.Data
            return IsPointInsideRect(Position, DrawingObject.Position, DrawingObject.TextBounds)
        elseif DrawingData.Kind == "Image" or DrawingData.Kind == "Square" then
            local DrawingObject = DrawingData.Data
            return IsPointInsideRect(Position, DrawingObject.Position, DrawingObject.Size)
        elseif DrawingData.Kind == "Circle" then
            local DrawingObject = DrawingData.Data
            local Distance = (DrawingObject.Position - Position).Magnitude
            if Distance < DrawingObject.Radius then
                return Distance
            end
        elseif DrawingData.Kind == "Quad" then
            local DrawingObject = DrawingData.Data
            local Points = { DrawingObject.PointA, DrawingObject.PointB, DrawingObject.PointC, DrawingObject.PointD }
            local Centre = (DrawingObject.PointA + DrawingObject.PointB + DrawingObject.PointC + DrawingObject.PointD)
                / 4
            local Inside = true
            for i = 1, 4 do
                local A = Points[i]
                local B = Points[i % 4 + 1]
                local AB = B - A
                local AP = Position - A
                if AB:Cross(AP) < 0 then
                    Inside = false
                    break
                end
            end
            if Inside then
                return (Centre - Position).Magnitude
            end
        elseif DrawingData.Kind == "Triangle" then
            local DrawingObject = DrawingData.Data
            local Points = { DrawingObject.PointA, DrawingObject.PointB, DrawingObject.PointC }
            local Centre = (DrawingObject.PointA + DrawingObject.PointB + DrawingObject.PointC) / 3
            local Inside = true
            for i = 1, 3 do
                local A = Points[i]
                local B = Points[i % 3 + 1]
                local AB = B - A
                local AP = Position - A
                if AB:Cross(AP) < 0 then
                    Inside = false
                    break
                end
            end
            if Inside then
                return (Centre - Position).Magnitude
            end
        end
        return
    end
end

-- //
return FOVObject
