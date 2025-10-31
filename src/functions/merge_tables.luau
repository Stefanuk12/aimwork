--[=[
    Merges all the properties of `Source` onto `Destination`

    @function MergeTables
    @within Functions
    @param Destination table -- The destination table to merge the properties onto
    @param Source table -- The source table to get the properties from
    @return table -- The destination table with the merged properties from the source table
]=]
local function MergeTables<T, U>(Destination: T & {}, Source: U & {}): T & U
    -- // Ensure both A and B are tables, prefer to return A, if they're not
    if typeof(Destination) ~= "table" or typeof(Source) ~= "table" then
        return Destination :: any
    end

    -- // Loop through the source table
    for i, v in pairs(Source) do
        Destination = Destination :: any -- LUAU TYPE SOLVER ISSUE

        -- // Recurse if both are tables
        local DestinationValue = Destination[i]
        if typeof(DestinationValue) == "table" and typeof(v) == "table" then
            v = MergeTables(DestinationValue :: any, v) -- LUAU TYPE SOLVER ISSUE
        end

        -- // Set the property
        Destination[i] = v
    end

    -- // Return
    return Destination
end

-- //
return MergeTables
