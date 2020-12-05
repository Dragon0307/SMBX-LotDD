local alternator = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

alternator.name = "alternator"
alternator.id = NPC_ID

alternator.test = function()
  return "isAlternator", function(x)
    return (x == alternator.name or x == alternator.id)
  end
end

alternator.filter = function(n, c, p, d, hitbox)
  if (n.data.frameX == 0 and (d == 1 or d == 3)) or (n.data.frameX == 1 and (d == 0 or d == 2)) then
    if redstone.isOperator(c.id) then
      if c.data.powerPrev == 0 and c.data.power > 0 then
        n.data.facing = -n.data.facing
      end
    end
    redstone.setEnergy(n, p)
  end
end

alternator.config = npcManager.setNpcSettings({
	id = alternator.id,

  width = 32,
  height = 32,
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
	jumphurt = true,
  noblockcollision = true,
  notcointransformable = true,
	nohurt = true,
	noyoshi = true,
  blocknpc = true,
  playerblock = true,
  playerblocktop = true,
  npcblock = true
})


function alternator.prime(n)
  local data = n.data

  data.frameX = data._settings.dir or 0
  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.facing = data.facing or 1
  data.powerPrev = data.powerPrev or false

  data.redhitbox = redstone.basicRedHitBox(n)
end

function alternator.onTick(n)
  local data = n.data
  data.observ = false

  if data.power > 0 then
    if data.powerPrev == 0 then
      data.facing = -data.facing
    end
    redstone.updateRedHitBox(n)
    redstone.passDirectionEnergy{source = n, power = data.power, hitbox = data.redhitbox[data.frameX + data.facing + 2]}
  end

  if (data.power == 0 and data.powerPrev ~= 0) or (data.power ~= 0 and data.powerPrev == 0) then
    data.observ = true
  end

  if data.power == 0 then
    data.frameY = 0
  elseif data.facing == -1 then
    data.frameY = 1
  else
    data.frameY = 2
  end
-- Text.print(data.power, n.x - camera.x, n.y - camera.y)
  data.powerPrev = data.power
  data.power = 0
end

function alternator.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(alternator)

return alternator
