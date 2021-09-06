local tnt = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

tnt.name = "tnt"
tnt.id = NPC_ID

tnt.test = function()
  return "isTnt", function(x)
    return (x == tnt.name or x == tnt.id)
  end
end

tnt.config = npcManager.setNpcSettings({
	id = tnt.id,

	gfxwidth = 32,
	gfxheight = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
  invisible = false,

	frames = 2,
	framespeed = 8,
	framestyle = 0,

	width = 32,
	height = 32,

  nogravity = false,
	jumphurt = true,
  notcointransformable = true,
	nohurt = true,
	noyoshi = true,
  blocknpc = true,
  playerblock = true,
  playerblocktop = true,
  npcblock = true,
  radius = 128,
  explosiontimer = 130
})

local explosionID

local sfxcharge = Audio.SfxOpen(Misc.resolveFile("tnt-charge.ogg"))
local sfxexplode  = Audio.SfxOpen(Misc.resolveFile("tnt-explosion.ogg"))

function tnt.prime(n)
  local data = n.data

  data.frameX = data.frameX or 0
  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.timer = data.timer or 0
  data.isexploding = false
  data.willexploding = 0
end



function tnt.onTick(n)
  local data = n.data
  data.observ = false

  if n.collidesBlockBottom then
		n.speedX = n.speedX*0.5
	end

  if data.isexploding then
    data.timer = data.timer - 1
    if data.timer <= 0 then
      SFX.play(sfxexplode)
      local cx, cy = n.x + 0.5*n.width, n.y + 0.5*n.height
      local r = tnt.config.radius
      local explosionhitbox = Colliders.Circle(cx, cy, r)
      Explosion.spawn(cx, cy, explosionID)
      for _, v in ipairs(Colliders.getColliding{a = explosionhitbox, b = NPC.ALL, btype = Colliders.NPC, filter = function(v) return v ~= n end}) do
        local c = NPC.config[v.id]
        if not c.nogravity then
          local t = vector.v2(v.x + 0.5*v.width - cx, v.y + 0.5*v.height - cy)
          t = 6*t:normalise()
          v.speedX, v.speedY = math.max(-8, math.min(8, v.speedX + t.x)), math.max(-8, math.min(8, 1.1*(v.speedY + t.y)))
        end
        if v.id == tnt.id then
          if v.data.isexploding then
            v.data.timer = 0
          else
            v.data.willexploding = 2
            v.data.timer = math.floor(tnt.config.explosiontimer*0.5)
          end
        elseif redstone.isSickblock(v.id) then
          v.data.power = 15
        end
      end
      data.isexploding = false
      n:kill()
    end
  elseif data.willexploding > 0 then
    data.willexploding = data.willexploding - 1
    if data.willexploding == 0 then
      data.isexploding = true
    end
  elseif data.power > 0 then
      SFX.play(sfxcharge)
      data.timer = tnt.config.explosiontimer
      data.isexploding = true
      data.observ = true
  end

  if data.isexploding then
    data.frameY = 1
  else
    data.frameY = 0
  end

  data.power = 0
end

function tnt.onDraw(n)
  redstone.drawNPC(n)
end

function tnt.onStart()
  explosionID = Explosion.register(tnt.config.radius, 69, Misc.multiResolveFile("nitro.ogg", "sound/extended/nitro.ogg"), true, false)
end

function tnt.onInitAPI()
	registerEvent(tnt, "onStart", "onStart")
end
redstone.register(tnt)

return tnt
