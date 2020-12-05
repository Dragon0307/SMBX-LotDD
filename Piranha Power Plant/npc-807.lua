local sickblock = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

sickblock.name = "sickblock"
sickblock.id = NPC_ID

sickblock.test = function()
  return "isSickblock", function(x)
    return (x == sickblock.name or x == sickblock.id)
  end
end

local found = false
sickblock.filter = function(n, c, p, d, hitbox)
  found = true
  redstone.setEnergy(n, p)
end

sickblock.config = npcManager.setNpcSettings({
  id = sickblock.id,

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
  npcblock = true
})

local sfxpower = Audio.SfxOpen(Misc.resolveFile("sickblock-power.ogg"))
local sfxdeath = Audio.SfxOpen(Misc.resolveFile("sickblock-death.ogg"))

function sickblock.prime(n)
  local data = n.data

  data.frameX = data._settings.type or 0

  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.mode = data._settings.mode or 0
  data.isDead = data.isDead or false
  data.deathTimer = data.deathTimer or 0

  data.redarea = data.redarea or redstone.basicRedArea(n)
  data.redhitbox = data.redhitbox or redstone.basicRedHitBox(n)
end



function sickblock.onTick(n)
  local data = n.data
  data.observ = false

  if data.isDead and data.deathTimer > 0 then
    data.deathTimer = data.deathTimer - 1
    if data.deathTimer == 0 then
      found = false
      if data.frameX ~= 1 then
        redstone.updateRedArea(n)
        redstone.updateRedHitBox(n)
        redstone.passEnergy{source = n, power = 15, hitbox = data.redhitbox, area = data.redarea, npcList = sickblock.id, filter = function(v) return not v.data.isDead end}
        if data.frameX == 2 and data.immune then
          data.immune = false
          data.isDead = false
          n.friendly = false
        end
      end
      if not found and redstone.onScreenSound(n) then
        SFX.play(sfxdeath)
      end
    end
  end


  if data.power > 0 and not data.isDead then
    if redstone.onScreenSound(n) then
      SFX.play(sfxpower)
    end
    data.observ = true
    data.deathTimer = 4
    data.isDead = true
    data.pistIgnore = true
    n.friendly = true
    redstone.component.reaper.onPostNPCKill(n)
  end

  if data.isDead then
    if data.deathTimer == 0 then
      data.priority = -5
      data.frameY = 0
      n.id = redstone.component.deadsickblock.id
    else
      data.frameY = 2
    end
  else
    data.frameY = data.mode
  end

  data.power = 0
end

function sickblock.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(sickblock)

return sickblock
