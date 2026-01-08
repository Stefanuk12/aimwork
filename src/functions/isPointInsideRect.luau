--[=[
    Checks if a given 2D point is within a defined rect.

    @function isPointInsideRect
    @within Functions
    @return number?
]=]
local function isPointInsideRect(point: Vector2, centre: Vector2, size: Vector2): number?
    local topLeft = centre - size / 2
    local bottomRight = centre + size / 2
    if point.X >= topLeft.X and point.X <= bottomRight.X and point.Y >= topLeft.Y and point.Y <= bottomRight.Y then
        return (centre - point).Magnitude
    end

    return nil
end
return isPointInsideRect
