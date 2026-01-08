-- Dependencies
local DrawingTypes = require("@types/extra_drawing")
local PlayerObjectTypes = require("@modules/PlayerTracker/PlayerObject")

--
export type Configuration = {
    Checks: {
        ForceField: boolean,
        Friend: boolean,
        Health: boolean,
        Invisible: boolean,
        Ignored: boolean,
        WallCheck: "OnScreen" | "Full" | false,
    },

    FOVSettings: DrawingTypes.DrawingOptionalDataEnum,

    Ignored: {
        IgnoreLocalTeam: boolean,

        Whitelist: {
            Teams: boolean,
            Players: boolean,
        },

        Teams: { Team },
        Players: { number | Player },
    },
    RaycastIgnore: (PlayerObjectTypes.PlayerObject, Camera) -> { Instance },
}
local Configuration: Configuration = {
    Checks = {
        ForceField = true,
        Friend = true,
        Health = true,
        Invisible = true,
        Ignored = true,
        WallCheck = "Full",
    },

    FOVSettings = {
        Kind = "Circle",
        Value = {
            Visible = true,
            Thickness = 1,
            Radius = 60,
            Color = Color3.fromRGB(231, 84, 128),
        } :: DrawingTypes.DrawingCircleOptionalData,
    },

    Ignored = {
        IgnoreLocalTeam = true,
        Whitelist = {
            Teams = false,
            Players = false,
        },
        Teams = {},
        Players = {},
    },
    RaycastIgnore = function(player: PlayerObjectTypes.PlayerObject, camera: Camera)
        local ignored: { Instance } = { camera }

        if player.character then
            table.insert(ignored, player.character)
        end

        return ignored
    end,
}

return Configuration
