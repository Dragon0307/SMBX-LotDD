SaveData[Level.filename()] = SaveData[Level.filename()] or {}
local LevelSD = SaveData[Level.filename()]
local freeze = require("freezeHighlight")


--initialize variables

if LevelSD.BoomKilled == nil then
    LevelSD.BoomKilled = 0
end

if LevelSD.larryKilled == nil then
    LevelSD.larryKilled = 0
end

if LevelSD.bowserKilled == nil then
    LevelSD.bowserKilled = 0
end

--Set up EXP drops and HP

lhp.setHP(15, 15)
lhp.setHP(267, 10)
lhp.setHP(86, 15)
lhp.setHP(299, 20)

stats.xpDrop(15, 4)
stats.xpDrop(267, 4)
stats.xpDrop(86, 6)
stats.xpDrop(299, 5)

local function onStart()
    local boomLayer = Layer.get("Boom Boom")
    local larryLayer = Layer.get("Larry")
    local bowserLayer = Layer.get("PRINCESS BOWZAH") -- don't ask
    local bombLayer = Layer.get("Bomb Blaster")
    -- Ifs ahoy!
    if LevelSD.BoomKilled == 1 then
        layer.hide(boomLayer, true) -- You already beat Boomicus, no grinding for you.
    end

    if LevelSD.larryKilled == 1 then
        layer.hide(larryLayer, true) -- Same goes with Larrius
    end

    if LevelSD.bowserKilled == 1 then
        layer.hide(boomLayer, true) -- and PRINCESS BOWZAH, who has fallen in the lava more times than even Miyamoto can count.
    end
end
local function onEvent(event)
    if event == "Boom Boom Music" then
        Audio.MusicChange(0, "42 - Castle Boss.ogg")  
    elseif event == "Boom Boom Reset" then
        freeze.set(20)
        Audio.MusicChange(0, "mrpg-theme2.spc")
        LevelSD.BoomKilled = 1
    elseif event == "Larry Music" then
        Audio.MusicChange(0, "42 - Castle Boss.ogg")   
    elseif event == "Larry Reset" then
        Audio.MusicChange(0, "mrpg-theme2.spc")
        LevelSD.larryKilled = 1
    elseif event == "Bowser Killed" then
        LevelSD.bowserKilled = 1
    elseif
    
    end
end