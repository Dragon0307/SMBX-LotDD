local transmitter = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

transmitter.name = "transmitter"
transmitter.id = NPC_ID

transmitter.test = function()
  return "isTransmitter", function(x)
    return (x == transmitter.name or x == transmitter.id)
  end
end

transmitter.config = npcManager.setNpcSettings({
	id = transmitter.id,

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

function transmitter.prime(n)
  local data = n.data

  data.frameX = data._settings.dir or 0

  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.powerPrev = data.powerPrev or false

  data.redhitbox = redstone.basicDirectionalRedHitBox(n, data.frameX)
end

local function rangeDir(n, frameX, p)
  if frameX == 0 then
    return n.x - n.width*p, n.y, n.width, n.height
  elseif frameX == 1 then
    return n.x, n.y - n.height*p, n.width, n.height
  elseif frameX == 2 then
    return n.x + n.width*p, n.y, n.width, n.height
  else
    return n.x, n.y + n.height*p, n.width, n.height
  end
end

function transmitter.onTick(n)
  local data = n.data
  data.observ = false

  if data.power ~= 0 then
    for i = 1, data.power do
      data.redhitbox.x, data.redhitbox.y = rangeDir(n, data.frameX, i)
      redstone.passDirectionEnergy{source = n, power = data.power - i + 1, hitbox = data.redhitbox}
    end
  end

  if data.power == 0 then
    data.frameY = 0
  else
    data.frameY = 1
  end

  if data.power ~= data.powerPrev then
    data.observ = true
  end

  data.powerPrev = data.power
  data.power = 0
end

function transmitter.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(transmitter)

return transmitter
