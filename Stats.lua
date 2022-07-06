--Stats.lua - Gainus Levelus! This lets you gain experience and level up. Also includes HP and FP.
--COPPYRIT KMAKEVURSE LAL RITES RIZURVURVD DOO NUT DSITRIBUT
--Should I upload this?
--These are commented because 1. I don't mind people raiding my episode files and 2. I like talking to myself.

--Comments, Lua pretends these don't exist.

local colliders = require("colliders") -- We neeed this later

--NOTE TO SELF: "stat" is Levels and Experience, "stats" refers to the library itself.

local stats = {} -- API Table. I don't have a clue what this does.

--CONFIGURATION SETTINGS

--HP-related
stats.criticalHP = 5 -- Point from where your HP is considered critically low. If this is the case, stats.LowHP will equal true.
stats.HPgrowth = 5 -- The HP increase for each levelup. Defaults to 5.
stats.POWgrowth = 1 -- The POW increase for each levelup. Defaults to 5.
stats.DEFgrowth = 0 -- The DEF increase for each levelup.
stats.baseHP = 5 -- Base HP. Added onto by HP growth
stats.alwaysBig = true -- Prevents you from entering a small state after taking damage. Is a functional component of the damage system, and is recommended to be left as true.


local xpDrops = {

-- Everything from GainXP is installed here

}

local enemyPOW = {}

local enemyDEF = {}

-- Load required libraries

--local textplus = require("textplus")

function stats.registerNPC(NPCID, pow, def, xpdrop)
        enemyPOW[NPCID] = pow
        enemyDEF[NPCID] = def
        xpDrops[NPCID] = xpdrop
end

-- This function is included for backwards compatability with an internal version.

function stats.xpDrop(NPCID, reward) -- xpDrop - Adds an enemy and its experience drop to the xpDrops. Not to be confused with it! Replace NPCID with the ID of the NPC in question and reward with the XP drop.
    xpDrops[NPCID] = reward
end --Remember, xpDrop goes below xpDrops.

--local fontB = textplus.loadFont("textplus/font/6.ini") -- Used for text rendering

--Set up the levelup function

SaveData["episode"] = SaveData["episode"] or {}
stat = SaveData["episode"] -- Stat cannot be accessed from outside the game

function stats.onInitAPI() --Initialize variables whenever Stats.lua is loaded
    if stat.level == nil then
        stat.level = 1
    end

    if stat.xp == nil then
        stat.xp = 0
    end

    if stat.maxhp == nil then
        stat.maxhp = stats.baseHP + (stat.level * stats.HPgrowth)
    end

    if stat.hp == nil then
        stat.hp = stat.maxhp
    end

    if stat.pow == nil then
        stat.pow = 1 * stat.level
    end


    if stat.def == nil then
        stat.def = 1 * (stat.level - 1)
    end

    --Phase 2: Events

    registerEvent(stats,"onNPCKill","onNPCKill",false); -- Shamelessly plagirazied from followa.lua, by Hoeloe.
    registerEvent(stats,"onDraw","onDraw",false)
    registerEvent(stats,"onStart","onStart",false)
    registerEvent(stats,"onPlayerHarm","onPlayerHarm",false)
    --registerEvent(stats,"onPostPlayerHarm","onPlayerHarm",false)
    registerCustomEvent(stats,"onLevelUp","onLevelUp",false)
end

function stats.onPlayerHarm() --Handles playerHP
    local subjectpow = 0 -- In case it complains

-- Check who the enemy is and how much POW they've got
    for k,v in pairs(NPC.get()) do
        if (colliders.collide(player, v)) then
            subjectpow = enemyPOW[v.id] -- Records the target's POW
        end
    end
    local damagecalc = subjectpow - stat.def -- Calculates damage
    if damagecalc < 1 then
       damagecalc = 1 -- No healing when an enemy hits you, because that's just dumb
    end
    stat.hp = stat.hp - damagecalc -- OUCH!

    if stat.hp < 1 then
        player:kill() -- oof
    end

    --player.powerup = 2

end

--stats.levelFormula = stat.level * 5 + stat.level -- The formula used for gainXP's level up functionality. Remember to use BIDMAS!

function stats.LevelUp(x) -- LevelUp - This grants a level. Input a minus number to make the player level down. Included for ease of use.
	stat.level = stat.level + x
    stat.maxhp = stat.maxhp + stats.HPgrowth
    stat.pow = stat.pow + stats.POWgrowth
    stat.def = stat.def + stats.DEFgrowth
    onLevelUp()
end

function onLevelUp()
    --This is called whenever you level up. What do you want to do with it? Entirely up to you!
end

function stats.GainXP(x) -- GainXP - This function grants you experience points.
    stat.xp = stat.xp + x
    if stat.xp > stat.level * 5 + stat.level then
        repeat
            stat.xp = stat.xp - (stat.level * 5 + stat.level)
            stats.LevelUp(1) --Keep going until you haven't got enough experience points
        until stat.xp < stat.level * 5 + stat.level
    end
end

function stats.onStart()
    if stat.hp < 1 then
        stat.hp = stat.maxhp
    end
end

function stats.onDraw() -- Prints your stats. It has to be global for some reason.
    if stats.alwaysBig == true then
        if player.powerup == 1 and player.forcedState ~= FORCEDSTATE_POWERDOWN_SMALL then -- Shamelessly stolen from SmgLifeSystem by Marioman2007. Thanks for solving my problem for me!
            player.powerup = 2
        end
    end
end

function stats.heal(x) -- Heals player HP by the specified amount, set to 0 if you want to fully restore HP. Cannot go over the cap.
    if x == 0 then
        stat.hp = stat.maxhp
    else
        stat.hp = stat.hp + x
        if stat.hp > stat.maxhp then
            stat.hp = stat.maxhp
        end
    end
end

function stats.onNPCKill(EventObj, killedNPC, killReason) -- This raids xpDrops and dispenses XP for the NPC you just murdered, as long as you have declared it.
    if xpDrops[killedNPC.id] ~= nil then
        stats.GainXP(xpDrops[killedNPC.id])
    end
end

return stats
