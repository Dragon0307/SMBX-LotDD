local redblock = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

redblock.name = "redblock"
redblock.id = NPC_ID

redblock.test = function()
  return "isRedblock", function(x)
    return (x == redblock.name or x == redblock.id)
  end
end

redblock.filter = function(n, c, p, d, hitbox)
  if n.data.origin == 1 then
    n.data.frameX = 0
  elseif n.data.origin == 2 then
    n.data.frameX = 0
    n.data.countdown = n.data.delay*10
  end
  redstone.setEnergy(n, p)
end

redblock.config = npcManager.setNpcSettings({
	id = redblock.id,

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

  grabtop = true,
  notcointransformable = true,
  grabside = true,
  nogravity = false,
	jumphurt = false,
	nohurt = true,
  noiceball = true,
	noyoshi = false,
  harmlessgrab = true,
  npcblocktop = false,
  blocknpc = true,
  blocknpctop = true,
  playerblock = true,
  playerblocktop = true
})
npcManager.registerHarmTypes(redblock.id, {HARM_TYPE_LAVA}, {[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5}})

function redblock.prime(n)
  local data = n.data

  data.frameX = data._settings.type or 0

  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.delay = data._settings.delay or 6
  data.countdown = data.countdown or 0
  data.origin = data.frameX

  data.redarea = data.redarea or redstone.basicRedArea(n)
  data.redhitbox = data.redhitbox or redstone.basicRedHitBox(n)
end

local pswitch = false

function redblock.onTick(n)
  local data = n.data
  data.observ = false

  if n.collidesBlockBottom then
		n.speedX = n.speedX*0.5
	end

  if data.origin == 0 then
  elseif data.origin == 1 then
  elseif data.origin == 2 then
    if data.frameX == 0 then
      data.countdown = data.countdown - 1
    end
    if data.countdown <= 0 then
      data.frameX = 2
      data.observ = true
    end
  elseif data.origin == 3 then
    if not pswitch and data.frameX == 0 then
      data.frameX = 3
      data.observ = true
    elseif pswitch and data.frameX == 3 then
      data.frameX = 0
      data.observ = true
    end
  end

  if data.frameX == 0 then
    redstone.updateRedArea(n)
    redstone.updateRedHitBox(n)
    redstone.passEnergy{source = n, power = 15, hitbox = data.redhitbox, area = data.redarea}
  end

  data.powerPrev = data.power
  data.power = 0
end

function redblock.onDraw(n)
  redstone.drawNPC(n)

  local data = n.data
  if data.origin == 2 and data.frameX == 0 then
    local color = Color.red
    if data.powerPrev == 0 then color = Color.green end
    local x = n.x + math.floor(0.15*n.width)
    local w = math.floor(n.width*0.7)
    Graphics.drawBox{x = x, y = n.y - 10, width = w, height = 4, color = Color.gray, sceneCoords = true}
    Graphics.drawBox{x = x, y = n.y - 10, width = math.floor(n.data.countdown/n.data.delay*w*0.1), height = 4, color = color, sceneCoords = true}
  end
end

function redblock.onEvent(eventName)
  if eventName == "P Switch - Start" then
    pswitch = true
  elseif eventName == "P Switch - End" then
    pswitch = false
  end
end

function redblock.onInitAPI()
	registerEvent(redblock, "onEvent", "onEvent")
end

redstone.register(redblock)

return redblock
