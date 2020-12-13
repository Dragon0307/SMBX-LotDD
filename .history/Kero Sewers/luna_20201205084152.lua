SaveData[Level.filename()] = SaveData[Level.filename()] or {}
local LevelSD = SaveData[Level.filename()]

function onEvent(event)
    if event == "Chet Rippo" then
        if LevelSD.BlueCoinsCollected == nil then
             if LevelSD.Upgraded == 1 then
                Text.showMessageBox("Enjoying that uprgrade I gave you? Well too bad, NO REFUNDS!")
            else
                LevelSD.Upgraded = 1
                Text.showMessageBox("You got the coins? Well good. Now, allow me to read the terms and conditions. *ahem* ")
                Text.showMessageBox("This spell comes with ABSOLUTELY NO WARRANTY;  without even the implied warranty of SURVIVABILITY or FITNESS FOR A PARTICULAR LIFESTYLE. Chet Rippo takes absolutely no responsibility for any damages to your soul, mental health and wellbeing. Additionally, Chet Rippo's upgrades are non-refundable.")
                Text.showMessageBox("With that out of the way, HOCUS CHOKUS! Now you should feel stronger. Remember, no refunds!")
                LevelUp(5)
                stat.xp = -50
            end
    else
        text.showMessageBox("Anyway, if you bring me 32 Blue Coins, I'll give you a 100% definately legal upgrade!")
    end
end