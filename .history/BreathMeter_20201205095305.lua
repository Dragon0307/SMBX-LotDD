--------------------------------------------------
--===========Example LunaLua Library============--
--    Copypaste and edit this to make your      --
--                 own library!                 --
--    Load in a level with something like:      --
--     local example = require("example")      --
--------------------------------------------------

--breathMeter.lua - 'cause the X2 devs will shout at you if you use lsBreathMeter. Also featuring the Sonic 3 drowning music.

-- Declare our library table

local breathMeter = {} -- API Table. I'll give a genuine Kamekverse No-Prize to anyone who can tell me what it does.

-- Declare any local and library variables we might need:

-- Private variable. This can't be accessed outside of this code file.

local oxygen = 10 -- Oxygen remaining. If it reaches 0, you're toast. 
local maxOxygen = 10 -- Max oxygen. The 
local drownRate = 2.5 -- The time it takes you lose a unit of oxygen.
local drowningMusicOn = true -- If true, plays the drowning music.
local drowningMusic = "Sonic 3 & Knuckles - Running out of Air!.vgz" -- The filename of the music that plays when you have low oxygen. 
local drownSoundOn = true -- If true, makes a noise when you lose air. 
local drownSound = "smsunshine_game_over.wav" -- Filename of the sound that plays wen you lose air.

-- Exposed variable. This can be accessed by anything that loads the API.


-- Private function. Same deal.
local function drowning()
	if Player:mem(0x34, 2) then 
		Audio.playSFX(drownSound)
	end
end

function BreathMeter.onTick()
	if Player:mem(0x34, 2) then 
		Audio.playSFX(drownSound)
	end
end

function breathMeter.onStart()
	oxygen = maxOxygen -- Sets your oxygen to the max you set.
	local numberOfLiquids = Liquid.count()
end

-- Exposed function. Same deal.
function breathMeter.exampleFunc(x)
	return (x > 0)
end

-- Use onInitAPI to set up all the SMBX event handlers you'll need!
-- This runs as soon as library is loaded.
function breathMeter.onInitAPI()
	registerEvent(breathMeter, "onTick")
	registerEvent(breathMeter, "onStart")

	-- Put stuff that should happen when the library is loaded here.
end

function breathMeter.onTick()
	-- Put onTick stuff here
end

return barebones