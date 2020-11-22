--Attacks.lua - Beating people up is fun! Also adds MP.
--These can be used to summon NPCs to do damage for you.
--This might be WAAAAAAY outside my experience. 

--import libraries

local playerStun = require("playerStun")

local attack = {}  -- API Table. I don't have a clue what this does.

--[[

So, while I'm here, these are the attacks used by this script:

RECOVER - Turns you into Super Mario.
FIRE ORB - Creates a fireball and throws it.
CHILLOUT - Gives you an ice block to throw.
BOMB RUSH - Throws an SMB2 bomb. Be careful not to blow yourself up in the process!
ULTRA HAMMER - Summons a player-thrown hammer.
BOOMERANG BLADE - Throws one of Uncle Broadsword's boomerangs. 
POWER SLAM - Sets of a POW block but inflicts you with a stun.

]]--

--Variables

attack.Mana = 0 -- MANA - This is how much power you have left to use special attacks.
attack.maxMana = 0 -- MAX MANA - This is the MP limit.

-- Functions

--local function attack.MPCheck(x)
    --if attacks.Mana > x then
        --return true
    --else
        --return false
    --end
--end

function attack.fireOrb()
    --if function.MPCheck(4) == true then
    NPC.spawn(171, player.x, player.y, player.section)
    --end
end

function attack.powerSlam()
    --if function.MPCheck(4) == true then
        playerStun.stunPlayer(id, duration)
    --end
end

return attack