-- Dependencies
local AimworkChecks = require("@modules/checks")
local AimworkTypes = require("@types/aimwork")
local AimworkSelectedType = require("@types/selected")
local PlayerObjectTypes = require("@modules/player/object")
local VisualHandlerTypes = require("@modules/visuals")

--
local PlayerCheck = AimworkChecks.PlayerCheck
local PartChecks = AimworkChecks.PartChecks
type PlayerObject = PlayerObjectTypes.PlayerObject

--
return function(Aimwork: AimworkTypes.Aimwork)
    function Aimwork.Checks:PlayerCheck(Player: PlayerObject)
        if false then -- some condition
            return true -- return if valid
        end

        return PlayerCheck(self, Player)
    end

    function Aimwork.Checks:PartChecks(
        Player: PlayerObject,
        Part: BasePart,
        FOVs: { [VisualHandlerTypes.FOVPrimative]: VisualHandlerTypes.AdditionalFOVData },
        Selected: AimworkSelectedType.AimworkSelected
    )
        if false then -- some condition
            return -- do nothing
        end

        return PartChecks(self, Player, Part, FOVs, Selected)
    end
end
