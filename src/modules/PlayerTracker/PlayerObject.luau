-- Dependencies
local Trove = require("@pkgs/trove")

-- Services
local Players = game:GetService("Players")

-- Vars
local localPlayer = Players.LocalPlayer

--[=[
    @class PlayerObject

    Tracks a specific [Player] and all of the relevant information associated with them.
]=]
--[=[
    @prop instance Player
    @within PlayerObject
    The associated [Player].
]=]
--[=[
    @prop character Model?
    @within PlayerObject
    The associated [Player]'s Character, if they have one.
]=]
--[=[
    @prop bodyParts { BasePart }
    @within PlayerObject
    All of the [Player]'s body parts.
]=]
--[=[
    @prop health number
    @within PlayerObject
    The health of the [Player].
]=]
--[=[
    @prop friend boolean
    @within PlayerObject
    Whether the [Player] is a friend of [Player.LocalPlayer] or not.
]=]
--[=[
    @prop forceField boolean
    @within PlayerObject
    Whether the [Player] has a [ForceField] or not.
]=]
local PlayerObject = {}
PlayerObject.__index = PlayerObject

-- Types
export type PlayerObjectData = {
    _trove: Trove.Trove,

    instance: Player,
    character: Model?,

    bodyParts: { BasePart },
    health: number,
    friend: boolean,
    forceField: boolean,
}
export type PlayerObject = setmetatable<PlayerObjectData, typeof(PlayerObject)>

--[=[
    Constructs a new [PlayerObject].

    NOTE: `friend` will not update by itself, must be updated externally.

    @tag constructor
]=]
function PlayerObject.new(Player: Player): PlayerObject
    -- Create the object
    local self: PlayerObjectData = {
        _trove = Trove.new(),
        instance = Player,
        bodyParts = {},
        health = 0,
        friend = localPlayer:IsFriendsWithAsync(Player.UserId),
        forceField = false,
    }
    self = setmetatable(self, PlayerObject)

    -- Complete initialisation
    self:Initialise()

    -- Return the object
    return self
end

--[=[
    Finishes the initialisation process for [PlayerObject], called during [PlayerObject.new].
]=]
function PlayerObject.Initialise(self: PlayerObject)
    local trove = self._trove

    self:OnCharacterAdded(self.instance.Character)

    trove:Connect(self.instance.CharacterAdded, function(Character: Model)
        self:OnCharacterAdded(Character)
    end)
    trove:Connect(self.instance.CharacterRemoving, function(Character: Model)
        self:OnCharacterRemoved(Character)
    end)
end

--[=[
    Cleans up, then destroys this object.
    > Note that you cannot use this object anymore, it's set to `nil`.

    @tag destructor
]=]
function PlayerObject.Destroy(self: PlayerObject)
    self._trove:Destroy()
    setmetatable(self :: any, nil)
end

--[=[
    Called whenever a child is added inside of the [Player]s character, setting tracked values and connections.
]=]
function PlayerObject.OnChildAdded(self: PlayerObject, child: Instance)
    if child:IsA("BasePart") then
        table.insert(self.bodyParts, child)
    elseif child:IsA("Humanoid") then
        self._trove:Connect(child.HealthChanged, function(Health: number)
            self.health = Health
        end)
    elseif child:IsA("ForceField") then
        self.forceField = true
    end
end

--[=[
    Called whenever a child is removed from the [Player]s character, cleaning up associated tracked values back to their default "falsy" values.
]=]
function PlayerObject.OnChildRemoved(self: PlayerObject, child: Instance)
    if child:IsA("BasePart") then
        local bodyPartIndex = table.find(self.bodyParts, child)
        if bodyPartIndex then
            table.remove(self.bodyParts, bodyPartIndex)
        end
    elseif child:IsA("Humanoid") then
        self.health = 0
    elseif child:IsA("ForceField") then
        self.forceField = false
    end
end

--[=[
    Called whenever the [Player]s character spawns, initialising all connections, etc.
]=]
function PlayerObject.OnCharacterAdded(self: PlayerObject, character: Model?)
    if not character then
        return
    end

    self.character = character
    for _, v in ipairs(character:GetChildren()) do
        self:OnChildAdded(v)
    end

    local trove = self._trove
    trove:Connect(character.ChildAdded, function(Child: Instance)
        self:OnChildAdded(Child)
    end)
    trove:Connect(character.ChildRemoved, function(Child: Instance)
        self:OnChildRemoved(Child)
    end)
end

--[=[
    Called whenever the [Player]s character is destroyed. It resets all tracked values to their default "falsy" values.
]=]
function PlayerObject.OnCharacterRemoved(self: PlayerObject, _character: Model)
    self.character = nil
    self.health = 0
    table.clear(self.bodyParts)
end

return PlayerObject
