lhp.setHP(280, 100) -- Wario (Over Ludwig)
warioPhase = 0

function onEvent(event)
    if event == "Wario Music" then
        Audio.MusicChange(1, "YukariIsLove.spc")
    elseif event == "Hammer Bro Killed" then
        Audio.MusicChange(0, "mrpg-mushroompass.spc")
    elseif event == "Stop Music" then
        Audio.MusicChange(2, 0)
    end
end

function onNPCHarm(eventToken,killedNPC,harmType)
    if killedNPC == 280 and warioPhase == 0 then
        AirSupport = layer.get("Air Support")
        layer.show("AirSupport")
        Text.showMessageBox("Grrrrrrr! You're are making me MAAAAAAAAAD! NOW I SHALL ACTIVATE MY WARIO CANNON!") -- This is intentional
        warioPhase = 2
    end
end

function PhaseTwo()
    layer.show("AirSupport")
end