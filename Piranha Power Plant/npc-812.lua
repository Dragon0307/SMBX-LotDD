local spyblock = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

spyblock.name = "spyblock"
spyblock.id = NPC_ID

spyblock.test = function()
  return "isSpyblock", function(x)
    return (x == spyblock.name or x == spyblock.id)
  end
end

spyblock.filter = function(n, c, p, d, hitbox)
  if redstone.isOperator(c.id) then
    redstone.setEnergy(n, p)
  end
end

spyblock.config = npcManager.setNpcSettings({
	id = spyblock.id,

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
  notcointransformable = true,
	jumphurt = true,
  noblockcollision = true,
	nohurt = true,
	noyoshi = true,
  blocknpc = true,
  playerblock = true,
  playerblocktop = true,
  npcblock = true
})



function spyblock.prime(n)
  local data = n.data

  data.frameX = data._settings.dir or 0
  data.frameY = data._settings.type or 0

  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.prevState = data.prevState or 0
  data.type = data.frameY or 0

  if data._settings.whitelist ~= "" then
    local t = string.split(data._settings.whitelist, ",")
    data.whitelist = {}
    for k, v in ipairs(t) do
      data.whitelist[tonumber(v)] = true
    end
  else
    data.whitelist = false
  end

  data.isOn = data.isOn or false

  data.redhitbox = redstone.basicDirectionalRedHitBox(n, (data.frameX + 2)%4)
end

function spyblock.onTick(n)
  local data = n.data
  data.observ = false

  if data.frameY < 3 then
    data.type = data.frameY
  end

  local func, check
  if data.type == 0 then
    func = Player.getIntersecting
    check = "character"
  elseif data.type == 1 then
    func = NPC.getIntersecting
    check = "id"
  elseif data.type == 2 then
    func = Block.getIntersecting
    check = "id"
  end

  if data.power > 0 then
    data.isOn = true
    redstone.updateDirectionalRedHitBox(n, (data.frameX + 2)%4)
    redstone.passDirectionEnergy{source = n, power = data.power, hitbox = data.redhitbox}
    if not data.prevState then
      data.observ = true
    end
  end

  local x, y, w, h = redstone.collisionBox(n, data.frameX)
  for _, v in ipairs(func(x, y, x + w, y + h)) do
    if v and (not data.whitelist or data.whitelist[v[check]]) and not v.isHidden then
      data.isOn = true

      redstone.updateDirectionalRedHitBox(n, (data.frameX + 2)%4)
      redstone.passDirectionEnergy{source = n, power = 15, hitbox = data.redhitbox}

      if not data.prevState then
        data.observ = true
      end
      break
    end
  end

  if not data.isOn and data.prevState then
    data.observ = true
  end


  if data.isOn  then
    data.frameY = 3
  else
    data.frameY = data.type
  end

  data.prevState = data.isOn
  data.isOn = false
  data.power = 0
end

function spyblock.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(spyblock)

return spyblock
