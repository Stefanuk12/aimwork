-- Dependencies
local TroveBuilder = require("@pkgs/trove")
local Patches = require("@patches")

local Configuration = require("@core/config")

local PlayerObjectTypes = require("@modules/player/object")
local AimworkSelectedType = require("@types/selected")

local FOVObject = require("@modules/visuals/fov_object")
local AimworkChecks = require("@modules/checks")

local VisualHandler = require("@modules/visuals")

local AimworkTypes = require("@types/aimwork")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Vars
local LocalPlayer = Players.LocalPlayer
local DefaultSelected: AimworkSelectedType.AimworkSelected = {
    Player = LocalPlayer,
    Part = Instance.new("Part"),
    Position = Vector3.zero,
    Distance = math.huge,
}

--
--[=[
    @class Aimwork

    The main class that handles everything.
]=]
--[=[
    @prop FOV FOVObject
    @within Aimwork
    The FOV to use.
]=]
--[=[
    @prop Checks Checks
    @within Aimwork
    The Checks to use.
]=]
--[=[
    @prop Settings Configuration
    @within Aimwork
    The configuration to use.
]=]
--[=[
    @prop Selected AimworkSelected
    @within Aimwork
    The current Selected player.
]=]
local Aimwork = {}
Aimwork.__index = Aimwork
type Aimwork = AimworkTypes.Aimwork
do
    Aimwork.DefaultConfiguration = Configuration

    --[=[
        Constructs a new [PlayerObject].

        @param Settings Configuration
        @tag constructor
    ]=]
    function Aimwork.new(Settings: Configuration.Configuration): Aimwork
        -- Create the object
        local self: AimworkTypes.AimworkData = {
            Trove = TroveBuilder.new(),
            Visuals = VisualHandler.new(),
            Checks = AimworkChecks.new(Settings),
            Settings = Settings,
            Selected = nil,
        }
        self = setmetatable(self, Aimwork)

        self.Visuals:Add(FOVObject.new("Main", Settings.FOVSettings) :: any)

        -- Return the object
        return self :: any -- LUAU TYPE SOLVER ISSUE
    end

    --[=[
        Finishes the initialisation process for [Aimwork], called during [Aimwork.new].
    ]=]
    function Aimwork.Initialise(self: Aimwork)
        local Trove = self.Trove
        Trove:Add(RunService.Heartbeat:Connect(function()
            self:Iterate()
        end))
    end

    --[=[
        Cleans up, then destroys this object.
        > Note that you cannot use this object anymore, it's set to `nil`.

        @tag destructor
    ]=]
    function Aimwork.Destroy(self: Aimwork)
        self.Visuals:Destroy()
        self.Checks:Destroy()
        self.Trove:Destroy()
        setmetatable(self :: any, nil)
    end

    --[=[
        Attempts to load a custom patch.
    ]=]
    function Aimwork.LoadPatch(self: Aimwork, PatchName: string)
        local Patch = Patches[PatchName]
        assert(typeof(Patch) == "function", "could not find specified patch")
        Patch(self)
    end

    --[=[
        Processes a [Player] to check if they can be processed, i.e. don't process dead players.

        @param Player PlayerObject
    ]=]
    function Aimwork.IteratePlayer(self: Aimwork, Player: PlayerObjectTypes.PlayerObject)
        -- Ignore our LocalPlayer
        if Player.Instance == LocalPlayer then
            return
        end

        -- Perform initial Player checks, that we can do, based upon the Player alone
        if not self.Checks:PlayerCheck(Player) then
            return
        end

        -- Perform part checks
        for _, v in ipairs(Player.BodyParts) do
            self.Checks:PartChecks(Player, v, self.Visuals.Objects, self.Selected :: any)
        end
    end

    --[=[
        Processes all [PlayerObject]s inside of the [PlayerTracker].
    ]=]
    function Aimwork.Iterate(self: Aimwork)
        -- Reset Selected
        if self.Selected then
            for i, v in pairs(DefaultSelected :: any) do -- LUAU TYPE SOLVER ISSUE
                (self.Selected :: any)[i] = v -- LUAU TYPE SOLVER ISSUE
            end
        else
            self.Selected = table.clone(DefaultSelected)
        end

        -- Update FOV positions
        self.Visuals:Update()

        -- Iterate through all players
        for _, v in ipairs(self.Checks.PlayerTracker.Players) do
            self:IteratePlayer(v)
        end
    end
end

--
return Aimwork
