local jewel = {}

local redstone = require("redstone")
local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")
local lineguide = require("lineguide")

jewel.name = "jewel"
jewel.id = NPC_ID

jewel.test = function()
  return "isJewel", function(x)
    return (x == jewel.name or x == jewel.id)
  end
end

jewel.config = npcManager.setNpcSettings({
	id = jewel.id,

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

	jumphurt = false,
  noblockcollision = true,
  spinjumpsafe = false,
  nogravity = true,
  notcointransformable = true,
	nohurt = true,
	noyoshi = true,

  poweredframes = 1,
  lightningframes = 3,
  lightningframespeed = 2
})
npcManager.registerHarmTypes(jewel.id, {HARM_TYPE_JUMP, HARM_TYPE_SPINJUMP}, {[HARM_TYPE_JUMP] = 10, [HARM_TYPE_SPINJUMP] = 10})

lineguide.registerNpcs(jewel.id)
local light = Graphics.loadImage(Misc.resolveFile("npc-"..jewel.id.."-1.png"))
local sfxpower = Audio.SfxOpen(Misc.resolveFile("ampedjewel-powered.ogg"))

local sfxjump = 2
local jewid = 0
local reset = {}
local rays = {}

local function shareval(t1, t2)
  for i = 1, #t1 do
    for j = 1, #t2 do
      if t1[i] == t2[j] then return true end
    end
  end
end

function jewel.prime(n)
  local data = n.data

  data.frameX = data._settings.type or 0
  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0
  data.powerPre = 0
  data.powerPrev = 0

  data.hitbox = Colliders.Circle(0, 0, 1000)
  data.active = false
  data.connections = {}


  data.tags = {}
  data.tagstext = string.split(data._settings.tagstext, ",")
  for i = 1, #data.tagstext do
    data.tags[i] = data.tagstext[i]
  end

  jewid = jewid + 1
  data.index = jewid

  data.lightframe = 0
  data.lightanimationframe = 0
end

function jewel.onTick(n)
  local data = n.data
  data.observ = false

  if not (data._basegame.lineguide and data._basegame.lineguide.state == 1) then
		n.speedX, n.speedY = npcutils.getLayerSpeed(n)
	end

  if reset then
    rays = {}
    reset = false
  end

  if data.power > 0 then
    data.frameY = 1
    data.hitbox.x, data.hitbox.y = n.x + 0.5*n.width, n.y + 0.5*n.height


    if n.data.tags[1] ~= "" then
      for _, npc in ipairs(Colliders.getColliding{a = data.hitbox, b = jewel.id, btype = Colliders.NPC, filter = function(npc) return n ~= npc and (not npc.data.connections[n.data.index]) and (npc.data.power > 0 or npc.data.powerPre > 0) and shareval(n.data.tags, npc.data.tags) end}) do
        n.data.active = true
        npc.data.active = true
        n.data.connections[npc.data.index] = true
        table.insert(rays, {start = n, stop = npc, frame = data.lightframe})
      end
    end

    if data.powerPrev == 0 and redstone.onScreenSound(n) then
      SFX.play(sfxpower)
    end
  else
    data.frameY = 0
  end

  if data.power ~= data.powerPrev then
    data.observ = true
  end

  data.powerPre = data.power
  data.powerPrev = data.power
  data.power = 0
end

function jewel.onTickR()
  local pl = Player.get()
  for i = #rays, 1, -1 do
    local ray = rays[i]
    if not ray.start or not ray.stop then
      table.remove(rays, i)
    else
      local start = vector.v2(ray.start.x + 0.5*ray.start.width, ray.start.y + 0.5*ray.start.height)
      local stop = vector.v2(ray.stop.x + 0.5*ray.stop.width, ray.stop.y + 0.5*ray.stop.height)
      for k, p in ipairs(pl) do
        if Colliders.linecast(start, stop, p) then
          p:harm()
        end
      end
    end
  end
end

function jewel.onTickEnd(n)
  n.data.connections = {}
  n.data.active = false
  n.data.powerPre = 0

	reset = true
end

function jewel.onDraw(n)
  n.data.lightanimationframe = n.data.lightanimationframe + 1
  if n.data.lightanimationframe > jewel.config.lightningframespeed then
    n.data.lightanimationframe =  0
    n.data.lightframe = n.data.lightframe + 1
    if n.data.lightframe >= jewel.config.lightningframes then
      n.data.lightframe =  0
    end
  end
  redstone.drawNPC(n)
end

-- Huge Thanks to Mr.DoubleA for helping me getting this to work!
local function tableMultiInsert(tbl,tbl2) -- I suppose that I now use this any time I use glDraw, huh
    for _,v in ipairs(tbl2) do
        table.insert(tbl,v)
    end
end

function jewel.onDrawR()
  if jewel.config.invisible then return end
  local p = -45
  if jewel.config.foreground then
    p = -15
  end
  for i = #rays, 1, -1 do
    local ray = rays[i]
    if ray.start and ray.stop and ray.start.isValid and ray.stop.isValid then
      local start = vector.v2(ray.start.x + 0.5*ray.start.width, ray.start.y + 0.5*ray.start.height)
      local stop = vector.v2(ray.stop.x + 0.5*ray.stop.width, ray.stop.y + 0.5*ray.stop.height)
			local frames = jewel.config.lightningframes
      local frame = ray.frame
      local laserLength = (start - stop).length
      local vertexCoords,textureCoords = {},{}
      local v = start
      local w = (stop - start):normalize()
      local n = (w:normalize()):rotate(90)*light.height/(frames*2)
      while i <= laserLength do
        local segmentLength = math.min(light.width, laserLength - i)
        local y = w*segmentLength
        local z1, z2, z3, z4 = v + n, v - n, v + y + n, v + y - n
        tableMultiInsert(vertexCoords,{z1.x, z1.y, z2.x, z2.y, z4.x, z4.y, z1.x, z1.y, z3.x, z3.y, z4.x, z4.y})
        tableMultiInsert(textureCoords,{0,((frame  )/frames), 0 ,((frame+1)/frames), (segmentLength/light.width),((frame+1)/frames), 0,((frame  )/frames), (segmentLength/light.width),((frame  )/frames), (segmentLength/light.width),((frame+1)/frames)})
        v = v + y
        i = i + light.width
      end
      Graphics.glDraw{texture = light, vertexCoords = vertexCoords,textureCoords = textureCoords, priority = p-0.01,sceneCoords = true}
    end
  end
end

function jewel.onNPCHarm(event, n, reason, culprit)
  if n.id == jewel.id and (reason == HARM_TYPE_JUMP or reason == HARM_TYPE_SPINJUMP) then
    SFX.play(sfxjump)
    if n.data.power > 0 or n.data.powerPre > 0 then
      culprit:harm()
    end
    event.cancelled = true
  end
end

function jewel.onInitAPI()
	registerEvent(jewel, "onNPCHarm", "onNPCHarm")
  registerEvent(jewel, "onTick", "onTickR")
  registerEvent(jewel, "onDraw", "onDrawR")
end

redstone.register(jewel)

return jewel
