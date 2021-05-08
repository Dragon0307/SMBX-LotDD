local textnpc = {}

local npcManager = require("npcManager")
textnpc.id = NPC_ID

Graphics.activateHud(false)

textnpc.config = npcManager.setNpcSettings({
	id = textnpc.id,

	gfxwidth = 15,
	gfxheight = 7,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	foreground = true,

	frames = 30,
	framespeed = 8,
	framestyle = 0,

	width = 15,
	height = 7,

  nogravity = true,
  noblockcollision = true,
  notcointransformable = true,
	jumphurt = true,
	nohurt = true,
	noyoshi = true,
  blocknpc = false,
  playerblock = false,
  playerblocktop = false,
  npcblock = false
})


function textnpc.onDrawNPC(n)
  n.friendly = true
  n.animationFrame = n.data._settings.quantity or 0
  n.animationTimer = 0
end

function textnpc.onInitAPI()
	npcManager.registerEvent(textnpc.id, textnpc, "onDrawNPC")
end

return textnpc
