--Stats.lua
--Should I upload this?

--Comments, Lua pretends these don't exist.

--NOTE TO SELF: "stat" is Levels and Experience,

local stats = {} -- API Table. I don't have a clue what this does

local xpDrops = {

-- Everything from GainXP is to be bannished here.

}


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
end

function stats.LevelUp(x) -- LevelUp - This grants a level. Input a minus number to make the player level down.
	stat.level = stat.level + x
end

stats.GainXP(x) -- GainXP - This function grants you experience points.
    stat.xp = stat.xp + x
    if stat.xp > stat.level * 5 + stat.level then
        until stat.xp < stat.level * 5 + stat.level
            LevelUp(1)
        end
    end
end

function stat.xpDrop(NPCID, reward) -- xpDrop - Adds an enemy and its experience drop to the xpDrops. Not to be confusedd with it! Replace NPCID with the ID of the NPC in question and reward with the XP drop.
    xpDrops[NPCID] = reward
end

function stats.onNPCKill(EventObj, killedNPC, killReason) -- This raids xpDrops.
    if xpDrops[killedNPC.id] ~= nil then
        GainXP(xpDrops[killedNPC.id])
    end
end



return stats -- and STATS about that! Trolololololololololol.