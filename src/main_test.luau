-- Dependencies
local Aimwork = require("@self")
local Configuration = require("@core/config")
local mergeTables = require("@functions/mergeTables")

-- Initialisation
local aimwork = Aimwork.new(mergeTables(Configuration, {
    Ignored = {
        IgnoreLocalTeam = false
    }
}))
aimwork:Initialise()

-- Debug logging
local count = 0
while task.wait(1) and count < 10 do
    table.foreach(aimwork.selected, print)
    count += 1
end

-- Clean up once done
aimwork:Destroy()
