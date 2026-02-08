-- Dependencies
local TroveBuilder = require("@pkgs/trove")
local PlayerObject = require("@self/PlayerObject")

-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

--[=[
    @class PlayerTracker

    Tracks all [Player]s in the game via [PlayerObject].
]=]
--[=[
    @prop players { PlayerObject }
    @within PlayerTracker
    All the associated [PlayerObject]s that are being tracked.
]=]
local PlayerTracker = {}
PlayerTracker.__index = PlayerTracker

-- Types
export type PlayerTrackerData = {
    _trove: any,
    players: { PlayerObject.PlayerObject },
}
export type PlayerTracker = setmetatable<PlayerTrackerData, typeof(PlayerTracker)>

--[=[
    Constructs a new [PlayerTracker].

    @tag constructor
]=]
function PlayerTracker.new(): PlayerTracker
    -- Create the object
    local self: PlayerTrackerData = {
        _trove = TroveBuilder.new(),
        players = {},
    }
    self = setmetatable(self, PlayerTracker)

    -- Complete initialisation
    self:Initialise()

    -- Return the object
    return self
end

--[=[
    Finishes the initialisation process for [PlayerTracker], called during [PlayerTracker.new].
]=]
function PlayerTracker.Initialise(self: PlayerTracker)
    for _, player in ipairs(Players:GetPlayers()) do
        self:OnPlayerAdded(player)
    end

    local trove = self._trove
    trove:Connect(Players.PlayerAdded, function(Player: Player)
        self:OnPlayerAdded(Player)
    end)
    trove:Connect(Players.PlayerRemoving, function(Player: Player)
        self:OnPlayerRemoved(Player)
    end)
    trove:Connect(StarterGui:GetCore("PlayerFriendedEvent"), function(Player: Player)
        local _, player = self:GetFromInstance(Player)
        if not player then
            return
        end

        player.friend = true
    end)
    trove:Connect(StarterGui:GetCore("PlayerUnfriendedEvent"), function(Player: Player)
        local _, player = self:GetFromInstance(Player)
        if not player then
            return
        end

        player.friend = false
    end)
end

--[=[
    Cleans up, then destroys this object.
    > Note that you cannot use this object anymore, it's set to `nil`.

    @tag destructor
]=]
function PlayerTracker.Destroy(self: PlayerTracker)
    self._trove:Destroy()
    setmetatable(self :: any, self)
end

--[=[
    Get a [PlayerObject] from the stored [PlayerTracker.Players].

    @return (number?, PlayerObject?) -- The index and value of the [PlayerObject] inside of [PlayerTracker.Players], if it exists.
]=]
function PlayerTracker.GetFromInstance(
    self: PlayerTracker,
    playerInstance: Player
): (number?, PlayerObject.PlayerObject?)
    for i, player in ipairs(self.players) do
        if player.instance == playerInstance then
            return i, player
        end
    end

    return nil, nil
end

--[=[
    Ran when a new [Player] joins the game. It starts tracking them and adds them to [PlayerTracker.Players].
]=]
function PlayerTracker.OnPlayerAdded(self: PlayerTracker, playerInstance: Player)
    if self:GetFromInstance(playerInstance) then
        return
    end

    local player = PlayerObject.new(playerInstance)
    table.insert(self.players, player)
end

--[=[
    Ran when a [Player] leaves the game, cleaning up their [PlayerObject] and removing them from [PlayerTracker.Players].
]=]
function PlayerTracker.OnPlayerRemoved(self: PlayerTracker, Player: Player)
    local playerIndex = self:GetFromInstance(Player)
    if not playerIndex then
        return
    end

    table.remove(self.players, playerIndex)
end

return PlayerTracker
