--Stats.lua - Gainus Levelus! This lets you gain experience and level up. Also includes HP and FP.
--COPPYRIT KMAKEVURSE LAL RITES RIZURVURVD DOO NUT DSITRIBUT
--Should I upload this?
--These are commented because 1. I don't mind people raiding my episode files and 2. I like talking to myself.

--Comments, Lua pretends these don't exist.

--NOTE TO SELF: "stat" is Levels and Experience, "stats" refers to the library itself.

local stats = {} -- API Table. I don't have a clue what this does.

--CONFIGURATION SETTINGS

--HP-related
stats.enableHP = true -- If true, enables the HP system. Defaults to true.
stats.showHP = true -- If true, shows your HP using the default text thing. Diasble this if you have your own GUI.
stats.criticalHP = 5 -- Point from where your HP is considered critically low. If this is the case, stats.LowHP will equal true.
stats.HPgrowth = 5 -- The value to add on for each levelup. Defaults to 5. Set to -1 to effectively diable.
stats.baseHP = 5 -- Base HP. Added onto by HP growth

--[[FP-related (UNUSED) I've made it so that the player is automatically set back to
stats.enableFP = false -- If true, enables the FP system. Disabled by default as it serves no immediate purpose and is here for those who can find a use for it.
stats.showFP = true -- If true, shows the FP stat.
stats.criticalFP = 0 -- Point from where your HP is considered critically low. If this is the case, stats.LowFP will equal true. Off by default because it is pointless and only here for completions sake.
stats.FPgrowth = 5 -- The value to add on for each levelup. Defaults to 5. Set to 0 to disable.
stats.baseHP = 5 -- Base HP. Added onto by HP growth. Set to 0 to disable.]]

--XP and Leveling


--Other
stats.disableLives = true -- Disables lives. The reason for this is that the HP system effectively renders it pointless.
stats.alwaysBig = true -- Prevents you from entering a small state after taking damage. Is a functional component of the damage system, and is recommended to be left as true.
--stats.disableItemBox = false -- Disables 



local xpDrops = {

-- Everything from GainXP is installed here

}

-- Load required libraries

local textplus = require("textplus")

function stats.xpDrop(NPCID, reward) -- xpDrop - Adds an enemy and its experience drop to the xpDrops. Not to be confused with it! Replace NPCID with the ID of the NPC in question and reward with the XP drop.
    xpDrops[NPCID] = reward
end --Remember, xpDrop goes below xpDrops.

local fontB = textplus.loadFont("textplus/font/6.ini") -- Used for text rendering

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

    if stat.maxhp == nil and stats.enableHP == true then
        stat.maxhp = stats.baseHP + (stat.level * stats.HPgrowth)
    end

    if stat.hp == nil and stats.enableHP == true then
        stat.hp = stat.maxhp
    end

    --if stat.maxfp == nil and stats.enableFP == true then
      --  stat.maxfp = stats.baseFP + (stat.level * stats.FPgrowth)
    --end

    --if stat.fp == nil and stats.enableFP == true then
     --   stat.fp = stat.maxfp
    --end

    --Phase 2: Events

    registerEvent(stats,"onNPCKill","onNPCKill",false); -- Shamelessly plagirazied from followa.lua, by Hoeloe.
    registerEvent(stats,"onDraw","onDraw",false)
    registerEvent(stats,"onStart","onStart",false)
    registerEvent(stats,"onPlayerHarm","onPlayerHarm",false)
    registerCustomEvent(stats,"onLevelUp","onLevelUp",false)
end

function stats.onPlayerHarm() --Handles playerHP
    stat.hp = stat.hp - 1
    player.powerup = 2
    --SFX.play("Sounds/SmallExplosion8-Bit.ogg")
    if stat.hp == 0 then
        player:kill()
    end
end

--stats.levelFormula = stat.level * 5 + stat.level -- The formula used for gainXP's level up functionality. Remember to use BIDMAS!

function stats.LevelUp(x) -- LevelUp - This grants a level. Input a minus number to make the player level down. Included for ease of use.
	stat.level = stat.level + x
    stat.maxhp = stats.baseHP + (stat.level * stats.HPgrowth)
    stats.onLevelUp()
end

