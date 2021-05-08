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

--[[

YOSHI

I hate you Mario. You treat me like a tool to be used and discarded. You know where these wounds come from? You using me as a springboard!
And yes, I'm well aware of the Wiggler problem. But, frankly, I don't care anymore. Not since that time you sent me careening off to the bottom of Vanilla Dome...
...Tell you what. I'll do this for my friends and not you, and I'll only help you if you treat me respectfully. To make sure of this, I'm going to disable your spin jump so
you can't go leaving me to die in some pit! I've already had to crawl my way out the Pit of 100 Trials, like, a thousand times, and I'm not going in there ever again!
If you want the extra height, I can flutter jump instead. Just press the jump button in midair!

WIGGLERS

Oh yolk, this is worse than I thought. Luckilly, we Yoshis have a saying that if you can't beat 'em, eat 'em!
We'll need to hit them enough that they'll get mad, and then once their guard's down, I can slurp 'em up!
Just... don't get me hit. Okay?

]]



