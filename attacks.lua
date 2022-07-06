--Attacks.lua - Beating people up is fun! Also adds MP.
--These can be used to summon NPCs to do damage for you.
--This might be WAAAAAAY outside my experience. 

--import libraries

local playerStun = require("playerStun")
local freeze = require("freezeHighlight")
stats = require("Stats") -- Absoluetly necessary for HP to work
local attack = {}  -- API Table. I don't have a clue what this does. Now that I think of it, I guess its where all the custom stuff goes.

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

local particles = API.load("particles");

local effect = particles.Emitter(0,0, Misc.resolveFile("particles/p_gems.ini"))
effect:Attach(player)


--Variables

attack.Mana = 9999 -- MANA - This is how much power you have left to use special attacks. Don't bother changing this.
attack.maxMana = 90001 -- MAX MANA - This is the MP limit. You can change this, but I would advise using fancy Lua jank to change it on the fly.

local firecooldown = 0
local icecooldown = 0
local healcooldown = 0

healparticle = 0

-- Functions


function attack.onInitAPI() --Initialize variables whenever Stats.lua is loaded
    registerEvent(attack,"onCameraUpdate","onCameraUpdate",false)
    registerEvent(attack,"onDraw","onDraw",false)
end


function attack.onCameraUpdate()
    if healparticle == 1 then
        effect:Draw()
        Routine.run(function() Routine.wait(0.5) healparticle = 0 end)
    end
end

function attack.MPCheck(x)
    if attack.Mana >= x then -- Prevents the user from using a special attack if they don't have enough mana.
        return true
    else
        Audio.playSFX("Sounds/Cancel8-Bit.ogg")
        return false
    end
end

function attack.recover() --Restores your HP
    if attack.MPCheck(7) == true then
        Audio.playSFX("Sounds/earthboundheal.wav")
        effect:Draw()
        stats.heal(5)
        healparticle = 1
    end
end

function attack.fireOrb()
    if attack.MPCheck(4) == true and firecooldown < 1 then
        attack.Mana = attack.Mana - 4 -- MP deduction.
        Audio.playSFX("Sounds/FlameMagic.ogg")
        NPC.spawn(13, player.x, player.y, player.section, false, true) --spawns a player fireball at your exact location.
        for index,myNPC in ipairs(NPC.get(13)) do -- Stole this script from somewhere I forgot. I think it was the Wohlsoft wiki? I really can't remember.
            myNPC.speedX = 13 * player.direction
        end
        firecooldown = 20
    end
end


function attack.powerSlam()
    if attack.MPCheck(30) == true then
        playerStun.stunPlayer(10, 200) --...then stuns you to balance having such an OP attack.
        Misc.doPOW() -- Causes a POW block earthquake...
        freeze.set(20) -- Does a flash of Powah
    end
end

function attack.chillout()
    if attack.MPCheck(5) == true then
        Audio.playSFX("Sounds/FreezeMagic.ogg")
        NPC.spawn(237, player.x, player.y, player.section, false, true) --spawns an ice cube at your exact location.
        for index,myNPC in ipairs(NPC.get(237)) do
            myNPC.speedX = 4 * player.direction
        end
    end
end

function attack.onDraw()
    firecooldown = firecooldown - 1
    icecooldown = icecooldown - 1
    healcooldown = healcooldown - 1
end

return attack
