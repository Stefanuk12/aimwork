-- // Dependencies
local Configuration = require("@core/config")

local AimworkChecksType = require("@modules/checks")
local AimworkSelectedType = require("@types/selected")

local PlayerObjectTypes = require("@modules/player_object")
local FOVObject = require("@modules/fov_object")

-- // Types
export type AimworkData = {
    Trove: any,
    FOV: FOVObject.FOVObject,
    Checks: AimworkChecksType.Checks,
    Settings: Configuration.Configuration,
    Selected: AimworkSelectedType.AimworkSelected?,
}
export type AimworkMethods = {
    __index: AimworkMethods,
    new: (Configuration.Configuration) -> Aimwork,
    LoadPatch: (self: Aimwork, string) -> (),
    Destroy: (self: Aimwork) -> (),
    IteratePlayer: (self: Aimwork, Player: PlayerObjectTypes.PlayerObject) -> (),
    Iterate: (self: Aimwork) -> (),
}
export type AimworkAll = AimworkData & AimworkMethods
export type Aimwork = typeof(setmetatable({} :: AimworkData, {} :: AimworkMethods))

-- //
return false