function stats.onLevelUp()
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
    textplus.print{
        x = 30,
        y = 550,
        xscale = 2,
        yscale = 2,
        font = fontB,
        text = "LEVEL: " .. stat.level
    }
    textplus.print{
        x = 200,
        y = 550,
        xscale = 2,
        yscale = 2,
        font = fontB,
        text = "EXPERIENCE: " .. stat.xp
    }
    --textplus.print{
      --  x = 0,
        --y = 20,
    --    xscale = 2,
      --  yscale = 2,
        --font = fontB,
       -- text = "FP: " .. stat.fp
    --}
    if stat.hp >= 6 then
        textplus.print{
            x = 0,
            y = 0,
            xscale = 2,
            yscale = 2,
            font = fontB,
            text = "HP: " .. stat.hp
        }
    else
        textplus.print{
            x = 0,
            y = 0,
            xscale =2,
            yscale = 2,
            font = fontB,
            text = "HP: <color red><tremble strength=1>" .. stat.hp .."!</tremble></color>"
        }
    end
    if player.powerup == 1 then --Other than every frame, what would be the best time to implement this script? I tried it in onPlayerHarm
        --local lastHeight = player.height
        newHeight = 0
        player.y = player.y + player.height - newHeight
        player.powerup = 2    
        player.height = newHeight

        --local heightDifference = player.height - lastHeight
        --player.y = player.y - heightDifference
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

--function stats.onDraw() -- MANY scenarios are accounted for here. Here comes a lot of elseifs; if Redigit can get away with it then so can I.
    --[[
    if stats.enableHP == true and stats.showHP == true and stats.enableFP == true and stats.displayFP == true then -- Everything is on, draws HP above FP
        if playerFP >= stats.criticalFP + 1 then
            textplus.print{
                x = 0,
                y = 20,
                xscale = 2,
                yscale = 2,
                font = fontB,
                text = "FP: " .. stat.FP
            }
        else
            textplus.print{
                x = 0,
                y = 20,
                xscale =2,
                yscale = 2,
                font = fontB,
                text = "HP: <color red>" .. stat.HP .."!</color>"
            }
        end

        if playerHP >= stats.criticalHP + 1 then
            textplus.print{
                x = 0,
                y = 0,
                xscale = 2,
                yscale = 2,
                font = fontB,
                text = "HP: " .. stat.HP
            }
        else
            textplus.print{
                x = 0,
                y = 0,
                xscale =2,
                yscale = 2,
                font = fontB,
                text = "HP: <color red>" .. stat.HP .."!</color>"
            }
        end

    elseif stats.enableHP == false and stats.enableFP == true and stats.displayFP == true then -- HP is off
        if playerFP >= stats.criticalFP + 1 then
            textplus.print{
                x = 0,
                y = 0,
                xscale = 2,
                yscale = 2,
                font = fontB,
                text = "FP: " .. stat.FP
            }
        else
            textplus.print{
                x = 0,
                y = 0,
                xscale =2,
                yscale = 2,
                font = fontB,
                text = "HP: <color red>" .. stat.HP .."!</color>"
            }
        end

    elseif stats.displayHP == false and stats.enableFP == true and stats.displayFP == true then -- HP is on but hidden
        if playerFP >= stats.criticalFP + 1 then
            textplus.print{
                x = 0,
                y = 0,
                xscale = 2,
                yscale = 2,
                font = fontB,
                text = "FP: " .. stat.FP
            }
        else
            textplus.print{
                x = 0,
                y = 0,
                xscale =2,
                yscale = 2,
                font = fontB,
                text = "HP: <color red>" .. stat.HP .."!</color>"
            }
        end

    elseif stats.displayFP == false and stats.enableHP == true and stats.displayHP == true then -- FP is on but hidden
        if playerHP >= stats.criticalHP + 1 then
            textplus.print{
                x = 0,
                y = 0,
                xscale = 2,
                yscale = 2,
                font = fontB,
                text = "HP: " .. stat.HP
            }
        else
            textplus.print{
                x = 0,
                y = 0,
                xscale =2,
                yscale = 2,
                font = fontB,
                text = "HP: <color red>" .. stat.HP .."!</color>"
            }
        end

    elseif stats.enableFP == false and stats.enableHP == true and stats.displayHP == true then -- FP is off
        if playerHP >= stats.criticalHP + 1 then
            textplus.print{
                x = 0,
                y = 0,
                xscale = 2,
                yscale = 2,
                font = fontB,
                text = "HP: " .. stat.HP
            }
        else
            textplus.print{
                x = 0,
                y = 0,
                xscale =2,
                yscale = 2,
                font = fontB,
                text = "HP: <color red>" .. stat.HP .."!</color>"
            }
        end
    end
    ]]
--end

function stats.onNPCKill(EventObj, killedNPC, killReason) -- This raids xpDrops and dispenses XP for the NPC you just murdered, as long as you have declared it.
    if xpDrops[killedNPC.id] ~= nil then
        stats.GainXP(xpDrops[killedNPC.id])
    end
end

return stats