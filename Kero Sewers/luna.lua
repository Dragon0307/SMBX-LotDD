SaveData[Level.filename()] = SaveData[Level.filename()] or {}
local LevelSD = SaveData[Level.filename()]

areaNames.sectionNames = {
	[0] = "Main Sewage Tunnel",
    [1] = "Sewer Exterior",
	[2] = "TEST YOUR SKILLS",
    [3] = "Port Tunnel",
    [4] = "Secret Storage",
    [5] = "Fish Tank",
    [6] = "Ripo Zone",
    [7] = "Koopa Terminal",
    [8] = "Unassuming Chamber",
    [9] = "?????",
	[12] = "Thanks for playing!"
}

littleDialogue.registerAnswer("Pipes",{text = "The Orange Pipe",addText = "The orange pipe goes to DK Jungle. Just be sure to swim past all the Cheep Cheeps."})
littleDialogue.registerAnswer("Pipes",{text = "The Green Pipe",addText = "The green pipe is for authorised personell only, or so I've been told. You can find a pipe to the Mushroom Port there, as well as one that is locked to the general public."})
littleDialogue.registerAnswer("Pipes",{text = "The Red Pipe",addText = "The red pipe goes to our side of the Border Patrol. Bowser uses this pipe to sneak into the Mushroom Kingdom and kidnap Princess Peach. I'm suprised you and the Toads haven't noticed yet."})
littleDialogue.registerAnswer("Pipes",{text = "The Dark Grey Pipe",addText = "The dark grey pipe heads down to an area connected to a pipe which heads to Pipe Plaza on Yoshi's Island. I've also heard rumors about this dodgy dude who is looking for star coins..."})
littleDialogue.registerAnswer("Pipes",{text = "The Light Grey Pipe",addText = "The light grey pipe is hooked up directly to the central shaft, which itself is connected to Toad Town, the Mario Bros. Plumbing company and the main entranace to the sewers. Beware though, it's a one way trip!"})
littleDialogue.registerAnswer("Pipes",{text = "The Blue Pipe",addText = "The blue pipe is hooked right up to Boo Woods. That place gives me the chills!"})
littleDialogue.registerAnswer("Pipes",{text = "What about that door?",addText = "This door should take you to Bubble Lake. It's quite close to the bottom of the lake, so if you would like to visit the area then you should probably go there a different way."})

--[[function onEvent(event)
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
end]]--
