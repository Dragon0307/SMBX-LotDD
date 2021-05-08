local noteblock = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

noteblock.name = "noteblock"
noteblock.id = NPC_ID

noteblock.test = function()
  return "isNoteblock", function(x)
    return (x == noteblock.name or x == noteblock.id)
  end
end

noteblock.config = npcManager.setNpcSettings({
	id = noteblock.id,

	gfxwidth = 32,
	gfxheight = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
  invisible = false,

	frames = 4,
	framespeed = 8,
	framestyle = 0,

	width = 32,
	height = 32,

  nogravity = true,
	jumphurt = true,
  notcointransformable = true,
	nohurt = true,
	noyoshi = true,
  noblockcollision = true,
  blocknpc = true,
  playerblock = true,
  playerblocktop = true,
  npcblock = true
})

local animTimer = 0
local animFrame = 0

function noteblock.prime(n)
  local data = n.data

  data.frameX = data._settings.inv or 1
  data.frameX = data.frameX - 1

  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.powerPrev = data.powerPrev or 0
  data.instrument = data.instrument or 0
  data.inv = data.inv or 0
  data.invspace = true
end

function noteblock.onTick(n)
  local data = n.data
  data.observ = false

  if data.inv > 0 then
    data.frameX = math.min(data.inv, 24) - 1
    data.inv = 0
  end

  if data.power > 0 and data.powerPrev == 0 then
    data.observ = true
    data.observpower = data.power
    local v = NPC.spawn(redstone.component.note.id, n.x, n.y, n:mem(0x146, FIELD_WORD))
    v.data.frameX = data.frameX
    redstone.component.note.prime(v)
    --START SOUND
  end
  if data.power == 0 and data.powerPrev > 0 then
    --END SOUND
  end

  if data.power > 0 then
    data.frameY = 1
  else
    data.frameY = 0
  end

  data.powerPrev = data.power
  data.power = 0
end

function noteblock.onDraw(n)
  n.data.animTimer = animTimer
  n.data.animFrame = animFrame
  redstone.drawNPC(n)
end

function noteblock.onLibDraw()
  animTimer = animTimer + 1
  if animTimer >= noteblock.config.frameSpeed then
    animTimer = 0
    animFrame = animFrame + 1
    if animFrame >= noteblock.config.frames then
      animFrame = 0
    end
  end
end

function noteblock.onInitAPI()
  registerEvent(noteblock, "onDraw", "onLibDraw")
end


redstone.register(noteblock)

return noteblock
