lhp.setHP(15, 15)
stats.xpDrop(15, 4)

function onEvent(event)
    if event == "Boom Boom Music" then
        Audio.MusicChange(0, "42 - Castle Boss.ogg")
    elseif event == "Boom Boom Reset" then
        Audio.MusicChange(0, "mrpg-theme2.spc")
    elseif event == "Larry" then
        Audio.MusicChange(0, "mrpg-theme2.spc")
end