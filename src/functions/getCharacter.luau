--[=[
    Returns the Character associated with a `Player`

    @function getCharacter
    @within Functions
    @param player Player
    @return Model?
]=]
local function getCharacter(Player: Player)
    return Player.Character
end
return getCharacter
