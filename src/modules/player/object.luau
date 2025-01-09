-- // Dependencies
local TroveBuilder = require("@pkgs/trove")

-- // Services
local Players = game:GetService("Players")

-- // Vars
local LocalPlayer = Players.LocalPlayer

-- //
--[=[
    @class PlayerObject

    Tracks a specific [Player] and all of the relevant information associated with them.
]=]
--[=[
    @prop Instance Player
    @within PlayerObject
    The associated [Player].
]=]
--[=[
    @prop Character Model?
    @within PlayerObject
    The associated [Player]'s Character, if they have one.
]=]
--[=[
    @prop BodyParts { BasePart }
    @within PlayerObject
    All of the [Player]'s body parts.
]=]
--[=[
    @prop Health number
    @within PlayerObject
    The health of the [Player].
]=]
--[=[
    @prop Friend boolean
    @within PlayerObject
    Whether the [Player] is a friend of [Player.LocalPlayer] or not.
]=]
--[=[
    @prop ForceField boolean
    @within PlayerObject
    Whether the [Player] has a [ForceField] or not.
]=]
local PlayerObject = {}
PlayerObject.__index = PlayerObject
export type PlayerObjectData = {
    Instance: Player,
    Character: Model?,
    Trove: any,

    BodyParts: { BasePart },
    Health: number,
    Friend: boolean,
    ForceField: boolean,
}
export type PlayerObject = typeof(setmetatable({} :: PlayerObjectData, PlayerObject))
do
    --[=[
        Constructs a new [PlayerObject].

        @tag constructor
    ]=]
    function PlayerObject.new(Player: Player): PlayerObject
        -- // Create the object
        local self = setmetatable({}, PlayerObject)

        -- // Set properties
        self.Instance = Player
        self.Trove = TroveBuilder.new()

        self.BodyParts = {}
        self.Health = 0
        self.Friend = LocalPlayer:IsFriendsWith(Player.UserId)
        self.ForceField = false

        -- // Complete initialisation
        self:Initialise()

        -- // Return the object
        return self
    end

    --[=[
        Finishes the initialisation process for [PlayerObject], called during [PlayerObject.new].
    ]=]
    function PlayerObject.Initialise(self: PlayerObject)
        local Trove = self.Trove

        self:OnCharacterAdded(self.Instance.Character)

        Trove:Add(self.Instance.CharacterAdded:Connect(function(Character)
            self:OnCharacterAdded(Character)
        end))
        Trove:Add(self.Instance.CharacterRemoving:Connect(function(Character)
            self:OnCharacterRemoved(Character)
        end))
    end

    --[=[
        Cleans up, then destroys this object.
        > Note that you cannot use this object anymore, it's set to `nil`.

        @tag destructor
    ]=]
    function PlayerObject.Destroy(self: PlayerObject)
        self.Trove:Destroy()
        setmetatable(self :: any, nil)
    end

    --[=[
        Called whenever a child is added inside of the [Player]s character, setting tracked values and connections.
    ]=]
    function PlayerObject.OnChildAdded(self: PlayerObject, Child: Instance)
        if Child:IsA("BasePart") then
            table.insert(self.BodyParts, Child)
        elseif Child:IsA("Humanoid") then
            local Trove = self.Trove
            Trove:Add(Child.HealthChanged:Connect(function(Health)
                self.Health = Health
            end))
        elseif Child:IsA("ForceField") then
            self.ForceField = true
        end
    end

    --[=[
        Called whenever a child is removed from the [Player]s character, cleaning up associated tracked values back to their default "falsy" values.
    ]=]
    function PlayerObject.OnChildRemoved(self: PlayerObject, Child: Instance)
        if Child:IsA("BasePart") then
            local i = table.find(self.BodyParts, Child)
            if i then
                table.remove(self.BodyParts, i)
            end
        elseif Child:IsA("Humanoid") then
            self.Health = 0
        elseif Child:IsA("ForceField") then
            self.ForceField = false
        end
    end

    --[=[
        Called whenever the [Player]s character spawns, initialising all connections, etc.
    ]=]
    function PlayerObject.OnCharacterAdded(self: PlayerObject, Character: Model?)
        if not Character then
            return
        end

        self.Character = Character
        for _, v in ipairs(Character:GetChildren()) do
            self:OnChildAdded(v)
        end

        local Trove = self.Trove
        Trove:Add(Character.ChildAdded:Connect(function(Child)
            self:OnChildAdded(Child)
        end))
        Trove:Add(Character.ChildRemoved:Connect(function(Child)
            self:OnChildRemoved(Child)
        end))
    end

    --[=[
        Called whenever the [Player]s character is destroyed. It resets all tracked values to their default "falsy" values.
    ]=]
    function PlayerObject.OnCharacterRemoved(self: PlayerObject, _Character: Model)
        self.Character = nil
        self.Health = 0
        table.clear(self.BodyParts)
    end
end

-- //
return PlayerObject
