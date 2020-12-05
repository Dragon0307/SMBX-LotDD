local flamethrower = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

flamethrower.name = "flamethrower"
flamethrower.id = NPC_ID

flamethrower.test = function()
  return "isFlamethrower", function(x)
    return (x == flamethrower.name or x == flamethrower.id)
  end
end

flamethrower.config = npcManager.setNpcSettings({
	id = flamethrower.id,

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
  noblockcollision = true,
	jumphurt = true,
	nohurt = true,
	noyoshi = true,
  blocknpc = true,
  playerblock = true,
  playerblocktop = true,
  npcblock = true,
})

local sfxfire = 16

function flamethrower.prime(n)
  local data = n.data

  data.angle = data._settings.angle or 0

  data.frameX = data.frameX or 0
  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.prevPower = data.prevPower or false
  data.invspace = true

  data.redarea = data.redarea or Colliders.Box(0, 0, n.width + 4, n.height + 2)
end

function flamethrower.onTick(n)
  if Defines.levelFreeze then return end
  local data = n.data
  data.observ = false

  data.redarea.x, data.redarea.y = n.x - 2, n.y
  for _, p in ipairs(Player.get()) do
    if (p.standingNPC and p.standingNPC == n) or Colliders.collide(p, data.redarea) then
      p:harm()
    end
  end

  data.redarea.y = data.redarea.y - 1
  local iceList = Colliders.getColliding{a = data.redarea, b = {620, 621, 633}, btype = Colliders.BLOCK, filter = function(v) return not v.isHidden end}
  for _, b in ipairs(iceList) do
    Animation.spawn(10, b.x, b.y)
    if b.id == 621 then
      b.id = 109
    elseif b.id == 633 then
      b:remove()
    else
      NPC.spawn(10, b.x, b.y, n.section)
      b:remove()
    end
  end



  if data.inv ~= 0 then
    data.angle = data.inv
    data.inv = 0
    data.invspace = false
  end

  if data.power > 0 and data.prevPower == 0 then
    data.invspace = true
    data.observ = true
    if redstone.onScreenSound(n) then
      SFX.play(sfxfire)
    end
    local e = Animation.spawn(10, n.x + 0.5*n.width - 16, n.y + 0.5*n.height - 16)
    local v = NPC.spawn(redstone.component.flame.id, n.x, n.y, n:mem(0x146, FIELD_WORD))
    v.x = v.x + 0.5*(n.width - v.width)
    v.y = v.y + 0.5*(n.height - v.height)
    v.data.angle = data.angle
    redstone.component.flame.prime(v)
  end

  data.prevPower = data.power
  data.power = 0
end

function flamethrower.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(flamethrower)

return flamethrower
