--------------------------------------------------
-- Level code
-- Created 9:50 2020-10-15
--------------------------------------------------

--Intro script. Lets-a-go.

intro = true

local cameras = Camera.get()
local handycam = require("handycam") -- For the openning scroll.
local textplus = require("textplus") -- For opening text.

-- Run code on level start
function onStart()
    textplus.print{
        x = 100,
        y = 100,
        xscale = 2,
        yscale = 2,
        font = fontB,
        text = "Dragon0307 Presents..."
    }

end

-- Run code every frame (~1/65 second)
-- (code will be executed before game logic will be processed)
function onTick()
    --Your code here
end

-- Run code when internal event of the SMBX Engine has been triggered
-- eventName - name of triggered event
function onEvent(eventName)
    --Your code here
end

