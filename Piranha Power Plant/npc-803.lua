local soundblock = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

soundblock.name = "soundblock"
soundblock.id = NPC_ID

soundblock.test = function()
  return "isSoundblock", function(x)
    return (x == soundblock.name or x == soundblock.id)
  end
end

soundblock.config = npcManager.setNpcSettings({
	id = soundblock.id,

	gfxwidth = 32,
	gfxheight = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
  invisible = false,

	frames = 1,
	framespeed = 8,
	framestyle = 0,

	width = 32,
	height = 32,

  nogravity = true,
  noblockcollision = true,
  notcointransformable = true,
	jumphurt = true,
	nohurt = true,
	noyoshi = true,
  blocknpc = true,
  playerblock = true,
  playerblocktop = true,
  npcblock = true
})

function soundblock.prime(n)
  local data = n.data

  data.inv = data._settings.inv or "29"
  data.invspace = true

  data.frameX = data.frameX or 0
  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.powerPrev = data.powerPrev or 0
  data.powertimer = data.powertimer or 0

  if tonumber(data.inv) then
    data.sound = tonumber(data.inv)
  else
    local soundpath = Misc.resolveFile(data.inv)
    if not soundpath then error("Invalid sound path in sound block in section "..n.section.." ["..n.x..", "..n.y.."]") end
    data.sound = Audio.SfxOpen(soundpath)
  end
  data.inv = 0
end

function soundblock.onTick(n)
  local data = n.data
  data.observ = false

  if data.powertimer > 0 then
    data.powertimer = data.powertimer - 1
  end
  if data.inv > 0 then
    data.sound = tonumber(data.inv)
    data.inv = 0
  end

  if data.power > 0 and data.powerPrev == 0 then
    data.observ = true
    SFX.play(data.sound)
    data.powertimer = 30
  end

  if data.powertimer > 0 then
    data.frameY = 1
  else
    data.frameY = 0
  end
-- Text.print(data.power, n.x - camera.x, n.y - camera.y)
  data.powerPrev = data.power
  data.power = 0
end

function soundblock.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(soundblock)

return soundblock
