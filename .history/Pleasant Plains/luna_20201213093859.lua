SaveData[Level.filename()] = SaveData[Level.filename()] or {}
local LevelSD = SaveData[Level.filename()]

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
        layer.hide(boomLayer noSmoke)
    end

    if LevelSD.larryKilled == 1 then
        layer.hide(boomLayer noSmoke)
    end

    
end
local function onEvent(event)
    if event == "Boom Boom Music" then
        Audio.MusicChange(0, "42 - Castle Boss.ogg")
    elseif event == "Boom Boom Reset" then
        Audio.MusicChange(0, "mrpg-theme2.spc")
        LevelSD
    elseif event == "Larry Music" then
        Audio.MusicChange(0, "42 - Castle Boss.ogg")    
    elseif event == "Larry Reset" then
        Audio.MusicChange(0, "mrpg-theme2.spc")
    elseif event == "Bowser Killed"
    end
end