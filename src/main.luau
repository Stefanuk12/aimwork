-- // Dependencies
local Aimwork = require("./init")
local Configuration = require("@core/config")
local MergeTables = require("@functions/merge_tables")

-- // Load any arguments passed in from loadstring, for the configuration
local Arguments = { ... }
assert(typeof(Arguments[1]) == "table", "expected a configuration table")
MergeTables(Configuration, Arguments[1])

-- // Return initialised Aimwork
return Aimwork.new(Configuration)
