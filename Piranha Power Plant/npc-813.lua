local dropper = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

dropper.name = "dropper"
dropper.id = NPC_ID

dropper.test = function()
  return "isDropper", function(x)
    return (x == dropper.name or x == dropper.id)
  end
end

dropper.config = npcManager.setNpcSettings({
	id = dropper.id,

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
  notcointransformable = true,
  noblockcollision = true,
	jumphurt = true,
	nohurt = true,
	noyoshi = true,
  blocknpc = true,
  playerblock = true,
  playerblocktop = true,
  npcblock = true
})

local sfxdrop = Audio.SfxOpen(Misc.resolveFile("dropper-drop.ogg"))

local function chooseDir(n, frameX, v)
  if frameX == 0 then
    return -1*v.width, (n.height - v.height)
  elseif frameX == 1 then
    return 0.5*(n.width - v.width), -v.height
  elseif frameX == 2 then
    return n.width, (n.height - v.height)
  elseif frameX == 3 then
    return 0.5*(n.width - v.width), n.height
  end
end

function dropper.prime(n)
  local data = n.data

  data.frameX = data._settings.dir or 0
  data.inv = data._settings.inv or 0

  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.overwrite = data._settings.overwrite or false
  data.autofire = data._settings.autofire or false
  data.prevPower = data.prevPower or false
end

function dropper.onTick(n)
  local data = n.data
  data.observ = false

  if data.inv > 0 then
    data.observ = true
    data.invspace = false
  else
    data.invspace = true
  end

  if data.overwrite then
    data.invspace = true
  end

  if data.power > 0 and data.prevPower == 0 or (data.inv > 0 and data.autofire) then
    if not (data.inv > 0 and data.inv < 1000) then
      local v = Animation.spawn(10, 0, 0)
      local x, y = chooseDir(n, n.data.frameX, v)
      v.x = n.x + x
      v.y = n.y + y
    else
      local v = NPC.spawn(data.inv, 0, 0, player.section)
      local x, y = chooseDir(n, n.data.frameX, v)
      v.x = n.x + x
      v.y = n.y + y
      local e = Animation.spawn(10, v.x + 0.5*v.width - 16, v.y + 0.5*v.height - 16)
    end
    if redstone.onScreenSound(n) then
      SFX.play(sfxdrop)
    end
    data.inv = 0
  end

  data.prevPower = data.power
  data.power = 0
end

function dropper.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(dropper)

return dropper
