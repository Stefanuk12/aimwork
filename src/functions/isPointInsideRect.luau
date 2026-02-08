--[=[
    Checks if a given 2D point is within a defined rect.

    @function isPointInsideRect
    @within Functions
    @return (boolean, number) inside, distance
]=]
local function isPointInsideRect(point: Vector2, centre: Vector2, size: Vector2): (boolean, number)
    local topLeft = centre - size / 2
    local bottomRight = centre + size / 2
    return point.X >= topLeft.X and point.X <= bottomRight.X and point.Y >= topLeft.Y and point.Y <= bottomRight.Y, (centre - point).Magnitude
end
return isPointInsideRect
