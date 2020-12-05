local deadsickblock = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

deadsickblock.name = "deadsickblock"
deadsickblock.id = NPC_ID

deadsickblock.test = function()
  return "isDeadsickblock", function(x)
    return (x == deadsickblock.name or x == deadsickblock.id)
  end
end

deadsickblock.filter = function(n, c, p, d, hitbox)
  if (n.data.power == 0 and n.data.mode == 1 or c.id ~= deadsickblock.id) then
    redstone.setEnergy(n, p)
    redstone.updateRedArea(n)
    redstone.updateRedHitBox(n)
    redstone.passEnergy{source = n, power = 15, hitbox = n.data.redhitbox, area = n.data.redarea, npcList = deadsickblock.id, filter = function(v) return v.data.mode == 1 and v.data.power == 0 and c ~= v end}
  end
end

deadsickblock.config = npcManager.setNpcSettings({
	id = deadsickblock.id,

	gfxwidth = 32,
	gfxheight = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
  foreground = true,
  invisible = false,

	frames = 1,
	framespeed = 8,
	framestyle = 0,

	width = 32,
	height = 32,

  nogravity = true,
	jumphurt = true,
  notcointransformable = true,
	nohurt = true,
	noyoshi = true,
  noblockcollision = true,
  blocknpc = false,
  blocknpctop = false,
  playerblock = false,
  playerblocktop = false
})

deadsickblock.prime = redstone.component.sickblock.prime

function deadsickblock.onTick(n)
  local data = n.data
  data.observ = false

  if data.mode == 1 and data.power == 0 and data.deathTimer == 0 then
    data.deathTimer = 5
    data.observ = true
  end

  data.frameY = data.mode

  if data.deathTimer > 0 then
    data.deathTimer = data.deathTimer - 1
    data.frameY = 2
    if data.deathTimer == 0 then
      data.isDead = false
      data.power = 0
      data.pistIgnore = false
      n.friendly = false
      data.priority = nil
      n.id = redstone.component.sickblock.id
      if redstone.onScreenSound(n) then
        SFX.play(14)
      end
    end
  end

  data.power = 0
end

function deadsickblock.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(deadsickblock)

return deadsickblock
