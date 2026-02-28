-- Dependencies
local PlayerObjectTypes = require("@modules/PlayerTracker/PlayerObject")

--
export type Configuration = {
    TargetLock: {
        Enabled: boolean,
        Mode: "Unlock" | "Lock",
        Bind: Enum.KeyCode | Enum.UserInputType,
    },

    Checks: {
        ForceField: boolean,
        Friend: boolean,
        Dead: boolean,
        Invisible: boolean,
        Ignored: boolean,
        WallCheck: "OnScreen" | "Full" | false,
    },

    PartFilter: {
        Type: "Allowlist" | "Blocklist",
        Name: { [string]: true },
    },

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
    TargetLock = {
        Enabled = false,
        Mode = "Lock",
        Bind = Enum.KeyCode.F1,
    },

    Checks = {
        ForceField = true,
        Friend = true,
        Dead = true,
        Invisible = true,
        Ignored = true,
        WallCheck = "Full",
    },

    PartFilter = {
        Type = "Blocklist",
        Name = {},
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
