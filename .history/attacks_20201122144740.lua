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

function attack.MPCheck(x)
    if attack.Mana >= x then -- Prevents the user from using a special attack if they don't have enough mana.
        return true
    else
        Audio.playSFX("Sounds/Cancel8-Bit.ogg")
        return false
    end
end

function attack.fireOrb()
    if attack.MPCheck(4) == true then
        NPC.spawn(13, player.x, player.y, player.section) --spawns a fireball at your exact location.
    end
end

function attack.powerSlam()
    if attack.MPCheck(4) == true then
        Misc.doPOW()
        playerStun.stunPlayer(1, 200)
    end
end

local function attack.onNPCKill()
    i

return attack