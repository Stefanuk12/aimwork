-- Dependencies
local PlayerObjectTypes = require("@modules/PlayerTracker/PlayerObject")

--- @prop TargetLock
--- @within Configuration
--- Only target a specific player.
export type ConfigurationTargetLock = {
    --- @prop Enabled
    --- @within ConfigurationTargetLock
    --- Enable the locking behaviour.
    Enabled: boolean,
    --- @prop LockOnly
    --- @within ConfigurationTargetLock
    --- Whether Aimwork should **only** target locked players.
    --- In the event that [TargetLock.Enabled] is `false`, or there is no locked player, Aimwork will not select a player at all.
    LockOnly: boolean,
    --- @prop Mode
    --- @within ConfigurationTargetLock
    --- Whether the keybind should lock onto a player, or release a lock.
    ---
    --- For example, if the mode is `"Unlock"`, then Aimwork will automatically lock to the first player it sees.
    --- For it to disengage, you must press the bind.
    ---
    --- On the other hand, if the mode is `"Lock"`, then Aimwork will only set the locked player when the bind is pressed.
    Mode: "Unlock" | "Lock",
    --- @prop Mode
    --- @within ConfigurationTargetLock
    --- The bind that triggers the (un)lock.
    Bind: Enum.KeyCode | Enum.UserInputType,
}

export type ConfigurationChecksWallCheck = "OnScreen" | "Full" | false
export type ConfigurationChecks = {
    --- @prop ForceField
    --- @within ConfigurationChecks
    --- Ignore players with an active `ForceField`.
    ForceField: boolean,
    --- @prop Friend
    --- @within ConfigurationChecks
    --- Ignore players that are marked as friends.
    Friend: boolean,
    --- @prop Dead
    --- @within ConfigurationChecks
    --- Ignore dead players.
    Dead: boolean,
    --- @prop Invisible
    --- @within ConfigurationChecks
    --- Ignore invisible players.
    Invisible: boolean,
    --- @prop Ignored
    --- @within ConfigurationChecks
    --- Respect the `Ignored` configuration lists.
    Ignored: boolean,
    --- @prop WallCheck
    --- @within ConfigurationChecks
    --- Chooses the visibility/wall-check strategy:
    --- - `"OnScreen"`: cheap check that ensures the target is on-screen.
    --- - `"Full"`: performs a full raycast-based visibility check.
    --- - `false`: disable wall checks.
    WallCheck: ConfigurationChecksWallCheck,
}

export type ConfigurationPartFilterType = "Allowlist" | "Blocklist"
--- @prop PartFilter
--- @within Configuration
--- Controls which body parts are considered when performing per-part checks.
export type ConfigurationPartFilter = {
    --- @prop Type
    --- @within ConfigurationPartFilter
    --- How the `Name` map is interpreted: `"Allowlist"` means only named parts are considered; `"Blocklist"` means named parts are ignored.
    Type: ConfigurationPartFilterType,
    --- @prop Name
    --- @within ConfigurationPartFilter
    --- Map of part names to `true` used by the filter.
    Name: { [string]: true },
}

--- @prop AllowlistEnabledFor
--- @within ConfigurationIgnored
--- Nested configuration controlling allowlist behaviour for teams/players.
export type ConfigurationIgnoredAllowlist = {
    --- @prop Teams
    --- @within ConfigurationIgnoredAllowlist
    --- When `true`, `Ignored.Teams` is treated as a allowlist; when `false`, as a blocklist.
    Teams: boolean,
    --- @prop Players
    --- @within ConfigurationIgnoredAllowlist
    --- When `true`, `Ignored.Players` is treated as a allowlist; when `false`, as a blocklist.
    Players: boolean,
}
--- @prop Ignored
--- @within Configuration
--- Global ignore / allowlist configuration used by the `Ignored` checks.
export type ConfigurationIgnored = {
    --- @prop IgnoreLocalTeam
    --- @within ConfigurationIgnored
    --- If `true`, players on the local player's team are ignored.
    IgnoreLocalTeam: boolean,

    --- @prop AllowlistEnabledFor
    --- @within ConfigurationIgnored
    --- Nested configuration controlling allowlist behaviour for teams/players.
    AllowlistEnabledFor: ConfigurationIgnoredAllowlist,

    --- @prop Teams
    --- @within ConfigurationIgnored
    --- Team objects to ignore or allowlist depending on `AllowlistEnabledFor.Teams`.
    Teams: { Team },
    --- @prop Players
    --- @within ConfigurationIgnored
    --- Player instances or user IDs to ignore or allowlist depending on `AllowlistEnabledFor.Players`.
    Players: { number | Player },
}

--- @prop Configuration
--- Top-level configuration used to initialise `Aimwork`.
---
--- `RaycastIgnore` should return an array of `Instance`s to ignore when performing raycasts.
export type Configuration = {
    TargetLock: ConfigurationTargetLock,
    Checks: ConfigurationChecks,
    PartFilter: ConfigurationPartFilter,

    Ignored: ConfigurationIgnored,
    RaycastIgnore: (PlayerObjectTypes.PlayerObject, Camera) -> { Instance },
}

local Configuration: Configuration = {
    TargetLock = {
        Enabled = false,
        LockOnly = false,
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
        AllowlistEnabledFor = {
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
