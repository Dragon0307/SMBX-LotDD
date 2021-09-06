local repeater = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

repeater.name = "repeater"
repeater.id = NPC_ID

repeater.test = function()
  return "isRepeater", function(x)
    return (x == repeater.name or x == repeater.id)
  end
end

repeater.filter = function(n, c, p, d, hitbox)
  if d == n.data.frameX then
    redstone.setEnergy(n, p)
  elseif c.id == repeater.id and (d == (n.data.frameX + 1)%3 or d == (n.data.frameX - 1)%3) then
    n.data.locked = true
  else
    return true
  end
end

repeater.config = npcManager.setNpcSettings({
	id = repeater.id,

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

local function chooseDir(n, frameX)
  if frameX == 0 then
    return n.width*-0.5, 0, n.width*0.5, n.height
  elseif frameX == 1 then
    return 0, -n.height*0.5, n.width, n.height*0.5
  elseif frameX == 2 then
    return n.width, 0, n.width*0.5, n.height
  else
    return 0, n.height, n.width, n.height*0.5
  end
end

function repeater.prime(n)
  local data = n.data

  data.frameX = data._settings.dir or 0
  data.delay = data._settings.delay or 2

  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.isOn = data.isOn or false
  data.onTimer = data.onTimer or 0

  data.powerPrev = data.powerPrev or 0
  data.timerPrev = data.timerPrev or 0

  data.redhitbox = redstone.basicDirectionalRedHitBox(n, data.frameX)
end

function repeater.onTick(n)
  local data = n.data
  data.observ = false

  if data.locked then
    data.power = data.powerPrev
    data.onTimer = data.timerPrev
  end
  data.timerPrev = data.onTimer

  if data.isOn then
    redstone.updateDirectionalRedHitBox(n, data.frameX)
    redstone.passDirectionEnergy{source = n, power = 15, hitbox = data.redhitbox}

    if data.power == 0 and data.onTimer == 0 then
      data.onTimer = data.delay*10
    elseif data.onTimer > 0 then
      data.onTimer = data.onTimer - 1
      if data.onTimer == 0 then
        data.isOn = false
        data.observ = true
      end
    end
  else
    if data.power > 0 and data.onTimer == 0 then
      data.onTimer = data.delay*10
    elseif data.onTimer > 0 then
      data.onTimer = data.onTimer - 1
      if data.onTimer == 0 then
        data.isOn = true
        data.observ = true
      end
    end
  end

  if data.isOn then
    data.frameY = 1
  else
    data.frameY = 0
  end
  if data.locked then
    data.frameY = data.frameY + 2
  end

  data.locked = false
  data.powerPrev = data.power
  data.power = 0
end

function repeater.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(repeater)

return repeater
