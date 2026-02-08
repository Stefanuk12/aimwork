-- Dependencies
local ConfigurationDef = require("@core/config")
local PlayerTracker = require("@modules/PlayerTracker")
local PlayerObjectTypes = require("@modules/PlayerTracker/PlayerObject")
local VisualHandlerTypes = require("@modules/VisualHandler")
local getCurrentCamera = require("@functions/getCurrentCamera")
local AimworkSelectedType = require("@types/selected")

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Vars
local localPlayer = Players.LocalPlayer

--[=[
    @class Checks

    Handles any Aimwork checks to check if we can target a specific [Player]/[Part].
]=]
--[=[
    @prop playerTracker PlayerTracker
    @within Checks
    Used internally to track the status of all [Player]s
]=]
--[=[
    @prop configuration Configuration
    @within Checks
    Contains the entire configuration, however, only certain parts are used.
]=]
local Checks = {}
Checks.__index = Checks

-- Types
type PlayerObject = PlayerObjectTypes.PlayerObject

export type ChecksData = {
    playerTracker: PlayerTracker.PlayerTracker,
    configuration: ConfigurationDef.Configuration,
}
export type Checks = setmetatable<ChecksData, typeof(Checks)>

--[=[
    Constructs a new [Checks] object.

    @param configuration Configuration
    @tag constructor
]=]
function Checks.new(configuration: ConfigurationDef.Configuration): Checks
    local self: ChecksData = {
        playerTracker = PlayerTracker.new(),
        configuration = configuration,
    }
    return setmetatable(self, Checks)
end

--[=[
    Cleans up, then destroys this object.
    > Note that you cannot use this object anymore, it's set to `nil`.

    @tag destructor
]=]
function Checks.Destroy(self: Checks)
    self.playerTracker:Destroy()
    setmetatable(self :: any, nil)
end

--[=[
    Returns `true` if the [Player] has a [ForceField].

    @param player PlayerObject -- The player you want to check
]=]
function Checks.ForceField(_self: Checks, player: PlayerObject)
    return player.forceField
end

--[=[
    Returns `true` if the [Player] is a friend to the [Player.LocalPlayer].

    @param player PlayerObject -- The player you want to check
]=]
function Checks.Friend(_self: Checks, player: PlayerObject)
    return player.friend
end

--[=[
    Returns `true` if the `Player` has a health **above** 0.

    @param player PlayerObject -- The player you want to check
]=]
function Checks.Health(_self: Checks, player: PlayerObject)
    return player.health > 0
end

--[=[
    Returns `true` if the [Part.Transparency] property is equal to `1` (invisible).

    @param part BasePart -- The part you want to check
]=]
function Checks.Invisible(_self: Checks, part: BasePart)
    return part.Transparency == 1
end

--[=[
    Returns `true` if the `Player`'s [Team] is the same as the [Players.LocalPlayer]'s [Team].

    @param player PlayerObject -- The player you want to check
]=]
function Checks.TeamPlayer(_self: Checks, player: PlayerObject)
    return player.instance.Team == localPlayer.Team
end

--[=[
    Returns `true` if the `Player` is "ignored" within the configuration.

    @param player PlayerObject -- The player you want to check
]=]
function Checks.IgnoredPlayer(self: Checks, player: PlayerObject)
    local mode = self.configuration.Ignored.Whitelist

    for _, ignoredPlayer in ipairs(self.configuration.Ignored.Players) do
        local playerType = typeof(ignoredPlayer)

        if
            (playerType == "Instance" and player.instance == ignoredPlayer)
            or (playerType == "number" and player.instance.UserId)
        then
            return not mode.Players
        end
    end

    return false
end

--[=[
    Returns `true` if the `Player`'s team is "ignored" within the configuration.

    @param player PlayerObject -- The player you want to check
]=]
function Checks.IgnoredTeam(self: Checks, player: PlayerObject)
    local mode = self.configuration.Ignored.Whitelist
    local ourTeam = player.instance.Team

    for _, ignoredTeam in ipairs(self.configuration.Ignored.Teams) do
        if ourTeam == ignoredTeam then
            return not mode.Teams
        end
    end

    return false
end

--[=[
    Returns `true` if the `Player` and their team is ignored within the configuration.

    @param player PlayerObject -- The player you want to check
]=]
function Checks.Ignored(self: Checks, player: PlayerObject)
    local ignored = self.configuration.Ignored

    return (ignored.IgnoreLocalTeam and self:TeamPlayer(player))
        or self:IgnoredTeam(player)
        or self:IgnoredPlayer(player)
end

--[=[
    Checks if the `Part` is visible, if a ray was fired from our [Camera]'s position.

    @param partAncestor Instance -- Used to ensure the `Part` hit is apart of the `Player`
]=]
function Checks.WallHit(self: Checks, part: BasePart, partAncestor: Instance, currentCamera: Camera)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances =
        self.configuration.RaycastIgnore(self.playerTracker.localPlayer, currentCamera)

    local origin = currentCamera.CFrame.Position
    local direction = part.Position - origin
    local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
    if not raycastResult then
        return true
    end

    local partHit = raycastResult.Instance
    print(partHit:GetFullName())
    return partHit ~= part or not partAncestor:IsAncestorOf(partHit)
end

--[=[
    Returns `true` if the Player is valid.

    @param player PlayerObject -- The player you want to check
]=]
function Checks.PlayerCheck(self: Checks, player: PlayerObject): boolean
    local configuration = self.configuration.Checks

    return not (
        (configuration.ForceField and self:ForceField(player))
        or (configuration.Friend and self:Friend(player))
        or (configuration.Health and self:Health(player))
    )
end

--[=[
    Performs all the necessary checks and calculations for the `Part`, setting the properties inside of `Selected`, if it's a valid `Part` as determined by previous checks.

    @param selected AimworkSelected
]=]
function Checks.PartChecks(
    self: Checks,
    player: PlayerObject,
    part: BasePart,
    fovs: { [VisualHandlerTypes.FOVPrimative]: VisualHandlerTypes.AdditionalFOVData },
    selected: AimworkSelectedType.AimworkSelected
)
    local configuration = self.configuration.Checks
    if configuration.Invisible and self:Invisible(part) then
        return
    end

    local currentCamera = getCurrentCamera()
    local screenPosition, isOnScreen = currentCamera:WorldToViewportPoint(part.Position)
    if configuration.WallCheck and not isOnScreen then
        return
    end

    local screen2D = Vector2.new(screenPosition.X, screenPosition.Y)
    local distance = selected.distance
    for fov, data in pairs(fovs) do
        if not data.check then
            continue
        end

        local insideFov, distanceToFov = fov:InsideFOV(screen2D)
        if
            not insideFov
            or ((distanceToFov or math.huge) > distance)
            or (configuration.WallCheck == "Full" and self:WallHit(part, player.character :: any, currentCamera))
        then
            continue
        end

        distance = distanceToFov
    end

    if not distance or distance == math.huge then
        return
    end

    selected.part = part
    selected.player = player.instance
    selected.position = part.Position
    selected.distance = distance
end

return Checks
