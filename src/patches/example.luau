-- Dependencies
local AimworkChecks = require("@modules/checks")
local AimworkTypes = require("@types/aimwork")
local AimworkSelectedType = require("@types/selected")
local PlayerObjectTypes = require("@modules/PlayerTracker/PlayerObject")
local VisualHandlerTypes = require("@modules/VisualHandler")
local FovObjectLike = require("@types/fov_object_like")

--
local PlayerCheck = AimworkChecks.PlayerCheck
local PartChecks = AimworkChecks.PartChecks
type PlayerObject = PlayerObjectTypes.PlayerObject

--
return function(aimwork: AimworkTypes.Aimwork)
    function aimwork.checks:PlayerCheck(Player: PlayerObject)
        if false then -- some condition
            return true -- return if valid
        end

        return PlayerCheck(self, Player)
    end

    function aimwork.checks:PartChecks(
        player: PlayerObject,
        parts: BasePart,
        fovs: { [FovObjectLike.FovObjectLike]: VisualHandlerTypes.AdditionalFOVData },
        selected: AimworkSelectedType.AimworkSelected
    )
        if false then -- some condition
            return -- do nothing
        end

        return PartChecks(self, player, parts, fovs, selected)
    end
end
