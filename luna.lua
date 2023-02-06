--luna.lua for Legend of the Dark Door, an SMBX episode.
--This code will make experienced lua people cry. Also, comments.


--PLANS

--Add a menu to choose special attacks from. I can't make sense of Mega Man's code so I can't use that as a reference.
--Switch characters to Uncle Broadsword and reskin him into Mario

--function onLoop()

--end

stats = require("Stats") -- Installs a custom library that I should not be proud of but I am. Provides the levels and experience
allAchievements = Achievements.get() -- Stuffs all the achievements into a useable state.
local attack = require("attacks") -- May be deleted at some point; is a special attack script that conjures special attacks.
local hammer = require("hammer") -- Stop, hammertime. Changed locally to make the game think its a sword since I've already implemented that.
hammer.active = true

--hammer.canSlamSwing = false
--hammer.canSlamAir = false

--playerHP = 0 -- Suprise! There's limited HP. Why else would I have reskinned Mario to be Uncle Broadsword unless I wanted that sweet sweet knockback mechanic?


--WARNING: Spaghetti Code Ahead!

SaveData["episode"] = SaveData["episode"] or {}
unlocks = SaveData["episode"]

function onKeyboardPress(keyCode)
    if keyCode == VK_Q then
        attack.fireOrb()
    elseif keyCode == VK_W then
        attack.powerSlam()
    elseif keyCode == VK_E then
        attack.chillout()
    elseif keyCode == VK_R then
        attack.recover()
    elseif keyCode == VK_T then
        attack.swordBeam()
    elseif keyCode == VK_Y then
        attack.boomerangBlade()
    end
end


-- Story savedatas

unlocks.hasHammer = 1
unlocks.hammerTier = 0
unlocks.bootTier = 0

lhp = require("LightHitPoint") -- Needs to be global for per-level health bars.
--anothercurrency = require("anothercurrency") -- Global for it to count across every level - ever. I think.
--local textbox = require("customTextbox") -- Vanilla textboxes are gunk
littleDialogue = require("littleDialogue")
areaNames = require("areaNames")

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

function onStart()
    --player.character = 15 -- You used to have to be Broadsword. He pretended to be Mario. Then hammer.lua happened, and frankly Uncle Broadsword was too slow for appropriate gameplay.
end

function onTickEnd()
    --sText.print(0x11C,100,100)
    if player.keys.altRun == KEYS_PRESSED and player.keys.up then
        if player:isOnGround() --[[player.speedY == 0]] then
            if player.speedX == 0 and not player.keys.left and not player.keys.right then
                attack.fireOrb()
            elseif hammer.canSlamSwing == true then
                attack.chillout()
            end
        elseif hammer.canSlamAir == true then
            attack.swordBeam()
        end
        --[[
        attack.fireOrb()
    else player.keys.altRun == KEYS_PRESSED and player.keys.up == KEYS_DOWN and unlocks.fireOrb == 1 and player.isOnGround then
        attack.chillout()
    end
    ]]--
    end
end

function onHUDDraw()
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
    textplus.print{
        x = 0,
        y = 20,
        xscale = 2,
        yscale = 2,
        font = fontB,
        text = "FP: " .. attack.Mana .. "/" .. attack.maxMana
    }
    if stat.hp >= stats.criticalHP then
        textplus.print{
            x = 0,
            y = 0,
            xscale = 2,
            yscale = 2,
            font = fontB,
            text = "HP: " .. stat.hp .. "/" .. stat.maxhp
        }
    else
        textplus.print{
            x = 0,
            y = 0,
            xscale =2,
            yscale = 2,
            font = fontB,
            text = "HP: " .. stat.hp .."!/" .. stat.maxhp
        }
    end
end


function onEvent(eventName)
    if eventName == "Unlock Fire Power" then
        SFX.play("Sounds/samus_item_sound.ogg")
    elseif eventName == "Resume" then
        unlocks.fireOrb = 1
    end
end

function onNPCKill(t,k,h) -- t = Event Token, k = Killed NPC, h = Harm Type
    if h == HARM_TYPE_VANISH and k.id == 9 then
        stats.heal(5)
    end
end

---------------------------
--LightHitPoint.lua setup--
---------------------------



--HARM TYPES
local function onTick() --This is really the only way I thought I could add dynamic level stats, seeing as onDraw was taken.
lhp.setHarmtypeDamage(HARM_TYPE_JUMP, stat.level * 0.75) -- When Mario jumps on an enemy
lhp.setHarmtypeSound(HARM_TYPE_JUMP, "Sounds/SmallExplosion8-Bit.ogg")
lhp.setHarmtypeDamage(HARM_TYPE_FROMBELOW, stat.level * 3) -- When Mario hits a block, damaging enemies on it.
lhp.setHarmtypeSound(HARM_TYPE_FROMBELOW, "Sounds/Crush8-Bit.ogg")
lhp.setHarmtypeDamage(HARM_TYPE_TAIL, stat.level * 0.75) -- When Mario uses a Tanooki spin.
lhp.setHarmtypeSound(HARM_TYPE_TAIL, "Sounds/Crush8-Bit.ogg")
lhp.setHarmtypeDamage(HARM_TYPE_SPINJUMP, stat.level * 1) -- When Mario spin jumps.
lhp.setHarmtypeSound(HARM_TYPE_SPINJUMP, "Sounds/Crush8-Bit.ogg")
lhp.setHarmtypeDamage(HARM_TYPE_SWORD, stat.level * 0.7) -- When Link stabs someone. Hyaaa!
lhp.setHarmtypeSound(HARM_TYPE_SWORD, "Sounds/Crush8-Bit.ogg")

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

stats.registerNPC(1, 1, 0, 1) -- SMB3 Goomba
stats.registerNPC(89, 5, 0, 12) -- SMB1 Goomba

-- Git could you please stop screwing up my levels
