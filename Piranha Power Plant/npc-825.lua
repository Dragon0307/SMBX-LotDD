local broadcaster = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

broadcaster.name = "broadcaster"
broadcaster.id = 825

broadcaster.test = function()
  return "isBroadcaster", function(x)
    return (x == broadcaster.name or x == broadcaster.id)
  end
end

broadcaster.config = npcManager.setNpcSettings({
	id = broadcaster.id,

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
  notcointransformable = true,
	jumphurt = true,
  noblockcollision = true,
	nohurt = true,
	noyoshi = true,
  blocknpc = true,
  playerblock = true,
  playerblocktop = true,
  npcblock = true
})

function broadcaster.prime(n)
  local data = n.data

  data.frameX = data.frameX or 0
  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.powdir = data.powdir or 0
  data.powerPrev = data.powerPrev or false

  data.redarea = data.redarea or redstone.basicRedArea(n)
  data.redhitbox = data.redhitbox or redstone.basicRedHitBox(n)
end

function broadcaster.onTick(n)
  local data = n.data
  data.observ = false

  if data.power > 0 then
    redstone.updateRedArea(n)
    redstone.updateRedHitBox(n)
    redstone.passEnergy{source = n, npcList = redstone.npcList, power = data.power, hitbox = data.redhitbox, area = data.redarea}
  end

  if data.powerPrev ~= data.power then
    data.observ = true
  else
    data.observ = false
  end

  if data.power == 0 then
    data.frameY = 0
  else
    data.frameY = 1
  end

  data.powerPrev = data.power
  data.power = 0
end

function broadcaster.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(broadcaster)


return broadcaster
