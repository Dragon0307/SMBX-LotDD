local chest = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

chest.name = "chest"
chest.id = NPC_ID

chest.test = function()
  return "isChest", function(x)
    return (x == chest.name or x == chest.id)
  end
end

chest.filter = function() end

chest.config = npcManager.setNpcSettings({
  id = chest.id,

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
  grabside = true,
  nogravity = false,
	jumphurt = true,
	nohurt = true,
  notcointransformable = true,
  noyoshi = false,
  harmlessgrab = true,
  blocknpc = true,
  blocknpctop = true,
  playerblock = false,
  playerblocktop = true
})

local sfxbreak = Audio.SfxOpen(Misc.resolveFile("piston-extend.ogg"))
local enderchestinvIDList = {0}


function chest.prime(n)
  local data = n.data

  data.frameX = data._settings.type or 0
  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.invList = data._settings.inv

  if data.invList ~= "" and data.invList ~= "0" then
    data.invList = string.split(data.invList, ",")
    for i = 1, #data.invList do
      data.invList[i] = tonumber(data.invList[i])
    end
    if data.frameX == 2 then
      enderchestinvIDList = table.iclone(data.invList)
    end
  else
    data.invList = {0}
  end

  data.invOut = data.invList[1]
  data.invCurr = 1

  data.timer = data.timer or 0
  data.amount = data._settings.quantity or 1

  data.redhitbox = redstone.basicDirectionalRedHitBox(n, 3)
  data.invspace = true
end

function chest.onTick(n)
  local data = n.data

  if n.collidesBlockBottom then
		n.speedX = n.speedX * 0.5
	end

  if data.inv ~= 0 then
    if data.frameX == 2 then
      enderchestinvIDList = {data.inv}
    else
      data.invList = {data.inv}
    end
    data.invCurr = 1
    data.inv = 0
  end

  if data.frameX == 2 then
    data.invList = enderchestinvIDList

  end

  data.invOut = data.invList[data.invCurr]

  if data.invOut == 0 then
    data.observ = false
  else
    data.observ = true
  end

  if data.invOut and data.invOut ~= 0 then
    redstone.updateDirectionalRedHitBox(n, 3)
    local passed = redstone.passInventory{source = n, npcList = redstone.component.hopper.id, inventory = data.invOut, hitbox = data.redhitbox}
    if passed then
      data.invCurr = data.invCurr + 1
      if data.invCurr > #data.invList then
        data.invCurr = 1
      end

      if data.frameX == 1 then
        data.amount = data.amount - 1
        if data.amount == 0 then
          local e = Animation.spawn(10, n.x, n.y)
          e.x = n.x + 0.5*n.width - e.width*0.5
          e.y = n.y + 0.5*n.height - e.height*0.5
          SFX.play(sfxbreak)
          n:kill()
        end
      end
    end
  end

  data.power = 0
end

function chest.onDraw(n)
  redstone.drawNPC(n)
end



redstone.register(chest)

return chest
