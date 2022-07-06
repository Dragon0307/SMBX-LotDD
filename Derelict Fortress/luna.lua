stats.registerNPC(2, 3, 1, 5) -- SMB3 Red Goomba
stats.registerNPC(617, 4, 0, 0) -- SMB3 hammer

function onStart()
    --stat.def = 0
end

function onEvent(eventname)
    if eventname == "Elite Koopa" then
        Audio.MusicChange(4, "Metals of Terror.spc")
    end
end
