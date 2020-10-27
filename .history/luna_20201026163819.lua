--luna.lua for Legend of the Dark Door, an SMBX episode.
--This code will make the X2 devs cry

local exp = require("Stats")
allAchievements = Achievements.get()

SaveData["episode"] = SaveData["episode"] or {}
stat = SaveData["episode"]

--WARNING: Spaghetti Code Ahead!

lhp = require("LightHitPoint") -- Needs to be global for per-level health bars.
anothercurrenc
local textplus = require("textplus")
local flutter = require("flutterjump") --Yoshi is NOT a tool to be used and discarded, he has rights! Use the flutter jump instead of cruelly sacrificing him.
local warp = require("warpTransition")

function sleep(n)
    if n > 0 then os.execute("ping -n " .. tonumber(n+1) .. " localhost > NUL") end
end

local fontB = textplus.loadFont("textplus/font/6.ini")
local fontA = textplus.loadFont("textplus/font/smw-b.ini")

------------------
--Textplus setup--
------------------

function onDraw()
    textplus.print{
        x = 30,
        y = 550,
        xscale = 2,
        yscale = 2.1,
        font = fontB,
        text = "LEVEL: " .. stat.level
    }
    textplus.print{
        x = 200,
        y = 550,
        xscale =2,
        yscale = 2.1,
        font = fontB,
        text = "EXPERIENCE: " .. stat.xp
    }
end

---------------------------
--LightHitPoint.lua setup--
---------------------------

--HARM TYPES
function onLoop() --This is really the only way I thought I could add dynamic level stats.
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
lhp.setNPCDamage(157, stat.level * 3) --Verticle Stripe Mushroom Blocks
end

--NPC HP

lhp.setHP(1, 4.25) -- SMB3 Goomba
lhp.setHP(2, 10) -- SMB3 Red Goomba
lhp.setHP(89, 1.5) -- SMB1 Goomba
lhp.setHP(71, 30 ) -- SMB3 Grand Goomba
lhp.setHP(431, 12) -- SMW Supercharged Spiny
lhp.setHP(29, 7) -- SMB1 Hammer Bro.
lhp.setHP(173, 3.3) -- SMB1 Green Koopa

xpDrop(89, 1)

--Leveling Up and EXP stats




-- I know, really bad practice.