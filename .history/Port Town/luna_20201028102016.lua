--------------------------------------------------
-- Level code
-- Created 9:59 2020-10-28
--------------------------------------------------
SaveData[Level.filename()] = SaveData[Level.filename()] or {}
local LevelSD = SaveData[Level.filename()]

Level

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
    if eventName == "Toad Quest" then
        if LevelSD.wheelQuest == false then
            Text.showMessageBox("...or I WOULD, if the Wario Bros. didn't steal my steering wheel! Unless that you can somehow get another one, I'll be stuck here. FOREVER! Unless you can somehow manipulate my boat's turning direction.")
        elseif LevelSD.wheelFound == true then
            Text.showMessageBox("Wait, is that what I think it is? No, it's not my steering wheel. But, at the end of the day, it's *A* steering wheel, so I can actually drive my boat one again! Thanks!")
            LevelSD.wheelQuest = true
        end
    end
end


