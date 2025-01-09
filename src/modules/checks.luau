-- // Dependencies
local ConfigurationDef = require("@core/config")
local Functions = require("@functions")
local PlayerTracker = require("@modules/player/tracker")
local PlayerObjectTypes = require("@modules/player/object")
local FOVObjectTypes = require("@modules/visuals/fov_object")
local AimworkSelectedType = require("@types/selected")

-- // Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- // Vars
local LocalPlayer = Players.LocalPlayer

-- // Types
type PlayerObject = PlayerObjectTypes.PlayerObject

--[=[
    @class Checks

    Handles any Aimwork checks to check if we can target a specific [Player]/[Part].
]=]
--[=[
    @prop PlayerTracker PlayerTracker
    @within Checks
    Used internally to track the status of all [Player]s
]=]
--[=[
    @prop FOV FOVObject
    @within Checks
    Holds all FOV-related data, including methods that help with checking if a [Vector2] point in inside of the FOV.
]=]
--[=[
    @prop Configuration Configuration
    @within Checks
    Contains the entire configuration, however, only certain parts are used.
]=]
local Checks = {}
Checks.__index = Checks
export type ChecksData = {
    PlayerTracker: PlayerTracker.PlayerTracker,
    FOV: FOVObjectTypes.FOVObject,
    Configuration: ConfigurationDef.Configuration,
}
export type Checks = typeof(setmetatable({} :: ChecksData, Checks))
do
    --[=[
        Constructs a new [Checks] object.

        @param FOV FOVObject
        @param Config Configuration
        @tag constructor
    ]=]
    function Checks.new(FOV: FOVObjectTypes.FOVObject, Config: ConfigurationDef.Configuration): Checks
        -- // Create the object
        local self = setmetatable({}, Checks)

        -- // Initialise properties
        self.Configuration = Config
        self.FOV = FOV
        self.PlayerTracker = PlayerTracker.new()

        -- // Return the object
        return self
    end

    --[=[
        Cleans up, then destroys this object.
        > Note that you cannot use this object anymore, it's set to `nil`.

        @tag destructor
    ]=]
    function Checks.Destroy(self: Checks)
        self.PlayerTracker:Destroy()
        setmetatable(self :: any, nil)
    end
    --[=[
        Returns `true` if the [Player] has a [ForceField].

        @param Player PlayerObject -- The player you want to check
    ]=]
    function Checks.ForceField(_self: Checks, Player: PlayerObject)
        return Player.ForceField
    end
    --[=[
        Returns `true` if the [Player] is a friend to the [Player.LocalPlayer].

        @param Player PlayerObject -- The player you want to check
    ]=]
    function Checks.Friend(_self: Checks, Player: PlayerObject)
        return Player.Friend
    end
    --[=[
        Returns `true` if the `Player` has a health **above** 0.

        @param Player PlayerObject -- The player you want to check
    ]=]
    function Checks.Health(_self: Checks, Player: PlayerObject)
        return Player.Health > 0
    end
    --[=[
        Returns `true` if the [Part.Transparency] property is equal to `1` (invisible).

        @param Part BasePart -- The part you want to check
    ]=]
    function Checks.Invisible(_self: Checks, Part: BasePart)
        return Part.Transparency == 1
    end
    --[=[
        Returns `true` if the `Player`'s [Team] is the same as the [Players.LocalPlayer]'s [Team].

        @param Player PlayerObject -- The player you want to check
    ]=]
    function Checks.TeamPlayer(_self: Checks, Player: PlayerObject)
        return Player.Instance.Team == LocalPlayer.Team
    end

    --[=[
        Returns `true` if the `Player` is "ignored" within the configuration.

        @param Player PlayerObject -- The player you want to check
    ]=]
    function Checks.IgnoredPlayer(self: Checks, Player: PlayerObject)
        local WhitelistMode = self.Configuration.Ignored.Whitelist
        for _, v in ipairs(self.Configuration.Ignored.Players) do
            local vType = typeof(v)

            if (vType == "Instance" and Player.Instance == v) or (vType == "number" and Player.Instance.UserId) then
                return not WhitelistMode.Players
            end
        end

        return false
    end
    --[=[
        Returns `true` if the `Player`'s team is "ignored" within the configuration.

        @param Player PlayerObject -- The player you want to check
    ]=]
    function Checks.IgnoredTeam(self: Checks, Player: PlayerObject)
        local WhitelistMode = self.Configuration.Ignored.Whitelist
        local Team = Player.Instance.Team
        for _, v in ipairs(self.Configuration.Ignored.Teams) do
            if Team == v then
                return not WhitelistMode.Teams
            end
        end

        return false
    end
    --[=[
        Returns `true` if the `Player` and their team is ignored within the configuration.

        @param Player PlayerObject -- The player you want to check
    ]=]
    function Checks.Ignored(self: Checks, Player: PlayerObject)
        local Ignored = self.Configuration.Ignored
        return (Ignored.IgnoreLocalTeam and self:TeamPlayer(Player))
            or self:IgnoredTeam(Player)
            or self:IgnoredPlayer(Player)
    end
    --[=[
        Checks if the `Part` is visible, if a ray was fired from our [Camera]'s position.

        @param PartAncestor Instance -- Used to ensure the `Part` hit is apart of the `Player`
    ]=]
    function Checks.WallHit(
        self: Checks,
        Player: PlayerObject,
        Part: BasePart,
        PartAncestor: Instance,
        CurrentCamera: Camera
    )
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = self.Configuration.RaycastIgnore(Player, CurrentCamera)

        local Origin = CurrentCamera.CFrame.Position
        local Direction = Part.Position - Origin
        local raycastResult = Workspace:Raycast(Origin, Direction, raycastParams)
        if not raycastResult then
            return true
        end

        local PartHit = raycastResult.Instance
        return PartHit ~= Part or not PartAncestor:IsAncestorOf(PartHit)
    end

    --[=[
        Returns `true` if the Player is valid.

        @param Player PlayerObject -- The player you want to check
    ]=]
    function Checks.PlayerCheck(self: Checks, Player: PlayerObject): boolean
        local Configuration = self.Configuration.Checks

        return not (
            (Configuration.ForceField and self:ForceField(Player))
            or (Configuration.Friend and self:Friend(Player))
            or (Configuration.Health and self:Health(Player))
        )
    end
    --[=[
        Performs all the necessary checks and calculations for the `Part`, setting the properties inside of `Selected`, if it's a valid `Part` as determined by previous checks.
    
        @param Selected AimworkSelected
    ]=]
    function Checks.PartChecks(
        self: Checks,
        Player: PlayerObject,
        Part: BasePart,
        Selected: AimworkSelectedType.AimworkSelected
    )
        local Configuration = self.Configuration.Checks
        if Configuration.Invisible and self:Invisible(Part) then
            return
        end

        local CurrentCamera = Functions.GetCurrentCamera()
        local ScreenPosition, OnScreen = CurrentCamera:WorldToViewportPoint(Part.Position)
        if Configuration.WallCheck and not OnScreen then
            return
        end

        local ScreenPosition2D = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
        local Distance = self.FOV:InsideFOV(ScreenPosition2D)

        if
            (not Distance or Distance < Selected.Distance)
            or (
                Configuration.WallCheck == "Full"
                and self:WallHit(Player, Part, Player.Character :: any, CurrentCamera)
            )
        then
            return
        end

        Selected.Part = Part
        Selected.Player = Player.Instance
        Selected.Position = Part.Position
        Selected.Distance = Distance
    end
end

return Checks
