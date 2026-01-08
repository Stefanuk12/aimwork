-- Dependencies
local DrawingTypes = require("@types/extra_drawing")
local mergeTables = require("@functions/mergeTables")
local isPointInsideRect = require("@functions/isPointInsideRect")

-- Services
local UserInputService = game:GetService("UserInputService")

--[[
    All of the defaults
]]
local fovDefaults = table.freeze({
    Line = {
        Visible = false,
        ZIndex = 1,
        Transparency = 0,
        Color = Color3.new(),

        Thickness = 1,
        From = Vector2.zero,
        To = Vector2.zero,
    } :: DrawingTypes.DrawingLineData,
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
    } :: DrawingTypes.DrawingTextData,
    Image = {
        Visible = false,
        ZIndex = 1,
        Transparency = 0,
        Color = Color3.new(),

        Data = "",
        Size = Vector2.zero,
        Position = Vector2.zero,
        Rounding = 0,
    } :: DrawingTypes.DrawingImageData,
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
    } :: DrawingTypes.DrawingCircleData,
    Square = {
        Visible = false,
        ZIndex = 1,
        Transparency = 0,
        Color = Color3.new(),

        Thickness = 1,
        Size = Vector2.zero,
        Position = Vector2.zero,
        Filled = false,
    } :: DrawingTypes.DrawingSquareData,
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
    } :: DrawingTypes.DrawingQuadData,
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
    } :: DrawingTypes.DrawingTriangleData,
})

--[=[
    @class FovObject

    Handles updating and rendering the FOV while providing methods to check if a [Vector2] point is inside.
]=]
--[=[
    @prop drawing DrawingEnumWithData
    @within FovObject
    Holds the Drawing object and its related data.
]=]
local FovObject = {}
FovObject.__index = FovObject

-- Types
export type FovObjectData = {
    id: string,
    drawing: DrawingTypes.DrawingEnumWithData,
}
export type FovObject = setmetatable<FovObjectData, typeof(FovObject)>

--[=[
    Constructs a new [FovObject].

    @tag constructor
]=]
function FovObject.new(id: string, drawingData: DrawingTypes.DrawingOptionalDataEnum): FovObject
    -- Initialise properties
    local defaults = (fovDefaults :: any)[drawingData.Kind]
    assert(defaults, "could not find drawing defaults")
    defaults = table.clone(defaults)

    -- Create the object
    local self: FovObjectData = {
        id = id,
        drawing = {
            Kind = drawingData.Kind,
            Data = mergeTables(defaults, drawingData.Value),
            Value = nil,
        } :: any,
    }
    self = setmetatable(self, FovObject)

    -- Create the drawing
    self:CreateDrawing()

    -- Return the object
    return self
end

--[=[
    Used during [FovObject.new] to create the [Drawing] object, if the library is available.
]=]
function FovObject.CreateDrawing(self: FovObject)
    if not Drawing then
        return
    end

    local drawingObject = (Drawing.new :: any)(self.drawing.Kind)
    self.drawing.Value = drawingObject
    self:SetDrawingData()
end

--[=[
    Applies all of the settings stored internally in `self.Drawing.Value` to the actual Drawing object, if it exists.
]=]
function FovObject.SetDrawingData(self: FovObject)
    local object = self.drawing.Value
    if not object then
        return
    end

    for i, v in self.drawing.Data do
        (object :: any)[i] = v -- LUAU TYPE SOLVER ISSUE
    end
end

--[=[
    Updates the internal data and attempts to update the internal Drawing object with the new data.
]=]
function FovObject.Update(self: FovObject)
    local drawingData = self.drawing

    if drawingData.Kind == "Circle" then
        drawingData.Data.Position = UserInputService:GetMouseLocation()
    elseif drawingData.Kind == "Text" then
        if drawingData.Value then
            drawingData.Data.TextBounds = drawingData.Value.TextBounds
        end
    end

    self:SetDrawingData()
end

--[=[
    Checks if a [Vector2] point is inside of the FOV.

    @return number? -- The distance from the centre of the FOV
]=]
function FovObject.InsideFOV(self: FovObject, position: Vector2): number?
    local drawing = self.drawing

    if drawing.Kind == "Line" then
        local drawingData = drawing.Data
        local lineDirection = drawingData.To - drawingData.From
        local pointDirection = position - drawingData.From
        local projection = pointDirection:Dot(lineDirection.Unit)

        if not (projection >= 0 and projection <= lineDirection.Magnitude) then
            return nil
        end

        local closestPoint = drawingData.From + lineDirection.Unit * projection
        local distance = (closestPoint - position).Magnitude
        if distance <= drawingData.Thickness / 2 then
            return distance
        end
    elseif drawing.Kind == "Text" then
        local drawingData = drawing.Data
        return isPointInsideRect(position, drawingData.Position, drawingData.TextBounds)
    elseif drawing.Kind == "Image" or drawing.Kind == "Square" then
        local drawingData = drawing.Data
        return isPointInsideRect(position, drawingData.Position, drawingData.Size)
    elseif drawing.Kind == "Circle" then
        local drawingData = drawing.Data
        local distance = (drawingData.Position - position).Magnitude

        if distance < drawingData.Radius then
            return distance
        end
    elseif drawing.Kind == "Quad" then
        local drawingData = drawing.Data
        local points = { drawingData.PointA, drawingData.PointB, drawingData.PointC, drawingData.PointD }
        local centre = (drawingData.PointA + drawingData.PointB + drawingData.PointC + drawingData.PointD) / 4
        local isInside = true

        for i = 1, 4 do
            local A = points[i]
            local B = points[i % 4 + 1]
            local AB = B - A
            local AP = position - A

            if AB:Cross(AP) < 0 then
                isInside = false
                break
            end
        end

        if isInside then
            return (centre - position).Magnitude
        end
    elseif drawing.Kind == "Triangle" then
        local drawingData = drawing.Data
        local points = { drawingData.PointA, drawingData.PointB, drawingData.PointC }
        local centre = (drawingData.PointA + drawingData.PointB + drawingData.PointC) / 3
        local isInside = true

        for i = 1, 3 do
            local A = points[i]
            local B = points[i % 3 + 1]
            local AB = B - A
            local AP = position - A

            if AB:Cross(AP) < 0 then
                isInside = false
                break
            end
        end

        if isInside then
            return (centre - position).Magnitude
        end
    end

    return nil
end

return FovObject
