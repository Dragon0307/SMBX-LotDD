function onEvent(event)
    if event == "Boom Boom Music" then
        Audio.MusicChange(0, "Mid-Boss - Super Mario Sunshine.ogg")
    elseif event == "Hammer Bro Killed" then
        Audio.MusicChange(0, "mrpg-mushroompass.spc")
    elseif event == "Stop Music" then
        Audio.MusicChange(2, 0)
    elseif event == "Lift Start" and soundPlayed == 0 then
        Audio.playSFX("Sounds/nsmbwiiBoneRollercoasterActivate.ogg")
        soundPlayed = 1
    end
end