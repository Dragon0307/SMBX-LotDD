--Stats.lua - Stat script for the SMBX episode "Legend of the Dark Door".
--I made this to de-clutter the episode's luna.lua 
--Steal this script! Feel free to modify or utilise this in some form for your episode.

--XP drops

-- Within this array are contained knowlege of greatness! If you want, mess around with it. But I don't have a clue because I was just looking at how HitPointLite does its tables.
xpDrops = {

}

-- To add experience to the table, call xpDrop(NPC, reward). replace "NPC" with the ID of the NPC in question and  

--Set up the levelup function 

SaveData["episode"] = SaveData["episode"] or {}
local stat = SaveData["episode"]

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

function xpDrop(NPCID, reward) -- This is declared in your luna.lua. Replacce NPCID with the ID of the NPC in question and reward with the XP drop.
    xpDrops[NPCID] = reward
end

function tableHasKey(table,key)
    return table[key] ~= nil
end

function onNPCKill(EventObj, killedNPC, killReason)
    if tableHasKey(xpDrops,killedNPC.id) then
        Text.print(0, 0 )
    end
end


-- Use onInitAPI to set up all the SMBX event handlers you'll need!
-- This runs as soon as library is loaded.

--function barebones.onTick()
	-- Put onTick stuff here
--end

--return stat