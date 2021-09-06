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

function attack.recover() --Makes you super. This is a placeholder until I can add HP.
    
end

function attack.fireOrb()
    if attack.MPCheck(0) == true then
        Audio.playSFX("Sounds/FlameMagic.ogg")
        NPC.spawn(13, player.x, player.y, player.section, false, true) --spawns a player fireball at your exact location.
        for index,myNPC in ipairs(NPC.get(13)) do -- Stole this script from son
            myNPC.speedX = 13 * player.direction
        end
    end
end


function attack.powerSlam()
    if attack.MPCheck(4) == true then
        Misc.doPOW() -- Causes a POW block earthquake...
        playerStun.stunPlayer(10, 200) --...then stuns you to balance having such an OP attack.
    end
end

function attack.chillout()
    if attack.MPCheck(0) == true then
        Audio.playSFX("Sounds/FreezeMagic.ogg")
        NPC.spawn(237, player.x, player.y, player.section, false, true) --spawns a Yoshi fireball at your exact location.
        for index,myNPC in ipairs(NPC.get(237)) do
            myNPC.speedX = 4 * player.direction
        end
    end
end


return attack