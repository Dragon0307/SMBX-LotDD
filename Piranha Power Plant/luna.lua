local lhp = require("LightHitPoint")

lhp.setHP(821, 40) -- Custom Fryguy Boss

function onEvent(event)
    if event == "Fryguy Music" then
        Audio.MusicChange(2, "Shootout!!.spc")
    end
end