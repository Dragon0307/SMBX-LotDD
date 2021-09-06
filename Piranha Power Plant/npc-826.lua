local operator = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

operator.name = "operator"
operator.id = NPC_ID

operator.test = function()
  return "isOperator", function(x)
    return (x == operator.name or x == operator.id)
  end
end

operator.filter = function(n, c, p, d, hitbox)
  n.data.pow = n.data.pow or {[0] = 0, [1] = 0, [2] = 0, [3] = 0}
  if d ~= n.data.frameX then
    local dir = (d + 2)%4
    n.data.pow[dir] = math.max(n.data.pow[dir], p)
  end
end

operator.config = npcManager.setNpcSettings({
	id = operator.id,

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
  blocknpctop = true,
  playerblock = true,
  playerblocktop = true
})

local function tie(a, b, n)
  if n < a then
    return b - (a - n) + 1
  elseif n > b then
    return a + (n - b) - 1
  end
  return n
end

local function bound(a, b, n)
  if n < a then
    return a
  elseif n > b then
    return b
  end
  return n
end

local finD = function(n, i)
  return n.data.pow[i]
end

function operator.prime(n)
  local data = n.data

  data.frameX = data._settings.dir or 0

  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.pow = data.pow or {[0] = 0, [1] = 0, [2] = 0, [3] = 0}
  data.powerPrev = data.powerPrev or 0
  data.diff = data.diff or 0
  data.timer = data.timer or 0

  data.redhitbox = redstone.basicRedHitBox(n)
end

local function chooseDir(n, frameX)
  if frameX == 0 then
    return n.width*-0.5, 0, n.width*0.5, n.height
  elseif frameX == 1 then
    return 0, n.height*-0.5, n.width, n.height*0.5
  elseif frameX == 2 then
    return n.width, 0, n.width*0.5, n.height
  else
    return 0, n.height, n.width, n.height*0.5
  end
end

local side_eyes = 0
local side_mouth = 0
local side_plus = 0
local side_minus = 0


operator.op = {}
operator.op.gand = function(n)
  return (finD(n, side_eyes) > 0 and finD(n, side_minus) > 0)
end
operator.op.gxor = function(n)
  local te = finD(n, side_eyes) > 0
  local tp = finD(n, side_plus) > 0
  return (te or tp) and not (te and tp)
end
operator.op.dpos = function(n)
  if n.data.diff > 0 then
    return n.data.diff
  end
  return 0
end
operator.op.dneg = function(n)
  if n.data.diff < 0 then
    return -n.data.diff
  end
  return 0
end
operator.op.diff = function(n)
  if n.data.diff then
    return math.abs(n.data.diff)
  end
  return 0
end
operator.op.cmax = function(n)
  return math.max(finD(n, side_eyes), finD(n, side_minus))
end
operator.op.cmin = function(n)
  return math.min(finD(n, side_eyes), finD(n, side_plus))
end

function operator.onTick(n)
  local data = n.data
  data.observ = false

  side_eyes = n.data.frameX
  side_mouth = tie(0, 3, n.data.frameX + 2)
  side_plus = tie(0, 3, n.data.frameX - 1)
  side_minus = tie(0, 3, n.data.frameX + 1)

  data.power = bound(0, 15, finD(n, side_eyes) + finD(n, side_plus) - finD(n, side_minus))
  -- Text.print(finD(n, side_eyes) .. "-".. finD(n, side_plus) .. "-".. finD(n, side_minus), n.x - camera.x + 32, n.y - camera.y + 64)
  if n.data.powerPrev ~= n.data.power then
    n.data.diff = n.data.power - n.data.powerPrev
    n.data.timer = 5
  end
  if n.data.timer <= 0 then
    n.data.diff = 0
  else
    n.data.timer = n.data.timer - 1
  end

  if finD(n, 0) == 0 and finD(n, 1) == 0 and finD(n, 2) == 0 and finD(n, 3) == 0 then
    data.frameY = 0
  else
    data.frameY = 1
  end


  redstone.updateRedHitBox(n)

  redstone.passDirectionEnergy{source = n, power = data.power, hitbox = data.redhitbox[side_mouth + 1]}

  redstone.passDirectionEnergy{source = n, power = 0, hitbox = data.redhitbox[side_plus + 1]}

  redstone.passDirectionEnergy{source = n, power = 0, hitbox = data.redhitbox[side_minus + 1]}


  if (data.power == 0 and data.powerPrev ~= 0) or (data.power ~= 0 and data.powerPrev == 0) then
    data.observ = true
  end

  for i = 0, 3 do
    data.pow[i] = 0
  end
  data.powerPrev = data.power
  data.power = 0
end

function operator.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(operator)

return operator
