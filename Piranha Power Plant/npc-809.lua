local lever = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

lever.name = "lever"
lever.id = NPC_ID

lever.test = function()
  return "isLever", function(x)
    return (x == lever.name or x == lever.id)
  end
end

lever.filter = function() end

lever.config = npcManager.setNpcSettings({
	id = lever.id,

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
	nogravity = false,
  notcointransformable = true,
  nohurt = true,
	noblockcollision = 0,
	nofireball = 1,
	noiceball = 1,
	noyoshi = 1,
	speed = 0,
  npcblock = true,
	iswalker = true
})
npcManager.registerHarmTypes(lever.id, {HARM_TYPE_JUMP, HARM_TYPE_SPINJUMP}, {[HARM_TYPE_JUMP] = 10, [HARM_TYPE_SPINJUMP] = 10})

local sfxtoggle = 2

function lever.prime(n)
  local data = n.data

  data.isOn = data._settings.state == 1

  data.frameX = data.frameX or 0
  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.observTimer = data.observTimer or 0
  data.countdown = data.countdown or 0

  data.redarea = data.redarea or redstone.basicRedArea(n)
  data.redhitbox = data.redhitbox or redstone.basicRedHitBox(n)
end

function lever.onTick(n)
  local data = n.data
  if data.observTimer > 0 then
    data.observTimer = data.observTimer - 1
  else
    data.observ = false
  end

  if data.countdown > 0 then
    data.countdown = data.countdown - 1
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

function lever.onDraw(n)
  redstone.drawNPC(n)
end

function lever.onNPCHarm(event, n, reason, culprit)
	if n.id == lever.id and (reason == HARM_TYPE_JUMP or reason == HARM_TYPE_SPINJUMP) then
    if n.data.countdown == 0 then
      n.data.isOn = not n.data.isOn
      n.data.observ = true
      n.data.observTimer = 1
      n.data.countdown = 5
      SFX.play(sfxtoggle)
    end
    event.cancelled = true
  end
end

function lever.onInitAPI()
	registerEvent(lever, "onNPCHarm", "onNPCHarm")
end

redstone.register(lever)

return lever
