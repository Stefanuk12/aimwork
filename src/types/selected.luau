--[=[
    @interface AimworkSelected
    @within Aimwork
    .player Player -- The current selected [Player]. Note that if this is equal to [Players.LocalPlayer], then there is not a selected player.
    .part BasePart -- The closest part to the cursor inside of the [Player.Character].
    .position Vector3 -- The [Part.Position] of the closest part.
    .distance number -- The on screen distance from the cursor to the on screen [Part.Position] of the closest part.
]=]
export type AimworkSelected = {
    player: Player,
    part: BasePart,
    position: Vector3,
    distance: number,
}

return true
