-- Dependencies
local Aimwork = require("./init")
local Configuration = require("@core/config")
local mergeTables = require("@functions/mergeTables")

-- Load any arguments passed in from loadstring, for the configuration
local arguments = { ... }
assert(typeof(arguments[1]) == "table", "expected a configuration table")
mergeTables(Configuration, arguments[1])

-- Return initialised Aimwork
return Aimwork.new(Configuration)
