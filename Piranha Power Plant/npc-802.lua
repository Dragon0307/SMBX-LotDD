local observer = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

observer.name = "observer"
observer.id = NPC_ID

observer.test = function()
  return "isObserver", function(x)
    return (x == observer.name or x == observer.id)
  end
end

observer.filter = function() end

observer.config = npcManager.setNpcSettings({
	id = observer.id,

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
  npcblock = true,

  poweronmove = true
})

function observer.prime(n)
  local data = n.data

  data.frameX = data._settings.dir or 0
  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.powerTimer = data.powerTimer or 0
  data.isOn = data.isOn or false
  data.observNotice = data.observNotice or false
  data.prevX = data.prevX or math.floor(n.x)
  data.prevY = data.prevY or math.floor(n.y)

  local x, y, w, h = redstone.facingHitBox(n, data.frameX)
  data.observbox = Colliders.Box(x, y, w, h)
  data.redhitbox = redstone.basicDirectionalRedHitBox(n, (data.frameX + 2)%4)
end

function observer.onTick(n)
  local data = n.data
  data.observ = false

  if data.isOn then
    redstone.updateDirectionalRedHitBox(n, (data.frameX + 2)%4)
    redstone.passDirectionEnergy{source = n, power = data.power, hitbox = data.redhitbox}

    data.powerTimer = data.powerTimer + 1
    if data.powerTimer == 4 then
      data.observ = true
    end
    if data.powerTimer >= 5 and not data.observNotice then
      data.powerTimer = 0
      data.isOn = false
    end
  end

  if data.isOn  then
    data.frameY = 1
  else
    data.frameY = 0
  end

  data.observNotice = false
end

local filter = function(n) return n.data.observ end

function observer.onTickObserver(n)
  local data = n.data

  data.observbox.x, data.observbox.y = redstone.facingHitBox(n, data.frameX)
  for _, v in ipairs(Colliders.getColliding{a = data.observbox, b = NPC.ALL, btype = Colliders.NPC, filter = filter}) do
    data.isOn = true
    data.power = v.data.observpower
    data.observNotice = true
    break
  end

  if observer.config.poweronmove then
    n.x = math.floor(n.x)
    n.y = math.floor(n.y)
    if data.prevX ~= n.x or data.prevY ~= n.y then
      data.isOn = true
      data.observNotice = true
    end
    data.prevX = n.x
    data.prevY = n.y
  end
end

function observer.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(observer)

return observer
