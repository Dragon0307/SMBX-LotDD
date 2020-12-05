local hopper = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

hopper.name = "hopper"
hopper.id = NPC_ID

hopper.test = function()
  return "isHopper", function(x)
    return (x == hopper.name or x == hopper.id)
  end
end

hopper.config = npcManager.setNpcSettings({
	id = hopper.id,

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
  noblockcollision = true,
  notcointransformable = true,
	jumphurt = true,
	nohurt = true,
	noyoshi = true,
  blocknpc = true,
  playerblock = true,
  playerblocktop = true,
  npcblock = true
})

local function chooseDir(n, frameX)
  if frameX == 0 then
    return -n.width*0.5, n.height*0.05, n.width*0.5, n.height*0.9
  elseif frameX == 1 then
    return n.width*0.05, -n.height*0.5, n.width*0.9, n.height*0.5
  elseif frameX == 2 then
    return n.width, n.height*0.05, n.width*0.5, n.height*0.9
  else
    return n.width*0.05, n.height, n.width*0.9, n.height*0.5
  end
end

function hopper.prime(n)
  local data = n.data

  data.frameX = data._settings.dir or 0
  data.inv = data._settings.inv or 0

  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.powerPrev = data.powerPrev or 0
  data.timer = data.timer or 0
end

function hopper.onTick(n)
  local data = n.data

  if data.inv ~= 0 then
    data.observ = true
    data.invspace = false
  else
    data.observ = false
    data.invspace = true
  end


  if data.power == 0 and data.inv ~= 0 then
    data.timer = data.timer + 1
    if data.timer >= 8 or data.powerPrev > 0 then
      data.timer = 0
      redstone.updateDirectionalRedHitBox(n, data.frameX)
      local passed = redstone.passInventory{source = n, inventory = data.inv, hitbox = data.redhitbox}
      if passed then
        data.inv = 0
        data.invspace = true
      else
        data.invspace = false
      end
    end
  end

  if data.power == 0 then
    data.frameY = 0
  else
    data.frameY = 1
  end

  data.powerPrev = data.power
  data.power = 0

  data.redhitbox = redstone.basicDirectionalRedHitBox(n, data.frameX)
end

function hopper.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(hopper)

return hopper
