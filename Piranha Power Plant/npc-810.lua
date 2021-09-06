local button = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

button.name = "button"
button.id = NPC_ID

button.test = function()
  return "isButton", function(x)
    return (x == button.name or x == button.id)
  end
end

button.filter = function() end

button.config = npcManager.setNpcSettings({
	id = button.id,

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

  jumphurt = 0,
  nohurt = true,
  notcointransformable = true,
	nogravity = false,
	noblockcollision = 0,
	nofireball = 1,
	noiceball = 1,
	noyoshi = 1,
	speed = 0,
  npcblock = true,
	iswalker = true
})
npcManager.registerHarmTypes(button.id, {HARM_TYPE_JUMP, HARM_TYPE_SPINJUMP}, {[HARM_TYPE_JUMP] = 10, [HARM_TYPE_SPINJUMP] = 10})

local sfxtoggle = 2

function button.prime(n)
  local data = n.data

  data.delay = data._settings.delay or 2
  data.frameX = data._settings.type or 0
  if data._settings.state == 1 then
    data.isOn = true
  else
    data.isOn = false
  end

  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.observTimer = data.observTimer or 0
  data.countdown = data.countdown or 0

  data.redarea = data.redarea or redstone.basicRedArea(n)
  data.redhitbox = data.redhitbox or redstone.basicRedHitBox(n)
end

function button.onTick(n)
  local data = n.data
  if data.observTimer > 0 then
    data.observTimer = data.observTimer - 1
  else
    data.observ = false
  end

  if data.isOn and data.countdown == 0 then
    n.data.countdown = n.data.delay*10
  end

  if data.countdown > 0 then
    data.countdown = data.countdown - 1
    if data.countdown == 0 then
      n.data.observ = true
      data.isOn = false
      if data.frameX == 1 then
        n:kill()
      end
    end
  end

  if data.isOn then
    redstone.updateRedArea(n)
    redstone.updateRedHitBox(n)
    redstone.passEnergy{source = n, power = 15, hitbox = data.redhitbox, area = data.redarea}
  end

  if data.isOn then
    data.frameY = 1
  else
    data.frameY = 0
  end

  data.power = 0
end

function button.onDraw(n)
  redstone.drawNPC(n)
end

function button.onNPCHarm(event, n, reason, culprit)
  if n.id == button.id and (reason == HARM_TYPE_JUMP or reason == HARM_TYPE_SPINJUMP) then
    n.data.isOn = true
    if n.data.countdown == 0 then
      n.data.observ = true
      n.data.observTimer = 1
    end
    if n.data.frameX == 0 or (n.data.frameX == 1 and n.data.countdown == 0) then
      n.data.countdown = n.data.delay*10
    end
    SFX.play(sfxtoggle)
    event.cancelled = true
  end
end

function button.onInitAPI()
	registerEvent(button, "onNPCHarm", "onNPCHarm")
end

redstone.register(button)

return button
