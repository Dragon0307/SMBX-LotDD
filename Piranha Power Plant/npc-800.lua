local dust = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

dust.name = "dust"
dust.id = NPC_ID

dust.test = function()
  return "isDust", function(x)
    return (x == dust.name or x == dust.id)
  end
end

dust.config = npcManager.setNpcSettings({
	id = dust.id,

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

  noblockcollision = true,
  notcointransformable = true,
  nogravity = true,
	jumphurt = true,
	nohurt = true,
	noyoshi = true,

  basicdust = false,
  automap = true
})

local dustMap = {}
dustMap["true true true true"] = 1
dustMap["true false true false"] = 2
dustMap["false true false true"] = 3
dustMap["false false true true"] = 4
dustMap["false true true false"] = 5
dustMap["true true false false"] = 6
dustMap["true false false true"] = 7
dustMap["true false true true"] = 8
dustMap["false true true true"] = 9
dustMap["true true true false"] = 10
dustMap["true true false true"] = 11
dustMap["true false false false"] = 12
dustMap["false true false false"] = 13
dustMap["false false true false"] = 14
dustMap["false false false true"] = 15
dustMap["false false false false"] = 16

local function found(n, x, y, w, h)
  for _, v in ipairs(NPC.getIntersecting(x, y, x + w, y + h)) do
    if v.id == dust.id and n.layerName == v.layerName then
      return true
    end
  end
  return false
end

local function setFrameX(n)
  local x, y, w, h
  x, y, w, h = redstone.facingHitBox(n, 0)
  local fLeft = tostring(found(n, x, y, w, h))
  x, y, w, h = redstone.facingHitBox(n, 1)
  local fUp = tostring(found(n, x, y, w, h))
  x, y, w, h = redstone.facingHitBox(n, 2)
  local fRight = tostring(found(n, x, y, w, h))
  x, y, w, h = redstone.facingHitBox(n, 3)
  local fDown = tostring(found(n, x, y, w, h))
  n.data.frameX = dustMap[fLeft.." "..fUp.." "..fRight.." "..fDown] or 0
end

local nofilter = function() return true end

-- Look guys, I tried my best here.
local function instantpower(n, data)
  local list = Colliders.getColliding{a = data.redarea, b = redstone.comID, btype = Colliders.NPC, filter = nofilter}
  for i, c in ipairs(data.redhitbox) do
    if not data.powdir[(i+2)%4] then
      for k = #list, 1, -1 do
        local v = list[k]
        if Colliders.collide(v, c) then
          table.remove(list, k)
          if v.id == dust.id then
            if v ~= n and data.power > v.data.power + 1 then
              v.data.powdir[i] = true
              v.data.check = true
              redstone.setEnergy(v, data.power - 1)
              redstone.updateRedArea(v)
              redstone.updateRedHitBox(v)
              v:instantpower(v.data)
            end
          else
            redstone.energyAI(v, n, data.power, i - 1, c)
          end
        end
      end
    end
  end
end

function dust.prime(n)
  local data = n.data

  data.frameX = data._settings.mapX or 1
  data.frameX = data.frameX - 1

  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.powdir = data.powdir or {}
  data.check = data.check or false
  data.powerPrev = data.powerPrev or 0
  data.pistIgnore = data.pistIgnore or true

  data.redarea = data.redarea or redstone.basicRedArea(n)
  data.redhitbox = data.redhitbox or redstone.basicRedHitBox(n)

  n.instantpower = instantpower
  n.priority = -46

  if dust.config.automap and data.frameX == 0 then
    setFrameX(n)
  end
end




if dust.config.basicdust then
  dust.energyAI = function(n, c, p, d)
    if c.id == dust.id then
      redstone.setEnergy(n, p - 1)
    else
      redstone.setEnergy(n, p)
    end
  end
  function dust.onTick(n)
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

    if data.power == 0 then
      data.frameY = 0
    elseif data.power >= 8 then
      data.frameY = 2
    else
      data.frameY = 1
    end

    data.powerPrev = data.power
    data.power = 0
  end
else
  dust.energyAI = function(n, c, p, d, hitbox)
    if not redstone.isDust(c.id) then
      n.data.powdir = {}
      n.data.powdir[d + 1] = true
      n.data.check = true
      redstone.setEnergy(n, p)
      redstone.updateRedArea(n)
      redstone.updateRedHitBox(n)
      n:instantpower(n.data)
    end
    -- if (n.data.power == 0 or n.data.power < p or c.id ~= dust.id) then
    --     redstone.setEnergy(n, p)
    --     redstone.updateRedArea(n)
    --     redstone.updateRedHitBox(n)
    --     redstone.passEnergy{source = n, power = n.data.power - 1, hitbox = n.data.redhitbox, area = n.data.redarea, filter = function(v) return ((v.data.power == 0 and v.data.id == dust.id) or v.data.id ~= dust.id) and c ~= v and (p > 1 or v.id ~= dust.id) end}
    -- end
  end
  function dust.onTick(n, v)
    local data = n.data
    data.observ = false

    -- if not v and data.check then return end
    -- if data.power > 0 then
    --   redstone.updateRedArea(n)
    --   redstone.updateRedHitBox(n)
    --   instantpower(n, n.data)
    -- end
    -- data.power = 0
  end

  function dust.onTickEnd(n)
    local data = n.data

    if data.powerPrev ~= data.power then
      data.observ = true
    else
      data.observ = false
    end

    if data.power == 0 then
      data.frameY = 0
    elseif data.power >= 8 then
      data.frameY = 2
    else
      data.frameY = 1
    end

    -- Text.print(data.power, n.x - camera.x, n.y - camera.y)
    data.powerPrev = data.power
    data.power = 0
    data.check = false
    data.powdir = {}
  end
end

dust.filter = dust.energyAI

function dust.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(dust)

return dust
