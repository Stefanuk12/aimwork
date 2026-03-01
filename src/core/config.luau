-- Dependencies
local PlayerObjectTypes = require("@modules/PlayerTracker/PlayerObject")

--- @type ConfigurationTargetLockMode "Unlock" | "Lock"
--- @within Configuration
--- Whether the keybind should lock onto a player, or release a lock.
---
--- 1. For example, if the mode is `"Unlock"`, then Aimwork will automatically lock to the first player it sees.
--- 2. For it to disengage, you must press the bind.
---
--- 3. On the other hand, if the mode is `"Lock"`, then Aimwork will only set the locked player when the bind is pressed.
export type ConfigurationTargetLockMode = "Unlock" | "Lock"

--- @interface ConfigurationTargetLock
--- @within Configuration
--- .Enabled boolean -- Enable the locking behaviour.
--- .LockOnly boolean -- Whether Aimwork should **only** target locked players
--- .Mode ConfigurationTargetLockMode -- Whether the keybind should lock onto a player, or release a lock.
--- .Bind Enum.KeyCode | Enum.UserInputType -- The bind that triggers the (un)lock
--- Lock onto only one player.
export type ConfigurationTargetLock = {
    --- Enable the locking behaviour.
    Enabled: boolean,
    --- Whether Aimwork should **only** target locked players.
    --- In the event that [TargetLock.Enabled] is `false`, or there is no locked player, Aimwork will not select a player at all.
    LockOnly: boolean,
    --- Whether the keybind should lock onto a player, or release a lock.
    ---
    --- For example, if the mode is `"Unlock"`, then Aimwork will automatically lock to the first player it sees.
    --- For it to disengage, you must press the bind.
    ---
    --- On the other hand, if the mode is `"Lock"`, then Aimwork will only set the locked player when the bind is pressed.
    Mode: ConfigurationTargetLockMode,
    --- The bind that triggers the (un)lock.
    Bind: Enum.KeyCode | Enum.UserInputType,
}

--- @type ConfigurationChecksWallCheck "OnScreen" | "Full" | false
--- @within Configuration
--- - `"OnScreen"`: cheap check that ensures the target is on-screen.
--- - `"Full"`: performs a full raycast-based visibility check.
--- - `false`: disable wall checks.
export type ConfigurationChecksWallCheck = "OnScreen" | "Full" | false

--- @interface ConfigurationChecks
--- @within Configuration
--- .ForceField boolean -- Ignore players with an active `ForceField`.
--- .Friend boolean -- Ignore players that are marked as friends.
--- .Dead boolean -- Ignore dead players.
--- .Invisible boolean -- Ignore invisible players.
--- .Ignored boolean -- Respect the [ConfigurationIgnored] configuration lists.
--- .WallCheck ConfigurationChecksWallCheck -- Chooses the visibility/wall-check strategy
export type ConfigurationChecks = {
    --- Ignore players with an active `ForceField`.
    ForceField: boolean,
    --- Ignore players that are marked as friends.
    Friend: boolean,
    --- Ignore dead players.
    Dead: boolean,
    --- Ignore invisible players.
    Invisible: boolean,
    --- Respect the `Ignored` configuration lists.
    Ignored: boolean,
    --- Chooses the visibility/wall-check strategy:
    --- - `"OnScreen"`: cheap check that ensures the target is on-screen.
    --- - `"Full"`: performs a full raycast-based visibility check.
    --- - `false`: disable wall checks.
    WallCheck: ConfigurationChecksWallCheck,
}

--- @type ConfigurationPartFilterType "Allowlist" | "Blocklist"
--- @within Configuration
--- - `"Allowlist"` - only allow these named parts.
--- - `"Blocklist"` - ignore these named parts.
export type ConfigurationPartFilterType = "Allowlist" | "Blocklist"

--- @interface ConfigurationPartFilter
--- @within Configuration
--- .Type ConfigurationPartFilterType -- How the `Name` map is interpreted.
--- .Name { [string]: true } -- Map of part names to `true` used by the filter.
--- Controls which body parts are considered when performing per-part checks.
export type ConfigurationPartFilter = {
    --- How the `Name` map is interpreted: `"Allowlist"` means only named parts are considered; `"Blocklist"` means named parts are ignored.
    Type: ConfigurationPartFilterType,
    --- Map of part names to `true` used by the filter.
    Name: { [string]: true },
}

--- @interface ConfigurationIgnoredAllowlist
--- @within Configuration
--- .Teams boolean -- When `true`, [ConfigurationIgnored.Teams] is treated as a allowlist; when `false`, as a blocklist.
--- .Players boolean -- When `true`, [ConfigurationIgnored.Players] is treated as a allowlist; when `false`, as a blocklist.
--- Nested configuration controlling allowlist behaviour for teams/players.
export type ConfigurationIgnoredAllowlist = {
    --- When `true`, `Ignored.Teams` is treated as a allowlist; when `false`, as a blocklist.
    Teams: boolean,
    --- When `true`, `Ignored.Players` is treated as a allowlist; when `false`, as a blocklist.
    Players: boolean,
}

--- @interface ConfigurationIgnored
--- @within Configuration
--- .IgnoreLocalTeam boolean -- If `true`, players on the local player's team are ignored.
--- .AllowlistEnabledFor ConfigurationIgnoredAllowlist -- Nested configuration controlling allowlist behaviour for teams/players.
--- .Teams { Team } -- Team objects to ignore or allowlist depending on `AllowlistEnabledFor.Teams`.
--- .Players { number | Player } -- Player instances or user IDs to ignore or allowlist depending on `AllowlistEnabledFor.Players`.
--- Global ignore / allowlist configuration used by the `Ignored` checks.
export type ConfigurationIgnored = {
    --- If `true`, players on the local player's team are ignored.
    IgnoreLocalTeam: boolean,

    --- Nested configuration controlling allowlist behaviour for teams/players.
    AllowlistEnabledFor: ConfigurationIgnoredAllowlist,

    --- Team objects to ignore or allowlist depending on `AllowlistEnabledFor.Teams`.
    Teams: { Team },
    --- Player instances or user IDs to ignore or allowlist depending on `AllowlistEnabledFor.Players`.
    Players: { number | Player },
}

--- @class Configuration
--- Top-level configuration used to initialise [Aimwork].
export type Configuration = {
    --- @prop TargetLock ConfigurationTargetLock
    --- @within Configuration
    --- Lock onto only one player.
    TargetLock: ConfigurationTargetLock,
    --- @prop Checks ConfigurationChecks
    --- @within Configuration
    --- Toggle what checks to use.
    Checks: ConfigurationChecks,
    --- @prop PartFilter ConfigurationPartFilter
    --- @within Configuration
    --- Filter for specific body parts to use.
    PartFilter: ConfigurationPartFilter,

    --- @prop Ignored ConfigurationIgnored
    --- @within Configuration
    --- Control which players and teams to ignore.
    Ignored: ConfigurationIgnored,
    --- @prop RaycastIgnore (PlayerObjectTypes.PlayerObject, Camera) -> { Instance }
    --- @within Configuration
    --- Return an array of [Instance]s to ignore when performing raycasts.
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
