local block = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

block.name = "block"
block.id = NPC_ID

block.test = function()
  return "isBlock", function(x)
    return (x == block.name or x == block.id)
  end
end

block.filter = function(n, c, p, d, hitbox)
  if redstone.isOperator(c.id) or redstone.isAlternator(c.id) or redstone.isObserver(c.id) or redstone.isSpyblock(c.id) or redstone.isRepeater(c.id) or redstone.isCapacitor(c.id) or redstone.isLever(c.id) or redstone.isButton(c.id) or redstone.isReciever(c.id) or redstone.isReaper(c.id) or (redstone.isTorch(c.id) and d == 1) then
    redstone.setEnergy(n, p)
  end
end

block.config = npcManager.setNpcSettings({
	id = block.id,

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
  noblockcollision = true,
	jumphurt = true,
	nohurt = true,
	noyoshi = true,
  blocknpc = true,
  playerblock = true,
  playerblocktop = true,
  npcblock = true
})

function block.prime(n)
  local data = n.data

  data.frameX = data._settings.mapX or 1
  data.frameX = data.frameX - 1
  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0
  data.powerPrev = data.powerPrev or 0

  data.redarea = data.redarea or redstone.basicRedArea(n)
  data.redhitbox = data.redhitbox or redstone.basicRedHitBox(n)
end

function block.onTick(n)
  local data = n.data
  data.observ = false

  if data.power > 0 then
    redstone.updateRedArea(n)
    redstone.updateRedHitBox(n)
    redstone.passEnergy{source = n, power = data.power, hitbox = data.redhitbox, area = data.redarea}
  end

  if data.powerPrev ~= data.power then
    data.observ = true
  end

  data.powerPrev = data.power
  data.power = 0
end

function block.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(block)

return block
