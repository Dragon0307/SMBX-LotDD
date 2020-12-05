local torch = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

torch.name = "torch"
torch.id = NPC_ID

torch.test = function()
  return "isTorch", function(x)
    return (x == torch.name or x == torch.id)
  end
end

torch.filter = function(n, c, p, d, hitbox)
  if redstone.isBlock(c.id) and d == 1 then
    redstone.setEnergy(n, p)
  end
end

torch.config = npcManager.setNpcSettings({
	id = torch.id,

	gfxwidth = 32,
	gfxheight = 64,
	gfxoffsetx = 0,
	gfxoffsety = 0,
  invisible = false,

	frames = 2,
	framespeed = 8,
	framestyle = 0,

	width = 32,
	height = 64,

  noblockcollision = true,
  notcointransformable = true,
  nogravity = true,
	jumphurt = true,
	nohurt = true,
	noyoshi = true,
})

function torch.prime(n)
  local data = n.data

  data.frameX = data.frameX or 0
  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.powerPrev = data.powerPrev or 0

  data.redarea = data.redarea or redstone.basicRedArea(n)
  data.redhitbox = data.redhitbox or redstone.basicRedHitBox(n)
end

function torch.onTick(n)
  local data = n.data
  data.observ = false

  if data.power == 0 then
    redstone.updateRedArea(n)
    redstone.updateRedHitBox(n)
    redstone.passEnergy{source = n, power = 15, hitbox = data.redhitbox, area = data.redarea}
  end

  if data.powerPrev ~= data.power then
    data.observ = true
  end

  if data.power == 0 then
    data.frameY = 0
  else
    data.frameY = 1
  end

  data.powerPrev = data.power
  data.power = 0
end

function torch.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(torch)

return torch
