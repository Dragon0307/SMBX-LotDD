local reaper = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

reaper.name = "reaper"
reaper.id = NPC_ID

reaper.test = function()
  return "isReaper", function(x)
    return (x == reaper.name or x == reaper.id)
  end
end

reaper.filter = function(n, c, p, d, hitbox)
  if redstone.isOperator(c.id) and p > 0 then
    n.data.isOn = true
    n.data.onTimer = -1
    redstone.setEnergy(n, p)
  end
end

reaper.config = npcManager.setNpcSettings({
	id = reaper.id,

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


local isoul = Graphics.loadImage(Misc.resolveFile("npc-"..reaper.id.."-1.png"))
local sfxeat = Audio.SfxOpen(Misc.resolveFile("reaperblock-consume.ogg"))
local sfxeatfast = Audio.SfxOpen(Misc.resolveFile("reaperblock-consumefast.ogg"))
local ribbontail = Misc.resolveFile("npc-"..reaper.id.."-ribbon.ini")
local ribbonlist = {}

function reaper.prime(n)
  local data = n.data

  data.frameX = data._settings.dir or 0
  data.frameY = data.frameY or 0

  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.prevState = data.prevState or false
  data.type = data.frameY or 0
  data.isOn = data.isOn or false
  data.onTimer = 0
  data.offTimer = 0
  data.souls = {}
  data.queque = 0

  if data._settings.whitelist ~= "" then
    local t = string.split(data._settings.whitelist, ",")
    data.whitelist = {}
    for k, v in ipairs(t) do
      data.whitelist[tonumber(v)] = true
    end
  else
    data.whitelist = false
  end

  data.redhitbox = redstone.basicDirectionalRedHitBox(n, (data.frameX + 2)%4)
end

function reaper.onTick(n)
  local data = n.data
  data.observ = false

  if #data.souls > 0 then
    local cx, cy = n.x + 0.5*n.width, n.y + 0.5*n.height
    for i = #data.souls, 1, -1 do
      local s = data.souls[i]
      local v = vector.v2(cx - s.x, cy -  s.y)
      if v.length < 8 then
        data.queque = data.queque + 1
        s.ribbon.enabled = false
        s.ribbon:Break()
        table.insert(ribbonlist, s.ribbon)
        table.remove(data.souls, i)
      else
        v = v:normalize()*6
        s.x, s.y = s.x + v.x, s.y + v.y
    		s.ribbon.x, s.ribbon.y = s.x, s.y
      end
    end
  end

  if data.queque > 0 and not data.isOn and data.offTimer == 0 then
    data.power = 15
  end

  if data.power > 0 then
    data.isOn = true
  end

  if data.onTimer > 0 then
    data.onTimer = data.onTimer - 1
    data.isOn = true
    if data.onTimer == 0 then
      data.isOn = false
      data.queque = data.queque - 1
      if data.queque > 0 then
        data.offTimer = 5
      end
    end
  end

  if data.offTimer > 0 then
    data.offTimer = data.offTimer - 1
    data.isOn = false
    if data.offTimer == 0 then
      data.isOn = true
    end
  end

  if data.isOn then
    redstone.updateDirectionalRedHitBox(n, (data.frameX + 2)%4)
    redstone.passDirectionEnergy{source = n, power = data.power, hitbox = data.redhitbox}
  end

  local x, y, w, h = redstone.collisionBox(n, data.frameX)
  for _, v in ipairs(NPC.getIntersecting(x, y, x + w, y + h)) do
    if not v.isHidden and v.id ~= redstone.component.operator.id then
      local e = Animation.spawn(10, v.x + 0.5*v.width, v.y + 0.5*v.height)
      e.x, e.y = e.x - 0.5*e.width, e.y - 0.5*e.height
      v:kill()
    end
  end

  if data.isOn and not data.prevState then
    data.onTimer = 5
  elseif not data.isOn and data.prevState then
    data.observ = true
  end

  if data.onTimer == -1 then
    data.onTimer = 0
  end

  if data.isOn or #data.souls > 0  then
    data.frameY = 1
  else
    data.frameY = 0
  end

  data.prevState = data.isOn
  data.isOn = false
  data.power = 0
end

function reaper.onDraw(n)
  redstone.drawNPC(n)

  if reaper.config.invisible then return end
  if #n.data.souls > 0 then
    local hw, hh = isoul.width*0.5, isoul.height*0.5
    for _, s in ipairs(n.data.souls) do
      Graphics.drawImageToScene(isoul, s.x - hw, s.y - hh)
      s.ribbon:Draw(-60)
    end
  end
end

function reaper.onDrawR()
  if reaper.config.invisible then return end

  -- Draw all the dead ribbons
  for k = #ribbonlist, 1, -1 do
    local p = ribbonlist[k]
    if p:Count() > 0 then
      p:Draw(-60)
    else
      table.remove(ribbonlist, k)
    end
  end
end

local function hasSoul(n, v)
  local data = n.data
  if data.whitelist then return data.whitelist[v.id] end
  return redstone.hasSoul(n)
end

function reaper.onPostNPCKill(n, reason)
  if reason == HARM_TYPE_OFFSCREEN then return end
  local l = Colliders.getColliding{a = Colliders.Box(n.x - 800, n.y - 600, 1600 + n.width, 1200 + n.height), b = reaper.id, btype = Colliders.NPC, filter = function() return true end}
  if l then
    local c = -1
    local npc
    local d
    for _, v in ipairs(l) do
      d = (v.x + 0.5*v.width - n.x - 0.5*n.width)^2 + (v.y + 0.5*v.height - n.y - 0.5*n.height)^2
      if c == -1 or d < c and hasSoul(v, n) then
        c = d
        npc = v
      end
    end
    if npc then
      if not reaper.config.invisible then
        local s = {x = n.x + n.width*0.5, y = n.y + n.height*0.5, ribbon = Particles.Ribbon(0, 0, ribbontail)}
        s.ribbon.x, s.ribbon.y = s.x, s.y
        s.ribbon:Emit(1)
        table.insert(npc.data.souls, s)
      end
      if d < 25600 then
        SFX.play(sfxeatfast)
      else
        SFX.play(sfxeat)
      end
    end
  end
end

function reaper.onInitAPI()
	registerEvent(reaper, "onPostNPCKill", "onPostNPCKill")
  registerEvent(reaper, "onDraw", "onDrawR")
end

redstone.register(reaper)

return reaper
