-- // Dependencies
local AimworkTypes = require("@types/aimwork")

-- // Types
export type Patch = (AimworkTypes.Aimwork) -> ()

-- // Load each patch in, with it's name
return {
    Example = require("./example"),
} :: { [string]: Patch }
