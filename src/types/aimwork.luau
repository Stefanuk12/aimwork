-- // Dependencies
local Configuration = require("@core/config")

local AimworkChecksType = require("@modules/checks")
local AimworkSelectedType = require("@types/selected")

local PlayerObjectTypes = require("@modules/player/object")
local VisualHandler = require("@modules/visuals")

-- // Types
export type AimworkData = {
    Trove: any,
    Checks: AimworkChecksType.Checks,
    Visuals: VisualHandler.VisualHandler,
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
