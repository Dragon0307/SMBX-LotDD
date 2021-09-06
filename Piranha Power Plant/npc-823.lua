local flame = {}

local redstone = require("redstone")
local npcManager = require("npcManager")
local rebounder = require("npcs/ai/rebounder")

flame.name = "flame"
flame.id = NPC_ID

flame.test = function()
  return "isFlame", function(x)
    return (x == flame.name or x == flame.id)
  end
end

flame.filter = function() end

flame.config = npcManager.setNpcSettings({
  id = flame.id,
  gfxheight = 32,
  gfxwidth = 32,
  width = 32,
  height = 32,
  gfxoffsety = 0,
  frames = 4,
  framestyle = 0,
  framespeed = 2,
  invisible = false,
  nogravity=1,
  jumphurt = 1,
  nofireball=1,
  noiceball=0,
  grabside=0,
  grabtop=0,
  noyoshi=1,
  playerblock=0,
  spinjumpsafe=true,
  notcointransformable = true,
  nogravity = true,
  noblockcollision = true,
  ishot = true,
  firespeed = 4
})

function flame.prime(n)
  local data = n.data

  data.frameX = data.frameX or 0
  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.angle = data.angle or data._settings.angle or 0
  data.vector = vector.v2(flame.config.firespeed, 0):rotate(-data.angle)
  data.redhitbox = Colliders.Circle(0, 0, 0.5*n.width + 2)

  data.disabledespawn = true
end

local blockfilter = function(d)
  return function(v)
    if v.isHidden or Block.NONSOLID_MAP[v.id] then
      return false
    elseif Block.SEMISOLID_MAP[v.id] then
      return d.y < 0
    end
    return true
  end
end

local npcfilter = function(v, d)
  local c = NPC.config[v.id]
  return c.npcblocktop or c.blocknpc or c.playerblocktop or c.playerblock
end

function flame.onTick(n)
  local data = n.data

  local cx, cy = n.x + 0.5*n.width, n.y + 0.5*n.height
  if data.angle > 360 or data.angle < 0 then
    data.angle = data.angle%360
  end

  data.vector = vector.v2(flame.config.firespeed, 0):rotate(-data.angle)
  data.redhitbox.x, data.redhitbox.y = cx, cy

  local iceList = Colliders.getColliding{a = data.redhitbox, b = {620, 621, 633}, btype = Colliders.BLOCK, filter = function(v) return not v.isHidden end}
  if iceList[1] then
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
    n:kill()
  end

  local iscollision, point, normal, crashcollider
  local blockList = Colliders.getColliding{a = data.redhitbox, b = Block.ALL, btype = Colliders.BLOCK, filter = blockfilter(data.vector)}
  local npcList = Colliders.getColliding{a = data.redhitbox, b = NPC.ALL, btype = Colliders.NPC, filter = npcfilter}

  if blockList[1] then
    local startpoint = vector.v2(cx, cy)
    local endpoint = vector.v2(0.5*n.width + 6, 0):rotate(-data.angle)
    iscollision, point, normal, crashcollider = Colliders.raycast(startpoint, endpoint, blockList)
  end
  if npcList[1] and not iscollision then
    local startpoint = vector.v2(cx, cy)
    local endpoint = vector.v2(0.5*n.width + 6, 0):rotate(-data.angle)
    iscollision, point, normal, crashcollider = Colliders.raycast(startpoint, endpoint, npcList)
  end

  if iscollision then
    data.vector = -2*(data.vector .. normal)*normal + data.vector
    data.angle = math.deg(math.atan2(-data.vector.y, data.vector.x))
  end

  n.speedX = data.vector.x
  n.speedY = data.vector.y
end

function flame.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(flame)

return flame
