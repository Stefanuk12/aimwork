-- Dependencies
local Trove = require("@pkgs/trove")
local patches = require("@patches")
local Configuration = require("@core/config")
local AimworkChecks = require("@modules/checks")
local PlayerObjectTypes = require("@modules/PlayerTracker/PlayerObject")
local VisualHandler = require("@modules/VisualHandler")
local FovObject = require("@modules/VisualHandler/FovObject")
local AimworkTypes = require("@types/aimwork")
local AimworkSelectedTypes = require("@types/selected")
local DrawingTypes = require("@types/extra_drawing")
local FovObjectLike = require("@types/fov_object_like")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Vars
local localPlayer = Players.LocalPlayer
local defaultSelected: typeof(table.freeze({} :: AimworkSelectedTypes.AimworkSelected)) = table.freeze({
    player = localPlayer,
    part = Instance.new("Part"),
    position = Vector3.zero,
    distance = math.huge,
})

--[=[
    @class Aimwork

    The main class that handles everything.
]=]
--[=[
    @prop fov FovObject
    @within Aimwork
    The FOV to use.
]=]
--[=[
    @prop checks Checks
    @within Aimwork
    The Checks to use.
]=]
--[=[
    @prop settings Configuration
    @within Aimwork
    The configuration to use.
]=]
--[=[
    @prop selected AimworkSelected
    @within Aimwork
    The current Selected player.
]=]
local Aimwork = {}
Aimwork.DefaultConfiguration = Configuration
Aimwork.__index = Aimwork

-- Types
export type Aimwork = AimworkTypes.Aimwork

--[=[
    Constructs a new [PlayerObject].

    @param settings Configuration
    @tag constructor
]=]
function Aimwork.new(settings: Configuration.Configuration): Aimwork
    local trove = Trove.new()
    local self: AimworkTypes.AimworkData = {
        _trove = trove,

        visuals = trove:Add(VisualHandler.new()),
        checks = trove:Add(AimworkChecks.new(settings)),
        settings = settings,
        selected = table.clone(defaultSelected) :: AimworkSelectedTypes.AimworkSelected,
    }
    return setmetatable(self, Aimwork)
end

--[=[
    Cleans up, then destroys this object.
    > Note that you cannot use this object anymore, it's set to `nil`.

    @tag destructor
]=]
function Aimwork.Destroy(self: Aimwork)
    self._trove:Destroy()
    setmetatable(self :: any, nil)
end

--[=[
    Finishes the initialisation process for [Aimwork], called during [Aimwork.new].
]=]
function Aimwork.Initialise(self: Aimwork)
    local trove = self._trove

    trove:Connect(RunService.Heartbeat, function()
        self:Iterate()
    end)

    trove:Connect(UserInputService.InputEnded, function(inputObject: InputObject, gp: boolean)
        if gp then
            return
        end

        local bind = self.settings.TargetLock.Bind
        if
            typeof(bind) == "EnumItem"
            and (
                (bind:IsA("KeyCode") and inputObject.KeyCode == bind)
                or (bind:IsA("UserInputType") and inputObject.UserInputType == bind)
            )
        then
            self._lockTarget = nil
        end
    end)
end

--[=[
    Register a basic Drawing FOV.
]=]
function Aimwork.RegisterFov(self: Aimwork, flag: string, data: DrawingTypes.DrawingOptionalDataEnum)
    local fovObject = FovObject.new(flag, data)
    self.visuals:Add(fovObject)
    return fovObject
end

--[=[
    Register a custom FOV object.
]=]
function Aimwork.RegisterCustomFov(self: Aimwork, object: FovObjectLike.FovObjectLike)
    self.visuals:Add(object)
end

--[=[
    Attempts to load a custom patch.
]=]
function Aimwork.LoadPatch(self: Aimwork, patchName: string)
    local patch = patches[patchName]
    assert(typeof(patch) == "function", "could not find specified patch")
    patch(self)
end

--[=[
    Processes a [Player] to check if they can be processed, i.e. don't process dead players.

    @param player PlayerObject
]=]
function Aimwork.IteratePlayer(self: Aimwork, player: PlayerObjectTypes.PlayerObject)
    -- Ignore our LocalPlayer
    if player.instance == localPlayer then
        return
    end

    -- Perform initial Player checks, that we can do, based upon the Player alone
    if not self.checks:PlayerCheck(player) then
        return
    end

    -- Perform part checks
    local partFilter = self.settings.PartFilter
    local partFilerName = partFilter.Name
    for _, bodyPart in ipairs(player.bodyParts) do
        local name = bodyPart.Name
        if
            (partFilter.Type == "Allowlist" and not partFilerName[name])
            or (partFilter.Type == "Blocklist" and partFilerName[name])
        then
            continue
        end

        self.checks:PartChecks(player, bodyPart, self.visuals.objects, self.selected)
    end
end

--[=[
    Processes all [PlayerObject]s inside of the [PlayerTracker].
]=]
function Aimwork.Iterate(self: Aimwork)
    -- Reset Selected
    for i, v in defaultSelected :: any do -- LUAU TYPE SOLVER ISSUE
        (self.selected :: any)[i] = v -- LUAU TYPE SOLVER ISSUE
    end

    -- Update FOV positions
    self.visuals:Update()

    -- We are locked onto someone
    if self.settings.TargetLock.Enabled and self._lockTarget then
        self:IteratePlayer(self._lockTarget)
        return
    end

    -- Iterate through all players
    for _, player in ipairs(self.checks.playerTracker.players) do
        self:IteratePlayer(player)
    end

    -- Check if we got a target
    if self.settings.TargetLock.Enabled and not self._lockTarget and self.selected.player ~= localPlayer then
        local _, playerObject = self.checks.playerTracker:GetFromInstance(self.selected.player)
        if playerObject then
            self._lockTarget = playerObject
        end
    end
end

return Aimwork
