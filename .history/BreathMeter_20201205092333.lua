--------------------------------------------------
--===========Example LunaLua Library============--
--    Copypaste and edit this to make your      --
--                 own library!                 --
--    Load in a level with something like:      --
--     local example = require("example")      --
--------------------------------------------------

--breathMeter.lua - 'cause the X2 devs will shout at you if you use lsBreathMeter. Also featuring Sonic drowning music.

-- Declare our library table

local breathMeter = {} -- API Table. I'll give a genuine Kamekverse No-Prize to anyone who can tell me what it does.

-- Declare any local and library variables we might need:

-- Private variable. This can't be accessed outside of this code file.

local oxygen = 10 -- Oxygen remaining. You can have up to 10, but

-- Exposed variable. This can be accessed by anything that loads the API.
breathMeter.maxOxygen = 0 

-- Private function. Same deal.
local function myFunc(a, b)
	return a + b
end

breathMeter.onStart()
	oxygen = breathMeter.maxOxygen


-- Exposed function. Same deal.
function barebones.exampleFunc(x)
	return (x > 0)
end

-- Use onInitAPI to set up all the SMBX event handlers you'll need!
-- This runs as soon as library is loaded.
function barebones.onInitAPI()
	registerEvent(barebones, "onTick")

	-- Put stuff that should happen when the library is loaded here.
end

function barebones.onTick()
	-- Put onTick stuff here
end

return barebones