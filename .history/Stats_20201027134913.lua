--Stats

local xpDrops = {

[89]

}

SaveData["episode"] = SaveData["episode"] or {}
stat = SaveData["episode"]

--Set up the levelup function 

if stat.level == nil then
    stat.level = 1
end

if stat.xp == nil then
    stat.xp = 0
end

LevelUp = function(x) -- LevelUp - This grants a level. Input a minus number to make the player level down.
	stat.level = stat.level + x
end

GainXP = function(x) -- GainXP - This function grants you experience points.
    stat.xp = stat.xp + x
    if stat.xp > stat.level * 5 + stat.level then
        LevelUp(1)
    end
end

function xpDrop(NPCID, reward) -- Replace NPCID with the ID of the NPC in question and reward with the XP drop.
    xpDrops[NPCID] = reward
end

local function onNPCKill(EventObj, killedNPC, killReason)
    if xpDrops[killedNPC.id] ~= nil then
        GainXP(xpDrops[killedNPC.id])
    end
end