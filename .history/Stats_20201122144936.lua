--Stats.lua - Gainus Levelus! This lets you gain experience and level up.
--COPPYRIT KMAKEVURSE LAL RITES RIZURVURVD DOO NUT DSITRIBUT
--Should I upload this?
--These are commented because 1. I don't mind people raiding my episode files and 2. I like talking to myself.

--Comments, Lua pretends these don't exist.

--NOTE TO SELF: "stat" is Levels and Experience, "stats" refers to the library itself.

local stats = {} -- API Table. I don't have a clue what this does.

local xpDrops = {

-- Everything from GainXP is to be bannished here.

}

function stats.xpDrop(NPCID, reward) -- xpDrop - Adds an enemy and its experience drop to the xpDrops. Not to be confused with it! Replace NPCID with the ID of the NPC in question and reward with the XP drop.
    xpDrops[NPCID] = reward
end --Remember, xpDrop goes below xpDrops.

SaveData["episode"] = SaveData["episode"] or {}
local stat = SaveData["episode"]

--Set up the levelup function 

function stats.onInitAPI() --Initialize variables whenever Stats.lua is loaded
    if stat.level == nil then
        stat.level = 1
    end

    if stat.xp == nil then
        stat.xp = 0
    end

    --Phase 2: Events

    registerEvent(stats,"onNPCKill","onNPCKill",false); -- Shamelessly plagirazied from followa.lua, by Hoeloe.

end

function stats.LevelUp(x) -- LevelUp - This grants a level. Input a minus number to make the player level down.
	stat.level = stat.level + x
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

function stats.onNPCKill(EventObj, killedNPC, killReason) -- This raids xpDrops and dispenses XP for the NPC you just murdered, as long as you have declared it.
    if xpDrops[killedNPC.id] ~= nil then
        stats.GainXP(xpDrops[killedNPC.id])
    end
end

return stats