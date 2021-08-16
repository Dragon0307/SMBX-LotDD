--luna.lua for Legend of the Dark Door, an SMBX episode.
--This code will make experienced lua dudes cry. Also, comments.


--PLANS

--Add a menu to choose special attacks from. I can't make sense of Mega Man's code so I can't use that as a reference.
--Switch characters to Uncle Broadsword and reskin him into Mario


stats = require("Stats") -- Installs a custom library that I should not be proud of but I am. Provides the levels and experience
allAchievements = Achievements.get() -- Stuffs all the achievements into a useable state.
attack = require("attacks") -- May be deleted at some point; is a special attack script that conjures special attacks.

playerHP = 0 -- Suprise! There's limited HP. Why else would I have reskinned Mario to be Uncle Broadsword unless I wanted that sweet sweet knockback mechanic?

function onKeyboardPress(keyCode)
    if keyCode == VK_Q then
        attack.fireOrb()
    elseif keyCode == VK_W then
        attack.powerSlam()
    elseif keyCode == VK_E then
        attack.chillout()
    end
end

function onNPCKill(EventObj, killedNPC, killReason) -- Restore mana when collecting an SMB1 axe trigger.
    if killedNPC.id == 178 then
        attack.Mana = attack.Mana + 12
        Audio.playSFX("Sounds/Heal8-Bit.ogg")
    end
end

--WARNING: Spaghetti Code Ahead!

SaveData["episode"] = SaveData["episode"] or {}
local stat = SaveData["episode"]

lhp = require("LightHitPoint") -- Needs to be global for per-level health bars.
anothercurrency = require("anothercurrency") -- Global for it to count across every level - ever. I think.
local textbox = require("customTextbox") -- Vanilla textboxes are gunk
local textplus = require("textplus")
local flutter = require("flutterjump") --Yoshi is NOT a tool to be used and discarded, he has rights! Use the flutter jump instead of cruelly sacrificing him.
local warpTransition = require("warpTransition")

--local fontB = textplus.loadFont(Misc.resolveFile("superstarsaga-a.ini"))
local fontB = textplus.loadFont("textplus/font/6.ini")
local fontA = textplus.loadFont("textplus/font/smw-b.ini")

--LsBreathMeter = require("BreathMeter") -- Was a thing at one point.

------------------
--Textplus setup--
------------------

function onDraw() -- Prints your stats
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
        xscale =2,
        yscale = 2,
        font = fontB,
        text = "EXPERIENCE: " .. stat.xp
    }
    textplus.print{
        x = 0,
        y = 0,
        xscale =2,
        yscale = 2,
        font = fontB,
        text = "FP: " .. attack.Mana
    }
    textplus.print{
        x = 0,
        y = 0,
        xscale =2,
        yscale = 2,
        font = fontB,
        text = "FP: " .. attack.Mana
    }
end

---------------------------
--LightHitPoint.lua setup--
---------------------------



--HARM TYPES
function onTick() --This is really the only way I thought I could add dynamic level stats.
lhp.setHarmtypeDamage(HARM_TYPE_JUMP, stat.level * 0.75) -- When Mario jumps on an enemy
lhp.setHarmtypeSound(HARM_TYPE_JUMP, "Sounds/SmallExplosion8-Bit.ogg")
lhp.setHarmtypeDamage(HARM_TYPE_FROMBELOW, stat.level * 3) -- When Mario hits a block, damaging enemies on it.
lhp.setHarmtypeSound(HARM_TYPE_FROMBELOW, "Sounds/Crush8-Bit.ogg")
lhp.setHarmtypeDamage(HARM_TYPE_TAIL, stat.level * 1.5) -- When Mario uses a Tanooki spin.
lhp.setHarmtypeSound(HARM_TYPE_TAIL, "Sounds/Crush8-Bit.ogg")
lhp.setHarmtypeDamage(HARM_TYPE_SPINJUMP, stat.level * 1) -- When Mario spin jumps.
lhp.setHarmtypeSound(HARM_TYPE_SPINJUMP, "Sounds/Crush8-Bit.ogg")
lhp.setHarmtypeDamage(HARM_TYPE_SWORD, stat.level * 0.8) -- When Link stabs someone. Hyaaa!
lhp.setHarmtypeSound(HARM_TYPE_SWORD, "Sounds/Slash8-Bit.ogg")

--NPC HARM DAMAGE

lhp.setNPCDamage(13, stat.level * 1.25) --Fireballs
lhp.setNPCDamage(263, stat.level * 1.5) --Ice Cubes
lhp.setNPCDamage(171, stat.level * 3) --Player Hammers
lhp.setNPCDamage(157, stat.level * 3) --Vertical Stripe Mushroom Blocks
lhp.setNPCDamage(80, stat.level * 1) --Verticle Stripe Mushroom Blocks
end

--NPC HP

lhp.setHP(1, 4.25) -- SMB3 Goomba
lhp.setHP(2, 10) -- SMB3 Red Goomba
lhp.setHP(89, 1.5) -- SMB1 Goomba
lhp.setHP(71, 30 ) -- SMB3 Grand Goomba
lhp.setHP(431, 12) -- SMW Supercharged Spiny
lhp.setHP(29, 4) -- SMB1 Hammer Bro.
lhp.setHP(173, 3.3) -- SMB1 Green Koopa
lhp.setHP(27, 4.25) -- SMB1 Gloomba

--Leveling Up and EXP stats

stats.xpDrop(1, 1) -- SMB3 Goomba

-- I know, really bad practice.