-- Dependencies
local Configuration = require("@core/config")
local Trove = require("@pkgs/trove")

local AimworkChecksType = require("@modules/checks")
local AimworkSelectedType = require("@types/selected")

local PlayerObjectTypes = require("@modules/PlayerTracker/PlayerObject")
local VisualHandler = require("@modules/VisualHandler")
local FovObject = require("@modules/VisualHandler/FovObject")
local FovObjectLike = require("@types/fov_object_like")
local DrawingTypes = require("@types/extra_drawing")

-- Types
export type AimworkData = {
    _trove: Trove.Trove,
    _lockTarget: PlayerObjectTypes.PlayerObject?,

    checks: AimworkChecksType.Checks,
    visuals: VisualHandler.VisualHandler,
    settings: Configuration.Configuration,
    selected: AimworkSelectedType.AimworkSelected,
}
export type AimworkObject = {
    __index: AimworkObject,
    DefaultConfiguration: Configuration.Configuration,
    new: (Configuration.Configuration) -> Aimwork,
    Destroy: (self: Aimwork) -> (),
    Initialise: (self: Aimwork) -> (),
    LockTarget: (self: Aimwork) -> (),
    RegisterFov: (self: Aimwork, flag: string, data: DrawingTypes.DrawingOptionalDataEnum) -> FovObject.FovObject,
    RegisterCustomFov: (self: Aimwork, object: FovObjectLike.FovObjectLike) -> (),
    LoadPatch: (self: Aimwork, patchName: string) -> (),
    IteratePlayer: (self: Aimwork, Player: PlayerObjectTypes.PlayerObject) -> (),
    Iterate: (self: Aimwork) -> (),
}
export type Aimwork = setmetatable<AimworkData, AimworkObject>

--
return false
