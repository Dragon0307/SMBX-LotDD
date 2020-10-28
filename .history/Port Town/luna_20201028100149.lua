--------------------------------------------------
-- Level code
-- Created 9:59 2020-10-28
--------------------------------------------------
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


-- Run code on level start
function onStart()
    --Your code here
end

-- Run code every frame (~1/65 second)
-- (code will be executed before game logic will be processed)
function onTick()
    --Your code here
end

-- Run code when internal event of the SMBX Engine has been triggered
-- eventName - name of triggered event
function onEvent(eventName)
    if eventName == "Toad Quest"
end


