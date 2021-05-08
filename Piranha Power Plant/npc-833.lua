local capacitor = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

capacitor.name = "capacitor"
capacitor.id = NPC_ID

capacitor.test = function()
  return "isCapacitor", function(x)
    return (x == capacitor.name or x == capacitor.id)
  end
end

capacitor.filter = function(n, c, p, d, hitbox)
  if d == n.data.frameX then
    redstone.setEnergy(n, p)
  end
end

capacitor.config = npcManager.setNpcSettings({
	id = capacitor.id,

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
	jumphurt = true,
  noblockcollision = true,
	nohurt = true,
	noyoshi = true,
  blocknpc = true,
  playerblock = true,
  playerblocktop = true,
  npcblock = true
})

function capacitor.prime(n)
  local data = n.data

  data.frameX = data._settings.dir or 0
  data.frameY = data.frameY or 0

  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.capacitance = 0
  data.maxcapacitance = data._settings.capacitance
  data.powerPrev = data.powerPrev or 0
  data.redhitbox = redstone.basicDirectionalRedHitBox(n, data.frameX)
  data.observ = true
  data.invspace = true
end

function capacitor.onTick(n)
  local data = n.data

  data.timerPrev = data.onTimer

  if data.inv ~= 0 then
    data.maxcapacitance = data.inv
    data.inv = 0
    data.invspace = false
  end

  if data.capacitance > data.maxcapacitance then
    redstone.updateDirectionalRedHitBox(n, data.frameX)
    redstone.passDirectionEnergy{source = n, power = data.power, hitbox = data.redhitbox}
  elseif data.power > 0 and data.powerPrev == 0 then
    data.capacitance = data.capacitance + 1
  end

  if data.power == 0 and data.powerPrev > 0 then
    data.invspace = true
  end

  if data.power == 0 then
    data.frameY = 0
  elseif data.capacitance > data.maxcapacitance then
    data.frameY = 2
  else
    data.frameY = 1
  end

  data.observpower = math.floor(15*data.capacitance/data.maxcapacitance)

  data.powerPrev = data.power
  data.power = 0
end

function capacitor.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(capacitor)

return capacitor
