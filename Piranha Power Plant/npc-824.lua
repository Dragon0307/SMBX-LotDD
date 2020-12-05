local note = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

note.name = "note"
note.id = NPC_ID

note.test = function()
  return "isNote", function(x)
    return (x == note.name or x == note.id)
  end
end

note.config = npcManager.setNpcSettings({
	id = note.id,

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
  notcointransformable = true,
  foreground = true,
  noblockcollision = true,
  nohurt = true,
  jumphurt = true
})

function note.prime(n)
  local data = n.data

  data.frameX = data.frameX or data._settings.type or 0

  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.timer = data.timer or 0
end

function note.onTick(n)
  local data = n.data
  n.friendly = true
  n.speedY = -1.4

  data.timer = data.timer + 1
  if data.timer > 25 then
	  n.opacity = 1 - (1/(50 - 25))*(data.timer - 25)
  end
  if data.timer >= 50 then
    n:kill()
  end
end

function note.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(note)

return note
