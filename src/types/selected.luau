--[=[
    @interface AimworkSelected
    @within Aimwork
    .Player Player -- The current selected [Player]. Note that if this is equal to [Players.LocalPlayer], then there is not a selected player.
    .Part BasePart -- The closest part to the cursor inside of the [Player.Character].
    .Position Vector3 -- The [Part.Position] of the closest part.
    .Distance number -- The on screen distance from the cursor to the on screen [Part.Position] of the closest part.
]=]
export type AimworkSelected = {
    Player: Player,
    Part: BasePart,
    Position: Vector3,
    Distance: number,
}

return true
