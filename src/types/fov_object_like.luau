export type FovObjectLikeData = {
    id: string,
}

export type FovObjectLikeBase = FovObjectLikeData & {
    Destroy: (self: FovObjectLikeBase) -> (),
    Update: (self: FovObjectLikeBase) -> (),
    InsideFOV: (self: FovObjectLikeBase, position: Vector2) -> (boolean, number?),
}

export type FovObjectLikeMetatable = typeof(setmetatable(
    {},
    {} :: FovObjectLikeData & {
        Destroy: (self: FovObjectLikeMetatable) -> (),
        Update: (self: FovObjectLikeMetatable) -> (),
        InsideFOV: (self: FovObjectLikeMetatable, position: Vector2) -> (boolean, number?),
    }
))

export type FovObjectLike = FovObjectLikeBase | FovObjectLikeMetatable

return nil
