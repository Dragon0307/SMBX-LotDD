lhp.setHP(15, 15)
stats.xpDrop(15, 4)

function onEvent(event)
    if event == "Boom Boom Music" then
        Audio.MusicChange(0, "42 - Castle Boss.ogg")
    elseif event == "Section Reset" then
        Audio.MusicChange(0, "mrpg-theme2.spc")
    elseif event == "Bo" then
        Audio.MusicChange(0, "42 - Castle Boss.ogg")    
end