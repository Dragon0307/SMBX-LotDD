SaveData[Level.filename()] = SaveData[Level.filename()] or {}
local LevelSD = SaveData[Level.filename()]

function onStart()
    if LevelSD.BossKilled == nil then
        Audio.MusicChange(0, "Mario & Luigi Bowser's Inside Story- Bowser's Path.ogg")
    end
end


function onEvent(event)
    if event == "Greeter Staus" then
        if LevelSD.BossKilled == nil then
            Text.showMessageBox("Although, we're a bit scared right now...")
        end
    end
end