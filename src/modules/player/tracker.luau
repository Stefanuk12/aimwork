-- Dependencies
local TroveBuilder = require("@pkgs/trove")
local PlayerObject = require("./object")

-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

--
--[=[
    @class PlayerTracker

    Tracks all [Player]s in the game via [PlayerObject].
]=]
--[=[
    @prop Players { PlayerObject }
    @within PlayerTracker
    All the associated [PlayerObject]s that are being tracked.
]=]
local PlayerTracker = {}
PlayerTracker.__index = PlayerTracker
export type PlayerTrackerData = {
    Trove: any,
    Players: { PlayerObject.PlayerObject },
}
export type PlayerTracker = typeof(setmetatable({} :: PlayerTrackerData, PlayerTracker))
do
    --[=[
        Constructs a new [PlayerTracker].

        @tag constructor
    ]=]
    function PlayerTracker.new(): PlayerTracker
        -- Create the object
        local self = setmetatable({}, PlayerTracker)

        -- Initialise properties
        self.Trove = TroveBuilder.new()
        self.Players = {}

        -- Complete initialisation
        self:Initialise()

        -- Return the object
        return self
    end

    --[=[
        Finishes the initialisation process for [PlayerTracker], called during [PlayerTracker.new].
    ]=]
    function PlayerTracker.Initialise(self: PlayerTracker)
        for _, v in ipairs(Players:GetPlayers()) do
            self:OnPlayerAdded(v)
        end

        local Trove = self.Trove
        Trove:Add(Players.PlayerAdded:Connect(function(Player)
            self:OnPlayerAdded(Player)
        end))
        Trove:Add(Players.PlayerRemoving:Connect(function(Player)
            self:OnPlayerRemoved(Player)
        end))
        Trove:Add(StarterGui:GetCore("PlayerFriendedEvent"):Connect(function(Player)
            local _, v = self:GetFromInstance(Player)
            if not v then
                return
            end

            v.Friend = true
        end))
        Trove:Add(StarterGui:GetCore("PlayerUnfriendedEvent"):Connect(function(Player)
            local _, v = self:GetFromInstance(Player)
            if not v then
                return
            end

            v.Friend = false
        end))
    end

    --[=[
        Cleans up, then destroys this object.
        > Note that you cannot use this object anymore, it's set to `nil`.

        @tag destructor
    ]=]
    function PlayerTracker.Destroy(self: PlayerTracker)
        self.Trove:Destroy()
        setmetatable(self :: any, self)
    end

    --[=[
        Get a [PlayerObject] from the stored [PlayerTracker.Players].

        @return (number?, PlayerObject?) -- The index and value of the [PlayerObject] inside of [PlayerTracker.Players], if it exists.
    ]=]
    function PlayerTracker.GetFromInstance(self: PlayerTracker, Player: Player): (number?, PlayerObject.PlayerObject?)
        for i, v in ipairs(self.Players) do
            if v.Instance == Player then
                return i, v
            end
        end

        return nil, nil
    end

    --[=[
        Ran when a new [Player] joins the game. It starts tracking them and adds them to [PlayerTracker.Players].
    ]=]
    function PlayerTracker.OnPlayerAdded(self: PlayerTracker, Player: Player)
        if self:GetFromInstance(Player) then
            return
        end

        local Object = PlayerObject.new(Player)
        table.insert(self.Players, Object)
    end

    --[=[
        Ran when a [Player] leaves the game, cleaning up their [PlayerObject] and removing them from [PlayerTracker.Players].
    ]=]
    function PlayerTracker.OnPlayerRemoved(self: PlayerTracker, Player: Player)
        local i = self:GetFromInstance(Player)
        if not i then
            return
        end

        table.remove(self.Players, i)
    end
end

--
return PlayerTracker
