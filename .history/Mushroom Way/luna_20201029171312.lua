local warpTransition = require("warpTransition")
warpTransition.crossSectionTransition = warpTransition.TRANSITION_FADE

soundPlayed = 0

function onEvent(event)
    if event == "Hammer Bro Music" then
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

stats.xpDrop(89, 1)
stats.xpDrop(173, 1)
stats.xpDrop(29, 2)
stats.xpDrop(27, 1)
stats.xpDrop(28, 1)
stats.xpDrop(233, 1)